//
//  BasicGlareShader.metal
//  SwiftUIAnimationDemos
//
//  Simple radial glare effect following tilt position
//  Based on CSS basic.css - the simplest holographic effect
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]] half4 simpleGlare(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    // Skip transparent pixels
    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Calculate glare position based on tilt
    // Tilt is -1 to 1, we map to 0-1 UV space
    float2 glareCenter = float2(
        0.5 + tilt.x * 0.4,
        0.5 + tilt.y * 0.4
    );

    // Radial gradient from glare center
    float dist = length(uv - glareCenter);
    float glare = smoothstep(0.8, 0.0, dist);
    glare = pow(glare, 2.0); // Make it more concentrated

    // Secondary, softer glare on opposite side
    float2 glareCenter2 = float2(
        0.5 - tilt.x * 0.3,
        0.5 - tilt.y * 0.3
    );
    float glare2 = smoothstep(0.6, 0.0, length(uv - glareCenter2)) * 0.3;

    // Combine glares
    float totalGlare = glare + glare2;

    // Apply brightness and contrast (CSS filter equivalent)
    // brightness(0.6) contrast(4)
    half3 adjusted = originalColor.rgb;

    // Luminosity blend mode - use glare to brighten
    half lum = dot(adjusted, half3(0.299h, 0.587h, 0.114h));
    half3 glareColor = half3(1.0h, 1.0h, 1.0h);

    // Mix based on glare intensity
    half3 result = mix(adjusted, adjusted + glareColor * half(totalGlare * 0.8), half(intensity));

    // Add slight rainbow tint based on position
    float hueShift = (tilt.x + tilt.y) * 0.1 + time * 0.05;
    half3 tint = half3(
        0.5h + 0.5h * half(sin(hueShift * 6.28)),
        0.5h + 0.5h * half(sin((hueShift + 0.33) * 6.28)),
        0.5h + 0.5h * half(sin((hueShift + 0.66) * 6.28))
    );

    // Subtle tint in the glare area
    result = mix(result, result * tint + tint * half(totalGlare * 0.2), half(totalGlare * 0.3 * intensity));

    // Apply contrast boost in glare area
    result = mix(result, (result - 0.5h) * 1.5h + 0.5h, half(totalGlare * 0.5 * intensity));

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
