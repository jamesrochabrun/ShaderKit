//
//  CardRarity.swift
//  ShaderCards
//
//  Rarity tiers, their symbols, and display metadata.
//

import SwiftUI

/// The rarity tier of a card.
///
/// Rarity determines the symbol printed in the card footer and the
/// default holographic treatment applied by ``CardFinish``.
public enum CardRarity: String, CaseIterable, Codable, Sendable, Identifiable {
  /// Black circle. No foil.
  case common
  /// Black diamond. No foil.
  case uncommon
  /// Black star. Optionally holo.
  case rare
  /// Black star with holo art window.
  case holoRare
  /// Foil card body with matte art window.
  case reverseHolo
  /// Two black stars. EX-style foil.
  case doubleRare
  /// Silver star. Full-art foil.
  case ultraRare
  /// Gold star with textured full-art illustration.
  case illustrationRare
  /// Layered gold stars, alternate full-art treatment.
  case specialIllustrationRare
  /// Rainbow gradient treatment over the entire card.
  case rainbowRare
  /// Gold body with intense metallic sparkle.
  case hyperRare
  /// Radiant treatment: metallic crosshatch foil.
  case radiant
  /// Amazing-rare treatment: galaxy swirl bleeding past the art window.
  case amazing

  public var id: String { rawValue }

  /// Human-readable name for galleries and accessibility labels.
  public var displayName: String {
    switch self {
    case .common: "Common"
    case .uncommon: "Uncommon"
    case .rare: "Rare"
    case .holoRare: "Holo Rare"
    case .reverseHolo: "Reverse Holo"
    case .doubleRare: "Double Rare"
    case .ultraRare: "Ultra Rare"
    case .illustrationRare: "Illustration Rare"
    case .specialIllustrationRare: "Special Illustration Rare"
    case .rainbowRare: "Rainbow Rare"
    case .hyperRare: "Hyper Rare"
    case .radiant: "Radiant"
    case .amazing: "Amazing Rare"
    }
  }

  /// The footer symbol for this rarity.
  var symbol: RaritySymbol {
    switch self {
    case .common: RaritySymbol(shape: .circle, color: .black, count: 1)
    case .uncommon: RaritySymbol(shape: .diamond, color: .black, count: 1)
    case .rare, .holoRare, .reverseHolo: RaritySymbol(shape: .star, color: .black, count: 1)
    case .doubleRare: RaritySymbol(shape: .star, color: .black, count: 2)
    case .ultraRare: RaritySymbol(shape: .star, color: Color(white: 0.75), count: 2)
    case .illustrationRare: RaritySymbol(shape: .star, color: Color(red: 0.85, green: 0.68, blue: 0.25), count: 1)
    case .specialIllustrationRare: RaritySymbol(shape: .star, color: Color(red: 0.85, green: 0.68, blue: 0.25), count: 2)
    case .rainbowRare, .hyperRare: RaritySymbol(shape: .star, color: Color(red: 0.85, green: 0.68, blue: 0.25), count: 3)
    case .radiant: RaritySymbol(shape: .radiantStar, color: Color(red: 0.85, green: 0.35, blue: 0.30), count: 1)
    case .amazing: RaritySymbol(shape: .star, color: Color(red: 0.45, green: 0.30, blue: 0.75), count: 1)
    }
  }
}

/// Geometry + color spec for the rarity symbol drawn in the card footer.
struct RaritySymbol: Equatable {
  enum Shape { case circle, diamond, star, radiantStar }
  let shape: Shape
  let color: Color
  let count: Int
}
