//
//  LayeredHoloView.swift
//  ShaderKitDemo
//
//  Split-layer holographic effect:
//  - Card background + stats → Full holo effect (rainbow, patterns, sparkles)
//  - Artwork image → Placed ON TOP with separate glare-only effect
//  - This gives clean artwork with subtle light reflection
//

import SwiftUI
import ShaderKit

// MARK: - Card Background

private struct LayeredHoloBackground: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    GeometryReader { geometry in
      let w = geometry.size.width
      let h = geometry.size.height

      ZStack {
        // Card background - golden style
        LinearGradient(
          colors: [
            Color(red: 0.92, green: 0.85, blue: 0.55),
            Color(red: 0.88, green: 0.8, blue: 0.45),
            Color(red: 0.85, green: 0.75, blue: 0.4)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        VStack(spacing: 0) {
          // Image placeholder area
          ZStack {
            Rectangle()
              .fill(
                LinearGradient(
                  colors: [
                    Color(red: 0.2, green: 0.35, blue: 0.35),
                    Color(red: 0.15, green: 0.25, blue: 0.3)
                  ],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
          }
          .frame(width: w * 0.92, height: h * 0.44)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(
                Color(red: 0.7, green: 0.6, blue: 0.3),
                lineWidth: 3
              )
          )
          .padding(.top, h * 0.03)

          // Info line
          Text("Layered Holographic Effect Demo")
            .font(.system(size: w * 0.025))
            .foregroundStyle(.black.opacity(0.6))
            .padding(.top, h * 0.01)

          // Stats area
          VStack(spacing: h * 0.012) {
            // Effect 1
            HStack(alignment: .top, spacing: 6) {
              HStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { _ in
                  Circle()
                    .fill(.white)
                    .stroke(.black.opacity(0.3), lineWidth: 1)
                    .frame(width: w * 0.055, height: w * 0.055)
                }
              }

              VStack(alignment: .leading, spacing: 2) {
                Text("Blended Holo")
                  .font(.system(size: w * 0.048, weight: .bold))
                  .foregroundStyle(.black)

                Text("Rainbow gradient blended with the card background for subtle iridescence")
                  .font(.system(size: w * 0.026))
                  .foregroundStyle(.black.opacity(0.75))
                  .lineLimit(2)
              }

              Spacer()

              Text("10x")
                .font(.system(size: w * 0.055, weight: .bold))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, w * 0.04)

            Rectangle()
              .fill(.black.opacity(0.15))
              .frame(height: 1)
              .padding(.horizontal, w * 0.04)

            // Effect 2
            HStack(alignment: .top, spacing: 6) {
              HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                  ZStack {
                    Circle()
                      .fill(i < 2 ? Color.gray.opacity(0.8) : .white)
                      .frame(width: w * 0.055, height: w * 0.055)
                    if i < 2 {
                      Circle()
                        .stroke(.black.opacity(0.5), lineWidth: 1)
                        .frame(width: w * 0.035, height: w * 0.035)
                    }
                  }
                }
                Circle()
                  .fill(.white)
                  .stroke(.black.opacity(0.3), lineWidth: 1)
                  .frame(width: w * 0.055, height: w * 0.055)
              }

              VStack(alignment: .leading, spacing: 2) {
                Text("Sparkle Layer")
                  .font(.system(size: w * 0.048, weight: .bold))
                  .foregroundStyle(.black)

                Text("Animated sparkles visible behind clean artwork layer for depth effect")
                  .font(.system(size: w * 0.024))
                  .foregroundStyle(.black.opacity(0.75))
                  .lineLimit(3)
              }

              Spacer()

              Text("180")
                .font(.system(size: w * 0.055, weight: .bold))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, w * 0.04)

            Rectangle()
              .fill(.black.opacity(0.15))
              .frame(height: 1)
              .padding(.horizontal, w * 0.04)

            // Stats
            HStack {
              HStack(spacing: 3) {
                Text("intensity")
                  .font(.system(size: w * 0.022))
                  .foregroundStyle(.black.opacity(0.6))

                ZStack {
                  Circle()
                    .fill(Color.green)
                    .frame(width: w * 0.04, height: w * 0.04)
                  Image(systemName: "wand.and.stars")
                    .font(.system(size: w * 0.022))
                    .foregroundStyle(.white)
                }

                Text("x2")
                  .font(.system(size: w * 0.026, weight: .bold))
                  .foregroundStyle(.black)
              }

              Spacer()

              HStack(spacing: 3) {
                Text("blend")
                  .font(.system(size: w * 0.022))
                  .foregroundStyle(.black.opacity(0.6))
                Text("-")
                  .font(.system(size: w * 0.026))
                  .foregroundStyle(.black.opacity(0.4))
              }

              Spacer()

              HStack(spacing: 3) {
                Text("layers")
                  .font(.system(size: w * 0.022))
                  .foregroundStyle(.black.opacity(0.6))

                ForEach(0..<3, id: \.self) { _ in
                  Circle()
                    .fill(.white)
                    .stroke(.black.opacity(0.3), lineWidth: 1)
                    .frame(width: w * 0.028, height: w * 0.028)
                }
              }
            }
            .padding(.horizontal, w * 0.04)

            Text("Split-layer technique keeps artwork crisp while background shimmers with holographic effects.")
              .font(.system(size: w * 0.022).italic())
              .foregroundStyle(.black.opacity(0.55))
              .multilineTextAlignment(.center)
              .lineLimit(2)
              .padding(.horizontal, w * 0.05)

            HStack {
              Text("ShaderKit Demo")
                .font(.system(size: w * 0.02))

              Spacer()

              HStack(spacing: 4) {
                Image(systemName: "square.3.layers.3d")
                  .font(.system(size: w * 0.025))
                Text("003/100")
                  .font(.system(size: w * 0.02, weight: .bold))
                Image(systemName: "star.fill")
                  .font(.system(size: w * 0.018))
              }
            }
            .foregroundStyle(.black.opacity(0.45))
            .padding(.horizontal, w * 0.04)
            .padding(.bottom, h * 0.015)
          }
          .padding(.top, h * 0.01)
        }

        // Card border
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color(red: 0.75, green: 0.65, blue: 0.3),
                Color(red: 0.9, green: 0.85, blue: 0.5),
                Color(red: 0.75, green: 0.65, blue: 0.3)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 5
          )
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .frame(width: width, height: height)
  }
}

// MARK: - Sparkle Container

private struct LayeredHoloSparkleContainer: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(
          colors: [
            Color(red: 0.2, green: 0.35, blue: 0.35),
            Color(red: 0.15, green: 0.25, blue: 0.3)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .frame(width: width * 0.88, height: height * 0.41)
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .verticalBeams()
  }
}

// MARK: - Artwork Layer

private struct LayeredHoloArtwork: View {
  let width: CGFloat
  let height: CGFloat

  var body: some View {
    Image("unicorn")
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: width * 0.88, height: height * 0.41)
      .clipShape(RoundedRectangle(cornerRadius: 6))
  }
}

// MARK: - Layered Holo View

struct LayeredHoloView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .yellow,
      rotationMultiplier: 12
    ) {
      ZStack {
        // Layer 1: Card background with holo effect
        LayeredHoloBackground(width: cardWidth, height: cardHeight)
          .blendedHolo(intensity: 0.7, saturation: 0.75)

        // Layer 2: Sparkle container
        LayeredHoloSparkleContainer(
          width: cardWidth,
          height: cardHeight
        )
        .offset(y: -cardHeight * 0.198)

        // Layer 3: Image on top (clean)
        LayeredHoloArtwork(
          width: cardWidth,
          height: cardHeight
        )
        .offset(y: -cardHeight * 0.198)
      }
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    LayeredHoloView()
  }
}
