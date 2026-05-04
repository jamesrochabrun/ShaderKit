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
      let contentInset = cardWidth * 0.0275
      let innerWidth = cardWidth - contentInset * 2
      let innerHeight = cardHeight - contentInset * 2

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
        Image("ray")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: innerWidth, height: innerHeight * 0.7)
          .clipped()
          .offset(y: -innerHeight * 0.05)

        // Content overlay
        VStack(spacing: 0) {
          // Header
          HStack(alignment: .top) {
            Text("RAY FERNANDO")
              .font(.system(size: cardWidth * 0.085, weight: .heavy))
              .lineLimit(1)
              .minimumScaleFactor(0.55)
              .foregroundStyle(.black)
              .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)

            Spacer(minLength: 6)

            HStack(spacing: 4) {
              Text("HP")
                .font(.system(size: cardWidth * 0.04, weight: .medium))
              Text("1337")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
              Image(systemName: "bolt.fill")
                .font(.system(size: cardWidth * 0.07))
                .foregroundStyle(.orange)
            }
            .foregroundStyle(.black)
            .layoutPriority(1)
          }
          .padding(.horizontal, cardWidth * 0.04)
          .padding(.top, cardHeight * 0.025)

          Spacer()

          // Bottom panel
          VStack(spacing: 0) {
            // Effect section
            HStack(alignment: .top, spacing: 8) {
              Text("◆")
                .font(.system(size: cardWidth * 0.052, weight: .bold))
                .foregroundStyle(.black)

              VStack(alignment: .leading, spacing: 2) {
                Text("VIBE CODE OG")
                  .font(.system(size: cardWidth * 0.055, weight: .bold))
                  .foregroundStyle(.black)

                Text("Ships production code on livestream.\nBugs included. Audience: 30,000+")
                  .font(.system(size: cardWidth * 0.03))
                  .foregroundStyle(.black.opacity(0.8))
                  .lineLimit(2)
              }

              Spacer()

              Text("30+")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, cardWidth * 0.04)
            .padding(.vertical, cardHeight * 0.02)

            // Divider
            Rectangle()
              .fill(.black.opacity(0.3))
              .frame(height: 1)
              .padding(.horizontal, cardWidth * 0.04)
              .padding(.vertical, cardHeight * 0.015)

            // Second effect section
            HStack(alignment: .top, spacing: 8) {
              Text("◆◆")
                .font(.system(size: cardWidth * 0.052, weight: .bold))
                .foregroundStyle(.black)

              VStack(alignment: .leading, spacing: 2) {
                Text("SHIP IT")
                  .font(.system(size: cardWidth * 0.055, weight: .bold))
                  .foregroundStyle(.black)

                Text("Pushes to main on a Friday. Survives.")
                  .font(.system(size: cardWidth * 0.03))
                  .foregroundStyle(.black.opacity(0.8))
                  .lineLimit(2)
              }

              Spacer()

              Text("∞")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, cardWidth * 0.04)
            .padding(.vertical, cardHeight * 0.014)

            // Description
            Text("Drafted to the GPT-5.5 class of 5/5/26.\nAcceptance rate: 1.2%. Compaction works in mysterious ways.")
              .font(.system(size: cardWidth * 0.028).italic())
              .foregroundStyle(.black.opacity(0.7))
              .multilineTextAlignment(.center)
              .lineLimit(2)
              .padding(.horizontal, cardWidth * 0.06)
              .padding(.top, cardHeight * 0.015)

            // Footer
            HStack {
              Text("Illus. OpenAI")
                .font(.system(size: cardWidth * 0.025))

              Spacer()

              Text("5/55  ★  HOLO RARE")
                .font(.system(size: cardWidth * 0.025, weight: .bold))
            }
            .foregroundStyle(.black.opacity(0.6))
            .padding(.horizontal, cardWidth * 0.04)
            .padding(.top, cardHeight * 0.01)
            .padding(.bottom, cardHeight * 0.012)
          }
          .frame(maxWidth: .infinity)
          .background(
            polishedContentSectionBackground()
          )
          .offset(y: cardHeight * 0.014)
        }
        .frame(width: innerWidth, height: innerHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))

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

        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color(red: 0.02, green: 0.20, blue: 0.46),
                Color(red: 0.05, green: 0.34, blue: 0.76),
                Color(red: 0.01, green: 0.15, blue: 0.36)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 4
          )
          .frame(width: innerWidth, height: innerHeight)
      }
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }

  private func polishedContentSectionBackground() -> some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(
        LinearGradient(
          colors: [
            Color(red: 0.94, green: 0.95, blue: 0.96),
            Color(red: 0.78, green: 0.80, blue: 0.84),
            Color(red: 0.90, green: 0.91, blue: 0.94)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .shader(.polishedAluminum(intensity: 0.72))
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
