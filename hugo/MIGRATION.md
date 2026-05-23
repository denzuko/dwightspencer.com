# Hugo Migration Guide — dwightaspencer.com

## Structure

```
hugo/                         ← Hugo project root
├── hugo.toml                 ← Site config, all params centralised
├── archetypes/
│   └── posts.md              ← Front matter template for new posts
├── content/
│   ├── _index.md             ← Home page (Lisp finger block lives here)
│   └── posts/                ← One .md file per post
├── layouts/
│   ├── index.html            ← Home page layout (whoami/finger/recent)
│   ├── index.json            ← JSON feed
│   ├── 404.html              ← 404 page
│   ├── _default/
│   │   ├── baseof.html       ← Base HTML wrapper
│   │   ├── single.html       ← Single post layout (h-entry)
│   │   └── list.html         ← Post list / tag pages (h-feed)
│   └── partials/
│       ├── head.html         ← All <head> metadata (DC, OGP, Twitter, AEO)
│       ├── css.html          ← Single source of truth for all CSS
│       ├── schema.html       ← Schema.org JSON-LD
│       ├── header.html       ← Site nav header + hr
│       └── footer.html       ← Policy links + copyright
├── static/                   ← Files copied verbatim to output root
│   └── .well-known/          ← Symlink or copy from repo root
└── .github/
    └── workflows/
        └── hugo.yml          ← Build + deploy to gh-pages on push to master
```

## Adding a new post

```bash
cd hugo
hugo new posts/04-watchers-you-fed.md
# Edit content/posts/04-watchers-you-fed.md
# Set draft = false when ready
hugo server -D  # preview with drafts
git add content/posts/04-watchers-you-fed.md
git commit -m "feat: add post 04 — The Watchers You Fed chapter preview"
git push origin master
# GitHub Actions builds and deploys automatically
```

## Front matter reference

```toml
+++
title       = "Article Title"
date        = "2026-05-23"
draft       = false
description = "One-sentence description for meta/OGP/RSS."
slug        = "custom-slug"          # overrides URL slug if needed
keywords    = ["tag1", "tag2"]
tags        = ["privacy", "devops"]
categories  = ["articles"]
schema_type = "TechArticle"          # TechArticle | BlogPosting
aeo_expertise = "Privacy, Security"  # overrides default in head partial
og_image    = "/assets/og-posts.png"
+++
```

## Migrating existing posts (posts 00–03)

Each existing `posts/NN-slug/index.html` becomes `hugo/content/posts/NN-slug.md`:
1. Extract front matter values from the existing `<meta>` tags
2. Extract body content from `<section>` → paste as Markdown (or raw HTML)
3. Hugo's goldmark renderer has `unsafe = true` so raw HTML passthrough works
4. Delete the old static `posts/NN-slug/index.html` once Hugo output matches

## Static files

Files in `hugo/static/` are copied verbatim. The following should be present:
- `.well-known/` (canary.txt, pgp-key.txt, funding.json, etc.)
- `assets/` (favicon.ico, og-posts.png, twitter-posts.png, og-default.png)
- `ai.txt`, `llms.txt`, `humans.txt`, `CNAME`, `robots.txt`

Note: `robots.txt` in `hugo/static/` will override Hugo's generated one.
Keep it in static/ so it stays under explicit version control.

## GitHub Actions

Push to `master` → Hugo builds from `hugo/` → deploys to `gh-pages` branch.
Cloudflare serves from `gh-pages`. The `CNAME` file in `hugo/static/` ensures
the custom domain persists across deploys.

## Warrant canary renewal (quarterly)

```bash
gpg --clearsign .well-known/canary.txt
mv .well-known/canary.txt.asc .well-known/canary.txt
# update Issue date in the file
git add .well-known/canary.txt
git commit -S -m "chore: renew warrant canary (YYYY-QN)"
git push origin master
```
