//
//  MetalAvatarCardView.swift
//  ShaderKitDemo
//
//  Premium metal avatar badge with cosmic aura accents.
//

import CoreImage.CIFilterBuiltins
import SwiftUI
import ShaderKit

struct MetalAvatarCardView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.30 }
  private let flipDuration: TimeInterval = 0.56
  @State private var isShowingBack = false
  @State private var isFrontFaceVisible = true
  @State private var flipGeneration = 0

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.04, green: 0.05, blue: 0.09),
          Color(red: 0.10, green: 0.13, blue: 0.20),
          Color(red: 0.02, green: 0.03, blue: 0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      MetalAvatarHolographicStage(
        width: cardWidth,
        height: cardHeight,
        shadowColor: Color(red: 0.70, green: 0.88, blue: 1.0),
        rotationMultiplier: 9
      ) {
        MetalAvatarFlippableCard(
          avatarName: "ray",
          rotation: isShowingBack ? 180 : 0,
          isFrontFaceVisible: isFrontFaceVisible
        )
      }
      .highPriorityGesture(
        TapGesture(count: 2)
          .onEnded {
            flipCard()
          }
      )
    }
    .navigationTitle("Metal Avatar Card")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }

  private func flipCard() {
    let nextIsShowingBack = !isShowingBack
    flipGeneration += 1
    let currentGeneration = flipGeneration

    withAnimation(.easeInOut(duration: flipDuration)) {
      isShowingBack = nextIsShowingBack
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration * 0.5) {
      guard flipGeneration == currentGeneration else {
        return
      }

      var transaction = Transaction()
      transaction.disablesAnimations = true
      withTransaction(transaction) {
        isFrontFaceVisible = !nextIsShowingBack
      }
    }
  }
}

private struct MetalAvatarHolographicStage<Content: View>: View {
  let width: CGFloat
  let height: CGFloat
  let shadowColor: Color
  let rotationMultiplier: Double
  @ViewBuilder let content: () -> Content

  @State private var startTime = Date.now
  @State private var dragOffset: CGSize = .zero
  @State private var touchPosition: CGPoint?

  var body: some View {
    TimelineView(.animation) { timeline in
      let elapsedTime = startTime.distance(to: timeline.date)
      let halfW = max(width * 0.5, 1)
      let halfH = max(height * 0.5, 1)
      let effectiveTilt = CGPoint(
        x: dragOffset.width / halfW,
        y: dragOffset.height / halfH
      )
      let shadowScale = min(width, height) * 0.04

      content()
        .shaderContext(tilt: effectiveTilt, time: elapsedTime, touchPosition: touchPosition)
        .frame(width: width, height: height)
        .contentShape(MetalAvatarCardShape())
        .modifier(MetalAvatarStageTransformEffect(
          tiltX: -effectiveTilt.y * rotationMultiplier,
          tiltY: effectiveTilt.x * rotationMultiplier
        ))
        .shadow(
          color: shadowColor.opacity(0.5),
          radius: shadowScale * 1.5,
          x: effectiveTilt.x * shadowScale,
          y: effectiveTilt.y * shadowScale
        )
        .gesture(
          DragGesture(minimumDistance: 0)
            .onChanged { value in
              withAnimation(.interactiveSpring) {
                dragOffset = value.translation
              }
              touchPosition = CGPoint(
                x: width > 0 ? value.location.x / width : 0,
                y: height > 0 ? value.location.y / height : 0
              )
            }
            .onEnded { _ in
              withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = .zero
              }
              touchPosition = nil
            }
        )
    }
  }
}

private struct MetalAvatarStageTransformEffect: GeometryEffect {
  var tiltX: Double
  var tiltY: Double

  var animatableData: AnimatablePair<Double, Double> {
    get { AnimatablePair(tiltX, tiltY) }
    set {
      tiltX = newValue.first
      tiltY = newValue.second
    }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    var transform = CATransform3DIdentity
    transform.m34 = -1.0 / 1000.0
    transform = CATransform3DTranslate(transform, size.width / 2, size.height / 2, 0)
    transform = CATransform3DRotate(transform, tiltX * .pi / 180, 1, 0, 0)
    transform = CATransform3DRotate(transform, tiltY * .pi / 180, 0, 1, 0)
    transform = CATransform3DTranslate(transform, -size.width / 2, -size.height / 2, 0)
    return ProjectionTransform(transform)
  }
}

private struct MetalAvatarFlippableCard: View {
  let avatarName: String
  let rotation: Double
  let isFrontFaceVisible: Bool

  var body: some View {
    ZStack {
      MetalAvatarBadgeCard(avatarName: avatarName)
        .opacity(isFrontFaceVisible ? 1 : 0)
        .transaction { transaction in
          transaction.animation = nil
        }

      MetalAvatarQRBackCard(payload: "https://shaderkit.dev/card/nic")
        .opacity(isFrontFaceVisible ? 0 : 1)
        .transaction { transaction in
          transaction.animation = nil
        }
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0), perspective: 0.70)
    }
    .rotation3DEffect(
      .degrees(rotation),
      axis: (x: 0, y: 1, z: 0),
      perspective: 0.70
    )
  }
}

private struct MetalAvatarBadgeCard: View {
  let avatarName: String

  var body: some View {
    TimelineView(.animation) { context in
      let time = context.date.timeIntervalSinceReferenceDate

      GeometryReader { geometry in
        let width = geometry.size.width
        let height = geometry.size.height
        let horizontalInset = width * 0.045
        let innerWidth = width - horizontalInset * 2.0
        let artHeight = height * 0.73
        let plateHeight = height - artHeight

        ZStack {
          MetalAvatarCardShape()
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.92, green: 0.97, blue: 1.0),
                  Color(red: 0.68, green: 0.78, blue: 0.92),
                  Color(red: 0.98, green: 0.88, blue: 1.0),
                  Color(red: 0.70, green: 0.86, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shader(.polishedAluminum(intensity: 0.92))

          VStack(spacing: 0) {
            avatarWindow(width: innerWidth, height: artHeight, time: time)
            identityPlate(width: innerWidth, height: plateHeight)
          }
          .padding(.horizontal, horizontalInset)

          MetalAvatarCardShape()
            .strokeBorder(
              LinearGradient(
                colors: [
                  Color.white.opacity(0.96),
                  Color(red: 0.52, green: 0.72, blue: 1.0).opacity(0.90),
                  Color(red: 1.0, green: 0.76, blue: 0.98).opacity(0.82),
                  Color.white.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: width * 0.035
            )
            .shader(.foil(intensity: 0.75))

          MetalAvatarInnerFrameShape()
            .stroke(
              LinearGradient(
                colors: [
                  Color.white.opacity(0.85),
                  Color(red: 0.55, green: 0.82, blue: 1.0).opacity(0.72),
                  Color(red: 0.86, green: 0.67, blue: 1.0).opacity(0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: width * 0.010
            )
            .padding(width * 0.037)
            .blendMode(.screen)

        }
        .clipShape(MetalAvatarCardShape())
        .compositingGroup()
      }
    }
  }

  private func avatarWindow(width: CGFloat, height: CGFloat, time: TimeInterval) -> some View {
    ZStack(alignment: .topLeading) {
      Image(avatarName)
        .resizable()
        .scaledToFill()
        .frame(width: width, height: height)
        .clipped()
        .saturation(1.06)
        .contrast(1.04)

      Rectangle()
        .fill(Color.white.opacity(0.003))
        .frame(width: width, height: height)
        .shader(
          .cosmicAura(
            intensity: 0.62,
            avatarRadius: 0.0,
            auraRadius: 0.72
          ),
          time: time
        )
        .blendMode(.plusLighter)
        .allowsHitTesting(false)

      LinearGradient(
        colors: [
          Color(red: 0.76, green: 0.92, blue: 1.0).opacity(0.16),
          Color.clear,
          Color(red: 0.96, green: 0.65, blue: 1.0).opacity(0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .blendMode(.screen)

      Rectangle()
        .stroke(
          LinearGradient(
            colors: [
              Color.white.opacity(0.80),
              Color(red: 0.60, green: 0.78, blue: 1.0).opacity(0.62),
              Color(red: 0.94, green: 0.64, blue: 1.0).opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: width * 0.012
        )
        .shader(.lightSweep)

      levelBadge(width: width * 0.23)
        .padding(.top, width * 0.070)
        .padding(.leading, width * 0.025)
    }
    .frame(width: width, height: height)
    .clipped()
  }

  private func identityPlate(width: CGFloat, height: CGFloat) -> some View {
    VStack(spacing: height * 0.08) {
      Text("unicorn")
        .font(.system(size: width * 0.128, weight: .semibold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.78)
        .foregroundStyle(Color(red: 0.04, green: 0.13, blue: 0.44))

      Text("ATTENDEE")
        .font(.system(size: width * 0.056, weight: .heavy, design: .rounded))
        .lineLimit(1)
        .foregroundStyle(Color(red: 0.17, green: 0.28, blue: 0.62).opacity(0.86))
    }
    .frame(width: width, height: height)
    .background(
      MetalAvatarIdentityPlateShape()
        .fill(
          LinearGradient(
            colors: [
              Color(red: 0.94, green: 0.98, blue: 1.0),
              Color(red: 0.82, green: 0.90, blue: 1.0),
              Color(red: 0.98, green: 0.90, blue: 1.0),
              Color(red: 0.88, green: 0.96, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .shader(.polishedAluminum(intensity: 0.86))
    )
    .overlay {
      MetalAvatarIdentityPlateShape()
        .stroke(
          LinearGradient(
            colors: [
              Color.white.opacity(0.92),
              Color(red: 0.58, green: 0.77, blue: 1.0).opacity(0.78),
              Color(red: 0.98, green: 0.72, blue: 1.0).opacity(0.70)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: width * 0.012
        )
    }
    .shader(.lightSweep)
  }

  private func levelBadge(width: CGFloat) -> some View {
    MetalAvatarLevelBadgeShape()
      .fill(
        LinearGradient(
          colors: [
            Color.white.opacity(0.95),
            Color(red: 0.72, green: 0.88, blue: 1.0).opacity(0.88),
            Color(red: 0.96, green: 0.82, blue: 1.0).opacity(0.82)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .shader(.polishedAluminum(intensity: 0.70))
      .frame(width: width, height: width)
      .overlay {
        Text("5.5")
          .font(.system(size: width * 0.31, weight: .bold, design: .rounded))
          .lineLimit(1)
          .minimumScaleFactor(0.75)
          .foregroundStyle(Color(red: 0.20, green: 0.34, blue: 0.52))
      }
      .overlay {
        MetalAvatarLevelBadgeShape()
          .stroke(Color.white.opacity(0.80), lineWidth: width * 0.045)
      }
      .shadow(color: Color(red: 0.55, green: 0.80, blue: 1.0).opacity(0.35), radius: width * 0.10)
  }
}

private struct MetalAvatarQRBackCard: View {
  let payload: String
  private let qrImage: CGImage?

  init(payload: String) {
    self.payload = payload
    self.qrImage = MetalAvatarQRCodeFactory.makeImage(payload: payload)
  }

  var body: some View {
    TimelineView(.animation) { _ in
      GeometryReader { geometry in
        let width = geometry.size.width
        let height = geometry.size.height
        let horizontalInset = width * 0.055
        let innerWidth = width - horizontalInset * 2.0
        let qrSize = innerWidth * 0.76

        ZStack {
          MetalAvatarCardShape()
            .fill(
              LinearGradient(
                colors: [
                  Color(red: 0.58, green: 0.78, blue: 0.88),
                  Color(red: 0.72, green: 0.68, blue: 0.88),
                  Color(red: 0.58, green: 0.86, blue: 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )

          VStack(spacing: height * 0.045) {
            Spacer(minLength: height * 0.045)

            Text("unicorn")
              .font(.system(size: width * 0.15, weight: .semibold, design: .rounded))
              .lineLimit(1)
              .minimumScaleFactor(0.80)
              .foregroundStyle(Color(red: 0.04, green: 0.13, blue: 0.44))

            MetalAvatarShaderQRCode(qrImage: qrImage, size: qrSize)

            Text("ATTENDEE")
              .font(.system(size: width * 0.052, weight: .heavy, design: .rounded))
              .lineLimit(1)
              .foregroundStyle(Color(red: 0.16, green: 0.27, blue: 0.62).opacity(0.90))

            Spacer(minLength: height * 0.045)
          }
          .frame(width: innerWidth, height: height)
          .padding(.horizontal, horizontalInset)

          MetalAvatarCardShape()
            .strokeBorder(
              LinearGradient(
                colors: [
                  Color.white.opacity(0.97),
                  Color(red: 0.55, green: 0.82, blue: 1.0).opacity(0.90),
                  Color(red: 1.0, green: 0.75, blue: 0.98).opacity(0.84),
                  Color.white.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: width * 0.035
            )
            .shader(.foil(intensity: 0.78))

          MetalAvatarInnerFrameShape()
            .stroke(
              LinearGradient(
                colors: [
                  Color.white.opacity(0.86),
                  Color(red: 0.55, green: 0.84, blue: 1.0).opacity(0.72),
                  Color(red: 0.90, green: 0.68, blue: 1.0).opacity(0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: width * 0.010
            )
            .padding(width * 0.037)
            .blendMode(.screen)
        }
        .clipShape(MetalAvatarCardShape())
        .compositingGroup()
      }
    }
  }
}

private struct MetalAvatarShaderQRCode: View {
  let qrImage: CGImage?
  let size: CGFloat

  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.white)

      if let qrImage {
        Rectangle()
          .fill(
            LinearGradient(
              colors: [
                Color(red: 0.01, green: 0.04, blue: 0.18),
                Color(red: 0.03, green: 0.12, blue: 0.38),
                Color(red: 0.24, green: 0.12, blue: 0.48),
                Color(red: 0.01, green: 0.06, blue: 0.22)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: size, height: size)
          .shader(.polishedAluminum(intensity: 0.54))
          .shader(.foil(intensity: 0.22))
          .mask {
            qrMask(qrImage)
          }

      } else {
        Image(systemName: "qrcode")
          .resizable()
          .scaledToFit()
          .padding(size * 0.20)
          .foregroundStyle(Color(red: 0.05, green: 0.16, blue: 0.45))
      }

      Rectangle()
        .stroke(Color(red: 0.68, green: 0.88, blue: 1.0).opacity(0.62), lineWidth: size * 0.018)
    }
    .frame(width: size, height: size)
    .clipped()
  }

  private func qrMask(_ qrImage: CGImage) -> some View {
    Image(decorative: qrImage, scale: 1)
      .interpolation(.none)
      .resizable()
      .scaledToFit()
      .padding(size * 0.075)
      .frame(width: size, height: size)
  }
}

private enum MetalAvatarQRCodeFactory {
  static func makeImage(payload: String) -> CGImage? {
    let generator = CIFilter.qrCodeGenerator()
    generator.message = Data(payload.utf8)
    generator.correctionLevel = "Q"

    guard let qrImage = generator.outputImage else {
      return nil
    }

    let recolor = CIFilter.falseColor()
    recolor.inputImage = qrImage
    recolor.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
    recolor.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)

    guard let outputImage = recolor.outputImage else {
      return nil
    }

    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 16, y: 16))
    return CIContext(options: nil).createCGImage(scaledImage, from: scaledImage.extent)
  }
}

private struct MetalAvatarCardShape: InsettableShape {
  var insetAmount: CGFloat = 0

  func path(in rect: CGRect) -> Path {
    let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
    let radius = min(rect.width, rect.height) * 0.075
    return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
  }

  func inset(by amount: CGFloat) -> MetalAvatarCardShape {
    var copy = self
    copy.insetAmount += amount
    return copy
  }
}

private struct MetalAvatarInnerFrameShape: Shape {
  func path(in rect: CGRect) -> Path {
    let corner = min(rect.width, rect.height) * 0.070
    return RoundedRectangle(cornerRadius: corner, style: .continuous).path(in: rect)
  }
}

private struct MetalAvatarIdentityPlateShape: Shape {
  func path(in rect: CGRect) -> Path {
    let cut = min(rect.width, rect.height) * 0.18
    var path = Path()

    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
    path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
    path.closeSubpath()

    return path
  }
}

private struct MetalAvatarQRPanelShape: Shape {
  func path(in rect: CGRect) -> Path {
    let cut = min(rect.width, rect.height) * 0.075
    var path = Path()

    path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cut))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
    path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
    path.closeSubpath()

    return path
  }
}

private struct MetalAvatarLevelBadgeShape: Shape {
  func path(in rect: CGRect) -> Path {
    let cut = min(rect.width, rect.height) * 0.24
    var path = Path()

    path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cut))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
    path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
    path.closeSubpath()

    return path
  }
}

#Preview {
  NavigationStack {
    MetalAvatarCardView()
  }
}
