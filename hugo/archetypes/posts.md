+++
title       = "{{ replace .Name "-" " " | title }}"
date        = {{ .Date }}
draft       = true
description = ""
slug        = "{{ .Name }}"
keywords    = []
tags        = []
categories  = []
schema_type = "TechArticle"   # TechArticle | BlogPosting
aeo_expertise = "DevOps, Privacy, Security, Architecture"
og_image    = "/assets/og-posts.png"
shortlink   = ""              # e.g. "github-tos" → creates /github-tos/ redirect
+++
