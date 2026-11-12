# 05 — Debugging Playbook

**Purpose:** symptom → cause → shortcut. Read when something is broken.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. Nothing runs yet, so there are no logs or error messages to document. The code wins (see 16).

## Why this is short

No server, app, or site exists to fail. Inventing symptoms would teach nothing true.

## Useful today (verified)

| Symptom | Likely cause | Check |
|---|---|---|
| `fatal: not a git repository` at `silver-sentinel-ecosystem/` | The root is not a repo | `cd` into a child repo (02 #1) |
| Commit rejected / awkward in tools | Subject >50 chars or no blank line | 03 |

## To add as code lands

Log locations per component, each error by exact message, causes ranked by frequency, diagnostic commands. Add entries via `INBOX.md` (*Type: Debugging tip*).
