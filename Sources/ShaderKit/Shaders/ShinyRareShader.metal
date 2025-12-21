//
//  ShinyRareShader.metal
//  SwiftUIAnimationDemos
//
//  Metallic sun-pillar effect with crosshatch texture
//  Based on CSS shiny-rare.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 metallicCrosshatch(
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

    // Background offset
    float2 bgOffset = float2(
        tilt.x * 0.3,
        tilt.y * 0.35
    );

    // Distance from center for effects
    float distFromCenter = length(uv - float2(0.5, 0.5)) / 0.7071;

    // Foil texture base (procedural)
    float foilTex = valueNoise(uv * 15.0 + tilt * 3.0);
    foilTex = foilTex * 0.5 + 0.5;

    // Repeating vertical gradient (0 degrees) - sun pillar colors
    float vertT = fract((uv.y + bgOffset.y) * 3.5);
    half3 sunPillarColor = sunPillarGradient(vertT + tilt.y * 0.4);

    // Diagonal crosshatch pattern (133 degrees)
    float crossAngle = 133.0 * 3.14159 / 180.0;
    float2 crossDir = float2(cos(crossAngle), sin(crossAngle));
    float crossT = dot(uv + bgOffset, crossDir);
    float crossPhase = fract(crossT * 8.0);
    float crossPattern = smoothstep(0.0, 0.2, crossPhase) * smoothstep(1.0, 0.8, crossPhase);

    // Second crosshatch at perpendicular angle
    float cross2Angle = 43.0 * 3.14159 / 180.0;
    float2 cross2Dir = float2(cos(cross2Angle), sin(cross2Angle));
    float cross2T = dot(uv - bgOffset * 0.5, cross2Dir);
    float cross2Phase = fract(cross2T * 8.0);
    float cross2Pattern = smoothstep(0.0, 0.2, cross2Phase) * smoothstep(1.0, 0.8, cross2Phase);

    // Combined crosshatch
    float crosshatch = crossPattern * cross2Pattern;

    // Radial darkening at tilt position
    float2 darkCenter = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float darkDist = length(uv - darkCenter);
    float radialDark = smoothstep(0.0, 0.8, darkDist);

    // Combine layers
    half3 holoLayer = sunPillarColor;

    // Soft-light with foil texture
    half3 foilColor = half3(half(foilTex));
    holoLayer = blendSoftLight(holoLayer, foilColor);

    // Hue application
    float hueT = (tilt.x + tilt.y) * 0.2 + uv.x * 0.3;
    half3 hueColor = half3(
        0.5h + 0.3h * half(sin(hueT * 6.28)),
        0.5h + 0.3h * half(sin((hueT + 0.33) * 6.28)),
        0.5h + 0.3h * half(sin((hueT + 0.66) * 6.28))
    );
    holoLayer = mix(holoLayer, hueColor, 0.3h);

    // Hard-light with crosshatch
    half3 crossColor = half3(half(crosshatch));
    holoLayer = blendHardLight(holoLayer, crossColor * 0.5h + 0.25h);

    // Exclusion for metallic effect
    holoLayer = blendExclusion(holoLayer, half3(half(radialDark * 0.2)));

    // Overlay for depth
    holoLayer = blendOverlay(holoLayer, sunPillarColor * 0.3h);

    // Apply radial darkening
    holoLayer *= half(1.0 - radialDark * 0.3);

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * 0.7));

    // CSS filters: brightness varies with pointer, contrast(1.4), saturate(2.25)
    float brightness = 0.4 + distFromCenter * 0.4;
    result *= half(0.8 + brightness * 0.4);
    result = (result - 0.5h) * 1.3h + 0.5h; // contrast

    // High saturation
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 1.8h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
