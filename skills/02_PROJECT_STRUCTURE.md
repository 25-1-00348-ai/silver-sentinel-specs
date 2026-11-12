# 02 — Project Structure

**Purpose:** where things live and where new code goes.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. Source trees are empty, so only the top level is real. The code wins (see 16).

## Tree (verified)

```
silver-sentinel-ecosystem/          # NOT a git repo; just a parent folder
  CLAUDE.md                         # tells agents which child docs to read first
  handoff.md                        # the instructions that generate these skills
  silver-sentinel-api/              # own git repo: README, CLAUDE.md, .gitignore
  silver-sentinel-android/          # own git repo: README, CLAUDE.md
  silver-sentinel-web/              # own git repo: README, CLAUDE.md, .gitignore
  silver-sentinel-specs/            # own git repo
    CLAUDE.md, README.md, git-guidelines.md
    skills/                         # this folder
```

## Rules

1. The ecosystem root is **not** a repository. Run git inside each child. *Miss → `git` says "not a git repository" or, worse, you commit to the wrong repo.*
2. Skills live in `silver-sentinel-specs/skills/` (handoff.md; root CLAUDE.md reads `*-specs/skills/*.md`).
3. Where new code goes inside api/web/android: **undecided** (no stack chosen). Record the layout here when it is.
4. `INBOX.md` is the only non-numbered file in `skills/`.

## Naming that carries meaning

| Name | Meaning |
|---|---|
| `NN_TOPIC.md` | numbered skill doc; never renumber (append only) |
| `WSS/BSS/ASS/SSS` | release tag prefixes: Web / Backend / Android / Specs, short code `SS` (see 10) |
| `silver-sentinel-*` | code name used for repos, commit scopes and tags; the product is **Dasaka** |
