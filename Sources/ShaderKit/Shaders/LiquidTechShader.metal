//
//  LiquidTechShader.metal
//  ShaderKit
//
//  Liquid Tech [234] shader (Twigl GLSL inspired)
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float2x2 rotate2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return float2x2(c, -s, s, c);
}

[[stitchable]] half4 liquidTech(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float intensity,
  float speed,
  float scale
) {
  float2 r = size;
  float t = time * speed;

  float2 uv = (position * 2.0 - r) / r.y;
  uv *= scale;
  uv += tilt * 0.12;

  float d = 0.0;
  float s = 0.0;
  float4 o = float4(0.0);

  float2x2 rot = rotate2D(t * 0.5);

  for (int i = 0; i < 100; i++) {
    float fi = float(i);
    float2 v = rot * (uv * d);
    float3 p = float3(v.x, v.y, d - 8.0);

    float2 xz = rot * p.xz;
    p.x = xz.x;
    p.z = xz.y;

    float dp = dot(p.yzx, p) / 0.7;
    float m = max(sin(dp), length(p) - 4.0);
    s = 0.012 + 0.08 * abs(m - fi / 100.0);
    d += s;

    float4 wave = 1.3 * sin(float4(3.0, 2.0, 1.0, 1.0) + fi * 0.3) / s;
    float lenPP = length(p * p);
    o += max(wave, float4(-lenPP));
  }

  o = tanh(o * o / 800000.0);
  float3 effect = o.rgb;

  half4 sampled = layer.sample(position);
  half3 blended = mix(sampled.rgb, min(sampled.rgb + half3(effect), half3(1.0)), half(intensity));

  return half4(blended, sampled.a);
}
