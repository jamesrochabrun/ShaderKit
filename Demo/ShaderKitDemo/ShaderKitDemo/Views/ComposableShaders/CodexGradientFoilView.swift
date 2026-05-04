//
//  CodexGradientFoilView.swift
//  ShaderKitDemo
//
//  Codex artwork card using the Gradient Foil composition
//

import SwiftUI
import ShaderKit

private enum CodexGradientPalette {
  static let light = Color(red: 177.0 / 255.0, green: 167.0 / 255.0, blue: 255.0 / 255.0)
  static let mid = Color(red: 122.0 / 255.0, green: 157.0 / 255.0, blue: 255.0 / 255.0)
  static let deep = Color(red: 57.0 / 255.0, green: 65.0 / 255.0, blue: 255.0 / 255.0)

  static let colors = [light, mid, deep]
}

struct CodexGradientFoilView: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      HolographicCardContainer(
        width: 280,
        height: 400,
        cornerRadius: 20,
        shadowColor: CodexGradientPalette.mid
      ) {
        CodexGradientFoilContent()
          .foil()
          .glitter()
          .lightSweep()
      }
    }
    .preferredColorScheme(.dark)
  }
}

// MARK: - Card Content

private struct CodexGradientFoilContent: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            colors: CodexGradientPalette.colors,
            startPoint: .top,
            endPoint: .bottom
          )
        )

      // Artwork - full bleed background
      Image("codex")
        .renderingMode(.original)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 280, height: 400)
        .clipped()

      VStack(spacing: 12) {
        HStack {
          Text("Codex")
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
            .codexCardTextShadow()
          Spacer()
          Text("GPT 5.5")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(CodexGradientPalette.light)
            .codexCardTextShadow()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 8) {
          HStack {
            Image(systemName: "bolt.fill")
              .foregroundStyle(CodexGradientPalette.light)
            Text("Power")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
              .codexCardTextShadow()
            Spacer()
            HStack(spacing: 4) {
              Text("100M+")
                .font(.title3)
                .fontWeight(.black)
                .codexCardTextShadow()
              Image(systemName: "star.fill")
                .font(.caption)
            }
            .foregroundStyle(CodexGradientPalette.light)
          }

          Text("A coding agent that helps you build and ship with AI—powered by ChatGPT.")
            .font(.caption2)
            .foregroundStyle(CodexGradientPalette.light.opacity(0.85))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .codexCardTextShadow()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
      }

      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: CodexGradientPalette.colors,
            startPoint: .top,
            endPoint: .bottom
          ),
          lineWidth: 3
        )
    }
  }
}

private extension View {
  func codexCardTextShadow() -> some View {
    shadow(color: .black.opacity(0.65), radius: 2, x: 0, y: 1)
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    CodexGradientFoilView()
  }
}
