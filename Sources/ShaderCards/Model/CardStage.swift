//
//  CardStage.swift
//  ShaderCards
//
//  Evolution stage / card kind badge shown in the header area.
//

import Foundation

/// The evolution stage or special mechanic of a creature card.
public enum CardStage: String, Codable, Sendable, Equatable {
  case basic
  case stage1
  case stage2
  /// Oversized "ex"-style powered-up card.
  case ex
  /// Full-art V-style card.
  case vStyle
  /// Giant VMAX-style card.
  case vMax

  /// Label shown in the stage badge, e.g. "BASIC" or "Stage 1".
  public var badgeText: String {
    switch self {
    case .basic: "Basic"
    case .stage1: "Stage 1"
    case .stage2: "Stage 2"
    case .ex: "Basic"
    case .vStyle: "Basic"
    case .vMax: "VMAX"
    }
  }

  /// Suffix appended to the display name, e.g. "ex" or "V".
  public var nameSuffix: String? {
    switch self {
    case .ex: "ex"
    case .vStyle: "V"
    case .vMax: "VMAX"
    default: nil
    }
  }
}
