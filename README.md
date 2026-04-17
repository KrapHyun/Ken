# Harness Codex

Codex-adapted workspace port of [revfactory/harness](https://github.com/revfactory/harness).

This package keeps the original "meta-skill that creates more skills and workflows"
idea, but rewrites the runtime assumptions for the current Codex environment:

- Codex plugin metadata lives in `.codex-plugin/plugin.json`
- installable skills live under `skills/`
- workflow delegation must respect the current Codex runtime and tool policy
- role documents are treated as reusable project artifacts, not auto-executable
  custom agent types

## What This Plugin Does

The `harness` skill helps you:

- audit an existing workflow/skill setup
- design domain-specific roles and orchestration patterns
- draft reusable role docs under `.codex/agents/`
- draft installable skills under `.codex/skills/` or plugin-local `skills/`
- package the result as a repo-local Codex plugin

## Workspace Packaging

This workspace also includes a repo-local marketplace entry at:

- `.agents/plugins/marketplace.json`

That entry points to:

- `./plugins/harness-codex`

## Source Notes

This port was created by adapting ideas and structure from:

- upstream: `revfactory/harness`
- Codex-oriented public fork reference: `song-younghoon/harness-codex`

The content here is trimmed and adjusted to the current Codex runtime, especially
around delegation and orchestration constraints.

## Global Install

From the plugin root, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-global.ps1
```

That installs:

- the skill into `~/.codex/skills/harness`
- the plugin into `~/plugins/harness-codex`
- a marketplace entry into `~/.agents/plugins/marketplace.json`

## Suggested Prompts

- `Build a harness for this project`
- `Design a Codex harness for this repo`
- `Audit the current harness and extend it`
