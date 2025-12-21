//
//  CardTwoView.swift
//  ShaderKitDemo
//
//  Butterfly holographic card with intense shader effects
//

import SwiftUI
import ShaderKit

struct CardTwoView: View {
    var body: some View {
        HolographicCardContainer(
            width: 280,
            height: 400,
            cornerRadius: 20,
            shadowColor: .orange
        ) {
            CardTwoContent()
                .foil()
                .glitter()
                .lightSweep()
        }
    }
}

// MARK: - Card Content

private struct CardTwoContent: View {
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

            // Butterfly artwork - full bleed background
            Image("butterfly")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 280, height: 400)
                .clipped()

            VStack(spacing: 12) {
                HStack {
                    Text("Ultra Rare")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("HP 200")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "flame.circle.fill")
                            .foregroundStyle(.red)
                        Text("Inferno Strike")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("150")
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundStyle(.orange)
                    }

                    Text("Secret Rare Holographic")
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
        CardTwoView()
    }
}
