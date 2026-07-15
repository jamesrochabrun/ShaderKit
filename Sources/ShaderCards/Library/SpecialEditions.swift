//
//  SpecialEditions.swift
//  ShaderCards
//
//  Special-edition cards recreating the classic ShaderKit demo foil
//  designs: gradient canvases under signature shader compositions.
//

import SwiftUI

public extension CardLibrary {

  /// The special-edition collection: one card per classic foil design.
  static var specialEditionCards: [Card] {
    specialEditions.map { .creature($0) }
  }

  internal static let specialEditions: [CardModel] = [
    codex, midas, nova, mindwave, glacier, yule,
    quicksilver, neonFlux, bubblegum, gyre, tidepool, prism,
    titan, nocturne, aurelia, mercury, spectrum, damascus,
    monocoque, verdigris, nacre, interference,
  ]

  // MARK: - The editions

  /// Homage to the Codex gradient foil card.
  static let codex = CardModel(
    name: "Codex",
    element: .psychic,
    hp: 200,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.10, green: 0.22, blue: 0.52),
      Color(red: 0.24, green: 0.16, blue: 0.55),
      Color(red: 0.45, green: 0.20, blue: 0.65),
    ]),
    layout: .minimal,
    finish: .codex,
    species: "Special Edition",
    setNumber: "053/151"
  )

  /// The golden glitter-sweep card.
  static let midas = CardModel(
    name: "Midas",
    element: .colorless,
    hp: 180,
    rarity: .hyperRare,
    art: .gradient([
      Color(red: 0.96, green: 0.88, blue: 0.56),
      Color(red: 0.90, green: 0.76, blue: 0.42),
      Color(red: 0.83, green: 0.67, blue: 0.33),
    ]),
    layout: .minimal,
    finish: .goldenSweep,
    species: "Special Edition",
    setNumber: "054/151"
  )

  /// The gold starburst-radial card.
  static let nova = CardModel(
    name: "Nova",
    element: .fire,
    hp: 220,
    rarity: .hyperRare,
    art: .gradient([
      Color(red: 0.55, green: 0.32, blue: 0.08),
      Color(red: 0.85, green: 0.58, blue: 0.18),
      Color(red: 0.98, green: 0.80, blue: 0.38),
    ]),
    layout: .minimal,
    finish: .starburstGold,
    species: "Special Edition",
    setNumber: "055/151"
  )

  /// The psychic holo card.
  static let mindwave = CardModel(
    name: "Mindwave",
    element: .psychic,
    hp: 190,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.38, green: 0.12, blue: 0.55),
      Color(red: 0.62, green: 0.20, blue: 0.62),
      Color(red: 0.88, green: 0.40, blue: 0.70),
    ]),
    layout: .minimal,
    finish: .psychicWave,
    species: "Special Edition",
    setNumber: "056/151"
  )

  /// The icy Frozen card.
  static let glacier = CardModel(
    name: "Glacier",
    element: .water,
    hp: 170,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.78, green: 0.88, blue: 0.96),
      Color(red: 0.55, green: 0.72, blue: 0.88),
      Color(red: 0.30, green: 0.48, blue: 0.70),
    ]),
    layout: .minimal,
    finish: .frozenCrystal,
    species: "Special Edition",
    setNumber: "057/151"
  )

  /// The festive snowfall card.
  static let yule = CardModel(
    name: "Yule",
    element: .grass,
    hp: 160,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.40, green: 0.06, blue: 0.10),
      Color(red: 0.16, green: 0.10, blue: 0.16),
      Color(red: 0.05, green: 0.28, blue: 0.14),
    ]),
    layout: .minimal,
    finish: .snowfall,
    species: "Special Edition",
    setNumber: "058/151"
  )

  /// The polished-aluminum card.
  static let quicksilver = CardModel(
    name: "Quicksilver",
    element: .metal,
    hp: 200,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.88, green: 0.90, blue: 0.94),
      Color(red: 0.62, green: 0.66, blue: 0.72),
      Color(red: 0.40, green: 0.44, blue: 0.52),
    ]),
    layout: .minimal,
    finish: .quicksilver,
    species: "Special Edition",
    setNumber: "059/151"
  )

  /// The liquid-tech card.
  static let neonFlux = CardModel(
    name: "Neon Flux",
    element: .darkness,
    hp: 210,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.03, green: 0.05, blue: 0.12),
      Color(red: 0.06, green: 0.10, blue: 0.22),
      Color(red: 0.10, green: 0.16, blue: 0.30),
    ]),
    layout: .minimal,
    finish: .neonFlux,
    species: "Special Edition",
    setNumber: "060/151"
  )

  /// The halftone-pastel card.
  static let bubblegum = CardModel(
    name: "Bubblegum",
    element: .fairy,
    hp: 150,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.98, green: 0.75, blue: 0.85),
      Color(red: 0.85, green: 0.80, blue: 0.95),
      Color(red: 0.70, green: 0.92, blue: 0.90),
    ]),
    layout: .minimal,
    finish: .halftonePop,
    species: "Special Edition",
    setNumber: "061/151"
  )

  /// The golden spiral-rings card.
  static let gyre = CardModel(
    name: "Gyre",
    element: .dragon,
    hp: 230,
    rarity: .hyperRare,
    art: .gradient([
      Color(red: 0.28, green: 0.20, blue: 0.06),
      Color(red: 0.50, green: 0.38, blue: 0.12),
      Color(red: 0.72, green: 0.58, blue: 0.22),
    ]),
    layout: .minimal,
    finish: .spiralRings,
    species: "Special Edition",
    setNumber: "062/151"
  )

  /// The water-caustics card.
  static let tidepool = CardModel(
    name: "Tidepool",
    element: .water,
    hp: 180,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.35, green: 0.55, blue: 0.62),
      Color(red: 0.22, green: 0.42, blue: 0.52),
      Color(red: 0.12, green: 0.28, blue: 0.40),
    ]),
    layout: .minimal,
    finish: .tidepool,
    species: "Special Edition",
    setNumber: "063/151"
  )

  /// The layered-holo split card — clean artwork over blended rainbow.
  static let prism = CardModel(
    name: "Prism",
    element: .colorless,
    hp: 190,
    rarity: .ultraRare,
    artwork: .prismpaw,
    layout: .fullArt,
    finish: .prismLayers,
    ability: CardAbility(
      name: "Refraction",
      text: "Whenever this card takes damage, flip a coin. If heads, prevent half of it."
    ),
    attacks: [
      CardAttack(cost: [.colorless, .colorless], name: "Spectrum Slash", damage: "120"),
    ],
    retreatCost: 1,
    species: "Special Edition",
    setNumber: "064/151"
  )
}
