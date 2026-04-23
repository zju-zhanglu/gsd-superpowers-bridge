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
