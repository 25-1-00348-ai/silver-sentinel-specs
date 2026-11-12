# 11 — Testing

**Purpose:** how confidence is gained.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. No tests or CI exist. The code wins (see 16).

## Honest coverage

0%. Nothing to test yet.

## Process (verified from git-guidelines)

| Stage | Who | Branch |
|---|---|---|
| Unit | developers | `main` |
| System | QA, against major product claims | `beta` |
| Integration | independent testers, published bundles only | `release` |
| Production approval | final approver | — |

Per README step 7: try on phone and computer.

## Must be tested once code exists

Contract between API and both clients (04 L1); report status vocabulary (04 L3); behavior with no nearby buses and no GPS permission (inferred). Decide mocking approach and CI, then record here.
