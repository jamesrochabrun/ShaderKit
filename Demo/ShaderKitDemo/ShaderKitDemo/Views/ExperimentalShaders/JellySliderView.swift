//
//  JellySliderView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly slider demo using ShaderKitUI component.
//

import ShaderKitUI
import SwiftUI

struct JellySliderView: View {
  private let contentHorizontalPadding: CGFloat = 16
  private let sliderMaxLength: CGFloat = 640

  @State private var value = 1.0
  @State private var darkMode = false
  @State private var soundEnabled = false
  @State private var showsColorControls = true

  @State private var jellyHue: Double = 0.06
  @State private var jellySaturation: Double = 0.92
  @State private var jellyBrightness: Double = 0.95

  private var jellyColor: Color {
    Color(hue: jellyHue, saturation: jellySaturation, brightness: jellyBrightness)
  }

  private var screenBackground: Color {
    darkMode ? .black : Color(red: 0.95, green: 0.94, blue: 0.99)
  }

  private var controlsBackground: Color {
    darkMode ? Color.white.opacity(0.08) : .white
  }

  private var controlsForeground: Color {
    darkMode ? .white : .black
  }

  var body: some View {
    ZStack {
      screenBackground
        .ignoresSafeArea()

      GeometryReader { proxy in
        ScrollView {
          VStack(spacing: 18) {
            JellySlider(
              value: $value,
              jellyColor: jellyColor,
              darkMode: darkMode,
              soundEnabled: soundEnabled
            )
            .frame(
              width: sliderLength(in: proxy.size),
              height: sliderLength(in: proxy.size)
            )

            controlsPanel
              .frame(maxWidth: 380)
          }
          .frame(maxWidth: .infinity)
          .padding(.horizontal, contentHorizontalPadding)
          .padding(.top, sliderTopPadding(in: proxy.size))
          .padding(.bottom, 24)
          .animation(.easeInOut(duration: 0.24), value: showsColorControls)
        }
      }
    }
    .background(screenBackground)
    .navigationTitle("Jelly Slider")
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(screenBackground, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(darkMode ? .dark : .light, for: .navigationBar)
    #endif
    .preferredColorScheme(darkMode ? .dark : .light)
    .onChange(of: darkMode) { _, isDark in
      withAnimation(.easeInOut(duration: 0.4)) {
        jellyBrightness = isDark ? 1.0 : 0.95
      }
    }
  }

  private func sliderLength(in size: CGSize) -> CGFloat {
    min(sliderMaxLength, max(1, size.width - contentHorizontalPadding * 2))
  }

  private func sliderTopPadding(in size: CGSize) -> CGFloat {
    let centeredTopPadding = max(16, (size.height - sliderLength(in: size)) / 2)

    guard showsColorControls else {
      return centeredTopPadding
    }

    let lift = min(88, max(48, size.height * 0.11))
    return max(16, centeredTopPadding - lift)
  }

  private var controlsPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        Text("Mode")
          .font(.callout.weight(.semibold))

        Spacer(minLength: 12)

        modeControls
      }

      if showsColorControls {
        Divider()
          .overlay(controlsForeground.opacity(0.12))

        HStack(alignment: .top, spacing: 12) {
          Text("Jelly Color")
            .font(.callout.weight(.semibold))
            .frame(width: 76, alignment: .leading)

          VStack(spacing: 6) {
            JellySliderColorSlider(value: $jellyHue)
            JellySliderColorSlider(value: $jellySaturation)
            JellySliderColorSlider(value: $jellyBrightness)
          }
        }
      }
    }
    .font(.callout)
    .foregroundStyle(controlsForeground)
    .padding(14)
    .background(controlsBackground)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }

  private var modeControls: some View {
    HStack(spacing: 8) {
      Button {
        darkMode.toggle()
      } label: {
        controlIcon(darkMode ? "moon.fill" : "sun.max.fill")
      }
      .buttonStyle(.bordered)
      .controlSize(.small)
      .tint(controlsForeground)
      .accessibilityLabel(darkMode ? "Use light mode" : "Use dark mode")

      Button {
        soundEnabled.toggle()
      } label: {
        controlIcon(soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
      }
      .buttonStyle(.bordered)
      .controlSize(.small)
      .tint(controlsForeground)
      .accessibilityLabel(soundEnabled ? "Disable sound" : "Enable sound")

      Button {
        withAnimation(.easeInOut(duration: 0.2)) {
          showsColorControls.toggle()
        }
      } label: {
        controlIcon(showsColorControls ? "paintpalette.fill" : "paintpalette")
      }
      .buttonStyle(.bordered)
      .controlSize(.small)
      .tint(controlsForeground)
      .accessibilityLabel(showsColorControls ? "Hide jelly color controls" : "Show jelly color controls")
    }
  }

  private func controlIcon(_ systemName: String) -> some View {
    Image(systemName: systemName)
      .font(.body.weight(.semibold))
      .foregroundStyle(controlsForeground)
      .frame(width: 28, height: 28)
  }
}

private struct JellySliderColorSlider: View {
  @Binding var value: Double

  var body: some View {
    Slider(value: $value, in: 0...1)
      .tint(.orange)
      .frame(minWidth: 150)
  }
}

#Preview {
  NavigationStack {
    JellySliderView()
  }
}
