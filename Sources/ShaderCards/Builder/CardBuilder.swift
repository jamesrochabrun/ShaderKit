//
//  CardBuilder.swift
//  ShaderCards
//
//  Fluent builder for composing custom cards.
//

import Foundation
import ShaderKit

/// A fluent builder for custom creature cards.
///
/// ```swift
/// let card = CardBuilder(name: "Solarix", element: .fire)
///   .hp(160)
///   .stage(.ex)
///   .rarity(.hyperRare)
///   .artwork(.pyroclaw)
///   .ability("Solar Core", text: "Once during your turn, heal 30 damage from this card.")
///   .attack("Nova Burst", cost: [.fire, .fire], damage: "150")
///   .weakness(.water)
///   .retreat(2)
///   .flavor("Forged in the heart of a dying star.")
///   .build()
/// ```
public struct CardBuilder {
  private var model: CardModel

  /// Starts building a card with a name and element.
  /// The artwork defaults to the first artwork of that element.
  public init(name: String, element: ElementType) {
    let defaultArtwork = CardArtwork.allCases.first { $0.element == element } ?? .emberfox
    self.model = CardModel(
      name: name,
      element: element,
      hp: 60,
      artwork: defaultArtwork
    )
  }

  /// Sets the hit points.
  public func hp(_ value: Int) -> CardBuilder {
    mutating { $0.hp = value }
  }

  /// Sets the evolution stage or special mechanic.
  public func stage(_ value: CardStage) -> CardBuilder {
    mutating { $0.stage = value }
  }

  /// Sets the rarity, which selects the holographic finish.
  public func rarity(_ value: CardRarity) -> CardBuilder {
    mutating { $0.rarity = value }
  }

  /// Sets a built-in procedural artwork.
  public func artwork(_ value: CardArtwork) -> CardBuilder {
    mutating { $0.art = .procedural(value) }
  }

  /// Sets a custom image (PNG/JPEG/HEIC data) as the artwork.
  public func artwork(imageData: Data) -> CardBuilder {
    mutating { $0.art = .image(imageData) }
  }

  /// Sets the artwork source directly.
  public func art(_ value: CardArt) -> CardBuilder {
    mutating { $0.art = value }
  }

  /// Forces a face layout. Pass `nil` to follow the rarity
  /// (full-art rarities bleed, everything else is framed).
  public func layout(_ value: CardLayout?) -> CardBuilder {
    mutating { $0.layout = value }
  }

  /// Sets a bespoke holographic finish. Pass `nil` to derive it from
  /// the rarity. See `CardFinish` for the named special finishes.
  public func finish(_ value: CardFinish?) -> CardBuilder {
    mutating { $0.finish = value }
  }

  /// Adds the passive ability.
  public func ability(_ name: String, text: String) -> CardBuilder {
    mutating { $0.ability = CardAbility(name: name, text: text) }
  }

  /// Appends an attack.
  public func attack(
    _ name: String,
    cost: [ElementType],
    damage: String = "",
    text: String? = nil
  ) -> CardBuilder {
    mutating { $0.attacks.append(CardAttack(cost: cost, name: name, damage: damage, text: text)) }
  }

  /// Sets the weakness element.
  public func weakness(_ element: ElementType?) -> CardBuilder {
    mutating { $0.weakness = element }
  }

  /// Sets the resistance element.
  public func resistance(_ element: ElementType?) -> CardBuilder {
    mutating { $0.resistance = element }
  }

  /// Sets the retreat cost (0–4).
  public func retreat(_ cost: Int) -> CardBuilder {
    mutating { $0.retreatCost = max(0, min(cost, 4)) }
  }

  /// Sets the species line shown under the art window.
  public func species(_ value: String) -> CardBuilder {
    mutating { $0.species = value }
  }

  /// Sets the flavor text.
  public func flavor(_ text: String?) -> CardBuilder {
    mutating { $0.flavorText = text }
  }

  /// Sets the collector number, e.g. "007/151".
  public func setNumber(_ value: String) -> CardBuilder {
    mutating { $0.setNumber = value }
  }

  /// Sets the illustrator credit.
  public func illustrator(_ value: String) -> CardBuilder {
    mutating { $0.illustrator = value }
  }

  /// Finishes building and returns the card.
  public func build() -> Card {
    .creature(model)
  }

  /// Finishes building and returns the raw creature model.
  public func buildModel() -> CardModel {
    model
  }

  private func mutating(_ change: (inout CardModel) -> Void) -> CardBuilder {
    var copy = self
    change(&copy.model)
    return copy
  }
}
