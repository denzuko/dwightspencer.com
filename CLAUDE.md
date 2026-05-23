# CLAUDE.md — dwightspencer.com project context

## Repo
`denzuko/dwightspencer.com` · gh-pages branch → Cloudflare → dwightaspencer.com
Clone: `git clone https://github.com/denzuko/dwightspencer.com`

## Stack
Hugo 0.129.0 extended · Cloudflare CDN · GitHub Pages (gh-pages branch)
HAProxy (not Nginx) · Podman quadlets · FreeBSD/NetBSD targets on dapla.net

## Key paths
```
hugo/                          Hugo project root
hugo/hugo.toml                 Config, params, output formats
hugo/data/author.yaml          SINGLE SOURCE OF TRUTH — author identity
hugo/content/posts/            8 posts (00-07)
hugo/content/{privacy,cookies,terms,copyright,data-usage}/  Policy pages (Hugo)
hugo/layouts/index.html        Home page — renders from author.yaml
hugo/layouts/index.lisp        Auto-generates /corpus.lisp from posts
hugo/layouts/index.humans      Auto-generates /humans.txt
hugo/layouts/partials/finger.html  Syntax-highlighted Lisp from author.yaml
hugo/layouts/partials/css.html All CSS — dark mode, policy, tags, icons
hugo/layouts/partials/head.html Layer 2 comment, OG meta, Schema.org
hugo/layouts/taxonomy/tag.terms.html  Frequency-weighted tag index
hugo/static/assets/            favicon.ico, icons.svg (sprite), OG images
hugo/static/assets/src/        OG image HTML source for regeneration
hugo/static/lisp/              Lisp system source files
hugo/static/.well-known/       security.txt, webfinger, canary, tdm-policy
hugo/MIGRATION.md              Backlog (v2, v2.5, v3 items)
```

## Design system
- Background: `#fffdfa` (warm off-white — explicit on BOTH html AND body)
- Fonts: Bricolage Grotesque (headings) + Share Tech Mono (code/mono)
- Dark mode: `[data-theme="dark"]` on html element + `@media prefers-color-scheme`
- FOUC fix: theme detection script in `<head>` before CSS
- Icons: self-hosted SVG sprite at `/assets/icons.svg` — no external calls
- Voice: terminal/BBS/SysOp, adversarial toward platform overreach
- Tone: "expert reviewed" not "peer reviewed"

## Entity separation (strict)
- dwightaspencer.com = personal publishing platform only
- Da Planet Security commercial branding NEVER appears on this site
- RT4 content credited "Technology Chair, RT4" only — no chapter/national ambiguity
- Author credited only as "Dwight Spencer" with ORCID + PGP fingerprint

## The Lisp system (layers 1-3)
Layer 1: Finger block on homepage — real SBCL program, defpackage DwightSpencerCom
Layer 2: HTML source comment — `;; (ql-dist:install-dist "http://dwightaspencer.com" :prompt nil)`
Layer 3: PostScript polyglot output — PoC||GTFO tradition, PS+CL+git bundle

Dist: `(ql-dist:install-dist "http://dwightaspencer.com" :prompt nil)`
System: `(ql:quickload :DwightASpencerCom)`
Entry: `(DwightASpencerCom:finger)` — same output as homepage

Architecture dogfoods `github.com/denzuko/ml-prolog-pokemon`:
- Same micro-Prolog engine (logic-engine.lisp)
- Posts as Prolog facts (corpus.lisp — Hugo-generated, never edit directly)
- Query API: find-post, find-by-tag, all-posts, all-tags
- Render: :postscript only (intentional — PS is Turing-complete, kin to Lisp)

Layers 4-23 reserved for future sessions.

## Open PRs at context end
- #19: post fixes (post 02 rendering, all post audit, manifesto date)
- #20: Hugo policy pages + data-usage policy
- #21: root .well-known cleanup
- #24: Hugo data templates (author.yaml, auto-generated corpus, layer 2 fix)

## Workflow
Always: feature branch → PR → merge → next branch from master
Never: commit to master directly
PAT in session history — do not hardcode in files

## PR pattern observed
GitHub merges partial branch history — always check `git log master..HEAD`
after a merge before assuming all commits landed. Open new PR if commits remain.

## Known issues / next session
- OG images: Playwright HTML source in hugo/static/assets/src/ — regenerate
  by opening in Playwright and screenshotting at 1200x630
- hack.dapla.net: currently Quest 2 web shell for ARG/server admin.
  May return as Soft Serve + 3270 BBS. Each state change = editorial opportunity
- Post 00: verify hack.dapla.net SSH endpoint still live
- Post 01: verify Canarytail project still active
- corpus.lisp: auto-generated. When new posts added, just run hugo --gc
- Pagefind: v2 backlog — add to GH Actions workflow after 10+ posts
- OSCAL/NIST/arXiv/DOI: v2.5 — see MIGRATION.md
