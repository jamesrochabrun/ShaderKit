//
//  CardSixShaders.metal
//  SwiftUIAnimationDemos
//
//  Reverse Holo effect:
//  - Foil layer on background/border (not on artwork)
//  - Mask layer separates image window from foil areas
//  - Glare sweeps across, clipped differently for image vs foil
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Main reverse holo effect
// imageWindow: x=minX, y=minY, z=maxX, w=maxY (in UV 0-1 space)
[[stitchable]] half4 cardSixReverseHolo(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float4 imageWindow,  // UV bounds of artwork area
    float foilIntensity
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // ========================================
    // MASK: Determine if we're in image window
    // ========================================

    float inImageX = step(imageWindow.x, uv.x) * step(uv.x, imageWindow.z);
    float inImageY = step(imageWindow.y, uv.y) * step(uv.y, imageWindow.w);
    float inImageWindow = inImageX * inImageY;
    float inFoilArea = 1.0 - inImageWindow;

    // ========================================
    // FOIL LAYER (for background/border only)
    // ========================================

    // Rainbow foil based on position and tilt
    float foilPhase = (uv.x * 4.0 + uv.y * 3.0) + (tilt.x * 2.5 + tilt.y * 2.0);

    // Multiple wave patterns for rich foil look
    float wave1 = sin(foilPhase * 3.0 + time * 0.5) * 0.5 + 0.5;
    float wave2 = sin(foilPhase * 5.0 - time * 0.3 + 1.0) * 0.5 + 0.5;
    float wave3 = sin((uv.x - uv.y) * 8.0 + tilt.x * 3.0) * 0.5 + 0.5;

    float foilPattern = (wave1 + wave2 * 0.7 + wave3 * 0.5) / 2.2;

    // Rainbow hue from foil
    float hue = fract(foilPattern * 0.8 + tilt.x * 0.15 + tilt.y * 0.1 + time * 0.02);
    half3 foilColor = hsv2rgb(half(hue), 0.75h, 1.0h);

    // Secondary shifted hue for depth
    float hue2 = fract(hue + 0.25);
    half3 foilColor2 = hsv2rgb(half(hue2), 0.6h, 0.9h);

    half3 finalFoil = mix(foilColor, foilColor2, half(wave2));

    // ========================================
    // GLARE LAYER (sweeping light)
    // ========================================

    // Glare position follows tilt
    float2 glareCenter = float2(
        0.5 + tilt.y * 0.7,
        0.5 + tilt.x * 0.7
    );

    float glareDist = length(uv - glareCenter);

    // Main glare - circular falloff
    float glare = smoothstep(0.5, 0.0, glareDist);
    glare = pow(glare, 2.0);

    // Secondary wider glow
    float glow = smoothstep(0.8, 0.2, glareDist) * 0.3;

    // ========================================
    // COMBINE WITH MASKING
    // ========================================

    half3 result = originalColor.rgb;

    // Apply foil ONLY to non-image areas
    half foilStrength = half(inFoilArea * foilIntensity * (0.4 + foilPattern * 0.3));
    result = mix(result, result * 0.7h + finalFoil * 0.5h, foilStrength);

    // Add foil shimmer/brightness to foil areas
    result += finalFoil * half(inFoilArea * foilPattern * 0.2 * foilIntensity);

    // Apply glare differently based on area:
    // - Foil area: strong white/rainbow glare
    // - Image area: subtle, softer glare (preserves artwork)

    // Foil area glare (strong, rainbow-tinted)
    half3 foilGlare = half3(1.0h, 0.98h, 0.95h) + finalFoil * 0.3h;
    result += foilGlare * half(glare * 0.6 * inFoilArea);
    result += foilGlare * half(glow * inFoilArea);

    // Image area glare (subtle white, preserves artwork)
    half3 imageGlare = half3(1.0h, 1.0h, 1.0h);
    result += imageGlare * half(glare * 0.25 * inImageWindow);
    result += imageGlare * half(glow * 0.15 * inImageWindow);

    return half4(result, originalColor.a);
}

// Sparkle overlay for foil areas
[[stitchable]] half4 cardSixSparkle(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float4 imageWindow
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Check if in foil area
    float inImageX = step(imageWindow.x, uv.x) * step(uv.x, imageWindow.z);
    float inImageY = step(imageWindow.y, uv.y) * step(uv.y, imageWindow.w);
    float inFoilArea = 1.0 - (inImageX * inImageY);

    // Sparkle grid
    float gridSize = 40.0;
    float2 gridUV = uv * gridSize;
    float2 cellID = floor(gridUV);
    float2 cellUV = fract(gridUV) - 0.5;

    float rand = hash21(cellID);

    // Sparkle phase tied to tilt
    float sparklePhase = rand * 6.28318 + (tilt.x + tilt.y) * 12.0 + time * 3.0;
    float sparkleActive = step(0.7, rand);
    float sparkleIntensity = pow(max(0.0, sin(sparklePhase)), 10.0);

    float dist = length(cellUV);
    float point = smoothstep(0.15, 0.0, dist);

    float sparkle = point * sparkleIntensity * sparkleActive * inFoilArea;

    // Sparkle color
    float hue = fract(rand + tilt.x * 0.3);
    half3 sparkleColor = half3(1.0h) + hsv2rgb(half(hue), 0.4h, 0.3h);

    half3 result = originalColor.rgb + sparkleColor * half(sparkle * 0.9);

    return half4(result, originalColor.a);
}

// Foil texture pattern (optional fine detail)
[[stitchable]] half4 cardSixFoilTexture(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float4 imageWindow
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Check if in foil area
    float inImageX = step(imageWindow.x, uv.x) * step(uv.x, imageWindow.z);
    float inImageY = step(imageWindow.y, uv.y) * step(uv.y, imageWindow.w);
    float inFoilArea = 1.0 - (inImageX * inImageY);

    // Fine diagonal lines texture
    float lines1 = sin((uv.x + uv.y) * 150.0 + tilt.x * 10.0) * 0.5 + 0.5;
    float lines2 = sin((uv.x - uv.y) * 120.0 + tilt.y * 8.0) * 0.5 + 0.5;

    float texture = (lines1 * lines2) * 0.08 * inFoilArea;

    half3 result = originalColor.rgb * half(1.0 + texture);

    return half4(result, originalColor.a);
}
