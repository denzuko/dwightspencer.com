;;;; run-tests.lisp — CLI test runner for DwightASpencerCom
;;;;
;;;; Usage:
;;;;   sbcl --load run-tests.lisp
;;;;
;;;; Requires Quicklisp installed at ~/quicklisp/ or $QUICKLISP_HOME.
;;;; Dependencies fetched via Quicklisp: named-readtables, parachute.

(require :asdf)

(let ((ql (or (uiop:getenv "QUICKLISP_HOME")
              (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))))
  (unless (probe-file ql)
    (error "Quicklisp not found at ~A. Set QUICKLISP_HOME or install Quicklisp." ql))
  (load ql))

(ql:quickload '("named-readtables" "parachute") :silent t)

(let ((dir (make-pathname :directory (pathname-directory *load-truename*))))
  (load (merge-pathnames "package.lisp" dir))
  (named-readtables:in-readtable :standard)
  (load (merge-pathnames "logic-engine.lisp" dir))
  (load (merge-pathnames "corpus.lisp" dir))
  (load (merge-pathnames "render.lisp" dir))
  (load (merge-pathnames "dwightaspencer.lisp" dir))
  (load (merge-pathnames "tests.lisp" dir)))

(let* ((results (parachute:test-toplevel :dwightaspencercom-tests
                                          :report 'parachute:plain))
       (status (parachute:status results)))
  (format t "~%~%Result: ~A~%" status)
  (uiop:quit (if (eq :passed status) 0 1)))
