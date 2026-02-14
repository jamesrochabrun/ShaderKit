//
//  CardLayer.swift
//  ShaderKit
//
//  Represents a single layer in an explodable holographic card
//

import SwiftUI

/// A discrete layer in an `ExplodableHolographicCard` that can be separated
/// and viewed independently when the card is exploded.
///
/// Each layer contains its own content view and optional shader effects:
/// ```swift
/// CardLayer {
///   RoundedRectangle(cornerRadius: 16)
///     .fill(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
/// }
/// .effects([.foil(intensity: 0.8)])
/// .label("Background")
/// ```
public struct CardLayer: Identifiable {
  public let id: UUID
  public let content: AnyView
  public var effects: [ShaderEffect]
  public var label: String?
  public var zIndex: Int

  /// Creates a card layer with the given content.
  /// - Parameter content: A view builder that provides the layer's visual content
  public init<Content: View>(@ViewBuilder content: () -> Content) {
    self.id = UUID()
    self.content = AnyView(content())
    self.effects = []
    self.label = nil
    self.zIndex = 0
  }

  /// Creates a card layer with explicit ID (useful for animations).
  /// - Parameters:
  ///   - id: A unique identifier for this layer
  ///   - content: A view builder that provides the layer's visual content
  public init<Content: View>(id: UUID = UUID(), @ViewBuilder content: () -> Content) {
    self.id = id
    self.content = AnyView(content())
    self.effects = []
    self.label = nil
    self.zIndex = 0
  }

  /// Applies shader effects to this layer.
  /// - Parameter effects: An array of shader effects to apply in order
  /// - Returns: A new layer with the specified effects
  public func effects(_ effects: [ShaderEffect]) -> CardLayer {
    var copy = self
    copy.effects = effects
    return copy
  }

  /// Sets an optional debug label for this layer.
  /// - Parameter label: A descriptive name shown when the card is exploded
  /// - Returns: A new layer with the specified label
  public func label(_ label: String) -> CardLayer {
    var copy = self
    copy.label = label
    return copy
  }

  /// Sets the z-index ordering for this layer.
  /// Higher values appear in front when collapsed, and further from viewer when exploded.
  /// - Parameter index: The z-index value (default is 0)
  /// - Returns: A new layer with the specified z-index
  public func zIndex(_ index: Int) -> CardLayer {
    var copy = self
    copy.zIndex = index
    return copy
  }
}
