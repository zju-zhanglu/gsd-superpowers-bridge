# GSP Bridge — GSD + Superpowers

## Commands

- `/gsd-sp-execute [N]` — Execute phase N with TDD and quality gates
- `/gsd-sp-review [N]` — Dual-layer review (GSD + Superpowers)

## Prerequisites

- GSD plugin installed (`~/.claude/skills/` contains GSD commands)
- Superpowers plugin installed (`~/.claude/skills/` contains SP skills)

## How it works

The bridge wraps native GSD commands with Superpowers quality enforcement:

1. `/gsd-sp-execute` spawns the `sp-executor` agent which enforces TDD, systematic debugging, and verification-before-completion
2. `/gsd-sp-review` runs both GSD's cross-AI review and Superpowers' structured code review, merging results into a single verdict

Both commands delegate to GSD's native commands for phase orchestration. GSD and Superpowers remain independently updateable.

## Auto-trigger

When the user types `/gsd-sp-execute` or `/gsd-sp-review`, load the corresponding command file from `commands/`.
