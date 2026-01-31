//
//  Spring.swift
//  ShaderKit
//
//  Damped spring physics simulation for smooth animations
//

import Foundation

/// A damped spring physics simulation.
///
/// Use this for smooth, physics-based animations that respond naturally to changes:
/// ```swift
/// @State private var spring = DampedSpring(stiffness: 1000, damping: 10)
///
/// // In physics update loop:
/// spring.target = newValue
/// spring.update(dt: deltaTime)
/// // Use spring.value for animation
/// ```
@Observable
public final class DampedSpring {
  /// Current animated value
  public var value: Float = 0

  /// Target value the spring is moving toward
  public var target: Float = 0

  /// Current velocity
  public var velocity: Float = 0

  /// Mass of the spring system (affects momentum)
  public let mass: Float

  /// Spring stiffness (higher = faster response)
  public let stiffness: Float

  /// Damping factor (higher = less oscillation)
  public let damping: Float

  /// Creates a new spring with the given parameters.
  /// - Parameters:
  ///   - value: Initial value (default 0)
  ///   - mass: Mass of the system (default 1)
  ///   - stiffness: Spring stiffness (default 1000)
  ///   - damping: Damping factor (default 10)
  public init(
    value: Float = 0,
    mass: Float = 1,
    stiffness: Float = 1000,
    damping: Float = 10
  ) {
    self.value = value
    self.target = value
    self.mass = mass
    self.stiffness = stiffness
    self.damping = damping
  }

  /// Updates the spring physics by one time step.
  /// - Parameter dt: Delta time in seconds
  public func update(dt: Float) {
    let springForce = -stiffness * (value - target)
    let dampingForce = -damping * velocity
    let acceleration = (springForce + dampingForce) / mass
    velocity += acceleration * dt
    value += velocity * dt
  }

  /// Immediately sets value and target, resetting velocity.
  /// - Parameter newValue: The new value to snap to
  public func snap(to newValue: Float) {
    value = newValue
    target = newValue
    velocity = 0
  }
}
