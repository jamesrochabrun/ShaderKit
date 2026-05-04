//
//  MetalAvatarCardView.swift
//  ShaderKitDemo
//
//  Premium metal avatar badge with cosmic aura accents.
//

import SwiftUI
import ShaderKit

struct MetalAvatarCardView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.30 }

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

      HolographicCardContainer(
        width: cardWidth,
        height: cardHeight,
        shadowColor: Color(red: 0.70, green: 0.88, blue: 1.0),
        rotationMultiplier: 9
      ) {
        MetalAvatarBadgeCard(avatarName: "ray")
      }
    }
    .navigationTitle("Metal Avatar Card")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
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
      Text("nic")
        .font(.system(size: width * 0.128, weight: .semibold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.78)
        .foregroundStyle(Color(red: 0.04, green: 0.13, blue: 0.44))

      Text("TOP 1%  •  ATTENDEE")
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
