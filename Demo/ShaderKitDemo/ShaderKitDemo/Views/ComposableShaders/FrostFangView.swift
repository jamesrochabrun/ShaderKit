//
//  FrostFangView.swift
//  ShaderKitDemo
//
//  Composed with the holo-card-composer skill — "Winter Frost" vibe.
//  A husky full-art card: glacier palette + frozen shimmer + light sweep over
//  the photo, with translucent "glass" info panels for the card text.
//

import SwiftUI
import ShaderKit

/// Icy palette for the Winter Frost vibe (glacier edition stops).
private enum FrostPalette {
  static let light = Color(red: 0.78, green: 0.88, blue: 0.96)
  static let mid = Color(red: 0.55, green: 0.72, blue: 0.88)
  static let deep = Color(red: 0.30, green: 0.48, blue: 0.70)
  static let accent = Color(red: 0.62, green: 0.86, blue: 1.0)
  static let base: [Color] = [light, mid, deep]
  static let border: [Color] = [
    Color(red: 0.90, green: 0.95, blue: 1.0),
    mid,
    Color(red: 0.90, green: 0.95, blue: 1.0),
  ]
}

struct FrostFangView: View {
  private let cardWidth: CGFloat = 280
  private let cardHeight: CGFloat = 400

  var body: some View {
    ZStack {
      // Dark stage with a faint icy cast so the frost carries.
      RadialGradient(
        colors: [
          Color(red: 0.06, green: 0.10, blue: 0.16),
          Color(red: 0.03, green: 0.03, blue: 0.05),
        ],
        center: .center,
        startRadius: 40,
        endRadius: 620
      )
      .ignoresSafeArea()

      VStack(spacing: 26) {
        Text("Winter Frost")
          .font(.system(size: 22, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.92))

        HolographicCardContainer(
          width: cardWidth,
          height: cardHeight,
          cornerRadius: 20,
          shadowColor: .cyan,
          rotationMultiplier: 13,
          interactionMode: .surfacePointer
        ) {
          FrostFangContent(width: cardWidth, height: cardHeight)
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

private struct FrostFangContent: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    ZStack {
      // Shaded photo layer — the frost + sweep live HERE only, so the text and
      // glass panels stay clean on top instead of being buried in snowflakes.
      ZStack {
        // 1 — glacier base (fallback if the image fails to load)
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              colors: FrostPalette.base,
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

        // 3 — icy tint scrim marries the photo to the palette
        LinearGradient(
          colors: [
            FrostPalette.deep.opacity(0.28),
            .clear,
            FrostPalette.deep.opacity(0.22),
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      }
      .frozen(intensity: 0.7, starDensity: 0.4)
      .lightSweep()

      // 3b — legibility scrims where text sits (above the frost, below text)
      VStack(spacing: 0) {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
          .frame(height: height * 0.17)
        Spacer()
        LinearGradient(colors: [.clear, .black.opacity(0.66)], startPoint: .top, endPoint: .bottom)
          .frame(height: height * 0.44)
      }

      // 4 — chrome: name banner + glass stat panel
      VStack(spacing: 12) {
        HStack(alignment: .firstTextBaseline) {
          Text("FROSTFANG")
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
          Spacer()
          HStack(spacing: 3) {
            Text("HP")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(.white.opacity(0.85))
            Text("210")
              .font(.system(size: 18, weight: .black, design: .rounded))
              .foregroundStyle(FrostPalette.accent)
            Image(systemName: "snowflake")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(FrostPalette.accent)
          }
          .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 9) {
          statRow(symbol: "wind.snow", name: "Blizzard Howl", damage: "140")

          Rectangle()
            .fill(.white.opacity(0.18))
            .frame(height: 0.5)

          statRow(symbol: "snowflake", name: "Permafrost Bite", damage: "90")

          Text("ARCTIC SENTINEL")
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(FrostPalette.accent.opacity(0.9))
            .padding(.top, 2)

          Text("\"Where the north wind ends, his watch begins.\"")
            .font(.caption2.italic())
            .foregroundStyle(.white.opacity(0.62))
            .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 14)
            .fill(.black.opacity(0.45))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
            )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }

      // 5 — icy border
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: FrostPalette.border,
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
        .foregroundStyle(FrostPalette.accent)
        .frame(width: 22)
      Text(name)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(.white)
      Spacer()
      Text(damage)
        .font(.system(size: 20, weight: .black, design: .rounded))
        .foregroundStyle(FrostPalette.accent)
    }
  }
}

#Preview {
  FrostFangView()
}
