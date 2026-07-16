# ShaderKit primitives API (condensed, verified against source)

Everything below ships in the `ShaderKit` library product. `import ShaderKit`.

## HolographicCardContainer

The tilt-interactive host. It runs a `TimelineView(.animation)`, converts the
drag gesture into normalized tilt, applies 3D rotation + dynamic shadow, and
**automatically injects shader context** (tilt, time, touch position) into its
content — every `.shader(...)` modifier inside just works.

```swift
HolographicCardContainer(
  width: CGFloat,                     // required, points
  height: CGFloat,                    // required, points
  cornerRadius: CGFloat = 16,         // clip + border radius
  shadowColor: Color = .black,        // tint to the card's palette
  rotationMultiplier: Double = 15,    // 3D rotation intensity (demos use 12–15)
  interactionMode: HolographicInteractionMode = .dragTranslation,
  @ViewBuilder content: () -> Content
) { ... }
```

- Card proportions: demos use ~1 : 1.4 – 1.45 (260×380, 280×400).
- `interactionMode`: `.dragTranslation` (tilt follows drag distance — default)
  or `.surfacePointer` (tilt follows absolute finger position, center neutral —
  the physical-card feel).
- Respects `accessibilityReduceMotion` (freezes time and rotation) — do not
  add a second reduce-motion guard inside.

## Applying effects

```swift
CardContent()
  .foil(intensity: 0.8)      // sugar for .shader(.foil(intensity: 0.8))
  .glitter()
  .lightSweep()
```

- Generic form: `.shader(_ effect: ShaderEffect, tilt: CGPoint? = nil, time: TimeInterval? = nil)`.
  Every effect also has a same-named convenience modifier.
- Effects wrap the view they are attached to: each modifier composites over
  everything below it in the chain, so **chain order = stack order**.
- Attach effects to sub-views to shade only that layer (split-layer technique).
- Outside a `HolographicCardContainer`, inject context manually:
  `.shaderContext(tilt: CGPoint, time: TimeInterval, touchPosition: CGPoint? = nil)`.

## Effect catalog

Intensities below are the defaults. "Translucent" effects show the content
underneath (safe over photos); "opaque" effects replace the surface (photo
disappears).

### Foil (translucent)
| Modifier | Params |
|---|---|
| `.foil()` | `intensity: 1.0` — rainbow foil overlay |
| `.invertedFoil()` | `intensity: 0.7` — inverted foil with shine |
| `.maskedFoil(imageWindow:)` | + `intensity: 1.0` — foil everywhere EXCEPT the window |
| `.foilTexture(imageWindow:)` | fine diagonal lines outside the window |

`imageWindow` is `SIMD4<Float>(minX, minY, maxX, maxY)` in 0–1 UV space of the
shaded view (e.g. `SIMD4<Float>(0.04, 0.20, 0.96, 0.64)` for a classic art window).

### Glitter & sparkle (translucent)
| Modifier | Params |
|---|---|
| `.glitter()` | `density: 50` |
| `.multiGlitter()` | `density: 80` — multi-scale |
| `.sparkles()` | tilt-activated grid |
| `.maskedSparkle(imageWindow:)` | sparkles outside the window only |
| `.rainbowGlitter()` | `intensity: 0.7` — luminosity blend |
| `.shimmer()` | `intensity: 0.7` — metallic shimmer |

### Light (translucent — always stack LAST)
| Modifier | Params |
|---|---|
| `.lightSweep()` | sweeping band |
| `.radialSweep()` | rotating radial sweep |
| `.angledSweep()` | angled band |
| `.glare()` | `intensity: 1.0` — hotspot follows tilt |
| `.simpleGlare()` | `intensity: 0.7` |
| `.edgeShine()` | edge highlight |

### Holographic patterns (translucent)
| Modifier | Params / character |
|---|---|
| `.blendedHolo()` | `intensity: Float = 0.7, saturation: Float = 0.75` — luminance-blended rainbow, the classic "gold card" wash |
| `.verticalBeams()` | `0.7` — vertical rainbow beams |
| `.diagonalHolo()` | `0.7` — diagonal lines with 3D depth |
| `.crisscrossHolo()` | `0.7` — criss-cross diamonds |
| `.galaxyHolo()` | `0.7` — cosmos stars + rainbow |
| `.diamondGrid()` | `1.0` |
| `.intenseBling()` | maximum-intensity diamonds |
| `.starburst()` | `1.0` — radial rainbow rays |
| `.radialStar()` | `0.7` |
| `.subtleGradient()` | `0.7` — slow large-scale drift |
| `.metallicCrosshatch()` | `0.7` — sun-pillar crosshatch |
| `.etchedFoil()` | `intensity: 0.7, density: 80` — engraved lines + rainbow interference (textured full-art treatment) |
| `.shader(.spiralRings(...))` | `intensity: 0.8, ringCount: 20, spiralTwist: 0.5, baseColor:` golden default |

### Glass (translucent — good closers)
| Modifier | Params |
|---|---|
| `.shader(.glassSheen(...))` | `intensity: 0.7, spread: 0.5` — specular + sweep, layers well |
| `.shader(.glassEnclosure(...))` | `intensity: 1.0, cornerRadius: 0.05, bevelSize: 0.7, glossiness: 0.8` — lamination look |
| `.shader(.glassBevel(...))` | `intensity: 0.8, thickness: 0.6` — visual card thickness |
| `.shader(.chromaticGlass(...))` | `intensity: 0.6, separation: 0.4` — RGB edge separation |

### Atmosphere (translucent, colorable)
| Modifier | Params |
|---|---|
| `.snowfall(...)` | `intensity: 0.8, snowDensity: 0.5, starDensity: 0.6, primaryColor:, secondaryColor:` (SIMD4 RGBA) |
| `.frozen(...)` | `intensity: 0.85, starDensity: 0.6, shimmerIntensity: 0.8, iceColor:, starColor:` |
| `.halftonePastel(...)` | `intensity: 0.8, dotDensity: 30, waveSpeed: 1.0` |
| `.shader(.water(...))` | caustics; `colorBack`, `colorHighlight`, several tuning params |
| `.liquidTech(...)` | `intensity: 0.9, speed: 1.0, scale: 1.0` — procedural tech flow |

### Premium materials (OPAQUE — hide any image underneath)
`.polishedAluminum()`, `.brushedTitanium()`, `.blackChrome()`, `.roseGold()`,
`.liquidMercury()`, `.anodizedTitanium()`, `.damascusSteel()`,
`.forgedCarbon()`, `.copperPatina()`, `.pearlCeramic()`, `.oilSlick()` —
all take a single `intensity` (defaults 0.80–0.88). Use only as the card's
surface itself (no photo), or on chrome elements like borders/banners.

### Complete trading-card constructions
```swift
.tradingCardHolo(_ style: TradingCardHoloStyle, intensity: Double = 0.85)
```
One call = a full foil recipe (texture + color separation + glare + blend).
`TradingCardHoloStyle` cases: `.regularHolo`, `.cosmosHolo`, `.reverseHolo`,
`.radiantHolo`, `.amazingRare`, `.vRegular`, `.vMax`, `.vStar`, `.vFullArt`,
`.rainbowRare`, `.rainbowAlternate`, `.secretRareGold`, `.shinyRare`,
`.shinyV`, `.shinyVMax`, `.trainerFullArt`, `.trainerGalleryHolo`,
`.trainerGallerySecretRare`, `.trainerGalleryV`, `.trainerGalleryVMax`,
`.pikachuSecretRare`. Each has a `displayName`.
Treat `tradingCardHolo` as the base foil of a stack — it still pairs well with
`.glitter()` and `.lightSweep()` on top.

## SimpleCardContent

A ready-made Pokémon-style card frame (header with title + "HP 200", center
artwork area, footer subtitle + energy icons, gradient border):

```swift
SimpleCardContent(
  title: String = "HOLO CARD",
  subtitle: String = "Special Edition",
  image: String = "unicorn",          // asset-catalog name for the art area
  @ViewBuilder background: () -> Background
)
```

Good for quick framed cards; build a custom ZStack for full-art or
split-layer constructions.
