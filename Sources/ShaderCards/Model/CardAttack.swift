//
//  CardAttack.swift
//  ShaderCards
//
//  Attack and ability rows printed on the card body.
//

import Foundation

/// An attack printed on a card: energy cost, name, damage, and rules text.
public struct CardAttack: Identifiable, Equatable, Codable, Sendable {
  public var id: UUID
  /// Energy icons shown before the attack name.
  public var cost: [ElementType]
  public var name: String
  /// Damage string, e.g. "120", "60+", "30×". Empty for pure-effect attacks.
  public var damage: String
  /// Optional rules text printed under the attack name.
  public var text: String?

  public init(
    id: UUID = UUID(),
    cost: [ElementType],
    name: String,
    damage: String = "",
    text: String? = nil
  ) {
    self.id = id
    self.cost = cost
    self.name = name
    self.damage = damage
    self.text = text
  }
}

/// A passive ability printed above attacks.
public struct CardAbility: Equatable, Codable, Sendable {
  public var name: String
  public var text: String

  public init(name: String, text: String) {
    self.name = name
    self.text = text
  }
}
