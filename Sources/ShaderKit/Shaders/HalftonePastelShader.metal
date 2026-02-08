//
//  HalftonePastelShader.metal
//  ShaderKit
//
//  Halftone dot pattern with pastel holographic iridescent colors
//  Rounded-square dots over a smooth flowing pastel gradient
//  with diagonal chevron wave bands
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Lp-norm distance for rounded-square shape
static float lpNorm(float2 v, float p) {
  return pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1.0 / p);
}

// 5-stop wrapping pastel gradient
static half3 pastelGradient5(float t) {
  half3 colors[5] = {
    half3(0.78h, 0.72h, 0.96h), // lavender
    half3(0.65h, 0.90h, 0.95h), // cyan
    half3(0.95h, 0.72h, 0.82h), // pink
    half3(0.96h, 0.92h, 0.78h), // cream
    half3(0.78h, 0.72h, 0.96h)  // wrap back to lavender
  };

  float scaledT = fract(t) * 4.0;
  int idx = int(scaledT);
  float blend = fract(scaledT);
  int next = (idx + 1) % 5;
  return mix(colors[idx], colors[next], half(blend));
}

[[stitchable]] half4 halftonePastel(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float dotDensity,
    float waveSpeed
) {
  float2 uv = position / size;
  half4 originalColor = layer.sample(position);

  if (originalColor.a < 0.01h) {
    return originalColor;
  }

  // Tilt-reactive light center
  float2 lightPos = float2(0.5 + tilt.x * 0.6, 0.5 + tilt.y * 0.6);
  float lightDist = length(uv - lightPos);
  float hotspot = smoothstep(0.8, 0.0, lightDist);
  hotspot = pow(hotspot, 1.2);

  // --- B. Rotated halftone grid (~35 degrees) ---
  float angle = 35.0 * 3.14159 / 180.0;
  float cosA = cos(angle);
  float sinA = sin(angle);
  float2 centered = uv - 0.5;
  float2 rotUV = float2(
    centered.x * cosA - centered.y * sinA,
    centered.x * sinA + centered.y * cosA
  );
  rotUV += 0.5;

  float density = dotDensity;
  float2 gridUV = rotUV * density;
  float2 cell = floor(gridUV);
  float2 local = fract(gridUV) - 0.5;

  // --- D. Chevron wave bands ---
  // Two dominant diagonal projections from light center create V-shaped bands
  float2 fromLight = uv - lightPos;
  float diag1 = fromLight.x + fromLight.y;
  float diag2 = fromLight.x - fromLight.y;
  float radial = length(fromLight);

  float chevron1 = sin(diag1 * 8.0 + tilt.x * 5.0 + time * waveSpeed * 0.4) * 0.5 + 0.5;
  float chevron2 = sin(diag2 * 7.0 + tilt.y * 5.0 + time * waveSpeed * 0.3) * 0.5 + 0.5;
  float radialMod = sin(radial * 6.0 - time * waveSpeed * 0.5) * 0.5 + 0.5;

  float waveMix = chevron1 * 0.45 + chevron2 * 0.35 + radialMod * 0.2;
  // Increase contrast between large and tiny dots
  waveMix = smoothstep(0.15, 0.85, waveMix);

  // Dot radius modulated by waves and hotspot proximity
  float baseRadius = 0.08 + waveMix * 0.36;
  float hotspotBoost = hotspot * 0.08;
  float dotRadius = baseRadius + hotspotBoost;

  // --- A. Rounded-square dot shape via Lp-norm ---
  float dist = lpNorm(local, 3.5);

  // --- E. Soft feathered edges ---
  float dot = smoothstep(dotRadius, dotRadius - 0.15, dist);

  // --- C. Smooth continuous pastel gradient ---
  // Computed on original UV, tilt shifts for parallax, slow time drift
  float gradT = (uv.x + uv.y) * 0.5
    + tilt.x * 0.2 + tilt.y * 0.15
    + time * 0.04;
  half3 gradient = pastelGradient5(gradT);

  // Tilt-reactive hue shift for extra iridescence
  float hueShift = tilt.x * 0.08 + tilt.y * 0.06;
  half3 shiftedGrad = hsv2rgb(half3(
    half(fract(float(rgb2hsv(gradient).x) + hueShift)),
    rgb2hsv(gradient).y * 0.9h,
    rgb2hsv(gradient).z
  ));

  // Light-following brightness
  half3 brightHighlight = half3(1.0h, 0.98h, 0.95h);
  shiftedGrad = mix(shiftedGrad, brightHighlight, half(hotspot * 0.25));

  // --- E. Composition: dots as transparency mask over gradient ---
  // Gap tint: faintly tinted version of original content
  half3 gapTint = mix(originalColor.rgb, half3(0.96h, 0.94h, 0.97h), 0.15h);
  half3 holoLayer = mix(gapTint, shiftedGrad, half(dot));

  // Sparkle on brightest dots near hotspot
  float sparkleHash = hash21(cell);
  float sparklePhase = sparkleHash * 6.28 + (tilt.x + tilt.y) * 6.0 + time * 2.5;
  float sparkle = pow(max(0.0, sin(sparklePhase)), 12.0);
  sparkle *= step(0.75, sparkleHash);
  sparkle *= dot * hotspot;

  // Final blend with original content
  half blendStrength = half(intensity * (0.6 + hotspot * 0.4));
  half3 result = mix(originalColor.rgb, holoLayer, blendStrength);

  // Add sparkle highlights
  result += half(sparkle * 0.8 * intensity) * half3(1.0h, 1.0h, 1.0h);

  // Subtle overall brightness boost near light center
  result *= half(1.0 + hotspot * 0.12);

  return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
