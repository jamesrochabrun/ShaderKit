//
//  HolographicInteractionMode.swift
//  ShaderKit
//
//  Gesture-to-tilt mappings for holographic surfaces.
//

import CoreGraphics

/// Defines how a gesture is converted into normalized shader tilt and 3D rotation.
public enum HolographicInteractionMode: Sendable {
  /// Preserves ShaderKit's original behavior, where tilt follows the distance
  /// dragged from the gesture's starting point.
  case dragTranslation

  /// Tracks the pointer's absolute location across the card surface. The
  /// center is neutral and every edge reaches a normalized tilt of `1`.
  /// This matches the interaction model used by physical-card foil demos.
  case surfacePointer

  func normalizedTilt(
    translation: CGSize,
    pointer: CGPoint?,
    size: CGSize
  ) -> CGPoint {
    let halfWidth = max(size.width * 0.5, 1)
    let halfHeight = max(size.height * 0.5, 1)

    switch self {
    case .dragTranslation:
      return CGPoint(
        x: translation.width / halfWidth,
        y: translation.height / halfHeight
      )

    case .surfacePointer:
      guard let pointer else { return .zero }
      return CGPoint(
        x: ((pointer.x - 0.5) * 2).clamped(to: -1...1),
        y: ((pointer.y - 0.5) * 2).clamped(to: -1...1)
      )
    }
  }

  func rotation(
    for tilt: CGPoint,
    multiplier: Double
  ) -> (x: Double, y: Double) {
    switch self {
    case .dragTranslation:
      return (
        x: -tilt.y * multiplier,
        y: tilt.x * multiplier
      )

    case .surfacePointer:
      return (
        x: tilt.y * multiplier,
        y: -tilt.x * multiplier
      )
    }
  }
}

private extension CGFloat {
  func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
    Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
  }
}
