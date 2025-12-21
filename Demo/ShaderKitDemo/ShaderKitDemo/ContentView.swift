//
//  ContentView.swift
//  ShaderKitDemo
//
//  Main navigation hub for ShaderKit demos
//

import SwiftUI

enum ShaderSection: String, CaseIterable {
  case basic = "Basic Shaders"
  case composable = "Composable Shaders"
}

enum ShaderType: String, CaseIterable, Identifiable {
  // Basic Shaders (11 items)
  case basicGlare = "Basic Glare"
  case verticalBeams = "Vertical Beams"
  case reverseHolo = "Reverse Holo"
  case cosmosHolo = "Cosmos Holo"
  case rainbowRare = "Rainbow Rare"
  case shinyRare = "Shiny Rare"
  case diagonalHolo = "Diagonal Holo"
  case vMax = "VMax"
  case vStar = "VStar"
  case radiantHolo = "Radiant Holo"
  case amazingRare = "Amazing Rare"

  // Composable Shaders (6 items)
  case foilGlitterSweep = "Foil + Glitter + Sweep"
  case gradientFoil = "Gradient Foil"
  case psychicHolo = "Psychic Holo"
  case starburstRadial = "Starburst Radial"
  case layeredHolo = "Layered Holo"
  case maskedFoil = "Masked Foil"

  var id: String { rawValue }

  var section: ShaderSection {
    switch self {
    case .basicGlare, .verticalBeams, .reverseHolo, .cosmosHolo,
        .rainbowRare, .shinyRare, .diagonalHolo, .vMax, .vStar,
        .radiantHolo, .amazingRare:
      return .basic
    case .foilGlitterSweep, .gradientFoil, .psychicHolo,
        .starburstRadial, .layeredHolo, .maskedFoil:
      return .composable
    }
  }

  var description: String {
    switch self {
    // Basic Shaders
    case .basicGlare:
      return "Simple radial glare following tilt position"
    case .verticalBeams:
      return "Rainbow vertical beams that shift with tilt"
    case .reverseHolo:
      return "Inverted foil effect with shine overlay"
    case .cosmosHolo:
      return "Galaxy background with rainbow gradient"
    case .rainbowRare:
      return "Glittery rainbow with luminosity blending"
    case .shinyRare:
      return "Metallic sun-pillar effect with crosshatch"
    case .diagonalHolo:
      return "Diagonal holographic lines creating depth"
    case .vMax:
      return "Large-scale subtle gradient with texture"
    case .vStar:
      return "V effect with radial mask fade"
    case .radiantHolo:
      return "Criss-cross diamond pattern"
    case .amazingRare:
      return "Glittery metallic shimmer effect"
    // Composable Shaders
    case .foilGlitterSweep:
      return "Combined foil, glitter, and light sweep"
    case .gradientFoil:
      return "Multi-color gradient with foil effects"
    case .psychicHolo:
      return "Psychic-type card with triple effects"
    case .starburstRadial:
      return "Starburst rainbow with radial sweep"
    case .layeredHolo:
      return "Split-layer holo with clean artwork"
    case .maskedFoil:
      return "Reverse holo with masked foil areas"
    }
  }

  var icon: String {
    switch self {
    // Basic Shaders
    case .basicGlare: return "sun.max.fill"
    case .verticalBeams: return "rainbow"
    case .reverseHolo: return "rectangle.on.rectangle.angled"
    case .cosmosHolo: return "sparkles"
    case .rainbowRare: return "star.fill"
    case .shinyRare: return "diamond.fill"
    case .diagonalHolo: return "line.diagonal"
    case .vMax: return "crown.fill"
    case .vStar: return "star.circle.fill"
    case .radiantHolo: return "rays"
    case .amazingRare: return "wand.and.stars"
    // Composable Shaders
    case .foilGlitterSweep: return "wand.and.sparkles"
    case .gradientFoil: return "paintpalette.fill"
    case .psychicHolo: return "eye.fill"
    case .starburstRadial: return "sun.max.trianglebadge.exclamationmark.fill"
    case .layeredHolo: return "square.3.layers.3d"
    case .maskedFoil: return "theatermask.and.paintbrush.fill"
    }
  }

  @ViewBuilder
  var destination: some View {
    switch self {
    // Basic Shaders
    case .basicGlare:
      BasicGlareView()
    case .verticalBeams:
      VerticalBeamsDemo()
    case .reverseHolo:
      ReverseHoloView()
    case .cosmosHolo:
      CosmosHoloView()
    case .rainbowRare:
      RainbowRareView()
    case .shinyRare:
      ShinyRareView()
    case .diagonalHolo:
      DiagonalHoloView()
    case .vMax:
      VMaxView()
    case .vStar:
      VStarView()
    case .radiantHolo:
      CrisscrossHoloView()
    case .amazingRare:
      ShimmerDemo()
    // Composable Shaders
    case .foilGlitterSweep:
      FoilGlitterSweepView()
    case .gradientFoil:
      GradientFoilView()
    case .psychicHolo:
      PsychicHoloView()
    case .starburstRadial:
      StarburstRadialView()
    case .layeredHolo:
      LayeredHoloView()
    case .maskedFoil:
      MaskedFoilView()
    }
  }
}

struct ContentView: View {
  var body: some View {
    NavigationStack {
      List {
        ForEach(ShaderSection.allCases, id: \.self) { section in
          Section(section.rawValue) {
            ForEach(ShaderType.allCases.filter { $0.section == section }) { shader in
              NavigationLink(destination: shader.destination) {
                HStack(spacing: 16) {
                  Image(systemName: shader.icon)
                    .font(.title2)
                    .foregroundStyle(section == .basic ? .purple : .orange)
                    .frame(width: 32)

                  VStack(alignment: .leading, spacing: 4) {
                    Text(shader.rawValue)
                      .font(.headline)
                    Text(shader.description)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }
                .padding(.vertical, 8)
              }
            }
          }
        }
      }
      .navigationTitle("ShaderKit Demos")
    }
  }
}

#Preview {
  ContentView()
}
