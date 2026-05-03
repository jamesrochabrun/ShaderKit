//
//  CodexLogoShader.metal
//  ShaderKit
//
//  Demo-only Codex Logo neural gradient shader
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

static float codexSaturate(float value) {
  return clamp(value, 0.0, 1.0);
}

static float3 codexMix(float3 a, float3 b, float value) {
  return a + (b - a) * value;
}

[[stitchable]] half4 codexLogoBrain(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float intensity,
  float pulseSpeed,
  float neuralDensity,
  float glow,
  float motionResponse
) {
  half4 sampled = layer.sample(position);
  float alpha = float(sampled.a);

  if (alpha <= 0.001) {
    return sampled;
  }

  float2 safeSize = max(size, float2(1.0));
  float2 uv = position / safeSize;
  float2 reactiveTilt = tilt * motionResponse;
  float t = time * max(pulseSpeed, 0.05);

  float2 lightCenter = float2(0.49, 0.49) + reactiveTilt * 0.16;
  float2 centered = (uv - lightCenter) * 2.0;
  centered.x *= safeSize.x / safeSize.y;
  float radial = length(centered);
  float angle = atan2(centered.y, centered.x);
  float pulse = 0.5 + 0.5 * sin(t * 4.0 - radial * 2.6);

  float density = max(neuralDensity, 0.1);
  float waveA = sin((centered.x + reactiveTilt.x * 0.28) * 12.0 * density + t * 2.4);
  float waveB = sin((centered.y - reactiveTilt.y * 0.25) * 15.0 * density - t * 2.0);
  float waveC = sin(angle * 6.0 + radial * 22.0 * density - t * 1.7);
  float interference = (waveA + waveB + waveC) / 3.0;
  float neural = pow(codexSaturate(abs(interference)), 2.4);

  float neuralLattice = smoothstep(0.46, 0.92, neural);
  float synapse = pow(codexSaturate(sin((radial * 28.0 - t * 3.1) + angle * 3.4)), 16.0);

  float rays1 = sin(angle * 12.0 + reactiveTilt.x * 8.0 + t * 0.58) * 0.5 + 0.5;
  float rays2 = sin(angle * 18.0 - reactiveTilt.y * 7.0 - t * 0.42) * 0.5 + 0.5;
  float rays3 = sin(angle * 26.0 + (reactiveTilt.x + reactiveTilt.y) * 5.0 + radial * 3.0) * 0.5 + 0.5;
  float starburst = pow(rays1 * 0.42 + rays2 * 0.34 + rays3 * 0.24, 1.85);
  starburst *= smoothstep(0.98, 0.08, radial) * 0.78;

  float film = sin((uv.x * 2.2 + uv.y * 3.4 + reactiveTilt.x * 2.0 + reactiveTilt.y * 1.5 + t * 0.12) * 3.14159) * 0.5 + 0.5;
  float brushed = sin((uv.x * 1.55 - uv.y * 1.05 + reactiveTilt.x * 0.45 + t * 0.08) * 54.0) * 0.5 + 0.5;
  brushed = pow(codexSaturate(brushed), 9.0);
  float foilLine = pow(codexSaturate(sin((uv.x + uv.y * 0.45 + reactiveTilt.y * 0.18) * 92.0 - t * 0.7)), 14.0);

  float hueAngle = angle / 6.28318 + 0.5;
  half3 rainbow1 = hsv2rgb(half(fract(hueAngle + reactiveTilt.x * 0.16 + t * 0.028)), 0.82h, 1.0h);
  half3 rainbow2 = hsv2rgb(half(fract(hueAngle + film * 0.36 + reactiveTilt.y * 0.15)), 0.58h, 1.0h);
  half3 rainbow3 = hsv2rgb(half(fract(radial * 0.65 + uv.x * 0.28 - t * 0.018)), 0.72h, 0.95h);
  half3 rainbowBlend = mix(rainbow1, rainbow2, half(starburst));
  rainbowBlend = mix(rainbowBlend, rainbow3, half(rays3 * 0.34));

  float2 hotspot1 = float2(0.43 + reactiveTilt.x * 0.48, 0.30 + reactiveTilt.y * 0.40);
  float2 hotspot2 = float2(0.64 - reactiveTilt.y * 0.30, 0.58 + reactiveTilt.x * 0.28);
  float hot1 = pow(smoothstep(0.70, 0.0, distance(uv, hotspot1)), 2.2);
  float hot2 = pow(smoothstep(0.52, 0.0, distance(uv, hotspot2)), 2.5) * 0.65;
  float totalHot = min(hot1 + hot2, 1.35);

  float sparkleGrid = 46.0 + density * 22.0;
  float2 sparkleUV = uv * sparkleGrid;
  float2 sparkleCell = floor(sparkleUV);
  float2 sparkleLocal = fract(sparkleUV) - 0.5;
  float sparkleRand = hash21(sparkleCell);
  float sparklePhase = sparkleRand * 6.28318 + (reactiveTilt.x + reactiveTilt.y) * 16.0 + t * 4.2;
  float sparklePoint = smoothstep(0.16, 0.0, length(sparkleLocal));
  float sparkle = sparklePoint * pow(max(0.0, sin(sparklePhase)), 10.0) * step(0.72, sparkleRand);
  float megaSparkle = sparklePoint * pow(max(0.0, sin(sparklePhase * 0.45 + 1.1)), 18.0) * step(0.92, sparkleRand);

  float texture = valueNoise(uv * 92.0 + reactiveTilt * 4.0) * 0.08;
  texture += valueNoise(uv * 155.0 - reactiveTilt * 3.0) * 0.05;

  float3 top = float3(0.66, 0.70, 1.0);
  float3 middle = float3(0.40, 0.55, 1.0);
  float3 bottom = float3(0.18, 0.29, 1.0);
  float3 violet = float3(0.45, 0.30, 0.98);
  float3 cyan = float3(0.28, 0.95, 1.0);
  float3 magenta = float3(0.72, 0.42, 0.96);
  float3 warmWhite = float3(1.0, 0.92, 0.72);

  float3 base = codexMix(top, middle, smoothstep(0.06, 0.46, uv.y + reactiveTilt.y * 0.08));
  base = codexMix(base, bottom, smoothstep(0.42, 0.96, uv.y - reactiveTilt.y * 0.08));
  base = codexMix(base, violet, smoothstep(0.58, 1.05, uv.y + uv.x * 0.20));

  float3 neuralColor = codexMix(cyan, magenta, 0.5 + 0.5 * sin(angle * 2.0 + t));
  half3 spectralFoil = mix(rainbowBlend, half3(0.55h, 0.64h, 1.0h), 0.34h);
  half3 result = half3(base);
  result = mix(result, spectralFoil, half(intensity * (0.10 + starburst * 0.24 + totalHot * 0.08)));
  result = blendScreen(result, spectralFoil * half(starburst * 0.28 * intensity));
  result += half3(neuralColor) * half(neuralLattice * 0.15 * intensity);
  result += half3(cyan) * half(synapse * 0.16 * intensity);
  result += half3(warmWhite) * half((totalHot * 0.24 + brushed * 0.18 + foilLine * 0.13) * glow);
  result += (half3(1.0h, 1.0h, 1.0h) + rainbowBlend * 0.35h) * half((sparkle * 1.1 + megaSparkle * 2.2) * intensity);
  result *= half(0.94 + pulse * 0.16 * intensity + texture);
  result = (result - 0.5h) * 1.10h + 0.5h;

  return half4(clamp(result, half3(0.0h), half3(1.0h)), half(alpha));
}
