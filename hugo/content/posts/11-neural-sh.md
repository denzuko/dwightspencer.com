+++
title       = "neural.sh: A Shell Script Where a Plugin Used to Be"
date        = "2026-05-26"
draft       = false
description = "neural.sh is a composable text filter for the shell — stdin in, LLM response out. Built on the same Unix philosophy that makes procmail, notmuch, and the plumber useful."
slug        = "11-neural-sh"
keywords    = ["llm", "shell", "unix", "plan9", "chatgpt", "neural.sh", "cli", "privacy", "infrastructure"]
tags        = ["infrastructure", "open-source", "privacy", "history"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Systems Design, Unix, LLM Tooling, Infrastructure"
aliases     = ["/11-neural-sh/"]
og_image    = "/assets/og-posts.png"
series      = ["Infrastructure Independence"]

[related_post]
  slug  = "05-infrastructure-independence"
  label = "post 05 covers the infrastructure ownership argument this tooling sits inside"
+++

<p>At its core, like all Unix programs, neural.sh is a composable text processor: prompt in on stdin or as an argument, response out on stdout. It composes with everything that speaks text streams.</p>

<pre><code>cat error.log | neural "what is causing this?"
git diff | neural "summarize these changes"
neural "write a makefile target that runs shellcheck" >> Makefile
</code></pre>

<p>neural.sh was my answer to the same problem w0rp solved with neural.vim, but from a different direction. Named <code>.sh</code> in honor of his plugin — suffix as namespace, editor scope vs. shell scope.</p>

<h2 id="the-unix-model">The UNIX model — and Plan 9</h2>

<p>After installing ALE I went to see what else w0rp had written and found neural.vim. Good plugin, well built. Not UNIX philosophy — a plugin reaches into the editor's state rather than composing in the shell. Plan 9's plumber routes messages between programs based on content rules. neural.sh fits that model without modification:</p>

<pre><code># Plan 9 plumber rule — route LLM queries to neural
type is text
data matches 'ASK:(.+)'
plumb to win
plumb start neural "$1"
</code></pre>

<pre><code># procmail recipe — summarise incoming mail over 10k chars before filing
:0 c
* > 10000
| neural "summarise this email in two sentences" >> ~/.mail/summaries

# procmail milter — classify and tag before delivery
:0 fw
| neural "output one of: technical, personal, spam" | \
  xargs -I{} formail -A "X-Neural-Class: {}"

# mailcap — pipe text/plain attachments through neural for classification
text/plain; neural "classify: technical, personal, or spam?" < %s

# notmuch + fzf — pipe selected thread to neural for triage
notmuch search --output=messages tag:inbox | \
  fzf --preview 'notmuch show {}' | \
  xargs notmuch show | \
  neural "what action does this thread require?"

# notmuch + fzf — extract follow-up tasks from flagged thread
notmuch show thread:$(notmuch search --output=threads tag:flagged | head -1) | \
  neural "list action items from this thread"
</code></pre>

<p>These are real workflows. Inbox triage, thread extraction, mail classification — without leaving the terminal, without a plugin, without anything that knows about LLMs except the final stage of the pipe. The upstream tools are unchanged.</p>

<h2 id="the-right-environment">The right environment for the right tool</h2>

<p>Ollama launched in July 2023, six weeks after neural.sh. llama.cpp existed from March 2023 but running anything useful locally still required hardware most people didn't have — and still requires hardware that SDF, Panix, a Raspberry Pi, Termux, or Plan 9 don't provide.</p>

<p>neural.sh was built for those environments. <code>OPENAI_API_KEY</code> was how OpenAI's own documentation specified key handling at the time — every tool in that cohort used it, from the official Python SDK down. The architecture was always pointed at the shell; what sat at the other end of the socket was configuration, not identity.</p>

<p>That configuration lives in <code>config.m4</code>, a DSL consumed at build time by <code>neural.m4</code>. The model is not hardcoded — <code>text-davinci-003</code> was the default because it was current in May 2023. Adding a new model or a local Ollama endpoint is a one-line change to <code>config.m4</code> and a <code>sed</code> pass on <code>neural.m4</code>. Where local inference is available, neural.sh routes there without modification. The interface doesn't change. The data stops leaving.</p>

<h2 id="the-architecture-held">The architecture held</h2>

<p>neural.sh is unmaintained. The <code>text-davinci-003</code> default was deprecated by OpenAI in January 2024. A generation of LLM tooling built GUIs, sidebars, and chat interfaces instead. The filter model stayed correct the whole time — and the same composable architecture that made it useful in 2023 makes it useful today, whether the model lives on a remote API or a local GPU.</p>

<p>The source is at <a href="https://git.sr.ht/~denzuko/neural.sh">git.sr.ht/~denzuko/neural.sh</a>. The mailing lists are on sourcehut:</p>

<ul>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-devel">neural.sh-devel</a> — patches and development discussion</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-discuss">neural.sh-discuss</a> — general chat</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-announce">neural.sh-announce</a> — release announcements</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-fdn">neural.sh-fdn</a> — ASCII-armored binary releases</li>
</ul>

<p>Adding model support is a one-line change to <code>config.m4</code>. Read the source, understand the DSL, send a patch to neural.sh-devel via <code>git send-email</code>. That is how good infrastructure grows.</p>
