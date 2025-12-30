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

  /// Concentric spiral rings with metallic golden effect
  case spiralRings(
    intensity: Double = 0.8,
    ringCount: Double = 20,
    spiralTwist: Double = 0.5,
    baseColor: SIMD4<Float> = SIMD4<Float>(1.0, 0.85, 0.3, 1.0)
  )

  // MARK: - Glass Effects

  /// Plastic/glass layer over the card - like lamination or screen protector
  /// Flat glossy surface with beveled edges and soft reflections
  case glassEnclosure(
    intensity: Double = 1.0,
    cornerRadius: Double = 0.05,
    bevelSize: Double = 0.7,
    glossiness: Double = 0.8
  )

  /// Simple glass sheen overlay - specular and sweep reflections
  /// Good for layering with other effects
  case glassSheen(
    intensity: Double = 0.7,
    spread: Double = 0.5
  )

  /// Glass edge bevel effect - adds visual thickness to cards
  /// Creates highlighted top-left edges and shadowed bottom-right edges
  case glassBevel(
    intensity: Double = 0.8,
    thickness: Double = 0.6
  )

  /// Chromatic glass distortion - subtle RGB separation at edges
  /// Creates a premium prismatic glass feel
  case chromaticGlass(
    intensity: Double = 0.6,
    separation: Double = 0.4
  )

  // MARK: - Seasonal Effects

  /// Snowfall effect with falling snowflakes, twinkling stars,
  /// and customizable gradient colors
  case snowfall(
    intensity: Double = 0.8,
    snowDensity: Double = 0.5,
    starDensity: Double = 0.6,
    primaryColor: SIMD4<Float> = SIMD4<Float>(0.8, 0.1, 0.15, 1.0),
    secondaryColor: SIMD4<Float> = SIMD4<Float>(0.1, 0.5, 0.2, 1.0)
  )

  /// Frozen-inspired effect with super shiny icy silver background
  /// and floating light blue stars - Elsa aesthetic
  case frozen(
    intensity: Double = 0.85,
    starDensity: Double = 0.6,
    shimmerIntensity: Double = 0.8,
    iceColor: SIMD4<Float> = SIMD4<Float>(0.9, 0.95, 1.0, 1.0),
    starColor: SIMD4<Float> = SIMD4<Float>(0.6, 0.85, 1.0, 1.0)
  )

  // MARK: - Metallic Effects

  /// Polished aluminum with diagonal rainbow holographic reflection
  case polishedAluminum(intensity: Double = 0.85)
}
