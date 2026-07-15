//
//  GolemFigure.swift
//  ShaderCards
//
//  A mighty rock golem drawn from bezier paths in unit space.
//

import SwiftUI

/// A hulking stone golem standing front-on: boulder torso, ground-slammed
/// fists, cracked stone plates, and a glowing runic core.
struct GolemFigure: View {
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
        Path(ellipseIn: CGRect(x: 0.10 * w, y: 0.84 * h, width: 0.80 * w, height: 0.09 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Chunky short legs poking out beneath the torso.
      for (x, y, width, height) in [
        (0.345, 0.66, 0.115, 0.22),
        (0.545, 0.67, 0.115, 0.21),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        var leg = Path()
        leg.addRoundedRect(
          in: CGRect(x: x * w, y: y * h, width: width * w, height: height * h),
          cornerSize: CGSize(width: 0.045 * w, height: 0.045 * w)
        )
        context.fill(leg, with: bodyGradient)
      }

      // Head: a smaller boulder drawn first so the torso swallows its base.
      var head = Path()
      head.move(to: pt(0.38, 0.24))
      head.addCurve(to: pt(0.47, 0.135), control1: pt(0.38, 0.17), control2: pt(0.41, 0.14))
      head.addCurve(to: pt(0.63, 0.23), control1: pt(0.56, 0.125), control2: pt(0.63, 0.165))
      head.addCurve(to: pt(0.50, 0.30), control1: pt(0.63, 0.275), control2: pt(0.58, 0.30))
      head.addCurve(to: pt(0.38, 0.24), control1: pt(0.43, 0.30), control2: pt(0.38, 0.285))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Torso: massive rounded boulder, right shoulder hitched slightly higher.
      var torso = Path()
      torso.move(to: pt(0.28, 0.28))
      torso.addCurve(to: pt(0.50, 0.30), control1: pt(0.36, 0.26), control2: pt(0.43, 0.30))
      torso.addCurve(to: pt(0.72, 0.26), control1: pt(0.57, 0.30), control2: pt(0.64, 0.23))
      torso.addCurve(to: pt(0.78, 0.55), control1: pt(0.80, 0.31), control2: pt(0.82, 0.44))
      torso.addCurve(to: pt(0.62, 0.78), control1: pt(0.76, 0.68), control2: pt(0.72, 0.76))
      torso.addCurve(to: pt(0.36, 0.77), control1: pt(0.52, 0.81), control2: pt(0.44, 0.81))
      torso.addCurve(to: pt(0.22, 0.52), control1: pt(0.28, 0.74), control2: pt(0.22, 0.64))
      torso.addCurve(to: pt(0.28, 0.28), control1: pt(0.22, 0.40), control2: pt(0.24, 0.31))
      torso.closeSubpath()
      context.fill(torso, with: bodyGradient)

      // Left forearm sweeping from the shoulder down to the ground.
      var leftArm = Path()
      leftArm.move(to: pt(0.28, 0.30))
      leftArm.addCurve(to: pt(0.10, 0.66), control1: pt(0.18, 0.33), control2: pt(0.10, 0.48))
      leftArm.addCurve(to: pt(0.22, 0.68), control1: pt(0.13, 0.72), control2: pt(0.18, 0.72))
      leftArm.addCurve(to: pt(0.32, 0.42), control1: pt(0.26, 0.62), control2: pt(0.28, 0.50))
      leftArm.closeSubpath()
      context.fill(leftArm, with: bodyGradient)

      // Right forearm, planted a touch higher for asymmetry.
      var rightArm = Path()
      rightArm.move(to: pt(0.72, 0.28))
      rightArm.addCurve(to: pt(0.90, 0.64), control1: pt(0.82, 0.31), control2: pt(0.90, 0.46))
      rightArm.addCurve(to: pt(0.78, 0.66), control1: pt(0.87, 0.70), control2: pt(0.82, 0.70))
      rightArm.addCurve(to: pt(0.68, 0.40), control1: pt(0.74, 0.60), control2: pt(0.72, 0.48))
      rightArm.closeSubpath()
      context.fill(rightArm, with: bodyGradient)

      // Left fist: a huge knuckle boulder resting on the ground.
      var leftFist = Path()
      leftFist.move(to: pt(0.06, 0.78))
      leftFist.addCurve(to: pt(0.14, 0.64), control1: pt(0.055, 0.70), control2: pt(0.08, 0.65))
      leftFist.addCurve(to: pt(0.26, 0.74), control1: pt(0.21, 0.63), control2: pt(0.26, 0.67))
      leftFist.addCurve(to: pt(0.20, 0.87), control1: pt(0.26, 0.81), control2: pt(0.25, 0.87))
      leftFist.addCurve(to: pt(0.06, 0.78), control1: pt(0.13, 0.875), control2: pt(0.065, 0.84))
      leftFist.closeSubpath()
      context.fill(leftFist, with: bodyGradient)

      // Right fist, slightly larger and set a little higher.
      var rightFist = Path()
      rightFist.move(to: pt(0.74, 0.76))
      rightFist.addCurve(to: pt(0.84, 0.61), control1: pt(0.74, 0.67), control2: pt(0.77, 0.615))
      rightFist.addCurve(to: pt(0.945, 0.73), control1: pt(0.91, 0.605), control2: pt(0.945, 0.66))
      rightFist.addCurve(to: pt(0.87, 0.86), control1: pt(0.945, 0.80), control2: pt(0.93, 0.855))
      rightFist.addCurve(to: pt(0.74, 0.76), control1: pt(0.81, 0.865), control2: pt(0.745, 0.82))
      rightFist.closeSubpath()
      context.fill(rightFist, with: bodyGradient)

      // Lighter cracked stone plate on the lower torso.
      var torsoPlate = Path()
      torsoPlate.move(to: pt(0.30, 0.46))
      torsoPlate.addCurve(to: pt(0.44, 0.42), control1: pt(0.34, 0.41), control2: pt(0.40, 0.40))
      torsoPlate.addCurve(to: pt(0.42, 0.60), control1: pt(0.48, 0.47), control2: pt(0.47, 0.56))
      torsoPlate.addCurve(to: pt(0.30, 0.46), control1: pt(0.36, 0.64), control2: pt(0.30, 0.56))
      torsoPlate.closeSubpath()
      context.fill(torsoPlate, with: .color(colors.secondary))

      // Plate capping the raised right shoulder.
      var shoulderPlate = Path()
      shoulderPlate.move(to: pt(0.60, 0.30))
      shoulderPlate.addCurve(to: pt(0.72, 0.28), control1: pt(0.63, 0.26), control2: pt(0.69, 0.25))
      shoulderPlate.addCurve(to: pt(0.66, 0.38), control1: pt(0.74, 0.32), control2: pt(0.72, 0.37))
      shoulderPlate.addCurve(to: pt(0.60, 0.30), control1: pt(0.62, 0.39), control2: pt(0.59, 0.35))
      shoulderPlate.closeSubpath()
      context.fill(shoulderPlate, with: .color(colors.secondary))

      // Knuckle plate on the left fist.
      var leftKnuckle = Path()
      leftKnuckle.move(to: pt(0.095, 0.71))
      leftKnuckle.addCurve(to: pt(0.17, 0.665), control1: pt(0.11, 0.675), control2: pt(0.14, 0.66))
      leftKnuckle.addCurve(to: pt(0.225, 0.72), control1: pt(0.20, 0.67), control2: pt(0.225, 0.69))
      leftKnuckle.addCurve(to: pt(0.095, 0.71), control1: pt(0.19, 0.75), control2: pt(0.12, 0.75))
      leftKnuckle.closeSubpath()
      context.fill(leftKnuckle, with: .color(colors.secondary))

      // Knuckle plate on the right fist.
      var rightKnuckle = Path()
      rightKnuckle.move(to: pt(0.79, 0.685))
      rightKnuckle.addCurve(to: pt(0.865, 0.635), control1: pt(0.805, 0.65), control2: pt(0.835, 0.63))
      rightKnuckle.addCurve(to: pt(0.915, 0.695), control1: pt(0.895, 0.64), control2: pt(0.915, 0.665))
      rightKnuckle.addCurve(to: pt(0.79, 0.685), control1: pt(0.88, 0.725), control2: pt(0.81, 0.725))
      rightKnuckle.closeSubpath()
      context.fill(rightKnuckle, with: .color(colors.secondary))

      // Thin crack lines etched into the stone.
      for points in [
        [pt(0.64, 0.40), pt(0.60, 0.46), pt(0.63, 0.52)],
        [pt(0.405, 0.155), pt(0.425, 0.18), pt(0.41, 0.20)],
        [pt(0.12, 0.70), pt(0.15, 0.74), pt(0.13, 0.78)],
        [pt(0.60, 0.72), pt(0.62, 0.76), pt(0.605, 0.80)],
      ] {
        var crack = Path()
        crack.move(to: points[0])
        crack.addLine(to: points[1])
        crack.addLine(to: points[2])
        context.stroke(crack, with: .color(.black.opacity(0.3)), style: StrokeStyle(
          lineWidth: 0.008 * w, lineCap: .round, lineJoin: .round
        ))
      }

      // Finger grooves across the fists.
      for (start, end) in [
        (pt(0.13, 0.76), pt(0.135, 0.84)),
        (pt(0.185, 0.75), pt(0.19, 0.83)),
        (pt(0.815, 0.75), pt(0.81, 0.82)),
        (pt(0.87, 0.745), pt(0.875, 0.82)),
      ] {
        var groove = Path()
        groove.move(to: start)
        groove.addQuadCurve(to: end, control: CGPoint(x: start.x + 0.015 * w, y: (start.y + end.y) * 0.5))
        context.stroke(groove, with: .color(.black.opacity(0.25)), style: StrokeStyle(
          lineWidth: 0.008 * w, lineCap: .round
        ))
      }

      // Runic eyes: soft radial glow beneath sharp accent slits.
      for (ex, ey) in [(0.445, 0.205), (0.555, 0.20)] as [(CGFloat, CGFloat)] {
        context.fill(
          Path(ellipseIn: CGRect(x: (ex - 0.055) * w, y: (ey - 0.055) * h, width: 0.11 * w, height: 0.11 * h)),
          with: .radialGradient(
            Gradient(colors: [colors.accent.opacity(0.85), colors.accent.opacity(0)]),
            center: pt(ex, ey),
            startRadius: 0,
            endRadius: 0.055 * w
          )
        )

        var eye = Path()
        eye.move(to: pt(ex - 0.028, ey + 0.008))
        eye.addLine(to: pt(ex, ey - 0.012))
        eye.addLine(to: pt(ex + 0.028, ey + 0.008))
        eye.addLine(to: pt(ex, ey + 0.002))
        eye.closeSubpath()
        context.fill(eye, with: .color(colors.accent))
      }

      // Chest core: radial glow behind a molten seam.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.39 * w, y: 0.36 * h, width: 0.22 * w, height: 0.22 * h)),
        with: .radialGradient(
          Gradient(colors: [colors.accent.opacity(0.7), colors.accent.opacity(0)]),
          center: pt(0.50, 0.47),
          startRadius: 0,
          endRadius: 0.11 * w
        )
      )

      var seam = Path()
      seam.move(to: pt(0.50, 0.38))
      seam.addCurve(to: pt(0.50, 0.56), control1: pt(0.535, 0.44), control2: pt(0.535, 0.50))
      seam.addCurve(to: pt(0.50, 0.38), control1: pt(0.465, 0.50), control2: pt(0.465, 0.44))
      seam.closeSubpath()
      context.fill(seam, with: .color(colors.accent))

      var seamCore = Path()
      seamCore.move(to: pt(0.50, 0.41))
      seamCore.addCurve(to: pt(0.50, 0.53), control1: pt(0.516, 0.45), control2: pt(0.516, 0.49))
      seamCore.addCurve(to: pt(0.50, 0.41), control1: pt(0.484, 0.49), control2: pt(0.484, 0.45))
      seamCore.closeSubpath()
      context.fill(seamCore, with: .color(.white.opacity(0.75)))

      // Hairline energy cracks branching off the core.
      for (start, end) in [
        (pt(0.50, 0.385), pt(0.47, 0.345)),
        (pt(0.515, 0.52), pt(0.55, 0.56)),
        (pt(0.485, 0.44), pt(0.445, 0.46)),
      ] {
        var spark = Path()
        spark.move(to: start)
        spark.addLine(to: end)
        context.stroke(spark, with: .color(colors.accent.opacity(0.7)), style: StrokeStyle(
          lineWidth: 0.008 * w, lineCap: .round
        ))
      }
    }
  }
}

#Preview("Golem") {
  GolemFigure(colors: FigureColors(
    body: Color(red: 0.52, green: 0.50, blue: 0.47),
    secondary: Color(red: 0.72, green: 0.70, blue: 0.65),
    accent: Color(red: 0.35, green: 0.95, blue: 0.80)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.25))
}
