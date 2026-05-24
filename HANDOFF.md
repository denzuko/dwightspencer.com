# Next session prompt — dwightaspencer.com

Paste this as your opening message in a new conversation.

---

You are continuing development on `dwightaspencer.com`, the personal
publishing platform of Dwight Spencer (@denzuko). Live Hugo site on
GitHub Pages behind Cloudflare. Git-flow native — no web CMS.

## Publishing workflow

- `draft = false` + `publishDate = "YYYY-MM-DD"` — post merges now, goes live on that date
- Nightly GH Actions deploy at 06:00 UTC picks up `publishDate` posts automatically
- Manual deploy: Actions → Deploy Hugo site → Run workflow (workflow_dispatch)
- `draft = true` suppresses regardless of `publishDate`
- Archetype includes `publishDate` field — set it on every new post

## Read these files first, in order

```
CLAUDE.md              — conventions, gotchas, entity separation rules
hugo/MIGRATION.md      — full backlog (v2, v2.5, v3 stretch goals)
hugo/ARCHITECTURE.md   — Mermaid diagrams: build pipeline, Lisp layers, CF interaction
```

Clone if not present:
```
git clone https://github.com/denzuko/dwightspencer.com
cd dwightspencer.com
```

Prompt for the GitHub PAT — do not store it. Set via:
```
export GH_TOKEN="..."
git remote set-url origin "https://denzuko:${GH_TOKEN}@github.com/denzuko/dwightspencer.com.git"
```

Use `gh` and `git` for all GitHub interaction. Avoid python/node scripts where possible.

## Current state (as of 2026-05-23)

- 10 posts (00–09), all live
- Taxonomies: tags, series, venue (field only)
- Pages: /now, /projects, /uses (not in nav — URL + Pagefind only)
- Nav: posts · tags · series · media · ⌕ (Pagefind) · ☀︎ (dark mode)
- Build: Hugo → Pagefind → gh-pages → Cloudflare; all green
- No open PRs, no stray branches

## Immediate backlog

See `hugo/MIGRATION.md` for full detail. Top items:

1. **post 05 corrections** — Bitwarden→KeePassDX, Nextcloud for media/docs,
   step-ca + Let's Encrypt for CA, Podman with system account, sourcehut/cgit
   over Forgejo, HAProxy paired with dns-sd/policyd/fastcgi+kcgi/keepalived
2. **MIGRATION.md CMS entry removal** — "Hugo CMS integration (Decap/Forestry)"
   is gone by design; remove the entry
3. **Archive content recovery (v3 stretch)** — posts 10–12 from WordPress/CompuTEK
   era pending Internet Archive backup retrieval
4. **v2.5** — OSCAL/NIST/arXiv/DOI taxonomy (see MIGRATION.md)

## Production pipeline (next major work)

Order: whitepaper → technical brief/code audit → video short → HPR episode + Twitch livestream  
Plausible analytics deferred until after this pipeline is established.

## Key conventions (do not deviate)

- `data-cfasync="false"` on the FOUC script — Cloudflare Rocket Loader deferral = flash bang
- Layer 2 must be an HTML comment (`<!-- ;; ... -->`) — bare text node in `<head>` renders visibly
- `len .Pages` not `.Count` in Hugo taxonomy term layouts
- `&#35;` to escape `#` inside raw `<pre><code>` blocks when preceded by a blank line
- finger.html: plain `<pre><code>` only — no monokai/highlight wrapper
- HAProxy not Nginx — verify before writing any proxy config
- Issues disabled on this repo — PR description serves as the issue

## Style guidance

Soft questions (should/could): push back if misaligned with strategy  
Hard questions (I would): execute as directed  
Gut checks appreciated — Den trusts direct disagreement over compliance

73s
