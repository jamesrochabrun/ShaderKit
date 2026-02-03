//
//  JellyButtonView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly button demo using ShaderKitUI component.
//

import SwiftUI
import ShaderKitUI

struct JellyButtonView: View {
  @State private var tapCount = 0
  @State private var darkMode = false
  @State private var soundEnabled = true

  // Appearance customization
  @State private var jellyHue: Double = 0.95
  @State private var jellySaturation: Double = 0.75
  @State private var jellyBrightness: Double = 0.85

  private var jellyColor: Color {
    Color(hue: jellyHue, saturation: jellySaturation, brightness: jellyBrightness)
  }

  var body: some View {
    ZStack {
      JellyButton(
        action: {
          tapCount += 1
          darkMode.toggle()
        },
        jellyColor: jellyColor,
        darkMode: darkMode,
        soundEnabled: soundEnabled
      )
      .ignoresSafeArea()

      // Floating glass controls at bottom
      VStack {
        Spacer()

        // Tap counter
        Text("Taps: \(tapCount)")
          .font(.headline)
          .foregroundStyle(darkMode ? .white : .black)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(.ultraThinMaterial)
          .clipShape(Capsule())
          .padding(.bottom, 12)

        controlsPanel
          .padding(.bottom, 40)
      }
    }
    .navigationTitle("Jelly Button")
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    #endif
    .onChange(of: darkMode) { _, isDark in
      withAnimation(.easeInOut(duration: 0.4)) {
        if isDark {
          jellyBrightness = 1.0
        } else {
          jellyBrightness = 0.85
        }
      }
    }
  }

  private var controlsPanel: some View {
    HStack(spacing: 16) {
      // Sound toggle button
      Button {
        soundEnabled.toggle()
      } label: {
        Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
          .font(.title2)
          .foregroundStyle(soundEnabled ? .blue : .gray)
          .frame(width: 44, height: 44)
          .background(.ultraThinMaterial)
          .clipShape(Circle())
      }

      // Compact color sliders
      VStack(spacing: 4) {
        CompactColorSlider(value: $jellyHue)
        CompactColorSlider(value: $jellySaturation)
        CompactColorSlider(value: $jellyBrightness)
      }
      .frame(width: 150)
      .padding(8)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

private struct CompactColorSlider: View {
  @Binding var value: Double

  var body: some View {
    Slider(value: $value, in: 0...1)
      .tint(.primary)
      .frame(height: 16)
  }
}

#Preview {
  NavigationStack {
    JellyButtonView()
  }
}
