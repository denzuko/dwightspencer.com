;;;; corpus.lisp — bundled stub for DwightASpencerCom system
;;;;
;;;; This file provides the dsc/corpus functions by loading the
;;;; Hugo-generated corpus from https://dwightaspencer.com/corpus.lisp
;;;; at runtime. The live corpus is regenerated on every site build
;;;; and contains all post facts as Prolog assertions.

(in-package #:dsc/corpus)

(defconstant +dist-root+    "https://dwightaspencer.com")
(defconstant +search-index+ "https://dwightaspencer.com/pagefind/pagefind.js")
(defconstant +corpus-url+   "https://dwightaspencer.com/corpus.lisp")

(defun make-site-kb ()
  "Load and populate the site knowledge base from the live corpus.
   Fetches https://dwightaspencer.com/corpus.lisp at runtime and
   evals it into the current image."
  (let ((db (dsc/logic:make-post-kb)))
    (handler-case
        (progn
          (format *debug-io* "~&; Fetching corpus from ~A~%" +corpus-url+)
          (load (concatenate 'string +corpus-url+))
          (assert-post-facts db))
      (error (e)
        (format *debug-io* "~&; Warning: could not load live corpus: ~A~%~
                             ; Using empty knowledge base.~%" e)))
    db))
