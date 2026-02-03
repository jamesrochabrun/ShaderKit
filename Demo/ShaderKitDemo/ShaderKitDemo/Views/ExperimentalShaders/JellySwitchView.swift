//
//  JellySwitchView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly switch demo using ShaderKitUI component.
//

import SwiftUI
import ShaderKitUI

struct JellySwitchView: View {
  @State private var isOn = false
  @State private var darkMode = false

  // Appearance customization
  @State private var jellyHue: Double = 0.78
  @State private var jellySaturation: Double = 0.85
  @State private var jellyBrightness: Double = 0.65

  private let toneGenerator = ToneGenerator()

  private var jellyColor: Color {
    Color(hue: jellyHue, saturation: jellySaturation, brightness: jellyBrightness)
  }

  var body: some View {
    ZStack {
      JellySwitch(isOn: $isOn, jellyColor: jellyColor, darkMode: darkMode)
        .ignoresSafeArea()

      // Floating glass controls at bottom
      VStack {
        Spacer()
        controlsPanel
          .padding(.bottom, 40)
      }
    }
    .navigationTitle("Jelly Switch")
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    #endif
    .onChange(of: darkMode) { _, isDark in
      withAnimation(.easeInOut(duration: 0.4)) {
        if isDark {
          jellyBrightness = 1.0
        } else {
          jellyBrightness = 0.65
        }
      }
    }
  }

  private var controlsPanel: some View {
    HStack(spacing: 16) {
      // Light toggle button
      Button {
        toneGenerator.playClick(ascending: !darkMode)
        darkMode.toggle()
      } label: {
        Image(systemName: darkMode ? "moon.fill" : "sun.max.fill")
          .font(.title2)
          .foregroundStyle(darkMode ? .yellow : .orange)
          .frame(width: 44, height: 44)
          .background(.ultraThinMaterial)
          .clipShape(Circle())
      }

      // Compact color sliders
      VStack(spacing: 4) {
        CompactSlider(value: $jellyHue)
        CompactSlider(value: $jellySaturation)
        CompactSlider(value: $jellyBrightness)
      }
      .frame(width: 150)
      .padding(8)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

private struct CompactSlider: View {
  @Binding var value: Double

  var body: some View {
    Slider(value: $value, in: 0...1)
      .tint(.primary)
      .frame(height: 16)
  }
}

#Preview {
  NavigationStack {
    JellySwitchView()
  }
}
