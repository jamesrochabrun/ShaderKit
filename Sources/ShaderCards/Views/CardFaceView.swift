//
//  CardFaceView.swift
//  ShaderCards
//
//  The static card face: dispatches to the right frame for the card kind
//  and applies the finish's whole-card effects.
//

import SwiftUI
import ShaderKit

/// Renders a card face at a given width, without interaction.
///
/// Wrap it in ``TradingCardView`` (or your own `HolographicCardContainer`)
/// for tilt, motion, and live shader time. On its own it renders a crisp
/// static card — ideal for grids and thumbnails.
public struct CardFaceView: View {
  let card: Card
  let width: CGFloat
  /// Overrides the rarity-derived finish when non-nil.
  let finishOverride: CardFinish?

  public init(card: Card, width: CGFloat = 300, finish: CardFinish? = nil) {
    self.card = card
    self.width = width
    self.finishOverride = finish
  }

  public var body: some View {
    let metrics = CardMetrics.resolve(width: width)
    let finish = resolvedFinish

    Group {
      switch card {
      case .creature(let model):
        switch model.resolvedLayout(for: finish) {
        case .framed:
          StandardCardFace(card: model, metrics: metrics, finish: finish)
        case .fullArt:
          FullArtCardFace(card: model, metrics: metrics, finish: finish)
        case .minimal:
          MinimalCardFace(card: model, metrics: metrics, finish: finish)
        }
      case .trainer(let model):
        TrainerCardFace(card: model, metrics: metrics, finish: finish)
      case .energy(let model):
        EnergyCardFace(card: model, metrics: metrics, finish: finish)
      }
    }
    .frame(width: metrics.width, height: metrics.height)
    .modifier(EffectStack(effects: finish.cardEffects))
    .clipShape(RoundedRectangle(cornerRadius: metrics.cornerRadius))
    .accessibilityElement(children: .contain)
    .accessibilityLabel("\(card.displayName), \(card.rarity.displayName) card")
  }

  private var resolvedFinish: CardFinish {
    finishOverride ?? card.resolvedFinish
  }
}

/// An interactive holographic trading card.
///
/// Wraps the card face in ShaderKit's `HolographicCardContainer`, adding
/// drag-to-tilt 3D rotation, dynamic shadows, and a live time source for
/// every shader effect in the finish:
/// ```swift
/// TradingCardView(.creature(CardLibrary.emberfox), width: 300)
/// ```
public struct TradingCardView: View {
  let card: Card
  let width: CGFloat
  let finishOverride: CardFinish?

  public init(_ card: Card, width: CGFloat = 300, finish: CardFinish? = nil) {
    self.card = card
    self.width = width
    self.finishOverride = finish
  }

  public var body: some View {
    let metrics = CardMetrics.resolve(width: width)
    HolographicCardContainer(
      width: metrics.width,
      height: metrics.height,
      cornerRadius: metrics.cornerRadius,
      shadowColor: shadowColor,
      rotationMultiplier: 14.3,
      interactionMode: .surfacePointer
    ) {
      CardFaceView(card: card, width: width, finish: finishOverride)
    }
  }

  private var shadowColor: Color {
    switch card {
    case .creature(let model): model.element.palette.dark
    case .trainer: .black
    case .energy(let model): model.element.palette.dark
    }
  }
}
