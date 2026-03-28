# OmniDev Kit

[English](README.md)

OmniDev Kit 是一个集成了多个顶尖开源 AI 编码框架（如 `obra/superpowers`、`OpenSpec`、`planning-with-files`、`everything-claude-code`）核心精华的 AI 助手增强工具包。

它将 AI 从一个“只会按指令敲代码的打字员”，升级为一个**“懂成本控制、会做架构设计、能自己写测试、且永远不会忘事的高级研发工程师”**。

## 核心特色

### 1. 极简的交互体验 (One-Command Trigger)
- **一键安装**：只需将 `INSTALL.md` 丢给 AI，AI 即可自动识别平台（Cursor/Claude Code 等）并完成规则配置。
- **短指令唤醒**：通过输入 `/od` 即可瞬间唤醒标准工业级工作流，无需每次输入长篇大论的 Prompt。

### 2. 智能自适应调度 (Token & Cost Optimization)
- **动态复杂度评估 (T-Shirt Sizing)**：AI 拿到需求后会先评估复杂度 (S/M/L)。
- **拒绝教条主义**：如果是改个拼写错误（S级），AI 会直接改完测试，不浪费 token 去写设计文档；如果是大型新功能（L级），则严格走完“蓝图->计划->开发->测试”全流程。

### 3. 谋定而后动的工程纪律 (Spec-Driven)
- **强制脑暴与蓝图**：禁止 AI 听到需求就直接写代码。必须先思考边界、异常和用户体验，输出全局蓝图。
- **审批式推进**：每一个核心阶段（蓝图设计、任务拆解）都设有“拦截器”，必须等待人类开发者确认后，AI 才能进入下一步，确保方向绝对正确。

### 4. 强大的跨会话记忆 (State Persistence)
- **文件系统即记忆**：将开发状态、进度、未解决的 Bug 实时写入 `docs/omnidev-state/` 目录下的 Markdown 文件中。
- **断点续传与协同**：哪怕 IDE 重启、会话中断，或者换了个人接手，只需输入 `/resume`，AI 就能读取进度文件并对比本地 Git 状态，瞬间恢复上下文继续工作。

### 5. 闭环的质量保证 (Automated Verification via MCP)
- **拒绝“盲目自信”**：代码写完不算完，强制要求 AI 编写测试用例或通过 MCP 模拟真实数据流（如向数据库插数据、调用 Playwright 进行 UI 点击）进行验证。
- **透明的测试报告**：测试完成后，必须输出包含测试范围、结果和已知边界的测试报告。

### 6. 运维友好的交付物 (DevOps Ready)
- **自动生成发布清单**：功能开发完毕后，AI 会自动总结本次需求引入的 `.env` 变更、新增的第三方依赖、数据库迁移脚本等，输出一份清晰的上线配置文档，直接抹平开发与运维的沟通鸿沟。

## 目录结构

```text
omnidev-kit/
├── INSTALL.md                      # 安装与使用指南（请将此文件交给 AI）
├── README.md                       # 英文说明文件
├── README.zh-CN.md                 # 本说明文件
└── rules/                          # 核心规则库
    ├── 01-omnidev-workflow.mdc     # 核心工作流规则 (含复杂度评估)
    ├── 02-omnidev-state-sync.mdc   # 状态持久化与断点续传规则
    ├── 03-omnidev-test-deploy.mdc  # 测试验证与发布规范
    └── 04-omnidev-skills-mcp.mdc   # 预置开源 Skills 与 MCP 协同规范
```

## 快速开始

将 `INSTALL.md` 文件拖入你的 AI 助手（Cursor / Claude Code 等）对话框中，并说：“请帮我安装这个工具包”。AI 会自动读取规则并配置到你的项目中。

之后，你可以通过输入 `/od` 或直接提出需求来体验全新的结构化 AI 编码工作流。
