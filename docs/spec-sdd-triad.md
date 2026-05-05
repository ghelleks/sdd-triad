# SDD Triad — Spec-Driven Proposal System

**Last updated:** 2026-04-15  
**Agents:** `sdd-orchestrator`, `sdd-writer`, `sdd-evaluator`  
**Companion:** `sdd-coach` (alias: Deming) — describes the philosophy; this document describes the implementation

---

## What it is

The SDD Triad is a system of three agents that implement the dark-factory pattern at Level 4: you provide a specification and a set of evaluation scenarios, the system generates proposals, evaluates them independently, and iterates until they converge.

The defining feature is an **information barrier** between proposal writers and evaluation scenarios. Writers are never shown the scenarios. Evaluators are never shown writer context. The orchestrator is the only agent that sees both. This mirrors how good evaluation works in practice: the grader doesn't tell the student what's on the test.

The three agents are:

| Agent | Role | Sees |
|-------|------|------|
| `sdd-orchestrator` | Runs the loop, enforces the barrier | Spec + scenarios + context |
| `sdd-writer` | Drafts proposals | Spec + context (no scenarios) |
| `sdd-evaluator` | Evaluates proposals against scenarios | Scenarios + proposal (no writer context) |

All three agents are **domain-agnostic**. They know nothing about org design, software, policy, or any particular problem. You bring the domain through the spec, scenarios, and context files.

---

## Relationship to existing infrastructure

### `sdd-coach` (Deming)

The `sdd-coach` agent describes why this pattern matters:

> *"Building agents cannot read the test scenarios. This prevents teaching to the test. When scenarios are opaque to building agents, passing a scenario means the artifact genuinely works."*

Where `sdd-coach` advises on writing specs and understanding the dark-factory pattern conceptually, the SDD Triad executes it operationally.

### Looper CRITIC (`docs/scenarios/CRITIC.md`)

The Looper system's CRITIC was a domain-specific version of this pattern: a blueprint reviewer that checked Looper build artifacts against Looper-specific scenarios. The SDD Triad generalizes it into reusable, domain-agnostic agents that work on any spec/scenarios pair.

---

## The information barrier

### Why it exists

Without a barrier, a writer who sees the scenarios will write to pass them — producing proposals that look like they address the evaluation criteria without genuinely solving the underlying problem. This is the same failure mode as a student who memorizes test answers: the output appears correct but the understanding isn't there.

With the barrier in place, a proposal that passes evaluation does so because it actually addresses the problem domain well enough that the scenarios are satisfied as a side effect — not because the writer reverse-engineered the test.

### How it is enforced

Defense in depth across four layers:

1. **Writer system prompt** — the writer is explicitly told it must not read scenario files and must not search for them
2. **Orchestrator embeds content** — the orchestrator passes spec and context as embedded text in writer prompts, not as file paths; the scenarios file path is never mentioned
3. **Evaluator feedback is sanitized** — before any evaluator feedback reaches a writer, the orchestrator reviews it for leakage (scenario IDs, names, category labels, characteristic phrasing) and strips or rephrases anything that reveals the test
4. **Evaluator instructions** — the evaluator is instructed to frame all feedback as questions about real-world behavior and gap observations, never as scenario citations

### What each agent can see

| Document | Writer | Evaluator | Orchestrator |
|----------|--------|-----------|--------------|
| Spec file | embedded + can re-read | reference only | reads directly |
| Scenarios file | **BLOCKED** | embedded | reads directly |
| Context files | embedded + can explore filesystem | no | reads directly |
| Prior proposal | embedded | embedded | reads directly |
| Evaluator feedback | sanitized version | n/a | reads directly |
| Internal scorecard | **BLOCKED** | produces | reads directly |

### `best-of-n-runner` option (stronger isolation)

If you want a filesystem-level barrier in addition to the prompt-level barrier: initialize a git repository in the working directory, add the scenarios file to `.gitignore`, and use `best-of-n-runner` to spawn writers in isolated worktrees. The scenarios file will physically not exist in any worktree the writer can access. This can be adopted without changing any agent definitions.

---

## How to write a spec for the triad

The spec is the writer's primary input. A well-structured spec produces better proposals in fewer rounds. A vague spec produces proposals that stall.

### Required sections

**Requirements** — Everything a valid proposal must satisfy. Be specific and testable. Prefer "every manager has 5–15 direct reports" over "spans should be reasonable." A requirement the writer cannot unambiguously check produces a proposal you cannot unambiguously evaluate.

Subdivide requirements by domain if there are many (structural, functional, boundary conditions, personnel rules, etc.).

**Proposal format** — The exact sections and content the writer must produce. This is the deliverable definition. State it precisely. The writer will follow it literally.

**Static evaluation metrics** — Pass/fail criteria the writer self-checks against before returning. These are checks the writer *should* be able to verify from the spec and context alone. Examples: span compliance, depth compliance, functional coherence, documentation gates. The writer includes a self-check table at the end of each proposal.

### What belongs in scenarios, not the spec

The spec should not contain use-case narratives, stress tests, or ongoing health metrics. Those belong in the scenarios file. The writer sees the spec; if you put scenarios in the spec, you break the barrier.

Ongoing health metrics (things you'll measure the final result against over time) belong in the scenarios file, not the spec. The spec's static metrics are pre-flight checks; the scenarios' dynamic metrics are post-implementation monitoring.

### Signs of a good spec

- A writer could produce a structurally valid proposal without any additional clarification
- The proposal format section names every required heading and what it must contain
- Every requirement is falsifiable — you can say clearly whether a proposal passes or fails it
- Requirements do not duplicate scenario content

### Signs of a weak spec

- Requirements use qualitative language without a measurement ("should be effective," "minimize confusion")
- The proposal format is implicit ("produce a proposal")
- Requirements and scenarios overlap (you'll see stalls in the same place across rounds if this is happening)

---

## How to write scenarios for the triad

The scenarios file is the evaluator's primary input. Well-designed scenarios produce useful, specific feedback. Vague scenarios produce feedback the writer cannot act on.

### Required sections

**Use cases** — Named situations that a valid proposal must be able to handle. Each use case should:
- Describe a plausible real-world situation in the domain
- List the questions a proposal must answer to handle it (who is accountable, what is the path, what does "done" look like)
- Reference metric IDs from the spec for the orchestrator's convergence tracking

**Stress tests** — Pass/fail conditions. Each stress test has a test ID, a plain-language description, and a pass condition. Stress tests check structural properties that either hold or don't.

**Anti-pattern regression signals** — Observable symptoms that indicate the proposal is likely to fail in practice. Each signal names the failure mode it indicates and the metric it maps to. The evaluator uses these to flag risks; the orchestrator tracks whether risks are improving.

### What belongs in the spec, not the scenarios

Static evaluation metrics (pre-flight checks) belong in the spec. The writer self-checks against those. If a metric appears in both the spec and the scenarios, that's duplication — consolidate to one place.

### The evaluator's output contract

The evaluator must return output in two sections separated by exact delimiters:

```
---INTERNAL SCORECARD---
[pass counts and per-scenario results — for orchestrator only]
---FEEDBACK FOR WRITER---
[gap observations as situational questions — no scenario IDs or names]
```

Your scenarios should be written so that an evaluator can produce specific, actionable writer feedback without naming the scenario. If a scenario is so abstract that the only useful feedback would be "the scenario about X fails," rewrite it to be more concrete.

### Signs of good scenarios

- Each use case asks questions whose answers can be found (or not found) in a proposal
- Stress test pass conditions are unambiguous
- Anti-pattern signals are observable — you could detect them in a real org after 90 days
- Metric IDs cross-reference the spec consistently

### Signs of weak scenarios

- Use cases have no questions — just a situation description
- Stress tests have no pass conditions — just descriptions of what should be true
- Scenarios duplicate spec requirements (same content, different location)
- Scenarios are so specific they only apply to one possible proposal structure

---

## Orchestrator invocation

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `spec_file` | yes | — | Path to the specification document |
| `scenarios_file` | yes | — | Path to the evaluation scenarios document |
| `context_files` | no | [] | Additional files for writers (org charts, handbooks, operational plans) |
| `num_writers` | no | 3 | Parallel writers in round 1 |
| `max_rounds` | no | 3 | Maximum revision rounds |
| `convergence` | no | "all stress tests pass and 80%+ of use cases pass" | Convergence definition |
| `output_dir` | no | `proposals/` | Where to write final proposals |

### Example invocation

```
Run sdd-orchestrator with:
  spec_file: ~/projects/api-design/api-spec.md
  scenarios_file: ~/projects/api-design/api-scenarios.md
  context_files:
    - ~/projects/api-design/current-api.md
    - ~/projects/api-design/consumer-requirements.md
  num_writers: 3
  max_rounds: 3
  output_dir: ~/projects/api-design/proposals/
```

The orchestrator reads all files, embeds spec and context into writer prompts (never the scenarios), runs the loop, and writes final proposals and an evaluation summary to `output_dir`.

### Output files

Every proposal and evaluation is persisted per-round so you can trace the evolution of each branch:

| File | Contents |
|------|----------|
| `proposals/round-{N}/proposal-{letter}.md` | Proposal variation from round N |
| `proposals/round-{N}/evaluation-{letter}.md` | Full evaluation (internal scorecard + writer feedback) from round N |
| `proposals/proposal-{letter}.md` | Best/final version of each converging proposal (copy from last round) |
| `proposals/evaluation-summary.md` | Round-by-round scorecard table, stall flags, recommendations |

Round artifacts are written as they are produced — not deferred until the loop ends. If the loop is interrupted, every artifact produced up to that point is on disk.

---

## Convergence and failure modes

### Normal convergence

A proposal converges when its scorecard meets the convergence threshold. The orchestrator marks it as a candidate, writes it to disk, and (if other proposals are still running) continues evaluating them. At the end, the user sees all candidates and chooses.

### Stall detection

If all active proposals show no scorecard improvement across two consecutive rounds, the orchestrator stops the loop. This is almost always a spec ambiguity: the writer doesn't have enough information to address the gap, no matter how many revision rounds run.

When a stall is detected, the orchestrator:
1. Reports which gaps remain
2. Identifies that the gaps have been consistent across rounds
3. Flags this as a likely spec ambiguity and recommends reviewing the spec before the next run

Do not force more rounds when stalled. More rounds against an ambiguous spec produce more iterations of the same gap, not better proposals.

### Branch pruning

If one proposal shows no improvement across two rounds while others are converging, the orchestrator drops it rather than continuing to spawn revision writers for it. The dropped proposal is noted in the evaluation summary.

### The stall as a spec diagnostic

A consistent stall is valuable signal. If all writers stall on the same gap across multiple rounds, that gap is either:
- Underspecified in the spec (the requirements don't give writers enough to work with)
- A scenario that no valid proposal structure can satisfy (the scenario tests something the spec doesn't require)

Either case is worth examining before the next run.

---

## Example use cases

The triad works for any domain where you have a specification and evaluation scenarios:

- **Org design** — spec defines structural constraints and proposal format; scenarios are operational stress tests and use cases
- **API design** — spec defines interface requirements; scenarios are integration and edge-case tests
- **Policy documents** — spec defines what the policy must cover; scenarios are compliance checklists and real-world application tests
- **Architecture Decision Records** — spec defines the decision context and constraints; scenarios are architectural stress tests
- **Product requirements** — spec defines what the product must do; scenarios are user acceptance criteria and failure modes

The agents never change. Only the spec, scenarios, and context files change.
