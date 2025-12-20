//
//  AmazingRareShader.metal
//  SwiftUIAnimationDemos
//
//  Glittery metallic shimmer effect
//  Based on CSS amazing-rare.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 amazingRareEffect(
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

    // Dual glitter layers (40%/45% and 55%/55%)
    float2 offset1 = float2(0.4, 0.45) + tilt * 0.12;
    float2 offset2 = float2(0.55, 0.55) - tilt * 0.12;

    // Glitter layer 1
    float2 glitterUV1 = (uv + offset1) * 65.0;
    float2 cell1 = floor(glitterUV1);
    float hash1 = hash21(cell1);
    float sparkle1 = step(0.86, hash1);
    float phase1 = hash1 * 6.28 + time * 4.5 + (tilt.x + tilt.y) * 3.5;
    float glitter1 = sparkle1 * pow(max(0.0, sin(phase1)), 7.0);

    // Glitter layer 2
    float2 glitterUV2 = (uv + offset2) * 85.0;
    float2 cell2 = floor(glitterUV2);
    float hash2 = hash21(cell2 + 150.0);
    float sparkle2 = step(0.88, hash2);
    float phase2 = hash2 * 6.28 + time * 3.8 + (tilt.x - tilt.y) * 3.0;
    float glitter2 = sparkle2 * pow(max(0.0, sin(phase2)), 7.0);

    float totalGlitter = max(glitter1, glitter2);

    // Radial gradient at tilt position
    float2 radialCenter = float2(0.5 + tilt.x * 0.35, 0.5 + tilt.y * 0.35);
    float radialDist = length(uv - radialCenter);
    float radialGlow = smoothstep(0.7, 0.0, radialDist);

    // Dynamic angle sun pillar gradient
    float dynamicAngle = (tilt.x * 0.5 + tilt.y * 0.3) * 3.14159;
    float2 sunDir = float2(cos(dynamicAngle), sin(dynamicAngle));
    float sunT = dot(uv, sunDir) + 0.5;
    half3 sunPillarColor = sunPillarGradient(sunT * 3.0 + time * 0.1);

    // Foil base with color burn
    half3 foilBase = sunPillarColor * half(0.7 + radialGlow * 0.3);

    // Combine effects
    half3 holoLayer = foilBase;

    // Soft-light with glitter
    half3 glitterColor = half3(half(totalGlitter));
    holoLayer = blendSoftLight(holoLayer, glitterColor * 0.8h);

    // Color burn for depth
    holoLayer = blendColorBurn(holoLayer, sunPillarColor * 0.2h + 0.8h);

    // Overlay for shimmer
    half3 shimmerColor = half3(
        0.5h + 0.5h * half(sin(time * 2.0 + uv.x * 10.0)),
        0.5h + 0.5h * half(sin(time * 2.0 + uv.y * 10.0 + 1.0)),
        0.5h + 0.5h * half(sin(time * 2.0 + (uv.x + uv.y) * 5.0 + 2.0))
    );
    holoLayer = blendOverlay(holoLayer, shimmerColor * 0.2h);

    // Lighten blend
    holoLayer = blendLighten(holoLayer, half3(half(radialGlow * 0.4)));

    // Saturation blend (simulate CSS saturation blend)
    half lum = dot(holoLayer, half3(0.299h, 0.587h, 0.114h));
    half3 saturatedLayer = mix(half3(lum), holoLayer, 1.5h);
    holoLayer = mix(holoLayer, saturatedLayer, 0.3h);

    // Different glare for "masked" vs "unmasked" areas
    // Simulate with edge detection
    float edgeDist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float edgeMask = smoothstep(0.0, 0.15, edgeDist);

    // Overlay glare (changes based on mask)
    half3 glareColor = half3(half(radialGlow));
    if (edgeMask > 0.5) {
        holoLayer = blendOverlay(holoLayer, glareColor * 0.4h);
    } else {
        holoLayer = blendMultiply(holoLayer, half3(1.0h) - glareColor * 0.2h);
    }

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * 0.75));

    // Add sparkle highlights
    result += half(totalGlitter * 1.2 * intensity) * half3(1.0h, 0.98h, 0.95h);

    // Brightness and contrast
    result *= 0.95h;
    result = (result - 0.5h) * 1.2h + 0.5h;

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
