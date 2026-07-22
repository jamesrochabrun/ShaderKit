//
//  MotionManager.swift
//  ShaderKitDemo
//
//  Demo-only device-motion helper. Exposes a normalized tilt (roll/pitch
//  mapped to -1...1) that shader showcases use to drive parallax and
//  holographic response. Falls back to a neutral, unavailable state on
//  platforms without CoreMotion device motion.
//

import SwiftUI

#if canImport(CoreMotion)
import CoreMotion
#endif

@Observable
final class MotionManager {
  /// Normalized device tilt. `x` follows roll, `y` follows pitch, each
  /// clamped to -1...1. `.zero` when motion is unavailable or stopped.
  private(set) var tilt: CGPoint = .zero

  /// Whether live device-motion updates are being delivered.
  private(set) var isAvailable: Bool = false

  /// Roll/pitch angle (radians) that maps to full deflection (±1).
  private let maxTiltAngle: Double = .pi / 4

  #if os(iOS)
  private let manager = CMMotionManager()
  #endif

  func start() {
    #if canImport(CoreMotion) && os(iOS)
    guard manager.isDeviceMotionAvailable else {
      isAvailable = false
      return
    }
    isAvailable = true
    manager.deviceMotionUpdateInterval = 1.0 / 60.0
    manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let self, let motion else { return }
      let roll = motion.attitude.roll
      let pitch = motion.attitude.pitch
      self.tilt = CGPoint(
        x: Self.normalize(roll, max: self.maxTiltAngle),
        y: Self.normalize(pitch, max: self.maxTiltAngle)
      )
    }
    #else
    isAvailable = false
    #endif
  }

  func stop() {
    #if canImport(CoreMotion) && os(iOS)
    manager.stopDeviceMotionUpdates()
    #endif
    isAvailable = false
    tilt = .zero
  }

  private static func normalize(_ value: Double, max: Double) -> CGFloat {
    CGFloat(min(Swift.max(value / max, -1.0), 1.0))
  }
}
