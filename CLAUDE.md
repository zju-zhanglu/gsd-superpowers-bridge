# GSP Bridge — GSD + Superpowers

Bridge plugin combining GSD project lifecycle with Superpowers execution discipline.

## Commands

- `/gsd-sp-execute [N] [--no-tdd]` — Execute phase N with TDD, systematic debugging, verification, and automatic two-stage review. Example: `/gsd-sp-execute 3` runs phase 3 with all quality gates. Output: pass/pass_with_concerns/blocked verdict with test results and review findings.
- `/gsd-sp-review [N]` — Dual-layer code review for phase N (spec compliance + code quality). Merges findings with CRITICAL/STANDARD priority. Output: blocked/ready verdict.
- `/gsd-sp-debug <description>` — Systematic debugging using scientific method. Reproduce → isolate → hypothesize → fix → verify. Output: root cause finding and fix commit.

## Prerequisites

- GSD plugin installed (`~/.claude/skills/` contains GSD commands)
- Superpowers plugin NOT required (methodology is embedded)

## How it works

The bridge reads GSD's `.planning/` state for project context and embeds Superpowers' methodology directly:

1. `/gsd-sp-execute` spawns the `sp-executor` agent which enforces TDD (RED-GREEN-REFACTOR), systematic debugging on failure, and verification-before-completion. After execution, two review subagents automatically check spec compliance and code quality.
2. `/gsd-sp-review` dispatches both reviewers independently and merges findings. Issues flagged by both reviewers at the same location are elevated to CRITICAL.
3. `/gsd-sp-debug` follows the four-phase scientific method for root cause investigation.

## Auto-trigger

When the user types `/gsd-sp-execute`, `/gsd-sp-review`, or `/gsd-sp-debug`, load the corresponding command file from `commands/`.
