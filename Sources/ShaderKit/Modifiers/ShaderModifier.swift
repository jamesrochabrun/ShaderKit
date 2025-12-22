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

  private var touchPosition: CGPoint? {
    context.touchPosition
  }
  
  public func body(content: Content) -> some View {
    let currentTilt = tilt
    let currentTime = time
    let currentEffect = effect
    let currentTouchPosition = touchPosition

    content
      .drawingGroup()
      .visualEffect { view, proxy in
        applyEffect(currentEffect, to: view, size: proxy.size, tilt: currentTilt, time: currentTime, touchPosition: currentTouchPosition)
      }
  }
}

// MARK: - Effect Application

private func applyEffect<V: VisualEffect>(
  _ effect: ShaderEffect,
  to view: V,
  size: CGSize,
  tilt: CGPoint,
  time: TimeInterval,
  touchPosition: CGPoint?
) -> some VisualEffect {
  let shaders = ShaderKit.shaders
  
  switch effect {
    // MARK: - Foil Effects
    
  case .foil(let intensity):
    return view.layerEffect(
      shaders.foil(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .invertedFoil(let intensity):
    return view.layerEffect(
      shaders.invertedFoil(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .maskedFoil(let imageWindow, let intensity):
    return view.layerEffect(
      shaders.maskedFoil(
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
      shaders.foilTexture(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float4(imageWindow.x, imageWindow.y, imageWindow.z, imageWindow.w)
      ),
      maxSampleOffset: .zero
    )
    
    // MARK: - Glitter & Sparkle Effects
    
  case .glitter(let density):
    return view.layerEffect(
      shaders.glitter(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(density)
      ),
      maxSampleOffset: .zero
    )
    
  case .multiGlitter(let density):
    return view.layerEffect(
      shaders.multiGlitter(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(density)
      ),
      maxSampleOffset: .zero
    )
    
  case .sparkles:
    return view.layerEffect(
      shaders.sparkles(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .maskedSparkle(let imageWindow):
    return view.layerEffect(
      shaders.maskedSparkle(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float4(imageWindow.x, imageWindow.y, imageWindow.z, imageWindow.w)
      ),
      maxSampleOffset: .zero
    )
    
  case .rainbowGlitter(let intensity):
    return view.layerEffect(
      shaders.rainbowGlitter(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .shimmer(let intensity):
    return view.layerEffect(
      shaders.shimmer(
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
      shaders.lightSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .radialSweep:
    return view.layerEffect(
      shaders.radialSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .angledSweep:
    return view.layerEffect(
      shaders.angledSweep(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .glare(let intensity):
    return view.layerEffect(
      shaders.glare(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .simpleGlare(let intensity):
    let touch = touchPosition ?? CGPoint(x: -1, y: -1)
    return view.layerEffect(
      shaders.simpleGlare(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float2(touch.x, touch.y)
      ),
      maxSampleOffset: .zero
    )
    
  case .edgeShine:
    return view.layerEffect(
      shaders.edgeShine(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y)
      ),
      maxSampleOffset: .zero
    )
    
    // MARK: - Holographic Patterns
    
  case .diamondGrid(let intensity):
    return view.layerEffect(
      shaders.diamondGrid(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .intenseBling:
    return view.layerEffect(
      shaders.intenseBling(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time)
      ),
      maxSampleOffset: .zero
    )
    
  case .starburst(let intensity):
    return view.layerEffect(
      shaders.starburst(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .blendedHolo(let intensity, let saturation):
    return view.layerEffect(
      shaders.blendedHolo(
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
      shaders.verticalBeams(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .diagonalHolo(let intensity):
    return view.layerEffect(
      shaders.diagonalHolo(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .crisscrossHolo(let intensity):
    return view.layerEffect(
      shaders.crisscrossHolo(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .galaxyHolo(let intensity):
    return view.layerEffect(
      shaders.galaxyHolo(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .radialStar(let intensity):
    return view.layerEffect(
      shaders.radialStar(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .subtleGradient(let intensity):
    return view.layerEffect(
      shaders.subtleGradient(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )
    
  case .metallicCrosshatch(let intensity):
    return view.layerEffect(
      shaders.metallicCrosshatch(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity)
      ),
      maxSampleOffset: .zero
    )

  case .spiralRings(let intensity, let ringCount, let spiralTwist, let baseColor):
    return view.layerEffect(
      shaders.spiralRings(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(ringCount),
        .float(spiralTwist),
        .float4(baseColor.x, baseColor.y, baseColor.z, baseColor.w)
      ),
      maxSampleOffset: .zero
    )

    // MARK: - Glass Effects

  case .glassEnclosure(let intensity, let cornerRadius, let bevelSize, let glossiness):
    return view.layerEffect(
      shaders.glassEnclosure(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(cornerRadius),
        .float(bevelSize),
        .float(glossiness)
      ),
      maxSampleOffset: .zero
    )

  case .glassSheen(let intensity, let spread):
    return view.layerEffect(
      shaders.glassSheen(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(spread)
      ),
      maxSampleOffset: .zero
    )

  case .glassBevel(let intensity, let thickness):
    return view.layerEffect(
      shaders.glassBevel(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(thickness)
      ),
      maxSampleOffset: .zero
    )

  case .chromaticGlass(let intensity, let separation):
    // Small sample offset needed for chromatic aberration
    let maxOffset = separation * 5.0
    return view.layerEffect(
      shaders.chromaticGlass(
        .float2(size.width, size.height),
        .float2(tilt.x, tilt.y),
        .float(time),
        .float(intensity),
        .float(separation)
      ),
      maxSampleOffset: CGSize(width: maxOffset, height: maxOffset)
    )
  }
}
