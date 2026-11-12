# 07 — Database

**Purpose:** schema rules and dangerous operations.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. There is no schema or migration. api/CLAUDE.md mentions Supabase; api README says "TO BE DECIDED". The code wins (see 16).

## Known

| Item | State |
|---|---|
| Engine | Supabase named in api/CLAUDE.md (**unverified**; README undecided) |
| Tables | none; domain implies buses, routes, reports, confirmations, users (inferred) |
| Migrations | none; location undecided |

## Decisions needed (record in 01 as they are made)

1. Identity strategy (UUID vs serial); which ids clients may see.
2. Delete policy (soft vs hard). Reports are crowdsourced, so history likely matters.
3. Migration tool and where it lives (api repo vs specs `schema`).
4. Who may write directly: if Supabase row-level security is used, policies become a lockstep set with the API (04 L2, 09).

## Rule (carried from git-guidelines)

Schema doc changes use commit scope `silver-sentinel-specs/schema`; DB-only code changes use `db`.
