//
//  CardLayout.swift
//  ShaderCards
//
//  The frame layouts a creature card can use, independent of rarity.
//

import Foundation

/// How a creature card's face is laid out.
///
/// By default the layout follows the rarity (ultra rares and above are
/// full-art). Set ``CardModel/layout`` to force one explicitly — e.g. a
/// full-bleed photo card at common rarity, or a minimal poster card.
public enum CardLayout: String, CaseIterable, Codable, Sendable, Identifiable {
  /// Classic frame: artwork inside a beveled window, stats below.
  case framed
  /// Edge-to-edge artwork with the stats chrome floating on scrims.
  case fullArt
  /// Poster style: edge-to-edge artwork with just the name banner and
  /// info line — no attacks or battle stats.
  case minimal

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .framed: "Framed"
    case .fullArt: "Full Art"
    case .minimal: "Minimal"
    }
  }
}
