import CoreGraphics
import Testing
@testable import ShaderKitDemo

@Suite("Codex Logo Demo")
struct CodexLogoDemoTests {

  @Test("Codex Logo appears as an experimental shader with reference identity")
  func codexLogoNavigationMetadataMatchesReferenceIdentity() {
    #expect(ShaderType.codexLogo.rawValue == "Codex Logo")
    #expect(ShaderType.codexLogo.section == .experimental)
    #expect(ShaderType.codexLogo.icon == "terminal.fill")
    #expect(ShaderType.codexLogo.description == "Pulsing AI-brain logo with orientation-reactive gradient light")
  }

  @Test("Codex Logo motion response clamps source tilt and applies strength")
  func codexLogoMotionResponseClampsTiltAndAppliesStrength() {
    let deviceTilt = CodexLogoMotionResponse.effectiveTilt(
      deviceTilt: CGPoint(x: 2.0, y: -3.0),
      dragTilt: CGPoint(x: -0.25, y: 0.25),
      motionStrength: 0.5,
      hasDeviceMotion: true
    )

    #expect(deviceTilt.x == 0.5)
    #expect(deviceTilt.y == -0.5)

    let dragTilt = CodexLogoMotionResponse.effectiveTilt(
      deviceTilt: .zero,
      dragTilt: CGPoint(x: -0.75, y: 0.25),
      motionStrength: 0.8,
      hasDeviceMotion: false
    )

    #expect(abs(dragTilt.x + 0.6) < 0.000001)
    #expect(abs(dragTilt.y - 0.2) < 0.000001)
  }

  @Test("Codex Logo reduced motion keeps the pulse subtle")
  func codexLogoReducedMotionKeepsPulseSubtle() {
    let animated = CodexLogoMotionResponse.pulseScale(
      time: 0.25,
      pulseSpeed: 1.0,
      reduceMotion: false
    )
    let reduced = CodexLogoMotionResponse.pulseScale(
      time: 0.25,
      pulseSpeed: 1.0,
      reduceMotion: true
    )

    #expect(abs(animated - 1.035) < 0.000001)
    #expect(abs(reduced - 1.006) < 0.000001)
  }
}
