//
//  ShaderCardsDemoApp.swift
//  ShaderCardsDemo
//
//  Runnable demo: `swift run ShaderCardsDemo` (macOS), or open the package
//  in Xcode and run the ShaderCardsDemo scheme.
//

import SwiftUI
import ShaderCards

@main
struct ShaderCardsDemoApp: App {
  #if os(macOS)
  init() {
    // SPM executables have no app bundle; opt into a regular Dock app so
    // the window appears when launched via `swift run`.
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate(ignoringOtherApps: true)
  }
  #endif

  var body: some Scene {
    WindowGroup {
      DemoRootView()
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 860)
        #endif
    }
  }
}

struct DemoRootView: View {
  var body: some View {
    TabView {
      NavigationStack {
        CardGalleryView()
      }
      .tabItem {
        Label("Library", systemImage: "square.grid.3x3.fill")
      }

      NavigationStack {
        CardGalleryView(cards: CardLibrary.showcase)
          .navigationTitle("Showcase")
      }
      .tabItem {
        Label("Showcase", systemImage: "sparkles")
      }

      NavigationStack {
        CardGalleryView(cards: CardLibrary.specialEditionCards)
          .navigationTitle("Special Editions")
      }
      .tabItem {
        Label("Special", systemImage: "crown.fill")
      }

      NavigationStack {
        CardGalleryView(cards: CardLibrary.premiumMaterialCards)
          .navigationTitle("Premium Materials")
      }
      .tabItem {
        Label("Materials", systemImage: "square.3.layers.3d")
      }

      NavigationStack {
        CardGalleryView(cards: CardLibrary.cssParityCards)
          .navigationTitle("CSS Parity")
      }
      .tabItem {
        Label("CSS Parity", systemImage: "circle.hexagongrid.fill")
      }

      NavigationStack {
        CardStudioView()
      }
      .tabItem {
        Label("Studio", systemImage: "paintbrush.pointed.fill")
      }
    }
  }
}
