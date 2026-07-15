//
//  RaritySymbolView.swift
//  ShaderCards
//
//  The tiny rarity symbol printed in the card's info line.
//

import SwiftUI

/// Draws the rarity symbol: circle, diamond, star, or radiant star.
struct RaritySymbolView: View {
  let rarity: CardRarity
  let size: CGFloat
  /// Overrides the symbol color — for dark, art-led layouts.
  var colorOverride: Color?

  var body: some View {
    let symbol = rarity.symbol
    HStack(spacing: size * 0.15) {
      ForEach(0..<symbol.count, id: \.self) { _ in
        shape(for: symbol.shape)
          .foregroundStyle(colorOverride ?? symbol.color)
          .frame(width: size, height: size)
      }
    }
    .accessibilityLabel(rarity.displayName)
  }

  @ViewBuilder
  private func shape(for shape: RaritySymbol.Shape) -> some View {
    switch shape {
    case .circle:
      Circle()
    case .diamond:
      Rectangle().rotation(.degrees(45)).scale(0.72)
    case .star:
      StarShape(points: 5)
    case .radiantStar:
      StarShape(points: 4)
    }
  }
}

/// A classic N-pointed star.
struct StarShape: Shape {
  var points: Int = 5
  var innerRatio: CGFloat = 0.42

  func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let outer = min(rect.width, rect.height) / 2
    let inner = outer * innerRatio
    var path = Path()
    let step = .pi / CGFloat(points)
    for i in 0..<(points * 2) {
      let radius = i.isMultiple(of: 2) ? outer : inner
      let angle = CGFloat(i) * step - .pi / 2
      let point = CGPoint(
        x: center.x + cos(angle) * radius,
        y: center.y + sin(angle) * radius
      )
      if i == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
      }
    }
    path.closeSubpath()
    return path
  }
}
