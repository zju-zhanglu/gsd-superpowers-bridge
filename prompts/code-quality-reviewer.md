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
