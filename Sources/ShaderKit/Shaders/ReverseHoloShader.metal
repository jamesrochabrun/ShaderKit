//
//  ReverseHoloShader.metal
//  SwiftUIAnimationDemos
//
//  Inverted foil effect with shine overlay
//  Based on CSS reverse-holo.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 invertedFoil(
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

    // Inverted mask area (effect is on background, not artwork)
    // In CSS this uses clip-path: var(--clip-invert)
    // We'll simulate by having the effect stronger at edges
    float2 center = float2(0.5, 0.5);
    float edgeDist = max(abs(uv.x - center.x), abs(uv.y - center.y)) * 2.0;
    float invertMask = smoothstep(0.3, 0.8, edgeDist);

    // Foil texture (procedural)
    float foilScale = 12.0;
    float foil1 = valueNoise(uv * foilScale + tilt * 2.0);
    float foil2 = valueNoise(uv * foilScale * 2.0 - tilt * 1.5 + 100.0);
    float foilTex = mix(foil1, foil2, 0.5);

    // Radial gradient at cursor for shine
    float2 shineCenter = float2(0.5 + tilt.x * 0.4, 0.5 + tilt.y * 0.4);
    float shineDist = length(uv - shineCenter);
    float shine = smoothstep(0.7, 0.0, shineDist);
    shine = pow(shine, 1.5);

    // Linear gradient with difference blend
    float gradAngle = 45.0 * 3.14159 / 180.0;
    float2 gradDir = float2(cos(gradAngle), sin(gradAngle));
    float gradT = dot(uv + tilt * 0.2, gradDir);

    half3 gradColor = half3(
        0.5h + 0.3h * half(sin(gradT * 6.28 * 2.0)),
        0.5h + 0.3h * half(sin((gradT + 0.33) * 6.28 * 2.0)),
        0.5h + 0.3h * half(sin((gradT + 0.66) * 6.28 * 2.0))
    );

    // Foil brightness varies by energy type (we'll use a neutral value)
    float foilBrightness = 0.7;

    // Combine effects
    half3 foilColor = half3(half(foilTex * foilBrightness));

    // Soft-light foil texture
    half3 holoLayer = blendSoftLight(gradColor, foilColor);

    // Color dodge with shine
    half3 shineColor = half3(half(shine));
    holoLayer = blendColorDodge(holoLayer, shineColor * 0.5h);

    // Difference blend for rainbow effect
    holoLayer = blendDifference(holoLayer, gradColor * 0.3h);

    // Apply inverted mask (stronger at edges)
    float effectStrength = mix(0.3, 1.0, invertMask);

    // Opacity calculation from CSS
    float opacity = (1.5 * intensity) - (shineDist / 0.7071);
    opacity = clamp(opacity, 0.0, 1.0) * effectStrength;

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(opacity));

    // Add shine highlight
    result += half(shine * 0.3 * intensity * effectStrength) * half3(1.0h, 1.0h, 1.0h);

    // Slight saturation boost
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 1.2h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
