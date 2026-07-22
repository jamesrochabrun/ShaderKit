//
//  CosmicApexView.swift
//  ShaderKitDemo
//
//  Composed with the holo-card-composer skill — an over-the-top "Secret Rare"
//  treatment. The husky, ascended: deep-space galaxy holo + radial sweep +
//  multi-glitter, closed with a chromatic-glass edge fringe, under a rainbow
//  border. Effects live on the photo layer so the glass chrome stays crisp.
//

import SwiftUI
import ShaderKit

/// Deep-space palette for the Cosmic Apex (secret-rare) vibe.
private enum ApexPalette {
  static let gold = Color(red: 1.0, green: 0.82, blue: 0.35)
  static let base: [Color] = [
    Color(red: 0.04, green: 0.03, blue: 0.12),
    Color(red: 0.16, green: 0.05, blue: 0.28),
    Color(red: 0.02, green: 0.02, blue: 0.06),
  ]
  static let wash: [Color] = [
    Color(red: 0.05, green: 0.02, blue: 0.20).opacity(0.72),
    Color(red: 0.20, green: 0.04, blue: 0.30).opacity(0.30),
    Color(red: 0.02, green: 0.02, blue: 0.08).opacity(0.80),
  ]
  // Full-spectrum secret-rare border.
  static let border: [Color] = [
    Color(red: 1.0, green: 0.30, blue: 0.55),
    Color(red: 1.0, green: 0.82, blue: 0.35),
    Color(red: 0.40, green: 1.0, blue: 0.70),
    Color(red: 0.35, green: 0.80, blue: 1.0),
    Color(red: 0.75, green: 0.45, blue: 1.0),
  ]
}

struct CosmicApexView: View {
  private let cardWidth: CGFloat = 280
  private let cardHeight: CGFloat = 400

  var body: some View {
    ZStack {
      // Pitch-black void stage with a faint magenta cast.
      RadialGradient(
        colors: [
          Color(red: 0.10, green: 0.03, blue: 0.14),
          Color(red: 0.01, green: 0.01, blue: 0.03),
        ],
        center: .center,
        startRadius: 30,
        endRadius: 640
      )
      .ignoresSafeArea()

      VStack(spacing: 26) {
        Text("Cosmic Apex")
          .font(.system(size: 22, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.92))

        HolographicCardContainer(
          width: cardWidth,
          height: cardHeight,
          cornerRadius: 20,
          shadowColor: Color(red: 0.7, green: 0.3, blue: 1.0),
          rotationMultiplier: 15,
          interactionMode: .surfacePointer
        ) {
          CosmicApexContent(width: cardWidth, height: cardHeight)
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

private struct CosmicApexContent: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    ZStack {
      // Shaded photo layer — galaxy holo + sweep + bling + chromatic edges.
      ZStack {
        // 1 — deep-space base (fallback if the image fails to load)
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              colors: ApexPalette.base,
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

        // 3 — cosmic wash sinks the gray backdrop into the void
        LinearGradient(
          colors: ApexPalette.wash,
          startPoint: .top,
          endPoint: .bottom
        )
        .blendMode(.plusDarker)
      }
      .galaxyHolo(intensity: 0.9)
      .multiGlitter()
      .radialSweep()
      .shader(.chromaticGlass(intensity: 0.5, separation: 0.4))

      // 3b — legibility scrims (void top, black bottom) above the effects.
      VStack(spacing: 0) {
        LinearGradient(
          colors: [.black.opacity(0.7), .black.opacity(0.3), .clear],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: height * 0.18)
        Spacer()
        LinearGradient(
          colors: [.clear, .black.opacity(0.62), .black.opacity(0.9)],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: height * 0.46)
      }

      // 4 — chrome: secret-rare banner + glass stat panel
      VStack(spacing: 12) {
        HStack(alignment: .firstTextBaseline) {
          VStack(alignment: .leading, spacing: 1) {
            Text("✦ SECRET RARE")
              .font(.system(size: 8, weight: .bold))
              .tracking(2)
              .foregroundStyle(ApexPalette.gold)
            Text("VOIDMAW")
              .font(.system(size: 22, weight: .black, design: .rounded))
              .foregroundStyle(.white)
          }
          .shadow(color: .black.opacity(0.7), radius: 2, y: 1)
          Spacer()
          HStack(spacing: 3) {
            Text("HP")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(.white.opacity(0.85))
            Text("999")
              .font(.system(size: 22, weight: .black, design: .rounded))
              .foregroundStyle(ApexPalette.gold)
            Image(systemName: "atom")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(ApexPalette.gold)
          }
          .shadow(color: .black.opacity(0.7), radius: 2, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 9) {
          statRow(symbol: "burst.fill", name: "Supernova Bite", damage: "300")

          Rectangle()
            .fill(.white.opacity(0.18))
            .frame(height: 0.5)

          statRow(symbol: "hurricane", name: "Event Horizon Howl", damage: "250")

          Text("COSMIC APEX PREDATOR")
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.6)
            .foregroundStyle(ApexPalette.gold.opacity(0.92))
            .padding(.top, 2)

          Text("\"At the end of the universe, it is still hungry.\"")
            .font(.caption2.italic())
            .foregroundStyle(.white.opacity(0.64))
            .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 14)
            .fill(.black.opacity(0.5))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                  LinearGradient(
                    colors: [ApexPalette.gold.opacity(0.55), .white.opacity(0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                  ),
                  lineWidth: 0.6
                )
            )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }

      // 5 — full-spectrum secret-rare border
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: ApexPalette.border,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 4
        )
    }
    .frame(width: width, height: height)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }

  private func statRow(symbol: String, name: String, damage: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: symbol)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(ApexPalette.gold)
        .frame(width: 22)
      Text(name)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)
      Spacer()
      Text(damage)
        .font(.system(size: 20, weight: .black, design: .rounded))
        .foregroundStyle(ApexPalette.gold)
    }
  }
}

#Preview {
  CosmicApexView()
}
