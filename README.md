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

| Skill | What it does |
|---|---|
| `sdd-spec-writer` | Guides you through authoring or improving an SDD spec. Conducts a structured interview to draw out hard constraints, soft constraints, proposal format, and static evaluation metrics. Runs a quality checklist to catch vague or unfalsifiable requirements. |
| `sdd-scenario-writer` | Guides you through authoring or improving evaluation scenarios. Covers use cases, stress tests, anti-pattern signals, and comparison tables. Guards the information barrier by keeping scenario content out of the spec. |

### Agents

Agents either have a distinct conversational identity, make routing/dispatch decisions, or require state isolation (a clean context window that cannot inherit the parent's working memory). All four components below qualify as agents — but for different reasons.

| Agent | Why it's an agent |
|---|---|
| `sdd-coach` ("Deming") | **Conversational identity.** A named persona grounded in human factors, cognitive systems engineering, manufacturing theory, and value stream thinking. Coaches teams on SDD adoption, spec quality, and the organizational conditions that produce thin specs. |
| `sdd-orchestrator` | **Routes and dispatches.** Runs the write/evaluate loop: dispatches to `sdd-writer`, receives sanitized feedback from `sdd-evaluator`, decides whether to iterate or terminate. It is the only component that sees both sides of the information barrier. |
| `sdd-writer` | **State isolation — information barrier.** The writer must not see evaluation scenarios. Running it as a separate agent ensures it starts from a clean context that cannot contain scenario content leaked from the orchestrator's working memory. If the writer saw the scenarios, passing a scenario would no longer mean the proposal genuinely works. |
| `sdd-evaluator` | **State isolation — information barrier.** The evaluator sees the scenarios and scores the proposal against them. It must sanitize its feedback before returning it to the orchestrator so the writer cannot reconstruct scenario content from the feedback it receives in subsequent rounds. A separate context window enforces this sanitization boundary. |

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

## License

MIT — see [LICENSE](LICENSE)
