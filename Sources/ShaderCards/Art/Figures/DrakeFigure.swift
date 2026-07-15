//
//  DrakeFigure.swift
//  ShaderCards
//
//  A noble standing dragon drawn from bezier paths in unit space.
//

import SwiftUI

/// A stylized standing drake, facing left, with a swept-back horned head,
/// a folded wing on its back, and a thick tail curling forward to a spade tip.
struct DrakeFigure: View {
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
        startPoint: pt(0.5, 0.08),
        endPoint: pt(0.5, 0.9)
      )

      // Ground shadow.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.15 * w, y: 0.845 * h, width: 0.64 * w, height: 0.085 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Tail: thick at the rump, curling forward around the feet.
      var tail = Path()
      tail.move(to: pt(0.66, 0.60))
      tail.addCurve(to: pt(0.34, 0.895), control1: pt(0.86, 0.68), control2: pt(0.62, 0.90))
      tail.addCurve(to: pt(0.235, 0.845), control1: pt(0.29, 0.895), control2: pt(0.25, 0.875))
      tail.addCurve(to: pt(0.60, 0.815), control1: pt(0.33, 0.83), control2: pt(0.46, 0.84))
      tail.addCurve(to: pt(0.66, 0.60), control1: pt(0.72, 0.78), control2: pt(0.72, 0.68))
      tail.closeSubpath()
      context.fill(tail, with: bodyGradient)

      // Spade tip pointing forward at the end of the tail.
      var spade = Path()
      spade.move(to: pt(0.245, 0.815))
      spade.addCurve(to: pt(0.125, 0.845), control1: pt(0.21, 0.80), control2: pt(0.16, 0.81))
      spade.addCurve(to: pt(0.245, 0.885), control1: pt(0.16, 0.885), control2: pt(0.21, 0.895))
      spade.addCurve(to: pt(0.245, 0.815), control1: pt(0.225, 0.865), control2: pt(0.225, 0.835))
      spade.closeSubpath()
      context.fill(spade, with: .color(colors.accent))

      // Horns: two swept-back crescents, bases tucked under the skull.
      var frontHorn = Path()
      frontHorn.move(to: pt(0.235, 0.135))
      frontHorn.addCurve(to: pt(0.375, 0.055), control1: pt(0.27, 0.085), control2: pt(0.325, 0.055))
      frontHorn.addCurve(to: pt(0.28, 0.125), control1: pt(0.335, 0.09), control2: pt(0.305, 0.105))
      frontHorn.closeSubpath()
      context.fill(frontHorn, with: .color(colors.secondary))

      var backHorn = Path()
      backHorn.move(to: pt(0.285, 0.155))
      backHorn.addCurve(to: pt(0.425, 0.10), control1: pt(0.325, 0.115), control2: pt(0.38, 0.095))
      backHorn.addCurve(to: pt(0.315, 0.15), control1: pt(0.385, 0.125), control2: pt(0.35, 0.14))
      backHorn.closeSubpath()
      context.fill(backHorn, with: .color(colors.secondary))

      // Silhouette: snout, skull, S-curved neck, back, rump, belly, proud chest.
      var trunk = Path()
      trunk.move(to: pt(0.115, 0.175))
      trunk.addCurve(to: pt(0.29, 0.115), control1: pt(0.14, 0.115), control2: pt(0.22, 0.095))
      trunk.addCurve(to: pt(0.335, 0.20), control1: pt(0.335, 0.13), control2: pt(0.35, 0.16))
      trunk.addCurve(to: pt(0.46, 0.40), control1: pt(0.315, 0.27), control2: pt(0.37, 0.34))
      trunk.addCurve(to: pt(0.72, 0.58), control1: pt(0.58, 0.44), control2: pt(0.70, 0.48))
      trunk.addCurve(to: pt(0.68, 0.76), control1: pt(0.735, 0.65), control2: pt(0.72, 0.72))
      trunk.addCurve(to: pt(0.38, 0.72), control1: pt(0.60, 0.80), control2: pt(0.46, 0.78))
      trunk.addCurve(to: pt(0.255, 0.40), control1: pt(0.28, 0.66), control2: pt(0.235, 0.52))
      trunk.addCurve(to: pt(0.135, 0.235), control1: pt(0.265, 0.32), control2: pt(0.22, 0.26))
      trunk.addCurve(to: pt(0.115, 0.175), control1: pt(0.10, 0.225), control2: pt(0.10, 0.20))
      trunk.closeSubpath()
      context.fill(trunk, with: bodyGradient)

      // Haunch: heavy thigh over the rear body.
      var haunch = Path()
      haunch.move(to: pt(0.54, 0.50))
      haunch.addCurve(to: pt(0.70, 0.72), control1: pt(0.66, 0.52), control2: pt(0.72, 0.62))
      haunch.addCurve(to: pt(0.52, 0.76), control1: pt(0.68, 0.80), control2: pt(0.58, 0.80))
      haunch.addCurve(to: pt(0.54, 0.50), control1: pt(0.46, 0.68), control2: pt(0.47, 0.56))
      haunch.closeSubpath()
      context.fill(haunch, with: bodyGradient)

      // Sturdy legs with rounded feet.
      var frontLeg = Path()
      frontLeg.addRoundedRect(
        in: CGRect(x: 0.345 * w, y: 0.62 * h, width: 0.065 * w, height: 0.245 * h),
        cornerSize: CGSize(width: 0.03 * w, height: 0.03 * w)
      )
      context.fill(frontLeg, with: bodyGradient)

      var hindLeg = Path()
      hindLeg.addRoundedRect(
        in: CGRect(x: 0.585 * w, y: 0.68 * h, width: 0.07 * w, height: 0.19 * h),
        cornerSize: CGSize(width: 0.03 * w, height: 0.03 * w)
      )
      context.fill(hindLeg, with: bodyGradient)

      for footX in [0.305, 0.555] as [CGFloat] {
        context.fill(
          Path(ellipseIn: CGRect(x: footX * w, y: 0.842 * h, width: 0.115 * w, height: 0.048 * h)),
          with: bodyGradient
        )
      }

      // Folded wing lying along the back, with a wrist spike and scalloped edge.
      var wing = Path()
      wing.move(to: pt(0.42, 0.42))
      wing.addCurve(to: pt(0.865, 0.135), control1: pt(0.50, 0.235), control2: pt(0.70, 0.115))
      wing.addCurve(to: pt(0.78, 0.30), control1: pt(0.875, 0.19), control2: pt(0.83, 0.245))
      wing.addCurve(to: pt(0.745, 0.46), control1: pt(0.74, 0.34), control2: pt(0.72, 0.40))
      wing.addCurve(to: pt(0.665, 0.62), control1: pt(0.68, 0.50), control2: pt(0.66, 0.56))
      wing.addCurve(to: pt(0.42, 0.42), control1: pt(0.565, 0.60), control2: pt(0.455, 0.52))
      wing.closeSubpath()
      context.fill(wing, with: .color(colors.secondary))

      // Membrane ribs fanning from the wing joint.
      for (tip, bend) in [
        (pt(0.79, 0.28), pt(0.62, 0.29)),
        (pt(0.74, 0.44), pt(0.60, 0.40)),
        (pt(0.665, 0.595), pt(0.56, 0.50)),
      ] {
        var rib = Path()
        rib.move(to: pt(0.46, 0.43))
        rib.addQuadCurve(to: tip, control: bend)
        context.stroke(rib, with: .color(colors.body.opacity(0.45)), style: StrokeStyle(
          lineWidth: 0.012 * w, lineCap: .round
        ))
      }

      // Belly plates: rounded bands climbing the chest and neck.
      for (x, y, width) in [
        (0.248, 0.345, 0.075),
        (0.252, 0.415, 0.085),
        (0.258, 0.487, 0.095),
        (0.278, 0.560, 0.105),
      ] as [(CGFloat, CGFloat, CGFloat)] {
        var plate = Path()
        plate.addRoundedRect(
          in: CGRect(x: x * w, y: y * h, width: width * w, height: 0.046 * h),
          cornerSize: CGSize(width: 0.023 * w, height: 0.023 * h)
        )
        context.fill(plate, with: .color(colors.accent.opacity(0.9)))
      }

      // Eye with highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.225 * w, y: 0.165 * h, width: 0.038 * w, height: 0.042 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.235 * w, y: 0.172 * h, width: 0.013 * w, height: 0.015 * h)),
        with: .color(.white.opacity(0.9))
      )

      // Nostril near the snout tip.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.145 * w, y: 0.19 * h, width: 0.018 * w, height: 0.014 * h)),
        with: .color(.black.opacity(0.7))
      )
    }
  }
}

#Preview("Drake") {
  DrakeFigure(colors: FigureColors(
    body: Color(red: 0.20, green: 0.55, blue: 0.40),
    secondary: Color(red: 0.55, green: 0.80, blue: 0.60),
    accent: Color(red: 0.95, green: 0.80, blue: 0.35)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.2))
}
