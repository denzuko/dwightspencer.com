+++
title       = "The Shell Is Gone (For Now)"
date        = "2026-05-23"
draft       = false
description = "hack.dapla.net is offline. What it was, why Soft Serve and Wish never got along, and what the node might become — BBS, CTF, storefront, Gopher, livestream playground."
slug        = "08-the-shell-is-gone"
keywords    = ["hack.dapla.net", "self-hosting", "infrastructure", "Soft Serve", "BBS", "XMCore", "CTF", "gopher", "dapla.net", "retro"]
tags        = ["infrastructure", "self-hosting", "Write-Ups"]
categories  = ["articles"]
series      = ["Infrastructure Independence"]
schema_type = "BlogPosting"
aeo_expertise = "DevOps, Open Source, Privacy, Security, Architecture"
aliases     = ["/08-the-shell-is-gone/"]
og_image    = "/assets/og-posts.png"

[related_post]
  slug  = "05-infrastructure-independence"
  label = "post 05 covers the philosophy in more depth"
+++

<h2 id="the-endpoint-is-down">The endpoint is down.</h2>

<p>If you came here from
<a href="/posts/00-hellowrld/">post 00</a> expecting to SSH into
<code>hack.dapla.net</code> and find research papers and easter eggs —
you can't. It's returning 503. The SSH port is closed. The service is offline.</p>

<p>This post is the status update that post 00 implicitly promised.</p>

<h2 id="what-it-was">What it was</h2>

<p><code>hack.dapla.net</code> ran Soft Serve, the Charmbracelet SSH-accessible
git server, hosting research whitepapers and a handful of easter eggs that
rewarded anyone who bothered to read <code>ssh hack.dapla.net help</code> carefully.</p>

<p>It also ran a browser-accessible VDI over HTTPS — a web shell reachable
from any device, including the Quest 2's browser for remote work in VR.
The node is a playground: tools to use, abuse, and iterate on.</p>

<h2 id="what-went-wrong">What went wrong, specifically</h2>

<p>Soft Serve and
<a href="https://github.com/charmbracelet/wish">Wish</a>
never got along. You couldn't actually clone code or browse documents in
any reliable way. What looked like a git host was mostly a maintenance
surface with no users.</p>

<p>The deeper problem: the endpoint was supposed to eventually host a
consolidation of work spread across SourceHut, GitHub, SourceForge, and
five boxes of hard drives ranging from 10 to 30 years old. That
archaeology project outweighed the return on keeping a broken git server
running for a userbase that was effectively zero.</p>

<p>The research content is intact on <code>storage/</code> ZFS. Nothing was lost.
The service just stopped being worth the maintenance before the larger
migration was ready to justify it.</p>

<h2 id="what-comes-back">What might come back</h2>

<p>Honest answer: unclear, and that's fine. Some options on the table:</p>

<ul>
<li>A <a href="https://github.com/moshix/bricks_ts">3270/bricks</a>-style terminal experience or proper BBS — the node has the right aesthetic for it</li>
<li>A honeypot + CTF — give people something to actually attack</li>
<li>A storefront for retro tech: ROMs, games, hardware remakes, preferably things people can actually use</li>
<li>A Gopher site — the protocol fits the audience</li>
<li>A revival of XMCore BBS — it had a run, it could have another</li>
<li>A livestream node — come watch infrastructure get built in real time</li>
</ul>

<p>Probably some combination. The node is a playground first.
Whatever goes there will be something worth showing up for.</p>

<h2 id="the-broader-point">The broader point</h2>

<p>This is what self-hosting actually looks like. Temporary arrangements
calcify. A service that was supposed to be scaffolding becomes load-bearing.
Then the thing it was scaffolding never gets built, and the scaffolding
itself doesn't work well enough to justify keeping.</p>

<p>The answer isn't to move back to a managed platform.
The answer is to let things that aren't working die cleanly,
and build the replacement when you know what it's actually for.</p>

<p><code>hack.dapla.net</code> will be back when there's something worth putting there.</p>

