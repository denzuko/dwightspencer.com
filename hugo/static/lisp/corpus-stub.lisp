;;;; corpus.lisp — bundled stub for DwightASpencerCom system
;;;;
;;;; This file is a source file in the DwightASpencerCom ASDF system,
;;;; implementing the dsc/corpus package.
;;;;
;;;; Package hierarchy:
;;;;   dsc/logic        — micro-Prolog engine (make-post-kb, db-assert, etc.)
;;;;   dsc/corpus       — THIS FILE — post/tag/author facts (uses dsc/logic)
;;;;   dsc/render       — PostScript output (uses dsc/corpus)
;;;;   DwightASpencerCom — top-level; ql:quickload target; uses all three
;;;;
;;;; (in-package #:dsc/corpus) is correct. The quickload target name and the
;;;; implementation package are different things. dsc/corpus is the right
;;;; package for this source file; DwightASpencerCom (:use #:dsc/corpus) makes
;;;; make-site-kb available at the top level after loading.
;;;;
;;;; Within dsc/corpus, dsc/logic is available as the local nickname 'logic'
;;;; per (:local-nicknames (#:logic #:dsc/logic)) in package.lisp.

(in-package #:dsc/corpus)

;;; These constants are also defined in the Hugo-generated corpus.lisp.
;;; The bundled stub provides them so the system loads without a live fetch.
(defconstant +dist-root+    "https://dwightaspencer.com")
(defconstant +search-index+ "https://dwightaspencer.com/pagefind/pagefind.js")
(defconstant +corpus-url+   "https://dwightaspencer.com/corpus.lisp")

(defun make-site-kb ()
  "Create and populate the site knowledge base.
   Uses the local nickname LOGIC for dsc/logic per package.lisp.
   If corpus.lisp was bundled into the tgz at build time (via CI),
   assert-post-facts is called on the already-loaded facts.
   Otherwise falls back to fetching the live corpus via HTTP."
  (let ((db (logic:make-post-kb)))
    (handler-case
        (progn
          (unless (fboundp 'assert-post-facts)
            (format *debug-io* "~&; Fetching corpus from ~A~%" +corpus-url+)
            (load +corpus-url+))
          (assert-post-facts db))
      (error (e)
        (format *debug-io* "~&; Warning: could not load corpus: ~A~%~
                             ; Using empty knowledge base.~%" e)))
    db))
