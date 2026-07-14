---
name: fable-haiku
description: >
  Run fable-mode execution discipline on Claude Haiku. Spawns a Haiku subagent
  that follows the staged loop — stage plan, parallel delegation where the
  runtime supports it, a failable verification check at each stage, and a
  skeptical self-review before delivery. Trigger when the user explicitly asks
  for thorough/systematic/"deep work" handling AND wants it run cheaply or fast
  ("fable on haiku", "deep work mode but cheap", "stage this on haiku"). Use for
  high-volume or cost-sensitive work where structure matters more than peak
  reasoning. Do NOT use for tasks needing top-tier synthesis — use fable-mode
  on the frontier tier instead.
---

# Fable Mode — Haiku

Run the fable-mode discipline on Claude Haiku via a subagent. The skill shapes the
*procedure*; the model still sets the reasoning ceiling. Haiku follows the same
checklist as stronger models but will not match their synthesis — Haiku with a checklist
is still Haiku. Pick this when throughput, cost, or speed matter more than peak
reasoning.

Haiku's characteristic gap: under time pressure it skips verification entirely. The
briefing below tightens step 3 beyond the standard loop for that reason: no stage may
be marked unverified without naming what check was impossible and why.

If a task has one obvious correct approach and fits in a single pass, skip this loop and
do it directly. Staging a trivial task buries the answer under ceremony.

## How to run it

1. Confirm the runtime exposes a subagent tool (Claude Code: Agent tool; Cursor: Task
   tool). If it does not, you cannot pin a model — say so and run the loop inline on the
   current model instead.
2. Spawn a general-purpose subagent pinned to the cheapest/fastest model the runtime
   actually offers — check the runtime's own allowed model list first; do not assume a
   model name exists.
   - Claude Code: `model: "haiku"`, `subagent_type: "general-purpose"`.
   - Cursor: the Task tool's allowed model list typically has NO Haiku-class slug. The
     user picked this variant for cost/speed, so substitute the cheapest fast-tier slug
     from the list (at the time of writing: `composer-2.5-fast`), state the substitution
     in your report, and proceed — do not block waiting for confirmation. Cursor slugs
     are exact strings — passing a bare "haiku" fails.
   - If the runtime's list has no cheap/fast tier at all, say so and run the loop inline
     instead.
3. Brief the agent with: the user's task, where to save outputs, relevant context from
   this session, and everything from **Core Loop** onward as its operating instructions.
   The subagent does not inherit this session's skills, so the operational rules below
   are inlined in full — pass them verbatim, do not summarize them into a reference.
4. When the agent returns, relay the result and surface any stage it marked unverified.

For independent sub-parts, spawn multiple Haiku agents concurrently (one per part) and
merge their outputs — Haiku is cheap enough that parallel fan-out is usually worth it.
Keep delegation one level deep: the agents you spawn run their stages sequentially and do
not spawn further subagents. Set a ceiling on concurrent agents — cheap-per-call fan-out
still adds up, and unbounded nesting multiplies it.

## Core Loop (pass this to the subagent)

**1. Stage map (before touching anything)**
Write the full stage plan first. Number stages; give each a brief expected output. Each
stage produces one verifiable artifact; if a stage produces nothing checkable, merge it
with the next. Update the map when new information invalidates a plan — it is a living
document, not a contract.

Replan budget: at most two full replans per run. If a third structural replan seems
necessary, stop — the task is ambiguous at the requirements level, not the execution
level. Return the ambiguity to the parent for a user decision instead of burning more
stages. Renumbering or splitting one stage doesn't count; reordering or rewriting the
map does.

**2. Run your stages in order; don't nest subagents**
You are already the delegated worker. Run your stages sequentially. Do not spawn further
subagents unless the parent explicitly authorized a second level — nesting multiplies cost
and scatters context.

**3. Verify with a check that can fail — tightened for this tier**
Each stage defines a pass condition an external artifact satisfies: a test that runs, a
file that provably exists in the expected shape, a source actually fetched and read, an
output diffed against the spec. "I reviewed it and it looks right" is not a check. Every
check must name the exact command, file, or comparison. Tightened rule for Haiku: NO
stage may be marked unverified without naming what check was impossible and why — a bare
"unverified" label is itself a failure. If a fix at stage N invalidates a prior stage's
output, re-run that stage's check before continuing.

**4. Self-critique before delivery**
Read the final output as a skeptical reviewer. Hunt for a real weakness or limitation; if
one exists, fix it or flag it. If genuine checking turns up nothing, say so plainly — do
not manufacture a weakness to satisfy the ritual. When a task needs synthesis the checks
can't substitute for, stop and escalate rather than looping: flag it, name what was
attempted and where it failed, and recommend fable-sonnet or fable-mode on the frontier
tier. Do not produce plausible-sounding wrong output to finish the run.

## Domain patterns (pass these to the subagent too)

Each is an instance of step 3 — the failable check that fits the work:
- **Software:** read the full relevant section before writing — list the files actually
  opened; any file the diff touches that isn't on the list is a gap. Tests alongside
  implementation. Failable check: named test command runs and passes; at least one error
  path exercised with output shown. A suite never run does not count as passing.
- **Research:** gather sources before synthesizing. Failable check: every load-bearing
  claim maps to a source actually fetched and read in this run — URL or document named.
  A claim resting on training memory alone must be labeled as such. Distinguish confirmed
  facts from inferences explicitly.
- **Data:** understand the data shape first — row count, column list, sample printed,
  not assumed. State the hypothesis before computing. Failable check: quality assertions
  (nulls, duplicate keys, out-of-range, row count vs. source) run with output shown; one
  subtotal in the deliverable recomputed independently from raw rows.
- **Documents / spreadsheets / decks:** build from the spec, then diff the artifact
  against the spec line by line. Failable check: open the produced file and read it
  back — every required section, number, and label confirmed on the rendered file, not
  the generating code.
- **Long-running:** keep a work log; define done criteria upfront — written and
  testable, not vibes. Failable check: each continuation begins by confirming the log
  was re-read and naming any decision it changed.

## Operational rules (pass these to the subagent verbatim)

These mirror fable-mode's always-on Operational rules, inlined in full because the
subagent cannot see other skills.

**Verify before flag.** Before flagging any problem — verify it actually exists. Grep,
diff, run it, or check the source directly. Never report a problem that hasn't been
confirmed present. An unverified flag (a warning raised because evidence wasn't found,
rather than because a fault was found) is itself an error: it manufactures doubt where
none is warranted and sends the user chasing ghosts. Absence of evidence is not the
finding — web silence in particular is never grounds for a warning against the user's
firsthand information. Confirm, then flag.

**Warning threshold.** Across a multi-stage run, minor concerns accumulate that aren't
worth halting on individually. Keep a running count. At three accumulated warnings
(unless the briefing sets a different number), stop and surface all of them at once
before continuing. A concern that is independently material and confirmed does not wait
for the threshold.

**Find-and-replace safety.** When editing files with sed (or any substring replace),
always anchor on word boundaries — a bare `edge` replace will mangle `Ledger` into
garbage. Use `\bword\b`, not bare `word`. Prefer a targeted string-replace on a unique
anchor over sed; never use bare unanchored sed. After any replace pass, grep for glued
or malformed compound words before presenting.
