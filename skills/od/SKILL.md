---
name: od
description: >-
  OmniDev AI-driven development workflow. Use ONLY when the user's message starts with /od
  (e.g. /od help, /od resume, /od onboard, /od report, /od review, /od qa, /od change, /od evolve).
  Do not load or follow this skill for normal chat without the /od prefix.
---

# OmniDev Workflow Skill — Full Specification

This file is the **single source of truth** for all OmniDev rules. The lightweight trigger lives in `rules/01-omnidev-workflow.mdc` (`alwaysApply: false`); **everything below applies only when the current user message starts with `/od`** — including workflow, `docs/omnidev-state/**`, and evolution logging. No OmniDev behavior on non-`/od` turns.

---

## A. Command Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `/od [requirement]` | — | Guided workflow: assess complexity → recommend phases → user can skip any |
| `/od --fast [req]` | `/od -f` | Skip blueprint/plan, develop directly (hotfixes) |
| `/od --plan-only [req]` | `/od -p` | Output blueprint and plan only, no coding |
| `/od help` | `/od h` | Show all OmniDev commands |
| `/od onboard` | `/od ob` | Scan legacy project, generate context document |
| `/od report` | `/od rp` | Generate enterprise-grade weekly status report |
| `/od review` | `/od rv` | Code review only (no modifications) |
| `/od qa` | — | Write and execute test cases |
| `/od change [new req]` | `/od ch` | Handle mid-stream requirement changes |
| `/od learn` | `/od ln` | Self-learning from recent errors |
| `/od update` | `/od up` | Update OmniDev Kit rules to latest version |
| `/od install <url>` | `/od i` | Install OmniDev Kit from remote Git repo |
| `/od push` | `/od ps` | Commit and push (user must `git add` first) |
| `/od stash` | `/od st` | Stash current task context |
| `/od pop` | — | Restore stashed task context |
| `/od sync` | `/od sy` | Sync output back to Jira/GitHub Issue |
| `/od dashboard` | `/od db` | Generate global ROI dashboard |
| `/od resume` | `/od res` | Restore session from `docs/omnidev-state` (use this, not bare `/resume`, so OmniDev rules load) |
| `/od evolve` | `/od ev` | Self-evolution: scan learning signals, propose rule/skill improvements |
| `/od evolve --review` | `/od ev -r` | View evolution log and pending proposals |
| `/od evolve --apply` | `/od ev -a` | Apply all pending proposals without review |
| `/od evolve --rollback [N]` | `/od ev --rb [N]` | Revert evolution #N |

### Phase Navigation

| Command | Alias | Action |
|---------|-------|--------|
| `/od 继续` | `/od c`, `/od next` | Next phase |
| `/od 调整 [内容]` | `/od adj [内容]` | Revise current phase output |
| `/od 跳过 [阶段名]` | `/od sk [阶段名]` | Skip a future phase |
| `/od 回到 [阶段名]` | `/od back [阶段名]` | Re-enter a previous phase |
| `/od 全部完成` | `/od all` | Execute all remaining phases without checkpoints |

---

## B. Core Rules

### B.1 Activation & Tool Execution
- OmniDev activates **only** on `/od` prefix. Without it, treat as normal conversation.
- First action on any `/od` message MUST be a tool call — zero text before tools.
- Ad-hoc requests (e.g. `/od 这里加个按钮`) → use tools to find file, edit code, apply changes directly.
- Image attachments: tool calls FIRST, then explain.

### B.2 Workflow Philosophy
- Guided, not forced. Phase order: **Blueprint → Plan → Dev → Test → Deploy**.
- Phases execute in forward order only, but **any phase can be skipped**.
- Complexity assessment (S/M/L/XL) provides **recommendations**, not mandates.

### B.3 State File Isolation
- Global: `docs/omnidev-state/` (`00-project-context.md`, `metrics.json`)
- Branch-specific: `docs/omnidev-state/[branch-name]/` (`01-blueprint.md`, `02-plan.md`, `03-progress.md`, `04-design.md`, `05-test-report.md`, `06-release-notes.md`)

---

## C. Phase 0: Complexity Assessment

Perform T-Shirt Sizing:
- **S**: Skip blueprint/plan → Dev → Test directly.
- **M**: Skip blueprint → Plan → Dev → Test.
- **L/XL**: Full workflow: Blueprint → Plan → Dev → Test → Deploy.

Output format:
```
## OmniDev Phase 0: 需求解析 & 复杂度评估
**需求解析**: [1-2 sentences]
**复杂度评估**: [S/M/L/XL] — [reason]
**推荐策略**: [phases]
```

For **S tasks**: Do NOT generate state files. Resolve directly.

---

## D. Phase Execution Protocol

After each phase completes, output:
```
✅ **阶段 N 完成: [Phase Name]**
   产出: [what was produced]
📍 **当前进度**: 已完成: [...] ✅ | 待执行: [...] ⏳
🔜 **下一阶段: Phase N+1 — [Phase Name]**
   将要做: [description]
```
Then ask: "请回复 `/od 继续` 进入下一阶段。" and **STOP — WAIT for user reply**.

---

## E. Phases

### Phase 1: Blueprint (recommended for L/XL)
1. Analyze requirements, edge cases, exception handling, UX.
2. Output to `docs/omnidev-state/[branch]/01-blueprint.md` with **Mermaid.js** diagrams.
3. Checkpoint → WAIT.

### Phase 2: Planning (recommended for M+)
1. Break down into features/tasks with priorities.
2. Output checkbox task list to `docs/omnidev-state/[branch]/02-plan.md`.
3. Checkpoint → WAIT.

### Phase 3: Development
1. Auto-checkpoint: `git commit -m "chore: auto-checkpoint before omnidev task"`.
2. Adaptive coding:
   - Legacy: imitate surrounding code, reuse existing utilities.
   - Greenfield: TDD/DDD, modern conventions.
3. Update `02-plan.md` checkboxes after each sub-task.
4. Checkpoint → WAIT.

### Phase 4: Testing & Wrap-up
1. Run/write test cases. For legacy without test infra, basic verification only.
2. Generate `05-test-report.md` (scope, mock data, results, limitations).
3. For M+: generate `06-release-notes.md` with efficiency bill.
4. Trigger `/od learn` flow.
5. **Evolution Signal Check**: Scan `docs/omnidev-state/evolution-log.jsonl` for unprocessed signals. If any exist, append: "🧬 **进化信号**: 检测到 N 条新学习信号。回复 `/od evolve` 查看进化提案。"
6. Final summary → STOP.

---

## F. State Sync & Session Recovery

### Dual-State Storage
`03-progress.md` uses YAML Frontmatter + Markdown:
```markdown
---
status: in_progress
current_step: 3
last_updated: "2026-03-28 10:00:00"
---
## State Snapshot
- **Currently doing**: ...
- **Completed**: ...
- **Blockers**: ...
- **Next Action**: ...
```

### Update Triggers
Proactively update `03-progress.md` and `02-plan.md` when:
- A module/function is completed.
- An unsolvable error requires a pivot.
- Session is ending or user requests pause.

### Session Recovery (`/od resume`)

Use **`/od resume`** (not bare `/resume`) so this skill loads and OmniDev state rules apply.

1. Read `03-progress.md` and `02-plan.md` (parse YAML frontmatter first).
2. Compare with `git status`.
3. Check `evolution-log.jsonl` for unprocessed high-confidence signals. If any: "💡 有 N 条待处理的进化信号，可随时使用 `/od evolve` 查看。"
4. Report: "🔄 **Context Restored**. Status: [X]. Next: [Y]. Continue?" → WAIT.

### SDD (Spec-Driven Development)
- Major architectural decisions must first be recorded in `04-design.md`.
- Code must stay consistent with `04-design.md`. If deviating, update design first.

### Stash/Pop
- `/od stash`: Save state, set status to `stashed`, clear active context.
- `/od pop`: Read stashed state, restore branch/context, resume.

---

## G. Testing & Deployment

### Testing
- No "blind confidence" — execute test cases, not just write code.
- If database MCP available: insert mock data → run code → verify data state.
- If external service credentials needed: STOP and ask user.
- Security: never hardcode keys/passwords in state files or code.

### Test Report (`05-test-report.md`)
Include: test scope, mock data (desensitized), results, known limitations.

### Docker Orchestration
Check for `docker-compose.yml` → offer to `docker compose up -d` → test → `docker compose down`.

### Release Notes (`06-release-notes.md`)
Include: env requirements, config changes, DB migrations, deployment steps, efficiency bill.

### Efficiency Bill
Append ROI metrics to `docs/omnidev-state/metrics.json`.

### Archive & Cleanup
When user confirms release notes, prompt: "🎉 Requirement complete! Would you like me to generate a Git Commit Message?" → WAIT.

---

## H. Context Pruning

### Triggers
- `03-progress.md` exceeds 200 lines.
- 3+ M-level sub-tasks completed.
- User types `/od compress`.

### Action
1. Archive resolved logs to `docs/omnidev-state/archive/progress-archive-[date].md`.
2. Condense to 1-2 sentence summary at top of `03-progress.md`.
3. Retain: YAML frontmatter, current blockers, next action.
4. Report: "🧹 **Context Memory Compressed**."

---

## I. Special Flows

### Report (`/od report`)
1. Read all state files + `archive/`.
2. Analyze `git log` (past 7 days).
3. Generate management-ready report in `docs/omnidev-state/weekly-report-[date].md`.
4. Include: executive summary, AI-assisted achievements, progress, blockers, next week plan.

### Change Management (`/od change`)
1. Impact assessment on current architecture.
2. Ask confirmation → WAIT.
3. Archive old plan, regenerate blueprint/plan.

### Push (`/od push`)
1. `git status` → show modified files.
2. Prompt user to `git add` → WAIT.
3. After staging: analyze diff, generate commit message, show to user → WAIT.
4. After confirmation: `git commit` + `git push`.

### Update (`/od update`)
1. Warn user about overwrite → WAIT for `/od 确认更新`.
2. Clone `https://github.com/zy-eagle/omnidev-kit.git` to temp dir, copy rules/skills.
3. Cleanup temp dir.

### Install (`/od install <url>`)
1. `git clone --depth 1 <url> _omnidev-kit-tmp`.
2. Validate structure, read INSTALL.md, copy rules/skills (non-destructive merge).
3. Cleanup, report success.

### Onboard (`/od onboard`)
1. Scan project dependencies, directory structure, core configs.
2. Extract architecture, conventions, code style.
3. Output to `docs/omnidev-state/00-project-context.md`, mark `project_type: legacy`.

### Learn (`/od learn`)
1. Scan progress docs/archives for errors and user corrections.
2. Extract lessons, write to `[AI Pitfall Guide]` in `00-project-context.md`.
3. **Feed Evolution Engine**: Each extracted pitfall MUST also be logged as an `error_resolution` signal in `docs/omnidev-state/evolution-log.jsonl`.

### Evolve (`/od evolve`)
Full specification: **Section L** below. In short: read `evolution-log.jsonl` → cluster → propose → WAIT → apply approved → log `evolution-history.md`. Passive signal logging only during `/od` work (see Section L scope).

### Project Type Awareness
- **Legacy**: Follow existing conventions 100%. No forced DDD/TDD. "Write code like a sensible veteran employee."
- **Greenfield**: Full modern conventions — OpenSpec / TDD / DDD, high test coverage, deployment manifests.

---

## J. MCP Integration

During Phase 3 & 4, proactively use available MCP servers:
- **Database MCP**: Verify table structures, insert mock data, check data flow.
- **Browser MCP (Playwright)**: Start server → visit page → E2E test → screenshot/DOM verification.
- **Discovery**: Check `.cursor/mcp.json` before complex tasks. If critical MCP missing, suggest installation.

---

## K. Skills & Best Practices

### Security (AgentShield)
- Verify third-party packages are mainstream before introducing.
- Never print tokens/passwords/DSNs in plain text — use `REDACTED`.

### Performance
- Precise reading: `Grep`/`SemanticSearch`/`offset+limit`.
- Minimal editing: `StrReplace` over full file rewrites.

### Framework-Specific
- **Go/Gin/GORM**: DI required; check `err`; business logic in Service, not Handler.
- **React/Next.js**: Strict mode; prefer Server Components; minimize re-renders.

---

## L. Self-Evolution Engine (Full Specification)

**Activation scope**: Everything in this section runs **only** on `/od`-prefixed turns (same as the rest of this skill). Do **not** append to `evolution-log.jsonl`, run evolution proposals, or treat corrections in plain chat as OmniDev signals.

OmniDev is not a static rule set — it is a **living system** that continuously improves itself based on real-world usage. The self-evolution engine observes, learns, and proposes rule/skill refinements when `/od` is active.

### L.1 Evolution Data Sources

The AI collects evolution signals from **four channels** (only while executing `/od` workflow or `/od` commands):

#### L.1.1 User Corrections (Implicit Feedback)
During `/od`-driven work, when the user corrects the AI's output (e.g., "不要这样做", "改成 XXX", manual edits after AI generation):

1. Detect the correction pattern.
2. Classify: **style preference** / **technical convention** / **workflow friction** / **wrong assumption**.
3. Record in `docs/omnidev-state/evolution-log.jsonl` (append-only).

#### L.1.2 Repeated Patterns (Behavioral Mining)
If, **within `/od` sessions**, the AI performs the **same manual adjustment 3+ times** across turns, flag as **evolution candidate**.

#### L.1.3 Error & Retry Signals
During `/od` execution, when errors occur (tests, lint, build) and a different approach succeeds, record **anti-pattern → resolution**.

#### L.1.4 Explicit Feedback (`/od evolve`)
- `/od evolve` — Scan signals, propose rule updates.
- `/od evolve [feedback]` — User gives direct feedback to learn from.
- `/od evolve --review` — Show log without applying.
- `/od evolve --apply` — Apply all pending proposals without interactive review.

### L.2 Evolution Log Format

Append-only JSONL at `docs/omnidev-state/evolution-log.jsonl`:

```jsonl
{"ts":"2026-03-29T10:00:00Z","type":"correction","category":"style","signal":"User prefers single quotes over double quotes in TypeScript","source":"user_edit","confidence":0.7}
{"ts":"2026-03-29T11:00:00Z","type":"pattern","category":"convention","signal":"Always add 'use client' directive to components using useState","source":"repeated_action","confidence":0.9}
{"ts":"2026-03-29T12:00:00Z","type":"error_resolution","category":"technical","signal":"GORM AutoMigrate must run before seeding; reverse order causes foreign key errors","source":"retry_success","confidence":0.95}
```

| Field | Type | Description |
|-------|------|-------------|
| `ts` | ISO 8601 | Timestamp |
| `type` | enum | `correction` / `pattern` / `error_resolution` / `explicit` |
| `category` | enum | `style` / `convention` / `technical` / `workflow` / `architecture` |
| `signal` | string | Human-readable learning |
| `source` | enum | `user_edit` / `user_verbal` / `repeated_action` / `retry_success` / `explicit_feedback` |
| `confidence` | float | 0.0–1.0 |

### L.3 Evolution Triggers

Propose evolution when **any**:

| Trigger | Condition |
|---------|-----------|
| **Accumulation** | 5+ same `category` in `evolution-log.jsonl` |
| **High Confidence** | Any signal with `confidence >= 0.95` |
| **Phase 4** | End of Phase 4: mini evolution review |
| **Explicit** | User types `/od evolve` |
| **`/od resume`** | After state restore via **`/od resume`**, if unprocessed high-confidence signals exist, mention `/od evolve` |

### L.4 Evolution Actions

**Step 1 — Aggregate**: Read `evolution-log.jsonl`, cluster by `category`, dedupe, rank.

**Step 2 — Proposals** (examples):

| Proposal Type | Target | Example |
|---------------|--------|---------|
| **Rule Amendment** | `.cursor/rules/*.mdc` | Path joining convention |
| **Pitfall Guide** | `00-project-context.md` [AI Pitfall Guide] | GORM migrate before seed |
| **New Skill** | `.cursor/skills/` | DB migration skill |
| **Workflow Tweak** | `SKILL.md` / project rules | Default skip blueprint for S |
| **Context Convention** | `00-project-context.md` | Quotes, tabs, trailing commas |

**Step 3 — Present** (then **STOP — WAIT**):

```
🧬 **OmniDev 进化提案** (基于 N 条学习信号)
...
请回复：
- `/od evolve 全部采纳`
- `/od evolve 采纳 1,3`
- `/od evolve 拒绝`
- `/od evolve 调整 [编号] [修改意见]`
```

**Step 4 — Apply** (after user confirmation): Patch files; mark signals `processed` in JSONL; append `docs/omnidev-state/evolution-history.md`; confirm success.

### L.5 Passive Evolution (Silent, `/od` Only)

| Adaptation | Action | No approval |
|------------|--------|-------------|
| **Pitfall Guide** | Append to `[AI Pitfall Guide]` | Yes |
| **Metrics** | Update `metrics.json` | Yes |
| **Signal Logging** | Append JSONL | Yes |

Rule/skill/workflow changes **always** need explicit user approval via `/od evolve` flow.

### L.6 Safety Guardrails

- **Never** remove/weaken: `/od` prefix requirement, checkpoints, security guardrails, or this section's safety rules.
- **Rollback**: `/od evolve --rollback [N]` using git history + `evolution-history.md`.
- **Confidence**: `< 0.5` never proposed; `0.5–0.8` needs 3+ occurrences; `>= 0.8` can propose after 1.

### L.7 Integration

- **`/od learn`**: Each pitfall → also `error_resolution` row in `evolution-log.jsonl`.
- **Phase 4**: If unprocessed signals, remind: `🧬 **进化信号**... /od evolve`.
- **`/od resume`**: If log has pending high-confidence signals, mention `/od evolve`.
