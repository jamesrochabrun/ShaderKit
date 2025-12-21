//
//  ShaderContext.swift
//  ShaderKit
//
//  Environment-based shader context for tilt and time
//

import SwiftUI

/// Context for shader effects containing tilt position and elapsed time.
///
/// Inject context at a parent level and all child shader effects will use it:
/// ```swift
/// CardContent()
///     .shaderContext(tilt: tilt, time: elapsedTime)
///     .foil()
///     .glitter()
/// ```
public struct ShaderContext: Equatable, Sendable {
  /// The tilt position, typically from device motion or drag gestures.
  /// Values are normalized to roughly -1 to 1 range.
  public var tilt: CGPoint
  
  /// The elapsed time since the effect started, used for animations.
  public var time: TimeInterval
  
  /// Creates a shader context with the given tilt and time values.
  public init(tilt: CGPoint = .zero, time: TimeInterval = 0) {
    self.tilt = tilt
    self.time = time
  }
}

// MARK: - Environment Key

private struct ShaderContextKey: EnvironmentKey {
  static let defaultValue = ShaderContext()
}

public extension EnvironmentValues {
  /// The current shader context containing tilt and time for shader effects.
  var shaderContext: ShaderContext {
    get { self[ShaderContextKey.self] }
    set { self[ShaderContextKey.self] = newValue }
  }
}

// MARK: - View Extension

public extension View {
  /// Provides shader context (tilt and time) to child views.
  ///
  /// Child views using `.shader(_:)` or convenience methods like `.foil()`
  /// will automatically use these values unless explicitly overridden.
  ///
  /// - Parameters:
  ///   - tilt: The tilt position from device motion or drag
  ///   - time: The elapsed time for animations
  /// - Returns: A view with shader context injected
  func shaderContext(tilt: CGPoint, time: TimeInterval) -> some View {
    environment(\.shaderContext, ShaderContext(tilt: tilt, time: time))
  }
}
