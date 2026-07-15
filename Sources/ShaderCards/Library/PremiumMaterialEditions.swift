//
//  PremiumMaterialEditions.swift
//  ShaderCards
//
//  Showcase cards for ShaderKit's opaque premium material shaders.
//

import SwiftUI

public extension CardLibrary {
  /// The ten cards that showcase ShaderKit's opaque premium materials.
  static var premiumMaterialCards: [Card] {
    [
      titan, nocturne, aurelia, mercury, spectrum,
      damascus, monocoque, verdigris, nacre, interference,
    ].map { .creature($0) }
  }

  /// Satin brushed titanium over a cool industrial gradient.
  static let titan = CardModel(
    name: "Titan",
    element: .metal,
    hp: 230,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.20, green: 0.25, blue: 0.32),
      Color(red: 0.52, green: 0.59, blue: 0.68),
      Color(red: 0.16, green: 0.20, blue: 0.27),
    ]),
    layout: .minimal,
    finish: .brushedTitanium,
    species: "Material Edition",
    setNumber: "065/151"
  )

  /// Mirror-black chrome with a faint spectral edge.
  static let nocturne = CardModel(
    name: "Nocturne",
    element: .darkness,
    hp: 220,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.015, green: 0.020, blue: 0.035),
      Color(red: 0.10, green: 0.12, blue: 0.17),
      Color(red: 0.025, green: 0.030, blue: 0.050),
    ]),
    layout: .minimal,
    finish: .blackChrome,
    species: "Material Edition",
    setNumber: "066/151"
  )

  /// Warm pink copper under a jewel-like gloss.
  static let aurelia = CardModel(
    name: "Aurelia",
    element: .fairy,
    hp: 190,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.40, green: 0.12, blue: 0.12),
      Color(red: 0.88, green: 0.51, blue: 0.42),
      Color(red: 0.58, green: 0.20, blue: 0.18),
    ]),
    layout: .minimal,
    finish: .roseGold,
    species: "Material Edition",
    setNumber: "067/151"
  )

  /// Fluid mirror silver that rolls as the card moves.
  static let mercury = CardModel(
    name: "Mercury",
    element: .metal,
    hp: 210,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.12, green: 0.16, blue: 0.22),
      Color(red: 0.74, green: 0.80, blue: 0.88),
      Color(red: 0.18, green: 0.23, blue: 0.31),
    ]),
    layout: .minimal,
    finish: .liquidMercury,
    species: "Material Edition",
    setNumber: "068/151"
  )

  /// Heat-anodized titanium with shifting violet, cyan, and gold.
  static let spectrum = CardModel(
    name: "Spectrum",
    element: .lightning,
    hp: 200,
    rarity: .rainbowRare,
    art: .gradient([
      Color(red: 0.12, green: 0.12, blue: 0.25),
      Color(red: 0.18, green: 0.45, blue: 0.62),
      Color(red: 0.48, green: 0.20, blue: 0.52),
    ]),
    layout: .minimal,
    finish: .anodizedTitanium,
    species: "Material Edition",
    setNumber: "069/151"
  )

  /// Layer-forged steel with flowing blade-like strata.
  static let damascus = CardModel(
    name: "Damascus",
    element: .dragon,
    hp: 240,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.07, green: 0.09, blue: 0.12),
      Color(red: 0.45, green: 0.50, blue: 0.57),
      Color(red: 0.13, green: 0.16, blue: 0.20),
    ]),
    layout: .minimal,
    finish: .damascusSteel,
    species: "Material Edition",
    setNumber: "070/151"
  )

  /// Chopped carbon-fiber composite with directional flake reflections.
  static let monocoque = CardModel(
    name: "Monocoque",
    element: .darkness,
    hp: 220,
    rarity: .ultraRare,
    art: .gradient([
      Color(red: 0.012, green: 0.016, blue: 0.022),
      Color(red: 0.11, green: 0.13, blue: 0.16),
      Color(red: 0.025, green: 0.032, blue: 0.042),
    ]),
    layout: .minimal,
    finish: .forgedCarbon,
    species: "Material Edition",
    setNumber: "071/151"
  )

  /// Weathered copper with organic turquoise oxidation.
  static let verdigris = CardModel(
    name: "Verdigris",
    element: .grass,
    hp: 190,
    rarity: .illustrationRare,
    art: .gradient([
      Color(red: 0.22, green: 0.08, blue: 0.035),
      Color(red: 0.50, green: 0.22, blue: 0.08),
      Color(red: 0.04, green: 0.30, blue: 0.25),
    ]),
    layout: .minimal,
    finish: .copperPatina,
    species: "Material Edition",
    setNumber: "072/151"
  )

  /// Opaque porcelain with a nacreous rainbow glaze.
  static let nacre = CardModel(
    name: "Nacre",
    element: .water,
    hp: 180,
    rarity: .specialIllustrationRare,
    art: .gradient([
      Color(red: 0.30, green: 0.36, blue: 0.44),
      Color(red: 0.36, green: 0.48, blue: 0.56),
      Color(red: 0.52, green: 0.38, blue: 0.50),
    ]),
    layout: .minimal,
    finish: .pearlCeramic,
    species: "Material Edition",
    setNumber: "073/151"
  )

  /// Dark chrome under fluid rainbow thin-film interference.
  static let interference = CardModel(
    name: "Interference",
    element: .psychic,
    hp: 210,
    rarity: .rainbowRare,
    art: .gradient([
      Color(red: 0.015, green: 0.020, blue: 0.045),
      Color(red: 0.13, green: 0.06, blue: 0.23),
      Color(red: 0.02, green: 0.14, blue: 0.18),
    ]),
    layout: .minimal,
    finish: .oilSlick,
    species: "Material Edition",
    setNumber: "074/151"
  )
}
