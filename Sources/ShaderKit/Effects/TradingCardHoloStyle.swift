//
//  TradingCardHoloStyle.swift
//  ShaderKit
//
//  A complete catalog of modern trading-card foil constructions.
//

/// Named holographic treatments modeled after physical Sword & Shield-era
/// collectible-card finishes. Related treatments intentionally share a GPU
/// family while retaining their distinct glare, contrast, and masking recipe.
public enum TradingCardHoloStyle: Int, CaseIterable, Identifiable, Sendable {
  case regularHolo
  case cosmosHolo
  case reverseHolo
  case radiantHolo
  case amazingRare
  case vRegular
  case vMax
  case vStar
  case vFullArt
  case rainbowRare
  case rainbowAlternate
  case secretRareGold
  case shinyRare
  case shinyV
  case shinyVMax
  case trainerFullArt
  case trainerGalleryHolo
  case trainerGallerySecretRare
  case trainerGalleryV
  case trainerGalleryVMax
  case pikachuSecretRare

  public var id: Self { self }

  /// A concise name suitable for menus, galleries, and layer labels.
  public var displayName: String {
    switch self {
    case .regularHolo: "Regular Holo"
    case .cosmosHolo: "Cosmos Holo"
    case .reverseHolo: "Reverse Holo"
    case .radiantHolo: "Radiant Holo"
    case .amazingRare: "Amazing Rare"
    case .vRegular: "V Regular"
    case .vMax: "VMAX"
    case .vStar: "VSTAR"
    case .vFullArt: "V Full Art"
    case .rainbowRare: "Rainbow Rare"
    case .rainbowAlternate: "Rainbow Alternate"
    case .secretRareGold: "Secret Rare Gold"
    case .shinyRare: "Shiny Rare"
    case .shinyV: "Shiny V"
    case .shinyVMax: "Shiny VMAX"
    case .trainerFullArt: "Trainer Full Art"
    case .trainerGalleryHolo: "Trainer Gallery Holo"
    case .trainerGallerySecretRare: "Trainer Gallery Gold"
    case .trainerGalleryV: "Trainer Gallery V"
    case .trainerGalleryVMax: "Trainer Gallery VMAX"
    case .pikachuSecretRare: "Pikachu Secret Rare"
    }
  }

  /// The upstream treatment sheet represented by this procedural style.
  /// This is useful for documentation, QA tooling, and catalog migrations.
  public var referenceSheetName: String {
    switch self {
    case .regularHolo: "regular-holo.css"
    case .cosmosHolo: "cosmos-holo.css"
    case .reverseHolo: "reverse-holo.css"
    case .radiantHolo: "radiant-holo.css"
    case .amazingRare: "amazing-rare.css"
    case .vRegular: "v-regular.css"
    case .vMax: "v-max.css"
    case .vStar: "v-star.css"
    case .vFullArt: "v-full-art.css"
    case .rainbowRare: "rainbow-holo.css"
    case .rainbowAlternate: "rainbow-alt.css"
    case .secretRareGold: "secret-rare.css"
    case .shinyRare: "shiny-rare.css"
    case .shinyV: "shiny-v.css"
    case .shinyVMax: "shiny-vmax.css"
    case .trainerFullArt: "trainer-full-art.css"
    case .trainerGalleryHolo: "trainer-gallery-holo.css"
    case .trainerGallerySecretRare: "trainer-gallery-secret-rare.css"
    case .trainerGalleryV: "trainer-gallery-v-regular.css"
    case .trainerGalleryVMax: "trainer-gallery-v-max.css"
    case .pikachuSecretRare: "swsh-pikachu.css"
    }
  }
}
