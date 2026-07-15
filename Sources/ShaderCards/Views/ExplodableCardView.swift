//
//  ExplodableCardView.swift
//  ShaderCards
//
//  Presents a card as an exploded 3D layer stack using ShaderKit's
//  CardLayerExplodeContainer: drag to orbit, pinch to spread the layers,
//  with spring-animated view presets.
//

import SwiftUI
import ShaderKit

/// An interactive exploded view of a card's composition.
///
/// The card separates into discrete layers — frame, artwork, chrome, and
/// one layer per holographic pass — with the same interaction model as
/// the ShaderKit builder:
/// - **Drag** orbits the stack (X/Y rotation, angular drags add Z).
/// - **Pinch** spreads the layers apart.
/// - On appear the stack springs into an isometric explode.
///
/// ```swift
/// ExplodableCardView(card: .creature(CardLibrary.mindmoth))
/// ```
/// Set `showsTransformControls` for slider control and view presets.
public struct ExplodableCardView: View {
  let card: Card
  let width: CGFloat
  let showsTransformControls: Bool
  /// Overrides the rarity-derived finish when non-nil.
  let finishOverride: CardFinish?
  /// Gradient sampled by the foil carrier layers.
  let shaderInputColors: [Color]

  private struct DragRotationStart {
    let xRotation: Double
    let yRotation: Double
    let zRotation: Double
    let startVector: CGPoint
  }

  private let explodeAnimation = Animation.spring(
    response: 0.75,
    dampingFraction: 0.62,
    blendDuration: 0.08
  )

  @State private var xRotation: Double = 0
  @State private var yRotation: Double = 0
  @State private var zRotation: Double = 0
  @State private var layerDistance: Double = 0
  @State private var didAnimateIn = false
  @State private var dragStart: DragRotationStart?
  @State private var pinchStartDistance: Double?
  @State private var isPinching = false

  public init(
    card: Card,
    width: CGFloat = 280,
    showsTransformControls: Bool = false,
    finish: CardFinish? = nil,
    shaderInputColors: [Color]? = nil
  ) {
    self.card = card
    self.width = width
    self.showsTransformControls = showsTransformControls
    self.finishOverride = finish
    self.shaderInputColors = shaderInputColors ?? CardLayerFactory.defaultShaderInputColors
  }

  public var body: some View {
    let metrics = CardMetrics.resolve(width: width)

    VStack(spacing: 18) {
      CardLayerExplodeContainer(
        width: metrics.width,
        height: metrics.height,
        cornerRadius: metrics.cornerRadius,
        xRotation: xRotation,
        yRotation: yRotation,
        zRotation: zRotation,
        layerDistance: layerDistance,
        shadowColor: .black,
        animation: explodeAnimation,
        layers: CardLayerFactory.layers(
          for: card,
          metrics: metrics,
          finish: finishOverride,
          shaderInputColors: shaderInputColors
        )
      )
      .frame(width: metrics.width, height: metrics.height + 100)
      .contentShape(Rectangle())
      .gesture(dragRotationGesture(metrics: metrics))
      .simultaneousGesture(pinchLayerGesture)

      if showsTransformControls {
        transformControls(metrics: metrics)
      }
    }
    .onAppear {
      guard !didAnimateIn else { return }
      didAnimateIn = true
      withAnimation(explodeAnimation) {
        applyPreset(.isometric)
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Exploded layer view of \(card.displayName)")
  }

  // MARK: - Presets

  /// Camera/spread presets matching the ShaderKit builder.
  enum ViewPreset {
    case flat
    case isometric
    case topDown

    var values: (x: Double, y: Double, z: Double, distance: Double) {
      switch self {
      case .flat: (0, 0, 0, 0)
      case .isometric: (58, -12, 0, 0.055)
      case .topDown: (65, -14, 59, 0.11)
      }
    }
  }

  private func applyPreset(_ preset: ViewPreset) {
    let values = preset.values
    xRotation = values.x
    yRotation = values.y
    zRotation = values.z
    layerDistance = values.distance
  }

  // MARK: - Gestures

  private func dragRotationGesture(metrics: CardMetrics.Resolved) -> some Gesture {
    DragGesture(minimumDistance: 1, coordinateSpace: .local)
      .onChanged { value in
        guard !isPinching else {
          dragStart = nil
          return
        }

        let center = CGPoint(x: metrics.width * 0.5, y: metrics.height * 0.5)
        let currentVector = CGPoint(
          x: value.location.x - center.x,
          y: value.location.y - center.y
        )

        if dragStart == nil {
          dragStart = DragRotationStart(
            xRotation: xRotation,
            yRotation: yRotation,
            zRotation: zRotation,
            startVector: CGPoint(
              x: value.startLocation.x - center.x,
              y: value.startLocation.y - center.y
            )
          )
        }
        guard let dragStart else { return }

        let xDelta = Double(value.translation.height / metrics.height) * 180
        let yDelta = Double(value.translation.width / metrics.width) * 180
        xRotation = clamped(dragStart.xRotation - xDelta, to: -180...180)
        yRotation = clamped(dragStart.yRotation + yDelta, to: -180...180)

        let startLength = hypot(dragStart.startVector.x, dragStart.startVector.y)
        let currentLength = hypot(currentVector.x, currentVector.y)
        if startLength > 10, currentLength > 10 {
          let startAngle = atan2(dragStart.startVector.y, dragStart.startVector.x)
          let currentAngle = atan2(currentVector.y, currentVector.x)
          let zDelta = Double(normalizedAngle(currentAngle - startAngle) * 180 / .pi)
          zRotation = clamped(dragStart.zRotation + zDelta, to: -180...180)
        }
      }
      .onEnded { _ in
        dragStart = nil
      }
  }

  private var pinchLayerGesture: some Gesture {
    MagnificationGesture()
      .onChanged { scale in
        isPinching = true
        dragStart = nil
        if pinchStartDistance == nil {
          pinchStartDistance = layerDistance
        }
        guard let pinchStartDistance else { return }
        let delta = Double(scale - 1) * 0.14
        layerDistance = clamped(pinchStartDistance + delta, to: 0...0.14)
      }
      .onEnded { _ in
        pinchStartDistance = nil
        isPinching = false
      }
  }

  private func clamped(_ value: Double, to range: ClosedRange<Double>) -> Double {
    Swift.max(range.lowerBound, Swift.min(value, range.upperBound))
  }

  private func normalizedAngle(_ angle: CGFloat) -> CGFloat {
    var normalized = angle
    let twoPi = CGFloat.pi * 2
    while normalized > .pi { normalized -= twoPi }
    while normalized < -.pi { normalized += twoPi }
    return normalized
  }

  // MARK: - Controls

  private func transformControls(metrics: CardMetrics.Resolved) -> some View {
    VStack(spacing: 12) {
      HStack(spacing: 10) {
        presetButton("Flat", preset: .flat)
        presetButton("Isometric", preset: .isometric)
        presetButton("Top Down", preset: .topDown)
      }

      TransformSliderRow(title: "X Rotation", value: $xRotation, range: -180...180,
                         valueText: "\(Int(xRotation.rounded()))°")
      TransformSliderRow(title: "Y Rotation", value: $yRotation, range: -180...180,
                         valueText: "\(Int(yRotation.rounded()))°")
      TransformSliderRow(title: "Z Rotation", value: $zRotation, range: -180...180,
                         valueText: "\(Int(zRotation.rounded()))°")
      TransformSliderRow(title: "Layer Spread", value: $layerDistance, range: 0...0.14,
                         valueText: "\(Int((layerDistance * metrics.height).rounded())) pt",
                         step: 0.001)
    }
    .tint(.orange)
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 14)
        .fill(.white.opacity(0.07))
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    )
    .frame(maxWidth: 420)
  }

  private func presetButton(_ title: String, preset: ViewPreset) -> some View {
    Button(title) {
      withAnimation(explodeAnimation) {
        applyPreset(preset)
      }
    }
    .font(.system(size: 12, weight: .semibold))
    .foregroundStyle(.white)
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(Capsule().fill(.white.opacity(0.14)))
    .buttonStyle(.plain)
  }
}

/// Labeled slider row shared by the transform panels.
struct TransformSliderRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>
  let valueText: String
  var step: Double = 1

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(title)
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.white)
        Spacer()
        Text(valueText)
          .font(.system(size: 11, weight: .medium, design: .monospaced))
          .foregroundStyle(.white.opacity(0.85))
      }
      Slider(value: $value, in: range, step: step)
    }
  }
}

extension ShaderEffect {
  /// A short human-readable label for layer displays, derived from the
  /// case name: `.verticalBeams(0.85)` → "Vertical Beams".
  var layerLabel: String {
    if case .tradingCardHolo(let style, _) = self {
      return style.displayName
    }

    let caseName = String(describing: self).prefix { $0 != "(" }
    var words: [String] = []
    var current = ""
    for character in caseName {
      if character.isUppercase {
        words.append(current)
        current = String(character)
      } else {
        current.append(character)
      }
    }
    words.append(current)
    return words
      .filter { !$0.isEmpty }
      .map { $0.prefix(1).uppercased() + $0.dropFirst() }
      .joined(separator: " ")
  }
}
