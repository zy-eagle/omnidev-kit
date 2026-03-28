# OmniDev Kit

[English](README.md)

OmniDev Kit 是一个集成了多个顶尖开源 AI 编码框架（如 `obra/superpowers`、`OpenSpec`、`planning-with-files`、`everything-claude-code`）核心精华的 AI 助手增强工具包。

它将 AI 从一个“只会按指令敲代码的打字员”，升级为一个**“懂成本控制、会做架构设计、能自己写测试、且永远不会忘事的高级研发工程师”**。

## 核心特色

### 1. 极简的交互体验 (One-Command Trigger)
- **一键安装与无损融合**：只需将 `INSTALL.md` 丢给 AI，AI 即可自动识别平台（Cursor/Claude Code 等）并与现有的 `.cursorrules` 无损融合。
- **短指令与多角色唤醒**：支持 `/od` 瞬间唤醒标准工作流，支持 `/od --fast`（跳过蓝图直接开发）、`/od <Issue-URL>`（直接解析需求链接）、`/od review`（化身架构师进行 Code Review）。

### 2. 智能自适应调度 (Token & Cost Optimization)
- **动态复杂度评估 (T-Shirt Sizing)**：AI 拿到需求后会先评估复杂度 (S/M/L)。
- **拒绝教条主义**：如果是改个拼写错误（S级），AI 会直接改完测试；如果是大型新功能（L级），则严格走完“蓝图->计划->开发->测试”全流程。

### 3. 谋定而后动的工程纪律 (Spec-Driven)
- **强制脑暴与蓝图**：禁止 AI 听到需求就直接写代码。必须先思考边界、异常和用户体验，输出全局蓝图。
- **自动快照防错 (Auto-Checkpointing)**：在开始修改代码前，强制 AI 执行 Git Commit 备份，改乱了随时 `/rollback`。

### 4. 强大的跨会话记忆 (State Persistence)
- **双态存储 (Dual-State Storage)**：采用 `YAML Frontmatter + Markdown` 格式记录状态，确保机器读取 100% 精准，人类阅读依旧友好。
- **记忆压缩 (Context Pruning)**：当长会话导致状态文件过长时，自动触发“记忆压缩”，将历史细节归档，防止 AI 产生幻觉和浪费 Token。
- **断点续传与协同**：只需输入 `/resume`，AI 就能读取进度文件并对比本地 Git 状态，瞬间恢复上下文继续工作。

### 5. 闭环的质量保证 (Automated Verification via MCP)
- **拒绝“盲目自信”**：强制要求 AI 编写测试用例或通过 MCP 模拟真实数据流（如向数据库插数据、调用 Playwright 进行 UI 点击）进行验证。
- **安全护栏 (Security Guardrails)**：严格禁止在状态文件或生成的代码中硬编码真实的 API Key 或敏感信息。

### 6. 运维友好的交付物 (DevOps Ready)
- **自动生成发布清单**：功能开发完毕后，自动总结 `.env` 变更、新增依赖、数据库迁移脚本等。
- **效能账单 (Efficiency Bill)**：在交付时输出直观的 ROI 账单（如“本次为您节省了 15,000 Tokens 和 2.5 小时”），让 AI 的价值清晰可见。

## 目录结构

```text
omnidev-kit/
├── INSTALL.md                      # 安装与使用指南（请将此文件交给 AI）
├── README.md                       # 英文说明文件
├── README.zh-CN.md                 # 本说明文件
└── rules/                          # 核心规则库
    ├── 01-omnidev-workflow.mdc     # 核心工作流（含复杂度评估、指令参数化、自动快照）
    ├── 02-omnidev-state-sync.mdc   # 状态持久化（双态存储与断点续传）
    ├── 03-omnidev-test-deploy.mdc  # 测试验证（含安全护栏与效能账单）
    ├── 04-omnidev-skills-mcp.mdc   # 预置开源 Skills 与 MCP 协同规范
    └── 05-omnidev-context-management.mdc # 上下文膨胀与遗忘管理（记忆压缩）
```

## 快速开始

将 `INSTALL.md` 文件拖入你的 AI 助手（Cursor / Claude Code 等）对话框中，并说：“请帮我安装这个工具包”。AI 会自动读取规则并配置到你的项目中。

之后，你可以通过输入 `/od` 或直接提出需求来体验全新的结构化 AI 编码工作流。