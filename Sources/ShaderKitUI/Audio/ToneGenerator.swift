//
//  ToneGenerator.swift
//  ShaderKitUI
//
//  Programmatic tone generator for UI sound effects.
//

import AVFoundation

/// Generates jelly-like wobble tones for UI feedback sounds.
@Observable
public final class ToneGenerator {
  private let engine = AVAudioEngine()
  private let playerNode = AVAudioPlayerNode()
  private let format: AVAudioFormat

  public init() {
    format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    engine.attach(playerNode)
    engine.connect(playerNode, to: engine.mainMixerNode, format: format)
    try? engine.start()
  }

  /// Play a jelly-like wobble sound.
  /// - Parameters:
  ///   - baseFrequency: Starting frequency in Hz
  ///   - duration: Duration in seconds
  ///   - pitchDrop: How much the frequency drops over time (Hz)
  ///   - wobbleRate: Vibrato rate in Hz
  ///   - wobbleDepth: Vibrato depth in Hz
  public func playJellyTone(
    baseFrequency: Double,
    duration: Double,
    pitchDrop: Double,
    wobbleRate: Double,
    wobbleDepth: Double
  ) {
    let sampleRate = format.sampleRate
    let frameCount = AVAudioFrameCount(sampleRate * duration)

    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
    buffer.frameLength = frameCount

    let data = buffer.floatChannelData![0]
    var phase = 0.0

    for i in 0..<Int(frameCount) {
      let t = Double(i) / sampleRate
      let progress = t / duration

      // Frequency drops over time (pitch bend down)
      let freq = baseFrequency - (pitchDrop * progress)

      // Add wobble/vibrato that decays over time
      let wobble = sin(2.0 * .pi * wobbleRate * t) * wobbleDepth * (1.0 - progress)
      let instantFreq = freq + wobble

      // Soft attack, smooth decay envelope
      let attack = min(t / 0.01, 1.0)  // 10ms attack
      let decay = 1.0 - progress
      let envelope = attack * decay * decay  // Quadratic decay for softness

      // Accumulate phase for smooth frequency changes
      phase += instantFreq / sampleRate
      data[i] = Float(sin(2.0 * .pi * phase) * envelope * 0.4)
    }

    playerNode.scheduleBuffer(buffer, at: nil)
    if !playerNode.isPlaying {
      playerNode.play()
    }
  }

  /// Play a quick whip/squash sound with upward pitch sweep.
  public func playWhipTone(
    startFrequency: Double,
    endFrequency: Double,
    duration: Double
  ) {
    let sampleRate = format.sampleRate
    let frameCount = AVAudioFrameCount(sampleRate * duration)

    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
    buffer.frameLength = frameCount

    let data = buffer.floatChannelData![0]
    var phase = 0.0

    for i in 0..<Int(frameCount) {
      let t = Double(i) / sampleRate
      let progress = t / duration

      // Exponential frequency sweep (fast rise, then settles)
      let sweepCurve = 1.0 - pow(1.0 - progress, 3.0)  // Cubic ease-out
      let freq = startFrequency + (endFrequency - startFrequency) * sweepCurve

      // Quick attack, fast decay envelope
      let attack = min(t / 0.005, 1.0)  // 5ms attack
      let decay = pow(1.0 - progress, 2.0)  // Quadratic decay
      let envelope = attack * decay

      // Accumulate phase
      phase += freq / sampleRate
      data[i] = Float(sin(2.0 * .pi * phase) * envelope * 0.5)
    }

    playerNode.scheduleBuffer(buffer, at: nil)
    if !playerNode.isPlaying {
      playerNode.play()
    }
  }

  /// Play the "on" sound - quick upward whip/squash.
  public func playOn() {
    playWhipTone(
      startFrequency: 150,
      endFrequency: 600,
      duration: 0.08
    )
  }

  /// Play the "off" sound - lower, softer wobble.
  public func playOff() {
    playJellyTone(
      baseFrequency: 180,
      duration: 0.12,
      pitchDrop: 50,
      wobbleRate: 20,
      wobbleDepth: 20
    )
  }

  /// Play a mechanical click sound like a light switch.
  /// - Parameter ascending: If true, plays a slightly brighter click; if false, plays a duller click.
  public func playClick(ascending: Bool = true) {
    let sampleRate = format.sampleRate
    let duration = 0.015  // 15ms - very short
    let frameCount = AVAudioFrameCount(sampleRate * duration)

    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
    buffer.frameLength = frameCount

    let data = buffer.floatChannelData![0]

    // Base frequency for the click body
    let baseFreq = ascending ? 2200.0 : 1800.0

    for i in 0..<Int(frameCount) {
      let t = Double(i) / sampleRate
      let progress = t / duration

      // Very sharp attack (1ms), instant decay
      let attack = min(t / 0.001, 1.0)
      let decay = pow(1.0 - progress, 4.0)  // Steep quartic decay
      let envelope = attack * decay

      // Mix of frequencies for a more mechanical sound
      let click = sin(2.0 * .pi * baseFreq * t)
        + 0.5 * sin(2.0 * .pi * baseFreq * 2.3 * t)  // Inharmonic overtone
        + 0.3 * sin(2.0 * .pi * baseFreq * 3.7 * t)  // Another inharmonic

      data[i] = Float(click * envelope * 0.25)
    }

    playerNode.scheduleBuffer(buffer, at: nil)
    if !playerNode.isPlaying {
      playerNode.play()
    }
  }
}
