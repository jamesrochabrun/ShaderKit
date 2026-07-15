//
//  TradingCardHoloEditions.swift
//  ShaderCards
//
//  One original ShaderCards showcase card for every CSS-reference foil family.
//

import Foundation
import ShaderKit

public extension CardLibrary {
  /// One card for each of ShaderKit's 21 modern trading-card holo styles.
  static let cssParityCards: [Card] = {
    let creatureEntries: [(TradingCardHoloStyle, CardModel)] = [
      (.regularHolo, emberfox),
      (.cosmosHolo, dreamwisp),
      (.reverseHolo, mistjelly),
      (.radiantHolo, skyserpent),
      (.amazingRare, voltkit),
      (.vRegular, tidecaller),
      (.vMax, auridrake),
      (.vStar, wyrmcoil),
      (.vFullArt, mindmoth),
      (.rainbowRare, glimmerkit),
      (.rainbowAlternate, prismpaw),
      (.secretRareGold, nightfang),
      (.shinyRare, pixiewing),
      (.shinyV, chromehawk),
      (.shinyVMax, forgegolem),
    ]

    let pikachuEntry: (TradingCardHoloStyle, CardModel) =
      (.pikachuSecretRare, stormbeak)

    let trainerEntries: [(TradingCardHoloStyle, TrainerCardModel)] = [
      (.trainerFullArt, professorHazel),
      (.trainerGalleryHolo, crystalCavern),
      (.trainerGallerySecretRare, nightTrader),
      (.trainerGalleryV, expeditionMap),
      (.trainerGalleryVMax, summitArena),
    ]

    let creatures = creatureEntries.enumerated().map { offset, entry in
      let style = entry.0
      var model = entry.1
      model.id = UUID()
      model.name = style.displayName
      model.stage = .basic
      model.rarity = rarity(for: style)
      model.finish = .tradingCardHolo(style)
      model.layout = model.finish?.isFullArt == true ? .minimal : .framed
      model.species = "CSS Parity Edition"
      model.setNumber = String(format: "%03d/151", 75 + offset)
      return Card.creature(model)
    }

    let trainers = trainerEntries.enumerated().map { offset, entry in
      let style = entry.0
      var model = entry.1
      model.id = UUID()
      model.name = style.displayName
      model.rarity = rarity(for: style)
      model.finish = .tradingCardHolo(style)
      model.setNumber = String(format: "%03d/151", 90 + offset)
      return Card.trainer(model)
    }

    var pikachuModel = pikachuEntry.1
    pikachuModel.id = UUID()
    pikachuModel.name = pikachuEntry.0.displayName
    pikachuModel.stage = .basic
    pikachuModel.rarity = rarity(for: pikachuEntry.0)
    pikachuModel.finish = .tradingCardHolo(pikachuEntry.0)
    pikachuModel.layout = .minimal
    pikachuModel.species = "CSS Parity Edition"
    pikachuModel.setNumber = "095/151"

    return creatures + trainers + [.creature(pikachuModel)]
  }()

  private static func rarity(for style: TradingCardHoloStyle) -> CardRarity {
    switch style {
    case .regularHolo, .cosmosHolo:
      .holoRare
    case .reverseHolo:
      .reverseHolo
    case .radiantHolo:
      .radiant
    case .amazingRare:
      .amazing
    case .rainbowRare, .rainbowAlternate, .trainerGalleryVMax,
         .pikachuSecretRare:
      .rainbowRare
    case .secretRareGold, .trainerGallerySecretRare:
      .hyperRare
    case .vRegular, .vMax, .vStar, .vFullArt, .shinyRare, .shinyV,
         .shinyVMax, .trainerFullArt, .trainerGalleryHolo, .trainerGalleryV:
      .ultraRare
    }
  }
}
