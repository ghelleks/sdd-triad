---
name: sdd-spec-writer
description: >-
  Help write or improve a specification document for the SDD Triad
  (spec-driven proposal system). Guides the user through hard constraints,
  soft constraints, proposal format, and static evaluation metrics — and
  checks the result for common weaknesses. Use when the user says "write an
  SDD spec", "help me write a spec", "create a spec for the triad",
  "improve my spec", "check my spec", or "spec review".
---

# SDD Spec Writer

Help the user author or improve a specification document that will be consumed by the `sdd-writer` agent inside the SDD Triad loop. A good spec produces better proposals in fewer rounds. A vague spec produces proposals that stall.

## Prerequisites

- The user must have (or be ready to articulate) the domain constraints and desired proposal structure.
- No MCP tools required — this is a pure authoring skill.

## What a spec is for

The spec is the writer agent's primary input. The writer never sees the evaluation scenarios. Everything the writer needs to produce a valid proposal must be in the spec. If information is missing, the writer will guess or the loop will stall.

The spec is **not** where use cases, stress tests, or evaluation scenarios belong — those go in a separate scenarios file (see `sdd-scenario-writer`).

---

## Required sections

Walk the user through each section. Ask questions to draw out specifics. Push back on vague or qualitative language.

### 1. Requirements

Everything a valid proposal must satisfy. Subdivide by domain if there are many (structural, functional, boundary conditions, personnel rules, etc.).

**Quality bar:** every requirement must be falsifiable — you can say clearly whether a proposal passes or fails it.

Good:
- "Each custody period is at least 7 consecutive days."
- "Every manager has 5–15 direct reports."
- "Actual days = designated days minus travel overlap; ceiling is 25."

Bad:
- "Spans should be reasonable."
- "Maximize time together."
- "The schedule should be fair."

When the user offers a vague requirement, ask: "How would you know whether a proposal passes or fails this? What number or condition makes it pass?"

### 2. Proposal format

The exact sections and content a valid proposal must include. The writer follows this literally — it is the deliverable definition.

State every required heading and what it must contain. If the user says "just produce a proposal," push back: "The writer will follow the format section exactly. If it's vague, you'll get proposals in unpredictable shapes. What sections do you want to see?"

### 3. Static evaluation metrics

Pass/fail criteria the writer self-checks against before returning. These are pre-flight checks the writer should be able to verify from the spec and context alone.

Each metric needs: an ID, a name, and an unambiguous pass condition.

Examples:
- `M-01 Span compliance: every manager has 5–15 direct reports`
- `M-02 Period minimum: no custody period is shorter than 7 days`
- `M-03 Day ceiling: actual days ≤ 25`

The writer includes a self-check table at the end of every proposal scoring itself against these metrics. If a metric is vague, the writer will always mark it green. Make metrics testable.

---

## What does NOT belong in the spec

These belong in the scenarios file. If the user starts putting them in the spec, flag it:

- **Use cases** — real-world situations that test the proposal
- **Stress tests** — pass/fail structural tests applied by the evaluator
- **Sensitivity analyses** — "what if X changes?"
- **Ongoing health metrics** — things you'd measure post-implementation
- **Anti-pattern signals** — observable failure indicators

Tell the user: "That sounds like a scenario, not a requirement. If you put it in the spec, the writer sees the test — that breaks the information barrier. Move it to your scenarios file."

---

## Interview technique

Your job is not to transcribe what the user says — it is to draw out what they haven't said yet. The user knows their domain; you know what makes a spec work. Interview them like a curious, rigorous collaborator.

### Posture

- **One question at a time.** Do not dump a list of questions. Ask one, listen to the answer, follow up before moving on.
- **Summarize before advancing.** After each topic area, play back what you heard in spec language. "So the hard constraint is: each period is at least 7 consecutive days. Is that right?" Get confirmation before moving on.
- **Push on vague language immediately.** Don't collect vague answers and fix them later. The moment the user says "reasonable" or "minimize," stop and ask: "What number makes it pass? What would a failing proposal look like?"
- **Name the thing they haven't said.** Users carry assumptions they don't articulate because they feel obvious. Probe for them: "You said the schedule has to work around your travel. Are there other people's schedules that constrain this too?" "You mentioned managers — is there a minimum span as well as a maximum?"

### Question patterns

Use these throughout the interview. They are not a script — deploy them when the conversation calls for them.

**Boundary probes** — find the edges of a constraint:
- "What's the minimum? What's the maximum?"
- "Is there a number where this goes from acceptable to unacceptable?"
- "You said X. Does that mean exactly X, at least X, or at most X?"

**Assumption surfacing** — expose what the user takes for granted:
- "What would someone unfamiliar with this domain need to know to understand that constraint?"
- "Is there anything you're assuming the writer will just know? Because they won't — they only see the spec."
- "Are there rules you're following that you haven't written down because they feel obvious?"

**Consequence probes** — test whether a constraint matters:
- "What happens if a proposal violates this? Is it invalid, or just suboptimal?"
- "If this constraint disappeared, would the proposals look different?"
- "Is this a hard constraint (any violation is a failure) or a soft constraint (the writer should optimize for it)?"

**Completeness probes** — find what's missing:
- "What else could go wrong that we haven't covered?"
- "If I handed this spec to three different people, where would they disagree about what's required?"
- "What's the most important thing a proposal gets right — the thing that separates a good proposal from a technically valid but useless one?"

**Definition probes** — force precision on ambiguous terms:
- "You used the word '[term].' How would you define that for someone who doesn't share your context?"
- "Are 'designated days' and 'actual days' the same thing? If not, which one matters for this constraint?"
- "When you say 'team,' do you mean the direct reports, the extended org, or something else?"

---

## Workflow

### If starting from scratch

Conduct the interview in four phases. Each phase has a goal, opening questions, and follow-up patterns. Do not rush through phases — stay in each one until you have concrete, testable material.

**Phase 1: Domain orientation**
- Goal: understand the problem space well enough to ask good follow-up questions.
- Open with: "Tell me what you're trying to produce proposals for. What's the problem, and who cares about the outcome?"
- Follow up on: stakeholders, prior attempts, why this is hard, what "good" looks like.
- Close with a one-sentence summary of the domain and get confirmation.

**Phase 2: Constraint discovery**
- Goal: surface every hard and soft constraint.
- Open with: "Let's start with the non-negotiable facts. What are the rules, limits, or boundaries that every valid proposal must respect?"
- For each constraint the user offers:
  - Classify it (hard or soft) and confirm: "Is this non-negotiable, or is it a preference?"
  - Probe the boundary: "What's the threshold? What number makes it pass?"
  - Surface assumptions: "Is there anything related to this that you're taking for granted?"
- After hard constraints, shift: "Now — what distinguishes a valid proposal from a good one? What would you optimize for if you could?"
- Probe for missing constraints: "If I gave the spec as-is to a writer, where could they produce something technically valid but clearly wrong? What rule is missing?"
- Close with a numbered list of constraints (hard, then soft) and get confirmation.

**Phase 3: Proposal format**
- Goal: define the exact deliverable structure.
- Open with: "What should the output look like? Walk me through the sections a proposal should have."
- For each section: "What must this section contain? Is it a narrative, a table, a list?"
- Probe for completeness: "If you received a proposal with just these sections, would you have everything you need to decide? What's missing?"
- Close with the heading list and content descriptions. Get confirmation.

**Phase 4: Static metrics**
- Goal: define the self-check criteria.
- Open with: "The writer will score their own proposal against a checklist before returning it. What should be on that checklist?"
- For each metric: assign an ID, name it, and state the pass condition.
- Probe: "Are there any constraints from Phase 2 that should also be a metric? If a constraint is important enough to require, it's important enough to self-check."
- Close with the metrics table. Get confirmation.

After all four phases, run the quality checklist. Then write the spec.

### If improving an existing spec

1. **Read the spec** the user provides.
2. **Run the quality checklist** against it. Report every issue found.
3. **Interview about stalls.** "Has the triad stalled on this spec? What gaps kept coming back?" For each gap, probe: "What would the writer need to know to close this gap? Is that information in the spec?" Stalls almost always indicate a missing or underspecified constraint.
4. **Interview about assumptions.** Walk through each requirement and ask: "Is there anything implicit here that the writer might not know? Any term that means something specific in your context?"
5. **Propose fixes.** For each issue, suggest a concrete revision.
6. **Rewrite** the affected sections with the user's approval.

---

## Quality checklist

Run this against every spec before finalizing. Report each item as pass or fail with a note.

| # | Check | Pass condition |
|---|-------|----------------|
| 1 | Every requirement is falsifiable | You can say clearly whether a proposal passes or fails it — no qualitative-only language |
| 2 | Requirements use testable thresholds | Numbers, conditions, or formulas — not vibes ("reasonable", "effective", "minimize") |
| 3 | Proposal format names every heading | Each required section is listed with what it must contain |
| 4 | Proposal format is explicit | "Produce a proposal" is not a format definition |
| 5 | Static metrics have IDs and pass conditions | Each metric has an ID (M-01, etc.) and an unambiguous pass condition |
| 6 | No scenario content in the spec | No use cases, stress tests, sensitivity analyses, or health metrics |
| 7 | No overlap with scenarios | If the user has a scenarios file, check that requirements don't duplicate scenario content |
| 8 | Hard vs soft constraints are separated | Hard constraints are non-negotiable facts; soft constraints are preferences |
| 9 | A writer could produce a valid proposal without additional clarification | The spec is self-contained for proposal generation |

---

## Defaults

- Output: clean markdown spec document with Requirements, Proposal Format, and Static Evaluation Metrics sections
- Push back on qualitative requirements — always ask for a testable threshold
- Flag any scenario content that has leaked into the spec
- If the user has a scenarios file, check for overlap but do not reveal scenario content in the spec
