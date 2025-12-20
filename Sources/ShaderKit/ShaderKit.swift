//
//  ShaderKit.swift
//  ShaderKit
//
//  A Swift package for Metal shaders and holographic UI effects
//

import SwiftUI

// Re-export all public types
@_exported import struct SwiftUI.Color
@_exported import struct SwiftUI.CGPoint

// MARK: - ShaderKit Namespace

/// ShaderKit provides Metal shaders and SwiftUI components for creating
/// beautiful holographic and iridescent card effects.
///
/// ## Main Components:
/// - `HolographicCardContainer`: A reusable container with motion/tilt support
/// - `MotionManager`: Gyroscope-based device motion for tilt effects
/// - `SimpleCardContent`: A reusable card layout for demos
///
/// ## View Modifiers:
/// - `.cardThreeHolographicEffect()`: Foil + glitter + sweep effect
/// - `.cardFourHolographicEffect()`: Starburst rainbow effect
/// - `.cardFiveBackgroundHolo()`: Chrome/rainbow background
/// - `.cardFiveImageSparkles()`: Sparkle overlay
/// - `.cardFiveSweep()`: Light sweep effect
/// - `.cardSixReverseHoloEffect()`: Reverse holo with masked areas
///
/// ## Usage:
/// ```swift
/// HolographicCardContainer(
///     width: 260,
///     height: 380,
///     shadowColor: .purple
/// ) { tilt, elapsedTime in
///     YourCardContent()
///         .cardThreeHolographicEffect(tilt: tilt, time: elapsedTime)
/// }
/// ```
public enum ShaderKit {
    public static let version = "1.0.0"

    /// The shader library containing all ShaderKit Metal shaders.
    /// Use this instead of `ShaderLibrary` to ensure shaders are loaded from the correct bundle.
    public static let shaders: ShaderLibrary = ShaderLibrary.bundle(.module)
}
