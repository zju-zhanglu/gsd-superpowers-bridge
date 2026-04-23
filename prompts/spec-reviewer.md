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
