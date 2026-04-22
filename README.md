# GSP Bridge — GSD + Superpowers

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight bridge plugin that combines [GSD](https://github.com/gsd-build/get-shit-done)'s project lifecycle management with [Superpowers](https://github.com/obra/superpowers)' development quality enforcement.

## Problem

- **GSD** excels at phase management, milestone tracking, and roadmap orchestration but doesn't enforce TDD, systematic debugging, or structured code review.
- **Superpowers** enforces development best practices (TDD, debugging methodology, code review) but has no project lifecycle management.
- You want both: GSD manages *what* and *when*; Superpowers enforces *how*.

## Solution

Two new commands that wrap native GSD commands with Superpowers quality gates:

| Command | What it does |
|---------|-------------|
| `/gsd-sp-execute [N]` | Execute phase N with TDD, systematic debugging, and verification-before-completion |
| `/gsd-sp-review [N]` | Dual-layer review: GSD cross-AI review + Superpowers structured review |

## Architecture

```
/gsd-sp-execute [N]
  ├── Validate prerequisites (GSD + SP installed, phase exists)
  ├── Create git worktree for isolation
  ├── Spawn sp-executor agent (TDD + debugging + verification)
  ├── Agent executes phase tasks with quality gates
  ├── Output pass/fail verdict + commit summary
  └── Clean up worktree

/gsd-sp-review [N]
  ├── Run GSD /gsd-review (cross-AI peer review)
  ├── Run SP code-reviewer agent (structured review)
  ├── Merge outputs (both = CRITICAL, one = STANDARD)
  └── Output VERDICT: BLOCKED or READY
```

## Installation

### Prerequisites

- [GSD](https://github.com/gsd-build/get-shit-done) installed
- [Superpowers](https://github.com/obra/superpowers) installed

### Quick Install

```bash
# Clone into your Claude Code plugins directory
git clone https://github.com/<you>/gsd-superpowers-bridge ~/.claude/plugins/gsd-superpowers-bridge

# Or install via plugin manager (when published)
# /plugin install gsd-superpowers-bridge
```

After installation, the new commands appear alongside existing GSD commands.

## Usage

```bash
# Execute a phase with TDD quality gates
/gsd-sp-execute 3

# Execute with verbose debugging
/gsd-sp-execute 3 --debug

# Review with dual-layer analysis
/gsd-sp-review 3
```

You can mix native and enhanced commands:
- Use `/gsd-execute-phase` for phases that don't need TDD
- Use `/gsd-sp-execute` for phases where code quality matters
- Use `/gsd-review` for quick reviews, `/gsd-sp-review` for thorough ones

## Compatibility

See [COMPATIBILITY.md](COMPATIBILITY.md) for tested version combinations.

## License

MIT
