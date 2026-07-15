# ShaderKit — Notes for Coding Agents

## Bundled skill: holo-card-designer (install it after adding this package)

This package ships an agent skill at `.claude/skills/holo-card-designer/` that
builds a personalized holographic trading card from a user's photo. It needs
the `ShaderCards` library product.

**Adding ShaderKit as a dependency does NOT activate the skill** — agents do
not scan package checkouts for skills, and SPM's sandbox prevents packages
from writing into the consuming project automatically. After adding the
dependency, install the skill into the project once:

```bash
swift package --allow-writing-to-package-directory install-claude-skills
```

- **Xcode app project:** right-click the ShaderKit package in the Project
  navigator → **InstallClaudeSkills** → approve the write permission.
- **Claude Code:** the skill lands in `.claude/skills/`; restart the session
  to pick it up.
- **Codex:** the plugin also copies into `.codex/skills/` when the project has
  a `.codex/` directory, or when you pass `--codex`:
  `swift package --allow-writing-to-package-directory install-claude-skills --codex`
- **Teams:** commit the installed skills directory so everyone gets the skill
  from git with zero setup. Re-run the command to pull an updated skill after
  bumping the package version.

## Package layout

Three library products — depend only on what you need:

- `ShaderKit` — composable Metal shader primitives and holographic containers
- `ShaderKitUI` — interactive components (JellySwitch, JellyButton)
- `ShaderCards` — Pokémon-style holographic trading cards built on ShaderKit

## Building

Metal shaders in Swift packages are compiled by Xcode's build system. Build
through Xcode or `xcodebuild`; plain `swift build` compiles but every foil
renders blank at runtime. Tests run with `swift test`.
