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

// Smooth circular star with glow
static float star_point(float2 uv, float2 center, float size, float time, float seed) {
    float dist = length(uv - center);
    // Soft circular falloff
    float star = smoothstep(size, 0.0, dist);
    // Add glow halo
    float glow = smoothstep(size * 3.0, 0.0, dist) * 0.3;
    // Twinkle
    float twinkle = 0.6 + 0.4 * sin(time * 2.5 + seed * 50.0);
    return (star + glow) * twinkle;
}

// Procedural galaxy pattern with smooth circular stars
static half3 cosmos_galaxy(float2 uv, float time, bool starsOnly) {
    half3 result = half3(0.0h);

    // Generate sparse circular stars using grid cells
    float starTotal = 0.0;

    // Layer 1: Larger, brighter stars
    for (int layer = 0; layer < 2; layer++) {
        float gridSize = (layer == 0) ? 0.08 : 0.05;
        float starSize = (layer == 0) ? 0.008 : 0.004;
        float offset = float(layer) * 100.0;

        float2 gridUV = uv / gridSize;
        float2 cellID = floor(gridUV);
        float2 cellUV = fract(gridUV);

        // Check this cell and neighbors for smooth stars
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                float2 neighbor = float2(x, y);
                float2 id = cellID + neighbor;

                // Random position within cell
                float seed = hash21(id + offset);
                if (seed > 0.85) { // Only 15% of cells have stars
                    float2 starPos = neighbor + float2(
                        hash21(id + offset + 1.0),
                        hash21(id + offset + 2.0)
                    );

                    float brightness = pow(hash21(id + offset + 3.0), 2.0);
                    starTotal += star_point(cellUV, starPos, starSize / gridSize, time, seed) * brightness;
                }
            }
        }
    }

    // Add stars with slight color variation
    half3 starColor = half3(1.0h, 0.98h, 0.95h);
    result += half(starTotal) * starColor;

    if (!starsOnly) {
        // Soft, subtle nebula clouds
        float nebula1 = fbm(uv * 2.0 + time * 0.015, 4);
        float nebula2 = fbm(uv * 1.5 - time * 0.01 + 100.0, 3);

        // Softer, more transparent colors
        half3 color1 = half3(0.08h, 0.0h, 0.18h);   // Soft purple
        half3 color2 = half3(0.0h, 0.06h, 0.22h);   // Soft blue
        half3 color3 = half3(0.15h, 0.0h, 0.1h);    // Soft magenta

        half3 nebula = mix(color1, color2, half(nebula1));
        nebula = mix(nebula, color3, half(nebula2 * 0.4));

        result += nebula;
    }

    return result;
}

[[stitchable]] half4 galaxyHolo(
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

    // Parallax offsets for layers (subtle movement)
    float2 offset1 = tilt * 0.08;
    float2 offset2 = tilt * 0.12;

    // Two-layer galaxy (simpler, less overwhelming)
    half3 galaxyBottom = cosmos_galaxy(uv + offset1, time, false);
    half3 galaxyTop = cosmos_galaxy(uv * 1.3 + offset2 + 50.0, time * 0.9, false);

    // Combine layers - lighter blend
    half3 galaxyBase = blendLighten(galaxyBottom, galaxyTop * 0.6h);

    // Rainbow gradient (82 degrees) with smooth color transitions
    float rainbowAngle = 82.0 * 3.14159 / 180.0;
    float2 rainbowDir = float2(cos(rainbowAngle), sin(rainbowAngle));
    float rainbowT = dot(uv + tilt * 0.25, rainbowDir);

    // Smooth rainbow colors
    half3 rainbowColor = half3(
        0.5h + 0.5h * half(sin(rainbowT * 6.28 * 2.5)),
        0.5h + 0.5h * half(sin((rainbowT + 0.33) * 6.28 * 2.5)),
        0.5h + 0.5h * half(sin((rainbowT + 0.66) * 6.28 * 2.5))
    );

    // Calculate original image luminance for smart blending
    half origLum = dot(originalColor.rgb, half3(0.299h, 0.587h, 0.114h));

    // Content-aware opacity: effect is more subtle on bright/detailed areas
    half contentMask = smoothstep(0.2h, 0.7h, origLum);

    // Build the holo layer with gentler blends
    half3 holoLayer = galaxyBase;

    // Soft overlay with rainbow (preserves midtones)
    holoLayer = blendOverlay(holoLayer, rainbowColor * 0.35h + 0.5h);

    // Light color dodge for shimmer
    float2 lightPos = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float lightDist = length(uv - lightPos);
    float highlight = smoothstep(0.7, 0.0, lightDist) * 0.25;
    holoLayer = blendColorDodge(holoLayer, half3(half(highlight)));

    // Add rainbow shimmer to the holo layer
    holoLayer += rainbowColor * 0.15h;

    // Smart blend: preserve more of original in detailed/bright areas
    half effectStrength = half(intensity) * (0.5h + 0.5h * (1.0h - contentMask));
    half3 result = mix(originalColor.rgb, holoLayer, effectStrength * 0.6h);

    // Add stars as additive overlay (so they sparkle on top without replacing content)
    half3 starLayer = cosmos_galaxy(uv + offset1 * 0.5, time, true); // stars only
    result += starLayer * half(intensity) * 0.5h;

    // Preserve original saturation better
    half resultLum = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(resultLum), result, 0.95h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
