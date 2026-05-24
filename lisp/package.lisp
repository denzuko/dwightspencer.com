;;;; package.lisp — package definitions for DwightASpencerCom system
;;;;
;;;; The DwightASpencerCom package was first introduced on the homepage at
;;;; https://dwightaspencer.com — the finger/whoami block is the canonical
;;;; package definition. This file is the machine-readable extension of that
;;;; same program.

(in-package #:cl-user)

;;; ── Logic layer — micro-Prolog engine from ml-prolog-pokemon ─────────────────
;;; Architecture: github.com/denzuko/ml-prolog-pokemon/logic-engine.lisp
;;; Same prolog-db struct, same db-assert/db-prove-all interface.
;;; Posts become facts exactly as Pokémon moves became facts in the study.
(defpackage #:dsc/logic
  (:use #:cl)
  (:export
   ;; database
   #:make-post-kb
   #:db-assert
   #:db-prove-first
   #:db-prove-all
   #:db-var-all
   ;; internals (exposed for corpus layer)
   #:%var-p #:%unify #:%subst #:%lookup #:db-clauses #:prolog-db))

;;; ── Corpus layer — post/tag/author facts ─────────────────────────────────────
;;; Mirrors pokemon-catalog: assert-catalog-facts → assert-post-facts
;;; Fact schemas:
;;;   (post   slug title date word-count)
;;;   (tag    slug tag-name)
;;;   (author slug orcid)
(defpackage #:dsc/corpus
  (:use #:cl)
  (:local-nicknames (#:logic #:dsc/logic))
  (:export
   #:assert-post-facts
   #:find-post
   #:find-by-tag
   #:all-posts
   #:all-tags
   #:make-site-kb
   ;; search index
   #:+search-index+
   #:+dist-root+))

;;; ── Render layer — PostScript output ─────────────────────────────────────────
(defpackage #:dsc/render
  (:use #:cl)
  (:local-nicknames (#:corpus #:dsc/corpus))
  (:export
   #:render))

;;; ── Top-level DwightASpencerCom package ───────────────────────────────────────
;;; This is the package the finger block declares on the homepage.
;;; Loading this system extends it with corpus + render capabilities.
(defpackage #:DwightASpencerCom
  (:use #:cl #:dsc/logic #:dsc/corpus #:dsc/render)
  (:export
   ;; From the homepage finger block — still works
   #:finger
   #:Self
   #:AboutMe
   ;; Corpus queries
   #:query
   #:find-post
   #:find-by-tag
   #:all-posts
   ;; Render
   #:render))
