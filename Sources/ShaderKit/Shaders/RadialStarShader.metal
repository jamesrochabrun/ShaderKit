//
//  RadialStarShader.metal
//  SwiftUIAnimationDemos
//
//  Radial mask fade creating starry effect
//  Based on CSS v-star.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 radialStar(
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

    // Radial mask that fades based on tilt (the key VStar feature)
    float2 maskCenter = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float maskDist = length(uv - maskCenter);
    float radialMask = smoothstep(0.8, 0.0, maskDist);

    // Background offset
    float2 bgOffset = tilt * 0.25;

    // Vertical sun pillar gradient
    float vertT = fract((uv.y + bgOffset.y) * 3.0);
    half3 sunPillarColor = sunPillarGradient(vertT + tilt.y * 0.3);

    // Diagonal gradient (similar to V)
    float diagAngle = 133.0 * 3.14159 / 180.0;
    float2 diagDir = float2(cos(diagAngle), sin(diagAngle));
    float diagT = fract(dot(uv + bgOffset, diagDir) * 5.0);

    half3 diagColor = half3(
        0.6h + 0.4h * half(sin(diagT * 6.28)),
        0.6h + 0.4h * half(sin((diagT + 0.33) * 6.28)),
        0.6h + 0.4h * half(sin((diagT + 0.66) * 6.28))
    );

    // Ancient texture pattern (procedural)
    float textureScale = 50.0;
    float2 texCoord = uv * textureScale + tilt * 5.0;
    float2 cell = floor(texCoord);
    float cellHash = hash21(cell);
    float texture = smoothstep(0.3, 0.7, cellHash);

    // Star sparkle effect
    float starPhase = cellHash * 6.28 + time * 2.0 + (tilt.x + tilt.y) * 3.0;
    float star = step(0.92, cellHash) * pow(max(0.0, sin(starPhase)), 6.0);

    // Combine layers
    half3 holoLayer = sunPillarColor;

    // Soft-light with diagonal
    holoLayer = blendSoftLight(holoLayer, diagColor * 0.4h);

    // Hard-light for texture
    half3 textureColor = half3(half(texture * 0.5));
    holoLayer = blendHardLight(holoLayer, textureColor);

    // Exclusion for edge effects
    holoLayer = blendExclusion(holoLayer, half3(half(radialMask * 0.2)));

    // Apply radial mask for starry fade effect
    float maskFade = pow(radialMask, 1.5);
    holoLayer *= half(0.5 + maskFade * 0.5);

    // Mix with original using mask
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * maskFade));

    // Add star sparkles
    result += half(star * 1.2 * intensity) * half3(1.0h, 1.0h, 1.0h);

    // Brighter at center (inverse of typical)
    result *= half(0.7 + maskFade * 0.5);

    // Apply filters
    result = (result - 0.5h) * 1.3h + 0.5h; // contrast

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
