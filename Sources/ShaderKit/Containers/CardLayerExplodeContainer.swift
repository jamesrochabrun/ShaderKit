//
//  CardLayerExplodeContainer.swift
//  ShaderKit
//
//  A reusable container for exploded card layer previews with animated 3D depth.
//

import SwiftUI
import QuartzCore

/// A compositing layer used by ``CardLayerExplodeContainer``.
public struct CardLayerExplodeLayer: Identifiable {
  public let id: String
  fileprivate let content: AnyView

  /// Creates a compositing layer.
  /// - Parameters:
  ///   - id: Stable identifier for z-ordering and animations.
  ///   - content: Full-size card layer content.
  public init<V: View>(
    id: String,
    @ViewBuilder content: () -> V
  ) {
    self.id = id
    self.content = AnyView(content())
  }
}

/// A container that separates card compositing layers along the Z-axis.
///
/// The container keeps every layer's size/content intact while applying:
/// - Shared card rotation in X/Y/Z
/// - Proportional Z-spacing based on card height
/// - Progressive soft shadows per layer
/// - Shader context injection from rotation/time
///
/// Use this for exploded-view card inspections where layer hierarchy should stay readable.
public struct CardLayerExplodeContainer: View {
  private let width: CGFloat
  private let height: CGFloat
  private let cornerRadius: CGFloat
  private let xRotation: Double
  private let yRotation: Double
  private let zRotation: Double
  private let layerDistance: Double
  private let perspective: CGFloat
  private let shadowColor: Color
  private let animation: Animation
  private let layers: [CardLayerExplodeLayer]

  @State private var startTime = Date.now

  /// Creates a card layer explode container.
  ///
  /// - Parameters:
  ///   - width: Card width in points.
  ///   - height: Card height in points.
  ///   - cornerRadius: Corner radius applied to layers that need clipping.
  ///   - xRotation: Card X rotation in degrees.
  ///   - yRotation: Card Y rotation in degrees.
  ///   - zRotation: Card Z rotation in degrees.
  ///   - layerDistance: Distance fraction relative to card height (`0.05` = `5%` of card height).
  ///   - perspective: Perspective depth denominator for 3D projection.
  ///   - shadowColor: Base shadow color for inter-layer depth shadows.
  ///   - animation: Animation used for rotation/depth transitions.
  ///   - layers: Ordered compositing layers from back to front.
  public init(
    width: CGFloat,
    height: CGFloat,
    cornerRadius: CGFloat = 16,
    xRotation: Double,
    yRotation: Double,
    zRotation: Double,
    layerDistance: Double,
    perspective: CGFloat = 900,
    shadowColor: Color = .black,
    animation: Animation = .spring(response: 0.75, dampingFraction: 0.62, blendDuration: 0.08),
    layers: [CardLayerExplodeLayer]
  ) {
    self.width = width
    self.height = height
    self.cornerRadius = cornerRadius
    self.xRotation = xRotation
    self.yRotation = yRotation
    self.zRotation = zRotation
    self.layerDistance = layerDistance
    self.perspective = perspective
    self.shadowColor = shadowColor
    self.animation = animation
    self.layers = layers
  }

  public var body: some View {
    TimelineView(.animation) { timeline in
      let elapsedTime = startTime.distance(to: timeline.date)
      let spacing = max(0, layerDistance) * height
      let midpoint = CGFloat(max(layers.count - 1, 0)) * 0.5
      let tilt = CGPoint(
        x: yRotation / 180.0,
        y: -xRotation / 180.0
      )

      ZStack {
        ForEach(Array(layers.enumerated()), id: \.element.id) { index, layer in
          let relativeIndex = CGFloat(index) - midpoint
          let zDepth = relativeIndex * spacing
          let shadowRatio = CGFloat(index) / CGFloat(max(layers.count - 1, 1))

          layer.content
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .modifier(CardLayerTransformEffect(
              zDepth: zDepth,
              xRotation: xRotation,
              yRotation: yRotation,
              zRotation: zRotation,
              perspective: perspective
            ))
            .shadow(
              color: shadowColor.opacity(0.08 + (0.18 * shadowRatio)),
              radius: 8 + (10 * shadowRatio),
              x: CGFloat(-yRotation / 180.0) * (4 + 2 * shadowRatio),
              y: 2 + (8 * shadowRatio) + CGFloat(abs(xRotation) / 180.0) * 4
            )
            .zIndex(Double(index))
            .allowsHitTesting(false)
        }
      }
      .shaderContext(tilt: tilt, time: elapsedTime)
      .frame(width: width, height: height)
      .animation(animation, value: xRotation)
      .animation(animation, value: yRotation)
      .animation(animation, value: zRotation)
      .animation(animation, value: layerDistance)
    }
  }
}

private struct CardLayerTransformEffect: GeometryEffect {
  var zDepth: CGFloat
  var xRotation: Double
  var yRotation: Double
  var zRotation: Double
  var perspective: CGFloat

  var animatableData: AnimatablePair<AnimatablePair<Double, Double>, AnimatablePair<Double, Double>> {
    get {
      AnimatablePair(
        AnimatablePair(Double(zDepth), xRotation),
        AnimatablePair(yRotation, zRotation)
      )
    }
    set {
      zDepth = CGFloat(newValue.first.first)
      xRotation = newValue.first.second
      yRotation = newValue.second.first
      zRotation = newValue.second.second
    }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    var transform = CATransform3DIdentity
    transform.m34 = -1.0 / max(perspective, 1)
    transform = CATransform3DTranslate(transform, size.width * 0.5, size.height * 0.5, 0)
    transform = CATransform3DRotate(transform, xRotation * .pi / 180, 1, 0, 0)
    transform = CATransform3DRotate(transform, yRotation * .pi / 180, 0, 1, 0)
    transform = CATransform3DRotate(transform, zRotation * .pi / 180, 0, 0, 1)
    transform = CATransform3DTranslate(transform, 0, 0, zDepth)
    transform = CATransform3DTranslate(transform, -size.width * 0.5, -size.height * 0.5, 0)
    return ProjectionTransform(transform)
  }
}
