//
//  MaskedFoilView.swift
//  ShaderKitDemo
//
//  Reverse Holo card effect:
//  - Foil on background/border areas
//  - Image window stays clean (artwork preserved)
//  - Glare clipped differently between image and foil areas
//

import SwiftUI
import ShaderKit

// MARK: - Card Content

private struct MaskedFoilContent: View {
  var body: some View {
    GeometryReader { geometry in
      let w = geometry.size.width
      let h = geometry.size.height

      ZStack {
        // Card background - golden style
        LinearGradient(
          colors: [
            Color(red: 0.95, green: 0.9, blue: 0.6),
            Color(red: 0.92, green: 0.85, blue: 0.5),
            Color(red: 0.88, green: 0.8, blue: 0.45)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .maskedFoil(imageWindow: imageWindow)
        .maskedSparkle(imageWindow: imageWindow)
        .foilTexture(imageWindow: imageWindow)

        VStack(spacing: 0) {
          // HEADER (Foil area)
          HStack(alignment: .top) {
            HStack(spacing: 4) {
              Text("MASKED")
                .font(.system(size: w * 0.028, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                  RoundedRectangle(cornerRadius: 3)
                    .fill(.black.opacity(0.7))
                )

              Text("Foil Card")
                .font(.system(size: w * 0.07, weight: .bold))
                .foregroundStyle(.black)
            }

            Spacer()

            HStack(spacing: 3) {
              Text("LV")
                .font(.system(size: w * 0.032, weight: .medium))
              Text("70")
                .font(.system(size: w * 0.065, weight: .bold))

              Image(systemName: "bolt.fill")
                .font(.system(size: w * 0.05))
                .foregroundStyle(.orange)
            }
            .foregroundStyle(.black)
          }
          .padding(.horizontal, w * 0.04)
          .padding(.top, h * 0.025)
          .padding(.bottom, h * 0.015)

          // IMAGE WINDOW
          ZStack {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.black.opacity(0.1))

            Image("unicorn")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: w * 0.88, height: h * 0.42)
              .clipShape(RoundedRectangle(cornerRadius: 6))

            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(
                LinearGradient(
                  colors: [
                    .white.opacity(0.6),
                    .black.opacity(0.2),
                    .white.opacity(0.4)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 2
              )
          }
          .frame(width: w * 0.92, height: h * 0.44)

          // STATS AREA (Foil area)
          Spacer()
            .frame(height: h * 0.015)

          VStack(spacing: h * 0.01) {
            HStack(alignment: .top, spacing: 8) {
              HStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { _ in
                  ZStack {
                    Circle()
                      .fill(Color.yellow)
                      .frame(width: w * 0.055, height: w * 0.055)
                    Image(systemName: "bolt.fill")
                      .font(.system(size: w * 0.032))
                      .foregroundStyle(.black)
                  }
                }
                ZStack {
                  Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: w * 0.055, height: w * 0.055)
                  Image(systemName: "star.fill")
                    .font(.system(size: w * 0.028))
                    .foregroundStyle(.white)
                }
              }

              VStack(alignment: .leading, spacing: 1) {
                Text("Masked Foil")
                  .font(.system(size: w * 0.045, weight: .bold))
                  .foregroundStyle(.black)

                Text("Foil effect applies only to card borders and stats area")
                  .font(.system(size: w * 0.025))
                  .foregroundStyle(.black.opacity(0.7))
                  .lineLimit(2)
              }

              Spacer()

              Text("90")
                .font(.system(size: w * 0.07, weight: .bold))
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
                    .fill(Color(red: 0.75, green: 0.35, blue: 0.25))
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

                Circle()
                  .fill(.white)
                  .stroke(.black.opacity(0.3), lineWidth: 1)
                  .frame(width: w * 0.03, height: w * 0.03)
              }
            }
            .padding(.horizontal, w * 0.04)

            Text("The masked foil effect preserves artwork clarity while adding iridescent shimmer to surrounding areas.")
              .font(.system(size: w * 0.022).italic())
              .foregroundStyle(.black.opacity(0.55))
              .multilineTextAlignment(.center)
              .lineLimit(2)
              .padding(.horizontal, w * 0.05)

            HStack {
              Text("ShaderKit Demo")
                .font(.system(size: w * 0.02))

              Spacer()

              Text("002/100")
                .font(.system(size: w * 0.02, weight: .bold))
            }
            .foregroundStyle(.black.opacity(0.45))
            .padding(.horizontal, w * 0.04)
            .padding(.bottom, h * 0.015)
          }
        }

        // Card border
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color(red: 0.8, green: 0.7, blue: 0.3),
                Color(red: 0.95, green: 0.9, blue: 0.5),
                Color(red: 0.8, green: 0.7, blue: 0.3)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 4
          )
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

// MARK: - Masked Foil View

struct MaskedFoilView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .yellow,
      rotationMultiplier: 12
    ) {
      MaskedFoilContent()
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    MaskedFoilView()
  }
}


// Image window bounds (UV space 0-1)
private let imageWindow = SIMD4<Float>(
  0.04,   // minX
  0.20,   // minY
  0.96,   // maxX
  0.64   // maxY
)
