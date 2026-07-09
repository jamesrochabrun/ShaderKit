//
//  EtchedFoilShader.metal
//  ShaderKit
//
//  Etched textured foil: fine diagonal engraved lines carrying two
//  counter-panned sunpillar rainbows whose interference shifts with tilt.
//  The signature treatment of textured full-art trading cards.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

namespace etchedfoil {

// Six-hue holographic ramp (the classic sunpillar colors).
inline half3 sunpillar(float t) {
    const half3 c0 = half3(1.00h, 0.48h, 0.44h);   // warm red
    const half3 c1 = half3(1.00h, 0.95h, 0.42h);   // yellow
    const half3 c2 = half3(0.58h, 1.00h, 0.44h);   // green
    const half3 c3 = half3(0.52h, 1.00h, 0.93h);   // aqua
    const half3 c4 = half3(0.50h, 0.64h, 1.00h);   // blue
    const half3 c5 = half3(0.86h, 0.48h, 1.00h);   // violet

    float scaled = fract(t) * 6.0;
    int index = int(floor(scaled));
    half blend = half(fract(scaled));

    switch (index) {
        case 0: return mix(c0, c1, blend);
        case 1: return mix(c1, c2, blend);
        case 2: return mix(c2, c3, blend);
        case 3: return mix(c3, c4, blend);
        case 4: return mix(c4, c5, blend);
        default: return mix(c5, c0, blend);
    }
}

} // namespace etchedfoil

[[stitchable]] half4 etchedFoil(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float density
) {
    float2 uv = position / size;
    half4 originalColor = layer.sample(position);

    if (originalColor.a < 0.01h) {
        return originalColor;
    }

    // Fine engraved lines at 133°, swept by tilt.
    float angle = 133.0 * 3.14159 / 180.0;
    float2 lineDir = float2(cos(angle), sin(angle));
    float etchCoord = dot(uv, lineDir) * density
        + tilt.x * 7.0 + tilt.y * 2.0 + time * 0.18;
    float etchPhase = fract(etchCoord);
    float etchLine = smoothstep(0.38, 0.5, etchPhase) * smoothstep(0.62, 0.5, etchPhase);

    // A second, coarser engraving running the opposite diagonal keeps
    // the texture from reading as simple stripes.
    float crossCoord = dot(uv, float2(-lineDir.y, lineDir.x)) * density * 0.31
        - tilt.x * 3.0 + 0.5;
    float crossPhase = fract(crossCoord);
    float crossLine = smoothstep(0.30, 0.5, crossPhase) * smoothstep(0.70, 0.5, crossPhase);

    // Two sunpillar rainbows panned against each other by tilt; their
    // interference is what makes the foil "roll" as the card moves.
    float pan = tilt.x * 0.8 + tilt.y * 0.35;
    float pillarA = uv.y * 1.3 + uv.x * 0.25 - pan + time * 0.02;
    float pillarB = uv.y * 1.3 - uv.x * 0.25 + pan + 0.37;
    half3 rainbowA = etchedfoil::sunpillar(pillarA);
    half3 rainbowB = etchedfoil::sunpillar(pillarB);
    half3 interference = abs(rainbowA - rainbowB);

    // Etched lines carry most of the shine; art luminance modulates it
    // so the foil reads as part of the illustration.
    half luminance = dot(originalColor.rgb, half3(0.299h, 0.587h, 0.114h));
    half3 foil = rainbowA * 0.30h + interference * 0.55h;
    foil *= half(0.30 + 0.70 * etchLine) * half(0.55 + 0.45 * crossLine);
    foil *= 0.45h + 0.65h * luminance;

    // Tilt-following hotspot lifts the engraving nearest the light.
    float2 lightPos = float2(0.5 + tilt.x * 0.5, 0.5 + tilt.y * 0.5);
    float glow = smoothstep(0.85, 0.0, length(uv - lightPos));
    glow = pow(glow, 2.0);
    foil += half3(1.0h, 0.98h, 0.94h) * half(glow * etchLine * 0.4);

    half3 result = blendColorDodge(originalColor.rgb, foil * half(intensity));

    // Gentle saturation lift so the rainbow stays vivid over art.
    half resultLuminance = dot(result, half3(0.299h, 0.587h, 0.114h));
    result = mix(half3(resultLuminance), result, 1.18h);

    return half4(clamp(result, half3(0.0h), half3(1.0h)), originalColor.a);
}
