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
+++

After installing ALE, I went looking at what else w0rp had written.
[neural.vim](https://github.com/dense-analysis/neural) was there —
a Vim plugin for ChatGPT integration, from the same author who built
one of the most solid LSP implementations in the Vim ecosystem.

It's well-built. It also assumes the editor is the unit of composition.
If your workflow lives in Vim, that holds. If you're working across a shell,
a mail client, a plumber script, and pipelines stitched together with
POSIX glue, a plugin that can't be invoked outside the editor is a
constraint, not a tool.

[neural.sh](https://git.sr.ht/~denzuko/neural.sh) is the answer to the
same problem from the other direction. The `.sh` suffix follows w0rp's
own convention — suffix as namespace, same as `.vim` signals editor scope.

```sh
cat error.log | neural "what is causing this?"
git diff | neural "summarize these changes"
neural "write a makefile target that runs shellcheck" >> Makefile
```

<h2 id="the-unix-model">The UNIX model — and Plan 9</h2>

neural.sh is a text filter: prompt in on stdin or as arguments, response
out on stdout. It composes with everything that speaks text streams.

Plan 9's plumber routes messages between programs based on content rules.
neural.sh fits that model without modification:

```
# Plan 9 plumber rule — route LLM queries to neural
type is text
data matches 'ASK:(.+)'
plumb to win
plumb start neural "$1"
```

```sh
# procmail recipe (pipe action) — summarise incoming mail over 10k chars
:0 c
* > 10000
| neural "summarise this email in two sentences" >> ~/.mail/summaries

# mailcap — pipe text/plain attachments through neural for classification
text/plain; neural "classify: technical, personal, or spam?" < %s

# notmuch + fzf — search mail, pipe selected thread to neural
notmuch search --output=messages tag:inbox | \
  fzf --preview 'notmuch show {}' | \
  xargs notmuch show | \
  neural "what action does this thread require?"
```

That last pipeline is a real workflow — triage your inbox without leaving
the terminal, without a plugin, without anything that knows about LLMs
except the final stage of the pipe. The upstream tools are unchanged.

<h2 id="what-it-couldnt-do">What it couldn't do then — and what it can now</h2>

Ollama launched in July 2023, six weeks after neural.sh's last commit.
llama.cpp existed from March 2023 but running anything useful locally
still required hardware most people didn't have.

neural.sh was built for environments where local inference isn't available:
SDF, Panix, a Raspberry Pi, Termux, Plan 9. The OPENAI_API_KEY environment
variable was how OpenAI's own documentation specified key handling at the
time, and how every tool in the space worked. The architecture was always
pointed at the shell — what sat at the other end of the socket was
configuration.

That configuration lives in `config.m4`, a DSL consumed at build time
by `neural.m4`. The model is not hardcoded — `text-davinci-003` was the
default because it was current in May 2023. Pointing neural.sh at a
different endpoint or model is a one-line change to `config.m4` and
a `sed` pass on `neural.m4`. The build system handles the rest.

Where local inference is available — Ollama, llama.cpp, anything with
an OpenAI-compatible API — neural.sh routes there without modification.
The interface doesn't change. The data stops leaving.

<h2 id="where-it-went">Where it went</h2>

neural.sh is unmaintained. The `text-davinci-003` default was deprecated
by OpenAI in January 2024. The source is on sourcehut as a dated artifact.

The architecture is the point. A generation of LLM tooling built GUIs,
sidebars, workspaces, and chat interfaces. The filter model — stdin,
stdout, compose — stayed correct the whole time. The tools that inherited
it are the ones worth using now.

<h2 id="contribute">Contribute</h2>

The repo is at [~denzuko/neural.sh](https://git.sr.ht/~denzuko/neural.sh).
The model configuration is a one-line change. Patches and model support
updates welcome via `git send-email` to the
[devel list](https://lists.sr.ht/~denzuko/neural.sh-devel) — read the
source, understand the `config.m4` DSL, send a clean patch. That's what
good infrastructure looks like.
