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
// MARK: - Caustic Pattern (Shadertoy-style)
// =============================================================================

// Caustic pattern - Shadertoy-style algorithm for visible caustic lines
// Returns both caustic value (x) and glow magnitude (y)
static float2 causticPattern(float2 p, float time, float patternSize, float speed) {
  float result = 0.0;
  float scale = 9.0;
  float2 n = float2(0.0);
  float2 N = float2(0.0);

  // Rotation matrix at angle 5 radians (~286 degrees)
  float angle = 5.0;
  float2x2 m = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));

  // Scale input position
  p = p * patternSize;

  // 30 iterations for dramatic caustic pattern
  for (int i = 0; i < 30; i++) {
    // Rotate coordinates each iteration
    p = m * p;
    n = m * n;

    // Query position with time animation
    float2 q = p * scale + float(i) + n + time * speed;

    // Accumulate caustic pattern: (cos(q.x) + cos(q.y)) / scale
    result += (cos(q.x) + cos(q.y)) / scale;

    // Accumulate offset and glow
    q = sin(q);
    n += q;
    N += q / (scale + 60.0);

    // Increase scale
    scale *= 1.2;
  }

  // Return caustic value and glow magnitude
  return float2(result, length(N));
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
  float patternSize,
  float speed,
  float scale
) {
  // Normalize coordinates
  float2 uv = position / size;

  // Apply tilt offset for parallax effect
  float2 tiltOffset = tilt * 0.08;

  // === Calculate caustic pattern ===
  float2 causticUV = uv * 2.5 + tiltOffset;

  // Get caustic value and glow from new algorithm
  float2 causticResult1 = causticPattern(causticUV, time, patternSize, speed);
  float2 causticResult2 = causticPattern(causticUV * 0.8 + 0.3, time + 1.5, patternSize * 1.1, speed * 0.8);

  // Primary caustic and glow
  float caustic1 = causticResult1.x;
  float glow1 = causticResult1.y;

  // Secondary layer
  float caustic2 = causticResult2.x;
  float glow2 = causticResult2.y;

  // Combine caustic layers
  float combinedCaustic = caustic1 + caustic2 * layering;
  float combinedGlow = glow1 + glow2 * layering;

  // === Create background caustic color ===
  half3 backColor = half3(colorBack.x, colorBack.y, colorBack.z);
  half3 highlightColor = half3(colorHighlight.x, colorHighlight.y, colorHighlight.z);

  // === Shadertoy-style caustic processing ===
  // Normalize caustic value
  float causticNorm = (combinedCaustic + 0.5) * 0.1;

  // Add glow contribution
  causticNorm += 0.003 / max(combinedGlow, 0.001);

  // Apply pow(0.45) for sharp contrast - this creates the bright network lines
  float causticLines = pow(max(0.0, causticNorm), 0.45);

  // Create caustic color with high contrast
  half3 causticColor = backColor * half(causticLines * 6.0);

  // Add highlight peaks
  float highlightMask = smoothstep(0.5, 0.8, causticLines) * highlights;

  // Tilt-reactive highlights
  float tiltFactor = (tilt.x + tilt.y) * 0.3 + 0.5;
  tiltFactor = clamp(tiltFactor, 0.3, 1.0);
  highlightMask *= tiltFactor;

  causticColor = mix(causticColor, highlightColor, half(highlightMask));

  // Clamp to prevent blowout
  causticColor = min(causticColor, half3(2.0));

  // === Sample the image WITHOUT distortion ===
  float2 samplePos = position;  // No distortion - keep original position
  half4 sampledColor = layer.sample(samplePos);

  // === Apply caustic as overlay on top ===
  half3 result;

  if (sampledColor.a < 0.1h) {
    // Transparent - show caustic background
    result = causticColor;
  } else {
    // Opaque - blend caustic on top using screen blend
    half3 base = sampledColor.rgb;

    // Scale caustic intensity properly for visibility
    // Use causticLines directly (already 0-1+ range from pow(0.45))
    float overlayStrength = causticLines * caustic;

    // Create bright white/colored caustic overlay
    half3 causticOverlayColor = half3(overlayStrength * 1.5);

    // Screen blend: brighter result, caustics add light on top
    result = 1.0h - (1.0h - base) * (1.0h - causticOverlayColor);

    // Add highlights on peak caustic areas
    float peakMask = smoothstep(0.6, 1.0, causticLines);
    result += highlightColor * half(peakMask * caustic * 0.5);

    // Clamp to prevent blowout
    result = min(result, half3(1.0));
  }

  return half4(result, max(sampledColor.a, half(causticLines > 0.1 ? 1.0 : 0.0)));
}
