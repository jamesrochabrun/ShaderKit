//
//  WaterCausticView.swift
//  ShaderKitDemo
//
//  Water caustic shader demo with realistic light refraction
//

import SwiftUI
import ShaderKit

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct WaterCausticView: View {
  @State private var colorBack = Color(red: 0.56, green: 0.56, blue: 0.56)
  @State private var colorHighlight = Color.white
  @State private var highlights = 0.12
  @State private var layering = 0.35
  @State private var edges = 0.55
  @State private var waves = 0.7
  @State private var caustic = 0.2
  @State private var speed = 0.8
  @State private var scale = 0.9

  private enum Preset {
    case `default`, slowMo, abstract, streaming
  }

  private func applyPreset(_ preset: Preset) {
    withAnimation(.easeInOut(duration: 0.3)) {
      switch preset {
      case .default:
        colorBack = Color(red: 0.56, green: 0.56, blue: 0.56)
        colorHighlight = .white
        highlights = 0.12
        layering = 0.35
        edges = 0.55
        waves = 0.7
        caustic = 0.2
        speed = 0.8
        scale = 0.9
      case .slowMo:
        colorBack = Color(red: 0.4, green: 0.5, blue: 0.6)
        colorHighlight = .white
        highlights = 0.08
        layering = 0.2
        edges = 0.3
        waves = 0.4
        caustic = 0.15
        speed = 0.2
        scale = 0.95
      case .abstract:
        colorBack = Color(red: 0.3, green: 0.2, blue: 0.5)
        colorHighlight = Color(red: 1.0, green: 0.8, blue: 0.9)
        highlights = 0.25
        layering = 0.8
        edges = 0.9
        waves = 1.2
        caustic = 0.6
        speed = 1.0
        scale = 0.7
      case .streaming:
        colorBack = Color(red: 0.2, green: 0.3, blue: 0.4)
        colorHighlight = .white
        highlights = 0.15
        layering = 0.5
        edges = 0.4
        waves = 1.0
        caustic = 0.3
        speed = 1.5
        scale = 0.85
      }
    }
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: 16) {
        HolographicCardContainer(
          width: 280,
          height: 400,
          shadowColor: .cyan
        ) {
          Image("fish")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .waterCaustic(
              colorBack: colorBack.simdRGBA,
              colorHighlight: colorHighlight.simdRGBA,
              highlights: highlights,
              layering: layering,
              edges: edges,
              waves: waves,
              caustic: caustic,
              speed: speed,
              scale: scale
            )
        }

        ScrollView {
          VStack(spacing: 12) {
            HStack {
              Text("Presets")
                .font(.headline)
              Spacer()
            }

            HStack(spacing: 12) {
              Button("Default") {
                applyPreset(.default)
              }
              .buttonStyle(.bordered)
              Button("Slow-mo") {
                applyPreset(.slowMo)
              }
              .buttonStyle(.bordered)
              Button("Abstract") {
                applyPreset(.abstract)
              }
              .buttonStyle(.bordered)
              Button("Streaming") {
                applyPreset(.streaming)
              }
              .buttonStyle(.bordered)
            }

            Divider().opacity(0.4)

            HStack {
              Text("colorBack")
              Spacer()
              ColorPicker("", selection: $colorBack, supportsOpacity: true)
                .labelsHidden()
            }

            HStack {
              Text("colorHighlight")
              Spacer()
              ColorPicker("", selection: $colorHighlight, supportsOpacity: true)
                .labelsHidden()
            }

            SliderRow(title: "highlights", value: $highlights, range: 0...0.3)
            SliderRow(title: "layering", value: $layering, range: 0...1)
            SliderRow(title: "edges", value: $edges, range: 0...1)
            SliderRow(title: "waves", value: $waves, range: 0...1.5)
            SliderRow(title: "caustic", value: $caustic, range: 0...1)
            SliderRow(title: "speed", value: $speed, range: 0...3.0)
            SliderRow(title: "scale", value: $scale, range: 0.4...1.2)
          }
          .padding(16)
          .background(Color.white.opacity(0.08))
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .padding(.horizontal, 16)
        }
      }
      .padding(.top, 16)
    }
    .navigationTitle("Water Caustic")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#if os(iOS) || os(tvOS) || os(visionOS)
private extension Color {
  var simdRGBA: SIMD4<Float> {
    let ui = UIColor(self)
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    ui.getRed(&r, green: &g, blue: &b, alpha: &a)
    return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
  }
}
#elseif os(macOS)
private extension Color {
  var simdRGBA: SIMD4<Float> {
    guard let rgb = NSColor(self).usingColorSpace(.deviceRGB) else {
      return SIMD4<Float>(1, 1, 1, 1)
    }
    return SIMD4<Float>(Float(rgb.redComponent), Float(rgb.greenComponent), Float(rgb.blueComponent), Float(rgb.alphaComponent))
  }
}
#endif

private struct SliderRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>

  var body: some View {
    HStack(spacing: 12) {
      Text(title)
        .frame(width: 90, alignment: .leading)
      Slider(value: $value, in: range)
      Text(String(format: "%.2f", value))
        .monospacedDigit()
        .frame(width: 52, alignment: .trailing)
    }
  }
}

#Preview {
  NavigationStack {
    WaterCausticView()
  }
}
