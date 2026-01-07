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
      let effectiveTilt = CGPoint(
        x: motionManager.tilt.x + dragOffset.width / 100,
        y: motionManager.tilt.y + dragOffset.height / 100
      )

      content()
        .shaderContext(tilt: effectiveTilt, time: elapsedTime, touchPosition: touchPosition)
        .frame(
          width: width > 0 && width.isFinite ? width : 1,
          height: height > 0 && height.isFinite ? height : 1
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .rotation3DEffect(
          .degrees(effectiveTilt.x * rotationMultiplier),
          axis: (x: 0, y: 1, z: 0),
          perspective: 0.5
        )
        .rotation3DEffect(
          .degrees(-effectiveTilt.y * rotationMultiplier),
          axis: (x: 1, y: 0, z: 0),
          perspective: 0.5
        )
        .shadow(
          color: shadowColor.opacity(0.5),
          radius: 20,
          x: CGFloat(effectiveTilt.x * 10),
          y: CGFloat(effectiveTilt.y * 10)
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
              withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
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
