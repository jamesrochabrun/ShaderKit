//
//  SpecialShadersDemo.swift
//  ShaderKitDemo
//
//  Pokemon-style holographic card effects with Metal shaders
//

import SwiftUI
import ShaderKit

enum SpecialShaderType: String, CaseIterable, Identifiable {
    case basicGlare = "Basic Glare"
    case regularHolo = "Regular Holo"
    case reverseHolo = "Reverse Holo"
    case cosmosHolo = "Cosmos Holo"
    case rainbowRare = "Rainbow Rare"
    case shinyRare = "Shiny Rare"
    case pokemonV = "Pokemon V"
    case vMax = "VMax"
    case vStar = "VStar"
    case secretGold = "Secret Gold"
    case radiantHolo = "Radiant Holo"
    case amazingRare = "Amazing Rare"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .basicGlare:
            return "Simple radial glare following tilt position"
        case .regularHolo:
            return "Rainbow vertical beams that shift with tilt"
        case .reverseHolo:
            return "Inverted foil effect with shine overlay"
        case .cosmosHolo:
            return "Galaxy background with rainbow gradient"
        case .rainbowRare:
            return "Glittery rainbow with luminosity blending"
        case .shinyRare:
            return "Metallic sun-pillar effect with crosshatch"
        case .pokemonV:
            return "Diagonal holographic lines creating depth"
        case .vMax:
            return "Large-scale subtle gradient with texture"
        case .vStar:
            return "V effect with radial mask fade"
        case .secretGold:
            return "Shimmering gold glitter overlay"
        case .radiantHolo:
            return "Criss-cross diamond pattern"
        case .amazingRare:
            return "Glittery metallic shimmer effect"
        }
    }

    var icon: String {
        switch self {
        case .basicGlare: return "sun.max.fill"
        case .regularHolo: return "rainbow"
        case .reverseHolo: return "rectangle.on.rectangle.angled"
        case .cosmosHolo: return "sparkles"
        case .rainbowRare: return "star.fill"
        case .shinyRare: return "diamond.fill"
        case .pokemonV: return "v.circle.fill"
        case .vMax: return "crown.fill"
        case .vStar: return "star.circle.fill"
        case .secretGold: return "dollarsign.circle.fill"
        case .radiantHolo: return "rays"
        case .amazingRare: return "wand.and.stars"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .basicGlare:
            BasicGlareView()
        case .regularHolo:
            RegularHoloView()
        case .reverseHolo:
            ReverseHoloView()
        case .cosmosHolo:
            CosmosHoloView()
        case .rainbowRare:
            RainbowRareView()
        case .shinyRare:
            ShinyRareView()
        case .pokemonV:
            PokemonVView()
        case .vMax:
            VMaxView()
        case .vStar:
            VStarView()
        case .secretGold:
            SecretGoldView()
        case .radiantHolo:
            RadiantHoloView()
        case .amazingRare:
            AmazingRareView()
        }
    }
}

struct SpecialShadersDemo: View {
    var body: some View {
        List(SpecialShaderType.allCases) { shaderType in
            NavigationLink(destination: shaderType.destination) {
                HStack(spacing: 16) {
                    Image(systemName: shaderType.icon)
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(shaderType.rawValue)
                            .font(.headline)
                        Text(shaderType.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Special Shaders")
    }
}

#Preview {
    NavigationStack {
        SpecialShadersDemo()
    }
}
