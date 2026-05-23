;;;; logic-engine.lisp — Embedded micro-Prolog for DwightSpencerCom
;;;;
;;;; Direct port of the logic engine from ml-prolog-pokemon/logic-engine.lisp.
;;;; Same architecture, different domain: posts replace Pokémon.
;;;;
;;;; The evaluator is a minimal backward-chaining interpreter over ground facts.
;;;; No external Prolog runtime required — the same design decision made in the
;;;; ml-prolog-pokemon study applies here: cl-gambol has a known TCO bug in
;;;; SBCL 2.2.9+; this CL-native engine avoids the dependency entirely.
;;;;
;;;; Fact schemas asserted by corpus.lisp:
;;;;   (post   slug title date word-count)
;;;;   (tag    slug tag-name)
;;;;   (author slug orcid)
;;;;   (series slug series-name position)

(named-readtables:in-readtable :standard)
(in-package #:dsc/logic)

;;;; ── Prolog database ─────────────────────────────────────────────────────────

(defstruct (prolog-db (:conc-name db-))
  "Isolated Prolog database. make-post-kb returns a fresh one per call."
  (clauses (make-hash-table :test 'eq) :type hash-table))

(defun db-assert (db fact)
  "Assert FACT into DB, normalising symbols to keywords."
  (let ((kfact (mapcar (lambda (x)
                         (if (and (symbolp x)
                                  (not (keywordp x))
                                  (not (%var-p x)))
                             (intern (symbol-name x) :keyword)
                             x))
                       fact)))
    (push kfact (gethash (car kfact) (db-clauses db)))))

(defun %var-p (x)
  "T if X is a Prolog variable — symbol whose name starts with ?."
  (and (symbolp x)
       (plusp (length (symbol-name x)))
       (char= #\? (char (symbol-name x) 0))))

(defun %unify (x y env)
  "Unify X and Y under ENV. Returns extended env or :fail."
  (let ((xv (if (%var-p x) (cdr (assoc x env)) x))
        (yv (if (%var-p y) (cdr (assoc y env)) y)))
    (cond ((equal xv yv) env)
          ((%var-p xv)   (acons xv yv env))
          ((%var-p yv)   (acons yv xv env))
          ((and (consp xv) (consp yv))
           (let ((e2 (%unify (car xv) (car yv) env)))
             (unless (eq e2 :fail) (%unify (cdr xv) (cdr yv) e2))))
          (t :fail))))

(defun %subst (term env)
  "Substitute variables in TERM using ENV."
  (cond ((%var-p term)
         (let ((v (cdr (assoc term env))))
           (if v (%subst v env) term)))
        ((consp term) (mapcar (lambda (x) (%subst x env)) term))
        (t term)))

(defun %lookup (db key)
  "Return clauses in DB whose head functor matches KEY."
  (gethash (intern (symbol-name key) :keyword) (db-clauses db)))

(defun %norm-goal (goal)
  "Normalise a goal to a keyword-headed list."
  (if (symbolp goal)
      (list (intern (symbol-name goal) :keyword))
      (cons (intern (symbol-name (car goal)) :keyword) (cdr goal))))

(defun %prove (db goals env)
  "Backward-chain GOALS against DB under ENV. Returns list of envs."
  (if (null goals)
      (list env)
      (let* ((goal  (%norm-goal (car goals)))
             (rest  (cdr goals))
             (clauses (%lookup db (car goal)))
             (results '()))
        (dolist (clause clauses results)
          (let ((e2 (%unify goal clause env)))
            (unless (eq e2 :fail)
              (setf results
                    (nconc results (%prove db rest e2)))))))))

(defun db-prove-all (db goal)
  "Return all solutions for GOAL as a list of environments."
  (%prove db (list goal) '()))

(defun db-prove-first (db goal)
  "Return first solution for GOAL or NIL."
  (first (db-prove-all db goal)))

(defun db-var-all (db goal var)
  "Return all bindings of VAR across solutions of GOAL."
  (mapcar (lambda (env)
            (let ((v (cdr (assoc var env))))
              (if v (%subst v env) var)))
          (db-prove-all db goal)))

(defun make-post-kb ()
  "Create a fresh post knowledge base. Call assert-post-facts to populate."
  (make-prolog-db))
