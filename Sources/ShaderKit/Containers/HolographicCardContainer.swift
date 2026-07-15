//
//  HolographicCardContainer.swift
//  ShaderKit
//
//  Reusable container for holographic cards with drag/tilt/rotation behavior
//

import SwiftUI

/// A container that provides tilt-based motion and shader context for holographic effects.
///
/// The container automatically injects shader context (tilt and time) into child views,
/// allowing you to use shader effects without manually passing parameters:
///
/// ```swift
/// HolographicCardContainer(width: 260, height: 380) {
///     CardContent()
///         .foil()
///         .glitter()
///         .lightSweep()
/// }
/// ```
///
/// The container provides:
/// - Drag gesture for tilt control
/// - 3D rotation effects synchronized with tilt
/// - Dynamic shadow based on tilt angle
/// - Automatic shader context injection
public struct HolographicCardContainer<Content: View>: View {
  let width: CGFloat
  let height: CGFloat
  let cornerRadius: CGFloat
  let shadowColor: Color
  let rotationMultiplier: Double
  let interactionMode: HolographicInteractionMode
  @ViewBuilder let content: Content
  
  @State private var startTime = Date.now
  @State private var dragOffset: CGSize = .zero
  @State private var touchPosition: CGPoint? = nil
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  
  /// Creates a holographic card container.
  ///
  /// - Parameters:
  ///   - width: Card width in points
  ///   - height: Card height in points
  ///   - cornerRadius: Corner radius for clipping (default 16)
  ///   - shadowColor: Shadow color (default black)
  ///   - rotationMultiplier: 3D rotation intensity (default 15)
  ///   - interactionMode: How gestures map to tilt and rotation
  ///   - content: Content builder - shader effects will automatically receive tilt and time
  public init(
    width: CGFloat,
    height: CGFloat,
    cornerRadius: CGFloat = 16,
    shadowColor: Color = .black,
    rotationMultiplier: Double = 15,
    interactionMode: HolographicInteractionMode = .dragTranslation,
    @ViewBuilder content: () -> Content
  ) {
    self.width = width
    self.height = height
    self.cornerRadius = cornerRadius
    self.shadowColor = shadowColor
    self.rotationMultiplier = rotationMultiplier
    self.interactionMode = interactionMode
    self.content = content()
  }
  
  public var body: some View {
    TimelineView(.animation(paused: reduceMotion)) { timeline in
      let elapsedTime = reduceMotion ? 0 : startTime.distance(to: timeline.date)
      let effectiveTilt = interactionMode.normalizedTilt(
        translation: dragOffset,
        pointer: touchPosition,
        size: CGSize(width: width, height: height)
      )
      let rotation = interactionMode.rotation(
        for: effectiveTilt,
        multiplier: rotationMultiplier
      )
      let shadowTilt = reduceMotion ? CGPoint.zero : effectiveTilt
      let shadowScale = min(width, height) * 0.04

      content
        .shaderContext(tilt: effectiveTilt, time: elapsedTime, touchPosition: touchPosition)
        .frame(
          width: width > 0 && width.isFinite ? width : 1,
          height: height > 0 && height.isFinite ? height : 1
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .modifier(CardTransformEffect(
          tiltX: reduceMotion ? 0 : rotation.x,
          tiltY: reduceMotion ? 0 : rotation.y
        ))
        .shadow(
          color: shadowColor.opacity(0.5),
          radius: shadowScale * 1.5,
          x: shadowTilt.x * shadowScale,
          y: shadowTilt.y * shadowScale
        )
        .gesture(
          DragGesture(minimumDistance: 0)
            .onChanged { value in
              withAnimation(reduceMotion ? nil : .interactiveSpring) {
                dragOffset = value.translation
                touchPosition = CGPoint(
                  x: normalized(value.location.x, dimension: width),
                  y: normalized(value.location.y, dimension: height)
                )
              }
            }
            .onEnded { _ in
              withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                dragOffset = .zero
              }
              touchPosition = nil
            }
        )
    }
  }

  private func normalized(_ coordinate: CGFloat, dimension: CGFloat) -> CGFloat {
    guard dimension > 0, dimension.isFinite else { return 0.5 }
    return min(max(coordinate / dimension, 0), 1)
  }

}

private struct CardTransformEffect: GeometryEffect {
  var tiltX: Double
  var tiltY: Double

  var animatableData: AnimatablePair<Double, Double> {
    get { AnimatablePair(tiltX, tiltY) }
    set {
      tiltX = newValue.first
      tiltY = newValue.second
    }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    var t = CATransform3DIdentity
    t.m34 = -1.0 / 1000.0
    t = CATransform3DTranslate(t, size.width / 2, size.height / 2, 0)
    t = CATransform3DRotate(t, tiltX * .pi / 180, 1, 0, 0)
    t = CATransform3DRotate(t, tiltY * .pi / 180, 0, 1, 0)
    t = CATransform3DTranslate(t, -size.width / 2, -size.height / 2, 0)
    return ProjectionTransform(t)
  }
}
