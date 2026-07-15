//
//  CardHeader.swift
//  ShaderCards
//
//  The top band of a creature card: stage badge, name, HP, energy icon.
//

import SwiftUI

/// The header row of a creature card.
struct CardHeader: View {
  let card: CardModel
  let metrics: CardMetrics.Resolved
  /// Text color — dark on standard frames, light on full-art frames.
  var textColor: Color = .black

  var body: some View {
    VStack(alignment: .leading, spacing: metrics.width * 0.004) {
      StageBadge(stage: card.stage, metrics: metrics)

      HStack(alignment: .firstTextBaseline, spacing: metrics.width * 0.02) {
        Text(card.displayName)
          .font(CardTypography.name(metrics))
          .foregroundStyle(textColor)
          .lineLimit(1)
          .minimumScaleFactor(0.6)

        Spacer(minLength: 0)

        Text("HP")
          .font(.system(size: metrics.nameSize * 0.45, weight: .bold))
          .foregroundStyle(textColor.opacity(0.85))
          .baselineOffset(metrics.nameSize * 0.08)
        Text("\(card.hp)")
          .font(CardTypography.hp(metrics))
          .foregroundStyle(textColor)

        EnergyIcon(card.element, size: metrics.energyIconSize)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(card.displayName), \(card.hp) HP, \(card.element.displayName) type")
  }
}

/// The small "Basic" / "Stage 1" pill badge.
struct StageBadge: View {
  let stage: CardStage
  let metrics: CardMetrics.Resolved

  var body: some View {
    Text(stage.badgeText)
      .font(CardTypography.stageBadge(metrics))
      .foregroundStyle(.black.opacity(0.75))
      .padding(.horizontal, metrics.width * 0.02)
      .padding(.vertical, metrics.width * 0.004)
      .background(
        Capsule()
          .fill(
            LinearGradient(
              colors: [.white.opacity(0.95), Color(white: 0.82)],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .overlay(
            Capsule().strokeBorder(.black.opacity(0.2), lineWidth: 0.5)
          )
      )
  }
}
