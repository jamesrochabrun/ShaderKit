//
//  CodexLogoView.swift
//  ShaderKitDemo
//
//  Demo-only Codex Logo shader showcase
//

import SwiftUI
import ShaderKit

enum CodexLogoMotionResponse {
  static func effectiveTilt(
    deviceTilt: CGPoint,
    dragTilt: CGPoint,
    motionStrength: Double,
    hasDeviceMotion: Bool
  ) -> CGPoint {
    let source = hasDeviceMotion ? deviceTilt : dragTilt
    let strength = min(max(motionStrength, 0.0), 1.5)

    return CGPoint(
      x: min(max(source.x, -1.0), 1.0) * strength,
      y: min(max(source.y, -1.0), 1.0) * strength
    )
  }

  static func pulseScale(
    time: TimeInterval,
    pulseSpeed: Double,
    reduceMotion: Bool
  ) -> Double {
    let amplitude = reduceMotion ? 0.006 : 0.035
    let phase = sin(time * pulseSpeed * .pi * 2.0)
    return 1.0 + ((phase + 1.0) * 0.5 * amplitude)
  }
}

struct CodexLogoView: View {
  var body: some View {
    Text("Codex Logo")
      .navigationTitle("Codex Logo")
  }
}

#Preview {
  NavigationStack {
    CodexLogoView()
  }
}
