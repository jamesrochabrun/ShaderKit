//
//  ExplodableCardDemo.swift
//  ShaderKitDemo
//
//  Interactive card viewer with layer decomposition animation.
//  Tap to toggle between flat view and exploded isometric layer view.
//

import SwiftUI
import ShaderKit

struct ExplodableCardDemo: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      ScrollView {
        VStack(spacing: 24) {
          Text("Layer Decomposition")
            .font(.headline)
            .foregroundStyle(.white.opacity(0.7))

          ExplodableHolographicCard(
            width: cardWidth,
            height: cardHeight,
            cornerRadius: 20,
            shadowColor: .orange,
            rotationMultiplier: 12,
            layerSpacing: 60,
            showLabels: true,
            showControls: true
          ) {
            // Layer 0: Gradient background
            CardLayer {
              ZStack {
                RoundedRectangle(cornerRadius: 20)
                  .fill(
                    LinearGradient(
                      colors: [.pink, .purple, .blue, .orange],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )

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
            .label("Gradient Background")
            .zIndex(0)

            // Layer 1: Artwork & text
            CardLayer {
              ZStack {
                Color.clear

                Image("unicorn")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: cardWidth, height: cardHeight)
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
              }
            }
            .label("Artwork & Text")
            .zIndex(1)

            // Layer 2: Foil & glitter overlay
            CardLayer {
              RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
            }
            .effects([.foil(), .glitter()])
            .label("Foil & Glitter")
            .zIndex(2)

            // Layer 3: Light sweep overlay
            CardLayer {
              RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
            }
            .effects([.lightSweep])
            .label("Light Sweep")
            .zIndex(3)
          }

          VStack(spacing: 4) {
            Text("Tap to toggle layers")
              .font(.caption)
              .foregroundStyle(.white.opacity(0.5))

            Text("Drag to tilt")
              .font(.caption2)
              .foregroundStyle(.white.opacity(0.35))
          }
        }
        .padding(.vertical, 40)
      }
    }
  }
}

#Preview {
  ExplodableCardDemo()
}
