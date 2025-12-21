//
//  RadiantHoloShader.metal
//  SwiftUIAnimationDemos
//
//  Criss-cross diamond pattern with intense brightness
//  Based on CSS radiant-holo.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 crisscrossHolo(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Background offset
    float2 bgOffset = tilt * 0.4;

    // Two perpendicular repeating gradients (45deg and -45deg)
    // Ultra-fine bars (1.2% width equivalent)
    float barWidth = 0.012;

    // Gradient 1 (45 degrees)
    float angle1 = 45.0 * 3.14159 / 180.0;
    float2 dir1 = float2(cos(angle1), sin(angle1));
    float grad1T = dot(uv + bgOffset, dir1);
    float grad1Phase = fract(grad1T / barWidth);

    // Create bar pattern with multiple brightness levels
    float bar1 = 0.0;
    for (int i = 0; i < 5; i++) {
        float offset = float(i) * 0.2;
        float localPhase = fract(grad1Phase + offset);
        bar1 += smoothstep(0.0, 0.1, localPhase) * smoothstep(0.2, 0.1, localPhase) * (0.5 + float(i) * 0.1);
    }
    bar1 /= 2.5;

    // Gradient 2 (-45 degrees)
    float angle2 = -45.0 * 3.14159 / 180.0;
    float2 dir2 = float2(cos(angle2), sin(angle2));
    float grad2T = dot(uv - bgOffset * 0.8, dir2);
    float grad2Phase = fract(grad2T / barWidth);

    float bar2 = 0.0;
    for (int i = 0; i < 5; i++) {
        float offset = float(i) * 0.2;
        float localPhase = fract(grad2Phase + offset);
        bar2 += smoothstep(0.0, 0.1, localPhase) * smoothstep(0.2, 0.1, localPhase) * (0.5 + float(i) * 0.1);
    }
    bar2 /= 2.5;

    // Diamond pattern from criss-cross
    float diamond = bar1 * bar2;

    // Rainbow repeating gradient (55 degrees)
    float rainbowAngle = 55.0 * 3.14159 / 180.0;
    float2 rainbowDir = float2(cos(rainbowAngle), sin(rainbowAngle));
    float rainbowT = dot(uv + bgOffset * 0.5, rainbowDir) + time * 0.1;
    half3 rainbowColor = rainbowGradient(rainbowT * 2.0);

    // Glitter layer (15% 15% size)
    float2 glitterUV = uv * 40.0 + tilt * 8.0;
    float2 glitterCell = floor(glitterUV);
    float glitterHash = hash21(glitterCell);
    float sparkle = step(0.9, glitterHash);
    float sparklePhase = glitterHash * 6.28 + time * 5.0 + (tilt.x + tilt.y) * 4.0;
    float glitter = sparkle * pow(max(0.0, sin(sparklePhase)), 8.0);

    // Combine layers
    half3 holoLayer = rainbowColor;

    // Exclusion blend with diamond pattern
    half3 diamondColor = half3(half(diamond));
    holoLayer = blendExclusion(holoLayer, diamondColor * 0.5h);

    // Darken blend
    holoLayer = blendDarken(holoLayer, half3(1.0h - half(diamond * 0.3)));

    // Color dodge for intensity
    holoLayer = blendColorDodge(holoLayer, rainbowColor * half(diamond * 0.3));

    // Hard-light for criss-cross
    half3 crossColor = half3(half(bar1 * 0.5), half(bar2 * 0.5), half((bar1 + bar2) * 0.25));
    holoLayer = blendHardLight(holoLayer, crossColor);

    // Overlay for glitter
    half3 glitterColor = half3(half(glitter));
    holoLayer = blendOverlay(holoLayer, glitterColor);

    // Color dodge with glitter
    holoLayer = blendColorDodge(holoLayer, glitterColor * 0.5h);

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * 0.7));

    // Add sparkle highlights
    result += half(glitter * 1.5 * intensity) * half3(1.0h, 1.0h, 1.0h);

    // CSS filters: brightness(.5) contrast(2) saturate(1.75)
    result *= 0.7h; // brightness
    result = (result - 0.5h) * 1.6h + 0.5h; // contrast

    // Saturate
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 1.5h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
