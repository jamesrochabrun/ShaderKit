//
//  CardModel.swift
//  ShaderCards
//
//  The complete data model for a trading card.
//

import Foundation

/// All data needed to render a trading card.
///
/// Create one directly, or use ``CardBuilder`` for a fluent API:
/// ```swift
/// let card = CardModel(
///   name: "Emberfox",
///   element: .fire,
///   hp: 120,
///   rarity: .holoRare,
///   artwork: .emberfox,
///   attacks: [
///     CardAttack(cost: [.fire, .colorless], name: "Cinder Dash", damage: "50")
///   ]
/// )
/// ```
public struct CardModel: Identifiable, Equatable, Sendable {
  public var id: UUID
  public var name: String
  public var element: ElementType
  public var hp: Int
  public var stage: CardStage
  public var rarity: CardRarity
  /// Artwork rendered in the art window: a built-in procedural scene or
  /// a user-provided image.
  public var art: CardArt
  /// Explicit face layout. `nil` follows the rarity: ultra rare and
  /// above render full-art, everything else framed.
  public var layout: CardLayout?
  /// Explicit holographic finish. `nil` derives the finish from the
  /// rarity. Special-edition cards carry their bespoke foil here.
  public var finish: CardFinish?
  public var ability: CardAbility?
  public var attacks: [CardAttack]
  public var weakness: ElementType?
  public var resistance: ElementType?
  /// Retreat cost in colorless energy (0–4).
  public var retreatCost: Int
  /// Species line printed under the art, e.g. "Ember Fox".
  public var species: String
  /// Flavor text printed in the lower info box.
  public var flavorText: String?
  /// Card number within its set, e.g. "007/151".
  public var setNumber: String
  public var illustrator: String

  public init(
    id: UUID = UUID(),
    name: String,
    element: ElementType,
    hp: Int,
    stage: CardStage = .basic,
    rarity: CardRarity = .common,
    art: CardArt,
    layout: CardLayout? = nil,
    finish: CardFinish? = nil,
    ability: CardAbility? = nil,
    attacks: [CardAttack] = [],
    weakness: ElementType? = nil,
    resistance: ElementType? = nil,
    retreatCost: Int = 1,
    species: String = "",
    flavorText: String? = nil,
    setNumber: String = "001/151",
    illustrator: String = "ShaderCards"
  ) {
    self.id = id
    self.name = name
    self.element = element
    self.hp = hp
    self.stage = stage
    self.rarity = rarity
    self.art = art
    self.layout = layout
    self.finish = finish
    self.ability = ability
    self.attacks = attacks
    self.weakness = weakness
    self.resistance = resistance
    self.retreatCost = retreatCost
    self.species = species
    self.flavorText = flavorText
    self.setNumber = setNumber
    self.illustrator = illustrator
  }

  /// Creates a card with a built-in procedural artwork.
  public init(
    id: UUID = UUID(),
    name: String,
    element: ElementType,
    hp: Int,
    stage: CardStage = .basic,
    rarity: CardRarity = .common,
    artwork: CardArtwork,
    layout: CardLayout? = nil,
    finish: CardFinish? = nil,
    ability: CardAbility? = nil,
    attacks: [CardAttack] = [],
    weakness: ElementType? = nil,
    resistance: ElementType? = nil,
    retreatCost: Int = 1,
    species: String = "",
    flavorText: String? = nil,
    setNumber: String = "001/151",
    illustrator: String = "ShaderCards"
  ) {
    self.init(
      id: id,
      name: name,
      element: element,
      hp: hp,
      stage: stage,
      rarity: rarity,
      art: .procedural(artwork),
      layout: layout,
      finish: finish,
      ability: ability,
      attacks: attacks,
      weakness: weakness,
      resistance: resistance,
      retreatCost: retreatCost,
      species: species,
      flavorText: flavorText,
      setNumber: setNumber,
      illustrator: illustrator
    )
  }

  /// Display name including any stage suffix (e.g. "Emberfox ex").
  public var displayName: String {
    if let suffix = stage.nameSuffix {
      return "\(name) \(suffix)"
    }
    return name
  }

  /// The layout this card renders with: the explicit ``layout`` if set,
  /// otherwise derived from the finish (full-art rarities bleed).
  func resolvedLayout(for finish: CardFinish) -> CardLayout {
    layout ?? (finish.isFullArt ? .fullArt : .framed)
  }
}
