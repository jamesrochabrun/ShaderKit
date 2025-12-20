//
//  CardFiveView.swift
//  ShaderKitDemo
//
//  Split-layer holographic effect:
//  - Card background + stats → Full holo effect (rainbow, patterns, sparkles)
//  - Artwork image → Placed ON TOP with separate glare-only effect
//  - This gives clean artwork with subtle light reflection
//

import SwiftUI
import ShaderKit

// MARK: - Card Background

struct CardFiveBackground: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height

            ZStack {
                // Card background - golden Pokemon card style
                LinearGradient(
                    colors: [
                        Color(red: 0.92, green: 0.85, blue: 0.55),
                        Color(red: 0.88, green: 0.8, blue: 0.45),
                        Color(red: 0.85, green: 0.75, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 0) {
                    // Image placeholder area
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.35, blue: 0.35),
                                        Color(red: 0.15, green: 0.25, blue: 0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: w * 0.92, height: h * 0.44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                Color(red: 0.7, green: 0.6, blue: 0.3),
                                lineWidth: 3
                            )
                    )
                    .padding(.top, h * 0.03)

                    // Pokemon info line
                    Text("NO. 248  Armor Pokemon  HT: 6'7\"  WT: 445.3 lbs.")
                        .font(.system(size: w * 0.025))
                        .foregroundStyle(.black.opacity(0.6))
                        .padding(.top, h * 0.01)

                    // Stats area
                    VStack(spacing: h * 0.012) {
                        // Attack 1
                        HStack(alignment: .top, spacing: 6) {
                            HStack(spacing: 2) {
                                ForEach(0..<2, id: \.self) { _ in
                                    Circle()
                                        .fill(.white)
                                        .stroke(.black.opacity(0.3), lineWidth: 1)
                                        .frame(width: w * 0.055, height: w * 0.055)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Raging Crash")
                                    .font(.system(size: w * 0.048, weight: .bold))
                                    .foregroundStyle(.black)

                                Text("This attack does 10 damage for each damage counter on all of your Benched Pokemon.")
                                    .font(.system(size: w * 0.026))
                                    .foregroundStyle(.black.opacity(0.75))
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text("10x")
                                .font(.system(size: w * 0.055, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, w * 0.04)

                        Rectangle()
                            .fill(.black.opacity(0.15))
                            .frame(height: 1)
                            .padding(.horizontal, w * 0.04)

                        // Attack 2
                        HStack(alignment: .top, spacing: 6) {
                            HStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { i in
                                    ZStack {
                                        Circle()
                                            .fill(i < 2 ? Color.gray.opacity(0.8) : .white)
                                            .frame(width: w * 0.055, height: w * 0.055)
                                        if i < 2 {
                                            Circle()
                                                .stroke(.black.opacity(0.5), lineWidth: 1)
                                                .frame(width: w * 0.035, height: w * 0.035)
                                        }
                                    }
                                }
                                Circle()
                                    .fill(.white)
                                    .stroke(.black.opacity(0.3), lineWidth: 1)
                                    .frame(width: w * 0.055, height: w * 0.055)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Earthquake")
                                    .font(.system(size: w * 0.048, weight: .bold))
                                    .foregroundStyle(.black)

                                Text("This attack also does 20 damage to each of your Benched Pokemon. (Don't apply Weakness and Resistance for Benched Pokemon.)")
                                    .font(.system(size: w * 0.024))
                                    .foregroundStyle(.black.opacity(0.75))
                                    .lineLimit(3)
                            }

                            Spacer()

                            Text("180")
                                .font(.system(size: w * 0.055, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, w * 0.04)

                        Rectangle()
                            .fill(.black.opacity(0.15))
                            .frame(height: 1)
                            .padding(.horizontal, w * 0.04)

                        // Weakness / Resistance / Retreat
                        HStack {
                            HStack(spacing: 3) {
                                Text("weakness")
                                    .font(.system(size: w * 0.022))
                                    .foregroundStyle(.black.opacity(0.6))

                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: w * 0.04, height: w * 0.04)
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: w * 0.022))
                                        .foregroundStyle(.white)
                                }

                                Text("x2")
                                    .font(.system(size: w * 0.026, weight: .bold))
                                    .foregroundStyle(.black)
                            }

                            Spacer()

                            HStack(spacing: 3) {
                                Text("resistance")
                                    .font(.system(size: w * 0.022))
                                    .foregroundStyle(.black.opacity(0.6))
                                Text("-")
                                    .font(.system(size: w * 0.026))
                                    .foregroundStyle(.black.opacity(0.4))
                            }

                            Spacer()

                            HStack(spacing: 3) {
                                Text("retreat")
                                    .font(.system(size: w * 0.022))
                                    .foregroundStyle(.black.opacity(0.6))

                                ForEach(0..<3, id: \.self) { _ in
                                    Circle()
                                        .fill(.white)
                                        .stroke(.black.opacity(0.3), lineWidth: 1)
                                        .frame(width: w * 0.028, height: w * 0.028)
                                }
                            }
                        }
                        .padding(.horizontal, w * 0.04)

                        Text("Its body can't be harmed by any sort of attack, so it is very eager to make challenges against enemies.")
                            .font(.system(size: w * 0.022).italic())
                            .foregroundStyle(.black.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, w * 0.05)

                        HStack {
                            Text("Illus. Nisota Niso")
                                .font(.system(size: w * 0.02))

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "f.circle.fill")
                                    .font(.system(size: w * 0.025))
                                Text("043/078")
                                    .font(.system(size: w * 0.02, weight: .bold))
                                Image(systemName: "star.fill")
                                    .font(.system(size: w * 0.018))
                            }
                        }
                        .foregroundStyle(.black.opacity(0.45))
                        .padding(.horizontal, w * 0.04)
                        .padding(.bottom, h * 0.015)
                    }
                    .padding(.top, h * 0.01)
                }

                // Card border
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.75, green: 0.65, blue: 0.3),
                                Color(red: 0.9, green: 0.85, blue: 0.5),
                                Color(red: 0.75, green: 0.65, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Sparkle Container

struct CardFiveSparkleContainer: View {
    let width: CGFloat
    let height: CGFloat
    let tilt: CGPoint
    let time: TimeInterval

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.35, blue: 0.35),
                        Color(red: 0.15, green: 0.25, blue: 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width * 0.88, height: height * 0.41)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .cardFiveImageSparkles(tilt: tilt, time: time)
    }
}

// MARK: - Artwork Layer

struct CardFiveArtwork: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image("lion")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width * 0.88, height: height * 0.41)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Card Five View

struct CardFiveView: View {
    private let cardWidth: CGFloat = 260
    private var cardHeight: CGFloat { cardWidth * 1.4 }

    var body: some View {
        HolographicCardContainer(
            width: cardWidth,
            height: cardHeight,
            shadowColor: .yellow,
            rotationMultiplier: 12
        ) { tilt, elapsedTime in
            ZStack {
                // Layer 1: Card background with holo effect
                CardFiveBackground(width: cardWidth, height: cardHeight)
                    .cardFiveBackgroundHolo(
                        tilt: tilt,
                        time: elapsedTime,
                        intensity: 0.7,
                        saturation: 0.75
                    )

                // Layer 2: Sparkle container
                CardFiveSparkleContainer(
                    width: cardWidth,
                    height: cardHeight,
                    tilt: tilt,
                    time: elapsedTime
                )
                .offset(y: -cardHeight * 0.198)

                // Layer 3: Image on top (clean)
                CardFiveArtwork(
                    width: cardWidth,
                    height: cardHeight
                )
                .offset(y: -cardHeight * 0.198)
            }
            .cardFiveSweep(tilt: tilt, time: elapsedTime)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CardFiveView()
    }
}
