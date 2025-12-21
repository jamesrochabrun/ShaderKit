//
//  ShaderEffect.swift
//  ShaderKit
//
//  Composable shader effects with semantic naming
//

import SwiftUI
import simd

/// Represents a single composable shader effect with its configuration.
///
/// Stack multiple effects using the builder pattern:
/// ```swift
/// CardContent()
///     .shaderContext(tilt: tilt, time: elapsedTime)
///     .shader(.foil(intensity: 0.8))
///     .shader(.glitter())
///     .shader(.lightSweep())
/// ```
public enum ShaderEffect: Equatable, Sendable {
  
  // MARK: - Foil Effects
  
  /// Rainbow foil overlay effect
  case foil(intensity: Double = 1.0)
  
  /// Inverted foil with shine overlay
  case invertedFoil(intensity: Double = 0.7)
  
  /// Foil effect with image window mask (applies foil only outside the mask)
  case maskedFoil(imageWindow: SIMD4<Float>, intensity: Double = 1.0)
  
  /// Fine diagonal line foil texture
  case foilTexture(imageWindow: SIMD4<Float>)
  
  // MARK: - Glitter & Sparkle Effects
  
  /// Sparkle particle overlay
  case glitter(density: Double = 50)
  
  /// Multi-scale sparkle particles
  case multiGlitter(density: Double = 80)
  
  /// Tilt-activated sparkle grid
  case sparkles
  
  /// Sparkles in masked area only
  case maskedSparkle(imageWindow: SIMD4<Float>)
  
  /// Glittery rainbow with luminosity blend
  case rainbowGlitter(intensity: Double = 0.7)
  
  /// Glittery metallic shimmer effect
  case shimmer(intensity: Double = 0.7)

  // MARK: - Light Effects
  
  /// Sweeping light band across the surface
  case lightSweep
  
  /// Rotating radial light sweep
  case radialSweep
  
  /// Angled light sweep effect
  case angledSweep
  
  /// Following light hotspot based on tilt
  case glare(intensity: Double = 1.0)
  
  /// Simple radial glare effect
  case simpleGlare(intensity: Double = 0.7)
  
  /// Edge highlight effect
  case edgeShine
  
  // MARK: - Holographic Patterns
  
  /// Diamond grid holographic pattern
  case diamondGrid(intensity: Double = 1.0)
  
  /// Maximum intensity diamond holographic
  case intenseBling
  
  /// Radial rainbow rays emanating from center
  case starburst(intensity: Double = 1.0)
  
  /// Luminance-blended rainbow holographic
  case blendedHolo(intensity: Float = 0.7, saturation: Float = 0.75)
  
  /// Vertical rainbow beam pattern
  case verticalBeams(intensity: Double = 0.7)
  
  /// Diagonal lines with 3D depth effect
  case diagonalHolo(intensity: Double = 0.7)
  
  /// Criss-cross diamond pattern holographic
  case crisscrossHolo(intensity: Double = 0.7)
  
  /// Galaxy/cosmos with rainbow overlay
  case galaxyHolo(intensity: Double = 0.7)
  
  /// Star pattern with radial mask fade
  case radialStar(intensity: Double = 0.7)
  
  /// Large-scale subtle gradient movement
  case subtleGradient(intensity: Double = 0.7)
  
  /// Metallic sun-pillar with crosshatch texture
  case metallicCrosshatch(intensity: Double = 0.7)
}
