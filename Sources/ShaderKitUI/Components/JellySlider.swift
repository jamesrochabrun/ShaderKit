//
//  JellySlider.swift
//  ShaderKitUI
//
//  An interactive 3D jelly slider with rope-style spring physics.
//

import ShaderKit
import SwiftUI
import simd

/// An interactive 3D jelly slider with spring physics.
///
/// `JellySlider` renders a translucent jelly track whose endpoint can be dragged
/// horizontally. Compressing the track causes it to arch and settle with a
/// soft spring motion.
public struct JellySlider: View {
  @Binding private var value: Double
  private let bounds: ClosedRange<Double>
  private let jellyColor: Color
  private let darkMode: Bool
  private let soundEnabled: Bool

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @State private var physics = JellySliderPhysicsState()
  @State private var toneGenerator = ToneGenerator()
  @State private var dragStartProgress: Float = 0

  /// Creates a jelly slider.
  ///
  /// - Parameters:
  ///   - value: Binding to the slider value
  ///   - bounds: Closed range for the slider value
  ///   - jellyColor: Color of the jelly
  ///   - darkMode: Whether to use dark ambient lighting
  ///   - soundEnabled: Whether to play release sounds
  public init(
    value: Binding<Double>,
    in bounds: ClosedRange<Double> = 0...1,
    jellyColor: Color = Color(red: 1.0, green: 0.45, blue: 0.075),
    darkMode: Bool = false,
    soundEnabled: Bool = true
  ) {
    self._value = value
    self.bounds = bounds
    self.jellyColor = jellyColor
    self.darkMode = darkMode
    self.soundEnabled = soundEnabled
  }

  private var jellyColorSIMD: SIMD4<Float> {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
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
        let packs = physics.pointPacks
        let controlPacks = physics.controlPointPacks

        Rectangle()
          .fill(darkMode ? Color.black : Color(white: 0.95))
          .shaderContext(tilt: .zero, time: timeline.date.timeIntervalSince1970)
          .layerEffect(
            ShaderKit.shaders.jellySlider(
              .float2(geometry.size.width, geometry.size.height),
              .float2(0, 0),
              .float(timeline.date.timeIntervalSince1970),
              .float4(packs[0].x, packs[0].y, packs[0].z, packs[0].w),
              .float4(packs[1].x, packs[1].y, packs[1].z, packs[1].w),
              .float4(packs[2].x, packs[2].y, packs[2].z, packs[2].w),
              .float4(packs[3].x, packs[3].y, packs[3].z, packs[3].w),
              .float4(packs[4].x, packs[4].y, packs[4].z, packs[4].w),
              .float4(packs[5].x, packs[5].y, packs[5].z, packs[5].w),
              .float4(packs[6].x, packs[6].y, packs[6].z, packs[6].w),
              .float4(packs[7].x, packs[7].y, packs[7].z, packs[7].w),
              .float4(packs[8].x, packs[8].y, packs[8].z, packs[8].w),
              .float4(controlPacks[0].x, controlPacks[0].y, controlPacks[0].z, controlPacks[0].w),
              .float4(controlPacks[1].x, controlPacks[1].y, controlPacks[1].z, controlPacks[1].w),
              .float4(controlPacks[2].x, controlPacks[2].y, controlPacks[2].z, controlPacks[2].w),
              .float4(controlPacks[3].x, controlPacks[3].y, controlPacks[3].z, controlPacks[3].w),
              .float4(controlPacks[4].x, controlPacks[4].y, controlPacks[4].z, controlPacks[4].w),
              .float4(controlPacks[5].x, controlPacks[5].y, controlPacks[5].z, controlPacks[5].w),
              .float4(controlPacks[6].x, controlPacks[6].y, controlPacks[6].z, controlPacks[6].w),
              .float4(controlPacks[7].x, controlPacks[7].y, controlPacks[7].z, controlPacks[7].w),
              .float(physics.normalizedProgress),
              .float4(jellyColorSIMD.x, jellyColorSIMD.y, jellyColorSIMD.z, jellyColorSIMD.w),
              .float3(lightDirection.x, lightDirection.y, lightDirection.z),
              .float(darkMode ? 1.0 : 0.0)
            ),
            maxSampleOffset: .zero
          )
          .contentShape(Rectangle())
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { gesture in
                handleDragChanged(gesture, in: geometry.size)
              }
              .onEnded { gesture in
                handleDragEnded(gesture, in: geometry.size)
              }
          )
      }
      .onChange(of: timeline.date) { _, newDate in
        physics.update(now: newDate, reduceMotion: reduceMotion)
        if physics.isDragging {
          setValueFromNormalized(physics.normalizedProgress)
        }
      }
    }
    .onAppear {
      physics.setNormalizedTarget(normalizedValue(for: value), immediate: true)
    }
    .onChange(of: value) { _, newValue in
      if !physics.isDragging {
        physics.setNormalizedTarget(normalizedValue(for: newValue), immediate: false)
      }
    }
    .accessibilityRepresentation {
      Slider(value: $value, in: bounds) {
        Text("Jelly Slider")
      }
    }
  }

  private func handleDragChanged(_ gesture: DragGesture.Value, in size: CGSize) {
    let targetX = dragTargetX(for: gesture.location, in: size)

    if !physics.isDragging {
      physics.startDrag(at: targetX)
      dragStartProgress = physics.normalizedProgress
    } else {
      physics.updateDragTarget(targetX)
    }
  }

  private func handleDragEnded(_: DragGesture.Value, in _: CGSize) {
    physics.endDrag()
    setValueFromNormalized(physics.normalizedProgress)

    if soundEnabled {
      toneGenerator.playClick(ascending: physics.normalizedProgress >= dragStartProgress)
    }
  }

  private func dragTargetX(for location: CGPoint, in size: CGSize) -> Float {
    physics.dragTargetX(for: Float(location.x / max(size.width, 1)))
  }

  private func normalizedValue(for value: Double) -> Float {
    let span = max(bounds.upperBound - bounds.lowerBound, .leastNonzeroMagnitude)
    let normalized = (value - bounds.lowerBound) / span
    return min(1, max(0, Float(normalized)))
  }

  private func setValueFromNormalized(_ normalized: Float) {
    let clamped = min(1, max(0, normalized))
    let next = bounds.lowerBound + Double(clamped) * (bounds.upperBound - bounds.lowerBound)
    if abs(value - next) > 0.0001 {
      value = next
    }
  }
}

@Observable
final class JellySliderPhysicsState {
  private static let pointCount = 17
  private static let mouseSmoothing: Float = 0.08
  private static let mouseMinX: Float = 0.45
  private static let mouseMaxX: Float = 0.9
  private static let mouseRangeMin: Float = 0.4
  private static let mouseRangeMax: Float = 0.9
  private static let sourceTargetMinX: Float = -0.7
  private static let sourceTargetMaxX: Float = 1.0
  private static let targetOffsetX: Float = -0.5
  private static let targetMinX: Float = -0.33
  private static let targetMaxX: Float = 0.9

  private let anchor = SIMD2<Float>(-1.0, 0.0)
  private let baseY: Float = 0.0
  private let yOffset: Float = -0.03
  private let totalLength: Float = 1.9
  private let restLength: Float

  @ObservationIgnored private var positions: [SIMD2<Float>]
  @ObservationIgnored private var normals: [SIMD2<Float>]
  @ObservationIgnored private var controlPoints: [SIMD2<Float>]
  @ObservationIgnored private var previousPositions: [SIMD2<Float>]
  @ObservationIgnored private var inverseMass: [Float]
  @ObservationIgnored private var targetX: Float = JellySliderPhysicsState.targetMaxX
  @ObservationIgnored private var dragX: Float = JellySliderPhysicsState.targetMaxX
  @ObservationIgnored private var lastUpdate: Date?

  private(set) var isDragging = false

  var iterations = 16
  var substeps = 6
  var damping: Float = 0.01
  var bendingStrength: Float = 0.1
  var archStrength: Float = 2.0
  var endFlatCount = 1
  var endFlatStiffness: Float = 0.05
  var bendingExponent: Float = 1.2
  var archEdgeDeadzone: Float = 0.01

  var normalizedProgress: Float {
    let span = Self.targetMaxX - Self.targetMinX
    return min(1, max(0, (targetX - Self.targetMinX) / span))
  }

  var pointPacks: [SIMD4<Float>] {
    var packs = Array(repeating: SIMD4<Float>(repeating: 0), count: 9)

    for index in 0..<Self.pointCount {
      let point = positions[index]
      let packIndex = index / 2
      if index.isMultiple(of: 2) {
        packs[packIndex].x = point.x
        packs[packIndex].y = point.y
      } else {
        packs[packIndex].z = point.x
        packs[packIndex].w = point.y
      }
    }

    return packs
  }

  var controlPointPacks: [SIMD4<Float>] {
    var packs = Array(repeating: SIMD4<Float>(repeating: 0), count: 8)

    for index in 0..<(Self.pointCount - 1) {
      let point = controlPoints[index]
      let packIndex = index / 2
      if index.isMultiple(of: 2) {
        packs[packIndex].x = point.x
        packs[packIndex].y = point.y
      } else {
        packs[packIndex].z = point.x
        packs[packIndex].w = point.y
      }
    }

    return packs
  }

  init() {
    restLength = totalLength / Float(Self.pointCount - 1)
    positions = Array(repeating: .zero, count: Self.pointCount)
    normals = Array(repeating: SIMD2<Float>(0, 1), count: Self.pointCount)
    controlPoints = Array(repeating: .zero, count: Self.pointCount - 1)
    previousPositions = Array(repeating: .zero, count: Self.pointCount)
    inverseMass = Array(repeating: 1, count: Self.pointCount)

    for index in 0..<Self.pointCount {
      let t = Float(index) / Float(Self.pointCount - 1)
      let x = anchor.x * (1 - t) + Self.targetMaxX * t
      let y = anchor.y + yOffset
      let position = SIMD2<Float>(x, y)
      positions[index] = position
      previousPositions[index] = position
      inverseMass[index] = index == 0 || index == Self.pointCount - 1 ? 0 : 1
    }

    computeNormals()
    computeControlPoints()
  }

  func setNormalizedTarget(_ normalized: Float, immediate: Bool) {
    targetX = xPosition(for: normalized)
    dragX = targetX

    if immediate {
      resetLine(to: targetX)
      lastUpdate = nil
    }
  }

  func startDrag(at x: Float) {
    isDragging = true
    dragX = x
  }

  func updateDragTarget(_ x: Float) {
    dragX = x
  }

  func endDrag() {
    isDragging = false
  }

  func update(now: Date, reduceMotion: Bool) {
    let dt: Float
    if let lastUpdate {
      dt = Float(lastUpdate.distance(to: now))
      if dt <= 0 {
        return
      }
    } else {
      dt = 0.016
    }
    self.lastUpdate = now

    let clampedDt = min(dt, 0.05)
    let damp = reduceMotion ? 0.2 : damping
    let arch = reduceMotion ? archStrength * 0.25 : archStrength
    let h = clampedDt / Float(substeps)

    if isDragging {
      let smoothing = reduceMotion ? 1 : Self.mouseSmoothing
      targetX += (dragX - targetX) * smoothing
    }

    let compression = max(0, 1 - abs(targetX - anchor.x) / totalLength)

    for _ in 0..<substeps {
      integrate(h: h, damp: damp, compression: compression, arch: arch)
      projectConstraints()
    }

    computeNormals()
    computeControlPoints()
  }

  private func resetLine(to targetX: Float) {
    for index in 0..<Self.pointCount {
      let t = Float(index) / Float(Self.pointCount - 1)
      let x = anchor.x * (1 - t) + targetX * t
      let y = anchor.y + yOffset
      let position = SIMD2<Float>(x, y)
      positions[index] = position
      previousPositions[index] = position
    }

    computeNormals()
    computeControlPoints()
  }

  private func xPosition(for normalized: Float) -> Float {
    let clamped = min(1, max(0, normalized))
    return Self.targetMinX + (Self.targetMaxX - Self.targetMinX) * clamped
  }

  func dragTargetX(for pointerX: Float) -> Float {
    let clampedPointer = min(Self.mouseMaxX, max(Self.mouseMinX, pointerX))
    let target = ((clampedPointer - Self.mouseRangeMin) / (Self.mouseRangeMax - Self.mouseRangeMin))
      * (Self.sourceTargetMaxX - Self.sourceTargetMinX)
      + Self.targetOffsetX
    return min(Self.targetMaxX, max(Self.targetMinX, target))
  }

  private func integrate(h: Float, damp: Float, compression: Float, arch: Float) {
    for index in 0..<Self.pointCount {
      let point = positions[index]

      if index == 0 {
        let pinned = SIMD2<Float>(anchor.x, anchor.y + yOffset)
        positions[index] = pinned
        previousPositions[index] = pinned
        continue
      }

      if index == Self.pointCount - 1 {
        let pinned = SIMD2<Float>(targetX, 0.08 + yOffset)
        positions[index] = pinned
        previousPositions[index] = pinned
        continue
      }

      let velocity = (point - previousPositions[index]) * (1 - min(damp, 0.999))
      var accelerationY: Float = 0

      if compression > 0 {
        let t = Float(index) / Float(Self.pointCount - 1)
        let edge = archEdgeDeadzone
        let window = smoothstep(edge, 1 - edge, t) * smoothstep(edge, 1 - edge, 1 - t)
        let profile = sin(.pi * t) * window
        accelerationY = arch * profile * compression
      }

      previousPositions[index] = point
      positions[index] = SIMD2<Float>(
        point.x + velocity.x,
        point.y + velocity.y + accelerationY * h * h
      )

      let floorY = baseY + yOffset
      if positions[index].y < floorY {
        positions[index].y = floorY
      }
    }
  }

  private func projectConstraints() {
    for _ in 0..<iterations {
      for index in 0..<(Self.pointCount - 1) {
        projectDistance(index, index + 1, rest: restLength, strength: 0.1)
      }

      for index in 1..<(Self.pointCount - 1) {
        let t = Float(index) / Float(Self.pointCount - 1)
        let distFromCenter = abs(t - 0.5) * 2
        let strength = pow(distFromCenter, bendingExponent)
        let k = bendingStrength * (0.05 + 0.95 * strength)
        projectDistance(index - 1, index + 1, rest: 2 * restLength, strength: k)
      }

      if endFlatCount > 0 {
        let count = min(endFlatCount, Self.pointCount - 2)
        for index in 1...count {
          projectLineY(index, targetY: baseY + yOffset, strength: endFlatStiffness)
        }
        for index in (Self.pointCount - 1 - count)..<(Self.pointCount - 1) {
          projectLineY(index, targetY: baseY + yOffset, strength: endFlatStiffness)
        }
      }

      positions[0] = SIMD2<Float>(anchor.x, anchor.y + yOffset)
      positions[Self.pointCount - 1] = SIMD2<Float>(targetX, 0.08 + yOffset)
    }
  }

  private func projectDistance(_ i: Int, _ j: Int, rest: Float, strength: Float) {
    let delta = positions[j] - positions[i]
    let length = simd_length(delta)
    if length < 1.0e-8 {
      return
    }

    let w1 = inverseMass[i]
    let w2 = inverseMass[j]
    let weightSum = w1 + w2
    if weightSum <= 0 {
      return
    }

    let diff = (length - rest) / length
    let c1 = (w1 / weightSum) * strength
    let c2 = (w2 / weightSum) * strength

    positions[i] += delta * diff * c1
    positions[j] -= delta * diff * c2
  }

  private func projectLineY(_ index: Int, targetY: Float, strength: Float) {
    if index <= 0 || index >= Self.pointCount - 1 || inverseMass[index] <= 0 {
      return
    }

    positions[index].y += (targetY - positions[index].y) * min(1, max(0, strength))
  }

  private func computeNormals() {
    let eps: Float = 1.0e-6

    for index in 0..<Self.pointCount {
      var tangent: SIMD2<Float>

      if index == 0 {
        tangent = positions[1] - positions[0]
      } else if index == Self.pointCount - 1 {
        tangent = positions[Self.pointCount - 1] - positions[Self.pointCount - 2]
      } else {
        tangent = positions[index + 1] - positions[index - 1]
      }

      var length = simd_length(tangent)
      if length < eps {
        if index > 0 {
          tangent = positions[index] - positions[index - 1]
          length = simd_length(tangent)
        }
        if length < eps && index < Self.pointCount - 1 {
          tangent = positions[index + 1] - positions[index]
          length = simd_length(tangent)
        }
        if length < eps {
          normals[index] = index > 0 ? normals[index - 1] : SIMD2<Float>(0, 1)
          continue
        }
      }

      tangent /= length
      normals[index] = SIMD2<Float>(-tangent.y, tangent.x)
    }
  }

  private func computeControlPoints() {
    for index in 0..<(Self.pointCount - 1) {
      let start = positions[index]
      let end = positions[index + 1]

      if index == 0 || index == Self.pointCount - 2 {
        controlPoints[index] = (start + end) * 0.5
        continue
      }

      let startNormal = normals[index]
      let endNormal = normals[index + 1]

      if simd_dot(startNormal, endNormal) > 0.99 {
        controlPoints[index] = (start + end) * 0.5
        continue
      }

      let startTangent = SIMD2<Float>(startNormal.y, -startNormal.x)
      let endTangent = SIMD2<Float>(endNormal.y, -endNormal.x)
      let delta = end - start
      let denom = startTangent.x * endTangent.y - startTangent.y * endTangent.x

      if abs(denom) <= 1.0e-6 {
        controlPoints[index] = (start + end) * 0.5
        continue
      }

      let t = (delta.x * endTangent.y - delta.y * endTangent.x) / denom
      controlPoints[index] = start + startTangent * t
    }
  }

  private func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
    let t = min(1, max(0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)
  }
}
