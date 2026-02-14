//
//  ExplodableHolographicCard.swift
//  ShaderKit
//
//  A holographic card container that reveals individual layers in 3D when tapped
//

import SwiftUI
import QuartzCore

/// A container that displays holographic card layers and explodes them into
/// a 3D isometric view when tapped, revealing the shader composition.
///
/// Unlike `HolographicCardContainer` which chains shader modifiers (causing layers
/// to flatten), this container keeps each layer discrete and renders them independently.
/// When tapped, layers spread apart vertically in an isometric perspective to visualize
/// how the card's appearance is composited from multiple shader passes.
///
/// ## Usage
///
/// ```swift
/// ExplodableHolographicCard(width: 260, height: 380) {
///   CardLayer {
///     RoundedRectangle(cornerRadius: 16)
///       .fill(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
///   }
///   .label("Base Frame")
///   .zIndex(0)
///
///   CardLayer {
///     Image("artwork")
///       .resizable()
///       .aspectRatio(contentMode: .fill)
///   }
///   .label("Artwork")
///   .zIndex(1)
///
///   CardLayer {
///     Color.clear
///   }
///   .effects([.foil(intensity: 0.8)])
///   .label("Holographic Foil")
///   .zIndex(2)
///
///   CardLayer {
///     Color.clear
///   }
///   .effects([.glassSheen(intensity: 0.6, spread: 0.5)])
///   .label("Specular Shine")
///   .zIndex(3)
/// }
/// ```
///
/// ## Gestures
///
/// - **Tap**: Toggles between flat view and exploded isometric layer view
/// - **Drag**: Tilts the card for holographic effects
public struct ExplodableHolographicCard: View {
  private let width: CGFloat
  private let height: CGFloat
  private let cornerRadius: CGFloat
  private let shadowColor: Color
  private let rotationMultiplier: Double
  private let initialLayerSpacing: CGFloat
  private let dragExplosionDistance: CGFloat
  private let showLabels: Bool
  private let showControls: Bool
  private let layers: [CardLayer]

  @State private var motionManager = MotionManager()
  @State private var startTime = Date.now
  @State private var dragOffset: CGSize = .zero
  @State private var touchPosition: CGPoint? = nil
  @State private var explosionProgress: CGFloat = 0
  @State private var isExploded: Bool = false

  @State private var isDragging: Bool = false
  @State private var lastDragLocation: CGPoint? = nil

  // Controllable rotation and spread values (matching React reference defaults)
  @State private var rotateX: Double = -20
  @State private var rotateY: Double = -30
  @State private var rotateZ: Double = 0
  @State private var spread: Double = 60

  /// Creates an explodable holographic card container.
  ///
  /// - Parameters:
  ///   - width: Card width in points
  ///   - height: Card height in points
  ///   - cornerRadius: Corner radius for layer clipping (default 16)
  ///   - shadowColor: Shadow color for the collapsed card (default black)
  ///   - rotationMultiplier: 3D rotation intensity (default 15)
  ///   - layerSpacing: Z-distance between layers when fully exploded (default 60)
  ///   - dragExplosionDistance: Drag distance (in points) required for full explosion (default 160)
  ///   - showLabels: Whether to show layer labels when exploded (default true)
  ///   - showControls: Whether to show rotation/spread control sliders (default false)
  ///   - layers: A result builder providing the card layers
  public init(
    width: CGFloat,
    height: CGFloat,
    cornerRadius: CGFloat = 16,
    shadowColor: Color = .black,
    rotationMultiplier: Double = 15,
    layerSpacing: CGFloat = 60,
    dragExplosionDistance: CGFloat = 160,
    showLabels: Bool = true,
    showControls: Bool = false,
    @CardLayerBuilder layers: () -> [CardLayer]
  ) {
    self.width = width
    self.height = height
    self.cornerRadius = cornerRadius
    self.shadowColor = shadowColor
    self.rotationMultiplier = rotationMultiplier
    self.initialLayerSpacing = layerSpacing
    self.dragExplosionDistance = dragExplosionDistance
    self.showLabels = showLabels
    self.showControls = showControls
    self.layers = layers().sorted { $0.zIndex < $1.zIndex }
  }

  public var body: some View {
    VStack(spacing: 20) {
      cardView

      if showControls {
        controlPanel
      }
    }
    .onAppear {
      motionManager.start()
      spread = initialLayerSpacing
    }
    .onDisappear { motionManager.stop() }
  }

  private var cardView: some View {
    TimelineView(.animation) { timeline in
      let elapsedTime = startTime.distance(to: timeline.date)
      let halfW = max(width * 0.5, 1)
      let halfH = max(height * 0.5, 1)
      let effectiveTilt = CGPoint(
        x: motionManager.tilt.x + (showControls ? 0 : dragOffset.width / halfW),
        y: motionManager.tilt.y + (showControls ? 0 : dragOffset.height / halfH)
      )
      let shadowScale = min(width, height) * 0.04
      let explosionFade = 1 - Double(explosionProgress) * 0.7
      let ctrlRotX = showControls ? rotateX : rotateX * Double(explosionProgress)
      let ctrlRotY = showControls ? rotateY : rotateY * Double(explosionProgress)
      let ctrlRotZ = showControls ? rotateZ : rotateZ * Double(explosionProgress)

      ZStack {
        ForEach(Array(layers.enumerated()), id: \.element.id) { index, layer in
          let zOffset = calculateZOffset(for: index)

          ExplodedLayerView(
            layer: layer,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            tilt: effectiveTilt,
            time: elapsedTime,
            touchPosition: touchPosition,
            zOffset: zOffset,
            explosionProgress: explosionProgress,
            rotationMultiplier: rotationMultiplier * (1 - Double(explosionProgress) * 0.5),
            showLabels: showLabels,
            useDirectOffset: showControls
          )
        }
      }
      .modifier(CardTransformEffect3D(
        tiltX: -effectiveTilt.y * rotationMultiplier * explosionFade + ctrlRotX,
        tiltY: effectiveTilt.x * rotationMultiplier * explosionFade + ctrlRotY,
        tiltZ: ctrlRotZ
      ))
      .shadow(
        color: shadowColor.opacity(0.5 * Double(1 - explosionProgress * 0.5)),
        radius: shadowScale * 1.5 + 10 * Double(explosionProgress),
        x: effectiveTilt.x * shadowScale + 15 * CGFloat(explosionProgress),
        y: effectiveTilt.y * shadowScale + 25 * CGFloat(explosionProgress)
      )
      .gesture(dragGesture)
      .onTapGesture {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
          isExploded.toggle()
          explosionProgress = isExploded ? 1.0 : 0.0
        }
      }
    }
  }

  private var controlPanel: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("Transform")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.white)

        // Slider section
        VStack(spacing: 10) {
          ControlRow(
            title: "Layer Separation",
            value: $spread,
            range: 0...150,
            valueText: "\(Int(spread))px"
          )
          ControlRow(
            title: "X Rotation",
            value: $rotateX,
            range: -180...180,
            valueText: "\(Int(rotateX))°"
          )
          ControlRow(
            title: "Y Rotation",
            value: $rotateY,
            range: -180...180,
            valueText: "\(Int(rotateY))°"
          )
          ControlRow(
            title: "Z Rotation",
            value: $rotateZ,
            range: -180...180,
            valueText: "\(Int(rotateZ))°"
          )
        }
        .tint(.orange)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.08)))

        // Presets section
        VStack(alignment: .leading, spacing: 8) {
          Text("Presets")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)

          HStack(spacing: 10) {
            Button("Default View") {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                rotateX = -20
                rotateY = -30
                rotateZ = 0
                spread = 60
              }
            }
            .buttonStyle(DarkControlButton())

            Button("Top-Down View") {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                rotateX = 65
                rotateY = -14
                rotateZ = 59
                spread = 118
              }
            }
            .buttonStyle(DarkControlButtonProminent())
          }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.08)))
      }
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 18)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 18)
            .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        )
    )
    .frame(maxWidth: 450)
  }

  private func calculateZOffset(for index: Int) -> CGFloat {
    // Each layer gets progressively higher offset
    // Layer 0 stays at bottom, higher layers float up
    return CGFloat(index) * spread
  }

  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 5)
      .onChanged { value in
        if showControls {
          if !isDragging {
            isDragging = true
            lastDragLocation = value.location
          }

          if let lastDragLocation {
            let deltaX = value.location.x - lastDragLocation.x
            let deltaY = value.location.y - lastDragLocation.y
            rotateY += Double(deltaX) * 0.5
            rotateX -= Double(deltaY) * 0.5
          }
          lastDragLocation = value.location
        } else {
          withAnimation(.interactiveSpring) {
            dragOffset = value.translation
          }
        }

        touchPosition = CGPoint(
          x: width > 0 ? value.location.x / width : 0,
          y: height > 0 ? value.location.y / height : 0
        )
      }
      .onEnded { _ in
        if showControls {
          isDragging = false
          lastDragLocation = nil
        } else {
          withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = .zero
          }
        }
        touchPosition = nil
      }
  }
}

private struct CardTransformEffect3D: GeometryEffect {
  var tiltX: Double
  var tiltY: Double
  var tiltZ: Double

  var animatableData: AnimatablePair<AnimatablePair<Double, Double>, Double> {
    get { AnimatablePair(AnimatablePair(tiltX, tiltY), tiltZ) }
    set {
      tiltX = newValue.first.first
      tiltY = newValue.first.second
      tiltZ = newValue.second
    }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    var t = CATransform3DIdentity
    t.m34 = -1.0 / 1000.0
    t = CATransform3DTranslate(t, size.width / 2, size.height / 2, 0)
    t = CATransform3DRotate(t, tiltX * .pi / 180, 1, 0, 0)
    t = CATransform3DRotate(t, tiltY * .pi / 180, 0, 1, 0)
    t = CATransform3DRotate(t, tiltZ * .pi / 180, 0, 0, 1)
    t = CATransform3DTranslate(t, -size.width / 2, -size.height / 2, 0)
    return ProjectionTransform(t)
  }
}

private struct ControlRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>
  let valueText: String
  var step: Double = 1

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(title)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(.white)
        Spacer()
        Text(valueText)
          .font(.system(size: 12, weight: .medium, design: .monospaced))
          .foregroundStyle(.white.opacity(0.85))
      }
      Slider(value: $value, in: range, step: step)
    }
  }
}

private struct DarkControlButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .semibold))
      .foregroundStyle(.white)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(configuration.isPressed ? 0.22 : 0.14)))
  }
}

private struct DarkControlButtonProminent: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .semibold))
      .foregroundStyle(.white)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(RoundedRectangle(cornerRadius: 8).fill(.orange.opacity(configuration.isPressed ? 0.75 : 0.9)))
  }
}
