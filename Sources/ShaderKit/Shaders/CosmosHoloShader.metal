//
//  CosmosHoloShader.metal
//  SwiftUIAnimationDemos
//
//  Galaxy background with rainbow gradient overlay
//  Based on CSS cosmos-holo.css
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Procedural galaxy pattern using shared utilities
static half3 cosmos_galaxy(float2 uv, float time) {
    // Stars
    float stars = pow(hash21(floor(uv * 200.0)), 20.0);
    float stars2 = pow(hash21(floor(uv * 300.0 + 50.0)), 25.0);

    // Nebula clouds
    float nebula1 = fbm(uv * 3.0 + time * 0.02, 5);
    float nebula2 = fbm(uv * 2.0 - time * 0.015 + 100.0, 4);
    float nebula3 = fbm(uv * 4.0 + time * 0.01 + 200.0, 3);

    // Color the nebula
    half3 color1 = half3(0.1h, 0.0h, 0.25h);  // Deep purple
    half3 color2 = half3(0.0h, 0.1h, 0.35h);  // Deep blue
    half3 color3 = half3(0.25h, 0.0h, 0.15h); // Magenta
    half3 color4 = half3(0.0h, 0.15h, 0.2h);  // Teal

    half3 nebula = mix(color1, color2, half(nebula1));
    nebula = mix(nebula, color3, half(nebula2 * 0.5));
    nebula = mix(nebula, color4, half(nebula3 * 0.3));

    // Add stars
    half starBright = half(stars + stars2 * 0.5);
    nebula += starBright * half3(1.0h, 1.0h, 0.95h);

    // Add subtle glow around bright areas
    float glow = fbm(uv * 5.0, 3) * 0.3;
    nebula += half(glow) * color2;

    return nebula;
}

[[stitchable]] half4 cosmosHoloEffect(
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

    // Parallax offsets for layers (10%, 15%, 20% movement rates)
    float2 offset1 = tilt * 0.10;
    float2 offset2 = tilt * 0.15;
    float2 offset3 = tilt * 0.20;

    // Three-layer galaxy (simulating PNG stack)
    half3 galaxyBottom = cosmos_galaxy(uv + offset1, time);
    half3 galaxyMiddle = cosmos_galaxy(uv * 1.2 + offset2 + 50.0, time * 0.8);
    half3 galaxyTop = cosmos_galaxy(uv * 0.8 + offset3 + 100.0, time * 1.2);

    // Combine layers with depth
    half3 galaxyBase = galaxyBottom;
    galaxyBase = blendMultiply(galaxyBase, galaxyMiddle + 0.5h);
    galaxyBase = blendLighten(galaxyBase, galaxyTop * 0.7h);

    // Rainbow gradient (82 degrees) with 12 color stops
    float rainbowAngle = 82.0 * 3.14159 / 180.0;
    float2 rainbowDir = float2(cos(rainbowAngle), sin(rainbowAngle));
    float rainbowT = dot(uv + tilt * 0.25, rainbowDir);

    // 12-stop rainbow (continuous)
    half3 rainbowColor = half3(
        0.5h + 0.5h * half(sin(rainbowT * 6.28 * 3.0)),
        0.5h + 0.5h * half(sin((rainbowT + 0.33) * 6.28 * 3.0)),
        0.5h + 0.5h * half(sin((rainbowT + 0.66) * 6.28 * 3.0))
    );

    // Apply blend modes (color-burn, multiply, lighten, overlay)
    half3 holoLayer = galaxyBase;

    // Color burn with rainbow
    holoLayer = blendColorBurn(holoLayer, rainbowColor * 0.3h + 0.7h);

    // Multiply for depth
    holoLayer = blendMultiply(holoLayer, half3(0.8h) + rainbowColor * 0.2h);

    // Overlay for vibrancy
    holoLayer = blendOverlay(holoLayer, rainbowColor * 0.4h);

    // Color dodge for highlights
    float2 lightPos = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float lightDist = length(uv - lightPos);
    float highlight = smoothstep(0.6, 0.0, lightDist) * 0.3;
    holoLayer = blendColorDodge(holoLayer, half3(half(highlight)));

    // Mix with original
    half3 result = mix(originalColor.rgb, holoLayer, half(intensity * 0.8));

    // CSS filters: brightness(1) contrast(1) saturate(.8)
    half lum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(lum), result, 0.9h); // slightly desaturated

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
