//
//  CosmicAuraShader.metal
//  ShaderKit
//
//  Transparent iridescent aura/nebula overlay for avatar compositing.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
#include "ShaderUtilities.metal"
using namespace metal;

static constant float cosmicTau = 6.28318530718;

static float2 cosmicRotate(float2 p, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

static half3 cosmicPalette(float t) {
    half3 deepBlue = half3(0.10h, 0.22h, 0.95h);
    half3 cyan = half3(0.22h, 0.88h, 1.0h);
    half3 violet = half3(0.56h, 0.28h, 1.0h);
    half3 pink = half3(1.0h, 0.34h, 0.88h);

    float band = fract(t);
    half3 base;
    if (band < 0.28) {
        base = mix(deepBlue, cyan, half(smoothstep(0.0, 1.0, band / 0.28)));
    } else if (band < 0.58) {
        base = mix(cyan, violet, half(smoothstep(0.0, 1.0, (band - 0.28) / 0.30)));
    } else if (band < 0.84) {
        base = mix(violet, pink, half(smoothstep(0.0, 1.0, (band - 0.58) / 0.26)));
    } else {
        base = mix(pink, deepBlue, half(smoothstep(0.0, 1.0, (band - 0.84) / 0.16)));
    }

    half rainbowShift = half(0.12 * sin(t * cosmicTau));
    half hue = half(fract(t + 0.70));
    half3 rainbow = hsv2rgb(hue, 0.40h, 1.0h);
    return mix(base, rainbow, rainbowShift + 0.18h);
}

static float cosmicParticle(float2 polarUV, float phase, float ringMask) {
    float orbit = fract(polarUV.x + sin(phase) * 0.035 + cos(phase * 2.0) * 0.018);
    float shell = polarUV.y;
    float2 gridUV = float2(orbit * 48.0, shell * 8.0);
    float2 cell = floor(gridUV);
    float2 local = fract(gridUV) - 0.5;

    float seed = hash21(cell + float2(13.7, 91.4));
    float active = step(0.72, seed);
    float2 jitter = float2(
        hash21(cell + 31.1),
        hash21(cell + 57.9)
    ) - 0.5;

    float twinkle = pow(max(0.0, sin(phase * 3.0 + seed * cosmicTau)), 6.0);
    float point = smoothstep(0.17, 0.0, length(local - jitter * 0.42));
    float halo = smoothstep(0.42, 0.0, length(local - jitter * 0.42)) * 0.20;

    return (point + halo) * active * twinkle * ringMask;
}

static float cosmicStarField(float2 uv, float phase, float mask) {
    float2 gridUV = uv * 92.0;
    float2 cell = floor(gridUV);
    float2 local = fract(gridUV) - 0.5;

    float seed = hash21(cell + 211.4);
    float active = step(0.90, seed);
    float2 jitter = float2(hash21(cell + 19.2), hash21(cell + 73.8)) - 0.5;
    float twinkle = 0.45 + 0.55 * pow(max(0.0, sin(phase * 2.0 + seed * cosmicTau)), 4.0);
    float point = smoothstep(0.075, 0.0, length(local - jitter * 0.55));
    float halo = smoothstep(0.20, 0.0, length(local - jitter * 0.55)) * 0.10;

    return (point + halo) * active * twinkle * mask;
}

[[stitchable]] half4 cosmicAura(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity,
    float avatarRadius,
    float auraRadius
) {
    float2 viewUV = position / size;
    float minSide = max(min(size.x, size.y), 1.0);
    float2 uv = (position - size * 0.5) / minSide;
    float radius = length(uv);
    float angle = atan2(uv.y, uv.x);

    float phase = fmod(time, 18.0) / 18.0 * cosmicTau;
    float2 loopA = float2(cos(phase), sin(phase));
    float2 loopB = float2(cos(phase * 2.0 + 1.7), sin(phase * 2.0 + 1.7));

    bool fullImageOverlay = avatarRadius <= 0.001;
    float inner = clamp(avatarRadius, 0.05, auraRadius - 0.035);
    float outer = max(auraRadius, inner + 0.08);
    float edgeDistance = min(min(viewUV.x, 1.0 - viewUV.x), min(viewUV.y, 1.0 - viewUV.y));
    float overlayEdgeBand = 1.0;

    float ringMask;
    float normalizedRing;
    if (fullImageOverlay) {
        overlayEdgeBand = smoothstep(0.0, 0.045, edgeDistance) *
                          (1.0 - smoothstep(0.18, 0.34, edgeDistance));
        ringMask = overlayEdgeBand * 0.72;
        normalizedRing = clamp(1.0 - edgeDistance / 0.34, 0.0, 1.0);
    } else {
        float innerFade = smoothstep(inner, inner + 0.030, radius);
        float outerFade = 1.0 - smoothstep(outer - 0.050, outer + 0.035, radius);
        ringMask = clamp(innerFade * outerFade, 0.0, 1.0);
        normalizedRing = clamp((radius - inner) / max(outer - inner, 0.001), 0.0, 1.0);
    }

    float2 swirlUV = cosmicRotate(uv, phase) * (3.2 + normalizedRing * 1.8);
    swirlUV += loopA * 0.72 + tilt * 0.20;

    float nebulaA = fbm(swirlUV + loopB * 0.38, 5);
    float nebulaB = fbm(cosmicRotate(uv, -phase * 2.0) * 5.6 - loopA * 0.42 + 23.4, 4);
    float nebula = smoothstep(0.28, 0.90, nebulaA * 0.62 + nebulaB * 0.38);

    float streakAngle = angle + (nebulaA - 0.5) * 1.55 + tilt.x * 0.55 - tilt.y * 0.35;
    float streaks = pow(max(0.0, sin(streakAngle * 7.0 + phase * 2.0)), 7.0);
    streaks += pow(max(0.0, sin(streakAngle * 11.0 - phase * 3.0 + nebulaB * 2.1)), 9.0) * 0.50;
    streaks *= smoothstep(0.04, 0.48, normalizedRing) * (1.0 - smoothstep(0.86, 1.0, normalizedRing));

    float ribbon = 0.0;
    float stars = 0.0;
    if (fullImageOverlay) {
        float edgeBand = overlayEdgeBand;
        float ovalRadius = 0.435 + 0.026 * sin(angle * 3.0 - phase * 1.35 + nebulaB);
        float ribbonDistance = abs(radius - ovalRadius);
        float ribbonCore = smoothstep(0.030, 0.0, ribbonDistance);
        float ribbonGlow = smoothstep(0.115, 0.0, ribbonDistance) * 0.22;
        float arcMask = 0.30 + 0.70 * smoothstep(-0.30, 0.92, sin(angle * 1.65 + phase * 0.75));
        float cornerLift = smoothstep(0.18, 0.0, length(viewUV - float2(0.12, 0.86))) +
                           smoothstep(0.22, 0.0, length(viewUV - float2(0.90, 0.72))) +
                           smoothstep(0.18, 0.0, length(viewUV - float2(0.86, 0.18)));

        ribbon = (ribbonCore + ribbonGlow) * edgeBand * arcMask * 0.68;
        ribbon += cornerLift * edgeBand * 0.18;

        float starMask = edgeBand * (0.55 + 0.45 * nebula);
        stars = cosmicStarField(viewUV + loopA * 0.035, phase, starMask);
        stars += cosmicStarField(viewUV * 1.35 - loopB * 0.045 + 13.7, phase * 1.7, starMask) * 0.38;
    }

    float2 particleUV = cosmicRotate(uv, -phase);
    float polarAngle = atan2(particleUV.y, particleUV.x) / cosmicTau + 0.5;
    float particles = cosmicParticle(float2(polarAngle, normalizedRing), phase, ringMask);
    float2 particleUV2 = cosmicRotate(uv, phase * 2.0);
    float polarAngle2 = atan2(particleUV2.y, particleUV2.x) / cosmicTau + 0.5;
    particles += cosmicParticle(float2(fract(polarAngle2 + 0.37), normalizedRing * 1.15), phase * 2.0 + 0.6, ringMask) * 0.55;

    float softGlow = pow(1.0 - abs(normalizedRing - 0.42) * 1.9, 2.0);
    softGlow = clamp(softGlow, 0.0, 1.0);

    float glow = ringMask * (
        0.22 * softGlow +
        0.38 * nebula +
        0.34 * streaks +
        0.46 * ribbon
    ) + particles * 0.92 + stars * 0.72;

    float edgeBloom = ringMask * smoothstep(0.0, 0.22, normalizedRing) * (1.0 - smoothstep(0.70, 1.0, normalizedRing));
    edgeBloom += ribbon * 0.62;
    float colorPhase = polarAngle + normalizedRing * 0.45 + 0.08 * sin(phase) + nebulaA * 0.18;
    half3 color = cosmicPalette(colorPhase);
    half3 bloomColor = cosmicPalette(colorPhase + 0.16);
    half3 ribbonColor = cosmicPalette(colorPhase + 0.28);

    half3 rgb = color * half(glow * 1.22) +
                bloomColor * half(edgeBloom * 0.18) +
                ribbonColor * half(ribbon * 0.48) +
                half3(0.82h, 0.86h, 1.0h) * half(stars * 0.34);
    float alpha = clamp((glow * 0.58 + particles * 0.32 + ribbon * 0.28 + stars * 0.22) * intensity, 0.0, 0.72);

    float centerClear = fullImageOverlay ? (0.10 + overlayEdgeBand * 0.90) : smoothstep(inner + 0.020, inner + 0.055, radius);
    alpha *= centerClear;
    rgb *= half(centerClear * intensity);

    return half4(clamp(rgb, half3(0.0h), half3(1.0h)), half(alpha));
}
