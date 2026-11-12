# 08 — API

**Purpose:** contract conventions and route inventory.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. Routes are **planned** (api README: "Endpoints may change once the group agrees on the design"). The code wins (see 16).

## Planned routes

| Method | Path | Purpose | Auth |
|---|---|---|---|
| GET | `/buses/nearby` | nearby buses | undecided |
| GET | `/buses/{id}` | details, arrival time, crowding | undecided |
| GET | `/routes` | list/search routes | undecided |
| POST | `/reports` | submit a bus report | undecided |
| POST | `/reports/{id}/confirm` | confirm a report | likely required |
| POST | `/auth/login` | log in ("if time allows") | none |

## Undefined (decide, then record)

Response envelope, error codes, validators, versioning, how to add an endpoint. Until then: **any route change is a contract change** (04 L1) and goes through `silver-sentinel-specs/contracts`.

## Common mistakes to prevent early

- Letting web and Android assume different field names. *Miss → one client breaks silently.*
- Anonymous `POST /reports` with no abuse control — see 09.
