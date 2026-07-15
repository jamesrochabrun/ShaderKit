//
//  TradingCardHoloFinishes.swift
//  ShaderCards
//
//  Region-aware card recipes for ShaderKit's complete holo catalog.
//

import ShaderKit

public extension CardFinish {
  /// Every modern trading-card holo construction as a named Studio preset.
  static var tradingCardHoloFinishes: [(name: String, finish: CardFinish)] {
    TradingCardHoloStyle.allCases.map { style in
      (style.displayName, .tradingCardHolo(style))
    }
  }

  /// Builds the region-aware finish for a physical foil family.
  /// Standard holos remain inside the artwork, reverse holos stay on the
  /// frame, and etched/full-art treatments cover the complete card face.
  static func tradingCardHolo(_ style: TradingCardHoloStyle) -> CardFinish {
    let effect = ShaderEffect.tradingCardHolo(style: style, intensity: 0.88)

    switch style {
    case .regularHolo, .cosmosHolo:
      return CardFinish(artEffects: [effect])

    case .reverseHolo:
      return CardFinish(frameMaskedEffects: [effect])

    case .radiantHolo:
      return CardFinish(
        artEffects: [effect],
        frameMaskedEffects: [
          .tradingCardHolo(style: style, intensity: 0.58),
        ]
      )

    case .amazingRare, .shinyRare:
      return CardFinish(artEffects: [effect])

    case .secretRareGold, .trainerGallerySecretRare:
      return CardFinish(
        cardEffects: [effect],
        isFullArt: true,
        isGoldFrame: true
      )

    case .vRegular, .vMax, .vStar, .vFullArt,
         .rainbowRare, .rainbowAlternate, .shinyV, .shinyVMax,
         .trainerFullArt, .trainerGalleryHolo, .trainerGalleryV,
         .trainerGalleryVMax, .pikachuSecretRare:
      return CardFinish(
        cardEffects: [effect],
        isFullArt: true
      )
    }
  }
}
