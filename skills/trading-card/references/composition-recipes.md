# Composition recipes: stacking shaders, images, and gradients

How to assemble a card from ShaderKit primitives so it looks like the demo
cards, plus the vibe → design mappings. Every number here is copied from a
real demo view in `Demo/ShaderKitDemo/.../Views/ComposableShaders/` — reproduce
them, don't approximate.

## 1. The stack doctrine

A card is two stacks: the **content stack** (a ZStack, bottom → top) and the
**effect stack** (modifier chain order, first → last). Get both orders right
and almost any combination looks premium.

**Content stack, bottom → top:**
1. **Background** — the color identity. For the default construction this is a
   procedural shader surface or a `LinearGradient` in the vibe's palette. It is
   also the fallback when an image fails to load, so it is never skipped.
2. **Subject** — the user's art. Two modes:
   - *Transparent subject (default)*: a cutout PNG with no background of its
     own. Use `.aspectRatio(contentMode: .fit)` and **do not clip to fill** —
     the transparency is the point; the foil background must show around it.
   - *Opaque photo*: a full-bleed photo. `.fill` + `.clipped()`, then a tint
     scrim (step 3).
3. **Tint scrim** (opaque photos only) — a translucent `LinearGradient` at
   **0.10–0.35 opacity** that marries the photo to the palette. A transparent
   subject needs **no** scrim; instead it needs legibility scrims only where
   text sits (see §6).
4. **Glass info panels + chrome** — name/title/stats/flavor, each on a
   translucent backing (§6). White text over dark art; black over gold/light.
5. **Border** — `RoundedRectangle.strokeBorder` with a 2–5 pt metallic gradient
   echoing the palette.

**Effect stack (modifier chain), first → last:**
1. **Foil / pattern base** — exactly one dominant identity:
   `.foil()`, `.blendedHolo()`, `.galaxyHolo()`, `.etchedFoil()`,
   `.starburst()`, `.verticalBeams()`, `.tradingCardHolo(style)`, …
2. **Texture / sparkle** — `.glitter()`, `.multiGlitter()`, `.shimmer()`.
3. **Light** — `.lightSweep()`, `.radialSweep()`, `.glare()`, or
   `.shader(.glassSheen())` LAST, so the reflection sits on top of everything.

Budget: **2–4 effects total**. One pattern + one sparkle + one light is the
demo-proven formula (`.foil().glitter().lightSweep()`). Two competing patterns
= mud. When layering more, lower each `intensity` (0.5–0.7).

**Where effects attach = the whole card vs. a sub-layer.** This is the single
most important choice:
- Attach the chain to the **whole card** → the foil shimmers over the subject
  too (Gradient Foil, Psychic Holo). Good for opaque photos and abstract cards.
- Attach the chain to the **background sub-layer only** → the subject stays
  pristine and the foil shimmers *around/behind* it (Foil+Glitter+Sweep,
  Layered Holo, Starburst). **This is the default for transparent subjects** —
  the cutout reveals a shimmering foil pocket behind it.

**Hard rule — pattern effects render BELOW the subject, never over it.** A
bright-core pattern (`.starburst()`, `.radialSweep()`, `.intenseBling()`,
`.galaxyHolo()` at high intensity) has a hot center that blooms and blows out
whatever it's composited over — put one on the whole card and it burns a white
hole through the subject. Only genuinely *translucent overlays* (a foil sheen,
frost, glitter, scattered stars, a light sweep) are safe on top of the subject.
Everything with structure or a hotspot goes on the background layer, below the
image. This holds for **any image** — opaque or transparent.

Consequence for **opaque full-bleed photos**: you cannot simply background-attach
a starburst, because the opaque photo would cover it entirely. Instead, inset
the subject into an **art window** (split-layer, §5-B) so the effect fills the
whole card and *frames* the clean subject, bursting around it — e.g. a starburst
on the full-card background with the subject in a rounded art window on top, rays
radiating in the margins and from behind the portrait. Never full-bleed a photo
over a bright pattern.

Critical rule: premium materials (`.polishedAluminum`, `.brushedTitanium`,
`.blackChrome`, `.oilSlick`, …) are **opaque** — never over a subject you want
visible. Use them as the card surface itself (no photo) or on chrome elements.

## 2. Default construction — Transparent Full-Bleed Subject

The primary layout. A large transparent-PNG subject floats over a shimmering
foil background; glass panels carry the text. It is the Foil+Glitter+Sweep
technique (effects on the base, clean art on top) fused with the
`FullArtCardFace` info-panel idiom.

```swift
HolographicCardContainer(
  width: 280, height: 400, cornerRadius: 20,
  shadowColor: vibe.shadow, rotationMultiplier: 13,
  interactionMode: .surfacePointer
) {
  ZStack {
    // 1 — background carries the foil (effects on THIS layer only)
    RoundedRectangle(cornerRadius: 20)
      .fill(LinearGradient(colors: vibe.base, startPoint: .topLeading, endPoint: .bottomTrailing))
      .foil().glitter().lightSweep()          // ← per-vibe effect stack

    // 2 — transparent subject, clean, fit (NOT clipped/filled)
    Image(subject).resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 280, height: 400)

    // 3 — legibility scrims only where text sits (top + bottom)
    VStack {
      LinearGradient(colors: [.black.opacity(0.55), .clear], startPoint: .top, endPoint: .bottom)
        .frame(height: 400 * 0.16)
      Spacer()
      LinearGradient(colors: [.clear, .black.opacity(0.62)], startPoint: .top, endPoint: .bottom)
        .frame(height: 400 * 0.42)
    }

    // 4 — glass info panels + chrome (see §6)
    cardChrome

    // 5 — border
    RoundedRectangle(cornerRadius: 20)
      .strokeBorder(vibe.borderGradient, lineWidth: 3)
  }
}
```

Why the effects are on the background sub-layer, not the whole card: a
transparent subject has holes, so whole-card foil would shimmer *through* the
subject and flatten it. Keeping foil on the background makes the subject read
as a solid object sitting in a holographic well.

If the user's image is actually an opaque photo, fall back to the classic
Full-Art construction (§5-A) with a tint scrim.

## 3. Hero recipes — the seven analyzed demo cards

Each is a proven, copy-ready preset. Values are exact.

### R1 · Iridescent Premium (`FoilGlitterSweepView`)
Container `260×380, cornerRadius 16, shadowColor .orange, rotationMultiplier 12`.
Base gradient (topLeading→bottomTrailing):
`(0.95,0.85,0.5) → (0.9,0.75,0.4) → (0.85,0.7,0.35)`.
Effects **on the base layer**: `.glitter().foil()`. Subject + text sit on top
clean. Border `[.yellow.opacity(0.8), .orange.opacity(0.6), .yellow.opacity(0.8)]`, lineWidth 4.

### R2 · Sunset Gradient (`GradientFoilView`)
Container `280×400, cornerRadius 20, shadowColor .orange`.
Base `[.pink, .purple, .blue, .orange]` (system), topLeading→bottomTrailing.
Effects **whole card**: `.foil().glitter().lightSweep()`.
Border `[.orange, .yellow, .red]`, lineWidth 3.

### R3 · Tech-Mono / Codex (`CodexGradientFoilView`)
Container `280×400, cornerRadius 20, shadowColor = mid`.
Palette (vertical top→bottom): `light (177,167,255) → mid (122,157,255) → deep (57,65,255)` (÷255).
Effects **whole card**: `.foil().glitter().lightSweep()`.
Every text label gets `.shadow(color: .black.opacity(0.65), radius: 2, y: 1)`.
Border reuses the same vertical palette gradient, lineWidth 3.

### R4 · Psychic Cosmic (`PsychicHoloView`)
Container `280×392 (width×1.4), shadowColor .purple`.
Base `[.purple, .pink, .purple.opacity(0.8)]` topLeading→bottomTrailing.
**Dual scrim** for legibility: top `[.purple.opacity(0.9), .purple.opacity(0.7), .clear]` (height h×0.18); bottom `[.clear, .black.opacity(0.6), .black.opacity(0.85)]` (height h×0.45).
Effects **whole card**: `.foil().glitter().lightSweep()`.
Border `[.white.opacity(0.6), .purple.opacity(0.8), .white.opacity(0.3)]`, lineWidth 3. Clip corner 16.

### R5 · Burst Hero (`StarburstRadialView`)
Container `260×364, shadowColor .yellow, rotationMultiplier 12`.
Base gold `(1.0,0.85,0.2) → (1.0,0.85,0.2)·0.9 → (1.0,0.7,0.0)·0.7`.
**Two effect sites**: base layer `.starburst()`; whole card `.radialSweep().multiGlitter()`.
Subject is only 70% card height, `.offset(y: -h×0.05)`; an opaque gold panel
covers the lower third for text. Border is 5-stop gold/white, lineWidth 5.

### R6 · Floating Depth (`LayeredHoloView`) — split-layer
Container `260×364, shadowColor .yellow, rotationMultiplier 12`. Three siblings:
1. Background (frame w×h) `.blendedHolo(intensity: 0.7, saturation: 0.75)`,
   gold base `(0.92,0.85,0.55) → (0.88,0.8,0.45) → (0.85,0.75,0.4)`.
2. Sparkle pocket (frame `w×0.88 × h×0.41`, dark-teal fill) `.verticalBeams()`,
   `.offset(y: -h×0.198)`.
3. Clean subject — **same frame + same offset** as the pocket, **no effects**.
The shared frame/offset is what makes the art float on an animated foil pocket.

### R7 · Reverse-Holo Framed (`MaskedFoilView`)
Container `260×364, shadowColor .yellow, rotationMultiplier 12`.
`imageWindow = SIMD4<Float>(0.04, 0.20, 0.96, 0.64)`.
Base gold `(0.95,0.9,0.6) → (0.92,0.85,0.5) → (0.88,0.8,0.45)`.
Effects **on the base layer**, all passing the same window:
`.maskedFoil(imageWindow:).maskedSparkle(imageWindow:).foilTexture(imageWindow:)`.
The art window ZStack is laid out on top at the matching screen position
(`w×0.92 × h×0.44`), staying clean while the frame shimmers.

## 4. Named vibes → recipe + palette

The interview asks for a **vibe**, not colors. Map the answer to a recipe (§3),
a palette, and a `shadowColor`. Palettes below are lifted from the ShaderCards
premium editions (`(r,g,b)` = `Color(red:green:blue:)`).

| Vibe | Recipe / effect stack | Base palette | shadow |
|---|---|---|---|
| Iridescent Premium (gold) | R1 · base `.glitter().foil()` | `(0.95,0.85,0.5)/(0.9,0.75,0.4)/(0.85,0.7,0.35)` | `.orange` |
| Sunset Gradient | R2 · whole `.foil().glitter().lightSweep()` | `[.pink,.purple,.blue,.orange]` | `.orange` |
| Tech-Mono / Codex | R3 · whole `.foil().glitter().lightSweep()` + text shadows | `(177,167,255)/(122,157,255)/(57,65,255)` ÷255 | mid |
| Psychic Cosmic | R4 · whole `.foil().glitter().lightSweep()` + dual scrim | `[.purple,.pink,.purple·0.8]` | `.purple` |
| Burst Hero | R5 · base `.starburst()` + whole `.radialSweep().multiGlitter()` | gold `(1.0,0.85,0.2)…` | `.yellow` |
| Floating Depth | R6 split-layer · `.blendedHolo(0.7,0.75)` + `.verticalBeams()` | gold `(0.92,0.85,0.55)…` | `.yellow` |
| Reverse-Holo Framed | R7 · `.maskedFoil/.maskedSparkle/.foilTexture` (window) | gold `(0.95,0.9,0.6)…` | `.yellow` |
| Winter Frost (glacier) | whole `.frozen()` + `.lightSweep()` | `(0.78,0.88,0.96)/(0.55,0.72,0.88)/(0.30,0.48,0.70)` | `.cyan` |
| Pastel Pop (bubblegum) | whole `.halftonePastel()` + `.rainbowGlitter()` | `(0.98,0.75,0.85)/(0.85,0.80,0.95)/(0.70,0.92,0.90)` | `.pink` |
| Oil-Slick (interference) | **opaque** `.oilSlick()` — no subject | `(0.015,0.02,0.045)/(0.13,0.06,0.23)/(0.02,0.14,0.18)` | `.purple` |
| Copper Patina (verdigris) | **opaque** `.copperPatina()` — no subject | `(0.22,0.08,0.035)/(0.50,0.22,0.08)/(0.04,0.30,0.25)` | `.green` |
| Industrial Metal (titan/mercury/quicksilver) | **opaque** `.brushedTitanium()` / `.liquidMercury()` / `.polishedAluminum()` | titan `(0.20,0.25,0.32)/(0.52,0.59,0.68)/(0.16,0.20,0.27)` | `.white` |

**One-shot trading-card holos** (`.tradingCardHolo(style)` — a full foil recipe
in one call; still pairs with `.glitter()`/`.lightSweep()`):
Pikachu Secret Rare → `.pikachuSecretRare` · Shiny V → `.shinyV` · Rainbow
Alternate → `.rainbowAlternate` · V Full Art → `.vFullArt` · Tidecaller V →
`.vRegular`. Use with a transparent subject over a dark base.

Notes: "mindware" → closest catalog match is `mindwave` (psychic wave, purple
`(0.38,0.12,0.55)/(0.62,0.20,0.62)/(0.88,0.40,0.70)`). "thornspite" has no
catalog match — treat as a custom green/thorn palette or ask.

## 5. Other constructions (secondary)

### A. Full-Art opaque photo — when the image is a real photo, not a cutout
Same as §2 but the subject is `.aspectRatio(.fill).clipped()` and step 3 is a
full tint scrim (`0.10–0.35` opacity), not just edge scrims.

### B. Split-Layer — see R6. Best when you want a crisp subject over shimmer.

### C. Masked window — see R7. Reverse-holo: foil frame, clean art window.

### D. Atmosphere (no photo) — near-black gradient + one atmospheric effect.
```swift
SimpleCardContent(title: "COSMOS HOLO", subtitle: "Galaxy Rare") {
  RoundedRectangle(cornerRadius: 16)
    .fill(LinearGradient(colors: deepSpaceStops, startPoint: .top, endPoint: .bottom))
    .galaxyHolo(intensity: 0.8)
}
```
Swap `.galaxyHolo` for `.frozen()`, `.snowfall()`, `.liquidTech()`,
`.halftonePastel()`, or an **opaque** material for the metal vibes.

## 6. Glass & translucent info panels

The user wants text on "glass". Two facts from the codebase decide how:

1. **`.ultraThinMaterial` samples what is behind the app window, not the card
   art.** On a card face it looks wrong/flat. Reserve Material for floating
   HUD/editor chrome that sits over a real blurred backdrop — not card panels.
2. **The glass Metal shaders** (`.shader(.glassEnclosure())`,
   `.glassSheen()`, `.glassBevel()`, `.chromaticGlass()`) are whole-card
   *surface finishes* — they distort/reflect, they are not a legible flat
   backing. `.shader(.glassSheen(intensity: 0.15, spread: 0.5))` is a great
   final whole-card closer for a laminated sheen; the others are for atmosphere.

**The correct on-card info panel** (house style, from `FullArtCardFace`):
translucent color fill + hairline white stroke, over legibility scrims.

```swift
Text("…")                                   // plain white text
  .padding(10)
  .background(
    RoundedRectangle(cornerRadius: 12)
      .fill(.black.opacity(0.34))           // .white.opacity(0.55–0.75) on light cards
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
      )
  )
```

So: **scrims** for global legibility (§2 step 3), **translucent-fill panels**
for stat/name blocks, and **`.glassSheen` as the whole-card closer** if you
want a true glass sheen on top of the lamination. That trio is the "glass" look
without the Material pitfall.

## 7. The dark stage

Present the finished card centered on a near-black radial gradient so the foil
reads; never on white.

```swift
RadialGradient(
  colors: [stageCast, Color(red: 0.03, green: 0.03, blue: 0.05)],
  center: .center, startRadius: 40, endRadius: 620
)
.ignoresSafeArea()
```
`stageCast` ≈ the palette hue near `Color(red: 0.10, green: 0.06, blue: 0.16)`
brightness. Add `.preferredColorScheme(.dark)`, a headline above and a
"Drag to tilt" hint below.

## 8. Tuning checklist

- Foil shimmers *through* the transparent subject → move the effect chain from
  the whole card onto the background sub-layer only (§1).
- A bright pattern (starburst/radial sweep/intense holo) blooms over and washes
  out the subject → it's composited on top of the image. Move it to the
  background layer BELOW the image; for an opaque photo, inset the subject into
  an art window (§1 hard rule, §5-B) so the effect frames it instead.
- Subject edges look cut-out/harsh → add a faint inner shadow or a 1px
  `.white.opacity(0.15)` stroke matching the subject silhouette isn't possible
  for arbitrary PNGs; instead darken the background directly behind the subject
  or add a soft radial vignette.
- Foil invisible → raise the pattern's `intensity` before adding effects.
- Text unreadable → deepen the local scrim or the panel fill opacity, don't
  brighten the text past white.
- Looks noisy → remove one effect; two patterns never beat one.
- Whole card too dark → the base gradient is too dark for a translucent
  pattern; lighten it one step.
- Foil bleeding over the art window (R7) → tighten the `imageWindow` UV rect.
