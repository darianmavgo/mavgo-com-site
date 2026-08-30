# CLAUDE.md

Guidance for working in this repo. See `README.md` for the user-facing overview.

## What this is

A **Hugo (extended) static site** for mavgo.com — Darian Hickman's project hub —
deployed to **Cloudflare Pages** (`mavgo-com`). Custom in-repo theme; no external
Hugo theme or module.

## Commands

```bash
hugo server -D            # local dev, live reload, :1313
hugo --minify             # production build -> ./public
hugo version              # confirm the "extended" build (SCSS needs it)
./sync.sh --check         # report GitHub drift in data/projects/*.yaml (no writes)
./sync.sh                 # apply the safe updates (visibility only)
./deploy.sh               # hugo --minify + wrangler pages deploy public/
```

There is no test suite, linter, or CI. "Does it build" = `hugo --minify` exits 0.

## Architecture / where things live

- **Projects are data-driven.** A project = `data/projects/<slug>.yaml` (structured
  fields) + `content/projects/<slug>.md` (stub front matter: `layout: project`,
  `dataKey: <slug>`; Markdown body optional, renders after the generated sections).
  The two slugs must match.
- **URLs**: project pages are authored in `content/projects/` but served from the
  **site root** — `content/projects/banquet.md` → `https://mavgo.com/banquet/`.
  This is the `[permalinks]` rule in `hugo.toml` (`projects = "/:contentbasename/"`).
  `content/projects/_index.md` has `build.render: never` so there is no
  `/projects/` index page. `static/_redirects` 301s the old `/projects/<slug>/`
  URLs to the new ones. Hugo lowercases paths, so `Gen97.md` → `/gen97/`; when you
  build a project link in a template, pipe the key through `| urlize`.
- **Homepage** `layouts/index.html` iterates `hugo.Data.projects`, buckets cards by
  `category` into exactly five groups: `data`, `quant`, `cloud`, `games`,
  `research`. A project with any other `category` builds fine but is invisible on
  the homepage (its own page still works).
- **Project page** `layouts/projects/single.html` (the *only* project template —
  section `projects` + `single.html` is what Hugo resolves) composes partials:
  `hero.html` (badges, title, quickstart code tabs, optional `stats`),
  `feature-grid.html` (`features:` list), then the Markdown body under a
  "Documentation & Architecture" heading, then `ecosystem.html` (`related:` list
  of other project keys).
- **Standalone pages**: `content/{about,work-log,trading-journey,privacy-policy,terms-of-service}/index.md`
  → `layouts/_default/single.html`.
- **Styling**: one file, `assets/css/style.scss`, compiled/minified/fingerprinted
  by Hugo in `_default/baseof.html`. No CSS framework.
- **JS**: one file, `assets/js/main.js` — code tabs, copy button, hamburger menu,
  homepage project search (filters `.project-card` by `data-*` attrs), scroll
  fade-in. Keep it dependency-free vanilla JS.
- **Edge**: `functions/_middleware.js` is a Cloudflare Pages Function that
  301-redirects any path containing uppercase letters to lowercase. `_redirects`
  (static) handles the `/projects/` → root move. Taxonomies are disabled
  (`disableKinds` in `hugo.toml`) — no `/categories/` or `/languages/` pages.

## sync.sh — GitHub → YAML

`sync.sh` uses the authenticated `gh` CLI to reconcile `data/projects/*.yaml`
with the repos under `github.com/darianmavgo`:

- **auto-writes** `visibility:` only (public/private is unambiguous);
- **reports, never writes**, everything editorial — `language` (GitHub's
  byte-count guess is often wrong for installer/generated files), stars, last
  push date, license, `homepageUrl` (candidate for `demo_url:`), archived/fork
  flags, and description-vs-tagline drift;
- lists public source repos that have no `data/projects/*.yaml` yet;
- `./sync.sh --scaffold <repo>` writes a new yaml + content stub to fill in.

It's a manual pre-deploy step, not wired into `deploy.sh`. Curated fields
(`category`, `hero_*`, `features`, `quickstart`, `related`, `tagline`, `title`,
`badge_*`) are never touched.

## Deploy & secrets

- `deploy.sh` scavenges a Cloudflare token from hard-coded `.env` paths on
  Darian's machine, then `npx wrangler pages deploy public/ --project-name mavgo-com`.
- `setup_cloudflare_env.sh`, `get_api_key.sh`, `link_domains.sh`,
  `update_www_dns.sh` are Cloudflare account/DNS setup helpers — occasional, not
  part of a normal deploy.
- `.env.cloudflare` contains **live credentials and is not git-ignored**. Never
  commit it, never print its contents, and flag it if asked to touch `.gitignore`.
- Deploying is outward-facing — only run `./deploy.sh` / `wrangler ... deploy`
  when the user explicitly asks.

## Conventions

- Match the existing YAML field set when adding a project (see
  `data/projects/aggrid.yaml` for the fullest example; `stats`, `demo_url`,
  `quickstart`, `related` are all optional). Or run `./sync.sh --scaffold`.
- Slugs are lowercase-hyphenated; the middleware + Hugo both enforce lowercase URLs.
- `visibility: public` + a `github:` URL is what gates the "View on GitHub" button
  and the external-link icon on cards.
- Git: the repo currently has **no tracked files** (the old "Initial crawl" of
  Google-Docs-viewer HTML was removed; the real site was never committed). Branch
  before committing; commit/push only when asked.
