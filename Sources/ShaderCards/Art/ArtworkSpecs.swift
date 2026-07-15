//
//  ArtworkSpecs.swift
//  ShaderCards
//
//  Hand-tuned scene specs for every artwork in the catalog.
//

import SwiftUI

extension CardArtwork {
  /// The hand-tuned scene description for this artwork.
  var spec: ArtSceneSpec {
    switch self {
    // MARK: Fire
    case .emberfox:
      ArtSceneSpec(
        sky: [Color(red: 0.14, green: 0.06, blue: 0.16),
              Color(red: 0.55, green: 0.16, blue: 0.14),
              Color(red: 0.98, green: 0.55, blue: 0.20)],
        glow: Color(red: 1.0, green: 0.65, blue: 0.25),
        terrain: .mountains,
        terrainColors: [Color(red: 0.35, green: 0.10, blue: 0.14),
                        Color(red: 0.22, green: 0.06, blue: 0.10)],
        particles: .embers,
        particleColor: Color(red: 1.0, green: 0.70, blue: 0.30),
        figure: .fox,
        figureColors: FigureColors(
          body: Color(red: 0.96, green: 0.45, blue: 0.14),
          secondary: Color(red: 1.0, green: 0.90, blue: 0.75),
          accent: Color(red: 1.0, green: 0.80, blue: 0.35)
        ),
        seed: 11
      )
    case .pyroclaw:
      ArtSceneSpec(
        sky: [Color(red: 0.10, green: 0.02, blue: 0.05),
              Color(red: 0.45, green: 0.06, blue: 0.05),
              Color(red: 0.85, green: 0.30, blue: 0.10)],
        glow: Color(red: 1.0, green: 0.45, blue: 0.15),
        terrain: .crystals,
        terrainColors: [Color(red: 0.30, green: 0.06, blue: 0.06),
                        Color(red: 0.18, green: 0.03, blue: 0.04)],
        particles: .sparks,
        particleColor: Color(red: 1.0, green: 0.60, blue: 0.20),
        figure: .drake,
        figureColors: FigureColors(
          body: Color(red: 0.80, green: 0.20, blue: 0.10),
          secondary: Color(red: 1.0, green: 0.65, blue: 0.25),
          accent: Color(red: 1.0, green: 0.90, blue: 0.50)
        ),
        figureScale: 0.72,
        seed: 12
      )
    case .cindermoth:
      ArtSceneSpec(
        sky: [Color(red: 0.20, green: 0.05, blue: 0.02),
              Color(red: 0.48, green: 0.14, blue: 0.04),
              Color(red: 0.90, green: 0.45, blue: 0.12)],
        glow: Color(red: 1.0, green: 0.72, blue: 0.30),
        terrain: .forest,
        terrainColors: [Color(red: 0.32, green: 0.09, blue: 0.05),
                        Color(red: 0.18, green: 0.05, blue: 0.03)],
        particles: .embers,
        particleColor: Color(red: 1.0, green: 0.78, blue: 0.40),
        figure: .moth,
        figureColors: FigureColors(
          body: Color(red: 0.92, green: 0.40, blue: 0.12),
          secondary: Color(red: 1.0, green: 0.75, blue: 0.35),
          accent: Color(red: 0.35, green: 0.10, blue: 0.05)
        ),
        figureY: 0.46,
        seed: 13
      )

    // MARK: Water
    case .aquafin:
      ArtSceneSpec(
        sky: [Color(red: 0.02, green: 0.15, blue: 0.30),
              Color(red: 0.05, green: 0.32, blue: 0.55),
              Color(red: 0.15, green: 0.55, blue: 0.75)],
        glow: Color(red: 0.45, green: 0.85, blue: 1.0),
        terrain: .waves,
        terrainColors: [Color(red: 0.04, green: 0.22, blue: 0.40),
                        Color(red: 0.02, green: 0.14, blue: 0.28)],
        particles: .bubbles,
        particleColor: Color(red: 0.75, green: 0.93, blue: 1.0),
        figure: .fish,
        figureColors: FigureColors(
          body: Color(red: 0.20, green: 0.55, blue: 0.90),
          secondary: Color(red: 0.65, green: 0.88, blue: 1.0),
          accent: Color(red: 0.05, green: 0.25, blue: 0.55)
        ),
        figureY: 0.5,
        seed: 21
      )
    case .tidecaller:
      ArtSceneSpec(
        sky: [Color(red: 0.01, green: 0.08, blue: 0.20),
              Color(red: 0.03, green: 0.20, blue: 0.42),
              Color(red: 0.06, green: 0.38, blue: 0.60)],
        glow: Color(red: 0.35, green: 0.80, blue: 0.95),
        terrain: .waves,
        terrainColors: [Color(red: 0.02, green: 0.16, blue: 0.34),
                        Color(red: 0.01, green: 0.10, blue: 0.22)],
        particles: .orbs,
        particleColor: Color(red: 0.55, green: 0.90, blue: 1.0),
        figure: .serpent,
        figureColors: FigureColors(
          body: Color(red: 0.10, green: 0.45, blue: 0.75),
          secondary: Color(red: 0.50, green: 0.85, blue: 0.95),
          accent: Color(red: 0.85, green: 0.97, blue: 1.0)
        ),
        figureScale: 0.75,
        seed: 22
      )
    case .mistjelly:
      ArtSceneSpec(
        sky: [Color(red: 0.05, green: 0.10, blue: 0.28),
              Color(red: 0.10, green: 0.25, blue: 0.48),
              Color(red: 0.20, green: 0.45, blue: 0.62)],
        glow: Color(red: 0.60, green: 0.85, blue: 1.0),
        terrain: .none,
        terrainColors: [],
        particles: .bubbles,
        particleColor: Color(red: 0.80, green: 0.94, blue: 1.0),
        figure: .jelly,
        figureColors: FigureColors(
          body: Color(red: 0.45, green: 0.70, blue: 0.95),
          secondary: Color(red: 0.80, green: 0.92, blue: 1.0),
          accent: Color(red: 0.25, green: 0.40, blue: 0.75)
        ),
        figureY: 0.48,
        seed: 23
      )

    // MARK: Grass
    case .verdantail:
      ArtSceneSpec(
        sky: [Color(red: 0.55, green: 0.85, blue: 0.60),
              Color(red: 0.30, green: 0.65, blue: 0.40),
              Color(red: 0.12, green: 0.40, blue: 0.22)],
        glow: Color(red: 0.85, green: 1.0, blue: 0.60),
        terrain: .forest,
        terrainColors: [Color(red: 0.10, green: 0.32, blue: 0.18),
                        Color(red: 0.05, green: 0.20, blue: 0.10)],
        particles: .leaves,
        particleColor: Color(red: 0.70, green: 0.92, blue: 0.45),
        figure: .cat,
        figureColors: FigureColors(
          body: Color(red: 0.30, green: 0.62, blue: 0.30),
          secondary: Color(red: 0.75, green: 0.92, blue: 0.55),
          accent: Color(red: 0.95, green: 0.75, blue: 0.35)
        ),
        seed: 31
      )
    case .bloomshell:
      ArtSceneSpec(
        sky: [Color(red: 0.65, green: 0.88, blue: 0.55),
              Color(red: 0.40, green: 0.72, blue: 0.42),
              Color(red: 0.18, green: 0.48, blue: 0.28)],
        glow: Color(red: 1.0, green: 0.85, blue: 0.90),
        terrain: .mountains,
        terrainColors: [Color(red: 0.18, green: 0.42, blue: 0.26),
                        Color(red: 0.10, green: 0.28, blue: 0.16)],
        particles: .petals,
        particleColor: Color(red: 1.0, green: 0.75, blue: 0.85),
        figure: .turtle,
        figureColors: FigureColors(
          body: Color(red: 0.35, green: 0.60, blue: 0.32),
          secondary: Color(red: 0.95, green: 0.65, blue: 0.75),
          accent: Color(red: 0.98, green: 0.92, blue: 0.65)
        ),
        figureY: 0.60,
        seed: 32
      )
    case .thornsprite:
      ArtSceneSpec(
        sky: [Color(red: 0.08, green: 0.25, blue: 0.12),
              Color(red: 0.15, green: 0.42, blue: 0.20),
              Color(red: 0.30, green: 0.60, blue: 0.28)],
        glow: Color(red: 0.75, green: 1.0, blue: 0.50),
        terrain: .forest,
        terrainColors: [Color(red: 0.08, green: 0.26, blue: 0.13),
                        Color(red: 0.04, green: 0.16, blue: 0.07)],
        particles: .orbs,
        particleColor: Color(red: 0.85, green: 1.0, blue: 0.55),
        figure: .wisp,
        figureColors: FigureColors(
          body: Color(red: 0.40, green: 0.75, blue: 0.35),
          secondary: Color(red: 0.85, green: 1.0, blue: 0.60),
          accent: Color(red: 0.10, green: 0.30, blue: 0.12)
        ),
        figureY: 0.50,
        seed: 33
      )

    // MARK: Lightning
    case .voltkit:
      ArtSceneSpec(
        sky: [Color(red: 0.10, green: 0.10, blue: 0.25),
              Color(red: 0.25, green: 0.22, blue: 0.45),
              Color(red: 0.50, green: 0.42, blue: 0.20)],
        glow: Color(red: 1.0, green: 0.92, blue: 0.40),
        terrain: .cityscape,
        terrainColors: [Color(red: 0.16, green: 0.15, blue: 0.30),
                        Color(red: 0.08, green: 0.08, blue: 0.18)],
        particles: .sparks,
        particleColor: Color(red: 1.0, green: 0.95, blue: 0.50),
        figure: .cat,
        figureColors: FigureColors(
          body: Color(red: 0.98, green: 0.82, blue: 0.20),
          secondary: Color(red: 1.0, green: 0.96, blue: 0.70),
          accent: Color(red: 0.45, green: 0.32, blue: 0.05)
        ),
        seed: 41
      )
    case .stormbeak:
      ArtSceneSpec(
        sky: [Color(red: 0.06, green: 0.08, blue: 0.18),
              Color(red: 0.18, green: 0.20, blue: 0.38),
              Color(red: 0.38, green: 0.38, blue: 0.55)],
        glow: Color(red: 1.0, green: 0.95, blue: 0.55),
        terrain: .clouds,
        terrainColors: [Color(red: 0.22, green: 0.24, blue: 0.40),
                        Color(red: 0.12, green: 0.13, blue: 0.26)],
        particles: .sparks,
        particleColor: Color(red: 1.0, green: 0.92, blue: 0.45),
        figure: .bird,
        figureColors: FigureColors(
          body: Color(red: 0.95, green: 0.80, blue: 0.15),
          secondary: Color(red: 0.25, green: 0.28, blue: 0.50),
          accent: Color(red: 1.0, green: 0.97, blue: 0.75)
        ),
        figureY: 0.44,
        figureScale: 0.72,
        seed: 42
      )
    case .zapwisp:
      ArtSceneSpec(
        sky: [Color(red: 0.04, green: 0.04, blue: 0.12),
              Color(red: 0.12, green: 0.10, blue: 0.28),
              Color(red: 0.28, green: 0.22, blue: 0.10)],
        glow: Color(red: 1.0, green: 0.95, blue: 0.45),
        terrain: .none,
        terrainColors: [],
        particles: .sparks,
        particleColor: Color(red: 1.0, green: 0.95, blue: 0.55),
        figure: .wisp,
        figureColors: FigureColors(
          body: Color(red: 0.95, green: 0.85, blue: 0.25),
          secondary: Color(red: 1.0, green: 0.98, blue: 0.75),
          accent: Color(red: 0.40, green: 0.30, blue: 0.05)
        ),
        seed: 43
      )

    // MARK: Psychic
    case .mindmoth:
      ArtSceneSpec(
        sky: [Color(red: 0.10, green: 0.04, blue: 0.20),
              Color(red: 0.28, green: 0.10, blue: 0.42),
              Color(red: 0.50, green: 0.25, blue: 0.62)],
        glow: Color(red: 0.90, green: 0.60, blue: 1.0),
        terrain: .crystals,
        terrainColors: [Color(red: 0.22, green: 0.08, blue: 0.36),
                        Color(red: 0.12, green: 0.04, blue: 0.22)],
        particles: .stars,
        particleColor: Color(red: 0.92, green: 0.75, blue: 1.0),
        figure: .moth,
        figureColors: FigureColors(
          body: Color(red: 0.62, green: 0.35, blue: 0.85),
          secondary: Color(red: 0.90, green: 0.70, blue: 1.0),
          accent: Color(red: 0.25, green: 0.08, blue: 0.42)
        ),
        figureY: 0.46,
        seed: 51
      )
    case .dreamwisp:
      ArtSceneSpec(
        sky: [Color(red: 0.06, green: 0.03, blue: 0.15),
              Color(red: 0.18, green: 0.08, blue: 0.32),
              Color(red: 0.38, green: 0.20, blue: 0.55)],
        glow: Color(red: 0.80, green: 0.55, blue: 1.0),
        terrain: .clouds,
        terrainColors: [Color(red: 0.24, green: 0.12, blue: 0.42),
                        Color(red: 0.14, green: 0.06, blue: 0.26)],
        particles: .stars,
        particleColor: Color(red: 0.95, green: 0.85, blue: 1.0),
        figure: .wisp,
        figureColors: FigureColors(
          body: Color(red: 0.58, green: 0.38, blue: 0.90),
          secondary: Color(red: 0.88, green: 0.78, blue: 1.0),
          accent: Color(red: 0.22, green: 0.08, blue: 0.40)
        ),
        seed: 52
      )
    case .astracat:
      ArtSceneSpec(
        sky: [Color(red: 0.03, green: 0.02, blue: 0.12),
              Color(red: 0.12, green: 0.06, blue: 0.28),
              Color(red: 0.30, green: 0.15, blue: 0.48)],
        glow: Color(red: 0.75, green: 0.55, blue: 1.0),
        terrain: .mountains,
        terrainColors: [Color(red: 0.16, green: 0.08, blue: 0.32),
                        Color(red: 0.08, green: 0.04, blue: 0.18)],
        particles: .stars,
        particleColor: Color(red: 0.90, green: 0.82, blue: 1.0),
        figure: .cat,
        figureColors: FigureColors(
          body: Color(red: 0.35, green: 0.20, blue: 0.60),
          secondary: Color(red: 0.75, green: 0.60, blue: 0.95),
          accent: Color(red: 1.0, green: 0.85, blue: 0.45)
        ),
        seed: 53
      )

    // MARK: Fighting
    case .boulderfist:
      ArtSceneSpec(
        sky: [Color(red: 0.55, green: 0.38, blue: 0.22),
              Color(red: 0.72, green: 0.52, blue: 0.30),
              Color(red: 0.88, green: 0.70, blue: 0.45)],
        glow: Color(red: 1.0, green: 0.85, blue: 0.55),
        terrain: .mountains,
        terrainColors: [Color(red: 0.45, green: 0.28, blue: 0.16),
                        Color(red: 0.28, green: 0.16, blue: 0.08)],
        particles: .none,
        particleColor: .clear,
        figure: .golem,
        figureColors: FigureColors(
          body: Color(red: 0.55, green: 0.38, blue: 0.24),
          secondary: Color(red: 0.78, green: 0.62, blue: 0.42),
          accent: Color(red: 1.0, green: 0.72, blue: 0.25)
        ),
        figureY: 0.56,
        figureScale: 0.70,
        seed: 61
      )
    case .ridgewolf:
      ArtSceneSpec(
        sky: [Color(red: 0.30, green: 0.20, blue: 0.28),
              Color(red: 0.60, green: 0.35, blue: 0.28),
              Color(red: 0.88, green: 0.60, blue: 0.35)],
        glow: Color(red: 1.0, green: 0.75, blue: 0.45),
        terrain: .mountains,
        terrainColors: [Color(red: 0.38, green: 0.22, blue: 0.18),
                        Color(red: 0.22, green: 0.12, blue: 0.10)],
        particles: .none,
        particleColor: .clear,
        figure: .wolf,
        figureColors: FigureColors(
          body: Color(red: 0.55, green: 0.40, blue: 0.30),
          secondary: Color(red: 0.85, green: 0.75, blue: 0.62),
          accent: Color(red: 0.95, green: 0.60, blue: 0.25)
        ),
        seed: 62
      )
    case .cragturtle:
      ArtSceneSpec(
        sky: [Color(red: 0.42, green: 0.30, blue: 0.20),
              Color(red: 0.62, green: 0.45, blue: 0.28),
              Color(red: 0.80, green: 0.62, blue: 0.40)],
        glow: Color(red: 0.95, green: 0.80, blue: 0.50),
        terrain: .dunes,
        terrainColors: [Color(red: 0.50, green: 0.34, blue: 0.20),
                        Color(red: 0.32, green: 0.20, blue: 0.10)],
        particles: .none,
        particleColor: .clear,
        figure: .turtle,
        figureColors: FigureColors(
          body: Color(red: 0.52, green: 0.36, blue: 0.22),
          secondary: Color(red: 0.72, green: 0.58, blue: 0.40),
          accent: Color(red: 0.92, green: 0.78, blue: 0.50)
        ),
        figureY: 0.60,
        seed: 63
      )

    // MARK: Darkness
    case .nightfang:
      ArtSceneSpec(
        sky: [Color(red: 0.02, green: 0.02, blue: 0.06),
              Color(red: 0.08, green: 0.08, blue: 0.16),
              Color(red: 0.16, green: 0.16, blue: 0.28)],
        glow: Color(red: 0.35, green: 0.55, blue: 0.75),
        terrain: .forest,
        terrainColors: [Color(red: 0.06, green: 0.06, blue: 0.12),
                        Color(red: 0.03, green: 0.03, blue: 0.07)],
        particles: .stars,
        particleColor: Color(red: 0.70, green: 0.80, blue: 0.95),
        figure: .wolf,
        figureColors: FigureColors(
          body: Color(red: 0.15, green: 0.16, blue: 0.24),
          secondary: Color(red: 0.38, green: 0.42, blue: 0.55),
          accent: Color(red: 0.30, green: 0.85, blue: 0.75)
        ),
        seed: 71
      )
    case .shadewisp:
      ArtSceneSpec(
        sky: [Color(red: 0.03, green: 0.02, blue: 0.08),
              Color(red: 0.10, green: 0.06, blue: 0.16),
              Color(red: 0.20, green: 0.12, blue: 0.26)],
        glow: Color(red: 0.45, green: 0.30, blue: 0.65),
        terrain: .none,
        terrainColors: [],
        particles: .orbs,
        particleColor: Color(red: 0.55, green: 0.40, blue: 0.75),
        figure: .wisp,
        figureColors: FigureColors(
          body: Color(red: 0.25, green: 0.18, blue: 0.38),
          secondary: Color(red: 0.55, green: 0.45, blue: 0.75),
          accent: Color(red: 0.85, green: 0.30, blue: 0.45)
        ),
        seed: 72
      )
    case .duskraven:
      ArtSceneSpec(
        sky: [Color(red: 0.10, green: 0.05, blue: 0.15),
              Color(red: 0.25, green: 0.10, blue: 0.25),
              Color(red: 0.48, green: 0.20, blue: 0.30)],
        glow: Color(red: 0.75, green: 0.35, blue: 0.45),
        terrain: .cityscape,
        terrainColors: [Color(red: 0.14, green: 0.08, blue: 0.18),
                        Color(red: 0.07, green: 0.04, blue: 0.10)],
        particles: .stars,
        particleColor: Color(red: 0.85, green: 0.60, blue: 0.70),
        figure: .bird,
        figureColors: FigureColors(
          body: Color(red: 0.14, green: 0.12, blue: 0.20),
          secondary: Color(red: 0.42, green: 0.30, blue: 0.50),
          accent: Color(red: 0.90, green: 0.40, blue: 0.50)
        ),
        figureY: 0.44,
        figureScale: 0.72,
        seed: 73
      )

    // MARK: Metal
    case .ironshell:
      ArtSceneSpec(
        sky: [Color(red: 0.30, green: 0.34, blue: 0.40),
              Color(red: 0.55, green: 0.60, blue: 0.66),
              Color(red: 0.78, green: 0.82, blue: 0.88)],
        glow: Color(red: 0.95, green: 0.97, blue: 1.0),
        terrain: .mountains,
        terrainColors: [Color(red: 0.36, green: 0.40, blue: 0.48),
                        Color(red: 0.22, green: 0.25, blue: 0.32)],
        particles: .none,
        particleColor: .clear,
        figure: .turtle,
        figureColors: FigureColors(
          body: Color(red: 0.55, green: 0.58, blue: 0.64),
          secondary: Color(red: 0.82, green: 0.85, blue: 0.90),
          accent: Color(red: 0.30, green: 0.55, blue: 0.85)
        ),
        figureY: 0.60,
        seed: 81
      )
    case .chromehawk:
      ArtSceneSpec(
        sky: [Color(red: 0.16, green: 0.20, blue: 0.28),
              Color(red: 0.38, green: 0.45, blue: 0.55),
              Color(red: 0.65, green: 0.72, blue: 0.80)],
        glow: Color(red: 0.90, green: 0.95, blue: 1.0),
        terrain: .cityscape,
        terrainColors: [Color(red: 0.25, green: 0.30, blue: 0.38),
                        Color(red: 0.14, green: 0.17, blue: 0.23)],
        particles: .none,
        particleColor: .clear,
        figure: .bird,
        figureColors: FigureColors(
          body: Color(red: 0.62, green: 0.66, blue: 0.72),
          secondary: Color(red: 0.88, green: 0.91, blue: 0.96),
          accent: Color(red: 0.95, green: 0.55, blue: 0.20)
        ),
        figureY: 0.44,
        figureScale: 0.72,
        seed: 82
      )
    case .forgegolem:
      ArtSceneSpec(
        sky: [Color(red: 0.12, green: 0.10, blue: 0.12),
              Color(red: 0.30, green: 0.24, blue: 0.22),
              Color(red: 0.55, green: 0.38, blue: 0.25)],
        glow: Color(red: 1.0, green: 0.55, blue: 0.20),
        terrain: .cityscape,
        terrainColors: [Color(red: 0.20, green: 0.16, blue: 0.16),
                        Color(red: 0.10, green: 0.08, blue: 0.08)],
        particles: .embers,
        particleColor: Color(red: 1.0, green: 0.62, blue: 0.25),
        figure: .golem,
        figureColors: FigureColors(
          body: Color(red: 0.45, green: 0.47, blue: 0.52),
          secondary: Color(red: 0.70, green: 0.73, blue: 0.78),
          accent: Color(red: 1.0, green: 0.55, blue: 0.18)
        ),
        figureY: 0.56,
        figureScale: 0.70,
        seed: 83
      )

    // MARK: Fairy
    case .glimmerkit:
      ArtSceneSpec(
        sky: [Color(red: 0.95, green: 0.75, blue: 0.88),
              Color(red: 0.85, green: 0.55, blue: 0.78),
              Color(red: 0.60, green: 0.30, blue: 0.60)],
        glow: Color(red: 1.0, green: 0.92, blue: 0.98),
        terrain: .clouds,
        terrainColors: [Color(red: 0.75, green: 0.45, blue: 0.68),
                        Color(red: 0.55, green: 0.28, blue: 0.52)],
        particles: .stars,
        particleColor: Color(red: 1.0, green: 0.95, blue: 1.0),
        figure: .fox,
        figureColors: FigureColors(
          body: Color(red: 0.98, green: 0.70, blue: 0.85),
          secondary: Color(red: 1.0, green: 0.94, blue: 0.98),
          accent: Color(red: 0.70, green: 0.30, blue: 0.60)
        ),
        seed: 91
      )
    case .pixiewing:
      ArtSceneSpec(
        sky: [Color(red: 0.55, green: 0.35, blue: 0.65),
              Color(red: 0.80, green: 0.55, blue: 0.80),
              Color(red: 0.98, green: 0.80, blue: 0.92)],
        glow: Color(red: 1.0, green: 0.90, blue: 0.98),
        terrain: .forest,
        terrainColors: [Color(red: 0.45, green: 0.25, blue: 0.52),
                        Color(red: 0.30, green: 0.15, blue: 0.36)],
        particles: .petals,
        particleColor: Color(red: 1.0, green: 0.85, blue: 0.95),
        figure: .moth,
        figureColors: FigureColors(
          body: Color(red: 0.95, green: 0.60, blue: 0.80),
          secondary: Color(red: 1.0, green: 0.90, blue: 0.96),
          accent: Color(red: 0.55, green: 0.20, blue: 0.48)
        ),
        figureY: 0.46,
        seed: 92
      )
    case .starkitten:
      ArtSceneSpec(
        sky: [Color(red: 0.25, green: 0.12, blue: 0.35),
              Color(red: 0.55, green: 0.30, blue: 0.60),
              Color(red: 0.90, green: 0.62, blue: 0.80)],
        glow: Color(red: 1.0, green: 0.88, blue: 0.95),
        terrain: .clouds,
        terrainColors: [Color(red: 0.42, green: 0.22, blue: 0.48),
                        Color(red: 0.28, green: 0.12, blue: 0.34)],
        particles: .stars,
        particleColor: Color(red: 1.0, green: 0.92, blue: 0.98),
        figure: .cat,
        figureColors: FigureColors(
          body: Color(red: 0.92, green: 0.65, blue: 0.82),
          secondary: Color(red: 1.0, green: 0.92, blue: 0.97),
          accent: Color(red: 0.98, green: 0.85, blue: 0.40)
        ),
        seed: 93
      )

    // MARK: Dragon
    case .auridrake:
      ArtSceneSpec(
        sky: [Color(red: 0.12, green: 0.10, blue: 0.05),
              Color(red: 0.35, green: 0.28, blue: 0.10),
              Color(red: 0.70, green: 0.55, blue: 0.22)],
        glow: Color(red: 1.0, green: 0.85, blue: 0.40),
        terrain: .mountains,
        terrainColors: [Color(red: 0.28, green: 0.22, blue: 0.10),
                        Color(red: 0.16, green: 0.12, blue: 0.05)],
        particles: .orbs,
        particleColor: Color(red: 1.0, green: 0.88, blue: 0.45),
        figure: .drake,
        figureColors: FigureColors(
          body: Color(red: 0.80, green: 0.62, blue: 0.20),
          secondary: Color(red: 0.98, green: 0.88, blue: 0.55),
          accent: Color(red: 0.35, green: 0.50, blue: 0.30)
        ),
        figureScale: 0.72,
        seed: 101
      )
    case .wyrmcoil:
      ArtSceneSpec(
        sky: [Color(red: 0.08, green: 0.12, blue: 0.10),
              Color(red: 0.18, green: 0.30, blue: 0.20),
              Color(red: 0.42, green: 0.55, blue: 0.30)],
        glow: Color(red: 0.85, green: 0.95, blue: 0.50),
        terrain: .crystals,
        terrainColors: [Color(red: 0.14, green: 0.24, blue: 0.15),
                        Color(red: 0.08, green: 0.14, blue: 0.08)],
        particles: .orbs,
        particleColor: Color(red: 0.90, green: 0.95, blue: 0.55),
        figure: .serpent,
        figureColors: FigureColors(
          body: Color(red: 0.35, green: 0.55, blue: 0.28),
          secondary: Color(red: 0.85, green: 0.80, blue: 0.40),
          accent: Color(red: 0.95, green: 0.90, blue: 0.60)
        ),
        figureScale: 0.75,
        seed: 102
      )
    case .skyserpent:
      ArtSceneSpec(
        sky: [Color(red: 0.30, green: 0.45, blue: 0.70),
              Color(red: 0.55, green: 0.68, blue: 0.85),
              Color(red: 0.85, green: 0.90, blue: 0.95)],
        glow: Color(red: 1.0, green: 0.95, blue: 0.75),
        terrain: .clouds,
        terrainColors: [Color(red: 0.55, green: 0.65, blue: 0.82),
                        Color(red: 0.40, green: 0.50, blue: 0.68)],
        particles: .none,
        particleColor: .clear,
        figure: .serpent,
        figureColors: FigureColors(
          body: Color(red: 0.45, green: 0.60, blue: 0.85),
          secondary: Color(red: 0.90, green: 0.85, blue: 0.55),
          accent: Color(red: 1.0, green: 0.95, blue: 0.80)
        ),
        figureY: 0.48,
        figureScale: 0.75,
        seed: 103
      )

    // MARK: Colorless
    case .nimbuff:
      ArtSceneSpec(
        sky: [Color(red: 0.60, green: 0.75, blue: 0.90),
              Color(red: 0.80, green: 0.88, blue: 0.95),
              Color(red: 0.95, green: 0.95, blue: 0.92)],
        glow: Color(red: 1.0, green: 1.0, blue: 0.95),
        terrain: .clouds,
        terrainColors: [Color(red: 0.78, green: 0.84, blue: 0.92),
                        Color(red: 0.62, green: 0.70, blue: 0.82)],
        particles: .snow,
        particleColor: .white,
        figure: .jelly,
        figureColors: FigureColors(
          body: Color(red: 0.92, green: 0.92, blue: 0.95),
          secondary: Color(red: 1.0, green: 1.0, blue: 1.0),
          accent: Color(red: 0.55, green: 0.60, blue: 0.72)
        ),
        figureY: 0.48,
        seed: 111
      )
    case .skydancer:
      ArtSceneSpec(
        sky: [Color(red: 0.35, green: 0.55, blue: 0.80),
              Color(red: 0.60, green: 0.78, blue: 0.92),
              Color(red: 0.92, green: 0.95, blue: 0.98)],
        glow: Color(red: 1.0, green: 1.0, blue: 0.92),
        terrain: .clouds,
        terrainColors: [Color(red: 0.68, green: 0.80, blue: 0.92),
                        Color(red: 0.52, green: 0.65, blue: 0.82)],
        particles: .none,
        particleColor: .clear,
        figure: .bird,
        figureColors: FigureColors(
          body: Color(red: 0.95, green: 0.95, blue: 0.98),
          secondary: Color(red: 0.75, green: 0.80, blue: 0.88),
          accent: Color(red: 0.95, green: 0.70, blue: 0.30)
        ),
        figureY: 0.44,
        figureScale: 0.72,
        seed: 112
      )
    case .prismpaw:
      ArtSceneSpec(
        sky: [Color(red: 0.85, green: 0.80, blue: 0.90),
              Color(red: 0.92, green: 0.88, blue: 0.82),
              Color(red: 0.98, green: 0.95, blue: 0.90)],
        glow: Color(red: 1.0, green: 1.0, blue: 1.0),
        terrain: .dunes,
        terrainColors: [Color(red: 0.80, green: 0.75, blue: 0.72),
                        Color(red: 0.65, green: 0.60, blue: 0.58)],
        particles: .stars,
        particleColor: Color(red: 1.0, green: 0.95, blue: 0.85),
        figure: .cat,
        figureColors: FigureColors(
          body: Color(red: 0.90, green: 0.87, blue: 0.82),
          secondary: Color(red: 1.0, green: 0.98, blue: 0.95),
          accent: Color(red: 0.65, green: 0.50, blue: 0.75)
        ),
        seed: 113
      )
    }
  }
}
