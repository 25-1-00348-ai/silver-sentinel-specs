# 15 — Known Limitations

**Purpose:** gaps ordered by how likely they are to surprise you.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. The code wins (see 16).

| # | Kind | Limitation | Confidence |
|---|---|---|---|
| 1 | Drift | Product is *Dasaka* (bus app); code name *Silver Sentinel*. web/CLAUDE.md still says "regulatory compliance", which doesn't match | verified text, cause suspected |
| 2 | Drift | READMEs link `dasaka-*` repos (stale); `git-guidelines.md` still says `code-name-*`, short code `CN`, prefixes `*CN` (should be `silver-sentinel-*`, `SS`, `*SS`) | verified |
| 3 | Drift | `git-guidelines.md` says `code-name-app` for Android; decided `silver-sentinel-android` | verified |
| 4 | Template | `git-guidelines.md` still says "replace `code-name`", `<feature1>`; contains mis-encoded characters (`â€”`) | verified |
| 5 | Deferred | Stack, DB, setup, Figma/Discord links all `TO BE DECIDED` / `[ADD LINK]` | verified |
| 6 | Deferred | Owner `[NAME]` and team roles `[ROLE]` unassigned | verified |
| 7 | Deferred | Login, saved routes, report confirmation are "if time allows" | verified |
| 8 | Security | `android` repo has no `.gitignore` | verified |
| 9 | Process | `beta`/`release` branches, CI, tests don't exist | verified |
| 10 | Process | Root `silver-sentinel-ecosystem` isn't a git repo; `handoff.md` and root `CLAUDE.md` are untracked | verified |

## Redesign candidates

None; nothing is built. Resolve #1–#3 first; every later document depends on them.
