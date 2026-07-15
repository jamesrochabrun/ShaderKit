//
//  ElementPalette.swift
//  ShaderCards
//
//  Canonical color palettes for each element type.
//

import SwiftUI

/// The color system for an element: frame, accents, and art-backdrop gradients.
public struct ElementPalette: Equatable, Sendable {
  /// Primary frame color (card border / energy icon fill).
  public let primary: Color
  /// Lighter companion used for gradients and inner panels.
  public let light: Color
  /// Darker companion used for text, borders, and shadows.
  public let dark: Color
  /// Accent used for small highlights (HP, badges).
  public let accent: Color

  public init(primary: Color, light: Color, dark: Color, accent: Color) {
    self.primary = primary
    self.light = light
    self.dark = dark
    self.accent = accent
  }

  /// The default backdrop gradient behind procedural artwork.
  public var artGradient: LinearGradient {
    LinearGradient(
      colors: [light, primary, dark],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  /// The classic frame gradient used for card borders.
  public var frameGradient: LinearGradient {
    LinearGradient(
      colors: [light, primary],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

public extension ElementType {
  /// The canonical palette for this element.
  var palette: ElementPalette {
    switch self {
    case .grass:
      ElementPalette(
        primary: Color(red: 0.29, green: 0.68, blue: 0.31),
        light: Color(red: 0.61, green: 0.84, blue: 0.46),
        dark: Color(red: 0.11, green: 0.37, blue: 0.15),
        accent: Color(red: 0.83, green: 0.97, blue: 0.60)
      )
    case .fire:
      ElementPalette(
        primary: Color(red: 0.91, green: 0.30, blue: 0.14),
        light: Color(red: 1.00, green: 0.60, blue: 0.25),
        dark: Color(red: 0.55, green: 0.10, blue: 0.05),
        accent: Color(red: 1.00, green: 0.82, blue: 0.40)
      )
    case .water:
      ElementPalette(
        primary: Color(red: 0.16, green: 0.51, blue: 0.85),
        light: Color(red: 0.45, green: 0.75, blue: 0.98),
        dark: Color(red: 0.05, green: 0.25, blue: 0.52),
        accent: Color(red: 0.70, green: 0.92, blue: 1.00)
      )
    case .lightning:
      ElementPalette(
        primary: Color(red: 0.98, green: 0.80, blue: 0.10),
        light: Color(red: 1.00, green: 0.93, blue: 0.45),
        dark: Color(red: 0.65, green: 0.48, blue: 0.02),
        accent: Color(red: 1.00, green: 0.98, blue: 0.75)
      )
    case .psychic:
      ElementPalette(
        primary: Color(red: 0.61, green: 0.32, blue: 0.73),
        light: Color(red: 0.80, green: 0.55, blue: 0.90),
        dark: Color(red: 0.32, green: 0.12, blue: 0.45),
        accent: Color(red: 0.94, green: 0.78, blue: 1.00)
      )
    case .fighting:
      ElementPalette(
        primary: Color(red: 0.71, green: 0.40, blue: 0.22),
        light: Color(red: 0.88, green: 0.60, blue: 0.38),
        dark: Color(red: 0.42, green: 0.20, blue: 0.09),
        accent: Color(red: 0.98, green: 0.80, blue: 0.58)
      )
    case .darkness:
      ElementPalette(
        primary: Color(red: 0.18, green: 0.20, blue: 0.25),
        light: Color(red: 0.38, green: 0.42, blue: 0.50),
        dark: Color(red: 0.05, green: 0.06, blue: 0.09),
        accent: Color(red: 0.35, green: 0.75, blue: 0.65)
      )
    case .metal:
      ElementPalette(
        primary: Color(red: 0.66, green: 0.69, blue: 0.73),
        light: Color(red: 0.88, green: 0.90, blue: 0.93),
        dark: Color(red: 0.35, green: 0.38, blue: 0.43),
        accent: Color(red: 0.95, green: 0.96, blue: 1.00)
      )
    case .fairy:
      ElementPalette(
        primary: Color(red: 0.93, green: 0.42, blue: 0.66),
        light: Color(red: 1.00, green: 0.70, blue: 0.85),
        dark: Color(red: 0.60, green: 0.15, blue: 0.38),
        accent: Color(red: 1.00, green: 0.88, blue: 0.95)
      )
    case .dragon:
      ElementPalette(
        primary: Color(red: 0.78, green: 0.62, blue: 0.22),
        light: Color(red: 0.95, green: 0.83, blue: 0.45),
        dark: Color(red: 0.35, green: 0.42, blue: 0.28),
        accent: Color(red: 0.55, green: 0.72, blue: 0.45)
      )
    case .colorless:
      ElementPalette(
        primary: Color(red: 0.85, green: 0.83, blue: 0.78),
        light: Color(red: 0.97, green: 0.96, blue: 0.93),
        dark: Color(red: 0.52, green: 0.50, blue: 0.45),
        accent: Color(red: 1.00, green: 1.00, blue: 0.98)
      )
    }
  }
}
