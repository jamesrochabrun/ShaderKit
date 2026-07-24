---
name: holo-card-composer
description: This skill should be used when a user wants a custom holographic trading card composed directly from ShaderKit primitives — full creative control over shader stacking, e.g. "build me a custom holo card with ShaderKit", "compose foil and glitter over my image", "make a card like the ShaderKit demo cards", "stack shaders over a gradient", or when the project depends on the ShaderKit library but not ShaderCards. It interviews the user by VIBE (not raw colors), places a large transparent-PNG subject over a shimmering foil background, adds translucent "glass" info panels, and renders the tilt-interactive result on a dark showcase screen using HolographicCardContainer.
---

# Holo Card Composer

Compose a personalized holographic trading card from ShaderKit **primitives**:
`HolographicCardContainer` for tilt-interactive 3D, a large transparent subject
floating over a hand-built shimmering background, translucent glass info panels,
and a hand-tuned chain of Metal shader effects. Full flexibility — no
ShaderCards presets — with results matching the demo's composed cards
(`FoilGlitterSweepView`, `GradientFoilView`, `CodexGradientFoilView`,
`PsychicHoloView`, `StarburstRadialView`, `LayeredHoloView`, `MaskedFoilView`).

The deliverable is a single SwiftUI view: the composed card on a dark stage.
Hardcoding the interview answers into the generated view is expected and fine.

## Requirements

- The `ShaderKit` library product (this repo, or any project that depends on
  it). ShaderCards is NOT needed.
- Optionally one user image. **Prefer a large, transparent-background PNG**
  (a cutout subject) — that is the default construction. An opaque photo or a
  photo-free abstract card both also work.

## Workflow

### Step 1 — Get the image (optional)

Ask whether the card should feature an image or be a pure shader/gradient piece
(like the demo's cosmos and frozen cards).

- **Transparent PNG subject (default & best):** a large cutout with no
  background. It floats over the foil so the shimmer shows around it. Get the
  file path and verify it exists. `.aspectRatio(contentMode: .fit)`, no clip.
- **Opaque photo:** falls back to the classic full-art construction with a tint
  scrim (recipes §5-A).
- **No image:** atmosphere card (recipes §5-D) or an opaque-metal vibe.

Generated code loads the image from a hardcoded absolute path (fine for a
personal demo card) and falls back to the base gradient when loading fails.

### Step 2 — Preview the fields, THEN interview

Real user feedback: being asked for many fields one at a time, with no warning,
feels abrupt and catches people off guard. So set expectations first, make the
one visual choice actually visual, and batch the rest.

**2a — Show what's coming before asking anything.** Post a short heads-up that
lists every field you'll collect and WHERE each lands on the card, so the user
can prepare their answers. Share this checklist and anatomy:

> I'll build your card from: **image · vibe · name · HP (optional) · role ·
> motto · two skills (each with a damage number)**. Here's where each shows up:

```
┌──────────────────────────┐
│ NAME             HP ###   │  name → header       HP → header (optional)
│                           │
│       [ your image ]      │  image → full-bleed subject
│                           │
│  ┌─────────────────────┐  │
│  │ ⚡ Skill One    ###  │  │  skill 1 + damage → stat row
│  │ ✦ Skill Two    ###  │  │  skill 2 + damage → stat row
│  │    ROLE / TITLE     │  │  role → line under the art
│  │  "your motto here"  │  │  motto → italic flavor text
│  └─────────────────────┘  │
└──────────────────────────┘
   the VIBE = the whole foil + color treatment wrapping all of it
```
If a live example helps, point the user at the demo cards (FrostFang, Nocturne,
VOIDMAW under ShaderKitDemo → Composable Shaders) so they can see finished cards
before answering.

**2b — Pick the vibe (AskUserQuestion, single-select, WITH previews).** The vibe
is the one genuinely visual decision, so give every option a `preview` that
describes its look (palette + effect) so the user can picture the style before
choosing — don't make them guess from a name alone. Vibes (each maps to a hero
recipe, recipes §4): Iridescent Premium · Sunset Gradient · Tech-Mono/Codex ·
Psychic Cosmic · Burst Hero · Floating Depth · Reverse-Holo Framed · Winter
Frost · Pastel Pop · Industrial Metal · Oil-Slick · Copper Patina. Offer the
one-shot trading-card holos when relevant (Pikachu Secret Rare, Shiny V, Rainbow
Alternate, V Full Art, Tidecaller V). Only ask a follow-up construction question
(whole-card foil vs. clean subject) if the image type leaves it genuinely
ambiguous.

**2c — Collect the text fields in ONE prompt, not one at a time.** Ask for all
of the person fields together in a single message so it never feels like an
interrogation, and offer to invent any the user doesn't care to supply:
- **Card name** — header (their name, nickname, or alter ego).
- **Role / title** — line under the art (e.g. "Senior Product Designer").
- **Motto / fun fact** — italic flavor text.
- **Two signature skills**, each with a damage number 90–300 — the stat rows
  (e.g. "Design Review — 120").
- **HP / power number** (optional) — header.

### Step 3 — Map the vibe to a composition

Load `references/composition-recipes.md` and pick:
- **Construction** — default is §2 (transparent subject over foil background).
  Use §5-A for opaque photos, §5-D for no image.
- **Recipe + palette + shadowColor** from the chosen vibe (§4 table maps each
  vibe to one of the seven hero recipes in §3, with exact palette stops).
- **Effect attachment** — for a transparent subject, put the effect chain on
  the **background sub-layer** so the subject stays clean (§1). For opaque
  photos or abstract cards, whole-card is fine.
- **Glass info panels** (§6) — translucent color fill (`.black.opacity(0.34)`)
  + hairline `.white.opacity(0.25)` stroke, over legibility scrims. Do NOT use
  `.ultraThinMaterial` on the card face (it samples behind the window, not the
  art). Optionally close the whole card with `.shader(.glassSheen(intensity: 0.15))`.

Critical rule: premium material effects (`.brushedTitanium`, `.blackChrome`,
`.oilSlick`, `.copperPatina`, …) are **opaque** and hide any subject. Use them
only for the metal/oil-slick/patina vibes (no subject), or on chrome elements.

### Step 4 — Generate the showcase view

Exact API signatures (container parameters, every effect modifier and its
defaults, `TradingCardHoloStyle` cases, glass shader signatures, UV
`imageWindow` format) are in `references/shaderkit-api.md` — consult it instead
of guessing.

Copy `assets/ComposedCardShowcase.swift` into the target (for this repo:
`Demo/ShaderKitDemo/ShaderKitDemo/Views/`, wired into the demo navigation; in a
consuming app: wherever the user wants it) and replace every `{{TOKEN}}`.
Platform tokens: `{{PLATFORM_IMAGE_TYPE}}` / `{{PLATFORM_IMAGE_INIT}}` are
`NSImage` / `nsImage` on macOS and `UIImage` / `uiImage` on iOS.
`{{EFFECT_STACK}}` is the chosen modifier chain, one per line.

The template implements the default transparent-subject construction. For the
opaque-photo, split-layer, masked-window, or atmosphere constructions, keep the
template's stage/tokens and restructure the card's ZStack following the recipe.

### Step 5 — Build and show it

**Metal shaders in this package compile only through Xcode's build system.**
`swift build` / `swift run` copies `.metal` files raw and every effect renders
blank. Build with `xcodebuild` or XcodeBuildMCP (scheme `ShaderKitDemo` when
working in this repo) and screenshot the simulator to confirm the card actually
looks premium — dark stage, visible foil around the subject, readable glass
panels — before declaring it done. If something is off, apply recipes §8
(tuning checklist).

### Step 6 — Iterate

Offer quick variations: swap the vibe (whole recipe changes in one place),
adjust an intensity, deepen a scrim, move the effect chain between whole-card
and background, or add the `.glassSheen` closer. Each is a small localized
change in the generated view.

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
