//
//  SubtleGradientShader.metal
//  SwiftUIAnimationDemos
//
//  Large-scale subtle gradient with pronounced texture
//  Based on CSS v-max.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 subtleGradient(
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

    // Very slow background movement (1100% equivalent = slow)
    float2 bgOffset = tilt * 0.1; // Much slower than V

    // Distance from center for effects
    float distFromCenter = length(uv - float2(0.5, 0.5)) / 0.7071;

    // Wide repeating gradient (-33 degrees)
    float mainAngle = -33.0 * 3.14159 / 180.0;
    float2 mainDir = float2(cos(mainAngle), sin(mainAngle));
    float mainT = dot(uv + bgOffset, mainDir);
    float mainPhase = fract(mainT * 0.8); // Very large, slow gradient

    // VMax colors: red, blue, cyan, green, purple
    half3 vmaxColors[5] = {
        half3(0.9h, 0.4h, 0.4h),  // Red
        half3(0.4h, 0.4h, 0.9h),  // Blue
        half3(0.3h, 0.8h, 0.9h),  // Cyan
        half3(0.4h, 0.9h, 0.5h),  // Green
        half3(0.7h, 0.4h, 0.8h)   // Purple
    };

    float scaledPhase = mainPhase * 4.0;
    int idx = int(scaledPhase) % 5;
    int nextIdx = (idx + 1) % 5;
    float blend = fract(scaledPhase);
    half3 mainColor = mix(vmaxColors[idx], vmaxColors[nextIdx], half(blend));

    // Diagonal pattern (133 degrees) with custom hex colors
    float diagAngle = 133.0 * 3.14159 / 180.0;
    float2 diagDir = float2(cos(diagAngle), sin(diagAngle));
    float diagT = fract(dot(uv + bgOffset * 0.5, diagDir) * 3.0);

    half3 diagColor = half3(
        0.5h + 0.3h * half(sin(diagT * 6.28)),
        0.5h + 0.3h * half(sin((diagT + 0.33) * 6.28)),
        0.5h + 0.3h * half(sin((diagT + 0.66) * 6.28))
    );

    // Radial gradient at tilt position with pastel colors
    float2 lightPos = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float lightDist = length(uv - lightPos);
    float radialFade = smoothstep(0.8, 0.0, lightDist);

    half3 pastelGlow = half3(0.9h, 0.85h, 1.0h) * half(radialFade);

    // Procedural texture pattern
    float texture = valueNoise(uv * 20.0 + tilt * 2.0);
    half3 textureLayer = half3(half(texture * 0.3));

    // Combine with blend modes
    half3 holoLayer = mainColor;

    // Difference blend
    holoLayer = blendDifference(holoLayer, diagColor * 0.3h);

    // Luminosity blend
    holoLayer = blendLuminosity(holoLayer, textureLayer);

    // Soft-light blend
    holoLayer = blendSoftLight(holoLayer, pastelGlow);

    // Hard-light for diagonal
    holoLayer = blendHardLight(holoLayer, diagColor * 0.2h);

    // Lighten blend
    holoLayer = blendLighten(holoLayer, half3(half(radialFade * 0.3)));

    // Apply to original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * 0.6));

    // Brightness varies with distance from center
    float brightness = 0.4 + distFromCenter * 0.4;
    result *= half(0.8 + brightness * 0.4);

    // CSS filters: brightness, contrast(2), saturate(1)
    result = (result - 0.5h) * 1.5h + 0.5h; // contrast

    // Dynamic opacity for the effect
    float effectOpacity = 0.3 + distFromCenter * 0.5 * intensity;
    result = mix(originalColor.rgb, result, half(effectOpacity));

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
