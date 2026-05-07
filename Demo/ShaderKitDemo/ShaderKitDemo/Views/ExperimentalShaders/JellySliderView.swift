//
//  JellySliderView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly slider demo using ShaderKitUI component.
//

import ShaderKitUI
import SwiftUI

struct JellySliderView: View {
  @State private var value = 1.0
  @State private var darkMode = false
  @State private var soundEnabled = false

  @State private var jellyHue: Double = 0.06
  @State private var jellySaturation: Double = 0.92
  @State private var jellyBrightness: Double = 0.95

  private var jellyColor: Color {
    Color(hue: jellyHue, saturation: jellySaturation, brightness: jellyBrightness)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 18) {
        JellySlider(
          value: $value,
          jellyColor: jellyColor,
          darkMode: darkMode,
          soundEnabled: soundEnabled
        )
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 640)

        controlsPanel
          .frame(maxWidth: 640)
      }
      .padding()
    }
    .background(Color(red: 0.95, green: 0.94, blue: 0.99))
    .navigationTitle("Jelly Slider")
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    #endif
    .onChange(of: darkMode) { _, isDark in
      withAnimation(.easeInOut(duration: 0.4)) {
        jellyBrightness = isDark ? 1.0 : 0.95
      }
    }
  }

  private var controlsPanel: some View {
    VStack(alignment: .leading, spacing: 18) {
      Text("Example controls")
        .font(.title2.weight(.semibold))
        .foregroundStyle(.black)

      Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 14) {
        GridRow {
          Text("Mode")
          modeControls
        }

        GridRow {
          Text("Jelly Color")
          VStack(spacing: 8) {
            JellySliderColorSlider(value: $jellyHue)
            JellySliderColorSlider(value: $jellySaturation)
            JellySliderColorSlider(value: $jellyBrightness)
          }
        }
      }
      .font(.body)
      .foregroundStyle(.black)
    }
    .padding(24)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var modeControls: some View {
    HStack(spacing: 10) {
      Button {
        darkMode.toggle()
      } label: {
        Image(systemName: darkMode ? "moon.fill" : "sun.max.fill")
          .font(.title3)
          .foregroundStyle(darkMode ? .yellow : .orange)
          .frame(width: 40, height: 40)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.regular)

      Button {
        soundEnabled.toggle()
      } label: {
        Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
          .font(.title3)
          .foregroundStyle(soundEnabled ? .blue : .gray)
          .frame(width: 40, height: 40)
      }
      .buttonStyle(.bordered)
      .controlSize(.regular)
    }
  }
}

private struct JellySliderColorSlider: View {
  @Binding var value: Double

  var body: some View {
    Slider(value: $value, in: 0...1)
      .tint(.orange)
      .frame(minWidth: 180)
  }
}

#Preview {
  NavigationStack {
    JellySliderView()
  }
}
