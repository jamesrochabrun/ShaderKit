//
//  View+Shader.swift
//  ShaderKit
//
//  View extensions for applying shader effects
//

import SwiftUI
import simd

public extension View {
  
  // MARK: - Primary Builder API
  
  /// Apply a shader effect to the view.
  ///
  /// Chain multiple effects using the builder pattern:
  /// ```swift
  /// CardContent()
  ///     .shaderContext(tilt: tilt, time: elapsedTime)
  ///     .shader(.foil(intensity: 0.8))
  ///     .shader(.glitter())
  ///     .shader(.lightSweep())
  /// ```
  ///
  /// - Parameters:
  ///   - effect: The shader effect to apply
  ///   - tilt: Optional tilt override (uses context if nil)
  ///   - time: Optional time override (uses context if nil)
  /// - Returns: A view with the shader effect applied
  func shader(
    _ effect: ShaderEffect,
    tilt: CGPoint? = nil,
    time: TimeInterval? = nil
  ) -> some View {
    modifier(ShaderModifier(effect: effect, tilt: tilt, time: time))
  }
  
  // MARK: - Foil Effects
  
  /// Apply rainbow foil overlay effect.
  /// - Parameter intensity: Effect strength (default 1.0)
  func foil(intensity: Double = 1.0) -> some View {
    shader(.foil(intensity: intensity))
  }
  
  /// Apply inverted foil with shine overlay.
  /// - Parameter intensity: Effect strength (default 0.7)
  func invertedFoil(intensity: Double = 0.7) -> some View {
    shader(.invertedFoil(intensity: intensity))
  }
  
  /// Apply foil effect with image window mask.
  /// - Parameters:
  ///   - imageWindow: UV bounds (minX, minY, maxX, maxY) of area to exclude from foil
  ///   - intensity: Effect strength (default 1.0)
  func maskedFoil(imageWindow: SIMD4<Float>, intensity: Double = 1.0) -> some View {
    shader(.maskedFoil(imageWindow: imageWindow, intensity: intensity))
  }
  
  /// Apply fine diagonal line foil texture.
  /// - Parameter imageWindow: UV bounds of area to exclude from texture
  func foilTexture(imageWindow: SIMD4<Float>) -> some View {
    shader(.foilTexture(imageWindow: imageWindow))
  }
  
  // MARK: - Glitter & Sparkle Effects
  
  /// Apply sparkle particle overlay.
  /// - Parameter density: Particle density (default 50)
  func glitter(density: Double = 50) -> some View {
    shader(.glitter(density: density))
  }
  
  /// Apply multi-scale sparkle particles.
  /// - Parameter density: Particle density (default 80)
  func multiGlitter(density: Double = 80) -> some View {
    shader(.multiGlitter(density: density))
  }
  
  /// Apply tilt-activated sparkle grid.
  func sparkles() -> some View {
    shader(.sparkles)
  }
  
  /// Apply sparkles only in masked area.
  /// - Parameter imageWindow: UV bounds of foil area where sparkles appear
  func maskedSparkle(imageWindow: SIMD4<Float>) -> some View {
    shader(.maskedSparkle(imageWindow: imageWindow))
  }
  
  /// Apply glittery rainbow with luminosity blend.
  /// - Parameter intensity: Effect strength (default 0.7)
  func rainbowGlitter(intensity: Double = 0.7) -> some View {
    shader(.rainbowGlitter(intensity: intensity))
  }
  
  /// Apply glittery metallic shimmer effect.
  /// - Parameter intensity: Effect strength (default 0.7)
  func shimmer(intensity: Double = 0.7) -> some View {
    shader(.shimmer(intensity: intensity))
  }

  // MARK: - Light Effects
  
  /// Apply sweeping light band across the surface.
  func lightSweep() -> some View {
    shader(.lightSweep)
  }
  
  /// Apply rotating radial light sweep.
  func radialSweep() -> some View {
    shader(.radialSweep)
  }
  
  /// Apply angled light sweep effect.
  func angledSweep() -> some View {
    shader(.angledSweep)
  }
  
  /// Apply following light hotspot based on tilt.
  /// - Parameter intensity: Effect strength (default 1.0)
  func glare(intensity: Double = 1.0) -> some View {
    shader(.glare(intensity: intensity))
  }
  
  /// Apply simple radial glare effect.
  /// - Parameter intensity: Effect strength (default 0.7)
  func simpleGlare(intensity: Double = 0.7) -> some View {
    shader(.simpleGlare(intensity: intensity))
  }
  
  /// Apply edge highlight effect.
  func edgeShine() -> some View {
    shader(.edgeShine)
  }
  
  // MARK: - Holographic Patterns
  
  /// Apply diamond grid holographic pattern.
  /// - Parameter intensity: Effect strength (default 1.0)
  func diamondGrid(intensity: Double = 1.0) -> some View {
    shader(.diamondGrid(intensity: intensity))
  }
  
  /// Apply maximum intensity diamond holographic.
  func intenseBling() -> some View {
    shader(.intenseBling)
  }
  
  /// Apply radial rainbow rays emanating from center.
  /// - Parameter intensity: Effect strength (default 1.0)
  func starburst(intensity: Double = 1.0) -> some View {
    shader(.starburst(intensity: intensity))
  }
  
  /// Apply luminance-blended rainbow holographic.
  /// - Parameters:
  ///   - intensity: Effect strength (default 0.7)
  ///   - saturation: Color saturation (default 0.75)
  func blendedHolo(intensity: Float = 0.7, saturation: Float = 0.75) -> some View {
    shader(.blendedHolo(intensity: intensity, saturation: saturation))
  }
  
  /// Apply vertical rainbow beam pattern.
  /// - Parameter intensity: Effect strength (default 0.7)
  func verticalBeams(intensity: Double = 0.7) -> some View {
    shader(.verticalBeams(intensity: intensity))
  }
  
  /// Apply diagonal lines with 3D depth effect.
  /// - Parameter intensity: Effect strength (default 0.7)
  func diagonalHolo(intensity: Double = 0.7) -> some View {
    shader(.diagonalHolo(intensity: intensity))
  }
  
  /// Apply criss-cross diamond pattern holographic.
  /// - Parameter intensity: Effect strength (default 0.7)
  func crisscrossHolo(intensity: Double = 0.7) -> some View {
    shader(.crisscrossHolo(intensity: intensity))
  }
  
  /// Apply galaxy/cosmos with rainbow overlay.
  /// - Parameter intensity: Effect strength (default 0.7)
  func galaxyHolo(intensity: Double = 0.7) -> some View {
    shader(.galaxyHolo(intensity: intensity))
  }
  
  /// Apply star pattern with radial mask fade.
  /// - Parameter intensity: Effect strength (default 0.7)
  func radialStar(intensity: Double = 0.7) -> some View {
    shader(.radialStar(intensity: intensity))
  }
  
  /// Apply large-scale subtle gradient movement.
  /// - Parameter intensity: Effect strength (default 0.7)
  func subtleGradient(intensity: Double = 0.7) -> some View {
    shader(.subtleGradient(intensity: intensity))
  }
  
  /// Apply metallic sun-pillar with crosshatch texture.
  /// - Parameter intensity: Effect strength (default 0.7)
  func metallicCrosshatch(intensity: Double = 0.7) -> some View {
    shader(.metallicCrosshatch(intensity: intensity))
  }

  // MARK: - Seasonal Effects

  /// Apply snowfall effect with falling snowflakes, twinkling stars,
  /// and customizable gradient colors.
  /// - Parameters:
  ///   - intensity: Effect strength (default 0.8)
  ///   - snowDensity: Density of falling snowflakes (default 0.5)
  ///   - starDensity: Density of twinkling stars (default 0.6)
  ///   - primaryColor: Primary gradient color (default SIMD4<Float>(0.8, 0.1, 0.15, 1.0))
  ///   - secondaryColor: Secondary gradient color (default SIMD4<Float>(0.1, 0.5, 0.2, 1.0))
  func snowfall(
    intensity: Double = 0.8,
    snowDensity: Double = 0.5,
    starDensity: Double = 0.6,
    primaryColor: SIMD4<Float> = SIMD4<Float>(0.8, 0.1, 0.15, 1.0),
    secondaryColor: SIMD4<Float> = SIMD4<Float>(0.1, 0.5, 0.2, 1.0)
  ) -> some View {
    shader(.snowfall(
      intensity: intensity,
      snowDensity: snowDensity,
      starDensity: starDensity,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor
    ))
  }

  /// Apply Frozen-inspired effect with super shiny icy silver background
  /// and floating light blue stars.
  /// - Parameters:
  ///   - intensity: Effect strength (default 0.85)
  ///   - starDensity: Density of floating stars (default 0.6)
  ///   - shimmerIntensity: Intensity of ice shimmer effect (default 0.8)
  ///   - iceColor: Base ice/silver color (default icy white)
  ///   - starColor: Color of floating stars (default light blue)
  func frozen(
    intensity: Double = 0.85,
    starDensity: Double = 0.6,
    shimmerIntensity: Double = 0.8,
    iceColor: SIMD4<Float> = SIMD4<Float>(0.9, 0.95, 1.0, 1.0),
    starColor: SIMD4<Float> = SIMD4<Float>(0.6, 0.85, 1.0, 1.0)
  ) -> some View {
    shader(.frozen(
      intensity: intensity,
      starDensity: starDensity,
      shimmerIntensity: shimmerIntensity,
      iceColor: iceColor,
      starColor: starColor
    ))
  }

  // MARK: - Paper Effects

  /// Apply water caustic effect with realistic light refraction patterns.
  /// - Parameters:
  ///   - colorBack: Background/tint color (default gray)
  ///   - colorHighlight: Highlight color (default white)
  ///   - highlights: Highlight intensity for caustic + glints (default 0.12)
  ///   - layering: Second caustic layer intensity (default 0.35)
  ///   - edges: Edge distortion power (default 0.55)
  ///   - waves: Simplex noise wave distortion (default 0.7)
  ///   - caustic: Caustic distortion power (default 0.2)
  ///   - speed: Animation speed (default 0.8)
  ///   - scale: Overall zoom (default 0.9)
  func waterCaustic(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.56, 0.56, 0.56, 1.0),
    colorHighlight: SIMD4<Float> = SIMD4<Float>(1.0, 1.0, 1.0, 1.0),
    highlights: Double = 0.12,
    layering: Double = 0.35,
    edges: Double = 0.55,
    waves: Double = 0.7,
    caustic: Double = 0.2,
    speed: Double = 0.8,
    scale: Double = 0.9
  ) -> some View {
    shader(.waterCaustic(
      colorBack: colorBack,
      colorHighlight: colorHighlight,
      highlights: highlights,
      layering: layering,
      edges: edges,
      waves: waves,
      caustic: caustic,
      speed: speed,
      scale: scale
    ))
  }

  /// Apply water caustic v2 effect inspired by Twigl GLSL.
  /// - Parameters:
  ///   - colorBack: Background/tint color (default gray)
  ///   - colorHighlight: Highlight color (default white)
  ///   - highlights: Highlight intensity for caustic overlay (default 0.07)
  ///   - edges: Edge distortion power (default 0.8)
  ///   - waves: Additional wave noise distortion (default 0.3)
  ///   - caustic: Caustic distortion power (default 0.1)
  ///   - size: Pattern scale relative to the image (default 1.0)
  ///   - speed: Animation speed (default 1.0)
  ///   - scale: Overall zoom (default 0.8)
  func waterCausticV2(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.56, 0.56, 0.56, 1.0),
    colorHighlight: SIMD4<Float> = SIMD4<Float>(1.0, 1.0, 1.0, 1.0),
    highlights: Double = 0.07,
    edges: Double = 0.8,
    waves: Double = 0.3,
    caustic: Double = 0.1,
    size patternSize: Double = 1.0,
    speed: Double = 1.0,
    scale: Double = 0.8
  ) -> some View {
    shader(.waterCausticV2(
      colorBack: colorBack,
      colorHighlight: colorHighlight,
      highlights: highlights,
      edges: edges,
      waves: waves,
      caustic: caustic,
      size: patternSize,
      speed: speed,
      scale: scale
    ))
  }
}
