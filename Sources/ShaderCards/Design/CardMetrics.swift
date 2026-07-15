//
//  CardMetrics.swift
//  ShaderCards
//
//  Proportional layout system. All measurements are fractions of card size
//  so cards render identically at any scale (real cards are 63mm × 88mm).
//

import SwiftUI

/// Proportional layout constants for a trading card.
///
/// All values are fractions of the card's width or height, derived from the
/// 63×88mm physical card. Use ``CardMetrics/resolve(width:)`` to get point
/// values for a concrete card size.
public enum CardMetrics {
  /// Physical trading card aspect ratio (width / height): 63mm / 88mm.
  public static let aspectRatio: CGFloat = 63.0 / 88.0

  /// Corner radius as a fraction of card width (≈3mm on a real card).
  public static let cornerRadiusFraction: CGFloat = 3.0 / 63.0

  /// Outer border (the colored frame) thickness as a fraction of width.
  public static let borderFraction: CGFloat = 0.045

  // Vertical band fractions (of card height) for the standard creature frame.
  // The shader mask UV window is derived from these, so layout and foil
  // masking always agree.
  static let headerFraction: CGFloat = 0.075
  static let artFraction: CGFloat = 0.40

  /// UV bounds (minX, minY, maxX, maxY) of the standard art window in card
  /// space — feeds `ShaderEffect.maskedFoil`-style effects.
  public static var artWindowUV: SIMD4<Float> {
    let borderY = borderFraction * aspectRatio  // border in height units
    let minY = borderY + headerFraction
    return SIMD4<Float>(
      Float(borderFraction),
      Float(minY),
      Float(1 - borderFraction),
      Float(minY + artFraction)
    )
  }

  /// Resolved point-value metrics for a concrete card width.
  public struct Resolved {
    public let width: CGFloat
    public let height: CGFloat
    public let cornerRadius: CGFloat
    /// The colored outer frame inset.
    public let border: CGFloat
    /// Base unit for typography: name text size.
    public let nameSize: CGFloat
    public let bodySize: CGFloat
    public let captionSize: CGFloat
    public let energyIconSize: CGFloat
    /// Height of the header band (stage badge + name + HP).
    public let headerHeight: CGFloat
    /// Height of the framed art window.
    public let artHeight: CGFloat

    /// The art window's frame in card coordinates (standard layout).
    public var artWindowRect: CGRect {
      CGRect(
        x: border,
        y: border + headerHeight + height * 0.008,
        width: width - border * 2,
        height: artHeight
      )
    }

    init(width: CGFloat) {
      self.width = width
      self.height = width / CardMetrics.aspectRatio
      self.cornerRadius = width * CardMetrics.cornerRadiusFraction
      self.border = width * CardMetrics.borderFraction
      self.nameSize = width * 0.068
      self.bodySize = width * 0.042
      self.captionSize = width * 0.032
      self.energyIconSize = width * 0.072
      self.headerHeight = height * CardMetrics.headerFraction
      self.artHeight = height * CardMetrics.artFraction
    }
  }

  /// Resolves proportional metrics for a card of the given width.
  public static func resolve(width: CGFloat) -> Resolved {
    Resolved(width: width)
  }

  /// Height for a card of the given width.
  public static func height(forWidth width: CGFloat) -> CGFloat {
    width / aspectRatio
  }
}
