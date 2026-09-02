# Spec-Driven Layer & Execution Discipline (B.23 / B.24)
→ Platform mapping: SKILL.md §F (Platform Abstraction Layer)

Provenance: merges the strongest ideas from **OpenSpec** (spec-driven change artifacts, delta specs, verify/archive discipline) and **Superpowers** (brainstorming, junior-executable plans, RED-GREEN-REFACTOR TDD, two-stage sub-agent review, verification-before-completion) into OmniDev's existing phase flow — no new phases, no new required artifacts.

**Design principle (from OpenSpec)**: fluid, not rigid. The spec layer is additive scaffolding — it must never add a new STOP-WAIT gate by itself.

## 1. Config: `spec_mode` (`config.json`)

| Value | Behavior |
|-------|----------|
| `"off"` | Layer disabled. Existing B.20 UNIT rules still apply. |
| `"auto"` (default) | Activate when Phase 0 rates complexity **L/XL**, OR requirement has ≥2 blocking open questions / 🔴 assumptions. Otherwise inert. |
| `"on"` | Always activate (user's explicit choice). |

Record the resolved value in `session-log.md` frontmatter (`spec_mode_active: true|false`) at Phase 1 exit. Do not re-decide mid-session unless `/od ch` (B.14) fires.

## 2. Spec Delta → `08-spec.md` (Phase 2, when active)

Per-branch artifact: `docs/omnidev-state/[branch]/08-spec.md` (document-history §1). Written **before** `04-design.md`. Plain Markdown, ≤60 lines, delta markers like OpenSpec:

```markdown
---
version: 1
artifact: 08-spec.md
spec_mode: auto
---
# Spec Delta: [requirement summary]

## ADDED
### R1: [Requirement name]
The system SHALL [one testable behavior statement].

#### Scenario: [name]
- **WHEN** [trigger]
- **THEN** [observable outcome]

## MODIFIED
### R2 (was: [old behavior, source: 08-spec.md / existing code])
[...] scenarios same format.

## REMOVED
### R3: [name] — [why safe to remove]
```

Rules:
- Every requirement uses **SHALL**; every scenario uses **WHEN/THEN** (Given may prefix WHEN).
- Scenario IDs: `SC-F{n}-{nn}` aligned to feature numbering used by `04-design.md` (F1, F2, …).
- One requirement = one behavior — split compound sentences.
- On `/od ch` (B.14): update `08-spec.md` first, then ripple to design/test plan; record delta in the change record.

## 3. Traceability

| Link | Where |
|------|-------|
| Scenario `SC-F*-**` → design section | `04-design.md` / `features/FN.md` reference scenario IDs in edge cases |
| Scenario → test case | `05-test-plan.md` TC table gains a `SC` column; every scenario ≥1 TC |
| Scenario → task | `02-plan.md` tasks keep `feature:` field (existing); groups covering a requirement list its `R*` |

A scenario with no TC at Phase 2 exit → add one before `phase2_plan_ready`.

## 4. Plan Quality Bar (Superpowers `writing-plans`)

Every `02-plan.md` task MUST pass the "junior-engineer bar":

- [ ] Exact file paths in `outputs` (no "and related files")
- [ ] Verification step or command a newcomer can run (`go test ./...`, `npm test -- --findRelatedTests`)
- [ ] Depends edges complete (no hidden ordering)
- [ ] 2–5 minute single-responsibility granularity for L/XL; coarse groups still allowed for S

If a task cannot state its verification command, it is not ready — return to Step 2 (test plan) rather than guessing.

## 5. TDD: RED-GREEN-REFACTOR (Phase 3, when active)

Extends B.20 §4.1 (UNIT mandatory). When `spec_mode_active: true` or `project_type: greenfield`:

1. **RED**: write the failing UNIT test mapped from `05-test-plan.md` TC-IDs first; run it, confirm it fails for the expected reason.
2. **GREEN**: write the minimal code to pass; re-run.
3. **REFACTOR**: dedupe/clean with tests green; re-run.
4. Only then mark task `[x]` and append `unit_tests: [...]` per Phase 3 §1.

Anti-patterns (from Superpowers): never write implementation before the RED run; if code exists without tests, wrap it in RED first — do not retrofit tests onto untested code silently. Legacy repos: match existing test layout; TDD applies to **new** logic only.

## 6. Two-Stage Review (sub-agent tasks, when active)

When §1.2 dispatches a task to a worker, the main agent reviews before `[x]`:

| Stage | Check | Fail action |
|-------|-------|-------------|
| 1. Spec compliance | Implementation satisfies the mapped scenarios (`08-spec.md` / `04-design.md` section) — behavior, edge cases, data changes | Return to worker with the failing scenario quoted; no style comments at this stage |
| 2. Code quality | Repo conventions, error handling, B.22 quick scan (§3) | Fix in place or re-dispatch once |

Critical issues in either stage block `[x]`. Main-agent serial tasks self-review with the same two questions.

## 7. Verification Before Completion

Evidence over claims — before **any** completion assertion (task `[x]`, group close, phase Handoff):

- Cite the actual command run + result (pass/fail counts), not "should work".
- `03-progress.md` task record gains `verify: [command → result]` (one line).
- No assertion of "tests pass" without a test run in the current session.

## 8. Spec Verify & Archive

- **Verify** (default at Phase 4 entry when active; manual `/od spec verify`): walk each `SC-*` → confirm a passing TC covers it → output ≤12-line coverage table; uncovered scenario → Phase 4 Gap Backfill (test-strategy §5).
- **Archive** (at Phase 5 exit / `/od ps` when active): merge `08-spec.md` delta into cumulative `docs/omnidev-state/specs.md` (global root — ADDED→append, MODIFIED→replace section, REMOVED→mark struck), then archive `08-spec.md` to `08-spec-history.md` per document-history.md. `specs.md` becomes the long-lived source of truth for future sessions' Phase 1 reads.

Chat budget: spec delta summary ≤6 lines; verify table ≤12 lines; never paste full scenario text into chat.
