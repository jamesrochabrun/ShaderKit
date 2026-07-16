//
//  ComposedCardShowcase.swift
//
//  {{OWNER_NAME}}'s holographic card, composed from ShaderKit primitives by
//  the holo-card-composer skill. Drag the card to tilt it in 3D.
//
//  This file implements construction A (Full-Art Foil). For split-layer,
//  masked-window, or atmosphere constructions, restructure the ZStack per
//  references/composition-recipes.md — the tokens and stage stay the same.
//
//  Template tokens ({{…}}) must all be replaced before compiling.
//

import SwiftUI
import ShaderKit

struct ComposedCardShowcase: View {
  private static let cardWidth: CGFloat = 280
  private static let cardHeight: CGFloat = 400

  /// The user's photo, loaded once. When nil, the base gradient carries the
  /// card, so the view never renders a gray placeholder.
  private static let portrait: {{PLATFORM_IMAGE_TYPE}}? =
    {{PLATFORM_IMAGE_TYPE}}(contentsOfFile: "{{IMAGE_PATH}}")

  /// Opaque backdrop in {{OWNER_NAME}}'s palette.
  private static let baseGradient: [Color] = [
    {{BASE_GRADIENT_STOPS}}
  ]

  /// Translucent stops layered over the photo to marry it to the foil.
  /// Keep every stop's opacity in 0.10–0.35.
  private static let tintScrim: [Color] = [
    {{TINT_SCRIM_STOPS}}
  ]

  var body: some View {
    ZStack {
      // Near-black stage with a faint palette cast so the foil carries.
      RadialGradient(
        colors: [
          Color(red: {{STAGE_CENTER_RGB}}),
          Color(red: 0.03, green: 0.03, blue: 0.05),
        ],
        center: .center,
        startRadius: 40,
        endRadius: 620
      )
      .ignoresSafeArea()

      VStack(spacing: 26) {
        Text("{{HEADLINE}}")
          .font(.system(size: 22, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.92))

        HolographicCardContainer(
          width: Self.cardWidth,
          height: Self.cardHeight,
          cornerRadius: 20,
          shadowColor: {{SHADOW_COLOR}},
          rotationMultiplier: 13,
          interactionMode: .surfacePointer
        ) {
          cardContent
            {{EFFECT_STACK}}
        }

        Text("Drag to tilt")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.white.opacity(0.5))
      }
      .padding(.vertical, 32)
    }
    .preferredColorScheme(.dark)
  }

  private var cardContent: some View {
    ZStack {
      // 1 — base gradient (also the fallback when the photo is missing)
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            colors: Self.baseGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )

      // 2 — full-bleed portrait
      if let portrait = Self.portrait {
        Image({{PLATFORM_IMAGE_INIT}}: portrait)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: Self.cardWidth, height: Self.cardHeight)
          .clipped()

        // 3 — tint scrim marries the photo to the foil palette
        LinearGradient(
          colors: Self.tintScrim,
          startPoint: .top,
          endPoint: .bottom
        )
      }

      // 4 — chrome
      VStack(spacing: 12) {
        HStack {
          Text("{{CARD_NAME}}")
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
          Spacer()
          Text("HP {{HP}}")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle({{ACCENT_COLOR}})
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 8) {
          HStack {
            Image(systemName: "{{SKILL_1_SYMBOL}}")
              .foregroundStyle({{ACCENT_COLOR}})
            Text("{{SKILL_1_NAME}}")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
            Spacer()
            Text("{{SKILL_1_DAMAGE}}")
              .font(.title3)
              .fontWeight(.black)
              .foregroundStyle({{ACCENT_COLOR}})
          }

          HStack {
            Image(systemName: "{{SKILL_2_SYMBOL}}")
              .foregroundStyle({{ACCENT_COLOR}})
            Text("{{SKILL_2_NAME}}")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
            Spacer()
            Text("{{SKILL_2_DAMAGE}}")
              .font(.title3)
              .fontWeight(.black)
              .foregroundStyle({{ACCENT_COLOR}})
          }

          Text("{{ROLE_TITLE}}")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white.opacity(0.8))

          Text("{{MOTTO}}")
            .font(.caption2.italic())
            .foregroundStyle(.white.opacity(0.55))
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
      }

      // 5 — border
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: [
              {{BORDER_GRADIENT_STOPS}}
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 3
        )
    }
  }
}

#Preview {
  ComposedCardShowcase()
}
