# 14 — Developer Workflows

**Purpose:** recipes for common tasks.

**Confidence note:** verified against READMEs and `git-guidelines.md` (specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f`) on 2026-11-12. Setup steps are blank in every README. The code wins (see 16).

## Setup

Not documented (`[ADD INSTRUCTIONS]` in api, android, web). Fill in once a stack is chosen.

## Recipe: make a change

1. Pick an Issue. 2. Pull latest `main`. 3. Branch (`feature/<name>`). 4. Commit per 03. 5. Open a PR. 6. A teammate approves. 7. Merge to `main`.
*Miss (committing to `main`) → bypasses review; all READMEs forbid it.*
Use your own GitHub username on commits so they are traceable. Do not add an AI as author (03).

## Recipe: change an API contract

Follow 04 L1 in one change set; PRs in each repo should reference each other. Guards against a client breaking silently.

## Recipe: cut a weekly tag

See 10, "Weekly tagging rules". Never before Friday 17:00 local.

## Recipe: update these skills

Process `INBOX.md`, diff code since each confidence note, append don't renumber.

Add what surprised you to `INBOX.md`.
