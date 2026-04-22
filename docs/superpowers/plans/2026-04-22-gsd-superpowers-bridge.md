# GSP Bridge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a lightweight Claude Code plugin that adds two wrapper commands (`/gsd-sp-execute` and `/gsd-sp-review`) combining GSD's project lifecycle with Superpowers' quality enforcement.

**Architecture:** Thin wrapper plugin following GSD's command file format. Commands invoke GSD native commands with Superpowers skill injections. Agent definitions use GSD's agent frontmatter format with SP skill content embedded.

**Tech Stack:** Markdown skill files, YAML frontmatter, JSON plugin manifest. No code dependencies.

---

## File Map

| File | Responsibility |
|------|---------------|
| `.claude-plugin/plugin.json` | Plugin manifest: name, description, version, author |
| `CLAUDE.md` | Plugin entry point: auto-trigger rules and available commands |
| `commands/gsd-sp-execute.md` | Execute wrapper: TDD + debug during phase execution |
| `commands/gsd-sp-review.md` | Review wrapper: dual-layer review (GSD + SP) |
| `agents/sp-executor.md` | Agent definition: TDD + debugging + verification workflow |
| `COMPATIBILITY.md` | Tested GSD + SP version combinations |
| `README.md` | Installation, usage, and architecture documentation |

## Dependencies

- **GSD** (required): The bridge calls GSD commands. GSD must be installed as a Claude plugin.
- **Superpowers** (required): The bridge uses SP skills. SP must be installed as a Claude plugin.
- Both dependencies are consumed as external plugins — no source modifications.

---

### Task 1: Plugin Scaffold

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `CLAUDE.md`

- [ ] **Step 1: Create plugin.json**

```json
{
  "name": "gsd-superpowers-bridge",
  "description": "Bridge plugin: GSD project management + Superpowers quality gates",
  "version": "0.1.0",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "homepage": "https://github.com/<you>/gsd-superpowers-bridge",
  "repository": "https://github.com/<you>/gsd-superpowers-bridge",
  "license": "MIT",
  "keywords": [
    "gsd",
    "superpowers",
    "tdd",
    "code-review",
    "workflow"
  ],
  "dependencies": {
    "gsd": ">=1.0.0",
    "superpowers": ">=5.0.0"
  }
}
```

- [ ] **Step 2: Create CLAUDE.md**

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json CLAUDE.md
git commit -m "feat: add plugin scaffold with manifest and entry point"
```

---

### Task 2: `/gsd-sp-execute` Command

**Files:**
- Create: `commands/gsd-sp-execute.md`

- [ ] **Step 1: Create the execute wrapper command**

```markdown
---
name: gsd:sp-execute
description: Execute a phase with Superpowers quality gates (TDD, systematic debugging, verification)
argument-hint: "<phase-number> [--tdd] [--debug] [--verify]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
  - AskUserQuestion
---

<objective>
Execute phase N with Superpowers quality gates enforced throughout.

This command wraps GSD's native `execute-phase` with three quality gates:
1. **TDD enforcement** — Every task writes failing tests first, then implements
2. **Systematic debugging** — On test failure, use scientific method (reproduce → isolate → fix → verify)
3. **Verification-before-completion** — No claiming done until all tests pass

The `sp-executor` agent handles the actual coding. This command orchestrates: validate prerequisites, spawn the agent, collect results, and report pass/fail.
</objective>

<prerequisites>
Before executing, verify:

1. **GSD is installed**: Check `~/.claude/skills/` or project `.claude/` for GSD command files (e.g., `gsd-execute-phase.md`). If missing, abort with:
   ```
   GSP Bridge requires GSD. Install GSD first:
   https://github.com/gsd-build/get-shit-done
   ```

2. **Superpowers is installed**: Check for Superpowers skills (e.g., `test-driven-development`, `systematic-debugging`). If missing, warn and continue with degraded mode:
   ```
   WARNING: Superpowers not detected. Running in degraded mode — no TDD or quality gates enforced.
   Install Superpowers for full quality gates:
   https://github.com/obra/superpowers
   ```

3. **Phase exists**: Read `.planning/ROADMAP.md` or `.planning/phases/` to verify phase N exists. If missing, abort with available phases list.

4. **Phase is planned**: Check phase state. If already completed, warn and show current state. If not yet planned, suggest running `/gsd-plan-phase` first.
</prerequisites>

<execution>
Phase: $ARGUMENTS

1. **Read phase spec**: Load the phase N plan file from `.planning/` directory. Extract:
   - Task list with file paths
   - Verification criteria
   - Dependencies between tasks

2. **Create worktree**: Use Superpowers' git worktree isolation. Create a fresh branch for this phase:
   ```bash
   git worktree add .worktrees/phase-<N> -b phase-<N>
   cd .worktrees/phase-<N>
   ```

3. **Spawn sp-executor agent**: Dispatch the `sp-executor` agent (defined in `agents/sp-executor.md`) with:
   - Phase spec as input
   - TDD workflow enforced
   - Systematic debugging on failure
   - Verification-before-completion gate

4. **Wait for agent completion**: The agent returns:
   - Committed code changes (with atomic commits per task)
   - Test results (pass/fail per test)
   - Overall verdict (pass/fail)

5. **Verify results**:
   - If VERDICT=PASS: Output success summary with test counts, commit list, and readiness for `/gsd-ship`
   - If VERDICT=FAIL: Output failure report with:
     - Which tests failed
     - Which tasks are incomplete
     - Recommended next steps (run `/gsd-sp-review` to identify issues, or re-execute with `--debug`)

6. **Clean up worktree**:
   ```bash
   cd $ORIGINAL_DIR
   git worktree remove .worktrees/phase-<N>
   ```

Flag behavior:
- `--tdd` (default): Enforce TDD workflow. Active unless explicitly disabled.
- `--debug`: Enable verbose debugging output during execution.
- `--verify`: Run verification-before-completion gate even if tests pass.
</execution>

<output>
On success:
```
PHASE N EXECUTION COMPLETE ✓
==================
Tasks completed: X/Y
Tests passed: A (0 failures)
Commits:
  - abc1234 feat: <task 1 description>
  - def5678 feat: <task 2 description>
Branch: phase-<N>

Ready for review: /gsd-sp-review <N>
Ready to ship: /gsd-ship <N>
```

On failure:
```
PHASE N EXECUTION FAILED ✗
==================
Tasks completed: X/Y
Tests failed: A failures in B files

Failed tests:
  - test_name (file.py:line): error message

Incomplete tasks:
  - Task N: <description> (reason)

Next steps:
  1. Run /gsd-sp-review <N> to identify issues
  2. Re-execute with /gsd-sp-execute <N> --debug
  3. Fix manually and commit
```
</output>
```

- [ ] **Step 2: Commit**

```bash
git add commands/gsd-sp-execute.md
git commit -m "feat: add /gsd-sp-execute command with TDD and quality gates"
```

---

### Task 3: `/gsd-sp-review` Command

**Files:**
- Create: `commands/gsd-sp-review.md`

- [ ] **Step 1: Create the review wrapper command**

```markdown
---
name: gsd:sp-review
description: Dual-layer code review combining GSD cross-AI review with Superpowers structured review
argument-hint: "<phase-number>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
  - AskUserQuestion
---

<objective>
Run dual-layer code review for phase N, combining GSD's cross-AI review with Superpowers' structured code review.

Issues found by BOTH reviewers are elevated to CRITICAL priority. Issues found by one reviewer are STANDARD. The review outputs a single VERDICT: BLOCKED (critical issues found) or READY (only standard or no issues).
</objective>

<prerequisites>
Before reviewing, verify:

1. **GSD is installed**: Same check as `/gsd-sp-execute`. Abort with instructions if missing.

2. **Phase N exists and has code**: Check `.planning/` for phase spec. Check git for uncommitted changes on the phase branch. If no code changes exist, abort with:
   ```
   Phase N has no code changes to review. Run /gsd-sp-execute <N> first.
   ```

3. **Superpowers code-reviewer agent available**: Check `~/.claude/skills/agents/code-reviewer.md` or equivalent. If missing, warn and run GSD-only review.
</prerequisites>

<execution>
Phase: $ARGUMENTS

1. **Read phase spec**: Load phase N plan and list of changed files.

2. **Run GSD review**: Invoke GSD's `/gsd-review` command for the cross-AI peer review. Collect the review output.

3. **Run Superpowers review**: Spawn the `code-reviewer` agent with:
   - Phase plan as the reference document
   - Changed files as the review target
   - Instructions to review against plan alignment, code quality, architecture, and security

4. **Merge review outputs**: Parse both review outputs and categorize:
   - **CRITICAL**: Issues flagged by BOTH reviewers (same file:line or same logical issue)
   - **STANDARD**: Issues flagged by only one reviewer

5. **Generate report**: Write `REVIEW-<N>.md` in the `.planning/` directory with the merged output.

6. **Determine verdict**:
   - If any CRITICAL issues → VERDICT: BLOCKED. Suggest specific fixes for each critical issue.
   - If only STANDARD or no issues → VERDICT: READY. List standard issues as improvement suggestions.

7. **Output report** to the user with the verdict.
</execution>

<output>
Review report format:
```
REVIEW REPORT for Phase N: <phase name>
==================

CRITICAL (both reviewers flagged):
  - [file:line] Issue description. Fix: specific recommendation.

STANDARD (GSD reviewer):
  - [file:line] Issue description.

STANDARD (SP reviewer):
  - [file:line] Issue description.

VERDICT: BLOCKED / READY
==================
<Blocked: Fix critical issues before shipping. Suggested commands:
  - Run /gsd-sp-execute <N> to re-execute with fixes
  - Fix manually and commit, then re-run /gsd-sp-review <N>>
<Ready: Phase is ready for shipping. Run /gsd-ship <N>>
```
</output>
```

- [ ] **Step 2: Commit**

```bash
git add commands/gsd-sp-review.md
git commit -m "feat: add /gsd-sp-review command with dual-layer review"
```

---

### Task 4: `sp-executor` Agent

**Files:**
- Create: `agents/sp-executor.md`

- [ ] **Step 1: Create the executor agent definition**

```markdown
---
name: sp-executor
description: Execute code tasks with Superpowers quality enforcement: TDD (write failing test first), systematic debugging on failure, verification-before-completion (all tests must pass), and git worktree isolation.
model: inherit
---

You are a code executor agent that enforces Superpowers development quality standards. You receive a phase specification containing tasks with file paths and verification criteria.

## Core Rules

### 1. TDD Enforcement (RED-GREEN-REFACTOR)
For EVERY task in the phase spec:
1. Write a failing test first (RED)
2. Run the test to confirm it fails
3. Write minimal code to make the test pass (GREEN)
4. Run the test to confirm it passes
5. Refactor if needed, keeping all tests passing (REFACTOR)
6. Commit with a descriptive message

NEVER write implementation code before a failing test. If the task is a refactor, write tests that verify the new behavior before changing code.

### 2. Systematic Debugging on Failure
If a test fails during GREEN or REFACTOR:
1. **Reproduce**: Run the failing test, capture the exact error
2. **Isolate**: Identify the minimal reproduction case
3. **Hypothesize**: State your theory of what's broken
4. **Test hypothesis**: Add a targeted test or log to confirm/deny
5. **Fix**: Make the minimal change that addresses the root cause
6. **Verify**: Run all tests to confirm no regressions

Do NOT trial-and-error. Do NOT change multiple things at once. Do NOT add error handling for scenarios that can't happen.

### 3. Verification-Before-Completion
Before claiming a task is done:
- Run ALL tests (not just the new ones)
- Verify every test passes
- Check that the implementation matches the phase spec's verification criteria
- If any test fails, the task is NOT complete — go back to debugging

### 4. Git Worktree Isolation
You are working in a git worktree. All changes should be committed here:
- One commit per task (atomic commits)
- Descriptive commit messages: `feat: <specific change description>`
- Never amend existing commits
- Never force push

## Input Format

You receive a phase specification:

```
PHASE SPEC: <N>
Tasks:
  1. <task description>
     Files: <file paths>
     Verify: <verification criteria>
     Depends on: <task numbers or "none">
```

## Execution Protocol

For each task (respecting dependency order):

1. Read the task specification and any referenced files
2. Write a failing test
3. Run test → confirm FAIL
4. Write minimal implementation
5. Run test → confirm PASS
6. Run full test suite → confirm ALL PASS
7. Commit changes
8. Mark task complete

If ANY test fails at step 5 or 8, switch to systematic debugging. Do NOT proceed to the next task until the current task's tests all pass.

## Output Format

When all tasks complete, output:

```
EXECUTION SUMMARY
==================
Tasks completed: X/Y
Tests written: A
Tests passed: A (0 failures)
Commits:
  - <hash> feat: <task 1>
  - <hash> feat: <task 2>
  ...

VERDICT: PASS
```

If any task could not be completed:

```
EXECUTION SUMMARY
==================
Tasks completed: X/Y (Y-X incomplete)

Incomplete tasks:
  - Task N: <description> — <reason>

Failed tests:
  - <test_name> in <file>:<line> — <error>

VERDICT: FAIL
```
```

- [ ] **Step 2: Commit**

```bash
git add agents/sp-executor.md
git commit -m "feat: add sp-executor agent with TDD + debugging + verification"
```

---

### Task 5: Documentation

**Files:**
- Create: `COMPATIBILITY.md`
- Create: `README.md`

- [ ] **Step 1: Create COMPATIBILITY.md**

```markdown
# Compatibility Matrix

## Tested Versions

| GSD Version | Superpowers Version | Bridge Version | Status |
|-------------|-------------------|----------------|--------|
| >= 1.0.0 | >= 5.0.0 | 0.1.0 | Tested |

## Dependency Notes

- **GSD**: Bridge calls GSD commands via slash command interface. Internal `.planning/` file format changes may require bridge updates.
- **Superpowers**: Bridge uses SP skills as agent prompts. New SP skills are additive and don't affect bridge behavior. Removed SP skills cause graceful degradation.

## Reporting Incompatibilities

If you encounter issues with a specific version combination, open an issue with:
- GSD version (`gsd --version` or git commit)
- Superpowers version (git commit or plugin version)
- Bridge version
- Error output or unexpected behavior
```

- [ ] **Step 2: Create README.md**

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add COMPATIBILITY.md README.md
git commit -m "docs: add compatibility matrix and README"
```

---

### Task 6: Integration Test

**Files:**
- Modify: (none — uses existing `.planning/` from the GSD project in this repo)

- [ ] **Step 1: Verify plugin structure**

Run these checks:
```bash
# Verify all required files exist
test -f .claude-plugin/plugin.json && echo "plugin.json OK" || echo "MISSING"
test -f CLAUDE.md && echo "CLAUDE.md OK" || echo "MISSING"
test -f commands/gsd-sp-execute.md && echo "gsd-sp-execute.md OK" || echo "MISSING"
test -f commands/gsd-sp-review.md && echo "gsd-sp-review.md OK" || echo "MISSING"
test -f agents/sp-executor.md && echo "sp-executor.md OK" || echo "MISSING"
test -f COMPATIBILITY.md && echo "COMPATIBILITY.md OK" || echo "MISSING"
test -f README.md && echo "README.md OK" || echo "MISSING"
```

Expected: All 7 files OK.

- [ ] **Step 2: Validate YAML frontmatter**

Check each command file has valid frontmatter:
```bash
# Verify frontmatter parses correctly (check for name, description, argument-hint)
head -6 commands/gsd-sp-execute.md
head -6 commands/gsd-sp-review.md
```

Expected: Valid YAML with `name`, `description`, `argument-hint` fields.

- [ ] **Step 3: Verify agent definition**

```bash
# Check agent frontmatter
head -3 agents/sp-executor.md
```

Expected: Valid YAML with `name: sp-executor` and `model: inherit`.

- [ ] **Step 4: Final commit**

```bash
git status
# Verify clean working tree (only docs/ should be uncommitted from plan file)
```
