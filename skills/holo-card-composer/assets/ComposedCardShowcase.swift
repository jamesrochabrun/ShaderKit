//
//  ComposedCardShowcase.swift
//
//  {{OWNER_NAME}}'s holographic card, composed from ShaderKit primitives by
//  the holo-card-composer skill. Drag the card to tilt it in 3D.
//
//  This file implements the DEFAULT construction: a large transparent-PNG
//  subject floating over a shimmering foil background, with translucent
//  "glass" info panels. The effect stack is attached to the BACKGROUND layer
//  so the subject stays clean and the foil shimmers around it.
//
//  For opaque-photo, split-layer, masked-window, or atmosphere constructions,
//  restructure the ZStack per references/composition-recipes.md — the tokens
//  and the stage stay the same.
//
//  Template tokens ({{…}}) must all be replaced before compiling.
//

import SwiftUI
import ShaderKit

struct ComposedCardShowcase: View {
  private static let cardWidth: CGFloat = 280
  private static let cardHeight: CGFloat = 400

  /// The user's transparent-PNG subject, loaded once. When nil, the base
  /// gradient carries the card, so the view never renders a gray placeholder.
  private static let subject: {{PLATFORM_IMAGE_TYPE}}? =
    {{PLATFORM_IMAGE_TYPE}}(contentsOfFile: "{{IMAGE_PATH}}")

  /// Opaque backdrop in {{OWNER_NAME}}'s vibe palette. Also the fallback when
  /// the image is missing.
  private static let baseGradient: [Color] = [
    {{BASE_GRADIENT_STOPS}}
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
      // 1 — background carries the foil. The effect stack lives HERE (not on
      //     the whole card) so the transparent subject stays pristine and the
      //     shimmer reads around/behind it.
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            colors: Self.baseGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        {{EFFECT_STACK}}

      // 2 — transparent subject: fit, NOT clipped-to-fill, so the foil shows
      //     around the cutout. Falls back to the bare background when missing.
      if let subject = Self.subject {
        Image({{PLATFORM_IMAGE_INIT}}: subject)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: Self.cardWidth, height: Self.cardHeight)
      }

      // 3 — legibility scrims only where text sits (top header + bottom stats).
      VStack(spacing: 0) {
        LinearGradient(
          colors: [.black.opacity(0.55), .clear],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: Self.cardHeight * 0.16)
        Spacer()
        LinearGradient(
          colors: [.clear, .black.opacity(0.62)],
          startPoint: .top, endPoint: .bottom
        )
        .frame(height: Self.cardHeight * 0.42)
      }

      // 4 — chrome: name banner + glass stat panels.
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

        // Glass info panel — translucent fill + hairline stroke (NOT Material,
        // which would sample behind the window instead of the card art).
        VStack(spacing: 8) {
          statRow(symbol: "{{SKILL_1_SYMBOL}}", name: "{{SKILL_1_NAME}}", damage: "{{SKILL_1_DAMAGE}}")
          statRow(symbol: "{{SKILL_2_SYMBOL}}", name: "{{SKILL_2_NAME}}", damage: "{{SKILL_2_DAMAGE}}")

          Text("{{ROLE_TITLE}}")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white.opacity(0.85))

          Text("{{MOTTO}}")
            .font(.caption2.italic())
            .foregroundStyle(.white.opacity(0.6))
            .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 14)
            .fill(.black.opacity(0.34))
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
            )
        )
        .padding(.horizontal, 16)
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
    // Optional whole-card glass sheen closer (uncomment for a laminated look):
    // .shader(.glassSheen(intensity: 0.15, spread: 0.5))
  }

  private func statRow(symbol: String, name: String, damage: String) -> some View {
    HStack {
      Image(systemName: symbol)
        .foregroundStyle({{ACCENT_COLOR}})
      Text(name)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
      Spacer()
      Text(damage)
        .font(.title3)
        .fontWeight(.black)
        .foregroundStyle({{ACCENT_COLOR}})
    }
  }
}

#Preview {
  ComposedCardShowcase()
}
