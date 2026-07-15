//
//  SnapshotRenderTests.swift
//  ShaderCards
//
//  Renders every card face to PNG for visual review. Set the output
//  directory via the SHADERCARDS_SNAPSHOT_DIR environment variable;
//  the suite is skipped when it isn't set.
//

#if os(macOS)
import Testing
import SwiftUI
import AppKit
@testable import ShaderCards

@Suite("Snapshot rendering")
@MainActor
struct SnapshotRenderTests {
  @Test func renderAllCards() throws {
    guard let dir = ProcessInfo.processInfo.environment["SHADERCARDS_SNAPSHOT_DIR"],
          !dir.isEmpty else {
      return
    }
    let outputURL = URL(fileURLWithPath: dir, isDirectory: true)
    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    for (index, card) in CardLibrary.allCards.enumerated() {
      // Metal layerEffects don't render offscreen — snapshot the face with
      // the finish's layout flags but no shader passes.
      var finish = CardFinish.finish(for: card.rarity)
      finish.artEffects = []
      finish.cardEffects = []
      finish.frameMaskedEffects = []
      let renderer = ImageRenderer(content: CardFaceView(card: card, width: 300, finish: finish))
      renderer.scale = 2
      guard let nsImage = renderer.nsImage,
            let tiff = nsImage.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:]) else {
        Issue.record("Failed to render \(card.displayName)")
        continue
      }
      let safeName = card.displayName
        .replacingOccurrences(of: " ", with: "-")
        .lowercased()
      let fileURL = outputURL.appendingPathComponent(
        String(format: "%02d-%@.png", index, safeName)
      )
      try png.write(to: fileURL)
    }
  }

  @Test func renderAllArtworks() throws {
    guard let dir = ProcessInfo.processInfo.environment["SHADERCARDS_SNAPSHOT_DIR"],
          !dir.isEmpty else {
      return
    }
    let outputURL = URL(fileURLWithPath: dir, isDirectory: true)
      .appendingPathComponent("artworks")
    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    for artwork in CardArtwork.allCases {
      let renderer = ImageRenderer(
        content: ArtworkView(artwork: artwork).frame(width: 300, height: 220)
      )
      renderer.scale = 2
      guard let nsImage = renderer.nsImage,
            let tiff = nsImage.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:]) else {
        Issue.record("Failed to render \(artwork.rawValue)")
        continue
      }
      let fileURL = outputURL.appendingPathComponent("\(artwork.rawValue).png")
      try png.write(to: fileURL)
    }
  }
}
#endif
