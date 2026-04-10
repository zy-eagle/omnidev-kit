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
| `/od cfg` | `/od config` | 查看当前 OmniDev 配置 |
| `/od cfg -i on` | — | 开启交互模式（决策点使用结构化选择 UI；默认开启） |
| `/od cfg -i off` | — | 关闭交互模式 |

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
- Global: `docs/omnidev-state/` (`00-project-context.md`, `metrics.json`, `config.json`)
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
- **When `interactive_mode` is `true`** (see §B.6): Replace the numbered text list with the **AskQuestion** tool (structured choice UI). The user clicks an option instead of typing a number or command. This saves a request round-trip and reduces token usage.

### B.5 Lazy Context Loading

**Principle**: Do NOT read all state files or scan the entire project upfront. Each phase and command declares exactly what context it needs (see §E Phase Context Requirements). On entering a phase:

1. **Read only the files listed** in that phase's `context_requires` block.
2. **Skip files that don't exist** — their absence is informational (e.g. no `00-project-context.md` means onboard hasn't run; trigger §C.1 stack detection instead).
3. **Cache across phases within the same session** — if a file was already read in a previous phase of the current session, reuse it unless the phase explicitly says `reload: true`.
4. **Never pre-read** downstream phase artifacts (e.g. don't read `05-test-report.md` during Phase 2).
5. **Project scanning is gated**: full codebase scans (Grep, Glob, SemanticSearch) are only permitted when the phase's context block includes `scan: [target]`. Otherwise, operate on the files already known from state files or prior phases.

This keeps token usage proportional to the current phase's actual needs, not the total project size.

### B.6 Configuration (`config.json`)

OmniDev stores user preferences in `docs/omnidev-state/config.json`. If the file does not exist, treat all settings as their defaults.

```json
{
  "interactive_mode": true
}
```

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `interactive_mode` | boolean | `true` | When `true`, use the **AskQuestion** tool to present structured choice UIs at decision points instead of numbered text prompts. Saves requests and tokens. |

#### Config Commands

- **`/od cfg`** — Read and display current `config.json` (create with defaults if missing).
- **`/od cfg -i on`** — Set `interactive_mode` to `true`.
- **`/od cfg -i off`** — Set `interactive_mode` to `false`.

### B.7 Interactive Mode

When `interactive_mode` is **`true`** (default) in `config.json`, the AI MUST use the **AskQuestion** tool (structured multiple-choice UI) at the following decision points instead of numbered text prompts:

| Decision Point | Questions Presented |
|----------------|-------------------|
| **Phase 0: Complexity Assessment** | Confirm/adjust complexity rating (S/M/L/XL); select which phases to include/skip |
| **Phase Checkpoint** (after each phase) | Choose next action: continue / adjust / skip / go back |
| **Change Management** (`/od ch`) | Confirm impact assessment: proceed / revise / cancel |
| **Push** (`/od ps`) | Confirm commit message: commit / edit message / cancel |
| **Learning Proposals** (`/od ln`) | For each proposal: adopt / reject / adjust |

When `interactive_mode` is **`false`**, use numbered text prompts as defined in §B.4. **Do not** use AskQuestion.

**On first `/od` activation in a session**: Read `docs/omnidev-state/config.json` (if it exists) to load `interactive_mode`. If the file does not exist, assume `true` (default).

---

## C. Phase Execution Protocol (Auto-Context Loading)

**MANDATORY**: Before executing ANY phase or special command, you MUST autonomously use the `Read` tool to load its specific instruction file from `.cursor/skills/od/phases/` or `.cursor/skills/od/engine/`. Do NOT wait for the user to tell you to read it.

| Target Phase/Command | File to Read Immediately |
|----------------------|--------------------------|
| Phase 0 / `/od onboard` | `.cursor/skills/od/phases/00-assessment.md` |
| Phase 1 / Phase 2 | `.cursor/skills/od/phases/01-02-planning.md` |
| Phase 3 | `.cursor/skills/od/phases/03-development.md` |
| Phase 4 / `/od qa` | `.cursor/skills/od/phases/04-testing.md` |
| `/od push`, `/od change`, `/od report`, `/od compress` | `.cursor/skills/od/engine/special-flows.md` |
| `/od learn`, `/od ln` | `.cursor/skills/od/engine/evolution.md` |

After reading the instruction file, follow its `context_requires` block to load project state files.

### C.1 Phase Exit — Checkpoint

After each phase completes, output:
```
✅ **Phase N 完成: [Phase Name]**
   产出物: [what was produced]
   已加载上下文: [list files/scans actually read]
📍 **当前进度**: 已完成: [...] ✅ | 剩余: [...] ⏳
🔜 **下一阶段: Phase N+1 — [Phase Name]**
   将加载: [list context_requires of next phase]
   将执行: [description]
```

**If `interactive_mode` is `false`**: Display the numbered list above. Accept number (`1`–`5`), alias (`/od n`), or full command (`/od next`). **STOP — WAIT for user reply**.

**If `interactive_mode` is `true`** (default): Use **AskQuestion** tool to present the same options as a structured choice UI. **STOP — WAIT for user selection**.

---

## D. Project Type Awareness
- **Legacy**: Follow existing conventions 100%. No forced DDD/TDD. "Write code like a sensible veteran employee."
- **Greenfield**: Full modern conventions — OpenSpec / TDD / DDD, high test coverage, deployment manifests.

## E. MCP Integration
During Phase 3 & 4, proactively use available MCP servers:
- **Database MCP**: Verify table structures, insert mock data, check data flow.
- **Browser MCP (Playwright)**: Start server → visit page → E2E test → screenshot/DOM verification.
- **Discovery**: Check `.cursor/mcp.json` before complex tasks. If critical MCP missing, suggest installation.