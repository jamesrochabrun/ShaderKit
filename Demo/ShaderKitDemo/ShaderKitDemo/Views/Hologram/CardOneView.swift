//
//  CardOneView.swift
//  ShaderKitDemo
//
//  Dragon holographic card with foil, glitter, and sweep effects
//

import SwiftUI
import ShaderKit

struct CardOneView: View {
    var body: some View {
        HolographicCardContainer(
            width: 260,
            height: 380,
            shadowColor: .orange,
            rotationMultiplier: 12
        ) {
            CardOneContent()
                .foil()
                .glitter()
                .lightSweep()
        }
    }
}

// MARK: - Card Content

private struct CardOneContent: View {
    var body: some View {
        ZStack {
            // Card background - golden/yellow Pokemon card style
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

            // Dragon artwork - full bleed background
            Image("dragon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 260, height: 380)
                .clipped()

            VStack(spacing: 0) {
                // Header: Name + HP
                HStack(alignment: .top) {
                    HStack(spacing: 4) {
                        Text("STAGE 2")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.7))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                        Text("Charizard")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        Text("HP")
                            .font(.system(size: 12, weight: .medium))
                        Text("180")
                            .font(.system(size: 20, weight: .bold))
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange)
                    }
                    .foregroundStyle(.red)
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)

                // Pokemon info line
                Text("NO.006  Charizard  HT: 5'7\"  WT: 200 lbs")
                    .font(.system(size: 8))
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.top, 4)

                Spacer()

                // Ability section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Ability")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text("Blazing Aura")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    Text("Once during your turn, you may attach a Fire Energy from your discard pile to this Pokemon.")
                        .font(.system(size: 9))
                        .foregroundStyle(.black.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)

                // Attack section
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray.opacity(0.5))
                    }

                    Text("Fire Blast")
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

                // Footer: Weakness, Resistance, Retreat
                HStack {
                    HStack(spacing: 4) {
                        Text("weakness")
                            .font(.system(size: 8))
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.blue)
                        Text("x2")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("resistance")
                            .font(.system(size: 8))
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                        Text("-30")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("retreat")
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

                // Flavor text
                Text("It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.")
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
        CardOneView()
    }
}
