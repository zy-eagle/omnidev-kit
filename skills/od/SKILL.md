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
| `/od next` | `/od c` | Next phase |
| `/od adj [content]` | — | Revise current phase output |
| `/od sk [phase]` | — | Skip a future phase |
| `/od back [phase]` | — | Re-enter a previous phase |
| `/od all` | — | Execute all remaining phases without checkpoints |

### Confirmation Commands

| Command | Action |
|---------|--------|
| `/od confirm-update` | Confirm OmniDev Kit update |
| `/od cancel` | Cancel the current operation |
| `/od confirm` | Confirm a change request (`/od change`) |
| `/od staged` | Confirm files have been manually staged (`/od push`) |
| `/od skip-add` | Skip manual staging, auto-run `git add .` (`/od push`) |
| `/od confirm-push` | Confirm and execute git commit & push |
| `/od edit-msg [msg]` | Modify the proposed commit message |
| `/od evolve accept-all` | Accept all evolution proposals |
| `/od evolve accept [N,N]` | Accept specific proposals by number |
| `/od evolve reject` | Reject all proposals |
| `/od evolve adjust [N] [feedback]` | Adjust a specific proposal |

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

### B.4 Lazy Context Loading

**Principle**: Do NOT read all state files or scan the entire project upfront. Each phase and command declares exactly what context it needs (see §E Phase Context Requirements). On entering a phase:

1. **Read only the files listed** in that phase's `context_requires` block.
2. **Skip files that don't exist** — their absence is informational (e.g. no `00-project-context.md` means onboard hasn't run; trigger §C.1 stack detection instead).
3. **Cache across phases within the same session** — if a file was already read in a previous phase of the current session, reuse it unless the phase explicitly says `reload: true`.
4. **Never pre-read** downstream phase artifacts (e.g. don't read `05-test-report.md` during Phase 2).
5. **Project scanning is gated**: full codebase scans (Grep, Glob, SemanticSearch) are only permitted when the phase's context block includes `scan: [target]`. Otherwise, operate on the files already known from state files or prior phases.

This keeps token usage proportional to the current phase's actual needs, not the total project size.

---

## C. Phase 0: Complexity Assessment

```yaml
context_requires:
  read:
    - 00-project-context.md          # cached stack info; may not exist
  scan:
    - package.json, go.mod, pom.xml  # only if 00-project-context.md missing or has no Stack & Layers section
    - top-level directory listing     # quick ls for structure signals
  skip:
    - 01-blueprint.md, 02-plan.md, 03-progress.md, 04-design.md  # not yet created
```

### C.1 Project Stack Detection

Before sizing, **scan the project once** (results are cached in `00-project-context.md` § Stack & Layers after `/od onboard`; re-scan only if the file is missing or the section is absent):

1. **Frontend signals** — look for any of:
   - `package.json` containing frontend frameworks (`react`, `vue`, `angular`, `svelte`, `next`, `nuxt`, `solid`, `astro`, etc.)
   - Directories: `src/pages`, `src/views`, `src/components`, `pages/`, `app/`, `frontend/`, `web/`, `client/`
   - Config files: `vite.config.*`, `next.config.*`, `nuxt.config.*`, `webpack.config.*`, `angular.json`, `.umirc.*`
2. **Backend signals** — look for any of:
   - `go.mod`, `requirements.txt`, `pyproject.toml`, `pom.xml`, `build.gradle`, `Cargo.toml`, `Gemfile`
   - `package.json` containing backend frameworks (`express`, `koa`, `fastify`, `nestjs`, `hono`, etc.)
   - Directories: `cmd/`, `internal/`, `server/`, `api/`, `backend/`, `services/`
3. **Classify**:
   - **fullstack**: both frontend and backend signals detected.
   - **frontend-only**: only frontend signals.
   - **backend-only**: only backend signals.
   - **monorepo**: multiple `package.json` or workspace config (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`).
4. Record detected stack in Phase 0 output (see format below).

### C.2 T-Shirt Sizing

- **S**: Skip blueprint/plan → Dev → Test directly.
- **M**: Skip blueprint → Plan → Dev → Test.
- **L/XL**: Full workflow: Blueprint → Plan → Dev → Test → Deploy.

Output format:
```
## OmniDev Phase 0: 需求解析 & 复杂度评估
**需求解析**: [1-2 sentences]
**项目结构**: [fullstack | frontend-only | backend-only | monorepo] — frontend: [framework/none], backend: [framework/none]
**复杂度评估**: [S/M/L/XL] — [reason]
**前端影响**: [yes — 需同步修改前端 | no — 纯后端变更 | n/a — 无前端代码]
**推荐策略**: [phases]
```

For **S tasks**: Do NOT generate state files. Resolve directly.

---

## D. Phase Execution Protocol

### D.1 Phase Entry — Context Loading

**Before executing any phase logic**, follow this sequence:

1. **Read the phase's `context_requires` block** (defined in §C / §E for each phase).
2. **Load `read` files** — read each listed file. If a file doesn't exist, note it and proceed (it means that phase's input hasn't been produced yet).
3. **Execute `scan` targets** — run the specified scans (Grep, Glob, git commands) to gather runtime context. Scope scans tightly to the listed targets; do not scan unrelated directories.
4. **Respect `skip`** — do NOT read the listed files, even if they exist. They are irrelevant to this phase and would waste context tokens.
5. **Check `reload`** — if a file is marked `reload`, re-read it even if it was loaded in a previous phase (its content may have changed).
6. **Proceed** with the phase logic using only the loaded context.

### D.2 Phase Exit — Checkpoint

After each phase completes, output:
```
✅ **Phase N Complete: [Phase Name]**
   Deliverables: [what was produced]
   Context loaded: [list files/scans actually read — transparency for the user]
📍 **Current Progress**: Completed: [...] ✅ | Remaining: [...] ⏳
🔜 **Next Phase: Phase N+1 — [Phase Name]**
   Will load: [list context_requires of next phase]
   Will do: [description]
```
Then ask: "Reply `/od next` to proceed. You can also: `/od adj [content]`, `/od sk [phase]`, `/od back [phase]`." and **STOP — WAIT for user reply**.

---

## E. Phases

### Phase 1: Blueprint (recommended for L/XL)

```yaml
context_requires:
  read:
    - 00-project-context.md          # stack type, conventions, pitfall guide
  scan:
    - source directories relevant to the requirement  # understand existing architecture
  skip:
    - 02-plan.md, 03-progress.md, 04-design.md, 05-test-report.md
```

1. Analyze requirements, edge cases, exception handling, UX.
2. Identify major work streams and their **input/output boundaries** — this feeds Phase 2 dependency analysis.
3. Output to `docs/omnidev-state/[branch]/01-blueprint.md` with **Mermaid.js** diagrams (include a task dependency graph for L/XL).
4. Checkpoint → WAIT.

### Phase 2: Planning (recommended for M+)

```yaml
context_requires:
  read:
    - 00-project-context.md          # stack type, frontend_root, frontend_patterns, backend_root
    - 01-blueprint.md                # architecture decisions, work streams (if Phase 1 ran)
  scan:
    - frontend entry files            # only if stack_type is fullstack/frontend-only — learn API client, router, state patterns
    - backend route/handler files     # understand existing API surface for impact analysis
  skip:
    - 03-progress.md, 04-design.md, 05-test-report.md, 06-release-notes.md
```

1. **Decompose** requirements into atomic tasks (each task has a single clear deliverable).
2. **Frontend Impact Analysis** — if Phase 0 detected `fullstack` or `frontend-only`:
   - For **every backend task** that changes an API contract (new endpoint, modified request/response schema, renamed field, deleted route), **automatically create a corresponding frontend sync task** covering: API call updates, type/interface changes, UI adjustments, and related component tests.
   - For **every data model change** (new field, renamed column, schema migration), check whether the frontend renders or submits that field; if yes, create a frontend sync task.
   - Scan the existing frontend code to learn the project's patterns (API client location, state management, component structure) so that generated frontend tasks reference the **correct files and conventions**.
   - Tag frontend sync tasks with `layer: frontend` and link them via `depends` to the backend task that triggers them.
   - If the requirement is **purely backend** with no API/schema surface change, explicitly note `前端影响: none` and skip frontend tasks.
3. **Dependency Analysis** — for every task, identify:
   - **Inputs**: what files, modules, or data it reads/consumes.
   - **Outputs**: what files, modules, or interfaces it produces/modifies.
   - **Depends-on**: list task IDs whose outputs are this task's inputs. Tasks with no dependencies are **independent**.
4. **Parallel / Serial Grouping** — organize tasks into execution groups:
   - Tasks sharing **no dependency edges** belong to the same **parallel group** (can execute concurrently).
   - Tasks with dependency chains form **serial sequences** within or across groups.
   - Groups execute in topological order; tasks within a group execute in parallel.
   - Frontend sync tasks typically depend on their backend counterpart and can be **parallelized** with other independent frontend tasks.
5. **Critical Path** — highlight the longest serial chain; this determines minimum total time.
6. Output structured plan to `docs/omnidev-state/[branch]/02-plan.md` using the format below.
7. Checkpoint → WAIT.

#### 02-plan.md Format

```markdown
---
total_tasks: N
parallel_groups: M
critical_path: [T1 → T3 → T5 → T7]
frontend_impact: yes | no
---

## Group 1 (parallel — no prerequisites)

- [ ] **T1** [backend] Create user data model · outputs: `models/user.go`
- [ ] **T2** [backend] Design API schema doc · outputs: `docs/api.yaml`

## Group 2 (parallel — after Group 1)

- [ ] **T3** [backend] Implement User CRUD service · depends: T1 · outputs: `service/user.go`
- [ ] **T4** [backend] Implement API handlers · depends: T3 · outputs: `handler/user.go`

## Group 3 (parallel — after Group 2)

- [ ] **T5** [frontend] Update API client & types · depends: T4 · outputs: `src/api/user.ts`, `src/types/user.d.ts`
- [ ] **T6** [frontend] Add user list page · depends: T5 · outputs: `src/pages/user/list.vue`
- [ ] **T7** [frontend] Add user form component · depends: T5 · outputs: `src/components/UserForm.vue`
- [ ] **T8** [test] Backend unit tests · depends: T3 · outputs: `service/user_test.go`
- [ ] **T9** [test] Frontend component tests · depends: T6, T7 · outputs: `src/pages/user/__tests__/*`
```

Key rules:
- Each task has a unique **ID** (T1, T2, …).
- Each task has a **layer tag**: `[backend]`, `[frontend]`, `[test]`, `[infra]`, `[docs]`, etc.
- `depends` lists prerequisite task IDs; omit if none.
- `outputs` lists primary files/modules produced.
- Groups are numbered in execution order; tasks within a group have **no mutual dependencies** and are safe to run in parallel.
- Frontend sync tasks are **auto-generated** when backend changes affect API contracts or data models in a fullstack project; they must reference the project's actual frontend file paths and conventions (learned from scanning existing code).

### Phase 3: Development

```yaml
context_requires:
  read:
    - 00-project-context.md          # conventions, pitfall guide, stack info
    - 02-plan.md                     # task groups, dependencies, layer tags — the execution roadmap
    - 03-progress.md                 # resume point (if continuing a previous session)
    - 04-design.md                   # architectural constraints (if exists)
  scan:
    - files listed in current group's task `outputs` and `depends`  # only the code relevant to the active group
  reload: 02-plan.md                 # re-read after each group completes to see updated checkboxes
  skip:
    - 01-blueprint.md                # already consumed by Phase 2
    - 05-test-report.md, 06-release-notes.md
```

1. Auto-checkpoint: `git commit -m "chore: auto-checkpoint before omnidev task"`.
2. **Execute by group order** from `02-plan.md`:
   - For each **parallel group**, assess whether tasks can be dispatched concurrently:
     - **Parallel dispatch** (preferred when tasks touch **different files/modules** with no shared state): launch independent tasks via separate subagents (`Task` tool) simultaneously, then collect results.
     - **Sequential fallback**: if tasks in the same group modify **overlapping files** or the runtime environment doesn't support parallel dispatch, execute them one by one.
   - After all tasks in a group complete, proceed to the next group.
3. **Frontend sync execution** — when executing `[frontend]` tasks:
   - Read `00-project-context.md` § Stack & Layers to locate `frontend_root`, `frontend_patterns`.
   - **Follow existing conventions**: use the project's actual API client wrapper (not raw fetch/axios), match the existing state management pattern, follow the component naming and directory conventions already in use.
   - After modifying frontend code, verify consistency: imports resolve, TypeScript types align with the new backend contract, no dead references to old field names.
   - If the frontend framework has a dev server command in `package.json`, suggest running it for visual verification.
4. Adaptive coding:
   - Legacy: imitate surrounding code, reuse existing utilities.
   - Greenfield: TDD/DDD, modern conventions.
5. Update `02-plan.md` checkboxes after each task completes (mark `[x]`).
6. If a task fails or is blocked, note the blocker in `03-progress.md` and continue with other independent tasks in the same group.
7. Checkpoint → WAIT.

### Phase 4: Testing & Wrap-up

```yaml
context_requires:
  read:
    - 00-project-context.md          # test conventions, stack info
    - 02-plan.md                     # verify all tasks checked off
    - 03-progress.md                 # blockers, known issues
    - 04-design.md                   # verify implementation matches design
    - evolution-log.jsonl            # check for unprocessed signals
    - metrics.json                   # append efficiency data
  scan:
    - test directories               # existing test patterns, frameworks, config
    - files modified during Phase 3   # verify changes, write targeted tests
  skip:
    - 01-blueprint.md               # not needed for testing
```

1. Run/write test cases. For legacy without test infra, basic verification only.
2. Generate `05-test-report.md` (scope, mock data, results, limitations).
3. For M+: generate `06-release-notes.md` with efficiency bill.
4. Trigger `/od learn` flow.
5. **Evolution Signal Check**: Scan `docs/omnidev-state/evolution-log.jsonl` for unprocessed signals. If any exist, append: "🧬 **Evolution Signals**: Detected N new learning signals. Reply `/od evolve` to review evolution proposals."
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

```yaml
context_requires:
  read:
    - 03-progress.md                 # YAML frontmatter → status, current_step, last_updated
    - 02-plan.md                     # task groups, checkbox state → what's done, what's next
    - evolution-log.jsonl            # pending high-confidence signals
  scan:
    - git status                     # compare working tree with saved state
  skip:
    - 00-project-context.md          # defer until next phase actually starts
    - 01-blueprint.md, 04-design.md  # defer — only load when the resumed phase needs them
```

Use **`/od resume`** (not bare `/resume`) so this skill loads and OmniDev state rules apply.

1. Read `03-progress.md` and `02-plan.md` (parse YAML frontmatter first).
2. Compare with `git status`.
3. Check `evolution-log.jsonl` for unprocessed high-confidence signals. If any: "💡 There are N pending evolution signals. Use `/od evolve` to review."
4. Report: "🔄 **Context Restored**. Status: [X]. Last stopped at: [Z]. Next: [Y]. Reply `/od next` to continue." → **STOP — WAIT**.

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
When user confirms release notes, prompt: "🎉 **Requirement development and verification are fully complete!** Would you like me to generate a Git Commit Message? Reply `/od confirm` to proceed." → **STOP — WAIT**.

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

```yaml
context_requires:
  read:                              # report needs the full picture — exception to minimal loading
    - 00-project-context.md
    - 02-plan.md
    - 03-progress.md
    - metrics.json
    - archive/*                      # historical progress
  scan:
    - git log --since="7 days ago"
```

1. Read all state files + `archive/`.
2. Analyze `git log` (past 7 days).
3. Generate management-ready report in `docs/omnidev-state/weekly-report-[date].md`.
4. Include: executive summary, AI-assisted achievements, progress, blockers, next week plan.

### Change Management (`/od change`)

```yaml
context_requires:
  read:
    - 00-project-context.md          # stack info for impact scope
    - 02-plan.md                     # current plan to assess impact against
    - 03-progress.md                 # what's already done (can't undo)
    - 04-design.md                   # architectural constraints
  scan:
    - files affected by the proposed change
```

1. Impact assessment on current architecture.
2. Ask: "Reply `/od confirm` to apply this change, or `/od cancel` to abort." → **STOP — WAIT**.
3. After `/od confirm`: archive old plan, regenerate blueprint/plan.

### Push (`/od push`)

```yaml
context_requires:
  scan:
    - git status                     # modified files list
    - git diff --staged              # after staging, for commit message generation
  skip:
    - all state files                # push doesn't need OmniDev state
```

1. `git status` → show modified files.
2. Prompt user:
   > "📋 **The following files have been modified but are not yet staged:** [list]
   > Please run `git add` in the terminal. When done, reply:
   > - `/od staged` — I have manually selected the files to commit
   > - `/od skip-add` — Commit all changes directly (auto-run `git add .`)"
   **STOP — WAIT.**
3. After `/od staged` or `/od skip-add`: analyze diff, generate commit message, show to user:
   > "📝 **Commit message**: `[message]`. Reply `/od confirm-push` to execute, or `/od edit-msg [new message]` to modify."
   **STOP — WAIT.**
4. After `/od confirm-push`: `git commit` + `git push origin <current-branch>`. Report result.

### Update (`/od update`)
1. **Confirm**: Stop and warn the user:
   > "⚠️ **Warning**: Updating from the remote repository will **directly overwrite** local `.cursor/rules/` and `SKILL.md` files with the same name, and **delete** any local files that no longer exist in the remote repository. Your local customizations that have not been pushed to remote will be lost. Reply `/od confirm-update` to proceed, or `/od cancel` to abort."
   **🛑 STOP — WAIT for `/od confirm-update`. DO NOT proceed automatically.**
2. **Fetch & Overwrite**: Only after `/od confirm-update`, clone `https://github.com/zy-eagle/omnidev-kit.git` to a temp dir, then:
   - **Overwrite same-name files**: Forcefully copy all `rules/*.mdc` and `skills/od/SKILL.md` from the cloned repo to the current project, overwriting existing files.
   - **Delete obsolete files**: Compare local `rules/` and `skills/od/` with the cloned repo. Delete any local files that do **not** exist in the remote (i.e., removed upstream).
3. **Cleanup**: Delete the temp dir. Report success, listing which files were overwritten and which were deleted.

### Install (`/od install <url>`)
1. `git clone --depth 1 <url> _omnidev-kit-tmp`.
2. Validate structure, read INSTALL.md, copy rules/skills (non-destructive merge).
3. Cleanup, report success.

### Onboard (`/od onboard`)

```yaml
context_requires:
  read:
    - 00-project-context.md          # check if already exists (update vs create)
  scan:
    - package.json, go.mod, pom.xml, Cargo.toml, requirements.txt  # dependency detection
    - top-level directory listing     # structure signals
    - config files (vite, webpack, tsconfig, docker-compose, etc.)
    - .cursor/mcp.json               # available MCP servers
  skip:
    - all branch-specific state files # onboard is project-global, not branch-specific
```

1. Scan project dependencies, directory structure, core configs.
2. **Stack & Layer Detection** — run the same detection logic as Phase 0 §C.1 and record:
   - `stack_type`: `fullstack` | `frontend-only` | `backend-only` | `monorepo`
   - `frontend_framework`: detected framework and version (e.g. `vue@3.4`, `react@18`, `none`)
   - `frontend_root`: relative path to frontend entry (e.g. `frontend/`, `src/`, `.`)
   - `frontend_patterns`: discovered conventions — API client location, state management (pinia/vuex/redux/zustand), router, component directory, naming style (PascalCase/kebab-case)
   - `backend_framework`: detected framework and version (e.g. `gin@1.9`, `express@4`, `none`)
   - `backend_root`: relative path to backend entry
3. Extract architecture, conventions, code style.
4. Output to `docs/omnidev-state/00-project-context.md`, mark `project_type: legacy` or `greenfield`. Include a **## Stack & Layers** section with the fields above so that Phase 0/2 can read cached results instead of re-scanning.

### Learn (`/od learn`)
1. Scan progress docs/archives for errors and user corrections.
2. Extract lessons, write to `[AI Pitfall Guide]` in `00-project-context.md`.
3. **Feed Evolution Engine**: Each extracted pitfall MUST also be logged as an `error_resolution` signal in `docs/omnidev-state/evolution-log.jsonl`.

### Evolve (`/od evolve`)

```yaml
context_requires:
  read:
    - evolution-log.jsonl            # all signals to cluster and propose from
    - evolution-history.md           # past evolutions for dedup
    - 00-project-context.md          # project conventions for proposal context
  scan:
    - .cursor/rules/*.mdc            # current rules — needed to draft amendments
    - skills/od/SKILL.md             # current skill — needed for workflow tweaks
  skip:
    - branch-specific state files    # evolution is project-global
```

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
🧬 **OmniDev Evolution Proposals** (based on N learning signals)
...
Reply:
- `/od evolve accept-all` — Accept all proposals
- `/od evolve accept 1,3` — Accept specific proposals
- `/od evolve reject` — Reject all proposals
- `/od evolve adjust [N] [feedback]` — Adjust a specific proposal
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
- **Phase 4**: If unprocessed signals, remind: `🧬 **Evolution Signals**... /od evolve`.
- **`/od resume`**: If log has pending high-confidence signals, mention `/od evolve`.
