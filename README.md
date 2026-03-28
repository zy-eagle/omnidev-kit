# OmniDev Kit

[中文](README.zh-CN.md)

OmniDev Kit is an advanced AI coding assistant enhancement toolkit that integrates the core essence of top open-source AI frameworks (such as `obra/superpowers`, `OpenSpec`, `planning-with-files`, and `everything-claude-code`).

It upgrades the AI from a "typist who only writes code on command" to a **"senior R&D engineer who understands cost control, architecture design, writes their own tests, and never forgets."**

## Core Features

### 1. Minimalist Interaction (One-Command Trigger)
- **One-Click Install & Non-Destructive Merge**: Just feed `INSTALL.md` to the AI, and it will automatically recognize the platform (Cursor/Claude Code, etc.) and merge the rules with your existing `.cursorrules` seamlessly.
- **Short Commands & Multi-Persona**: Instantly wake up the standard workflow with `/od`. Supports `/od --fast` (skip blueprint, code directly), `/od <Issue-URL>` (parse requirements from links), and `/od review` (act as an architect for Code Review).

### 2. Adaptive Scheduling (Token & Cost Optimization)
- **Dynamic Complexity Assessment (T-Shirt Sizing)**: The AI evaluates the complexity (S/M/L) upon receiving a requirement.
- **No Dogmatism**: For a typo (Size S), the AI fixes and tests it directly; for a large new feature (Size L), it strictly follows the "Blueprint -> Plan -> Develop -> Test" full lifecycle.

### 3. Spec-Driven Engineering Discipline
- **Forced Brainstorming & Blueprinting**: Prohibits the AI from writing code immediately. It must first consider edge cases, exceptions, and user experience, outputting a global blueprint.
- **Auto-Checkpointing**: Before modifying code, the AI is forced to execute a Git Commit backup. If things get messy, you can `/rollback` at any time.

### 4. Powerful Cross-Session Memory (State Persistence)
- **Dual-State Storage**: Uses `YAML Frontmatter + Markdown` to record state, ensuring 100% accurate machine reading while remaining human-readable.
- **Context Pruning**: When long sessions cause state files to bloat, it automatically triggers "memory compression" to archive historical details, preventing AI hallucinations and saving Tokens.
- **Session Recovery**: Just type `/resume`, and the AI will read the progress file, compare it with the local Git state, and instantly restore context to continue working.

### 5. Closed-Loop Quality Assurance (Automated Verification)
- **No "Blind Confidence"**: Forces the AI to write test cases or use MCP to simulate real data flows (e.g., inserting data into DB, calling Playwright for UI clicks) for verification.
- **Security Guardrails**: Strictly prohibits hardcoding real API keys or sensitive information in state files or generated code.

### 6. DevOps-Ready Deliverables
- **Automated Release Notes**: After development, it automatically summarizes `.env` changes, new dependencies, database migration scripts, etc.
- **Efficiency Bill (ROI)**: Outputs an intuitive ROI bill upon delivery (e.g., "Saved you 15,000 Tokens and 2.5 hours"), making the AI's value clearly visible.

## Directory Structure

```text
omnidev-kit/
├── INSTALL.md                      # Installation guide (Feed this to AI)
├── README.md                       # This file
├── README.zh-CN.md                 # Chinese documentation
└── rules/                          # Core Rules
    ├── 01-omnidev-workflow.mdc     # Core workflow (Complexity, Commands, Checkpoints)
    ├── 02-omnidev-state-sync.mdc   # State persistence (Dual-state, Recovery)
    ├── 03-omnidev-test-deploy.mdc  # Testing & Deployment (Security, ROI Bill)
    ├── 04-omnidev-skills-mcp.mdc   # Pre-configured Skills & MCP norms
    └── 05-omnidev-context-management.mdc # Context Pruning & Memory Compression
```

## Quick Start

Drag the `INSTALL.md` file into your AI assistant's chat (Cursor / Claude Code, etc.) and say: "Please help me install this toolkit." The AI will automatically read the rules and configure them in your project.

Afterward, you can experience the brand-new structured AI coding workflow by typing `/od` or directly stating your requirements.