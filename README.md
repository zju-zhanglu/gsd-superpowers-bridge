# GSD-Superpowers Bridge

Integrates [Superpowers](https://github.com/obra/superpowers) capabilities into [GSD](https://github.com/gsd-build/get-shit-done) workflows without modifying either framework.

## Prerequisites

- GSD installed (`~/.claude/skills/gsd-*/SKILL.md` exists)
- Superpowers plugin installed (`/plugin install superpowers`)
- Claude Code 2.1.88+

## Installation

```bash
cd gsd-superpowers-bridge
chmod +x install.sh
./install.sh
```

## Modules

| Module | Trigger | Description |
|--------|---------|-------------|
| Design Explorer | `/gsd:discuss-phase N --design` | Forced 2-3 approach exploration before discuss-phase |
| TDD Executor | config `agent_skills.executor` | RED-GREEN-REFACTOR cycle for every plan task |
| Enhanced Debug | `/gsd:debug` (when enabled) | 4-phase systematic root cause analysis |
| Two-Stage Review | `/gsd:verify-work N --review` | Spec compliance + code quality review |

## Configuration

Add to `.planning/config.json`:

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

## Uninstall

```bash
./install.sh --uninstall
```
