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
