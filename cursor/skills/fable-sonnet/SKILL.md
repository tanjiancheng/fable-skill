---
name: fable-sonnet
description: >
  Run fable-mode execution discipline on Claude Sonnet. Spawns a Sonnet subagent
  that follows the staged loop — stage plan, parallel delegation where the
  runtime supports it, a failable verification check at each stage, and a
  skeptical self-review before delivery. Trigger when the user explicitly asks
  for thorough/systematic/"deep work" handling AND wants it run on Sonnet ("fable
  on sonnet", "stage this on sonnet", "deep work mode, sonnet"). Use as the
  balanced default between Haiku (cheap/fast) and Opus/Fable (peak reasoning).
  Do NOT use for ordinary single-pass tasks.
---

# Fable Mode — Sonnet

Run the fable-mode discipline on Claude Sonnet via a subagent. The skill shapes the
*procedure*; the model still sets the reasoning ceiling. Sonnet sits between Haiku and
the frontier tier — strong general reasoning at lower cost. Pick this as the balanced
default for thorough work that doesn't demand peak synthesis.

Sonnet's characteristic gap: it plans decently but reliably skips step 3 — the check
that can fail — and substitutes "looks right" review. The briefing below enforces step 3
hardest for that reason.

If a task has one obvious correct approach and fits in a single pass, skip this loop and
do it directly. Staging a trivial task buries the answer under ceremony.

## How to run it

1. Confirm the runtime exposes a subagent tool (Claude Code: Agent tool; Cursor: Task
   tool). If it does not, you cannot pin a model — say so and run the loop inline on the
   current model instead.
2. Spawn a general-purpose subagent pinned to the latest Sonnet-class model the runtime
   offers. Use the runtime's own parameter names and model identifiers — e.g. Claude
   Code: `model: "sonnet"`, `subagent_type: "general-purpose"`; Cursor: `subagent_type:
   "generalPurpose"` with the newest `claude-sonnet-*` slug from the runtime's allowed
   model list. If no Sonnet-class model is in the runtime's list, say so and either run
   inline or ask which available model to use — do not silently substitute another tier.
3. Brief the agent with: the user's task, where to save outputs, relevant context from
   this session, and everything from **Core Loop** onward as its operating instructions.
   The subagent does not inherit this session's skills, so the operational rules below
   are inlined in full — pass them verbatim, do not summarize them into a reference.
4. When the agent returns, relay the result and surface any stage it marked unverified.

For independent sub-parts, spawn multiple Sonnet agents concurrently and merge outputs.
Keep delegation one level deep: the agents you spawn run their stages sequentially and do
not spawn further subagents. Cap concurrency to a handful of agents so cost and context
stay controlled.

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

**3. Verify with a check that can fail — your weakest step; enforce it hardest**
Each stage defines a pass condition an external artifact satisfies: a test that runs, a
file that provably exists in the expected shape, a source actually fetched and read, an
output diffed against the spec. "I reviewed it and it looks right" is not a check. Every
check must name the exact command, file, or comparison — "verified" without a named
artifact is a violation. If a stage has no failable check, say so and mark the output
unverified. If a fix at stage N invalidates a prior stage's output, re-run that stage's
check before continuing.

**4. Self-critique before delivery**
Read the final output as a skeptical reviewer. Hunt for a real weakness or limitation; if
one exists, fix it or flag it. If genuine checking turns up nothing, say so plainly — do
not manufacture a weakness to satisfy the ritual. When a task is genuinely beyond Sonnet's
capability, flag it rather than producing plausible-sounding wrong output — name what was
attempted and where it failed, and recommend escalating to fable-mode on the frontier
tier.

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
