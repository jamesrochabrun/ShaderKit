//
//  ArtSceneSpec.swift
//  ShaderCards
//
//  Declarative spec for a procedural artwork scene: sky, terrain, creature
//  figure, and particle field.
//

import SwiftUI

/// The geometric creature silhouettes the art engine can draw.
enum FigureKind {
  case fox
  case drake
  case bird
  case fish
  case jelly
  case golem
  case wisp
  case moth
  case wolf
  case turtle
  case cat
  case serpent
}

/// Distant scenery silhouettes layered behind the figure.
enum TerrainKind {
  case mountains
  case waves
  case forest
  case dunes
  case clouds
  case crystals
  case cityscape
  case none
}

/// Ambient particle styles drifting through the scene.
enum ParticleKind {
  case embers
  case bubbles
  case sparks
  case petals
  case stars
  case snow
  case leaves
  case orbs
  case none
}

/// Colors for a creature figure.
struct FigureColors {
  /// Main body fill.
  var body: Color
  /// Secondary fill: belly, wing undersides, inner details.
  var secondary: Color
  /// Small accents: eyes, tail tips, markings.
  var accent: Color
}

/// Full description of one artwork scene.
struct ArtSceneSpec {
  /// Sky gradient stops, top to bottom.
  var sky: [Color]
  /// Radial glow color behind the figure.
  var glow: Color
  var terrain: TerrainKind
  /// Terrain silhouette colors, far to near.
  var terrainColors: [Color]
  var particles: ParticleKind
  var particleColor: Color
  var figure: FigureKind
  var figureColors: FigureColors
  /// Vertical position of the figure center (0 top – 1 bottom).
  var figureY: CGFloat = 0.58
  /// Figure size relative to scene width.
  var figureScale: CGFloat = 0.62
  /// Random seed for particle placement.
  var seed: UInt64 = 1
}
