# Maintainer runbook: DwightASpencerCom Quicklisp dist

Internal reference. Not served publicly — lives in `docs/` not `hugo/static/`.

---

## Dist endpoints

| URL | Purpose |
|---|---|
| `http://dwightaspencer.com/distinfo.txt` | Quicklisp dist entry point |
| `http://dwightaspencer.com/lisp/systems.txt` | System index |
| `http://dwightaspencer.com/lisp/releases.txt` | Release index |
| `https://dwightaspencer.com/corpus.lisp` | Hugo-generated post facts (at site root) |
| `http://dwightaspencer.com/lisp/DwightASpencerCom-YYYY-MM-DD.tgz` | Release archive |

## Verify endpoints are live

```sh
curl -s http://dwightaspencer.com/distinfo.txt
# Must return plain text starting with "name DwightASpencerCom"

curl -s http://dwightaspencer.com/lisp/releases.txt
# Single data line: DwightASpencerCom http://... size md5 sha256 prefix asd

curl -s http://dwightaspencer.com/lisp/systems.txt
# Single data line: DwightASpencerCom DwightASpencerCom-YYYY-MM-DD DwightASpencerCom ...

curl -s https://dwightaspencer.com/corpus.lisp | head -5
# Must return Lisp source, not HTML
```

## Load and test in SBCL

```lisp
(ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
(ql:quickload :DwightASpencerCom)
(DwightASpencerCom:finger)
(DwightASpencerCom:all-posts)
(DwightASpencerCom:find-by-tag :privacy)
(DwightASpencerCom:query '(tag ?s :infrastructure))
```

## Package structure

```
dsc/logic     — micro-Prolog (db-assert, db-prove-all, unification, backward chaining)
dsc/corpus    — post facts (assert-post-facts, make-site-kb, find-post, find-by-tag)
dsc/render    — PostScript backend (render :ps/:postscript stream kb)
DwightASpencerCom — top-level package (finger, query, kb, render, all-posts)
```

## Corpus

`corpus.lisp` is Hugo-generated — never edit directly.
Lives at site root `/corpus.lisp`, not under `/lisp/`.
Regenerates on every `hugo --gc`.

The `+corpus-url+` constant in the corpus template must point to:
`https://dwightaspencer.com/corpus.lisp`

## Updating the release

When changing any `.lisp` or `.asd` source file:

```sh
# 1. Update source files in hugo/static/lisp/
# 2. Rebuild tgz
cd /tmp
tar xzf /path/to/hugo/static/lisp/DwightASpencerCom-YYYY-MM-DD.tgz
# copy updated files in
tar czf DwightASpencerCom-YYYY-MM-DD.tgz DwightASpencerCom-YYYY-MM-DD/

# 3. Get checksums
wc -c < DwightASpencerCom-YYYY-MM-DD.tgz    # size
md5sum DwightASpencerCom-YYYY-MM-DD.tgz      # md5
sha256sum DwightASpencerCom-YYYY-MM-DD.tgz   # sha256

# 4. Update releases.txt with new size/md5/sha256
# 5. Update distinfo.txt version field if cutting a new release date
```

## Known issues

| Symptom | Cause | Fix |
|---|---|---|
| DESTRUCTURING-BIND error with `<!doctype` | URL is wrong, returns HTML | Use `http://dwightaspencer.com/distinfo.txt` |
| `System "DwightASpencerCom" not found` | Dist not installed or cache stale | `(ql:update-all-dists)` then retry |
| Checksum mismatch | tgz updated without rebuilding releases.txt | Rebuild index per above |
| `corpus.lisp` 404 | Hugo not generating it or wrong URL | Check `hugo/layouts/index.lisp` output format |
