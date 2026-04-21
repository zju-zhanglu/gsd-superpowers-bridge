---
name: gsd-review
description: "Two-stage code review for GSD verify-work. Spec compliance + code quality. Triggered by /gsd:verify-work N --review."
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Skill
---

<objective>
Perform two-stage code review: spec compliance against PLAN.md, then code quality assessment.
</objective>

<process>
1. **Load context**: Load PLAN.md, CONTEXT.md, and all implementation files for the target phase.

2. **Stage 1 - Spec Compliance**:
   - Invoke `superpowers:requesting-code-review` for structured spec compliance review.
   - Verify each plan action is implemented.
   - Check done criteria are fully satisfied.
   - Validate CONTEXT.md architectural decisions are respected.
   - Perform anti-stub verification: exists -> substantive -> wired -> data flowing.
   - Record compliance-issues[] with severity (CRITICAL/MAJOR/MINOR).

3. **Stage 2 - Code Quality**:
   - Internal code quality review covering:
     - **YAGNI**: No unnecessary or speculative code.
     - **DRY**: No significant duplication without good reason.
     - **Security**: OWASP Top 10 awareness (injection, auth, data exposure, misconfiguration).
     - **Test quality**: Right behaviors tested, not implementation details.
   - Record quality-issues[] with severity (CRITICAL/MAJOR/MINOR).

4. **Merge results**: Deduplicate issues across stages, keeping higher severity for duplicates.

5. **Write REVIEW.md**: Generate review document with summary, compliance tables, quality issues, positive findings, and recommendations.

6. **Commit**: Commit the review results.

**Verdict rules**:
- Any CRITICAL -> **BLOCKED** (must fix before proceeding)
- Only MAJOR/MINOR -> **PASS_WITH_NOTES** (should fix, can proceed)
- No issues -> **PASS**
</process>
