//
//  RainbowRareShader.metal
//  SwiftUIAnimationDemos
//
//  Glittery rainbow effect with luminosity blending
//  Based on CSS rainbow-holo.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 rainbowGlitter(
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

    // Distance from center for opacity control
    float2 center = float2(0.5, 0.5);
    float distFromCenter = length(uv - center) / 0.7071;

    // Glitter pattern - dual layers
    float2 glitterUV1 = uv * 60.0;
    float2 glitterUV2 = uv * 80.0;

    // Offset glitter based on tilt
    float2 offset1 = float2(0.4, 0.45) + tilt * 0.1;
    float2 offset2 = float2(0.55, 0.55) - tilt * 0.1;

    // Glitter layer 1
    float2 cell1 = floor(glitterUV1 + offset1 * 60.0);
    float cellHash1 = hash21(cell1);
    float sparkle1 = step(0.85, cellHash1);
    float phase1 = cellHash1 * 6.28 + time * 3.0 + (tilt.x + tilt.y) * 2.0;
    float glitter1 = sparkle1 * pow(max(0.0, sin(phase1)), 8.0);

    // Glitter layer 2
    float2 cell2 = floor(glitterUV2 + offset2 * 80.0);
    float cellHash2 = hash21(cell2 + 100.0);
    float sparkle2 = step(0.88, cellHash2);
    float phase2 = cellHash2 * 6.28 + time * 2.5 + (tilt.x - tilt.y) * 2.0;
    float glitter2 = sparkle2 * pow(max(0.0, sin(phase2)), 8.0);

    float totalGlitter = max(glitter1, glitter2);

    // 7-color rainbow gradient (-45 degrees)
    float angle1 = -45.0 * 3.14159 / 180.0;
    float2 dir1 = float2(cos(angle1), sin(angle1));
    float bgOffset = (tilt.x + tilt.y) * 0.2;
    float gradT1 = fract(dot(uv, dir1) * 2.0 + bgOffset);

    // Second gradient layer (-30 degrees)
    float angle2 = -30.0 * 3.14159 / 180.0;
    float2 dir2 = float2(cos(angle2), sin(angle2));
    float gradT2 = fract(dot(uv, dir2) * 2.5 + bgOffset * 0.8);

    // Rainbow colors (7 HSL colors)
    half3 rainbow1 = half3(
        0.5h + 0.5h * half(sin(gradT1 * 6.28)),
        0.5h + 0.5h * half(sin((gradT1 + 0.33) * 6.28)),
        0.5h + 0.5h * half(sin((gradT1 + 0.66) * 6.28))
    );

    half3 rainbow2 = half3(
        0.5h + 0.5h * half(sin(gradT2 * 6.28 + 1.0)),
        0.5h + 0.5h * half(sin((gradT2 + 0.33) * 6.28 + 1.0)),
        0.5h + 0.5h * half(sin((gradT2 + 0.66) * 6.28 + 1.0))
    );

    // Combine gradient layers
    half3 holoLayer = mix(rainbow1, rainbow2, 0.5h);

    // Apply glitter with soft-light
    half3 glitterColor = half3(half(totalGlitter));
    holoLayer = blendSoftLight(holoLayer, glitterColor);

    // Brightness varies with distance from center
    float brightness = 0.6 + distFromCenter * 0.25;
    holoLayer *= half(brightness);

    // Opacity varies with distance from center
    float opacity = (distFromCenter + 0.4) * 0.6 * intensity;

    // Luminosity blend with original
    half3 result = blendLuminosity(originalColor.rgb, holoLayer);
    result = mix(originalColor.rgb, result, half(opacity));

    // Add color dodge for highlights
    result = blendColorDodge(result, holoLayer * half(0.3 * intensity));

    // Add sparkle highlights
    result += half(totalGlitter * 0.8 * intensity) * half3(1.0h, 1.0h, 1.0h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
