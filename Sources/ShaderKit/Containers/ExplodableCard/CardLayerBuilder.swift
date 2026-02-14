//
//  CardLayerBuilder.swift
//  ShaderKit
//
//  Result builder for ergonomic layer declaration in ExplodableHolographicCard
//

import SwiftUI

/// A result builder that enables declarative layer composition for explodable cards.
///
/// Use with `ExplodableHolographicCard` to define discrete layers:
/// ```swift
/// ExplodableHolographicCard(width: 260, height: 380) {
///   CardLayer {
///     RoundedRectangle(cornerRadius: 16)
///       .fill(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
///   }
///   .effects([.foil()])
///   .zIndex(0)
///
///   CardLayer {
///     Image("artwork")
///       .resizable()
///       .aspectRatio(contentMode: .fill)
///   }
///   .effects([.simpleGlare()])
///   .zIndex(1)
/// }
/// ```
@resultBuilder
public struct CardLayerBuilder {
  public static func buildBlock(_ components: CardLayer...) -> [CardLayer] {
    components
  }

  public static func buildArray(_ components: [[CardLayer]]) -> [CardLayer] {
    components.flatMap { $0 }
  }

  public static func buildOptional(_ component: CardLayer?) -> [CardLayer] {
    component.map { [$0] } ?? []
  }

  public static func buildEither(first component: CardLayer) -> CardLayer {
    component
  }

  public static func buildEither(second component: CardLayer) -> CardLayer {
    component
  }
}
