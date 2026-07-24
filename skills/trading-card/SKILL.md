---
name: trading-card
description: This skill should be used when a user wants to turn an image into a holographic Pokémon-style trading card with ShaderKit — triggered as `/trading-card <image-path>`, optionally with a short description hint. Zero questions: given only an image it invents a cool creature name and stats, randomly selects a holographic card design, and renders a tilt-interactive trading card composed from ShaderKit primitives (HolographicCardContainer + a hand-tuned shader stack, glass info panels) on a dark showcase screen. Triggers e.g. "make a trading card from this photo", "/trading-card ~/dog.png", "turn this into a holo card", "stack foil over my image". Requires the ShaderKit library product.
---

# Trading Card

Turn an image into a premium holographic **trading card** — no interview. Given
just an image path, invent a cool Pokémon-style creature name and stats, pick a
holographic design at random (foil vibe + effect stack + palette), compose the
card from ShaderKit primitives inside `HolographicCardContainer`, and render it
tilt-interactive on a dark stage. The result is a single SwiftUI view.

## Invocation

```
/trading-card <image-path> [optional short description hint]
```

- **`<image-path>`** (required) — the only thing the skill needs.
- **description hint** (optional) — a few words to steer the design, e.g.
  "icy", "cosmic", "gold legendary", "cyberpunk". Without it, choose a design
  at random.

**Do NOT interview the user.** The whole point is: image in → finished trading
card out. Invent every text field; the output is always a trading card.

## Prerequisite — Metal toolchain

ShaderKit's foils are Metal shaders. In **Xcode 26+ the Metal Toolchain is a
separate download** and is required to compile them. If a build fails with
`cannot execute tool 'metal' due to missing Metal Toolchain`, install it once,
then rebuild:

```
xcodebuild -downloadComponent MetalToolchain
```

Also: shaders compile only through Xcode's build system — `swift build` /
`swift run` copies `.metal` files raw and every foil renders blank. Always build
with `xcodebuild` (scheme `ShaderKitDemo` when working in this repo).

## Requirements

- The `ShaderKit` library product (this repo, or any project that depends on
  it). ShaderCards is NOT needed.
- One image at `<image-path>`. A transparent-PNG cutout is best (it floats over
  the foil); an opaque photo also works and gets a tint scrim.

## Workflow

### Step 1 — Verify the image
Confirm `<image-path>` exists. A missing path is the only thing the skill can't
invent — if it's absent, ask just for a valid path, nothing else. Copy the
image into the target's asset catalog (see Step 4) under a slug derived from the
invented name.

### Step 2 — Invent the character (no questions)
Read/inspect the image, then invent everything and print a one-line summary of
what you chose so the user sees it. Theme it to the subject (and to the
description hint if one was given):
- **Creature name** — a cool, punchy Pokémon-style name for the subject
  (husky → "FROSTFANG" / "VOIDMAW"; cat → "EMBERPAW"; etc.).
- **HP** — fits the vibe (180–999; higher reads "legendary/secret rare").
- **Role / title** — a species/epithet line (e.g. "Arctic Sentinel").
- **Motto** — one italic flavor line.
- **Two signature skills**, each with a damage number 90–300, themed to the
  creature and vibe.

### Step 3 — Select a design (random, or steered by the hint)
Load `references/composition-recipes.md` and pick a vibe → hero recipe:
- **No hint** → choose a vibe at **random** from the catalog (§4), and vary it
  run to run — do not default to the same vibe every time.
- **Hint given** → map keywords to the closest vibe:
  ice/winter/frost → Winter Frost · cosmic/space/psychic/spirit → Psychic
  Cosmic · gold/legendary/hero/radiant → Burst Hero · rainbow/secret/hyper/
  ultra → Secret Rare (Cosmic Apex) · metal/chrome/steel → Industrial Metal ·
  pastel/cute/soft → Pastel Pop · sunset/warm → Sunset Gradient · tech/mono →
  Tech-Mono/Codex · oil/dark iridescent → Oil-Slick · copper/patina/green →
  Copper Patina.

The chosen vibe fixes the palette, effect stack, and `shadowColor` together
(§4). Default construction: subject over a foil background with the **effect
stack on the background sub-layer** so the subject stays clean and the glass
panels stay legible (§1–2).

### Step 4 — Generate the showcase view
Exact API signatures (container parameters, every effect modifier and its
defaults, `TradingCardHoloStyle` cases, glass shaders, UV `imageWindow` format)
are in `references/shaderkit-api.md` — consult it instead of guessing.

Use `assets/ComposedCardShowcase.swift` as the starting template (default
transparent-subject construction) and fill in the invented name/stats + chosen
recipe, OR write a dedicated `NameView.swift` in the same style as the demo
cards. In this repo, add it under
`Demo/ShaderKitDemo/ShaderKitDemo/Views/ComposableShaders/` and wire it into the
`ContentView` navigation (enum case + section + description + icon +
destination). The demo project uses file-system-synchronized groups, so new
files need no `.pbxproj` edits. Platform tokens: `{{PLATFORM_IMAGE_TYPE}}` /
`{{PLATFORM_IMAGE_INIT}}` are `NSImage`/`nsImage` on macOS, `UIImage`/`uiImage`
on iOS.

### Step 5 — Build and render
Ensure the Metal toolchain is present (prerequisite above). Build with
`xcodebuild` (or XcodeBuildMCP), install to the simulator, and screenshot to
confirm the card looks premium — dark stage, visible foil around/behind the
subject, crisp glass panels — before declaring it done. If something is off,
apply recipes §8 (tuning checklist); the most common fix is moving the effect
chain onto the background sub-layer so effects don't bury the text.

### Step 6 — Offer variations
Offer to **reroll the design** (pick another random vibe), swap the pattern
effect, adjust an intensity, or change the invented stats. Each is a small
localized change.

## Bundled resources

- `references/shaderkit-api.md` — condensed, source-verified ShaderKit API:
  `HolographicCardContainer`, every effect modifier with parameters and
  translucent/opaque classification, the glass shaders, `TradingCardHoloStyle`,
  `SimpleCardContent`. Load before writing card code.
- `references/composition-recipes.md` — the stack doctrine, the default
  transparent-subject construction, the seven demo-verified hero recipes with
  exact params, the vibe → recipe/palette catalog, the glass info-panel idiom,
  dark-stage spec, and the tuning checklist. Load during Step 3.
- `assets/ComposedCardShowcase.swift` — tokenized SwiftUI template for the final
  showcase view (default transparent-subject construction). Copy and fill in Step 4.
