//
//  CardOneShaders.metal
//  SwiftUIAnimationDemos
//
//  Diamond holographic pattern shader for CardOne
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 diamondGrid(
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

    // Diamond grid pattern
    float diamondWidth = 24.0;
    float diamondHeight = 40.0;

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

    float diamondEdge = smoothstep(0.5, 0.35, diamondDist);
    float diamondRim = smoothstep(0.5, 0.45, diamondDist) - smoothstep(0.45, 0.35, diamondDist);

    // Rainbow color per diamond
    float2 tiltOffset = tilt * 3.0;
    float hueBase = (diamondCell.x + diamondCell.y) * 0.08;
    float hueTilt = (tiltOffset.x + tiltOffset.y) * 0.15;
    float hue = fract(hueBase + hueTilt);

    half3 diamondColor = hsv2rgb(half3(hue, 0.85h, 1.0h));

    // Light hotspot
    float2 lightPos = float2(0.5 + tilt.y * 0.8, 0.5 + tilt.x * 0.8);
    float lightDist = length(uv - lightPos);
    float hotspot = smoothstep(0.6, 0.0, lightDist);
    hotspot = pow(hotspot, 1.5);

    float2 lightPos2 = float2(0.5 - tilt.y * 0.5, 0.5 - tilt.x * 0.5);
    float hotspot2 = smoothstep(0.4, 0.0, length(uv - lightPos2)) * 0.5;

    // Sparkles
    float sparkleRand = hash21(diamondCell);
    float sparklePhase = sparkleRand * 6.28 + (tilt.x + tilt.y) * 8.0 + time * 2.0;
    float sparkle = pow(max(0.0, sin(sparklePhase)), 8.0);
    sparkle *= step(0.7, sparkleRand);
    sparkle *= diamondEdge;

    // Combine effects
    half holoStrength = half(intensity * diamondEdge * (0.5 + hotspot * 0.5));
    half3 result = mix(originalColor.rgb, diamondColor, holoStrength);

    float diamondBrightness = hotspot * 0.4 + hotspot2 * 0.2;
    result += half(diamondBrightness * diamondEdge) * diamondColor;
    result += half(diamondRim * 0.3 * (hotspot + 0.2)) * half3(1.0h, 1.0h, 1.0h);
    result += half(sparkle * 1.2) * half3(1.0h, 1.0h, 1.0h);
    result *= half(1.0 + hotspot * 0.2);

    return half4(result, originalColor.a);
}
