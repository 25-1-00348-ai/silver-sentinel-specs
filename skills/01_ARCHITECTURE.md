# 01 — Architecture

**Purpose:** the mental model of the ecosystem and its decisions. Read first.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. Everything below is **from READMEs/CLAUDE.md only** — no code exists. The code wins (see 16).

## Model

Four repos form one ecosystem: an API that mediates between clients and a database, a web client, an Android client, and a specs repo that holds documents and conventions. Clients talk only to the API (README of web/android: "Talks to: dasaka-api", i.e. `silver-sentinel-api`).

## Components

| Component | Dir | Owns | Status |
|---|---|---|---|
| API | `silver-sentinel-api` | Business logic; sits between clients and the Supabase database API (api/CLAUDE.md) | README only |
| Web | `silver-sentinel-web` | Browser UI | README only |
| Android | `silver-sentinel-android` | Mobile UI | README only |
| Specs | `silver-sentinel-specs` | Requirements, design, conventions, these skills | README + git-guidelines |

## Data flow (planned, inferred)

client → `silver-sentinel-api` REST (`/buses/nearby`, `/buses/{id}`, `/routes`, `/reports`, `/reports/{id}/confirm`, `/auth/login`) → Supabase → back. See 08.

## Hard boundaries

- Clients never talk to the database directly (inferred from api/CLAUDE.md; **unverified intent**).
- Never commit secrets; use `.env` listed in `.gitignore` (api README).
- Never commit directly to `main` (all READMEs). Branch model in 10.

## Decision records

### Decision: Supabase as database layer (unknown date, unknown author)
**Status:** proposed — conflicts with api README ("Database: TO BE DECIDED").
**Context:** api/CLAUDE.md names a "Supabase database API". **Choice:** Supabase. **Alternatives:** undecided. **Consequences:** auth and row-level security options come with it; see 09.

### Decision: Maturity-based branching `main` → `beta` → `release` (see 10)
**Status:** accepted (`git-guidelines.md`). **Consequence:** READMEs say "branch + PR into `main`"; both can hold, `main` is just dev.

## ⚠ Open conflicts (resolve before coding)

1. **Naming (resolved, user 2026-11-12).** Product = **Dasaka** (crowdsourced bus app, CSIT 105). Code name = **Silver Sentinel** (repos, scopes, tags). **Still open:** web/CLAUDE.md says "regulatory compliance", which does not match a bus app; probably stale (suspected, unverified).
2. **Repo names.** Repos are `silver-sentinel-*`. READMEs still link `dasaka-*` (stale placeholders) and git-guidelines still says `code-name-*`. See 15.
3. **Android scope (resolved).** Use `silver-sentinel-android`; git-guidelines still says `code-name-app`. Tag short code is `SS` (prefixes `WSS/BSS/ASS/SSS`). See 03, 10.

## Inherited tradeoffs / debt register (ranked)

1. Stale "regulatory compliance" description in web/CLAUDE.md (above) — wrong specs get built.
2. No stack chosen for any component.
3. `git-guidelines.md` still has `code-name`/`<feature1>` placeholders.
