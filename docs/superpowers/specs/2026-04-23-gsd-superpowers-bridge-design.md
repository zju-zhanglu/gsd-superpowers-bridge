# GSD-Superpowers Bridge Plugin Design

## Problem

GSD provides excellent project lifecycle management (discuss → research → plan → execute → verify → ship) with state tracking, 33+ agents, and context engineering. But its execution methodology is thin — no TDD enforcement, no systematic debugging, no structured code review.

Superpowers excels at execution discipline — TDD (RED-GREEN-REFACTOR), systematic debugging (reproduce → isolate → hypothesize → fix → verify), verification-before-completion, and two-stage subagent review. But it has no project lifecycle, no state management, no planning system.

Neither should be modified directly. Both must remain independently updateable.

## Solution

A bridge plugin that provides 3 explicit commands wrapping GSD's `.planning/` state with Superpowers' execution methodology. Users choose when to use bridge commands vs. standard GSD commands.

**Approach**: Augmented Commands — explicit `/gsd-sp-*` commands, one enhanced agent, review prompt templates. No hook injection, no runtime dependency on Superpowers files.

## Architecture

```
gsd-superpowers-bridge/
  .claude-plugin/
    plugin.json
  commands/
    gsd-sp-execute.md
    gsd-sp-review.md
    gsd-sp-debug.md
  agents/
    sp-executor.md
  prompts/
    spec-reviewer.md
    code-quality-reviewer.md
  CLAUDE.md
  README.md
```

### Independence guarantees

- **GSD**: Bridge only reads `.planning/` directory files (ROADMAP.md, plan files, STATE.md). Never modifies GSD source.
- **Superpowers**: Bridge embeds SP methodology directly in its own agent/prompt files. No runtime dependency on SP skill files.
- **Updates**: GSD format changes (rare) → update bridge file readers. SP methodology improvements → manually sync to bridge prompts.

## Commands

### `/gsd-sp-execute [N] [--no-tdd]`

Execute GSD phase N with Superpowers quality gates, followed by automatic two-stage review.

**Prerequisites**:
1. GSD installed (`.claude/skills/` contains GSD commands)
2. Phase N exists in `.planning/ROADMAP.md`
3. Phase N has plan files in `.planning/phases/NN-name/`

**Execution flow**:
1. Parse `$ARGUMENTS` for phase number N and flags
2. Validate prerequisites
3. Read phase plan from `.planning/phases/NN-name/NN-PLAN.md`
4. Create git worktree for isolation
5. Dispatch `sp-executor` agent with:
   - Phase spec (tasks, files, verification criteria)
   - TDD mode (on unless `--no-tdd`)
   - Project conventions (test runner, test patterns)
6. Wait for executor completion (PASS/FAIL)
7. On PASS: dispatch two review subagents:
   - Spec reviewer: verify implementation matches phase plan
   - Code quality reviewer: verify code quality, architecture, security
8. Fix loop: if reviewers find issues, re-dispatch executor for fixes (max 2 rounds)
9. Report final verdict:
   - **PASS**: All tasks complete, all tests pass, reviewers approve
   - **PASS_WITH_CONCERNS**: All tasks complete, reviewers flagged non-critical issues
   - **BLOCKED**: Tests failing, critical review issues, or executor timed out
10. Clean up worktree (PASS) or preserve for inspection (BLOCKED)

**Output format**:
```
PHASE N EXECUTION COMPLETE
==================
Verdict: PASS / PASS_WITH_CONCERNS / BLOCKED
Tasks completed: X/Y
Tests: A passed, B failed
Review: C critical issues, D standard issues
Commits:
  - <hash> <type>: <description>

<Next steps based on verdict>
```

### `/gsd-sp-review [N]`

Standalone dual-layer code review. For reviewing code written outside the bridge.

**Prerequisites**:
1. Phase N exists and has code changes (`git diff --name-only`)

**Execution flow**:
1. Parse phase number N from `$ARGUMENTS`
2. Get changed files: `git diff --name-only main..HEAD` (or GSD's `base_branch` from `.planning/config.json`)
3. Dispatch spec reviewer subagent (implementation vs. plan)
4. Dispatch code quality reviewer subagent (quality, architecture, security)
5. Merge findings:
   - Issues found by BOTH reviewers at same file:line → **CRITICAL**
   - Issues found by one reviewer → **STANDARD**
6. Write `REVIEW-<N>.md` to `.planning/`
7. Output verdict:
   - **BLOCKED**: Critical issues found
   - **READY**: Only standard or no issues

**Output format**:
```
REVIEW REPORT for Phase N: <name>
==================

CRITICAL (both reviewers flagged):
  - [file:line] Description. Fix: recommendation.

STANDARD (spec reviewer):
  - [file:line] Description.

STANDARD (quality reviewer):
  - [file:line] Description.

VERDICT: BLOCKED / READY
==================
<Recommended next steps>
```

### `/gsd-sp-debug [description]`

Systematic debugging within GSD project context.

**Prerequisites**:
1. GSD installed
2. A concrete issue to debug (test failure, runtime error, unexpected behavior)

**Execution flow**:
1. Read project context from `.planning/STATE.md`
2. **Reproduce**: Run the failing test/command, capture exact error output
3. **Isolate**: Create minimal reproduction case
4. **Hypothesize**: State theory of root cause
5. **Test hypothesis**: Add targeted test or diagnostic to confirm/deny
6. **Fix**: Make minimal change addressing root cause
7. **Verify**: Run full test suite, check no regressions
8. Commit fix with descriptive message

**Rules**:
- Never change multiple things at once
- Never add error handling for scenarios that can't happen
- After 3 failed hypothesis attempts, stop and report BLOCKED
- Always run full test suite before claiming done

**Output format**:
```
DEBUG SESSION COMPLETE
==================
Issue: <description>
Root cause: <finding>
Fix: <hash> <description>
Tests: A passed, 0 failed
Regressions: none / <list>
```

## Agent: sp-executor

Combines GSD's execution behavior with Superpowers' discipline enforcement.

### Core rules (from Superpowers methodology)

**TDD enforcement** (default-on, opt-out with `--no-tdd`):
1. Write failing test first (RED)
2. Run test → confirm FAIL
3. Write minimal implementation (GREEN)
4. Run test → confirm PASS
5. Refactor if needed, keep tests passing (REFACTOR)
6. Commit

Rationalization prevention:
- "This is too simple for tests" → No task is too simple. Write the test.
- "I'll add tests later" → Later never comes. Write it now.
- "The test would be trivial" → Trivial tests catch trivial bugs. Write it.

Tasks exempt from TDD (no `--no-tdd` needed):
- Pure documentation changes (`.md` files)
- Configuration format changes (`.json`, `.yaml` without logic)
- Asset changes (images, fonts)

**Systematic debugging** (on test failure):
1. Reproduce: run failing test, capture exact error
2. Isolate: minimal reproduction case
3. Hypothesize: state theory
4. Test: confirm/deny with targeted diagnostic
5. Fix: minimal change for root cause
6. Verify: all tests pass

Never: trial-and-error, change multiple things, add error handling for impossible scenarios.

**Verification-before-completion**:
- Run affected tests after each implementation change
- Run full test suite before final commit
- Match implementation against plan's verification criteria
- Any test failure → task NOT complete

### GSD integration (from GSD executor behavior)

- Atomic commits per task
- Conventional commit messages (`feat:`, `fix:`, `test:`, `refactor:`)
- Worktree isolation
- Respect task dependency order from PLAN.md
- Output structured EXECUTION SUMMARY for orchestrator

### Model

`model: inherit` — uses the same model as the parent session.

## Review Prompt Templates

### spec-reviewer.md

Verifies implementation matches phase plan specification.

Reviews:
- Each task in the plan is addressed
- Verification criteria are met
- No scope creep (no unlisted changes)
- No scope reduction (no skipped requirements)

Reports findings as:
- CRITICAL: Missing planned functionality, broken verification criteria
- STANDARD: Minor deviations, non-blocking suggestions

Status: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT

### code-quality-reviewer.md

Verifies code quality, architecture, and security.

Reviews:
- Code quality (readability, naming, complexity)
- Architecture (separation of concerns, consistent patterns)
- Security (OWASP top 10, input validation, auth)
- Test quality (coverage, meaningful assertions, no brittle tests)

Reports findings as:
- CRITICAL: Security vulnerabilities, data loss risks, broken functionality
- STANDARD: Style issues, minor improvements, naming suggestions

Status: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT

## Configuration

No separate configuration file. Behavior is controlled via command flags:
- `--no-tdd`: Disable TDD enforcement (warns on use)
- Debug command has no flags — always runs in strict mode

The bridge respects GSD's `.planning/config.json` for project-level settings (test runner, branching strategy, etc.).

## Error handling

- **Missing GSD**: Abort with installation instructions
- **Phase not found**: List available phases
- **No plan file**: Suggest running `/gsd-plan-phase` first
- **Executor timeout** (30 min): Report BLOCKED, preserve worktree
- **Review fix loop exhausted** (2 rounds): Report BLOCKED with remaining issues
- **Debug hypothesis exhausted** (3 attempts): Report BLOCKED with findings so far

## Testing strategy

- Each command tested manually against a GSD project with:
  - A phase with plan files
  - A codebase with existing tests
  - Known bugs for debug command
- Agent behavior verified by examining:
  - Commit messages follow conventional format
  - Tests written before implementation (TDD compliance)
  - Debug sessions follow scientific method steps
- Review accuracy verified by:
  - Intentionally introducing known issues
  - Confirming both reviewers catch them
  - Confirming CRITICAL elevation when both agree
