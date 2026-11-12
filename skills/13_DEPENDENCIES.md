# 13 — Dependencies

**Purpose:** why each dependency exists and what rejections to remember.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. No manifests exist; stack is "TO BE DECIDED" in all three READMEs. The code wins (see 16).

## Policy (proposed)

Each dependency gets a row: reason, upgrade traps, alternatives rejected. Record in the same change that adds it. *Miss → nobody knows why it is there and nobody dares remove it.*

| Dependency | Reason | Traps | Rejected alternatives |
|---|---|---|---|
| Supabase (**unverified**) | named in api/CLAUDE.md | — | — |

Commit scope for dependency bumps: `deps`.
