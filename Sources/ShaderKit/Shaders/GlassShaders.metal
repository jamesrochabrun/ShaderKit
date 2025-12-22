//
//  GlassShaders.metal
//  DemoView
//
//  Refractive glass effect based on physical light simulation
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Helper: Signed distance function for a capsule/pill shape
float sdCapsule(float2 p, float2 size) {
    float radius = size.y * 0.5;
    float halfWidth = size.x * 0.5 - radius;
    p.x = abs(p.x) - halfWidth;
    p.x = max(p.x, 0.0);
    return length(p) - radius;
}

// MARK: - Circular Magnifying Glass Effect
// Based on physical glass simulation: refraction, shadows, edge lighting, chromatic aberration

[[stitchable]] half4 magnifyingGlass(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,       // Normalized (0-1) position of glass center
    float glassRadius,        // Normalized radius (0-1)
    float refractionStrength, // How much the glass bends light
    float shadowOffset,       // Shadow offset for depth
    float shadowBlur,         // Shadow blur radius
    float edgeThickness,      // Rim light thickness
    float chromaticAmount     // Chromatic aberration intensity
) {
    // Work in normalized UV space (0-1) with aspect ratio correction
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;

    // Correct for aspect ratio so circle doesn't become oval
    float aspectRatio = size.x / size.y;
    float2 toCenterCorrected = float2(toCenter.x * aspectRatio, toCenter.y);
    float dist = length(toCenterCorrected);
    float normalizedDist = dist / glassRadius;

    // Default: sample original background
    half4 originalColor = layer.sample(position);

    // --- SHADOW & OCCLUSION ---
    float2 shadowCenter = glassCenter + float2(shadowOffset, shadowOffset);
    float2 toShadowCenter = uv - shadowCenter;
    float2 toShadowCorrected = float2(toShadowCenter.x * aspectRatio, toShadowCenter.y);
    float shadowDist = length(toShadowCorrected);
    float shadowRadiusNorm = glassRadius + shadowBlur;

    bool insideGlass = (normalizedDist <= 1.0);
    bool insideShadow = (shadowDist < shadowRadiusNorm && shadowDist > glassRadius);

    // Apply shadow outside glass but within shadow radius
    if (!insideGlass && insideShadow) {
        float shadowFalloff = (shadowDist - glassRadius) / shadowBlur;
        float shadowStrength = smoothstep(1.0, 0.0, shadowFalloff);
        originalColor.rgb = mix(originalColor.rgb, half3(0.0), shadowStrength * 0.2);
    }

    // Outside the glass: return (potentially shadowed) original
    if (!insideGlass) {
        return originalColor;
    }

    // --- REFRACTION ---
    // Parabolic falloff: 1 - r² gives strongest distortion at center
    float distortion = 1.0 - normalizedDist * normalizedDist;

    // Convert glass center and current position to find direction vector
    float2 centerPx = glassCenter * size;
    float2 toCenterPx = centerPx - position;  // Points TOWARD center
    float radiusPx = glassRadius * min(size.x, size.y);

    // Scale the offset - positive values pull toward center (magnify)
    float offsetStrength = distortion * refractionStrength * radiusPx;
    float2 offset = normalize(toCenterPx + 0.001) * offsetStrength;

    // --- CHROMATIC ABERRATION ---
    float chromaticStrength = normalizedDist * chromaticAmount;

    // Sample positions - ADD offset to pull samples toward center
    float2 redSamplePos = position + offset * (1.0 + chromaticStrength);
    float2 greenSamplePos = position + offset;
    float2 blueSamplePos = position + offset * (1.0 - chromaticStrength);

    half4 redSample = layer.sample(redSamplePos);
    half4 greenSample = layer.sample(greenSamplePos);
    half4 blueSample = layer.sample(blueSamplePos);

    half4 refractedColor;
    refractedColor.r = redSample.r;
    refractedColor.g = greenSample.g;
    refractedColor.b = blueSample.b;
    refractedColor.a = 1.0;

    // --- EDGE LIGHTING / RIM HIGHLIGHT ---
    float edgeDistance = abs(normalizedDist - 1.0) * glassRadius;
    float edgeFade = smoothstep(edgeThickness, 0.0, edgeDistance);

    // Directional light from upper-left (use corrected vector for proper circle highlight)
    float2 lightDir = normalize(float2(-0.5, -0.8));
    float rimBias = dot(normalize(toCenterCorrected), lightDir);
    rimBias = clamp(rimBias, 0.0, 1.0);

    // Cool-toned highlight for glass feel
    half3 highlightColor = half3(1.1, 1.15, 1.25);
    refractedColor.rgb += edgeFade * rimBias * highlightColor * 0.8;

    // Secondary subtle rim on opposite side
    float rimBias2 = dot(normalize(toCenterCorrected), -lightDir);
    rimBias2 = clamp(rimBias2, 0.0, 1.0);
    refractedColor.rgb += edgeFade * rimBias2 * half3(0.7, 0.75, 0.85) * 0.25;

    // --- SUBTLE GLASS TINT ---
    half3 glassTint = half3(0.98, 0.99, 1.02);
    refractedColor.rgb *= glassTint;

    // Center brightness boost (lens effect)
    float centerBrightness = (1.0 - normalizedDist) * 0.02;
    refractedColor.rgb += centerBrightness;

    return refractedColor;
}

// MARK: - Visualization Shader (for debugging distortion)
[[stitchable]] half4 refractionVisual(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,
    float glassRadius,
    float refraction
) {
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;
    float dist = length(toCenter);
    float normalizedDist = dist / glassRadius;

    // Default to background layer
    half4 originalColor = layer.sample(position);

    // Outside the glass: return original
    if (normalizedDist > 1.0) {
        return originalColor;
    }

    // Compute distortion strength - parabolic falloff
    float distortion = 1.0 - normalizedDist * normalizedDist * refraction;

    // Visualize it: brighter = more distortion
    return half4(distortion, distortion, distortion, 1.0);
}

// MARK: - Animated Liquid Glass Effect
[[stitchable]] half4 liquidGlass(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,
    float glassRadius,
    float time,
    float refractionStrength
) {
    // Work in normalized UV space with aspect ratio correction
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;

    // Correct for aspect ratio
    float aspectRatio = size.x / size.y;
    float2 toCenterCorrected = float2(toCenter.x * aspectRatio, toCenter.y);
    float dist = length(toCenterCorrected);
    float normalizedDist = dist / glassRadius;

    half4 originalColor = layer.sample(position);

    // Shadow with animated offset
    float shadowWobble = sin(time * 1.5) * 0.005;
    float2 shadowCenter = glassCenter + float2(0.02 + shadowWobble, 0.03 + shadowWobble);
    float2 toShadowCorrected = float2((uv.x - shadowCenter.x) * aspectRatio, uv.y - shadowCenter.y);
    float shadowDist = length(toShadowCorrected);
    float shadowRadiusNorm = glassRadius + 0.05;

    if (normalizedDist > 1.0) {
        if (shadowDist < shadowRadiusNorm && shadowDist > glassRadius) {
            float shadowFalloff = (shadowDist - glassRadius) / 0.05;
            float shadowStrength = smoothstep(1.0, 0.0, shadowFalloff);
            originalColor.rgb = mix(originalColor.rgb, half3(0.0), shadowStrength * 0.15);
        }
        return originalColor;
    }

    // Animated distortion with liquid wobble
    float wobble = sin(time * 2.0 + normalizedDist * 6.28) * 0.15;
    float distortion = 1.0 - pow(normalizedDist, 2.0 + wobble);

    // Simple offset in UV space
    float2 offset = toCenter * distortion * refractionStrength;

    // Animated chromatic aberration
    float chromaticStrength = normalizedDist * (0.08 + sin(time) * 0.02);

    float2 redOffset = offset * (1.0 + chromaticStrength);
    float2 greenOffset = offset;
    float2 blueOffset = offset * (1.0 - chromaticStrength);

    // Sample with offsets converted to pixel space
    half4 refractedColor;
    refractedColor.r = layer.sample(position + redOffset * size).r;
    refractedColor.g = layer.sample(position + greenOffset * size).g;
    refractedColor.b = layer.sample(position + blueOffset * size).b;
    refractedColor.a = 1.0;

    // Animated rim lighting
    float edgeFade = smoothstep(0.015, 0.0, abs(normalizedDist - 1.0) * glassRadius);
    float lightAngle = time * 0.5;
    float2 lightDir = normalize(float2(-0.5 + sin(lightAngle) * 0.3, -0.8 + cos(lightAngle) * 0.2));
    float rimBias = clamp(dot(normalize(toCenterCorrected), lightDir), 0.0, 1.0);

    half3 rimColor = half3(1.2, 1.25, 1.4);
    refractedColor.rgb += edgeFade * rimBias * rimColor * 0.7;

    // Secondary rim
    float rimBias2 = clamp(dot(normalize(toCenterCorrected), -lightDir), 0.0, 1.0);
    refractedColor.rgb += edgeFade * rimBias2 * half3(0.7, 0.75, 0.85) * 0.2;

    // Glass tint
    refractedColor.rgb *= half3(0.97, 0.98, 1.02);
    refractedColor.rgb += (1.0 - normalizedDist) * 0.02;

    return refractedColor;
}

// MARK: - Refractive Glass Capsule Effect
[[stitchable]] half4 glassRefraction(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float refractionStrength,
    float edgeThickness,
    float shadowOffset,
    float shadowBlur
) {
    float2 uv = position / size;
    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;

    // Capsule SDF in UV space
    float2 capsuleSize = float2(1.0, 1.0); // normalized
    float dist = sdCapsule(toCenter, capsuleSize);

    // Normalize distance (0 at center, 1 at edge)
    float glassRadius = 0.0; // edge of capsule
    float innerRadius = -0.4; // deep inside
    float normalizedDist = smoothstep(innerRadius, glassRadius, dist);

    // Sample original
    half4 originalColor = layer.sample(position);

    // Outside the glass shape
    if (dist > 0.0) {
        // Shadow region
        float2 shadowCenter = center + float2(shadowOffset, shadowOffset);
        float shadowDist = sdCapsule(uv - shadowCenter, capsuleSize);

        if (shadowDist < shadowBlur && shadowDist > 0.0) {
            float shadowFalloff = shadowDist / shadowBlur;
            float shadowStrength = smoothstep(1.0, 0.0, shadowFalloff);
            originalColor.rgb = mix(originalColor.rgb, half3(0.0), shadowStrength * 0.3);
        }
        return originalColor;
    }

    // Inside the glass - apply refraction
    // Parabolic falloff: stronger at center, weaker at edges
    float distortion = 1.0 - normalizedDist * normalizedDist;
    float2 offset = toCenter * distortion * refractionStrength;

    // Chromatic aberration - increases toward edges
    float chromaticStrength = normalizedDist * 0.015;
    float2 redOffset = offset * (1.0 + chromaticStrength);
    float2 greenOffset = offset;
    float2 blueOffset = offset * (1.0 - chromaticStrength);

    // Sample each channel with different offsets
    half4 redSample = layer.sample(position + redOffset * size);
    half4 greenSample = layer.sample(position + greenOffset * size);
    half4 blueSample = layer.sample(position + blueOffset * size);

    half4 refractedColor;
    refractedColor.r = redSample.r;
    refractedColor.g = greenSample.g;
    refractedColor.b = blueSample.b;
    refractedColor.a = 1.0;

    // Edge lighting / rim highlight
    float edgeDist = abs(dist);
    float edgeFade = smoothstep(edgeThickness, 0.0, edgeDist);

    // Directional light from upper-left
    float2 lightDir = normalize(float2(-0.5, -0.8));
    float rimBias = dot(normalize(toCenter), lightDir);
    rimBias = clamp(rimBias, 0.0, 1.0);

    // Cool-toned highlight
    half3 highlightColor = half3(1.2, 1.25, 1.35);
    refractedColor.rgb += edgeFade * rimBias * highlightColor * 0.8;

    // Subtle inner glow/tint
    half3 glassTint = half3(0.95, 0.97, 1.0); // slight cool tint
    refractedColor.rgb *= glassTint;

    // Add subtle brightness in center (lens effect)
    float centerBrightness = (1.0 - normalizedDist) * 0.05;
    refractedColor.rgb += centerBrightness;

    return refractedColor;
}

// MARK: - Rounded Rectangle SDF helper
float sdRoundedRect(float2 p, float2 size, float radius) {
    float2 q = abs(p) - size + radius;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

// MARK: - Glass Enclosure Effect
// Plastic/glass layer over the card - like lamination or screen protector
// Flat glossy surface with beveled edges and soft reflections

[[stitchable]] half4 glassEnclosure(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,         // Overall effect strength (0.0 - 1.0)
    float cornerRadius,      // Corner radius (0.0 - 0.5)
    float bevelSize,         // Edge bevel thickness (0.0 - 1.0)
    float glossiness         // How shiny/reflective (0.0 - 1.0)
) {
    float2 uv = position / size;
    float2 centered = uv - 0.5;
    half4 color = layer.sample(position);

    // --- EDGE DISTANCES ---
    float edgeL = uv.x;
    float edgeR = 1.0 - uv.x;
    float edgeT = uv.y;
    float edgeB = 1.0 - uv.y;

    // --- FIXED LIGHT SOURCE (like room light above) ---
    // Light is FIXED - doesn't move with tilt
    float3 lightDir3D = normalize(float3(-0.4, -0.6, 1.0));

    // --- CARD SURFACE NORMAL (changes with tilt) ---
    // When card tilts, its surface normal changes
    float3 cardNormal = normalize(float3(
        -tilt.x * 0.5,  // Tilt right = normal points left
        -tilt.y * 0.5,  // Tilt down = normal points up
        1.0
    ));

    // --- REFLECTION CALCULATION ---
    // Where does the fixed light reflect off the tilted card surface?
    float3 viewDir = float3(0.0, 0.0, 1.0);
    float3 reflectDir = reflect(-lightDir3D, cardNormal);

    // How much does the reflection point toward viewer?
    float reflectToView = max(dot(reflectDir, viewDir), 0.0);

    // === EFFECT 1: ANGLE-BASED SHEEN ===
    // Sheen based on card angle relative to light
    float sheen = reflectToView * 0.06 * glossiness;

    // === EFFECT 2: SPECULAR REFLECTION ===
    // The specular highlight position is determined by card angle
    // It sweeps across the card as you tilt

    // Calculate where specular would appear on card surface
    // Based on reflection geometry
    float2 specOffset = float2(
        tilt.x * 0.4,
        tilt.y * 0.4
    );
    float2 specPos = float2(0.35, 0.3) - specOffset; // Moves opposite to tilt

    float specDist = length(uv - specPos);

    // Only show specular when angle is right (reflection toward viewer)
    float specVisible = smoothstep(0.3, 0.8, reflectToView);

    float specSoft = smoothstep(0.3, 0.0, specDist) * 0.1 * glossiness * specVisible;
    float specSharp = smoothstep(0.08, 0.0, specDist);
    specSharp = pow(specSharp, 2.0) * 0.2 * glossiness * specVisible;

    // === EFFECT 3: EDGE BEVELS ===
    // Bevels respond to card tilt - edges facing light get brighter
    float bevelWidth = 0.02 + bevelSize * 0.04;

    // Edge bevels based on card tilt angle
    // When card tilts, certain edges face the light more
    float topBevel = smoothstep(bevelWidth, 0.0, edgeT);
    float topLight = clamp(0.5 - tilt.y * 0.8, 0.0, 1.0); // Bright when tilted back

    float leftBevel = smoothstep(bevelWidth, 0.0, edgeL);
    float leftLight = clamp(0.5 - tilt.x * 0.8, 0.0, 1.0); // Bright when tilted right

    float bottomBevel = smoothstep(bevelWidth, 0.0, edgeB);
    float bottomLight = clamp(0.3 + tilt.y * 0.6, 0.0, 1.0); // Bright when tilted forward

    float rightBevel = smoothstep(bevelWidth, 0.0, edgeR);
    float rightLight = clamp(0.3 + tilt.x * 0.6, 0.0, 1.0); // Bright when tilted left

    // Combine bevels
    float bevelHighlight = (topBevel * topLight + leftBevel * leftLight) * 0.3;
    float bevelDim = (bottomBevel * (1.0 - bottomLight) + rightBevel * (1.0 - rightLight)) * 0.08;

    // === EFFECT 4: CORNER HIGHLIGHTS ===
    // Corners respond to tilt angle
    float2 tlPos = float2(cornerRadius, cornerRadius);
    float tlDist = length(uv - tlPos);
    float tlCorner = smoothstep(cornerRadius * 1.5, 0.0, tlDist);
    tlCorner *= clamp(0.4 - tilt.x * 0.5 - tilt.y * 0.5, 0.0, 1.0) * 0.15;

    float2 trPos = float2(1.0 - cornerRadius, cornerRadius);
    float trDist = length(uv - trPos);
    float trCorner = smoothstep(cornerRadius * 1.5, 0.0, trDist);
    trCorner *= clamp(0.3 + tilt.x * 0.4 - tilt.y * 0.4, 0.0, 1.0) * 0.1;

    float cornerHighlight = (tlCorner + trCorner) * glossiness;

    // === EFFECT 5: INNER EDGE LINE ===
    // Thin line showing glass thickness - responds to tilt
    float innerEdgeDist = min(min(edgeL, edgeR), min(edgeT, edgeB));
    float innerLine = smoothstep(bevelWidth * 1.2, bevelWidth * 0.8, innerEdgeDist);
    innerLine *= smoothstep(bevelWidth * 0.2, bevelWidth * 0.6, innerEdgeDist);
    innerLine *= 0.1 * glossiness;

    float innerLineLight = innerLine * (
        smoothstep(bevelWidth, 0.0, edgeT) * topLight * 0.4 +
        smoothstep(bevelWidth, 0.0, edgeL) * leftLight * 0.4 +
        0.15
    );

    // === COMBINE ALL EFFECTS ===
    half3 result = color.rgb;

    // Angle-based sheen
    result += half(sheen) * half3(1.0, 1.0, 1.0) * half(intensity);

    // Specular (only when angle is right)
    result += half(specSoft) * half3(1.0, 1.0, 1.0) * half(intensity);
    result += half(specSharp) * half3(1.0, 1.0, 1.0) * half(intensity);

    // Edge bevels
    result += half(bevelHighlight) * half3(1.0, 1.0, 1.0) * half(intensity);
    result -= half(bevelDim) * half3(0.08, 0.06, 0.04) * half(intensity);

    // Corners
    result += half(cornerHighlight) * half3(1.0, 1.0, 1.0) * half(intensity);

    // Inner edge
    result += half(innerLineLight) * half3(1.0, 1.0, 1.0) * half(intensity);

    return half4(result, color.a);
}

// MARK: - Glass Sheen Effect
// Simpler glass reflection overlay - just the reflection sweep and specular
// Good for layering with other effects

[[stitchable]] half4 glassSheen(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float spread    // How wide the reflection spreads (0.0 - 1.0)
) {
    float2 uv = position / size;
    half4 color = layer.sample(position);

    // Light position follows tilt
    float2 lightPos = float2(0.3 + tilt.x * 0.5, 0.25 + tilt.y * 0.4);

    // Main specular blob
    float specDist = length(uv - lightPos);
    float specSize = 0.25 + spread * 0.25;
    float specular = smoothstep(specSize, 0.0, specDist);
    specular = pow(specular, 1.5);

    // Diagonal sweep band
    float angle = -0.6 + tilt.x * 0.2;
    float sweep = uv.x * cos(angle) + uv.y * sin(angle);
    float sweepCenter = 0.5 + tilt.x * 0.25 + tilt.y * 0.15;
    float sweepWidth = 0.12 + spread * 0.08;
    float band = smoothstep(sweepWidth, 0.0, abs(sweep - sweepCenter));
    band *= smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.7, uv.y); // Fade at edges

    // Secondary subtle reflection
    float2 lightPos2 = float2(0.7 - tilt.x * 0.3, 0.6 - tilt.y * 0.3);
    float spec2Dist = length(uv - lightPos2);
    float specular2 = smoothstep(0.4, 0.0, spec2Dist) * 0.2;

    // Combine
    half3 result = color.rgb;
    result += specular * half3(1.0, 1.0, 1.03) * intensity * 0.35;
    result += band * half3(1.0, 1.0, 1.02) * intensity * 0.25;
    result += specular2 * half3(0.98, 0.99, 1.0) * intensity * 0.15;

    return half4(result, color.a);
}

// MARK: - Glass Edge Bevel
// Just the edge bevel effect - great for adding "thickness" to any card

[[stitchable]] half4 glassBevel(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float thickness   // Bevel thickness (0.0 - 1.0)
) {
    float2 uv = position / size;
    half4 color = layer.sample(position);

    // Edge distances
    float distLeft = uv.x;
    float distRight = 1.0 - uv.x;
    float distTop = uv.y;
    float distBottom = 1.0 - uv.y;

    float bevelWidth = 0.06 * thickness + 0.02;

    // Light direction from tilt
    float2 lightDir = normalize(float2(-0.5 + tilt.x * 0.5, -0.6 + tilt.y * 0.5));

    // Edge highlights (facing light)
    float topBevel = smoothstep(bevelWidth, 0.0, distTop) * clamp(-lightDir.y, 0.0, 1.0);
    float leftBevel = smoothstep(bevelWidth, 0.0, distLeft) * clamp(-lightDir.x, 0.0, 1.0);

    // Edge shadows (away from light)
    float bottomBevel = smoothstep(bevelWidth, 0.0, distBottom) * clamp(lightDir.y, 0.0, 1.0);
    float rightBevel = smoothstep(bevelWidth, 0.0, distRight) * clamp(lightDir.x, 0.0, 1.0);

    // Corner intensity boost
    float cornerTL = smoothstep(bevelWidth * 2.0, 0.0, length(uv));
    float cornerBR = smoothstep(bevelWidth * 2.0, 0.0, length(uv - float2(1.0, 1.0)));

    cornerTL *= clamp(-lightDir.x - lightDir.y, 0.0, 1.0) * 0.5;
    cornerBR *= clamp(lightDir.x + lightDir.y, 0.0, 1.0) * 0.3;

    half3 result = color.rgb;

    // Apply highlights
    float highlight = (topBevel + leftBevel + cornerTL);
    result += highlight * half3(1.15, 1.18, 1.25) * intensity;

    // Apply shadows
    float shadow = (bottomBevel + rightBevel + cornerBR);
    result -= shadow * half3(0.15, 0.12, 0.08) * intensity;

    return half4(result, color.a);
}

// MARK: - Chromatic Glass Distortion
// Subtle RGB split that shifts with tilt - creates premium glass feel

[[stitchable]] half4 chromaticGlass(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float separation   // How much RGB channels separate (0.0 - 1.0)
) {
    float2 uv = position / size;

    // Chromatic offset based on tilt and position
    // Stronger at edges, follows tilt direction
    float2 center = float2(0.5, 0.5);
    float2 fromCenter = uv - center;
    float edgeFactor = length(fromCenter) * 2.0; // 0 at center, 1 at corners
    edgeFactor = pow(edgeFactor, 1.5); // Non-linear falloff

    // Offset direction influenced by tilt
    float2 offsetDir = normalize(fromCenter + tilt * 0.3 + 0.001);
    float offsetAmount = separation * edgeFactor * 3.0; // pixels

    // Sample each channel at slightly different positions
    float2 redOffset = offsetDir * offsetAmount;
    float2 blueOffset = -offsetDir * offsetAmount;

    half4 redSample = layer.sample(position + redOffset);
    half4 greenSample = layer.sample(position);
    half4 blueSample = layer.sample(position + blueOffset);

    half4 result;
    half h_intensity = half(intensity);
    result.r = mix(greenSample.r, redSample.r, h_intensity);
    result.g = greenSample.g;
    result.b = mix(greenSample.b, blueSample.b, h_intensity);
    result.a = greenSample.a;

    // Add subtle brightness boost at center
    float centerGlow = smoothstep(0.7, 0.0, length(fromCenter)) * 0.03 * intensity;
    result.rgb += centerGlow;

    return result;
}

// MARK: - Glass Capsule with Background Blur Simulation
[[stitchable]] half4 glassButton(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float time
) {
    float2 uv = position / size;
    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;

    // Capsule shape
    float2 capsuleSize = float2(1.0, 1.0);
    float dist = sdCapsule(toCenter, capsuleSize);

    half4 originalColor = layer.sample(position);

    // Outside glass
    if (dist > 0.0) {
        // Soft shadow
        float shadowDist = sdCapsule(toCenter - float2(0.02, 0.03), capsuleSize);
        if (shadowDist < 0.08 && shadowDist > 0.0) {
            float shadowStrength = smoothstep(0.08, 0.0, shadowDist);
            originalColor.rgb = mix(originalColor.rgb, half3(0.0), shadowStrength * 0.25);
        }
        return originalColor;
    }

    // Normalized distance inside capsule
    float innerRadius = -0.35;
    float normalizedDist = smoothstep(innerRadius, 0.0, dist);

    // Refraction with parabolic falloff
    float distortion = 1.0 - normalizedDist * normalizedDist;
    float refractionStrength = 0.06;
    float2 offset = toCenter * distortion * refractionStrength;

    // Chromatic aberration
    float chromaticStrength = normalizedDist * 0.02;

    half4 redSample = layer.sample(position + offset * size * (1.0 + chromaticStrength));
    half4 greenSample = layer.sample(position + offset * size);
    half4 blueSample = layer.sample(position + offset * size * (1.0 - chromaticStrength));

    half4 result;
    result.r = redSample.r;
    result.g = greenSample.g;
    result.b = blueSample.b;
    result.a = 1.0;

    // Rim/edge lighting
    float edgeFade = smoothstep(0.02, 0.0, abs(dist));

    // Animated light direction
    float lightAngle = time * 0.3;
    float2 lightDir = normalize(float2(-0.5 + sin(lightAngle) * 0.2, -0.8 + cos(lightAngle) * 0.1));
    float rimBias = dot(normalize(toCenter), lightDir);
    rimBias = clamp(rimBias * 1.5, 0.0, 1.0);

    half3 rimColor = half3(1.3, 1.35, 1.5);
    result.rgb += edgeFade * rimBias * rimColor * 0.6;

    // Secondary rim on opposite side (subtle)
    float rimBias2 = dot(normalize(toCenter), -lightDir);
    rimBias2 = clamp(rimBias2, 0.0, 1.0);
    result.rgb += edgeFade * rimBias2 * half3(0.8, 0.85, 1.0) * 0.2;

    // Glass tint and inner glow
    result.rgb *= half3(0.97, 0.98, 1.02);
    result.rgb += (1.0 - normalizedDist) * 0.03;

    // Specular highlight (top-left)
    float2 specPos = float2(-0.25, -0.3);
    float specDist = length(toCenter - specPos);
    float specular = smoothstep(0.15, 0.0, specDist);
    result.rgb += specular * half3(1.0, 1.0, 1.0) * 0.15;

    return result;
}
