//
//  TurtleFigure.swift
//  ShaderCards
//
//  A sturdy friendly turtle with a high domed, plated shell.
//

import SwiftUI

/// A stylized turtle in side profile facing left, standing.
struct TurtleFigure: View {
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
        startPoint: pt(0.5, 0.3),
        endPoint: pt(0.5, 0.9)
      )

      // Ground shadow.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.14 * w, y: 0.82 * h, width: 0.72 * w, height: 0.10 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Tiny tail peeking out back-right.
      var tail = Path()
      tail.move(to: pt(0.82, 0.72))
      tail.addCurve(to: pt(0.92, 0.78), control1: pt(0.88, 0.71), control2: pt(0.92, 0.74))
      tail.addCurve(to: pt(0.81, 0.78), control1: pt(0.89, 0.80), control2: pt(0.84, 0.80))
      tail.closeSubpath()
      context.fill(tail, with: bodyGradient)

      // Back leg.
      var backLeg = Path()
      backLeg.addRoundedRect(
        in: CGRect(x: 0.66 * w, y: 0.68 * h, width: 0.13 * w, height: 0.19 * h),
        cornerSize: CGSize(width: 0.05 * w, height: 0.05 * w)
      )
      context.fill(backLeg, with: bodyGradient)

      // Front leg.
      var frontLeg = Path()
      frontLeg.addRoundedRect(
        in: CGRect(x: 0.30 * w, y: 0.68 * h, width: 0.13 * w, height: 0.19 * h),
        cornerSize: CGSize(width: 0.05 * w, height: 0.05 * w)
      )
      context.fill(frontLeg, with: bodyGradient)

      // Toe notches on each foot.
      for legX in [0.30, 0.66] as [CGFloat] {
        for toe in 0..<2 {
          var notch = Path()
          let nx = legX + 0.035 + CGFloat(toe) * 0.045
          notch.move(to: pt(nx, 0.87))
          notch.addLine(to: pt(nx, 0.83))
          context.stroke(notch, with: .color(.black.opacity(0.3)), style: StrokeStyle(
            lineWidth: 0.012 * w, lineCap: .round
          ))
        }
      }

      // Head: extended out to the left with a gentle smile.
      var head = Path()
      head.move(to: pt(0.30, 0.52))
      head.addCurve(to: pt(0.12, 0.48), control1: pt(0.24, 0.44), control2: pt(0.15, 0.42))
      head.addCurve(to: pt(0.10, 0.60), control1: pt(0.09, 0.52), control2: pt(0.08, 0.57))
      head.addCurve(to: pt(0.22, 0.68), control1: pt(0.13, 0.65), control2: pt(0.17, 0.68))
      head.addCurve(to: pt(0.30, 0.62), control1: pt(0.27, 0.68), control2: pt(0.30, 0.66))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Smile.
      var smile = Path()
      smile.move(to: pt(0.115, 0.585))
      smile.addQuadCurve(to: pt(0.175, 0.615), control: pt(0.14, 0.625))
      context.stroke(smile, with: .color(.black.opacity(0.45)), style: StrokeStyle(
        lineWidth: 0.012 * w, lineCap: .round
      ))

      // Eye with highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.155 * w, y: 0.495 * h, width: 0.05 * w, height: 0.055 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.168 * w, y: 0.505 * h, width: 0.018 * w, height: 0.02 * h)),
        with: .color(.white.opacity(0.9))
      )

      // Belly plate peeking under the shell rim.
      var belly = Path()
      belly.addRoundedRect(
        in: CGRect(x: 0.28 * w, y: 0.63 * h, width: 0.50 * w, height: 0.10 * h),
        cornerSize: CGSize(width: 0.05 * w, height: 0.05 * h)
      )
      context.fill(belly, with: .color(colors.accent))

      // Shell: high dome.
      let shellGradient = GraphicsContext.Shading.linearGradient(
        Gradient(colors: [colors.body.opacity(0.9), colors.body.opacity(0.65)]),
        startPoint: pt(0.5, 0.12),
        endPoint: pt(0.5, 0.68)
      )
      var shell = Path()
      shell.move(to: pt(0.22, 0.64))
      shell.addCurve(to: pt(0.52, 0.14), control1: pt(0.22, 0.36), control2: pt(0.32, 0.14))
      shell.addCurve(to: pt(0.84, 0.64), control1: pt(0.74, 0.14), control2: pt(0.84, 0.38))
      shell.closeSubpath()
      context.fill(shell, with: shellGradient)
      // Darken shell slightly to separate from body.
      context.fill(shell, with: .color(.black.opacity(0.14)))

      // Shell rim band along the bottom edge.
      var rim = Path()
      rim.addRoundedRect(
        in: CGRect(x: 0.20 * w, y: 0.60 * h, width: 0.66 * w, height: 0.075 * h),
        cornerSize: CGSize(width: 0.035 * w, height: 0.035 * h)
      )
      context.fill(rim, with: .color(colors.secondary.opacity(0.9)))

      // Shell plates: rounded polygons in the secondary color.
      let plates: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (0.395, 0.245, 0.22, 0.16),   // top plate
        (0.265, 0.415, 0.17, 0.15),   // left mid
        (0.475, 0.415, 0.19, 0.16),   // center mid
        (0.685, 0.425, 0.14, 0.14),   // right mid
      ]
      for (px, py, pw, ph) in plates {
        var plate = Path()
        plate.addRoundedRect(
          in: CGRect(x: px * w, y: py * h, width: pw * w, height: ph * h),
          cornerSize: CGSize(width: 0.045 * w, height: 0.045 * w)
        )
        context.fill(plate, with: .color(colors.secondary))
        context.stroke(plate, with: .color(.black.opacity(0.25)), lineWidth: 0.008 * w)
      }

      // Dome highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.33 * w, y: 0.185 * h, width: 0.16 * w, height: 0.06 * h)),
        with: .color(.white.opacity(0.35))
      )
    }
  }
}

#Preview("Turtle") {
  TurtleFigure(colors: FigureColors(
    body: Color(red: 0.35, green: 0.60, blue: 0.32),
    secondary: Color(red: 0.95, green: 0.65, blue: 0.75),
    accent: Color(red: 0.98, green: 0.92, blue: 0.65)
  ))
  .frame(width: 300, height: 300)
  .background(.teal.opacity(0.2))
}
