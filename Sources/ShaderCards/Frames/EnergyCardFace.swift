//
//  EnergyCardFace.swift
//  ShaderCards
//
//  Energy card layout: a large centered energy icon on an element-tinted
//  radial burst.
//

import SwiftUI
import ShaderKit

/// The energy card face: bold, centered, iconic.
struct EnergyCardFace: View {
  let card: EnergyCardModel
  let metrics: CardMetrics.Resolved
  let finish: CardFinish

  private var palette: ElementPalette { card.element.palette }

  var body: some View {
    ZStack {
      // Element-tinted field.
      RoundedRectangle(cornerRadius: metrics.cornerRadius)
        .fill(
          LinearGradient(
            colors: [palette.light, palette.primary, palette.dark],
            startPoint: .top,
            endPoint: .bottom
          )
        )

      // Radial burst rays behind the icon.
      BurstRays(rays: 18)
        .fill(palette.accent.opacity(0.30))
        .frame(width: metrics.width * 1.6, height: metrics.width * 1.6)

      VStack(spacing: metrics.height * 0.02) {
        Text(card.isSpecial ? "Special Energy" : "Basic Energy")
          .font(.system(size: metrics.captionSize, weight: .heavy))
          .textCase(.uppercase)
          .foregroundStyle(.white.opacity(0.92))
          .shadow(color: palette.dark.opacity(0.8), radius: 1, y: 1)

        EnergyIcon(card.element, size: metrics.width * 0.45)
          .shadow(color: palette.dark.opacity(0.6), radius: metrics.width * 0.03, y: metrics.width * 0.015)

        Text("\(card.element.displayName) Energy")
          .font(.system(size: metrics.nameSize * 0.8, weight: .bold))
          .foregroundStyle(.white)
          .shadow(color: palette.dark.opacity(0.8), radius: 1, y: 1)
      }

      // Info line pinned to the bottom.
      VStack {
        Spacer()
        InfoLine(
          setNumber: card.setNumber,
          illustrator: "ShaderCards",
          rarity: card.isSpecial ? .holoRare : .common,
          metrics: metrics,
          textColor: .white
        )
        .padding(metrics.border)
      }
    }
    .overlay(
      RoundedRectangle(cornerRadius: metrics.cornerRadius)
        .strokeBorder(.black.opacity(0.3), lineWidth: 0.75)
    )
  }
}

/// Radial sunburst rays.
struct BurstRays: Shape {
  var rays: Int

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = max(rect.width, rect.height)
    let step = .pi * 2 / CGFloat(rays)
    for i in 0..<rays {
      let angle = CGFloat(i) * step
      let halfWidth = step * 0.28
      path.move(to: center)
      path.addLine(to: CGPoint(
        x: center.x + cos(angle - halfWidth) * radius,
        y: center.y + sin(angle - halfWidth) * radius
      ))
      path.addLine(to: CGPoint(
        x: center.x + cos(angle + halfWidth) * radius,
        y: center.y + sin(angle + halfWidth) * radius
      ))
      path.closeSubpath()
    }
    return path
  }
}
