//
//  CardTwoShaders.metal
//  SwiftUIAnimationDemos
//
//  Intense holographic shader for CardTwo (maximum bling)
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 intenseBling(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Dense vertical diamond grid
    float diamondWidth = 28.0;
    float diamondHeight = 48.0;

    float2 diamondUV = float2(
        uv.x * diamondWidth,
        uv.y * diamondHeight
    );

    float row = floor(diamondUV.y);
    if (fmod(row, 2.0) == 1.0) {
        diamondUV.x += 0.5;
    }

    float2 diamondCell = floor(diamondUV);
    float2 diamondLocal = fract(diamondUV) - 0.5;
    float diamondDist = abs(diamondLocal.x) * 2.0 + abs(diamondLocal.y);

    float diamondEdge = smoothstep(0.5, 0.25, diamondDist);
    float diamondRim = smoothstep(0.5, 0.4, diamondDist) - smoothstep(0.4, 0.3, diamondDist);

    // Multi-hue rainbow
    float2 tiltOffset = tilt * 4.0;
    float hue1 = fract((diamondCell.x + diamondCell.y) * 0.06 + tiltOffset.x * 0.12);
    float hue2 = fract((diamondCell.x - diamondCell.y) * 0.04 + tiltOffset.y * 0.1);
    float hue = fract((hue1 + hue2) * 0.5 + time * 0.01);

    half3 diamondColor = hsv2rgb(half3(hue, 0.9h, 1.0h));

    // Secondary color layer
    float hue3 = fract(hue + 0.33);
    half3 diamondColor2 = hsv2rgb(half3(hue3, 0.7h, 0.9h));

    // Multiple light sources
    float2 light1 = float2(0.5 + tilt.y * 0.9, 0.5 + tilt.x * 0.9);
    float2 light2 = float2(0.5 - tilt.y * 0.6, 0.5 - tilt.x * 0.6);
    float2 light3 = float2(0.5 + tilt.x * 0.5, 0.5 - tilt.y * 0.5);

    float hot1 = pow(smoothstep(0.5, 0.0, length(uv - light1)), 1.8);
    float hot2 = pow(smoothstep(0.4, 0.0, length(uv - light2)), 2.0) * 0.6;
    float hot3 = pow(smoothstep(0.35, 0.0, length(uv - light3)), 2.0) * 0.4;
    float totalHot = hot1 + hot2 + hot3;

    // Intense sparkles
    float sparkleRand = hash21(diamondCell);
    float sparklePhase = sparkleRand * 6.28 + (tilt.x + tilt.y) * 12.0 + time * 3.0;
    float sparkle = pow(max(0.0, sin(sparklePhase)), 6.0);
    sparkle *= step(0.5, sparkleRand);
    sparkle *= diamondEdge;

    // Extra bright sparkles
    float megaSparkle = pow(max(0.0, sin(sparklePhase * 0.5)), 12.0);
    megaSparkle *= step(0.85, sparkleRand);
    megaSparkle *= diamondEdge;

    // Combine all effects
    half holoStrength = half(diamondEdge * (0.7 + totalHot * 0.3));
    half3 result = mix(originalColor.rgb, diamondColor, holoStrength);

    result = mix(result, diamondColor2, half(totalHot * diamondEdge * 0.3));
    result += half(totalHot * diamondEdge * 0.5) * diamondColor;
    result += half(diamondRim * 0.5 * (totalHot + 0.3)) * half3(1.0h, 1.0h, 1.0h);
    result += half(sparkle * 1.5) * half3(1.0h, 1.0h, 1.0h);
    result += half(megaSparkle * 2.5) * half3(1.0h, 0.95h, 0.9h);
    result *= half(1.0 + totalHot * 0.25);

    return half4(result, originalColor.a);
}
