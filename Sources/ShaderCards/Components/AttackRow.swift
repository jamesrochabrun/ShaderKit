//
//  AttackRow.swift
//  ShaderCards
//
//  Attack and ability rows for the card body.
//

import SwiftUI

/// One attack row: energy cost, name, rules text, damage.
struct AttackRow: View {
  let attack: CardAttack
  let metrics: CardMetrics.Resolved
  var textColor: Color = .black

  var body: some View {
    VStack(alignment: .leading, spacing: metrics.width * 0.006) {
      HStack(spacing: metrics.width * 0.02) {
        HStack(spacing: -metrics.energyIconSize * 0.15) {
          ForEach(Array(attack.cost.enumerated()), id: \.offset) { _, element in
            EnergyIcon(element, size: metrics.energyIconSize * 0.85)
          }
        }

        Text(attack.name)
          .font(CardTypography.attackName(metrics))
          .foregroundStyle(textColor)
          .lineLimit(1)
          .minimumScaleFactor(0.7)

        Spacer(minLength: 0)

        if !attack.damage.isEmpty {
          Text(attack.damage)
            .font(CardTypography.attackDamage(metrics))
            .foregroundStyle(textColor)
        }
      }

      if let text = attack.text {
        Text(text)
          .font(CardTypography.body(metrics))
          .foregroundStyle(textColor.opacity(0.85))
          .lineLimit(3)
          .minimumScaleFactor(0.75)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

/// A passive ability row with the signature red "Ability" badge.
struct AbilityRow: View {
  let ability: CardAbility
  let metrics: CardMetrics.Resolved
  var textColor: Color = .black

  var body: some View {
    VStack(alignment: .leading, spacing: metrics.width * 0.006) {
      HStack(spacing: metrics.width * 0.02) {
        Text("Ability")
          .font(.system(size: metrics.captionSize, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)
          .padding(.horizontal, metrics.width * 0.022)
          .padding(.vertical, metrics.width * 0.006)
          .background(
            Capsule().fill(
              LinearGradient(
                colors: [Color(red: 0.95, green: 0.35, blue: 0.25),
                         Color(red: 0.75, green: 0.12, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
              )
            )
          )

        Text(ability.name)
          .font(CardTypography.attackName(metrics))
          .foregroundStyle(Color(red: 0.72, green: 0.15, blue: 0.12))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }

      Text(ability.text)
        .font(CardTypography.body(metrics))
        .foregroundStyle(textColor.opacity(0.85))
        .lineLimit(3)
        .minimumScaleFactor(0.75)
        .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .combine)
  }
}
