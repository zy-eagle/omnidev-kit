# OmniDev Kit

[English](README.md)

OmniDev Kit 是一个集成了多个顶尖开源 AI 编码框架核心精华的 AI 助手增强工具包。

它将 AI 从一个“只会按指令敲代码的打字员”，升级为一个**“懂成本控制、会做架构设计、能自己写测试、且永远不会忘事的高级研发工程师”**。

## 核心特色

### 1. 项目类型感知与自适应约束 (Project Type Awareness)
- **智能记忆与区分**：AI 会在初始化时判断当前是“全新项目 (Greenfield)”还是“历史项目 (Legacy)”，并将此状态永久记忆在 `00-project-context.md` 中。
- **历史项目 (基准优先)**：面对老项目，AI 会**“像一个懂事的老员工”**，100% 遵循历史目录结构、命名规范和老轮子。**绝对禁止**将 OmniDev 推荐的现代规范（如强行引入 DDD 或特定测试框架）塞入老项目，防止代码风格割裂。
- **全新项目 (规范驱动)**：面对新项目，AI 会化身“严苛的架构师”，全面启用 OmniDev 的现代软件工程规范，强制推行 TDD/DDD 和高覆盖率测试。

### 2. 极简的交互体验 (One-Command Trigger)
- **一键安装与无损融合**：只需将 `INSTALL.md` 丢给 AI，AI 即可自动识别平台（Cursor/Claude Code 等）并与现有的 `.cursorrules` 无损融合。
- **短指令与多角色唤醒**：支持 `/od` 瞬间唤醒标准工作流，支持 `/od --fast`（跳过蓝图直接开发）、`/od change`（开发中途追加/修改需求）、`/od review`（化身架构师进行 Code Review）。
- **内置帮助手册**：随时输入 `/od help` 即可查看所有可用指令及其含义。

### 3. 历史项目无缝注入 (Legacy Project Onboarding)
- **自主学习与上下文提取**：通过 `/od onboard` 指令，AI 会主动扫描当前历史项目的目录结构、依赖文件和配置文件，提取架构模式（如 MVC）和代码规范，固化为上下文指南。

### 4. 自我进化与复盘 (Self-Learning & Retrospective)
- **AI 避坑指南**：通过 `/od learn` 指令或在大型任务完成后自动触发，AI 会扫描开发日志中的报错、卡点和用户的纠正，提取经验教训并固化到自身的“避坑指南”中。**“踩过的坑，AI 绝对不会踩第二次”**。

### 5. 智能自适应调度 (Token & Cost Optimization)
- **动态复杂度评估 (T-Shirt Sizing)**：AI 拿到需求后会先评估复杂度 (S/M/L)。
- **拒绝教条主义**：如果是改个拼写错误（S级），AI 会直接改完测试；如果是大型新功能（L级），则严格走完“蓝图->计划->开发->测试”全流程。

### 6. 谋定而后动的工程纪律 (Spec-Driven)
- **强制脑暴与蓝图**：禁止 AI 听到需求就直接写代码。必须先思考边界、异常和用户体验，输出全局蓝图。
- **需求变更管理 (Change Management)**：支持开发中途追加或修改需求。AI 会先输出影响面评估文档，经确认后自动归档旧方案并生成新蓝图，确保架构不腐化。
- **自动快照防错 (Auto-Checkpointing)**：在开始修改代码前，强制 AI 执行 Git Commit 备份，改乱了随时 `/rollback`。

### 7. 强大的跨会话记忆 (State Persistence)
- **双态存储 (Dual-State Storage)**：采用 `YAML Frontmatter + Markdown` 格式记录状态，确保机器读取 100% 精准，人类阅读依旧友好。
- **记忆压缩 (Context Pruning)**：当长会话导致状态文件过长时，自动触发“记忆压缩”，将历史细节归档，防止 AI 产生幻觉和浪费 Token。
- **断点续传与协同**：只需输入 `/resume`，AI 就能读取进度文件并对比本地 Git 状态，瞬间恢复上下文继续工作。

### 8. 闭环的质量保证 (Automated Verification via MCP)
- **拒绝“盲目自信”**：强制要求 AI 编写测试用例或通过 MCP 模拟真实数据流（如向数据库插数据、调用 Playwright 进行 UI 点击）进行验证。
- **安全护栏 (Security Guardrails)**：严格禁止在状态文件或生成的代码中硬编码真实的 API Key 或敏感信息。

### 9. 运维友好的交付物 (DevOps Ready)
- **自动生成发布清单**：功能开发完毕后，自动总结 `.env` 变更、新增依赖、数据库迁移脚本等。
- **效能账单 (Efficiency Bill)**：在交付时输出直观的 ROI 账单（如“本次为您节省了 15,000 Tokens 和 2.5 小时”），让 AI 的价值清晰可见。

## 指令速查表 (Command Reference)

| 指令 | 说明 |
| --- | --- |
| `/od help` | 📖 查看所有指令帮助 |
| `/od onboard` | 🔍 扫描并学习当前历史项目的架构与规范，防止后续开发自我发散 |
| `/od learn` | 🧠 触发自我复盘，从报错和纠正中提取经验并写入避坑指南 |
| `/od [需求]` | 🚀 启动标准开发工作流（自动评估复杂度） |
| `/od --fast [需求]` | ⚡ 跳过蓝图和计划，直接写代码（适合紧急修 Bug） |
| `/od --plan-only [需求]` | 📝 只做需求分析和计划拆解，不写代码 |
| `/od change [新需求]` | 🔄 在开发中途追加或修改需求，自动评估影响面并重构蓝图 |
| `/od <Issue-URL>` | 🔗 抓取 GitHub/Jira 链接内容并转化为需求蓝图 |
| `/od review` | 🧐 化身架构师，仅对当前代码进行 Code Review |
| `/od qa` | 🧪 化身测试工程师，仅编写和执行测试用例 |
| `/resume` | 🔄 恢复上一次中断的开发上下文 |

## 目录结构

```text
omnidev-kit/
├── INSTALL.md                      # 安装与使用指南（请将此文件交给 AI）
├── README.md                       # 英文说明文件
├── README.zh-CN.md                 # 本说明文件
└── rules/                          # 核心规则库
    ├── 01-omnidev-workflow.mdc     # 核心工作流（含项目类型感知、需求变更、自我学习）
    ├── 02-omnidev-state-sync.mdc   # 状态持久化（双态存储与断点续传）
    ├── 03-omnidev-test-deploy.mdc  # 测试验证（含安全护栏与效能账单）
    ├── 04-omnidev-skills-mcp.mdc   # 预置开源 Skills 与 MCP 协同规范
    └── 05-omnidev-context-management.mdc # 上下文膨胀与遗忘管理（记忆压缩）
```

## 快速开始

将 `INSTALL.md` 文件拖入你的 AI 助手（Cursor / Claude Code 等）对话框中，并说：“请帮我安装这个工具包”。AI 会自动读取规则并配置到你的项目中。

之后，你可以通过输入 `/od` 或直接提出需求来体验全新的结构化 AI 编码工作流。