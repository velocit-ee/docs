# velocit-ee/docs

Source for [docs.velocit.ee](https://docs.velocit.ee). Built with
[MkDocs Material](https://squidfunk.github.io/mkdocs-material/), deployed
to Cloudflare Pages on every push to `main`.

## Local development

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Open <http://127.0.0.1:8000>. Live-reload picks up changes as you edit.

## Deployment

`.github/workflows/deploy.yml` runs `mkdocs build --strict` on every PR and
deploys to Cloudflare Pages on push to `main`. Two repository secrets are
required:

- `CLOUDFLARE_API_TOKEN` — scoped to `Pages:Edit` for the velocitee account.
- `CLOUDFLARE_ACCOUNT_ID` — the account id from the CF dashboard.

## Custom domain

`docs.velocit.ee` is configured as a custom domain on the `velocitee-docs`
Cloudflare Pages project. DNS is in the same Cloudflare zone as
`velocit.ee` itself.

## Structure

```
docs/
  index.md                      # landing page
  what-is-velocitee.md
  getting-started.md
  vme/                          # synced from velocit-ee/core/docs/vme/
  vne/                          # canonical here
  architecture/
  reference/
  contributing/
  changelog.md                  # synced from velocit-ee/core/CHANGELOG.md
  commercial-license.md         # synced from velocit-ee/core/docs/
  assets/
    favicon.svg, logo.svg, velocitee.css
overrides/                       # custom MkDocs Material partials
mkdocs.yml                       # site config + nav
requirements.txt                 # build dependencies
```

## Sync from velocit-ee/core

A few files originate in the [core](https://github.com/velocit-ee/core)
repo and are mirrored here:

- `vme/getting-started.md`, `vme/compatibility.md` ← `core/docs/vme/`
- `commercial-license.md` ← `core/docs/commercial-license.md`
- `changelog.md` ← `core/CHANGELOG.md`

For now the sync is manual — copy on update. A future GitHub Action will
automate it.

## Style

- IBM Plex Mono / Sans (loaded via Google Fonts in the Material theme).
- Palette in `docs/assets/velocitee.css`. Two schemes — `velocitee-dark`
  (default) and `velocitee-light`.
- Headings render with `# ` / `## ` prefixes — terminal-flavoured to match
  the landing page.

## License

MIT for the docs build configuration; documentation content under Apache 2.0
in line with the engines themselves.
