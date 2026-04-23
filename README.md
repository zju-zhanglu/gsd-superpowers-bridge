# GSD-Superpowers Bridge

A Claude Code plugin that bridges [GSD](https://github.com/gsd-build/get-shit-done) project lifecycle management with [Superpowers](https://github.com/obra/superpowers) execution discipline.

## What It Does

GSD excels at project management — planning, state tracking, phase lifecycle. Superpowers excels at execution quality — TDD, systematic debugging, verification. This bridge gives you both without modifying either.

## Commands

| Command | Description |
|---------|-------------|
| `/gsd-sp-execute [N] [--no-tdd]` | Execute a phase with TDD + debugging + verification + auto-review |
| `/gsd-sp-review [N]` | Dual-layer code review (spec + quality) |
| `/gsd-sp-debug <description>` | Systematic debugging with scientific method |

## Prerequisites

- [GSD](https://github.com/gsd-build/get-shit-done) installed and initialized in your project
- A GSD project with phases planned (`.planning/` directory exists)

## Installation

1. Install this plugin in Claude Code
2. Ensure GSD is installed and your project has a `.planning/` directory
3. Run any `/gsd-sp-*` command

## How It Works

### `/gsd-sp-execute [N] [--no-tdd]`

Executes phase N with quality gates:

1. Reads the phase plan from `.planning/phases/`
2. Creates a git worktree for isolation
3. Dispatches the `sp-executor` agent which:
   - Writes failing tests first (TDD RED)
   - Implements minimal code to pass (TDD GREEN)
   - Refactors while keeping tests green (TDD REFACTOR)
   - Uses scientific debugging on any test failure
   - Verifies all tests pass before claiming done
4. Automatically dispatches two reviewers:
   - **Spec reviewer**: Did they build what was planned?
   - **Quality reviewer**: Is the code well-built?
5. If reviewers find critical issues, re-dispatches executor for fixes (max 2 rounds)
6. Reports final verdict: PASS / PASS_WITH_CONCERNS / BLOCKED

### `/gsd-sp-review [N]`

Standalone review for code written outside the bridge:

1. Gets changed files for phase N
2. Dispatches spec and quality reviewers
3. Issues found by BOTH reviewers at the same location → CRITICAL
4. Issues found by one reviewer → STANDARD
5. Reports: BLOCKED (has critical) / READY (no critical)

### `/gsd-sp-debug <description>`

Systematic debugging following the scientific method:

1. **Reproduce** — Run failing test/command, capture exact error
2. **Isolate** — Minimal reproduction case
3. **Hypothesize** — State root cause theory
4. **Test** — Confirm/deny with targeted diagnostic
5. **Fix** — Minimal change for root cause
6. **Verify** — Full test suite, no regressions

## Independence

- Does not modify GSD or Superpowers source code
- Reads GSD's `.planning/` files (public interface)
- Embeds Superpowers methodology directly (no runtime dependency)
- Both GSD and Superpowers can be updated independently

## License

MIT
