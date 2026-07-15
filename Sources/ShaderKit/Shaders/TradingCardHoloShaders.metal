//
//  TradingCardHoloShaders.metal
//  ShaderKit
//
//  Procedural recreations of modern collectible-card foil constructions.
//  The implementation uses no borrowed texture assets: grain, glitter,
//  etched masks, cosmos particles, and geometric foils are synthesized on GPU.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

namespace trading_card_holo {

constant float tau = 6.28318530718;

inline float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

inline float valueNoise(float2 p) {
    float2 cell = floor(p);
    float2 local = fract(p);
    local = local * local * (3.0 - 2.0 * local);
    float a = hash21(cell);
    float b = hash21(cell + float2(1.0, 0.0));
    float c = hash21(cell + float2(0.0, 1.0));
    float d = hash21(cell + float2(1.0, 1.0));
    return mix(mix(a, b, local.x), mix(c, d, local.x), local.y);
}

inline float fbm(float2 p) {
    float sum = 0.0;
    float amplitude = 0.5;
    float2x2 rotation = float2x2(0.80, -0.60, 0.60, 0.80);
    for (int octave = 0; octave < 5; ++octave) {
        sum += valueNoise(p) * amplitude;
        p = rotation * p * 2.03 + 17.7;
        amplitude *= 0.5;
    }
    return sum;
}

inline float2 rotate(float2 p, float angle) {
    float cosine = cos(angle);
    float sine = sin(angle);
    return float2(cosine * p.x - sine * p.y, sine * p.x + cosine * p.y);
}

inline float3 spectrum(float phase) {
    return 0.55 + 0.45 * cos(tau * (phase + float3(0.00, 0.67, 0.33)));
}

inline float3 pastelSpectrum(float phase) {
    return mix(float3(0.74), spectrum(phase), 0.58);
}

inline float luminance(float3 color) {
    return dot(color, float3(0.299, 0.587, 0.114));
}

inline float3 screenBlend(float3 base, float3 blend) {
    return 1.0 - (1.0 - base) * (1.0 - blend);
}

inline float3 overlayBlend(float3 base, float3 blend) {
    float3 low = 2.0 * base * blend;
    float3 high = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
    return mix(low, high, step(float3(0.5), base));
}

inline float3 colorDodge(float3 base, float3 blend) {
    return min(float3(1.0), base / max(float3(0.08), 1.0 - blend));
}

inline float3 applyScreen(float3 source, float3 foil, float amount) {
    float readability = 0.22 + luminance(source) * 0.78;
    return mix(source, screenBlend(source, clamp(foil, 0.0, 1.0)), clamp(amount * readability, 0.0, 1.0));
}

inline float3 applyOverlay(float3 source, float3 foil, float amount) {
    float readability = 0.30 + luminance(source) * 0.70;
    return mix(source, overlayBlend(source, clamp(foil, 0.0, 1.0)), clamp(amount * readability, 0.0, 1.0));
}

inline float3 applyExclusion(float3 source, float3 foil, float amount) {
    float3 excluded = source + foil - 2.0 * source * foil;
    float readability = 0.24 + luminance(source) * 0.76;
    return mix(source, excluded, clamp(amount * readability, 0.0, 1.0));
}

inline float radialGlare(float2 uv, float2 pointer, float radius, float power) {
    float distance = length((uv - pointer) / float2(1.0, 1.15));
    return pow(smoothstep(radius, 0.0, distance), power);
}

inline float etchedLine(float coordinate, float width) {
    float centered = abs(fract(coordinate) - 0.5);
    return 1.0 - smoothstep(width, width + 0.08, centered);
}

inline float glitter(float2 uv, float scale, float2 pointer, float time, float seed) {
    float2 grid = uv * scale;
    float2 cell = floor(grid);
    float2 local = fract(grid) - 0.5;
    float random = hash21(cell + seed);
    float visibility = pow(max(0.0, sin(random * tau + time * (0.7 + random) + dot(pointer, float2(4.1, -3.7)))), 12.0);
    float point = smoothstep(0.12 + random * 0.06, 0.0, length(local));
    float cross = smoothstep(0.035, 0.0, min(abs(local.x), abs(local.y)))
        * smoothstep(0.30, 0.04, max(abs(local.x), abs(local.y)));
    return max(point, cross * 0.72) * visibility;
}

inline float starLayer(float2 uv, float scale, float2 pan, float time, float seed) {
    float2 grid = (uv + pan) * scale;
    float2 cell = floor(grid);
    float2 local = fract(grid) - 0.5;
    float random = hash21(cell + seed);
    float exists = step(0.82, random);
    float radius = mix(0.025, 0.16, hash21(cell + seed + 8.2));
    float core = smoothstep(radius, 0.0, length(local));
    float ray = smoothstep(0.025, 0.0, min(abs(local.x), abs(local.y)))
        * smoothstep(radius * 3.2, 0.0, max(abs(local.x), abs(local.y)));
    float twinkle = 0.55 + 0.45 * sin(time * 0.9 + random * tau);
    return exists * max(core, ray * 0.8) * twinkle;
}

inline float geometricFoil(float2 uv, float2 pan) {
    float2 p = (uv + pan * 0.12) * float2(12.0, 17.0);
    float2 cell = floor(p);
    float2 local = fract(p) - 0.5;
    float diagonalA = 1.0 - smoothstep(0.035, 0.09, abs(local.x + local.y));
    float diagonalB = 1.0 - smoothstep(0.035, 0.09, abs(local.x - local.y));
    float diamond = 1.0 - smoothstep(0.36, 0.48, abs(local.x) + abs(local.y));
    float alternate = step(0.5, hash21(cell));
    return mix(max(diagonalA, diagonalB), diamond, alternate) * 0.75;
}

inline float illusionFoil(float2 uv, float2 pan) {
    float2 p = uv - 0.5 + pan * 0.16;
    float radius = length(p);
    float angle = atan2(p.y, p.x);
    float wave = sin(radius * 84.0 - angle * 5.0 + sin(angle * 3.0) * 1.4);
    float rings = pow(0.5 + 0.5 * wave, 5.0);
    float cells = etchedLine((p.x + p.y) * 27.0, 0.34) * 0.45;
    return max(rings, cells);
}

inline float3 regularHolo(float2 uv, float2 pointer, float2 pan, float distanceFromCenter) {
    float phase = dot(uv + pan * float2(-1.9, -2.5), normalize(float2(-0.34, 0.94))) * 3.4;
    float3 rainbow = spectrum(phase);
    float scanlines = mix(0.28, 1.0, step(0.48, fract(uv.x * 92.0)));
    float barA = pow(0.5 + 0.5 * sin((uv.x + pan.x * 1.1 + pan.y * 0.5) * tau * 3.2), 7.0);
    float barB = pow(0.5 + 0.5 * sin((uv.x - pan.x * 0.8 - pan.y * 0.7) * tau * 5.1 + 1.4), 10.0);
    float glare = radialGlare(uv, pointer, 0.82, 1.8);
    float3 foil = rainbow * (0.18 + scanlines * 0.44);
    foil += float3(0.72, 0.78, 0.84) * (barA * 0.32 + barB * 0.22);
    foil += glare * float3(0.36, 0.42, 0.46);
    foil *= 0.78 + distanceFromCenter * 0.28;
    return foil;
}

inline float3 cosmosHolo(float2 uv, float2 pointer, float2 pan, float time) {
    float starA = starLayer(uv, 13.0, pan * 0.18, time, 2.0);
    float starB = starLayer(uv, 25.0, pan * -0.24, time, 21.0);
    float starC = starLayer(uv, 47.0, pan * 0.34, time, 59.0);
    float phase = dot(uv + pan * 0.8, normalize(float2(0.14, 0.99))) * 2.7;
    float3 rainbow = spectrum(phase);
    float glare = radialGlare(uv, pointer, 0.95, 1.3);
    float nebula = fbm(uv * 4.0 + pan * 0.8);
    float3 foil = rainbow * (0.10 + nebula * 0.22);
    foil += pastelSpectrum(phase + 0.18) * glare * 0.28;
    foil += float3(0.82, 0.91, 1.0) * starA;
    foil += float3(0.70, 0.84, 1.0) * starB * 0.75;
    foil += float3(1.0, 0.86, 0.96) * starC * 0.55;
    return foil;
}

inline float3 reverseHolo(float2 uv, float2 pointer, float2 pan) {
    float radialDistance = length(uv - pointer);
    float alternating = 0.5 + 0.5 * cos(radialDistance * tau * 1.8);
    float diagonal = 0.5 + 0.5 * sin(dot(uv + pan * 1.2, normalize(float2(1.0, -1.0))) * tau * 2.2);
    float texture = fbm(uv * 8.0 + pan * 1.4);
    float foil = abs(alternating - diagonal) * (0.58 + texture * 0.42);
    return mix(float3(0.10, 0.13, 0.18), float3(0.88, 0.94, 1.0), foil);
}

inline float3 radiantHolo(float2 uv, float2 pointer, float2 pan, float time) {
    float lineA = etchedLine(dot(uv + pan * 0.5, normalize(float2(1.0, 1.0))) * 72.0, 0.38);
    float lineB = etchedLine(dot(uv + pan * 0.5, normalize(float2(-1.0, 1.0))) * 72.0, 0.38);
    float lattice = max(lineA, lineB);
    float phase = dot(uv - pan * 1.6, normalize(float2(0.82, 0.57))) * 2.2;
    float glare = radialGlare(uv, pointer * 0.5 + 0.25, 0.95, 1.5);
    float sparkle = glitter(uv, 31.0, pointer, time, 13.0);
    float3 foil = spectrum(phase) * (0.14 + lattice * 0.52);
    foil += float3(0.68, 0.74, 0.80) * glare * 0.25;
    foil += float3(1.0) * sparkle * 0.78;
    return foil;
}

inline float3 amazingRare(float2 uv, float2 pointer, float2 pan, float time) {
    float splash = smoothstep(0.48, 0.72, fbm(uv * 5.2 + float2(4.0, 9.0)));
    float phase = dot(uv - pan * 2.1, normalize(float2(-0.68, 0.74))) * 2.6;
    float sparkleA = glitter(uv, 28.0, pointer, time, 8.0);
    float sparkleB = glitter(uv + 0.013, 44.0, pointer, time, 42.0);
    float silver = radialGlare(uv, pointer, 1.0, 1.1);
    float3 foil = spectrum(phase) * (0.12 + splash * 0.42);
    foil += pastelSpectrum(phase + 0.35) * splash * 0.24;
    foil += float3(0.70, 0.82, 0.80) * silver * 0.22;
    foil += float3(1.0, 0.96, 0.88) * (sparkleA * 0.7 + sparkleB * 0.45);
    return foil;
}

inline float3 sunpillarFoil(
    float2 uv,
    float2 pointer,
    float2 pan,
    float distanceFromCenter,
    float variant
) {
    float phase = uv.y * 1.34 - pan.y * 1.7 + pan.x * 0.32;
    float3 rainbow = spectrum(phase);
    float grain = valueNoise(float2(uv.x * 230.0, uv.y * 360.0));
    float ridgeA = etchedLine(dot(uv + pan * 0.54, normalize(float2(-0.68, 0.74))) * 44.0, 0.40);
    float ridgeB = etchedLine(dot(uv - pan * 0.42, normalize(float2(0.68, 0.74))) * 31.0, 0.44);
    float glare = radialGlare(uv, pointer, 0.82, 1.55);
    float foilMap = illusionFoil(uv, pan);
    float3 foil = rainbow * (0.16 + ridgeA * 0.31 + ridgeB * 0.13);
    foil += float3(0.42, 0.52, 0.62) * (0.12 + grain * 0.18);
    foil += pastelSpectrum(phase + 0.22) * foilMap * (0.10 + variant * 0.12);
    foil += float3(0.86, 0.91, 0.95) * glare * (0.16 + variant * 0.06);
    foil *= 0.76 + distanceFromCenter * 0.20;
    return foil;
}

inline float3 vmaxFoil(float2 uv, float2 pointer, float2 pan, float distanceFromCenter) {
    float field = fbm(uv * 5.0 + pan * 1.3);
    float phase = dot(uv + pan * 1.8, normalize(float2(0.55, -0.84))) * 3.2 + field * 0.32;
    float ridge = etchedLine(dot(uv + pan * 0.8, normalize(float2(-0.68, 0.74))) * 34.0, 0.39);
    float3 rainbow = spectrum(phase);
    float3 radial = pastelSpectrum(atan2(uv.y - pointer.y, uv.x - pointer.x) / tau);
    float glare = radialGlare(uv, pointer, 0.88, 1.4);
    float3 foil = rainbow * (0.14 + field * 0.30 + ridge * 0.24);
    foil += radial * glare * 0.26;
    foil += float3(0.16, 0.24, 0.34) * (1.0 - distanceFromCenter) * 0.20;
    return foil;
}

inline float3 vstarFoil(float2 uv, float2 pointer, float2 pan, float distanceFromCenter) {
    float3 base = sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.35);
    float2 p = uv - 0.5 + pan * 0.12;
    float radius = length(p);
    float angle = atan2(p.y, p.x);
    float glyph = etchedLine(radius * 26.0 + angle * 1.8, 0.40);
    float spokes = etchedLine(angle / tau * 18.0 + radius * 3.0, 0.43);
    float silver = radialGlare(uv, pointer, 0.92, 1.35);
    float3 glyphColor = mix(
        float3(0.47, 0.55, 0.68),
        pastelSpectrum(angle / tau + radius * 0.42),
        0.52
    );
    base += glyphColor * max(glyph, spokes) * 0.38;
    base += float3(0.82, 0.88, 0.96) * silver * 0.23;
    return base;
}

inline float3 rainbowFoil(
    float2 uv,
    float2 pointer,
    float2 pan,
    float time,
    float alternate,
    float pale
) {
    float phaseA = dot(uv + pan * (1.0 + alternate), normalize(float2(0.72, -0.69))) * (2.0 + alternate);
    float phaseB = dot(uv - pan * (1.2 + alternate), normalize(float2(0.50, -0.86))) * 2.6 + 0.22;
    float3 rainbowA = spectrum(phaseA);
    float3 rainbowB = spectrum(phaseB);
    float sparkleA = glitter(uv, 33.0, pointer, time, 11.0);
    float sparkleB = glitter(uv + 0.017, 49.0, pointer, time, 71.0);
    float texture = illusionFoil(uv, pan);
    float stripe = etchedLine(dot(uv + pan, normalize(float2(-0.68, 0.74))) * (18.0 + alternate * 12.0), 0.36);
    float glare = radialGlare(uv, pointer, 0.90, 1.45);
    float3 foil = mix(rainbowA, rainbowB, 0.44 + stripe * 0.26);
    foil = mix(foil, pastelSpectrum(phaseA), pale * 0.45);
    foil *= 0.22 + texture * 0.25 + stripe * alternate * 0.24;
    foil += float3(1.0) * (sparkleA * 0.58 + sparkleB * 0.36);
    foil += pastelSpectrum(phaseB + 0.2) * glare * 0.19;
    return foil;
}

inline float3 goldFoil(float2 uv, float2 pointer, float2 pan, float time, float blackAmount) {
    float geometry = geometricFoil(uv, pan);
    float phase = atan2(uv.y - 0.5 - pan.y * 0.2, uv.x - 0.5 - pan.x * 0.2) / tau;
    float conic = 0.5 + 0.5 * sin(phase * tau * 4.0 + length(uv - pointer) * 5.0);
    float sparkleA = glitter(uv, 31.0, pointer, time, 5.0);
    float sparkleB = glitter(uv + 0.021, 51.0, pointer, time, 29.0);
    float glare = radialGlare(uv, pointer, 0.90, 1.4);
    float3 darkGold = mix(float3(0.12, 0.075, 0.02), float3(0.38, 0.25, 0.055), 1.0 - blackAmount);
    float3 brightGold = float3(1.0, 0.73, 0.18);
    float3 foil = mix(darkGold, brightGold, geometry * 0.55 + conic * 0.22 + glare * 0.20);
    foil += float3(1.0, 0.86, 0.42) * (sparkleA * 0.75 + sparkleB * 0.42);
    return foil;
}

inline float3 shinyVmaxFoil(float2 uv, float2 pointer, float2 pan, float time) {
    float phase = dot(uv + pan * 1.5, normalize(float2(0.50, -0.86))) * 3.1;
    float3 mutedRainbow = mix(float3(0.55, 0.60, 0.67), spectrum(phase), 0.62);
    float sparkleA = glitter(uv, 29.0, pointer, time, 16.0);
    float sparkleB = glitter(uv + 0.015, 47.0, pointer, time, 63.0);
    float silver = radialGlare(uv, pointer, 0.94, 1.2);
    float foilTexture = fbm(uv * 6.0 + pan * 0.7);
    float etched = etchedLine(dot(uv + pan * 0.65, normalize(float2(-0.68, 0.74))) * 38.0, 0.40);
    float3 foil = mutedRainbow * (0.24 + foilTexture * 0.36 + etched * 0.17);
    foil += float3(0.72, 0.82, 0.94) * silver * 0.30;
    foil += float3(1.0) * (sparkleA * 0.82 + sparkleB * 0.55);
    return foil;
}

inline float3 trainerGalleryHolo(float2 uv, float2 pointer, float2 pan) {
    float phase = dot(uv + pan * float2(0.0, 1.6), normalize(float2(0.93, -0.37))) * 2.0;
    float3 rainbow = pastelSpectrum(phase);
    float ellipse = radialGlare(uv, pointer * 0.5 + 0.25, 1.25, 1.1);
    float3 foil = rainbow * 0.34;
    foil += mix(float3(0.12, 0.02, 0.16), float3(0.90), ellipse) * 0.24;
    return foil;
}

} // namespace trading_card_holo

[[stitchable]] half4 tradingCardHolo(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float2 pointerInput,
    float time,
    float intensity,
    float styleIndex
) {
    half4 sampled = layer.sample(position);
    if (sampled.a < 0.01h) { return sampled; }

    float2 uv = position / max(size, float2(1.0));
    float2 fallbackPointer = clamp(float2(0.5) + tilt * 0.5, 0.0, 1.0);
    float pointerIsValid = step(0.0, pointerInput.x) * step(0.0, pointerInput.y);
    float2 pointer = mix(fallbackPointer, clamp(pointerInput, 0.0, 1.0), pointerIsValid);
    float2 pan = pointer - 0.5;
    float distanceFromCenter = clamp(length(pan) * 1.41421356, 0.0, 1.0);
    float3 source = float3(sampled.rgb);
    float3 foil = float3(0.0);
    float3 result = source;
    float amount = clamp(intensity, 0.0, 1.0);
    int style = int(styleIndex + 0.5);

    switch (style) {
        case 0: // Regular Holo
            foil = trading_card_holo::regularHolo(uv, pointer, pan, distanceFromCenter);
            result = trading_card_holo::applyScreen(source, foil, amount * 0.84);
            break;
        case 1: // Cosmos Holo
            foil = trading_card_holo::cosmosHolo(uv, pointer, pan, time);
            result = trading_card_holo::applyScreen(source, foil, amount * 0.90);
            break;
        case 2: // Reverse Holo
            foil = trading_card_holo::reverseHolo(uv, pointer, pan);
            result = trading_card_holo::applyOverlay(source, foil, amount * (0.72 + distanceFromCenter * 0.18));
            break;
        case 3: // Radiant Holo
            foil = trading_card_holo::radiantHolo(uv, pointer, pan, time);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.78);
            result = trading_card_holo::applyScreen(result, foil, amount * 0.18);
            break;
        case 4: // Amazing Rare
            foil = trading_card_holo::amazingRare(uv, pointer, pan, time);
            result = trading_card_holo::applyScreen(source, foil, amount * 0.88);
            break;
        case 5: // V Regular
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.0);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.83);
            break;
        case 6: // VMAX
            foil = trading_card_holo::vmaxFoil(uv, pointer, pan, distanceFromCenter);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.80);
            break;
        case 7: // VSTAR
            foil = trading_card_holo::vstarFoil(uv, pointer, pan, distanceFromCenter);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.82);
            result = trading_card_holo::applyScreen(result, foil, amount * 0.12);
            break;
        case 8: // V Full Art
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 1.0);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.86);
            break;
        case 9: // Rainbow Rare
            foil = trading_card_holo::rainbowFoil(uv, pointer, pan, time, 0.0, 0.0);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.88);
            break;
        case 10: // Rainbow Alternate
            foil = trading_card_holo::rainbowFoil(uv, pointer, pan, time, 1.0, 0.0);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.90);
            break;
        case 11: // Secret Rare Gold
            foil = trading_card_holo::goldFoil(uv, pointer, pan, time, 0.0);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.92);
            break;
        case 12: // Shiny Rare
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.68);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.78);
            break;
        case 13: // Shiny V
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.86);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.86);
            result = trading_card_holo::applyScreen(result, foil, amount * 0.14);
            result *= 0.96 + trading_card_holo::radialGlare(uv, pointer, 0.82, 1.4) * 0.07;
            break;
        case 14: // Shiny VMAX
            foil = trading_card_holo::shinyVmaxFoil(uv, pointer, pan, time);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.84);
            result = trading_card_holo::applyScreen(result, foil, amount * 0.20);
            break;
        case 15: // Trainer Full Art
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.52);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.74);
            break;
        case 16: // Trainer Gallery Holo
            foil = trading_card_holo::trainerGalleryHolo(uv, pointer, pan);
            result = trading_card_holo::applyOverlay(source, foil, amount * 0.78);
            break;
        case 17: // Trainer Gallery Secret Rare
            foil = trading_card_holo::goldFoil(uv, pointer, pan, time, 0.72);
            result = trading_card_holo::applyScreen(source, foil, amount * 0.90);
            break;
        case 18: // Trainer Gallery V
            foil = trading_card_holo::sunpillarFoil(uv, pointer, pan, distanceFromCenter, 0.76);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.76);
            break;
        case 19: // Trainer Gallery VMAX
            foil = trading_card_holo::rainbowFoil(uv, pointer, pan, time, 1.0, 0.42);
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.84);
            break;
        default: // Pikachu Secret Rare
            foil = trading_card_holo::rainbowFoil(uv, pointer, pan, time, 0.0, 0.18);
            foil += float3(0.38, 0.22, 0.04) * 0.16;
            result = trading_card_holo::applyExclusion(source, foil, amount * 0.92);
            break;
    }

    return half4(half3(clamp(result, 0.0, 1.0)), sampled.a);
}
