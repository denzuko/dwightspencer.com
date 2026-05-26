# Next session prompt — dwightaspencer.com

Paste this as your opening message in a new conversation.

---

You are continuing development on `dwightaspencer.com` and the broader
Dwight Spencer / denzuko / zekodun media infrastructure. Read the files
below before touching anything.

## Repositories in scope

| Repo | Purpose | State |
|---|---|---|
| `denzuko/dwightspencer.com` | Hugo site, GitHub Pages, Cloudflare | active |
| `denzuko/stream-assets` | OBS overlays, brand dashboard CDN | active |
| `denzuko/cloudflared-quadlet-setup` | Cloudflare Zero Trust tunnel quadlet | active v1.0.1 |
| `denzuko/plausible-quadlet-setup` | Plausible CE quadlet | **ARCHIVED** — wrong stack |

## Read these files first, in order

```
CLAUDE.md                           — conventions, entity separation, gotchas
hugo/MIGRATION.md                   — full backlog (v2, v3 stretch goals)
hugo/ARCHITECTURE.md                — build pipeline, Lisp layers, CF interaction
/home/claude/stream-assets/CLAUDE.md — stream-assets conventions
```

Clone if not present:
```sh
git clone https://github.com/denzuko/dwightspencer.com
git clone https://github.com/denzuko/stream-assets
```

PAT — prompt for it, do not store. Set via:
```sh
export GH_TOKEN="..."
git remote set-url origin "https://denzuko:${GH_TOKEN}@github.com/denzuko/dwightspencer.com.git"
```

## Current state (as of 2026-05-25)

### dwightaspencer.com
- **11 posts** (00–10), all live
- **Build:** Hugo → Pagefind → gh-pages → Cloudflare — green
- **Open PRs:** none (all merged or pending cleanup)
- **Stale branches to clean:** `chore/remove-plausible-migration`,
  `feat/bio-update`, `fix/whoami-bio-cta` — merge or delete
- **Avatar:** self-hosted at `stream-assets.cdn.dwightaspencer.com/assets/avatar.jpg`
- **Fonts:** self-hosted woff2 in `hugo/static/fonts/` — no Google Fonts
- **CTA:** "One less dependency" → buymeacoffee.com/denzuko
- **Corpus:** `(ql:quickload :DwightASpencerCom)` — dsc/logic → dsc/corpus →
  DwightASpencerCom package hierarchy. See `docs/RUNBOOK-lisp.md`.
- **Easter egg:** `/.well-known/file_id.diz` — XM Core BBS ANSI splash,
  SAUCE header intact. Discoverable via corpus `(query '(tag ?s :bbs))`,
  `humans.txt`, `llms.txt`.

### stream-assets
- **Live at:** `stream-assets.cdn.dwightaspencer.com` (Cloudflare CNAME → GitHub Pages)
- **Dashboard tabs:** Scenes · Fragments · Panels · Bios · Brand · Docs
- **Data files** (edit these, push, all surfaces update in ~45s):
  - `data/now-building.yaml` — current work, drives Fragments/now-building
  - `data/charity.yaml` — monthly cause, goal, raised
  - `data/panels.yaml` — Twitch panel copy (static panels; Now Building is HTMX)
  - `data/author.yaml` — all bio variants for all platforms
  - `data/stream.yaml` — handle, links, ticker
- **HTMX fragments** at `/fragments/{now-building,charity-goal,stream-status,ticker}/`
  Pull into any surface: `hx-get="https://stream-assets.cdn.dwightaspencer.com/fragments/now-building/"`
- **brand.css:** tokens + utility classes ONLY — never body/reset rules
- **Absolute paths:** use `relURL` for CSS/JS links, `absURL` for card/hx-get URLs

### cloudflared-quadlet-setup
- **v1.0.1** — Cloudflare Zero Trust tunnel, rootless Podman quadlet
- Token in `%h/.config/containers/systemd/cloudflared.env` — never in Exec=
- `Network=host` by design — OS-level tunnel

### plausible-quadlet-setup — ARCHIVED
ClickHouse requires 1GB+ RAM baseline, JS server-side.
Stack wrong for target environment. Repo archived for quadlet pattern reference.
Analytics direction: Prometheus + log scraping + PII stripping pipeline —
whitepaper + Da Planet Security product. No consent banners by architecture.

## Open backlog (MIGRATION.md)

| Item | Priority | Notes |
|---|---|---|
| Dynamic per-post OG images | v2 | og-card.html template done, needs Playwright CI step |
| Observability stack | v2 | node_exporter/cAdvisor/Loki/Grafana — lab → HPR → whitepaper |
| R2 asset migration | v3 | issue #61 — assets.cdn.dwightaspencer.com |
| Archive content recovery | v3 stretch | Posts 10–12 from WordPress/CompuTEK era |
| arXiv post 03 | blocked | Needs endorsement or Cornell email |
| BMAC membership tiers | next session | R&D fund, charitable fundraising, community building |

## Production content pipeline

Order: whitepaper → technical brief → video short → HPR episode → Twitch  
Analytics whitepaper (DPS product): Prometheus + log scraping + PII stripping,
GDPR/CCPA/PECR compliant by architecture. No cookies, no consent, no vendor in path.

## Key conventions (do not deviate)

- `data-cfasync="false"` on FOUC script — Cloudflare Rocket Loader deferral
- Layer 2 must be HTML comment `<!-- ;; ... -->` — bare text in `<head>` renders
- `len .Pages` not `.Count` in Hugo taxonomy layouts
- HAProxy not Nginx — verify before writing any proxy config
- `machinectl shell user@ /bin/sh -c 'cmd'` — not `-- cmd` (path error on 5.x)
- Podman quadlet `DropCapability=ALL` is lowercased by 5.4.x generator — known bug
- OCI digest pinning: use platform manifest digest not index digest
- BDD workflow on all C projects: policy gate → test → code → changelog → tag
- Semver: MAJOR=API break only; PATCH freely exceeds 100

## Style guidance

Soft questions (should/could): push back if misaligned with strategy
Hard questions (I would like): execute as directed
Gut checks appreciated — direct disagreement over compliance

73s
