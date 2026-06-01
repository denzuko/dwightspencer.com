;;;; rag-tests.lisp — BDD spec for com.dwightaspencer/rag (issue #108)
;;;;
;;;; Written FIRST per BDD workflow. No implementation exists yet.
;;;; All tests here must FAIL until the implementation is written.
;;;;
;;;; Scenarios verbatim from issue #108:
;;;;   Scenario 1: Generating an answer to a question not in the corpus
;;;;   Scenario Outline: Tonal enforcement on adjectives based on corpus context
;;;;
;;;; Run:
;;;;   sbcl --load hugo/static/lisp/run-rag-tests.lisp
;;;;
;;;; Expected initially: all tests FAIL (package does not exist).

(defpackage #:rag-tests
  (:use #:cl #:parachute)
  (:local-nicknames (#:logic  #:com.dwightaspencer/logic)
                    (#:corpus #:com.dwightaspencer/corpus)
                    (#:rag    #:com.dwightaspencer/rag)))

(in-package #:rag-tests)

;;;; ── Background fixtures ─────────────────────────────────────────────────
;;;; Issue #108 Background:
;;;;   Given a training corpus is generated from site content (corpus.lisp)
;;;;   And the corpus has been parsed into character and word trigrams
;;;;   And the Prolog database contains tonal rules extracted from the corpus
;;;;   And the parallel AST engine contains structural grammar patterns

(defun make-corpus-kb ()
  "Minimal corpus KB satisfying the issue #108 Background condition.
Represents corpus.lisp site content as Prolog facts."
  (let ((kb (logic:make-post-kb)))
    (logic:db-assert kb '(post "code-execution" "Code Execution"  "2026-01-01" 500))
    (logic:db-assert kb '(post "lisp-elegance"  "Lisp Elegance"   "2026-01-02" 400))
    (logic:db-assert kb '(tag  "code-execution" :code))
    (logic:db-assert kb '(tag  "lisp-elegance"  :lisp))
    kb))

;;;; ── Background: corpus → trigrams ───────────────────────────────────────
;;;; "the corpus has been parsed into character and word trigrams"

(define-test background/char-trigrams-exist
  "Corpus text can be parsed into character trigrams (3-char sliding windows)."
  ;; Given the corpus KB exists
  (let ((kb (make-corpus-kb)))
    ;; When we compute trigrams of a corpus title
    (let ((tgs (rag:char-trigrams "Code")))
      ;; Then the result is a list of 3-character strings
      (true (listp tgs))
      (true (every (lambda (t3) (and (stringp t3) (= 3 (length t3)))) tgs))
      ;; And "ode" appears as a trigram (interior trigram of "Code" with padding)
      (true (member "ode" tgs :test #'equal)))))

(define-test background/word-trigrams-exist
  "Corpus titles can be parsed into word trigrams (3-word sliding windows)."
  (let ((tgs (rag:word-trigrams "the quick brown fox jumps")))
    (true (listp tgs))
    ;; Each trigram is a list of exactly 3 strings
    (true (every (lambda (tg) (and (listp tg) (= 3 (length tg))
                                   (every #'stringp tg)))
                 tgs))
    (is = 3 (length tgs))
    (is equal '("the" "quick" "brown") (first tgs))))

(define-test background/trigram-index-built
  "A trigram frequency index can be built from the corpus KB."
  (let* ((kb  (make-corpus-kb))
         (idx (rag:build-trigram-index kb)))
    ;; Then the index is a hash table of trigram → count
    (true (hash-table-p idx))
    (true (plusp (hash-table-count idx)))
    (maphash (lambda (k v)
               (true (stringp k))
               (true (integerp v))
               (true (>= v 0)))
             idx)))

;;;; ── Background: corpus → tonal Prolog rules ────────────────────────────
;;;; "the Prolog database contains tonal rules extracted from the corpus"

(define-test background/tonal-rules-extracted
  "Tonal rules can be extracted from the corpus into a Prolog DB."
  (let* ((kb    (make-corpus-kb))
         (rules (rag:extract-tonal-rules kb)))
    ;; The tonal rules DB is a prolog-db
    (true (logic:prolog-db-p rules))
    ;; And it is non-empty (domain rules at minimum)
    (true (plusp (hash-table-count (logic:db-clauses rules))))))

;;;; ── Background: parallel AST engine ────────────────────────────────────
;;;; "the parallel AST engine contains structural grammar patterns"

(define-test background/ast-patterns-defined
  "AST category compatibility patterns are defined."
  ;; *category-compatibility* must be bound and non-empty
  (true (boundp 'rag:*category-compatibility*))
  (true (listp rag:*category-compatibility*))
  (true (plusp (length rag:*category-compatibility*)))
  ;; :adjective must be a defined required category
  (true (assoc :adjective rag:*category-compatibility*))
  ;; :verb must be a defined required category
  (true (assoc :verb rag:*category-compatibility*)))

;;;; ── Scenario 1: Generating an answer not in the corpus ──────────────────
;;;; "Given a user asks the unseen question 'How does the system execute code?'"
;;;; "And the Generative Neural Net predicts the following candidate next tokens:"
;;;;   fast   0.85 ADJECTIVE
;;;;   cool   0.78 ADJECTIVE
;;;;   broken 0.22 ADJECTIVE
;;;; "When the parallel validation shields analyze the candidates for noun CODE"

(defun scenario-1-candidates ()
  '((:token "fast"   :probability 0.85 :category :adjective)
    (:token "cool"   :probability 0.78 :category :adjective)
    (:token "broken" :probability 0.22 :category :adjective)))

(define-test scenario-1/ast-allows-adjective-for-adjective-slot
  "Then the AST filter should allow tokens with the category ADJECTIVE."
  ;; An ADJECTIVE token satisfies an ADJECTIVE required slot
  (true  (rag:ast-category-match-p :adjective :adjective))
  ;; A VERB token does NOT satisfy an ADJECTIVE slot (needed for scenario outline row 3)
  (false (rag:ast-category-match-p :adjective :verb)))

(define-test scenario-1/prolog-fast-passes-tonal
  "Prolog filter: tonal_match(CODE, fast) = PASS."
  (let* ((kb    (make-corpus-kb))
         (rules (rag:extract-tonal-rules kb)))
    (true (rag:tonal-match-p rules :code "fast"))))

(define-test scenario-1/prolog-cool-fails-tonal
  "Prolog filter: tonal_match(CODE, cool) = FAIL."
  (let* ((kb    (make-corpus-kb))
         (rules (rag:extract-tonal-rules kb)))
    (false (rag:tonal-match-p rules :code "cool"))))

(define-test scenario-1/prolog-broken-fails-tonal
  "Prolog filter: tonal_match(CODE, broken) = FAIL."
  (let* ((kb    (make-corpus-kb))
         (rules (rag:extract-tonal-rules kb)))
    (false (rag:tonal-match-p rules :code "broken"))))

(define-test scenario-1/select-approved-token-fast
  "The system selects 'fast' — highest valid score after both shields."
  (let* ((kb     (make-corpus-kb))
         (result (rag:select-token kb :code :adjective
                                   (scenario-1-candidates))))
    (is equal "fast" result)))

(define-test scenario-1/final-response
  "The final generated response is 'The system executes code fast.'"
  (let* ((kb  (make-corpus-kb))
         (out (rag:generate-response
               "The system executes code ~A."
               kb :code :adjective
               (scenario-1-candidates))))
    (is equal "The system executes code fast." out)))

;;;; ── Scenario Outline: Tonal enforcement ─────────────────────────────────
;;;; | LISP | ADJECTIVE | elegant | PASS  | Matches structural AST and Prolog tone |
;;;; | LISP | ADJECTIVE | sloppy  | FAIL  | Fails Prolog tonal constraint check    |
;;;; | CODE | VERB      | fast    | FAIL  | Fails AST structural category req      |

(define-test outline/lisp-adjective-elegant-pass
  "LISP + ADJECTIVE + elegant → PASS (AST ok, tonal ok)."
  (let* ((kb     (make-corpus-kb))
         (result (rag:score-candidates kb :lisp :adjective
                   '((:token "elegant" :probability 0.9 :category :adjective)))))
    ;; The result for 'elegant' must have both shields passing
    (let ((r (find "elegant" result :key #'rag:token-result-token :test #'equal)))
      (true  (rag:token-result-tonal-pass r))
      (true  (rag:token-result-ast-pass   r))
      (true  (plusp (rag:token-result-score r))))))

(define-test outline/lisp-adjective-sloppy-fail-tonal
  "LISP + ADJECTIVE + sloppy → FAIL (Prolog tonal constraint check fails)."
  (let* ((kb     (make-corpus-kb))
         (result (rag:score-candidates kb :lisp :adjective
                   '((:token "sloppy" :probability 0.8 :category :adjective)))))
    (let ((r (find "sloppy" result :key #'rag:token-result-token :test #'equal)))
      ;; AST passes (adjective in adjective slot), but tonal fails
      (true  (rag:token-result-ast-pass   r))
      (false (rag:token-result-tonal-pass r))
      (is = 0.0 (rag:token-result-score r)))))

(define-test outline/code-verb-fast-fail-ast
  "CODE + VERB + fast(adjective) → FAIL (AST structural category requirement)."
  (let* ((kb     (make-corpus-kb))
         ;; fast is categorised as ADJECTIVE, but the slot requires a VERB
         (result (rag:score-candidates kb :code :verb
                   '((:token "fast" :probability 0.85 :category :adjective)))))
    (let ((r (find "fast" result :key #'rag:token-result-token :test #'equal)))
      ;; AST fails (adjective does not satisfy verb slot)
      (false (rag:token-result-ast-pass r))
      (is = 0.0 (rag:token-result-score r)))))
