# SDD Scenario Writer

Helps author or improve evaluation scenarios for the SDD Triad (spec-driven proposal system). Guides the user through use cases, stress tests, anti-pattern regression signals, and comparison tables — and runs a quality checklist to catch common weaknesses before the scenarios enter the write/evaluate loop.

## Trigger Phrases

- "write SDD scenarios"
- "help me write scenarios"
- "create scenarios for the triad"
- "improve my scenarios"
- "check my scenarios"
- "scenario review"

## Prerequisites

None — this is a pure authoring skill. No MCP tools required. Works best when the user has a companion spec document (authored via `sdd-spec-writer`).

## How It Works

1. **Elicits use cases** — named real-world situations with specific questions the evaluator checks proposals against
2. **Elicits stress tests** — structural pass/fail conditions with binary pass conditions
3. **Elicits anti-pattern signals** — observable symptoms, failure modes, and metric mappings
4. **Builds comparison tables** — when distinct structural approaches need side-by-side scoring
5. **Guards the information barrier** — flags any spec content that has leaked into the scenarios, and any scenario/spec duplication
6. **Applies the feedback test** — ensures every scenario can produce actionable writer feedback without naming the scenario
7. **Runs a quality checklist** — nine checks for concreteness, pass conditions, metric cross-references, and separation of concerns

## When to Use

- Before running the SDD Triad for the first time on a new domain
- When the triad has stalled and you suspect the scenarios are too vague or overlap with the spec
- When reviewing someone else's scenarios before evaluation

## Customization

No configurable parameters. The skill's quality checklist is fixed — it reflects the structural requirements documented in `docs/spec-sdd-triad.md`.

Override behavioral defaults inline: "skip the checklist, just write the scenarios from what I've told you."
