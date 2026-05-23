+++
title       = "The Shell Is Gone (For Now)"
date        = "2026-05-23"
draft       = false
description = "hack.dapla.net is offline. What it was, what took it down, and what it will be when it comes back — Soft Serve, 3270, and building infrastructure you actually control."
slug        = "08-the-shell-is-gone"
keywords    = ["hack.dapla.net", "self-hosting", "infrastructure", "Soft Serve", "BBS", "3270", "ARG", "Ellison Digital Minerals", "dapla.net"]
tags        = ["infrastructure", "self-hosting", "Write-Ups"]
categories  = ["articles"]
series      = ["Infrastructure Independence"]
schema_type = "BlogPosting"
aeo_expertise = "DevOps, Open Source, Privacy, Security, Architecture"
aliases     = ["/08-the-shell-is-gone/"]
og_image    = "/assets/og-posts.png"
+++

<h2 id="the-endpoint-is-down">The endpoint is down.</h2>

<p>If you came here from
<a href="/posts/00-hellowrld/">post 00</a> expecting to SSH into
<code>hack.dapla.net</code> and find security research papers, easter eggs,
and a Soft Serve git interface — you can't. It's returning 503.
The SSH port is closed. The service is offline.</p>

<p>This post is the status update that post 00 implicitly promised.</p>

<h2 id="what-it-was">What it was</h2>

<p><code>hack.dapla.net</code> ran a web shell accessible over HTTPS — originally
a Quest 2 VR web interface repurposed for remote server admin and used
as an entry point for the
<a href="https://klaxon.dapla.net">Ellison Digital Minerals</a> alternate reality game.
The ARG is set in the Albany/Troy area; the endpoint was both a functional
admin surface and a narrative anchor — a real server you could reach,
at an address that mattered to the story.</p>

<p>It also ran Soft Serve, the Charmbracelet SSH-accessible git server,
hosting research whitepapers and a handful of easter eggs that rewarded
anyone who bothered to read <code>ssh hack.dapla.net help</code> carefully.</p>

<p>The Quest 2 web shell was always a temporary arrangement — convenience
infrastructure layered over a node that deserved better architecture.
When the underlying host needed maintenance, the temporary arrangement
didn't survive the downtime gracefully. That's the whole story.</p>

<h2 id="what-went-wrong">What went wrong, specifically</h2>

<p>Nothing dramatic. No breach, no legal action, no infrastructure fire.
The host running the web shell layer on
<code>gorkon.dapla.net</code> — the backend node <code>hack.dapla.net</code> proxied through
HAProxy — needed a rebuild. The Quest 2 VR web shell process wasn't
worth porting forward. It was always a kludge; rebuilding it as the same
kludge would be repeating the mistake.</p>

<p>The Soft Serve instance and the research content are intact on
<code>storage/</code> ZFS. Nothing was lost. The service just isn't
currently reachable.</p>

<h2 id="what-comes-back">What comes back</h2>

<p>The plan is better than what was there:</p>

<ul>
<li><strong>Soft Serve</strong> back on SSH — same address, same key,
Podman quadlet this time so it survives reboots and host rebuilds
without a prayer to the process gods</li>
<li><strong>3270 terminal interface</strong> — a proper BBS/CICS front end
accessible via a TN3270 client, for the audience that knows what that means
and appreciates that the old interfaces were designed for the constraints
of the network, not designed to ignore them</li>
<li><strong>ARG re-integration</strong> — the Ellison Digital Minerals narrative
needs the endpoint back. The absence has been noted in-universe.
The return will be an event, not just a service restoration.</li>
</ul>

<p>Timeline: when it's ready. Self-hosted infrastructure gets done right
or it doesn't get done. Shipping a second kludge in the same spot
would be embarrassing.</p>

<h2 id="the-broader-point">The broader point</h2>

<p>This is what self-hosting actually looks like. Not the blog post version
where you spin up a VPS and everything works. The real version:
nodes go down, temporary arrangements calcify, rebuilds take longer
than planned because the rebuild is also the opportunity to do it
properly, and in the meantime the <code>ssh</code> command in a three-year-old
blog post returns nothing.</p>

<p>The answer isn't to move back to a managed platform where someone else
absorbs the maintenance burden in exchange for owning your data and
your availability. The answer is to build better infrastructure,
document the quadlets, and accept that real infrastructure sometimes
has gaps while you're fixing it.</p>

<p><code>hack.dapla.net</code> will be back. It'll be better.
This post will be updated with a date when it is.</p>

<p class="finger-exit"><span style="color:#75715e">; → <a href="/posts/05-infrastructure-independence/" style="color:#9a9a9a">post 05</a> covers the philosophy in more depth</span></p>
