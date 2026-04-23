# GSD-Superpowers Bridge

一个 Claude Code 插件，将 [GSD](https://github.com/gsd-build/get-shit-done) 项目生命周期管理与 [Superpowers](https://github.com/obra/superpowers) 执行规范桥接在一起。

## 功能概述

GSD 擅长项目管理——规划、状态追踪、阶段生命周期。Superpowers 擅长执行质量——TDD、系统化调试、验证。本桥接插件让你同时拥有两者的优势，且无需修改任何一个插件。

## 命令

| 命令 | 说明 |
|------|------|
| `/gsd-sp-execute [N] [--no-tdd]` | 执行阶段：TDD + 调试 + 验证 + 自动审查 |
| `/gsd-sp-review [N]` | 双层代码审查（规格合规 + 代码质量） |
| `/gsd-sp-debug <描述>` | 使用科学方法进行系统化调试 |

## 前置条件

- 已安装 [GSD](https://github.com/gsd-build/get-shit-done) 并在项目中初始化
- 已规划阶段的 GSD 项目（存在 `.planning/` 目录）

## 安装

1. 在 Claude Code 中安装本插件
2. 确保 GSD 已安装且项目包含 `.planning/` 目录
3. 运行任意 `/gsd-sp-*` 命令

## 工作原理

### `/gsd-sp-execute [N] [--no-tdd]`

带质量门控的阶段执行：

1. 从 `.planning/phases/` 读取阶段计划
2. 创建 git worktree 进行隔离
3. 调度 `sp-executor` 代理，该代理会：
   - 先编写失败的测试（TDD RED）
   - 编写最少代码使测试通过（TDD GREEN）
   - 在保持测试通过的前提下重构（TDD REFACTOR）
   - 遇到测试失败时使用科学调试方法
   - 在声称完成前验证所有测试通过
4. 自动调度两个审查者：
   - **规格审查者**：是否按照计划构建？
   - **质量审查者**：代码质量是否过关？
5. 若审查者发现关键问题，重新调度执行者进行修复（最多 2 轮）
6. 输出最终结论：PASS（通过）/ PASS_WITH_CONCERNS（通过但有顾虑）/ BLOCKED（阻塞）

### `/gsd-sp-review [N]`

用于桥接之外编写代码的独立审查：

1. 获取阶段 N 的变更文件
2. 调度规格和质量审查者
3. 两个审查者在同一位置发现的问题 → CRITICAL（关键）
4. 仅一个审查者发现的问题 → STANDARD（标准）
5. 输出：BLOCKED（有关键问题）/ READY（就绪，无关键问题）

### `/gsd-sp-debug <描述>`

遵循科学方法的系统化调试：

1. **复现** — 运行失败的测试/命令，捕获精确错误
2. **隔离** — 缩小到最小复现场景
3. **假设** — 提出根因假设
4. **验证** — 通过针对性诊断确认或否定假设
5. **修复** — 针对根因的最小化修改
6. **确认** — 运行完整测试套件，确保无回归

## 独立性

- 不修改 GSD 或 Superpowers 的源代码
- 读取 GSD 的 `.planning/` 文件（公开接口）
- 直接内嵌 Superpowers 方法论（无运行时依赖）
- GSD 和 Superpowers 可独立更新

## 许可证

MIT
