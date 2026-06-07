+++
title       = "neural.sh: A Shell Script Where a Plugin Used to Be"
date        = "2026-05-26"
draft       = false
description = "After installing ALE and reviewing w0rp's other work, I found neural.vim — well-built, not UNIX. neural.sh is the shell answer to the same problem."
slug        = "11-neural-sh"
keywords    = ["llm", "shell", "unix", "plan9", "chatgpt", "neural.sh", "cli", "privacy", "infrastructure"]
tags        = ["infrastructure", "open-source", "privacy", "history"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Systems Design, Unix, LLM Tooling, Infrastructure"
aliases     = ["/11-neural-sh/"]
og_image    = "/assets/og-posts.png"
series      = ["Dead Reckoning"]

[related_post]
  slug  = "12-owning-your-memory"
  label = "post 12 covers the same constraint-as-design argument applied to C99 memory management"
+++

<p>After installing ALE, I went looking at what else w0rp had written. <a href="https://github.com/dense-analysis/neural">neural.vim</a> was there — a Vim plugin for ChatGPT integration, from the same author who built one of the most solid LSP implementations in the Vim ecosystem.</p>

<p>It's well-built. It also assumes the editor is the unit of composition. If your workflow lives in Vim, that holds. If you're working across a shell, a mail client, a plumber script, and pipelines stitched together with POSIX glue, a plugin that can't be invoked outside the editor is a constraint, not a tool.</p>

<p><a href="https://git.sr.ht/~denzuko/neural.sh">neural.sh</a> is the answer to the same problem from the other direction. The <code>.sh</code> suffix follows w0rp's own convention — suffix as namespace, same as <code>.vim</code> signals editor scope.</p>

<pre><code>cat error.log | neural "what is causing this?"
git diff | neural "summarize these changes"
neural "write a makefile target that runs shellcheck" &gt;&gt; Makefile
</code></pre>

<h2 id="the-unix-model">The UNIX model — and Plan 9</h2>

<p>neural.sh is a text filter: prompt in on stdin or as arguments, response out on stdout. It composes with everything that speaks text streams.</p>

<p>Plan 9's plumber routes messages between programs based on content rules. neural.sh fits that model without modification:</p>

<pre><code># Plan 9 plumber rule — route LLM queries to neural
type is text
data matches 'ASK:(.+)'
plumb to win
plumb start neural "$1"
</code></pre>

<pre><code># procmail recipe (pipe action) — summarise incoming mail over 10k chars
:0 c
* &gt; 10000
| neural "summarise this email in two sentences" &gt;&gt; ~/.mail/summaries

# procmail milter — classify and tag before delivery
:0 fw
| neural "output one of: technical, personal, spam" | \
  xargs -I{} formail -A "X-Neural-Class: {}"

# mailcap — pipe text/plain attachments through neural for classification
text/plain; neural "classify: technical, personal, or spam?" &lt; %s

# notmuch + fzf — pipe selected thread to neural for triage
notmuch search --output=messages tag:inbox | \
  fzf --preview 'notmuch show {}' | \
  xargs notmuch show | \
  neural "what action does this thread require?"

# notmuch + fzf — extract follow-up tasks from flagged thread
notmuch show thread:$(notmuch search --output=threads tag:flagged | head -1) | \
  neural "list action items from this thread"
</code></pre>

<p>That last pipeline is a real workflow — triage your inbox without leaving the terminal, without a plugin, without anything that knows about LLMs except the final stage of the pipe. The upstream tools are unchanged.</p>

<h2 id="what-it-couldnt-do">What it couldn't do then — and what it can now</h2>

<p>Ollama launched in July 2023, six weeks after neural.sh's last commit. llama.cpp existed from March 2023 but running anything useful locally still required hardware most people didn't have.</p>

<p>neural.sh was built for environments where local inference isn't available: SDF, Panix, a Raspberry Pi, Termux, Plan 9. The OPENAI_API_KEY environment variable was how OpenAI's own documentation specified key handling at the time, and how every tool in the space worked. The architecture was always pointed at the shell — what sat at the other end of the socket was configuration.</p>

<p>That configuration lives in <code>config.m4</code>, a DSL consumed at build time by <code>neural.m4</code>. The model is not hardcoded — <code>text-davinci-003</code> was the default because it was current in May 2023. Adding a new model or a local Ollama endpoint is a one-line change to <code>config.m4</code> and a <code>sed</code> pass on <code>neural.m4</code>. Where local inference is available, neural.sh routes there without modification. The interface doesn't change. The data stops leaving.</p>

<h2 id="the-architecture-held">The architecture held</h2>

<p>neural.sh is unmaintained. The <code>text-davinci-003</code> default was deprecated by OpenAI in January 2024. The source is on sourcehut as a dated artifact.</p>

<p>The architecture is the point. A generation of LLM tooling built GUIs, sidebars, workspaces, and chat interfaces. The filter model — stdin, stdout, compose — stayed correct the whole time. The tools that inherited it are the ones worth using now.</p>

<h2 id="contribute">Contribute</h2>

<p>The source is at <a href="https://git.sr.ht/~denzuko/neural.sh">git.sr.ht/~denzuko/neural.sh</a>. The mailing lists are on sourcehut:</p>

<ul>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-devel">neural.sh-devel</a> — patches and development discussion</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-discuss">neural.sh-discuss</a> — general chat</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-announce">neural.sh-announce</a> — release announcements</li>
  <li><a href="https://lists.sr.ht/~denzuko/neural.sh-fdn">neural.sh-fdn</a> — ASCII-armored binary releases</li>
</ul>

<p>Adding model support is a one-line change to <code>config.m4</code>. Read the source, understand the DSL, send a patch to neural.sh-devel via <code>git send-email</code>. That is how good infrastructure grows.</p>
