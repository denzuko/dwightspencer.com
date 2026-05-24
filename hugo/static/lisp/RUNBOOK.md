# Runbook: Layer 2 Easter Egg — SBCL/Quicklisp/Vlime

## Overview

The Layer 2 Easter egg is a working Quicklisp dist hosted at
`http://dwightaspencer.com/lisp`. Loading it installs the site as
a Common Lisp system you can query from your REPL.

The hint is in the HTML source comment — visible in `view-source:` or `curl`:

```
curl -s https://dwightaspencer.com/ | grep 'ql-dist'
```

Expected output:
```
<!-- ;; (ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil) -->
```

---

## Prerequisites

- SBCL installed
- Quicklisp installed and loaded in your SBCL image
- Vlime configured in Vim (`:VlimeStart` working)

---

## Step 1 — Verify the dist is reachable

Before touching the REPL, confirm the dist endpoints are live:

```sh
# Must return plain text starting with "name DwightASpencerCom"
curl -s http://dwightaspencer.com/lisp/distinfo.txt

# Must return a single data line starting with "DwightASpencerCom http://"
curl -s http://dwightaspencer.com/lisp/releases.txt

# Must return a single data line starting with "DwightASpencerCom DwightASpencerCom-"
curl -s http://dwightaspencer.com/lisp/systems.txt
```

If any of these return HTML (a 404 page), the dist infrastructure is broken.
Open an issue — do not proceed.

---

## Step 2 — Install the dist

In SBCL (standalone or via Vlime):

```lisp
(ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
```

Expected output:

```
Installing dist "DwightASpencerCom" version "2026-05-23".
Adding "DwightASpencerCom" to Quicklisp.
```

**If you see a DESTRUCTURING-BIND error** with `"<!doctype"` in the args,
the dist URL is wrong — you're hitting the site root (returns HTML) not the
dist endpoint. Confirm you're using `/lisp` at the end.

**If you see a checksum mismatch error**, the tgz has been updated without
rebuilding the dist index. File an issue.

---

## Step 3 — Load the system

```lisp
(ql:quickload :DwightASpencerCom)
```

Expected: system loads without errors. Dependencies (`named-readtables`,
`dexador`, `yason`) will be fetched from Quicklisp if not already present.

---

## Step 4 — Call the entry point

```lisp
(DwightASpencerCom:finger)
```

This runs the same program as the finger block on the homepage.
Output is a Lisp data structure — the site's self-description.

---

## Step 5 — Query the corpus

```lisp
;; List all post slugs
(DwightASpencerCom:all-posts)

;; Find posts tagged :privacy
(DwightASpencerCom:find-by-tag :privacy)

;; Find a specific post by slug
(DwightASpencerCom:find-post "09-after-the-canary")

;; Raw Prolog query
(DwightASpencerCom:query '(tag ?s :infrastructure))
```

---

## Step 6 — Render to PostScript

```lisp
;; PostScript is the only render target — intentional
(DwightASpencerCom:render :ps *standard-output* (DwightASpencerCom:kb))
```

Output is a PostScript polyglot in the PoC‖GTFO tradition:
valid PostScript + valid Common Lisp comments + git bundle structure.
Pipe to `gs` or a PostScript viewer.

---

## Vlime workflow

With Vlime in Vim, the full session looks like:

```
:VlimeStart
```

Then in the REPL buffer (`,e` to evaluate expressions):

```lisp
(ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
(ql:quickload :DwightASpencerCom)
(DwightASpencerCom:finger)
(DwightASpencerCom:all-posts)
```

Use `,d` on any symbol to inspect its definition, `,a` to search apropos.
The system exports: `finger`, `Self`, `all-posts`, `find-post`,
`find-by-tag`, `query`, `render`, `kb`, `make-kb`.

---

## Dist structure reference

```
http://dwightaspencer.com/lisp/
├── distinfo.txt          Quicklisp dist metadata (fetched first by install-dist)
├── releases.txt          Release index: name url size md5 sha256 prefix asd
├── systems.txt           System index: project release system [deps]
├── corpus.lisp           Hugo-generated post facts (not bundled in tgz)
├── dwightaspencer.asd    ASDF system definition
├── package.lisp          Package :DwightASpencerCom
├── logic-engine.lisp     Micro-Prolog (db-assert, db-prove-all, unification)
├── render.lisp           PostScript render multimethod
├── dwightaspencer.lisp   Entry points: finger, query, render, kb
└── DwightASpencerCom-YYYY-MM-DD.tgz   Versioned release archive
```

`corpus.lisp` is Hugo-generated on every site build. It is not bundled
in the tgz — it is fetched at runtime by `make-kb` via dexador from
`https://dwightaspencer.com/lisp/corpus.lisp`.

---

## Updating the dist (maintainer notes)

When adding posts or changing the system:

1. Update source files under `hugo/static/lisp/`
2. Rebuild the tgz: `tar czf DwightASpencerCom-$(date +%F).tgz DwightASpencerCom-$(date +%F)/`
3. Update `releases.txt`: new size (`wc -c`), md5 (`md5sum`), sha256 (`sha256sum`)
4. Update `distinfo.txt` version field
5. `corpus.lisp` regenerates automatically on every `hugo --gc` — never edit directly

---

## Known issues

| Symptom | Cause | Fix |
|---|---|---|
| DESTRUCTURING-BIND error with `<!doctype` | URL points to site root, returns HTML | Use `http://dwightaspencer.com/lisp` |
| `System "DwightASpencerCom" not found` | Dist not installed or Quicklisp cache stale | Run `(ql:update-all-dists)` then retry |
| Checksum mismatch | tgz updated without rebuilding releases.txt | File issue; maintainer must rebuild index |
| `file "corpus" not found` | corpus.lisp not in tgz (it's runtime-fetched) | Ensure dexador is loaded; check network |
