//
//  JellyButton.swift
//  ShaderKitUI
//
//  An interactive 3D jelly button with spring physics.
//

import SwiftUI
import simd

/// An interactive 3D jelly button with spring physics.
///
/// A circular jelly button that squishes on tap, wiggles during long press,
/// and bounces back with physics animation on release.
///
/// Example:
/// ```swift
/// struct ContentView: View {
///   var body: some View {
///     JellyButton {
///       print("Button pressed!")
///     }
///     .ignoresSafeArea()
///   }
/// }
/// ```
///
/// With customization:
/// ```swift
/// JellyButton(
///   action: { doSomething() },
///   jellyColor: .blue,
///   darkMode: true,
///   soundEnabled: false
/// )
/// ```
public struct JellyButton: View {
  private let action: () -> Void
  private let jellyColor: Color
  private let darkMode: Bool
  private let soundEnabled: Bool

  @State private var physics = JellyButtonPhysicsState()
  @State private var toneGenerator = ToneGenerator()

  /// Creates a jelly button.
  ///
  /// - Parameters:
  ///   - action: Closure to execute when the button is tapped
  ///   - jellyColor: Color of the jelly (default: pink)
  ///   - darkMode: Whether to use dark ambient lighting (default: false)
  ///   - soundEnabled: Whether to play press/release sounds (default: true)
  public init(
    action: @escaping () -> Void,
    jellyColor: Color = Color(hue: 0.95, saturation: 0.75, brightness: 0.85),
    darkMode: Bool = false,
    soundEnabled: Bool = true
  ) {
    self.action = action
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
          .jellyButton(
            squashY: physics.squashYValue,
            squashX: physics.squashXValue,
            wiggle: physics.wiggleValue,
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
  }

  private func handleDragChanged(_ value: DragGesture.Value, in size: CGSize) {
    if isLocationWithinButton(value.location, size: size) {
      if !physics.isPressed {
        physics.press()
        if soundEnabled {
          toneGenerator.playOn()
        }
      }
    } else {
      if physics.isPressed {
        physics.release()
      }
    }
  }

  private func handleDragEnded(_ value: DragGesture.Value, in size: CGSize) {
    if physics.isPressed {
      physics.release()
      if soundEnabled {
        toneGenerator.playOff()
      }
      if isLocationWithinButton(value.location, size: size) {
        action()
      }
    }
  }

  private func isLocationWithinButton(_ location: CGPoint, size: CGSize) -> Bool {
    let bounds = buttonBounds(in: size)
    return bounds.contains(location)
  }

  private func buttonBounds(in size: CGSize) -> CGRect {
    let centerX = size.width * 0.5
    let centerY = size.height * 0.42
    let diameter = min(size.width, size.height) * 0.35
    return CGRect(
      x: centerX - diameter / 2,
      y: centerY - diameter / 2,
      width: diameter,
      height: diameter
    )
  }
}

/// Internal physics state for the jelly button animation.
@Observable
final class JellyButtonPhysicsState {
  private(set) var isPressed = false
  private var isLongPressing = false
  private var pressStartTime: Date?

  private var squashYSpring = Spring(mass: 1, stiffness: 400, damping: 6)
  private var squashXSpring = Spring(mass: 1, stiffness: 450, damping: 6)
  private var wiggleSpring = Spring(mass: 1, stiffness: 500, damping: 8)

  private var wigglePhase: Float = 0
  private var lastUpdate: Date?

  private let longPressThreshold: TimeInterval = 0.3

  var squashYValue: Float { squashYSpring.value }
  var squashXValue: Float { squashXSpring.value }
  var wiggleValue: Float { wiggleSpring.value }

  func press() {
    isPressed = true
    pressStartTime = Date()

    // Apply strong press impulse - squish it down!
    squashYSpring.velocity = -12.0
    squashXSpring.velocity = 8.0
    wiggleSpring.velocity = 5.0
  }

  func release() {
    let wasLongPressing = isLongPressing

    isPressed = false
    isLongPressing = false
    pressStartTime = nil

    // Apply release bounce - big springy pop!
    squashYSpring.velocity = 15.0
    squashXSpring.velocity = -12.0

    // Strong wiggle on release
    if wasLongPressing {
      wiggleSpring.velocity = 35.0  // Extra wobbly after long press
      wigglePhase = 0
    } else {
      wiggleSpring.velocity = 20.0  // Nice visible wobble
    }
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

    // Check for long press threshold
    if isPressed, let startTime = pressStartTime {
      let elapsed = now.timeIntervalSince(startTime)
      if elapsed >= longPressThreshold && !isLongPressing {
        isLongPressing = true
      }
    }

    // Apply subtle squash impulses during long press (gentle jiggle in place)
    if isLongPressing {
      wigglePhase += clampedDt * 20.0  // Jiggle frequency
      let jiggleImpulse = sin(wigglePhase) * clampedDt * 30
      squashYSpring.velocity += jiggleImpulse
      squashXSpring.velocity -= jiggleImpulse * 0.6
    }

    // Update all springs
    squashYSpring.update(dt: clampedDt)
    squashXSpring.update(dt: clampedDt)
    wiggleSpring.update(dt: clampedDt)
  }
}
