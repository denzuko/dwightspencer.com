+++
title       = "{{ replace .Name "-" " " | title }}"
date        = {{ .Date }}
publishDate = {{ .Date }}
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

# Optional: renders the terminal-register "; → post NN" closer via single.html.
# Use for posts in a running series or with a direct predecessor.
# Standalone reference posts (resource lists, references sections) and
# historical accounts (credentials block) should use contextual closers instead.
# [related_post]
#   slug  = "00-hellowrld"        # post slug without /posts/ prefix or trailing slash
#   label = "post 00 is the origin of this thread"
+++
