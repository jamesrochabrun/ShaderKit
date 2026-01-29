//
//  WaterShader.metal
//  ShaderKit
//
//  Water caustic effect based on Twigl GLSL reference
//  https://twigl.app/?ol=true&ss=-NOAlYulOVLklxMdxBDx
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"

using namespace metal;

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
// MARK: - Main Water Caustic V2 Shader
// =============================================================================

[[stitchable]] half4 water(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float4 colorBack,
  float4 colorHighlight,
  float highlights,
  float edges,
  float waves,
  float caustic,
  float patternSize,
  float speed,
  float scale
) {
  float2 uv = position / size;
  uv = (uv - 0.5) * scale + 0.5;

  float2 aspect = float2(size.x / size.y, 1.0);
  float2 p = uv * aspect + tilt * 0.2;

  float t = time * speed;

  float3 causticA = causticFieldV2(p, t * 0.2, patternSize);
  float a = causticA.x;
  float2 N = float2(causticA.y, causticA.z);

  float nLen = length(N);
  float causticBase = (a + 0.5) * 0.1;
  float causticGlow = 0.003 / max(nLen, 0.0004);
  float causticField = max(0.0, causticBase + causticGlow);
  float causticIntensity = pow(causticField, 0.45) * caustic;

  float2 causticDir = normalize(N + float2(0.0001, 0.0001));

  float2 waveNoise = float2(
    valueNoise(uv * 3.2 + float2(0.0, t * 0.15)),
    valueNoise(uv * 3.2 + float2(5.2, t * 0.15))
  ) - 0.5;
  float2 waveDist = waveNoise * (waves * 0.04);

  float edgeDist = min(min(uv.x, uv.y), min(1.0 - uv.x, 1.0 - uv.y));
  float edgeMask = smoothstep(0.0, 0.18, edgeDist);
  float edgePower = (1.0 - edgeMask) * edges;

  float2 distortion = waveDist;
  distortion += causticDir * (causticIntensity * 0.02);
  distortion += causticDir * (edgePower * 0.015);

  float2 warpedUV = uv + distortion;
  float2 samplePos = warpedUV * size;
  half4 sampledColor = layer.sample(samplePos);

  half3 backColor = half3(colorBack.x, colorBack.y, colorBack.z);
  half3 highlightColor = half3(colorHighlight.x, colorHighlight.y, colorHighlight.z);

  half3 baseColor = sampledColor.a < 0.1h ? backColor : sampledColor.rgb;
  if (sampledColor.a >= 0.1h) {
    baseColor = mix(baseColor, baseColor * backColor, half(0.18));
  }

  float highlightMask = clamp(causticIntensity, 0.0, 1.0);
  half3 causticColor = mix(backColor, highlightColor, half(highlightMask));
  half highlightStrength = half(highlights) * half(highlightMask);

  half3 result = mix(baseColor, causticColor, highlightStrength);

  return half4(result, sampledColor.a);
}
