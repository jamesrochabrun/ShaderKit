//
//  JellySwitchShader.metal
//  ShaderKit
//
//  3D ray-marched translucent jelly switch - translated from TypeGPU
//  Original: https://typegpu.com/examples/simulation/jelly-switch
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Constants (from original TypeGPU)

#define MAX_STEPS 64
#define MAX_DIST 10.0
#define SURF_DIST 0.001

#define JELLY_HALFSIZE float3(0.35, 0.3, 0.3)
#define JELLY_IOR 1.42
#define JELLY_SCATTER_STRENGTH 3.0
#define SWITCH_RAIL_LENGTH 0.4

#define LIGHT_GROUND_ALBEDO float3(1.0)
#define DARK_GROUND_ALBEDO float3(0.2)
#define AMBIENT_COLOR float3(0.6)
#define AMBIENT_INTENSITY 0.6
#define SPECULAR_POWER 10.0
#define SPECULAR_INTENSITY 0.6

#define AO_STEPS 3
#define AO_RADIUS 0.1
#define AO_INTENSITY 0.5
#define AO_BIAS (SURF_DIST * 5.0)

#define GROUND_THICKNESS 0.03
#define GROUND_RADIUS 0.05
#define GROUND_ROUNDNESS 0.02

#define OBJ_NONE 0
#define OBJ_BACKGROUND 1
#define OBJ_JELLY 2

// MARK: - SDF Primitives

float sdRoundedBox2d(float2 p, float2 b, float r) {
  float2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float sdRoundedBox3d(float3 p, float3 b, float r) {
  float3 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdPlane(float3 p, float3 n, float d) {
  return dot(p, n) + d;
}

// Extrude 2D SDF along Y axis
float opExtrudeY(float3 p, float d2d, float h) {
  float2 w = float2(d2d, abs(p.y) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

// MARK: - Jelly Deformation

// Cheap bend - bends XY based on X position
float3 opCheapBend(float3 p, float k) {
  float c = cos(k * p.x);
  float s = sin(k * p.x);
  float2x2 m = float2x2(c, -s, s, c);
  return float3(m * p.xy, p.z);
}

// Rotate around arbitrary axis
float3 opRotateAxisAngle(float3 p, float3 axis, float angle) {
  return mix(axis * dot(p, axis), p, cos(angle)) + cross(p, axis) * sin(angle);
}

// MARK: - Scene SDFs

// Rectangle cutout for the ground (where rail sits)
float rectangleCutoutDist(float2 position) {
  return sdRoundedBox2d(
    position,
    float2(SWITCH_RAIL_LENGTH * 0.5 + 0.2 + GROUND_ROUNDNESS, GROUND_RADIUS + GROUND_ROUNDNESS),
    GROUND_RADIUS + GROUND_ROUNDNESS
  );
}

// Main scene = ground plane with extruded cutout
float getMainSceneDist(float3 position) {
  float plane = sdPlane(position, float3(0, 1, 0), 0.06);
  float cutout = opExtrudeY(
    position,
    -rectangleCutoutDist(position.xz),
    GROUND_THICKNESS - GROUND_ROUNDNESS
  ) - GROUND_ROUNDNESS;
  return min(plane, cutout);
}

// Jelly SDF with deformations
float getJellyDist(float3 position, float progress, float squashX, float squashZ, float wiggleX) {
  // Jelly origin moves along rail based on progress
  float3 jellyOrigin = float3(
    (progress - 0.5) * SWITCH_RAIL_LENGTH - squashX * (progress - 0.5) * 0.2,
    JELLY_HALFSIZE.y * 0.5,
    0.0
  );

  // Scale for squash deformation
  float3 jellyInvScale = float3(1.0 - squashX, 1.0, 1.0 - squashZ);

  // Apply rotation (wiggle) around Z axis
  float3 localPos = opRotateAxisAngle(
    (position - jellyOrigin) * jellyInvScale,
    float3(0, 0, 1),
    wiggleX
  );

  // Apply cheap bend and compute rounded box SDF
  return sdRoundedBox3d(
    opCheapBend(localPos, 0.8),
    JELLY_HALFSIZE - 0.1,
    0.1
  );
}

struct HitInfo {
  float distance;
  int objectType;
};

HitInfo getSceneDist(float3 position, float progress, float squashX, float squashZ, float wiggleX) {
  float mainScene = getMainSceneDist(position);
  float jelly = getJellyDist(position, progress, squashX, squashZ, wiggleX);

  HitInfo hit;
  if (jelly < mainScene) {
    hit.distance = jelly;
    hit.objectType = OBJ_JELLY;
  } else {
    hit.distance = mainScene;
    hit.objectType = OBJ_BACKGROUND;
  }
  return hit;
}

float getSceneDistForAO(float3 position, float progress, float squashX, float squashZ, float wiggleX) {
  return min(getMainSceneDist(position), getJellyDist(position, progress, squashX, squashZ, wiggleX));
}

// MARK: - Normals

float3 getNormalApprox(float3 p, float e, float progress, float squashX, float squashZ, float wiggleX) {
  float dist = getSceneDist(p, progress, squashX, squashZ, wiggleX).distance;
  float3 n = float3(
    getSceneDist(p + float3(e, 0, 0), progress, squashX, squashZ, wiggleX).distance - dist,
    getSceneDist(p + float3(0, e, 0), progress, squashX, squashZ, wiggleX).distance - dist,
    getSceneDist(p + float3(0, 0, e), progress, squashX, squashZ, wiggleX).distance - dist
  );
  return normalize(n);
}

float3 getNormal(float3 position, float progress, float squashX, float squashZ, float wiggleX) {
  // Fast path for flat ground areas
  if (abs(position.z) > 0.5 || abs(position.x) > 1.02) {
    return float3(0, 1, 0);
  }
  return getNormalApprox(position, 0.0001, progress, squashX, squashZ, wiggleX);
}

// MARK: - Lighting

float calculateAO(float3 position, float3 normal, float progress, float squashX, float squashZ, float wiggleX) {
  float totalOcclusion = 0.0;
  float sampleWeight = 1.0;
  float stepDistance = AO_RADIUS / float(AO_STEPS);

  for (int i = 1; i <= AO_STEPS; i++) {
    float sampleHeight = stepDistance * float(i);
    float3 samplePosition = position + normal * sampleHeight;
    float distanceToSurface = getSceneDistForAO(samplePosition, progress, squashX, squashZ, wiggleX) - AO_BIAS;
    float occlusionContribution = max(0.0, sampleHeight - distanceToSurface);
    totalOcclusion += occlusionContribution * sampleWeight;
    sampleWeight *= 0.5;
    if (totalOcclusion > AO_RADIUS / AO_INTENSITY) break;
  }

  float rawAO = 1.0 - (AO_INTENSITY * totalOcclusion) / AO_RADIUS;
  return saturate(rawAO);
}

float3 getFakeShadow(float3 position, float3 lightDir) {
  if (position.y < -GROUND_THICKNESS) {
    // Shadow under the ground layer
    float fadeSharpness = 30.0;
    float inset = 0.02;
    float cutout = rectangleCutoutDist(position.xz) + inset;
    float edgeDarkening = saturate(1.0 - cutout * fadeSharpness);
    float lightGradient = saturate(-position.z * 4.0 * lightDir.z + 1.0);
    return float3(1.0) * edgeDarkening * lightGradient * 0.5;
  }
  return float3(1.0);
}

float3 calculateLighting(float3 hitPosition, float3 normal, float3 rayOrigin, float3 lightDir) {
  float3 fakeShadow = getFakeShadow(hitPosition, lightDir);
  float diffuse = max(dot(normal, -lightDir), 0.0);

  float3 viewDir = normalize(rayOrigin - hitPosition);
  float3 reflectDir = reflect(lightDir, normal);
  float specularFactor = pow(max(dot(viewDir, reflectDir), 0.0), SPECULAR_POWER);
  float3 specular = float3(1.0) * specularFactor * SPECULAR_INTENSITY;

  float3 baseColor = float3(0.9);
  float3 directionalLight = baseColor * diffuse * fakeShadow;
  float3 ambientLight = baseColor * AMBIENT_COLOR * AMBIENT_INTENSITY;
  float3 finalSpecular = specular * fakeShadow;

  return saturate(directionalLight + ambientLight + finalSpecular);
}

// MARK: - Fresnel and Absorption

float fresnelSchlick(float cosTheta, float n1, float n2) {
  float r0 = pow((n1 - n2) / (n1 + n2), 2.0);
  return r0 + (1.0 - r0) * pow(1.0 - cosTheta, 5.0);
}

float3 beerLambert(float3 sigma, float dist) {
  return exp(-sigma * dist);
}

// MARK: - Rendering

float4 renderBackground(float3 rayOrigin, float3 rayDirection, float backgroundHitDist,
                        float3 lightDir, float progress, float squashX, float squashZ, float wiggleX,
                        float4 jellyColor, float darkMode) {
  float3 hitPosition = rayOrigin + rayDirection * backgroundHitDist;
  float3 normal = getNormal(hitPosition, progress, squashX, squashZ, wiggleX);

  // Calculate fake bounce lighting from jelly
  float switchX = (progress - 0.5) * SWITCH_RAIL_LENGTH;
  float3 toJelly = hitPosition - float3(switchX, 0, 0);
  float sqDist = dot(toJelly, toJelly);
  float3 bounceLight = jellyColor.xyz * (1.0 / (sqDist * 15.0 + 1.0) * 0.4);
  float3 sideBounceLight = jellyColor.xyz * (1.0 / (sqDist * 40.0 + 1.0) * 0.3) * abs(normal.z);
  float emission = smoothstep(0.7, 1.0, progress) * 2.0 + 0.7;

  float3 litColor = calculateLighting(hitPosition, normal, rayOrigin, lightDir);
  float3 groundAlbedo = mix(LIGHT_GROUND_ALBEDO, DARK_GROUND_ALBEDO, darkMode);
  float ao = calculateAO(hitPosition, normal, progress, squashX, squashZ, wiggleX);

  float3 backgroundColor = groundAlbedo * litColor * ao;
  backgroundColor += bounceLight * emission + sideBounceLight * emission;

  return float4(backgroundColor, 1.0);
}

float3 rayMarchNoJelly(float3 rayOrigin, float3 rayDirection, float3 lightDir,
                       float progress, float squashX, float squashZ, float wiggleX,
                       float4 jellyColor, float darkMode) {
  float distanceFromOrigin = 0.0;

  for (int i = 0; i < 6; i++) {
    float3 p = rayOrigin + rayDirection * distanceFromOrigin;
    float hit = getMainSceneDist(p);
    distanceFromOrigin += hit;
    if (distanceFromOrigin > MAX_DIST || hit < SURF_DIST * 10.0) break;
  }

  if (distanceFromOrigin < MAX_DIST) {
    return renderBackground(rayOrigin, rayDirection, distanceFromOrigin,
                            lightDir, progress, squashX, squashZ, wiggleX,
                            jellyColor, darkMode).xyz;
  }
  return float3(0.0);
}

// MARK: - Main Shader

[[stitchable]] half4 jellySwitch(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float progress,
  float squashX,
  float squashZ,
  float wiggleX,
  float4 jellyColor,
  float3 lightDir,
  float darkMode
) {
  // NDC coordinates
  float2 uv = position / size;
  float2 ndc = float2(uv.x * 2.0 - 1.0, -(uv.y * 2.0 - 1.0));

  // Camera setup - moved back 20% from original TypeGPU position for smaller appearance
  float3 ro = float3(0.024, 3.27, 2.3);
  float3 target = float3(0, 0, 0);
  float3 up = float3(0, 1, 0);

  // Apply tilt
  ro.x += tilt.x * 0.3;
  ro.z += tilt.y * 0.3;

  // Camera basis vectors
  float3 forward = normalize(target - ro);
  float3 right = normalize(cross(forward, up));
  float3 camUp = cross(right, forward);

  // Field of view: PI/4
  float fov = 0.7853981634; // PI/4
  float aspectRatio = size.x / size.y;

  // Ray direction with perspective projection
  float3 rd = normalize(forward + right * ndc.x * tan(fov * 0.5) * aspectRatio + camUp * ndc.y * tan(fov * 0.5));

  // Normalize light direction
  float3 ld = normalize(lightDir);

  // First pass: march to background
  float backgroundDist = 0.0;
  for (int i = 0; i < MAX_STEPS; i++) {
    float3 p = ro + rd * backgroundDist;
    float hit = getMainSceneDist(p);
    backgroundDist += hit;
    if (hit < SURF_DIST) break;
  }
  float4 background = renderBackground(ro, rd, backgroundDist, ld, progress, squashX, squashZ, wiggleX, jellyColor, darkMode);

  // Second pass: check jelly intersection
  float distanceFromOrigin = 0.0;

  for (int i = 0; i < MAX_STEPS; i++) {
    float3 currentPosition = ro + rd * distanceFromOrigin;
    HitInfo hitInfo = getSceneDist(currentPosition, progress, squashX, squashZ, wiggleX);
    distanceFromOrigin += hitInfo.distance;

    if (hitInfo.distance < SURF_DIST) {
      float3 hitPosition = ro + rd * distanceFromOrigin;

      if (hitInfo.objectType != OBJ_JELLY) {
        break; // Hit background, use pre-computed background
      }

      // === JELLY HIT ===
      float3 N = getNormal(hitPosition, progress, squashX, squashZ, wiggleX);
      float3 I = rd;

      // Fresnel
      float cosi = min(1.0, max(0.0, dot(-I, N)));
      float F = fresnelSchlick(cosi, 1.0, JELLY_IOR);

      // Simple reflection (sky approximation)
      float3 reflection = saturate(float3(hitPosition.y + 0.2));

      // Refraction
      float eta = 1.0 / JELLY_IOR;
      float k = 1.0 - eta * eta * (1.0 - cosi * cosi);
      float3 refractedColor = float3(0.0);

      if (k > 0.0) {
        float3 refrDir = normalize(I * eta + N * (eta * cosi - sqrt(k)));
        float3 p = hitPosition + refrDir * (SURF_DIST * 2.0);
        float3 exitPos = p + refrDir * (SURF_DIST * 2.0);

        // Ray march through to find what's behind
        float3 env = rayMarchNoJelly(exitPos, refrDir, ld, progress, squashX, squashZ, wiggleX, jellyColor, darkMode);

        // Subsurface scattering and absorption
        float3 scatterTint = jellyColor.xyz * 1.5;
        float density = 20.0;
        float3 absorb = (float3(1.0) - jellyColor.xyz) * density;

        // Height-based progress for internal coloring
        float heightProgress = saturate(
          mix(1.0, 0.6, hitPosition.y * (1.0 / (JELLY_HALFSIZE.y * 2.0)) + 0.25)
        ) * progress;

        float3 T = beerLambert(absorb * (heightProgress * heightProgress), 0.08);

        // Forward scattering
        float fwdScatter = max(0.0, dot(-ld, refrDir));
        float3 scatter = scatterTint * JELLY_SCATTER_STRENGTH * fwdScatter * pow(heightProgress, 3.0);

        refractedColor = env * T + scatter;
      }

      // Combine reflection and refraction
      float3 jelly = reflection * F + refractedColor * (1.0 - F);

      // Exposure adjustment
      float exposure = mix(1.5, 2.0, darkMode);
      float3 col = tanh(jelly * exposure);

      return half4(half3(col), 1.0h);
    }

    if (distanceFromOrigin > backgroundDist) {
      break;
    }
  }

  // Apply exposure to background
  float exposure = mix(1.5, 2.0, darkMode);
  float3 col = tanh(background.xyz * exposure);

  return half4(half3(col), 1.0h);
}
