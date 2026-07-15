//
//  SerpentFigure.swift
//  ShaderCards
//
//  A majestic sea serpent rising from the bottom of the frame.
//

import SwiftUI

/// A sea serpent in an elegant S-pose: coils break the bottom edge and
/// the neck rises to a proud horned head at the upper left.
struct SerpentFigure: View {
  let colors: FigureColors

  var body: some View {
    Canvas { context, size in
      let w = size.width
      let h = size.height
      func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
      }

      let bodyGradient = GraphicsContext.Shading.linearGradient(
        Gradient(colors: [colors.body.opacity(0.92), colors.body]),
        startPoint: pt(0.5, 0.1),
        endPoint: pt(0.5, 1.0)
      )

      // Far coil arc (behind, right side), breaking the bottom edge.
      var farCoil = Path()
      farCoil.move(to: pt(0.62, 1.0))
      farCoil.addCurve(to: pt(0.80, 0.62), control1: pt(0.60, 0.82), control2: pt(0.66, 0.64))
      farCoil.addCurve(to: pt(0.97, 1.0), control1: pt(0.94, 0.60), control2: pt(0.99, 0.82))
      farCoil.closeSubpath()
      context.fill(farCoil, with: .color(colors.body.opacity(0.65)))

      // Near coil arc (middle), breaking the bottom edge.
      var nearCoil = Path()
      nearCoil.move(to: pt(0.28, 1.0))
      nearCoil.addCurve(to: pt(0.52, 0.70), control1: pt(0.28, 0.84), control2: pt(0.38, 0.70))
      nearCoil.addCurve(to: pt(0.76, 1.0), control1: pt(0.66, 0.70), control2: pt(0.76, 0.84))
      nearCoil.closeSubpath()
      context.fill(nearCoil, with: bodyGradient)

      // Belly band on the near coil.
      var coilBelly = Path()
      coilBelly.move(to: pt(0.34, 1.0))
      coilBelly.addCurve(to: pt(0.52, 0.76), control1: pt(0.34, 0.87), control2: pt(0.42, 0.76))
      coilBelly.addCurve(to: pt(0.70, 1.0), control1: pt(0.62, 0.76), control2: pt(0.70, 0.87))
      coilBelly.closeSubpath()
      context.fill(coilBelly, with: .color(colors.secondary.opacity(0.55)))

      // Main neck: rises from bottom-left up to the head.
      var neck = Path()
      neck.move(to: pt(0.02, 1.0))
      neck.addCurve(to: pt(0.20, 0.52), control1: pt(0.04, 0.80), control2: pt(0.10, 0.62))
      neck.addCurve(to: pt(0.28, 0.24), control1: pt(0.30, 0.42), control2: pt(0.24, 0.32))
      neck.addCurve(to: pt(0.42, 0.30), control1: pt(0.34, 0.20), control2: pt(0.42, 0.24))
      neck.addCurve(to: pt(0.40, 0.60), control1: pt(0.42, 0.40), control2: pt(0.34, 0.48))
      neck.addCurve(to: pt(0.30, 1.0), control1: pt(0.46, 0.74), control2: pt(0.34, 0.86))
      neck.closeSubpath()
      context.fill(neck, with: bodyGradient)

      // Dorsal fin crest: triangular spines along the back of the neck.
      let spines: [(CGFloat, CGFloat, CGFloat)] = [
        (0.115, 0.70, 0.075),
        (0.155, 0.585, 0.08),
        (0.21, 0.475, 0.08),
        (0.245, 0.375, 0.07),
        (0.27, 0.29, 0.055),
      ]
      for (sx, sy, sizeU) in spines {
        var spine = Path()
        spine.move(to: pt(sx, sy))
        spine.addCurve(
          to: pt(sx - sizeU * 1.3, sy - sizeU * 0.7),
          control1: pt(sx - sizeU * 0.4, sy - sizeU * 0.5),
          control2: pt(sx - sizeU * 0.9, sy - sizeU * 0.75)
        )
        spine.addCurve(
          to: pt(sx - sizeU * 0.1, sy + sizeU * 0.7),
          control1: pt(sx - sizeU * 0.9, sy),
          control2: pt(sx - sizeU * 0.4, sy + sizeU * 0.4)
        )
        spine.closeSubpath()
        context.fill(spine, with: .color(colors.secondary.opacity(0.9)))
      }

      // Belly bands on the front of the neck.
      for i in 0..<6 {
        let t = CGFloat(i)
        var band = Path()
        let bx = 0.335 + t * 0.008
        let by = 0.335 + t * 0.075
        band.addEllipse(in: CGRect(
          x: (bx - 0.052 - t * 0.004) * w,
          y: by * h,
          width: (0.10 + t * 0.008) * w,
          height: 0.035 * h
        ))
        context.fill(band, with: .color(colors.secondary.opacity(0.75)))
      }

      // Head: elongated elegant snout pointing right.
      var head = Path()
      head.move(to: pt(0.28, 0.24))
      head.addCurve(to: pt(0.52, 0.155), control1: pt(0.32, 0.16), control2: pt(0.42, 0.14))
      head.addCurve(to: pt(0.44, 0.26), control1: pt(0.54, 0.20), control2: pt(0.50, 0.245))
      head.addCurve(to: pt(0.42, 0.30), control1: pt(0.44, 0.28), control2: pt(0.43, 0.29))
      head.addCurve(to: pt(0.28, 0.24), control1: pt(0.36, 0.24), control2: pt(0.32, 0.28))
      head.closeSubpath()
      context.fill(head, with: bodyGradient)

      // Horn pair sweeping back from the crown.
      for (baseX, baseY, tipX, tipY) in [
        (0.315, 0.185, 0.22, 0.075),
        (0.365, 0.175, 0.295, 0.055),
      ] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        var horn = Path()
        horn.move(to: pt(baseX, baseY))
        horn.addCurve(
          to: pt(tipX, tipY),
          control1: pt(baseX - 0.02, baseY - 0.05),
          control2: pt(tipX + 0.02, tipY + 0.03)
        )
        horn.addCurve(
          to: pt(baseX + 0.035, baseY + 0.01),
          control1: pt(tipX + 0.045, tipY + 0.045),
          control2: pt(baseX + 0.035, baseY - 0.03)
        )
        horn.closeSubpath()
        context.fill(horn, with: .color(colors.secondary))
      }

      // Whisker barbels trailing from the snout.
      var whisker = Path()
      whisker.move(to: pt(0.50, 0.19))
      whisker.addCurve(to: pt(0.64, 0.30), control1: pt(0.58, 0.20), control2: pt(0.58, 0.28))
      context.stroke(whisker, with: .color(colors.accent.opacity(0.8)), style: StrokeStyle(
        lineWidth: 0.010 * w, lineCap: .round
      ))
      var whisker2 = Path()
      whisker2.move(to: pt(0.475, 0.225))
      whisker2.addCurve(to: pt(0.575, 0.36), control1: pt(0.545, 0.25), control2: pt(0.52, 0.33))
      context.stroke(whisker2, with: .color(colors.accent.opacity(0.6)), style: StrokeStyle(
        lineWidth: 0.008 * w, lineCap: .round
      ))

      // Eye with pupil and highlight.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.355 * w, y: 0.185 * h, width: 0.052 * w, height: 0.052 * h)),
        with: .color(colors.accent)
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.368 * w, y: 0.196 * h, width: 0.028 * w, height: 0.03 * h)),
        with: .color(.black.opacity(0.85))
      )
      context.fill(
        Path(ellipseIn: CGRect(x: 0.377 * w, y: 0.20 * h, width: 0.011 * w, height: 0.012 * h)),
        with: .color(.white.opacity(0.95))
      )

      // Nostril.
      context.fill(
        Path(ellipseIn: CGRect(x: 0.475 * w, y: 0.175 * h, width: 0.014 * w, height: 0.012 * h)),
        with: .color(.black.opacity(0.5))
      )
    }
  }
}

#Preview("Serpent") {
  SerpentFigure(colors: FigureColors(
    body: Color(red: 0.10, green: 0.45, blue: 0.75),
    secondary: Color(red: 0.50, green: 0.85, blue: 0.95),
    accent: Color(red: 0.85, green: 0.97, blue: 1.0)
  ))
  .frame(width: 300, height: 300)
  .background(.indigo.opacity(0.3))
}
