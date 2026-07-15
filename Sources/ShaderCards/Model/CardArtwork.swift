//
//  CardArtwork.swift
//  ShaderCards
//
//  The catalog of procedural artworks. Every artwork is drawn entirely in
//  SwiftUI (gradients, paths, Canvas) — the package ships zero image assets.
//

import SwiftUI

/// A procedural artwork rendered inside a card's art window.
///
/// Each case is an original creature scene composed from a geometric
/// figure, a layered backdrop, and a particle field — all tinted by a
/// hand-tuned palette. Render one with ``ArtworkView``.
public enum CardArtwork: String, CaseIterable, Codable, Sendable, Identifiable {
  // Fire
  case emberfox
  case pyroclaw
  case cindermoth
  // Water
  case aquafin
  case tidecaller
  case mistjelly
  // Grass
  case verdantail
  case bloomshell
  case thornsprite
  // Lightning
  case voltkit
  case stormbeak
  case zapwisp
  // Psychic
  case mindmoth
  case dreamwisp
  case astracat
  // Fighting
  case boulderfist
  case ridgewolf
  case cragturtle
  // Darkness
  case nightfang
  case shadewisp
  case duskraven
  // Metal
  case ironshell
  case chromehawk
  case forgegolem
  // Fairy
  case glimmerkit
  case pixiewing
  case starkitten
  // Dragon
  case auridrake
  case wyrmcoil
  case skyserpent
  // Colorless
  case nimbuff
  case skydancer
  case prismpaw

  public var id: String { rawValue }

  /// Display name of the creature this artwork depicts.
  public var creatureName: String {
    switch self {
    case .emberfox: "Emberfox"
    case .pyroclaw: "Pyroclaw"
    case .cindermoth: "Cindermoth"
    case .aquafin: "Aquafin"
    case .tidecaller: "Tidecaller"
    case .mistjelly: "Mistjelly"
    case .verdantail: "Verdantail"
    case .bloomshell: "Bloomshell"
    case .thornsprite: "Thornsprite"
    case .voltkit: "Voltkit"
    case .stormbeak: "Stormbeak"
    case .zapwisp: "Zapwisp"
    case .mindmoth: "Mindmoth"
    case .dreamwisp: "Dreamwisp"
    case .astracat: "Astracat"
    case .boulderfist: "Boulderfist"
    case .ridgewolf: "Ridgewolf"
    case .cragturtle: "Cragturtle"
    case .nightfang: "Nightfang"
    case .shadewisp: "Shadewisp"
    case .duskraven: "Duskraven"
    case .ironshell: "Ironshell"
    case .chromehawk: "Chromehawk"
    case .forgegolem: "Forgegolem"
    case .glimmerkit: "Glimmerkit"
    case .pixiewing: "Pixiewing"
    case .starkitten: "Starkitten"
    case .auridrake: "Auridrake"
    case .wyrmcoil: "Wyrmcoil"
    case .skyserpent: "Skyserpent"
    case .nimbuff: "Nimbuff"
    case .skydancer: "Skydancer"
    case .prismpaw: "Prismpaw"
    }
  }

  /// The element this artwork was designed for.
  public var element: ElementType {
    switch self {
    case .emberfox, .pyroclaw, .cindermoth: .fire
    case .aquafin, .tidecaller, .mistjelly: .water
    case .verdantail, .bloomshell, .thornsprite: .grass
    case .voltkit, .stormbeak, .zapwisp: .lightning
    case .mindmoth, .dreamwisp, .astracat: .psychic
    case .boulderfist, .ridgewolf, .cragturtle: .fighting
    case .nightfang, .shadewisp, .duskraven: .darkness
    case .ironshell, .chromehawk, .forgegolem: .metal
    case .glimmerkit, .pixiewing, .starkitten: .fairy
    case .auridrake, .wyrmcoil, .skyserpent: .dragon
    case .nimbuff, .skydancer, .prismpaw: .colorless
    }
  }
}
