# GSP Bridge — GSD + Superpowers

## Commands

- `/gsd-sp-execute [N]` — Execute phase N with TDD and quality gates. Example: `/gsd-sp-execute 3` runs phase 3 with TDD enforced. Outputs pass/fail verdict with test results and commit summary.
- `/gsd-sp-review [N]` — Dual-layer review (GSD + Superpowers). Example: `/gsd-sp-review 3` runs both reviewers and outputs a merged report with CRITICAL/STANDARD issues and a BLOCKED/READY verdict.

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
