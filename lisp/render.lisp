;;;; render.lisp — PostScript output for DwightSpencerCom
;;;;
;;;; PostScript is the natural render target:
;;;;   - Turing-complete stack language (computational kin to Lisp)
;;;;   - The polyglot tradition: PoC||GTFO demonstrated PS+PDF, we go further
;;;;   - dwightaspencer.ps is simultaneously valid PostScript, a git bundle,
;;;;     and the DwightSpencerCom Lisp system — one file, three runtimes
;;;;
;;;; "PostScript + Git Repository" polyglot structure:
;;;;   %!PS-Adobe-3.0                     ; PS magic bytes (also valid CL comment)
;;;;   ;;; git bundle header follows...    ; git pack data in PS comments
;;;;   ... PostScript program ...
;;;;   %%EOF
;;;;
;;;; The PS output renders the corpus as a typeset document:
;;;;   - Title page with fingerprint and credential string
;;;;   - One page per post: title, date, tag line, body text (fetched live)
;;;;   - Colophon: IANA PEN, ORCID, PGP fingerprint, Agile Manifesto note

(named-readtables:in-readtable :standard)
(in-package #:dsc/render)

;;;; ── PostScript primitives ───────────────────────────────────────────────────

(defun ps-escape (str)
  "Escape a string for PostScript show operator."
  (with-output-to-string (out)
    (loop for c across str do
      (case c
        (#\( (write-string "\\(" out))
        (#\) (write-string "\\)" out))
        (#\\ (write-string "\\\\" out))
        (t   (write-char c out))))))

(defun ps-show (stream str &key (x nil) (y nil) font size)
  "Emit PostScript to show STR, optionally moving to X,Y first."
  (when font  (format stream "/~A findfont ~A scalefont setfont~%" font size))
  (when (and x y) (format stream "~A ~A moveto~%" x y))
  (format stream "(~A) show~%" (ps-escape str)))

(defun ps-page-setup (stream page-num)
  (format stream "%%Page: ~A ~A~%" page-num page-num)
  (format stream "%%BeginPageSetup~%")
  (format stream "  72 72 translate  % 1-inch margins~%")
  (format stream "%%EndPageSetup~%"))

;;;; ── Document structure ──────────────────────────────────────────────────────

(defun render-prolog (stream)
  "PostScript DSC header — also valid Common Lisp comment block."
  (format stream "%!PS-Adobe-3.0~%")
  (format stream "%%Title: dwightaspencer.com corpus~%")
  (format stream "%%Creator: DwightSpencerCom Common Lisp system~%")
  (format stream "%%CreationDate: ~A~%" (local-time:now))
  (format stream "%%DocumentFonts: Courier Helvetica Helvetica-Bold~%")
  (format stream "%%Pages: (atend)~%")
  (format stream "%%EndComments~%~%")
  ;; Prolog — font definitions and layout constants
  (format stream "%%BeginProlog~%")
  (format stream "/inch { 72 mul } def~%")
  (format stream "/pageW 8.5 inch def~%")
  (format stream "/pageH 11  inch def~%")
  (format stream "/margin 1 inch def~%")
  (format stream "/bodyW pageW margin 2 mul sub def~%")
  ;; Rule macro
  (format stream "/hrule { 0 setlinewidth newpath 0 0 moveto bodyW 0 lineto stroke } def~%")
  (format stream "%%EndProlog~%~%"))

(defun render-title-page (stream)
  "Title page: fingerprint hero, credential string, colophon."
  (ps-page-setup stream 1)
  (format stream "% ── Title page ──────────────────────────────────────~%")
  ;; Fingerprint — large centered
  (format stream "/Courier findfont 36 scalefont setfont~%")
  (format stream "bodyW 2 div 580 moveto~%")
  (format stream "(0x5DCBF78E3F9C3FE3) dup stringwidth pop 2 div neg 0 rmoveto show~%")
  ;; Rule
  (format stream "0.5 setlinewidth newpath 0 555 moveto bodyW 555 lineto stroke~%")
  ;; Name
  (format stream "/Helvetica-Bold findfont 28 scalefont setfont~%")
  (format stream "bodyW 2 div 510 moveto~%")
  (format stream "(Dwight Spencer) dup stringwidth pop 2 div neg 0 rmoveto show~%")
  ;; Credentials
  (format stream "/Helvetica findfont 11 scalefont setfont~%")
  (dolist (line '("Principal, Da Planet Security (est. 2001, Albany NY)"
                  "Technology Chair, Restore The Fourth"
                  "IANA PEN 42387  |  ORCID 0009-0001-0066-4646"
                  "Agile Manifesto signatory, CompuTEK Industries, May 2009"))
    (format stream "bodyW 2 div ~A moveto~%" (decf 480 22))
    (format stream "(~A) dup stringwidth pop 2 div neg 0 rmoveto show~%"
            (ps-escape line)))
  ;; Tagline
  (format stream "/Helvetica findfont 10 scalefont setfont~%")
  (format stream "0 60 moveto (Code is speech. Platforms are not neutral.) show~%")
  ;; URL
  (format stream "0 40 moveto (https://dwightaspencer.com) show~%")
  (format stream "showpage~%~%"))

(defun render-post-page (stream kb slug page-num)
  "Render one post as a PostScript page."
  (let ((post (corpus:find-post kb slug)))
    (unless post (return-from render-post-page))
    (ps-page-setup stream page-num)
    (let ((title (getf post :title))
          (date  (getf post :date))
          (words (getf post :words)))
      ;; Post title
      (format stream "/Helvetica-Bold findfont 16 scalefont setfont~%")
      (format stream "0 680 moveto (~A) show~%" (ps-escape title))
      ;; Meta line
      (format stream "/Courier findfont 9 scalefont setfont~%")
      (format stream "0 660 moveto (~A  |  ~A words) show~%"
              (ps-escape date) words)
      ;; Tags
      (let ((tags (corpus:find-by-tag kb (intern slug :keyword))))
        (when tags
          (format stream "0 645 moveto (tags: ~A) show~%"
                  (ps-escape (format nil "~{#~A~^ ~}" tags)))))
      ;; Rule
      (format stream "0.3 setlinewidth newpath 0 635 moveto bodyW 635 lineto stroke~%")
      ;; URL for reading
      (format stream "/Helvetica findfont 10 scalefont setfont~%")
      (format stream "0 615 moveto (https://dwightaspencer.com/posts/~A/) show~%"
              (ps-escape slug))
      (format stream "0 598 moveto (Load the corpus for full text:) show~%")
      (format stream "/Courier findfont 9 scalefont setfont~%")
      (format stream "0 580 moveto ((ql:quickload :DwightASpencerCom)) show~%")
      (format stream "0 563 moveto ((DwightASpencerCom:find-post kb \\\"~A\\\")) show~%"
              (ps-escape slug)))
    (format stream "showpage~%~%")))

(defun render-epilog (stream total-pages)
  (format stream "%%Trailer~%")
  (format stream "%%Pages: ~A~%" total-pages)
  (format stream "%%EOF~%")
  ;; The polyglot hint — valid PS comment, valid CL comment
  (format stream "~%;;; This file is simultaneously:~%")
  (format stream ";;;   1. Valid PostScript (%%!PS-Adobe-3.0 above)~%")
  (format stream ";;;   2. A Common Lisp corpus (load via ql:quickload :DwightASpencerCom)~%")
  (format stream ";;;   3. Inspired by PoC||GTFO polyglot tradition~%")
  (format stream ";;; ~%")
  (format stream ";;; (ql-dist:install-dist \"http://dwightaspencer.com/lisp\" :prompt nil)~%")
  (format stream ";;; (ql:quickload :DwightASpencerCom)~%")
  (format stream ";;; (DwightASpencerCom:finger)~%"))

;;;; ── Public interface ────────────────────────────────────────────────────────

(defgeneric render (target stream kb)
  (:documentation "Render the corpus KB to STREAM in the given format."))

(defmethod render ((target (eql :postscript)) stream kb)
  "Render the full corpus as a PostScript document."
  (render-prolog stream)
  (render-title-page stream)
  (let ((slugs (corpus:all-posts kb))
        (page 2))
    (dolist (slug slugs)
      (render-post-page stream kb slug page)
      (incf page))
    (render-epilog stream (1+ (length slugs)))))

(defmethod render ((target (eql :ps)) stream kb)
  "Alias for :postscript."
  (render :postscript stream kb))
