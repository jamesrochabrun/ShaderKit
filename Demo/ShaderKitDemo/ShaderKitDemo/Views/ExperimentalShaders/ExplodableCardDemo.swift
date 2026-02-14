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
            cornerRadius: 16,
            shadowColor: .purple,
            rotationMultiplier: 12,
            layerSpacing: 60,
            showLabels: true,
            showControls: true
          ) {
            // Layer 0: Base card frame/background
            CardLayer {
              ZStack {
                RoundedRectangle(cornerRadius: 16)
                  .fill(
                    LinearGradient(
                      colors: [
                        Color(red: 0.12, green: 0.08, blue: 0.22),
                        Color(red: 0.18, green: 0.1, blue: 0.28),
                        Color(red: 0.1, green: 0.06, blue: 0.18)
                      ],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )

                // Card frame border
                RoundedRectangle(cornerRadius: 16)
                  .strokeBorder(
                    LinearGradient(
                      colors: [
                        Color.white.opacity(0.3),
                        Color.purple.opacity(0.2),
                        Color.white.opacity(0.1)
                      ],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                  )
              }
            }
            .label("Base Frame")
            .zIndex(0)

            // Layer 1: Card artwork
            CardLayer {
              ZStack {
                Color.clear

                VStack(spacing: 16) {
                  // Main artwork icon
                  Image(systemName: "flame.fill")
                    .font(.system(size: 72, weight: .regular))
                    .foregroundStyle(
                      LinearGradient(
                        colors: [.orange, .red, .purple],
                        startPoint: .top,
                        endPoint: .bottom
                      )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 20, y: 5)

                  VStack(spacing: 6) {
                    Text("PHOENIX")
                      .font(.system(size: 24, weight: .black, design: .rounded))
                      .foregroundStyle(.white)

                    Text("Legendary Card")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundStyle(.white.opacity(0.6))
                      .textCase(.uppercase)
                      .tracking(2)
                  }
                }
              }
            }
            .label("Artwork")
            .zIndex(1)

            // Layer 2: Holographic/foil overlay effect
            CardLayer {
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
            }
            .effects([.foil(intensity: 0.7), .diamondGrid(intensity: 0.4)])
            .label("Holographic Foil")
            .zIndex(2)

            // Layer 3: Specular reflection/shine layer
            CardLayer {
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
            }
            .effects([.glassSheen(intensity: 0.6, spread: 0.5), .simpleGlare(intensity: 0.5)])
            .label("Specular Shine")
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
