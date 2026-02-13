//
//  CardLayerExplodeView.swift
//  ShaderKitDemo
//
//  Exploded card layer demo with slider-driven X/Y/Z rotation and depth spacing.
//

import SwiftUI
import ShaderKit

struct CardLayerExplodeView: View {
  private struct DragRotationStart {
    let xRotation: Double
    let yRotation: Double
    let zRotation: Double
    let startVector: CGPoint
  }

  private let cardWidth: CGFloat = 260
  private let cardHeight: CGFloat = 380
  private let cornerRadius: CGFloat = 16
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

  private let defaultXRotation: Double = 58
  private let defaultYRotation: Double = -12
  private let defaultZRotation: Double = 0
  private let defaultLayerDistance: Double = 0.055
  private let dragXRange: ClosedRange<Double> = -180...180
  private let dragYRange: ClosedRange<Double> = -180...180
  private let dragZRange: ClosedRange<Double> = -180...180

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.08, green: 0.11, blue: 0.17),
          Color(red: 0.02, green: 0.03, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 20) {
        Spacer(minLength: 8)

        CardLayerExplodeContainer(
          width: cardWidth,
          height: cardHeight,
          cornerRadius: cornerRadius,
          xRotation: xRotation,
          yRotation: yRotation,
          zRotation: zRotation,
          layerDistance: layerDistance,
          shadowColor: .black,
          animation: explodeAnimation,
          layers: cardLayers
        )
        .frame(height: cardHeight + 120)
        .contentShape(Rectangle())
        .gesture(dragRotationGesture)
        .simultaneousGesture(pinchLayerGesture)

        controls
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 18)
              .fill(.ultraThinMaterial)
              .overlay(
                RoundedRectangle(cornerRadius: 18)
                  .strokeBorder(.white.opacity(0.18), lineWidth: 1)
              )
          )
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 20)
    }
    .onAppear {
      guard !didAnimateIn else { return }
      didAnimateIn = true
      withAnimation(explodeAnimation) {
        xRotation = defaultXRotation
        yRotation = defaultYRotation
        zRotation = defaultZRotation
        layerDistance = defaultLayerDistance
      }
    }
  }

  private var dragRotationGesture: some Gesture {
    DragGesture(minimumDistance: 1, coordinateSpace: .local)
      .onChanged { value in
        guard !isPinching else {
          dragStart = nil
          return
        }

        let center = CGPoint(x: cardWidth * 0.5, y: cardHeight * 0.5)
        let currentVector = CGPoint(
          x: value.location.x - center.x,
          y: value.location.y - center.y
        )

        if dragStart == nil {
          let startVector = CGPoint(
            x: value.startLocation.x - center.x,
            y: value.startLocation.y - center.y
          )
          dragStart = DragRotationStart(
            xRotation: xRotation,
            yRotation: yRotation,
            zRotation: zRotation,
            startVector: startVector
          )
        }

        guard let dragStart else { return }

        let xDelta = Double(value.translation.height / cardHeight) * 180
        let yDelta = Double(value.translation.width / cardWidth) * 180
        xRotation = clamped(dragStart.xRotation - xDelta, to: dragXRange)
        yRotation = clamped(dragStart.yRotation + yDelta, to: dragYRange)

        let startLength = hypot(dragStart.startVector.x, dragStart.startVector.y)
        let currentLength = hypot(currentVector.x, currentVector.y)
        if startLength > 10, currentLength > 10 {
          let startAngle = atan2(dragStart.startVector.y, dragStart.startVector.x)
          let currentAngle = atan2(currentVector.y, currentVector.x)
          let zDelta = Double(normalizedAngle(currentAngle - startAngle) * 180 / .pi)
          zRotation = clamped(dragStart.zRotation + zDelta, to: dragZRange)
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
    while normalized > .pi {
      normalized -= twoPi
    }
    while normalized < -.pi {
      normalized += twoPi
    }
    return normalized
  }

  private var controls: some View {
    VStack(spacing: 14) {
      ExplodeControlRow(
        title: "X Rotation",
        value: $xRotation,
        range: -180...180,
        valueText: "\(Int(xRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Y Rotation",
        value: $yRotation,
        range: -180...180,
        valueText: "\(Int(yRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Z Rotation",
        value: $zRotation,
        range: -180...180,
        valueText: "\(Int(zRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Layer Distance",
        value: $layerDistance,
        range: 0...0.14,
        valueText: "\(Int((layerDistance * cardHeight).rounded())) pt",
        step: 0.001
      )
    }
    .tint(.orange)
  }

  private var cardLayers: [CardLayerExplodeLayer] {
    [
      CardLayerExplodeLayer(id: "base-fill") {
        baseFillLayer
      },
      CardLayerExplodeLayer(id: "artwork") {
        artworkLayer
      },
      CardLayerExplodeLayer(id: "overlay-gradients") {
        overlayGradientLayer
      },
      CardLayerExplodeLayer(id: "shader-pass") {
        shaderPassLayer
      },
      CardLayerExplodeLayer(id: "ui-chrome") {
        uiChromeLayer
      }
    ]
  }

  private var baseFillLayer: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: [
            Color(red: 0.96, green: 0.88, blue: 0.56),
            Color(red: 0.9, green: 0.76, blue: 0.42),
            Color(red: 0.83, green: 0.67, blue: 0.33)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                .white.opacity(0.24),
                .clear,
                .black.opacity(0.14)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
  }

  private var artworkLayer: some View {
    Image("unicorn")
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: cardWidth, height: cardHeight)
      .clipped()
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
  }

  private var overlayGradientLayer: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: [
            .black.opacity(0.22),
            .clear,
            .black.opacity(0.35)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                .white.opacity(0.28),
                .clear
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
      .blendMode(.overlay)
  }

  private var shaderPassLayer: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: [
            .white.opacity(0.32),
            .yellow.opacity(0.12),
            .clear
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .blendMode(.screen)
      .foil()
      .glitter(density: 75)
      .lightSweep()
  }

  private var uiChromeLayer: some View {
    ZStack {
      VStack(spacing: 0) {
        HStack(alignment: .top, spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("CARD FOIL")
              .font(.system(size: 10, weight: .heavy))
              .foregroundStyle(.white.opacity(0.9))
            Text("Exploded Composition")
              .font(.system(size: 17, weight: .black))
              .foregroundStyle(.white)
          }
          Spacer()
          Text("LV 180")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)

        Spacer()

        VStack(alignment: .leading, spacing: 7) {
          Text("Foil + Glitter + Light Sweep")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
          Text("Layered explode view with synchronized spring motion and stable z-ordering.")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white.opacity(0.82))
            .lineLimit(2)

          HStack {
            Label("Blend", systemImage: "circle.lefthalf.filled")
            Spacer()
            Label("5 Layers", systemImage: "square.3.layers.3d")
          }
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
      }

      RoundedRectangle(cornerRadius: cornerRadius)
        .strokeBorder(
          LinearGradient(
            colors: [
              .yellow.opacity(0.9),
              .white.opacity(0.7),
              .orange.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 3
        )
    }
  }
}

private struct ExplodeControlRow: View {
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

#Preview {
  CardLayerExplodeView()
}
