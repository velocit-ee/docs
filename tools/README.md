# tools — keeping docs.velocit.ee in sync with velocit-ee/core

Two pieces live here, both aimed at preventing the docs site from
drifting out of step with the engines it documents:

1. **`render_engine_status.py`** — regenerates marker-delimited regions
   in the docs (engine status pills + tables) from `engines.json`. Same
   script and data file as `velocit-ee/core` and `velocit-ee/.github`.
2. **`sync_external.sh`** — fetches the canonical `CHANGELOG.md` (and a
   copy of `engines.json`) from `velocit-ee/core` into
   `docs/_external/` so the `mkdocs-include-markdown` plugin can pull
   them in at build time.

Together they make the docs site a near-zero-maintenance surface: edit
`engines.json` (or update the CHANGELOG) in `velocit-ee/core`, and
docs.velocit.ee picks up the change on its next build.

## Cloudflare build command

The Cloudflare Workers Static Assets deploy must run `sync_external.sh`
**before** `mkdocs build` so the changelog include resolves. Update the
Cloudflare project's build command to:

```bash
pip install -r requirements.txt && bash tools/sync_external.sh && mkdocs build --strict
```

`sync_external.sh` falls back to `raw.githubusercontent.com` when no
sibling local checkout exists, which is the case during a Cloudflare
build. No SSH keys or PATs needed.

## Local development

```bash
# One-time: install deps + the pre-commit hook
pip install -r requirements.txt jsonschema pre-commit
pre-commit install

# Iterate
bash tools/sync_external.sh   # refreshes _external/ from your sibling core/ checkout
mkdocs serve                   # live preview at http://localhost:8000
```

If you're editing engine status, do that in `velocit-ee/core/engines.json`
— the canonical source. Then either copy `engines.json` into this repo
manually, or wait for the cross-repo sync workflow (TODO — see
`velocit-ee/core/tools/README.md`).

## What gets regenerated

| Region                | File                                  |
|-----------------------|---------------------------------------|
| `engine-table`        | `docs/index.md`                       |
| `engine-table`        | `docs/what-is-velocitee.md`           |
| `engine-pill-vme`     | `docs/vme/index.md`                   |
| `engine-pill-vne`     | `docs/vne/index.md`                   |
| `engine-pill-vse`     | `docs/vse.md`                         |
| `engine-pill-vle`     | `docs/vle.md`                         |
| (full file include)   | `docs/changelog.md` ← `_external/changelog.md` |

## CI

`.github/workflows/ci.yml` runs:

1. `python tools/render_engine_status.py --check` — fails if any docs
   page has drifted from `engines.json`.
2. `bash tools/sync_external.sh` — fetches latest CHANGELOG.
3. `pytest tools/tests/` — covers the renderer.
4. `mkdocs build --strict` — fails on any warning (broken link, missing
   include, etc.).

## Future work

- **Cross-repo automation**: when `engines.json` changes in
  `velocit-ee/core`, an Action there opens a PR here syncing the file.
  Today this is manual.
- **Pin the CHANGELOG sync to a released tag** instead of `main` so docs
  show the released changelog, not whatever's on the `main` branch.
  Toggle via the `CORE_BRANCH` env var to `sync_external.sh`.
