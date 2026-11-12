# 12 — Performance

**Purpose:** limits and hot paths.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. No code. The code wins (see 16).

## Why this is short

Nothing is built, so no measured limits or deliberate inefficiencies exist.

## Expected hot path (inferred)

`GET /buses/nearby` — called by the live map, likely polled. Watch: polling interval, geo-query indexing (see 07), payload size on mobile data. Record real numbers here after the first measurement.
