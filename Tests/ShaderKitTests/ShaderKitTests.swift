//
//  ShaderKitTests.swift
//  ShaderKit
//
//  Tests for ShaderKit package
//

import CoreGraphics
import Testing
@testable import ShaderKit

@Suite("ShaderKit Tests")
struct ShaderKitTests {

    @Test("Version is set")
    func versionIsSet() {
        #expect(ShaderKit.version == "2.0.0")
    }

    @Test("Premium material effects are distinct")
    func premiumMaterialEffectsAreDistinct() {
        let effects: [ShaderEffect] = [
            .brushedTitanium(),
            .blackChrome(),
            .roseGold(),
            .liquidMercury(),
            .anodizedTitanium(),
            .damascusSteel(),
            .forgedCarbon(),
            .copperPatina(),
            .pearlCeramic(),
            .oilSlick(),
        ]

        #expect(effects.count == 10)
        let allDistinct = effects.enumerated().allSatisfy { index, effect in
            effects[..<index].allSatisfy { $0 != effect }
        }
        #expect(allDistinct)
    }

    @Test("Trading card catalog covers every reference style")
    func tradingCardCatalogIsComplete() {
      #expect(TradingCardHoloStyle.allCases.count == 21)
      #expect(Set(TradingCardHoloStyle.allCases.map(\.displayName)).count == 21)
      #expect(Set(TradingCardHoloStyle.allCases.map(\.referenceSheetName)) == [
        "regular-holo.css", "cosmos-holo.css", "reverse-holo.css",
        "radiant-holo.css", "amazing-rare.css", "v-regular.css",
        "v-max.css", "v-star.css", "v-full-art.css", "rainbow-holo.css",
        "rainbow-alt.css", "secret-rare.css", "shiny-rare.css", "shiny-v.css",
        "shiny-vmax.css", "trainer-full-art.css", "trainer-gallery-holo.css",
        "trainer-gallery-secret-rare.css", "trainer-gallery-v-regular.css",
        "trainer-gallery-v-max.css", "swsh-pikachu.css"
      ])
    }

    @Test("Surface pointer interaction matches card-reference coordinates")
    func surfacePointerInteractionMatchesReference() {
        let mode = HolographicInteractionMode.surfacePointer
        let size = CGSize(width: 260, height: 380)

        let center = mode.normalizedTilt(
            translation: .zero,
            pointer: CGPoint(x: 0.5, y: 0.5),
            size: size
        )
        #expect(center == .zero)

        let bottomRight = mode.normalizedTilt(
            translation: CGSize(width: -500, height: -500),
            pointer: CGPoint(x: 1.4, y: 1.2),
            size: size
        )
        #expect(bottomRight == CGPoint(x: 1, y: 1))

        let rotation = mode.rotation(
            for: CGPoint(x: 1, y: -1),
            multiplier: 14.3
        )
        #expect(abs(rotation.x + 14.3) < 0.001)
        #expect(abs(rotation.y + 14.3) < 0.001)
    }

    @Test("Legacy interaction still derives tilt from drag translation")
    func dragTranslationInteractionIsPreserved() {
        let mode = HolographicInteractionMode.dragTranslation
        let tilt = mode.normalizedTilt(
            translation: CGSize(width: 130, height: -190),
            pointer: CGPoint(x: 0, y: 1),
            size: CGSize(width: 260, height: 380)
        )

        #expect(tilt == CGPoint(x: 1, y: -1))
        let rotation = mode.rotation(for: tilt, multiplier: 15)
        #expect(rotation.x == 15)
        #expect(rotation.y == 15)
    }

}
