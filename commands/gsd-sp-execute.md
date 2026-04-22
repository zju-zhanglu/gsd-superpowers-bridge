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
