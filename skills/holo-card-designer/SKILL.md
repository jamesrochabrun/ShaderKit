---
name: holo-card-designer
description: This skill should be used when a designer wants a personalized Pokémon-style holographic trading card built from their own image using the ShaderCards package — e.g. "make me a holo card from this photo", "turn this image into a foil trading card", "create my personal holographic card", or "make a metal shader card for me". It interviews the user (favorite colors, layout, personal details), maps the answers to ShaderCards finishes and gradients layered over the image, and renders the card with the tilt-interactive holographic container on a dark showcase screen. For fully custom cards composed from raw ShaderKit primitives (no ShaderCards), use holo-card-composer instead.
---

# Holo Card Designer

Turn a designer's image and a short interview into a beautiful, personalized
Pokémon-style holographic trading card. The card reuses ShaderCards'
`TradingCardView` (ShaderKit's `HolographicCardContainer` underneath) for
drag-to-tilt 3D interaction and live Metal shader foils, layers gradients over
the user's image, and is presented centered on a dark stage so the holo pops.

The deliverable is a single SwiftUI view: the card with the user's asset and
personal context, on a dark background. Hardcoding the interview answers into
the generated view is expected and fine.

## Requirements

- The `ShaderCards` library from the ShaderKit package (this repo, or an app that depends on it).
- One user-provided image (PNG/JPEG/HEIC). Ask for a file path if none was given.

## Workflow

### Step 1 — Get the image

Ask for the image file path if the user has not provided one. Verify the file
exists. The generated code loads it with `Data(contentsOf:)` from a hardcoded
absolute path (fine for a personal demo card) and falls back to the base
gradient if loading fails. If the card ships in an app, recommend moving the
image into the bundle later.

### Step 2 — Interview the user

Use AskUserQuestion. Keep it to two rounds. This skill is for designers — make
the options visual and descriptive, not technical.

**Round 1 — the look:**
1. Favorite colors (multiSelect: warm reds/oranges, ocean blues, purples/violets,
   greens, golds/yellows, pinks/pastels, silver/monochrome, black/moody).
2. Foil vibe: Classic TCG holo · Rainbow/iridescent foil · Precious metal ·
   Ice/cosmic atmosphere.
3. Layout: Full Art (photo bleeds to the edges — best for photos) ·
   Minimal (poster: name banner + info line only) · Framed (classic Pokémon
   frame with stats below the art window).

**Round 2 — the person (this data gets printed on the card):**
1. Card name (their name, nickname, or alter ego).
2. Role/title — printed as the species line (e.g. "Senior Product Designer").
3. A fun fact or motto — printed as flavor text.
4. Two signature skills — become attack names (e.g. "Design Review", "Ship It").
   Skip attacks when the layout is Minimal (that layout doesn't render them).

### Step 3 — Map answers to a design

Load `references/design-recipes.md` and pick:
- **Element** from the favorite colors (drives frame palette + energy icons).
- **Finish** from the vibe (a named `CardFinish` preset, a `.tradingCardHolo`
  style, or a custom effect stack).
- **Base gradient** and **translucent tint scrim** from the favorite colors —
  the scrim is what marries the photo to the foil palette.
- **Rarity** to match the finish tier (affects the footer symbol).

Critical rule: premium material finishes (`.brushedTitanium`, `.blackChrome`,
`.oilSlick`, …) are **opaque** surface shaders — they hide the photo. Over a
user image, only use translucent holo stacks (foil, glitter, tradingCardHolo,
galaxyHolo, glassSheen, lightSweep…). The recipes file lists which is which.

### Step 4 — Generate the showcase view

Copy `assets/PersonalCardShowcase.swift` into the target (for this repo:
`Sources/ShaderCardsDemo/`), replace every `{{TOKEN}}`, and wire it in (a new
tab in `DemoRootView`, or the app's root). The template already provides the
dark radial-gradient stage, `.preferredColorScheme(.dark)`, and the layered
art pattern:

```swift
.layered([
  .gradient(baseColors),   // opaque backdrop in the user's palette
  .image(imageData),       // the user's asset, aspect-filled
  .gradient(tintScrim),    // translucent stops (0.15–0.35 opacity) tint the photo
])
```

Exact API signatures (CardBuilder, CardModel, CardFinish presets, views) are in
`references/card-api.md` — consult it instead of guessing.

### Step 5 — Build and show it

**Metal shaders in this package compile only through Xcode's build system.**
`swift build` / `swift run` copies `.metal` files raw and every foil renders
blank. Build with `xcodebuild` or XcodeBuildMCP (`build_run_sim`, scheme
`ShaderCardsDemo`) so the simulator shows real foil. Take a screenshot to
confirm the card actually looks premium — dark stage, visible holo — before
declaring it done.

### Step 6 — Iterate

Offer quick variations: swap the finish preset, adjust scrim opacity, or try
another layout. Each is a one-line change in the generated view.

## Bundled resources

- `references/card-api.md` — condensed, accurate ShaderCards API: models,
  builder, finishes, views. Load before writing card code.
- `references/design-recipes.md` — interview-answer → design mappings: color
  palettes, finish pairings, gradient/scrim recipes, opaque-vs-translucent
  effect catalog, dark-stage spec. Load during Step 3.
- `assets/PersonalCardShowcase.swift` — tokenized SwiftUI template for the
  final showcase view. Copy and fill during Step 4.
