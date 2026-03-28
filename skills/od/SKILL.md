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

## Critical Rule: `/od` Prefix Mandatory

**ALL interactions with OmniDev MUST start with `/od`** — this includes triggering commands, confirmations, adjustments, and phase navigation. Without `/od`, the message is treated as normal conversation and OmniDev takes NO action.

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
