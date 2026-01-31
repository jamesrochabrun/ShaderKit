//
//  JellySwitchView.swift
//  ShaderKitDemo
//
//  Interactive 3D jelly switch demo with spring physics
//

import SwiftUI
import ShaderKit
import simd

@Observable
private final class JellyPhysicsState {
  // Toggle state
  var toggled = false

  // Physics values
  var progress: Float = 0
  var velocity: Float = 0
  var squashXValue: Float = 0
  var squashXVelocity: Float = 0
  var squashZValue: Float = 0
  var squashZVelocity: Float = 0
  var wiggleXValue: Float = 0
  var wiggleXVelocity: Float = 0

  // Spring parameters - from original TypeGPU implementation
  private let squashXStiffness: Float = 1000
  private let squashXDamping: Float = 10
  private let squashZStiffness: Float = 900
  private let squashZDamping: Float = 12
  private let wiggleXStiffness: Float = 1000
  private let wiggleXDamping: Float = 20

  // Movement acceleration (from original: SWITCH_ACCELERATION = 100)
  private let switchAcceleration: Float = 100

  // Timing
  private var lastUpdate: Date?

  func toggle() {
    toggled.toggle()

    // Apply impulse to springs (from original TypeGPU switch.ts)
    squashXVelocity = -2.0
    squashZVelocity = 1.0
    wiggleXVelocity = 1.0 * (progress > 0.5 ? 1.0 : -1.0)
  }

  func update(now: Date) {
    let dt: Float
    if let last = lastUpdate {
      dt = min(Float(last.distance(to: now)), 0.05)
    } else {
      dt = 0.016
    }
    lastUpdate = now

    // Update progress with acceleration (not spring) like original
    let targetProgress: Float = toggled ? 1.0 : 0.0
    let direction: Float = targetProgress > progress ? 1.0 : -1.0
    velocity += direction * switchAcceleration * dt
    velocity *= 0.9 // damping
    progress += velocity * dt
    progress = max(0, min(1, progress))

    // Transfer momentum to wiggle when reaching bounds
    if progress <= 0 || progress >= 1 {
      wiggleXVelocity += velocity * 0.5
      velocity = 0
    }

    // Update squashX spring
    let squashXForce = -squashXStiffness * squashXValue
    let squashXDampingForce = -squashXDamping * squashXVelocity
    squashXVelocity += (squashXForce + squashXDampingForce) * dt
    squashXValue += squashXVelocity * dt

    // Update squashZ spring
    let squashZForce = -squashZStiffness * squashZValue
    let squashZDampingForce = -squashZDamping * squashZVelocity
    squashZVelocity += (squashZForce + squashZDampingForce) * dt
    squashZValue += squashZVelocity * dt

    // Update wiggleX spring
    let wiggleXForce = -wiggleXStiffness * wiggleXValue
    let wiggleXDampingForce = -wiggleXDamping * wiggleXVelocity
    wiggleXVelocity += (wiggleXForce + wiggleXDampingForce) * dt
    wiggleXValue += wiggleXVelocity * dt
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
