//
//  CardTypography.swift
//  ShaderCards
//
//  Font recipes shared by all card frames.
//

import SwiftUI

/// Typography recipes for card text, scaled from resolved metrics.
enum CardTypography {
  static func name(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.nameSize, weight: .bold, design: .default)
  }

  static func hp(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.nameSize * 0.92, weight: .heavy, design: .rounded)
  }

  static func stageBadge(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.captionSize * 0.9, weight: .bold)
  }

  static func attackName(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.bodySize * 1.15, weight: .bold)
  }

  static func attackDamage(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.bodySize * 1.3, weight: .heavy, design: .rounded)
  }

  static func body(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.bodySize, weight: .medium)
  }

  static func caption(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.captionSize, weight: .semibold)
  }

  static func flavor(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.captionSize, weight: .regular, design: .serif).italic()
  }

  static func species(_ m: CardMetrics.Resolved) -> Font {
    .system(size: m.captionSize * 0.95, weight: .semibold)
  }
}
