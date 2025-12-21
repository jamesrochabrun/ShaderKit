//
//  CardFourView.swift
//  ShaderKitDemo
//
//  Premium holographic card with starburst rainbow effect
//  Inspired by special Pokemon cards with radial iridescent patterns
//

import SwiftUI
import ShaderKit

// MARK: - Pokemon Type

enum CardFourPokemonType: String {
  case electric, fire, water, grass, psychic, fighting, dark, steel, dragon, fairy, normal
  
  var primaryColor: Color {
    switch self {
    case .electric: return Color(red: 1.0, green: 0.85, blue: 0.2)
    case .fire: return .orange
    case .water: return .blue
    case .grass: return .green
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
    case .electric: return Color(red: 1.0, green: 0.7, blue: 0.0)
    case .fire: return .red
    case .water: return .cyan
    case .grass: return Color(red: 0.2, green: 0.5, blue: 0.2)
    case .psychic: return .pink
    case .fighting: return .brown
    case .dark: return .black
    case .steel: return Color(red: 0.7, green: 0.7, blue: 0.8)
    case .dragon: return .indigo
    case .fairy: return Color(red: 1, green: 0.7, blue: 0.8)
    case .normal: return .brown
    }
  }
  
  var icon: Image {
    switch self {
    case .electric: return Image(systemName: "bolt.fill")
    case .fire: return Image(systemName: "flame.fill")
    case .water: return Image(systemName: "drop.fill")
    case .grass: return Image(systemName: "leaf.fill")
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

// MARK: - Card Four View

struct CardFourView: View {
  private let cardWidth: CGFloat = 260
  private var cardHeight: CGFloat { cardWidth * 1.4 }
  
  var body: some View {
    HolographicCardContainer(
      width: cardWidth,
      height: cardHeight,
      shadowColor: .yellow,
      rotationMultiplier: 12
    ) {
      CardFourContent(
        name: "Pikachu",
        hp: 70,
        type: .electric,
        attackName: "Wild Charge",
        attackDamage: 90,
        attackDescription: "This Pokemon also does 30 damage to itself.",
        attackEnergyCost: [.electric, .electric, .normal],
        weaknessType: .fighting,
        retreatCost: 1,
        cardNumber: "160/159",
        illustrator: "You Iribi",
        flavorText: "Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy."
      )
      .starburst()
      .radialSweep()
      .multiGlitter()
    }
  }
}

// MARK: - Card Content

struct CardFourContent: View {
  let name: String
  let hp: Int
  let type: CardFourPokemonType
  let attackName: String
  let attackDamage: Int
  let attackDescription: String
  let attackEnergyCost: [CardFourPokemonType]
  let weaknessType: CardFourPokemonType
  let retreatCost: Int
  let cardNumber: String
  let illustrator: String
  let flavorText: String
  
  var body: some View {
    GeometryReader { geometry in
      let cardWidth = geometry.size.width
      let cardHeight = geometry.size.height
      
      ZStack {
        // Card background gradient
        LinearGradient(
          colors: [
            type.primaryColor,
            type.primaryColor.opacity(0.9),
            type.secondaryColor.opacity(0.7)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        
        // Background artwork
        Image("unicorn")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: cardWidth, height: cardHeight * 0.7)
          .clipped()
          .offset(y: -cardHeight * 0.05)
        
        // Content overlay
        VStack(spacing: 0) {
          // Header - Name and HP
          HStack(alignment: .top) {
            HStack(spacing: 6) {
              Text("BASIC")
                .font(.system(size: cardWidth * 0.03, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                  Capsule()
                    .fill(.black.opacity(0.6))
                )
              
              Text(name)
                .font(.system(size: cardWidth * 0.085, weight: .heavy))
                .foregroundStyle(.black)
                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: 1)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
              Text("HP")
                .font(.system(size: cardWidth * 0.04, weight: .medium))
              Text("\(hp)")
                .font(.system(size: cardWidth * 0.085, weight: .bold))
              type.icon
                .resizable()
                .frame(width: cardWidth * 0.08, height: cardWidth * 0.08)
            }
            .foregroundStyle(.black)
          }
          .padding(.horizontal, cardWidth * 0.04)
          .padding(.top, cardHeight * 0.025)
          
          Spacer()
          
          // Bottom panel with attack and stats
          VStack(spacing: 0) {
            // Attack section
            HStack(alignment: .top, spacing: 8) {
              // Energy cost icons
              HStack(spacing: 3) {
                ForEach(0..<attackEnergyCost.count, id: \.self) { index in
                  ZStack {
                    Circle()
                      .fill(attackEnergyCost[index].primaryColor)
                      .frame(width: cardWidth * 0.065, height: cardWidth * 0.065)
                    attackEnergyCost[index].icon
                      .resizable()
                      .frame(width: cardWidth * 0.04, height: cardWidth * 0.04)
                      .foregroundStyle(.white)
                  }
                }
              }
              
              VStack(alignment: .leading, spacing: 2) {
                Text(attackName)
                  .font(.system(size: cardWidth * 0.055, weight: .bold))
                  .foregroundStyle(.black)
                
                Text(attackDescription)
                  .font(.system(size: cardWidth * 0.03))
                  .foregroundStyle(.black.opacity(0.8))
                  .lineLimit(2)
              }
              
              Spacer()
              
              Text("\(attackDamage)")
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
            
            // Weakness, Resistance, Retreat
            HStack {
              // Weakness
              HStack(spacing: 4) {
                Text("weakness")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))
                
                ZStack {
                  Circle()
                    .fill(weaknessType.primaryColor)
                    .frame(width: cardWidth * 0.05, height: cardWidth * 0.05)
                  weaknessType.icon
                    .resizable()
                    .frame(width: cardWidth * 0.03, height: cardWidth * 0.03)
                    .foregroundStyle(.white)
                }
                
                Text("x2")
                  .font(.system(size: cardWidth * 0.035, weight: .bold))
                  .foregroundStyle(.black)
              }
              
              Spacer()
              
              // Resistance
              HStack(spacing: 4) {
                Text("resistance")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))
                Text("-")
                  .font(.system(size: cardWidth * 0.035))
                  .foregroundStyle(.black.opacity(0.5))
              }
              
              Spacer()
              
              // Retreat cost
              HStack(spacing: 4) {
                Text("retreat")
                  .font(.system(size: cardWidth * 0.028))
                  .foregroundStyle(.black.opacity(0.7))
                
                ForEach(0..<retreatCost, id: \.self) { _ in
                  Circle()
                    .fill(.white)
                    .stroke(.black.opacity(0.3), lineWidth: 1)
                    .frame(width: cardWidth * 0.04, height: cardWidth * 0.04)
                }
              }
            }
            .padding(.horizontal, cardWidth * 0.04)
            
            // Flavor text
            Text(flavorText)
              .font(.system(size: cardWidth * 0.028).italic())
              .foregroundStyle(.black.opacity(0.7))
              .multilineTextAlignment(.center)
              .lineLimit(2)
              .padding(.horizontal, cardWidth * 0.06)
              .padding(.top, cardHeight * 0.015)
            
            // Footer - illustrator and card number
            HStack {
              Text("Illus. \(illustrator)")
                .font(.system(size: cardWidth * 0.025))
              
              Spacer()
              
              Text(cardNumber)
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
                type.primaryColor.opacity(0.95),
                type.primaryColor
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
                type.primaryColor,
                .white.opacity(0.8),
                type.secondaryColor,
                .white.opacity(0.6),
                type.primaryColor
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

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    CardFourView()
  }
}
