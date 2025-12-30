//
//  PolishedAluminumShader.metal
//  ShaderKit
//
//  Polished aluminum with linear gradient and diagonal rainbow reflection
//  Creates realistic polished metal with cyan/purple iridescent tones
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

[[stitchable]] half4 polishedAluminum(
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

    // =========================================================================
    // STEP 1: Linear Gradient Base (Polished Metal Look)
    // =========================================================================

    // Define polished metal colors
    half3 silver = half3(0.92h, 0.93h, 0.95h);       // Bright silver
    half3 darkSilver = half3(0.70h, 0.72h, 0.75h);   // Darker silver
    half3 cyan = half3(0.5h, 0.85h, 0.92h);          // Cyan/turquoise
    half3 purple = half3(0.78h, 0.65h, 0.88h);       // Lavender/purple

    // Linear gradient that shifts with tilt
    // Gradient runs vertically but shifts horizontally with tilt
    float gradientT = uv.y + tilt.x * 0.4 + tilt.y * 0.3;
    gradientT = fract(gradientT); // Keep in 0-1 range

    // Create smooth color bands: cyan -> silver -> purple -> silver -> cyan
    half3 metalBase;
    if (gradientT < 0.2) {
        // Cyan to silver
        float t = gradientT / 0.2;
        metalBase = mix(cyan, silver, half(smoothstep(0.0, 1.0, t)));
    } else if (gradientT < 0.4) {
        // Silver to bright silver
        float t = (gradientT - 0.2) / 0.2;
        metalBase = mix(silver, half3(0.98h), half(smoothstep(0.0, 1.0, t) * 0.5));
    } else if (gradientT < 0.6) {
        // Silver to purple
        float t = (gradientT - 0.4) / 0.2;
        metalBase = mix(silver, purple, half(smoothstep(0.0, 1.0, t)));
    } else if (gradientT < 0.8) {
        // Purple to silver
        float t = (gradientT - 0.6) / 0.2;
        metalBase = mix(purple, darkSilver, half(smoothstep(0.0, 1.0, t)));
    } else {
        // Dark silver to cyan
        float t = (gradientT - 0.8) / 0.2;
        metalBase = mix(darkSilver, cyan, half(smoothstep(0.0, 1.0, t)));
    }

    // Add horizontal variation for more dimension
    float horizVar = sin(uv.x * 3.14159 + tilt.x * 2.0) * 0.5 + 0.5;
    metalBase = mix(metalBase, metalBase * 1.1h, half(horizVar * 0.15));

    // Add subtle noise for brushed texture
    float noise = valueNoise(uv * 80.0 + tilt * 2.0);
    metalBase += half3((noise - 0.5) * 0.08h);

    // =========================================================================
    // STEP 2: Diagonal Rainbow Reflection Band
    // =========================================================================

    // Diagonal direction (45 degrees - bottom-left to top-right)
    float rainbowAngle = 45.0 * 3.14159 / 180.0;
    float2 rainbowDir = float2(cos(rainbowAngle), sin(rainbowAngle));

    // Rainbow position shifts with tilt for parallax
    float2 tiltOffset = tilt * 0.5;
    float rainbowT = dot(uv + tiltOffset, rainbowDir);

    // Create a focused band of rainbow
    float bandCenter = 0.5 + (tilt.x + tilt.y) * 0.25;
    float bandWidth = 0.3;
    float bandFalloff = smoothstep(bandCenter - bandWidth, bandCenter, rainbowT) *
                        smoothstep(bandCenter + bandWidth, bandCenter, rainbowT);

    // Rainbow colors along the band
    float rainbowPhase = rainbowT * 2.5 + (tilt.x - tilt.y) * 1.5;
    half3 rainbow = rainbowGradient(rainbowPhase);

    // =========================================================================
    // STEP 3: Combine Layers
    // =========================================================================

    half3 result = metalBase;

    // Blend rainbow using screen mode for bright overlay
    half3 rainbowContrib = rainbow * half(bandFalloff * intensity * 0.5);
    result = blendScreen(result, rainbowContrib);

    // Add subtle specular highlight that follows tilt
    float2 lightPos = float2(0.5 + tilt.x * 0.3, 0.5 + tilt.y * 0.3);
    float lightDist = length(uv - lightPos);
    float specular = smoothstep(0.5, 0.0, lightDist);
    specular = pow(specular, 3.0) * 0.2;
    result += half3(half(specular));

    // Mix with original based on intensity
    result = mix(originalColor.rgb, result, half(intensity));

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
