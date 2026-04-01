---
name: od
description: >-
  OmniDev AI-driven development workflow. Use when the user types /od to start
  a requirement, /od help for commands, /od onboard for legacy project scanning,
  /od report for status reports, /od review for code review, /od qa for testing,
  or /od change for mid-stream requirement changes.
---

# OmniDev Workflow Skill

When the user triggers `/od`, strictly follow the OmniDev workflow defined in the project's `.cursor/rules/01-omnidev-workflow.mdc`.

## Quick Reference

All commands support English shorthand aliases. The AI MUST treat aliases as equivalent to the full command.

| Command | Alias | Action |
|---------|-------|--------|
| `/od [requirement]` | — | Guided workflow: assess complexity -> recommend phases -> user can skip any |
| `/od --fast [requirement]` | `/od -f` | Skip blueprint/plan, develop directly (hotfixes) |
| `/od --plan-only [requirement]` | `/od -p` | Output blueprint and plan only, no coding |
| `/od help` | `/od h` | Show all OmniDev commands |
| `/od onboard` | `/od ob` | Scan legacy project, generate context document |
| `/od report` | `/od rp` | Generate enterprise-grade weekly status report |
| `/od review` | `/od rv` | Code review only (no modifications) |
| `/od qa` | — | Write and execute test cases |
| `/od change [new requirement]` | `/od ch` | Handle mid-stream requirement changes |
| `/od learn` | `/od ln` | Self-learning from recent errors |
| `/od update` | `/od up` | Update OmniDev Kit rules to latest version |
| `/od install <repo-url>` | `/od i` | Install OmniDev Kit from a remote Git repo URL (no manual clone needed) |
| `/od push` | `/od ps` | Commit and push code to remote (user must `git add` first) |
| `/od stash` | `/od st` | 暂存当前任务上下文（应对紧急插队任务） |
| `/od pop` | — | 恢复暂存的任务上下文 |
| `/od sync` | `/od sy` | 将产出同步回显到 Jira/GitHub Issue |
| `/od dashboard` | `/od db` | 生成全局效能 ROI 大盘图表 |

### Phase Navigation Aliases

| Command | Alias | Action |
|---------|-------|--------|
| `/od 继续` | `/od c`, `/od next` | 进入下一阶段 |
| `/od 调整 [内容]` | `/od adj [内容]` | 修改当前阶段产出，重新执行当前阶段 |
| `/od 跳过 [阶段名]` | `/od sk [阶段名]` | 跳过后续某个阶段 |
| `/od 回到 [阶段名]` | `/od back [阶段名]` | 回退到之前的阶段重新执行 |
| `/od 全部完成` | `/od all` | 自动执行所有剩余阶段，不再逐步确认 |

## Critical Rule: `/od` Prefix Mandatory & Strict Tool Execution

**ALL interactions with OmniDev MUST start with `/od`** — this includes triggering commands, confirmations, adjustments, phase navigation, and ad-hoc requests. Without `/od`, the message is treated as normal conversation and OmniDev takes NO action.

**MANDATORY TOOL EXECUTION (ABSOLUTE RULE)**: When a message starts with `/od`, you **MUST** call omnidev tools (`Shell`, `Read`, `Write`, `StrReplace`, `Grep`, `SemanticSearch`, `Glob`, etc.) to execute the request. This is **NON-NEGOTIABLE** — regardless of the nature of the request (coding, querying, planning, reviewing, or any other task), you MUST invoke actual tool calls. **DO NOT just reply with conversational text, explanations, or code blocks.** You are an **execution engine**, not a chatbot. If the user provides an ad-hoc request like `/od 这里给一个复制的按钮`, you MUST use tools to read the relevant files, make the code changes using `StrReplace` or `Write`, and then report the result. **Never just output the code block in chat without applying it via tools.**

**ZERO TEXT BEFORE TOOLS (STRICT)**: Your **very first action** in response to any `/od` message MUST be a tool call. Do NOT output any analysis, reasoning, explanation, or plan text before the first tool call. No "Let me check...", no "I need to...", no "The issue is...". Tool call FIRST, explanation AFTER. The user sees your thinking text in the UI — keep it invisible by going straight to tool execution.

**IMAGE ATTACHMENTS**: When the user's `/od` message includes screenshots or images, the same rules apply — tool calls FIRST. Read/analyze the image as needed, but do NOT output any text before invoking tools. If the image provides context for a code change, immediately use tools (`Read`, `Grep`, `Glob`, etc.) to locate the relevant code, then apply changes. **NEVER let image processing become an excuse to skip tool execution or output analysis text first.**

## Key Behaviors

- **Guided, not forced**: The workflow is a recommendation. Phase order is fixed (forward only), but any phase can be skipped. The AI guides the user through phases, never blocks them.
- **Proactive phase navigation**: After each phase completes, the AI MUST proactively output a progress summary showing completed/current/upcoming phases, and tell the user what the next step will do — do NOT wait for the user to ask.
- **Mid-phase adjustments**: At every checkpoint, the user can `/od 调整` (`/od adj`), `/od 跳过` (`/od sk`), `/od 回到` (`/od back`), etc.

## Workflow

1. **Read the full OmniDev rules** from `.cursor/rules/01-omnidev-workflow.mdc` before proceeding.
2. **Parse the command** and identify which flow to execute.
3. **Assess complexity** (S/M/L/XL) using T-Shirt Sizing — this provides **recommended** phases, not mandatory ones.
4. **Follow the phased workflow** with checkpoints — guide the user through each phase, allow skipping at any checkpoint.
5. **Store all state documents** in `docs/omnidev-state/`.
6. **Reply in the user's language** (Chinese if they write in Chinese).

## Related Rules

All OmniDev rules are in `.cursor/rules/`:
- `01-omnidev-workflow.mdc` — Core workflow phases
- `02-omnidev-state-sync.mdc` — State persistence and session recovery
- `03-omnidev-test-deploy.mdc` — Testing and deployment
- `04-omnidev-skills-mcp.mdc` — Skills and MCP integration
- `05-omnidev-context-management.mdc` — Context pruning
