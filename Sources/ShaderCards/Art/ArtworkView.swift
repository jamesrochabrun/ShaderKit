//
//  ArtworkView.swift
//  ShaderCards
//
//  Renders a CardArtwork: layered sky, glow, terrain, creature figure,
//  and drifting particles.
//

import SwiftUI

/// Renders the procedural scene for a ``CardArtwork``.
public struct ArtworkView: View {
  let artwork: CardArtwork

  public init(artwork: CardArtwork) {
    self.artwork = artwork
  }

  public var body: some View {
    let spec = artwork.spec
    GeometryReader { proxy in
      let size = proxy.size
      ZStack {
        // Sky.
        LinearGradient(colors: spec.sky, startPoint: .top, endPoint: .bottom)

        // Radial glow behind the figure.
        RadialGradient(
          colors: [spec.glow.opacity(0.75), spec.glow.opacity(0)],
          center: UnitPoint(x: 0.5, y: spec.figureY - 0.08),
          startRadius: 0,
          endRadius: size.width * 0.55
        )

        // Distant terrain.
        TerrainView(kind: spec.terrain, colors: spec.terrainColors, seed: spec.seed)

        // The creature.
        FigureView(kind: spec.figure, colors: spec.figureColors)
          .frame(
            width: size.width * spec.figureScale,
            height: size.width * spec.figureScale
          )
          .position(x: size.width * 0.5, y: size.height * spec.figureY)

        // Ambient particles.
        ParticleField(kind: spec.particles, color: spec.particleColor, seed: spec.seed)

        // Soft vignette to seat everything.
        RadialGradient(
          colors: [.clear, .black.opacity(0.22)],
          center: .center,
          startRadius: size.width * 0.45,
          endRadius: size.width * 0.95
        )
      }
    }
    .clipped()
    .accessibilityLabel("\(artwork.creatureName) artwork")
  }
}

/// Dispatches to the concrete figure drawing.
struct FigureView: View {
  let kind: FigureKind
  let colors: FigureColors

  var body: some View {
    switch kind {
    case .fox: FoxFigure(colors: colors)
    case .drake: DrakeFigure(colors: colors)
    case .bird: BirdFigure(colors: colors)
    case .fish: FishFigure(colors: colors)
    case .jelly: JellyFigure(colors: colors)
    case .golem: GolemFigure(colors: colors)
    case .wisp: WispFigure(colors: colors)
    case .moth: MothFigure(colors: colors)
    case .wolf: WolfFigure(colors: colors)
    case .turtle: TurtleFigure(colors: colors)
    case .cat: CatFigure(colors: colors)
    case .serpent: SerpentFigure(colors: colors)
    }
  }
}
