//
//  Card.swift
//  ShaderCards
//
//  Card kinds: creature, trainer, and energy cards under one umbrella type.
//

import Foundation

/// Any card the library can render: creature, trainer, or energy.
public enum Card: Identifiable, Equatable, Sendable {
  case creature(CardModel)
  case trainer(TrainerCardModel)
  case energy(EnergyCardModel)

  public var id: UUID {
    switch self {
    case .creature(let model): model.id
    case .trainer(let model): model.id
    case .energy(let model): model.id
    }
  }

  /// Name shown in galleries.
  public var displayName: String {
    switch self {
    case .creature(let model): model.displayName
    case .trainer(let model): model.name
    case .energy(let model): "\(model.element.displayName) Energy"
    }
  }

  /// The rarity used to pick the holo finish.
  public var rarity: CardRarity {
    switch self {
    case .creature(let model): model.rarity
    case .trainer(let model): model.rarity
    case .energy(let model): model.isSpecial ? .holoRare : .common
    }
  }

  /// The finish this card renders with when no override is supplied:
  /// the model's bespoke finish, special-energy beams, or the rarity's.
  public var resolvedFinish: CardFinish {
    switch self {
    case .creature(let model):
      model.finish ?? .finish(for: model.rarity)
    case .trainer(let model):
      model.finish ?? .finish(for: model.rarity)
    case .energy(let model):
      model.isSpecial
        ? CardFinish(cardEffects: [
            .verticalBeams(intensity: 0.55),
            .glassSheen(intensity: 0.3, spread: 0.5),
          ])
        : CardFinish()
    }
  }
}

/// The category of a trainer card, shown in its header banner.
public enum TrainerKind: String, Codable, Sendable {
  case supporter
  case item
  case stadium

  public var displayName: String {
    rawValue.prefix(1).uppercased() + rawValue.dropFirst()
  }
}

/// A trainer card: supporter, item, or stadium.
public struct TrainerCardModel: Identifiable, Equatable, Sendable {
  public var id: UUID
  public var name: String
  public var kind: TrainerKind
  public var rarity: CardRarity
  /// Rules text printed in the body.
  public var text: String
  /// Procedural artwork rendered in the art window.
  public var artwork: TrainerArtwork
  /// Explicit holographic finish. `nil` derives the finish from rarity.
  public var finish: CardFinish?
  public var setNumber: String
  public var illustrator: String

  public init(
    id: UUID = UUID(),
    name: String,
    kind: TrainerKind,
    rarity: CardRarity = .uncommon,
    text: String,
    artwork: TrainerArtwork,
    finish: CardFinish? = nil,
    setNumber: String = "120/151",
    illustrator: String = "ShaderCards"
  ) {
    self.id = id
    self.name = name
    self.kind = kind
    self.rarity = rarity
    self.text = text
    self.artwork = artwork
    self.finish = finish
    self.setNumber = setNumber
    self.illustrator = illustrator
  }
}

/// Abstract procedural scenes for trainer cards.
public enum TrainerArtwork: String, CaseIterable, Codable, Sendable {
  case potion
  case researchLab
  case travelMap
  case trainingGrounds
  case crystalCavern
  case midnightMarket
}

/// A basic or special energy card.
public struct EnergyCardModel: Identifiable, Equatable, Sendable {
  public var id: UUID
  public var element: ElementType
  /// Special energies get a holo treatment and bespoke naming.
  public var isSpecial: Bool
  public var setNumber: String

  public init(
    id: UUID = UUID(),
    element: ElementType,
    isSpecial: Bool = false,
    setNumber: String = "140/151"
  ) {
    self.id = id
    self.element = element
    self.isSpecial = isSpecial
    self.setNumber = setNumber
  }
}
