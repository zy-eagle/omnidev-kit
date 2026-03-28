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

| Command | Action |
|---------|--------|
| `/od [requirement]` | Guided workflow: assess complexity -> recommend phases -> user can skip any |
| `/od --fast [requirement]` | Skip blueprint/plan, develop directly (hotfixes) |
| `/od --plan-only [requirement]` | Output blueprint and plan only, no coding |
| `/od help` | Show all OmniDev commands |
| `/od onboard` | Scan legacy project, generate context document |
| `/od report` | Generate enterprise-grade weekly status report |
| `/od review` | Code review only (no modifications) |
| `/od qa` | Write and execute test cases |
| `/od change [new requirement]` | Handle mid-stream requirement changes |
| `/od learn` | Self-learning from recent errors |
| `/od update` | Update OmniDev Kit rules to latest version |
| `/od push` | Commit and push code to remote (user must `git add` first) |
| `/od stash` | 暂存当前任务上下文（应对紧急插队任务） |
| `/od pop` | 恢复暂存的任务上下文 |
| `/od sync` | 将产出同步回显到 Jira/GitHub Issue |
| `/od dashboard` | 生成全局效能 ROI 大盘图表 |

## Critical Rule: `/od` Prefix Mandatory & Strict Tool Execution

**ALL interactions with OmniDev MUST start with `/od`** — this includes triggering commands, confirmations, adjustments, phase navigation, and ad-hoc requests. Without `/od`, the message is treated as normal conversation and OmniDev takes NO action.

**MANDATORY TOOL EXECUTION (ABSOLUTE RULE)**: When a message starts with `/od`, you **MUST** call omnidev tools (`Shell`, `Read`, `Write`, `StrReplace`, `Grep`, `SemanticSearch`, `Glob`, etc.) to execute the request. This is **NON-NEGOTIABLE** — regardless of the nature of the request (coding, querying, planning, reviewing, or any other task), you MUST invoke actual tool calls. **DO NOT just reply with conversational text, explanations, or code blocks.** You are an **execution engine**, not a chatbot. If the user provides an ad-hoc request like `/od 这里给一个复制的按钮`, you MUST use tools to read the relevant files, make the code changes using `StrReplace` or `Write`, and then report the result. **Never just output the code block in chat without applying it via tools.**

**ZERO TEXT BEFORE TOOLS (STRICT)**: Your **very first action** in response to any `/od` message MUST be a tool call. Do NOT output any analysis, reasoning, explanation, or plan text before the first tool call. No "Let me check...", no "I need to...", no "The issue is...". Tool call FIRST, explanation AFTER. The user sees your thinking text in the UI — keep it invisible by going straight to tool execution.

**IMAGE ATTACHMENTS**: When the user's `/od` message includes screenshots or images, the same rules apply — tool calls FIRST. Read/analyze the image as needed, but do NOT output any text before invoking tools. If the image provides context for a code change, immediately use tools (`Read`, `Grep`, `Glob`, etc.) to locate the relevant code, then apply changes. **NEVER let image processing become an excuse to skip tool execution or output analysis text first.**

## Key Behaviors

- **Guided, not forced**: The workflow is a recommendation. Phase order is fixed (forward only), but any phase can be skipped. The AI guides the user through phases, never blocks them.
- **Proactive phase navigation**: After each phase completes, the AI MUST proactively output a progress summary showing completed/current/upcoming phases, and tell the user what the next step will do — do NOT wait for the user to ask.
- **Mid-phase adjustments**: At every checkpoint, the user can `/od 调整`, `/od 跳过`, `/od 回到`, etc.

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
