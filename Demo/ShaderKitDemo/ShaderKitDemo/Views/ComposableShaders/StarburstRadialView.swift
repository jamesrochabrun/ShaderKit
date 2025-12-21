//
//  StarburstRadialView.swift
//  ShaderKitDemo
//
//  Premium holographic card with starburst rainbow effect
//

import SwiftUI
import ShaderKit

// MARK: - Card Content

private struct StarburstRadialContent: View {
  var body: some View {
    GeometryReader { geometry in
      let cardWidth = geometry.size.width
      let cardHeight = geometry.size.height

      ZStack {
        // Card background gradient with starburst
        LinearGradient(
          colors: [
            Color(red: 1.0, green: 0.85, blue: 0.2),
            Color(red: 1.0, green: 0.85, blue: 0.2).opacity(0.9),
            Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.7)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .starburst()

        // Background artwork
        Image("unicorn")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: cardWidth, height: cardHeight * 0.7)
          .clipped()
          .offset(y: -cardHeight * 0.05)

        // Content overlay
        VStack(spacing: 0) {
          // Header
          HStack(alignment: .top) {
            HStack(spacing: 6) {
              Text("RADIAL")
                .font(.system(size: cardWidth * 0.03, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                  Capsule()
                    .fill(.black.opacity(0.6))
                )

              Text("Starburst")
                .font(.system(size: cardWidth * 0.085, weight: .heavy))
                .foregroundStyle(.black)
                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
            }

            Spacer()

            HStack(spacing: 4) {
              Text("LV")
                .font(.system(size: cardWidth * 0.04, weight: .medium))
              Text("70")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
              Image(systemName: "bolt.fill")
                .font(.system(size: cardWidth * 0.07))
                .foregroundStyle(.orange)
            }
            .foregroundStyle(.black)
          }
          .padding(.horizontal, cardWidth * 0.04)
          .padding(.top, cardHeight * 0.025)

          Spacer()

          // Bottom panel
          VStack(spacing: 0) {
            // Effect section
            HStack(alignment: .top, spacing: 8) {
              // Cost icons
              HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                  ZStack {
                    Circle()
                      .fill(index < 2 ? Color.yellow : Color.gray.opacity(0.5))
                      .frame(width: cardWidth * 0.065, height: cardWidth * 0.065)
                    Image(systemName: index < 2 ? "bolt.fill" : "star.fill")
                      .font(.system(size: cardWidth * 0.035))
                      .foregroundStyle(.white)
                  }
                }
              }

              VStack(alignment: .leading, spacing: 2) {
                Text("Radial Sweep")
                  .font(.system(size: cardWidth * 0.055, weight: .bold))
                  .foregroundStyle(.black)

                Text("Sweeping light effect emanating from center")
                  .font(.system(size: cardWidth * 0.03))
                  .foregroundStyle(.black.opacity(0.8))
                  .lineLimit(2)
              }

              Spacer()

              Text("90")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, cardWidth * 0.04)
            .padding(.vertical, cardHeight * 0.02)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.85))
            )
            .padding(.horizontal, cardWidth * 0.03)

            // Divider
            Rectangle()
              .fill(.black.opacity(0.3))
              .frame(height: 1)
              .padding(.horizontal, cardWidth * 0.04)
              .padding(.vertical, cardHeight * 0.015)

            // Stats
            HStack {
              HStack(spacing: 4) {
                Text("intensity")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))

                ZStack {
                  Circle()
                    .fill(.red)
                    .frame(width: cardWidth * 0.05, height: cardWidth * 0.05)
                  Image(systemName: "wand.and.stars")
                    .font(.system(size: cardWidth * 0.025))
                    .foregroundStyle(.white)
                }

                Text("x2")
                  .font(.system(size: cardWidth * 0.035, weight: .bold))
                  .foregroundStyle(.black)
              }

              Spacer()

              HStack(spacing: 4) {
                Text("blend")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))
                Text("-")
                  .font(.system(size: cardWidth * 0.035))
                  .foregroundStyle(.black.opacity(0.5))
              }

              Spacer()

              HStack(spacing: 4) {
                Text("layers")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))

                Circle()
                  .fill(.white)
                  .stroke(.black.opacity(0.3), lineWidth: 1)
                  .frame(width: cardWidth * 0.04, height: cardWidth * 0.04)
              }
            }
            .padding(.horizontal, cardWidth * 0.04)

            // Description
            Text("Radial starburst patterns create dynamic iridescent effects that shift as the card tilts.")
              .font(.system(size: cardWidth * 0.028).italic())
              .foregroundStyle(.black.opacity(0.7))
              .multilineTextAlignment(.center)
              .lineLimit(2)
              .padding(.horizontal, cardWidth * 0.06)
              .padding(.top, cardHeight * 0.015)

            // Footer
            HStack {
              Text("ShaderKit Demo")
                .font(.system(size: cardWidth * 0.025))

              Spacer()

              Text("001/100")
                .font(.system(size: cardWidth * 0.025, weight: .bold))
            }
            .foregroundStyle(.black.opacity(0.6))
            .padding(.horizontal, cardWidth * 0.04)
            .padding(.top, cardHeight * 0.01)
            .padding(.bottom, cardHeight * 0.02)
          }
          .background(
            LinearGradient(
              colors: [
                Color(red: 1.0, green: 0.85, blue: 0.2).opacity(0.95),
                Color(red: 1.0, green: 0.85, blue: 0.2)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
        }

        // Card border
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color(red: 1.0, green: 0.85, blue: 0.2),
                .white.opacity(0.8),
                Color(red: 1.0, green: 0.7, blue: 0.0),
                .white.opacity(0.6),
                Color(red: 1.0, green: 0.85, blue: 0.2)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 5
          )
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

// MARK: - Starburst Radial View

struct StarburstRadialView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .yellow,
      rotationMultiplier: 12
    ) {
      StarburstRadialContent()
        .radialSweep()
        .multiGlitter()
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    StarburstRadialView()
  }
}
