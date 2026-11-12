# 04 — Change Rules

**Purpose:** what must change together. Read before editing anything shared across repos.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. No code exists, so these sets are **inferred candidates** from the planned architecture; convert each to real file paths when files exist. The code wins (see 16).

## Lockstep sets (candidate)

### L1 — API route contract (api ↔ web ↔ android ↔ specs)
1. Route/payload in the API (planned: `/buses/nearby`, `/buses/{id}`, `/routes`, `/reports`, `/reports/{id}/confirm`, `/auth/login`).
2. Web client call site.
3. Android client call site.
4. Spec: `silver-sentinel-specs/contracts`.
*Miss → the other client breaks at runtime; two clients ship on different schedules, so there is no compile-time check.*

### L2 — Database schema ↔ API ↔ spec schema
1. Migration (location TBD).
2. API model/queries.
3. `silver-sentinel-specs/schema`.
*Miss → API errors on missing columns or silently drops new fields.*

### L3 — Report status vocabulary
README lists report types: on time, delayed, full, breakdown, plus a crowding indicator. These values must match across DB, API, web, and Android. *Miss → a client renders an unknown status blank.* (Inferred.)

### L4 — Release tag prefix ↔ repo
`WSS`/`BSS`/`ASS`/`SSS` tied to web/api/android/specs. *Miss → wrong product tag, and tags are never moved (see 10), so it is permanent.*

### L5 — Repo/code names (docs ↔ scopes ↔ links)
README links (`dasaka-*`, stale) vs directory names and commit scopes (`silver-sentinel-*`). See 01 conflict #2.

## Hidden dependencies / high-risk areas

Auth (`/auth/login`, "if time allows") touches every client; treat as high risk when it arrives. Nothing else known.

## Retest after a change

Not defined yet; see 11.
