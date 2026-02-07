//
//  HalftonePastelShader.metal
//  ShaderKit
//
//  Halftone dot pattern with pastel holographic iridescent colors
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

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

    // --- Halftone dot grid ---
    float density = dotDensity;
    float2 gridUV = uv * density;
    float2 cell = floor(gridUV);
    float2 local = fract(gridUV) - 0.5;

    // Wave patterns that modulate dot size in multiple diagonal directions
    // Creates the chevron/diamond wave look from the reference
    float wave1 = sin((cell.x + cell.y) * 0.4 + tilt.x * 4.0 + time * waveSpeed * 0.5) * 0.5 + 0.5;
    float wave2 = sin((cell.x - cell.y) * 0.35 + tilt.y * 4.0 + time * waveSpeed * 0.3) * 0.5 + 0.5;
    float wave3 = sin(cell.x * 0.5 + tilt.x * 3.0 + time * waveSpeed * 0.2) * 0.5 + 0.5;
    float wave4 = sin(cell.y * 0.45 + tilt.y * 3.0 - time * waveSpeed * 0.25) * 0.5 + 0.5;

    // Combine waves for complex interference pattern
    float waveMix = wave1 * 0.35 + wave2 * 0.3 + wave3 * 0.2 + wave4 * 0.15;

    // Dot radius modulated by waves and hotspot proximity
    float baseRadius = 0.08 + waveMix * 0.35;
    float hotspotBoost = hotspot * 0.1;
    float dotRadius = baseRadius + hotspotBoost;

    // Circular dot shape
    float dist = length(local);
    float dot = smoothstep(dotRadius, dotRadius - 0.06, dist);

    // --- Pastel holographic color ---
    // Multiple hue sources for iridescent shifting
    float hueBase = (cell.x + cell.y) * 0.03;
    float hueTilt = (tilt.x * 0.2 + tilt.y * 0.15);
    float hueWave = sin((uv.x + uv.y) * 3.0 + time * 0.15) * 0.1;
    float hue = fract(hueBase + hueTilt + hueWave);

    // Pastel palette: low saturation, high value
    half3 pastelColor = hsv2rgb(half3(half(hue), 0.35h, 1.0h));

    // Add secondary color layer for depth (shifted hue)
    float hue2 = fract(hue + 0.33);
    half3 pastelColor2 = hsv2rgb(half3(half(hue2), 0.25h, 1.0h));

    // Blend the two color layers based on wave interference
    half3 iridescent = mix(pastelColor, pastelColor2, half(waveMix));

    // Light-following brightness
    half3 brightHighlight = half3(1.0h, 0.98h, 0.95h);
    iridescent = mix(iridescent, brightHighlight, half(hotspot * 0.3));

    // Background between dots - very soft pastel
    float bgHue = fract(hue + 0.5);
    half3 bgColor = hsv2rgb(half3(half(bgHue), 0.12h, 0.95h));

    // Compose: dot areas get iridescent color, background stays soft
    half3 holoLayer = mix(bgColor, iridescent, half(dot));

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
    result *= half(1.0 + hotspot * 0.15);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
