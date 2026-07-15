//
//  CardStudioView.swift
//  ShaderCards
//
//  The card builder: full configuration of identity, stats, artwork
//  (including custom images), and the holographic shader stack, with a
//  live holographic or exploded-layer preview.
//

import SwiftUI
import PhotosUI
import ShaderKit

/// The interactive card builder.
///
/// Everything about the card is configurable live: identity and stats,
/// built-in procedural artwork or a photo from your library, and the
/// full holographic finish — rarity presets plus editable shader stacks
/// for the art window and the whole card, with the same shader menu as
/// the ShaderKit builder.
///
/// The preview has two modes:
/// - **Holographic** — the finished card; drag to tilt.
/// - **Layers** — the exploded composition; drag to orbit, pinch to
///   spread, with transform sliders and view presets.
/// ```swift
/// NavigationStack { CardStudioView() }
/// ```
public struct CardStudioView: View {
  private enum PreviewMode: String, CaseIterable, Identifiable {
    case holographic = "Holographic"
    case layers = "Layers"
    var id: String { rawValue }
  }

  // Identity
  @State private var name = "Emberfox"
  @State private var element: ElementType = .fire

  // Artwork layers, back to front: backdrop → scene → photo → overlay.
  @State private var showBackdropGradient = false
  @State private var backdropColors: [Color] = [
    Color(red: 0.10, green: 0.22, blue: 0.52),
    Color(red: 0.24, green: 0.16, blue: 0.55),
    Color(red: 0.45, green: 0.20, blue: 0.65),
  ]
  @State private var showSceneLayer = true
  @State private var artwork: CardArtwork = .emberfox
  @State private var showPhotoLayer = false
  @State private var showOverlayGradient = false
  @State private var overlayColors: [Color] = [
    .black.opacity(0.30),
    .clear,
    .black.opacity(0.40),
  ]
  @State private var customImageData: Data?
  @State private var photoSelection: PhotosPickerItem?
  @State private var isImportingImageFile = false
  @State private var imageImportError: String?
  @State private var layout: CardLayout?
  /// Set while a template load changes the rarity, so the rarity
  /// observer doesn't stomp the template's finish.
  @State private var suppressRarityFinishReload = false

  // Stats
  @State private var hp = 120.0
  @State private var stage: CardStage = .basic
  @State private var attackName = "Cinder Dash"
  @State private var attackDamage = 50.0

  // Finish
  @State private var rarity: CardRarity = .holoRare
  @State private var baseFinish: CardFinish = .finish(for: .holoRare)
  @State private var artEffects: [ShaderEffect] = CardFinish.finish(for: .holoRare).artEffects
  @State private var cardEffects: [ShaderEffect] = CardFinish.finish(for: .holoRare).cardEffects
  @State private var shaderInputColors: [Color] = CardLayerFactory.defaultShaderInputColors

  // Preview
  @State private var previewMode: PreviewMode = .holographic

  public init() {}

  public var body: some View {
    GeometryReader { proxy in
      let isWideLayout = proxy.size.width >= 900

      Group {
        if isWideLayout {
          HStack(alignment: .top, spacing: 24) {
            ScrollView {
              editorColumn
                .padding(.vertical, 20)
            }
            .frame(width: min(430, max(340, proxy.size.width * 0.38)))

            ScrollView {
              previewColumn
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
          }
          .padding(.horizontal, 20)
        } else {
          ScrollView {
            VStack(spacing: 24) {
              previewColumn
                .padding(.top, 16)
              editorColumn
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
          }
        }
      }
    }
    .background(studioBackground)
    .navigationTitle("Card Studio")
    .fileImporter(
      isPresented: $isImportingImageFile,
      allowedContentTypes: [.image]
    ) { result in
      switch result {
      case .success(let url):
        importImageFile(at: url)
      case .failure(let error):
        imageImportError = error.localizedDescription
      }
    }
    .onChange(of: element) { _, newElement in
      guard showSceneLayer else { return }
      if artwork.element != newElement,
         let match = CardArtwork.allCases.first(where: { $0.element == newElement }) {
        artwork = match
        name = match.creatureName
      }
    }
    .onChange(of: artwork) { oldArtwork, newArtwork in
      if showSceneLayer, name == oldArtwork.creatureName || name.isEmpty {
        name = newArtwork.creatureName
      }
    }
    .onChange(of: rarity) { _, newRarity in
      if suppressRarityFinishReload {
        suppressRarityFinishReload = false
        return
      }
      loadFinish(.finish(for: newRarity))
    }
    .onChange(of: photoSelection) { _, newSelection in
      guard let newSelection else { return }
      Task {
        if let data = try? await newSelection.loadTransferable(type: Data.self),
           ArtImageCache.image(for: data) != nil {
          customImageData = data
          showPhotoLayer = true
          imageImportError = nil
        } else {
          imageImportError = "Couldn't load that photo — try an image file instead."
        }
        photoSelection = nil
      }
    }
  }

  // MARK: - Card assembly

  private var card: Card {
    var builder = CardBuilder(name: name.isEmpty ? "Unnamed" : name, element: element)
      .hp(rounded(hp))
      .stage(stage)
      .rarity(rarity)
      .attack(
        attackName.isEmpty ? "Attack" : attackName,
        cost: [element, .colorless],
        damage: "\(rounded(attackDamage))"
      )
      .weakness(defaultWeakness)
      .flavor("Forged in the ShaderCards studio.")

    builder = builder.art(composedArt).species(speciesLine)
    return builder.layout(layout).build()
  }

  /// The art stack from the enabled layers, back to front.
  private var composedArt: CardArt {
    var artLayers: [CardArt] = []
    if showBackdropGradient {
      artLayers.append(.gradient(backdropColors))
    }
    if showSceneLayer {
      artLayers.append(.procedural(artwork))
    }
    if showPhotoLayer, let customImageData {
      artLayers.append(.image(customImageData))
    }
    if showOverlayGradient {
      artLayers.append(.gradient(overlayColors))
    }
    if artLayers.isEmpty {
      let palette = element.palette
      artLayers = [.gradient([palette.light, palette.primary, palette.dark])]
    }
    return artLayers.count == 1 ? artLayers[0] : .layered(artLayers)
  }

  private var speciesLine: String {
    if showPhotoLayer, customImageData != nil { return "Custom Art" }
    if showSceneLayer { return artwork.creatureName }
    return "Special Edition"
  }

  /// The loaded base finish with the studio's edited shader stacks.
  private var customFinish: CardFinish {
    var finish = baseFinish
    finish.artEffects = artEffects
    finish.cardEffects = cardEffects
    return finish
  }

  /// Loads a finish preset into the editable stacks.
  private func loadFinish(_ finish: CardFinish) {
    baseFinish = finish
    artEffects = finish.artEffects
    cardEffects = finish.cardEffects
  }

  /// Loads a whole special-edition card into the editor for tweaking.
  private func loadSpecialEdition(_ model: CardModel) {
    name = model.name
    element = model.element
    hp = Double(model.hp)
    stage = model.stage
    layout = model.layout
    if model.rarity != rarity {
      suppressRarityFinishReload = true
      rarity = model.rarity
    }
    // Map the art stack onto the layer toggles.
    showBackdropGradient = false
    showSceneLayer = false
    showPhotoLayer = false
    showOverlayGradient = false
    for (index, artLayer) in model.art.layers.enumerated() {
      switch artLayer {
      case .gradient(let colors):
        if index == 0 {
          backdropColors = colors
          showBackdropGradient = true
        } else {
          overlayColors = colors
          showOverlayGradient = true
        }
      case .procedural(let scene):
        artwork = scene
        showSceneLayer = true
      case .image(let data):
        customImageData = data
        showPhotoLayer = true
      case .layered:
        break
      }
    }
    if let finish = model.finish {
      loadFinish(finish)
    }
    if let attack = model.attacks.first {
      attackName = attack.name
      attackDamage = Double(Int(attack.damage) ?? 50)
    }
  }

  private func rounded(_ value: Double) -> Int {
    Int(value / 10) * 10
  }

  /// Loads an image file picked via the file importer. Dropped/picked
  /// URLs are security-scoped outside the app's own container.
  private func importImageFile(at url: URL) {
    let didStartAccess = url.startAccessingSecurityScopedResource()
    defer {
      if didStartAccess {
        url.stopAccessingSecurityScopedResource()
      }
    }
    guard let data = try? Data(contentsOf: url), ArtImageCache.image(for: data) != nil else {
      imageImportError = "Couldn't read an image from \(url.lastPathComponent)."
      return
    }
    imageImportError = nil
    customImageData = data
    showPhotoLayer = true
  }

  private var defaultWeakness: ElementType {
    switch element {
    case .fire: .water
    case .water: .lightning
    case .grass: .fire
    case .lightning: .fighting
    case .psychic: .darkness
    case .fighting: .psychic
    case .darkness: .fighting
    case .metal: .fire
    case .fairy: .metal
    case .dragon: .fairy
    case .colorless: .fighting
    }
  }

  // MARK: - Preview

  private var previewColumn: some View {
    VStack(spacing: 16) {
      Picker("Preview mode", selection: $previewMode) {
        ForEach(PreviewMode.allCases) { mode in
          Text(mode.rawValue).tag(mode)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .frame(maxWidth: 300)

      previewImageControls

      switch previewMode {
      case .holographic:
        holographicPreview
          .id(cardIdentity)
        Text("Drag the card to tilt the foil")
          .font(.footnote)
          .foregroundStyle(.white.opacity(0.55))
      case .layers:
        ExplodableCardView(
          card: card,
          width: 270,
          showsTransformControls: true,
          finish: customFinish,
          shaderInputColors: shaderInputColors
        )
        .id(cardIdentity)
        Text("Drag to orbit • pinch to spread the layers")
          .font(.footnote)
          .foregroundStyle(.white.opacity(0.55))
      }
    }
  }

  private var previewImageControls: some View {
    HStack(spacing: 12) {
      PhotosPicker(selection: $photoSelection, matching: .images) {
        Label(customImageData == nil ? "Add Photo" : "Replace Photo", systemImage: "photo.badge.plus")
      }

      Button(customImageData == nil ? "Add Image File" : "Replace Image File", systemImage: "folder.badge.plus") {
        isImportingImageFile = true
      }

      if customImageData != nil {
        Button("Remove Image", systemImage: "trash", role: .destructive) {
          customImageData = nil
          photoSelection = nil
          showPhotoLayer = false
          imageImportError = nil
        }
        .labelStyle(.iconOnly)
      }
    }
    .buttonStyle(.bordered)
    .controlSize(.small)
    .tint(.orange)
    .foregroundStyle(.white)
  }

  /// The holographic preview: the face carries its art foils, and each
  /// whole-card foil renders as a carrier layer built from the shader
  /// input gradient — so those colors directly shape the foil.
  private var holographicPreview: some View {
    let width: CGFloat = 290
    let metrics = CardMetrics.resolve(width: width)
    var faceFinish = customFinish
    faceFinish.cardEffects = []

    return HolographicCardContainer(
      width: metrics.width,
      height: metrics.height,
      cornerRadius: metrics.cornerRadius,
      shadowColor: element.palette.dark,
      rotationMultiplier: 14.3,
      interactionMode: .surfacePointer
    ) {
      ZStack {
        CardFaceView(card: card, width: width, finish: faceFinish)
        ForEach(Array(cardEffects.enumerated()), id: \.offset) { _, effect in
          RoundedRectangle(cornerRadius: metrics.cornerRadius)
            .fill(
              LinearGradient(
                colors: shaderInputColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .blendMode(.screen)
            .shader(effect)
        }
        // Chrome re-drawn above the foil so text stays crisp,
        // matching the layer order of the classic builder.
        if case .creature(let model) = card {
          chromeOverlay(model: model, metrics: metrics, finish: faceFinish)
        }
      }
    }
  }

  /// The text/panel chrome for the current layout, art omitted.
  @ViewBuilder
  private func chromeOverlay(
    model: CardModel,
    metrics: CardMetrics.Resolved,
    finish: CardFinish
  ) -> some View {
    switch model.resolvedLayout(for: finish) {
    case .minimal:
      MinimalCardFace(card: model, metrics: metrics, finish: finish, artHidden: true, scrimsHidden: true)
    case .fullArt:
      FullArtCardFace(card: model, metrics: metrics, finish: finish, artHidden: true, scrimsHidden: true)
    case .framed:
      StandardCardFace(
        card: model,
        metrics: metrics,
        finish: finish,
        layerMode: .chromeOnly,
        artTreatment: .transparent
      )
    }
  }

  /// Structural identity so the preview rebuilds when composition changes.
  private var cardIdentity: String {
    let effectsKey = (artEffects + cardEffects).map(\.layerLabel).joined(separator: ",")
    let artKey = [
      showBackdropGradient ? "bg-\(backdropColors.description.hashValue)" : "",
      showSceneLayer ? artwork.rawValue : "",
      showPhotoLayer ? "img-\(customImageData?.count ?? 0)" : "",
      showOverlayGradient ? "ov-\(overlayColors.description.hashValue)" : "",
    ].joined(separator: "|")
    let inputKey = "in-\(shaderInputColors.description.hashValue)"
    let layoutKey = layout?.rawValue ?? "auto"
    let flagsKey = "\(baseFinish.isFullArt)-\(baseFinish.isGoldFrame)"
    return "\(element.rawValue)-\(artKey)-\(rarity.rawValue)-\(stage.rawValue)-\(effectsKey)-\(inputKey)-\(layoutKey)-\(flagsKey)-\(previewMode.rawValue)"
  }

  private var studioBackground: some View {
    LinearGradient(
      colors: [Color(red: 0.09, green: 0.10, blue: 0.16),
               Color(red: 0.14, green: 0.12, blue: 0.22)],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }

  // MARK: - Editor

  private var editorColumn: some View {
    VStack(alignment: .leading, spacing: 18) {
      section("Templates") {
        LabeledContent("Special edition") {
          Menu("Start From…") {
            ForEach(CardLibrary.specialEditions) { edition in
              Button(edition.name) {
                loadSpecialEdition(edition)
              }
            }
          }
          .menuStyle(.borderlessButton)
          .fixedSize()
        }
      }

      section("Identity") {
        TextField("Card name", text: $name)
          .textFieldStyle(.roundedBorder)

        LabeledContent("Element") {
          Picker("Element", selection: $element) {
            ForEach(ElementType.allCases) { type in
              Text(type.displayName).tag(type)
            }
          }
          .labelsHidden()
        }
      }

      section("Artwork") {
        LabeledContent("Layout") {
          Picker("Layout", selection: $layout) {
            Text("Auto (rarity)").tag(CardLayout?.none)
            ForEach(CardLayout.allCases) { option in
              Text(option.displayName).tag(CardLayout?.some(option))
            }
          }
          .labelsHidden()
        }

        Text("Layers stack back to front — combine them freely.")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.55))

        Toggle("Backdrop gradient", isOn: $showBackdropGradient)
        if showBackdropGradient {
          GradientColorEditor(title: "Backdrop Colors", colors: $backdropColors)
        }

        Toggle("Scene", isOn: $showSceneLayer)
        if showSceneLayer {
          LabeledContent("Creature") {
            Picker("Scene", selection: $artwork) {
              ForEach(CardArtwork.allCases) { art in
                Text(art.creatureName).tag(art)
              }
            }
            .labelsHidden()
          }
        }

        Toggle("Photo", isOn: $showPhotoLayer)
        if showPhotoLayer {
          if let customImageData, let image = ArtImageCache.image(for: customImageData) {
            HStack(spacing: 12) {
              #if canImport(UIKit)
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
              #else
              Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
              #endif
              Text("Custom image")
                .font(.subheadline)
              Spacer()
              Button("Remove", systemImage: "xmark.circle.fill") {
                self.customImageData = nil
                photoSelection = nil
              }
              .labelStyle(.iconOnly)
              .buttonStyle(.plain)
              .foregroundStyle(.red.opacity(0.9))
            }
          }

          HStack(spacing: 14) {
            Button {
              isImportingImageFile = true
            } label: {
              Label("Image File…", systemImage: "folder")
                .font(.system(size: 13, weight: .semibold))
            }

            PhotosPicker(selection: $photoSelection, matching: .images) {
              Label("Photos…", systemImage: "photo.on.rectangle.angled")
                .font(.system(size: 13, weight: .semibold))
            }
          }

          if let imageImportError {
            Text(imageImportError)
              .font(.caption)
              .foregroundStyle(.red.opacity(0.9))
          }
        }

        Toggle("Overlay gradient", isOn: $showOverlayGradient)
        if showOverlayGradient {
          GradientColorEditor(title: "Overlay Colors (use opacity)", colors: $overlayColors)
        }
      }

      section("Stats") {
        LabeledContent("HP: \(rounded(hp))") {
          Slider(value: $hp, in: 30...340)
            .frame(maxWidth: 220)
        }

        LabeledContent("Stage") {
          Picker("Stage", selection: $stage) {
            Text("Basic").tag(CardStage.basic)
            Text("Stage 1").tag(CardStage.stage1)
            Text("Stage 2").tag(CardStage.stage2)
            Text("ex").tag(CardStage.ex)
            Text("V").tag(CardStage.vStyle)
            Text("VMAX").tag(CardStage.vMax)
          }
          .labelsHidden()
        }

        TextField("Attack name", text: $attackName)
          .textFieldStyle(.roundedBorder)

        LabeledContent("Damage: \(rounded(attackDamage))") {
          Slider(value: $attackDamage, in: 10...300)
            .frame(maxWidth: 220)
        }
      }

      section("Finish") {
        LabeledContent("Rarity preset") {
          Picker("Rarity", selection: $rarity) {
            ForEach(CardRarity.allCases) { tier in
              Text(tier.displayName).tag(tier)
            }
          }
          .labelsHidden()
        }

        LabeledContent("Special finish") {
          Menu("Load…") {
            ForEach(CardFinish.specialFinishes, id: \.name) { special in
              Button(special.name) {
                loadFinish(special.finish)
              }
            }
          }
          .menuStyle(.borderlessButton)
          .fixedSize()
        }

        ShaderStackEditor(title: "Foil on Artwork", effects: $artEffects)
        ShaderStackEditor(title: "Foil on Whole Card", effects: $cardEffects)
        GradientColorEditor(title: "Shader Input Gradient", colors: $shaderInputColors)
      }
    }
    .foregroundStyle(.white)
    .tint(.orange)
  }

  private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.white.opacity(0.92))
      VStack(alignment: .leading, spacing: 10) {
        content()
      }
      .padding(14)
      .background(
        RoundedRectangle(cornerRadius: 14)
          .fill(.white.opacity(0.07))
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .strokeBorder(.white.opacity(0.12), lineWidth: 1)
          )
      )
    }
  }
}

// MARK: - Shader stack editor

/// The curated shader menu for card foils — mirrors the ShaderKit
/// builder's options, including the card-specific etched foil.
struct ShaderStackEditor: View {
  let title: String
  @Binding var effects: [ShaderEffect]

  private struct ShaderOption: Identifiable {
    let id: String
    let title: String
    let effect: ShaderEffect
  }

  private static let options: [ShaderOption] = [
    ShaderOption(id: "etchedFoil", title: "Etched Foil", effect: .etchedFoil(intensity: 0.55, density: 90)),
    ShaderOption(id: "verticalBeams", title: "Vertical Beams", effect: .verticalBeams(intensity: 0.4)),
    ShaderOption(id: "diagonalHolo", title: "Diagonal Holo", effect: .diagonalHolo(intensity: 0.4)),
    ShaderOption(id: "crisscrossHolo", title: "Crisscross Holo", effect: .crisscrossHolo(intensity: 0.4)),
    ShaderOption(id: "galaxyHolo", title: "Galaxy Holo", effect: .galaxyHolo(intensity: 0.4)),
    ShaderOption(id: "blendedHolo", title: "Blended Holo", effect: .blendedHolo(intensity: 0.35, saturation: 0.8)),
    ShaderOption(id: "rainbowGlitter", title: "Rainbow Glitter", effect: .rainbowGlitter(intensity: 0.4)),
    ShaderOption(id: "metallicCrosshatch", title: "Metallic Crosshatch", effect: .metallicCrosshatch(intensity: 0.4)),
    ShaderOption(id: "radialStar", title: "Radial Star", effect: .radialStar(intensity: 0.4)),
    ShaderOption(id: "subtleGradient", title: "Subtle Gradient", effect: .subtleGradient(intensity: 0.5)),
    ShaderOption(id: "halftonePastel", title: "Halftone Pastel", effect: .halftonePastel(intensity: 0.5)),
    ShaderOption(id: "polishedAluminum", title: "Polished Aluminum", effect: .polishedAluminum(intensity: 0.5)),
    ShaderOption(id: "brushedTitanium", title: "Brushed Titanium", effect: .brushedTitanium(intensity: 0.85)),
    ShaderOption(id: "blackChrome", title: "Black Chrome", effect: .blackChrome(intensity: 0.88)),
    ShaderOption(id: "roseGold", title: "Rose Gold", effect: .roseGold(intensity: 0.82)),
    ShaderOption(id: "liquidMercury", title: "Liquid Mercury", effect: .liquidMercury(intensity: 0.84)),
    ShaderOption(id: "anodizedTitanium", title: "Anodized Titanium", effect: .anodizedTitanium(intensity: 0.84)),
    ShaderOption(id: "damascusSteel", title: "Damascus Steel", effect: .damascusSteel(intensity: 0.86)),
    ShaderOption(id: "forgedCarbon", title: "Forged Carbon", effect: .forgedCarbon(intensity: 0.88)),
    ShaderOption(id: "copperPatina", title: "Copper Patina", effect: .copperPatina(intensity: 0.82)),
    ShaderOption(id: "pearlCeramic", title: "Pearl Ceramic", effect: .pearlCeramic(intensity: 0.80)),
    ShaderOption(id: "oilSlick", title: "Oil Slick", effect: .oilSlick(intensity: 0.84)),
    ShaderOption(id: "foil", title: "Foil", effect: .foil(intensity: 0.5)),
    ShaderOption(id: "shimmer", title: "Shimmer", effect: .shimmer(intensity: 0.35)),
    ShaderOption(id: "glitter", title: "Glitter", effect: .glitter(density: 55)),
    ShaderOption(id: "multiGlitter", title: "Multi Glitter", effect: .multiGlitter(density: 65)),
    ShaderOption(id: "sparkles", title: "Sparkles", effect: .sparkles),
    ShaderOption(id: "lightSweep", title: "Light Sweep", effect: .lightSweep),
    ShaderOption(id: "radialSweep", title: "Radial Sweep", effect: .radialSweep),
    ShaderOption(id: "glare", title: "Glare", effect: .glare(intensity: 0.5)),
    ShaderOption(id: "glassSheen", title: "Glass Sheen", effect: .glassSheen(intensity: 0.3, spread: 0.5)),
    ShaderOption(id: "chromaticGlass", title: "Chromatic Glass", effect: .chromaticGlass(intensity: 0.4, separation: 0.4)),
    ShaderOption(id: "frozen", title: "Frozen", effect: .frozen(intensity: 0.5)),
    ShaderOption(id: "snowfall", title: "Snowfall", effect: .snowfall(intensity: 0.5)),
  ] + TradingCardHoloStyle.allCases.map { style in
    ShaderOption(
      id: "tradingCardHolo-\(style.rawValue)",
      title: style.displayName,
      effect: .tradingCardHolo(style: style, intensity: 0.88)
    )
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
          .font(.system(size: 12, weight: .semibold))
          .foregroundStyle(.white.opacity(0.9))
        Spacer()
        Menu {
          ForEach(Self.options) { option in
            Button(option.title) {
              effects.append(option.effect)
            }
          }
        } label: {
          Label("Add", systemImage: "plus.circle.fill")
            .font(.system(size: 12, weight: .semibold))
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
      }

      if effects.isEmpty {
        Text("No foil passes")
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(.white.opacity(0.55))
      } else {
        ForEach(Array(effects.enumerated()), id: \.offset) { index, effect in
          HStack(spacing: 8) {
            Image(systemName: "sparkle")
              .font(.system(size: 9))
              .foregroundStyle(.orange)
            Text(effect.layerLabel)
              .font(.system(size: 11, weight: .medium))
              .foregroundStyle(.white)
            Spacer()
            Button {
              effects.remove(at: index)
            } label: {
              Image(systemName: "minus.circle.fill")
                .foregroundStyle(.red.opacity(0.9))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(effect.layerLabel)")
          }
        }
      }
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.white.opacity(0.07))
    )
  }
}

// MARK: - Gradient color editor

/// Three-stop gradient editor matching the ShaderKit builder.
struct GradientColorEditor: View {
  let title: String
  @Binding var colors: [Color]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.white.opacity(0.9))

      HStack(spacing: 10) {
        ColorPicker("A", selection: binding(0), supportsOpacity: true)
        ColorPicker("B", selection: binding(1), supportsOpacity: true)
        ColorPicker("C", selection: binding(2), supportsOpacity: true)
      }
      .font(.system(size: 11, weight: .medium))
      .foregroundStyle(.white.opacity(0.85))
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.white.opacity(0.07))
    )
  }

  private func binding(_ index: Int) -> Binding<Color> {
    Binding(
      get: {
        colors.indices.contains(index) ? colors[index] : .clear
      },
      set: { newValue in
        while colors.count <= index {
          colors.append(.clear)
        }
        colors[index] = newValue
      }
    )
  }
}

#Preview("Card Studio") {
  NavigationStack {
    CardStudioView()
  }
  #if os(macOS)
  .frame(width: 1100, height: 900)
  #endif
}
