# 09 — Security

**Purpose:** rules that protect users and secrets.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. No code; items marked *inferred* are risks from the planned design. The code wins (see 16).

## Verified rules

1. **No secrets in git.** Keep them in `.env`, listed in `.gitignore` (api README). `api` and `web` have a `.gitignore`; **`android` has none** — add one before the first build. *Miss → keystores and `local.properties` get committed.*
2. Document env var *names* only, never values (handoff standards).
3. Never commit directly to `main`; PR review is the gate (READMEs).

## Inferred risks

| Risk | Why |
|---|---|
| Crowdsourced reports can be spoofed/spammed | `/reports` is user-submitted; "confirm a report" is the planned mitigation, but is "if time allows" |
| Location data is personal | `/buses/nearby` implies client coordinates; avoid logging them |
| Database exposed directly | If Supabase is used, API keys in clients grant direct access unless row-level security is on (see 07) |

## Change checklist

Does it add a route? An input? A secret? A log line with user location? Update this doc and 04 if yes.
