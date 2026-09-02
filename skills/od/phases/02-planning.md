# Phase 2 Instructions (Detailed Design & Planning)
→ Platform mapping: SKILL.md §F (Platform Abstraction Layer)


## Context Requires

```yaml
context_requires:
  read:
    - 00-project-context.md
    - user-preferences.md
    - 01-blueprint.md                # skip if M-level; use session-log requirement
  scan:
    - src/{pages,views,app}/**/index.{ts,tsx,js,jsx,vue}
    - src/{routes,router,api}/*.{ts,js}
    - cmd/**/main.go, internal/{handler,controller,route}/**/*.go
  scan_limit: 8
  skip:
    - 03-progress.md, features/*.md, 05-test-report.md, 06-release-notes.md
    - "*-history.md"                 # COLD — load active only
  unload:
    - "Phase 0 instruction file full text"
    - "Phase 0 project scan raw returns"
  summarize_before_exit:
    target: 02-plan.md
    discard_after_write:
      - "source code scan raw returns"
    retain:
      - 04-design.md                 # index only in context
      - features/*.md                # on disk; lazy-load per task in Phase 3
      - 05-test-plan.md
      - 02-plan.md
```

## Overview

Phase 2 produces **in order**:

1. **`04-design.md`** — single file per `config.json` `design_split` (default `false`):
   - **`design_split: false`** (default): one `04-design.md` with `## Feature F1`, `## Feature F2`, … sections (≤40 lines each). Phase 3 loads one section via Grep.
   - **`design_split: true`**: index `04-design.md` (≤60 lines) + per-feature `features/FN.md` files.
2. **`05-test-plan.md`** — table-first compact format
3. **`02-plan.md`** — tasks with `feature_ref: FN` field

→ Token: [token-optimization.md](../engine/token-optimization.md) · Occupancy: [context-lifecycle.md](../engine/context-lifecycle.md) §3 Phase 2

**Document history**: Before overwriting any existing active artifact (`01-blueprint`, `02-plan`, `04-design`, `05-test-plan`), archive previous content to paired `*-history.md` per [document-history.md](../engine/document-history.md). First creation skips archive.

```yaml
context_occupancy:
  hot: ["current feature section being written"]
  warm: ["04-design.md (single file)", "or 04-design index when design_split: true"]
  cold: ["other feature sections", "scan raw"]
```

---

> **Path resolution**: bare artifact names above resolve against `docs/omnidev-state/[branch]/` (document-history §1); `00-project-context.md` is global root.

## Step 0: Spec Delta → `08-spec.md` (only when `spec_mode` active)

When [spec-driven.md](../engine/spec-driven.md) §1 activates the layer (`"on"`, or `"auto"` with L/XL / ≥2 blocking open questions), write `08-spec.md` **before** design:

1. Delta requirements (`ADDED` / `MODIFIED` / `REMOVED`) with SHALL statements + WHEN/THEN scenarios, per spec-driven §2 (≤60 lines).
2. Assign scenario IDs `SC-F{n}-{nn}` aligned to the feature numbering used below.
3. When inert: skip this step entirely — no file, no chat mention.

## Step 1: Design → Index + Feature Files

### `design_split: false` (default) — Single File

Write ONE `04-design.md` with per-feature sections:

```markdown
# Design

## Feature F1: [Name]
### Business Context
- **Related**: [existing features]
- **Impact**: [affected flows]

### Implementation Logic
1. Entry: [route] → validate → service → response
2. Core: [3-5 steps max]
3. Data: [model/query]

### Edge Cases
- Happy: [...] | Err1: [...] | Err2: [...] | Boundary: [...]

### Data Changes
| Entity | Change | Details |

## Feature F2: [Name]
...
```

**Quality checks**: each section ≤40 lines; total ≤200 lines. Every feature linked to existing code.

### `design_split: true` — Index + Per-Feature Files

1. Write **`04-design.md`** index only (≤60 lines) — feature table + cross-cutting notes
2. Write each **`features/FN.md`** (≤40 lines) — one file per feature. Use template below.

**Feature file template** (`features/F1.md`):

```markdown
# F1: [Feature Name]

## Business Context
- **Related**: [existing features]
- **Impact**: [affected flows]

## Implementation Logic
1. Entry: [route] → validate → service → response
2. Core: [3-5 steps max]
3. Data: [model/query]

## Edge Cases
- Happy: [...] | Err1: [...] | Err2: [...] | Boundary: [...]

## Data Changes
| Entity | Change | Details |
```

**Quality checks**: every feature linked to existing code; ≤40 lines each.

---

## Step 2: Test Plan → `05-test-plan.md` (Multi-Layer)

→ Full rules: [test-strategy.md](../engine/test-strategy.md) — auto-compose layers from complexity + project_type + fullstack signals.

**Phase 2 MUST**:
1. Compute `test_strategy_profile` and `layers_required` (§2 matrix)
2. Write frontmatter (profile, e2e_tool, e2e_required, integration_required)
3. Author **separate tables per layer** per feature: UNIT, INT (if required), E2E (if fullstack), SMK, REG

**Table format** (compact — [token-optimization.md](../engine/token-optimization.md) §4):

```markdown
---
test_strategy_profile: fullstack-M
layers_required: [unit, integration, e2e, smoke, regression]
e2e_tool: playwright
e2e_required: true
integration_required: true
---

## Test Strategy Summary
| Layer | Required | Tool | Command | TC Count |
| UNIT | ✅ | jest | npm test | 8 |
| INT | ✅ | supertest | npm run test:int | 4 |
| E2E | ✅ | playwright | npx playwright test e2e/ | 3 |

## F1 — UNIT
| TC-ID | Layer | Type | Target | Input | Expected | Mock |
| TC-F1-U01 | UNIT | Happy | ... | ... | 200 | none |

## F1 — INT
| TC-ID | Layer | Type | Target | Input | Expected | Mock |

## E2E Flows
| TC-ID | Layer | Flow | Steps | Expected |

## Smoke Suite
| TC-ID | Source-TC | Layer | Critical Path |

## Regression Suite
| TC-ID | Layer | Module | Package | Type |
```

Minimums when layer **required**:
- UNIT: 1 Happy + 2 error + 1 boundary per feature
- INT: 1 Happy + 1 cross-module failure
- E2E: 1 primary user journey (fullstack)
- SMK: top critical paths
- REG: Module-tagged entries for touched modules

Legacy: match existing test layout; Greenfield: scaffold Playwright if E2E required.

---

## Step 3: Task Plan → `02-plan.md`

Each task MUST include feature reference:

```markdown
- [ ] **T3** [backend] User service · feature: F1 · outputs: `service/user.go` · depends: T1
```

Traceability table: Task Group ↔ Features ↔ TC-IDs (when `spec_mode` active: also SC coverage — spec-driven §3).

**Plan quality bar** (spec-driven §4, when active): every task states exact `outputs` paths + a runnable verification command; a task that cannot name its verification returns to Step 2 instead of guessing.

---

## Step 4: Checkpoint → Interactive → WAIT

Record token estimate in `metrics.json` if `log_token_estimates: true`.

### Handoff Checklist

- [ ] `04-design.md` index + all `features/FN.md` on disk
- [ ] `05-test-plan.md` has Test Strategy Summary + all **Required** layer tables
- [ ] `layers_required` matches test-strategy matrix (fullstack → E2E present)
- [ ] `02-plan.md` has `feature:` on every task
- [ ] Traceability complete
- [ ] When `spec_mode` active: `08-spec.md` exists, every scenario has ≥1 TC (spec-driven §3)
- [ ] When `spec_mode` active: every task passes the plan quality bar (spec-driven §4)
- [ ] Session-log frontmatter `spec_mode_active` matches config resolution (spec-driven §1)
- [ ] Prior versions archived to `*-history.md` if this is a revision (not first run)

### Interactive gate (mandatory)

Print **Phase Handoff Block** (SKILL.md §C.1) for **Phase 3 — Dev** (what Dev will do, `/od n`, skip not allowed if phase 3 required). Then **same turn** invoke [interactive-prompt.md](../engine/interactive-prompt.md):

1. §3.11 `phase2_plan_ready` — confirm design/plan ready for development
2. §3.1 `checkpoint` (B.8) — Continue (`/od n`) / Revise (`/od ad`) / …

Platform: §4 / §5 / §6 / §7; on failure → §8 Markdown table. **STOP — WAIT**. Workers must not show options UI.

---

## Sub-Agent Dispatch (per `sub_agents` config)

| Mode | Behavior |
|------|----------|
| **off** | Main agent writes all files serially |
| **auto** (default) | S/M: serial. L/XL + ≥5 features: 1 worker/feature for `features/*.md` only |
| **on** | 1 worker/feature for design + test tables; main agent merges |

Workers return ≤30 line summary. Main agent writes final files. Phase 2 NEVER loads worker raw outputs into context — merge from disk files only.
