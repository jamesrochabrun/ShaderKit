//
//  CardThreeShaders.metal
//  SwiftUIAnimationDemos
//
//  Holographic foil, glitter, and light sweep shaders for CardThree
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Rainbow color generation
static half3 cardThree_rainbow(float angle, float intensity) {
    half3 color;
    color.r = sin(angle) * 0.5h + 0.5h;
    color.g = sin(angle + 2.094h) * 0.5h + 0.5h;
    color.b = sin(angle + 4.189h) * 0.5h + 0.5h;
    return color * half(intensity);
}

// Holographic foil effect
[[stitchable]] half4 foil(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    float2 uv = position / size;

    // Holographic angle based on position and tilt
    float angle = (uv.x + uv.y) * 6.0 + tilt.x * 3.0 + tilt.y * 2.0 + time * 0.5;

    // Wave patterns
    float wave1 = sin(uv.x * 20.0 + time * 2.0 + tilt.x * 5.0) * 0.5 + 0.5;
    float wave2 = sin(uv.y * 15.0 + time * 1.5 + tilt.y * 4.0) * 0.5 + 0.5;
    float wave3 = sin((uv.x + uv.y) * 25.0 + time * 3.0) * 0.5 + 0.5;

    float pattern = (wave1 + wave2 + wave3) / 3.0;

    half3 rainbow = cardThree_rainbow(angle + pattern * 2.0, 1.0);

    // Sparkle effect
    float sparkleAngle = (uv.x * 50.0 + uv.y * 50.0 + time * 10.0);
    float sparkle = pow(max(0.0, sin(sparkleAngle)), 20.0) * 0.5;

    // Fresnel-like effect
    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;
    float tiltDot = dot(normalize(toCenter + 0.001), normalize(tilt + 0.001));
    float fresnel = pow(1.0 - abs(tiltDot), 2.0) * 0.3 + 0.7;

    // Combine effects
    half3 holoColor = rainbow * half(pattern * fresnel + sparkle);
    half3 finalColor = mix(originalColor.rgb, originalColor.rgb + holoColor * 0.6h, half(intensity));
    finalColor += rainbow * 0.15h * half(intensity);

    return half4(finalColor, originalColor.a);
}

// Glitter sparkle effect
[[stitchable]] half4 glitter(
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

    // Grid for glitter points
    float gridSize = density;
    float2 gridUV = fract(uv * gridSize);
    float2 gridID = floor(uv * gridSize);

    // Pseudo-random per grid cell
    float random = fract(sin(dot(gridID, float2(12.9898, 78.233))) * 43758.5453);

    // Sparkle visibility
    float sparklePhase = random * 6.28318 + time * (2.0 + random * 3.0);
    float tiltInfluence = dot(normalize(tilt + 0.001), float2(cos(random * 6.28), sin(random * 6.28)));
    float sparkleIntensity = pow(max(0.0, sin(sparklePhase + tiltInfluence * 3.0)), 8.0);

    // Distance from center of grid cell
    float2 cellCenter = float2(0.5, 0.5);
    float dist = length(gridUV - cellCenter);
    float pointSize = 0.1 + random * 0.1;
    float point = smoothstep(pointSize, 0.0, dist);

    // Sparkle color
    half3 sparkleColor = half3(1.0h, 1.0h, 1.0h);
    float rainbowAngle = random * 6.28 + tilt.x * 2.0 + tilt.y * 2.0;
    sparkleColor += cardThree_rainbow(rainbowAngle, 0.3) * 0.5h;

    half3 finalColor = originalColor.rgb + sparkleColor * half(point * sparkleIntensity * 0.8);

    return half4(finalColor, originalColor.a);
}

// Light sweep effect
[[stitchable]] half4 lightSweep(
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

    // Sweep position based on time and tilt
    float sweepPos = fract(time * 0.3 + tilt.x * 0.5);
    float sweepAngle = tilt.y * 0.5;

    // Rotated UV for angled sweep
    float2 rotatedUV;
    float cosA = cos(sweepAngle);
    float sinA = sin(sweepAngle);
    rotatedUV.x = uv.x * cosA - uv.y * sinA;
    rotatedUV.y = uv.x * sinA + uv.y * cosA;

    // Sweep intensity
    float sweepWidth = 0.15;
    float sweep = smoothstep(sweepPos - sweepWidth, sweepPos, rotatedUV.x) *
                  smoothstep(sweepPos + sweepWidth, sweepPos, rotatedUV.x);

    half3 finalColor = originalColor.rgb + half3(1.0h, 1.0h, 1.0h) * half(sweep * 0.4);

    return half4(finalColor, originalColor.a);
}
