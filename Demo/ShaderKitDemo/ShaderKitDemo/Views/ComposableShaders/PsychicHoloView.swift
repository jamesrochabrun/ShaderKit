//
//  PsychicHoloView.swift
//  ShaderKitDemo
//
//  Holographic card with foil, glitter, and light sweep effects
//

import SwiftUI
import ShaderKit

// MARK: - Card Content

private struct PsychicHoloContent: View {
  var body: some View {
    GeometryReader { geometry in
      let cardWidth = geometry.size.width
      let cardHeight = geometry.size.height

      ZStack {
        // Card background gradient
        LinearGradient(
          colors: [.purple, .pink, .purple.opacity(0.8)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        // Background image
        Image("unicorn")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: cardWidth, height: cardHeight)
          .clipped()

        // Gradient overlays for readability
        VStack(spacing: 0) {
          LinearGradient(
            colors: [
              .purple.opacity(0.9),
              .purple.opacity(0.7),
              .clear
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: cardHeight * 0.18)

          Spacer()

          LinearGradient(
            colors: [
              .clear,
              .black.opacity(0.6),
              .black.opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: cardHeight * 0.45)
        }

        // Card content overlay
        VStack(spacing: 0) {
          // Header
          HStack {
            Text("Psychic Holo")
              .font(.system(size: cardWidth * 0.08, weight: .bold))
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

            Spacer()

            HStack(spacing: 4) {
              Text("LV")
                .font(.system(size: cardWidth * 0.04, weight: .medium))
              Text("100")
                .font(.system(size: cardWidth * 0.08, weight: .bold))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

            Image(systemName: "sparkles")
              .font(.system(size: cardWidth * 0.08))
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
          }
          .padding(.horizontal, cardWidth * 0.05)
          .padding(.top, cardHeight * 0.03)

          // Tag
          HStack {
            Text("HOLO")
              .font(.system(size: cardWidth * 0.03, weight: .semibold))
              .foregroundStyle(.white)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .background(Capsule().fill(.black.opacity(0.4)))

            Spacer()

            Image(systemName: "star.fill")
              .font(.system(size: cardWidth * 0.05))
              .foregroundStyle(.yellow)
              .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
          }
          .padding(.horizontal, cardWidth * 0.05)
          .padding(.top, 6)

          Spacer()

          // Bottom info panel
          VStack(spacing: cardHeight * 0.015) {
            VStack(spacing: cardHeight * 0.012) {
              // Effect row 1
              HStack(alignment: .top, spacing: 8) {
                HStack(spacing: 2) {
                  Circle()
                    .fill(.purple)
                    .frame(width: cardWidth * 0.06, height: cardWidth * 0.06)
                }
                .frame(width: cardWidth * 0.15, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                  Text("Foil Effect")
                    .font(.system(size: cardWidth * 0.045, weight: .bold))
                  Text("Rainbow iridescent overlay")
                    .font(.system(size: cardWidth * 0.03))
                    .foregroundStyle(.white.opacity(0.8))
                }
                .foregroundStyle(.white)

                Spacer()

                Text("30")
                  .font(.system(size: cardWidth * 0.06, weight: .bold))
                  .foregroundStyle(.white)
              }
              .padding(.horizontal, cardWidth * 0.05)

              Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, cardWidth * 0.04)

              // Effect row 2
              HStack(alignment: .top, spacing: 8) {
                HStack(spacing: 2) {
                  Circle()
                    .fill(.purple)
                    .frame(width: cardWidth * 0.06, height: cardWidth * 0.06)
                  Circle()
                    .fill(.pink)
                    .frame(width: cardWidth * 0.06, height: cardWidth * 0.06)
                  Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: cardWidth * 0.06, height: cardWidth * 0.06)
                }
                .frame(width: cardWidth * 0.15, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                  Text("Glitter Burst")
                    .font(.system(size: cardWidth * 0.045, weight: .bold))
                  Text("Sparkling particles across the surface")
                    .font(.system(size: cardWidth * 0.03))
                    .foregroundStyle(.white.opacity(0.8))
                }
                .foregroundStyle(.white)

                Spacer()

                Text("100")
                  .font(.system(size: cardWidth * 0.06, weight: .bold))
                  .foregroundStyle(.white)
              }
              .padding(.horizontal, cardWidth * 0.05)
            }

            // Bottom stats
            HStack {
              VStack(spacing: 2) {
                Text("intensity")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 2) {
                  Image(systemName: "wand.and.stars")
                    .font(.system(size: cardWidth * 0.04))
                  Text("+20")
                    .font(.system(size: cardWidth * 0.03, weight: .bold))
                }
                .foregroundStyle(.white)
              }

              Spacer()

              VStack(spacing: 2) {
                Text("blend")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 2) {
                  Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: cardWidth * 0.04))
                  Text("-20")
                    .font(.system(size: cardWidth * 0.03, weight: .bold))
                }
                .foregroundStyle(.white)
              }

              Spacer()

              VStack(spacing: 2) {
                Text("layers")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 2) {
                  ForEach(0..<2, id: \.self) { _ in
                    Circle()
                      .fill(.white)
                      .frame(width: cardWidth * 0.04, height: cardWidth * 0.04)
                  }
                }
              }
            }
            .padding(.horizontal, cardWidth * 0.06)
            .padding(.top, cardHeight * 0.01)
          }
          .padding(.bottom, cardHeight * 0.03)
        }

        // Card border
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [
                .white.opacity(0.6),
                .purple.opacity(0.8),
                .white.opacity(0.3)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 3
          )
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

// MARK: - Psychic Holo View

struct PsychicHoloView: View {
  private let cardWidth: CGFloat = 280
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .purple
    ) {
      PsychicHoloContent()
        .foil()
        .glitter()
        .lightSweep()
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    PsychicHoloView()
  }
}
