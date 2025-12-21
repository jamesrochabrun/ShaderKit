//
//  ShaderKit.swift
//  ShaderKit
//
//  A Swift package for composable Metal shaders and holographic UI effects
//

import SwiftUI

// Re-export all public types
@_exported import struct SwiftUI.Color
@_exported import struct SwiftUI.CGPoint

// MARK: - ShaderKit Namespace

/// ShaderKit provides composable Metal shaders and SwiftUI components for creating
/// beautiful holographic and iridescent effects.
///
/// ## Quick Start
///
/// Stack multiple shader effects using the builder pattern:
/// ```swift
/// HolographicCardContainer(width: 260, height: 380) {
///     CardContent()
///         .foil()
///         .glitter()
///         .lightSweep()
/// }
/// ```
///
/// ## Available Effects
///
/// ### Foil Effects
/// - `.foil()` - Rainbow foil overlay
/// - `.invertedFoil()` - Inverted foil with shine
/// - `.maskedFoil(imageWindow:)` - Foil with masked area
/// - `.foilTexture(imageWindow:)` - Fine diagonal texture
///
/// ### Glitter & Sparkle
/// - `.glitter()` - Sparkle particles
/// - `.multiGlitter()` - Multi-scale sparkles
/// - `.sparkles()` - Tilt-activated sparkle grid
/// - `.shimmer()` - Metallic shimmer
/// - `.rainbowGlitter()` - Rainbow with luminosity blend
///
/// ### Light Effects
/// - `.lightSweep()` - Sweeping light band
/// - `.radialSweep()` - Rotating radial sweep
/// - `.angledSweep()` - Angled light sweep
/// - `.glare()` - Following light hotspot
/// - `.simpleGlare()` - Basic radial glare
/// - `.edgeShine()` - Edge highlight
///
/// ### Holographic Patterns
/// - `.diamondGrid()` - Diamond grid pattern
/// - `.intenseBling()` - Maximum intensity holo
/// - `.starburst()` - Radial rainbow rays
/// - `.blendedHolo()` - Luminance-blended rainbow
/// - `.verticalBeams()` - Vertical rainbow beams
/// - `.diagonalHolo()` - Diagonal 3D effect
/// - `.crisscrossHolo()` - Criss-cross diamonds
/// - `.galaxyHolo()` - Galaxy/cosmos overlay
/// - `.radialStar()` - Star pattern
/// - `.subtleGradient()` - Subtle gradient movement
/// - `.metallicCrosshatch()` - Metallic crosshatch
///
/// ## Main Components
///
/// - `HolographicCardContainer` - Container with motion/tilt support
/// - `ShaderEffect` - Enum of all available effects
/// - `ShaderContext` - Environment value for tilt/time
/// - `MotionManager` - Gyroscope-based device motion
///
/// ## Custom Composition
///
/// For custom tilt sources, inject context manually:
/// ```swift
/// CardContent()
///     .shaderContext(tilt: myTilt, time: myTime)
///     .shader(.foil(intensity: 0.8))
///     .shader(.glitter(density: 75))
/// ```
public enum ShaderKit {
  public static let version = "2.0.0"
  
  /// The shader library containing all ShaderKit Metal shaders.
  /// Use this instead of `ShaderLibrary` to ensure shaders are loaded from the correct bundle.
  public static let shaders: ShaderLibrary = ShaderLibrary.bundle(.module)
}
