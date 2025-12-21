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

    // Smooth circular sparkles
    float gridSize = 30.0;
    float2 glitterUV = uv * gridSize + tilt * 3.0;
    float2 cellId = floor(glitterUV);
    float2 cellUV = fract(glitterUV) - 0.5;

    // Accumulate sparkles from nearby cells for smooth effect
    half3 totalGlitterColor = half3(0.0h);
    float totalGlitter = 0.0;

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            float2 neighborCell = cellId + float2(dx, dy);
            float cellRand = hash21(neighborCell);

            // ~30% of cells have sparkles
            if (cellRand > 0.70) {
                // Random position within cell
                float2 sparklePos = float2(
                    hash21(neighborCell + 17.0) - 0.5,
                    hash21(neighborCell + 31.0) - 0.5
                ) * 0.6;

                // Distance to sparkle center (smooth circular falloff)
                float2 offset = cellUV - sparklePos - float2(dx, dy);
                float dist = length(offset);

                // Smooth circular sparkle with soft edges
                float sparkleSize = 0.12 + hash21(neighborCell + 30.0) * 0.08;
                float sparkle = smoothstep(sparkleSize, 0.0, dist);

                // Animate twinkle - stays visible with gentle pulsing
                float phase = cellRand * 6.28 + time * 1.5 + (tilt.x + tilt.y) * 2.0;
                float twinkle = 0.5 + 0.5 * pow(max(0.0, sin(phase)), 2.0);
                sparkle *= twinkle;

                // Rainbow color based on cell
                float hue = hash21(neighborCell + 50.0);
                half3 sparkleColor = half3(
                    0.5h + 0.5h * half(sin(hue * 6.28)),
                    0.5h + 0.5h * half(sin((hue + 0.33) * 6.28)),
                    0.5h + 0.5h * half(sin((hue + 0.66) * 6.28))
                );

                totalGlitterColor += sparkleColor * half(sparkle);
                totalGlitter = max(totalGlitter, sparkle);
            }
        }
    }

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

    // Apply rainbow glitter with soft-light
    holoLayer = blendSoftLight(holoLayer, totalGlitterColor);

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

    // Add rainbow sparkle highlights - masked by original image brightness
    half originalLuma = dot(originalColor.rgb, half3(0.299h, 0.587h, 0.114h));
    half sparkMask = 1.0h - originalLuma * 0.7h;
    result += totalGlitterColor * half(1.5 * intensity) * sparkMask;

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
