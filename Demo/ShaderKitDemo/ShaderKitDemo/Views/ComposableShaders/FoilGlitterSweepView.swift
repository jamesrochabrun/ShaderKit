//
//  FoilGlitterSweepView.swift
//  ShaderKitDemo
//
//  Holographic card with foil, glitter, and sweep effects
//

import SwiftUI
import ShaderKit

struct FoilGlitterSweepView: View {
  var body: some View {
    HolographicCardContainer(
      width: 260,
      height: 380,
      shadowColor: .orange,
      rotationMultiplier: 12
    ) {
      FoilGlitterSweepContent()
        .foil()
        .glitter()
        .lightSweep()
    }
  }
}

// MARK: - Card Content

private struct FoilGlitterSweepContent: View {
  var body: some View {
    ZStack {
      // Card background - golden style
      RoundedRectangle(cornerRadius: 16)
        .fill(
          LinearGradient(
            colors: [
              Color(red: 0.95, green: 0.85, blue: 0.5),
              Color(red: 0.9, green: 0.75, blue: 0.4),
              Color(red: 0.85, green: 0.7, blue: 0.35),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )

      // Artwork - full bleed background
      Image("unicorn")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 260, height: 380)
        .clipped()

      VStack(spacing: 0) {
        // Header
        HStack(alignment: .top) {
          HStack(spacing: 4) {
            Text("COMBO")
              .font(.system(size: 9, weight: .bold))
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
              .background(.black.opacity(0.7))
              .foregroundStyle(.white)
              .clipShape(RoundedRectangle(cornerRadius: 3))

            Text("Triple Effect")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(.black)
          }

          Spacer()

          HStack(spacing: 2) {
            Text("LV")
              .font(.system(size: 12, weight: .medium))
            Text("180")
              .font(.system(size: 20, weight: .bold))
            Image(systemName: "sparkles")
              .font(.system(size: 14))
              .foregroundStyle(.orange)
          }
          .foregroundStyle(.black)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)

        // Info line
        Text("Foil + Glitter + Light Sweep Combined")
          .font(.system(size: 8))
          .foregroundStyle(.black.opacity(0.5))
          .padding(.top, 4)

        Spacer()

        // Effect section
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text("Effect")
              .font(.system(size: 10, weight: .bold))
              .foregroundStyle(.white)
              .padding(.horizontal, 8)
              .padding(.vertical, 3)
              .background(.orange)
              .clipShape(RoundedRectangle(cornerRadius: 4))

            Text("Foil Overlay")
              .font(.system(size: 14, weight: .bold))
              .foregroundStyle(.black)
          }
          Text("Rainbow iridescent layer that shifts color based on viewing angle and tilt position.")
            .font(.system(size: 9))
            .foregroundStyle(.black.opacity(0.8))
            .lineLimit(2)
        }
        .padding(.horizontal, 12)

        // Effect row
        HStack {
          HStack(spacing: 2) {
            Image(systemName: "sparkle")
              .font(.system(size: 12))
              .foregroundStyle(.orange)
            Image(systemName: "sparkle")
              .font(.system(size: 12))
              .foregroundStyle(.orange)
            Image(systemName: "circle.fill")
              .font(.system(size: 12))
              .foregroundStyle(.gray.opacity(0.5))
          }

          Text("Glitter Burst")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.black)
            .padding(.leading, 8)

          Spacer()

          Text("150")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.black)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)

        Divider()
          .padding(.horizontal, 12)
          .padding(.top, 8)

        // Stats
        HStack {
          HStack(spacing: 4) {
            Text("intensity")
              .font(.system(size: 8))
            Image(systemName: "wand.and.stars")
              .font(.system(size: 10))
              .foregroundStyle(.blue)
            Text("x2")
              .font(.system(size: 10, weight: .bold))
          }

          Spacer()

          HStack(spacing: 4) {
            Text("blend")
              .font(.system(size: 8))
            Image(systemName: "circle.hexagongrid.fill")
              .font(.system(size: 10))
              .foregroundStyle(.green)
            Text("-30")
              .font(.system(size: 10, weight: .bold))
          }

          Spacer()

          HStack(spacing: 4) {
            Text("layers")
              .font(.system(size: 8))
            Image(systemName: "circle.fill")
              .font(.system(size: 8))
              .foregroundStyle(.gray.opacity(0.5))
            Image(systemName: "circle.fill")
              .font(.system(size: 8))
              .foregroundStyle(.gray.opacity(0.5))
          }
        }
        .foregroundStyle(.black.opacity(0.7))
        .padding(.horizontal, 12)
        .padding(.top, 6)

        // Description
        Text("Combined foil, glitter and light sweep effects create a premium holographic appearance.")
          .font(.system(size: 8).italic())
          .foregroundStyle(.black.opacity(0.6))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 20)
          .padding(.vertical, 8)
      }

      // Card border
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(
          LinearGradient(
            colors: [
              .yellow.opacity(0.8),
              .orange.opacity(0.6),
              .yellow.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 4
        )
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    FoilGlitterSweepView()
  }
}
