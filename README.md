# OmniDev Kit

[中文](README.zh-CN.md)

OmniDev Kit is an advanced AI coding assistant enhancement toolkit that integrates the core essence of top open-source AI frameworks (such as `obra/superpowers`, `OpenSpec`, `planning-with-files`, and `everything-claude-code`).

It upgrades the AI from a "typist who only writes code on command" to a **"senior R&D engineer who understands cost control, architecture design, writes their own tests, and never forgets."**

## Core Features

### 1. Minimalist Interaction (One-Command Trigger)
- **One-Click Install & Non-Destructive Merge**: Just feed `INSTALL.md` to the AI, and it will automatically recognize the platform (Cursor/Claude Code, etc.) and merge the rules with your existing `.cursorrules` seamlessly.
- **Short Commands & Multi-Persona**: Instantly wake up the standard workflow with `/od`. Supports `/od --fast` (skip blueprint, code directly), `/od change` (mid-stream requirement changes), `/od <Issue-URL>` (parse requirements from links), and `/od review` (act as an architect for Code Review).
- **Built-in Help**: Type `/od help` at any time to view all available commands and their meanings.

### 2. Legacy Project Onboarding
- **Autonomous Learning**: With the `/od onboard` command, the AI actively scans the current legacy project's directory structure, dependencies, and configuration files to extract architectural patterns (e.g., DDD, MVC) and coding conventions.
- **Preventing Architectural Decay**: The learned context is solidified into `00-project-context.md`. When adding new features later, the AI is constrained to follow these historical conventions, ensuring 100% consistency between old and new code.

### 3. Adaptive Scheduling (Token & Cost Optimization)
- **Dynamic Complexity Assessment (T-Shirt Sizing)**: The AI evaluates the complexity (S/M/L) upon receiving a requirement.
- **No Dogmatism**: For a typo (Size S), the AI fixes and tests it directly; for a large new feature (Size L), it strictly follows the "Blueprint -> Plan -> Develop -> Test" full lifecycle.

### 4. Spec-Driven Engineering Discipline
- **Forced Brainstorming & Blueprinting**: Prohibits the AI from writing code immediately. It must first consider edge cases, exceptions, and user experience, outputting a global blueprint.
- **Change Management**: Supports adding or modifying requirements mid-development. The AI will output an impact assessment document first, and upon confirmation, automatically archive the old plan and generate a new blueprint to prevent architectural decay.
- **Auto-Checkpointing**: Before modifying code, the AI is forced to execute a Git Commit backup. If things get messy, you can `/rollback` at any time.

### 5. Powerful Cross-Session Memory (State Persistence)
- **Dual-State Storage**: Uses `YAML Frontmatter + Markdown` to record state, ensuring 100% accurate machine reading while remaining human-readable.
- **Context Pruning**: When long sessions cause state files to bloat, it automatically triggers "memory compression" to archive historical details, preventing AI hallucinations and saving Tokens.
- **Session Recovery**: Just type `/resume`, and the AI will read the progress file, compare it with the local Git state, and instantly restore context to continue working.

### 6. Closed-Loop Quality Assurance (Automated Verification)
- **No "Blind Confidence"**: Forces the AI to write test cases or use MCP to simulate real data flows (e.g., inserting data into DB, calling Playwright for UI clicks) for verification.
- **Security Guardrails**: Strictly prohibits hardcoding real API keys or sensitive information in state files or generated code.

### 7. DevOps-Ready Deliverables
- **Automated Release Notes**: After development, it automatically summarizes `.env` changes, new dependencies, database migration scripts, etc.
- **Efficiency Bill (ROI)**: Outputs an intuitive ROI bill upon delivery (e.g., "Saved you 15,000 Tokens and 2.5 hours"), making the AI's value clearly visible.

## Command Reference

| Command | Description |
| --- | --- |
| `/od help` | 📖 View all available commands |
| `/od onboard` | 🔍 Scan and learn the architecture & conventions of the current legacy project |
| `/od [requirement]` | 🚀 Start standard workflow (auto-assesses complexity) |
| `/od --fast [req]` | ⚡ Skip blueprint and plan, code directly (for urgent bug fixes) |
| `/od --plan-only [req]`| 📝 Only analyze and plan, do not write code |
| `/od change [new req]`| 🔄 Add/modify requirements mid-stream, auto-assess impact and rebuild blueprint |
| `/od <Issue-URL>` | 🔗 Parse GitHub/Jira links and convert to a requirement blueprint |
| `/od review` | 🧐 Act as an architect, only perform Code Review |
| `/od qa` | 🧪 Act as a QA engineer, only write and execute test cases |
| `/resume` | 🔄 Restore the context of the last interrupted session |

## Directory Structure

```text
omnidev-kit/
├── INSTALL.md                      # Installation guide (Feed this to AI)
├── README.md                       # This file
├── README.zh-CN.md                 # Chinese documentation
└── rules/                          # Core Rules
    ├── 01-omnidev-workflow.mdc     # Core workflow (Complexity, Changes, Onboarding)
    ├── 02-omnidev-state-sync.mdc   # State persistence (Dual-state, Recovery)
    ├── 03-omnidev-test-deploy.mdc  # Testing & Deployment (Security, ROI Bill)
    ├── 04-omnidev-skills-mcp.mdc   # Pre-configured Skills & MCP norms
    └── 05-omnidev-context-management.mdc # Context Pruning & Memory Compression
```

## Quick Start

Drag the `INSTALL.md` file into your AI assistant's chat (Cursor / Claude Code, etc.) and say: "Please help me install this toolkit." The AI will automatically read the rules and configure them in your project.

Afterward, you can experience the brand-new structured AI coding workflow by typing `/od` or directly stating your requirements.