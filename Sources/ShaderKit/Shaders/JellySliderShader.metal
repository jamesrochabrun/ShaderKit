//
//  JellySliderShader.metal
//  ShaderKit
//
//  3D ray-marched translucent jelly slider.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

#define JS_POINT_COUNT 17
#define JS_SEGMENT_COUNT 16
#define JS_PACK_COUNT 9
#define JS_CONTROL_PACK_COUNT 8
#define JS_CURVE_SUBDIVISIONS 4

#define JS_MAX_STEPS 64
#define JS_MAX_DIST 10.0
#define JS_SURF_DIST 0.001

#define JS_LINE_RADIUS 0.024
#define JS_LINE_HALF_THICK 0.17
#define JS_JELLY_IOR 1.42
#define JS_JELLY_SCATTER_STRENGTH 3.0
#define JS_TARGET_MIN_X -0.33
#define JS_TARGET_MAX_X 0.9

#define JS_BBOX_LEFT -1.019
#define JS_BBOX_RIGHT 1.09
#define JS_BBOX_BOTTOM -0.30
#define JS_BBOX_TOP 0.65

#define JS_GROUND_THICKNESS 0.03
#define JS_GROUND_ROUNDNESS 0.02

#define JS_AMBIENT_COLOR float3(0.6)
#define JS_AMBIENT_INTENSITY 0.6
#define JS_SPECULAR_POWER 10.0
#define JS_SPECULAR_INTENSITY 0.6

#define JS_AO_STEPS 3
#define JS_AO_RADIUS 0.1
#define JS_AO_INTENSITY 0.5
#define JS_AO_BIAS (JS_SURF_DIST * 5.0)

#define JS_OBJ_BACKGROUND 1
#define JS_OBJ_SLIDER 2

struct JSLineInfo {
  float distance;
  float t;
  float2 normal;
};

struct JSHitInfo {
  float distance;
  int objectType;
  float t;
};

struct JSBoxIntersection {
  bool hit;
  float tMin;
  float tMax;
};

static float jsSdBox2d(float2 p, float2 b) {
  float2 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

static float jsSdRoundedBox2d(float2 p, float2 b, float r) {
  float2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

static float jsSdPlane(float3 p, float3 n, float d) {
  return dot(p, n) + d;
}

static float jsOpExtrudeY(float3 p, float d2d, float h) {
  float2 w = float2(d2d, abs(p.y) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

static float jsOpExtrudeZ(float3 p, float d2d, float h) {
  float2 w = float2(d2d, abs(p.z) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

static float jsSdPie(float2 p, float2 c, float r) {
  p.x = abs(p.x);
  float circle = length(p) - r;
  float2 radial = c * clamp(dot(p, c), 0.0, r);
  float wedge = length(p - radial) * sign(c.y * p.x - c.x * p.y);
  return max(circle, wedge);
}

static float2 jsPoint(thread const float4 *packs, int index) {
  float4 pack = packs[index / 2];
  return (index & 1) == 0 ? pack.xy : pack.zw;
}

static float2 jsControlPoint(thread const float4 *controlPacks, int index) {
  float4 pack = controlPacks[index / 2];
  return (index & 1) == 0 ? pack.xy : pack.zw;
}

static JSBoxIntersection jsIntersectBox(float3 rayOrigin, float3 rayDirection, float3 boxMin, float3 boxMax) {
  float3 invDir = 1.0 / rayDirection;
  float3 t1 = (boxMin - rayOrigin) * invDir;
  float3 t2 = (boxMax - rayOrigin) * invDir;
  float3 tMinVec = min(t1, t2);
  float3 tMaxVec = max(t1, t2);

  JSBoxIntersection result;
  result.tMin = max(max(tMinVec.x, tMinVec.y), tMinVec.z);
  result.tMax = min(min(tMaxVec.x, tMaxVec.y), tMaxVec.z);
  result.hit = result.tMax >= result.tMin && result.tMax >= 0.0;
  return result;
}

static float2 jsQuadraticBezier(float2 a, float2 c, float2 b, float t) {
  float oneMinusT = 1.0 - t;
  return oneMinusT * oneMinusT * a + 2.0 * oneMinusT * t * c + t * t * b;
}

static JSLineInfo jsSamplePolyline(float2 p, thread const float4 *packs, thread const float4 *controlPacks) {
  JSLineInfo result;
  result.distance = 1.0e6;
  result.t = 0.0;
  result.normal = float2(0.0, 1.0);

  float2 bboxCenter = float2((JS_BBOX_LEFT + JS_BBOX_RIGHT) * 0.5, (JS_BBOX_BOTTOM + JS_BBOX_TOP) * 0.5);
  float2 bboxHalfSize = float2((JS_BBOX_RIGHT - JS_BBOX_LEFT) * 0.5, (JS_BBOX_TOP - JS_BBOX_BOTTOM) * 0.5);
  float bboxDist = jsSdBox2d(p - bboxCenter, bboxHalfSize);
  if (bboxDist > 0.18) {
    result.distance = bboxDist - 0.18;
    result.t = saturate((p.x + 1.0) / 1.9);
    float2 closest = clamp(p, bboxCenter - bboxHalfSize, bboxCenter + bboxHalfSize);
    float2 delta = p - closest;
    result.normal = length(delta) > 1.0e-5 ? normalize(delta) : float2(0.0, 1.0);
    return result;
  }

  for (int i = 0; i < JS_SEGMENT_COUNT; i++) {
    float2 a = jsPoint(packs, i);
    float2 c = jsControlPoint(controlPacks, i);
    float2 b = jsPoint(packs, i + 1);

    for (int s = 0; s < JS_CURVE_SUBDIVISIONS; s++) {
      float t0 = float(s) / float(JS_CURVE_SUBDIVISIONS);
      float t1 = float(s + 1) / float(JS_CURVE_SUBDIVISIONS);
      float2 p0 = jsQuadraticBezier(a, c, b, t0);
      float2 p1 = jsQuadraticBezier(a, c, b, t1);
      float2 ab = p1 - p0;
      float denom = max(dot(ab, ab), 1.0e-5);
      float h = saturate(dot(p - p0, ab) / denom);
      float2 closest = p0 + ab * h;
      float2 delta = p - closest;
      float dist = length(delta);

      if (dist < result.distance) {
        result.distance = dist;
        result.t = (float(i) + mix(t0, t1, h)) / float(JS_SEGMENT_COUNT);
        if (dist > 1.0e-5) {
          result.normal = delta / dist;
        } else {
          float lenAb = max(length(ab), 1.0e-5);
          float2 tangent = ab / lenAb;
          result.normal = float2(-tangent.y, tangent.x);
        }
      }
    }
  }

  return result;
}

static JSLineInfo jsSampleSliderUV(float2 uv, thread const float4 *packs, thread const float4 *controlPacks) {
  float2 clampedUV = saturate(uv);
  float2 position = float2(
    mix(JS_BBOX_LEFT, JS_BBOX_RIGHT, clampedUV.x),
    mix(JS_BBOX_TOP, JS_BBOX_BOTTOM, clampedUV.y)
  );
  return jsSamplePolyline(position, packs, controlPacks);
}

static float jsRectangleCutoutDist(float2 position) {
  float groundRoundness = JS_GROUND_ROUNDNESS;
  return jsSdRoundedBox2d(
    position,
    float2(1.0 + groundRoundness, 0.2 + groundRoundness),
    0.2 + groundRoundness
  );
}

static float jsGetMainSceneDist(float3 position) {
  float groundRoundness = JS_GROUND_ROUNDNESS;
  float plane = jsSdPlane(position, float3(0.0, 1.0, 0.0), 0.06);
  float cutout = jsOpExtrudeY(
    position,
    -jsRectangleCutoutDist(position.xz),
    JS_GROUND_THICKNESS - groundRoundness
  ) - groundRoundness;
  return min(plane, cutout);
}

static float jsCap3D(float3 position, thread const float4 *packs) {
  float2 secondLast = jsPoint(packs, JS_POINT_COUNT - 2);
  float2 last = jsPoint(packs, JS_POINT_COUNT - 1);
  float angle = atan2(last.y - secondLast.y, last.x - secondLast.x);
  float c = cos(angle);
  float s = sin(angle);

  float3 p = position - float3(secondLast, 0.0);
  float2 rotated = float2(c * p.x - s * p.y, s * p.x + c * p.y);
  p = float3(rotated, p.z);

  float pie = jsSdPie(p.zx, float2(1.0, 0.0), JS_LINE_HALF_THICK);
  return jsOpExtrudeY(p, pie, 0.001) - JS_LINE_RADIUS;
}

static JSLineInfo jsSliderSdf3D(float3 position, thread const float4 *packs, thread const float4 *controlPacks) {
  JSLineInfo line = jsSamplePolyline(position.xy, packs, controlPacks);
  float dist3d = line.t > 0.94
    ? jsCap3D(position, packs)
    : jsOpExtrudeZ(position, line.distance, JS_LINE_HALF_THICK) - JS_LINE_RADIUS;
  line.distance = dist3d;
  return line;
}

static float jsSliderApproxDist(float3 position, thread const float4 *packs, thread const float4 *controlPacks) {
  float2 p = position.xy;
  if (p.x < JS_BBOX_LEFT || p.x > JS_BBOX_RIGHT || p.y < JS_BBOX_BOTTOM || p.y > JS_BBOX_TOP) {
    return 1.0e9;
  }

  JSLineInfo line = jsSamplePolyline(p, packs, controlPacks);
  return jsOpExtrudeZ(position, line.distance, JS_LINE_HALF_THICK) - JS_LINE_RADIUS;
}

static JSHitInfo jsGetSceneDist(float3 position, thread const float4 *packs, thread const float4 *controlPacks) {
  float mainScene = jsGetMainSceneDist(position);
  JSLineInfo slider = jsSliderSdf3D(position, packs, controlPacks);

  JSHitInfo hit;
  if (slider.distance < mainScene) {
    hit.distance = slider.distance;
    hit.objectType = JS_OBJ_SLIDER;
    hit.t = slider.t;
  } else {
    hit.distance = mainScene;
    hit.objectType = JS_OBJ_BACKGROUND;
    hit.t = 0.0;
  }
  return hit;
}

static float jsGetSceneDistForAO(float3 position, thread const float4 *packs, thread const float4 *controlPacks) {
  return min(jsGetMainSceneDist(position), jsSliderApproxDist(position, packs, controlPacks));
}

static float3 jsGetNormalMain(float3 position) {
  if (abs(position.z) > 0.22 || abs(position.x) > 1.02) {
    return float3(0.0, 1.0, 0.0);
  }

  float e = 0.0001;
  float dist = jsGetMainSceneDist(position);
  float3 n = float3(
    jsGetMainSceneDist(position + float3(e, 0.0, 0.0)) - dist,
    jsGetMainSceneDist(position + float3(0.0, e, 0.0)) - dist,
    jsGetMainSceneDist(position + float3(0.0, 0.0, e)) - dist
  );
  return normalize(n);
}

static float3 jsGetNormalApprox(float3 position, thread const float4 *packs, thread const float4 *controlPacks) {
  float e = 0.001;
  float dist = jsGetSceneDist(position, packs, controlPacks).distance;
  float3 n = float3(
    jsGetSceneDist(position + float3(e, 0.0, 0.0), packs, controlPacks).distance - dist,
    jsGetSceneDist(position + float3(0.0, e, 0.0), packs, controlPacks).distance - dist,
    jsGetSceneDist(position + float3(0.0, 0.0, e), packs, controlPacks).distance - dist
  );
  return normalize(n);
}

static float3 jsGetSliderNormal(float3 position, JSHitInfo hit, thread const float4 *packs, thread const float4 *controlPacks) {
  JSLineInfo line = jsSamplePolyline(position.xy, packs, controlPacks);
  float2 gradient2D = line.normal;

  float threshold = JS_LINE_HALF_THICK * 0.85;
  float absZ = abs(position.z);
  float zDistance = max(0.0, ((absZ - threshold) * JS_LINE_HALF_THICK) / (JS_LINE_HALF_THICK - threshold));
  float edgeDistance = JS_LINE_RADIUS - line.distance;

  float edgeContrib = 0.9;
  float zContrib = 1.0 - edgeContrib;
  float edgeBlendDistance = edgeContrib * JS_LINE_RADIUS + zContrib * JS_LINE_HALF_THICK;
  float blendFactor = smoothstep(edgeBlendDistance, 0.0, zDistance * zContrib + edgeDistance * edgeContrib);

  float zDirection = sign(position.z);
  float3 zAxisVector = float3(0.0, 0.0, zDirection == 0.0 ? 1.0 : zDirection);
  float3 normal2D = float3(gradient2D, 0.0);
  float3 blendedNormal = mix(zAxisVector, normal2D, blendFactor * 0.5 + 0.5);

  float3 normal = normalize(blendedNormal);
  if (hit.t > 0.94) {
    float ratio = saturate((hit.t - 0.94) / 0.04);
    normal = normalize(mix(normal, jsGetNormalApprox(position, packs, controlPacks), ratio));
  }
  return normal;
}

static float3 jsGetNormal(float3 position, JSHitInfo hit, thread const float4 *packs, thread const float4 *controlPacks) {
  if (hit.objectType == JS_OBJ_SLIDER && hit.t < 0.96) {
    return jsGetSliderNormal(position, hit, packs, controlPacks);
  }
  return hit.objectType == JS_OBJ_BACKGROUND ? jsGetNormalMain(position) : jsGetNormalApprox(position, packs, controlPacks);
}

static float jsCalculateMainAO(float3 position, float3 normal, thread const float4 *packs,
                               thread const float4 *controlPacks) {
  float totalOcclusion = 0.0;
  float sampleWeight = 1.0;
  float stepDistance = JS_AO_RADIUS / float(JS_AO_STEPS);

  for (int i = 1; i <= JS_AO_STEPS; i++) {
    float sampleHeight = stepDistance * float(i);
    float3 samplePosition = position + normal * sampleHeight;
    float distanceToSurface = jsGetSceneDistForAO(samplePosition, packs, controlPacks) - JS_AO_BIAS;
    float occlusionContribution = max(0.0, sampleHeight - distanceToSurface);
    totalOcclusion += occlusionContribution * sampleWeight;
    sampleWeight *= 0.5;
  }

  return saturate(1.0 - (JS_AO_INTENSITY * totalOcclusion) / JS_AO_RADIUS);
}

static float3 jsGetFakeShadow(float3 position, float3 lightDir, float endCapX, float4 jellyColor,
                              thread const float4 *packs, thread const float4 *controlPacks) {
  if (position.y < -JS_GROUND_THICKNESS) {
    float fadeSharpness = 30.0;
    float inset = 0.02;
    float cutout = jsRectangleCutoutDist(position.xz) + inset;
    float edgeDarkening = saturate(1.0 - cutout * fadeSharpness);
    float lightGradient = saturate(-position.z * 4.0 * lightDir.z + 1.0);
    return float3(1.0) * edgeDarkening * lightGradient * 0.5;
  }

  float zSign = lightDir.z < 0.0 ? -1.0 : 1.0;
  float safeLightZ = zSign * max(abs(lightDir.z), 1.0e-3);
  float2 finalUV = float2(
    (position.x - position.z * lightDir.x * zSign) * 0.5 + 0.5,
    1.0 - (-position.z / safeLightZ) * 0.5 - 0.2
  );
  JSLineInfo data = jsSampleSliderUV(finalUV, packs, controlPacks);

  float jellySaturation = mix(0.0, data.t, saturate(position.x * 1.5 + 1.1));
  float3 shadowColor = mix(float3(0.0), jellyColor.xyz, jellySaturation);

  float contrast = 20.0 * saturate(finalUV.y) * (0.8 + endCapX * 0.2);
  float shadowOffset = -0.3;
  float featherSharpness = 10.0;
  float uvEdgeFeather =
    saturate(finalUV.x * featherSharpness) *
    saturate((1.0 - finalUV.x) * featherSharpness) *
    saturate((1.0 - finalUV.y) * featherSharpness) *
    saturate(finalUV.y);
  float influence = saturate((1.0 - lightDir.y) * 2.0) * uvEdgeFeather;
  float shadowMask = saturate(data.distance * contrast + shadowOffset);

  return mix(float3(1.0), mix(shadowColor, float3(1.0), shadowMask), influence);
}

static float jsCalculateCausticHighlights(float3 hitPosition, float3 lightDir, float endCapX,
                                          thread const float4 *packs, thread const float4 *controlPacks) {
  float highlightWidth = 1.0;
  float highlightHeight = 0.2;
  float offsetX = -lightDir.x * 0.2;
  float offsetZ = 0.05 + lightDir.z * 0.2;

  if (abs(hitPosition.x + offsetX) >= highlightWidth || abs(hitPosition.z + offsetZ) >= highlightHeight) {
    return 0.0;
  }

  float uvXOrig = ((hitPosition.x + offsetX + highlightWidth * 2.0) / highlightWidth) * 0.5;
  float uvZOrig = ((hitPosition.z + offsetZ + highlightHeight * 2.0) / highlightHeight) * 0.5;
  float2 centeredUV = float2(uvXOrig - 0.5, uvZOrig - 0.5);
  float2 finalUV = float2(centeredUV.x, 1.0 - pow(abs(centeredUV.y - 0.5) * 2.0, 2.0) * 0.3);

  JSLineInfo data = jsSampleSliderUV(finalUV, packs, controlPacks);
  float density = max(0.0, (data.distance - 0.25) * 8.0);
  float endFade = smoothstep(0.0, -0.2, hitPosition.x - endCapX);
  float crossFade = 1.0 - pow(abs(centeredUV.y - 0.5) * 2.0, 3.0);
  float sliderStretch = (endCapX + 1.0) * 0.5;
  float stretchFade = saturate(1.0 - sliderStretch);
  float edgeFade = saturate(endFade) * saturate(crossFade) * stretchFade;

  return (pow(density, 3.0) * edgeFade * 3.0 * (1.0 + lightDir.z)) / 1.5;
}

static float3 jsCalculateLighting(float3 hitPosition, float3 normal, float3 rayOrigin,
                                  float3 lightDir, float endX, float4 jellyColor, thread const float4 *packs,
                                  thread const float4 *controlPacks) {
  float3 fakeShadow = jsGetFakeShadow(hitPosition, -lightDir, endX, jellyColor, packs, controlPacks);
  float diffuse = max(dot(normal, -lightDir), 0.0);

  float3 viewDir = normalize(rayOrigin - hitPosition);
  float3 reflectDir = reflect(lightDir, normal);
  float specularFactor = pow(max(dot(viewDir, reflectDir), 0.0), JS_SPECULAR_POWER);
  float3 specular = float3(1.0) * specularFactor * JS_SPECULAR_INTENSITY;

  float3 baseColor = float3(0.9);
  float3 directionalLight = baseColor * diffuse * fakeShadow;
  float3 ambientLight = baseColor * JS_AMBIENT_COLOR * JS_AMBIENT_INTENSITY;
  float3 finalSpecular = specular * fakeShadow;

  return saturate(directionalLight + ambientLight + finalSpecular);
}

static float jsFresnelSchlick(float cosTheta, float n1, float n2) {
  float r0 = pow((n1 - n2) / (n1 + n2), 2.0);
  return r0 + (1.0 - r0) * pow(1.0 - cosTheta, 5.0);
}

static float3 jsBeerLambert(float3 sigma, float dist) {
  return exp(-sigma * dist);
}

static bool jsSegmentOn(int digit, int segment) {
  switch (digit) {
    case 0: return segment != 6;
    case 1: return segment == 1 || segment == 2;
    case 2: return segment == 0 || segment == 1 || segment == 3 || segment == 4 || segment == 6;
    case 3: return segment == 0 || segment == 1 || segment == 2 || segment == 3 || segment == 6;
    case 4: return segment == 1 || segment == 2 || segment == 5 || segment == 6;
    case 5: return segment == 0 || segment == 2 || segment == 3 || segment == 5 || segment == 6;
    case 6: return segment == 0 || segment == 2 || segment == 3 || segment == 4 || segment == 5 || segment == 6;
    case 7: return segment == 0 || segment == 1 || segment == 2;
    case 8: return true;
    case 9: return segment == 0 || segment == 1 || segment == 2 || segment == 3 || segment == 5 || segment == 6;
    default: return false;
  }
}

static float jsDigitMask(float2 p, int digit) {
  float dist = 1.0e4;

  for (int segment = 0; segment < 7; segment++) {
    if (!jsSegmentOn(digit, segment)) {
      continue;
    }

    float2 center = float2(0.0);
    float2 halfSize = float2(0.34, 0.055);

    if (segment == 0) {
      center = float2(0.0, 0.86);
    } else if (segment == 1) {
      center = float2(0.46, 0.43);
      halfSize = float2(0.055, 0.34);
    } else if (segment == 2) {
      center = float2(0.46, -0.43);
      halfSize = float2(0.055, 0.34);
    } else if (segment == 3) {
      center = float2(0.0, -0.86);
    } else if (segment == 4) {
      center = float2(-0.46, -0.43);
      halfSize = float2(0.055, 0.34);
    } else if (segment == 5) {
      center = float2(-0.46, 0.43);
      halfSize = float2(0.055, 0.34);
    } else {
      center = float2(0.0, 0.0);
    }

    dist = min(dist, jsSdBox2d(p - center, halfSize));
  }

  return 1.0 - smoothstep(0.0, 0.045, dist);
}

static float jsPercentMask(float2 p) {
  float top = 1.0 - smoothstep(0.0, 0.055, abs(length(p - float2(-0.18, 0.42)) - 0.085));
  float bottom = 1.0 - smoothstep(0.0, 0.055, abs(length(p - float2(0.18, -0.42)) - 0.085));

  float2 a = float2(-0.32, -0.68);
  float2 b = float2(0.32, 0.68);
  float2 ab = b - a;
  float h = saturate(dot(p - a, ab) / dot(ab, ab));
  float slashDist = length(p - (a + ab * h));
  float slash = 1.0 - smoothstep(0.035, 0.075, slashDist);

  return saturate(max(max(top, bottom), slash));
}

static float jsRenderPercentageOnGround(float3 hitPosition, float progress) {
  float2 local = -float2(0.72 - hitPosition.x, hitPosition.z + 0.01);
  int percentage = int(round(saturate(progress) * 100.0));

  int hundreds = percentage / 100;
  int tens = (percentage / 10) % 10;
  int ones = percentage % 10;

  int count = percentage >= 100 ? 3 : (percentage >= 10 ? 2 : 1);
  float digitAdvance = 0.105;
  float startX = -0.5 * float(count - 1) * digitAdvance;
  float mask = 0.0;

  for (int i = 0; i < count; i++) {
    int digit = ones;
    if (count == 3) {
      digit = i == 0 ? hundreds : (i == 1 ? tens : ones);
    } else if (count == 2) {
      digit = i == 0 ? tens : ones;
    }

    float2 digitCenter = float2(startX + float(i) * digitAdvance, 0.0);
    float2 digitP = float2(
      (local.x - digitCenter.x) / 0.055,
      local.y / 0.115
    );
    mask = max(mask, jsDigitMask(digitP, digit));
  }

  float percentX = startX + float(count) * digitAdvance + 0.02;
  float2 percentP = float2((local.x - percentX) / 0.07, local.y / 0.13);
  mask = max(mask, jsPercentMask(percentP));
  return mask;
}

static float4 jsRenderBackground(float3 rayOrigin, float3 rayDirection, float backgroundHitDist,
                                 float3 lightDir, float progress, float4 jellyColor,
                                 float darkMode, thread const float4 *packs,
                                 thread const float4 *controlPacks) {
  float3 hitPosition = rayOrigin + rayDirection * backgroundHitDist;
  float3 normal = jsGetNormalMain(hitPosition);
  float endX = jsPoint(packs, JS_POINT_COUNT - 2).x;
  float textProgress = saturate((endX + 0.43) / 1.19);

  float sqDist = dot(hitPosition - float3(endX, 0.0, 0.0), hitPosition - float3(endX, 0.0, 0.0));
  float3 bounceLight = jellyColor.xyz * (1.0 / (sqDist * 15.0 + 1.0) * 0.4);
  float3 sideBounceLight = jellyColor.xyz * (1.0 / (sqDist * 40.0 + 1.0) * 0.3) * abs(normal.z);

  float3 litColor = jsCalculateLighting(hitPosition, normal, rayOrigin, lightDir, endX, jellyColor, packs, controlPacks);
  float ao = jsCalculateMainAO(hitPosition, normal, packs, controlPacks);
  float highlight = jsCalculateCausticHighlights(hitPosition, -lightDir, endX, packs, controlPacks);

  float3 groundAlbedo = mix(float3(1.0), float3(0.2), darkMode);
  float3 backgroundColor = groundAlbedo * litColor * ao;
  backgroundColor += bounceLight + sideBounceLight;

  float textMask = jsRenderPercentageOnGround(hitPosition, textProgress);
  float3 textColor = saturate(backgroundColor * mix(0.42, 1.35, darkMode));
  return float4(mix(backgroundColor, textColor, textMask) * (1.0 + highlight), 1.0);
}

static float3 jsRayMarchNoJelly(float3 rayOrigin, float3 rayDirection, float3 lightDir,
                                float progress, float4 jellyColor, float darkMode,
                                thread const float4 *packs, thread const float4 *controlPacks) {
  float distanceFromOrigin = 0.0;

  for (int i = 0; i < 6; i++) {
    float3 p = rayOrigin + rayDirection * distanceFromOrigin;
    float hit = jsGetMainSceneDist(p);
    distanceFromOrigin += hit;
    if (distanceFromOrigin > JS_MAX_DIST || hit < JS_SURF_DIST * 10.0) {
      break;
    }
  }

  if (distanceFromOrigin < JS_MAX_DIST) {
    return jsRenderBackground(rayOrigin, rayDirection, distanceFromOrigin,
                              lightDir, progress, jellyColor, darkMode, packs, controlPacks).xyz;
  }
  return float3(0.0);
}

[[stitchable]] half4 jellySlider(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float4 points0,
  float4 points1,
  float4 points2,
  float4 points3,
  float4 points4,
  float4 points5,
  float4 points6,
  float4 points7,
  float4 points8,
  float4 controls0,
  float4 controls1,
  float4 controls2,
  float4 controls3,
  float4 controls4,
  float4 controls5,
  float4 controls6,
  float4 controls7,
  float progress,
  float4 jellyColor,
  float3 lightDir,
  float darkMode
) {
  float4 packs[JS_PACK_COUNT] = {
    points0, points1, points2, points3, points4, points5, points6, points7, points8
  };
  float4 controlPacks[JS_CONTROL_PACK_COUNT] = {
    controls0, controls1, controls2, controls3, controls4, controls5, controls6, controls7
  };

  float2 uv = position / size;
  float2 ndc = float2(uv.x * 2.0 - 1.0, -(uv.y * 2.0 - 1.0));

  float3 ro = float3(0.024, 2.7, 1.9);
  float3 target = float3(0.0, 0.0, 0.0);
  float3 up = float3(0.0, 1.0, 0.0);

  ro.x += tilt.x * 0.25;
  ro.z += tilt.y * 0.25;

  float3 forward = normalize(target - ro);
  float3 right = normalize(cross(forward, up));
  float3 camUp = cross(right, forward);

  float fov = 0.7853981634;
  float aspectRatio = size.x / max(size.y, 1.0);
  float3 rd = normalize(forward + right * ndc.x * tan(fov * 0.5) * aspectRatio + camUp * ndc.y * tan(fov * 0.5));
  float3 ld = normalize(lightDir);

  float backgroundDist = 0.0;
  for (int i = 0; i < JS_MAX_STEPS; i++) {
    float3 p = ro + rd * backgroundDist;
    float hit = jsGetMainSceneDist(p);
    backgroundDist += hit;
    if (hit < JS_SURF_DIST) {
      break;
    }
  }

  float4 background = jsRenderBackground(ro, rd, backgroundDist, ld, progress, jellyColor, darkMode, packs, controlPacks);

  JSBoxIntersection sliderBox = jsIntersectBox(
    ro,
    rd,
    float3(-1.02, -0.30, -0.25),
    float3(1.09, 0.65, 0.25)
  );
  if (!sliderBox.hit) {
    float exposure = mix(1.3, 1.9, darkMode);
    float3 color = tanh(background.xyz * exposure);
    return half4(half3(color), 1.0h);
  }

  float distanceFromOrigin = max(0.0, sliderBox.tMin);
  float maxSliderDist = min(backgroundDist, sliderBox.tMax + 0.2);
  for (int i = 0; i < JS_MAX_STEPS; i++) {
    float3 currentPosition = ro + rd * distanceFromOrigin;
    JSHitInfo hitInfo = jsGetSceneDist(currentPosition, packs, controlPacks);
    distanceFromOrigin += hitInfo.distance;

    if (hitInfo.distance < JS_SURF_DIST) {
      float3 hitPosition = ro + rd * distanceFromOrigin;

      if (hitInfo.objectType != JS_OBJ_SLIDER) {
        break;
      }

      float3 normal = jsGetNormal(hitPosition, hitInfo, packs, controlPacks);
      float3 incident = rd;
      float cosi = min(1.0, max(0.0, dot(-incident, normal)));
      float fresnel = jsFresnelSchlick(cosi, 1.0, JS_JELLY_IOR);

      float3 reflection = saturate(float3(hitPosition.y + 0.2));

      float eta = 1.0 / JS_JELLY_IOR;
      float k = 1.0 - eta * eta * (1.0 - cosi * cosi);
      float3 refractedColor = float3(0.0);

      if (k > 0.0) {
        float3 refrDir = normalize(incident * eta + normal * (eta * cosi - sqrt(k)));
        float3 exitPos = hitPosition + refrDir * (JS_SURF_DIST * 4.0);
        float3 env = jsRayMarchNoJelly(exitPos, refrDir, ld, progress, jellyColor, darkMode, packs, controlPacks);

        float3 scatterTint = jellyColor.xyz * 1.5;
        float density = 20.0;
        float3 absorb = (float3(1.0) - jellyColor.xyz) * density;
        float localProgress = saturate(hitInfo.t);
        float3 transmittance = jsBeerLambert(absorb * (localProgress * localProgress), 0.08);

        float forwardScatter = max(0.0, dot(-ld, refrDir));
        float3 scatter = scatterTint * JS_JELLY_SCATTER_STRENGTH * forwardScatter * pow(localProgress, 3.0);
        refractedColor = env * transmittance + scatter;
      }

      float3 jelly = reflection * fresnel + refractedColor * (1.0 - fresnel);

      float exposure = mix(1.3, 1.9, darkMode);
      float3 color = tanh(jelly * exposure);
      return half4(half3(color), 1.0h);
    }

    if (distanceFromOrigin > maxSliderDist) {
      break;
    }
  }

  float exposure = mix(1.3, 1.9, darkMode);
  float3 color = tanh(background.xyz * exposure);
  return half4(half3(color), 1.0h);
}
