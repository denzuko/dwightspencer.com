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

## Backlog

### v2 — Dynamic per-post OG images
Currently all posts share `og-posts.png`. Per-post cards with the article
title injected would significantly improve click-through for shared articles.

**Approach:**
- Add a Hugo layout `layouts/partials/og-image.html` that renders an HTML
  card with `{{ .Title }}`, `{{ .Params.description }}`, and the tag line
- GitHub Actions step: Playwright screenshots each post's OG template during
  build, outputs to `public/assets/og/{{ .Slug }}.png`
- `head.html` updated: `og:image` points to post-specific PNG if it exists,
  falls back to `/assets/og-posts.png`

**Priority:** High — implement after post volume justifies the CI build time
(suggest trigger at 10+ posts)

### v2 — Professional OG variant
`og-default.png` (fingerprint card) is optimized for hacker/researcher
audience. Add `og-professional.png` with name + credential string more
prominently laid out for LinkedIn/professional context shares.

**Approach:** Second HTML template, same Playwright pipeline. One param in
`hugo.toml` (`params.ogVariant = "professional"`) to switch the home page
meta tag.

### v2 — /now page
Standard "what I'm working on right now" page (nownownow.com convention).
Fits the personal publishing positioning. Low maintenance — update quarterly
alongside the warrant canary.

### v2 — /projects page
Archive of active and historical projects with status indicators. Pulls from
the Lisp block `:Projects` list and expands it. Gives the expert witness and
MSP audience a structured view of technical work without requiring them to
read the Lisp.

### v2 — Plausible Analytics A/B integration
Privacy-respecting cookieless analytics (no consent banner required).
Planned A/B test against Cloudflare aggregate analytics. When enabled:
- Add `<script defer data-domain="dwightaspencer.com" src="https://plausible.io/js/script.js"></script>` to baseof.html
- Update privacy/cookies policy pages accordingly
- No other changes required

### v2 — /uses page
Tools, hardware, and infrastructure stack. Useful for HPR/aNONradio audience
who asks "what do you run." Feeds the Infrastructure Independence series.

### v3 — Hugo CMS integration (Decap/Forestry successor)
For non-code content updates (warrant canary renewal, media archive updates)
without requiring a full git workflow. Low priority — current git workflow
is acceptable for the volume.

---

## v2.5 — Research & Compliance Layer

### OSCAL Components
Yes — worth doing for Da Planet Security commercial positioning. Each post
that documents a security control, telemetry loop, or audit capability maps
to an OSCAL component. The component JSON lives in the Da Planet Security
git instance; dwightaspencer.com posts link to it via front matter:

```toml
oscal_component = "https://git.daplanetsecurity.com/oscal/components/telemetry-loop.json"
commercial_asset = "Da Planet Security Managed Core (Telemetry Engine)"
```

Hugo shortcode renders a "compliance context" block on qualifying posts.
Entity separation maintained: OSCAL refs point to Da Planet Security infra,
never appear in RT4 content.

### NIST 800-53 / CMMC / FedRAMP taxonomy
Technical posts mapped directly to controls via front matter:

```toml
nist_controls  = ["AC-3", "AU-10", "SI-4"]
cmmc_level     = "Level 3"
fedramp_impact = "Moderate"
```

Hugo taxonomy: `nist_controls` as a multi-value taxonomy generates
`/nist/AC-3/`, `/nist/AU-10/` etc. — machine-readable control coverage
map. Valuable for federal contracting pipeline (SAM.gov SIN 54151S,
NAICS 541513). The corpus Prolog facts gain a `(control slug nist-id)`
fact schema — query all posts covering a given control family.

### arXiv
Yes — add ORCID-linked arXiv author page to social links and webfinger
`aliases`. Posts that have a corresponding preprint get `arxiv_id` front
matter. Hugo generates `<link rel="canonical">` and Schema.org
`sameAs` pointing to the arXiv abstract. Feeds the expert witness and
academic citation positioning.

### Crossref / DOI
Yes for the book and any formal publications. DOI registration via
Crossref for *The Watchers You Fed* chapters published as preprints.
`doi` front matter field → Schema.org `identifier`, citation block
in post footer, machine-readable in corpus Prolog facts as
`(publication slug doi)`. The `/lisp/corpus.lisp` query API gains
`find-by-doi`.

### Hugo Taxonomies to add
Current: tags, categories
Add:
- `nist_controls` — NIST 800-53 control IDs
- `series` — post series grouping (Infrastructure Independence,
  GRID_BREAK_518, The Watchers You Fed chapters)
- `venue` — arXiv, KDP, HPR episode, conference
- `cmmc_level` — for Da Planet Security commercial posts only
