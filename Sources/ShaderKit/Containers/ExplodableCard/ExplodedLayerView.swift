//
//  ExplodedLayerView.swift
//  ShaderKit
//
//  Renders a single layer with shader effects and 3D positioning
//

import SwiftUI

/// Internal view that renders a single layer within an explodable card.
///
/// Handles:
/// - Shader effect application with context injection
/// - 3D rotation from parent tilt
/// - Layer separation via Z depth
/// - Per-layer shadow when exploded
struct ExplodedLayerView: View {
  let layer: CardLayer
  let width: CGFloat
  let height: CGFloat
  let cornerRadius: CGFloat
  let tilt: CGPoint
  let time: TimeInterval
  let touchPosition: CGPoint?
  let zOffset: CGFloat
  let explosionProgress: CGFloat
  let rotationMultiplier: Double
  let showLabels: Bool
  let useDirectOffset: Bool

  var body: some View {
    let layerContent = applyEffects(to: layer.content, effects: layer.effects)
    let depth = useDirectOffset ? zOffset : zOffset * explosionProgress

    ZStack {
      layerContent
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(
          color: .black.opacity(0.3 * (useDirectOffset ? 1 : Double(explosionProgress))),
          radius: 10 * (useDirectOffset ? 1 : Double(explosionProgress)),
          x: 5 * (useDirectOffset ? 1 : Double(explosionProgress)),
          y: 5 * (useDirectOffset ? 1 : Double(explosionProgress))
        )

      if showLabels && (useDirectOffset || explosionProgress > 0.5), let label = layer.label {
        VStack {
          Spacer()
          Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .opacity(useDirectOffset ? 1 : Double(explosionProgress - 0.5) * 2)
        }
        .frame(width: width, height: height)
        .padding(.bottom, 8)
      }
    }
    // Real Z translation to match CSS translateZ behavior
    .projectionEffect(ProjectionTransform(layerTransform(z: depth)))
    .zIndex(Double(layer.zIndex))
  }

  private func layerTransform(z: CGFloat) -> CATransform3D {
    var transform = CATransform3DIdentity
    // Match CSS perspective-ish depth (similar to perspective: 1200px)
    transform.m34 = -1 / 1200
    return CATransform3DTranslate(transform, 0, 0, z)
  }
  @ViewBuilder
  private func applyEffects(to content: AnyView, effects: [ShaderEffect]) -> some View {
    content
      .shaderContext(tilt: tilt, time: time, touchPosition: touchPosition)
      .modifier(MultiShaderModifier(effects: effects))
  }
}

/// Applies multiple shader effects in sequence.
private struct MultiShaderModifier: ViewModifier {
  let effects: [ShaderEffect]

  func body(content: Content) -> some View {
    effects.reduce(AnyView(content)) { view, effect in
      AnyView(view.shader(effect))
    }
  }
}
