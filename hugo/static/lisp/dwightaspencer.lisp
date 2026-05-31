;;;; dwightaspencer.lisp — DwightASpencerCom top-level entry points
;;;;
;;;; This file extends the DwightASpencerCom package declared on the
;;;; homepage at https://dwightaspencer.com.
;;;;
;;;; Loading this system from your REPL:
;;;;
;;;;   (ql-dist:install-dist "http://dwightaspencer.com/distinfo.txt" :prompt nil)
;;;;   (ql:quickload :DwightASpencerCom)
;;;;   (DwightASpencerCom:finger)          ; same output as the homepage
;;;;   (DwightASpencerCom:query '(tag ?s :privacy))  ; Prolog query
;;;;   (DwightASpencerCom:render :ps *standard-output* kb) ; PostScript to stdout
;;;;
;;;; Architecture mirrors ml-prolog-pokemon (github.com/denzuko/ml-prolog-pokemon):
;;;;   logic-engine.lisp  — micro-Prolog (db-assert, db-prove-all, unification)
;;;;   corpus.lisp        — post facts (mirrors catalog.lisp's Pokémon facts)
;;;;   render.lisp        — PostScript output (the only render target — intentional)
;;;;
;;;; The PostScript output is a polyglot file in the PoC||GTFO tradition:
;;;; valid PostScript + valid Common Lisp comments + git bundle structure.
;;;;
;;;; IANA PEN: 42387
;;;; ORCID:    0009-0001-0066-4646
;;;; PGP:      0x5DCBF78E3F9C3FE3

(named-readtables:in-readtable :standard)
(in-package #:DwightASpencerCom)

;;;; ── The finger block, now callable from your REPL ──────────────────────────
;;; This is the same program as the homepage whoami block.
;;; It runs there in the browser; it runs here in your image.

(defclass Self () ())

(defmethod AboutMe ((object Self))
  "Just a SysOp turned founder of #devops now coding AI, Blockchain, Commercial Systems."
  '(:Resume
    '(:Education (list :UoP :Cornell))
    '(:Languages (list :Golang :ANSI-C :ASM :TypeScript :Python :CommonLisp))
    '(:Projects  (list '(:Metis       "https://github.com/3um-Group")
                       '(:2600_Mod    "https://reddit.com/r/2600")
                       '(:corpus      "https://dwightaspencer.com/lisp/")
                       '(:game-study  "https://github.com/denzuko/ml-prolog-pokemon")))
    '(:Volunteering (list '(:Score    "https://Score.org")
                          '(:Archive  "https://archive.org")
                          '(:9front   "https://only9fans.com")
                          '(:Debian   "https://debian.org")))
    '(:Certs (list '(:RHCE              "February 2007")
                   '(:AWS-SA            "March 2015")
                   '(:Amazon-Leadership "March 2019")
                   '(:GCP-Architect     "January 2022")
                   '(:CISM              "June 2022")
                   '(:ORCID             "https://orcid.org/0009-0001-0066-4646")
                   '(:Keybase           "https://Keybase.io/Denzuko/pubkey")
                   '(:Agile-Manifesto   "CompuTEK Industries, May 2009")))
    '(:Tools (list :AlpineLinux :VIM :Vlime :VimWiki :entr :zmk :gnumake
                   :plan9ports :git-flow :git-bug :git-email
                   :charmbracelet_soft_serve :notmuch-mail :slrn
                   :Ansible :Terraform :Podman :Nomad :Consul :Ollama))))

(defun finger ()
  (let ((dwight (make-instance 'Self)))
    (format t "~A~&" (AboutMe dwight))))

;;;; ── Corpus entry points ─────────────────────────────────────────────────────

(defvar *kb* nil
  "The site knowledge base. Populated on first call to make-kb.")

(defun make-kb ()
  "Create and populate the site knowledge base."
  (setf *kb* (dsc/corpus:make-site-kb)))

(defun kb ()
  "Return the site knowledge base, creating it if necessary."
  (or *kb* (make-kb)))

(defun query (goal)
  "Run a Prolog query against the site corpus.
   Example: (query '(tag ?s :privacy))
            (query '(post ?slug ?title ?date ?wc))"
  (dsc/logic:db-prove-all (kb) goal))

(defun find-post (slug)
  "Find a post by SLUG in the site corpus.
Returns a plist with keys :slug, :title, :date, :words, or NIL if not found.
Uses the global site knowledge base (see kb).
Example: (find-post \"03-rules-types-and-glue\")"
  (dsc/corpus:find-post (kb) slug))

(defun find-by-tag (tag)
  "Return all post slugs in the site corpus that carry TAG (a keyword).
Uses the global site knowledge base (see kb).
Example: (find-by-tag :privacy) => list of slug strings."
  (dsc/corpus:find-by-tag (kb) tag))

(defun all-posts ()
  "Return a list of all post slugs in the site corpus.
Uses the global site knowledge base (see kb).
Example: (all-posts) => list of slug strings."
  (dsc/corpus:all-posts (kb)))

;;;; ── Render entry point ──────────────────────────────────────────────────────

(defmethod render ((target (eql :ps)) stream (kb null))
  "Render the site corpus to STREAM in PostScript format.
Specialisation for TARGET=:ps and KB=NIL: supplies the global knowledge base.
Uses kb to obtain or create the global instance.
Example: (render :ps *standard-output* nil)"
  (dsc/render:render :postscript stream (kb)))

;;;; ── Quicklisp dist declaration ──────────────────────────────────────────────
;;; This file is also the Quicklisp dist root.
;;; dist format: https://blog.quicklisp.org/2011/08/lisp-library-sites.html

(defparameter +dist-name+    "DwightASpencerCom")
(defparameter +dist-version+ "2026-05-23")
(defparameter +dist-root+    dsc/corpus:+dist-root+)
