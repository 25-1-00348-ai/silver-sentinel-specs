# 06 — Failure Stories

**Purpose:** incidents and the lessons behind rules. Read when tempted to remove a guard.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. Each repo has two commits (`Initial commit`, `Add README`); there are no fixes, reverts, or incidents. The code wins (see 16).

## Stories

_None yet._ Nothing has shipped, so nothing has failed.

## Format for new entries

Number each (`#1`, `#2`…). Include: **What happened · Why · How found · Fix · Lesson · Confidence in reconstruction.** Link from 04, 05, 16.

## Near-miss worth recording (inferred, not an incident)

**#0 — Name drift.** Docs used *Dasaka* (product) and *Silver Sentinel* (code name) interchangeably, with `code-name-*` and `dasaka-*` placeholders besides, and web/CLAUDE.md describes "regulatory compliance" for what the README says is a bus app. Not an outage, but a spec written for the wrong product is the cheapest bug to prevent now. See 01.
