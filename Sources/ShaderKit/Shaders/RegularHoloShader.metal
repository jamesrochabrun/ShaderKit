//
//  RegularHoloShader.metal
//  SwiftUIAnimationDemos
//
//  Rainbow vertical beam holographic effect
//  Based on CSS regular-holo.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 regularHoloEffect(
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

    // Background position offset based on tilt (CSS: 2.6x/3.5x multiplier)
    float2 bgOffset = float2(
        tilt.x * 2.6 * 0.5,
        tilt.y * 3.5 * 0.5
    );

    // Main rainbow gradient layer (110 degrees)
    // Repeating gradient with 5 rainbow colors
    float angle = 110.0 * 3.14159 / 180.0;
    float2 gradDir = float2(cos(angle), sin(angle));
    float gradT = dot(uv + bgOffset, gradDir);
    float gradPhase = fract(gradT * 4.0); // 400% 400% size

    // 5 rainbow colors: red, yellow, green, blue, violet
    half3 rainbowColors[5] = {
        half3(1.0h, 0.2h, 0.2h),  // Red
        half3(1.0h, 1.0h, 0.2h),  // Yellow
        half3(0.2h, 1.0h, 0.2h),  // Green
        half3(0.2h, 0.4h, 1.0h),  // Blue
        half3(0.6h, 0.2h, 0.8h)   // Violet
    };

    float scaledPhase = gradPhase * 4.0;
    int idx = int(scaledPhase) % 5;
    int nextIdx = (idx + 1) % 5;
    float blend = fract(scaledPhase);
    half3 rainbowColor = mix(rainbowColors[idx], rainbowColors[nextIdx], half(blend));

    // Scanlines layer (horizontal lines)
    float scanline = fract(uv.y * 100.0 + bgOffset.y * 50.0);
    float scanlineIntensity = smoothstep(0.0, 0.1, scanline) * smoothstep(1.0, 0.9, scanline);
    scanlineIntensity = mix(0.8, 1.0, scanlineIntensity);

    // Bar pattern layer (secondary gradient)
    float barAngle = 90.0 * 3.14159 / 180.0;
    float2 barDir = float2(cos(barAngle), sin(barAngle));
    float barT = dot(uv + bgOffset * 0.8, barDir);
    float barPhase = fract(barT * 8.0);
    float barPattern = smoothstep(0.0, 0.3, barPhase) * smoothstep(1.0, 0.7, barPhase);

    // Radial glow at tilt position
    float2 lightPos = float2(0.5 + tilt.x * 0.4, 0.5 + tilt.y * 0.4);
    float lightDist = length(uv - lightPos);
    float radialGlow = smoothstep(0.8, 0.0, lightDist);
    radialGlow = pow(radialGlow, 1.5);

    // Combine layers
    half3 holoLayer = rainbowColor;

    // Apply scanlines with overlay blend
    holoLayer = blendOverlay(holoLayer, half3(half(scanlineIntensity)));

    // Apply bar pattern with screen + hard-light
    half3 barColor = half3(half(barPattern));
    holoLayer = blendScreen(holoLayer, barColor * 0.3h);
    holoLayer = blendHardLight(holoLayer, barColor * 0.2h);

    // Apply radial glow
    holoLayer += half3(half(radialGlow * 0.4));

    // Color dodge blend with original
    half3 result = blendColorDodge(originalColor.rgb, holoLayer * half(intensity * 0.5));

    // Apply CSS filters: brightness(1.1) contrast(1.1) saturate(1.2)
    result *= 1.1h; // brightness
    result = (result - 0.5h) * 1.1h + 0.5h; // contrast

    // Saturate
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 1.2h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
