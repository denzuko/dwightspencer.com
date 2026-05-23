;;;; corpus.lisp — dwightaspencer.com posts as Prolog facts
;;;;
;;;; Mirrors catalog.lisp from ml-prolog-pokemon: the same db-assert pattern
;;;; that turns Pokémon moves into queryable Prolog facts here turns blog posts
;;;; into a queryable knowledge base.
;;;;
;;;; Fact schemas:
;;;;   (post   slug title date word-count)
;;;;   (tag    slug tag-name)
;;;;   (author slug orcid)
;;;;
;;;; Query examples:
;;;;   ;; All posts tagged privacy
;;;;   (find-by-tag kb :privacy)
;;;;
;;;;   ;; All tags across the corpus
;;;;   (all-tags kb)
;;;;
;;;;   ;; Find a specific post
;;;;   (find-post kb "02-github-tos-wont-save-you")

(named-readtables:in-readtable :standard)
(in-package #:dsc/corpus)

(defconstant +dist-root+    "https://dwightaspencer.com")
(defconstant +search-index+ "https://dwightaspencer.com/pagefind/pagefind.js")
(defconstant +corpus-url+   "https://dwightaspencer.com/lisp/corpus.lisp")

;;;; ── Fact assertion ──────────────────────────────────────────────────────────

(defun assert-post-facts (db)
  "Assert all post facts into DB (a dsc/logic::prolog-db).
   Mirrors pokemon-catalog:assert-catalog-facts — same pattern, different domain."
  (flet ((pf (&rest fact) (logic:db-assert db fact)))

    ;; Fact schema: (post slug title date word-count)
    (pf 'post "00-hellowrld"
        "00 Hellowrld"
        "2025-01-07" 78)

    (pf 'post "01-a-better-tweedy-bird"
        "Privacy Canaries: A better tweety bird"
        "2025-01-20" 803)

    (pf 'post "02-github-tos-wont-save-you"
        "GitHub's TOS Won't Save You: Why Your Code, Privacy & Copyrights Are at Risk"
        "2026-03-11" 3200)

    (pf 'post "03-rules-types-and-glue"
        "Rules, Types, and Glue: A Multi-Paradigm Architecture for Game Simulation"
        "2026-05-22" 4100)

    (pf 'post "04-watchers-you-fed"
        "The Watchers You Fed: Chapter Preview"
        "2026-05-23" 1400)

    (pf 'post "05-infrastructure-independence"
        "Infrastructure Independence: Self-Hosting Without the Hype"
        "2026-05-23" 1800)

    (pf 'post "06-fourth-amendment-ai-surveillance"
        "Fourth Amendment in the Age of AI Surveillance"
        "2026-05-23" 2100)

    (pf 'post "07-devops-before-devops"
        "DevOps Before DevOps: The 2007-2008 IBM IP Dispute and What It Means Now"
        "2026-05-23" 1600)

    ;; Fact schema: (tag slug tag-name)
    (pf 'tag "00-hellowrld"               :write-ups)
    (pf 'tag "01-a-better-tweedy-bird"    :privacy)
    (pf 'tag "01-a-better-tweedy-bird"    :surveillance)
    (pf 'tag "02-github-tos-wont-save-you" :privacy)
    (pf 'tag "02-github-tos-wont-save-you" :github)
    (pf 'tag "02-github-tos-wont-save-you" :sourcehut)
    (pf 'tag "02-github-tos-wont-save-you" :ai-training)
    (pf 'tag "02-github-tos-wont-save-you" :foss)
    (pf 'tag "03-rules-types-and-glue"    :architecture)
    (pf 'tag "03-rules-types-and-glue"    :lisp)
    (pf 'tag "03-rules-types-and-glue"    :prolog)
    (pf 'tag "03-rules-types-and-glue"    :systems)
    (pf 'tag "04-watchers-you-fed"        :surveillance)
    (pf 'tag "04-watchers-you-fed"        :privacy)
    (pf 'tag "04-watchers-you-fed"        :fourth-amendment)
    (pf 'tag "05-infrastructure-independence" :self-hosting)
    (pf 'tag "05-infrastructure-independence" :infrastructure)
    (pf 'tag "05-infrastructure-independence" :devops)
    (pf 'tag "06-fourth-amendment-ai-surveillance" :fourth-amendment)
    (pf 'tag "06-fourth-amendment-ai-surveillance" :surveillance)
    (pf 'tag "06-fourth-amendment-ai-surveillance" :civil-liberties)
    (pf 'tag "07-devops-before-devops"    :devops)
    (pf 'tag "07-devops-before-devops"    :history)
    (pf 'tag "07-devops-before-devops"    :open-source)

    ;; Fact schema: (author slug orcid)
    (dolist (slug '("00-hellowrld" "01-a-better-tweedy-bird"
                    "02-github-tos-wont-save-you" "03-rules-types-and-glue"
                    "04-watchers-you-fed" "05-infrastructure-independence"
                    "06-fourth-amendment-ai-surveillance" "07-devops-before-devops"))
      (pf 'author slug "0009-0001-0066-4646")))

  db)

;;;; ── Query API ───────────────────────────────────────────────────────────────
;;; Mirrors pokemon-catalog query functions — find-pokemon → find-post etc.

(defun make-site-kb ()
  "Create and populate the site knowledge base. Entry point."
  (assert-post-facts (logic:make-post-kb)))

(defun find-post (kb slug)
  "Return post plist for SLUG or NIL.
   Example: (find-post kb \"03-rules-types-and-glue\")"
  (let ((env (logic:db-prove-first kb `(post ,slug ?title ?date ?wc))))
    (when env
      (list :slug  slug
            :title (cdr (assoc '?title env))
            :date  (cdr (assoc '?date  env))
            :words (cdr (assoc '?wc    env))))))

(defun find-by-tag (kb tag)
  "Return all post slugs with TAG.
   Example: (find-by-tag kb :privacy)"
  (logic:db-var-all kb `(tag ?slug ,tag) '?slug))

(defun all-posts (kb)
  "Return all post slugs in the corpus."
  (logic:db-var-all kb '(post ?slug ?title ?date ?wc) '?slug))

(defun all-tags (kb)
  "Return all unique tags across the corpus."
  (remove-duplicates
   (logic:db-var-all kb '(tag ?slug ?tag) '?tag)
   :test #'equal))
