//
//  BirdFigure.swift
//  ShaderCards
//
//  A soaring raptor drawn from bezier paths in unit space.
//

import SwiftUI

/// A majestic raptor seen from below, wings spread wide and slightly raised,
/// with scalloped primary feathers and a fanned tail.
struct BirdFigure: View {
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
        endPoint: pt(0.5, 0.75)
      )

      // Wings: a scalloped feather layer beneath a smooth covert layer,
      // mirrored for the left and right side.
      for flip in [false, true] {
        func fpt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
          pt(flip ? 1 - x : x, y)
        }

        // Underside feather layer with five scalloped primary tips.
        var feathers = Path()
        feathers.move(to: fpt(0.46, 0.355))
        feathers.addCurve(to: fpt(0.075, 0.135), control1: fpt(0.33, 0.245), control2: fpt(0.16, 0.135))
        feathers.addQuadCurve(to: fpt(0.13, 0.245), control: fpt(0.125, 0.20))
        feathers.addQuadCurve(to: fpt(0.20, 0.33), control: fpt(0.19, 0.29))
        feathers.addQuadCurve(to: fpt(0.285, 0.40), control: fpt(0.265, 0.355))
        feathers.addQuadCurve(to: fpt(0.375, 0.45), control: fpt(0.35, 0.41))
        feathers.addQuadCurve(to: fpt(0.455, 0.475), control: fpt(0.425, 0.445))
        feathers.closeSubpath()
        context.fill(feathers, with: .color(colors.secondary))

        // Covert layer along the raised leading edge.
        var coverts = Path()
        coverts.move(to: fpt(0.475, 0.345))
        coverts.addCurve(to: fpt(0.075, 0.135), control1: fpt(0.33, 0.235), control2: fpt(0.155, 0.13))
        coverts.addCurve(to: fpt(0.305, 0.305), control1: fpt(0.145, 0.205), control2: fpt(0.215, 0.27))
        coverts.addCurve(to: fpt(0.475, 0.415), control1: fpt(0.385, 0.335), control2: fpt(0.44, 0.365))
        coverts.closeSubpath()
        context.fill(coverts, with: bodyGradient)
      }

      // Tail: fanned feathers below the body with scalloped tips.
      var tailFan = Path()
      tailFan.move(to: pt(0.455, 0.49))
      tailFan.addCurve(to: pt(0.375, 0.655), control1: pt(0.415, 0.545), control2: pt(0.385, 0.60))
      tailFan.addQuadCurve(to: pt(0.435, 0.70), control: pt(0.419, 0.651))
      tailFan.addQuadCurve(to: pt(0.50, 0.715), control: pt(0.4725, 0.678))
      tailFan.addQuadCurve(to: pt(0.565, 0.70), control: pt(0.5275, 0.678))
      tailFan.addQuadCurve(to: pt(0.625, 0.655), control: pt(0.581, 0.651))
      tailFan.addCurve(to: pt(0.545, 0.49), control1: pt(0.615, 0.60), control2: pt(0.585, 0.545))
      tailFan.closeSubpath()
      context.fill(tailFan, with: .color(colors.secondary))

      // Tail coverts overlapping the fan base.
      var tailCovert = Path()
      tailCovert.move(to: pt(0.445, 0.50))
      tailCovert.addCurve(to: pt(0.50, 0.635), control1: pt(0.45, 0.565), control2: pt(0.475, 0.615))
      tailCovert.addCurve(to: pt(0.555, 0.50), control1: pt(0.525, 0.615), control2: pt(0.55, 0.565))
      tailCovert.closeSubpath()
      context.fill(tailCovert, with: bodyGradient)

      // Compact torso: soft egg shape between the wings.
      var torso = Path()
      torso.move(to: pt(0.50, 0.28))
      torso.addCurve(to: pt(0.585, 0.44), control1: pt(0.565, 0.30), control2: pt(0.585, 0.37))
      torso.addCurve(to: pt(0.50, 0.575), control1: pt(0.585, 0.51), control2: pt(0.55, 0.565))
      torso.addCurve(to: pt(0.415, 0.44), control1: pt(0.45, 0.565), control2: pt(0.415, 0.51))
      torso.addCurve(to: pt(0.50, 0.28), control1: pt(0.415, 0.37), control2: pt(0.435, 0.30))
      torso.closeSubpath()
      context.fill(torso, with: bodyGradient)

      // Pale belly seen from below.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.447 * w, y: 0.425 * h, width: 0.106 * w, height: 0.13 * h)),
        with: .color(colors.secondary.opacity(0.9))
      )

      // Head, turned slightly to the left.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.415 * w, y: 0.17 * h, width: 0.15 * w, height: 0.15 * h)),
        with: bodyGradient
      )

      // Short hooked beak.
      var beak = Path()
      beak.move(to: pt(0.435, 0.205))
      beak.addCurve(to: pt(0.347, 0.252), control1: pt(0.39, 0.202), control2: pt(0.353, 0.222))
      beak.addCurve(to: pt(0.42, 0.258), control1: pt(0.362, 0.252), control2: pt(0.39, 0.258))
      beak.addCurve(to: pt(0.435, 0.205), control1: pt(0.432, 0.24), control2: pt(0.435, 0.22))
      beak.closeSubpath()
      context.fill(beak, with: .color(colors.accent))

      // Round eye with highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.437 * w, y: 0.208 * h, width: 0.042 * w, height: 0.046 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.447 * w, y: 0.215 * h, width: 0.015 * w, height: 0.017 * h)),
        with: .color(.white.opacity(0.9))
      )
    }
  }
}

#Preview("Bird") {
  BirdFigure(colors: FigureColors(
    body: Color(red: 0.45, green: 0.30, blue: 0.20),
    secondary: Color(red: 0.95, green: 0.88, blue: 0.72),
    accent: Color(red: 0.95, green: 0.65, blue: 0.20)
  ))
  .frame(width: 300, height: 300)
  .background(.cyan.opacity(0.2))
}
