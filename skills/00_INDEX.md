# 00 — Index

**Purpose:** entry point. Pick your task, read the listed documents in order, then check the last-verified date.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. The code wins (see 16).

> **State of the project (verified):** all four repos contain only an initial commit and a README. There is no code, schema, CI, or tests. These documents therefore record the *plan and conventions* and flag every open decision. Most were written to be filled in as code lands; each says so at the top.

## Reading order by task

| Task | Read |
|---|---|
| New to the project | 01, 02, 15, 16 |
| Writing code | 03, 04, 14 |
| Committing, branching, tagging | 03 (commits), 10, `../git-guidelines.md` |
| Adding an endpoint | 08, 04, 09 |
| Touching data | 07, 04 |
| Releasing | 10, 11 |
| Something broke | 05, 06 |
| Adding a dependency | 13 |

## Documents

| # | File | Last verified | Status |
|---|---|---|---|
| 00 | 00_INDEX.md | 2026-11-12 | complete |
| — | INBOX.md | 2026-11-12 | template |
| 01 | 01_ARCHITECTURE.md | 2026-11-12 | plan only, conflicts flagged |
| 02 | 02_PROJECT_STRUCTURE.md | 2026-11-12 | skeleton |
| 03 | 03_CODE_STYLE.md | 2026-11-12 | commit rules real, rest pending |
| 04 | 04_CHANGE_RULES.md | 2026-11-12 | candidate lockstep sets |
| 05 | 05_DEBUGGING_PLAYBOOK.md | 2026-11-12 | stub |
| 06 | 06_FAILURE_STORIES.md | 2026-11-12 | stub (no incidents) |
| 07 | 07_DATABASE.md | 2026-11-12 | stub |
| 08 | 08_API.md | 2026-11-12 | planned routes |
| 09 | 09_SECURITY.md | 2026-11-12 | stub, early rules |
| 10 | 10_DEPLOYMENT.md | 2026-11-12 | branching/tag rules real |
| 11 | 11_TESTING.md | 2026-11-12 | stub |
| 12 | 12_PERFORMANCE.md | 2026-11-12 | stub |
| 13 | 13_DEPENDENCIES.md | 2026-11-12 | stub |
| 14 | 14_DEVELOPER_WORKFLOWS.md | 2026-11-12 | git recipes real |
| 15 | 15_KNOWN_LIMITATIONS.md | 2026-11-12 | complete for now |
| 16 | 16_ENGINEERING_PRINCIPLES.md | 2026-11-12 | seed set |

## How to contribute

Add an entry to `INBOX.md` (a rough entry beats none) or edit a document directly. Routing table is in `INBOX.md`. Refresh rules: append, never renumber; retire, don't delete.

## Changelog (newest first)

- 2026-11-12 — User decisions: product name **Dasaka**, code name `silver-sentinel`, tag short code `SS` (prefixes `WSS/BSS/ASS/SSS`), Android scope `silver-sentinel-android`. Updated 01, 02, 03, 04, 06, 07, 08, 10, 15. `git-guidelines.md` itself not yet updated.
- 2026-11-12 — Initial set generated from READMEs, `CLAUDE.md` files and `git-guidelines.md`. No code existed.
