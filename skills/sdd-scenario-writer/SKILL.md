---
name: sdd-scenario-writer
description: >-
  Help write or improve evaluation scenarios for the SDD Triad
  (spec-driven proposal system). Guides the user through use cases, stress
  tests, anti-pattern signals, and comparison tables — and checks the result
  for common weaknesses. Use when the user says "write SDD scenarios",
  "help me write scenarios", "create scenarios for the triad", "improve my
  scenarios", "check my scenarios", or "scenario review".
---

# SDD Scenario Writer

Help the user author or improve an evaluation scenarios document that will be consumed by the `sdd-evaluator` agent inside the SDD Triad loop. Well-designed scenarios produce specific, actionable feedback. Vague scenarios produce feedback the writer cannot act on.

## Prerequisites

- The user should have (or be working on) a companion spec document. The scenarios are the evaluation complement to the spec.
- No MCP tools required — this is a pure authoring skill.

## What scenarios are for

The scenarios file is the evaluator's primary input. The evaluator reads the scenarios and a proposal, then tests the proposal against every scenario. The evaluator's feedback goes back to the writer (after sanitization by the orchestrator) to guide revisions.

The writer never sees the scenarios. This is the information barrier — the defining feature of the SDD Triad. Scenarios must be written so that an evaluator can produce specific, actionable feedback to the writer without naming any scenario.

---

## Required sections

Walk the user through each section. Push back on vague scenarios that would produce unusable feedback.

### 1. Use cases

Named situations that a valid proposal must be able to handle. Each use case describes a plausible real-world situation in the domain.

Every use case needs:
- **A name** — descriptive, not a code (good: "Cross-functional launch conflict"; bad: "UC-07")
- **A situation** — what is happening, who is involved, what's at stake
- **Questions the proposal must answer** — who is accountable, what is the resolution path, what does "done" look like
- **Metric cross-references** — which spec metrics (M-01, M-02, etc.) this use case exercises

Good use case:
> **Late Sweden return.** Sweden dates slip one week later than planned. The post-Sweden custody period start date shifts accordingly. Questions: Does the schedule still satisfy the 7-day minimum for Period 2? Does back-to-school continuity survive? Is the actual-day count still at ceiling?

Bad use case:
> **Schedule works when things change.** The schedule should handle changes. (No questions, no specifics, no metric references.)

When the user offers a vague use case, ask: "What specific questions should the evaluator check the proposal against? If the evaluator can't find clear answers in the proposal, what should the feedback say?"

### 2. Stress tests

Pass/fail structural conditions. Each stress test has:
- **A test ID** — short, e.g. T1, T2, T3
- **A plain-language description** — what property is being checked
- **A pass condition** — unambiguous, testable

Good:
> **T3 No coordination-only roles.** Every named role in the proposal owns a functional portfolio. Pass: no role's stated responsibilities are limited to routing, coordination, or hand-off work.

Bad:
> **T3 Roles are meaningful.** Roles should do real work. (No pass condition — the evaluator cannot score this.)

Push the user to make pass conditions binary. If they say "the schedule should be resilient," ask: "Resilient to what specifically? What's the pass condition — what would a non-resilient schedule look like?"

### 3. Anti-pattern regression signals

Observable symptoms that indicate the proposal is likely to fail in practice. Each signal names:
- **The symptom** — what you'd see if the anti-pattern is present
- **The failure mode it indicates** — why this symptom matters
- **The metric it maps to** — which spec metric would degrade

These are early-warning indicators, not pass/fail tests. The evaluator uses them to flag risks. The orchestrator tracks whether risks are improving across rounds.

Good:
> **Pods meet but don't decide.** Pod cadences are described but no named person holds accountability for pod-level decisions. Indicates: governance theater — meetings occur but decisions defer upward. Maps to: M-05 decision velocity.

Bad:
> **Things might not work.** (No symptom, no failure mode, no metric reference.)

### 4. Comparison table (optional but recommended)

When scenarios represent distinct structural approaches (e.g., three different schedule shapes, three different org structures), include a scoring table that compares them on the metrics that matter.

| Metric | Scenario A | Scenario B | Scenario C |
|--------|-----------|-----------|-----------|
| Actual days | 25 | 25 | 23 |
| Pre-event time | 10 days | 0 days | 10 days |
| Handoff count | 8 | 6 | 8 |

This helps the evaluator contextualize trade-offs and produce feedback that surfaces the real distinctions between approaches.

---

## What does NOT belong in scenarios

These belong in the spec. If the user starts putting them in the scenarios, flag it:

- **Hard constraints** — non-negotiable facts (belong in spec Requirements)
- **Soft constraints** — preferences and priorities (belong in spec Requirements)
- **Proposal format** — deliverable structure (belongs in spec Proposal Format)
- **Static evaluation metrics** — pre-flight self-checks (belong in spec Static Evaluation Metrics)

Tell the user: "That's a requirement, not a scenario. It belongs in the spec so the writer can see it and design to satisfy it. The scenarios test whether the proposal handles situations the writer wasn't explicitly told to optimize for."

---

## The feedback test

Apply this test to every use case and stress test before finalizing:

> Could an evaluator produce specific, actionable feedback to the writer about this scenario without naming the scenario?

If the only useful feedback would be "the scenario about X fails," the scenario is too abstract. Rewrite it to be concrete enough that the evaluator can describe the gap in terms of real-world behavior.

Wrong (requires naming the scenario): "UC-09 fails."
Right (describes the gap): "When two functions produce contradictory customer-facing materials, the proposal does not identify who resolves this or in what timeframe."

---

## Interview technique

Your job is not to transcribe what the user says — it is to draw out the failure modes, edge cases, and tensions they haven't articulated. The user knows what worries them; you know how to turn worries into testable scenarios.

### Posture

- **One scenario at a time.** Do not ask for a list. Explore one situation deeply, then move on.
- **Summarize each scenario before advancing.** Play back the situation, the questions, and the pass condition in scenario language. "So this use case is: when Sweden dates slip a week, does Period 2 still meet the 7-day minimum and does back-to-school continuity survive? Is that right?"
- **Mine lived experience.** The best scenarios come from things that have actually gone wrong. Ask: "Has this happened before? What went wrong last time? What did you wish you'd tested?"
- **Think adversarially.** Ask what a technically valid but useless proposal would look like: "If a writer wanted to game this, what loophole would they exploit? What scenario would expose that?"

### Question patterns

Use these throughout the interview. They are not a script — deploy them when the conversation calls for them.

**Failure mode probes** — find what breaks:
- "What's the worst thing that could happen if this proposal is implemented as-is?"
- "Where has this kind of plan gone wrong before? What was the failure?"
- "If you implemented this and checked back in 90 days, what would tell you it's failing?"

**Tension probes** — find where constraints conflict:
- "Are there two things you care about that pull in opposite directions?"
- "What trade-off would a writer have to make? What do they sacrifice to get X?"
- "If the writer maximizes A, does that hurt B? What's the scenario where that tension shows up?"

**Sensitivity probes** — find what's fragile:
- "What are the unknowns? What could change between now and implementation?"
- "If [specific input] moves by a week / changes by 20% / disappears entirely, does the proposal still work?"
- "Which assumption, if wrong, would break the most things?"

**Accountability probes** — find who owns what:
- "In this situation, who decides? Who's the single person accountable?"
- "If two people disagree about this, how does it get resolved? Who breaks the tie?"
- "Is there anyone who could block this from working? What does that look like?"

**Completeness probes** — find the gaps:
- "We've covered [list of scenarios]. What haven't we tested? What keeps you up at night?"
- "If a proposal passed all these scenarios, would you trust it? What else would you want to check?"
- "Is there a scenario that seems unlikely but would be catastrophic if it happened?"

**Anti-pattern probes** — find the silent failures:
- "What does it look like when this kind of thing fails quietly — not a blowup, but a slow decay?"
- "What's the meeting you'd be in 90 days from now where you realize it's not working? What would you be noticing?"
- "What's the symptom that would tell you people are going through the motions but nothing is actually happening?"

---

## Workflow

### If starting from scratch

Conduct the interview in four phases. Each phase has a goal, opening questions, and follow-up patterns. Do not rush — stay in each phase until you have concrete, testable material.

**Phase 1: Domain and spec orientation**
- Goal: understand what the companion spec covers so you know what the scenarios should test.
- Open with: "What are you writing scenarios for? Give me the one-paragraph version of the problem. Do you have a companion spec already?"
- If a spec exists, read it. Identify the requirements and metrics — scenarios should exercise them without duplicating them.
- Close with: "Here's what I understand the spec requires. The scenarios will test whether proposals that meet those requirements actually work in the real world."

**Phase 2: Use case discovery**
- Goal: surface the hard, ambiguous, conflict-laden situations a proposal must handle.
- Open with: "Think about the situations where a technically valid proposal could still fail. Where is accountability unclear? Where do timing, logistics, or competing interests make things hard?"
- For each use case the user offers:
  - Probe for specificity: "What exactly happens in this situation? Who's involved?"
  - Probe for questions: "What should the evaluator look for in the proposal? What questions does this situation ask of the proposal?"
  - Probe for metric ties: "Which of the spec metrics does this exercise?"
  - Apply the feedback test: "Could an evaluator describe this gap without naming the scenario?"
- After each use case, mine for adjacents: "What's a variation of this that would test something different? What if the timing were worse? What if a different person were involved?"
- Probe for completeness: "We have [N] use cases. What haven't we tested? Where are the gaps?"
- Close with a numbered list of use cases (name, situation, questions, metrics). Get confirmation.

**Phase 3: Stress tests and anti-patterns**
- Goal: define structural pass/fail conditions and early-warning signals.
- Open with: "Now let's think about structural properties. What should always be true of a valid proposal — regardless of which specific approach the writer takes?"
- For each stress test: probe for the pass condition. "How would the evaluator score this? What's the bright line between pass and fail?"
- Shift to anti-patterns: "What does silent failure look like? If the proposal is broken but nobody notices for 90 days, what's the first symptom?"
- For each anti-pattern: probe for the failure mode and the metric mapping.
- Close with the stress test table and anti-pattern list. Get confirmation.

**Phase 4: Comparison and synthesis**
- Goal: build the comparison table (if applicable) and do a final gap check.
- If the scenarios represent distinct approaches: "Let's compare them. What metrics distinguish Scenario A from B from C? Where does each one win and lose?"
- Final completeness probe: "If a proposal passed all these scenarios, would you trust it enough to implement it? What's the one thing that would still worry you?"
- Close with the full scenario document draft.

After all four phases, run the quality checklist. Then write the scenarios.

### If improving existing scenarios

1. **Read the scenarios** the user provides.
2. **Read the companion spec** if available — check for duplication.
3. **Run the quality checklist.** Report every issue found.
4. **Interview about stalls.** "Has the triad stalled? What gaps kept coming back?" For each recurring gap, probe: "Is this something the spec doesn't give the writer enough information to address? Or is the scenario testing something the spec doesn't require?" Recurring stalls on the same gap are often a spec problem, not a scenario problem.
5. **Interview about coverage.** Walk through each use case: "Is this still the right situation to test? Has anything changed? Is there a harder version of this that we should be testing instead?"
6. **Propose fixes.** For each issue, suggest a concrete revision.
7. **Rewrite** the affected sections with the user's approval.

---

## Quality checklist

Run this against every scenarios document before finalizing. Report each item as pass or fail with a note.

| # | Check | Pass condition |
|---|-------|----------------|
| 1 | Every use case has questions | Each use case lists the questions the evaluator checks the proposal against |
| 2 | Every stress test has a pass condition | Each stress test has an unambiguous, binary pass condition |
| 3 | Anti-pattern signals name the failure mode | Each signal identifies what would go wrong and why it matters |
| 4 | Metric cross-references are present | Use cases and signals reference spec metric IDs (M-01, etc.) |
| 5 | No spec content in the scenarios | No hard constraints, soft constraints, proposal format, or static metrics |
| 6 | No duplication with the spec | Scenarios don't re-state requirements already in the spec |
| 7 | Feedback test passes | Every scenario can produce actionable writer feedback without naming the scenario |
| 8 | Use cases are concrete | Each describes a specific plausible situation, not an abstract category |
| 9 | Stress test pass conditions are binary | Each can be scored pass or fail — not "partially" or "it depends" |

---

## Defaults

- Output: clean markdown scenarios document with Use Cases, Stress Tests, Anti-Pattern Regression Signals, and (optionally) Comparison Table sections
- Push back on vague use cases — always ask for specific questions the evaluator should check
- Push back on stress tests without pass conditions — always ask for the binary test
- Flag any spec content that has leaked into the scenarios
- Apply the feedback test to every scenario
