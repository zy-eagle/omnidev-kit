---
name: od
description: >-
  OmniDev AI-driven development workflow. Use when the user types /od to start
  a requirement, /od help for commands, /od onboard for legacy project scanning,
  /od report for status reports, /od review for code review, /od qa for testing,
  or /od change for mid-stream requirement changes.
---

# OmniDev Workflow Skill — Full Specification

This file is the **single source of truth** for all OmniDev rules. The lightweight trigger lives in `rules/01-omnidev-workflow.mdc` (`alwaysApply: false`); everything below is loaded on-demand when `/od` is detected.

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
5. Final summary → STOP.

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

### Session Recovery (`/resume`)
1. Read `03-progress.md` and `02-plan.md` (parse YAML frontmatter first).
2. Compare with `git status`.
3. Report: "🔄 **Context Restored**. Status: [X]. Next: [Y]. Continue?" → WAIT.

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
