---
name: gsd-tdd-execute
description: "TDD-enforcing execution skill. Applies RED-GREEN-REFACTOR cycle to each GSD plan task with two-stage code review. Used by gsd-tdd-executor agent."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Skill
---

<objective>
Execute a single GSD plan task using strict TDD with two-stage code review.
</objective>

<process>

This skill provides the per-task execution protocol for the gsd-tdd-executor agent.
It is invoked once per task within the agent's execute_task loop.

**Input:** Current task's `<action>`, `<verify>`, `<done>` from PLAN.md, plus CONTEXT.md decisions.

**Protocol:**

1. **RED:** Write failing test
   - Analyze `<action>` to determine what behavior to test
   - Invoke `Skill(skill="superpowers:test-driven-development")` for TDD guidance
   - Write test that validates the specific behavior described in `<action>`
   - Run test → must FAIL
   - If passes: test is wrong, rewrite

2. **GREEN:** Write minimal implementation
   - Write only enough code to make the failing test pass
   - Run test → must PASS
   - Run `<verify>` command from plan → must succeed

3. **REVIEW:** Two-stage code review
   - Invoke `Skill(skill="superpowers:requesting-code-review")`
   - Review against plan spec + code quality standards
   - Fix CRITICAL issues (max 3 cycles)
   - Escalate architectural issues

4. **COMMIT:** Atomic git commit

</process>
