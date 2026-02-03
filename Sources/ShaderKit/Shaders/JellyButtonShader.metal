//
//  JellyButtonShader.metal
//  ShaderKit
//
//  3D ray-marched translucent jelly button - gummy bear shape matching JellySwitch
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Constants

#define MAX_STEPS 64
#define MAX_DIST 10.0
#define SURF_DIST 0.001

#define JELLY_HALFSIZE float3(0.35, 0.3, 0.3)
#define JELLY_IOR 1.42
#define JELLY_SCATTER_STRENGTH 3.0

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

#define SHADOW_RADIUS 0.4
#define SHADOW_INTENSITY 0.35

#define OBJ_NONE 0
#define OBJ_BACKGROUND 1
#define OBJ_JELLY 2

// MARK: - SDF Primitives

static float jbSdRoundedBox3d(float3 p, float3 b, float r) {
  float3 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

static float jbSdPlane(float3 p, float3 n, float d) {
  return dot(p, n) + d;
}

// MARK: - Jelly Deformation

// Rotate around arbitrary axis
static float3 jbOpRotateAxisAngle(float3 p, float3 axis, float angle) {
  return mix(axis * dot(p, axis), p, cos(angle)) + cross(p, axis) * sin(angle);
}

// Cheap bend operation for gummy bear shape
static float3 jbOpCheapBend(float3 p, float k) {
  float c = cos(k * p.x);
  float s = sin(k * p.x);
  float2x2 m = float2x2(c, -s, s, c);
  return float3(m * p.xy, p.z);
}

// MARK: - Scene SDFs

// Main scene = flat ground plane
static float jbGetMainSceneDist(float3 position) {
  return jbSdPlane(position, float3(0, 1, 0), 0.0);
}

// Jelly gummy bear SDF with deformations
static float jbGetJellyDist(float3 position, float squashY, float squashX, float wiggle) {
  // Jelly origin - centered, raised above ground
  float3 jellyOrigin = float3(0.0, JELLY_HALFSIZE.y * 0.5, 0.0);

  // Scale for squash deformation (similar to JellySwitch)
  float3 jellyInvScale = float3(
    1.0 - squashX * 0.15,    // Compress horizontally when pressed
    1.0 + squashY * 0.25,    // Expand vertically when pressed (inverse)
    1.0 - squashX * 0.15     // Compress in depth
  );

  // Apply wiggle rotation around Y axis (button rotates around Y, not Z like switch)
  float3 localPos = jbOpRotateAxisAngle(
    (position - jellyOrigin) * jellyInvScale,
    float3(0, 1, 0),
    wiggle * 0.15
  );

  // Apply cheap bend and compute rounded box SDF (same as JellySwitch)
  return jbSdRoundedBox3d(
    jbOpCheapBend(localPos, 0.8),
    JELLY_HALFSIZE - 0.1,
    0.1
  );
}

struct JBHitInfo {
  float distance;
  int objectType;
};

static JBHitInfo jbGetSceneDist(float3 position, float squashY, float squashX, float wiggle) {
  float mainScene = jbGetMainSceneDist(position);
  float jelly = jbGetJellyDist(position, squashY, squashX, wiggle);

  JBHitInfo hit;
  if (jelly < mainScene) {
    hit.distance = jelly;
    hit.objectType = OBJ_JELLY;
  } else {
    hit.distance = mainScene;
    hit.objectType = OBJ_BACKGROUND;
  }
  return hit;
}

static float jbGetSceneDistForAO(float3 position, float squashY, float squashX, float wiggle) {
  return min(jbGetMainSceneDist(position), jbGetJellyDist(position, squashY, squashX, wiggle));
}

// MARK: - Normals

static float3 jbGetNormalApprox(float3 p, float e, float squashY, float squashX, float wiggle) {
  float dist = jbGetSceneDist(p, squashY, squashX, wiggle).distance;
  float3 n = float3(
    jbGetSceneDist(p + float3(e, 0, 0), squashY, squashX, wiggle).distance - dist,
    jbGetSceneDist(p + float3(0, e, 0), squashY, squashX, wiggle).distance - dist,
    jbGetSceneDist(p + float3(0, 0, e), squashY, squashX, wiggle).distance - dist
  );
  return normalize(n);
}

static float3 jbGetNormal(float3 position, float squashY, float squashX, float wiggle) {
  // Fast path for flat ground (ground is at y=0)
  if (position.y < 0.01) {
    return float3(0, 1, 0);
  }
  return jbGetNormalApprox(position, 0.0001, squashY, squashX, wiggle);
}

// MARK: - Lighting

static float jbCalculateAO(float3 position, float3 normal, float squashY, float squashX, float wiggle) {
  float totalOcclusion = 0.0;
  float sampleWeight = 1.0;
  float stepDistance = AO_RADIUS / float(AO_STEPS);

  for (int i = 1; i <= AO_STEPS; i++) {
    float sampleHeight = stepDistance * float(i);
    float3 samplePosition = position + normal * sampleHeight;
    float distanceToSurface = jbGetSceneDistForAO(samplePosition, squashY, squashX, wiggle) - AO_BIAS;
    float occlusionContribution = max(0.0, sampleHeight - distanceToSurface);
    totalOcclusion += occlusionContribution * sampleWeight;
    sampleWeight *= 0.5;
    if (totalOcclusion > AO_RADIUS / AO_INTENSITY) break;
  }

  float rawAO = 1.0 - (AO_INTENSITY * totalOcclusion) / AO_RADIUS;
  return saturate(rawAO);
}

// Subtle shadow beneath the jelly
static float jbGetGroundShadow(float3 position) {
  // Distance from center on XZ plane
  float distFromCenter = length(position.xz);
  // Smooth circular shadow falloff
  float shadow = smoothstep(0.0, SHADOW_RADIUS, distFromCenter);
  // Invert and scale: 1.0 = no shadow, lower = darker
  return mix(1.0 - SHADOW_INTENSITY, 1.0, shadow);
}

static float3 jbCalculateLighting(float3 hitPosition, float3 normal, float3 rayOrigin, float3 lightDir) {
  float shadow = jbGetGroundShadow(hitPosition);
  float diffuse = max(dot(normal, -lightDir), 0.0);

  float3 viewDir = normalize(rayOrigin - hitPosition);
  float3 reflectDir = reflect(lightDir, normal);
  float specularFactor = pow(max(dot(viewDir, reflectDir), 0.0), SPECULAR_POWER);
  float3 specular = float3(1.0) * specularFactor * SPECULAR_INTENSITY;

  float3 baseColor = float3(0.9);
  float3 directionalLight = baseColor * diffuse;
  float3 ambientLight = baseColor * AMBIENT_COLOR * AMBIENT_INTENSITY * shadow;
  float3 finalSpecular = specular;

  return saturate(directionalLight + ambientLight + finalSpecular);
}

// MARK: - Fresnel and Absorption

static float jbFresnelSchlick(float cosTheta, float n1, float n2) {
  float r0 = pow((n1 - n2) / (n1 + n2), 2.0);
  return r0 + (1.0 - r0) * pow(1.0 - cosTheta, 5.0);
}

static float3 jbBeerLambert(float3 sigma, float dist) {
  return exp(-sigma * dist);
}

// MARK: - Rendering

static float4 jbRenderBackground(float3 rayOrigin, float3 rayDirection, float backgroundHitDist,
                        float3 lightDir, float squashY, float squashX, float wiggle,
                        float4 jellyColor, float darkMode) {
  float3 hitPosition = rayOrigin + rayDirection * backgroundHitDist;
  float3 normal = jbGetNormal(hitPosition, squashY, squashX, wiggle);

  // Calculate fake bounce lighting from jelly (centered at origin)
  float3 toJelly = hitPosition - float3(0, JELLY_HALFSIZE.y, 0);
  float sqDist = dot(toJelly, toJelly);
  float3 bounceLight = jellyColor.xyz * (1.0 / (sqDist * 15.0 + 1.0) * 0.4);
  float3 sideBounceLight = jellyColor.xyz * (1.0 / (sqDist * 40.0 + 1.0) * 0.3) * abs(normal.z);
  float emission = 1.5;

  float3 litColor = jbCalculateLighting(hitPosition, normal, rayOrigin, lightDir);
  float3 groundAlbedo = mix(LIGHT_GROUND_ALBEDO, DARK_GROUND_ALBEDO, darkMode);
  float ao = jbCalculateAO(hitPosition, normal, squashY, squashX, wiggle);

  float3 backgroundColor = groundAlbedo * litColor * ao;
  backgroundColor += bounceLight * emission + sideBounceLight * emission;

  return float4(backgroundColor, 1.0);
}

static float3 jbRayMarchNoJelly(float3 rayOrigin, float3 rayDirection, float3 lightDir,
                       float squashY, float squashX, float wiggle,
                       float4 jellyColor, float darkMode) {
  float distanceFromOrigin = 0.0;

  for (int i = 0; i < 6; i++) {
    float3 p = rayOrigin + rayDirection * distanceFromOrigin;
    float hit = jbGetMainSceneDist(p);
    distanceFromOrigin += hit;
    if (distanceFromOrigin > MAX_DIST || hit < SURF_DIST * 10.0) break;
  }

  if (distanceFromOrigin < MAX_DIST) {
    return jbRenderBackground(rayOrigin, rayDirection, distanceFromOrigin,
                            lightDir, squashY, squashX, wiggle,
                            jellyColor, darkMode).xyz;
  }
  return float3(0.0);
}

// MARK: - Main Shader

[[stitchable]] half4 jellyButton(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float squashY,
  float squashX,
  float wiggle,
  float4 jellyColor,
  float3 lightDir,
  float darkMode
) {
  // NDC coordinates
  float2 uv = position / size;
  float2 ndc = float2(uv.x * 2.0 - 1.0, -(uv.y * 2.0 - 1.0));

  // Camera setup - positioned to view the centered button
  float3 ro = float3(0.0, 3.27, 2.3);
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
    float hit = jbGetMainSceneDist(p);
    backgroundDist += hit;
    if (hit < SURF_DIST) break;
  }
  float4 background = jbRenderBackground(ro, rd, backgroundDist, ld, squashY, squashX, wiggle, jellyColor, darkMode);

  // Second pass: check jelly intersection
  float distanceFromOrigin = 0.0;

  for (int i = 0; i < MAX_STEPS; i++) {
    float3 currentPosition = ro + rd * distanceFromOrigin;
    JBHitInfo hitInfo = jbGetSceneDist(currentPosition, squashY, squashX, wiggle);
    distanceFromOrigin += hitInfo.distance;

    if (hitInfo.distance < SURF_DIST) {
      float3 hitPosition = ro + rd * distanceFromOrigin;

      if (hitInfo.objectType != OBJ_JELLY) {
        break; // Hit background, use pre-computed background
      }

      // === JELLY HIT ===
      float3 N = jbGetNormal(hitPosition, squashY, squashX, wiggle);
      float3 I = rd;

      // Fresnel
      float cosi = min(1.0, max(0.0, dot(-I, N)));
      float F = jbFresnelSchlick(cosi, 1.0, JELLY_IOR);

      // View direction for specular and rim calculations
      float3 viewDir = normalize(ro - hitPosition);

      // Specular highlight on jelly surface (sharp, bright)
      float3 H = normalize(viewDir - ld);  // Half vector
      float spec = pow(max(dot(N, H), 0.0), 64.0);  // Sharp specular
      float3 specular = float3(1.0) * spec * 0.8;  // Bright white highlight

      // Rim lighting - brighter at grazing angles (subsurface scattering effect)
      float rim = 1.0 - cosi;
      float rimPower = pow(rim, 3.0) * 0.5;
      float3 rimColor = jellyColor.xyz * rimPower;

      // Better sky/environment reflection approximation
      float3 reflectDir = reflect(I, N);
      float skyGradient = reflectDir.y * 0.5 + 0.5;  // 0 at bottom, 1 at top
      float3 reflection = mix(float3(0.3), float3(1.0), skyGradient);  // Gray to white

      // Refraction
      float eta = 1.0 / JELLY_IOR;
      float k = 1.0 - eta * eta * (1.0 - cosi * cosi);
      float3 refractedColor = float3(0.0);

      if (k > 0.0) {
        float3 refrDir = normalize(I * eta + N * (eta * cosi - sqrt(k)));
        float3 p = hitPosition + refrDir * (SURF_DIST * 2.0);

        // Ray march inside jelly to find exit point (proper path length)
        float pathLength = 0.0;
        float3 internalPos = hitPosition;
        for (int j = 0; j < 16; j++) {
          internalPos += refrDir * 0.02;
          float d = jbGetJellyDist(internalPos, squashY, squashX, wiggle);
          if (d > 0.0) break;  // Exited jelly
          pathLength += 0.02;
        }

        float3 exitPos = p + refrDir * (SURF_DIST * 2.0);

        // Ray march through to find what's behind
        float3 env = jbRayMarchNoJelly(exitPos, refrDir, ld, squashY, squashX, wiggle, jellyColor, darkMode);

        // Subsurface scattering and absorption
        float3 scatterTint = jellyColor.xyz * 1.5;
        float density = 8.0;  // Reduced for more transparency
        float3 absorb = (float3(1.0) - jellyColor.xyz) * density;

        // Height-based coloring for the gummy bear
        float heightProgress = saturate(
          (hitPosition.y - 0.0) / (JELLY_HALFSIZE.y * 2.0) + 0.5
        );

        // Use computed path length for Beer-Lambert absorption
        float3 T = jbBeerLambert(absorb * (heightProgress * heightProgress), pathLength);

        // Forward scattering
        float fwdScatter = max(0.0, dot(-ld, refrDir));
        float3 scatter = scatterTint * JELLY_SCATTER_STRENGTH * fwdScatter * pow(heightProgress, 3.0);

        refractedColor = env * T + scatter;
      }

      // Combine all lighting contributions
      float3 jelly = reflection * F                    // Surface reflection
                   + refractedColor * (1.0 - F)        // Refracted background
                   + specular                          // Specular highlight
                   + rimColor;                         // Rim glow

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
