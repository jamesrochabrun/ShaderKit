//
//  SceneRandom.swift
//  ShaderCards
//
//  Deterministic pseudo-random source so scenes render identically
//  every frame and on every device.
//

import Foundation

/// A tiny splitmix64 generator for stable procedural placement.
struct SceneRandom {
  private var state: UInt64

  init(seed: UInt64) {
    self.state = seed &+ 0x9E3779B97F4A7C15
  }

  mutating func next() -> UInt64 {
    state = state &+ 0x9E3779B97F4A7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
    z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
    return z ^ (z >> 31)
  }

  /// Uniform value in 0..<1.
  mutating func unit() -> CGFloat {
    CGFloat(next() >> 11) / CGFloat(1 << 53)
  }

  /// Uniform value in the given range.
  mutating func range(_ range: ClosedRange<CGFloat>) -> CGFloat {
    range.lowerBound + unit() * (range.upperBound - range.lowerBound)
  }
}
