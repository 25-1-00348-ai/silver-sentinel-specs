# 03 — Code Style

**Purpose:** conventions for code and commits. Commit rules are real (from `git-guidelines.md`); language/tooling rules are pending because no stack is chosen.

**Confidence note:** verified against specs `2c3edff`, api `b4a1776`, android `7b7754e`, web `e5ccb8f` on 2026-11-12. The code wins (see 16).

## Commit messages (verified from git-guidelines.md)

Format: `scope: Imperative summary` — lowercase scope, sentence case, **≤50 chars**, no trailing period, imperative ("Add", not "Added").

1. Body optional; blank line 2 required if present. *Miss → tools that parse subject/body break.*
2. Wrap body at 72; explain *why*, not what.
3. One scope per commit; split otherwise.
4. Breaking change: `scope:!` plus `BREAKING CHANGE:` trailer.
5. **Never add an AI agent as author/co-author of commits, tags, releases, or PRs** (git-guidelines "Exclusion of AI Agent"). *Miss → violates project policy.*

   ⚠ A harness may inject a `Co-Authored-By` trailer by default. Policy in the repo wins; omit it. (Verified conflict; inferred resolution.)

### Scopes

| Scope | Use |
|---|---|
| `silver-sentinel-api[/feature]:` | back-end |
| `silver-sentinel-web[/feature]:` | web |
| `silver-sentinel-android[/feature]:` | **Android** (user, 2026-11-12; `git-guidelines.md` still says `code-name-app`) |
| `silver-sentinel-specs[/feature or requirements/design/schema/contracts]:` | spec content |
| `db`, `config`, `test`, `docs`, `ci`, `deps` | cross-cutting only |

Features shared across products: `auth`, `sync`, `security`, `backup`, `restore`.

**Resolved (2026-11-12, user):** product name **Dasaka**; code name **`silver-sentinel`** (so `code-name` in `git-guidelines.md` means `silver-sentinel`); tag short code **`SS`**; Android scope uses `-android`. `git-guidelines.md` itself is not yet edited (see 15 #4).

## Pending (fill when the stack exists)

Comment philosophy (the *why*, at the line), tooling/linting, naming, error handling, logging, anti-patterns with the cost that banned each.
Baseline rule already agreed: no secrets in git; `.env` in `.gitignore` (api README).
