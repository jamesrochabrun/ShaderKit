# Design recipes: interview answers → card design

How to turn the interview (colors, vibe, layout, person) into a concrete
element, finish, gradients, and rarity. Aim for *jewelry on a black velvet
tray*: dark stage, saturated-but-controlled foil, photo still readable.

## 1. Favorite colors → element + palette

| User's colors | Element | Base gradient (opaque, dark→mid) | Tint scrim (translucent stops) |
|---|---|---|---|
| Warm reds / oranges | `.fire` | deep maroon → ember orange | orange @ 0.25 → red @ 0.15 |
| Ocean blues / teals | `.water` | navy → teal | cyan @ 0.25 → blue @ 0.15 |
| Purples / violets | `.psychic` | indigo → violet → magenta | purple @ 0.30 → pink @ 0.15 |
| Greens | `.grass` | forest → emerald | green @ 0.25 → teal @ 0.12 |
| Golds / yellows | `.lightning` (electric) or `.colorless` (luxe gold) | bronze → amber | gold @ 0.30 → warm white @ 0.10 |
| Pinks / pastels | `.fairy` | plum → rose → peach | pink @ 0.25 → lavender @ 0.15 |
| Silver / monochrome | `.metal` | charcoal → slate | white @ 0.15 → blue-gray @ 0.10 |
| Black / moody | `.darkness` | near-black blues (0.03–0.12 RGB) | electric blue or violet @ 0.20 |
| Mixed / everything | `.dragon` or `.colorless` | two of the user's picks, darkened | third pick @ 0.20 |

Gradient construction: 2–4 `Color(red:green:blue:)` stops. The **base** layer
sits *behind* the photo (only visible if the image fails or has transparency) —
keep it dark. The **scrim** sits *on top*: every stop must carry
`.opacity(0.10–0.35)` or it will bury the photo. Run the scrim diagonal
(it renders topLeading→bottomTrailing) from stronger to weaker opacity so one
corner glows in the user's color.

## 2. Vibe → finish + rarity

Photo-safe options only (see §3 for why):

| Vibe answer | Finish | Rarity | Notes |
|---|---|---|---|
| Classic TCG holo | `.tradingCardHolo(.cosmosHolo)` (framed) or `.tradingCardHolo(.vFullArt)` (full art) | `.holoRare` / `.ultraRare` | The authentic Pokémon look. `cosmosHolo` keeps foil inside the art window. |
| Rainbow / iridescent | `.psychicWave` or `.codex`; max drama: `.tradingCardHolo(.rainbowRare)` | `.rainbowRare` | Foil + glitter + glare over the whole face. |
| Precious metal | gold: `.goldenSweep` or `.tradingCardHolo(.secretRareGold)`; silver: custom `CardFinish(cardEffects: [.etchedFoil(intensity: 0.5, density: 90), .lightSweep], isFullArt: true)` | `.hyperRare` (gold frame) / `.ultraRare` | Do NOT use the opaque material presets over a photo. |
| Ice / cosmic | ice: `.frozenCrystal`; cosmic: `CardFinish(cardEffects: [.galaxyHolo(intensity: 0.35), .glitter(density: 40), .lightSweep], isFullArt: true)` | `.illustrationRare` | Galaxy holo reads beautifully over portraits. |

Simplest reliable path: pick a rarity whose default finish matches the vibe and
pass `finish: nil` — `.illustrationRare` (galaxy), `.rainbowRare` (rainbow),
`.hyperRare` (gold) are all full-art and photo-friendly.

## 3. Opaque vs. translucent effects

**Opaque surface shaders — never over a photo** (they replace what's beneath):
`brushedTitanium, blackChrome, roseGold, liquidMercury, anodizedTitanium,
damascusSteel, forgedCarbon, copperPatina, pearlCeramic, oilSlick, polishedAluminum`
— and the presets built on them (`.brushedTitanium` … `.oilSlick`, `.quicksilver`).
Use these only when the user has no image or asks for a pure-material card
(art = gradient, layout = minimal).

**Translucent holo effects — photo-safe** (additive/blended):
`foil, glitter, multiGlitter, rainbowGlitter, sparkles, glassSheen, lightSweep,
radialSweep, glare, shimmer, verticalBeams, diagonalHolo, blendedHolo,
galaxyHolo, crisscrossHolo, etchedFoil, metallicCrosshatch, starburst, frozen,
snowfall, halftonePastel, spiralRings, tradingCardHolo, chromaticGlass`.
Keep whole-face intensities ≤ 0.5 over photos; `tradingCardHolo` defaults to
0.88 via the preset builder, which is fine because the style shaders are
luminance-aware.

## 4. Layout guidance

- Photo of a person/pet → `.fullArt`. The chrome floats on scrims; pick a
  photo where the subject isn't behind the name banner (top ~12%) or footer.
- Poster/brand-mark image → `.minimal`. Cleanest; renders no attacks, so skip
  the skills question or fold them into the flavor text.
- Playful "I'm a Pokémon" ask → `.framed`; attacks, HP, weakness all show.
  HP: pick something flattering, 120–250. Damage strings: "90", "150", or "∞".

## 5. The dark stage

The showcase background must be near-black so the foil highlights carry:

```swift
RadialGradient(
  colors: [Color(red: 0.10, green: 0.09, blue: 0.16),   // subtle color-cast center
           Color(red: 0.03, green: 0.03, blue: 0.05)],  // near-black edges
  center: .center, startRadius: 40, endRadius: 620)
```

Tint the center stop toward the user's element (e.g. `0.12, 0.06, 0.16` for
psychic). Add `.preferredColorScheme(.dark)`, generous vertical padding, and a
small caption (`.white.opacity(0.5)`) under the card — "drag to tilt". Card
width 300–340 on phones.

## 6. Personal data placement

| Interview answer | Card field |
|---|---|
| Name / alter ego | `CardBuilder(name:)` |
| Role / title | `.species("…")` |
| Fun fact / motto | `.flavor("…")` |
| Signature skills | `.attack("Skill", cost: [element, .colorless], damage: "90")` |
| Their name again | `.illustrator("…")` — designers love the credit line |
| Birthday/lucky number | `.setNumber("07/151")` |
| Strength as a stat | `.hp(180)` |
