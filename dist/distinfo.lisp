;;;; Redist dist configuration for dwightaspencer.com
;;;; https://shirakumo.org/docs/redist
;;;;
;;;; Usage (after installing redist binary):
;;;;   cd dist && redist compile -v
;;;;
;;;; The generated releases/ directory is served at:
;;;;   http://dwightaspencer.com/lisp/

(redist:define-project |DwightASpencerCom|
    ((:github "https://github.com/denzuko/dwightaspencer.com.git"
      :branch "master"))
  :source-directory #p"../hugo/static/lisp/"
  :excluded-paths ("hugo/" ".github/" "brand/" "dist/"))

(redist:define-dist |DwightASpencerCom| (|DwightASpencerCom|)
  :url "http://dwightaspencer.com/lisp/")
