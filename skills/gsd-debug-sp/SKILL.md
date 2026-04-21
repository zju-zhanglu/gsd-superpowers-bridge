---
name: gsd-debug-sp
description: |
  Enhanced debugging skill using Superpowers systematic-debugging methodology.
  4-phase root cause analysis with defense-in-depth. Used by gsd-debugger-sp agent.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Skill
---

<objective>
Apply systematic debugging methodology to find and fix root causes with evidence, not guesses.
Combine Superpowers' 4-phase systematic debugging with GSD state management for full traceability.
</objective>

<process>
Invoke `Skill(skill="superpowers:systematic-debugging")` to activate the systematic debugging framework.

Follow the 4-phase process:

**Phase 1 — Collect Evidence:** Reproduce the bug reliably. Gather logs, traces, and state.

**Phase 2 — Form Precise Hypothesis:** One testable root cause claim, not a symptom description.

**Phase 3 — Design Minimal Verification Experiment:** Smallest change that confirms or denies the hypothesis. Predict outcome before executing.

**Phase 4 — Root Cause Confirmed:** If confirmed, proceed to fix. If denied, return to Phase 2.

Apply defense-in-depth checks: single points of failure, boundary conditions, similar bug classes elsewhere.

For async bugs, use condition-based waiting — wait for explicit conditions, never arbitrary sleeps.

Fix via TDD: write failing test (RED), apply minimal fix (GREEN), run full suite.

Commit atomically and update GSD state.

**Escalation:** Maximum 3 hypothesis cycles before escalating to user with full evidence trail.
</process>
