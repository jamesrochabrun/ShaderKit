//
//  ParticleField.swift
//  ShaderCards
//
//  Ambient drifting particles (embers, bubbles, stars…) rendered with
//  Canvas. Animation time comes from the ShaderKit context environment,
//  so particles drift whenever the card lives inside a holographic
//  container — for free, on the same clock as the shaders.
//

import SwiftUI
import ShaderKit

/// A deterministic field of drifting particles.
struct ParticleField: View {
  let kind: ParticleKind
  let color: Color
  let seed: UInt64
  var count: Int = 26

  @Environment(\.shaderContext) private var context
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    if kind == .none {
      EmptyView()
    } else {
      Canvas { canvasContext, size in
        var random = SceneRandom(seed: seed)
        let time = reduceMotion ? 0 : context.time

        for index in 0..<count {
          let baseX = random.unit()
          let baseY = random.unit()
          let particleSize = random.range(0.008...0.022) * size.width * sizeMultiplier
          let speed = random.range(0.02...0.08)
          let phase = random.unit() * .pi * 2
          let drift = random.range(0.01...0.04)

          let position = position(
            baseX: baseX, baseY: baseY,
            speed: speed, phase: phase, drift: drift,
            time: time, size: size
          )
          let alpha = 0.35 + 0.55 * (0.5 + 0.5 * sin(time * 1.7 + phase))

          draw(
            in: &canvasContext,
            at: position,
            size: particleSize,
            alpha: alpha,
            rotation: Angle(radians: time * 0.4 + phase),
            index: index
          )
        }
      }
      .allowsHitTesting(false)
    }
  }

  private var sizeMultiplier: CGFloat {
    switch kind {
    case .petals, .leaves: 1.7
    case .orbs: 1.5
    case .snow: 1.2
    default: 1.0
    }
  }

  /// Computes a particle's animated position for the current time.
  private func position(
    baseX: CGFloat, baseY: CGFloat, speed: CGFloat, phase: CGFloat,
    drift: CGFloat, time: TimeInterval, size: CGSize
  ) -> CGPoint {
    let t = CGFloat(time)
    let wobble = sin(t * 0.9 + phase) * drift

    switch kind {
    case .embers, .sparks, .bubbles:
      // Rise upward, wrap around.
      let y = (baseY - t * speed).truncatingRemainder(dividingBy: 1)
      let wrappedY = y < 0 ? y + 1 : y
      return CGPoint(x: (baseX + wobble) * size.width, y: wrappedY * size.height)
    case .snow, .petals, .leaves:
      // Fall downward with sway.
      let y = (baseY + t * speed).truncatingRemainder(dividingBy: 1)
      return CGPoint(x: (baseX + wobble * 2) * size.width, y: y * size.height)
    case .stars, .orbs, .none:
      // Hover in place with gentle bob.
      return CGPoint(
        x: (baseX + wobble) * size.width,
        y: (baseY + sin(t * 0.6 + phase) * 0.012) * size.height
      )
    }
  }

  private func draw(
    in context: inout GraphicsContext,
    at position: CGPoint,
    size particleSize: CGFloat,
    alpha: Double,
    rotation: Angle,
    index: Int
  ) {
    let rect = CGRect(
      x: position.x - particleSize / 2,
      y: position.y - particleSize / 2,
      width: particleSize,
      height: particleSize
    )
    let shading = GraphicsContext.Shading.color(color.opacity(alpha))

    switch kind {
    case .embers, .bubbles, .orbs:
      context.fill(Path(ellipseIn: rect), with: shading)
      if kind == .bubbles {
        context.stroke(
          Path(ellipseIn: rect.insetBy(dx: -particleSize * 0.18, dy: -particleSize * 0.18)),
          with: .color(color.opacity(alpha * 0.35)),
          lineWidth: 0.5
        )
      }
    case .sparks:
      var path = Path()
      path.move(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
      path.move(to: CGPoint(x: rect.minX, y: rect.midY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
      context.stroke(path, with: shading, lineWidth: particleSize * 0.22)
    case .stars:
      let star = StarShape(points: 4, innerRatio: 0.35).path(in: rect)
      context.fill(star, with: shading)
    case .snow:
      context.fill(Path(ellipseIn: rect), with: shading)
    case .petals, .leaves:
      let transform = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        .rotated(by: rotation.radians + Double(index))
        .translatedBy(x: -rect.midX, y: -rect.midY)
      let petal = Path(ellipseIn: CGRect(
        x: rect.minX, y: rect.midY - particleSize * 0.28,
        width: particleSize, height: particleSize * 0.56
      )).applying(transform)
      context.fill(petal, with: shading)
    case .none:
      break
    }
  }
}
