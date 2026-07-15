//
//  CardArt.swift
//  ShaderCards
//
//  Artwork source for a card: a built-in procedural scene or a
//  user-provided image.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

/// The artwork shown in a card's art window: a built-in procedural
/// scene, a user image, a gradient field, or a stack of any of these.
public enum CardArt: Equatable, Sendable {
  /// A built-in procedural scene from the ``CardArtwork`` catalog.
  case procedural(CardArtwork)
  /// User-provided image data (PNG/JPEG/HEIC).
  case image(Data)
  /// A gradient field — the canvas the classic foil card designs use.
  /// Use translucent stops to layer it over other art as a tint/scrim.
  case gradient([Color])
  /// A back-to-front stack of art layers, e.g. a backdrop gradient
  /// under a photo under a tint gradient.
  indirect case layered([CardArt])

  /// The procedural artwork, when this art is or contains a scene.
  public var proceduralArtwork: CardArtwork? {
    switch self {
    case .procedural(let artwork): return artwork
    case .layered(let layers):
      for layer in layers {
        if let artwork = layer.proceduralArtwork { return artwork }
      }
      return nil
    default: return nil
    }
  }

  /// The layers of this art, back to front (itself when not layered).
  public var layers: [CardArt] {
    if case .layered(let items) = self { return items }
    return [self]
  }

  /// Display name for galleries: the creature name for procedural art,
  /// or a generic label for custom images and gradients.
  public var displayName: String {
    switch self {
    case .procedural(let artwork): artwork.creatureName
    case .image: "Custom Art"
    case .gradient: "Gradient"
    case .layered(let layers): layers.compactMap { layer in
        if case .gradient = layer { return nil }
        return layer.displayName
      }.first ?? "Layered Art"
    }
  }
}

/// Renders any ``CardArt``: procedural scenes draw live; images are
/// decoded once and cached.
public struct CardArtView: View {
  let art: CardArt

  public init(art: CardArt) {
    self.art = art
  }

  public var body: some View {
    switch art {
    case .procedural(let artwork):
      ArtworkView(artwork: artwork)
    case .layered(let items):
      ZStack {
        ForEach(Array(items.enumerated()), id: \.offset) { _, layer in
          CardArtView(art: layer)
        }
      }
    case .gradient(let colors):
      LinearGradient(
        colors: colors.isEmpty ? [Color(white: 0.4), Color(white: 0.2)] : colors,
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .accessibilityLabel("Gradient card artwork")
    case .image(let data):
      GeometryReader { proxy in
        if let image = ArtImageCache.image(for: data) {
          #if canImport(UIKit)
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
          #else
          Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
          #endif
        } else {
          LinearGradient(
            colors: [Color(white: 0.25), Color(white: 0.4)],
            startPoint: .top,
            endPoint: .bottom
          )
          .overlay(
            Image(systemName: "photo")
              .font(.largeTitle)
              .foregroundStyle(.white.opacity(0.5))
          )
        }
      }
      .accessibilityLabel("Custom card artwork")
    }
  }
}

/// Decode-once cache for custom image art, keyed by the image data.
enum ArtImageCache {
  private static let cache = NSCache<NSData, PlatformImage>()

  static func image(for data: Data) -> PlatformImage? {
    let key = data as NSData
    if let cached = cache.object(forKey: key) {
      return cached
    }
    guard let image = PlatformImage(data: data) else { return nil }
    cache.setObject(image, forKey: key)
    return image
  }
}
