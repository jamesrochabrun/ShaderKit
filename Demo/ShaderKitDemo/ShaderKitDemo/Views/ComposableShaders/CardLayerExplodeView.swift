//
//  CardLayerExplodeView.swift
//  ShaderKitDemo
//
//  Exploded card layer demo with slider-driven X/Y/Z rotation and depth spacing.
//

import SwiftUI
import ShaderKit

struct CardLayerExplodeCardConfiguration {
  var backgroundGradientColors: [Color]?
  var artworkImageName: String?
  var overlayGradientColors: [Color]?
  var shadersBetweenBackgroundAndArtwork: [ShaderEffect]
  var shadersOnTop: [ShaderEffect]
  var shaderInputGradientColors: [Color]
  var chromeBorderGradientColors: [Color]
  var showChromeLayer: Bool

  static let `default` = CardLayerExplodeCardConfiguration(
    backgroundGradientColors: [
      Color(red: 0.96, green: 0.88, blue: 0.56),
      Color(red: 0.9, green: 0.76, blue: 0.42),
      Color(red: 0.83, green: 0.67, blue: 0.33)
    ],
    artworkImageName: "unicorn",
    overlayGradientColors: [
      .black.opacity(0.22),
      .clear,
      .black.opacity(0.35)
    ],
    shadersBetweenBackgroundAndArtwork: [],
    shadersOnTop: [
      .foil(intensity: 1.0),
      .glitter(density: 75),
      .lightSweep
    ],
    shaderInputGradientColors: [
      .white.opacity(0.32),
      .yellow.opacity(0.12),
      .clear
    ],
    chromeBorderGradientColors: [
      .yellow.opacity(0.9),
      .white.opacity(0.7),
      .orange.opacity(0.9)
    ],
    showChromeLayer: true
  )
}

struct CardLayerExplodeView: View {
  private struct ShaderOption: Identifiable {
    let id: String
    let title: String
    let effect: ShaderEffect
  }

  private struct DragRotationStart {
    let xRotation: Double
    let yRotation: Double
    let zRotation: Double
    let startVector: CGPoint
  }

  private let cardWidth: CGFloat = 260
  private let cardHeight: CGFloat = 380
  private let cornerRadius: CGFloat = 16
  private let explodeAnimation = Animation.spring(
    response: 0.75,
    dampingFraction: 0.62,
    blendDuration: 0.08
  )

  @State private var xRotation: Double = 0
  @State private var yRotation: Double = 0
  @State private var zRotation: Double = 0
  @State private var layerDistance: Double = 0
  @State private var didAnimateIn = false
  @State private var dragStart: DragRotationStart?
  @State private var pinchStartDistance: Double?
  @State private var isPinching = false
  @State private var includesBackgroundLayer: Bool
  @State private var backgroundGradientColors: [Color]
  @State private var includesArtworkLayer: Bool
  @State private var artworkImageName: String
  @State private var includesOverlayLayer: Bool
  @State private var overlayGradientColors: [Color]
  @State private var shadersBetweenBackgroundAndArtwork: [ShaderEffect]
  @State private var shadersOnTop: [ShaderEffect]
  @State private var shaderInputGradientColors: [Color]
  @State private var chromeBorderGradientColors: [Color]
  @State private var showChromeLayer: Bool

  private let defaultXRotation: Double = 58
  private let defaultYRotation: Double = -12
  private let defaultZRotation: Double = 0
  private let defaultLayerDistance: Double = 0.055
  private let dragXRange: ClosedRange<Double> = -180...180
  private let dragYRange: ClosedRange<Double> = -180...180
  private let dragZRange: ClosedRange<Double> = -180...180
  private let showsLegacySliders = false

  init(cardConfiguration: CardLayerExplodeCardConfiguration = .default) {
    let defaultBackgroundColors = CardLayerExplodeCardConfiguration.default.backgroundGradientColors ?? [.orange, .yellow, .brown]
    let defaultOverlayColors = CardLayerExplodeCardConfiguration.default.overlayGradientColors ?? [.black.opacity(0.2), .clear, .black.opacity(0.35)]
    let defaultShaderColors = CardLayerExplodeCardConfiguration.default.shaderInputGradientColors
    let defaultChromeBorderColors = CardLayerExplodeCardConfiguration.default.chromeBorderGradientColors

    _includesBackgroundLayer = State(initialValue: cardConfiguration.backgroundGradientColors != nil)
    _backgroundGradientColors = State(initialValue: Self.colorStops(from: cardConfiguration.backgroundGradientColors, fallback: defaultBackgroundColors))
    let trimmedArtworkName = cardConfiguration.artworkImageName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    _includesArtworkLayer = State(initialValue: !trimmedArtworkName.isEmpty)
    _artworkImageName = State(initialValue: trimmedArtworkName.isEmpty ? (CardLayerExplodeCardConfiguration.default.artworkImageName ?? "unicorn") : trimmedArtworkName)
    _includesOverlayLayer = State(initialValue: cardConfiguration.overlayGradientColors != nil)
    _overlayGradientColors = State(initialValue: Self.colorStops(from: cardConfiguration.overlayGradientColors, fallback: defaultOverlayColors))
    _shadersBetweenBackgroundAndArtwork = State(initialValue: cardConfiguration.shadersBetweenBackgroundAndArtwork)
    _shadersOnTop = State(initialValue: cardConfiguration.shadersOnTop)
    _shaderInputGradientColors = State(initialValue: Self.colorStops(from: cardConfiguration.shaderInputGradientColors, fallback: defaultShaderColors))
    _chromeBorderGradientColors = State(initialValue: Self.colorStops(from: cardConfiguration.chromeBorderGradientColors, fallback: defaultChromeBorderColors))
    _showChromeLayer = State(initialValue: cardConfiguration.showChromeLayer)
  }

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      GeometryReader { proxy in
        let isWideLayout = proxy.size.width >= 980

        Group {
          if isWideLayout {
            HStack(spacing: 28) {
              editorColumn(fillsHeight: true)
                .frame(
                  width: min(450, max(340, proxy.size.width * 0.38)),
                  alignment: .topLeading
                )
                .frame(maxHeight: .infinity, alignment: .topLeading)

              cardPreview
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .leading
            )
          } else {
            VStack(spacing: 20) {
              cardPreview
              editorColumn(fillsHeight: false)
            }
            .frame(maxWidth: .infinity, alignment: .top)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
      }
    }
    .onAppear {
      guard !didAnimateIn else { return }
      didAnimateIn = true
      withAnimation(explodeAnimation) {
        xRotation = defaultXRotation
        yRotation = defaultYRotation
        zRotation = defaultZRotation
        layerDistance = defaultLayerDistance
      }
    }
  }

  private var cardPreview: some View {
    CardLayerExplodeContainer(
      width: cardWidth,
      height: cardHeight,
      cornerRadius: cornerRadius,
      xRotation: xRotation,
      yRotation: yRotation,
      zRotation: zRotation,
      layerDistance: layerDistance,
      shadowColor: .black,
      animation: explodeAnimation,
      layers: cardLayers
    )
    .frame(height: cardHeight + 120)
    .contentShape(Rectangle())
    .gesture(dragRotationGesture)
    .simultaneousGesture(pinchLayerGesture)
  }

  private func editorColumn(fillsHeight: Bool) -> some View {
    VStack(spacing: 12) {
      configPanel
        .frame(
          maxWidth: 450,
          maxHeight: fillsHeight ? .infinity : 340,
          alignment: .top
        )
        .padding(14)
        .background(
          RoundedRectangle(cornerRadius: 18)
            .fill(.ultraThinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            )
        )

      if showsLegacySliders {
        controls
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 18)
              .fill(.ultraThinMaterial)
              .overlay(
                RoundedRectangle(cornerRadius: 18)
                  .strokeBorder(.white.opacity(0.18), lineWidth: 1)
              )
          )
      }
    }
    .frame(maxHeight: fillsHeight ? .infinity : nil, alignment: .top)
  }

  private var dragRotationGesture: some Gesture {
    DragGesture(minimumDistance: 1, coordinateSpace: .local)
      .onChanged { value in
        guard !isPinching else {
          dragStart = nil
          return
        }

        let center = CGPoint(x: cardWidth * 0.5, y: cardHeight * 0.5)
        let currentVector = CGPoint(
          x: value.location.x - center.x,
          y: value.location.y - center.y
        )

        if dragStart == nil {
          let startVector = CGPoint(
            x: value.startLocation.x - center.x,
            y: value.startLocation.y - center.y
          )
          dragStart = DragRotationStart(
            xRotation: xRotation,
            yRotation: yRotation,
            zRotation: zRotation,
            startVector: startVector
          )
        }

        guard let dragStart else { return }

        let xDelta = Double(value.translation.height / cardHeight) * 180
        let yDelta = Double(value.translation.width / cardWidth) * 180
        xRotation = clamped(dragStart.xRotation - xDelta, to: dragXRange)
        yRotation = clamped(dragStart.yRotation + yDelta, to: dragYRange)

        let startLength = hypot(dragStart.startVector.x, dragStart.startVector.y)
        let currentLength = hypot(currentVector.x, currentVector.y)
        if startLength > 10, currentLength > 10 {
          let startAngle = atan2(dragStart.startVector.y, dragStart.startVector.x)
          let currentAngle = atan2(currentVector.y, currentVector.x)
          let zDelta = Double(normalizedAngle(currentAngle - startAngle) * 180 / .pi)
          zRotation = clamped(dragStart.zRotation + zDelta, to: dragZRange)
        }
      }
      .onEnded { _ in
        dragStart = nil
      }
  }

  private var pinchLayerGesture: some Gesture {
    MagnificationGesture()
      .onChanged { scale in
        isPinching = true
        dragStart = nil

        if pinchStartDistance == nil {
          pinchStartDistance = layerDistance
        }

        guard let pinchStartDistance else { return }
        let delta = Double(scale - 1) * 0.14
        layerDistance = clamped(pinchStartDistance + delta, to: 0...0.14)
      }
      .onEnded { _ in
        pinchStartDistance = nil
        isPinching = false
      }
  }

  private func clamped(_ value: Double, to range: ClosedRange<Double>) -> Double {
    Swift.max(range.lowerBound, Swift.min(value, range.upperBound))
  }

  private func normalizedAngle(_ angle: CGFloat) -> CGFloat {
    var normalized = angle
    let twoPi = CGFloat.pi * 2
    while normalized > .pi {
      normalized -= twoPi
    }
    while normalized < -.pi {
      normalized += twoPi
    }
    return normalized
  }

  private static let availableShaderOptions: [ShaderOption] = [
    ShaderOption(id: "foil", title: "Foil", effect: .foil(intensity: 1.0)),
    ShaderOption(id: "glitter", title: "Glitter", effect: .glitter(density: 75)),
    ShaderOption(id: "lightSweep", title: "Light Sweep", effect: .lightSweep),
    ShaderOption(id: "radialSweep", title: "Radial Sweep", effect: .radialSweep),
    ShaderOption(id: "sparkles", title: "Sparkles", effect: .sparkles),
    ShaderOption(id: "rainbowGlitter", title: "Rainbow Glitter", effect: .rainbowGlitter(intensity: 0.7)),
    ShaderOption(id: "shimmer", title: "Shimmer", effect: .shimmer(intensity: 0.7)),
    ShaderOption(id: "edgeShine", title: "Edge Shine", effect: .edgeShine),
    ShaderOption(id: "diamondGrid", title: "Diamond Grid", effect: .diamondGrid(intensity: 1.0)),
    ShaderOption(id: "blendedHolo", title: "Blended Holo", effect: .blendedHolo(intensity: 0.7, saturation: 0.75)),
    ShaderOption(id: "verticalBeams", title: "Vertical Beams", effect: .verticalBeams(intensity: 0.7)),
    ShaderOption(id: "diagonalHolo", title: "Diagonal Holo", effect: .diagonalHolo(intensity: 0.7)),
    ShaderOption(id: "galaxyHolo", title: "Galaxy Holo", effect: .galaxyHolo(intensity: 0.7)),
    ShaderOption(id: "subtleGradient", title: "Subtle Gradient", effect: .subtleGradient(intensity: 0.7))
  ]

  private static func colorStops(from colors: [Color]?, fallback: [Color]) -> [Color] {
    let source = (colors?.isEmpty == false) ? (colors ?? fallback) : fallback
    let first = source.first ?? .clear
    if source.count >= 3 { return Array(source.prefix(3)) }
    if source.count == 2 { return [source[0], source[1], source[1]] }
    return [first, first, first]
  }

  private var cardConfiguration: CardLayerExplodeCardConfiguration {
    CardLayerExplodeCardConfiguration(
      backgroundGradientColors: includesBackgroundLayer ? backgroundGradientColors : nil,
      artworkImageName: includesArtworkLayer ? artworkImageName : nil,
      overlayGradientColors: includesOverlayLayer ? overlayGradientColors : nil,
      shadersBetweenBackgroundAndArtwork: shadersBetweenBackgroundAndArtwork,
      shadersOnTop: shadersOnTop,
      shaderInputGradientColors: shaderInputGradientColors,
      chromeBorderGradientColors: chromeBorderGradientColors,
      showChromeLayer: showChromeLayer
    )
  }

  private var configPanel: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("Card Setup")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.white)

        Toggle("Background Gradient Layer", isOn: $includesBackgroundLayer)
          .tint(.orange)
          .foregroundStyle(.white)
        if includesBackgroundLayer {
          gradientColorEditor(title: "Background Colors", colors: $backgroundGradientColors)
        }

        Toggle("Artwork Layer", isOn: $includesArtworkLayer)
          .tint(.orange)
          .foregroundStyle(.white)
        if includesArtworkLayer {
          TextField("Artwork Asset Name", text: $artworkImageName)
#if os(iOS) || os(tvOS) || os(visionOS)
            .textInputAutocapitalization(.never)
#endif
            .autocorrectionDisabled()
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.14))
            )
            .foregroundStyle(.white)
        }

        Toggle("Overlay Gradient Layer", isOn: $includesOverlayLayer)
          .tint(.orange)
          .foregroundStyle(.white)
        if includesOverlayLayer {
          gradientColorEditor(title: "Overlay Colors", colors: $overlayGradientColors)
        }

        gradientColorEditor(title: "Shader Input Gradient", colors: $shaderInputGradientColors)

        shaderStackEditor(title: "Shaders Under Artwork", effects: $shadersBetweenBackgroundAndArtwork)
        shaderStackEditor(title: "Shaders On Top", effects: $shadersOnTop)

        Toggle("Chrome Layer", isOn: $showChromeLayer)
          .tint(.orange)
          .foregroundStyle(.white)
        if showChromeLayer {
          gradientColorEditor(title: "Chrome Border Colors", colors: $chromeBorderGradientColors)
        }
      }
    }
  }

  @ViewBuilder
  private func gradientColorEditor(title: String, colors: Binding<[Color]>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.white.opacity(0.9))

      HStack(spacing: 10) {
        ColorPicker("A", selection: colorBinding(colors, index: 0), supportsOpacity: true)
        ColorPicker("B", selection: colorBinding(colors, index: 1), supportsOpacity: true)
        ColorPicker("C", selection: colorBinding(colors, index: 2), supportsOpacity: true)
      }
      .font(.system(size: 11, weight: .medium))
      .foregroundStyle(.white.opacity(0.85))
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.white.opacity(0.08))
    )
  }

  private func colorBinding(_ colors: Binding<[Color]>, index: Int) -> Binding<Color> {
    Binding(
      get: {
        let array = colors.wrappedValue
        if array.indices.contains(index) {
          return array[index]
        }
        return .clear
      },
      set: { newValue in
        var array = colors.wrappedValue
        while array.count <= index {
          array.append(.clear)
        }
        array[index] = newValue
        colors.wrappedValue = array
      }
    )
  }

  @ViewBuilder
  private func shaderStackEditor(title: String, effects: Binding<[ShaderEffect]>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.white.opacity(0.9))
        Spacer()
        Menu("Add") {
          ForEach(Self.availableShaderOptions) { option in
            Button(option.title) {
              effects.wrappedValue.append(option.effect)
            }
          }
        }
        .font(.system(size: 12, weight: .semibold))
      }

      if effects.wrappedValue.isEmpty {
        Text("No shaders")
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(.white.opacity(0.6))
      } else {
        ForEach(Array(effects.wrappedValue.enumerated()), id: \.offset) { index, effect in
          HStack(spacing: 8) {
            Text(shaderTitle(for: effect))
              .font(.system(size: 11, weight: .medium))
              .foregroundStyle(.white)
            Spacer()
            Button {
              effects.wrappedValue.remove(at: index)
            } label: {
              Image(systemName: "minus.circle.fill")
                .foregroundStyle(.red.opacity(0.9))
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.white.opacity(0.08))
    )
  }

  private func shaderTitle(for effect: ShaderEffect) -> String {
    let id = String(describing: effect)
    return Self.availableShaderOptions.first(where: { String(describing: $0.effect) == id })?.title ?? id
  }

  private var controls: some View {
    VStack(spacing: 14) {
      ExplodeControlRow(
        title: "X Rotation",
        value: $xRotation,
        range: -180...180,
        valueText: "\(Int(xRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Y Rotation",
        value: $yRotation,
        range: -180...180,
        valueText: "\(Int(yRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Z Rotation",
        value: $zRotation,
        range: -180...180,
        valueText: "\(Int(zRotation.rounded()))°"
      )
      ExplodeControlRow(
        title: "Layer Distance",
        value: $layerDistance,
        range: 0...0.14,
        valueText: "\(Int((layerDistance * cardHeight).rounded())) pt",
        step: 0.001
      )
    }
    .tint(.orange)
  }

  private var cardLayers: [CardLayerExplodeLayer] {
    var generatedLayers: [CardLayerExplodeLayer] = []

    if let backgroundColors = normalizedGradientColors(cardConfiguration.backgroundGradientColors) {
      generatedLayers.append(
        CardLayerExplodeLayer(id: "base-fill") {
          baseFillLayer(colors: backgroundColors)
        }
      )
    }

    for (index, effect) in cardConfiguration.shadersBetweenBackgroundAndArtwork.enumerated() {
      generatedLayers.append(
        CardLayerExplodeLayer(id: effectLayerID(prefix: "shader-under", index: index, effect: effect)) {
          shaderEffectLayer(effect: effect)
        }
      )
    }

    if let artworkName = normalizedArtworkName {
      generatedLayers.append(
        CardLayerExplodeLayer(id: "artwork-\(artworkName)") {
          artworkLayer(imageName: artworkName)
        }
      )
    }

    if let overlayColors = normalizedGradientColors(cardConfiguration.overlayGradientColors) {
      generatedLayers.append(
        CardLayerExplodeLayer(id: "overlay-gradients") {
          overlayGradientLayer(colors: overlayColors)
        }
      )
    }

    for (index, effect) in cardConfiguration.shadersOnTop.enumerated() {
      generatedLayers.append(
        CardLayerExplodeLayer(id: effectLayerID(prefix: "shader-top", index: index, effect: effect)) {
          shaderEffectLayer(effect: effect)
        }
      )
    }

    if cardConfiguration.showChromeLayer {
      generatedLayers.append(
        CardLayerExplodeLayer(id: "ui-chrome") {
          uiChromeLayer
        }
      )
    }

    return generatedLayers
  }

  private var normalizedArtworkName: String? {
    guard
      let artworkImageName = cardConfiguration.artworkImageName?
        .trimmingCharacters(in: .whitespacesAndNewlines),
      !artworkImageName.isEmpty
    else {
      return nil
    }
    return artworkImageName
  }

  private func effectLayerID(prefix: String, index: Int, effect: ShaderEffect) -> String {
    "\(prefix)-\(index)-\(String(describing: effect))"
  }

  private func normalizedGradientColors(_ colors: [Color]?) -> [Color]? {
    guard let colors, !colors.isEmpty else { return nil }
    if colors.count == 1, let first = colors.first {
      return [first, first]
    }
    return colors
  }

  private func normalizedGradientColors(_ colors: [Color]) -> [Color]? {
    normalizedGradientColors(Optional(colors))
  }

  private func baseFillLayer(colors: [Color]) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: colors,
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                .white.opacity(0.24),
                .clear,
                .black.opacity(0.14)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
  }

  private func artworkLayer(imageName: String) -> some View {
    Image(imageName)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: cardWidth, height: cardHeight)
      .clipped()
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
  }

  private func overlayGradientLayer(colors: [Color]) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: colors,
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                .white.opacity(0.28),
                .clear
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
      .blendMode(.overlay)
  }

  private func shaderEffectLayer(effect: ShaderEffect) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(
        LinearGradient(
          colors: shaderInputGradientColors,
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .blendMode(.screen)
      .shader(effect)
  }

  private var uiChromeLayer: some View {
    ZStack {
      VStack(spacing: 0) {
        HStack(alignment: .top, spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("CARD FOIL")
              .font(.system(size: 10, weight: .heavy))
              .foregroundStyle(.white.opacity(0.9))
            Text("Exploded Composition")
              .font(.system(size: 17, weight: .black))
              .foregroundStyle(.white)
          }
          Spacer()
          Text("LV 180")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)

        Spacer()

        VStack(alignment: .leading, spacing: 7) {
          Text("Foil + Glitter + Light Sweep")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
          Text("Layered explode view with synchronized spring motion and stable z-ordering.")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white.opacity(0.82))
            .lineLimit(2)

          HStack {
            Label("Blend", systemImage: "circle.lefthalf.filled")
            Spacer()
            Label("5 Layers", systemImage: "square.3.layers.3d")
          }
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
      }

      RoundedRectangle(cornerRadius: cornerRadius)
        .strokeBorder(
          LinearGradient(
            colors: Self.colorStops(
              from: cardConfiguration.chromeBorderGradientColors,
              fallback: CardLayerExplodeCardConfiguration.default.chromeBorderGradientColors
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 3
        )
    }
  }
}

private struct ExplodeControlRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>
  let valueText: String
  var step: Double = 1

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(title)
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(.white)
        Spacer()
        Text(valueText)
          .font(.system(size: 12, weight: .medium, design: .monospaced))
          .foregroundStyle(.white.opacity(0.85))
      }
      Slider(value: $value, in: range, step: step)
    }
  }
}

#Preview {
  CardLayerExplodeView()
}
