//
//  NocturneView.swift
//  ShaderKitDemo
//
//  Composed with the trading-card skill — "Psychic Cosmic" vibe.
//  The same husky, recast as a spirit-wolf: a purple cosmic wash + rainbow
//  foil/glitter/sweep over the photo, with translucent "glass" info panels.
//  Effects live on the photo layer so the chrome stays crisp on top.
//

import SwiftUI
import ShaderKit

/// Cosmic purple palette for the Psychic Cosmic vibe.
private enum NocturnePalette {
  static let violet = Color(red: 0.42, green: 0.16, blue: 0.62)
  static let magenta = Color(red: 0.72, green: 0.28, blue: 0.68)
  static let accent = Color(red: 0.82, green: 0.64, blue: 1.0)
  static let base: [Color] = [
    Color(red: 0.30, green: 0.10, blue: 0.48),
    Color(red: 0.58, green: 0.22, blue: 0.58),
    Color(red: 0.24, green: 0.08, blue: 0.40),
  ]
  static let border: [Color] = [
    .white.opacity(0.6),
    Color(red: 0.62, green: 0.30, blue: 0.86).opacity(0.85),
    .white.opacity(0.3),
  ]
}

struct NocturneView: View {
  private let cardWidth: CGFloat = 280
  private let cardHeight: CGFloat = 400

  var body: some View {
    ZStack {
      // Dark stage with a faint violet cast so the foil carries.
      RadialGradient(
        colors: [
          Color(red: 0.10, green: 0.05, blue: 0.16),
          Color(red: 0.03, green: 0.03, blue: 0.05),
        ],
        center: .center,
        startRadius: 40,
        endRadius: 620
      )
      .ignoresSafeArea()

      VStack(spacing: 26) {
        Text("Psychic Cosmic")
          .font(.system(size: 22, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.92))

        HolographicCardContainer(
          width: cardWidth,
          height: cardHeight,
          cornerRadius: 20,
          shadowColor: .purple,
          rotationMultiplier: 13,
          interactionMode: .surfacePointer
        ) {
          NocturneContent(width: cardWidth, height: cardHeight)
        }

        Text("Drag to tilt")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.white.opacity(0.5))
      }
      .padding(.vertical, 32)
    }
    .preferredColorScheme(.dark)
  }
}

private struct NocturneContent: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    ZStack {
      // Shaded photo layer — cosmic wash + rainbow foil live HERE only.
      ZStack {
        // 1 — violet base (fallback if the image fails to load)
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              colors: NocturnePalette.base,
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )

        // 2 — full-bleed husky photo
        Image("frostfang")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: width, height: height)
          .clipped()

        // 3 — cosmic wash recolors the gray backdrop toward psychic purple
        LinearGradient(
          colors: [
            NocturnePalette.violet.opacity(0.5),
            NocturnePalette.magenta.opacity(0.18),
            NocturnePalette.violet.opacity(0.55),
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .blendMode(.plusDarker)
      }
      .foil()
      .glitter()
      .lightSweep()

      // 3b — legibility scrims (violet top, black bottom) above the foil.
      VStack(spacing: 0) {
        LinearGradient(
          colors: [NocturnePalette.violet.opacity(0.9), NocturnePalette.violet.opacity(0.5), .clear],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: height * 0.18)
        Spacer()
        LinearGradient(
          colors: [.clear, .black.opacity(0.55), .black.opacity(0.85)],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: height * 0.45)
      }

      // 4 — chrome: name banner + glass stat panel
      VStack(spacing: 12) {
        HStack(alignment: .firstTextBaseline) {
          Text("NOCTURNE")
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
          Spacer()
          HStack(spacing: 3) {
            Text("HP")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(.white.opacity(0.85))
            Text("190")
              .font(.system(size: 18, weight: .black, design: .rounded))
              .foregroundStyle(NocturnePalette.accent)
            Image(systemName: "moon.stars.fill")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(NocturnePalette.accent)
          }
          .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 9) {
          statRow(symbol: "waveform.path", name: "Astral Howl", damage: "120")

          Rectangle()
            .fill(.white.opacity(0.18))
            .frame(height: 0.5)

          statRow(symbol: "brain.head.profile", name: "Mind Fracture", damage: "90")

          Text("DREAMWALKER")
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(NocturnePalette.accent.opacity(0.9))
            .padding(.top, 2)

          Text("\"It hunts the space between your thoughts.\"")
            .font(.caption2.italic())
            .foregroundStyle(.white.opacity(0.62))
            .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 14)
            .fill(.black.opacity(0.42))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
            )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }

      // 5 — violet border
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: NocturnePalette.border,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 3
        )
    }
    .frame(width: width, height: height)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }

  private func statRow(symbol: String, name: String, damage: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: symbol)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(NocturnePalette.accent)
        .frame(width: 22)
      Text(name)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(.white)
      Spacer()
      Text(damage)
        .font(.system(size: 20, weight: .black, design: .rounded))
        .foregroundStyle(NocturnePalette.accent)
    }
  }
}

#Preview {
  NocturneView()
}
