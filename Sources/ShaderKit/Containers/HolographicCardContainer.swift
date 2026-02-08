//
//  HolographicCardContainer.swift
//  ShaderKit
//
//  Reusable container for holographic cards with drag/tilt/rotation behavior
//

import SwiftUI
import QuartzCore

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
/// - Device motion tracking via gyroscope
/// - Drag gesture for manual tilt control
/// - 3D rotation effects synchronized with tilt
/// - Dynamic shadow based on tilt angle
/// - Automatic shader context injection
public struct HolographicCardContainer<Content: View>: View {
  let width: CGFloat
  let height: CGFloat
  let cornerRadius: CGFloat
  let shadowColor: Color
  let rotationMultiplier: Double
  @ViewBuilder let content: () -> Content
  
  @State private var motionManager = MotionManager()
  @State private var startTime = Date.now
  @State private var dragOffset: CGSize = .zero
  @State private var touchPosition: CGPoint? = nil
  
  /// Creates a holographic card container.
  ///
  /// - Parameters:
  ///   - width: Card width in points
  ///   - height: Card height in points
  ///   - cornerRadius: Corner radius for clipping (default 16)
  ///   - shadowColor: Shadow color (default black)
  ///   - rotationMultiplier: 3D rotation intensity (default 15)
  ///   - content: Content builder - shader effects will automatically receive tilt and time
  public init(
    width: CGFloat,
    height: CGFloat,
    cornerRadius: CGFloat = 16,
    shadowColor: Color = .black,
    rotationMultiplier: Double = 15,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.width = width
    self.height = height
    self.cornerRadius = cornerRadius
    self.shadowColor = shadowColor
    self.rotationMultiplier = rotationMultiplier
    self.content = content
  }
  
  public var body: some View {
    TimelineView(.animation) { timeline in
      let elapsedTime = startTime.distance(to: timeline.date)
      let halfW = max(width * 0.5, 1)
      let halfH = max(height * 0.5, 1)
      let effectiveTilt = CGPoint(
        x: motionManager.tilt.x + dragOffset.width / halfW,
        y: motionManager.tilt.y + dragOffset.height / halfH
      )
      let shadowScale = min(width, height) * 0.04

      content()
        .shaderContext(tilt: effectiveTilt, time: elapsedTime, touchPosition: touchPosition)
        .frame(
          width: width > 0 && width.isFinite ? width : 1,
          height: height > 0 && height.isFinite ? height : 1
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .modifier(CardTransformEffect(
          tiltX: -effectiveTilt.y * rotationMultiplier,
          tiltY: effectiveTilt.x * rotationMultiplier
        ))
        .shadow(
          color: shadowColor.opacity(0.5),
          radius: shadowScale * 1.5,
          x: effectiveTilt.x * shadowScale,
          y: effectiveTilt.y * shadowScale
        )
        .gesture(
          DragGesture(minimumDistance: 0)
            .onChanged { value in
              withAnimation(.interactiveSpring) {
                dragOffset = value.translation
              }
              // Track touch position normalized to 0-1
              touchPosition = CGPoint(
                x: width > 0 ? value.location.x / width : 0,
                y: height > 0 ? value.location.y / height : 0
              )
            }
            .onEnded { _ in
              withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = .zero
              }
              touchPosition = nil
            }
        )
    }
    .onAppear { motionManager.start() }
    .onDisappear { motionManager.stop() }
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
