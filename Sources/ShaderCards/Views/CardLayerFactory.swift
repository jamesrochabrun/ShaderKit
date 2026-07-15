//
//  CardLayerFactory.swift
//  ShaderCards
//
//  Decomposes a card into CardLayerExplodeLayer stacks: frame base,
//  under-art foils, artwork, chrome, and one layer per top foil pass.
//  Collapsed, the layers composite back to the exact card face.
//

import SwiftUI
import ShaderKit

/// Builds the exploded-layer representation of a card.
enum CardLayerFactory {
  /// Default gradient the shader carrier layers sample from — matches
  /// the ShaderKit builder's shader-input gradient.
  static let defaultShaderInputColors: [Color] = [
    .white.opacity(0.32),
    .white.opacity(0.12),
    .clear,
  ]

  /// Produces the ordered layer stack (back to front) for a card.
  ///
  /// - Parameters:
  ///   - card: The card to decompose.
  ///   - metrics: Resolved card metrics.
  ///   - finish: The holographic finish (defaults to the rarity's finish).
  ///   - shaderInputColors: Gradient the foil carrier layers are built from.
  ///   - extraTopEffects: Additional whole-card effects appended on top.
  static func layers(
    for card: Card,
    metrics: CardMetrics.Resolved,
    finish: CardFinish? = nil,
    shaderInputColors: [Color] = defaultShaderInputColors,
    extraTopEffects: [ShaderEffect] = []
  ) -> [CardLayerExplodeLayer] {
    let resolvedFinish = finish ?? card.resolvedFinish
    var layers: [CardLayerExplodeLayer] = []

    switch card {
    case .creature(let model):
      switch model.resolvedLayout(for: resolvedFinish) {
      case .fullArt, .minimal:
        // Each art layer (backdrop, scene/photo, overlay tint) separates.
        for (index, artLayer) in model.art.layers.enumerated() {
          layers.append(CardLayerExplodeLayer(id: "art-\(index)-\(artLayer.displayName)") {
            fullBleedArt(artLayer, metrics: metrics)
          })
        }
        if resolvedFinish.isGoldFrame {
          layers.append(CardLayerExplodeLayer(id: "gold-plate") {
            goldPlate(metrics: metrics)
          })
        }
        for (index, effect) in resolvedFinish.artEffects.enumerated() {
          layers.append(CardLayerExplodeLayer(id: "art-foil-\(index)-\(effect.layerLabel)") {
            fullCardCarrier(effect: effect, metrics: metrics, colors: shaderInputColors)
          })
        }
        layers.append(CardLayerExplodeLayer(id: "chrome") {
          Group {
            if model.resolvedLayout(for: resolvedFinish) == .minimal {
              MinimalCardFace(card: model, metrics: metrics, finish: resolvedFinish, artHidden: true)
            } else {
              FullArtCardFace(card: model, metrics: metrics, finish: resolvedFinish, artHidden: true)
            }
          }
          .frame(width: metrics.width, height: metrics.height)
        })
      case .framed:
        layers.append(CardLayerExplodeLayer(id: "frame-base") {
          StandardCardFace(card: model, metrics: metrics, finish: resolvedFinish, layerMode: .frameOnly)
            .frame(width: metrics.width, height: metrics.height)
        })
        for (index, artLayer) in model.art.layers.enumerated() {
          layers.append(CardLayerExplodeLayer(id: "art-\(index)-\(artLayer.displayName)") {
            windowArt(artLayer, metrics: metrics)
          })
        }
        for (index, effect) in resolvedFinish.artEffects.enumerated() {
          layers.append(CardLayerExplodeLayer(id: "art-foil-\(index)-\(effect.layerLabel)") {
            artWindowCarrier(effect: effect, metrics: metrics, colors: shaderInputColors)
          })
        }
        layers.append(CardLayerExplodeLayer(id: "chrome") {
          StandardCardFace(
            card: model,
            metrics: metrics,
            finish: resolvedFinish,
            layerMode: .chromeOnly,
            artTreatment: .transparent
          )
          .frame(width: metrics.width, height: metrics.height)
        })
      }

    case .trainer(let model):
      layers.append(CardLayerExplodeLayer(id: "frame-base") {
        TrainerCardFace(card: model, metrics: metrics, finish: resolvedFinish, layerMode: .frameOnly)
          .frame(width: metrics.width, height: metrics.height)
      })
      layers.append(CardLayerExplodeLayer(id: "artwork") {
        ZStack {
          Color.clear
          TrainerArtworkView(artwork: model.artwork)
            .frame(width: metrics.artWindowRect.width, height: metrics.artWindowRect.height)
            .clipped()
            .position(x: metrics.artWindowRect.midX, y: metrics.artWindowRect.midY)
        }
        .frame(width: metrics.width, height: metrics.height)
      })
      layers.append(CardLayerExplodeLayer(id: "chrome") {
        TrainerCardFace(
          card: model,
          metrics: metrics,
          finish: resolvedFinish,
          layerMode: .chromeOnly,
          artTreatment: .transparent
        )
        .frame(width: metrics.width, height: metrics.height)
      })

    case .energy(let model):
      layers.append(CardLayerExplodeLayer(id: "card-face") {
        EnergyCardFace(card: model, metrics: metrics, finish: resolvedFinish)
          .frame(width: metrics.width, height: metrics.height)
      })
    }

    // Whole-card foil passes, one layer per effect. Like the classic
    // builder, foil sits under the chrome so text stays crisp.
    let carriers = (resolvedFinish.cardEffects + extraTopEffects).enumerated().map { index, effect in
      CardLayerExplodeLayer(id: "card-foil-\(index)-\(effect.layerLabel)") {
        fullCardCarrier(effect: effect, metrics: metrics, colors: shaderInputColors)
      }
    }
    if let chromeIndex = layers.lastIndex(where: { $0.id == "chrome" }) {
      layers.insert(contentsOf: carriers, at: chromeIndex)
    } else {
      layers.append(contentsOf: carriers)
    }

    return layers
  }

  // MARK: - Layer pieces

  /// One full-bleed art layer, clipped to the card shape.
  private static func fullBleedArt(
    _ art: CardArt,
    metrics: CardMetrics.Resolved
  ) -> some View {
    CardArtView(art: art)
      .frame(width: metrics.width, height: metrics.height)
      .clipShape(RoundedRectangle(cornerRadius: metrics.cornerRadius))
  }

  /// The gold re-plating pass used by gold-frame treatments.
  private static func goldPlate(metrics: CardMetrics.Resolved) -> some View {
    LinearGradient(
      colors: [Color(red: 0.95, green: 0.78, blue: 0.35),
               Color(red: 0.75, green: 0.55, blue: 0.18),
               Color(red: 1.0, green: 0.88, blue: 0.55)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .blendMode(.color)
    .frame(width: metrics.width, height: metrics.height)
    .clipShape(RoundedRectangle(cornerRadius: metrics.cornerRadius))
  }

  /// One art layer clipped and positioned in the standard art window.
  private static func windowArt(
    _ art: CardArt,
    metrics: CardMetrics.Resolved
  ) -> some View {
    ZStack {
      Color.clear
      CardArtView(art: art)
        .frame(width: metrics.artWindowRect.width, height: metrics.artWindowRect.height)
        .clipped()
        .position(x: metrics.artWindowRect.midX, y: metrics.artWindowRect.midY)
    }
    .frame(width: metrics.width, height: metrics.height)
  }

  /// A foil pass restricted to the art window.
  private static func artWindowCarrier(
    effect: ShaderEffect,
    metrics: CardMetrics.Resolved,
    colors: [Color]
  ) -> some View {
    ZStack {
      Color.clear
      Rectangle()
        .fill(
          LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .blendMode(.screen)
        .shader(effect)
        .frame(width: metrics.artWindowRect.width, height: metrics.artWindowRect.height)
        .position(x: metrics.artWindowRect.midX, y: metrics.artWindowRect.midY)
    }
    .frame(width: metrics.width, height: metrics.height)
  }

  /// A foil pass covering the whole card.
  private static func fullCardCarrier(
    effect: ShaderEffect,
    metrics: CardMetrics.Resolved,
    colors: [Color]
  ) -> some View {
    RoundedRectangle(cornerRadius: metrics.cornerRadius)
      .fill(
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
      )
      .blendMode(.screen)
      .shader(effect)
      .frame(width: metrics.width, height: metrics.height)
  }
}
