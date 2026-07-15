//
//  MothFigure.swift
//  ShaderCards
//
//  A moth with spread wings drawn from bezier paths in unit space.
//

import SwiftUI

/// An elegant moth, wings fully spread and perfectly mirrored: scalloped
/// upper wings with eye-spots, smaller lower wings, and curled antennae.
struct MothFigure: View {
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

      // Both sides are computed from one set of offsets and mirrored across
      // the vertical center line.
      for s in [CGFloat(-1), 1] {
        func mp(_ dx: CGFloat, _ y: CGFloat) -> CGPoint {
          pt(0.5 + s * dx, y)
        }

        let wingGradient = GraphicsContext.Shading.linearGradient(
          Gradient(colors: [colors.body.opacity(0.92), colors.body]),
          startPoint: mp(0.05, 0.52),
          endPoint: mp(0.42, 0.25)
        )

        // Lower wing, tucked behind the upper wing.
        var lowerWing = Path()
        lowerWing.move(to: mp(0.03, 0.57))
        lowerWing.addCurve(to: mp(0.28, 0.63), control1: mp(0.12, 0.565), control2: mp(0.22, 0.58))
        lowerWing.addCurve(to: mp(0.20, 0.80), control1: mp(0.335, 0.70), control2: mp(0.28, 0.78))
        lowerWing.addCurve(to: mp(0.10, 0.74), control1: mp(0.17, 0.765), control2: mp(0.13, 0.765))
        lowerWing.addCurve(to: mp(0.025, 0.70), control1: mp(0.07, 0.76), control2: mp(0.035, 0.74))
        lowerWing.closeSubpath()
        context.fill(lowerWing, with: wingGradient)

        // Lower wing inner panel.
        var lowerPanel = Path()
        lowerPanel.move(to: mp(0.045, 0.60))
        lowerPanel.addCurve(to: mp(0.20, 0.65), control1: mp(0.11, 0.595), control2: mp(0.17, 0.615))
        lowerPanel.addCurve(to: mp(0.045, 0.60), control1: mp(0.17, 0.71), control2: mp(0.09, 0.70))
        lowerPanel.closeSubpath()
        context.fill(lowerPanel, with: .color(colors.secondary))

        // Upper wing: rounded triangle with a scalloped trailing edge.
        var upperWing = Path()
        upperWing.move(to: mp(0.03, 0.50))
        upperWing.addCurve(to: mp(0.33, 0.18), control1: mp(0.08, 0.36), control2: mp(0.20, 0.21))
        upperWing.addCurve(to: mp(0.44, 0.28), control1: mp(0.40, 0.17), control2: mp(0.45, 0.21))
        upperWing.addCurve(to: mp(0.40, 0.38), control1: mp(0.45, 0.32), control2: mp(0.44, 0.36))
        upperWing.addCurve(to: mp(0.34, 0.48), control1: mp(0.42, 0.41), control2: mp(0.39, 0.46))
        upperWing.addCurve(to: mp(0.26, 0.55), control1: mp(0.35, 0.51), control2: mp(0.32, 0.545))
        upperWing.addCurve(to: mp(0.035, 0.58), control1: mp(0.18, 0.565), control2: mp(0.09, 0.58))
        upperWing.closeSubpath()
        context.fill(upperWing, with: wingGradient)

        // Upper wing inner panel.
        var upperPanel = Path()
        upperPanel.move(to: mp(0.055, 0.51))
        upperPanel.addCurve(to: mp(0.26, 0.25), control1: mp(0.10, 0.40), control2: mp(0.18, 0.27))
        upperPanel.addCurve(to: mp(0.28, 0.41), control1: mp(0.31, 0.27), control2: mp(0.32, 0.36))
        upperPanel.addCurve(to: mp(0.06, 0.56), control1: mp(0.22, 0.49), control2: mp(0.12, 0.55))
        upperPanel.closeSubpath()
        context.fill(upperPanel, with: .color(colors.secondary))

        // Wing veins.
        for (tip, control) in [
          (mp(0.36, 0.24), mp(0.18, 0.33)),
          (mp(0.24, 0.72), mp(0.12, 0.62)),
        ] {
          var vein = Path()
          vein.move(to: mp(0.05, 0.53))
          vein.addQuadCurve(to: tip, control: control)
          context.stroke(vein, with: .color(colors.accent.opacity(0.3)), style: StrokeStyle(
            lineWidth: 0.006 * w, lineCap: .round
          ))
        }

        // Eye-spot: concentric secondary ring with an accent center.
        let spotX = 0.5 + s * 0.35
        context.fill(
          Path(ellipseIn: CGRect(x: (spotX - 0.052) * w, y: 0.278 * h, width: 0.104 * w, height: 0.104 * h)),
          with: .color(colors.secondary)
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (spotX - 0.030) * w, y: 0.30 * h, width: 0.06 * w, height: 0.06 * h)),
          with: .color(colors.accent)
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (0.5 + s * 0.34 - 0.011) * w, y: 0.307 * h, width: 0.022 * w, height: 0.022 * h)),
          with: .color(.white.opacity(0.85))
        )

        // Curled antenna, drawn before the head so its root tucks under.
        var antenna = Path()
        antenna.move(to: mp(0.012, 0.39))
        antenna.addCurve(to: mp(0.13, 0.20), control1: mp(0.025, 0.32), control2: mp(0.065, 0.235))
        antenna.addCurve(to: mp(0.095, 0.225), control1: mp(0.165, 0.185), control2: mp(0.14, 0.235))
        context.stroke(antenna, with: .color(colors.accent), style: StrokeStyle(
          lineWidth: 0.012 * w, lineCap: .round, lineJoin: .round
        ))
        context.fill(
          Path(ellipseIn: CGRect(x: (0.5 + s * 0.095 - 0.011) * w, y: 0.214 * h, width: 0.022 * w, height: 0.022 * h)),
          with: .color(colors.accent)
        )
      }

      // Fuzzy body: thorax and tapering abdomen segment stack.
      for (cy, rx, ry) in [
        (0.52, 0.0525, 0.075),
        (0.625, 0.045, 0.06),
        (0.70, 0.038, 0.05),
        (0.765, 0.029, 0.043),
      ] as [(CGFloat, CGFloat, CGFloat)] {
        context.fill(
          Path(ellipseIn: CGRect(x: (0.5 - rx) * w, y: (cy - ry) * h, width: rx * 2 * w, height: ry * 2 * h)),
          with: bodyGradient
        )
      }

      // Segment dividers along the abdomen.
      for (yy, dx) in [(0.578, 0.048), (0.658, 0.040), (0.732, 0.030)] as [(CGFloat, CGFloat)] {
        var divider = Path()
        divider.move(to: pt(0.5 - dx, yy))
        divider.addQuadCurve(to: pt(0.5 + dx, yy), control: pt(0.5, yy + 0.02))
        context.stroke(divider, with: .color(.black.opacity(0.22)), style: StrokeStyle(
          lineWidth: 0.007 * w, lineCap: .round
        ))
      }

      // Fuzz collar between head and thorax.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.435 * w, y: 0.427 * h, width: 0.13 * w, height: 0.056 * h)),
        with: .color(colors.secondary.opacity(0.55))
      )

      // Round head.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.455 * w, y: 0.37 * h, width: 0.09 * w, height: 0.09 * h)),
        with: bodyGradient
      )

      // Dark eyes with highlights.
      for s in [CGFloat(-1), 1] {
        let ex = 0.5 + s * 0.021
        context.fill(
          Path(ellipseIn: CGRect(x: (ex - 0.014) * w, y: 0.399 * h, width: 0.028 * w, height: 0.032 * h)),
          with: .color(.black.opacity(0.85))
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (ex - 0.001) * w, y: 0.404 * h, width: 0.011 * w, height: 0.012 * h)),
          with: .color(.white.opacity(0.9))
        )
      }
    }
  }
}

#Preview("Moth") {
  MothFigure(colors: FigureColors(
    body: Color(red: 0.72, green: 0.48, blue: 0.78),
    secondary: Color(red: 0.97, green: 0.90, blue: 0.78),
    accent: Color(red: 0.32, green: 0.12, blue: 0.38)
  ))
  .frame(width: 300, height: 300)
  .background(.teal.opacity(0.2))
}
