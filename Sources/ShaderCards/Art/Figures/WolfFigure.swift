//
//  WolfFigure.swift
//  ShaderCards
//
//  A howling wolf drawn from bezier paths in unit space.
//

import SwiftUI

/// A noble seated wolf, facing left, muzzle raised mid-howl.
struct WolfFigure: View {
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
        startPoint: pt(0.5, 0.05),
        endPoint: pt(0.5, 0.9)
      )

      // Ground shadow.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.16 * w, y: 0.845 * h, width: 0.66 * w, height: 0.09 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Torso: seated haunches with a smooth back curve rising to the neck.
      var torso = Path()
      torso.move(to: pt(0.38, 0.30))
      torso.addCurve(to: pt(0.345, 0.62), control1: pt(0.335, 0.40), control2: pt(0.325, 0.52))
      torso.addCurve(to: pt(0.40, 0.86), control1: pt(0.355, 0.72), control2: pt(0.37, 0.82))
      torso.addCurve(to: pt(0.665, 0.85), control1: pt(0.50, 0.885), control2: pt(0.60, 0.885))
      torso.addCurve(to: pt(0.68, 0.55), control1: pt(0.735, 0.78), control2: pt(0.735, 0.63))
      torso.addCurve(to: pt(0.38, 0.30), control1: pt(0.62, 0.42), control2: pt(0.47, 0.335))
      torso.closeSubpath()
      context.fill(torso, with: bodyGradient)

      // Haunch crease: subtle shading over the folded hind leg.
      var haunch = Path()
      haunch.move(to: pt(0.64, 0.505))
      haunch.addCurve(to: pt(0.665, 0.78), control1: pt(0.71, 0.565), control2: pt(0.71, 0.70))
      haunch.addCurve(to: pt(0.64, 0.505), control1: pt(0.63, 0.70), control2: pt(0.615, 0.575))
      haunch.closeSubpath()
      context.fill(haunch, with: .color(.black.opacity(0.08)))

      // Front legs: straight and together, far leg shaded behind the near one.
      let farLeg = Path(
        roundedRect: CGRect(x: 0.345 * w, y: 0.615 * h, width: 0.053 * w, height: 0.255 * h),
        cornerSize: CGSize(width: 0.025 * w, height: 0.025 * w)
      )
      context.fill(farLeg, with: bodyGradient)
      context.fill(farLeg, with: .color(.black.opacity(0.14)))

      let nearLeg = Path(
        roundedRect: CGRect(x: 0.392 * w, y: 0.615 * h, width: 0.06 * w, height: 0.26 * h),
        cornerSize: CGSize(width: 0.027 * w, height: 0.027 * w)
      )
      context.fill(nearLeg, with: bodyGradient)

      // Tail: bushy sweep curling around the seated base.
      var tail = Path()
      tail.move(to: pt(0.70, 0.62))
      tail.addCurve(to: pt(0.78, 0.845), control1: pt(0.775, 0.68), control2: pt(0.795, 0.77))
      tail.addCurve(to: pt(0.46, 0.895), control1: pt(0.745, 0.905), control2: pt(0.58, 0.91))
      tail.addCurve(to: pt(0.235, 0.845), control1: pt(0.37, 0.885), control2: pt(0.28, 0.875))
      tail.addCurve(to: pt(0.30, 0.80), control1: pt(0.21, 0.82), control2: pt(0.245, 0.795))
      tail.addCurve(to: pt(0.60, 0.77), control1: pt(0.40, 0.815), control2: pt(0.50, 0.80))
      tail.addCurve(to: pt(0.70, 0.62), control1: pt(0.66, 0.75), control2: pt(0.665, 0.70))
      tail.closeSubpath()
      context.fill(tail, with: bodyGradient)

      // Lighter tail tip in the secondary color.
      var tailTip = Path()
      tailTip.move(to: pt(0.40, 0.812))
      tailTip.addCurve(to: pt(0.30, 0.80), control1: pt(0.365, 0.805), control2: pt(0.33, 0.796))
      tailTip.addCurve(to: pt(0.235, 0.845), control1: pt(0.255, 0.797), control2: pt(0.215, 0.822))
      tailTip.addCurve(to: pt(0.40, 0.878), control1: pt(0.26, 0.872), control2: pt(0.33, 0.884))
      tailTip.addCurve(to: pt(0.40, 0.812), control1: pt(0.415, 0.858), control2: pt(0.415, 0.832))
      tailTip.closeSubpath()
      context.fill(tailTip, with: .color(colors.secondary))

      // Chest ruff: thick fur bib with a jagged trailing edge.
      var ruff = Path()
      ruff.move(to: pt(0.375, 0.315))
      ruff.addCurve(to: pt(0.455, 0.425), control1: pt(0.43, 0.33), control2: pt(0.455, 0.385))
      ruff.addLine(to: pt(0.415, 0.445))
      ruff.addCurve(to: pt(0.45, 0.55), control1: pt(0.44, 0.475), control2: pt(0.455, 0.52))
      ruff.addLine(to: pt(0.405, 0.555))
      ruff.addCurve(to: pt(0.425, 0.655), control1: pt(0.43, 0.585), control2: pt(0.435, 0.625))
      ruff.addCurve(to: pt(0.355, 0.615), control1: pt(0.395, 0.665), control2: pt(0.365, 0.65))
      ruff.addCurve(to: pt(0.375, 0.315), control1: pt(0.34, 0.52), control2: pt(0.345, 0.405))
      ruff.closeSubpath()
      context.fill(ruff, with: .color(colors.secondary))

      // Ear: pointed and laid slightly back.
      var ear = Path()
      ear.move(to: pt(0.395, 0.225))
      ear.addQuadCurve(to: pt(0.545, 0.105), control: pt(0.435, 0.13))
      ear.addQuadCurve(to: pt(0.46, 0.265), control: pt(0.535, 0.20))
      ear.closeSubpath()
      context.fill(ear, with: bodyGradient)

      var earInner = Path()
      earInner.move(to: pt(0.43, 0.235))
      earInner.addQuadCurve(to: pt(0.525, 0.14), control: pt(0.455, 0.165))
      earInner.addQuadCurve(to: pt(0.455, 0.25), control: pt(0.515, 0.205))
      earInner.closeSubpath()
      context.fill(earInner, with: .color(.black.opacity(0.18)))

      // Head: skull tilted up with the muzzle raised at ~45°, mouth parted.
      var head = Path()
      head.move(to: pt(0.44, 0.26))
      head.addCurve(to: pt(0.205, 0.065), control1: pt(0.36, 0.14), control2: pt(0.28, 0.10))
      head.addCurve(to: pt(0.185, 0.093), control1: pt(0.19, 0.068), control2: pt(0.18, 0.078))
      head.addCurve(to: pt(0.29, 0.20), control1: pt(0.21, 0.13), control2: pt(0.245, 0.165))
      head.addQuadCurve(to: pt(0.23, 0.205), control: pt(0.26, 0.198))
      head.addCurve(to: pt(0.37, 0.345), control1: pt(0.245, 0.26), control2: pt(0.30, 0.32))
      head.addCurve(to: pt(0.44, 0.26), control1: pt(0.41, 0.33), control2: pt(0.445, 0.30))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Brow marking in the accent color.
      var brow = Path()
      brow.move(to: pt(0.265, 0.125))
      brow.addCurve(to: pt(0.345, 0.175), control1: pt(0.30, 0.125), control2: pt(0.33, 0.15))
      brow.addCurve(to: pt(0.265, 0.125), control1: pt(0.32, 0.165), control2: pt(0.29, 0.14))
      brow.closeSubpath()
      context.fill(brow, with: .color(colors.accent.opacity(0.8)))

      // Closed eye: a serene curved line for the howl.
      var eye = Path()
      eye.move(to: pt(0.295, 0.155))
      eye.addQuadCurve(to: pt(0.345, 0.185), control: pt(0.31, 0.19))
      context.stroke(eye, with: .color(.black.opacity(0.8)), style: StrokeStyle(
        lineWidth: 0.016 * w, lineCap: .round
      ))

      // Nose tip.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.172 * w, y: 0.058 * h, width: 0.036 * w, height: 0.032 * h)),
        with: .color(.black.opacity(0.85))
      )
    }
  }
}

#Preview("Wolf") {
  WolfFigure(colors: FigureColors(
    body: Color(red: 0.45, green: 0.52, blue: 0.62),
    secondary: Color(red: 0.85, green: 0.89, blue: 0.94),
    accent: Color(red: 0.25, green: 0.60, blue: 0.80)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.2))
}
