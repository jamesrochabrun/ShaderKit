---
name: holo-card-composer
description: This skill should be used when a user wants a custom holographic trading card composed directly from ShaderKit primitives — full creative control over shader stacking, e.g. "build me a custom holo card with ShaderKit", "compose foil and glitter over my photo", "make a card like the ShaderKit demo cards", "stack shaders over a gradient", or when the project depends on the ShaderKit library but not ShaderCards. It interviews the user (favorite colors, foil vibe, card construction, personal details), composes a layer stack (gradients, image, scrim, chrome) with a tuned shader effect chain inside HolographicCardContainer, and renders the tilt-interactive result on a dark showcase screen. For preset Pokémon-style cards built with the ShaderCards catalog, use holo-card-designer instead.
---

# Holo Card Composer

Compose a personalized holographic trading card from ShaderKit **primitives**:
`HolographicCardContainer` for tilt-interactive 3D, hand-built content layers
(gradients, an optional photo, a tint scrim, chrome, a border), and a
hand-tuned chain of Metal shader effects. Full flexibility — no ShaderCards
presets — with results matching the cards in the ShaderKitDemo app
(`GradientFoilView`, `LayeredHoloView`, `MaskedFoilView`, `CosmosHoloView`).

The deliverable is a single SwiftUI view: the composed card on a dark stage.
Hardcoding the interview answers into the generated view is expected and fine.

## Requirements

- The `ShaderKit` library product (this repo, or any project that depends on
  it). ShaderCards is NOT needed.
- Optionally one user image (PNG/JPEG/HEIC) — cards also work photo-free.

## Workflow

### Step 1 — Get the image (optional)

Ask whether the card should feature a photo or be a pure shader/gradient
piece (like the demo's cosmos and frozen cards). If a photo: get the file
path and verify it exists. The generated code loads it from a hardcoded
absolute path (fine for a personal demo card) and falls back to the base
gradient when loading fails.

### Step 2 — Interview the user

Use AskUserQuestion. Two rounds. Keep options visual and descriptive, not
technical.

**Round 1 — the look:**
1. Favorite colors (multiSelect: warm reds/oranges, ocean blues,
   purples/violets, greens, golds/yellows, pinks/pastels, silver/monochrome,
   black/moody).
2. Foil vibe: Classic TCG holo · Rainbow/iridescent · Etched premium ·
   Cosmic night sky · Ice/winter · Gold secret-rare · Pure metal (no photo).
3. Construction: Full-Art Foil (effects over a full-bleed photo) ·
   Split-Layer (crisp photo floating over animated shimmer) ·
   Framed Window (foil frame, clean art window — reverse-holo look) ·
   Atmosphere (no photo; moody procedural art).

**Round 2 — the person (this data gets printed on the card):**
1. Card name (their name, nickname, or alter ego).
2. Role/title — printed under the art (e.g. "Senior Product Designer").
3. A motto or fun fact — printed as italic flavor text.
4. Two signature skills — become the stat rows with bold damage numbers
   (e.g. "Design Review — 120").

### Step 3 — Map answers to a composition

Load `references/composition-recipes.md` and pick:
- **Base gradient + tint scrim + shadowColor** from the favorite colors
  (section 3 has concrete `Color(red:green:blue:)` stops per palette).
- **Effect stack** from the foil vibe (section 3 lists proven chains; obey
  chain order: pattern → sparkle → light, 2–4 effects total).
- **Construction** (section 2: A Full-Art, B Split-Layer, C Framed Window,
  D Atmosphere) — each has a code skeleton copied from a demo card.

Critical rule: premium material effects (`.brushedTitanium`, `.blackChrome`,
`.oilSlick`, …) are **opaque** and hide any photo. Over an image, use only
translucent effects — the API reference marks which is which.

### Step 4 — Generate the showcase view

Exact API signatures (container parameters, every effect modifier and its
defaults, `TradingCardHoloStyle` cases, UV `imageWindow` format) are in
`references/shaderkit-api.md` — consult it instead of guessing.

Copy `assets/ComposedCardShowcase.swift` into the target (for this repo:
`Demo/ShaderKitDemo/ShaderKitDemo/Views/`, wired into the demo navigation; in
a consuming app: wherever the user wants it) and replace every `{{TOKEN}}`.
Platform tokens: `{{PLATFORM_IMAGE_TYPE}}` / `{{PLATFORM_IMAGE_INIT}}` are
`NSImage` / `nsImage` on macOS and `UIImage` / `uiImage` on iOS.
`{{EFFECT_STACK}}` is the chosen modifier chain, one per line.

The template implements construction A (Full-Art). For B, C, or D, keep the
template's stage/tokens and restructure the card's ZStack following the
skeleton in the recipes file.

### Step 5 — Build and show it

**Metal shaders in this package compile only through Xcode's build system.**
`swift build` / `swift run` copies `.metal` files raw and every effect renders
blank. Build with `xcodebuild` or XcodeBuildMCP (scheme `ShaderKitDemo` when
working in this repo) and screenshot the simulator to confirm the card
actually looks premium — dark stage, visible foil, readable chrome — before
declaring it done. If something is off, apply section 5 of the recipes file
(tuning checklist).

### Step 6 — Iterate

Offer quick variations: swap the pattern effect, adjust an intensity, change
the scrim opacity, or try another construction. Each is a small localized
change in the generated view.

## Bundled resources

- `references/shaderkit-api.md` — condensed, source-verified ShaderKit API:
  `HolographicCardContainer`, every effect modifier with parameters and
  translucent/opaque classification, `TradingCardHoloStyle`,
  `SimpleCardContent`. Load before writing card code.
- `references/composition-recipes.md` — the stack doctrine (content layers +
  effect chain order), four demo-proven constructions with code skeletons,
  interview → palette/effect mappings, dark-stage spec, tuning checklist.
  Load during Step 3.
- `assets/ComposedCardShowcase.swift` — tokenized SwiftUI template for the
  final showcase view (construction A). Copy and fill during Step 4.
