//
//  WispFigure.swift
//  ShaderCards
//
//  A floating spirit orb with flame-like trails.
//

import SwiftUI

/// A ghostly floating wisp: layered glowing orb with trailing ribbons.
struct WispFigure: View {
  let colors: FigureColors

  var body: some View {
    Canvas { context, size in
      let w = size.width
      let h = size.height
      func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
      }

      // Outer aura.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.18 * w, y: 0.14 * h, width: 0.64 * w, height: 0.64 * h)),
        with: .radialGradient(
          Gradient(colors: [colors.body.opacity(0.55), colors.body.opacity(0)]),
          center: pt(0.5, 0.46),
          startRadius: 0,
          endRadius: 0.36 * w
        )
      )

      // Trailing ribbons flowing downward.
      for (offset, sway, length, width) in [
        (0.38, -0.10, 0.34, 0.045),
        (0.50, 0.02, 0.42, 0.055),
        (0.62, 0.12, 0.30, 0.04),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        var ribbon = Path()
        let startY: CGFloat = 0.58
        ribbon.move(to: pt(offset - width, startY))
        ribbon.addCurve(
          to: pt(offset + sway, startY + length),
          control1: pt(offset - width - 0.05, startY + length * 0.5),
          control2: pt(offset + sway - 0.03, startY + length * 0.8)
        )
        ribbon.addCurve(
          to: pt(offset + width, startY),
          control1: pt(offset + sway + 0.03, startY + length * 0.8),
          control2: pt(offset + width + 0.05, startY + length * 0.5)
        )
        ribbon.closeSubpath()
        context.fill(
          ribbon,
          with: .linearGradient(
            Gradient(colors: [colors.body.opacity(0.85), colors.secondary.opacity(0)]),
            startPoint: pt(offset, startY),
            endPoint: pt(offset + sway, startY + length)
          )
        )
      }

      // Core orb.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.30 * w, y: 0.26 * h, width: 0.40 * w, height: 0.40 * h)),
        with: .radialGradient(
          Gradient(colors: [colors.secondary, colors.body]),
          center: pt(0.46, 0.40),
          startRadius: 0,
          endRadius: 0.22 * w
        )
      )

      // Inner highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.36 * w, y: 0.30 * h, width: 0.14 * w, height: 0.12 * h)),
        with: .color(.white.opacity(0.75))
      )

      // Eyes: two sleepy arcs.
      for x in [0.415, 0.545] as [CGFloat] {
        var eye = Path()
        eye.move(to: pt(x - 0.028, 0.455))
        eye.addQuadCurve(to: pt(x + 0.028, 0.455), control: pt(x, 0.415))
        context.stroke(eye, with: .color(colors.accent), style: StrokeStyle(
          lineWidth: 0.018 * w, lineCap: .round
        ))
      }

      // Floating spark dots orbiting the orb.
      for (x, y, r) in [(0.24, 0.30, 0.018), (0.76, 0.24, 0.014), (0.70, 0.60, 0.012)]
        as [(CGFloat, CGFloat, CGFloat)] {
        context.fill(
          Path(ellipseIn: CGRect(x: (x - r) * w, y: (y - r) * h, width: r * 2 * w, height: r * 2 * h)),
          with: .color(colors.secondary.opacity(0.9))
        )
      }
    }
  }
}

#Preview("Wisp") {
  WispFigure(colors: FigureColors(
    body: Color(red: 0.55, green: 0.35, blue: 0.85),
    secondary: Color(red: 0.85, green: 0.75, blue: 1.0),
    accent: Color(red: 0.25, green: 0.10, blue: 0.45)
  ))
  .frame(width: 300, height: 300)
  .background(.black.opacity(0.8))
}
