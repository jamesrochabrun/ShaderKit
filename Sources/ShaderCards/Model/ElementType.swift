//
//  ElementType.swift
//  ShaderCards
//
//  The elemental types that drive card colors, icons, and holo tints.
//

import SwiftUI

/// The elemental identity of a card.
///
/// Each element defines the card's frame palette, energy icon, and the
/// default tinting used by holographic treatments.
public enum ElementType: String, CaseIterable, Codable, Sendable, Identifiable {
  case grass
  case fire
  case water
  case lightning
  case psychic
  case fighting
  case darkness
  case metal
  case fairy
  case dragon
  case colorless

  public var id: String { rawValue }

  /// Display name shown on cards and in galleries.
  public var displayName: String {
    rawValue.prefix(1).uppercased() + rawValue.dropFirst()
  }

  /// The SF Symbol used inside the element's energy icon.
  public var symbolName: String {
    switch self {
    case .grass: "leaf.fill"
    case .fire: "flame.fill"
    case .water: "drop.fill"
    case .lightning: "bolt.fill"
    case .psychic: "eye.fill"
    case .fighting: "figure.boxing"
    case .darkness: "moon.fill"
    case .metal: "gearshape.fill"
    case .fairy: "sparkles"
    case .dragon: "fossil.shell.fill"
    case .colorless: "star.fill"
    }
  }
}
