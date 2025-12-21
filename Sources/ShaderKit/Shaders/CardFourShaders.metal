//
//  CardFourShaders.metal
//  SwiftUIAnimationDemos
//
//  Starburst radial rainbow holographic shader - mimics premium Pokemon card effects
//  with multi-source iridescence, radial streaks, and sparkle particles
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

// Main starburst holographic effect
[[stitchable]] half4 starburst(
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

    // Center of the card for radial calculations
    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;

    // Calculate angle and distance from center
    float angle = atan2(toCenter.y, toCenter.x);
    float dist = length(toCenter);

    // ========================================
    // STARBURST RADIAL RAYS
    // ========================================

    // Multiple starburst patterns with different frequencies
    float rays1 = sin(angle * 12.0 + tilt.x * 8.0 + time * 0.5) * 0.5 + 0.5;
    float rays2 = sin(angle * 18.0 - tilt.y * 6.0 + time * 0.3) * 0.5 + 0.5;
    float rays3 = sin(angle * 24.0 + (tilt.x + tilt.y) * 4.0) * 0.5 + 0.5;

    // Combine rays with distance falloff
    float starburstPattern = (rays1 * 0.4 + rays2 * 0.35 + rays3 * 0.25);
    starburstPattern *= smoothstep(0.7, 0.0, dist); // Fade towards edges

    // ========================================
    // RAINBOW COLOR GENERATION
    // ========================================

    // Primary rainbow based on angle and tilt
    float hueAngle = angle / 6.28318 + 0.5; // Normalize to 0-1
    float hueTilt = (tilt.x + tilt.y) * 0.15;
    float hueTime = time * 0.02;
    float hue1 = fract(hueAngle + hueTilt + hueTime);

    // Secondary rainbow shifted by position
    float hue2 = fract(hue1 + (uv.x + uv.y) * 0.3 - tilt.x * 0.2);

    // Tertiary rainbow for depth
    float hue3 = fract(hue2 + dist * 0.5 + tilt.y * 0.15);

    // Generate rainbow colors
    half3 rainbow1 = hsv2rgb(half(hue1), 0.85h, 1.0h);
    half3 rainbow2 = hsv2rgb(half(hue2), 0.75h, 0.95h);
    half3 rainbow3 = hsv2rgb(half(hue3), 0.9h, 0.9h);

    // Blend rainbows based on starburst pattern
    half3 rainbowBlend = mix(rainbow1, rainbow2, half(starburstPattern));
    rainbowBlend = mix(rainbowBlend, rainbow3, half(rays3 * 0.5));

    // ========================================
    // IRIDESCENT OIL-SLICK EFFECT
    // ========================================

    // Thin-film interference simulation
    float filmThickness = (uv.x * 2.0 + uv.y * 3.0 + tilt.x * 2.0 + tilt.y * 1.5) * 3.14159;
    float interference = sin(filmThickness) * 0.5 + 0.5;

    // Iridescent color shift
    half3 iridescent = hsv2rgb(
        half(fract(interference + tilt.x * 0.3 + tilt.y * 0.2)),
        0.6h,
        1.0h
    );

    // ========================================
    // MULTIPLE LIGHT HOTSPOTS
    // ========================================

    // Primary hotspot follows tilt
    float2 hotspot1 = float2(0.5 + tilt.y * 0.8, 0.5 + tilt.x * 0.8);
    float hot1 = pow(smoothstep(0.6, 0.0, length(uv - hotspot1)), 2.0);

    // Secondary hotspots at different positions
    float2 hotspot2 = float2(0.5 - tilt.y * 0.5, 0.5 - tilt.x * 0.5);
    float hot2 = pow(smoothstep(0.5, 0.0, length(uv - hotspot2)), 2.2) * 0.6;

    float2 hotspot3 = float2(0.5 + tilt.x * 0.4, 0.5 - tilt.y * 0.4);
    float hot3 = pow(smoothstep(0.4, 0.0, length(uv - hotspot3)), 2.0) * 0.4;

    float totalHot = hot1 + hot2 + hot3;

    // ========================================
    // SPARKLE PARTICLES
    // ========================================

    // Grid-based sparkles
    float sparkleGrid = 60.0;
    float2 sparkleUV = uv * sparkleGrid;
    float2 sparkleCell = floor(sparkleUV);
    float2 sparkleLocal = fract(sparkleUV) - 0.5;

    float sparkleRand = hash21(sparkleCell);
    float sparklePhase = sparkleRand * 6.28318 + (tilt.x + tilt.y) * 15.0 + time * 4.0;

    // Sparkle intensity based on tilt alignment
    float sparkleIntensity = pow(max(0.0, sin(sparklePhase)), 8.0);
    sparkleIntensity *= step(0.6, sparkleRand); // Only some cells sparkle

    // Point sparkle shape
    float sparkleDist = length(sparkleLocal);
    float sparklePoint = smoothstep(0.15, 0.0, sparkleDist);
    float sparkle = sparklePoint * sparkleIntensity;

    // Extra bright sparkles for highlights
    float megaSparkle = pow(max(0.0, sin(sparklePhase * 0.5 + 1.0)), 16.0);
    megaSparkle *= step(0.88, sparkleRand);
    megaSparkle *= sparklePoint * 2.0;

    // ========================================
    // FINE TEXTURE PATTERN
    // ========================================

    // Subtle crosshatch/noise texture
    float texture = valueNoise(uv * 80.0 + tilt * 5.0) * 0.15;
    texture += valueNoise(uv * 120.0 - tilt * 3.0) * 0.1;

    // ========================================
    // COMBINE ALL EFFECTS
    // ========================================

    // Base holographic layer
    half holoStrength = half(intensity * (0.5 + starburstPattern * 0.3 + totalHot * 0.2));
    half3 result = mix(originalColor.rgb, rainbowBlend, holoStrength * 0.6h);

    // Add iridescent overlay
    result = mix(result, result + iridescent * 0.3h, half(totalHot * 0.5));

    // Starburst ray highlights
    result += rainbowBlend * half(starburstPattern * totalHot * 0.4);

    // Light hotspot glow
    result += half3(1.0h, 0.98h, 0.95h) * half(totalHot * 0.3);

    // Sparkle highlights
    half3 sparkleColor = half3(1.0h, 1.0h, 1.0h);
    sparkleColor += rainbowBlend * 0.3h; // Tinted sparkles
    result += sparkleColor * half(sparkle * 1.2);
    result += half3(1.0h, 0.95h, 0.9h) * half(megaSparkle * 2.0);

    // Texture overlay
    result *= half(1.0 + texture);

    // Brightness boost in hot areas
    result *= half(1.0 + totalHot * 0.15);

    return half4(result, originalColor.a);
}

// Radial light sweep effect
[[stitchable]] half4 radialSweep(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time
) {
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    float2 uv = position / size;
    float2 center = float2(0.5, 0.5);

    // Radial sweep that rotates with tilt
    float2 toCenter = uv - center;
    float angle = atan2(toCenter.y, toCenter.x);

    // Sweep position rotates based on time and tilt
    float sweepAngle = time * 0.8 + tilt.x * 2.0 + tilt.y * 1.5;
    float angleDiff = angle - sweepAngle;

    // Normalize angle difference
    angleDiff = fmod(angleDiff + 3.14159, 6.28318) - 3.14159;

    // Sweep intensity
    float sweepWidth = 0.5;
    float sweep = smoothstep(sweepWidth, 0.0, abs(angleDiff));
    sweep *= smoothstep(0.0, 0.3, length(toCenter)); // Fade near center
    sweep *= smoothstep(0.7, 0.4, length(toCenter)); // Fade at edges

    // Rainbow color for sweep
    float hue = fract(angle / 6.28318 + tilt.x * 0.1);
    half3 sweepColor = hsv2rgb(half(hue), 0.5h, 1.0h);

    half3 result = originalColor.rgb + sweepColor * half(sweep * 0.25);

    return half4(result, originalColor.a);
}

// Glitter overlay effect
[[stitchable]] half4 multiGlitter(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float density
) {
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    float2 uv = position / size;

    // Multi-scale glitter
    float glitter = 0.0;

    // Fine glitter
    float2 fineGrid = floor(uv * density);
    float fineRand = hash21(fineGrid);
    float finePhase = fineRand * 6.28318 + (tilt.x * 8.0 + tilt.y * 6.0) + time * 5.0;
    float fineSparkle = pow(max(0.0, sin(finePhase)), 12.0) * step(0.7, fineRand);

    float2 fineLocal = fract(uv * density) - 0.5;
    float fineDist = length(fineLocal);
    glitter += smoothstep(0.08, 0.0, fineDist) * fineSparkle * 0.6;

    // Medium glitter
    float2 medGrid = floor(uv * density * 0.5);
    float medRand = hash21(medGrid + 100.0);
    float medPhase = medRand * 6.28318 + (tilt.x * 6.0 + tilt.y * 8.0) + time * 3.0;
    float medSparkle = pow(max(0.0, sin(medPhase)), 10.0) * step(0.65, medRand);

    float2 medLocal = fract(uv * density * 0.5) - 0.5;
    float medDist = length(medLocal);
    glitter += smoothstep(0.12, 0.0, medDist) * medSparkle * 0.8;

    // Glitter color (white with slight rainbow tint)
    float hue = fract(fineRand + medRand + tilt.x * 0.2);
    half3 glitterColor = half3(1.0h, 1.0h, 1.0h) + hsv2rgb(half(hue), 0.3h, 0.3h);

    half3 result = originalColor.rgb + glitterColor * half(glitter);

    return half4(result, originalColor.a);
}
