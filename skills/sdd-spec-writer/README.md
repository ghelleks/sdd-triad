# SDD Spec Writer

Helps author or improve specification documents for the SDD Triad (spec-driven proposal system). Guides the user through the four required sections — requirements, proposal format, and static evaluation metrics — and runs a quality checklist to catch common weaknesses before the spec enters the write/evaluate loop.

## Trigger Phrases

- "write an SDD spec"
- "help me write a spec"
- "create a spec for the triad"
- "improve my spec"
- "check my spec"
- "spec review"

## Prerequisites

None — this is a pure authoring skill. No MCP tools required.

## How It Works

1. **Elicits constraints** — walks the user through hard constraints (non-negotiable facts) and soft constraints (preferences that distinguish valid from good)
2. **Defines proposal format** — ensures every required heading is named with what it must contain
3. **Defines static metrics** — each metric gets an ID and an unambiguous pass condition
4. **Guards the information barrier** — flags any scenario content that has leaked into the spec
5. **Runs a quality checklist** — nine checks for falsifiability, testable thresholds, completeness, and spec/scenario separation
6. **Writes or revises the spec** — produces a clean markdown document

## When to Use

- Before running the SDD Triad for the first time on a new domain
- When the triad has stalled and you suspect the spec is undercooked
- When reviewing someone else's spec before evaluation

## Customization

No configurable parameters. The skill's quality checklist is fixed — it reflects the structural requirements documented in `docs/spec-sdd-triad.md`.

Override behavioral defaults inline: "skip the checklist, just write the spec from what I've told you."
