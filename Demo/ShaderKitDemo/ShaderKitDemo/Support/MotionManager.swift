//
//  MotionManager.swift
//  ShaderKitDemo
//
//  Device tilt source for motion-reactive shader demos.
//

import CoreGraphics
import Foundation
import Observation

#if canImport(CoreMotion) && (os(iOS) || os(visionOS))
import CoreMotion
#endif

@Observable
final class MotionManager {
  private(set) var tilt: CGPoint = .zero
  private(set) var isAvailable = false

#if canImport(CoreMotion) && (os(iOS) || os(visionOS))
  @ObservationIgnored private let coreMotionManager = CMMotionManager()
#endif

  func start() {
#if canImport(CoreMotion) && (os(iOS) || os(visionOS))
    guard coreMotionManager.isDeviceMotionAvailable else {
      isAvailable = false
      tilt = .zero
      return
    }

    isAvailable = true
    coreMotionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    coreMotionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let self, let gravity = motion?.gravity else {
        return
      }

      tilt = Self.tilt(from: gravity)
    }
#else
    isAvailable = false
    tilt = .zero
#endif
  }

  func stop() {
#if canImport(CoreMotion) && (os(iOS) || os(visionOS))
    coreMotionManager.stopDeviceMotionUpdates()
#endif
    isAvailable = false
    tilt = .zero
  }

#if canImport(CoreMotion) && (os(iOS) || os(visionOS))
  private static func tilt(from gravity: CMAcceleration) -> CGPoint {
    CGPoint(
      x: clamped(gravity.x * 1.25),
      y: clamped(-gravity.y * 1.25)
    )
  }
#endif

  private static func clamped(_ value: Double) -> CGFloat {
    CGFloat(min(max(value, -1.0), 1.0))
  }
}
