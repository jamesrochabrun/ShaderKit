//
//  MinimalCardFace.swift
//  ShaderCards
//
//  Poster-style layout: edge-to-edge artwork with just a name banner,
//  element mark, and info line under a thin chrome border.
//

import SwiftUI
import ShaderKit

/// The minimal card face: the artwork is the card.
struct MinimalCardFace: View {
  let card: CardModel
  let metrics: CardMetrics.Resolved
  let finish: CardFinish
  /// When true the artwork is omitted, leaving scrims and chrome only —
  /// used by the explodable layer view.
  var artHidden: Bool = false
  /// When true the legibility scrims are omitted too — for stacking
  /// this chrome over a face that already drew them.
  var scrimsHidden: Bool = false

  private var palette: ElementPalette { card.element.palette }

  var body: some View {
    ZStack {
      if !artHidden {
        CardArtView(art: card.art)
          .frame(width: metrics.width, height: metrics.height)
          .modifier(EffectStack(effects: finish.artEffects))

        if finish.isGoldFrame {
          LinearGradient(
            colors: [Color(red: 0.95, green: 0.78, blue: 0.35),
                     Color(red: 0.75, green: 0.55, blue: 0.18),
                     Color(red: 1.0, green: 0.88, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .blendMode(.color)
        }
      }

      // Legibility scrims, lighter than full-art: the art leads here.
      if !scrimsHidden {
        VStack(spacing: 0) {
          LinearGradient(
            colors: [.black.opacity(0.5), .clear],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: metrics.height * 0.16)
          Spacer()
          LinearGradient(
            colors: [.clear, .black.opacity(0.55)],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: metrics.height * 0.18)
        }
      }

      content
    }
    .overlay(frameBorder)
  }

  private var content: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center, spacing: metrics.width * 0.02) {
        Text(card.displayName)
          .font(.system(size: metrics.nameSize * 1.1, weight: .black))
          .foregroundStyle(.white)
          .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
          .lineLimit(1)
          .minimumScaleFactor(0.6)

        Spacer(minLength: 0)

        Text("HP \(card.hp)")
          .font(.system(size: metrics.nameSize * 0.62, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.92))
          .shadow(color: .black.opacity(0.6), radius: 2, y: 1)

        EnergyIcon(card.element, size: metrics.energyIconSize)
      }

      Spacer()

      HStack(spacing: metrics.width * 0.02) {
        if !card.species.isEmpty {
          Text(card.species)
            .font(.system(size: metrics.captionSize, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
            .lineLimit(1)
        }
        Spacer(minLength: 0)
        Text(card.setNumber)
          .font(.system(size: metrics.captionSize * 0.85, weight: .semibold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.8))
        RaritySymbolView(
          rarity: card.rarity,
          size: metrics.captionSize * 0.85,
          colorOverride: .white.opacity(0.9)
        )
      }
    }
    .padding(metrics.border * 1.4)
  }

  /// Thin chrome border, element-tinted (gold for gold treatments).
  private var frameBorder: some View {
    RoundedRectangle(cornerRadius: metrics.cornerRadius)
      .strokeBorder(
        LinearGradient(
          colors: finish.isGoldFrame
            ? [Color(red: 1.0, green: 0.92, blue: 0.60),
               Color(red: 0.85, green: 0.65, blue: 0.20),
               Color(red: 1.0, green: 0.88, blue: 0.50)]
            : [palette.light.opacity(0.95), .white.opacity(0.75), palette.primary.opacity(0.9)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: metrics.width * 0.014
      )
  }
}
