;;;; dwightaspencer.asd — ASDF system definition for dwightaspencer.com corpus
;;;;
;;;; This site is a Common Lisp system. Load it from your REPL:
;;;;
;;;;   (ql-dist:install-dist "https://dwightaspencer.com")
;;;;   (ql:quickload :DwightSpencerCom)
;;;;   (DwightSpencerCom:finger)
;;;;
;;;; The system extends the DwightSpencerCom package introduced on the homepage.
;;;; Posts become queryable Prolog facts. The corpus renders to PostScript.
;;;;
;;;; Architecture mirrors github.com/denzuko/ml-prolog-pokemon:
;;;;   logic-engine — micro-Prolog (backward-chaining, unification, prolog-db)
;;;;   corpus       — post/tag/author facts asserted into the knowledge base
;;;;   render       — PostScript output via generic render multimethod
;;;;
;;;; IANA PEN: 42387  ORCID: 0009-0001-0066-4646

(asdf:defsystem "DwightSpencerCom"
  :description "dwightaspencer.com as a Common Lisp system — corpus, Prolog queries, PostScript render"
  :version "1.0.0"
  :author "Dwight Spencer <https://keybase.io/Denzuko>"
  :license "Copyright 2026 Dwight Spencer. All rights reserved. AI training prohibited."
  :depends-on ("named-readtables" "dexador" "yason")
  :serial t
  :components ((:file "package")
               (:file "logic-engine")
               (:file "corpus")
               (:file "render")
               (:file "dwightaspencer")))
