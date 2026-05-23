# Next session LLM prompt — dwightaspencer.com

Paste this as your opening message in a new conversation window.

---

You are continuing development on `dwightaspencer.com`, the personal
publishing platform of Dwight Spencer (@denzuko). This is a live Hugo
site deployed via GitHub Actions to GitHub Pages behind Cloudflare.

## First: read these files before touching anything

```
CLAUDE.md                  — full project context, conventions, known issues
hugo/MIGRATION.md          — backlog (v2, v2.5, v3 items)
hugo/ARCHITECTURE.md       — Mermaid diagrams of build pipeline and Lisp layers
```

Clone the repo if not already present:
  git clone https://github.com/denzuko/dwightspencer.com
  cd dwightspencer.com

## Current state

Open PRs to review and merge in order:
  #19  — post 02 rendering fix, all post audit, manifesto date clarification
  #20  — Hugo policy pages (privacy/cookies/terms/copyright/data-usage)
  #21  — root .well-known cleanup (stale duplicate)
  #24  — author.yaml source of truth, auto-generated corpus.lisp,
          layer 2 comment simplified, four Lisp bug fixes

After merging, verify live at https://dwightaspencer.com:
  - HTML source contains: ;; (ql-dist:install-dist "http://dwightaspencer.com" :prompt nil)
  - /corpus.lisp loads and parses in SBCL — package is :DwightASpencerCom
  - Finger block ends with (DwightASpencerCom:finger) not (finger)
  - Post 02 /posts/02-github-tos-wont-save-you/ renders correctly (no pre/code wrapping)
  - Policy pages have dark mode toggle and /media/ nav link

## Immediate next tasks

1. Pagefind site search — self-hosted, zero external deps:
   - Add to GH Actions: `npx pagefind --site hugo/public` after hugo build step
   - Add search UI partial to baseof.html
   - Update MIGRATION.md
   - No Algolia — privacy positioning

2. Post 00 hack.dapla.net reference — verify if SSH endpoint is live.
   Currently: Quest 2 web shell for ARG/server admin. May return as
   Soft Serve + 3270 BBS. If down, update to past tense.
   Each state change = editorial article opportunity.

3. Post 01 Canarytail link — verify project still active.

## Key conventions (do not deviate)

Design:
  - Background: #fffdfa explicit on BOTH html AND body
  - Fonts: Bricolage Grotesque + Share Tech Mono (Google Fonts, roadmap: self-host)
  - Dark mode: [data-theme="dark"] on html element, FOUC fix script in <head>
  - Icons: self-hosted SVG sprite /assets/icons.svg — no external calls
  - Social links: LinkedIn · GitHub · Keybase · Reddit · Resume (Calendly)

Content:
  - hugo/data/author.yaml is the SINGLE SOURCE OF TRUTH for author identity
  - corpus.lisp is Hugo-generated — never edit hugo/static/lisp/corpus.lisp directly
  - Entity separation: Da Planet Security branding NEVER on dwightaspencer.com
  - RT4 content: "expert reviewed" not "peer reviewed"
  - "Technology Chair, RT4" only — no chapter/national scope distinction in bylines

Lisp system:
  - Package: :DwightASpencerCom (matches dwightaspencer.com domain)
  - Dist: (ql-dist:install-dist "http://dwightaspencer.com" :prompt nil)
    Note: http:// required as argument; Quicklisp upgrades to https:// internally
  - Layer 2 comment is ONE line only — no narration, no labels
  - PostScript is the ONLY render target — intentional (Turing-complete, kin to Lisp)
  - Layers 4-23 reserved — do not fill speculatively

Workflow:
  - Always: feature branch → PR → merge → next branch from master
  - After merge: git log origin/master..HEAD to verify all commits landed
  - Never commit to master directly
  - HAProxy not Nginx — always verify before writing proxy config

## v2.5 backlog (do after Pagefind)

OSCAL components, NIST 800-53 taxonomy, arXiv integration, Crossref/DOI.
Full spec in hugo/MIGRATION.md under "v2.5 — Research & Compliance Layer".
OSCAL refs point to Da Planet Security infra only — entity separation applies.

## Style guidance

Soft questions (should/could): push back if misaligned with strategy
Hard questions (I would): execute as directed
Gut checks appreciated — Den trusts direct disagreement over compliance

73s
