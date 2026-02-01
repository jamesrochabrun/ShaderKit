//
//  JellySwitch.swift
//  ShaderKitUI
//
//  An interactive 3D jelly toggle switch with spring physics.
//  Inspired by TypeGPU's Jelly Switch example:
//  https://docs.swmansion.com/TypeGPU/examples/#example=rendering--jelly-switch
//

import SwiftUI
import simd

/// An interactive 3D jelly toggle switch with spring physics.
///
/// A full-screen toggle component that renders a realistic 3D jelly sphere
/// with physically-simulated spring animations. The jelly squishes, wobbles,
/// and bounces as users tap to toggle between on and off states.
///
/// Example:
/// ```swift
/// struct ContentView: View {
///   @State private var isEnabled = false
///
///   var body: some View {
///     JellySwitch(isOn: $isEnabled)
///       .ignoresSafeArea()
///   }
/// }
/// ```
///
/// With customization:
/// ```swift
/// JellySwitch(
///   isOn: $isEnabled,
///   jellyColor: .blue,
///   darkMode: true,
///   soundEnabled: false
/// )
/// ```
public struct JellySwitch: View {
  @Binding private var isOn: Bool
  private let jellyColor: Color
  private let darkMode: Bool
  private let soundEnabled: Bool

  @State private var physics = JellyPhysicsState()
  @State private var toneGenerator = ToneGenerator()
  @State private var isDragging = false

  /// Creates a jelly switch.
  ///
  /// - Parameters:
  ///   - isOn: Binding to the switch state
  ///   - jellyColor: Color of the jelly (default: purple)
  ///   - darkMode: Whether to use dark ambient lighting (default: false)
  ///   - soundEnabled: Whether to play toggle sounds (default: true)
  public init(
    isOn: Binding<Bool>,
    jellyColor: Color = Color(hue: 0.78, saturation: 0.85, brightness: 0.85),
    darkMode: Bool = false,
    soundEnabled: Bool = true
  ) {
    self._isOn = isOn
    self.jellyColor = jellyColor
    self.darkMode = darkMode
    self.soundEnabled = soundEnabled
  }

  private var jellyColorSIMD: SIMD4<Float> {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    #if os(iOS)
    UIColor(jellyColor).getRed(&r, green: &g, blue: &b, alpha: &a)
    #else
    NSColor(jellyColor).getRed(&r, green: &g, blue: &b, alpha: &a)
    #endif
    return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
  }

  private var lightDirection: SIMD3<Float> {
    normalize(SIMD3<Float>(0.19, -0.24, 0.75))
  }

  public var body: some View {
    TimelineView(.animation) { timeline in
      GeometryReader { geometry in
        Rectangle()
          .fill(darkMode ? Color.black : Color(white: 0.95))
          .shaderContext(tilt: .zero, time: timeline.date.timeIntervalSince1970)
          .jellySwitch(
            progress: physics.progress,
            squashX: physics.squashXValue,
            squashZ: physics.squashZValue,
            wiggleX: physics.wiggleXValue,
            jellyColor: jellyColorSIMD,
            lightDirection: lightDirection,
            darkMode: darkMode
          )
          .contentShape(Rectangle())
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                handleDragChanged(value, in: geometry.size)
              }
              .onEnded { value in
                handleDragEnded(value, in: geometry.size)
              }
          )
      }
      .onChange(of: timeline.date) { _, newDate in
        physics.update(now: newDate)
      }
    }
    .onAppear {
      physics.toggled = isOn
      physics.syncProgress(to: isOn)
    }
    .onChange(of: isOn) { _, newValue in
      if physics.toggled != newValue {
        physics.toggle()
      }
    }
  }

  private func handleDragChanged(_ value: DragGesture.Value, in size: CGSize) {
    if !isDragging {
      // Start drag only if horizontal movement exceeds threshold
      if abs(value.translation.width) > 8 {
        isDragging = true
        physics.startDrag()
      }
    }

    if isDragging {
      let dragDistance: CGFloat = 100
      let normalizedDelta = Float(value.translation.width / dragDistance)
      physics.updateDrag(normalizedDelta: normalizedDelta)
    }
  }

  private func handleDragEnded(_ value: DragGesture.Value, in size: CGSize) {
    if isDragging {
      let dragDistance: CGFloat = 100
      let normalizedVelocity = Float(value.velocity.width / dragDistance)
      physics.endDrag(normalizedVelocity: normalizedVelocity)
      isOn = physics.toggled
      playToggleSound()
    } else {
      // It was a tap - check if within switch bounds
      if isLocationWithinSwitch(value.location, size: size) {
        physics.toggle()
        isOn = physics.toggled
        playToggleSound()
      }
    }
    isDragging = false
  }

  private func isLocationWithinSwitch(_ location: CGPoint, size: CGSize) -> Bool {
    let bounds = switchBounds(in: size)
    return bounds.contains(location)
  }

  private func switchBounds(in size: CGSize) -> CGRect {
    let centerX = size.width * 0.5
    let centerY = size.height * 0.42
    let width = size.width * 0.28
    let height = size.height * 0.22
    return CGRect(
      x: centerX - width / 2,
      y: centerY - height / 2,
      width: width,
      height: height
    )
  }

  private func playToggleSound() {
    guard soundEnabled else { return }
    if physics.toggled {
      toneGenerator.playOn()
    } else {
      toneGenerator.playOff()
    }
  }
}

/// Internal physics state for the jelly switch animation.
@Observable
final class JellyPhysicsState {
  var toggled = false
  var pressed = false

  private var progress_: Float = 0
  private var velocity_: Float = 0
  private var squashXSpring = Spring(mass: 1, stiffness: 1000, damping: 10)
  private var squashZSpring = Spring(mass: 1, stiffness: 900, damping: 12)
  private var wiggleXSpring = Spring(mass: 1, stiffness: 1000, damping: 20)

  private let switchAcceleration: Float = 100
  private var lastUpdate: Date?

  private var isDragging = false
  private var dragStartProgress: Float = 0

  var progress: Float { progress_ }
  var squashXValue: Float { squashXSpring.value }
  var squashZValue: Float { squashZSpring.value }
  var wiggleXValue: Float { wiggleXSpring.value }

  func toggle() {
    toggled.toggle()
    pressed = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
      self?.pressed = false
    }
  }

  func syncProgress(to on: Bool) {
    progress_ = on ? 1 : 0
  }

  func startDrag() {
    isDragging = true
    dragStartProgress = progress_
    velocity_ = 0  // Stop any existing motion
  }

  func updateDrag(normalizedDelta: Float) {
    progress_ = max(0, min(1, dragStartProgress + normalizedDelta))
  }

  func endDrag(normalizedVelocity: Float) {
    isDragging = false

    // Predict final position with velocity (150ms lookahead)
    let predictedProgress = progress_ + normalizedVelocity * 0.15
    toggled = predictedProgress > 0.5

    // Transfer drag velocity to physics velocity
    velocity_ = normalizedVelocity * 50

    // Trigger squash effects on release
    squashXSpring.velocity = -3
    squashZSpring.velocity = 2
    wiggleXSpring.velocity = normalizedVelocity * 5
  }

  func update(now: Date) {
    let dt: Float
    if let last = lastUpdate {
      dt = Float(last.distance(to: now))
      if dt <= 0 { return }
    } else {
      dt = 0.016
    }
    lastUpdate = now

    let clampedDt = min(dt, 0.05)

    // Only apply automatic acceleration when NOT dragging
    var acc: Float = 0
    if !isDragging {
      if toggled && progress_ < 1 {
        acc = switchAcceleration
      }
      if !toggled && progress_ > 0 {
        acc = -switchAcceleration
      }
    }

    if pressed {
      squashXSpring.velocity = -2
      squashZSpring.velocity = 1
      wiggleXSpring.velocity = 1 * (progress_ > 0.5 ? 1.0 : -1.0)
    }

    velocity_ = velocity_ + acc * clampedDt

    if progress_ > 0 && progress_ < 1 {
      wiggleXSpring.velocity = velocity_
    }

    progress_ = progress_ + velocity_ * clampedDt

    if progress_ > 1 {
      progress_ = 1
      velocity_ = 0
      squashXSpring.velocity = -5
      squashZSpring.velocity = 5
      wiggleXSpring.velocity = -10
    }
    if progress_ < 0 {
      progress_ = 0
      velocity_ = 0
      squashXSpring.velocity = -5
      squashZSpring.velocity = 5
      wiggleXSpring.velocity = 10
    }

    progress_ = max(0, min(1, progress_))

    squashXSpring.update(dt: clampedDt)
    squashZSpring.update(dt: clampedDt)
    wiggleXSpring.update(dt: clampedDt)
  }
}
