//
//  FishFigure.swift
//  ShaderCards
//
//  An elegant koi gliding upward, drawn from bezier paths in unit space.
//

import SwiftUI

/// A koi-like fish in side profile facing left, arcing gently upward,
/// with a flowing two-lobed tail and soft patch markings on its back.
struct FishFigure: View {
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
        startPoint: pt(0.5, 0.15),
        endPoint: pt(0.5, 0.75)
      )

      // Tail: large two-lobed fin trailing right, with wavy trailing edges.
      var tail = Path()
      tail.move(to: pt(0.60, 0.47))
      tail.addCurve(to: pt(0.90, 0.18), control1: pt(0.70, 0.40), control2: pt(0.80, 0.24))
      tail.addCurve(to: pt(0.83, 0.33), control1: pt(0.89, 0.24), control2: pt(0.87, 0.29))
      tail.addCurve(to: pt(0.76, 0.47), control1: pt(0.79, 0.37), control2: pt(0.755, 0.42))
      tail.addCurve(to: pt(0.85, 0.60), control1: pt(0.775, 0.51), control2: pt(0.815, 0.55))
      tail.addCurve(to: pt(0.92, 0.76), control1: pt(0.885, 0.65), control2: pt(0.925, 0.70))
      tail.addCurve(to: pt(0.62, 0.60), control1: pt(0.82, 0.78), control2: pt(0.68, 0.70))
      tail.closeSubpath()
      context.fill(
        tail,
        with: .linearGradient(
          Gradient(colors: [colors.secondary, colors.secondary.opacity(0.7)]),
          startPoint: pt(0.62, 0.47),
          endPoint: pt(0.92, 0.47)
        )
      )

      // Dorsal fin: swept-back sail on the arch of the back.
      var dorsal = Path()
      dorsal.move(to: pt(0.33, 0.27))
      dorsal.addCurve(to: pt(0.455, 0.115), control1: pt(0.345, 0.185), control2: pt(0.39, 0.125))
      dorsal.addCurve(to: pt(0.50, 0.35), control1: pt(0.50, 0.17), control2: pt(0.525, 0.26))
      dorsal.closeSubpath()
      context.fill(dorsal, with: .color(colors.secondary))

      // Body: crescent-curved koi body arcing upward, nose to the left.
      var fish = Path()
      fish.move(to: pt(0.135, 0.33))
      fish.addCurve(to: pt(0.63, 0.47), control1: pt(0.26, 0.17), control2: pt(0.47, 0.28))
      fish.addCurve(to: pt(0.645, 0.585), control1: pt(0.665, 0.50), control2: pt(0.675, 0.55))
      fish.addCurve(to: pt(0.145, 0.435), control1: pt(0.45, 0.72), control2: pt(0.225, 0.585))
      fish.addCurve(to: pt(0.135, 0.33), control1: pt(0.10, 0.41), control2: pt(0.105, 0.36))
      fish.closeSubpath()
      context.fill(fish, with: bodyGradient)

      // Details clipped to the body silhouette so edges stay clean.
      var inner = context
      inner.clip(to: fish)

      // Belly patch sweeping along the underside.
      var belly = Path()
      belly.move(to: pt(0.15, 0.40))
      belly.addCurve(to: pt(0.63, 0.555), control1: pt(0.27, 0.52), control2: pt(0.49, 0.565))
      belly.addCurve(to: pt(0.15, 0.40), control1: pt(0.43, 0.75), control2: pt(0.19, 0.57))
      belly.closeSubpath()
      inner.fill(belly, with: .color(colors.secondary))

      // Koi patch markings draped over the back.
      for (x, y, sw, sh) in [
        (0.245, 0.235, 0.14, 0.11),
        (0.42, 0.33, 0.11, 0.09),
        (0.5475, 0.4425, 0.075, 0.065),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        inner.fill(
          Path(ellipseIn: CGRect(x: x * w, y: y * h, width: sw * w, height: sh * h)),
          with: .color(colors.accent.opacity(0.8))
        )
      }

      // Gill curve behind the cheek.
      var gill = Path()
      gill.move(to: pt(0.28, 0.30))
      gill.addQuadCurve(to: pt(0.235, 0.49), control: pt(0.305, 0.415))
      context.stroke(gill, with: .color(colors.accent.opacity(0.55)), style: StrokeStyle(
        lineWidth: 0.012 * w, lineCap: .round
      ))

      // Pectoral fin sweeping down and back.
      var pectoral = Path()
      pectoral.move(to: pt(0.265, 0.485))
      pectoral.addCurve(to: pt(0.385, 0.66), control1: pt(0.27, 0.565), control2: pt(0.315, 0.63))
      pectoral.addCurve(to: pt(0.315, 0.475), control1: pt(0.36, 0.60), control2: pt(0.335, 0.525))
      pectoral.closeSubpath()
      context.fill(pectoral, with: .color(colors.secondary.opacity(0.95)))

      // Eye with highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.1725 * w, y: 0.335 * h, width: 0.045 * w, height: 0.05 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.181 * w, y: 0.343 * h, width: 0.016 * w, height: 0.018 * h)),
        with: .color(.white.opacity(0.9))
      )
    }
  }
}

#Preview("Fish") {
  FishFigure(colors: FigureColors(
    body: Color(red: 0.98, green: 0.62, blue: 0.25),
    secondary: Color(red: 1.0, green: 0.94, blue: 0.86),
    accent: Color(red: 0.75, green: 0.20, blue: 0.12)
  ))
  .frame(width: 300, height: 300)
  .background(.cyan.opacity(0.2))
}
