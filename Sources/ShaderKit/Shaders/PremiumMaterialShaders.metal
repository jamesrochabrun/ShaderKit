//
//  PremiumMaterialShaders.metal
//  ShaderKit
//
//  Opaque, light-reactive surface treatments for collectible cards.
//  Each material keeps the source layer's luminance and contrast so card
//  artwork and typography remain readable through the metallic coating.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

namespace premium_material {

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
    float value = 0.0;
    float amplitude = 0.5;
    float2x2 rotation = float2x2(0.80, -0.60, 0.60, 0.80);
    for (int octave = 0; octave < 5; ++octave) {
        value += valueNoise(p) * amplitude;
        p = rotation * p * 2.03 + 19.1;
        amplitude *= 0.5;
    }
    return value;
}

inline float2 rotate(float2 p, float angle) {
    float cosine = cos(angle);
    float sine = sin(angle);
    return float2(cosine * p.x - sine * p.y, sine * p.x + cosine * p.y);
}

inline float3 spectrum(float phase) {
    return 0.56 + 0.44 * cos(tau * (phase + float3(0.00, 0.67, 0.33)));
}

inline float luminance(half3 color) {
    return dot(float3(color), float3(0.299, 0.587, 0.114));
}

inline half3 coat(half3 source, float3 material, float intensity) {
    float sourceLuminance = luminance(source);
    float3 coated = material * (0.36 + sourceLuminance * 0.82)
        + float3(source) * 0.26;
    return half3(mix(float3(source), coated, clamp(intensity, 0.0, 1.0)));
}

inline float softSpot(float2 uv, float2 tilt, float radius) {
    float2 lightPosition = float2(0.5) + clamp(tilt, -1.5, 1.5) * float2(0.28, 0.22);
    return pow(smoothstep(radius, 0.0, length(uv - lightPosition)), 2.2);
}

inline float edgeFresnel(float2 uv) {
    float2 edgeDistance = min(uv, 1.0 - uv);
    float nearestEdge = min(edgeDistance.x, edgeDistance.y);
    return 1.0 - smoothstep(0.0, 0.16, nearestEdge);
}

} // namespace premium_material

[[stitchable]] half4 brushedTitanium(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float travel = tilt.x * 0.42 - tilt.y * 0.18 + time * 0.015;
    float broad = 0.5 + 0.5 * sin((uv.x * 1.65 + travel) * premium_material::tau);
    broad = pow(broad, 1.7);
    float brush = premium_material::valueNoise(float2(uv.x * 16.0, uv.y * 420.0));
    float hairline = sin(uv.y * 1100.0 + brush * 4.0) * 0.5 + 0.5;
    float highlight = premium_material::softSpot(uv, tilt, 0.68);

    float silver = 0.46 + broad * 0.34 + (brush - 0.5) * 0.12 + hairline * 0.035;
    float3 material = float3(0.82, 0.86, 0.91) * silver;
    material += float3(0.20, 0.27, 0.34) * (1.0 - broad) * 0.18;
    material += highlight * float3(0.26, 0.29, 0.33);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 blackChrome(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float diagonal = dot(uv, normalize(float2(0.72, 1.0)))
        + tilt.x * 0.34 - tilt.y * 0.24 + time * 0.012;
    float reflection = pow(0.5 + 0.5 * sin(diagonal * premium_material::tau * 1.7), 7.0);
    float secondary = pow(0.5 + 0.5 * sin(diagonal * premium_material::tau * 3.4 + 1.3), 18.0);
    float edge = premium_material::edgeFresnel(uv);
    float spectralPhase = diagonal * 0.62 + edge * 0.20;

    float3 material = float3(0.012, 0.016, 0.024);
    material += reflection * float3(0.66, 0.72, 0.82);
    material += secondary * float3(0.92, 0.96, 1.0) * 0.38;
    material += premium_material::spectrum(spectralPhase) * edge * 0.22;
    material += premium_material::softSpot(uv, tilt, 0.52) * float3(0.08, 0.10, 0.14);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 roseGold(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float grain = premium_material::valueNoise(float2(uv.x * 36.0, uv.y * 360.0));
    float sweepCoordinate = uv.x + uv.y * 0.28 + tilt.x * 0.46 - tilt.y * 0.18 + time * 0.012;
    float sweep = pow(0.5 + 0.5 * cos(sweepCoordinate * premium_material::tau), 8.0);
    float warmShadow = smoothstep(0.0, 1.0, uv.y + tilt.y * 0.25);

    float3 rose = mix(float3(0.48, 0.16, 0.12), float3(1.00, 0.72, 0.60), 0.48 + grain * 0.18);
    float3 material = rose * (0.70 + warmShadow * 0.18);
    material += sweep * float3(1.00, 0.88, 0.78) * 0.54;
    material += premium_material::softSpot(uv, tilt, 0.58) * float3(0.30, 0.18, 0.16);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 liquidMercury(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float2 p = uv * 3.4 + tilt * 0.38;
    float warpA = premium_material::fbm(p + float2(time * 0.08, -time * 0.05));
    float warpB = premium_material::fbm(p * 1.8 + float2(warpA * 2.2, -warpA * 1.7));
    float contour = 0.5 + 0.5 * sin((warpA * 1.7 + warpB + uv.y * 0.55) * premium_material::tau * 2.0);
    float mirror = pow(contour, 5.0);
    float darkFold = pow(1.0 - contour, 3.0);
    float spot = premium_material::softSpot(uv, tilt, 0.66);

    float3 material = mix(float3(0.11, 0.14, 0.18), float3(0.70, 0.77, 0.84), contour);
    material += mirror * float3(0.34, 0.39, 0.46);
    material -= darkFold * float3(0.12, 0.13, 0.15);
    material += spot * float3(0.11, 0.14, 0.18);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 anodizedTitanium(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float field = premium_material::fbm(uv * 3.2 + tilt * 0.42);
    float phase = uv.x * 0.72 - uv.y * 0.42 + field * 0.54
        + tilt.x * 0.30 + tilt.y * 0.22 + time * 0.018;
    float3 oxide = premium_material::spectrum(phase);
    float micrograin = premium_material::valueNoise(float2(uv.x * 120.0, uv.y * 330.0));
    float sweep = pow(0.5 + 0.5 * sin((phase + uv.y) * premium_material::tau), 8.0);

    float3 titanium = float3(0.28, 0.31, 0.38) * (0.76 + micrograin * 0.16);
    float3 material = mix(titanium, oxide, 0.54);
    material += sweep * (oxide + 0.24) * 0.26;
    material += premium_material::softSpot(uv, tilt, 0.64) * 0.16;

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 damascusSteel(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float2 p = premium_material::rotate((uv - 0.5) * float2(1.0, 1.35), -0.22);
    float warp = premium_material::fbm(p * 4.2 + tilt * 0.22 + time * 0.008);
    float strataCoordinate = (p.x + warp * 0.34 + sin(p.y * 13.0) * 0.025) * 52.0;
    float strata = 0.5 + 0.5 * sin(strataCoordinate);
    float brightEdge = pow(1.0 - abs(strata * 2.0 - 1.0), 7.0);
    float broad = 0.5 + 0.5 * sin((p.y + tilt.y * 0.20) * premium_material::tau * 1.4);

    float3 darkSteel = float3(0.11, 0.14, 0.18);
    float3 lightSteel = float3(0.68, 0.74, 0.80);
    float3 material = mix(darkSteel, lightSteel, 0.20 + strata * 0.62);
    material += brightEdge * float3(0.46, 0.50, 0.56);
    material *= 0.80 + broad * 0.24;
    material += premium_material::softSpot(uv, tilt, 0.62) * 0.14;

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 forgedCarbon(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float2 grid = uv * float2(19.0, 27.0);
    float2 cell = floor(grid);
    float2 local = fract(grid) - 0.5;
    float random = premium_material::hash21(cell);
    float angle = random * premium_material::tau + sin(cell.x * 1.7) * 0.35;
    float2 fiber = premium_material::rotate(local, angle);
    float chip = smoothstep(0.48, 0.30, abs(fiber.x))
        * smoothstep(0.18 + random * 0.09, 0.08, abs(fiber.y));
    float fiberLight = pow(max(0.0, cos(angle - atan2(tilt.y + 0.2, tilt.x + 0.25))), 6.0);
    float matrixNoise = premium_material::valueNoise(uv * 90.0);
    float travel = 0.5 + 0.5 * sin((uv.x + uv.y * 0.5 + tilt.x * 0.28 + time * 0.01) * premium_material::tau);

    float3 material = float3(0.018, 0.024, 0.032) * (0.75 + matrixNoise * 0.35);
    material += chip * float3(0.15, 0.18, 0.22) * (0.42 + random * 0.70);
    material += chip * fiberLight * float3(0.74, 0.82, 0.90) * (0.28 + travel * 0.34);
    material += premium_material::softSpot(uv, tilt, 0.56) * float3(0.045, 0.055, 0.07);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 copperPatina(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float corrosion = premium_material::fbm(uv * 5.4 + float2(1.7, 8.2));
    corrosion += premium_material::fbm(uv * 14.0 - 5.0) * 0.28;
    float patinaMask = smoothstep(0.56, 0.78, corrosion);
    float boundary = smoothstep(0.50, 0.60, corrosion) - smoothstep(0.66, 0.76, corrosion);
    float brushed = premium_material::valueNoise(float2(uv.x * 40.0, uv.y * 310.0));
    float sweep = pow(0.5 + 0.5 * sin((uv.x + uv.y * 0.24 + tilt.x * 0.40 + time * 0.01) * premium_material::tau), 9.0);

    float3 copper = float3(0.62, 0.23, 0.08) * (0.78 + brushed * 0.28);
    copper += sweep * float3(0.95, 0.57, 0.27) * 0.46;
    float3 verdigris = mix(float3(0.035, 0.20, 0.18), float3(0.12, 0.58, 0.49), corrosion);
    float3 material = mix(copper, verdigris, patinaMask * 0.90);
    material += boundary * float3(0.22, 0.76, 0.61) * 0.20;

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 pearlCeramic(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float2 p = uv - 0.5;
    float curve = dot(p, p) * 1.3;
    float phase = curve + dot(p, tilt * 0.75) + time * 0.012;
    float3 pearl = premium_material::spectrum(phase + 0.08);
    pearl = mix(float3(0.82, 0.84, 0.82), pearl, 0.25);
    float softLight = premium_material::softSpot(uv, tilt, 0.72);
    float glaze = pow(0.5 + 0.5 * cos((uv.x - uv.y * 0.32 + tilt.x * 0.35) * premium_material::tau), 14.0);
    float pores = premium_material::valueNoise(uv * 160.0) - 0.5;

    float3 material = pearl * (0.70 + pores * 0.045);
    material += softLight * float3(0.18, 0.19, 0.21);
    material += glaze * float3(0.36, 0.40, 0.46) * 0.22;

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}

[[stitchable]] half4 oilSlick(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 tilt,
    float time,
    float intensity
) {
    half4 source = layer.sample(position);
    if (source.a < 0.01h) { return source; }

    float2 uv = position / max(size, float2(1.0));
    float fieldA = premium_material::fbm(uv * 3.8 + tilt * 0.32 + float2(time * 0.025, 0.0));
    float fieldB = premium_material::fbm(uv * 8.0 + float2(fieldA * 2.0, -fieldA * 1.5));
    float phase = fieldA * 1.3 + fieldB * 0.72 + uv.x * 0.28 - uv.y * 0.18
        + tilt.x * 0.30 - tilt.y * 0.16;
    float3 interference = premium_material::spectrum(phase * 1.7);
    float band = pow(0.5 + 0.5 * sin(phase * premium_material::tau * 2.3), 4.0);
    float shadow = smoothstep(0.18, 0.72, fieldB);
    float edge = premium_material::edgeFresnel(uv);

    float3 material = float3(0.018, 0.022, 0.035) * (0.75 + shadow * 0.40);
    material += interference * (0.24 + band * 0.58);
    material += edge * premium_material::spectrum(phase + 0.22) * 0.22;
    material += premium_material::softSpot(uv, tilt, 0.54) * float3(0.12, 0.15, 0.22);

    return half4(clamp(premium_material::coat(source.rgb, material, intensity), 0.0h, 1.0h), source.a);
}
