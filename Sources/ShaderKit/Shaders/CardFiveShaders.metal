//
//  CardFiveShaders.metal
//  SwiftUIAnimationDemos
//
//  Blended holographic effect:
//  - Effect blends WITH the image content (not just on top)
//  - Uses luminance-based blending - effect interacts with artwork
//  - Repeating gradients shift with tilt (background-position)
//  - Screen/overlay blend modes for natural integration
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Get luminance of a color
static half getLuminance(half3 color) {
    return dot(color, half3(0.299h, 0.587h, 0.114h));
}

// Simplified soft light blend (different from shared version)
static half3 cardFive_softLight(half3 base, half3 blend) {
    return (1.0h - 2.0h * blend) * base * base + 2.0h * blend * base;
}

// Main blended holographic effect
[[stitchable]] half4 blendedHolo(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,      // Overall effect strength
    float saturation      // Rainbow saturation
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Get luminance of original pixel - effect blends based on this
    half luma = getLuminance(originalColor.rgb);

    // ========================================
    // BACKGROUND POSITION (shifts with tilt)
    // ========================================
    float2 bgOffset = tilt * 0.4;

    // ========================================
    // REPEATING GRADIENT PATTERNS
    // ========================================

    // Pattern 1: Diagonal stripes (shift with tilt)
    float stripe1 = sin((uv.x + uv.y + bgOffset.x + bgOffset.y) * 25.0) * 0.5 + 0.5;

    // Pattern 2: Horizontal waves
    float stripe2 = sin((uv.y * 20.0 + bgOffset.y * 3.0) + time * 0.3) * 0.5 + 0.5;

    // Pattern 3: Vertical waves
    float stripe3 = sin((uv.x * 18.0 + bgOffset.x * 3.0) - time * 0.2) * 0.5 + 0.5;

    // Pattern 4: Circular ripples from tilt position
    float2 rippleCenter = float2(0.5, 0.5) + bgOffset * 0.6;
    float rippleDist = length(uv - rippleCenter);
    float ripple = sin(rippleDist * 30.0 - time * 0.5) * 0.5 + 0.5;

    // Combine patterns
    float pattern = (stripe1 * 0.3 + stripe2 * 0.25 + stripe3 * 0.25 + ripple * 0.2);

    // ========================================
    // RAINBOW COLOR (position + tilt based)
    // ========================================

    // Primary hue - shifts with position and tilt
    float hue1 = fract(
        (uv.x * 0.8 + uv.y * 0.6) +
        bgOffset.x * 0.5 +
        bgOffset.y * 0.4 +
        pattern * 0.15
    );

    // Secondary hue (offset)
    float hue2 = fract(hue1 + 0.33);

    // Tertiary hue
    float hue3 = fract(hue1 + 0.66);

    // Generate rainbow colors
    half3 rainbow1 = hsv2rgb(half(hue1), half(saturation), 1.0h);
    half3 rainbow2 = hsv2rgb(half(hue2), half(saturation * 0.9), 0.95h);
    half3 rainbow3 = hsv2rgb(half(hue3), half(saturation * 0.85), 0.9h);

    // Blend rainbows based on patterns
    half3 rainbowColor = mix(rainbow1, rainbow2, half(stripe1));
    rainbowColor = mix(rainbowColor, rainbow3, half(stripe2 * 0.4));

    // ========================================
    // GLARE (follows tilt)
    // ========================================

    float2 glarePos = float2(0.5 + tilt.y * 0.6, 0.5 + tilt.x * 0.6);
    float glareDist = length(uv - glarePos);
    float glare = smoothstep(0.5, 0.0, glareDist);
    glare = pow(glare, 1.8);

    // ========================================
    // BLEND WITH ORIGINAL (the magic!)
    // ========================================

    // The effect strength is modulated by luminance
    // Brighter areas show more rainbow effect
    half lumaFactor = smoothstep(0.1h, 0.8h, luma);

    // Also add pattern variation to the blend
    half blendAmount = half(intensity) * (0.4h + lumaFactor * 0.6h) * half(0.7 + pattern * 0.3);

    // Use different blend modes for different effects:

    // 1. Screen blend - adds light, good for rainbows
    half3 screenBlend = blendScreen(originalColor.rgb, rainbowColor * 0.5h);

    // 2. Overlay blend - enhances contrast with color
    half3 overlayBlend = blendOverlay(originalColor.rgb, rainbowColor * 0.6h);

    // 3. Soft light - subtle color tinting
    half3 softBlend = cardFive_softLight(originalColor.rgb, rainbowColor * 0.4h);

    // Mix the blend modes
    half3 blendedColor = mix(screenBlend, overlayBlend, 0.5h);
    blendedColor = mix(blendedColor, softBlend, 0.3h);

    // Apply the blend based on our calculated amount
    half3 result = mix(originalColor.rgb, blendedColor, blendAmount);

    // Add glare (brighter, follows tilt)
    half3 glareColor = half3(1.0h, 0.98h, 0.95h) + rainbowColor * 0.2h;
    result += glareColor * half(glare * 0.35 * intensity);

    // Subtle overall brightness boost in rainbow areas
    result *= 1.0h + half(pattern * 0.1 * intensity);

    return half4(result, originalColor.a);
}

// Additional shimmer/sparkle layer
[[stitchable]] half4 sparkles(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Sparkle grid
    float gridSize = 45.0;
    float2 gridUV = uv * gridSize;
    float2 cellID = floor(gridUV);
    float2 cellUV = fract(gridUV) - 0.5;

    // Random per cell
    float rand = fract(sin(dot(cellID, float2(127.1, 311.7))) * 43758.5453);

    // Sparkle phase - tied to tilt
    float phase = rand * 6.28318 + (tilt.x + tilt.y) * 12.0 + time * 3.5;

    // Only some cells sparkle
    float active = step(0.7, rand);

    // Sparkle intensity
    float sparkleIntensity = pow(max(0.0, sin(phase)), 12.0) * active;

    // Point shape
    float dist = length(cellUV);
    float point = smoothstep(0.15, 0.0, dist);

    float sparkle = point * sparkleIntensity;

    // Sparkle color (white with rainbow tint)
    float hue = fract(rand + tilt.x * 0.2 + tilt.y * 0.15);
    half3 sparkleColor = half3(1.0h, 1.0h, 1.0h) + hsv2rgb(half(hue), 0.5h, 0.3h);

    half3 result = originalColor.rgb + sparkleColor * half(sparkle * 0.7);

    return half4(result, originalColor.a);
}

// Light sweep effect
[[stitchable]] half4 angledSweep(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Sweep position based on time and tilt
    float sweepPos = fract(time * 0.15 + tilt.x * 0.4 + tilt.y * 0.3);

    // Angled sweep
    float angle = tilt.y * 0.4;
    float cosA = cos(angle);
    float sinA = sin(angle);
    float2 rotUV = float2(
        uv.x * cosA - uv.y * sinA,
        uv.x * sinA + uv.y * cosA
    );

    // Sweep band
    float sweepWidth = 0.1;
    float sweep = smoothstep(sweepPos - sweepWidth, sweepPos, rotUV.x) *
                  smoothstep(sweepPos + sweepWidth, sweepPos, rotUV.x);

    // Rainbow tint for sweep
    float hue = fract(rotUV.y + tilt.x * 0.2);
    half3 sweepColor = half3(1.0h, 1.0h, 1.0h) + hsv2rgb(half(hue), 0.4h, 0.3h);

    half3 result = originalColor.rgb + sweepColor * half(sweep * 0.2);

    return half4(result, originalColor.a);
}

// ============================================
// IMAGE-ONLY EFFECTS (for artwork layer on top)
// ============================================

// Simple glare effect for image - just moving light, no rainbow
[[stitchable]] half4 glare(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float intensity
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Glare position follows tilt
    float2 glarePos = float2(0.5 + tilt.y * 0.7, 0.5 + tilt.x * 0.7);
    float glareDist = length(uv - glarePos);

    // Main glare - soft circular gradient
    float glare = smoothstep(0.6, 0.0, glareDist);
    glare = pow(glare, 2.0);

    // Secondary wider glow
    float glow = smoothstep(0.8, 0.2, glareDist) * 0.3;

    // Combine
    float totalGlare = glare * 0.4 + glow;

    // White glare with slight warm tint
    half3 glareColor = half3(1.0h, 0.98h, 0.95h);

    half3 result = originalColor.rgb + glareColor * half(totalGlare * intensity);

    return half4(result, originalColor.a);
}

// Subtle edge shine for image frame
[[stitchable]] half4 edgeShine(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Distance from edges
    float edgeX = min(uv.x, 1.0 - uv.x);
    float edgeY = min(uv.y, 1.0 - uv.y);
    float edge = min(edgeX, edgeY);

    // Edge highlight
    float edgeShine = smoothstep(0.0, 0.05, edge) * (1.0 - smoothstep(0.05, 0.12, edge));

    // Modulate by tilt direction
    float2 tiltDir = normalize(tilt + 0.001);
    float2 uvDir = normalize(uv - 0.5 + 0.001);
    float tiltAlignment = dot(tiltDir, uvDir) * 0.5 + 0.5;

    edgeShine *= tiltAlignment;

    half3 result = originalColor.rgb + half3(1.0h) * half(edgeShine * 0.25);

    return half4(result, originalColor.a);
}
