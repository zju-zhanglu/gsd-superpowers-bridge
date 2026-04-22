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

1. **GSD is installed**: Check `~/.claude/skills/` or project `.claude/` for GSD command files (e.g., `gsd-execute-phase.md`). If missing, abort with:
   ```
   GSP Bridge requires GSD. Install GSD first:
   https://github.com/gsd-build/get-shit-done
   ```

2. **Phase N exists and has code**: Check `.planning/` for phase spec. Check git for uncommitted changes on the phase branch. If no code changes exist, abort with:
   ```
   Phase N has no code changes to review. Run /gsd-sp-execute <N> first.
   ```

3. **Superpowers code-reviewer agent available**: Check `~/.claude/skills/agents/code-reviewer.md` or equivalent. If missing, warn and run GSD-only review.
</prerequisites>

<execution>
Phase: Parse `$ARGUMENTS` to extract phase number N (first positional token).

1. **Read phase spec**: Load phase N plan and list of changed files from git diff against the base branch.

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
