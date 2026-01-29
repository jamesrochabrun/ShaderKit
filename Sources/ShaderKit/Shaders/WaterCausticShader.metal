//
//  WaterCausticShader.metal
//  ShaderKit
//
//  Water caustic effect with realistic light refraction patterns
//  Inspired by Paper Design water shader (paper.design)
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// =============================================================================
// MARK: - Simplex Noise (2D)
// =============================================================================

// Permutation polynomial for hashing
static float3 permute_wc(float3 x) {
  return fmod(((x * 34.0) + 1.0) * x, 289.0);
}

// 2D Simplex noise - smoother than value noise
static float simplexNoise2D(float2 v) {
  const float4 C = float4(
    0.211324865405187,   // (3.0-sqrt(3.0))/6.0
    0.366025403784439,   // 0.5*(sqrt(3.0)-1.0)
    -0.577350269189626,  // -1.0 + 2.0 * C.x
    0.024390243902439    // 1.0 / 41.0
  );

  // First corner
  float2 i = floor(v + dot(v, C.yy));
  float2 x0 = v - i + dot(i, C.xx);

  // Other corners
  float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = fmod(i, 289.0);
  float3 p = permute_wc(permute_wc(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));

  float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;

  // Gradients
  float3 x = 2.0 * fract(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

  // Compute final noise value at P
  float3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// =============================================================================
// MARK: - Caustic Pattern (Twigl GLSL inspired)
// =============================================================================

static float2x2 rotation2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return float2x2(c, -s, s, c);
}

// Returns x: caustic value, y/z: N vector for distortion
static float3 causticFieldV2(float2 p, float time, float patternSize) {
  float S = 9.0 / max(patternSize, 0.01);
  float a = 0.0;
  float2 n = float2(0.0);
  float2 N = float2(0.0);
  float2x2 m = rotation2D(5.0);

  for (int i = 0; i < 30; i++) {
    p = m * p;
    n = m * n;
    float2 q = p * S + float(i) + n + time;
    a += (cos(q.x) + cos(q.y)) / S;
    q = sin(q);
    n += q;
    N += q / (S + 60.0);
    S *= 1.2;
  }

  return float3(a, N.x, N.y);
}

// =============================================================================
// MARK: - Main Water Caustic Shader
// =============================================================================

[[stitchable]] half4 waterCaustic(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float4 colorBack,
  float4 colorHighlight,
  float highlights,
  float layering,
  float edges,
  float waves,
  float caustic,
  float speed,
  float scale
) {
  // Normalize coordinates and apply scale (zoom)
  float2 uv = position / size;
  uv = (uv - 0.5) * scale + 0.5;

  // Apply tilt offset for parallax effect
  float2 tiltOffset = tilt * 0.08;

  float t = time * speed;

  // === Flow field for fluid distortion ===
  float2 flow1 = float2(
    simplexNoise2D(uv * 2.6 + float2(0.0, t * 0.15)),
    simplexNoise2D(uv * 2.6 + float2(5.2, t * 0.15))
  );
  float2 flow2 = float2(
    simplexNoise2D(uv * 6.0 + float2(t * 0.3, 2.3)),
    simplexNoise2D(uv * 6.0 + float2(1.7, t * 0.3))
  );
  float2 flow = flow1 + 0.5 * flow2;

  float2 ripple = float2(
    sin((uv.y + t * 0.05) * 12.0),
    cos((uv.x - t * 0.05) * 12.0)
  );

  // Base distortion in UV space
  float2 distortion = (flow + ripple * 0.2) * (waves * 0.02);

  // Edge distortion to create subtle water-like wobble near edges
  float edgeDist = min(min(uv.x, uv.y), min(1.0 - uv.x, 1.0 - uv.y));
  float edgeMask = smoothstep(0.0, 0.12, edgeDist);
  float edgeWarp = (1.0 - edgeMask) * edges;
  distortion += flow2 * edgeWarp * 0.015;

  // === Soft caustic modulation (subtle) ===
  float2 causticUV = uv * 2.4 + tiltOffset + flow * 0.12;
  float3 causticA = causticFieldV2(causticUV, t * 0.2, 1.0);
  float3 causticB = causticFieldV2(causticUV * 1.1 + float2(0.7, 1.3), t * 0.23 + 1.5, 0.85);

  float a = causticA.x + causticB.x * layering;
  float2 N = float2(causticA.y, causticA.z) + float2(causticB.y, causticB.z) * layering;

  float nLen = length(N);
  float causticBase = (a + 0.5) * 0.1;
  float causticGlow = 0.003 / max(nLen, 0.0004);
  float causticField = max(0.0, causticBase + causticGlow);
  float causticBoost = pow(causticField, 0.45) * caustic;

  distortion += normalize(N + float2(0.0001, 0.0001)) * (causticBoost * 0.008);

  // === Create background caustic color ===
  half3 backColor = half3(colorBack.x, colorBack.y, colorBack.z);
  half3 highlightColor = half3(colorHighlight.x, colorHighlight.y, colorHighlight.z);

  // === Sample the image WITH water distortion ===
  float2 warpedUV = uv + distortion;
  float2 samplePos = warpedUV * size;
  half4 sampledColor = layer.sample(samplePos);

  // === Apply subtle caustic light ===
  half3 result;
  // Sun glints: derive a soft pseudo-normal from noise and add a specular highlight
  float heightFreq = 4.0;
  float2 heightOffset = float2(t * 0.08, t * 0.06);
  float eps = 1.5 / max(size.x, size.y);
  float heightBase = simplexNoise2D(uv * heightFreq + heightOffset);
  float heightX = simplexNoise2D((uv + float2(eps, 0.0)) * heightFreq + heightOffset);
  float heightY = simplexNoise2D((uv + float2(0.0, eps)) * heightFreq + heightOffset);
  float2 grad = float2(heightX - heightBase, heightY - heightBase) / max(eps, 0.0002);
  float3 normal = normalize(float3(-grad.x * 0.12, -grad.y * 0.12, 1.0));
  float3 lightDir = normalize(float3(-0.2, -0.4, 1.0));
  float3 viewDir = float3(0.0, 0.0, 1.0);
  float3 halfDir = normalize(lightDir + viewDir);
  float spec = pow(max(dot(normal, halfDir), 0.0), 28.0);

  float2 sunPos = float2(0.75 + tilt.x * 0.08, 0.15 - tilt.y * 0.08);
  float sunMask = smoothstep(0.85, 0.0, distance(uv, sunPos));
  float sunGlow = smoothstep(1.05, 0.0, distance(uv, sunPos));
  float glint = (spec * sunMask + sunGlow * 0.35) * highlights;

  half3 causticLight = highlightColor * half(causticBoost * highlights * 1.4 + glint * 1.8);

  if (sampledColor.a < 0.1h) {
    result = backColor;
    result = half3(1.0) - (half3(1.0) - result) * (half3(1.0) - causticLight);
  } else {
    half3 base = sampledColor.rgb;
    // Apply backColor as color tint/wash
    base = mix(base, base * backColor, half(0.2));
    result = half3(1.0) - (half3(1.0) - base) * (half3(1.0) - causticLight);
  }

  return half4(result, sampledColor.a);
}
