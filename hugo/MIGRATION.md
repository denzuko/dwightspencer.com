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

### ✅ Favicon — eye in lens mark (DONE 2026-05-23)
Three SVG variants at `hugo/static/assets/`:
- `favicon-a.svg` — full barrel, 25° diagonal eye
- `favicon-b.svg` — cropped, lens overflows frame (Warhol crop)
- `favicon-c.svg` — iris only, no barrel (simplest, best at 16px)
- `favicon.svg` — active (currently A); copy target file content to rotate
- `favicon-192.png` — PWA manifest 192px raster ✅
- `favicon-512.png` — PWA manifest 512px raster ✅

Rotation schedule — update alongside quarterly warrant canary + /now:
- Q1 (Jan): A (full barrel)
- Q2 (Apr): B (cropped)
- Q3 (Jul): C (iris only)
- Q4 (Oct): A (full barrel)

Footer logo: `favicon.svg` at 32×32, inverted in dark mode via CSS filter.

### ✅ Brand submodule — stream-assets (DONE 2026-05-24)
`denzuko/stream-assets` added as git submodule at `brand/`.
GH Actions copies `brand/static/css/brand.css` → `hugo/static/css/brand.css`
and `brand/data/brand.yaml` → `hugo/data/brand.yaml` before each build.
`brand.css` imported in `head.html` — all CSS custom properties sourced
from one canonical file shared across the persona ecosystem.
Brand guide live at `denzuko.github.io/stream-assets/brand/`.

### ✅ Self-hosted fonts (DONE 2026-05-25)
Google Fonts removed. No external font requests, no tracking, no GDPR exposure.
Fonts served from `/fonts/` via `fonts.css`:
- `bricolage-grotesque-latin.woff2` — primary latin subset (variable, 200–800)
- `bricolage-grotesque-latin-ext.woff2` — extended latin
- `bricolage-grotesque-vietnamese.woff2` — vietnamese subset
- `share-tech-mono-400.woff2` — Share Tech Mono 400
Same font files also in `denzuko/stream-assets` — both repos now fully offline-capable.

### ✅ v1.5 — Pagefind site search (DONE 2026-05-23)
Self-hosted, zero external deps, no Algolia. Privacy positioning intact.
- GH Actions: `npx --yes pagefind --site public --output-path public/pagefind` after hugo build
- Search UI: `hugo/layouts/partials/search.html` — lazy-loaded on toggle, Escape to close
- Toggle button `⌕` in header nav (`header.html`)
- CSS in `css.html` — dark mode aware, print hidden
- `corpus.lisp` already references `/pagefind/pagefind.js` as `+search-index+` constant

### ⚠️ hack.dapla.net status (verified 2026-05-23)
`https://hack.dapla.net` returns HTTP 503. SSH port 22 unreachable.
Post 00 (`00-hellowrld.md`) references it as present-tense: "Thanks to Soft Serve one can find..."
**Action needed:** Update post 00 to past tense and note planned return as Soft Serve + 3270 BBS/CICS.
Each state change is an editorial opportunity — draft a short status note post when the service returns.

### ⚠️ Canarytail project status (verified 2026-05-23)
`github.com/canarytail` org does not resolve — org appears deleted.
`canarytail.org` returns no response.
Post 01 (`01-a-better-tweedy-bird.md`) links to `https://github.com/canarytail/standard`.
**Action needed:** Update post 01 to note the project as defunct/archived and link to
the Wayback Machine snapshot or remove the link. Mention the standard's fate in the editorial voice.

### ✅ Layer 2 — Quicklisp dist (FULLY RESOLVED 2026-05-24)
**Mechanism:** `<link rel="alternate" type="application/vnd.quicklisp-dist">` in `<head>`.
Survives `hugo --minify`. Visible in view-source. HTML comments do not survive minification.

**Correct REPL session:**
```lisp
(ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
(ql:quickload :DwightASpencerCom)
(DwightASpencerCom:finger)
```

**Live endpoints verified 2026-05-24:**
- `http://dwightaspencer.com/distinfo.txt` — dist entry point
- `http://dwightaspencer.com/lisp/systems.txt` — col 2 = asd basename (`dwightaspencer`)
- `http://dwightaspencer.com/lisp/releases.txt` — content-sha1, no comment header
- `https://dwightaspencer.com/corpus.lisp` — Hugo-generated at site root

**Runbook:** `docs/RUNBOOK-lisp.md` (not publicly served)

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

### ✅ v2 — /now page (DONE 2026-05-23)
`/now` — current work across writing, infra, OSS, advocacy, reading.
Quarterly update cadence alongside warrant canary. Not in nav — reachable by URL and Pagefind.

### ✅ v2 — /projects page (DONE 2026-05-23)
`/projects` — active and historical with status indicators. Entity-separation compliant.
Not in nav — reachable by URL and Pagefind.

### ✅ v2 — /uses page (DONE 2026-05-23)
`/uses` — editor/terminal, languages, infra, hardware, radio, desk software, site stack.
Not in nav — reachable by URL and Pagefind.

### v2 — Plausible Analytics A/B integration
**Deferred** — implement after whitepaper, technical brief/code audit, video short,
and HPR episode + Twitch livestream production pipeline is established.
Privacy-respecting cookieless analytics (no consent banner required).
Planned A/B test against Cloudflare aggregate analytics. When enabled:
- Add `<script defer data-domain="dwightaspencer.com" src="https://plausible.io/js/script.js"></script>` to baseof.html
- Update privacy/cookies policy pages accordingly
- No other changes required

### v2 — Observability stack: lab + whitepaper + HPR episode
Full dapla.net observability stack as a standalone production:

Stack to document:
- node_exporter — host metrics, ZFS pool health
- cAdvisor — per-container Podman metrics
- snmp_exporter — network device metrics
- systemd_exporter — quadlet unit state and resources
- Promtail + Loki — log shipping from journald and containers
- HAProxy native Prometheus stats endpoint
- keepalived + blackbox_exporter — HA and reachability probes
- Grafana — dashboards correlating metrics + logs

Deliverables (in order):
1. **Lab writeup** — post on dwightaspencer.com, full setup walkthrough
   with quadlet configs, Promtail pipeline config, Loki retention policy
2. **Whitepaper** — formal document for Da Planet Security, NIST 800-55
   alignment, observability as a compliance posture (entity separation applies)
3. **HPR episode script** — conversational, audience = sysadmin/homelab,
   focus on the Promtail→Loki→Grafana pipeline as the connective tissue
   that makes the other exporters useful
4. **Twitch livestream** — live build of the stack on a fresh node,
   audience participates in troubleshooting

venue = HPR on the episode post; venue = KDP or arXiv on the whitepaper

### v3 — Hugo CMS integration (Decap/Forestry successor)
For non-code content updates (warrant canary renewal, media archive updates)
without requiring a full git workflow. Low priority — current git workflow
is acceptable for the volume.

### v3 — Archive content recovery (stretch goal)
Posts 10–12 from WordPress/CompuTEK era (denzuko.wordpress.com, computekindustries.com,
denzuko.co.cc). Pending backup retrieval from Internet Archive team.
Content mapped in session notes — three posts identified:

- Post 10: *"What I Was Calling Developer Operations in 2007"* — expands post 07 with
  original contemporaneous writing; IBM dispute full account; primary source authority.
- Post 11: *"Before the Makerspace Was a Thing: SysOp to Founder"* — Software Systems
  Online BBS (1996) anchor; hDc; CompuTEK founding; bridges posts 00 and 05.
- Post 12: *"I Signed the Agile Manifesto in 2009. Here's What That Means Now."* —
  CompuTEK Industries, May 2009; practitioner retrospective at 24+ years.

All require editorial rewrite to current voice before publishing.
Do not draft from memory — raw content must be retrieved from Wayback first.

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
✅ Added 2026-05-23:
- `series` — post series grouping (Infrastructure Independence, The Watchers You Fed)
  - Layouts: `taxonomy/series.terms.html`, `taxonomy/series.html`
  - Nav: header includes `/series/` link
  - Front matter applied to posts 00–09
- `venue` — arXiv, KDP, HPR episode, conference (field added, no term pages yet — too few tagged posts)

Remaining v2.5:
- `nist_controls` — NIST 800-53 control IDs (see v2.5 section)
- `cmmc_level` — for Da Planet Security commercial posts only (see v2.5 section)
