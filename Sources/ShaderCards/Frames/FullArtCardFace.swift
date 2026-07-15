//
//  FullArtCardFace.swift
//  ShaderCards
//
//  Full-art layout: edge-to-edge artwork with translucent chrome overlays,
//  used by ultra-rare and higher treatments.
//

import SwiftUI
import ShaderKit

/// The full-art card face: artwork bleeds to the card edges and the UI
/// chrome floats on frosted panels, like modern ultra-rare cards.
struct FullArtCardFace: View {
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
      // Edge-to-edge artwork.
      if !artHidden {
        CardArtView(art: card.art)
          .frame(width: metrics.width, height: metrics.height)
          .modifier(EffectStack(effects: finish.artEffects))

        // Gold treatments re-plate the whole illustration in gold tones.
        if finish.isGoldFrame {
          LinearGradient(
            colors: [Color(red: 0.95, green: 0.78, blue: 0.35),
                     Color(red: 0.75, green: 0.55, blue: 0.18),
                     Color(red: 1.0, green: 0.88, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .blendMode(.color)
          LinearGradient(
            colors: [Color(red: 1.0, green: 0.88, blue: 0.50).opacity(0.5),
                     .clear,
                     Color(red: 0.9, green: 0.70, blue: 0.30).opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
          )
          .blendMode(.softLight)
        }
      }

      // Legibility scrims top and bottom.
      if !scrimsHidden {
        VStack(spacing: 0) {
          LinearGradient(
            colors: [.black.opacity(0.55), .clear],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: metrics.height * 0.14)
          Spacer()
          LinearGradient(
            colors: [.clear, .black.opacity(0.62)],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: metrics.height * 0.42)
        }
      }

      content
    }
    .overlay(frameBorder)
  }

  private var content: some View {
    VStack(spacing: metrics.height * 0.008) {
      CardHeader(card: card, metrics: metrics, textColor: .white)
        .frame(height: metrics.headerHeight)

      Spacer(minLength: 0)

      VStack(alignment: .leading, spacing: metrics.height * 0.012) {
        if let ability = card.ability {
          AbilityRow(ability: ability, metrics: metrics, textColor: .white)
        }
        ForEach(card.attacks) { attack in
          AttackRow(attack: attack, metrics: metrics, textColor: .white)
        }
      }
      .padding(.horizontal, metrics.width * 0.03)
      .padding(.vertical, metrics.width * 0.024)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.6)
          .fill(.black.opacity(0.34))
          .overlay(
            RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.6)
              .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
          )
      )

      BattleStatsFooter(card: card, metrics: metrics, textColor: .white)
        .padding(.horizontal, metrics.width * 0.01)

      InfoLine(
        setNumber: card.setNumber,
        illustrator: card.illustrator,
        rarity: card.rarity,
        metrics: metrics,
        textColor: .white
      )
    }
    .padding(metrics.border)
  }

  /// Thin metallic border hugging the card edge.
  private var frameBorder: some View {
    RoundedRectangle(cornerRadius: metrics.cornerRadius)
      .strokeBorder(
        LinearGradient(
          colors: finish.isGoldFrame
            ? [Color(red: 1.0, green: 0.92, blue: 0.60),
               Color(red: 0.85, green: 0.65, blue: 0.20),
               Color(red: 1.0, green: 0.88, blue: 0.50)]
            : [.white.opacity(0.9), palette.light.opacity(0.7), .white.opacity(0.5)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: metrics.width * 0.012
      )
  }
}
