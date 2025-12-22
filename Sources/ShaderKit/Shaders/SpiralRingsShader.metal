//
//  SpiralRingsShader.metal
//  ShaderKit
//
//  Golden spiral rings with holographic rainbow overlay
//  Inspired by Pokemon card holographic backgrounds
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 spiralRings(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float ringCount,
    float spiralTwist,
    float4 baseColor
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Center follows tilt slightly
    float2 center = float2(0.5 + tilt.x * 0.1, 0.5 + tilt.y * 0.1);
    float2 delta = uv - center;
    float dist = length(delta);
    float angle = atan2(delta.y, delta.x);

    // === GOLDEN SPIRAL RINGS ===
    // Archimedean spiral: distance offset by angle creates spiral
    float spiralDist = dist - angle * spiralTwist / 6.28318;

    // Create THICK gold bands with dark gaps
    float ringValue = spiralDist * ringCount;
    float rings = fract(ringValue);
    // Wide bright band (0.0-0.7), narrow dark gap (0.7-1.0)
    float bandPattern = smoothstep(0.0, 0.08, rings) * (1.0 - smoothstep(0.65, 0.73, rings));

    // Gold colors - more saturated metallic
    half3 darkGold = half3(0.55h, 0.4h, 0.1h);
    half3 midGold = half3(0.85h, 0.7h, 0.25h);
    half3 brightGold = half3(1.0h, 0.95h, 0.6h);

    // Gradient within each band
    float bandGradient = smoothstep(0.0, 0.5, rings);
    half3 goldColor = mix(midGold, brightGold, half(bandGradient * 0.6));
    goldColor = mix(darkGold, goldColor, half(bandPattern));

    // Bright center glow
    float centerGlow = 1.0 - smoothstep(0.0, 0.35, dist);
    centerGlow = pow(centerGlow, 2.0);
    goldColor = mix(goldColor, brightGold * 1.15h, half(centerGlow * 0.5));

    // === HOLOGRAPHIC RAINBOW RAYS ===
    // Rainbow rays emanating from center, shifting with tilt
    float rayAngle = angle + tilt.x * 2.0 + tilt.y * 1.5;
    float hue = fract(rayAngle / 6.28318 + dist * 0.3);
    half3 rainbow = hsv2rgb(half(hue), 0.9h, 1.0h);

    // Rays pattern - multiple frequencies for complexity
    float rays = sin(rayAngle * 6.0) * 0.5 + 0.5;
    rays *= sin(rayAngle * 10.0 + tilt.x * 3.0) * 0.5 + 0.5;
    rays = pow(rays, 1.5);

    // Rainbow fades toward edges, stronger in middle distance
    float rainbowDist = smoothstep(0.0, 0.2, dist) * (1.0 - smoothstep(0.5, 0.9, dist));
    float rainbowMask = rays * rainbowDist * 0.55;

    // Blend rainbow over gold (screen blend for brightness)
    half3 holoGold = goldColor + rainbow * half(rainbowMask);

    // === GLITTER PARTICLES ===
    float glitter = 0.0;

    // Dense small glitter
    float2 glitterUV = uv * 80.0;
    float2 glitterCell = floor(glitterUV);
    float glitterRand = hash21(glitterCell);

    if (glitterRand > 0.88) {
        float2 cellPos = fract(glitterUV) - 0.5;
        float2 randOffset = float2(hash21(glitterCell + 50.0), hash21(glitterCell + 100.0)) - 0.5;
        cellPos -= randOffset * 0.4;

        float dotDist = length(cellPos);
        float dot = smoothstep(0.15, 0.0, dotDist);

        // Twinkle with tilt
        float twinkle = sin(glitterRand * 30.0 + tilt.x * 8.0 + tilt.y * 6.0);
        twinkle = twinkle * 0.5 + 0.5;
        twinkle = pow(twinkle, 3.0);

        glitter = dot * twinkle;
    }

    // Larger star sparkles (fewer)
    float2 starUV = uv * 25.0;
    float2 starCell = floor(starUV);
    float starRand = hash21(starCell + 200.0);

    if (starRand > 0.94) {
        float2 cellPos = fract(starUV) - 0.5;
        float2 randOffset = float2(hash21(starCell + 150.0), hash21(starCell + 250.0)) - 0.5;
        cellPos -= randOffset * 0.3;

        float starDist = length(cellPos);
        float starAngle = atan2(cellPos.y, cellPos.x);

        // 4-point star
        float star = cos(starAngle * 4.0) * 0.5 + 0.5;
        star = pow(star, 6.0);
        float starShape = smoothstep(0.25, 0.0, starDist) * star;
        starShape += smoothstep(0.08, 0.0, starDist); // Bright center

        float starTwinkle = sin(starRand * 25.0 + tilt.x * 6.0 + tilt.y * 4.0);
        starTwinkle = pow(max(0.0, starTwinkle), 2.0);

        glitter += starShape * starTwinkle * 1.5;
    }

    // Final composition
    half3 result = mix(originalColor.rgb, holoGold, half(intensity));
    result += half(glitter * intensity) * half3(1.0h, 0.98h, 0.85h); // Warm white sparkles

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
