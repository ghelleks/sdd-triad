# sdd-triad

Spec-driven development skills and agents for AI coding assistants (Cursor, Claude Code, and compatible tools). Includes the full SDD Triad — the write/evaluate loop that separates proposal generation from scenario evaluation behind an information barrier — plus the authoring skills and the Deming coaching agent.

## Install

```bash
npx skills add ghelleks/sdd-triad --all
```

Or clone and run the install scripts directly:

```bash
git clone https://github.com/ghelleks/sdd-triad
cd sdd-triad
bash scripts/install-skills.sh
bash scripts/install-agents.sh
```

## Components

### Skills

Skills execute one coherent task with a well-defined input → output contract. They are invoked by agents or directly by the user. They do not route.


| Skill                 | What it does                                                                                                                                                                                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sdd-spec-writer`     | Guides you through authoring or improving an SDD spec. Conducts a structured interview to draw out hard constraints, soft constraints, proposal format, and static evaluation metrics. Runs a quality checklist to catch vague or unfalsifiable requirements. |
| `sdd-scenario-writer` | Guides you through authoring or improving evaluation scenarios. Covers use cases, stress tests, anti-pattern signals, and comparison tables. Guards the information barrier by keeping scenario content out of the spec.                                      |


### Agents

Agents either have a distinct conversational identity, make routing/dispatch decisions, or require state isolation (a clean context window that cannot inherit the parent's working memory). All four components below qualify as agents — but for different reasons.


| Agent                  | Why it's an agent                                                                                                                                                                                                                                                                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sdd-coach` ("Deming") | **Conversational identity.** A named persona grounded in human factors, cognitive systems engineering, manufacturing theory, and value stream thinking. Coaches teams on SDD adoption, spec quality, and the organizational conditions that produce thin specs.                                                                                              |
| `sdd-orchestrator`     | **Routes and dispatches.** Runs the write/evaluate loop: dispatches to `sdd-writer`, receives sanitized feedback from `sdd-evaluator`, decides whether to iterate or terminate. It is the only component that sees both sides of the information barrier.                                                                                                    |
| `sdd-writer`           | **State isolation — information barrier.** The writer must not see evaluation scenarios. Running it as a separate agent ensures it starts from a clean context that cannot contain scenario content leaked from the orchestrator's working memory. If the writer saw the scenarios, passing a scenario would no longer mean the proposal genuinely works.    |
| `sdd-evaluator`        | **State isolation — information barrier.** The evaluator sees the scenarios and scores the proposal against them. It must sanitize its feedback before returning it to the orchestrator so the writer cannot reconstruct scenario content from the feedback it receives in subsequent rounds. A separate context window enforces this sanitization boundary. |


### Design documentation

`docs/spec-sdd-triad.md` — full design rationale for the triad: the information barrier, the write/evaluate loop, the relationship between `sdd-coach` and the triad, and the connection to the StrongDM dark-factory pattern.

## The information barrier

The central design constraint of the SDD Triad is that **the writer agent never sees the evaluation scenarios**. This is what makes passing a scenario meaningful: the proposal wasn't built to pass a known test — it was built from the spec, and it either satisfies the scenario or it doesn't.

`sdd-writer` and `sdd-evaluator` are agents (not skills) specifically because of this constraint. State isolation — a clean context window — is the mechanism that enforces the barrier. Without it, context contamination across conversational turns would silently undermine the guarantee.

## Usage

Once installed, invoke components by name in your AI assistant:

```
Use sdd-coach to review my spec for gaps
Use sdd-orchestrator to run the triad loop against my spec and scenarios
Use sdd-spec-writer skill to help me write a spec
Use sdd-scenario-writer skill to help me write evaluation scenarios
```

## Example: end-to-end walkthrough

This example walks through the full workflow for a concrete problem: generating on-call rotation proposals for a small engineering team.

---

### Step 1 — Get oriented with `sdd-coach`

Before writing anything, ask Deming whether spec-driven development is the right approach for your problem, and what to watch out for.

```
Use sdd-coach to help me understand whether my on-call scheduling problem
is a good candidate for the SDD Triad. My team has 8 engineers, we need
to avoid consecutive weeks, and we have a bunch of constraints around
holidays and seniority that we can never seem to get right.
```

Deming will assess your problem, explain the information barrier, warn you about common spec mistakes for scheduling domains (aspirational language like "fair distribution" instead of testable thresholds), and tell you what the spec and scenarios files will each need to contain.

---

### Step 2 — Write the spec with `sdd-spec-writer`

The spec is what the writer agent sees. It must contain every constraint, the exact output format you want, and self-check metrics — but no evaluation scenarios.

```
Use the sdd-spec-writer skill to help me write a spec for on-call rotation proposals.
I'll create the file at scheduling/spec.md.
```

The skill interviews you one question at a time, pushing back on vague language:

- "You said rotations should be 'fair.' What number makes it pass? What's the maximum imbalance you'd accept?"
- "You mentioned seniority. Is that a hard constraint — a junior engineer can never be primary on-call alone — or a soft preference?"
- "What exactly should a proposal include? A table? Named individuals? Dates?"

At the end you'll have a file like `scheduling/spec.md` with three sections:

- **Requirements** — falsifiable constraints (e.g., "No engineer is primary on-call more than once per 6-week window"; "At least 5 days between consecutive on-call assignments for the same engineer")
- **Proposal format** — the exact sections and table structure a valid proposal must include
- **Static evaluation metrics** — the self-check checklist the writer scores itself against (M-01 through M-N, each with a binary pass condition)

---

### Step 3 — Write the scenarios with `sdd-scenario-writer`

The scenarios are what the evaluator agent sees. They live in a separate file — the writer never sees them. This separation is what makes passing a scenario meaningful.

```
Use the sdd-scenario-writer skill to help me write evaluation scenarios
for my on-call spec at scheduling/spec.md. I'll save them to scheduling/scenarios.md.
```

The skill mines your lived experience for the hard cases:

- "Has this scheduling problem gone wrong before? What happened? What was the failure mode?"
- "What's a technically valid rotation that would still make your team miserable? Let's write a scenario that exposes it."
- "If someone's out sick the week they're on call — who covers, and how does the proposal handle it?"

You end up with `scheduling/scenarios.md` containing:

- **Use cases** — named situations with specific questions (e.g., "Q4 Holiday Crunch: four engineers take PTO the last two weeks of December. Does the proposal still satisfy the 5-day gap requirement? Who holds primary?")
- **Stress tests** — binary pass/fail structural conditions (e.g., "T2 No consecutive weeks: no engineer appears in back-to-back primary slots. Pass: the rotation table contains no adjacent rows with the same primary.")
- **Anti-pattern signals** — early-warning symptoms (e.g., "Senior engineers carry disproportionate load: if the two most senior engineers account for >40% of primary slots, the proposal is optimizing for coverage over development")

---

### Step 4 — Run the triad loop with `sdd-orchestrator`

With both files ready, the orchestrator spawns multiple writers in parallel, routes proposals to evaluators, sanitizes feedback to preserve the information barrier, and iterates until proposals converge.

```
Use sdd-orchestrator with spec_file=scheduling/spec.md
and scenarios_file=scheduling/scenarios.md
```

The orchestrator runs autonomously. After each round it reports progress without revealing scenario details:

```
Round 1 complete.
  Proposal A: 3/5 use cases, 2/3 stress tests — improving
  Proposal B: 4/5 use cases, 3/3 stress tests — converging
  Proposal C: 2/5 use cases, 1/3 stress tests — stalling
Proceeding to round 2.
```

When a proposal converges (all stress tests pass, ≥80% of use cases pass), the orchestrator writes the final output to `scheduling/proposals/` and presents a summary. Proposals that stall are dropped; the summary flags any spec gaps that prevented convergence.

---

### What you end up with

```
scheduling/
├── spec.md                      # your requirements, format, and metrics
├── scenarios.md                 # your use cases, stress tests, anti-patterns
└── proposals/
    ├── round-1/
    │   ├── proposal-a.md
    │   ├── proposal-b.md
    │   ├── proposal-c.md
    │   ├── evaluation-a.md
    │   ├── evaluation-b.md
    │   └── evaluation-c.md
    ├── round-2/
    │   ├── proposal-a.md        # revised
    │   ├── proposal-b.md        # revised (converged)
    │   └── evaluation-*.md
    ├── proposal-b.md            # final best proposal
    └── evaluation-summary.md   # round-by-round scorecard, recommendations
```

The spec and scenarios are the durable artifacts — they accumulate your domain knowledge across runs. The proposals are derived output that can be regenerated anytime.

---

### Going back to `sdd-coach`

If the loop stalls — proposals plateau without reaching convergence — bring Deming back in:

```
Use sdd-coach to help me diagnose why my on-call rotation proposals keep
stalling. The evaluator keeps flagging holiday coverage gaps but the writers
can't seem to close them.
```

Deming will help you trace the stall to its root: usually a missing constraint in the spec (the writer doesn't have the information it needs), a vague use case in the scenarios (the evaluator can't produce specific feedback), or a mismatch between the two.

## License

MIT — see [LICENSE](LICENSE)