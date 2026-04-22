# GSP Bridge Design: GSD + Superpowers Integration

## Summary

A thin wrapper plugin that combines GSD's project lifecycle management with Superpowers' development quality enforcement, without modifying either upstream project. Users install the bridge as a Claude Code plugin and get two new commands: `/gsd-sp-execute` and `/gsd-sp-review`.

## Problem

- GSD excels at phase management, milestone tracking, and roadmap orchestration but lacks enforced quality gates (TDD, systematic debugging, structured code review).
- Superpowers enforces development best practices but has no project lifecycle management.
- Users want both: GSD manages *what* and *when*; Superpowers enforces *how*.

## Constraints

- No modifications to GSD or Superpowers source code. Both remain independently updateable.
- Lightweight, installable as a Claude Code plugin via `/plugin install`.
- Zero project-level configuration — works out of the box in any project.
- Users can mix native GSD commands with SP-enhanced commands.

## Architecture

```
User → /gsd-sp-execute [N]
         │
         ├── 1. Read phase N from GSD's .planning/ directory
         ├── 2. Validate prerequisites
         ├── 3. Spawn sp-executor agent (pre-loaded with SP skills)
         │      ├── TDD workflow (write test → make pass → refactor)
         │      ├── Systematic debugging on failure
         │      └── Verification-before-completion gate
         ├── 4. Agent executes phase tasks with quality gates
         ├── 5. GSD wave orchestration verifies inter-task dependencies
         └── 6. Output pass/fail verdict + commit summary

User → /gsd-sp-review [N]
         │
         ├── 1. Invoke /gsd-review (cross-AI peer review)
         ├── 2. Invoke SP requesting-code-review workflow
         ├── 3. Compare outputs, surface overlapping issues as high-priority
         └── 4. Block shipping if critical issues found
```

## Plugin Structure

```
gsd-superpowers-bridge/
├── CLAUDE.md                          # Plugin entry point, loaded by Claude Code
├── plugin.json                        # Claude plugin manifest
├── commands/
│   ├── gsd-sp-execute.md              # Execute wrapper command skill
│   └── gsd-sp-review.md              # Review wrapper command skill
├── agents/
│   └── sp-executor.md                 # Agent definition: TDD + debugging + verification
├── COMPATIBILITY.md                   # Tested GSD + SP version matrix
└── README.md                          # Installation and usage documentation
```

## Command Details

### `/gsd-sp-execute [N]`

Enhanced execution that wraps GSD's native execution with Superpowers quality gates.

**Flow:**
1. Read phase N spec from `.planning/phases/` or current active phase if N omitted
2. Validate prerequisites (GSD installed, phase exists, phase is in "planned" state)
3. Spawn `sp-executor` agent with phase spec and SP TDD workflow
4. Agent runs TDD cycle for each task in the phase
5. On test failure, agent switches to systematic-debugging workflow
6. After all tasks complete, run verification-before-completion gate
7. If verification passes, output success summary (ready for `/gsd-ship`)
8. If verification fails, output failure report with recommended fixes

**Error cases:**
- GSD not installed → fail early with installation instructions
- SP not installed → degrade gracefully, fall back to native GSD execution with warning
- Phase N not found → list available phases from ROADMAP.md
- Phase already completed → warn and show current state

### `/gsd-sp-review [N]`

Dual-layer review combining GSD's cross-AI review with Superpowers' structured code review.

**Flow:**
1. Read phase N spec and implemented code
2. Run `/gsd-review` for cross-AI peer review
3. Run Superpowers `requesting-code-review` against the phase plan
4. Merge review outputs:
   - Issues found by both → **critical** priority
   - Issues found by one → **standard** priority
5. Output structured review report with severity ratings
6. If critical issues found → block shipping, suggest fixes

**Output format:**
```
REVIEW REPORT for Phase N: <phase name>
==================
CRITICAL (both reviewers flagged):
  - [issue description, file:line]

STANDARD:
  - [issue description, file:line, reviewer]

VERDICT: BLOCKED / READY
```

### `sp-executor` Agent

A stateless agent that executes code with Superpowers quality enforcement.

**Skills embedded:**
- TDD: Always write failing test first, then implement, then refactor
- Systematic debugging: Scientific method for failures (reproduce → isolate → fix → verify)
- Verification-before-completion: No claiming done until all tests pass
- Git worktree isolation: Work on a dedicated branch for the phase

**Input:** Phase spec from GSD (task list, files, verification criteria)
**Output:** Committed code + test results + pass/fail verdict

## Dependency & Upgrade Strategy

The bridge consumes GSD and SP as black-box plugins:

- **GSD compatibility**: Bridge calls GSD commands (slash commands) and reads `.planning/` files. If GSD changes internal file formats, the bridge updates its readers.
- **SP compatibility**: Bridge uses SP skills as agent prompts. New SP skills don't break anything. Removed SP skills cause graceful degradation with a warning.
- **Compatibility matrix**: `COMPATIBILITY.md` tracks tested version combinations.

## Implementation Plan

1. Create plugin scaffolding (`plugin.json`, `CLAUDE.md`)
2. Write `/gsd-sp-execute` command skill
3. Write `/gsd-sp-review` command skill
4. Write `sp-executor` agent definition
5. Write README and COMPATIBILITY.md
6. Test against the existing GSD project in this repo
