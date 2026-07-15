//
//  JellyFigure.swift
//  ShaderCards
//
//  A floating jellyfish drawn from bezier paths in unit space.
//

import SwiftUI

/// An adorable jellyfish: translucent scalloped bell, wavy ribbon
/// tentacles fading downward, frilly oral arms, and a tiny smile.
struct JellyFigure: View {
  let colors: FigureColors

  var body: some View {
    Canvas { context, size in
      let w = size.width
      let h = size.height
      func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
      }

      // Wavy ribbon tentacles of varying lengths, fading downward.
      for (offset, sway, length, width) in [
        (0.295, -0.09, 0.27, 0.020),
        (0.375, 0.05, 0.37, 0.024),
        (0.455, -0.06, 0.31, 0.022),
        (0.545, 0.07, 0.41, 0.024),
        (0.625, -0.04, 0.34, 0.022),
        (0.705, 0.10, 0.26, 0.020),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        let startY: CGFloat = 0.49
        let bend = -sway * 0.6
        let midY = startY + length * 0.52
        let tipX = offset + sway
        var ribbon = Path()
        ribbon.move(to: pt(offset - width, startY))
        ribbon.addCurve(
          to: pt(offset + bend - width * 0.65, midY),
          control1: pt(offset - width - 0.03, startY + length * 0.18),
          control2: pt(offset + bend - width - 0.02, startY + length * 0.36)
        )
        ribbon.addCurve(
          to: pt(tipX, startY + length),
          control1: pt(offset + bend - width * 0.3 + 0.02, startY + length * 0.72),
          control2: pt(tipX - 0.015, startY + length * 0.9)
        )
        ribbon.addCurve(
          to: pt(offset + bend + width * 0.65, midY),
          control1: pt(tipX + 0.015, startY + length * 0.9),
          control2: pt(offset + bend + width * 0.3 + 0.02, startY + length * 0.72)
        )
        ribbon.addCurve(
          to: pt(offset + width, startY),
          control1: pt(offset + bend + width + 0.02, startY + length * 0.36),
          control2: pt(offset + width + 0.03, startY + length * 0.18)
        )
        ribbon.closeSubpath()
        context.fill(
          ribbon,
          with: .linearGradient(
            Gradient(colors: [colors.body.opacity(0.85), colors.body.opacity(0)]),
            startPoint: pt(offset, startY),
            endPoint: pt(tipX, startY + length)
          )
        )
      }

      // Two thicker frilly oral arms trailing from the bell's center.
      for (offset, sway, length, width) in [
        (0.445, -0.05, 0.30, 0.042),
        (0.555, 0.06, 0.335, 0.042),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        let startY: CGFloat = 0.485
        var arm = Path()
        arm.move(to: pt(offset - width, startY))
        arm.addCurve(
          to: pt(offset - width - 0.025, startY + length * 0.45),
          control1: pt(offset - width - 0.055, startY + length * 0.12),
          control2: pt(offset - width + 0.02, startY + length * 0.32)
        )
        arm.addCurve(
          to: pt(offset + sway, startY + length),
          control1: pt(offset - width - 0.06, startY + length * 0.68),
          control2: pt(offset + sway - 0.03, startY + length * 0.88)
        )
        arm.addCurve(
          to: pt(offset + width + 0.02, startY + length * 0.5),
          control1: pt(offset + sway + 0.035, startY + length * 0.82),
          control2: pt(offset + width - 0.02, startY + length * 0.66)
        )
        arm.addCurve(
          to: pt(offset + width, startY),
          control1: pt(offset + width + 0.05, startY + length * 0.3),
          control2: pt(offset + width - 0.015, startY + length * 0.1)
        )
        arm.closeSubpath()
        context.fill(
          arm,
          with: .linearGradient(
            Gradient(colors: [colors.secondary.opacity(0.95), colors.secondary.opacity(0.25)]),
            startPoint: pt(offset, startY),
            endPoint: pt(offset + sway, startY + length)
          )
        )
      }

      // Bell: translucent dome with a scalloped bottom edge.
      var bell = Path()
      bell.move(to: pt(0.235, 0.47))
      bell.addCurve(to: pt(0.50, 0.13), control1: pt(0.225, 0.26), control2: pt(0.345, 0.13))
      bell.addCurve(to: pt(0.765, 0.47), control1: pt(0.655, 0.13), control2: pt(0.775, 0.26))
      bell.addQuadCurve(to: pt(0.6325, 0.475), control: pt(0.70, 0.535))
      bell.addQuadCurve(to: pt(0.50, 0.475), control: pt(0.565, 0.545))
      bell.addQuadCurve(to: pt(0.3675, 0.475), control: pt(0.435, 0.545))
      bell.addQuadCurve(to: pt(0.235, 0.47), control: pt(0.30, 0.535))
      bell.closeSubpath()
      context.fill(
        bell,
        with: .radialGradient(
          Gradient(colors: [colors.secondary, colors.body]),
          center: pt(0.41, 0.26),
          startRadius: 0,
          endRadius: 0.40 * w
        )
      )

      // Inner glow ring floating inside the bell.
      context.stroke(
        Path(ellipseIn: CGRect(x: 0.315 * w, y: 0.21 * h, width: 0.37 * w, height: 0.235 * h)),
        with: .color(.white.opacity(0.38)),
        style: StrokeStyle(lineWidth: 0.014 * w, lineCap: .round)
      )

      // Glossy sheen at the upper-left of the dome.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.30 * w, y: 0.165 * h, width: 0.13 * w, height: 0.075 * h)),
        with: .color(.white.opacity(0.45))
      )

      // Eyes: dark ovals with white highlights.
      for x in [0.40, 0.55] as [CGFloat] {
        context.fill(
          Path(ellipseIn: CGRect(x: x * w, y: 0.314 * h, width: 0.05 * w, height: 0.062 * h)),
          with: .color(colors.accent.opacity(0.9))
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (x + 0.007) * w, y: 0.322 * h, width: 0.016 * w, height: 0.018 * h)),
          with: .color(.white.opacity(0.9))
        )
      }

      // Tiny smile.
      var smile = Path()
      smile.move(to: pt(0.468, 0.415))
      smile.addQuadCurve(to: pt(0.532, 0.415), control: pt(0.50, 0.452))
      context.stroke(smile, with: .color(colors.accent.opacity(0.9)), style: StrokeStyle(
        lineWidth: 0.016 * w, lineCap: .round
      ))
    }
  }
}

#Preview("Jelly") {
  JellyFigure(colors: FigureColors(
    body: Color(red: 0.80, green: 0.40, blue: 0.75),
    secondary: Color(red: 0.98, green: 0.80, blue: 0.95),
    accent: Color(red: 0.32, green: 0.08, blue: 0.30)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.35))
}
