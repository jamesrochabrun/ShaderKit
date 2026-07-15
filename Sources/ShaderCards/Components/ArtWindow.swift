//
//  ArtWindow.swift
//  ShaderCards
//
//  The framed art window with its metallic bevel, plus the species band
//  printed underneath it.
//

import SwiftUI

/// Wraps artwork in the signature beveled metallic frame.
struct ArtWindow<Art: View>: View {
  let metrics: CardMetrics.Resolved
  @ViewBuilder let art: () -> Art

  private var bevelWidth: CGFloat { metrics.width * 0.012 }

  var body: some View {
    art()
      .clipShape(Rectangle())
      .overlay(
        Rectangle()
          .strokeBorder(
            LinearGradient(
              colors: [
                Color(white: 0.98),
                Color(white: 0.65),
                Color(white: 0.88),
                Color(white: 0.45),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: bevelWidth
          )
      )
      .overlay(
        Rectangle()
          .strokeBorder(.black.opacity(0.35), lineWidth: 0.5)
      )
      .shadow(color: .black.opacity(0.35), radius: metrics.width * 0.01, y: metrics.width * 0.006)
  }
}

/// The thin metallic strip under the art: species and measurements.
struct SpeciesBand: View {
  let card: CardModel
  let metrics: CardMetrics.Resolved

  var body: some View {
    Text(bandText)
      .font(CardTypography.species(metrics))
      .foregroundStyle(.black.opacity(0.75))
      .lineLimit(1)
      .minimumScaleFactor(0.6)
      .padding(.horizontal, metrics.width * 0.03)
      .padding(.vertical, metrics.width * 0.008)
      .frame(maxWidth: .infinity)
      .background(
        Capsule()
          .fill(
            LinearGradient(
              colors: [Color(white: 0.95), Color(white: 0.78), Color(white: 0.9)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .overlay(Capsule().strokeBorder(.black.opacity(0.15), lineWidth: 0.5))
      )
  }

  private var bandText: String {
    var parts: [String] = []
    if !card.species.isEmpty {
      parts.append("\(card.species) Card")
    }
    parts.append("No. \(card.setNumber.prefix(3))")
    return parts.joined(separator: "  •  ")
  }
}
