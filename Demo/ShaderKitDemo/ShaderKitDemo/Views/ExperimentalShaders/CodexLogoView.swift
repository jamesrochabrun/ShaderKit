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
  private let pulse = 0.78
  private let glow = 1.04
  private let motion = 0.82

  var body: some View {
    ZStack {
      RadialGradient(
        colors: [
          Color.white,
          Color(red: 0.965, green: 0.970, blue: 0.985),
          Color(red: 0.905, green: 0.920, blue: 0.965)
        ],
        center: .topLeading,
        startRadius: 80,
        endRadius: 620
      )
      .ignoresSafeArea()

      TimelineView(.animation) { context in
        let time = context.date.timeIntervalSinceReferenceDate
        let tilt = CodexLogoMotionResponse.effectiveTilt(
          deviceTilt: motionManager.tilt,
          dragTilt: .zero,
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
          glow: glow,
          reduceMotion: reduceMotion
        )
        .frame(maxWidth: 390)
        .aspectRatio(1.0, contentMode: .fit)
        .padding(.horizontal, 24)
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
  private let depthLayerCount = 22

  let time: TimeInterval
  let tilt: CGPoint
  let scale: Double
  let glow: Double
  let reduceMotion: Bool

  var body: some View {
    GeometryReader { proxy in
      let availableSize = proxy.size
      let renderSide = max(1.0, min(availableSize.width, availableSize.height))
      let renderSize = CGSize(width: renderSide, height: renderSide)
      let tiltX = CGFloat(tilt.x)
      let tiltY = CGFloat(tilt.y)
      let depthX = -max(renderSide * 0.040, renderSide * (0.068 - tiltX * 0.012))
      let depthY = max(renderSide * 0.036, renderSide * (0.058 + tiltY * 0.010))
      let rimWidth = max(12.0, renderSide * 0.054)
      let innerRimWidth = max(4.0, renderSide * 0.018)
      let glyphWidth = renderSide * 0.078
      let glowRadius = reduceMotion ? 10.0 : 18.0 + glow * 6.0

      ZStack {
        CodexLogoBlobShape()
          .fill(Color(red: 0.24, green: 0.36, blue: 1.0))
          .blur(radius: glowRadius)
          .opacity(0.30 + glow * 0.08)
          .scaleEffect(1.025)
          .offset(x: depthX * 0.20, y: depthY * 0.16)

        ForEach((1...depthLayerCount).reversed(), id: \.self) { index in
          let progress = CGFloat(index) / CGFloat(depthLayerCount)

          CodexLogoBlobShape()
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.58, green: 0.52, blue: 1.0),
                  Color(red: 0.31, green: 0.38, blue: 0.98),
                  Color(red: 0.12, green: 0.18, blue: 0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .overlay {
              CodexLogoBlobShape()
                .stroke(
                  Color(red: 0.68, green: 0.66, blue: 1.0).opacity(0.10 + progress * 0.12),
                  lineWidth: max(1.0, renderSide * 0.010)
                )
            }
            .offset(x: depthX * progress, y: depthY * progress)
        }

        faceLayer(renderSize: renderSize)
          .overlay {
            CodexLogoBlobShape()
              .stroke(
                Color(red: 0.12, green: 0.14, blue: 0.58).opacity(0.42),
                lineWidth: rimWidth * 1.12
              )
              .blur(radius: renderSide * 0.006)
              .offset(x: renderSide * 0.006, y: renderSide * 0.010)
              .mask(CodexLogoBlobShape())
          }
          .overlay {
            CodexLogoBlobShape()
              .stroke(
                LinearGradient(
                  colors: [
                    Color.white.opacity(0.92),
                    Color(red: 0.72, green: 0.66, blue: 1.0).opacity(0.90),
                    Color(red: 0.22, green: 0.32, blue: 1.0).opacity(0.58)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: rimWidth
              )
          }
          .overlay {
            CodexLogoBlobShape()
              .stroke(
                LinearGradient(
                  colors: [
                    Color.white.opacity(0.95),
                    Color.white.opacity(0.38),
                    Color(red: 0.60, green: 0.68, blue: 1.0).opacity(0.22)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: innerRimWidth
              )
              .offset(x: -renderSide * 0.006, y: -renderSide * 0.010)
              .blur(radius: 0.4)
          }

        CodexLogoTerminal3DMarks(lineWidth: glyphWidth, sideOffset: CGSize(width: depthX, height: depthY))
      }
      .frame(width: renderSize.width, height: renderSize.height)
      .contentShape(Rectangle())
      .scaleEffect(scale)
      .rotation3DEffect(
        .degrees(tilt.y * -7.0),
        axis: (x: 1.0, y: 0.0, z: 0.0),
        perspective: 0.55
      )
      .rotation3DEffect(
        .degrees(tilt.x * 7.5),
        axis: (x: 0.0, y: 1.0, z: 0.0),
        perspective: 0.55
      )
      .position(x: availableSize.width / 2.0, y: availableSize.height / 2.0)
    }
    .aspectRatio(1.0, contentMode: .fit)
  }

  private func faceLayer(renderSize: CGSize) -> some View {
    ZStack {
      CodexLogoBlobShape()
        .fill(
          LinearGradient(
            colors: [
              Color(red: 0.64, green: 0.62, blue: 1.0),
              Color(red: 0.46, green: 0.58, blue: 1.0),
              Color(red: 0.24, green: 0.30, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .layerEffect(
          ShaderKit.shaders.codexBadgeFoil(
            .float2(renderSize.width, renderSize.height),
            .float2(tilt.x, tilt.y),
            .float(reduceMotion ? 0.0 : time),
            .float(reduceMotion ? 0.24 : 0.42),
            .float(reduceMotion ? 0.20 : 0.34)
          ),
          maxSampleOffset: .zero
        )
    }
    .compositingGroup()
  }
}

private struct CodexLogoTerminal3DMarks: View {
  let lineWidth: CGFloat
  let sideOffset: CGSize

  var body: some View {
    ZStack {
      CodexLogoTerminalMarks()
        .stroke(
          Color(red: 0.10, green: 0.12, blue: 0.35).opacity(0.28),
          style: strokeStyle(width: lineWidth * 1.06)
        )
        .blur(radius: lineWidth * 0.045)
        .offset(x: sideOffset.width * 0.20, y: sideOffset.height * 0.34)

      CodexLogoTerminalMarks()
        .stroke(
          LinearGradient(
            colors: [
              Color(red: 0.74, green: 0.75, blue: 0.90),
              Color(red: 0.56, green: 0.59, blue: 0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          style: strokeStyle(width: lineWidth * 1.04)
        )
        .offset(x: sideOffset.width * 0.08, y: sideOffset.height * 0.12)

      CodexLogoTerminalMarks()
        .stroke(
          LinearGradient(
            colors: [
              Color.white,
              Color(red: 0.99, green: 0.98, blue: 0.94),
              Color(red: 0.88, green: 0.89, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          style: strokeStyle(width: lineWidth)
        )
        .shadow(color: Color.white.opacity(0.45), radius: lineWidth * 0.05, x: -1, y: -1)
        .shadow(
          color: Color(red: 0.08, green: 0.10, blue: 0.30).opacity(0.24),
          radius: lineWidth * 0.14,
          x: sideOffset.width * 0.10,
          y: sideOffset.height * 0.12
        )

      CodexLogoTerminalMarks()
        .stroke(
          Color.white.opacity(0.76),
          style: strokeStyle(width: lineWidth * 0.20)
        )
        .blur(radius: 0.5)
        .offset(x: -sideOffset.width * 0.05, y: -sideOffset.height * 0.08)
    }
  }

  private func strokeStyle(width: CGFloat) -> StrokeStyle {
    StrokeStyle(
      lineWidth: width,
      lineCap: .round,
      lineJoin: .round
    )
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
