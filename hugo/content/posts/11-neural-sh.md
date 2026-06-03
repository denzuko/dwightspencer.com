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

<p>The <code>.sh</code> suffix follows the same convention as neural.vim — suffix as namespace, editor scope vs. shell scope. neural.sh was named in honor of w0rp's work on neural.vim, since his was called neural.vim at the time, signaling it was for editors. This one is for the shell.</p>

<h2 id="the-unix-model">The UNIX model — and Plan 9</h2>

<p>Plan 9's plumber routes messages between programs based on content rules. neural.sh fits that model without modification:</p>

<pre><code># Plan 9 plumber rule — route LLM queries to neural
type is text
data matches 'ASK:(.+)'
plumb to win
plumb start neural "$1"
</code></pre>

<pre><code># procmail recipe (pipe action) — summarise incoming mail over 10k chars
:0 c
* > 10000
| neural "summarise this email in two sentences" >> ~/.mail/summaries

# mailcap — pipe text/plain attachments through neural for classification
text/plain; neural "classify: technical, personal, or spam?" < %s

# notmuch + fzf — search mail, pipe selected thread to neural for triage
notmuch search --output=messages tag:inbox | \
  fzf --preview 'notmuch show {}' | \
  xargs notmuch show | \
  neural "what action does this thread require?"

# notmuch + fzf — pipe thread into neural to extract follow-up tasks
notmuch show thread:$(notmuch search --output=threads tag:flagged | head -1) | \
  neural "list action items from this thread"
</code></pre>

<p>The last two pipelines are real workflows — inbox triage and thread extraction without leaving the terminal, without a plugin, without anything that knows about LLMs except the final stage of the pipe. The upstream tools are unchanged.</p>

<h2 id="what-it-couldnt-do">What it couldn't do then — and what it can now</h2>

<p>Ollama launched in July 2023, six weeks after neural.sh. llama.cpp existed from March 2023 but running anything useful locally still required hardware most people didn't have.</p>

<p>neural.sh was built for environments where local inference isn't available: SDF, Panix, a Raspberry Pi, Termux, Plan 9. The <code>OPENAI_API_KEY</code> environment variable was how OpenAI's own documentation specified key handling at the time — that was the standard, not a design choice. The architecture was always pointed at the shell; what sat at the other end of the socket was configuration.</p>

<p>That configuration lives in <code>config.m4</code>, a DSL consumed at build time by <code>neural.m4</code>. The model is not hardcoded — <code>text-davinci-003</code> was the default because it was current in May 2023. Adding a new model or endpoint is a one-line change to <code>config.m4</code> and a <code>sed</code> pass on <code>neural.m4</code>. The build system handles the rest.</p>

<p>Where local inference is available — Ollama, llama.cpp, anything with an OpenAI-compatible API — neural.sh routes there without modification. The interface doesn't change. The data stops leaving.</p>

<h2 id="where-it-went">Where it went</h2>

<p>neural.sh is unmaintained. The <code>text-davinci-003</code> default was deprecated by OpenAI in January 2024. The source is on sourcehut as a dated artifact. The architecture is the point — a generation of LLM tooling built GUIs, sidebars, and chat interfaces. The filter model stayed correct the whole time.</p>

<h2 id="contribute">Patches welcome</h2>

<p>The repo is at <a href="https://git.sr.ht/~denzuko/neural.sh">~denzuko/neural.sh</a>. Adding model support is a one-line change to <code>config.m4</code>. Send patches via <code>git send-email</code> to the <a href="https://lists.sr.ht/~denzuko/neural.sh-devel">neural.sh-devel list</a>. Read the source, understand the DSL, send a clean patch.</p>

<p>That's what good infrastructure looks like.</p>
