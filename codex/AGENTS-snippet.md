# 追加到 ~/.codex/AGENTS.md 的肥波模式片段
# Append this section to ~/.codex/AGENTS.md (create the file if it doesn't exist).

## 肥波模式

When the user mentions `肥波模式`, `肥波`, `fable mode`, or `Fable Mode`
(case-insensitive), treat it as an explicit request to use the `codex-fable5`
skill workflow. Load the `codex-fable5` skill before acting and apply its
evidence-driven process: inspect first, classify the task, use goal
ledger/checkpoints for multi-step or risky work, track actionable findings when
review misses would matter, and verify with real tool output before claiming
completion.

Calibrate intensity to the task, per the skill's own routing table: the trigger
activates the discipline, not the ceremony. Simple one-step edits or factual
answers stay in the normal Codex loop even when triggered — do not create goal
or findings ledgers for trivial work. Ledgers earn their cost only on
multi-story, long-autonomous, review-sensitive, or resume-across-session work.

This mode adds workflow discipline only; it does not imply access to Fable
model weights or hidden capabilities. Active system, developer, safety,
project, and tool instructions remain higher priority.
