//
//  LiquidTechView.swift
//  ShaderKitDemo
//
//  Liquid Tech [234] shader demo
//

import SwiftUI
import ShaderKit

struct LiquidTechView: View {
  @State private var intensity = 0.9
  @State private var speed = 1.0
  @State private var scale = 1.0

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: 16) {
        HolographicCardContainer(
          width: 280,
          height: 400,
          shadowColor: .blue
        ) {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.05, green: 0.08, blue: 0.12),
                  Color(red: 0.08, green: 0.12, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .liquidTech(
              intensity: intensity,
              speed: speed,
              scale: scale
            )
        }

        ScrollView {
          VStack(spacing: 12) {
            SliderRow(title: "intensity", value: $intensity, range: 0...1)
            SliderRow(title: "speed", value: $speed, range: 0...2.5)
            SliderRow(title: "scale", value: $scale, range: 0.4...2.0)
          }
          .padding(16)
          .background(Color.white.opacity(0.08))
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .padding(.horizontal, 16)
        }
      }
      .padding(.top, 16)
    }
    .navigationTitle("Liquid Tech [234]")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

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
    LiquidTechView()
  }
}
