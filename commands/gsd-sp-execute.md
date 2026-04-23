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
