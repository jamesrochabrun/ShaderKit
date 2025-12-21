//
//  SecretGoldShader.metal
//  SwiftUIAnimationDemos
//
//  Shimmering gold glitter overlay effect
//  Based on CSS secret-rare.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 goldShimmer(
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

    // Distance from center
    float distFromCenter = length(uv - float2(0.5, 0.5)) / 0.7071;

    // Dual glitter layers (45%/45% and 55%/55% offset)
    float2 offset1 = float2(0.45, 0.45) + tilt * 0.15;
    float2 offset2 = float2(0.55, 0.55) - tilt * 0.15;

    // Glitter layer 1
    float2 glitterUV1 = (uv + offset1) * 70.0;
    float2 cell1 = floor(glitterUV1);
    float hash1 = hash21(cell1);
    float sparkle1 = step(0.88, hash1);
    float phase1 = hash1 * 6.28 + time * 4.0 + (tilt.x + tilt.y) * 3.0;
    float glitter1 = sparkle1 * pow(max(0.0, sin(phase1)), 6.0);

    // Glitter layer 2
    float2 glitterUV2 = (uv + offset2) * 90.0;
    float2 cell2 = floor(glitterUV2);
    float hash2 = hash21(cell2 + 200.0);
    float sparkle2 = step(0.9, hash2);
    float phase2 = hash2 * 6.28 + time * 3.5 + (tilt.x - tilt.y) * 2.5;
    float glitter2 = sparkle2 * pow(max(0.0, sin(phase2)), 6.0);

    // Conic gradient (radial color sweep)
    float2 centeredUV = uv - float2(0.5, 0.5);
    float angle = atan2(centeredUV.y, centeredUV.x);
    float conicT = (angle / 6.28318) + 0.5 + tilt.x * 0.1;

    // Gold linear gradient (45 degrees)
    float goldAngle = 45.0 * 3.14159 / 180.0;
    float2 goldDir = float2(cos(goldAngle), sin(goldAngle));
    float goldT = dot(uv + tilt * 0.2, goldDir) + 0.5;

    half3 goldColor = goldGradient(goldT);

    // Foil base with lighten blend
    float foilNoise = hash21(floor(uv * 30.0 + tilt * 5.0));
    half3 foilBase = goldColor * half(0.8 + foilNoise * 0.2);

    // Combine glitter layers
    float totalGlitter = max(glitter1, glitter2);

    // Apply blend modes
    half3 holoLayer = foilBase;

    // Soft-light with glitter
    half3 glitterColor = goldColor * half(totalGlitter);
    holoLayer = blendSoftLight(holoLayer, glitterColor);

    // Hard-light for shimmer
    holoLayer = blendHardLight(holoLayer, half3(half(glitter1 * 0.5)));

    // Overlay blend
    half3 conicColor = goldGradient(conicT);
    holoLayer = blendOverlay(holoLayer, conicColor * 0.3h);

    // Color dodge for highlights
    holoLayer = blendColorDodge(holoLayer, half3(half(totalGlitter * 0.4)));

    // Multiply for depth
    holoLayer = blendMultiply(holoLayer, half3(0.9h + half(distFromCenter * 0.2)));

    // Lighten blend with foil
    holoLayer = blendLighten(holoLayer, foilBase * 0.5h);

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity));

    // Add sparkle highlights
    result += half(totalGlitter * 1.0 * intensity) * half3(1.0h, 0.95h, 0.8h);

    // CSS filter: brightness varies, contrast(1), saturate(2.7)
    float brightness = 0.4 + distFromCenter * 0.2;
    result *= half(0.9 + brightness * 0.3);

    // High saturation
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 2.0h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
