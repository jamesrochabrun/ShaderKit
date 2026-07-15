//
//  CatFigure.swift
//  ShaderCards
//
//  An adorable seated cat drawn from bezier paths in unit space.
//

import SwiftUI

/// A cute cat sitting upright, facing forward with a slight three-quarter
/// charm: big round head, huge almond eyes, and a tail curled around the front.
struct CatFigure: View {
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
        Path(ellipseIn: CGRect(x: 0.19 * w, y: 0.85 * h, width: 0.62 * w, height: 0.085 * h)),
        with: .color(.black.opacity(0.18))
      )

      // Compact seated pear-shaped body.
      var torso = Path()
      torso.move(to: pt(0.50, 0.44))
      torso.addCurve(to: pt(0.685, 0.87), control1: pt(0.635, 0.50), control2: pt(0.705, 0.68))
      torso.addCurve(to: pt(0.315, 0.87), control1: pt(0.60, 0.905), control2: pt(0.40, 0.905))
      torso.addCurve(to: pt(0.50, 0.44), control1: pt(0.295, 0.68), control2: pt(0.365, 0.50))
      torso.closeSubpath()
      context.fill(torso, with: bodyGradient)

      // Chest patch running down the front.
      var chest = Path()
      chest.move(to: pt(0.49, 0.50))
      chest.addCurve(to: pt(0.585, 0.845), control1: pt(0.565, 0.565), control2: pt(0.60, 0.72))
      chest.addCurve(to: pt(0.395, 0.845), control1: pt(0.545, 0.875), control2: pt(0.435, 0.875))
      chest.addCurve(to: pt(0.49, 0.50), control1: pt(0.38, 0.72), control2: pt(0.415, 0.565))
      chest.closeSubpath()
      context.fill(chest, with: .color(colors.secondary))

      // Front paws tucked together at the bottom.
      for pawX in [0.41, 0.51] as [CGFloat] {
        var paw = Path()
        paw.addRoundedRect(
          in: CGRect(x: pawX * w, y: 0.775 * h, width: 0.09 * w, height: 0.09 * h),
          cornerSize: CGSize(width: 0.038 * w, height: 0.038 * w)
        )
        context.fill(paw, with: .color(colors.secondary))
        context.stroke(paw, with: .color(colors.body.opacity(0.35)), style: StrokeStyle(
          lineWidth: 0.006 * w
        ))

        var toe = Path()
        toe.move(to: pt(pawX + 0.045, 0.815))
        toe.addLine(to: pt(pawX + 0.045, 0.855))
        context.stroke(toe, with: .color(colors.body.opacity(0.4)), style: StrokeStyle(
          lineWidth: 0.006 * w, lineCap: .round
        ))
      }

      // Tail curling around the front of the paws.
      var tail = Path()
      tail.move(to: pt(0.60, 0.66))
      tail.addCurve(to: pt(0.775, 0.87), control1: pt(0.705, 0.675), control2: pt(0.79, 0.77))
      tail.addCurve(to: pt(0.315, 0.885), control1: pt(0.665, 0.935), control2: pt(0.45, 0.935))
      tail.addCurve(to: pt(0.312, 0.795), control1: pt(0.245, 0.875), control2: pt(0.248, 0.805))
      tail.addCurve(to: pt(0.655, 0.79), control1: pt(0.40, 0.85), control2: pt(0.54, 0.855))
      tail.addCurve(to: pt(0.545, 0.66), control1: pt(0.67, 0.745), control2: pt(0.60, 0.67))
      tail.closeSubpath()
      context.fill(tail, with: bodyGradient)

      // Lighter tail tip.
      var tailTip = Path()
      tailTip.move(to: pt(0.415, 0.88))
      tailTip.addCurve(to: pt(0.312, 0.795), control1: pt(0.30, 0.90), control2: pt(0.24, 0.83))
      tailTip.addCurve(to: pt(0.42, 0.845), control1: pt(0.37, 0.84), control2: pt(0.395, 0.845))
      tailTip.closeSubpath()
      context.fill(tailTip, with: .color(colors.secondary))

      // Big round head, slightly wider than tall.
      var head = Path()
      head.move(to: pt(0.73, 0.34))
      head.addCurve(to: pt(0.50, 0.535), control1: pt(0.73, 0.46), control2: pt(0.64, 0.535))
      head.addCurve(to: pt(0.27, 0.34), control1: pt(0.36, 0.535), control2: pt(0.27, 0.46))
      head.addCurve(to: pt(0.50, 0.135), control1: pt(0.27, 0.21), control2: pt(0.35, 0.135))
      head.addCurve(to: pt(0.73, 0.34), control1: pt(0.65, 0.135), control2: pt(0.73, 0.21))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Ears: outer triangles with inner secondary fills.
      for (base, tip, lean) in [
        (pt(0.375, 0.215), pt(0.29, 0.055), 0.07),
        (pt(0.625, 0.215), pt(0.715, 0.06), 0.07),
      ] {
        var ear = Path()
        ear.move(to: CGPoint(x: base.x - lean * w, y: base.y))
        ear.addLine(to: tip)
        ear.addLine(to: CGPoint(x: base.x + lean * w, y: base.y))
        ear.closeSubpath()
        context.fill(ear, with: bodyGradient)

        var inner = Path()
        inner.move(to: CGPoint(x: base.x - lean * 0.45 * w, y: base.y - 0.008 * h))
        inner.addLine(to: CGPoint(x: tip.x + (base.x - tip.x) * 0.22, y: tip.y + (base.y - tip.y) * 0.22))
        inner.addLine(to: CGPoint(x: base.x + lean * 0.45 * w, y: base.y - 0.008 * h))
        inner.closeSubpath()
        context.fill(inner, with: .color(colors.secondary))
      }

      // Muzzle patch, offset a touch left for the three-quarter look.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.365 * w, y: 0.35 * h, width: 0.25 * w, height: 0.14 * h)),
        with: .color(colors.secondary)
      )

      // Subtle tabby marking on the forehead.
      for (x0, y0, cx, cy, x1, y1) in [
        (0.49, 0.148, 0.497, 0.19, 0.49, 0.235),
        (0.443, 0.162, 0.44, 0.198, 0.452, 0.232),
        (0.537, 0.162, 0.54, 0.198, 0.528, 0.232),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] {
        var stripe = Path()
        stripe.move(to: pt(x0, y0))
        stripe.addQuadCurve(to: pt(x1, y1), control: pt(cx, cy))
        context.stroke(stripe, with: .color(colors.accent.opacity(0.5)), style: StrokeStyle(
          lineWidth: 0.016 * w, lineCap: .round
        ))
      }

      // Signature almond eyes: accent iris, deep pupil, sparkling highlights.
      for cx in [0.40, 0.58] as [CGFloat] {
        let cy: CGFloat = 0.325
        var eye = Path()
        eye.move(to: pt(cx - 0.057, cy + 0.008))
        eye.addCurve(
          to: pt(cx + 0.057, cy + 0.008),
          control1: pt(cx - 0.044, cy - 0.078),
          control2: pt(cx + 0.044, cy - 0.078)
        )
        eye.addCurve(
          to: pt(cx - 0.057, cy + 0.008),
          control1: pt(cx + 0.044, cy + 0.062),
          control2: pt(cx - 0.044, cy + 0.062)
        )
        eye.closeSubpath()
        context.fill(eye, with: .color(colors.accent))

        context.fill(
          Path(ellipseIn: CGRect(x: (cx - 0.026) * w, y: (cy - 0.038) * h, width: 0.052 * w, height: 0.076 * h)),
          with: .color(.black.opacity(0.88))
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (cx - 0.028) * w, y: (cy - 0.032) * h, width: 0.026 * w, height: 0.028 * h)),
          with: .color(.white.opacity(0.95))
        )
        context.fill(
          Path(ellipseIn: CGRect(x: (cx + 0.007) * w, y: (cy + 0.012) * h, width: 0.013 * w, height: 0.014 * h)),
          with: .color(.white.opacity(0.7))
        )
      }

      // Tiny triangle nose with a softly rounded point.
      var nose = Path()
      nose.move(to: pt(0.462, 0.412))
      nose.addLine(to: pt(0.518, 0.412))
      nose.addQuadCurve(to: pt(0.49, 0.448), control: pt(0.514, 0.442))
      nose.addQuadCurve(to: pt(0.462, 0.412), control: pt(0.466, 0.442))
      nose.closeSubpath()
      context.fill(nose, with: .color(colors.accent))

      // Little smiling mouth under the nose.
      for mouthEndX in [0.458, 0.522] as [CGFloat] {
        var mouth = Path()
        mouth.move(to: pt(0.49, 0.452))
        mouth.addQuadCurve(to: pt(mouthEndX, 0.469), control: pt(0.49 + (mouthEndX - 0.49) * 0.25, 0.474))
        context.stroke(mouth, with: .color(.black.opacity(0.45)), style: StrokeStyle(
          lineWidth: 0.009 * w, lineCap: .round
        ))
      }

      // Whiskers, three per side.
      for (x0, y0, cx, cy, x1, y1) in [
        (0.36, 0.40, 0.29, 0.378, 0.22, 0.372),
        (0.355, 0.425, 0.285, 0.418, 0.21, 0.425),
        (0.36, 0.45, 0.29, 0.458, 0.225, 0.475),
        (0.62, 0.40, 0.69, 0.375, 0.755, 0.37),
        (0.625, 0.425, 0.695, 0.412, 0.765, 0.42),
        (0.62, 0.45, 0.685, 0.455, 0.75, 0.472),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] {
        var whisker = Path()
        whisker.move(to: pt(x0, y0))
        whisker.addQuadCurve(to: pt(x1, y1), control: pt(cx, cy))
        context.stroke(whisker, with: .color(.white.opacity(0.85)), style: StrokeStyle(
          lineWidth: 0.007 * w, lineCap: .round
        ))
      }
    }
  }
}

#Preview("Cat") {
  CatFigure(colors: FigureColors(
    body: Color(red: 0.93, green: 0.60, blue: 0.26),
    secondary: Color(red: 1.0, green: 0.94, blue: 0.84),
    accent: Color(red: 0.20, green: 0.60, blue: 0.40)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.2))
}
