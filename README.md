# dwightaspencer.com

Personal publishing platform of Dwight Spencer (@denzuko).  
Live at **[dwightaspencer.com](https://dwightaspencer.com)** — Hugo → GitHub Pages → Cloudflare.

## Stack

| Layer | Technology |
|---|---|
| Site generator | Hugo 0.129.0 extended |
| Hosting | GitHub Pages (`gh-pages` branch) |
| CDN / proxy | Cloudflare |
| Search | Pagefind (self-hosted, built in CI) |
| Identity | ORCID 0009-0001-0066-4646 · PGP 0x5DCBF78E3F9C3FE3 |

## Repo layout

```
hugo/                     Hugo project root
├── hugo.toml             Site config, params, output formats, taxonomies
├── data/author.yaml      SINGLE SOURCE OF TRUTH — author identity
├── content/
│   ├── posts/            10 posts (00–09)
│   ├── now/              /now page — quarterly update
│   ├── projects/         /projects page
│   ├── uses/             /uses page
│   ├── media/            /media page (nav)
│   └── {privacy,cookies,terms,copyright,data-usage}/
├── layouts/
│   ├── partials/
│   │   ├── finger.html   Finger block — Layer 1 Lisp program
│   │   ├── head.html     OG meta, Schema.org, Layer 2 comment
│   │   ├── css.html      All CSS (dark mode, search, policy, tags)
│   │   ├── search.html   Pagefind UI container
│   │   └── header.html   Nav: posts · tags · series · media · ⌕ · ☀︎
│   └── taxonomy/
│       ├── tag.terms.html       Frequency-weighted tag cloud
│       ├── series.terms.html    Series index
│       └── series.html          Per-series post list
├── static/
│   ├── assets/           favicon, icons.svg sprite, OG images
│   ├── lisp/             Quicklisp dist files, corpus.lisp (Hugo-generated)
│   └── .well-known/      security.txt, webfinger, canary.txt, tdm-policy.json
└── MIGRATION.md          Backlog — v2, v2.5, v3
```

## Development workflow

```bash
git clone https://github.com/denzuko/dwightspencer.com
cd dwightspencer.com
cd hugo && hugo server   # local preview at localhost:1313
```

**Branch policy:** feature branch → PR → merge. Never commit to master directly.  
Push to master triggers GH Actions: Hugo build → Pagefind index → deploy to gh-pages.

## Key conventions

See **[CLAUDE.md](CLAUDE.md)** for the full convention set. Short version:

- `hugo/data/author.yaml` is the single source of truth for all author identity fields
- `hugo/static/lisp/corpus.lisp` is Hugo-generated — never edit directly
- Da Planet Security branding never appears on this site (entity separation)
- HAProxy not Nginx — verify before writing any proxy config
- `data-cfasync="false"` on the FOUC script — Cloudflare Rocket Loader must not defer it

## The Lisp system

The site is a self-documenting Lisp program across three layers:

- **Layer 1** — homepage finger block: real SBCL-runnable `defpackage :DwightASpencerCom`
- **Layer 2** — HTML source comment: `<!-- ;; (ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil) -->`
- **Layer 3** — PostScript polyglot at `/lisp/` — PoC‖GTFO tradition

```lisp
(ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
(ql:quickload :DwightASpencerCom)
(DwightASpencerCom:finger)   ; same output as the homepage
```

Layers 4–23 reserved.

## License

See [LICENSE.md](LICENSE.md).
