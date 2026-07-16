# Composition recipes: stacking shaders, images, and gradients

How to assemble a card from ShaderKit primitives so it looks like the demo
cards, plus the interview → design mappings.

## 1. The stack doctrine

A card is two stacks: the **content stack** (a ZStack, bottom → top) and the
**effect stack** (modifier chain order, first → last). Get both orders right
and almost any combination looks premium.

**Content stack, bottom → top:**
1. **Base gradient** — opaque `LinearGradient` in the palette; sets the card's
   color identity and is the fallback if an image fails to load.
2. **Image** (optional) — `.resizable().aspectRatio(contentMode: .fill)`,
   explicit `.frame(...)`, `.clipped()` or clip shape.
3. **Tint scrim** (only over an image) — a translucent `LinearGradient` whose
   stops use **0.10–0.35 opacity**. This is what marries a photo to the foil
   palette; skipping it is why cards look like "a photo with stickers".
4. **Chrome** — name/title text, stat rows, icons. White text with `.opacity`
   hierarchy (1.0 title → 0.5 footnotes) over dark art; black over gold/light.
5. **Border** — `RoundedRectangle.strokeBorder` with a 2–5 pt metallic-feeling
   gradient (e.g. `[.orange, .yellow, .red]` or gold tones).

**Effect stack (modifier chain), first → last:**
1. **Foil / pattern base** — exactly one dominant identity:
   `.foil()`, `.blendedHolo()`, `.galaxyHolo()`, `.etchedFoil()`,
   `.tradingCardHolo(style)`, `.verticalBeams()`, …
2. **Texture / sparkle** — `.glitter()`, `.multiGlitter()`, `.shimmer()`.
3. **Light** — `.lightSweep()`, `.glare()`, or `.shader(.glassSheen())` LAST,
   so the reflection reads as sitting on top of everything.

Budget: **2–4 effects total**. One pattern + one sparkle + one light is the
demo-proven formula (`.foil().glitter().lightSweep()`). Two competing
patterns = mud. When layering more, lower each `intensity` (0.5–0.7).

Critical rule: premium materials (`.brushedTitanium`, `.blackChrome`,
`.oilSlick`, …) are **opaque** — never apply them over a photo you want
visible. Everything else in the catalog is translucent.

## 2. The four constructions

Pick one per card. Each is proven by a demo view in this repo.

### A. Full-Art Foil (like `GradientFoilView`) — best with a photo
Whole-card effects over a full-bleed image. Simplest and most reliable.

```swift
HolographicCardContainer(width: 280, height: 400, cornerRadius: 20, shadowColor: .orange) {
  ZStack {
    RoundedRectangle(cornerRadius: 20).fill(baseGradient)   // 1 base
    portraitImage                                           // 2 full-bleed image
    LinearGradient(colors: scrimStops, ...)                 // 3 tint scrim
    chromeOverlay                                           // 4 name/stats
    RoundedRectangle(cornerRadius: 20).strokeBorder(borderGradient, lineWidth: 3)
  }
  .foil()          // effect stack applies to the WHOLE card
  .glitter()
  .lightSweep()
}
```

### B. Split-Layer Holo (like `LayeredHoloView`) — crisp art over shimmer
Effects go on individual layers, not the whole card. The artwork sits on top
**with no effects**, so it stays clean while everything behind it shimmers.

```swift
HolographicCardContainer(width: 260, height: 364, shadowColor: .yellow, rotationMultiplier: 12) {
  ZStack {
    cardFrameAndStats                    // full-card frame + text
      .blendedHolo(intensity: 0.7, saturation: 0.75)
    artWindowBackdrop                    // gradient sized to the art window
      .verticalBeams()                   //   animated depth behind the art
      .offset(y: -height * 0.198)
    artworkImage                         // CLEAN — zero effects
      .offset(y: -height * 0.198)        //   same frame + offset as backdrop
  }
}
```
The sparkle backdrop and the clean artwork must share the same frame size and
offset; the art then appears to float on an animated foil pocket.

### C. Reverse Holo / Framed window (like `MaskedFoilView`) — foil frame, clean window
One flat content view; the masked effects skip the art window in UV space.

```swift
ZStack {
  goldGradient
    .maskedFoil(imageWindow: window)     // foil OUTSIDE the window
    .maskedSparkle(imageWindow: window)
    .foilTexture(imageWindow: window)
  VStack { header; artImage; stats }     // art laid out INSIDE the window
}
```
`window` is `SIMD4<Float>(minX, minY, maxX, maxY)` in 0–1 coordinates of the
card. Compute it from the layout: the demo's art occupies x 4–96 %,
y 20–64 % → `SIMD4<Float>(0.04, 0.20, 0.96, 0.64)`. If the foil bleeds into
the art or hugs it too loosely, adjust the window, not the layout.

### D. Atmosphere card (like `CosmosHoloView` / `FrozenView`) — no photo needed
A near-black gradient plus one atmospheric effect; ideal when the user has no
image or wants a moody abstract card. Pair with `SimpleCardContent` for
instant framing:

```swift
SimpleCardContent(title: "COSMOS HOLO", subtitle: "Galaxy Rare") {
  RoundedRectangle(cornerRadius: 16)
    .fill(LinearGradient(colors: deepSpaceStops, ...))   // 0.02–0.15 RGB channels
    .galaxyHolo(intensity: 0.8)
}
```
Swap `.galaxyHolo` for `.frozen()`, `.snowfall()`, `.liquidTech()`, or
`.tradingCardHolo(.cosmosHolo)` to change the weather.

## 3. Interview → design mappings

### Favorite colors → base gradient + scrim + shadow
Base stops are opaque; scrim stops are the same hues at 0.10–0.35 opacity.
`shadowColor` on the container should echo the dominant hue.

| Answer | Base gradient stops | shadowColor |
|---|---|---|
| Warm reds/oranges | `Color(red: 0.85, green: 0.25, blue: 0.15)` → `Color(red: 0.95, green: 0.55, blue: 0.15)` | `.orange` |
| Ocean blues | `Color(red: 0.05, green: 0.25, blue: 0.5)` → `Color(red: 0.1, green: 0.55, blue: 0.75)` | `.cyan` |
| Purples/violets | `Color(red: 0.3, green: 0.1, blue: 0.5)` → `Color(red: 0.6, green: 0.3, blue: 0.8)` | `.purple` |
| Greens | `Color(red: 0.05, green: 0.4, blue: 0.25)` → `Color(red: 0.3, green: 0.7, blue: 0.4)` | `.green` |
| Golds/yellows | `Color(red: 0.92, green: 0.85, blue: 0.55)` → `Color(red: 0.85, green: 0.75, blue: 0.4)` | `.yellow` |
| Pinks/pastels | `Color(red: 0.95, green: 0.6, blue: 0.75)` → `Color(red: 0.7, green: 0.65, blue: 0.9)` | `.pink` |
| Silver/monochrome | `Color(red: 0.75, green: 0.78, blue: 0.82)` → `Color(red: 0.35, green: 0.38, blue: 0.45)` | `.white` |
| Black/moody | `Color(red: 0.05, green: 0.02, blue: 0.15)` → `Color(red: 0.08, green: 0.02, blue: 0.12)` | `.purple` |

### Foil vibe → effect stack
| Vibe | Stack (in chain order) |
|---|---|
| Classic TCG holo | `.blendedHolo(intensity: 0.7, saturation: 0.75)` + `.sparkles()` + `.lightSweep()` — or one `.tradingCardHolo(.regularHolo)` + `.glitter()` |
| Rainbow / iridescent | `.foil(intensity: 0.8)` + `.glitter()` + `.lightSweep()` |
| Etched premium full-art | `.etchedFoil(intensity: 0.75)` + `.glare(intensity: 0.6)` |
| Cosmic / night sky | `.galaxyHolo(intensity: 0.8)` + `.multiGlitter()` + `.shader(.glassSheen())` |
| Ice / winter | `.frozen()` + `.lightSweep()` |
| Gold secret-rare | `.tradingCardHolo(.secretRareGold)` + `.glitter(density: 60)` + `.glare(intensity: 0.5)` |
| Metal (no photo) | `.brushedTitanium()` or `.oilSlick()` + `.shader(.glassBevel())` — construction D only |

### Personality → chrome
- **Card name** → header title (bold, 16–20 pt equivalent).
- **Role/title** → the small line under the art (species line).
- **Motto/fun fact** → italic flavor text near the footer, ~0.55 opacity.
- **Two signature skills** → stat rows: name + a bold "damage" number
  (pick 90–200; bigger number for the skill they're proudest of).
- **Energy/HP number** → header right side ("HP 200" style).

## 4. The dark stage

Present the finished card centered on a near-black radial gradient so the foil
reads; never on white.

```swift
RadialGradient(
  colors: [stageCast, Color(red: 0.03, green: 0.03, blue: 0.05)],
  center: .center, startRadius: 40, endRadius: 620
)
.ignoresSafeArea()
```
`stageCast` = the palette hue at roughly `Color(red: 0.10, green: 0.06, blue: 0.16)`
brightness. Add `.preferredColorScheme(.dark)`, a headline above and a
"Drag to tilt" hint below the card.

## 5. Tuning checklist

- Foil invisible → raise the pattern's `intensity` before adding effects.
- Photo washed out → lower scrim stop opacities (toward 0.10) or drop the
  pattern intensity to ~0.5.
- Looks noisy → remove one effect; two patterns never beat one.
- Whole card too dark → the base gradient is too dark for a translucent
  pattern; lighten it one step.
- Foil bleeding over the art window (construction C) → tighten the
  `imageWindow` UV rect.
