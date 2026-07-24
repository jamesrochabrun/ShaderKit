# ShaderKit — Notes for Coding Agents

## Bundled skills (installed as a plugin)

This repo is also an agent plugin. It ships one skill under `skills/`:

- `trading-card` — turns an image into a holographic Pokémon-style trading card
  built from raw ShaderKit primitives. Invoke `/trading-card <image-path>` (plus
  an optional description hint); no interview — it invents the creature name and
  stats and picks a holographic design (needs only `ShaderKit`).

**Adding ShaderKit as a Swift package dependency does NOT activate the
skill** — agents do not scan package checkouts for skills. The skill is
distributed through the standard plugin mechanisms instead; nothing is
written into the consuming project.

- **Claude Code:** the repo doubles as a plugin marketplace
  (`.claude-plugin/marketplace.json` + `.claude-plugin/plugin.json`).
  Install with:

  ```
  /plugin marketplace add jamesrochabrun/ShaderKit
  /plugin install shaderkit@shaderkit
  ```

  The skill is then available as `shaderkit:trading-card`. Pull skill
  updates later with `/plugin marketplace update`.
- **Codex:** the repo also carries a Codex plugin manifest
  (`.codex-plugin/plugin.json`) and a repo-scoped marketplace at
  `.agents/plugins/marketplace.json`. Register it with
  `codex plugin marketplace add jamesrochabrun/ShaderKit`, then install
  from the `/plugins` browser (or the ChatGPT desktop app's Plugins pane).
- **Working inside this repo:** load the plugin directly with
  `claude --plugin-dir .` — no installation needed.

When a skill changes, bump `version` in both `.claude-plugin/plugin.json`
and `.codex-plugin/plugin.json` alongside the package release tag.

## Package layout

Three library products — depend only on what you need:

- `ShaderKit` — composable Metal shader primitives and holographic containers
- `ShaderKitUI` — interactive components (JellySwitch, JellyButton)
- `ShaderCards` — Pokémon-style holographic trading cards built on ShaderKit

## Building

Metal shaders in Swift packages are compiled by Xcode's build system. Build
through Xcode or `xcodebuild`; plain `swift build` compiles but every foil
renders blank at runtime. Tests run with `swift test`.
