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
Phase: Parse `$ARGUMENTS` to extract phase number N (first positional token). If no valid phase number is provided, abort with: "Usage: /gsd-sp-review <phase-number>". Verify the phase exists in `.planning/ROADMAP.md` — if not found, abort with available phases list.

1. **Read phase spec**: Load phase N plan from `.planning/`. Get the list of changed files since the phase branch was created:
   ```bash
   git diff --name-only main..phase-<N>
   ```
   If no files changed, abort with: "Phase N has no code changes to review."

2. **Run GSD review**: Read the `commands/gsd/review.md` file from the GSD plugin (located in `~/.claude/skills/` or equivalent). Follow its instructions to perform the cross-AI peer review on the changed files. Capture the full review output. If the GSD review command file does not exist, note "GSD review unavailable — proceeding with Superpowers review only" and set the GSD review output to empty.

3. **Run Superpowers review**: Use the `Task` tool to dispatch a subagent. Load the full content of `agents/code-reviewer.md` (from the Superpowers plugin at `~/.claude/skills/agents/code-reviewer.md` or equivalent) and pass it as the agent prompt. Provide:
   - The phase plan as the reference document
   - The changed files as the review target
   - Instructions to review against plan alignment, code quality, architecture, and security
   Set a timeout of 15 minutes for the subagent. If the agent times out or fails, note "Superpowers review unavailable — proceeding with GSD review only" and set the SP review output to empty.

4. **Merge review outputs**: If both reviewers are available, parse both outputs and categorize by matching file:line references:
   - **CRITICAL**: Issues flagged by BOTH reviewers at the same file:line
   - **STANDARD**: Issues flagged by only one reviewer, or matching issues at different lines in the same file
   If only one reviewer ran (the other was unavailable), all issues are STANDARD.

5. **Generate report**: Ensure `.planning/` exists, then write `REVIEW-<N>.md` with the merged output. If the file already exists (re-run), overwrite it and note the previous version was replaced.

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
