//
//  PokemonVShader.metal
//  SwiftUIAnimationDemos
//
//  Diagonal holographic effect with parallel lines creating 3D depth
//  Based on CSS v-regular.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Local grain texture with specific scaling
static float pokemonV_grain(float2 uv, float time) {
    return hash21(uv * 500.0 + time * 50.0);
}

[[stitchable]] half4 pokemonVEffect(
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

    // Background offset based on tilt
    float2 bgOffset = tilt * 0.3;

    // Grain texture layer (screen blend)
    float grain = pokemonV_grain(uv, time);
    half3 grainLayer = half3(half(grain * 0.15));

    // Repeating vertical gradient (0 degrees) - sun pillar colors
    float vertGradT = fract((uv.y + bgOffset.y) * 3.5);
    half3 sunPillarColor = sunPillarGradient(vertGradT + tilt.y * 0.5);

    // Diagonal repeating gradient (133 degrees)
    float diagAngle = 133.0 * 3.14159 / 180.0;
    float2 diagDir = float2(cos(diagAngle), sin(diagAngle));
    float diagT = dot(uv + bgOffset, diagDir);
    float diagPhase = fract(diagT * 6.0); // 300% size

    // 3-color stripe pattern for diagonal
    half3 stripeColors[3] = {
        half3(0.9h, 0.7h, 0.5h),
        half3(0.7h, 0.8h, 0.9h),
        half3(0.8h, 0.6h, 0.9h)
    };
    int stripeIdx = int(diagPhase * 3.0) % 3;
    half3 diagonalColor = stripeColors[stripeIdx];

    // Radial gradient for depth perception
    float2 lightPos = float2(0.5 + tilt.x * 0.4, 0.5 + tilt.y * 0.4);
    float lightDist = length(uv - lightPos);
    float radialFade = smoothstep(1.0, 0.0, lightDist);

    // Combine layers
    half3 holoLayer = sunPillarColor;

    // Hue blend with diagonal pattern
    half3 diagHSV = half3(fract(diagPhase * 0.5), 0.6h, 0.8h);
    half3 diagRGB = half3(
        0.5h + 0.5h * half(cos(diagHSV.x * 6.28)),
        0.5h + 0.5h * half(cos((diagHSV.x + 0.33) * 6.28)),
        0.5h + 0.5h * half(cos((diagHSV.x + 0.66) * 6.28))
    );
    holoLayer = mix(holoLayer, diagRGB, 0.4h);

    // Screen blend with grain
    holoLayer = blendScreen(holoLayer, grainLayer);

    // Hard-light blend for diagonal stripes
    holoLayer = blendHardLight(holoLayer, diagonalColor * 0.3h);

    // Soft-light blend for final effect
    half3 result = blendSoftLight(originalColor.rgb, holoLayer * half(intensity));

    // Apply radial brightness
    result *= half(0.8 + radialFade * 0.4);

    // CSS filters: brightness(.8) contrast(2.95) saturate(.65)
    result *= 0.9h; // brightness
    result = (result - 0.5h) * 1.8h + 0.5h; // contrast (scaled down from 2.95)

    // Saturate
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 0.8h); // slightly desaturated

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
