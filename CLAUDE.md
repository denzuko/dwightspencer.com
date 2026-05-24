# CLAUDE.md — dwightaspencer.com

## Repo
`denzuko/dwightspencer.com` · gh-pages branch → Cloudflare → dwightaspencer.com  
Clone: `git clone https://github.com/denzuko/dwightspencer.com`

## Stack
Hugo 0.129.0 extended · Cloudflare CDN · GitHub Pages (gh-pages branch)  
Pagefind (self-hosted search, built in CI after hugo build)  
HAProxy (not Nginx) · Podman quadlets · FreeBSD/NetBSD targets on dapla.net

## Key paths
```
hugo/hugo.toml                 Config, params, output formats, taxonomies
hugo/data/author.yaml          SINGLE SOURCE OF TRUTH — author identity
hugo/content/posts/            10 posts (00–09)
hugo/content/now/              /now page (quarterly update)
hugo/content/projects/         /projects page
hugo/content/uses/             /uses page
hugo/content/media/            /media page (nav link)
hugo/content/{privacy,cookies,terms,copyright,data-usage}/
hugo/layouts/partials/finger.html   Plain pre/code — NO monokai wrapper
hugo/layouts/partials/css.html      All CSS — dark mode, search, policy, tags
hugo/layouts/partials/head.html     OG meta, Schema.org, Layer 2 HTML comment
hugo/layouts/partials/search.html   Pagefind UI container (no inline script)
hugo/layouts/partials/header.html   Nav: posts · tags · series · media · ⌕ · ☀︎
hugo/layouts/taxonomy/series.html   Per-series post list (len .Pages not .Count)
hugo/layouts/_default/baseof.html   All post-DOM JS in one DOMContentLoaded block
hugo/static/lisp/              Quicklisp dist; corpus.lisp is Hugo-generated
hugo/static/.well-known/       security.txt, webfinger, canary.txt, tdm-policy
hugo/MIGRATION.md              Backlog — v2, v2.5, v3
hugo/ARCHITECTURE.md           Mermaid diagrams — build pipeline, Lisp layers
```

## Design system
- Background: `#fffdfa` — explicit on BOTH `html` AND `body`
- Fonts: Bricolage Grotesque (headings) + Share Tech Mono (code/mono) — Google Fonts css2 API
- Dark mode: `[data-theme="dark"]` on html element + `@media prefers-color-scheme`
- FOUC fix: `<script data-cfasync="false">` in `<head>` — `data-cfasync="false"` is mandatory;
  Cloudflare Rocket Loader defers bare script tags causing flash on revisits
- Icons: self-hosted SVG sprite `/assets/icons.svg` — no external icon calls
- Finger block: plain `<pre><code>` — no monokai/highlight wrapper
- Voice: terminal/BBS/SysOp, adversarial toward platform overreach
- Tone: "expert reviewed" not "peer reviewed"

## Entity separation (strict)
- dwightaspencer.com = personal publishing platform only
- Da Planet Security commercial branding NEVER appears on this site
- RT4 content credited "Technology Chair, RT4" only
- Author credited as "Dwight Spencer" with ORCID + PGP fingerprint only
- DPS role string: "Principal, Da Planet Security" — no location or founding date

## The Lisp system (layers 1–3)
- **Layer 1**: Finger block — real SBCL program, `defpackage :DwightASpencerCom`
- **Layer 2**: HTML comment — `<!-- ;; (ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil) -->`
  - Must be an HTML comment — bare text nodes in `<head>` after `</style>` get
    foster-parented into `<body>` by HTML5 error recovery and rendered visibly
- **Layer 3**: PostScript polyglot — PoC‖GTFO tradition, PS+CL+git bundle

Dist URL uses `http://` — Quicklisp upgrades to https:// internally.  
Entry: `(DwightASpencerCom:finger)` — same output as homepage.  
Layers 4–23 reserved. Do not fill speculatively.

## Taxonomies (live)
- `tags` → `/tags/` frequency-weighted cloud
- `series` → `/series/` — Infrastructure Independence, The Watchers You Fed
- `venue` → field only (no term pages — too few tagged posts)
- `categories` → field only

## Workflow
- Always: feature branch → PR → merge → next branch from master
- Never commit to master directly
- Issues disabled on this repo — use PR description as the issue
- PAT: prompt each session, never hardcode
- `gh` and `git` for GitHub interactions — avoid python/node scripts
- After merge: check `gh run list` to confirm build green before next branch

## Known gotchas
- Hugo taxonomy term layout: use `len .Pages` not `.Count` (`.Count` is Terms-level only)
- `# comment` inside raw `<pre><code>` blocks: escape as `&#35;` to prevent
  goldmark parsing it as a heading when a blank line precedes it
- Cloudflare Rocket Loader rewrites bare `<script>` type to a hash — any script
  that must run synchronously needs `data-cfasync="false"`
- `hugo/static/lisp/corpus.lisp` is Hugo-generated — never edit directly;
  regenerates on every `hugo --gc`

## Current post count
10 posts: 00-hellowrld through 09-after-the-canary
