+++
title       = "{{ replace .Name "-" " " | title }}"
date        = {{ .Date }}
draft       = true
description = ""
slug        = "{{ .Name }}"
keywords    = []
tags        = []
categories  = []
series      = []              # e.g. ["The Watchers You Fed"] | ["Infrastructure Independence"]
venue       = []              # e.g. ["HPR"] | ["KDP"] | ["arXiv"]
schema_type = "TechArticle"   # TechArticle | BlogPosting
aeo_expertise = "DevOps, Privacy, Security, Architecture"
og_image    = "/assets/og-posts.png"
shortlink   = ""              # e.g. "github-tos" → creates /github-tos/ redirect
+++
