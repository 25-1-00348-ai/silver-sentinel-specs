# 10 — Deployment, Branching and Releases

**Purpose:** how code moves to production and how tags are named. This is the most concrete part of the project today.

**Confidence note:** verified against `silver-sentinel-specs/git-guidelines.md` (specs `2c3edff`) on 2026-11-12. Hosting/deploy targets are unknown. The code wins (see 16).

## Branch model

`main` (dev, unit tests) → `beta` (QA system testing) → `release` (published bundle, independent testing) → production, each gated.

1. Promote only after the gate passes; reviewed merges only.
2. Tag candidates **from `release` only**; never from `main`/`beta`. *Miss → testers validate code that was not what shipped.*
3. Never move or reuse a tag. *Miss → the audit trail of what was tested is gone.*
4. Fixes made on `beta`/`release` must be merged/cherry-picked back upstream. *Miss → regression on the next promotion.*

⚠ READMEs say "branch, PR into `main`". Consistent with the above; `beta`/`release` do not exist yet in any repo (verified: one branch each).

## Tags

Format `<prefix>.0X.Y.00Z[label]`, e.g. `WSS.01.0.017rc2`. Short code `SS` (user, 2026-11-12). Prefixes: `WSS` web, `BSS` api, `ASS` android, `SSS` specs. Never normalize (`01.0.001`, not `1.0.1`).

| Part | Rule |
|---|---|
| `0X` | new approved breaking requirements; resets `Y`=0, `00Z`=001 |
| `Y` | maintenance lifecycle after a production deploy; resets `00Z` |
| `00Z` | weekly build; one per ISO week that has commits |
| label | `a` → `b` → `rc`; first has no suffix, retries `a2`, `a3`; suffix resets on advance |

### Weekly tagging rules

1. First tag (`001`) on the ISO week of the first commit.
2. No commits that week → no tag, no number consumed.
3. **No tag before Friday 17:00 local** for the current week. *Miss → later commits land in an already-tagged week.*
4. Tag points to the week's last commit (committer date).
5. Never retag; fill missing weeks earliest first; stay chronological.

Current state: no tags in any repo (git-guidelines tables are empty; next is `WSS`/`BSS`/`ASS`/`SSS.01.0.001`; `git-guidelines.md` tables still show the old `*CN` prefixes). Labels only after development is 100% complete.

## Release order across components

**Undefined.** Likely API before clients (clients depend on it, 04 L1). Decide and record.

## Checklist

[ ] QA accepted on `beta` · [ ] bundle published from `release` · [ ] tag from `release` · [ ] final approver signed off · [ ] deploy the *exact* `rc`.
