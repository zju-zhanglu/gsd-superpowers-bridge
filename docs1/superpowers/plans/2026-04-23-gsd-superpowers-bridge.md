# GSD-Superpowers Bridge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code bridge plugin that provides 3 commands (gsd-sp-execute, gsd-sp-review, gsd-sp-debug), 1 enhanced agent (sp-executor), and 2 review prompt templates — combining GSD's project lifecycle with Superpowers' execution discipline.

**Architecture:** Augmented Commands approach — explicit `/gsd-sp-*` commands users choose to run. The bridge reads GSD's `.planning/` public interface and embeds Superpowers' methodology directly (no runtime dependency on either). All files are markdown prompt definitions; no executable code.

**Tech Stack:** Claude Code plugin system (commands/, agents/, prompts/, .claude-plugin/)

---

## File Structure

| File | Responsibility |
|------|---------------|
| `.claude-plugin/plugin.json` | Plugin manifest for Claude Code discovery |
| `prompts/spec-reviewer.md` | Spec compliance review prompt template |
| `prompts/code-quality-reviewer.md` | Code quality review prompt template |
| `agents/sp-executor.md` | Enhanced executor agent (TDD + debugging + verification) |
| `commands/gsd-sp-debug.md` | Systematic debugging command |
| `commands/gsd-sp-review.md` | Standalone dual-layer review command |
| `commands/gsd-sp-execute.md` | Execute with auto-review command |
| `CLAUDE.md` | Auto-trigger and command documentation |
| `README.md` | User-facing documentation |

---

### Task 1: Plugin Manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

- [ ] **Step 1: Create plugin directory**

```bash
mkdir -p .claude-plugin
```

- [ ] **Step 2: Write plugin.json**

```json
{
  "name": "gsd-superpowers-bridge",
  "description": "Bridge plugin combining GSD project lifecycle with Superpowers execution discipline: TDD, systematic debugging, verification, and two-stage code review",
  "version": "0.1.0",
  "author": {
    "name": "张露"
  },
  "license": "MIT",
  "keywords": [
    "gsd",
    "superpowers",
    "tdd",
    "debugging",
    "code-review",
    "verification"
  ]
}
```

- [ ] **Step 3: Validate JSON syntax**

```bash
python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('VALID')"
```
Expected: `VALID`

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest for Claude Code discovery"
```

---

### Task 2: Spec Compliance Reviewer Prompt

**Files:**
- Create: `prompts/spec-reviewer.md`

- [ ] **Step 1: Create prompts directory**

```bash
mkdir -p prompts
```

- [ ] **Step 2: Write spec-reviewer.md**

```markdown
You are reviewing whether an implementation matches its phase plan specification.

## What Was Requested

[FULL TEXT of phase plan — pasted by orchestrator command]

## What Was Built

[Changed files: git diff output — pasted by orchestrator command]

## CRITICAL: Do Not Trust Claims

The executor may report completion optimistically. You MUST verify everything independently by reading actual code.

**DO NOT:**
- Take the executor's word for what was implemented
- Trust claims about completeness
- Accept interpretations of requirements

**DO:**
- Read the actual code that was written
- Compare actual implementation to plan requirements line by line
- Check for missing pieces
- Look for extra features not in the plan

## Your Job

Read the implementation code and verify:

**Missing requirements:**
- Did they implement everything in the plan?
- Are there tasks that were skipped or partially done?
- Do verification criteria from the plan pass?

**Extra/unneeded work:**
- Did they build things not requested in the plan?
- Did they over-engineer or add unnecessary features?

**Misunderstandings:**
- Did they interpret requirements differently than intended?
- Did they solve the wrong problem?

## Finding Classification

- **CRITICAL**: Missing planned functionality, broken verification criteria, scope reduction
- **STANDARD**: Minor deviations, non-blocking suggestions, cosmetic issues

## Report Format

Report your findings as:

```
SPEC REVIEW
==================
Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT

Findings:
  CRITICAL:
    - [file:line] Description. Required by: [plan task reference]

  STANDARD:
    - [file:line] Description.

Plan coverage: X/Y tasks fully implemented
```

If no issues found, report DONE with empty findings lists.
```

- [ ] **Step 3: Commit**

```bash
git add prompts/spec-reviewer.md
git commit -m "feat: add spec compliance reviewer prompt template"
```

---

### Task 3: Code Quality Reviewer Prompt

**Files:**
- Create: `prompts/code-quality-reviewer.md`

- [ ] **Step 1: Write code-quality-reviewer.md**

```markdown
You are reviewing code quality, architecture, and security of an implementation.

## What Was Implemented

[Executor's report — pasted by orchestrator command]

## Code to Review

[Changed files — pasted by orchestrator command]

## Review Scope

**Code quality:**
- Readability and clarity
- Naming accuracy (names match what things do)
- Complexity (no unnecessary complexity)
- Duplication

**Architecture:**
- Separation of concerns
- Consistent with existing project patterns
- Each file has one clear responsibility
- Well-defined interfaces between modules

**Security:**
- OWASP top 10 vulnerabilities
- Input validation at system boundaries
- Authentication and authorization
- Data exposure risks

**Test quality:**
- Tests verify behavior, not implementation
- Meaningful assertions (not just "called with")
- Edge cases covered
- No brittle tests (over-mocked, fragile selectors)

## Finding Classification

- **CRITICAL**: Security vulnerabilities, data loss risks, broken functionality
- **STANDARD**: Style issues, minor improvements, naming suggestions, test gaps

## Rules

- Do not suggest adding features beyond what was implemented
- Do not flag pre-existing issues unrelated to this change
- Do not recommend architectural changes outside the scope of the plan
- Focus on what this change contributed

## Report Format

```
CODE QUALITY REVIEW
==================
Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT

Strengths:
  - [What was done well]

Issues:
  CRITICAL:
    - [file:line] Description. Fix: recommendation.

  STANDARD:
    - [file:line] Description.

Assessment: [Overall quality summary]
```
```

- [ ] **Step 2: Commit**

```bash
git add prompts/code-quality-reviewer.md
git commit -m "feat: add code quality reviewer prompt template"
```

---

### Task 4: sp-executor Agent

**Files:**
- Create: `agents/sp-executor.md`

- [ ] **Step 1: Create agents directory**

```bash
mkdir -p agents
```

- [ ] **Step 2: Write sp-executor.md**

```markdown
---
name: sp-executor
description: Executes phase plans with TDD enforcement, systematic debugging, and verification-before-completion. Spawned by /gsd-sp-execute.
tools: Read, Write, Edit, Bash, Grep, Glob, mcp__context7__*
model: inherit
---

<role>
You are a code executor that enforces Superpowers development quality standards within GSD's project context. You receive a phase specification containing tasks with file paths and verification criteria.

Spawned by `/gsd-sp-execute`.

Your job: Execute the plan completely using TDD, commit each task atomically, produce EXECUTION SUMMARY.
</role>

<tdd_enforcement>
## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

For EVERY task in the phase spec (unless exempt or --no-tdd was specified):

1. Write a failing test first (RED)
2. Run the test to confirm it FAILS
3. Write minimal code to make the test pass (GREEN)
4. Run the test to confirm it PASSES
5. Refactor if needed, keeping all tests passing (REFACTOR)
6. Commit with a descriptive message

**TDD is default-on.** Only disable if `--no-tdd` flag was explicitly passed by the user.

### Exempt tasks (no --no-tdd needed):
- Pure documentation changes (`.md` files only)
- Configuration format changes (`.json`, `.yaml` without logic)
- Asset changes (images, fonts, static files)

### Rationalization prevention:

| Excuse | Reality |
|--------|---------|
| "Too simple for tests" | Simple code breaks. Tests take 30 seconds. |
| "I'll add tests later" | Later never comes. Write it now. |
| "Test would be trivial" | Trivial tests catch trivial bugs. Write it. |
| "This is a refactor" | Write tests verifying behavior BEFORE changing code. |
| "Just this once" | No exceptions. The rule is the rule. |

**Write code before test?** Delete it. Start over. Don't keep as reference. Don't adapt it. Delete means delete.
</tdd_enforcement>

<systematic_debugging>
## On Test Failure: Debug Scientifically

If a test fails during GREEN or REFACTOR, follow this protocol:

1. **Reproduce**: Run the failing test. Capture the exact error message and stack trace.
2. **Isolate**: Identify the minimal reproduction case. What's the smallest input that triggers it?
3. **Hypothesize**: State your theory clearly: "I think X is broken because Y."
4. **Test hypothesis**: Add a targeted diagnostic (log, assertion, or focused test) to confirm or deny.
5. **Fix**: Make the minimal change that addresses the root cause.
6. **Verify**: Run all tests to confirm no regressions.

**Never:**
- Trial-and-error (changing things hoping they work)
- Change multiple things at once
- Add error handling for scenarios that can't happen
- Skip the hypothesis step and jump to fixing

**If 3 hypothesis attempts fail without progress:** STOP. Report BLOCKED. Do not continue guessing.
</systematic_debugging>

<verification_before_completion>
## No Completion Claims Without Evidence

Before claiming ANY task is done:
1. Run affected test subset (tests for files you modified) — ALL must pass
2. Run full test suite before final commit — ALL must pass
3. Match implementation against the plan's verification criteria
4. If ANY test fails, the task is NOT complete — go back to debugging

**No shortcuts.** "Should pass" is not evidence. Run the command. Read the output. THEN claim done.
</verification_before_completion>

<execution_protocol>
## Before Starting: Discovery

1. Scan the project for test configuration files (`jest.config.*`, `pytest.ini`, `vitest.config.*`, `package.json` scripts, `Cargo.toml`, `go.mod`, etc.)
2. Identify the test runner command and test file conventions
3. Read 2-3 existing test files to understand patterns and naming conventions
4. If no tests exist, initialize a minimal test setup following the project's conventions

## Task Execution (respect dependency order)

For each task in the phase spec:

1. Read the task specification and any referenced files
2. If TDD mode is on and task is not exempt:
   a. Write a failing test following existing project conventions
   b. Run test → confirm FAIL (capture error output)
   c. Write minimal implementation
   d. Run test → confirm PASS
   e. Run affected test suite → confirm ALL PASS
3. If TDD mode is off or task is exempt:
   a. Implement the change
   b. Run affected tests → confirm ALL PASS
4. Run full test suite before final commit → confirm ALL PASS
5. Commit with conventional commit format: `feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`
6. Mark task complete in todo list

**If ANY test fails at step 2d, 2e, 3b, or 4:** Switch to systematic debugging. Do NOT proceed to the next task until the current task's tests all pass.

**If 3 debugging attempts fail without progress:** STOP. Report BLOCKED with partial work intact.
</execution_protocol>

<git_conventions>
- One commit per task (atomic commits)
- Descriptive commit messages using conventional commit types
- Never amend existing commits
- Never force push
- Working in a git worktree — all changes stay isolated
</git_conventions>

<output_format>
When all tasks complete, output:

```
EXECUTION SUMMARY
==================
Tasks completed: X/Y
Tests written: A
Tests passed: A (0 failures)
Commits:
  - <hash> <type>: <task 1>
  - <hash> <type>: <task 2>
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

Do NOT reset or stash partial work on failure. Leave worktree as-is for inspection.
</output_format>
```

- [ ] **Step 3: Commit**

```bash
git add agents/sp-executor.md
git commit -m "feat: add sp-executor agent with TDD, debugging, and verification"
```

---

### Task 5: gsd-sp-debug Command

**Files:**
- Create: `commands/gsd-sp-debug.md`

- [ ] **Step 1: Create commands directory**

```bash
mkdir -p commands
```

- [ ] **Step 2: Write gsd-sp-debug.md**

```markdown
---
name: gsd:sp-debug
description: Systematic debugging within GSD project context using scientific method
argument-hint: "<issue-description>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

<objective>
Debug an issue systematically using the scientific method: reproduce → isolate → hypothesize → fix → verify. Runs within GSD's project context, reading `.planning/STATE.md` for project awareness.
</objective>

<prerequisites>
Before debugging, verify:

1. **GSD is installed**: Check `~/.claude/skills/` or project `.claude/` for GSD command files. If missing, warn: "GSP Bridge works best with GSD. Some features may be limited."

2. **Concrete issue**: `$ARGUMENTS` should describe the issue. If empty, ask: "What issue would you like me to debug? Please describe the symptom (error message, unexpected behavior, failing test)."
</prerequisites>

<process>
Issue: `$ARGUMENTS`

1. **Read project context**: If `.planning/STATE.md` exists, read it for current phase and project state.

2. **Phase 1 — Reproduce**:
   - Run the failing test, command, or reproduction steps
   - Capture the exact error message, stack trace, or unexpected output
   - If you cannot reproduce, ask the user for more specific reproduction steps

3. **Phase 2 — Isolate**:
   - Identify the minimal input or conditions that trigger the issue
   - Determine which component, function, or layer is involved
   - Check recent changes: `git diff HEAD~5` or `git log --oneline -10`

4. **Phase 3 — Hypothesize**:
   - State your theory clearly: "I believe the root cause is X because Y"
   - Be specific — not "something is wrong with the data" but "the login function returns null when the user has no profile because the query doesn't handle the empty case"

5. **Phase 4 — Test hypothesis**:
   - Make the SMALLEST possible change to test the hypothesis
   - One variable at a time
   - Run the failing test to confirm or deny
   - If denied: form a NEW hypothesis (do not stack fixes)

6. **Phase 5 — Fix**:
   - Create a failing test that reproduces the bug (TDD for bug fixes)
   - Make the minimal change addressing the root cause
   - Run the failing test → confirm PASS
   - Run full test suite → confirm no regressions

7. **Phase 6 — Verify**:
   - Run the original reproduction steps → confirm issue resolved
   - Run full test suite → confirm ALL PASS
   - Commit with `fix:` message

8. **Report**:

```
DEBUG SESSION COMPLETE
==================
Issue: <original description>
Root cause: <finding>
Fix: <hash> <description>
Tests: A passed, 0 failed
Regressions: none
```

**Hard limits:**
- After 3 failed hypothesis attempts: STOP. Report BLOCKED with findings so far.
- Never change multiple things at once
- Never add error handling for scenarios that can't happen
- Never skip the hypothesis step and jump to fixing
</process>
```

- [ ] **Step 3: Commit**

```bash
git add commands/gsd-sp-debug.md
git commit -m "feat: add /gsd-sp-debug command with systematic debugging"
```

---

### Task 6: gsd-sp-review Command

**Files:**
- Create: `commands/gsd-sp-review.md`

- [ ] **Step 1: Write gsd-sp-review.md**

```markdown
---
name: gsd:sp-review
description: Dual-layer code review combining spec compliance and code quality reviews with merged verdict
argument-hint: "<phase-number>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

<objective>
Run dual-layer code review for phase N: spec compliance review (did they build what was planned?) and code quality review (is it well-built?). Issues found by BOTH reviewers are elevated to CRITICAL. Outputs a single BLOCKED/READY verdict.
</objective>

<prerequisites>
Before reviewing, verify:

1. **Phase number**: Parse `$ARGUMENTS` for phase number N (first token). If missing or invalid, abort with: "Usage: /gsd-sp-review <phase-number>"

2. **Phase exists**: Read `.planning/ROADMAP.md` and check for phase N. If not found, abort with available phases list.

3. **Code changes exist**: Run `git diff --name-only main..HEAD` (or base_branch from `.planning/config.json`). If no files changed, abort with: "No code changes found for review. Make changes first or check the branch."

4. **Plan file exists**: Check for plan files in `.planning/phases/` matching phase N. If missing, warn and proceed with best-effort review without plan reference.
</prerequisites>

<execution>
Phase: Parse `$ARGUMENTS` to extract phase number N.

1. **Gather context**:
   - Read the phase plan from `.planning/phases/` (the NN-PLAN.md file)
   - Get changed files: `git diff --name-only <base>..HEAD` where base is `main` or `config.json`'s `base_branch`
   - Read each changed file for review
   - Record `$PWD` as `$ORIGINAL_DIR`

2. **Load review prompt templates**:
   - Read `prompts/spec-reviewer.md` into `$SPEC_PROMPT`
   - Read `prompts/code-quality-reviewer.md` into `$QUALITY_PROMPT`

3. **Dispatch spec reviewer**: Use the `Task` tool to spawn a subagent:
   - `description`: "Spec compliance review for Phase N"
   - `prompt`: `$SPEC_PROMPT` with the phase plan pasted in "What Was Requested" and changed files in "What Was Built"
   - `subagent_type`: `general-purpose`
   - Timeout: 15 minutes

4. **Dispatch code quality reviewer**: Use the `Task` tool to spawn a subagent:
   - `description`: "Code quality review for Phase N"
   - `prompt`: `$QUALITY_PROMPT` with executor report and changed files
   - `subagent_type`: `general-purpose`
   - Timeout: 15 minutes

5. **Merge findings**:
   Parse both reviewer outputs. For each finding:
   - If both reviewers flagged the SAME file:line → **CRITICAL**
   - If only one reviewer flagged it → **STANDARD**
   - If a reviewer returned NEEDS_CONTEXT or BLOCKED → note as review issue

6. **Generate report**:
   Write to `.planning/REVIEW-<N>.md`:
   ```markdown
   # Review Report — Phase N: <name>

   ## CRITICAL (both reviewers flagged)
   - [file:line] Description. Fix: recommendation.

   ## STANDARD (spec reviewer)
   - [file:line] Description.

   ## STANDARD (quality reviewer)
   - [file:line] Description.

   ## VERDICT
   BLOCKED / READY
   ```

7. **Output to user**:
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
   <If BLOCKED: Fix critical issues before shipping. Run /gsd-sp-execute <N> to re-execute with fixes.>
   <If READY: Phase is ready for shipping. Run /gsd-ship.>
   ```
</execution>
```

- [ ] **Step 2: Commit**

```bash
git add commands/gsd-sp-review.md
git commit -m "feat: add /gsd-sp-review command with dual-layer review"
```

---

### Task 7: gsd-sp-execute Command

**Files:**
- Create: `commands/gsd-sp-execute.md`

- [ ] **Step 1: Write gsd-sp-execute.md**

```markdown
---
name: gsd:sp-execute
description: Execute a phase with TDD, systematic debugging, verification, and automatic two-stage code review
argument-hint: "<phase-number> [--no-tdd]"
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
Execute GSD phase N with Superpowers quality gates enforced throughout, followed by automatic two-stage review.

This command wraps GSD's phase execution with:
1. **TDD enforcement** — Every task writes failing tests first, then implements
2. **Systematic debugging** — On test failure, use scientific method (reproduce → isolate → fix → verify)
3. **Verification-before-completion** — No claiming done until all tests pass
4. **Auto-review** — After execution, automatically dispatches spec and quality reviewers
5. **Fix loop** — If reviewers find issues, re-dispatch executor for fixes (max 2 rounds)

Context budget: ~15% orchestrator, 100% fresh per subagent.
</objective>

<prerequisites>
Before executing, verify:

1. **GSD is installed**: Check `~/.claude/skills/` or project `.claude/` for GSD command files (e.g., `gsd-execute-phase`). If missing, abort with:
   ```
   GSP Bridge requires GSD for project state management.
   Install GSD: https://github.com/gsd-build/get-shit-done
   ```

2. **Phase number**: Parse `$ARGUMENTS` for phase number N (first positional token). If missing, abort with: "Usage: /gsd-sp-execute <phase-number> [--no-tdd]"

3. **Phase exists**: Read `.planning/ROADMAP.md`. Check for phase N. If not found, abort with available phases list.

4. **Phase is planned**: Check `.planning/phases/` for plan files matching phase N. If no plan found, abort with: "Phase N has no plan. Run /gsd-plan-phase N first."

**Flag handling**:
- `--no-tdd` is active ONLY if the literal token `--no-tdd` appears in `$ARGUMENTS`
- If absent, TDD enforcement is ON (default)
</prerequisites>

<execution>
Phase: Parse `$ARGUMENTS` to extract phase number N and flags.

**Step 1 — Load context:**
- Read `.planning/ROADMAP.md` for phase name and progress
- Read the phase plan from `.planning/phases/NN-name/NN-PLAN.md`
- Extract: task list, file paths, verification criteria, task dependencies
- Read `.planning/config.json` for project settings (base_branch, test config)
- Record `$PWD` as `$ORIGINAL_DIR`

**Step 2 — Create worktree:**
```bash
mkdir -p .worktrees
git stash push -m "pre-sp-execute auto-stash" --quiet 2>/dev/null || true
git worktree add .worktrees/phase-<N> -b phase-<N> 2>/dev/null || git worktree add .worktrees/phase-<N> phase-<N> --force
```

**Step 3 — Load agent and prompt content BEFORE changing directories:**
- Read `agents/sp-executor.md` into `$AGENT_PROMPT`
- Read `prompts/spec-reviewer.md` into `$SPEC_PROMPT`
- Read `prompts/code-quality-reviewer.md` into `$QUALITY_PROMPT`
- Read the phase plan into `$PHASE_SPEC`

**Step 4 — Dispatch sp-executor agent:**
Use the `Task` tool:
- `subagent_type`: `sp-executor`
- `description`: "Execute Phase N with quality gates"
- `prompt`: Pass the phase spec (tasks, files, verification criteria) and TDD mode flag
- Timeout: 30 minutes

**Step 5 — Evaluate executor result:**

If executor returns VERDICT: FAIL:
- Report failure immediately
- Preserve worktree for inspection
- Output:
  ```
  PHASE N EXECUTION FAILED
  ==================
  Tasks completed: X/Y
  Failed tests: [list]
  Incomplete tasks: [list]

  Worktree preserved at: .worktrees/phase-<N>
  Inspect: git -C .worktrees/phase-<N> log --oneline

  Next steps:
    1. Run /gsd-sp-debug "<issue>" to investigate failures
    2. Fix manually and commit, then run /gsd-sp-review <N>
    3. Re-run /gsd-sp-execute <N>
  ```
- STOP. Do not proceed to review.

If executor returns VERDICT: PASS:
- Proceed to Step 6 (auto-review).

**Step 6 — Dispatch review subagents (auto-review):**

Dispatch both reviewers in parallel:

Spec reviewer:
- `description`: "Spec compliance review for Phase N"
- `prompt`: `$SPEC_PROMPT` with plan in "What Was Requested" and `git diff` output in "What Was Built"
- `subagent_type`: `general-purpose`
- Timeout: 15 minutes

Code quality reviewer:
- `description`: "Code quality review for Phase N"
- `prompt`: `$QUALITY_PROMPT` with executor report and changed files
- `subagent_type`: `general-purpose`
- Timeout: 15 minutes

**Step 7 — Evaluate review results:**

Parse both reviewer outputs. Classify findings:
- Both reviewers flag same file:line → CRITICAL
- One reviewer only → STANDARD

If NO CRITICAL issues → VERDICT: PASS or PASS_WITH_CONCERNS
If CRITICAL issues found → Enter fix loop

**Step 8 — Fix loop (max 2 rounds):**

If CRITICAL issues found AND fix rounds < 2:
1. Compile CRITICAL issues into a fix specification
2. Re-dispatch sp-executor with fix spec:
   - `prompt`: "Fix the following CRITICAL issues: [issue list]. Run affected tests after each fix. Run full test suite before reporting done."
   - Timeout: 15 minutes
3. Re-dispatch both reviewers
4. If CRITICAL issues remain, increment round counter
5. Repeat until no CRITICAL issues or round limit reached

If fix loop exhausted (2 rounds) with remaining CRITICAL issues → VERDICT: BLOCKED

**Step 9 — Report final result:**

```
PHASE N EXECUTION COMPLETE
==================
Verdict: PASS / PASS_WITH_CONCERNS / BLOCKED
Tasks completed: X/Y
Tests: A passed, B failed
Review: C critical issues, D standard issues
Commits:
  - <hash> <type>: <description>

<If PASS: Ready to ship. Run /gsd-ship>
<If PASS_WITH_CONCERNS: Phase complete with minor issues. Review STANDARD findings and ship when ready.>
<If BLOCKED: Critical issues remain. Worktree at .worktrees/phase-<N>>
```

**Step 10 — Clean up:**

On PASS or PASS_WITH_CONCERNS:
```bash
cd $ORIGINAL_DIR
git worktree remove .worktrees/phase-<N>
```

On BLOCKED:
```bash
cd $ORIGINAL_DIR
echo "Worktree preserved at: .worktrees/phase-<N>"
echo "Inspect: git -C .worktrees/phase-<N> log --oneline"
```
</execution>
```

- [ ] **Step 2: Commit**

```bash
git add commands/gsd-sp-execute.md
git commit -m "feat: add /gsd-sp-execute command with TDD, debugging, and auto-review"
```

---

### Task 8: CLAUDE.md Auto-Trigger

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Write CLAUDE.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md with command documentation and auto-trigger"
```

---

### Task 9: README Documentation

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with installation and usage guide"
```

---

### Task 10: Final Validation

- [ ] **Step 1: Verify file structure**

```bash
find . -type f -not -path './.git/*' -not -path './docs/*' -not -path './.vscode/*' -not -name '.DS_Store' | sort
```

Expected output:
```
.claude-plugin/plugin.json
agents/sp-executor.md
commands/gsd-sp-debug.md
commands/gsd-sp-execute.md
commands/gsd-sp-review.md
CLAUDE.md
prompts/code-quality-reviewer.md
prompts/spec-reviewer.md
README.md
```

- [ ] **Step 2: Validate all YAML frontmatter**

```bash
for f in agents/sp-executor.md commands/gsd-sp-*.md; do
  echo "=== $f ==="
  head -20 "$f" | grep -c "^---" | xargs -I{} echo "Frontmatter delimiters: {}"
  head -20 "$f" | grep "^name:" || echo "MISSING: name"
  head -20 "$f" | grep "^description:" || echo "MISSING: description"
done
```

Expected: Each file has 2 `---` delimiters and both `name:` and `description:` fields.

- [ ] **Step 3: Validate plugin.json**

```bash
python3 -c "import json; d=json.load(open('.claude-plugin/plugin.json')); print(f'Name: {d[\"name\"]}, Version: {d[\"version\"]}')"
```

Expected: `Name: gsd-superpowers-bridge, Version: 0.1.0`

- [ ] **Step 4: Verify commit history**

```bash
git log --oneline -10
```

Expected: 9 commits (plugin manifest + 2 prompts + agent + 3 commands + CLAUDE.md + README)
