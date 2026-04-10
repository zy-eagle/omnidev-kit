# OmniDev Kit

[中文](README.zh-CN.md)

OmniDev Kit is an advanced AI coding assistant enhancement toolkit that integrates the core essence of top open-source AI frameworks.

It upgrades the AI from a "typist who only writes code on command" to a **"senior R&D engineer who understands cost control, architecture design, writes their own tests, and never forgets."**

## Core Features

### 1. Project Type Awareness & Adaptive Constraints
- **Smart Memory & Differentiation**: During initialization, the AI determines whether the current project is a "Greenfield Project" or a "Legacy Project" and permanently remembers this state in `00-project-context.md`.
- **Legacy Projects (Baseline First)**: When facing an old project, the AI acts like a **"sensible veteran employee"**, 100% following the historical directory structure, naming conventions, and existing utilities. **It is strictly prohibited** from forcing modern OmniDev conventions (like DDD or specific test frameworks) into old projects, preventing code style fragmentation.
- **Greenfield Projects (Spec-Driven)**: For new projects, the AI transforms into a "strict architect", fully enabling OmniDev's modern software engineering conventions, mandating TDD/DDD and high-coverage testing.

### 2. Minimalist Interaction (One-Command Trigger)
- **One-Click Install & Non-Destructive Merge**: Just feed `INSTALL.md` to the AI, and it will automatically recognize the platform and merge the rules with your existing `.cursorrules` seamlessly. You can also install directly from a remote Git URL — no need to clone the repository first.
- **Short Commands & Multi-Persona**: Instantly wake up the standard workflow with `/od`. Supports `/od --fast` (skip blueprint, code directly), `/od change` (mid-stream requirement changes), and `/od review` (act as an architect for Code Review).
- **Built-in Help**: Type `/od help` at any time to view all available commands and their meanings.

### 3. Legacy Project Onboarding
- **Autonomous Learning**: With the `/od onboard` command, the AI actively scans the legacy project's directory structure, dependencies, and configuration files to extract architectural patterns and coding conventions, solidifying them into a context guide.

### 4. Self-Learning & Retrospective
- **AI Pitfall Guide**: Triggered by the `/od learn` command or automatically after a large task, the AI scans development logs for errors, blockers, and user corrections. It extracts lessons learned and solidifies them into its own "Pitfall Guide". **"The AI will never fall into the same trap twice."**

### 5. Adaptive Scheduling (Token & Cost Optimization)
- **Dynamic Complexity Assessment (T-Shirt Sizing)**: The AI evaluates the complexity (S/M/L) upon receiving a requirement.
- **No Dogmatism**: For a typo (Size S), the AI fixes and tests it directly; for a large new feature (Size L), it strictly follows the "Blueprint -> Plan -> Develop -> Test" full lifecycle.

### 6. Spec-Driven Engineering Discipline
- **Forced Brainstorming & Blueprinting**: Prohibits the AI from writing code immediately. It must first consider edge cases, exceptions, and user experience, outputting a global blueprint.
- **Change Management**: Supports adding or modifying requirements mid-development. The AI will output an impact assessment document first, and upon confirmation, automatically archive the old plan and generate a new blueprint to prevent architectural decay.
- **Auto-Checkpointing**: Before modifying code, the AI is forced to execute a Git Commit backup. If things get messy, you can use `git reset --hard` or your IDE's version control to rollback.

### 7. Powerful Cross-Session Memory (State Persistence)
- **Dual-State Storage**: Uses `YAML Frontmatter + Markdown` to record state, ensuring 100% accurate machine reading while remaining human-readable.
- **Context Pruning**: When long sessions cause state files to bloat, it automatically triggers "memory compression" to archive historical details, preventing AI hallucinations and saving Tokens.
- **Session Recovery**: Type **`/od resume`** so OmniDev rules apply; the AI reads progress files, compares with Git, and restores context. (Bare `/resume` does not load this toolkit's rules.)

### 8. Closed-Loop Quality Assurance (Automated Verification)
- **No "Blind Confidence"**: Forces the AI to write test cases or use MCP to simulate real data flows (e.g., inserting data into DB, calling Playwright for UI clicks) for verification.
- **Security Guardrails**: Strictly prohibits hardcoding real API keys or sensitive information in state files or generated code.

### 9. DevOps-Ready Deliverables
- **Automated Release Notes**: After development, it automatically summarizes `.env` changes, new dependencies, database migration scripts, etc.
- **Efficiency Bill (ROI)**: Outputs an intuitive ROI bill upon delivery (e.g., "Saved you 15,000 Tokens and 2.5 hours"), making the AI's value clearly visible.

### 10. Enterprise-Grade Reporting & Manual Updates
- **One-Click Weekly Reports**: Using `/od report`, the AI combines Git commit history with state files to automatically generate a beautifully formatted, **management-ready project status report**. The report not only covers overall progress, blockers, and next week's plan, but also **specifically aggregates all AI-assisted tasks completed via OmniDev**, highlighting R&D efficiency gains.
- **Tool Manual Update**: Use `/od update` to fetch the latest rules from the remote repository. Updates are never automatic — the user must explicitly trigger them. The update will overwrite same-name files and delete obsolete local files that no longer exist in the remote.

### 11. Self-Evolution Engine (Auto-Evolution)
- **Passive Learning**: During **`/od`** work only, the AI may log corrections, repeated patterns, and error resolutions to `evolution-log.jsonl` (no OmniDev logging on plain chat).
- **Smart Proposals**: When signals accumulate (5+ of the same category, or any single high-confidence signal), the AI generates concrete rule/skill improvement proposals — rule amendments, new pitfall entries, workflow tweaks, or even new skills.
- **User-Controlled**: All rule modifications require explicit user approval. Use `/od ln` to review proposals, selectively adopt or reject them. The AI never silently changes its own behavioral rules.
- **Safety Guardrails**: The evolution engine cannot weaken core safety rules (like the `/od` prefix mandate or security guardrails). Every evolution is logged with rollback capability via `/od ln --rb [N]`.
- **"The more you use it, the smarter it gets"** — OmniDev adapts to your project's unique conventions, coding style, and architectural patterns over time.

## Command Reference

All commands support **short aliases** (1-2 letters). Users can reply with **numbers** at checkpoints.

| Command | Alias | Description |
| --- | --- | --- |
| `/od h` | `/od help` | 📖 显示所有命令 |
| `/od ob` | `/od onboard` | 🔍 扫描项目，生成上下文文档 |
| `/od ln` | `/od learn` | 🧠 自学习：回顾错误 + 提炼规则 + 演化提案 |
| `/od ln -r` | — | 🔍 查看学习日志和待处理提案 |
| `/od ln --rb [N]` | — | ⏪ 回滚第 N 条演化 |
| `/od rp` | `/od report` | 📊 生成周报 |
| `/od up` | `/od update` | 🔄 更新 OmniDev Kit 到最新版本 |
| `/od i <url>` | `/od install` | 📥 从远程 Git 仓库安装 |
| `/od [需求]` | — | 🚀 引导式工作流（自动评估复杂度） |
| `/od -f [需求]` | — | ⚡ 快速模式：跳过蓝图/计划，直接开发 |
| `/od -p [需求]` | — | 📝 仅规划：只输出蓝图和计划 |
| `/od ch [新需求]` | `/od change` | 🔄 需求变更管理 |
| `/od <Issue-URL>` | — | 🔗 解析 GitHub/Jira 链接为需求蓝图 |
| `/od rv` | `/od review` | 🧐 代码审查（只读） |
| `/od qa` | — | 🧪 依赖分析 → Mock → 场景覆盖 → 韧性测试 |
| `/od ps` | `/od push` | 📤 提交并推送代码 |
| `/od st` | `/od stash` | 📦 暂存当前任务上下文 |
| `/od po` | `/od pop` | 📦 恢复暂存的任务上下文 |
| `/od sy` | `/od sync` | 🔗 同步输出到 Jira/GitHub Issue |
| `/od db` | `/od dashboard` | 📈 生成全局效率 ROI 面板 |
| `/od re` | `/od resume` | 🔄 恢复上次中断的会话 |

## Directory Structure

```text
omnidev-kit/
├── INSTALL.md                      # Installation guide (Feed this to AI)
├── README.md                       # This file
├── README.zh-CN.md                 # Chinese documentation
├── rules/                          # Lightweight trigger (alwaysApply: false)
│   └── 01-omnidev-workflow.mdc     # Trigger rule — points to SKILL.md on /od
└── skills/                         # Full specification (loaded on-demand)
    └── od/
        └── SKILL.md                # /od skill — complete OmniDev workflow spec
```

## Quick Start

**Option 1: Install from Remote URL (Recommended)**

Type the following command in your AI assistant:
> `/od install https://github.com/zy-eagle/omnidev-kit.git`

The AI will automatically clone the repository, install the rules and skills into your project, and clean up — no manual cloning required.

**Option 2: Install from Local Directory**

Drag the `INSTALL.md` file into your AI assistant's chat (Cursor / Claude Code, etc.) and say: "Please help me install this toolkit." The AI will automatically read the rules and configure them in your project.

Afterward, you can experience the brand-new structured AI coding workflow by typing `/od` or directly stating your requirements.