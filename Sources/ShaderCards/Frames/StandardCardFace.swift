//
//  StandardCardFace.swift
//  ShaderCards
//
//  The classic creature card layout: framed art window, body panel with
//  attacks, battle-stats footer, and info line.
//

import SwiftUI
import ShaderKit

/// Which slice of a card face to render — used to split faces into
/// discrete layers for the exploded composition view.
enum FaceLayerMode {
  /// The complete card.
  case full
  /// Only the frame base: colored border plate, no content.
  case frameOnly
  /// Only the chrome: header, panels, and text with a transparent art
  /// window, so the artwork layer beneath shows through when collapsed.
  case chromeOnly
}

/// How the art window renders.
enum ArtWindowTreatment {
  /// The card's artwork.
  case artwork
  /// A dark opening (frame display without art).
  case dark
  /// Fully transparent: bevel only, art shows from the layer beneath.
  case transparent
}

/// The classic bordered creature card face.
///
/// Applies the finish's art effects inside the art window and its
/// frame-masked effects across the frame, so holo and reverse-holo
/// treatments land exactly where they would on a real card.
struct StandardCardFace: View {
  let card: CardModel
  let metrics: CardMetrics.Resolved
  let finish: CardFinish
  /// Which slice of the face to render.
  var layerMode: FaceLayerMode = .full
  /// How the art window renders (ignored in `.frameOnly` mode).
  var artTreatment: ArtWindowTreatment = .artwork

  private var palette: ElementPalette { card.element.palette }

  var body: some View {
    // Frame foil goes on the frame base only, underneath the panels and
    // text, so reverse-holo treatments keep body text crisp.
    switch layerMode {
    case .full:
      frameBase
        .modifier(EffectStack(effects: frameEffects))
        .overlay(alignment: .top) { content }
    case .frameOnly:
      frameBase
        .modifier(EffectStack(effects: frameEffects))
    case .chromeOnly:
      Color.clear
        .overlay(alignment: .top) { content }
    }
  }

  /// Frame-masked effects with the real art window UV injected.
  private var frameEffects: [ShaderEffect] {
    finish.frameMaskedEffects.map { effect in
      switch effect {
      case .maskedFoil(_, let intensity):
        .maskedFoil(imageWindow: CardMetrics.artWindowUV, intensity: intensity)
      case .maskedSparkle:
        .maskedSparkle(imageWindow: CardMetrics.artWindowUV)
      case .foilTexture:
        .foilTexture(imageWindow: CardMetrics.artWindowUV)
      default:
        effect
      }
    }
  }

  private var frameBase: some View {
    RoundedRectangle(cornerRadius: metrics.cornerRadius)
      .fill(
        finish.isGoldFrame
          ? LinearGradient(
              colors: [
                Color(red: 0.98, green: 0.86, blue: 0.45),
                Color(red: 0.85, green: 0.65, blue: 0.20),
                Color(red: 0.95, green: 0.80, blue: 0.38),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          : LinearGradient(
              colors: [palette.light, palette.primary, palette.dark.opacity(0.9)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
      )
      .overlay(FramePinstripes(spacing: metrics.width * 0.02).opacity(0.14))
      .overlay(
        RoundedRectangle(cornerRadius: metrics.cornerRadius)
          .strokeBorder(.black.opacity(0.35), lineWidth: 0.75)
      )
  }

  private var content: some View {
    VStack(spacing: metrics.height * 0.008) {
      CardHeader(card: card, metrics: metrics)
        .frame(height: metrics.headerHeight)

      ArtWindow(metrics: metrics) {
        artWindowContent
          .frame(width: metrics.width - metrics.border * 2, height: metrics.artHeight)
      }
      .frame(height: metrics.artHeight)

      SpeciesBand(card: card, metrics: metrics)
        .padding(.horizontal, metrics.width * 0.06)

      bodyPanel

      BattleStatsFooter(card: card, metrics: metrics)
        .padding(.horizontal, metrics.width * 0.01)

      InfoLine(
        setNumber: card.setNumber,
        illustrator: card.illustrator,
        rarity: card.rarity,
        metrics: metrics
      )
    }
    .padding(metrics.border)
  }

  @ViewBuilder
  private var artWindowContent: some View {
    switch artTreatment {
    case .artwork:
      CardArtView(art: card.art)
        .modifier(EffectStack(effects: finish.artEffects))
    case .dark:
      LinearGradient(
        colors: [Color(white: 0.10), Color(white: 0.16)],
        startPoint: .top,
        endPoint: .bottom
      )
    case .transparent:
      Color.clear
    }
  }

  private var bodyPanel: some View {
    VStack(alignment: .leading, spacing: metrics.height * 0.012) {
      if let ability = card.ability {
        AbilityRow(ability: ability, metrics: metrics)
      }

      ForEach(card.attacks) { attack in
        AttackRow(attack: attack, metrics: metrics)
      }

      if card.ability == nil && card.attacks.count < 2, let flavor = card.flavorText {
        Divider().opacity(0.4)
        Text(flavor)
          .font(CardTypography.flavor(metrics))
          .foregroundStyle(.black.opacity(0.65))
          .lineLimit(3)
          .minimumScaleFactor(0.8)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(.horizontal, metrics.width * 0.03)
    .padding(.vertical, metrics.width * 0.022)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(
      RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.5)
        .fill(bodyPanelColor)
        .overlay(
          RoundedRectangle(cornerRadius: metrics.cornerRadius * 0.5)
            .strokeBorder(.black.opacity(0.12), lineWidth: 0.5)
        )
    )
  }

  private var bodyPanelColor: LinearGradient {
    LinearGradient(
      colors: [
        Color(red: 0.99, green: 0.98, blue: 0.94),
        Color(red: 0.95, green: 0.93, blue: 0.86),
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

/// Applies an ordered stack of ShaderKit effects.
struct EffectStack: ViewModifier {
  let effects: [ShaderEffect]

  func body(content: Content) -> some View {
    effects.reduce(AnyView(content)) { view, effect in
      AnyView(view.shader(effect))
    }
  }
}

/// Subtle diagonal pinstripe texture for card frames.
struct FramePinstripes: View {
  let spacing: CGFloat

  var body: some View {
    Canvas { context, size in
      let diagonal = size.width + size.height
      var x: CGFloat = -size.height
      while x < diagonal {
        var path = Path()
        path.move(to: CGPoint(x: x, y: size.height))
        path.addLine(to: CGPoint(x: x + size.height, y: 0))
        context.stroke(path, with: .color(.white), lineWidth: 0.5)
        x += spacing
      }
    }
    .allowsHitTesting(false)
  }
}
