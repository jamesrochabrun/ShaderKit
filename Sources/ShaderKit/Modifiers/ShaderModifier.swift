//
//  ShaderModifier.swift
//  ShaderKit
//
//  Core ViewModifier that applies shader effects
//

import SwiftUI
import simd

/// A view modifier that applies a single shader effect.
///
/// Use the `.shader(_:)` view extension or convenience methods:
/// ```swift
/// CardContent()
///     .shaderContext(tilt: tilt, time: elapsedTime)
///     .shader(.foil(intensity: 0.8))
///     .shader(.glitter())
/// ```
public struct ShaderModifier: ViewModifier {
  private let effect: ShaderEffect
  private let tiltOverride: CGPoint?
  private let timeOverride: TimeInterval?
  
  @Environment(\.shaderContext) private var context
  
  /// Creates a shader modifier for the given effect.
  /// - Parameters:
  ///   - effect: The shader effect to apply
  ///   - tilt: Optional tilt override (uses context if nil)
  ///   - time: Optional time override (uses context if nil)
  public init(
    effect: ShaderEffect,
    tilt: CGPoint? = nil,
    time: TimeInterval? = nil
  ) {
    self.effect = effect
    self.tiltOverride = tilt
    self.timeOverride = time
  }
  
  private var tilt: CGPoint {
    tiltOverride ?? context.tilt
  }
  
  private var time: TimeInterval {
    timeOverride ?? context.time
  }
  
  public func body(content: Content) -> some View {
    let currentTilt = tilt
    let currentTime = time
    let currentEffect = effect
    
    content
      .drawingGroup()
      .visualEffect { view, proxy in
        applyEffect(currentEffect, to: view, size: proxy.size, tilt: currentTilt, time: currentTime)
      }
  }
}

// MARK: - Effect Application

private func applyEffect<V: VisualEffect>(
  _ effect: ShaderEffect,
  to view: V,
  size: CGSize,
  tilt: CGPoint,
  time: TimeInterval
) -> some VisualEffect {
  let shaders = ShaderKit.shaders
  
  switch effect {
    // MARK: - Foil Effects
    
  case .foil(let intensity):
    return view.layerEffect(
      shaders.cardThreeFoil(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .invertedFoil(let intensity):
    return view.layerEffect(
      shaders.reverseHoloEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .maskedFoil(let imageWindow, let intensity):
    return view.layerEffect(
      shaders.cardSixReverseHolo(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float4(imageWindow.x, imageWindow.y, imageWindow.z, imageWindow.w),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .foilTexture(let imageWindow):
    return view.layerEffect(
      shaders.cardSixFoilTexture(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float4(imageWindow.x, imageWindow.y, imageWindow.z, imageWindow.w)
      ),
      maxSampleOffset: .zero
    )
    
    // MARK: - Glitter & Sparkle Effects
    
  case .glitter(let density):
    return view.layerEffect(
      shaders.cardThreeGlitter(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(density)
      ),
      maxSampleOffset: .zero
    )
    
  case .multiGlitter(let density):
    return view.layerEffect(
      shaders.cardFourGlitter(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(density)
      ),
      maxSampleOffset: .zero
    )
    
  case .sparkles:
    return view.layerEffect(
      shaders.cardFiveSparkles(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .maskedSparkle(let imageWindow):
    return view.layerEffect(
      shaders.cardSixSparkle(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float4(imageWindow.x, imageWindow.y, imageWindow.z, imageWindow.w)
      ),
      maxSampleOffset: .zero
    )
    
  case .rainbowGlitter(let intensity):
    return view.layerEffect(
      shaders.rainbowRareEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .shimmer(let intensity):
    return view.layerEffect(
      shaders.amazingRareEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .goldShimmer(let intensity):
    return view.layerEffect(
      shaders.secretGoldEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
    // MARK: - Light Effects
    
  case .lightSweep:
    return view.layerEffect(
      shaders.cardThreeSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .radialSweep:
    return view.layerEffect(
      shaders.cardFourSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .angledSweep:
    return view.layerEffect(
      shaders.cardFiveSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .glare(let intensity):
    return view.layerEffect(
      shaders.cardFiveImageGlare(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .simpleGlare(let intensity):
    return view.layerEffect(
      shaders.basicGlareEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .edgeShine:
    return view.layerEffect(
      shaders.cardFiveImageEdgeShine(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y)
      ),
      maxSampleOffset: .zero
    )
    
    // MARK: - Holographic Patterns
    
  case .diamondGrid(let intensity):
    return view.layerEffect(
      shaders.cardOneHolographic(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .intenseBling:
    return view.layerEffect(
      shaders.cardTwoHolographic(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .starburst(let intensity):
    return view.layerEffect(
      shaders.cardFourStarburst(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .blendedHolo(let intensity, let saturation):
    return view.layerEffect(
      shaders.cardFiveBlendedHolo(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(saturation)
      ),
      maxSampleOffset: .zero
    )
    
  case .verticalBeams(let intensity):
    return view.layerEffect(
      shaders.regularHoloEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .diagonalHolo(let intensity):
    return view.layerEffect(
      shaders.pokemonVEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .crisscrossHolo(let intensity):
    return view.layerEffect(
      shaders.radiantHoloEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .galaxyHolo(let intensity):
    return view.layerEffect(
      shaders.cosmosHoloEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .radialStar(let intensity):
    return view.layerEffect(
      shaders.vstarEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .subtleGradient(let intensity):
    return view.layerEffect(
      shaders.vmaxEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .metallicCrosshatch(let intensity):
    return view.layerEffect(
      shaders.shinyRareEffect(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
  }
}
