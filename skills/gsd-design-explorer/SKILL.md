---
name: gsd-design-explorer
description: "Precedes /gsd:discuss-phase with Superpowers brainstorming. Triggered by --design flag. Explores 2-3 design approaches with trade-offs before capturing implementation decisions."
argument-hint: "<phase-number> [workspace]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
  - Agent
---

<objective>
Explore design alternatives for a GSD phase using Superpowers brainstorming methodology, then transition to discuss-phase for implementation decision capture.
</objective>

<prerequisites>
- GSD project initialized (`.planning/` exists)
- Phase exists in ROADMAP.md
- Superpowers plugin installed
</prerequisites>

<context>
$ARGUMENTS
</context>

<process>

<step name="initialize">
Parse `$ARGUMENTS` for phase number and GSD workspace name.

```bash
INIT=$(gsd-sdk query init.phase-op "${PHASE}")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse JSON for: `phase_found`, `phase_dir`, `phase_number`, `phase_name`, `phase_slug`, `padded_phase`, `has_research`.

**If `phase_found` is false:**
```
Phase [X] not found in roadmap.
Use /gsd-progress to see available phases.
```
Exit.

**If `phase_found` is true:** Continue to load_context.
</step>

<step name="load_context">
Read GSD project context to provide to brainstorming.

```bash
cat .planning/PROJECT.md 2>/dev/null || true
cat .planning/REQUIREMENTS.md 2>/dev/null || true
cat .planning/ROADMAP.md 2>/dev/null || true
cat .planning/STATE.md 2>/dev/null || true
```

Read prior CONTEXT.md files from earlier phases:
```bash
(find .planning/phases -name "*-CONTEXT.md" 2>/dev/null || true) | sort
```

Build internal `<project_context>` containing:
- Phase goal from ROADMAP.md
- Project vision from PROJECT.md
- Requirements constraints from REQUIREMENTS.md
- Prior decisions from earlier CONTEXT.md files
- Codebase scout hints (lightweight grep for phase-relevant terms)

Store as internal context for brainstorming invocation.
</step>

<step name="invoke_brainstorming">
Invoke Superpowers brainstorming skill with GSD context.

```
Skill(skill="superpowers:brainstorming", args="Design exploration for GSD Phase ${PHASE}: ${phase_name}. Phase goal: ${phase_goal_from_roadmap}. Project: ${project_name}. Constraints: ${requirements_summary}. Prior decisions: ${prior_decisions_summary}")
```

The brainstorming skill will:
1. Ask clarifying questions one at a time
2. Force 2-3 design approaches with trade-offs
3. Present design in sections for user approval
4. (Optional) Use visual companion for UI/architecture diagrams

**IMPORTANT:** After brainstorming completes its design presentation and user approves:
- Do NOT write to `docs/superpowers/specs/` (Superpowers default path)
- Instead, write DESIGN.md to the GSD phase directory (next step)
</step>

<step name="write_design">
Write the approved design to GSD's phase directory.

**File:** `${phase_dir}/${padded_phase}-DESIGN.md`

Use the template structure:

```markdown
# Phase {N}: {Name} - Design Spec

**Gathered:** {date}
**Status:** Ready for discuss-phase

## Approaches Compared

### Approach A: {name} (recommended)
- **Pros:** {pros}
- **Cons:** {cons}
- **Trade-off:** {key trade-off}

### Approach B: {name}
- **Pros:** {pros}
- **Cons:** {cons}
- **Trade-off:** {key trade-off}

[### Approach C: {name} (if a third was explored)]

## Selected Design

### Architecture
{Component relationships, key abstractions}

### Data Flow
{How data moves through the system}

### Error Handling
{Error strategy, recovery patterns}

### Testing Strategy
{How to verify the implementation works}

## Scope Boundary
{What this phase delivers — from ROADMAP.md. No scope creep.}

## Canonical References
{Any specs, ADRs, or docs referenced during design exploration}
```

Write file.
</step>

<step name="self_review">
Check DESIGN.md for quality issues:

1. **Placeholder scan:** Any "TBD", "TODO", vague descriptions? Fix inline.
2. **Consistency check:** Does the selected design match the approach comparison? Fix contradictions.
3. **Scope check:** Does the design stay within ROADMAP.md phase boundary? Remove scope creep.
4. **Ambiguity check:** Could any section be interpreted two ways? Clarify.

Fix issues inline. No re-review needed.
</step>

<step name="commit">
```bash
gsd-sdk query commit "docs(${padded_phase}): capture design spec (design explorer)" "${phase_dir}/${padded_phase}-DESIGN.md"
```
</step>

<step name="transition">
Display summary and transition to discuss-phase:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► DESIGN COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Design spec saved: ${phase_dir}/${padded_phase}-DESIGN.md

Transitioning to discuss-phase...
Discuss-phase will load DESIGN.md as locked design decisions.
Discussion will focus on implementation details only.

/clear then:

/gsd-discuss-phase ${PHASE} ${GSD_WS}
```

**Note:** The DESIGN.md file will be picked up by discuss-phase's `check_spec` step (similar to SPEC.md handling). Discuss-phase reads it, locks the design decisions, and focuses subsequent discussion on implementation choices rather than re-exploring design alternatives.
</step>

</process>

<success_criteria>
- Phase validated against ROADMAP.md
- Project context loaded from GSD artifacts
- Superpowers brainstorming invoked with GSD context
- 2-3 design approaches compared with trade-offs
- User approved design via section-by-section review
- DESIGN.md written to phase directory with self-review passed
- Git commit created
- User informed of transition to discuss-phase
</success_criteria>
