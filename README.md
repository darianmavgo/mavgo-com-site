# mavgo.com

The source for **[mavgo.com](https://mavgo.com/)** — the personal software hub of
Darian Hickman. It's a [Hugo](https://gohugo.io/) static site that catalogs ~33
open-source projects (data/SQLite tooling, quantitative-finance backtesters,
cloud/AI utilities, web games, and civic-tech research) and is deployed to
Cloudflare Pages.

## Stack

| Piece | Choice |
|-------|--------|
| Site generator | Hugo **extended** (built with v0.165.0) — SCSS needs the extended build |
| Theme | Custom, in-repo (`layouts/` + `assets/`) — no external theme or module |
| Hosting | Cloudflare Pages, project `mavgo-com`, domains `mavgo.com` + `www.mavgo.com` |
| Edge logic | One Cloudflare Pages Function (`functions/_middleware.js`) |
| Deploy tool | `wrangler` via `npx` (no local install required) |

## Prerequisites

- **Hugo extended** ≥ 0.128 — `brew install hugo`
- **Node.js** (for `npx wrangler`) — only needed to deploy
- A Cloudflare API token with Pages permissions (for deploys)

## Local development

```bash
hugo server -D        # live-reload dev server at http://localhost:1313
hugo --minify         # production build into ./public
```

`public/` and `resources/` are build artifacts and are git-ignored.

## Content model

Each project has **two files** that share a slug:

- `content/projects/<slug>.md` — a stub with front matter
  (`layout: project`, `dataKey: <slug>`) plus optional long-form Markdown that
  renders below the generated sections.
- `data/projects/<slug>.yaml` — the structured data (tagline, category, language,
  GitHub URL, hero copy, feature cards, quickstart tabs, related projects).

The homepage (`layouts/index.html`) reads every YAML file and groups the cards by
`category`: `data`, `quant`, `cloud`, `games`, `research`.

Standalone pages live under `content/` as well: `about/`, `work-log/`,
`trading-journey/`, `privacy-policy/`, `terms-of-service/`.

### URLs

Project pages are authored in `content/projects/` but published at the **site
root**: `content/projects/banquet.md` → `https://mavgo.com/banquet/` (the
`[permalinks]` setting in `hugo.toml`). There is no `/projects/` index page; the
project list *is* the homepage grid (`/#projects`). `static/_redirects` 301s the
old `/projects/<slug>/` URLs to the new flat ones.

### Add a project

1. `./sync.sh --scaffold my-project` — creates `data/projects/my-project.yaml`
   and `content/projects/my-project.md` pre-filled from the GitHub repo. (Or copy
   `data/projects/aggrid.yaml` by hand for the full field set.)
2. Fill in `category` (one of the five values above), `hero_eyebrow`, `features`,
   and `quickstart`.
3. `hugo server -D` and check `http://localhost:1313/my-project/`.

## Keeping project data in sync with GitHub

```bash
./sync.sh --check   # report drift vs github.com/darianmavgo, write nothing
./sync.sh           # apply the safe updates (visibility only)
```

`sync.sh` compares each `data/projects/*.yaml` against its GitHub repo. It only
auto-writes `visibility` (public/private). Everything editorial — language, stars,
last-push date, license, homepage, archived/fork status, description drift — is
**reported for you to review**, never overwritten. It also lists public repos
that don't have a project file yet. Requires an authenticated `gh` CLI.

## Deployment

```bash
./deploy.sh
```

`deploy.sh` locates a Cloudflare API token from a few known `.env` paths, runs
`hugo --minify`, then `npx wrangler pages deploy public/ --project-name mavgo-com`.
The site is live at https://mavgo.com/ after Cloudflare finishes rolling the
deployment.

### One-time / occasional Cloudflare setup scripts

| Script | Purpose |
|--------|---------|
| `setup_cloudflare_env.sh` | Pull an OAuth token out of the local `wrangler` session into `.env.cloudflare` |
| `get_api_key.sh <KEY>` | Save a Cloudflare Global API key + email to `.env.cloudflare` (for `flarectl`) |
| `link_domains.sh` | Attach `mavgo.com` and `www.mavgo.com` as Pages custom domains |
| `update_www_dns.sh` | Point `www.mavgo.com` at `mavgo-com.pages.dev` via `flarectl` |

> **Security note:** `.env.cloudflare` holds live credentials and is **not** in
> `.gitignore`. Don't commit it — add it to `.gitignore` or keep secrets outside
> the repo.

## Repository layout

```
content/             Markdown content (projects + standalone pages)
  projects/            <slug>.md stubs + _index.md (render: never)
data/projects/       One YAML file per project (structured data)
layouts/             Custom Hugo templates
  index.html           Homepage: category-grouped project grid + search
  projects/single.html Project page (hero, feature grid, body, related)
  _default/            baseof, single, list
  partials/            nav, footer, hero, feature-grid, ecosystem
assets/
  css/style.scss       Single SCSS stylesheet (compiled + fingerprinted by Hugo)
  js/main.js           Tabs, copy-to-clipboard, mobile menu, project search, fade-in
static/
  favicon.svg          Copied verbatim
  _redirects           Cloudflare Pages redirects (/projects/* → root)
functions/             Cloudflare Pages Functions (_middleware.js: lowercase redirect)
hugo.toml              Site config
sync.sh                Reconcile data/projects/*.yaml with GitHub
deploy.sh              Build + deploy to Cloudflare Pages
```
