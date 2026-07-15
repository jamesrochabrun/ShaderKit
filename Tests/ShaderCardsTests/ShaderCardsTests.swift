//
//  ShaderCardsTests.swift
//  ShaderCards
//

import Testing
@testable import ShaderCards
import ShaderKit

@Suite("Card library")
struct CardLibraryTests {
  @Test func libraryHasAllKinds() {
    #expect(CardLibrary.creatureCards.count == 33)
    #expect(CardLibrary.trainerCards.count == 6)
    #expect(CardLibrary.energyCards.count == 13)
    #expect(CardLibrary.specialEditionCards.count == 22)
    #expect(CardLibrary.premiumMaterialCards.count == 10)
    #expect(CardLibrary.cssParityCards.count == 21)
    #expect(CardLibrary.allCards.count == 95)
  }

  @Test func specialEditionsCarryBespokeFinishes() {
    for case .creature(let model) in CardLibrary.specialEditionCards {
      #expect(model.finish != nil, "\(model.name) is missing its special finish")
      #expect(!(model.finish?.cardEffects.isEmpty ?? true),
              "\(model.name) special finish has no foil passes")
    }
  }

  @Test func premiumMaterialFinishesAreAvailable() {
    let premiumFinishes: [CardFinish] = [
      .brushedTitanium,
      .blackChrome,
      .roseGold,
      .liquidMercury,
      .anodizedTitanium,
      .damascusSteel,
      .forgedCarbon,
      .copperPatina,
      .pearlCeramic,
      .oilSlick,
    ]

    #expect(premiumFinishes.count == 10)
    #expect(premiumFinishes.allSatisfy { $0.isFullArt })
    #expect(premiumFinishes.allSatisfy { !$0.cardEffects.isEmpty })
  }

  @Test func cssParityCatalogCoversEveryHoloStyle() {
    let representedStyles = Set(CardLibrary.cssParityCards.compactMap { card in
      let finish = card.resolvedFinish
      let effects = finish.artEffects + finish.cardEffects + finish.frameMaskedEffects
      return effects.compactMap { effect -> TradingCardHoloStyle? in
        guard case .tradingCardHolo(let style, _) = effect else { return nil }
        return style
      }.first
    })

    #expect(representedStyles == Set(TradingCardHoloStyle.allCases))
  }

  @Test func everyElementHasCreatures() {
    for element in ElementType.allCases {
      #expect(!CardLibrary.cards(for: element).isEmpty, "\(element) has no creatures")
    }
  }

  @Test func everyRarityRepresented() {
    for rarity in CardRarity.allCases {
      #expect(!CardLibrary.cards(of: rarity).isEmpty, "\(rarity) not represented in library")
    }
  }

  @Test func artworkMatchesElement() {
    for case .creature(let model) in CardLibrary.creatureCards {
      #expect(model.art.proceduralArtwork?.element == model.element,
              "\(model.name) artwork element mismatch")
    }
  }

  @Test func uvWindowMatchesLayoutFractions() {
    let uv = CardMetrics.artWindowUV
    #expect(uv.x > 0 && uv.z < 1 && uv.y > 0 && uv.w < 1)
    #expect(uv.w > uv.y && uv.z > uv.x)
  }
}
