---
name: wiki-history-ingest
description: >
  Unified wiki-history-ingest entrypoint for conversation/session sources. Use this when the user says
  "/wiki-history-ingest opencode" or "/wiki-history-ingest kiro", or asks to ingest agent history without
  naming the underlying skill. This router dispatches to the specialized history skill.
---

# Unified History Ingest Router

This is a thin router for **history sources only**. It does not replace `wiki-ingest` for documents.

## Subcommands

If the user invokes `/wiki-history-ingest <target>` (or equivalent text command), dispatch directly:

| Subcommand | Route To |
|---|---|
| `opencode` | |
| `kiro` | |
| `antigravity` | `antigravity-history-ingest` |
| `agent` | `agent-history-ingest` |
| `auto` | infer from context using rules below |

## Routing Rules

1. If the user explicitly says `opencode`, `kiro`, `antigravity`, or `agent`, route directly.
2. If the user provides a path/source:
   - `~/.opencode` or OpenCode memory/session JSONL artifacts ->
   - `~/.kiro` or rollout/session index artifacts ->
   - `~/.antigravity` or Antigravity memories/session artifacts -> `antigravity-history-ingest`
   - `~/.agent` or Agent MEMORY.md/session JSONL artifacts -> `agent-history-ingest`
3. If ambiguous, ask one short clarification:
   - "Should I ingest `opencode`, `kiro`, `antigravity`, or `agent` history?"

## Execution Contract

- After routing, execute the destination skill's workflow exactly.
- Do not duplicate destination logic in this file.
- Leave manifest/index/log update semantics to the destination skill.

## UX Convention

- Use `wiki-ingest` for **documents/content sources**
- Use `wiki-history-ingest` for **agent history sources**

Examples:

- `/wiki-history-ingest opencode`
- `/wiki-history-ingest kiro`
- `/wiki-history-ingest antigravity`
- `/wiki-history-ingest agent`
