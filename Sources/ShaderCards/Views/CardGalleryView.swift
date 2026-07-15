//
//  CardGalleryView.swift
//  ShaderCards
//
//  A browsable grid of the whole card library with an interactive
//  holographic detail view.
//

import SwiftUI

/// A grid gallery of cards. Tap any card for the full interactive
/// holographic experience.
///
/// ```swift
/// NavigationStack { CardGalleryView() }          // whole library
/// NavigationStack { CardGalleryView(cards: CardLibrary.showcase) }
/// ```
public struct CardGalleryView: View {
  let cards: [Card]
  @State private var selectedCard: Card?

  public init(cards: [Card] = CardLibrary.allCards) {
    self.cards = cards
  }

  public var body: some View {
    ScrollView {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)],
        spacing: 16
      ) {
        ForEach(cards) { card in
          Button {
            selectedCard = card
          } label: {
            VStack(spacing: 6) {
              CardFaceView(card: card, width: 160, finish: thumbnailFinish(for: card))
              Text(card.rarity.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
          .buttonStyle(.plain)
          .accessibilityHint("Opens the interactive holographic card")
        }
      }
      .padding(16)
    }
    .background(galleryBackground)
    .navigationTitle("Card Library")
    .sheet(item: $selectedCard) { card in
      CardDetailView(card: card)
    }
  }

  /// Static grid cells keep the finish's layout choices, but omit live
  /// Metal passes that can render transparent outside an interactive host.
  private func thumbnailFinish(for card: Card) -> CardFinish {
    var finish = card.resolvedFinish
    finish.artEffects = []
    finish.cardEffects = []
    finish.frameMaskedEffects = []
    return finish
  }

  private var galleryBackground: some View {
    LinearGradient(
      colors: [Color(red: 0.09, green: 0.10, blue: 0.16),
               Color(red: 0.13, green: 0.11, blue: 0.20)],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }
}

/// Full-screen interactive presentation of one card.
struct CardDetailView: View {
  let card: Card
  @State private var isExplodedMode = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Text(card.displayName)
          .font(.title2.bold())
          .foregroundStyle(.white)
        Spacer()
        Button("Done") { dismiss() }
          .buttonStyle(.borderedProminent)
          .tint(.orange)
      }
      .padding([.top, .horizontal], 20)

      Picker("Mode", selection: $isExplodedMode) {
        Text("Holographic").tag(false)
        Text("Layers").tag(true)
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, 40)

      Spacer()

      if isExplodedMode {
        ExplodableCardView(card: card, width: 300)
        Text("Drag to orbit • pinch to spread the layers")
          .font(.footnote)
          .foregroundStyle(.white.opacity(0.6))
      } else {
        TradingCardView(card, width: 300)
        Text("Drag to tilt the holographic foil")
          .font(.footnote)
          .foregroundStyle(.white.opacity(0.6))
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      LinearGradient(
        colors: [Color(red: 0.07, green: 0.08, blue: 0.14),
                 Color(red: 0.12, green: 0.10, blue: 0.20)],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
    )
    #if os(macOS)
    .frame(minWidth: 480, minHeight: 720)
    #endif
  }
}

#Preview("Gallery") {
  NavigationStack {
    CardGalleryView()
  }
  #if os(macOS)
  .frame(width: 700, height: 800)
  #endif
}
