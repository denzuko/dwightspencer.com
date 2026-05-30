+++
title       = "Uses"
date        = "2026-05-23"
description = "Tools, hardware, and infrastructure stack — what Dwight Spencer actually runs."
layout      = "single"
type        = "uses"
aliases     = ["/uses/"]
+++

<p class="meta">For the HPR/aNONradio audience who asks "what do you run." Updated when things actually change.</p>

<h2>Editor &amp; terminal</h2>

<ul>
<li>VIM + Vlime (Common Lisp REPL integration) + VimWiki</li>
<li>Share Tech Mono everywhere code appears</li>
<li>tmux — always, no exceptions</li>
<li><code>entr</code> for file-watch build loops</li>
<li><code>notmuch-mail</code> + <code>slrn</code> (yes, Usenet)</li>
</ul>

<h2>Languages (daily drivers)</h2>

<ul>
<li>C99 — primary for systems work (<code>nob.h</code> build driver, arena allocator, <code>sv.h</code> string views)</li>
<li>Common Lisp (SBCL) — corpus, finger block, render layer</li>
<li>POSIX sh — scripts, no bashisms</li>
<li>Golang — occasional; legacy projects</li>
<li>TypeScript — when the client insists</li>
</ul>

<h2>Infrastructure</h2>

<ul>
<li>Podman quadlets — rootless systemd container management (not Docker)</li>
<li>HAProxy — reverse proxy and load balancing (not Nginx)</li>
<li>ZFS — <code>storage/</code> pool on gorkon; <code>storage/containers/</code> and <code>storage/users/</code> layout</li>
<li>FreeBSD / NetBSD — server targets; Alpine Linux for containers</li>
<li>Terraform + Consul + Nomad — orchestration layer</li>
<li>Ansible — configuration management</li>
<li>OPA/Rego — policy gates on all C projects</li>
</ul>

<h2>Hardware</h2>

<ul>
<li>ZMK-based keyboard (custom layout)</li>
<li>Plan 9 ports running on whatever is nearby</li>
<li>Systronix-100 — hobbyist PDP-11 compatible punch card reader (rs232 interface)</li>
</ul>

<h2>Radio</h2>

<ul>
<li>Da Planet Radio — Liquidsoap 2.3.2 + Icecast, GStreamer UDP studio input</li>
<li>Eggdrop IRC bots — BOFH/PFY ecosystem (TCL persona scripts)</li>
<li>Ham radio — amateur license; radiograms, APRS</li>
</ul>

<h2>Desk software</h2>

<ul>
<li>Alpine Linux workstation</li>
<li>git-flow + git-bug + git-email (patch-based workflow)</li>
<li>gnumake — build coordination</li>
<li>plan9ports — acme, plumber</li>
<li>Ollama — local LLM inference, privacy-first</li>
</ul>

<h2>This site</h2>

<ul>
<li>Hugo 0.129.0 extended — static site generator</li>
<li>GitHub Pages (gh-pages branch) behind Cloudflare CDN</li>
<li>Pagefind — self-hosted search, zero external deps</li>
<li>No analytics, no tracking, no consent banners — <a href="/privacy/">privacy policy</a></li>
<li>Bricolage Grotesque + Share Tech Mono (Google Fonts — roadmap: self-host)</li>
</ul>
