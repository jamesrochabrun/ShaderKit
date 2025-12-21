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

[[stitchable]] half4 verticalBeams(
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

    // Tilt-based offset for parallax
    float2 bgOffset = tilt * 0.3;

    // Animated vertical beams with rainbow colors
    float beamCount = 12.0;
    float beamX = uv.x + bgOffset.x + time * 0.05;
    float beamPhase = fract(beamX * beamCount);

    // Soft beam shape
    float beam = smoothstep(0.0, 0.3, beamPhase) * smoothstep(1.0, 0.7, beamPhase);
    beam = pow(beam, 0.8);

    // Rainbow color based on beam position
    float hueShift = fract(floor(beamX * beamCount) / beamCount + tilt.x * 0.5);
    half3 beamColor = half3(
        0.5h + 0.5h * half(sin(hueShift * 6.28)),
        0.5h + 0.5h * half(sin((hueShift + 0.33) * 6.28)),
        0.5h + 0.5h * half(sin((hueShift + 0.66) * 6.28))
    );

    // Sweeping light that moves across the card
    float sweepPos = fract(time * 0.15 + tilt.x * 0.3);
    float sweep = smoothstep(0.0, 0.1, uv.x - sweepPos + 0.15) *
                  smoothstep(0.3, 0.0, uv.x - sweepPos);
    sweep *= 1.5;

    // Radial glow following tilt
    float2 lightPos = float2(0.5 + tilt.x * 0.5, 0.5 + tilt.y * 0.5);
    float lightDist = length(uv - lightPos);
    float radialGlow = smoothstep(0.7, 0.0, lightDist);
    radialGlow = pow(radialGlow, 2.0);

    // Secondary diagonal rainbow gradient
    float angle = 110.0 * 3.14159 / 180.0;
    float2 gradDir = float2(cos(angle), sin(angle));
    float gradT = fract(dot(uv + bgOffset, gradDir) * 2.0);
    half3 bgRainbow = half3(
        0.5h + 0.5h * half(sin(gradT * 6.28 + time * 0.5)),
        0.5h + 0.5h * half(sin((gradT + 0.33) * 6.28 + time * 0.5)),
        0.5h + 0.5h * half(sin((gradT + 0.66) * 6.28 + time * 0.5))
    );

    // Combine effects
    half3 holoLayer = bgRainbow * 0.4h;
    holoLayer += beamColor * half(beam * 0.7);
    holoLayer += half3(1.0h) * half(sweep * 0.6);
    holoLayer += half3(1.0h, 0.95h, 0.9h) * half(radialGlow * 0.5);

    // Color dodge blend with original
    half3 result = blendColorDodge(originalColor.rgb, holoLayer * half(intensity));

    // Boost saturation
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 1.3h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
