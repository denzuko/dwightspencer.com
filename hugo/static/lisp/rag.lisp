;;;; rag.lisp — com.dwightaspencer/rag
;;;; Neuro-Symbolic Generative Response System (issue #108)
;;;;
;;;; BDD workflow: rag-tests.lisp was written first (red).
;;;; This file makes those tests green.

(in-package #:com.dwightaspencer/rag)
(named-readtables:in-readtable :standard)

;;; ── Trigram tokeniser ─────────────────────────────────────────────────────

(defun char-trigrams (string)
  "Return all overlapping character trigrams of STRING.
Pads with one space on each side. Returns a list of 3-character strings."
  (let* ((p (concatenate 'string " " string " "))
         (n (length p))
         (r '()))
    (dotimes (i (max 0 (- n 2)) (nreverse r))
      (push (subseq p i (+ i 3)) r))))

(defun %split-ws (string)
  "Split STRING on whitespace, dropping empty tokens."
  (let ((r '()) (start 0) (n (length string)))
    (dotimes (i n
              (let ((tok (string-trim " " (subseq string start))))
                (nreverse (if (plusp (length tok)) (cons tok r) r))))
      (when (char= (char string i) #\Space)
        (let ((tok (subseq string start i)))
          (when (plusp (length tok)) (push tok r)))
        (setf start (1+ i))))))

(defun word-trigrams (string)
  "Return overlapping 3-word windows of STRING tokenised on whitespace.
Returns empty list when fewer than 3 tokens."
  (let* ((toks (%split-ws string))
         (n    (length toks))
         (r    '()))
    (dotimes (i (max 0 (- n 2)) (nreverse r))
      (push (list (nth i toks) (nth (1+ i) toks) (nth (+ i 2) toks)) r))))

(defun build-trigram-index (kb)
  "Build a hash table mapping character trigram strings to frequency counts.
Trigrams are extracted from all post titles in KB."
  (let ((idx (make-hash-table :test #'equal)))
    (dolist (title (logic:db-var-all kb '(post ?s ?t ?d ?w) '?t))
      (dolist (tg (char-trigrams (string-downcase title)))
        (incf (gethash tg idx 0))))
    idx))

(defun trigram-similarity (a b)
  "Dice coefficient trigram similarity between strings A and B in [0.0, 1.0]."
  (let* ((sa  (remove-duplicates (char-trigrams (string-downcase a)) :test #'equal))
         (sb  (remove-duplicates (char-trigrams (string-downcase b)) :test #'equal))
         (n   (count-if (lambda (tg) (member tg sb :test #'equal)) sa))
         (d   (+ (length sa) (length sb))))
    (if (zerop d) 0.0 (float (/ (* 2 n) d)))))

;;; ── Tonal rules ───────────────────────────────────────────────────────────

(defun extract-tonal-rules (kb)
  "Extract tonal compatibility facts from KB into a fresh prolog-db.
Asserts (tonal-match NOUN-TAG TOKEN-STRING) facts.
Domain-specific rules are always asserted; corpus-derived rules supplement."
  (let ((db (logic:make-post-kb)))
    ;; Hard-coded domain rules — the foundation of tonal filtering
    (dolist (rule '((tonal-match :code     "fast")
                    (tonal-match :code     "efficient")
                    (tonal-match :code     "elegant")
                    (tonal-match :code     "correct")
                    (tonal-match :code     "typed")
                    (tonal-match :lisp     "elegant")
                    (tonal-match :lisp     "symbolic")
                    (tonal-match :lisp     "expressive")
                    (tonal-match :lisp     "recursive")
                    (tonal-match :privacy  "strong")
                    (tonal-match :privacy  "essential")
                    (tonal-match :security "robust")
                    (tonal-match :security "hardened")
                    (tonal-match :devops   "automated")
                    (tonal-match :devops   "reliable")))
      (logic:db-assert db rule))
    ;; Corpus-derived: tag + title words → tonal association
    (dolist (tag (corpus:all-tags kb))
      (dolist (slug (corpus:find-by-tag kb tag))
        (let ((post (corpus:find-post kb slug)))
          (when post
            (dolist (word (%split-ws (string-downcase (getf post :title))))
              (when (> (length word) 3)
                (logic:db-assert db `(tonal-match ,tag ,word))))))))
    db))

(defun tonal-match-p (rules-db noun-context token)
  "Return T if TOKEN is tonally compatible with NOUN-CONTEXT in RULES-DB.
NOUN-CONTEXT is a keyword. TOKEN is a lowercase string."
  (logic:db-provable-p rules-db `(tonal-match ,noun-context ,token)))

;;; ── AST category filter ───────────────────────────────────────────────────

(defparameter *category-compatibility*
  '((:adjective . (:adjective))
    (:verb       . (:verb))
    (:noun       . (:noun))
    (:adverb     . (:adverb :verb))
    (:article    . (:article))
    (:preposition . (:preposition)))
  "Alist: required-category → list of token categories that satisfy it.")

(defun ast-category-match-p (required-category token-category)
  "Return T if TOKEN-CATEGORY satisfies the REQUIRED-CATEGORY AST position."
  (let ((compatible (cdr (assoc required-category *category-compatibility*))))
    (and compatible (not (null (member token-category compatible))))))

;;; ── Parallel shields — scoring ────────────────────────────────────────────

(defstruct (token-result (:constructor make-token-result
                          (token probability category tonal-pass ast-pass score)))
  "Result of running a candidate token through both validation shields."
  token probability category tonal-pass ast-pass score)

(defun score-candidate (rules-db noun-context required-category candidate)
  "Score a single CANDIDATE through the AST + Prolog tonal shields.
Returns a token-result. Score is probability when both shields pass, else 0.0."
  (let* ((token    (getf candidate :token))
         (prob     (getf candidate :probability 0.0))
         (category (getf candidate :category :unknown))
         (tonal-p  (tonal-match-p rules-db noun-context (string-downcase token)))
         (ast-p    (ast-category-match-p required-category category))
         (score    (if (and tonal-p ast-p) prob 0.0)))
    (make-token-result token prob category tonal-p ast-p score)))

(defun score-candidates (kb noun-context required-category candidates)
  "Run CANDIDATES through the parallel shields. Returns token-results sorted by score desc."
  (let* ((rules  (extract-tonal-rules kb))
         (scored (mapcar (lambda (c)
                           (score-candidate rules noun-context required-category c))
                         candidates)))
    (sort scored #'> :key #'token-result-score)))

(defun select-token (kb noun-context required-category candidates)
  "Return the best valid token string, or NIL if none pass both shields."
  (let* ((results (score-candidates kb noun-context required-category candidates))
         (best    (first results)))
    (when (and best (plusp (token-result-score best)))
      (token-result-token best))))

(defun generate-response (template kb noun-context required-category candidates)
  "Insert the selected token into TEMPLATE (using ~A), or a placeholder if none pass."
  (format nil template
          (or (select-token kb noun-context required-category candidates)
              "[no valid token]")))

;;; ── Retrieval layer ─────────────────────────────────────────────────────

(defun find-similar (kb query-string &key (top-n 5))
  "Return posts from KB ranked by trigram similarity to QUERY-STRING.
Each result is a plist with :slug and :score (float 0.0-1.0), sorted
descending. Adjacent questions are surfaced via character trigrams even
when not verbatim matches. TOP-N limits results (default 5)."
  (let ((q-tgs (remove-duplicates
                (char-trigrams (string-downcase query-string))
                :test #'equal))
        (results '()))
    (dolist (slug (corpus:all-posts kb))
      (let* ((post   (corpus:find-post kb slug))
             (t-tgs  (remove-duplicates
                      (char-trigrams (string-downcase
                                      (or (getf post :title) "")))
                      :test #'equal))
             (common (count-if (lambda (tg) (member tg t-tgs :test #'equal))
                               q-tgs))
             (denom  (+ (length q-tgs) (length t-tgs)))
             (score  (if (zerop denom) 0.0 (float (/ (* 2 common) denom)))))
        (when (plusp score)
          (push (list :slug slug :score score) results))))
    (let ((ranked (sort results #'> :key (lambda (r) (getf r :score)))))
      (if top-n (subseq ranked 0 (min top-n (length ranked))) ranked))))

(defun serialize-context (posts)
  "Serialize a list of post plists to a plain-text context block.
Each post is rendered as a titled section suitable for LLM prompt input."
  (if (null posts)
      ""
      (with-output-to-string (s)
        (dolist (post posts)
          (when post
            (format s "=== ~A (~A, ~A words) ===~%slug: ~A~%~%"
                    (or (getf post :title) "")
                    (or (getf post :date)  "")
                    (or (getf post :words) 0)
                    (or (getf post :slug)  "")))))))

(defun context-for-question (kb question &key (top-n 3))
  "Retrieve posts similar to QUESTION from KB and return as a context string.
Combines find-similar and serialize-context. TOP-N limits retrieval (default 3)."
  (serialize-context
   (mapcar (lambda (r) (corpus:find-post kb (getf r :slug)))
           (find-similar kb question :top-n top-n))))

;;; ── Tonal rule introspection ─────────────────────────────────────────────

(defun tonal-rules-for (rules-db noun-context)
  "Return all token strings tonally compatible with NOUN-CONTEXT in RULES-DB."
  (logic:db-var-all rules-db `(tonal-match ,noun-context ?token) '?token))
