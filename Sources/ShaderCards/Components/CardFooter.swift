//
//  CardFooter.swift
//  ShaderCards
//
//  The bottom bands: weakness / resistance / retreat, then the info line
//  with set number, illustrator, and rarity symbol.
//

import SwiftUI

/// Weakness, resistance, and retreat-cost band.
struct BattleStatsFooter: View {
  let card: CardModel
  let metrics: CardMetrics.Resolved
  var textColor: Color = .black

  private var iconSize: CGFloat { metrics.energyIconSize * 0.62 }

  var body: some View {
    HStack(spacing: 0) {
      statBlock(title: "weakness") {
        if let weakness = card.weakness {
          HStack(spacing: metrics.width * 0.006) {
            EnergyIcon(weakness, size: iconSize)
            Text("×2")
              .font(CardTypography.caption(metrics))
              .foregroundStyle(textColor)
          }
        } else {
          dash
        }
      }

      statBlock(title: "resistance") {
        if let resistance = card.resistance {
          HStack(spacing: metrics.width * 0.006) {
            EnergyIcon(resistance, size: iconSize)
            Text("−30")
              .font(CardTypography.caption(metrics))
              .foregroundStyle(textColor)
          }
        } else {
          dash
        }
      }

      statBlock(title: "retreat") {
        if card.retreatCost > 0 {
          HStack(spacing: -iconSize * 0.2) {
            ForEach(0..<min(card.retreatCost, 4), id: \.self) { _ in
              EnergyIcon(.colorless, size: iconSize)
            }
          }
        } else {
          dash
        }
      }
    }
    .accessibilityElement(children: .combine)
  }

  private var dash: some View {
    Text("—")
      .font(CardTypography.caption(metrics))
      .foregroundStyle(textColor.opacity(0.5))
  }

  private func statBlock(title: String, @ViewBuilder value: () -> some View) -> some View {
    VStack(spacing: metrics.width * 0.004) {
      Text(title)
        .font(.system(size: metrics.captionSize * 0.72, weight: .bold))
        .textCase(.uppercase)
        .foregroundStyle(textColor.opacity(0.6))
      value()
        .frame(height: iconSize)
    }
    .frame(maxWidth: .infinity)
  }
}

/// The bottom info line: set number, illustrator credit, rarity symbol.
struct InfoLine: View {
  let setNumber: String
  let illustrator: String
  let rarity: CardRarity
  let metrics: CardMetrics.Resolved
  var textColor: Color = .black

  var body: some View {
    HStack(spacing: metrics.width * 0.02) {
      Text("Illus. \(illustrator)")
        .font(.system(size: metrics.captionSize * 0.78, weight: .medium))
        .foregroundStyle(textColor.opacity(0.7))
        .lineLimit(1)

      Spacer(minLength: 0)

      Text(setNumber)
        .font(.system(size: metrics.captionSize * 0.78, weight: .semibold, design: .monospaced))
        .foregroundStyle(textColor.opacity(0.7))

      RaritySymbolView(rarity: rarity, size: metrics.captionSize * 0.85)
    }
  }
}
