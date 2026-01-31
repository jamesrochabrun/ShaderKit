//
//  JellySwitchView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly switch demo with spring physics
//

import SwiftUI
import ShaderKit
import simd

/// Spring physics matching TypeGPU Spring class exactly
private struct Spring {
  var value: Float = 0
  var target: Float = 0
  var velocity: Float = 0
  let mass: Float
  let stiffness: Float
  let damping: Float

  mutating func update(dt: Float) {
    let F_spring = -stiffness * (value - target)
    let F_damp = -damping * velocity
    let a = (F_spring + F_damp) / mass
    velocity = velocity + a * dt
    value = value + velocity * dt
  }
}

/// Switch behavior matching TypeGPU SwitchBehavior class exactly
@Observable
private final class JellyPhysicsState {
  // State
  var toggled = false
  var pressed = false

  // Derived physical state
  private var progress_: Float = 0
  private var velocity_: Float = 0
  private var squashXSpring = Spring(mass: 1, stiffness: 1000, damping: 10)
  private var squashZSpring = Spring(mass: 1, stiffness: 900, damping: 12)
  private var wiggleXSpring = Spring(mass: 1, stiffness: 1000, damping: 20)

  // SWITCH_ACCELERATION = 100
  private let switchAcceleration: Float = 100

  // Exposed values for shader
  var progress: Float { progress_ }
  var squashXValue: Float { squashXSpring.value }
  var squashZValue: Float { squashZSpring.value }
  var wiggleXValue: Float { wiggleXSpring.value }

  // Timing
  private var lastUpdate: Date?

  func toggle() {
    toggled.toggle()
    pressed = true

    // Schedule release after a short delay (simulating press-release)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
      self?.pressed = false
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

    // Clamp dt to avoid instability
    let clampedDt = min(dt, 0.05)

    var acc: Float = 0
    if toggled && progress_ < 1 {
      acc = switchAcceleration
    }
    if !toggled && progress_ > 0 {
      acc = -switchAcceleration
    }

    // Anticipating movement (when pressed)
    if pressed {
      squashXSpring.velocity = -2
      squashZSpring.velocity = 1
      wiggleXSpring.velocity = 1 * (progress_ > 0.5 ? 1.0 : -1.0)
    }

    velocity_ = velocity_ + acc * clampedDt

    // Transfer velocity to wiggle while moving
    if progress_ > 0 && progress_ < 1 {
      wiggleXSpring.velocity = velocity_
    }

    progress_ = progress_ + velocity_ * clampedDt

    // Overshoot handling
    if progress_ > 1 {
      progress_ = 1
      // Converting leftover velocity to compression
      velocity_ = 0
      squashXSpring.velocity = -5
      squashZSpring.velocity = 5
      wiggleXSpring.velocity = -10
    }
    if progress_ < 0 {
      progress_ = 0
      // Converting leftover velocity to compression
      velocity_ = 0
      squashXSpring.velocity = -5
      squashZSpring.velocity = 5
      wiggleXSpring.velocity = 10
    }

    // Clamp progress (saturate)
    progress_ = max(0, min(1, progress_))

    // Spring dynamics
    squashXSpring.update(dt: clampedDt)
    squashZSpring.update(dt: clampedDt)
    wiggleXSpring.update(dt: clampedDt)
  }
}

struct JellySwitchView: View {
  @State private var physics = JellyPhysicsState()

  // Appearance - default blue color from original TypeGPU: [0.08, 0.5, 1.0]
  @State private var jellyHue: Double = 0.58
  @State private var jellySaturation: Double = 0.92
  @State private var jellyBrightness: Double = 1.0
  @State private var darkMode = false

  private var jellyColor: SIMD4<Float> {
    let color = Color(hue: jellyHue, saturation: jellySaturation, brightness: jellyBrightness)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    #if os(iOS)
    UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    #else
    NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    #endif
    return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
  }

  // Light direction from original TypeGPU: normalize(vec3f(0.19, -0.24, 0.75))
  private var lightDirection: SIMD3<Float> {
    normalize(SIMD3<Float>(0.19, -0.24, 0.75))
  }

  var body: some View {
    ZStack {
      (darkMode ? Color.black : Color(white: 0.95))
        .ignoresSafeArea()

      VStack(spacing: 24) {
        // Shader view
        TimelineView(.animation) { timeline in
          Rectangle()
            .fill(darkMode ? Color.black : Color(white: 0.95))
            .frame(width: 300, height: 300)
            .shaderContext(tilt: .zero, time: timeline.date.timeIntervalSince1970)
            .jellySwitch(
              progress: physics.progress,
              squashX: physics.squashXValue,
              squashZ: physics.squashZValue,
              wiggleX: physics.wiggleXValue,
              jellyColor: jellyColor,
              lightDirection: lightDirection,
              darkMode: darkMode
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
            .onTapGesture {
              physics.toggle()
            }
            .onChange(of: timeline.date) { _, newDate in
              physics.update(now: newDate)
            }
        }

        // Controls
        ScrollView {
          VStack(spacing: 16) {
            // Toggle button
            Button {
              physics.toggle()
            } label: {
              Text(physics.toggled ? "ON" : "OFF")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 80, height: 40)
                .background(physics.toggled ? Color.green : Color.gray)
                .clipShape(Capsule())
            }

            Divider()

            // Color controls
            VStack(spacing: 12) {
              Text("Jelly Color")
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)

              ColorSliderRow(title: "Hue", value: $jellyHue, range: 0...1)
              ColorSliderRow(title: "Saturation", value: $jellySaturation, range: 0...1)
              ColorSliderRow(title: "Brightness", value: $jellyBrightness, range: 0.3...1)
            }

            Divider()

            // Dark mode toggle
            Toggle("Dark Mode", isOn: $darkMode)
          }
          .padding(16)
          .background(Color.white.opacity(darkMode ? 0.08 : 0.9))
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .padding(.horizontal, 16)
        }
      }
      .padding(.top, 16)
    }
    .navigationTitle("Jelly Switch")
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    #endif
  }
}

private struct ColorSliderRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>

  var body: some View {
    HStack(spacing: 12) {
      Text(title)
        .font(.caption)
        .frame(width: 80, alignment: .leading)
      Slider(value: $value, in: range)
      Text(String(format: "%.2f", value))
        .font(.caption)
        .monospacedDigit()
        .frame(width: 40, alignment: .trailing)
    }
  }
}

#Preview {
  NavigationStack {
    JellySwitchView()
  }
}
