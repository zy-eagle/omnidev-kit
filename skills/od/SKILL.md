---
name: od
description: >-
  OmniDev AI-driven development workflow. Use ONLY when the user's message starts with /od
  (e.g. /od h, /od re, /od ob, /od rp, /od rv, /od qa, /od ch, /od ln).
  Do not load or follow this skill for normal chat without the /od prefix.
---

# OmniDev Workflow Skill — Full Specification

This file is the **single source of truth** for all OmniDev rules. The lightweight trigger lives in `rules/01-omnidev-workflow.mdc` (`alwaysApply: false`); **everything below applies only when the current user message starts with `/od`** — including workflow, `docs/omnidev-state/**`, and evolution logging. No OmniDev behavior on non-`/od` turns.

---

## A. Command Reference

All commands support **short aliases** (1-2 letters). Users can also reply with **numbers** (e.g. `1`, `2`, `3`) when presented with numbered options at any checkpoint.

### Core Commands

| Command | Alias | 说明 |
|---------|-------|------|
| `/od [需求]` | — | 引导式工作流：评估复杂度 → 推荐阶段 → 可跳过任意阶段 |
| `/od -f [需求]` | — | 快速模式：跳过蓝图/计划，直接开发（热修复） |
| `/od -p [需求]` | — | 仅规划：只输出蓝图和计划，不写代码 |
| `/od h` | `/od help` | 显示所有命令 |
| `/od ob` | `/od onboard` | 扫描项目，生成上下文文档 |
| `/od rp` | `/od report` | 生成周报 |
| `/od rv` | `/od review` | 代码审查（只读，不修改） |
| `/od qa` | — | 依赖分析 → Mock → 场景覆盖 → 韧性测试 → 测试报告 |
| `/od ch [新需求]` | `/od change` | 需求变更管理 |
| `/od ln` | `/od learn` | 自学习：回顾错误 + 提炼规则 + 演化提案 |
| `/od ln -r` | — | 查看学习日志和待处理提案 |
| `/od ln -a` | — | 自动应用所有待处理提案 |
| `/od ln --rb [N]` | — | 回滚第 N 条演化 |
| `/od up` | `/od update` | 更新 OmniDev Kit 到最新版本 |
| `/od i <url>` | `/od install` | 从远程 Git 仓库安装 OmniDev Kit |
| `/od ps` | `/od push` | 提交并推送代码 |
| `/od st` | `/od stash` | 暂存当前任务上下文 |
| `/od po` | `/od pop` | 恢复暂存的任务上下文 |
| `/od sy` | `/od sync` | 同步输出到 Jira/GitHub Issue |
| `/od db` | `/od dashboard` | 生成全局效率 ROI 面板 |
| `/od re` | `/od resume` | 恢复上次中断的会话（加载 OmniDev 规则） |

### Phase Navigation (阶段导航)

| Command | Alias | 说明 |
|---------|-------|------|
| `/od n` | `/od next` | 下一阶段 |
| `/od ad [内容]` | `/od adj` | 修订当前阶段输出 |
| `/od sk [阶段]` | `/od skip` | 跳过某个阶段 |
| `/od bk [阶段]` | `/od back` | 返回某个阶段 |
| `/od al` | `/od all` | 执行所有剩余阶段（不暂停） |

### Confirmation (确认操作)

At every checkpoint, options are presented as **numbered list** — user can reply with the **number**, the **alias**, or the **full command**. Example: reply `1` or `/od n` or `/od next` all mean "proceed to next phase".

| Command | Alias | 说明 |
|---------|-------|------|
| `/od y` | `/od confirm` | 确认当前操作 |
| `/od x` | `/od cancel` | 取消当前操作 |
| `/od em [msg]` | — | 修改提交信息（`/od ps` 流程中） |
| `/od ln y` | — | 接受所有学习提案 |
| `/od ln y [N,N]` | — | 接受指定编号的提案 |
| `/od ln x` | — | 拒绝所有提案 |
| `/od ln ad [N] [反馈]` | — | 调整指定提案 |

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

### B.4 Numbered Quick-Select (数字快捷选择)

At **every checkpoint** where the user needs to choose an action, present options as a **numbered list with Chinese descriptions**. The user can reply with:
- The **number** (e.g. `1`, `2`, `3`)
- The **short alias** (e.g. `/od n`)
- The **full command** (e.g. `/od next`)

All three forms are equivalent. The AI must parse number replies and map them to the corresponding action.

**Format template** for all checkpoints:
```
请选择下一步操作：
  1. 继续下一阶段 (`/od n`)
  2. 修订当前输出 (`/od ad [内容]`)
  3. 跳过某阶段 (`/od sk [阶段]`)
  4. 返回某阶段 (`/od bk [阶段]`)
  5. 执行所有剩余阶段 (`/od al`)
```

**Rules**:
- Numbers are **context-dependent** — each checkpoint defines its own numbered menu (Phase Exit has 5 options, Push has 3 options, etc.).
- If the user replies with a number that is out of range, ask them to choose again.
- Always show the short alias in parentheses next to each option so the user learns the shortcuts over time.

### B.5 Lazy Context Loading

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
**稳定性级别**: [standard — 友好错误返回 | high — 熔断/降级/重试/限流] — [reason: user requested / default]
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
✅ **Phase N 完成: [Phase Name]**
   产出物: [what was produced]
   已加载上下文: [list files/scans actually read]
📍 **当前进度**: 已完成: [...] ✅ | 剩余: [...] ⏳
🔜 **下一阶段: Phase N+1 — [Phase Name]**
   将加载: [list context_requires of next phase]
   将执行: [description]

请选择下一步操作：
  1. ▶ 继续下一阶段 (`/od n`)
  2. ✏ 修订当前输出 (`/od ad [内容]`)
  3. ⏭ 跳过某阶段 (`/od sk [阶段]`)
  4. ◀ 返回某阶段 (`/od bk [阶段]`)
  5. ⏩ 执行所有剩余阶段 (`/od al`)
```
Then **STOP — WAIT for user reply**. Accept number (`1`–`5`), alias (`/od n`), or full command (`/od next`).

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
    - 00-project-context.md          # conventions, pitfall guide, stack info, dependency topology, stability_level
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
5. **Interface Resilience & Security Coding** — apply to every new/modified API endpoint or service interface (see §3.1 below).
6. Update `02-plan.md` checkboxes after each task completes (mark `[x]`).
7. If a task fails or is blocked, note the blocker in `03-progress.md` and continue with other independent tasks in the same group.
8. Checkpoint → WAIT.

#### 3.1 Interface Resilience & Security Requirements (DevSecOps)

Every interface implemented in Phase 3 must handle system-level failures gracefully and prevent common security vulnerabilities. The depth of resilience depends on the **Stability Level** (recorded in `00-project-context.md` § Stability Level, or inferred from user requirements):

**Security by Design (Mandatory for ALL levels)**:
1. **IDOR/BOLA Prevention**: Always verify resource ownership at the API boundary. Never trust the client-provided ID without checking if `resource.owner_id == current_user.id`.
2. **Injection Prevention**: Always use parameterized queries or ORM methods. Never concatenate user input into SQL, NoSQL, or shell commands.
3. **SSRF/CSRF Prevention**: Validate outbound URLs against a whitelist. Use anti-CSRF tokens or `SameSite` cookies for web sessions.
4. **Sensitive Data Protection**: Never log plaintext passwords, tokens, or PII. Always hash passwords (e.g., bcrypt, argon2) before storage. Ensure HTTPS/TLS is used for data in transit.

**Stability Level Classification**:

| Level | Trigger | Description |
|-------|---------|-------------|
| **Standard** | Default for all projects unless user states otherwise | Friendly error responses; basic timeout; no advanced patterns required |
| **High** | User explicitly requests high availability / stability / production-critical | Full resilience patterns: circuit breaker, bulkhead, retry, graceful degradation |

**Standard Level (default) — mandatory for ALL interfaces**:

1. **Structured Error Response**: Every error must return a consistent JSON structure with `code`, `message`, and optional `details`. Never expose raw stack traces, internal paths, or dependency names to the caller.
   ```json
   {"code": "VALIDATION_ERROR", "message": "Name is required", "details": {"field": "name"}}
   {"code": "INTERNAL_ERROR", "message": "Service temporarily unavailable, please retry later"}
   ```
2. **Timeout Control**: Every outbound call (DB query, HTTP request, RPC call) must have an explicit timeout. Never allow unbounded waits.
   - Default: 5s for DB, 10s for HTTP, 30s for batch operations (adjust per project convention).
3. **Graceful Dependency Failure**: When a downstream dependency (DB, cache, third-party API) fails:
   - Return an appropriate HTTP status (`502`, `503`, `504`) with a user-friendly message.
   - Log the actual error with full context (dependency name, operation, duration, error detail) for debugging.
   - Never crash the process or leave connections hanging.
4. **Input Validation at Boundary**: Validate and sanitize all inputs at the API entry point before any business logic or dependency call.

**High Level (user-requested) — additional patterns on top of Standard**:

5. **Circuit Breaker**: Wrap calls to each external dependency with a circuit breaker (e.g. `gobreaker`, `resilience4j`, `opossum`). When failure rate exceeds threshold, trip the circuit and return a degraded response immediately without calling the failing dependency.
6. **Retry with Backoff**: For transient failures (network blip, 503, connection reset), implement retry with exponential backoff and jitter. Max 3 retries. Only retry **idempotent** operations.
7. **Bulkhead Isolation**: Isolate dependency call pools (connection pools, thread pools, goroutine limits) so that one slow/failing dependency cannot exhaust resources and cascade to others.
8. **Graceful Degradation**: When a non-critical dependency fails (e.g. recommendation service, analytics), return a degraded but functional response rather than a full error. Document which dependencies are degradable vs. critical.
9. **Rate Limiting / Backpressure**: For high-throughput endpoints, implement rate limiting or backpressure mechanisms to prevent resource exhaustion under burst traffic.
10. **Health Check Endpoint**: Expose a `/health` or `/readiness` endpoint that checks all critical dependencies and reports aggregate health status.

**Implementation Checklist** (AI must verify before marking a task complete):
- [ ] Resource ownership verified (IDOR/BOLA prevention)
- [ ] SQL/NoSQL injection prevented (parameterized queries)
- [ ] Sensitive data masked in logs and responses
- [ ] All outbound calls have explicit timeouts
- [ ] All errors return structured JSON (no raw stack traces)
- [ ] Dependency failures produce appropriate HTTP status codes
- [ ] Input validation happens at the boundary
- [ ] (High only) Circuit breaker wraps external dependency calls
- [ ] (High only) Retry logic uses exponential backoff with jitter
- [ ] (High only) Degradable dependencies have fallback responses

### Phase 4: Testing & Wrap-up

```yaml
context_requires:
  read:
    - 00-project-context.md          # test conventions, stack info, dependency topology
    - 02-plan.md                     # verify all tasks checked off
    - 03-progress.md                 # blockers, known issues
    - 04-design.md                   # verify implementation matches design
    - evolution-log.jsonl            # check for unprocessed signals
    - metrics.json                   # append efficiency data
  scan:
    - test directories               # existing test patterns, frameworks, config
    - files modified during Phase 3   # verify changes, write targeted tests
    - config files for DB/cache/MQ connection strings  # identify storage dependencies
    - source code for HTTP/gRPC client calls           # identify third-party service dependencies
  skip:
    - 01-blueprint.md               # not needed for testing
```

#### 4.1 Dependency Analysis (Pre-Test)

Before writing any test, **map the dependency topology** of the code modified in Phase 3:

1. **Storage Dependencies** — scan for:
   - Database connections (MySQL, PostgreSQL, MongoDB, SQLite, etc.)
   - Cache layers (Redis, Memcached, etc.)
   - Message queues (Kafka, RabbitMQ, NATS, Pulsar, etc.)
   - Search engines (Elasticsearch, OpenSearch, Meilisearch, etc.)
   - Object storage (S3, OSS, MinIO, etc.)
   - File system I/O (local file read/write)
2. **Third-Party Service Dependencies** — scan for:
   - External HTTP/gRPC API calls (payment gateways, SMS providers, OAuth, etc.)
   - SDK integrations (cloud SDKs, monitoring SDKs, etc.)
   - Internal microservice calls (service-to-service RPC, event bus consumers)
3. **Classify each dependency**:
   - `controllable` — can be started locally (Docker, in-memory, embedded) or has MCP available
   - `mockable` — no local instance, must use mock/stub/fake
   - `credential-gated` — requires real credentials → **STOP and ask user**
4. Output a **Dependency Map** table in `05-test-report.md` § Dependencies.

#### 4.2 Mock Strategy

When a dependency's data source is **not directly available**, use mock data to achieve full scenario coverage:

1. **Mock Hierarchy** (prefer higher levels):
   | Level | Technique | When to Use |
   |-------|-----------|-------------|
   | **Interface Mock** | Mock at interface/trait boundary (e.g. `gomock`, `jest.mock`, `unittest.mock`) | Default for unit tests — isolate business logic from I/O |
   | **In-Memory Fake** | Lightweight in-process implementation (e.g. SQLite for MySQL, in-memory map for Redis) | Integration tests needing real query behavior without external infra |
   | **Container Stub** | Docker-based ephemeral service (e.g. `testcontainers`) | When query semantics matter and in-memory fakes are insufficient |
   | **HTTP/gRPC Stub** | Stub server returning canned responses (e.g. `wiremock`, `httptest`, `msw`) | Third-party API calls that cannot be reached in test env |
   | **MCP-Driven** | Use Database MCP / Browser MCP to insert data and verify state | When MCP is available — preferred over manual mocks |

2. **Mock Data Design Principles**:
   - Cover **happy path**, **edge cases**, **boundary values**, and **error conditions** for every interface.
   - Include **empty/null inputs**, **maximum-length inputs**, **concurrent-conflicting inputs**, **malformed inputs**.
   - Desensitize all mock data — no real PII, credentials, or production data.
   - Document every mock dataset with its **purpose** and **expected output** in the test report.

3. **Mock Boundary Rule**: Mock at the **narrowest boundary** possible. If testing a Service layer, mock the Repository — not the entire HTTP handler chain. This ensures maximum real code coverage.

#### 4.3 Scenario Coverage Matrix

For every interface (API endpoint / function / message handler) modified in Phase 3, build a **Scenario Coverage Matrix**:

```markdown
| # | Scenario | Input | Expected Output | Mock Dependencies | Status |
|---|----------|-------|-----------------|-------------------|--------|
| 1 | Happy path — normal create | `{name: "test", age: 25}` | `201 {id: 1}` | DB: in-memory | ✅ PASS |
| 2 | Validation — missing required field | `{age: 25}` | `400 {error: "name required"}` | None | ✅ PASS |
| 3 | Duplicate key conflict | `{name: "existing"}` | `409 {error: "already exists"}` | DB: pre-seeded duplicate | ✅ PASS |
| 4 | DB connection failure | `{name: "test"}` | `503 {error: "service unavailable"}` | DB: mock returns error | ✅ PASS |
| 5 | Concurrent writes | 10x parallel `{name: "race-N"}` | All succeed, no duplicates | DB: in-memory with lock | ✅ PASS |
| 6 | Boundary — max length input | `{name: "a"*10000}` | `400 {error: "name too long"}` | None | ✅ PASS |
```

**Minimum scenario categories** (adapt per interface type):
- **Normal / Happy path**: Standard valid input → expected success response
- **Validation / Bad input**: Missing fields, wrong types, boundary values, malformed data
- **Conflict / Idempotency**: Duplicate operations, concurrent modifications
- **Dependency failure**: Each storage/service dependency returns error or times out
- **Authorization**: Missing/invalid/expired credentials (if applicable)
- **Pagination / Bulk**: Empty result set, single page, multi-page, oversized request
- **Security / Injection**: SQL injection (`' OR 1=1 --`), XSS (`<script>alert(1)</script>`), oversized malicious payloads
- **Security / IDOR**: Unauthorized access attempts (User A trying to read/modify User B's resources)

#### 4.4 System-Level Resilience Testing

Beyond functional correctness, verify the interface's behavior under **system-level fault conditions** common in microservice environments:

| Fault Category | Test Method | Expected Behavior |
|----------------|-------------|-------------------|
| **Network Latency** | Inject artificial delay (e.g. `time.Sleep`, `setTimeout`, proxy delay) into dependency calls | Interface returns within acceptable timeout; does not hang indefinitely |
| **Network Partition** | Mock dependency to return `connection refused` / `ECONNREFUSED` | Graceful error response (not stack trace); retry if idempotent |
| **Dependency Timeout** | Set dependency mock to never respond; verify caller's timeout fires | Returns timeout error within configured deadline; releases resources |
| **High Concurrency** | Send N parallel requests (N = 10/50/100 based on expected load) to the same endpoint | No race conditions, no data corruption; **P99 Latency < 200ms** |
| **Memory Pressure** | Process large payloads (oversized JSON, huge file upload) | Rejects with `413` or streams without OOM; memory returns to baseline |
| **Cascading Failure** | Multiple dependencies fail simultaneously | Circuit breaker trips (if implemented); partial degradation, not total crash |
| **Slow Consumer** | Response stream consumer reads slowly or disconnects mid-stream | Server releases resources; no goroutine/connection leak |

**Performance SLA**: Under normal and high concurrency load, the interface must maintain a **P99 Latency of < 200ms** (unless otherwise specified by the architecture).

**Execution rules**:
- **Always run** network latency, dependency timeout, and high concurrency tests — these are the most common production failures.
- **Conditionally run** memory pressure and cascading failure tests for L/XL tasks or when user explicitly requests high stability.
- Record **actual response time**, **error message**, and **resource cleanup status** for each test.
- If a resilience test reveals unhandled failure, **log it as a bug** in `03-progress.md` and propose a fix.

#### 4.5 Test Execution & Reporting

1. **Execute SAST (Static Application Security Testing)** — run security linters if available in the project (e.g., `npm audit`, `gosec`, `bandit`, `eslint-plugin-security`). Fix any high/critical vulnerabilities introduced in Phase 3.
2. **Execute all tests with coverage** — run the test suite using coverage flags (e.g., `go test -cover`, `jest --coverage`).
   - **Coverage Gate**: Statement/Branch coverage must be **>= 90%** for the modified code. If below 90%, write additional tests to cover missing branches before proceeding.
3. **Generate `05-test-report.md`** with the full template (see §G.2 for format).
4. For M+: generate `06-release-notes.md` with efficiency bill.
5. Trigger `/od ln` (self-learning) flow.
6. **Learning Signal Check**: Scan `docs/omnidev-state/evolution-log.jsonl` for unprocessed signals. If any exist, append: "🧬 发现 N 条学习信号。使用 `/od ln` 查看提案。"
7. Final summary → STOP.

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

### Session Recovery (`/od re`)

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

Use **`/od re`** (not bare `/resume`) so this skill loads and OmniDev state rules apply.

1. Read `03-progress.md` and `02-plan.md` (parse YAML frontmatter first).
2. Compare with `git status`.
3. Check `evolution-log.jsonl` for unprocessed high-confidence signals. If any: "💡 发现 N 条待处理的学习信号。使用 `/od ln` 查看。"
4. Report:
   ```
   🔄 上下文已恢复。状态: [X]。上次停在: [Z]。下一步: [Y]。
   请选择：
     1. ▶ 继续下一阶段 (`/od n`)
     2. 📋 查看学习信号 (`/od ln -r`)
     3. ❌ 取消 (`/od x`)
   ```
   **STOP — WAIT**.

### SDD (Spec-Driven Development)
- Major architectural decisions must first be recorded in `04-design.md`.
- Code must stay consistent with `04-design.md`. If deviating, update design first.

### Stash/Pop
- `/od st`: Save state, set status to `stashed`, clear active context.
- `/od po`: Read stashed state, restore branch/context, resume.

---

## G. Testing & Deployment

### G.1 Testing Philosophy

- **No "blind confidence"** — execute test cases, not just write code. Every interface must be verified with real (or mock) inputs and observed outputs.
- If database MCP available: insert mock data → run code → verify data state.
- If external service credentials needed: **STOP and ask user**.
- Security: never hardcode keys/passwords in state files or code.
- **Mock-first when no data source**: When a dependency's data source is not directly available, always use mock data to cover all functional scenarios. Never skip testing because "the database isn't available."

### G.2 Test Report Template (`05-test-report.md`)

The test report is the **primary deliverable** of Phase 4. It must be comprehensive enough for a reviewer to understand what was tested, how, and what remains untested.

```markdown
---
generated: "[ISO 8601 timestamp]"
branch: "[branch name]"
stability_level: standard | high
total_scenarios: N
passed: N
failed: N
skipped: N
---

# Test Report

## 1. Dependency Topology

| Dependency | Type | Category | Test Strategy |
|------------|------|----------|---------------|
| MySQL (user_db) | Storage | controllable | Docker testcontainer |
| Redis (session_cache) | Storage | controllable | In-memory fake |
| Payment Gateway API | Third-Party | mockable | HTTP stub (wiremock) |
| Auth Service (internal) | Microservice | mockable | Interface mock |
| SMS Provider | Third-Party | credential-gated | Skipped — requires prod credentials |

## 2. Mock Data Registry

| Mock ID | Target Dependency | Purpose | Data Shape |
|---------|-------------------|---------|------------|
| MOCK-001 | MySQL user_db | Normal user record | `{id: 1, name: "test_user", email: "t@test.com", status: "active"}` |
| MOCK-002 | MySQL user_db | Edge case — max length fields | `{name: "a"*255, email: "b"*320+"@test.com"}` |
| MOCK-003 | MySQL user_db | Security — SQL Injection | `{name: "' OR 1=1 --"}` |
| MOCK-004 | Payment Gateway | Successful payment response | `{status: "success", txn_id: "mock-txn-001"}` |
| MOCK-005 | Payment Gateway | Timeout simulation | `[no response within 10s]` |
| MOCK-006 | Redis session_cache | Cache miss | `nil` |

## 3. Scenario Coverage Matrix

### 3.1 [Interface Name: POST /api/users]

| # | Scenario | Category | Input | Expected Output | Mock Used | Result | Duration |
|---|----------|----------|-------|-----------------|-----------|--------|----------|
| 1 | Normal create | Happy path | `{name: "test", email: "t@t.com"}` | `201 {id: 1}` | MOCK-001 | ✅ PASS | 12ms |
| 2 | Missing required field | Validation | `{email: "t@t.com"}` | `400 {code: "VALIDATION_ERROR"}` | None | ✅ PASS | 3ms |
| 3 | Duplicate email | Conflict | `{name: "test2", email: "t@t.com"}` | `409 {code: "CONFLICT"}` | MOCK-001 | ✅ PASS | 8ms |
| 4 | DB connection failure | Dependency fault | `{name: "test"}` | `503 {code: "INTERNAL_ERROR"}` | DB mock error | ✅ PASS | 5004ms |
| 5 | Max length input | Boundary | MOCK-002 | `400 {code: "VALIDATION_ERROR"}` | None | ✅ PASS | 4ms |
| 6 | SQL Injection | Security | `{name: "' OR 1=1 --"}` | `400 {code: "VALIDATION_ERROR"}` | None | ✅ PASS | 3ms |
| 7 | Unauthorized Access (IDOR) | Security | User A requests User B's ID | `403 {code: "FORBIDDEN"}` | DB: User B record | ✅ PASS | 5ms |
| 8 | 50 concurrent creates | Concurrency | 50x parallel requests | All succeed, no duplicates | MOCK-001 | ✅ PASS | 320ms |

### 3.2 [Interface Name: GET /api/users/:id]
(same matrix format)

## 4. System-Level Resilience Tests

| # | Fault Type | Target | Method | Expected Behavior | Actual Behavior | Result |
|---|-----------|--------|--------|-------------------|-----------------|--------|
| R1 | Network latency (2s) | MySQL | Injected delay | Response within timeout | Responded in 2.1s | ✅ PASS |
| R2 | Dependency timeout | Payment API | Mock never responds | 504 within 10s deadline | 504 at 10.0s | ✅ PASS |
| R3 | Connection refused | Redis | Mock ECONNREFUSED | Graceful 503, no crash | 503 returned | ✅ PASS |
| R4 | High concurrency (100 req) | POST /api/users | Parallel load | No race condition, P99 < 200ms | 0 conflicts, P99=45ms | ✅ PASS |
| R5 | Large payload (10MB) | POST /api/upload | Oversized body | 413 rejection | 413 returned | ✅ PASS |
| R6 | Circuit breaker trip | Payment API | 5 consecutive failures | Subsequent calls fast-fail | (High only) Tripped at 5th | ✅ PASS |

## 5. Summary

- **Total Scenarios**: N tested, N passed, N failed, N skipped
- **Code Coverage**: [percentage]% (Gate: >= 90%)
- **Functional Coverage**: [percentage] of interfaces have full scenario coverage
- **Resilience Coverage**: [list of fault types tested]
- **Performance**: P99 Latency = [X]ms (Target: < 200ms)
- **Known Limitations**: [what was NOT tested and why — e.g. "SMS sending skipped: requires production credentials"]
- **Recommendations**: [any issues found that need attention before deployment]
```

### G.3 Docker Orchestration
Check for `docker-compose.yml` → offer to `docker compose up -d` → test → `docker compose down`.

### G.4 Release Notes (`06-release-notes.md`)
Include: env requirements, config changes, DB migrations, deployment steps, efficiency bill.

### G.5 Efficiency Bill
Append ROI metrics to `docs/omnidev-state/metrics.json`.

### G.6 Archive & Cleanup
When user confirms release notes, present:
```
🎉 需求开发和验证已全部完成！
请选择：
  1. 📝 生成 Git Commit Message (`/od y`)
  2. 📤 直接提交并推送 (`/od ps`)
  3. ⏸ 暂不操作
```
**STOP — WAIT**.

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
2. Present options:
   ```
   请选择下一步操作：
     1. ✅ 确认应用变更 (`/od y`)
     2. ❌ 取消变更 (`/od x`)
   ```
   **STOP — WAIT.**
3. After `1` or `/od y`: archive old plan, regenerate blueprint/plan.

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
2. Present options:
   ```
   📋 以下文件已修改但未暂存：[list]
   请在终端执行 `git add`，完成后选择：
     1. ✅ 已手动选择文件 — 继续提交
     2. 📦 全部提交 — 自动执行 `git add .`
     3. ❌ 取消 (`/od x`)
   ```
   **STOP — WAIT.**
3. After `1` or `2`: analyze diff, generate commit message, present:
   ```
   📝 提交信息: `[message]`
   请选择：
     1. ✅ 确认提交并推送 (`/od y`)
     2. ✏ 修改提交信息 (`/od em [新信息]`)
     3. ❌ 取消 (`/od x`)
   ```
   **STOP — WAIT.**
4. After `1` or `/od y`: `git commit` + `git push origin <current-branch>`. Report result.

### Update (`/od up`)
1. **Confirm**: Stop and warn the user:
   ```
   ⚠️ 更新警告：从远程仓库更新将直接覆盖本地同名的 `.cursor/rules/` 和 `SKILL.md` 文件，
   并删除远程已不存在的本地文件。未推送的本地自定义将丢失。
   请选择：
     1. ✅ 确认更新 (`/od y`)
     2. ❌ 取消 (`/od x`)
   ```
   **🛑 STOP — WAIT. DO NOT proceed automatically.**
2. **Fetch & Overwrite**: Only after `1` or `/od y`, clone `https://github.com/zy-eagle/omnidev-kit.git` to a temp dir, then:
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
    - config files for DB/cache/MQ connection strings (*.yaml, *.yml, *.env*, *.toml, *.properties)
    - source code for database driver imports, HTTP client instantiations, SDK initializations
    - docker-compose.yml, Dockerfile  # infrastructure dependencies
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
3. **Dependency Topology Scan** — systematically discover all runtime dependencies:

   **3a. Storage Dependencies** — scan for:
   - **Database**: look for driver imports (`gorm`, `sqlx`, `pg`, `mysql2`, `mongoose`, `prisma`, `typeorm`, `sequelize`, `diesel`, `sqlalchemy`, etc.) and connection strings in config files.
   - **Cache**: look for Redis/Memcached client imports (`go-redis`, `ioredis`, `redis-py`, `jedis`, etc.).
   - **Message Queue**: look for Kafka/RabbitMQ/NATS/Pulsar client imports and broker URLs.
   - **Search Engine**: look for Elasticsearch/OpenSearch/Meilisearch client imports.
   - **Object Storage**: look for S3/OSS/MinIO SDK imports and bucket configurations.
   - **File I/O**: look for significant local file read/write operations beyond logging.

   **3b. Third-Party Service Dependencies** — scan for:
   - **External HTTP APIs**: look for `http.Client`, `axios`, `fetch`, `requests`, `reqwest` calls with external base URLs (not localhost/internal).
   - **gRPC Services**: look for `.proto` files, generated client stubs, gRPC dial targets.
   - **Internal Microservices**: look for service discovery configs, internal base URLs, RPC client registrations.
   - **SDK Integrations**: look for cloud provider SDKs (AWS, GCP, Azure, Alibaba Cloud), payment SDKs, monitoring SDKs (Prometheus, Datadog, Sentry), auth SDKs (OAuth, OIDC).

   **3c. Record each dependency** with:
   - `name`: human-readable identifier (e.g. "MySQL user_db", "Redis session_cache", "Payment Gateway")
   - `type`: `database` | `cache` | `message_queue` | `search` | `object_storage` | `file_io` | `http_api` | `grpc` | `microservice` | `sdk`
   - `category`: `storage` | `third_party` | `internal_service`
   - `config_source`: where the connection is configured (e.g. `config/database.yml`, `.env`, `docker-compose.yml`)
   - `code_locations`: key files where this dependency is used (e.g. `internal/repo/user.go`, `src/services/payment.ts`)

4. **Stability Level Detection** — check if the user has stated stability requirements:
   - If user mentioned keywords like "高可用", "高稳定性", "production-critical", "high availability", "zero downtime" → set `stability_level: high`
   - Otherwise → set `stability_level: standard`
   - This field is read by Phase 3 (§3.1) to determine resilience coding depth.

5. Extract architecture, conventions, code style.
6. Output to `docs/omnidev-state/00-project-context.md`, mark `project_type: legacy` or `greenfield`. Include:
   - **## Stack & Layers** section with the fields from step 2.
   - **## Dependency Topology** section with a table of all discovered dependencies from step 3.
   - **## Stability Level** section recording the stability classification from step 4.

   Example `## Dependency Topology` section:
   ```markdown
   ## Dependency Topology

   | Name | Type | Category | Config Source | Code Locations |
   |------|------|----------|--------------|----------------|
   | MySQL (user_db) | database | storage | `config/database.yml` | `internal/repo/user.go`, `internal/repo/order.go` |
   | Redis (session) | cache | storage | `.env` → `REDIS_URL` | `internal/middleware/session.go` |
   | Kafka (events) | message_queue | storage | `config/kafka.yml` | `internal/event/producer.go`, `internal/event/consumer.go` |
   | Payment Gateway | http_api | third_party | `.env` → `PAYMENT_API_URL` | `internal/service/payment.go` |
   | Auth Service | grpc | internal_service | `config/services.yml` | `internal/client/auth.go` |
   | Sentry SDK | sdk | third_party | `.env` → `SENTRY_DSN` | `cmd/server/main.go` |
   ```

### Learn (`/od ln`)

Unified self-learning command: combines error retrospective + evolution proposals into a single flow.

```yaml
context_requires:
  read:
    - 00-project-context.md          # project conventions, pitfall guide
    - evolution-log.jsonl            # all signals to cluster and propose from
    - evolution-history.md           # past evolutions for dedup
  scan:
    - 03-progress.md, archive/*      # errors and user corrections
    - .cursor/rules/*.mdc            # current rules — needed to draft amendments
    - skills/od/SKILL.md             # current skill — needed for workflow tweaks
  skip:
    - branch-specific state files other than 03-progress.md
```

**Flow**:

1. **Retrospective** — Scan progress docs/archives for errors, user corrections, and repeated patterns.
2. **Extract Pitfalls** — Write lessons to `[AI Pitfall Guide]` in `00-project-context.md`.
3. **Log Signals** — Each extracted pitfall is logged as an `error_resolution` signal in `docs/omnidev-state/evolution-log.jsonl`.
4. **Cluster & Propose** — Read `evolution-log.jsonl`, cluster by `category`, dedupe against `evolution-history.md`, generate proposals (see §L for full spec).
5. **Present Proposals** (if any exist):
   ```
   🧬 OmniDev 学习提案（基于 N 条学习信号）

   提案 1: [description]
   提案 2: [description]
   ...

   请选择：
     1. ✅ 全部接受 (`/od ln y`)
     2. 🔢 接受指定编号 (`/od ln y 1,3`)
     3. ❌ 全部拒绝 (`/od ln x`)
     4. ✏ 调整某条提案 (`/od ln ad [N] [反馈]`)
   ```
   **STOP — WAIT.**
6. **Apply** — After user confirmation, patch files, mark signals `processed`, append `evolution-history.md`.

**Sub-commands**:
- `/od ln` — Full flow: retrospective + proposals
- `/od ln -r` — Review only: show log and pending proposals without applying
- `/od ln -a` — Auto-apply: apply all pending proposals without review
- `/od ln --rb [N]` — Rollback: revert evolution #N

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

### Security (AgentShield & DevSecOps)
- **OWASP Top 10**: Always code defensively against common vulnerabilities (Injection, Broken Auth, Sensitive Data Exposure, Broken Access Control).
- **SAST First**: Proactively run static analysis tools (e.g., `gosec`, `bandit`, `npm audit`) before committing code.
- Verify third-party packages are mainstream before introducing.
- Never print tokens/passwords/DSNs in plain text — use `REDACTED`.

### Performance
- Precise reading: `Grep`/`SemanticSearch`/`offset+limit`.
- Minimal editing: `StrReplace` over full file rewrites.

### Resilience Patterns by Framework

When Phase 3 §3.1 requires resilience coding, use these framework-specific implementations:

- **Go/Gin/GORM**:
  - DI required; check `err`; business logic in Service, not Handler.
  - Timeout: `context.WithTimeout` on every outbound call; propagate context through the call chain.
  - Circuit breaker: `sony/gobreaker` or `afex/hystrix-go`.
  - Structured errors: define a project-level `AppError` struct with `Code`, `Message`, `HTTPStatus`; use middleware to serialize consistently.
  - Connection pools: configure `SetMaxOpenConns`, `SetMaxIdleConns`, `SetConnMaxLifetime` on `*sql.DB`.
  - Graceful shutdown: `signal.NotifyContext` + `server.Shutdown(ctx)`.

- **Node.js/Express/NestJS**:
  - Timeout: `AbortController` with `setTimeout` for fetch; `axios.defaults.timeout`; NestJS interceptors.
  - Circuit breaker: `opossum` (standalone) or `@nestjs/terminus` + custom health indicators.
  - Structured errors: global error-handling middleware that catches all exceptions and returns `{code, message, details}`.
  - Connection pools: configure pool size in DB driver options (e.g. `pg` pool, `mongoose` poolSize).
  - Graceful shutdown: handle `SIGTERM`/`SIGINT`; drain connections before exit.

- **Python/FastAPI/Django**:
  - Timeout: `httpx` with `timeout` parameter; `asyncio.wait_for` for async calls.
  - Circuit breaker: `pybreaker` or `tenacity` with retry + circuit breaker pattern.
  - Structured errors: custom exception handlers that return consistent JSON error responses.
  - Connection pools: SQLAlchemy `pool_size`/`max_overflow`; Django `CONN_MAX_AGE`.

- **Java/Spring Boot**:
  - Timeout: `RestTemplate`/`WebClient` with `connectTimeout`/`readTimeout`; `@Transactional(timeout=)`.
  - Circuit breaker: Spring Cloud Circuit Breaker with Resilience4j; `@CircuitBreaker`, `@Retry`, `@Bulkhead` annotations.
  - Structured errors: `@ControllerAdvice` + `@ExceptionHandler` returning `ResponseEntity<ErrorResponse>`.
  - Connection pools: HikariCP `maximumPoolSize`, `connectionTimeout`, `idleTimeout`.

- **React/Next.js** (frontend):
  - Strict mode; prefer Server Components; minimize re-renders.
  - API call timeout: `AbortController` with `signal` on fetch; show loading/error states.
  - Retry: `react-query` / `swr` with built-in retry and stale-while-revalidate.
  - Error boundaries: wrap route segments with `ErrorBoundary` components for graceful UI degradation.

---

## L. Self-Learning & Evolution Engine (Full Specification)

**Activation scope**: Everything in this section runs **only** on `/od`-prefixed turns (same as the rest of this skill). Do **not** append to `evolution-log.jsonl`, run evolution proposals, or treat corrections in plain chat as OmniDev signals.

OmniDev is not a static rule set — it is a **living system** that continuously improves itself based on real-world usage. The self-learning engine observes, learns, and proposes rule/skill refinements when `/od` is active. All learning and evolution are unified under the **`/od ln`** command.

### L.1 Learning Data Sources

The AI collects learning signals from **four channels** (only while executing `/od` workflow or `/od` commands):

#### L.1.1 User Corrections (Implicit Feedback)
During `/od`-driven work, when the user corrects the AI's output (e.g., "不要这样做", "改成 XXX", manual edits after AI generation):

1. Detect the correction pattern.
2. Classify: **style preference** / **technical convention** / **workflow friction** / **wrong assumption**.
3. Record in `docs/omnidev-state/evolution-log.jsonl` (append-only).

#### L.1.2 Repeated Patterns (Behavioral Mining)
If, **within `/od` sessions**, the AI performs the **same manual adjustment 3+ times** across turns, flag as **learning candidate**.

#### L.1.3 Error & Retry Signals
During `/od` execution, when errors occur (tests, lint, build) and a different approach succeeds, record **anti-pattern → resolution**.

#### L.1.4 Explicit Feedback (`/od ln`)
- `/od ln` — Full flow: retrospective + cluster signals + propose rule updates.
- `/od ln [feedback]` — User gives direct feedback to learn from.
- `/od ln -r` — Show log and pending proposals without applying.
- `/od ln -a` — Apply all pending proposals without interactive review.

### L.2 Learning Log Format

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

### L.3 Learning Triggers

Propose learning evolution when **any**:

| Trigger | Condition |
|---------|-----------|
| **Accumulation** | 5+ same `category` in `evolution-log.jsonl` |
| **High Confidence** | Any signal with `confidence >= 0.95` |
| **Phase 4** | End of Phase 4: mini learning review |
| **Explicit** | User types `/od ln` |
| **`/od re`** | After state restore, if unprocessed high-confidence signals exist, mention `/od ln` |

### L.4 Learning Actions

**Step 1 — Retrospective**: Scan progress docs, archives, and session history for errors, corrections, and patterns.

**Step 2 — Extract Pitfalls**: Write lessons to `[AI Pitfall Guide]` in `00-project-context.md`. Log each as `error_resolution` in `evolution-log.jsonl`.

**Step 3 — Aggregate**: Read `evolution-log.jsonl`, cluster by `category`, dedupe against `evolution-history.md`, rank by confidence.

**Step 4 — Proposals** (examples):

| Proposal Type | Target | Example |
|---------------|--------|---------|
| **Rule Amendment** | `.cursor/rules/*.mdc` | Path joining convention |
| **Pitfall Guide** | `00-project-context.md` [AI Pitfall Guide] | GORM migrate before seed |
| **New Skill** | `.cursor/skills/` | DB migration skill |
| **Workflow Tweak** | `SKILL.md` / project rules | Default skip blueprint for S |
| **Context Convention** | `00-project-context.md` | Quotes, tabs, trailing commas |

**Step 5 — Present** (then **STOP — WAIT**):

```
🧬 OmniDev 学习提案（基于 N 条学习信号）

提案 1: [description]
提案 2: [description]
...

请选择：
  1. ✅ 全部接受 (`/od ln y`)
  2. 🔢 接受指定编号 (`/od ln y 1,3`)
  3. ❌ 全部拒绝 (`/od ln x`)
  4. ✏ 调整某条提案 (`/od ln ad [N] [反馈]`)
```

**Step 6 — Apply** (after user confirmation): Patch files; mark signals `processed` in JSONL; append `docs/omnidev-state/evolution-history.md`; confirm success.

### L.5 Passive Learning (Silent, `/od` Only)

| Adaptation | Action | No approval |
|------------|--------|-------------|
| **Pitfall Guide** | Append to `[AI Pitfall Guide]` | Yes |
| **Metrics** | Update `metrics.json` | Yes |
| **Signal Logging** | Append JSONL | Yes |

Rule/skill/workflow changes **always** need explicit user approval via `/od ln` flow.

### L.6 Safety Guardrails

- **Never** remove/weaken: `/od` prefix requirement, checkpoints, security guardrails, or this section's safety rules.
- **Rollback**: `/od ln --rb [N]` using git history + `evolution-history.md`.
- **Confidence**: `< 0.5` never proposed; `0.5–0.8` needs 3+ occurrences; `>= 0.8` can propose after 1.

### L.7 Integration

- **`/od ln`**: Unified entry point — retrospective + pitfall extraction + evolution proposals.
- **Phase 4**: If unprocessed signals, remind: "🧬 发现 N 条学习信号。使用 `/od ln` 查看提案。"
- **`/od re`**: If log has pending high-confidence signals, mention `/od ln`.
