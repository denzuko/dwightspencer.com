;;;; tests.lisp — BDD test suite for DwightASpencerCom system
;;;;
;;;; Uses parachute (Shinmera/parachute) — a modern CL test framework
;;;; with define-test, is, true, false, fail, of-type assertions.
;;;;
;;;; Run from your REPL:
;;;;   (ql:quickload '("parachute" "dwightaspencercom"))
;;;;   (parachute:test-toplevel 'dwightaspencercom-tests)
;;;;
;;;; Run from CLI:
;;;;   sbcl --load run-tests.lisp
;;;;
;;;; Coverage targets — every exported and internal function:
;;;;   dsc/logic:   make-post-kb, db-assert, db-prove-all, db-prove-first,
;;;;                db-var-all, %var-p, %unify, %subst, %lookup, %norm-goal, %prove
;;;;   dsc/corpus:  make-site-kb, assert-post-facts (stub), find-post,
;;;;                find-by-tag, all-posts, all-tags, +dist-root+, +search-index+
;;;;   dsc/render:  ps-escape, ps-show, ps-page-setup, render-prolog,
;;;;                render-title-page, render-post-page, render-epilog, render
;;;;   DwightASpencerCom: finger, Self, AboutMe, make-kb, kb, query,
;;;;                      find-post, find-by-tag, all-posts, render

(defpackage #:dwightaspencercom-tests
  (:use #:cl #:parachute)
  (:local-nicknames (#:logic  #:dsc/logic)
                    (#:corpus #:dsc/corpus)
                    (#:render #:dsc/render)
                    (#:app    #:DwightASpencerCom)))

(in-package #:dwightaspencercom-tests)

;;;; ─────────────────────────────────────────────────────────────────────────
;;;; Suite: dsc/logic — micro-Prolog engine
;;;; ─────────────────────────────────────────────────────────────────────────

(define-test logic/make-post-kb
  "make-post-kb returns a fresh, empty prolog-db struct."
  (let ((kb (logic:make-post-kb)))
    (true (logic:prolog-db-p kb))
    (is equal '() (logic:db-prove-all kb '(nonexistent)))))

(define-test logic/%var-p
  "Variables are symbols whose names begin with ?."
  (true  (logic::%var-p '?x))
  (true  (logic::%var-p '?slug))
  (false (logic::%var-p 'x))
  (false (logic::%var-p :keyword))
  (false (logic::%var-p 42))
  (false (logic::%var-p "string"))
  (false (logic::%var-p nil)))

(define-test logic/%unify
  "Unification of ground terms, variables, and structures."
  ;; Ground equal terms succeed
  (is equal '() (logic::%unify :foo :foo '()))
  ;; Binding a variable
  (let ((env (logic::%unify '?x :foo '())))
    (true (not (eq env :fail)))
    (is equal :foo (cdr (assoc '?x env))))
  ;; Unification failure
  (is eq :fail (logic::%unify :foo :bar '()))
  ;; Variable already bound — consistent
  (let* ((e1 (logic::%unify '?x :a '()))
         (e2 (logic::%unify '?x :a e1)))
    (false (eq e2 :fail)))
  ;; Variable already bound — conflict
  (let* ((e1 (logic::%unify '?x :a '()))
         (e2 (logic::%unify '?x :b e1)))
    (is eq :fail e2))
  ;; Structural unification
  (let ((env (logic::%unify '(?a ?b) '(:x :y) '())))
    (false (eq env :fail))
    (is equal :x (cdr (assoc '?a env)))
    (is equal :y (cdr (assoc '?b env)))))

(define-test logic/%subst
  "Variable substitution in terms."
  (let ((env '((?x . :hello) (?y . :world))))
    (is equal :hello (logic::%subst '?x env))
    (is equal :world (logic::%subst '?y env))
    (is equal '?z    (logic::%subst '?z env))  ; unbound stays as-is
    (is equal :literal (logic::%subst :literal env))
    ;; Nested substitution
    (is equal '(:hello :world) (logic::%subst '(?x ?y) env))))

(define-test logic/db-assert-and-prove
  "db-assert stores facts; db-prove-all retrieves them by unification."
  (let ((kb (logic:make-post-kb)))
    ;; Assert a fact
    (logic:db-assert kb '(post "my-post" "My Post" "2026-01-01" 500))
    ;; Prove it with a ground query
    (let ((results (logic:db-prove-all kb '(post "my-post" "My Post" "2026-01-01" 500))))
      (is = 1 (length results)))
    ;; Prove with variables
    (let ((results (logic:db-prove-all kb '(post "my-post" ?title ?date ?wc))))
      (is = 1 (length results))
      (is equal "My Post"    (cdr (assoc '?title (first results))))
      (is equal "2026-01-01" (cdr (assoc '?date  (first results)))))
    ;; No match returns empty
    (is equal '() (logic:db-prove-all kb '(post "nonexistent" ?t ?d ?w)))))

(define-test logic/db-prove-first
  "db-prove-first returns first solution or NIL."
  (let ((kb (logic:make-post-kb)))
    (logic:db-assert kb '(post "a" "A Post" "2026-01-01" 100))
    (logic:db-assert kb '(post "b" "B Post" "2026-01-02" 200))
    (true  (not (null (logic:db-prove-first kb '(post ?s ?t ?d ?w)))))
    (false (logic:db-prove-first kb '(post "missing" ?t ?d ?w)))))

(define-test logic/db-var-all
  "db-var-all collects all bindings of a single variable."
  (let ((kb (logic:make-post-kb)))
    (logic:db-assert kb '(tag "post-a" :privacy))
    (logic:db-assert kb '(tag "post-b" :privacy))
    (logic:db-assert kb '(tag "post-c" :security))
    (let ((privacy-slugs (logic:db-var-all kb '(tag ?slug :privacy) '?slug)))
      (is = 2 (length privacy-slugs))
      (true (member "post-a" privacy-slugs :test #'equal))
      (true (member "post-b" privacy-slugs :test #'equal)))
    ;; No results for unknown tag
    (is equal '() (logic:db-var-all kb '(tag ?slug :unknown) '?slug))))

(define-test logic/%lookup
  "Lookup retrieves clauses by keyword-normalised functor."
  (let ((kb (logic:make-post-kb)))
    (logic:db-assert kb '(post "x" "X" "2026-01-01" 100))
    (let ((clauses (logic::%lookup kb 'post)))
      (is = 1 (length clauses)))
    ;; Missing functor returns nil
    (is eq nil (logic::%lookup kb 'author))))

(define-test logic/%norm-goal
  "Goal normalisation converts head symbol to keyword."
  (let ((normed (logic::%norm-goal '(post ?slug ?title))))
    (is eq :post (car normed))
    (is = 2 (length (cdr normed))))
  ;; Symbol-only goal
  (let ((normed (logic::%norm-goal 'post)))
    (is eq :post (car normed))))

;;;; ─────────────────────────────────────────────────────────────────────────
;;;; Suite: dsc/corpus — corpus layer
;;;; ─────────────────────────────────────────────────────────────────────────

(define-test corpus/constants
  "Dist and index constants are non-empty strings."
  (of-type string corpus:+dist-root+)
  (of-type string corpus:+search-index+)
  (true (plusp (length corpus:+dist-root+)))
  (true (plusp (length corpus:+search-index+)))
  (true (search "dwightaspencer.com" corpus:+dist-root+))
  (true (search "pagefind" corpus:+search-index+)))

(define-test corpus/make-site-kb
  "make-site-kb returns a prolog-db (may be empty if corpus not loaded)."
  (let ((kb (corpus:make-site-kb)))
    (true (logic:prolog-db-p kb))))

(defun make-test-kb ()
  "Build a small populated knowledge base for corpus tests."
  (let ((kb (logic:make-post-kb)))
    (logic:db-assert kb '(post "01-alpha" "Alpha Post" "2026-01-01" 300))
    (logic:db-assert kb '(post "02-beta"  "Beta Post"  "2026-02-01" 450))
    (logic:db-assert kb '(post "03-gamma" "Gamma Post" "2026-03-01" 600))
    (logic:db-assert kb '(tag  "01-alpha" :privacy))
    (logic:db-assert kb '(tag  "02-beta"  :privacy))
    (logic:db-assert kb '(tag  "02-beta"  :security))
    (logic:db-assert kb '(tag  "03-gamma" :foss))
    (logic:db-assert kb '(author "01-alpha" "0009-0001-0066-4646"))
    kb))

(define-test corpus/find-post
  "find-post returns plist for known slug, NIL for unknown."
  (let* ((kb   (make-test-kb))
         (post (corpus:find-post kb "01-alpha")))
    (true (not (null post)))
    (is equal "Alpha Post"  (getf post :title))
    (is equal "2026-01-01"  (getf post :date))
    (is equal 300           (getf post :words))
    (is equal "01-alpha"    (getf post :slug)))
  ;; Unknown slug returns nil
  (false (corpus:find-post (make-test-kb) "does-not-exist")))

(define-test corpus/find-by-tag
  "find-by-tag returns slugs having given tag, empty list for unknown tag."
  (let* ((kb    (make-test-kb))
         (slugs (corpus:find-by-tag kb :privacy)))
    (is = 2 (length slugs))
    (true (member "01-alpha" slugs :test #'equal))
    (true (member "02-beta"  slugs :test #'equal)))
  ;; Post with multiple tags appears once per tag query
  (let ((sec (corpus:find-by-tag (make-test-kb) :security)))
    (is = 1 (length sec))
    (is equal "02-beta" (first sec)))
  ;; Unknown tag → empty
  (is equal '() (corpus:find-by-tag (make-test-kb) :nonexistent)))

(define-test corpus/all-posts
  "all-posts returns a list of all slugs in the corpus."
  (let ((slugs (corpus:all-posts (make-test-kb))))
    (is = 3 (length slugs))
    (true (member "01-alpha" slugs :test #'equal))
    (true (member "02-beta"  slugs :test #'equal))
    (true (member "03-gamma" slugs :test #'equal)))
  ;; Empty KB returns empty list
  (is equal '() (corpus:all-posts (logic:make-post-kb))))

(define-test corpus/all-tags
  "all-tags returns all unique tag values from the corpus."
  (let ((tags (corpus:all-tags (make-test-kb))))
    (true (member :privacy  tags))
    (true (member :security tags))
    (true (member :foss     tags)))
  ;; Empty KB
  (is equal '() (corpus:all-tags (logic:make-post-kb))))

;;;; ─────────────────────────────────────────────────────────────────────────
;;;; Suite: dsc/render — PostScript output
;;;; ─────────────────────────────────────────────────────────────────────────

(define-test render/ps-escape
  "ps-escape wraps parentheses and backslashes in PostScript."
  (is equal ""            (render::ps-escape ""))
  (is equal "hello"       (render::ps-escape "hello"))
  (is equal "\\(foo\\)"   (render::ps-escape "(foo)"))
  (is equal "\\\\"        (render::ps-escape "\\"))
  (is equal "a\\(b\\)c"   (render::ps-escape "a(b)c"))
  ;; Mixed content
  (is equal "x\\\\y"      (render::ps-escape "x\\y"))
  ;; No escaping of other chars
  (is equal "hello world" (render::ps-escape "hello world")))

(define-test render/ps-show
  "ps-show emits PostScript show command to stream."
  ;; Basic show
  (let ((out (with-output-to-string (s)
               (render::ps-show s "hello"))))
    (true (search "(hello) show" out)))
  ;; With x,y moveto
  (let ((out (with-output-to-string (s)
               (render::ps-show s "test" :x 10 :y 20))))
    (true (search "10 20 moveto" out))
    (true (search "(test) show" out)))
  ;; With font
  (let ((out (with-output-to-string (s)
               (render::ps-show s "title" :font "Helvetica" :size 12))))
    (true (search "Helvetica findfont" out))
    (true (search "12 scalefont" out))))

(define-test render/ps-page-setup
  "ps-page-setup emits DSC Page comment and translate."
  (let ((out (with-output-to-string (s)
               (render::ps-page-setup s 1))))
    (true (search "%%Page: 1 1" out))
    (true (search "BeginPageSetup" out))
    (true (search "translate" out)))
  ;; Page number propagates
  (let ((out (with-output-to-string (s)
               (render::ps-page-setup s 5))))
    (true (search "%%Page: 5 5" out))))

(define-test render/render-prolog
  "render-prolog emits valid DSC header and prolog definitions."
  (let ((out (with-output-to-string (s)
               (render::render-prolog s))))
    (true (search "%!PS-Adobe-3.0" out))
    (true (search "%%Title:" out))
    (true (search "%%Creator:" out))
    (true (search "%%CreationDate:" out))
    (true (search "%%EndComments" out))
    (true (search "%%BeginProlog" out))
    (true (search "/inch { 72 mul } def" out))
    (true (search "/pageW" out))
    (true (search "/pageH" out))
    (true (search "/bodyW" out))
    (true (search "/hrule" out))
    (true (search "%%EndProlog" out))))

(define-test render/render-title-page
  "render-title-page emits page 1 with fingerprint, name, credentials."
  (let ((out (with-output-to-string (s)
               (render::render-title-page s))))
    (true (search "%%Page: 1 1" out))
    (true (search "0x5DCBF78E3F9C3FE3" out))
    (true (search "Dwight Spencer" out))
    (true (search "IANA PEN 42387" out))
    (true (search "dwightaspencer.com" out))
    (true (search "showpage" out))))

(define-test render/render-post-page
  "render-post-page emits a page for a known slug, skips unknown slug."
  (let* ((kb  (make-test-kb))
         (out (with-output-to-string (s)
                (render::render-post-page s kb "01-alpha" 2))))
    (true (search "%%Page: 2 2" out))
    (true (search "Alpha Post" out))
    (true (search "2026-01-01" out))
    (true (search "01-alpha" out))
    (true (search "showpage" out)))
  ;; Unknown slug emits nothing
  (let ((out (with-output-to-string (s)
               (render::render-post-page s (make-test-kb) "nonexistent" 99))))
    (is equal "" out)))

(define-test render/render-epilog
  "render-epilog emits trailer with correct page count and polyglot hint."
  (let ((out (with-output-to-string (s)
               (render::render-epilog s 5))))
    (true (search "%%Trailer" out))
    (true (search "%%Pages: 5" out))
    (true (search "%%EOF" out))
    (true (search "ql:quickload" out))))

(define-test render/render-postscript
  "render :postscript produces a complete PS document from a KB."
  (let* ((kb  (make-test-kb))
         (out (with-output-to-string (s)
                (render:render :postscript s kb))))
    ;; Must have all structural elements
    (true (search "%!PS-Adobe-3.0" out))
    (true (search "%%BeginProlog" out))
    (true (search "%%EndProlog" out))
    ;; Title page
    (true (search "Dwight Spencer" out))
    ;; Post pages (3 posts in test KB)
    (true (search "Alpha Post" out))
    (true (search "Beta Post" out))
    (true (search "Gamma Post" out))
    ;; Trailer
    (true (search "%%Trailer" out))
    (true (search "%%EOF" out))))

(define-test render/render-ps-alias
  "render :ps is an alias for :postscript."
  (let* ((kb (make-test-kb))
         (ps-out (with-output-to-string (s) (render:render :postscript s kb)))
         (alias-out (with-output-to-string (s) (render:render :ps s kb))))
    ;; Both should produce structurally identical output
    (true (search "%!PS-Adobe-3.0" alias-out))
    (true (search "%%EOF" alias-out))
    (is = (length ps-out) (length alias-out))))

;;;; ─────────────────────────────────────────────────────────────────────────
;;;; Suite: DwightASpencerCom — top-level entry points
;;;; ─────────────────────────────────────────────────────────────────────────

(define-test app/Self
  "Self is an instantiatable class."
  (of-type app:Self (make-instance 'app:Self)))

(define-test app/AboutMe
  "AboutMe method returns a plist with expected keys on a Self instance."
  (let* ((self (make-instance 'app:Self))
         (info (app:AboutMe self)))
    (true (listp info))
    (true (member :Resume info))))

(define-test app/finger
  "finger writes non-empty output to *standard-output*."
  (let ((out (with-output-to-string (*standard-output*)
               (app:finger))))
    (true (plusp (length out)))))

(define-test app/make-kb-and-kb
  "make-kb populates *kb*; kb returns it; subsequent calls reuse it."
  ;; Reset *kb* first
  (setf app:*kb* nil)
  (is eq nil app:*kb*)
  (let ((kb1 (app:make-kb)))
    (true (logic:prolog-db-p kb1))
    (is eq kb1 app::*kb*))
  ;; kb returns same instance
  (let ((kb2 (app:kb)))
    (is eq app::*kb* kb2)))

(define-test app/query
  "query runs Prolog goal against the site KB."
  (setf app:*kb* (make-test-kb))
  (let ((results (app:query '(post ?slug ?title ?date ?wc))))
    (is = 3 (length results)))
  (let ((results (app:query '(tag ?slug :privacy))))
    (is = 2 (length results)))
  (is equal '() (app:query '(post "nonexistent" ?t ?d ?w))))

(define-test app/find-post
  "app:find-post delegates to corpus:find-post via the site KB."
  (setf app:*kb* (make-test-kb))
  (let ((post (app:find-post "01-alpha")))
    (true (not (null post)))
    (is equal "Alpha Post" (getf post :title)))
  (false (app:find-post "no-such-post")))

(define-test app/find-by-tag
  "app:find-by-tag delegates to corpus:find-by-tag via the site KB."
  (setf app:*kb* (make-test-kb))
  (let ((slugs (app:find-by-tag :privacy)))
    (is = 2 (length slugs)))
  (is equal '() (app:find-by-tag :unknown-tag)))

(define-test app/all-posts
  "app:all-posts returns all slugs from the site KB."
  (setf app:*kb* (make-test-kb))
  (let ((posts (app:all-posts)))
    (is = 3 (length posts))))

(define-test app/render
  "app:render :ps with no KB uses the site KB."
  (setf app:*kb* (make-test-kb))
  (let ((out (with-output-to-string (s)
               (app:render :ps s nil))))
    (true (search "%!PS-Adobe-3.0" out))
    (true (search "%%EOF" out))))

;;;; ─────────────────────────────────────────────────────────────────────────
;;;; Top-level suite — aggregates all suites
;;;; ─────────────────────────────────────────────────────────────────────────

; Tests are run by test-toplevel on the package — no explicit root needed.
