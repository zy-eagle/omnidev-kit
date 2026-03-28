# OmniDev Kit 安装与使用指南

> **致 AI 助手 (Cursor / Claude Code / Codex 等)**: 
> 当用户将此文档交给你时，请立即读取本目录下的所有 `.mdc` 和 `.md` 文件，并根据用户的开发平台，自动将这些规则文件复制或链接到对应的平台配置目录中（例如 Cursor 的 `.cursor/rules/` 目录，或 Claude Code 的 `.claude/skills/` 目录）。
> 
> 完成安装后，向用户报告安装成功，并提示用户可以通过输入 `/od` 或直接提出需求来启动标准工作流。

## 1. 什么是 OmniDev Kit？

OmniDev Kit 是一个集成了 `obra/superpowers`、`everything-claude-code`、`planning-with-files` 和 `OpenSpec` 核心精华的 AI 编码助手增强工具包。

它强制 AI 遵循以下工作流：
1. **需求脑暴与蓝图 (Brainstorming & Blueprint)**：先思考，挖掘潜在需求，输出全局产品形态，等待用户确认。
2. **计划与拆解 (Planning)**：拆分功能点，排定优先级，等待用户确认。
3. **规范驱动与断点续传 (SDD/TDD/DDD & State Sync)**：在 `docs/omnidev-state/` 目录下持久化状态，支持中断恢复和多人协同。
4. **自动化测试验证 (Testing & Verification)**：利用 MCP 模拟数据流，输出测试报告。
5. **发布清单 (Deployment Docs)**：自动生成上线必备的配置和环境依赖文档。

## 2. 自动安装指南 (交给 AI 执行)

AI 助手请执行以下步骤：

### 对于 Cursor 用户：
1. 检查项目根目录是否存在 `.cursor/rules/` 文件夹，如果没有则创建。
2. 将 `omnidev-kit/rules/` 目录下的所有 `.mdc` 文件复制到 `.cursor/rules/` 目录中。
3. 确保项目根目录的 `.gitignore` 中**不包含** `.cursor/rules/`（规则应被提交到版本库）。
4. 在项目根目录创建 `docs/omnidev-state/` 文件夹（用于存储状态和产出文档）。

### 对于 Claude Code / Codex 用户：
1. 检查项目根目录是否存在 `.claude/skills/` 或对应平台的技能目录。
2. 将 `omnidev-kit/rules/` 下的规则转换为对应平台的格式（如 `SKILL.md`）并保存。
3. 在项目根目录创建 `docs/omnidev-state/` 文件夹。

## 3. 手动安装指南

如果你想手动安装：
1. 将 `omnidev-kit/rules/` 里的文件复制到你的 IDE 规则目录（如 Cursor 的 `.cursor/rules/`）。
2. 在项目根目录新建文件夹 `docs/omnidev-state/`。
3. 对 AI 说：“启动 OmniDev 工作流，我要开发 [你的需求]” 或直接输入 `/od [你的需求]`。

## 4. 产出物说明

所有由本工具包驱动产生的文档（需求蓝图、开发计划、进度状态、测试报告、发布清单）都将统一存放在项目根目录的 **`docs/omnidev-state/`** 文件夹中，以避免污染代码库主目录。
