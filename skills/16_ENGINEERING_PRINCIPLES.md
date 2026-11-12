# 16 — Engineering Principles

**Purpose:** short, quotable rules and the reasons behind them.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. These are **seed principles**, drawn from stated project rules, not from incidents. Promote proven ones from `INBOX.md`. The code wins (see 16).

1. **Every rule names what breaks.** A rule without a reason gets deleted by the next person. *Source: handoff.md.*
2. **One name per thing.** Product and repo naming drifted three ways before any code existed (15 #1–#3). Pick one and use it everywhere. *Source: 06 #0.*
3. **Never move a tag.** Tags are the record of what was tested and shipped (10). *Source: git-guidelines.*
4. **Promote through gates, never around them.** `main` → `beta` → `release` (10).
5. **Secrets never enter git.** Names in docs, values in `.env` (09).
6. **Contracts change in lockstep.** One API change touches web, Android and specs together (04 L1).
7. **Retire, don't delete.** Superseded knowledge stays, labelled, so nobody revives it.
8. **Trust the code over any document, including this one.**

_Later principles are appended below this line._
