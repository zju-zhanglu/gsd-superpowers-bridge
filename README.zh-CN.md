# GSD-Superpowers Bridge

将 [Superpowers](https://github.com/obra/superpowers) 的能力集成到 [GSD](https://github.com/gsd-build/get-shit-done) 工作流中，无需修改任一框架。

## 前置条件

- 已安装 GSD（`~/.claude/skills/gsd-*/SKILL.md` 存在）
- 已安装 Superpowers 插件（执行过 `/plugin install superpowers`）
- Claude Code 2.1.88+

## 安装

```bash
cd gsd-superpowers-bridge
chmod +x install.sh
./install.sh
```

## 模块

| 模块 | 触发方式 | 说明 |
|------|----------|------|
| Design Explorer | `/gsd:discuss-phase N --design` | 在讨论阶段前强制探索 2-3 种方案 |
| TDD Executor | 配置 `agent_skills.executor` | 为每个计划任务执行 RED-GREEN-REFACTOR 循环 |
| Enhanced Debug | `/gsd:debug`（启用时） | 四阶段系统化根因分析 |
| Two-Stage Review | `/gsd:verify-work N --review` | 规格符合性 + 代码质量双阶段审查 |

## 配置

在 `.planning/config.json` 中添加：

```json
{
  "agent_skills": {
    "executor": "gsd-tdd-executor"
  },
  "superpowers_bridge": {
    "design_explorer": true,
    "enhanced_debug": true,
    "two_stage_review": true
  }
}
```

## 卸载

```bash
./install.sh --uninstall
```
