# SDD Triad — Conventions

This file is read automatically by AI coding agents (Cursor, Claude Code, etc.) when working in this repository.

---

## The Agent/Skill Boundary

**If it routes, it's an agent. If it executes, it's a skill.**

- **Agent** (`agents/`): Has its own conversational identity, makes routing/dispatch decisions, or needs an isolated context window (for parallelism or state isolation).
- **Skill** (`skills/<name>/`): Executes one coherent task with a well-defined input → output contract. Always called by an agent. Never routes.

The SDD Triad has two skills (`sdd-spec-writer`, `sdd-scenario-writer`) and four agents (`sdd-coach`, `sdd-orchestrator`, `sdd-writer`, `sdd-evaluator`). The writer and evaluator are agents specifically because of the information barrier requirement — they need clean, isolated context windows, not because they route. See `docs/spec-sdd-triad.md` for the full rationale.

---

## Naming

- **Skills**: `domain-verb[-scope]` — e.g. `sdd-spec-writer`, `sdd-scenario-writer`
- **Agents**: descriptive nouns or role names — e.g. `sdd-coach`, `sdd-orchestrator`

---

## Skill Requirements

Every skill must have:

- `SKILL.md` with a `## Defaults` section listing behavioral defaults
- `README.md` with a `## Customization` section

---

## Repository Structure

```
sdd-triad/
├── README.md
├── LICENSE
├── package.json
├── AGENTS.md              # This file
├── scripts/
│   ├── install-skills.sh
│   └── install-agents.sh
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md       # Required
│       └── README.md      # Required
├── agents/
│   └── <agent-name>.md    # Agent definition
└── docs/
    └── spec-sdd-triad.md  # Design rationale
```
