//
//  GradientFoilView.swift
//  ShaderKitDemo
//
//  Holographic card with intense gradient shader effects
//

import SwiftUI
import ShaderKit

struct GradientFoilView: View {
  var body: some View {
    HolographicCardContainer(
      width: 280,
      height: 400,
      cornerRadius: 20,
      shadowColor: .orange
    ) {
      GradientFoilContent()
        .foil()
        .glitter()
        .lightSweep()
    }
  }
}

// MARK: - Card Content

private struct GradientFoilContent: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            colors: [
              .pink,
              .purple,
              .blue,
              .orange,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )

      // Artwork - full bleed background
      Image("unicorn")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 280, height: 400)
        .clipped()

      VStack(spacing: 12) {
        HStack {
          Text("Gradient Foil")
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
          Spacer()
          Text("LV 200")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 8) {
          HStack {
            Image(systemName: "paintpalette.fill")
              .foregroundStyle(.red)
            Text("Rainbow Gradient")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
            Spacer()
            Text("150")
              .font(.title3)
              .fontWeight(.black)
              .foregroundStyle(.orange)
          }

          Text("Multi-Color Holographic Effect")
            .font(.caption2)
            .foregroundStyle(.yellow.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
      }

      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: [.orange, .yellow, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 3
        )
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    GradientFoilView()
  }
}
