//
//  FoxFigure.swift
//  ShaderCards
//
//  A sitting fox drawn from bezier paths in unit space.
//

import SwiftUI

/// A stylized sitting fox, facing left, with a sweeping brush tail.
struct FoxFigure: View {
  let colors: FigureColors

  var body: some View {
    Canvas { context, size in
      let w = size.width
      let h = size.height
      func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
      }

      let bodyGradient = GraphicsContext.Shading.linearGradient(
        Gradient(colors: [colors.body.opacity(0.95), colors.body]),
        startPoint: pt(0.5, 0.1),
        endPoint: pt(0.5, 0.9)
      )

      // Ground shadow.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.18 * w, y: 0.84 * h, width: 0.64 * w, height: 0.09 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Tail: big brush curling up behind the body.
      var tail = Path()
      tail.move(to: pt(0.58, 0.82))
      tail.addCurve(to: pt(0.88, 0.55), control1: pt(0.78, 0.84), control2: pt(0.92, 0.72))
      tail.addCurve(to: pt(0.74, 0.24), control1: pt(0.85, 0.40), control2: pt(0.86, 0.28))
      tail.addCurve(to: pt(0.62, 0.42), control1: pt(0.64, 0.21), control2: pt(0.60, 0.32))
      tail.addCurve(to: pt(0.52, 0.80), control1: pt(0.64, 0.55), control2: pt(0.50, 0.68))
      tail.closeSubpath()
      context.fill(tail, with: bodyGradient)

      // Tail tip in the secondary color.
      var tailTip = Path()
      tailTip.move(to: pt(0.74, 0.24))
      tailTip.addCurve(to: pt(0.63, 0.41), control1: pt(0.64, 0.21), control2: pt(0.61, 0.32))
      tailTip.addCurve(to: pt(0.74, 0.40), control1: pt(0.66, 0.44), control2: pt(0.71, 0.44))
      tailTip.addCurve(to: pt(0.74, 0.24), control1: pt(0.79, 0.35), control2: pt(0.80, 0.28))
      tailTip.closeSubpath()
      context.fill(tailTip, with: .color(colors.secondary))

      // Haunch: seated pear-shaped body.
      var body = Path()
      body.move(to: pt(0.44, 0.42))
      body.addCurve(to: pt(0.66, 0.84), control1: pt(0.62, 0.48), control2: pt(0.70, 0.66))
      body.addCurve(to: pt(0.30, 0.84), control1: pt(0.58, 0.90), control2: pt(0.36, 0.90))
      body.addCurve(to: pt(0.36, 0.44), control1: pt(0.24, 0.72), control2: pt(0.28, 0.52))
      body.closeSubpath()
      context.fill(body, with: bodyGradient)

      // Chest patch.
      var chest = Path()
      chest.move(to: pt(0.40, 0.48))
      chest.addCurve(to: pt(0.44, 0.82), control1: pt(0.50, 0.56), control2: pt(0.52, 0.72))
      chest.addCurve(to: pt(0.33, 0.80), control1: pt(0.40, 0.86), control2: pt(0.35, 0.86))
      chest.addCurve(to: pt(0.40, 0.48), control1: pt(0.30, 0.66), control2: pt(0.33, 0.54))
      chest.closeSubpath()
      context.fill(chest, with: .color(colors.secondary))

      // Front leg.
      var leg = Path()
      leg.addRoundedRect(
        in: CGRect(x: 0.365 * w, y: 0.62 * h, width: 0.065 * w, height: 0.25 * h),
        cornerSize: CGSize(width: 0.03 * w, height: 0.03 * w)
      )
      context.fill(leg, with: bodyGradient)

      // Ears: outer triangles with inner secondary fill.
      for (base, tip, lean) in [
        (pt(0.315, 0.235), pt(0.27, 0.06), 0.065),
        (pt(0.435, 0.22), pt(0.47, 0.05), 0.065),
      ] {
        var ear = Path()
        ear.move(to: CGPoint(x: base.x - lean * w, y: base.y))
        ear.addLine(to: tip)
        ear.addLine(to: CGPoint(x: base.x + lean * w, y: base.y))
        ear.closeSubpath()
        context.fill(ear, with: bodyGradient)

        var inner = Path()
        inner.move(to: CGPoint(x: base.x - lean * 0.4 * w, y: base.y - 0.01 * h))
        inner.addLine(to: CGPoint(x: tip.x + (base.x - tip.x) * 0.25, y: tip.y + (base.y - tip.y) * 0.25))
        inner.addLine(to: CGPoint(x: base.x + lean * 0.4 * w, y: base.y - 0.01 * h))
        inner.closeSubpath()
        context.fill(inner, with: .color(colors.accent.opacity(0.75)))
      }

      // Head: rounded skull + snout wedge.
      var head = Path()
      head.move(to: pt(0.50, 0.30))
      head.addCurve(to: pt(0.38, 0.42), control1: pt(0.50, 0.40), control2: pt(0.46, 0.44))
      head.addCurve(to: pt(0.20, 0.36), control1: pt(0.30, 0.42), control2: pt(0.24, 0.40))
      head.addCurve(to: pt(0.28, 0.22), control1: pt(0.20, 0.30), control2: pt(0.23, 0.24))
      head.addCurve(to: pt(0.50, 0.30), control1: pt(0.36, 0.16), control2: pt(0.48, 0.20))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Snout patch.
      var snout = Path()
      snout.move(to: pt(0.30, 0.35))
      snout.addCurve(to: pt(0.20, 0.36), control1: pt(0.27, 0.39), control2: pt(0.23, 0.39))
      snout.addCurve(to: pt(0.27, 0.30), control1: pt(0.21, 0.33), control2: pt(0.24, 0.30))
      snout.closeSubpath()
      context.fill(snout, with: .color(colors.secondary))

      // Nose.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.185 * w, y: 0.345 * h, width: 0.035 * w, height: 0.03 * h)),
        with: .color(.black.opacity(0.8))
      )

      // Eye.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.335 * w, y: 0.285 * h, width: 0.045 * w, height: 0.05 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.345 * w, y: 0.29 * h, width: 0.016 * w, height: 0.018 * h)),
        with: .color(.white.opacity(0.9))
      )
    }
  }
}

#Preview("Fox") {
  FoxFigure(colors: FigureColors(
    body: Color(red: 0.95, green: 0.45, blue: 0.15),
    secondary: Color(red: 1.0, green: 0.92, blue: 0.80),
    accent: Color(red: 0.55, green: 0.15, blue: 0.05)
  ))
  .frame(width: 300, height: 300)
  .background(.mint.opacity(0.2))
}
