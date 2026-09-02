# Document History Protocol

**Principle**: Every state artifact uses **exactly two files** — **active (current)** + **history (append-only archive)**. Never overwrite history; never delete archived content.

**Load rule**: Workflow loads **active file only**. History is **COLD** — read only for `/od report`, `/od gv`, `/od ch` audit, or explicit user request.

---

## 1. Two-File Pair Model

**Branch isolation (mandatory)**: every requirement artifact lives under its **own branch directory** — never flat in the state root.

- `[branch]` = current git branch name, **sanitized**: `/` → `-`, spaces/underscores → `-` (e.g. `feature/redis-slot-drain` → `feature-redis-slot-drain`).
- Resolve `[branch]` once per session at activation (activation.md §1); record in session-log frontmatter (`branch:`).
- The branch directory is created on the **first per-branch artifact write** of the session.
- Bare artifact names in phase `context_requires` (`02-plan.md`, `features/FN.md`, …) always resolve against `docs/omnidev-state/[branch]/`.

Per branch: `docs/omnidev-state/[branch]/`

| Active (load in workflow) | History (append-only, do NOT load in normal phases) |
|---------------------------|-----------------------------------------------------|
| `01-blueprint.md` | `01-blueprint-history.md` |
| `02-plan.md` | `02-plan-history.md` |
| `03-progress.md` | `03-progress-history.md` |
| `04-design.md` | `04-design-history.md` |
| `05-test-plan.md` | `05-test-plan-history.md` |
| `05-test-report.md` | `05-test-report-history.md` |
| `06-release-notes.md` | `06-release-notes-history.md` |
| `08-spec.md` (spec-driven §2) | `08-spec-history.md` |
| `features/FN.md` | *(snapshots go to `04-design-history.md` § Feature FN)* |

Per branch (session): `docs/omnidev-state/[branch]/` — `session-log.md` only (latest 1, overwritten per session).

Global: `docs/omnidev-state/` (shared across branches — never branch-scoped)

| Active | History |
|--------|---------|
| `00-project-context.md` | `00-project-context-history.md` |
| `config.json` · `user-preferences.md` · `metrics.json` · `evolution-log.jsonl` · `flow-board.json` · `specs.md` | `00-project-context-history.md` only |

**Forbidden**:
- Writing per-branch artifacts (`01`–`08`, `features/`) flat into the state root — they belong under `[branch]/`
- Creating dated history copies `*-history-YYYY-MM-DD.md` — one paired history file per artifact, snapshots appended at the bottom
- Replacing active file without archiving previous version (except first creation)
- Deleting or truncating `*-history.md`
- Loading `*-history.md` during Phase 3/4 normal execution
- Scattering history across `archive/*-archive-[date].md` for paired artifacts (use paired history file instead)

### 1.1 Legacy Flat-Layout Migration (one-time, per repo)

On activation, if per-branch active artifacts (`0[1-8]*.md`, `features/`) sit flat at `docs/omnidev-state/` root:

1. Detect once; do not silently move anything (B.0).
2. At the **first artifact write** of the session, propose via `b0_confirm`: move flat artifacts into `docs/omnidev-state/[branch]/` (active + all `*-history*.md` variants, dated files moved as-is — never merged or deleted).
3. Global files (`config.json`, `user-preferences.md`, `00-project-context*`, `metrics.json`, `session-log*` root copies) stay at root; a root `session-log.md` moves to `[branch]/` when its `branch:` matches.
4. Record the migration in `metrics.json` (`layout_migrated: <date>`) so it is proposed only once.

---

## 2. Version & Archive Procedure

### 2.1 When to Archive (before updating active file)

Archive **previous active content** when ANY of:

- Requirement change (`/od ch`, B.14 doc sync)
- Phase revision (`/od ad`, user rejects checkpoint)
- Structural regen (Phase 2 replan, blueprint rewrite)
- New requirement on same branch superseding plan
- Manual user edit request affecting whole document

**Do NOT archive** for:
- First creation (file did not exist or empty template)
- Inline typo fix within same version (append CHANGE_LOG line in active file only)
- Task checkbox `[ ]` → `[x]` in `02-plan.md`
- Appending execution results to `05-test-plan.md` (same version)

### 2.2 Archive Write Steps

```
1. Read current active file content → PREVIOUS
2. If PREVIOUS is empty or only template → skip archive, write active
3. Append to *-history.md`:

---

## [ARCHIVE] {filename} · v{N} · {YYYY-MM-DD HH:MM}

| Field | Value |
|-------|-------|
| version | N |
| archived_at | ISO timestamp |
| reason | [change / revision / regen / requirement / phase_exit] |
| trigger | [user / od ch / od ad / phase checkpoint] |
| requirement_id | [from metrics or session-log] |
| summary | [1 line: what changed] |

<!-- BEGIN SNAPSHOT -->
[full previous active file content]
<!-- END SNAPSHOT -->

---
4. Write NEW content to active file
5. Set active frontmatter: version: N+1, previous_version: N
6. Append one line to active file CHANGE_LOG (see §4)
```

### 2.3 History File Header (create if missing)

```markdown
# History: {artifact name}

Append-only archive. Do not edit or delete past snapshots.
Newest entries appended at **bottom**.

| Metric | Value |
|--------|-------|
| snapshots | 0 |
| first_archived | — |
| last_archived | — |
```

Update `snapshots` count and `last_archived` on each append.

---

## 3. Active File Frontmatter (required after first save)

```yaml
---
version: 1
artifact: 02-plan.md
requirement_id: req-2026-07-04-xxx
last_updated: 2026-07-04T12:00:00Z
history_ref: 02-plan-history.md
---
```

Increment `version` on each archived update.

---

## 4. CHANGE_LOG (in active file, lightweight index)

Keep last **10 entries** in active file; older entries live only in history.

```markdown
<!-- CHANGE_LOG
[2026-07-04 14:00] v2→v3 | reason: /od ch login switch to OAuth | archived to 02-plan-history.md
[2026-07-03 10:00] v1→v2 | reason: Phase 2 revision | archived
-->
```

Full snapshots are in `*-history.md`, not duplicated in CHANGE_LOG.

---

## 4.5 Feature Files (`design_split`)

When updating `features/FN.md`:

1. Append previous `features/FN.md` content to `04-design-history.md` under:

   ```markdown
   ## [ARCHIVE] features/F1.md · v2 · 2026-07-04
   [snapshot]
   ```

2. Update active `features/F1.md`
3. Update `04-design.md` index `last_updated` — archive index only if structure/boundaries change

Do **not** create `features/F1-history.md` (keeps two-file rule at design level).

---

## 5. Context Loading Rules

```yaml
context_requires:
  read:
    - 02-plan.md              # active only
  skip:
    - "*-history.md"          # always skip in Phase 0-5
    - "archive/"              # legacy; migrate to *-history.md
```

**Exceptions** (may read history):

| Trigger | Allowed history reads |
|---------|----------------------|
| `/od report`, `/od rp` | All `*-history.md` summaries (frontmatter + CHANGE_LOG headers only, not full snapshots) |
| `/od gv --scope compliance` | Verify archive protocol |
| `/od ch` structural | Last 1 snapshot of affected artifact for diff |
| User: "show plan history" | Specific `*-history.md` |

---

## 6. Phase-Specific Rules

| Phase | Active updates | Archive trigger |
|-------|----------------|-----------------|
| 1 Blueprint | `01-blueprint.md` | Approach change, `/od ad` |
| 2 Planning | `02-plan`, `04-design`, `05-test-plan` | Any regen; new requirement |
| 3 Dev | `03-progress`, task `[x]` in plan | Progress snapshot on phase exit; plan archive only on `/od ch` |
| 4 Test | `05-test-plan` results inline; `05-test-report` | New report version → archive old report |
| 5 Deploy | `06-release-notes` | New release → archive old notes |
| `/od ch` | per classification | always archive before write |

### 6.1 Progress (`03-progress`)

- **Active**: current snapshot (≤50 lines after compress)
- **History**: on `/od compress` or phase exit, append active snapshot to `03-progress-history.md` before pruning active

Replace old pattern `archive/progress-archive-[date].md` → use `03-progress-history.md` only.

---

## 7. Requirement Lifecycle on Same Branch

When a **new requirement** starts on a branch that already has artifacts:

1. Archive **all** current active docs that will change (plan, design, test-plan at minimum)
2. Reset active files for new requirement OR merge via `/od ch` if continuation
3. Record in history: `reason: new_requirement`, link `requirement_id`

When **continuing** same requirement: update active in place; archive only on substantive change (§2.1).

---

## 8. History Size Management

If `*-history.md` exceeds **2000 lines**:

1. Move oldest snapshots to `docs/omnidev-state/archive/{artifact}-history-legacy-[YYYY].md` (one file per year max)
2. Keep `*-history.md` with recent snapshots + header pointing to legacy file
3. **Never delete** — only relocate to archive/

Normal workflow still loads active only.

---

## 9. Integration

- B.19 SKILL.md
- [special-flows.md](special-flows.md) §2 Change Management
- [context-lifecycle.md](context-lifecycle.md) — skip history in load
- [context-lifecycle.md](context-lifecycle.md) — history is COLD
- Phase instruction files — archive before regen
