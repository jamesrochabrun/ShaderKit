//
//  CardThreeView.swift
//  ShaderKitDemo
//
//  Unicorn holographic card with foil, glitter, and light sweep effects
//

import SwiftUI
import ShaderKit

// MARK: - Pokemon Card Content

struct CardThreeContent: View {
  let name: String
  let hp: Int
  let type: CardThreePokemonType
  let attack1: CardThreeAttack
  let attack2: CardThreeAttack
  let weakness: CardThreePokemonType
  let resistance: CardThreePokemonType?
  let retreatCost: Int
  let rarity: CardThreeRarity

  var body: some View {
    GeometryReader { geometry in
      let cardWidth = geometry.size.width
      let cardHeight = geometry.size.height

      ZStack {
        // Card background with type gradient
        type.gradient

        // Pokemon image as background
        Image("uni")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: cardWidth, height: cardHeight)
          .clipped()

        // Gradient overlays for readability
        VStack(spacing: 0) {
          LinearGradient(
            colors: [
              type.primaryColor.opacity(0.9),
              type.primaryColor.opacity(0.7),
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
          // Header with name and HP
          HStack {
            Text(name)
              .font(.system(size: cardWidth * 0.08, weight: .bold))
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

            Spacer()

            HStack(spacing: 4) {
              Text("HP")
                .font(.system(size: cardWidth * 0.04, weight: .medium))
              Text("\(hp)")
                .font(.system(size: cardWidth * 0.08, weight: .bold))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

            type.icon
              .resizable()
              .frame(width: cardWidth * 0.09, height: cardWidth * 0.09)
              .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
          }
          .padding(.horizontal, cardWidth * 0.05)
          .padding(.top, cardHeight * 0.03)

          // Stage indicator
          HStack {
            Text("BASIC")
              .font(.system(size: cardWidth * 0.03, weight: .semibold))
              .foregroundStyle(.white)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .background(Capsule().fill(.black.opacity(0.4)))

            Spacer()

            rarity.symbol
              .font(.system(size: cardWidth * 0.05))
              .foregroundStyle(rarity.color)
              .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
          }
          .padding(.horizontal, cardWidth * 0.05)
          .padding(.top, 6)

          Spacer()

          // Bottom info panel
          VStack(spacing: cardHeight * 0.015) {
            VStack(spacing: cardHeight * 0.012) {
              CardThreeAttackRow(attack: attack1, cardWidth: cardWidth)

              Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, cardWidth * 0.04)

              CardThreeAttackRow(attack: attack2, cardWidth: cardWidth)
            }

            // Bottom stats
            HStack {
              VStack(spacing: 2) {
                Text("weakness")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 2) {
                  weakness.icon
                    .resizable()
                    .frame(width: cardWidth * 0.05, height: cardWidth * 0.05)
                  Text("+20")
                    .font(.system(size: cardWidth * 0.03, weight: .bold))
                }
                .foregroundStyle(.white)
              }

              Spacer()

              VStack(spacing: 2) {
                Text("resistance")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                if let resistance {
                  HStack(spacing: 2) {
                    resistance.icon
                      .resizable()
                      .frame(width: cardWidth * 0.05, height: cardWidth * 0.05)
                    Text("-20")
                      .font(.system(size: cardWidth * 0.03, weight: .bold))
                  }
                  .foregroundStyle(.white)
                } else {
                  Text("-")
                    .font(.system(size: cardWidth * 0.03))
                    .foregroundStyle(.white)
                }
              }

              Spacer()

              VStack(spacing: 2) {
                Text("retreat cost")
                  .font(.system(size: cardWidth * 0.025))
                  .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 2) {
                  ForEach(0..<retreatCost, id: \.self) { _ in
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
                type.primaryColor.opacity(0.8),
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

// MARK: - Attack Row

struct CardThreeAttackRow: View {
  let attack: CardThreeAttack
  let cardWidth: CGFloat

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      HStack(spacing: 2) {
        ForEach(0..<attack.energyCost.count, id: \.self) { index in
          attack.energyCost[index].icon
            .resizable()
            .frame(width: cardWidth * 0.06, height: cardWidth * 0.06)
        }
      }
      .frame(width: cardWidth * 0.15, alignment: .leading)

      VStack(alignment: .leading, spacing: 2) {
        Text(attack.name)
          .font(.system(size: cardWidth * 0.045, weight: .bold))
        if let description = attack.description {
          Text(description)
            .font(.system(size: cardWidth * 0.03))
            .foregroundStyle(.white.opacity(0.8))
        }
      }
      .foregroundStyle(.white)

      Spacer()

      Text("\(attack.damage)")
        .font(.system(size: cardWidth * 0.06, weight: .bold))
        .foregroundStyle(.white)
    }
    .padding(.horizontal, cardWidth * 0.05)
  }
}

// MARK: - Supporting Types

enum CardThreePokemonType: String, CaseIterable {
  case fire, water, grass, electric, psychic, fighting, dark, steel, dragon, fairy, normal

  var primaryColor: Color {
    switch self {
    case .fire: return .orange
    case .water: return .blue
    case .grass: return .green
    case .electric: return .yellow
    case .psychic: return .purple
    case .fighting: return .red
    case .dark: return Color(red: 0.3, green: 0.2, blue: 0.3)
    case .steel: return .gray
    case .dragon: return Color(red: 0.4, green: 0.3, blue: 0.8)
    case .fairy: return .pink
    case .normal: return Color(red: 0.6, green: 0.6, blue: 0.5)
    }
  }

  var secondaryColor: Color {
    switch self {
    case .fire: return .red
    case .water: return .cyan
    case .grass: return Color(red: 0.2, green: 0.5, blue: 0.2)
    case .electric: return .orange
    case .psychic: return .pink
    case .fighting: return .brown
    case .dark: return .black
    case .steel: return Color(red: 0.7, green: 0.7, blue: 0.8)
    case .dragon: return .indigo
    case .fairy: return Color(red: 1, green: 0.7, blue: 0.8)
    case .normal: return .brown
    }
  }

  var gradient: LinearGradient {
    LinearGradient(
      colors: [primaryColor, secondaryColor, primaryColor.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  var icon: Image {
    switch self {
    case .fire: return Image(systemName: "flame.fill")
    case .water: return Image(systemName: "drop.fill")
    case .grass: return Image(systemName: "leaf.fill")
    case .electric: return Image(systemName: "bolt.fill")
    case .psychic: return Image(systemName: "eye.fill")
    case .fighting: return Image(systemName: "figure.boxing")
    case .dark: return Image(systemName: "moon.fill")
    case .steel: return Image(systemName: "shield.fill")
    case .dragon: return Image(systemName: "hurricane")
    case .fairy: return Image(systemName: "sparkle")
    case .normal: return Image(systemName: "star.fill")
    }
  }
}

struct CardThreeAttack {
  let name: String
  let energyCost: [CardThreePokemonType]
  let damage: Int
  let description: String?
}

enum CardThreeRarity {
  case common, uncommon, rare, holoRare, ultraRare, secretRare

  var symbol: Image {
    switch self {
    case .common: return Image(systemName: "circle.fill")
    case .uncommon: return Image(systemName: "diamond.fill")
    case .rare: return Image(systemName: "star.fill")
    case .holoRare: return Image(systemName: "star.fill")
    case .ultraRare: return Image(systemName: "star.circle.fill")
    case .secretRare: return Image(systemName: "crown.fill")
    }
  }

  var color: Color {
    switch self {
    case .common: return .black
    case .uncommon: return .gray
    case .rare: return .yellow
    case .holoRare: return .yellow
    case .ultraRare: return .cyan
    case .secretRare: return .yellow
    }
  }
}

// MARK: - Card Three View

struct CardThreeView: View {
  private let cardWidth: CGFloat = 280
  private var cardHeight: CGFloat { cardWidth * 1.4 }

  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .purple
    ) { tilt, elapsedTime in
      CardThreeContent(
        name: "Starlight",
        hp: 120,
        type: .psychic,
        attack1: CardThreeAttack(
          name: "Cosmic Ray",
          energyCost: [.psychic],
          damage: 30,
          description: "Flip a coin. If heads, the Defending Pokemon is now Confused."
        ),
        attack2: CardThreeAttack(
          name: "Prismatic Burst",
          energyCost: [.psychic, .psychic, .normal],
          damage: 100,
          description: "Discard 2 Energy attached to this Pokemon."
        ),
        weakness: .dark,
        resistance: .fighting,
        retreatCost: 2,
        rarity: .holoRare
      )
      .cardThreeHolographicEffect(
        tilt: tilt,
        time: elapsedTime,
        intensity: 1.0
      )
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    CardThreeView()
  }
}
