//
//  SpringPhysics.swift
//  ShaderKitUI
//
//  Spring physics engine for animations.
//

/// A spring physics simulation for smooth, natural animations.
///
/// Uses Hooke's law with damping to create realistic spring motion.
/// The spring oscillates around zero and can be used for various
/// physics-based UI effects.
///
/// Example:
/// ```swift
/// var spring = Spring(mass: 1, stiffness: 1000, damping: 10)
/// spring.velocity = -5 // Apply an impulse
/// spring.update(dt: 0.016) // Update each frame
/// let displacement = spring.value
/// ```
public struct Spring {
  /// Current displacement from rest position
  public var value: Float = 0

  /// Current velocity
  public var velocity: Float = 0

  /// Mass of the spring system
  public let mass: Float

  /// Spring stiffness (higher = stiffer, faster oscillation)
  public let stiffness: Float

  /// Damping coefficient (higher = less oscillation)
  public let damping: Float

  /// Creates a new spring with the specified physical properties.
  ///
  /// - Parameters:
  ///   - mass: Mass of the spring system (default: 1)
  ///   - stiffness: Spring stiffness coefficient
  ///   - damping: Damping coefficient
  public init(mass: Float = 1, stiffness: Float, damping: Float) {
    self.mass = mass
    self.stiffness = stiffness
    self.damping = damping
  }

  /// Updates the spring simulation by one time step.
  ///
  /// - Parameter dt: Time delta in seconds
  public mutating func update(dt: Float) {
    let springForce = -stiffness * value
    let dampingForce = -damping * velocity
    let acceleration = (springForce + dampingForce) / mass
    velocity = velocity + acceleration * dt
    value = value + velocity * dt
  }
}
