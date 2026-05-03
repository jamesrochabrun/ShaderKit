//
//  CodexLogoView.swift
//  ShaderKitDemo
//
//  Demo-only Codex Logo shader showcase
//

import SwiftUI
import ShaderKit

enum CodexLogoBlobGeometry {
  struct CircleLobe {
    let center: CGPoint
    let radius: CGFloat
  }

  static let lobeCount = 6

  private static let defaultSampleCount = 192
  private static let defaultSamples = makeSamples(count: defaultSampleCount)
  private static let origin = CGPoint(x: 0.500, y: 0.500)
  private static let centerRadius: CGFloat = 0.230
  private static let petalDistance: CGFloat = 0.275
  private static let petalRadius: CGFloat = 0.215
  private static let fallbackRadius: CGFloat = centerRadius

  private static let lobes: [CircleLobe] = makeLobes()

  private static func makeLobes() -> [CircleLobe] {
    var result: [CircleLobe] = [
      CircleLobe(center: origin, radius: centerRadius)
    ]

    let startAngle = -CGFloat.pi / 2.0 - CGFloat.pi / CGFloat(lobeCount)
    let step = 2.0 * CGFloat.pi / CGFloat(lobeCount)

    for index in 0..<lobeCount {
      let angle = startAngle + step * CGFloat(index)
      let center = CGPoint(
        x: origin.x + petalDistance * CGFloat(cos(Double(angle))),
        y: origin.y + petalDistance * CGFloat(sin(Double(angle)))
      )
      result.append(CircleLobe(center: center, radius: petalRadius))
    }

    return result
  }

  static func normalizedSamples(count: Int = defaultSampleCount) -> [CGPoint] {
    if count == defaultSampleCount {
      return defaultSamples
    }

    return makeSamples(count: count)
  }

  static func squareRenderRect(in rect: CGRect) -> CGRect {
    let side = min(rect.width, rect.height)

    return CGRect(
      x: rect.midX - side / 2.0,
      y: rect.midY - side / 2.0,
      width: side,
      height: side
    )
  }

  private static func makeSamples(count: Int) -> [CGPoint] {
    let sampleCount = max(count, 32)

    return (0..<sampleCount).map { index in
      let progress = CGFloat(index) / CGFloat(sampleCount)
      let angle = -CGFloat.pi + progress * CGFloat.pi * 2.0
      let direction = CGPoint(
        x: CGFloat(cos(Double(angle))),
        y: CGFloat(sin(Double(angle)))
      )
      let radius = farthestCircleExit(along: direction)

      return CGPoint(
        x: origin.x + direction.x * radius,
        y: origin.y + direction.y * radius
      )
    }
  }

  private static func farthestCircleExit(along direction: CGPoint) -> CGFloat {
    var farthestExit = CGFloat.zero

    for lobe in lobes {
      let relativeCenter = CGPoint(
        x: lobe.center.x - origin.x,
        y: lobe.center.y - origin.y
      )
      let projection = relativeCenter.x * direction.x + relativeCenter.y * direction.y
      let perpendicularDistanceSquared =
        relativeCenter.x * relativeCenter.x +
        relativeCenter.y * relativeCenter.y -
        projection * projection
      let radiusSquared = lobe.radius * lobe.radius

      guard perpendicularDistanceSquared < radiusSquared else {
        continue
      }

      let exit = projection + sqrt(radiusSquared - perpendicularDistanceSquared)
      farthestExit = max(farthestExit, exit)
    }

    return max(farthestExit, fallbackRadius)
  }
}

enum CodexLogoMotionResponse {
  static func effectiveTilt(
    deviceTilt: CGPoint,
    dragTilt: CGPoint,
    motionStrength: Double,
    hasDeviceMotion: Bool
  ) -> CGPoint {
    let source = hasDeviceMotion ? deviceTilt : dragTilt
    let strength = min(max(motionStrength, 0.0), 1.5)

    return CGPoint(
      x: min(max(source.x, -1.0), 1.0) * strength,
      y: min(max(source.y, -1.0), 1.0) * strength
    )
  }

  static func pulseScale(
    time: TimeInterval,
    pulseSpeed: Double,
    reduceMotion: Bool
  ) -> Double {
    let amplitude = reduceMotion ? 0.006 : 0.035
    let phase = sin(time * pulseSpeed * .pi * 2.0)
    return 1.0 + ((phase + 1.0) * 0.5 * amplitude)
  }
}

struct CodexLogoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var motionManager = MotionManager()
  @State private var dragTilt = CGPoint.zero
  private let intensity = 1.08
  private let pulse = 0.78
  private let density = 1.35
  private let glow = 1.04
  private let motion = 0.82

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.02, green: 0.025, blue: 0.04),
          Color(red: 0.06, green: 0.07, blue: 0.11),
          Color(red: 0.02, green: 0.03, blue: 0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      TimelineView(.animation) { context in
        let time = context.date.timeIntervalSinceReferenceDate
        let tilt = CodexLogoMotionResponse.effectiveTilt(
          deviceTilt: motionManager.tilt,
          dragTilt: dragTilt,
          motionStrength: motion,
          hasDeviceMotion: motionManager.isAvailable
        )
        let scale = CodexLogoMotionResponse.pulseScale(
          time: time,
          pulseSpeed: pulse,
          reduceMotion: reduceMotion
        )

        CodexLogoMark(
          time: time,
          tilt: tilt,
          scale: scale,
          intensity: intensity,
          pulse: pulse,
          density: density,
          glow: glow,
          motion: motion,
          reduceMotion: reduceMotion,
          dragTilt: $dragTilt
        )
        .frame(maxWidth: 360)
        .aspectRatio(1.0, contentMode: .fit)
        .padding(.horizontal, 26)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .navigationTitle("Codex Logo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
    .onAppear {
      motionManager.start()
    }
    .onDisappear {
      motionManager.stop()
    }
  }
}

private struct CodexLogoMark: View {
  let time: TimeInterval
  let tilt: CGPoint
  let scale: Double
  let intensity: Double
  let pulse: Double
  let density: Double
  let glow: Double
  let motion: Double
  let reduceMotion: Bool
  @Binding var dragTilt: CGPoint

  var body: some View {
    GeometryReader { proxy in
      let availableSize = proxy.size
      let renderSide = max(1.0, min(availableSize.width, availableSize.height))
      let renderSize = CGSize(width: renderSide, height: renderSide)
      let glowRadius = reduceMotion ? 16.0 : 30.0 + glow * 10.0

      ZStack {
        CodexLogoBlobShape()
          .fill(Color(red: 0.24, green: 0.36, blue: 1.0))
          .blur(radius: glowRadius)
          .opacity(0.34 + glow * 0.14)
          .scaleEffect(1.015)

        CodexLogoBlobShape()
          .fill(.white)
          .layerEffect(
            ShaderKit.shaders.codexLogoBrain(
              .float2(renderSize.width, renderSize.height),
              .float2(tilt.x, tilt.y),
              .float(time),
              .float(reduceMotion ? intensity * 0.65 : intensity),
              .float(reduceMotion ? pulse * 0.18 : pulse),
              .float(reduceMotion ? density * 0.55 : density),
              .float(reduceMotion ? glow * 0.55 : glow),
              .float(reduceMotion ? motion * 0.15 : motion)
            ),
            maxSampleOffset: .zero
          )
          .shadow(color: Color(red: 0.27, green: 0.42, blue: 1.0).opacity(0.65), radius: 22, y: 12)
          .overlay {
            CodexLogoBlobShape()
              .stroke(
                LinearGradient(
                  colors: [
                    .white.opacity(0.52),
                    .white.opacity(0.08),
                    Color(red: 0.55, green: 0.72, blue: 1.0).opacity(0.34)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: max(1.0, renderSide * 0.012)
              )
          }

        CodexLogoTerminalMarks()
          .stroke(
            .white,
            style: StrokeStyle(
              lineWidth: renderSide * 0.078,
              lineCap: .round,
              lineJoin: .round
            )
          )
          .shadow(color: .white.opacity(0.28), radius: 5)
      }
      .frame(width: renderSize.width, height: renderSize.height)
      .contentShape(Rectangle())
      .gesture(dragGesture(in: renderSize))
      .scaleEffect(scale)
      .rotation3DEffect(
        .degrees(tilt.y * -7.0),
        axis: (x: 1.0, y: 0.0, z: 0.0),
        perspective: 0.55
      )
      .rotation3DEffect(
        .degrees(tilt.x * 7.0),
        axis: (x: 0.0, y: 1.0, z: 0.0),
        perspective: 0.55
      )
      .position(x: availableSize.width / 2.0, y: availableSize.height / 2.0)
    }
    .aspectRatio(1.0, contentMode: .fit)
  }

  private func dragGesture(in size: CGSize) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        dragTilt = CGPoint(
          x: min(max((value.location.x / max(size.width, 1.0) - 0.5) * 2.0, -1.0), 1.0),
          y: min(max((value.location.y / max(size.height, 1.0) - 0.5) * 2.0, -1.0), 1.0)
        )
      }
      .onEnded { _ in
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
          dragTilt = .zero
        }
      }
  }
}

private struct CodexLogoBlobShape: Shape {
  func path(in rect: CGRect) -> Path {
    let squareRect = CodexLogoBlobGeometry.squareRenderRect(in: rect)

    func point(_ normalizedPoint: CGPoint) -> CGPoint {
      CGPoint(
        x: squareRect.minX + squareRect.width * normalizedPoint.x,
        y: squareRect.minY + squareRect.height * normalizedPoint.y
      )
    }

    let samples = CodexLogoBlobGeometry.normalizedSamples()
    var path = Path()

    guard let first = samples.first else {
      return path
    }

    path.move(to: point(first))

    for index in samples.indices {
      let previous = samples[(index - 1 + samples.count) % samples.count]
      let current = samples[index]
      let next = samples[(index + 1) % samples.count]
      let afterNext = samples[(index + 2) % samples.count]
      let smoothness: CGFloat = 0.92

      let control1 = CGPoint(
        x: current.x + (next.x - previous.x) * smoothness / 6.0,
        y: current.y + (next.y - previous.y) * smoothness / 6.0
      )
      let control2 = CGPoint(
        x: next.x - (afterNext.x - current.x) * smoothness / 6.0,
        y: next.y - (afterNext.y - current.y) * smoothness / 6.0
      )

      path.addCurve(
        to: point(next),
        control1: point(control1),
        control2: point(control2)
      )
    }

    path.closeSubpath()
    return path
  }
}

private struct CodexLogoTerminalMarks: Shape {
  func path(in rect: CGRect) -> Path {
    let squareRect = CodexLogoBlobGeometry.squareRenderRect(in: rect)

    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
      CGPoint(
        x: squareRect.minX + squareRect.width * x,
        y: squareRect.minY + squareRect.height * y
      )
    }

    var path = Path()
    path.move(to: point(0.30, 0.35))
    path.addLine(to: point(0.41, 0.50))
    path.addLine(to: point(0.30, 0.65))
    path.move(to: point(0.50, 0.59))
    path.addLine(to: point(0.72, 0.59))
    return path
  }
}

#Preview {
  NavigationStack {
    CodexLogoView()
  }
}
