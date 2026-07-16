# ShaderCards API (condensed)

Verified against the package source. `import ShaderCards` (and `import SwiftUI`).

## Views

```swift
// Interactive holographic card: drag-to-tilt 3D, dynamic shadow, live shader time.
// This is the container to use for the final showcase.
TradingCardView(_ card: Card, width: CGFloat = 300, finish: CardFinish? = nil)

// Static face (no interaction) — for grids/thumbnails.
CardFaceView(card: Card, width: CGFloat = 300, finish: CardFinish? = nil)

// Exploded 3D layer stack (drag orbits, pinch spreads). Nice as a bonus view.
ExplodableCardView(card: Card, width: CGFloat = 280,
                   showsTransformControls: Bool = false,
                   finish: CardFinish? = nil,
                   shaderInputColors: [Color]? = nil)
```

`shaderInputColors` feeds the foil-carrier gradient in the exploded view — pass
the user's favorite colors there when using it.

## Card

```swift
public enum Card { case creature(CardModel), trainer(TrainerCardModel), energy(EnergyCardModel) }
```

Personal cards are `.creature(CardModel)` — build via `CardBuilder`:

```swift
let card: Card = CardBuilder(name: "Ava", element: .psychic)
  .hp(200)
  .rarity(.illustrationRare)
  .art(.layered([...]))                 // or .artwork(imageData: Data)
  .layout(.fullArt)                     // .framed | .fullArt | .minimal ; nil = follow rarity
  .finish(.psychicWave)                 // nil = derive from rarity
  .ability("Flow State", text: "…")     // optional
  .attack("Design Review", cost: [.psychic, .colorless], damage: "90", text: nil)
  .weakness(.darkness) .resistance(.metal) .retreat(1)
  .species("Senior Product Designer")   // line under the art
  .flavor("Ships pixels and vibes.")    // lower info box
  .setNumber("001/151")
  .illustrator("holo-card-designer")
  .build()
```

`CardModel(...)` direct init mirrors the builder (params: id, name, element, hp,
stage, rarity, art/artwork, layout, finish, ability, attacks, weakness,
resistance, retreatCost, species, flavorText, setNumber, illustrator).

## CardArt

```swift
public enum CardArt {
  case procedural(CardArtwork)   // built-in scenes
  case image(Data)               // PNG/JPEG/HEIC data, aspect-filled + clipped
  case gradient([Color])         // linear topLeading→bottomTrailing; translucent stops = tint scrim
  indirect case layered([CardArt])  // back-to-front stack
}
```

Images decode once via an internal cache; a failed decode renders a gray
placeholder, so always guard the `Data` load and fall back to a gradient.

## CardLayout

- `.framed` — art in a beveled window, stats below (classic Pokémon).
- `.fullArt` — edge-to-edge art, chrome floats on scrims.
- `.minimal` — poster: name banner + info line only; **no attacks/stats render**.

## ElementType (frame palette + energy icon)

`grass, fire, water, lightning, psychic, fighting, darkness, metal, fairy,
dragon, colorless`

## CardRarity → default finish (when `finish` is nil)

`common/uncommon` none · `rare` glass sheen · `holoRare` beams+sparkles in art ·
`reverseHolo` foil on frame only · `doubleRare` diagonal holo+glitter ·
`ultraRare` etched foil, full-art · `illustrationRare` galaxy holo, full-art ·
`specialIllustrationRare` crisscross+multi-glitter, full-art · `rainbowRare`
rainbow glitter, full-art · `hyperRare` metallic crosshatch, full-art + gold
frame · `radiant` crisscross in art · `amazing` galaxy in art.

## CardFinish

```swift
CardFinish(artEffects: [ShaderEffect] = [],          // art window only
           cardEffects: [ShaderEffect] = [],         // whole face
           frameMaskedEffects: [ShaderEffect] = [],  // frame only (reverse holo)
           isFullArt: Bool = false,
           isGoldFrame: Bool = false)

CardFinish.finish(for: CardRarity)      // canonical rarity treatment
```

### Named presets (all `static var` on `CardFinish`)

Translucent-over-art (photo-safe): `.codex`, `.goldenSweep`, `.starburstGold`,
`.psychicWave`, `.frozenCrystal`, `.snowfall`, `.prismLayers`, `.halftonePop`,
`.spiralRings` (gold frame), `.quicksilver`*, `.neonFlux`*, `.tidepool`*
(* = adds strong effects in/over the art — check the photo stays readable).

Opaque premium materials (hide the photo — gradient cards only):
`.brushedTitanium`, `.blackChrome`, `.roseGold`, `.liquidMercury`,
`.anodizedTitanium`, `.damascusSteel`, `.forgedCarbon`, `.copperPatina`,
`.pearlCeramic`, `.oilSlick`.

### Trading-card holo styles

```swift
CardFinish.tradingCardHolo(_ style: TradingCardHoloStyle)  // region-aware recipe
```

Styles: `regularHolo, cosmosHolo, reverseHolo, radiantHolo, amazingRare,
shinyRare, secretRareGold, trainerGallerySecretRare, vRegular, vMax, vStar,
vFullArt, rainbowRare, rainbowAlternate, shinyV, shinyVMax, trainerFullArt,
trainerGalleryHolo, trainerGalleryV, trainerGalleryVMax, pikachuSecretRare`.

`regularHolo`/`cosmosHolo` stay inside the art window; `reverseHolo` foils the
frame; V/rainbow/gold styles go full-art (gold ones also gold-frame).

Browse everything by name: `CardFinish.specialFinishes: [(name: String, finish: CardFinish)]`.

## Build caveat (critical)

Metal shaders in this SPM package compile **only** through Xcode's build
system. `swift build`/`swift run` copies `.metal` files raw → every effect
renders blank. Verify visuals via `xcodebuild` or XcodeBuildMCP
(`build_run_sim`) with the `ShaderCardsDemo` scheme.
