# Handoff prompt — dwightaspencer.com next session

Use this prompt to resume work with a fresh LLM context.

---

## Prompt

You are continuing development on `dwightaspencer.com`, the personal
publishing platform of Dwight Spencer (@denzuko). Read `CLAUDE.md` and
`hugo/MIGRATION.md` before doing anything else. Then check open PRs.

Key facts:
- Repo: `denzuko/dwightspencer.com` (note: no 'a' in dwightspencer)
- Stack: Hugo 0.129.0 extended, Cloudflare, GitHub Pages (gh-pages branch)
- Local clone expected at: `/home/claude/dwightspencer/`
- Design: warm `#fffdfa` background, Bricolage Grotesque + Share Tech Mono,
  terminal/BBS voice, privacy-first, self-hosted everything
- Single source of truth: `hugo/data/author.yaml` — do not hardcode author
  data anywhere else
- corpus.lisp is Hugo-generated from post content — never edit directly
- Entity separation is strict — see CLAUDE.md

## First tasks for next session

1. Merge any open PRs (#19, #20, #21, #24 as of last session)
2. Verify live site at https://dwightaspencer.com — check:
   - Post 00 hack.dapla.net reference (may need past-tense update)
   - Post 01 Canarytail link (verify project still active)
   - HTML source comment renders as single-line ql-dist hint
   - /corpus.lisp loads and parses in SBCL
3. Add Pagefind site search (see MIGRATION.md v2) — self-hosted,
   zero external deps, one line in GH Actions workflow
4. Begin v2.5 compliance layer if Da Planet Security pipeline active:
   - nist_controls taxonomy
   - OSCAL component front matter
   - arXiv author page integration
   - DOI/Crossref for book chapters

## Style reminders
- Soft questions ("should/could") = push back if misaligned with strategy
- Hard questions ("I would") = execute as directed
- "expert reviewed" not "peer reviewed" in RT4 content
- Never add GitHub contribution graph (junior dev signal, wrong positioning)
- Pagefind > Algolia (self-sovereign, privacy-respecting)
- PostScript is the only render target for the Lisp corpus (intentional)
- Layers 4-23 of the easter egg are reserved — don't fill them in speculatively

## Workflow
Branch → PR → review → merge → next branch from master
Check `git log origin/master..HEAD` after any merge — partial history
landing is a known pattern in this repo.

## PAT
Retrieve from session history in previous conversation transcript.
Do not hardcode in any file.
