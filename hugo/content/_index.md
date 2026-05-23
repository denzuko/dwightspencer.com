+++
title       = "Dwight Spencer - 0x5DCBF78E3F9C3FE3"
description = "Code is speech. Platforms are not neutral. Principal, Da Planet Security. Technology Chair, Restore The Fourth. DevOps engineer, security researcher, open source advocate, author."
date        = "2025-01-20"
+++

```lisp
#!/usr/bin/env sh
"true" ; exec /usr/bin/env sbcl --noinform --script "$0" "$@"

(defpackage :DwightSpencerCom
  (:use #:cl)
  (:export #:finger)
  (:export #:Self))
(use-package :DwightSpencerCom)
(defclass Self() ())
(defmethod AboutMe((object Self)) 
    "Just a SysOp turned founder of #devops now coding AI, Blockchain, Commercial Systems."
    '(:Resume
        '(:Education (list :UoP :Cornell))

        '(:Languages (list
            :Golang
            :ANSI-C
            :ASM
            :TypeScript
            :Python
            :CommonLisp))

        '(:Projects (list
            '(:Metis "https://github.com/3um-Group")
            '(:2600_Moderator "https://reddit.com/r/2600")))

        '(:Volunteering (list
            '(:Score "https://Score.org")
            '(:Internet-Archive "https://archive.org")
            '(:9front "https://only9fans.com")
            '(:Debian "https://debian.org")))

        '(:Certs (list
            '(:RHCE "February 2007")
            '(:AWS_Solution_Architect "March 2015")
            '(:Amazon_Leadership "March 2019")
            '(:GCP_Cloud_Architect "January 2022")
            '(:CISM "June 2022")
            '(:ORCID "https://orcid.org/0009-0001-0066-4646")
            '(:Keybase "https://Keybase.io/Denzuko/pubkey")))

        '(:Tools (list
            :AlpineLinux :VIM :Vlime :VimWiki :entr :zmk :gnumake
            :plan9ports :git-flow :git-bug :git-email
            :charmbracelet_soft_serve :notmuch-mail :slrn
            :Ansible :Terraform :Podman :Nomad :Consul :Ollama))))

(defun finger() 
 (let ((DwightSpencer (make-instance 'Self)))
    (format t "~a~&" (AboutMe DwightSpencer))))

(finger)
```
