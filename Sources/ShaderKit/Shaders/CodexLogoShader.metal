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

[[stitchable]] half4 codexBadgeFoil(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float intensity,
  float glow
) {
  half4 sampled = layer.sample(position);
  float alpha = float(sampled.a);

  if (alpha <= 0.001) {
    return sampled;
  }

  float2 safeSize = max(size, float2(1.0));
  float2 uv = position / safeSize;
  float2 reactiveTilt = clamp(tilt, float2(-1.0), float2(1.0));
  float t = time * 0.72;

  float vertical = smoothstep(0.0, 1.0, uv.y);
  float3 top = float3(0.64, 0.62, 1.0);
  float3 middle = float3(0.46, 0.58, 1.0);
  float3 bottom = float3(0.24, 0.30, 1.0);
  float3 violet = float3(0.58, 0.55, 1.0);
  float3 base = codexMix(top, middle, smoothstep(0.10, 0.48, vertical));
  base = codexMix(base, bottom, smoothstep(0.42, 1.0, vertical));
  base = codexMix(base, violet, smoothstep(0.0, 0.35, 1.0 - uv.y) * 0.08);
  base = codexMix(float3(sampled.rgb), base, 1.0);

  float2 centered = (uv - 0.5) * 2.0;
  centered.x *= safeSize.x / safeSize.y;
  float radial = length(centered);
  float dome = codexSaturate(1.0 - radial * 0.72);
  float3 normal = normalize(float3(
    -centered.x * 0.36 + reactiveTilt.x * 0.10,
    -centered.y * 0.36 + reactiveTilt.y * 0.10,
    0.72 + dome * 0.62
  ));
  float3 lightDir = normalize(float3(
    -0.45 + reactiveTilt.x * 0.28,
    -0.62 + reactiveTilt.y * 0.24,
    0.96
  ));
  float3 viewDir = normalize(float3(
    -reactiveTilt.x * 0.18,
    -reactiveTilt.y * 0.16,
    1.0
  ));
  float3 halfDir = normalize(lightDir + viewDir);
  float ndotl = codexSaturate(dot(normal, lightDir));
  float ndoth = codexSaturate(dot(normal, halfDir));
  float ndotv = codexSaturate(dot(normal, viewDir));
  float metalShadow = pow(1.0 - ndotl, 1.45) * smoothstep(0.20, 0.96, radial);
  float grazing = pow(1.0 - ndotv, 2.25);
  float specularWide = pow(ndoth, 15.0);
  float specularTight = pow(ndoth, 56.0);
  float clearcoat = pow(ndoth, 118.0);
  float filmWave = sin((normal.x * 2.9 - normal.y * 1.8 + radial * 1.7 + t * 0.30) * 6.28318) * 0.5 + 0.5;

  float2 diagonalDirection = normalize(float2(0.72, 1.0));
  float diagonal = dot(uv + reactiveTilt * 0.20, diagonalDirection);
  float sweepTravel = fract(t * 0.16 + reactiveTilt.x * 0.10 + reactiveTilt.y * 0.05);
  float sweepCenter = -0.20 + sweepTravel * 1.72;
  float sweepWarp = (valueNoise(uv * 3.0 + float2(t * 0.10, -t * 0.06)) - 0.5) * 0.10;
  sweepWarp += sin((uv.x * 1.7 - uv.y * 1.15 + t * 0.22) * 6.28318) * 0.025;
  float sweepDistance = diagonal + sweepWarp - sweepCenter;
  float sweepEnvelope = smoothstep(0.0, 0.12, sweepTravel) * smoothstep(1.0, 0.82, sweepTravel);
  float upperReflectionMask = smoothstep(0.80, 0.18, uv.y);
  float softSweep = exp(-pow(sweepDistance / 0.30, 2.0)) * sweepEnvelope * upperReflectionMask * 0.24;
  float sweepCore = exp(-pow(sweepDistance / 0.12, 2.0)) * sweepEnvelope * upperReflectionMask * 0.16;
  float sweepGlow = exp(-pow(sweepDistance / 0.48, 2.0)) * sweepEnvelope * upperReflectionMask * 0.18;
  float bandCenter = 0.56 + reactiveTilt.x * 0.16 + reactiveTilt.y * 0.08 + sin(t * 0.55) * 0.04;
  float bandDistance = (diagonal - bandCenter) / 0.20;
  float broadBand = max(exp(-(bandDistance * bandDistance)) * 0.20, softSweep);
  float hotBand = max(exp(-(bandDistance * bandDistance) * 8.5) * 0.12, sweepCore * 0.44);

  float counterDiagonal = dot(uv + float2(reactiveTilt.y, -reactiveTilt.x) * 0.12, normalize(float2(-0.65, 1.0)));
  float secondaryDistance = (counterDiagonal - (0.38 - sin(t * 0.74) * 0.12)) / 0.24;
  float secondaryBand = exp(-(secondaryDistance * secondaryDistance)) * 0.62;

  float glassArcY = 0.20 + sin((uv.x + reactiveTilt.x * 0.10) * 3.14159) * 0.075 + reactiveTilt.y * 0.035;
  float glassArc = exp(-pow((uv.y - glassArcY) / 0.095, 2.0));
  glassArc *= smoothstep(0.06, 0.35, uv.x) * smoothstep(0.96, 0.48, uv.x) * smoothstep(0.58, 0.08, uv.y) * 0.32;

  float glassStreak = smoothstep(0.055, 0.0, abs(diagonal - (0.18 + reactiveTilt.x * 0.12 + sin(t * 0.6) * 0.05)));
  glassStreak *= smoothstep(0.05, 0.40, uv.x) * smoothstep(0.64, 0.22, uv.y) * 0.28;

  float foilLines = sin((diagonal + t * 0.16) * 82.0) * 0.5 + 0.5;
  foilLines = pow(codexSaturate(foilLines), 10.0);
  float brushed = sin((uv.x - uv.y * 0.26 + reactiveTilt.x * 0.18) * 72.0 + t * 1.8) * 0.5 + 0.5;
  brushed = pow(codexSaturate(brushed), 6.0);
  float microRidges = sin((uv.x * 0.52 + uv.y + t * 0.08) * 165.0) * 0.5 + 0.5;
  microRidges = pow(codexSaturate(microRidges), 18.0);
  float chromeRidges = sin((normal.x * 0.72 + normal.y * 0.38 + diagonal * 0.44 + t * 0.10) * 210.0) * 0.5 + 0.5;
  chromeRidges = pow(codexSaturate(chromeRidges), 20.0) * (0.22 + specularWide * 0.78);
  float mirrorLine = smoothstep(0.050, 0.0, abs(sweepDistance));
  mirrorLine *= smoothstep(0.12, 0.56, uv.x) * smoothstep(0.94, 0.30, uv.y);

  float2 sparkleUV = uv * 48.0;
  float2 sparkleCell = floor(sparkleUV);
  float2 sparkleLocal = fract(sparkleUV) - 0.5;
  float sparkleRandom = hash21(sparkleCell);
  float sparklePhase = sparkleRandom * 6.28318 + t * 9.5 + reactiveTilt.x * 10.0;
  float sparklePoint = smoothstep(0.22, 0.0, length(sparkleLocal));
  float sparkle = sparklePoint * pow(max(0.0, sin(sparklePhase)), 11.0) * step(0.72, sparkleRandom);
  float starSparkle = sparklePoint * pow(max(0.0, sin(sparklePhase * 0.62 + 1.7)), 22.0) * step(0.92, sparkleRandom);

  float upperGlow = smoothstep(0.82, 0.08, radial) * smoothstep(0.88, 0.12, uv.y);
  float edgeGlow = smoothstep(0.48, 0.98, radial) * smoothstep(1.08, 0.76, radial);
  float lowerDepth = smoothstep(0.34, 1.0, uv.y) * 0.08;

  half3 violetFoil = half3(0.72h, 0.68h, 1.0h);
  half3 cyanFoil = half3(0.58h, 0.78h, 1.0h);
  half3 whiteFoil = half3(1.0h, 0.98h, 0.92h);
  half3 glassBlue = half3(0.66h, 0.82h, 1.0h);
  half3 deepViolet = half3(0.34h, 0.38h, 0.98h);
  half3 chromeViolet = half3(0.78h, 0.72h, 1.0h);
  half3 chromeCyan = half3(0.62h, 0.86h, 1.0h);
  half3 filmColor = mix(chromeViolet, chromeCyan, half(filmWave));
  half3 foilColor = mix(violetFoil, cyanFoil, half(smoothstep(0.10, 0.90, diagonal)));
  foilColor = mix(foilColor, whiteFoil, half(hotBand * 0.28));

  half3 result = half3(base);
  result = mix(result, blendMultiply(result, deepViolet), half(metalShadow * 0.10));
  result = blendScreen(result, filmColor * half((specularWide * 0.10 + grazing * 0.03 + chromeRidges * 0.08) * intensity * upperReflectionMask));
  result = blendScreen(result, foilColor * half((broadBand * 0.12 + secondaryBand * 0.08 + hotBand * 0.10) * intensity * upperReflectionMask));
  result = blendScreen(result, glassBlue * half((glassArc * 0.10 + glassStreak * 0.08) * glow));
  result = blendScreen(result, cyanFoil * half((foilLines * 0.08 + brushed * 0.06 + microRidges * 0.05 + chromeRidges * 0.06) * intensity * upperReflectionMask));
  half specularMask = half(codexSaturate(hotBand * 0.32 + specularTight * 0.42 + clearcoat * 0.50 + mirrorLine * 0.20 + softSweep * 0.14));
  half3 paletteBody = half3(base);
  result = mix(result, paletteBody, half(0.22h) * (1.0h - specularMask * 0.58h));
  result = blendColorDodge(result, whiteFoil * half((hotBand * 0.01 + specularTight * 0.04 + clearcoat * 0.05) * intensity * upperReflectionMask));
  result = mix(result, paletteBody, half(softSweep * 0.16));
  result += filmColor * half((specularWide * 0.12 + chromeRidges * 0.08 + softSweep * 0.06 + sweepGlow * 0.04) * glow);
  result += whiteFoil * half((sparkle * 0.52 + starSparkle * 0.72 + upperGlow * 0.03 + edgeGlow * 0.03 + specularTight * 0.12 + clearcoat * 0.18 + mirrorLine * 0.04 + sweepCore * 0.03) * glow);
  result -= half3(0.01h, 0.012h, 0.03h) * half(lowerDepth);
  result = adjustSaturation(result, 1.04);
  result = adjustContrast(result, 1.04);

  return half4(clamp(result, half3(0.0h), half3(1.0h)), half(alpha));
}
