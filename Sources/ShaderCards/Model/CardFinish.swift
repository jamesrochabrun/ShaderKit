//
//  CardFinish.swift
//  ShaderCards
//
//  Maps rarity tiers to layered ShaderKit effect stacks — the recipe book
//  that makes each tier feel like its real-world foil treatment.
//

import SwiftUI
import ShaderKit

/// The holographic treatment for a card, expressed as ShaderKit effect
/// stacks applied to different regions of the card.
///
/// Use ``CardFinish/finish(for:)`` for the canonical treatment of a rarity,
/// or build a custom one for bespoke cards.
public struct CardFinish: Equatable, Sendable {
  /// Effects applied to the art window only (classic holo treatment).
  public var artEffects: [ShaderEffect]
  /// Effects applied across the entire card face.
  public var cardEffects: [ShaderEffect]
  /// Effects applied to the frame only (everything except the art window).
  /// Used by reverse-holo treatments. The window is injected at render time.
  public var frameMaskedEffects: [ShaderEffect]
  /// Whether the artwork bleeds to the card edges (full-art styles).
  public var isFullArt: Bool
  /// Whether the frame uses the gold metallic treatment.
  public var isGoldFrame: Bool

  public init(
    artEffects: [ShaderEffect] = [],
    cardEffects: [ShaderEffect] = [],
    frameMaskedEffects: [ShaderEffect] = [],
    isFullArt: Bool = false,
    isGoldFrame: Bool = false
  ) {
    self.artEffects = artEffects
    self.cardEffects = cardEffects
    self.frameMaskedEffects = frameMaskedEffects
    self.isFullArt = isFullArt
    self.isGoldFrame = isGoldFrame
  }

  /// The canonical finish for a rarity tier.
  public static func finish(for rarity: CardRarity) -> CardFinish {
    switch rarity {
    case .common, .uncommon:
      CardFinish()

    case .rare:
      CardFinish(cardEffects: [.glassSheen(intensity: 0.25, spread: 0.6)])

    case .holoRare:
      CardFinish(
        artEffects: [.verticalBeams(intensity: 0.35), .sparkles],
        cardEffects: [.glassSheen(intensity: 0.25, spread: 0.5)]
      )

    case .reverseHolo:
      CardFinish(
        cardEffects: [.glassSheen(intensity: 0.25, spread: 0.5)],
        frameMaskedEffects: [.maskedFoil(imageWindow: .zero, intensity: 0.4),
                             .maskedSparkle(imageWindow: .zero)]
      )

    case .doubleRare:
      CardFinish(
        artEffects: [.diagonalHolo(intensity: 0.35), .glitter(density: 45)],
        cardEffects: [.glassSheen(intensity: 0.3, spread: 0.5)]
      )

    case .ultraRare:
      CardFinish(
        cardEffects: [.etchedFoil(intensity: 0.55, density: 90),
                      .blendedHolo(intensity: 0.25, saturation: 0.8),
                      .lightSweep],
        isFullArt: true
      )

    case .illustrationRare:
      CardFinish(
        cardEffects: [.galaxyHolo(intensity: 0.3),
                      .glitter(density: 40),
                      .glassSheen(intensity: 0.3, spread: 0.6)],
        isFullArt: true
      )

    case .specialIllustrationRare:
      CardFinish(
        cardEffects: [.crisscrossHolo(intensity: 0.3),
                      .multiGlitter(density: 60),
                      .lightSweep],
        isFullArt: true
      )

    case .rainbowRare:
      CardFinish(
        cardEffects: [.rainbowGlitter(intensity: 0.35),
                      .shimmer(intensity: 0.2),
                      .lightSweep],
        isFullArt: true
      )

    case .hyperRare:
      CardFinish(
        cardEffects: [.metallicCrosshatch(intensity: 0.35),
                      .glitter(density: 55),
                      .lightSweep],
        isFullArt: true,
        isGoldFrame: true
      )

    case .radiant:
      CardFinish(
        artEffects: [.crisscrossHolo(intensity: 0.5), .multiGlitter(density: 50)],
        cardEffects: [.glassSheen(intensity: 0.3, spread: 0.5)]
      )

    case .amazing:
      CardFinish(
        artEffects: [.galaxyHolo(intensity: 0.45), .multiGlitter(density: 55)],
        cardEffects: [.glitter(density: 30), .glassSheen(intensity: 0.25, spread: 0.5)]
      )
    }
  }
}

// MARK: - Special finishes

/// Named premium finishes recreating the classic ShaderKit demo cards.
/// Apply one to any card via `CardBuilder.finish(_:)` or the `finish:`
/// parameter on the card views.
public extension CardFinish {
  /// All named special finishes, for menus and galleries.
  static var specialFinishes: [(name: String, finish: CardFinish)] {
    [
      ("Codex", .codex),
      ("Golden Sweep", .goldenSweep),
      ("Starburst", .starburstGold),
      ("Psychic Wave", .psychicWave),
      ("Frozen", .frozenCrystal),
      ("Snowfall", .snowfall),
      ("Quicksilver", .quicksilver),
      ("Neon Flux", .neonFlux),
      ("Halftone Pop", .halftonePop),
      ("Spiral Rings", .spiralRings),
      ("Tidepool", .tidepool),
      ("Prism Layers", .prismLayers),
      ("Brushed Titanium", .brushedTitanium),
      ("Black Chrome", .blackChrome),
      ("Rose Gold", .roseGold),
      ("Liquid Mercury", .liquidMercury),
      ("Anodized Titanium", .anodizedTitanium),
      ("Damascus Steel", .damascusSteel),
      ("Forged Carbon", .forgedCarbon),
      ("Copper Patina", .copperPatina),
      ("Pearl Ceramic", .pearlCeramic),
      ("Oil Slick", .oilSlick),
    ] + tradingCardHoloFinishes
  }

  /// The Codex gradient foil: rainbow foil, glitter, and a light sweep.
  static var codex: CardFinish {
    CardFinish(
      cardEffects: [.foil(intensity: 0.55), .glitter(density: 60), .lightSweep],
      isFullArt: true
    )
  }

  /// The golden glitter-sweep treatment on a gold frame.
  static var goldenSweep: CardFinish {
    CardFinish(
      cardEffects: [.glitter(density: 70), .foil(intensity: 0.45), .lightSweep],
      isFullArt: true,
      isGoldFrame: true
    )
  }

  /// Radial rainbow starburst with a rotating sweep and heavy sparkle.
  static var starburstGold: CardFinish {
    CardFinish(
      cardEffects: [.starburst(intensity: 0.5), .radialSweep, .multiGlitter(density: 70)],
      isFullArt: true,
      isGoldFrame: true
    )
  }

  /// The psychic holo: foil and glitter with a following glare.
  static var psychicWave: CardFinish {
    CardFinish(
      cardEffects: [.foil(intensity: 0.5), .glitter(density: 55), .glare(intensity: 0.45)],
      isFullArt: true
    )
  }

  /// Icy silver shimmer with floating light-blue stars.
  static var frozenCrystal: CardFinish {
    CardFinish(
      cardEffects: [.frozen(intensity: 0.6), .glassSheen(intensity: 0.3, spread: 0.5)],
      isFullArt: true
    )
  }

  /// Falling snow and twinkling stars over festive tones.
  static var snowfall: CardFinish {
    CardFinish(
      cardEffects: [.snowfall(intensity: 0.65), .glitter(density: 45)],
      isFullArt: true
    )
  }

  /// Brushed polished aluminum with a diagonal rainbow reflection.
  static var quicksilver: CardFinish {
    CardFinish(
      cardEffects: [.polishedAluminum(intensity: 0.6), .lightSweep],
      isFullArt: true
    )
  }

  /// Procedural liquid-tech flow over a dark field. The flow renders on
  /// the artwork, under the chrome, so the text stays crisp.
  static var neonFlux: CardFinish {
    CardFinish(
      artEffects: [.liquidTech(intensity: 0.75, speed: 0.8, scale: 1.0)],
      cardEffects: [.glassSheen(intensity: 0.3, spread: 0.5)],
      isFullArt: true
    )
  }

  /// Pastel iridescent halftone dots.
  static var halftonePop: CardFinish {
    CardFinish(
      cardEffects: [.halftonePastel(intensity: 0.55, dotDensity: 34, waveSpeed: 0.8),
                    .lightSweep],
      isFullArt: true
    )
  }

  /// Concentric golden spiral rings.
  static var spiralRings: CardFinish {
    CardFinish(
      cardEffects: [.spiralRings(intensity: 0.5), .glitter(density: 45)],
      isFullArt: true,
      isGoldFrame: true
    )
  }

  /// Water caustics rippling across the artwork, under the chrome.
  static var tidepool: CardFinish {
    CardFinish(
      artEffects: [.water(colorBack: SIMD4<Float>(0.16, 0.35, 0.45, 1.0),
                          highlights: 0.09, edges: 0.8, waves: 0.3, caustic: 0.1,
                          size: 1.0, speed: 0.8, scale: 0.8)],
      cardEffects: [.glassSheen(intensity: 0.25, spread: 0.5), .lightSweep],
      isFullArt: true
    )
  }

  /// The layered-holo split: luminance-blended rainbow under beams.
  static var prismLayers: CardFinish {
    CardFinish(
      cardEffects: [.blendedHolo(intensity: 0.4, saturation: 0.8),
                    .verticalBeams(intensity: 0.25),
                    .sparkles],
      isFullArt: true
    )
  }
}
