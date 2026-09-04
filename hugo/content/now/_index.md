+++
title       = "Now"
date        = "2026-09-03"
description = "What Dwight Spencer is working on right now — updated alongside the warrant canary."
layout      = "single"
type        = "now"
aliases     = ["/now/"]
+++

<p class="meta">Last updated: September 2026. <a href="https://nownownow.com/about">nownownow.com</a></p>

<h2 id="writing">Writing</h2>

<p>
"The Watchers You F.E.D." delivered at HOPE 26, August 14–16, Crystal Ballroom,
New York City. <em>The Watchers You Fed: Turn the Lens</em> manuscript sits at ~64,700
words across twelve chapters. KDP release timeline is under review now that the
talk is done. BMAC pre-order page is live; chapters continue surfacing here
before the book ships.
</p>

<h2 id="infrastructure">Infrastructure</h2>

<p>
<code>denzuko/ns</code> v0.1.0 shipped — a Common Lisp macro library that collapses
<code>defpackage</code> + <code>in-package</code> into one declarative form. Measured against 52 source
files and 44 namespace declarations across eleven production repositories: 10%
reduction on raw source, 44% reduction on namespace index injections into LLM
context windows. Green CI across SBCL, CCL, ECL. 39 FiveAM tests, 63 checks.
Lab article: <a href="/27-ns-macro-lab">post 27</a>. Lab report: <a href="/projects/ns-macro-lab">projects/ns-macro-lab</a>.
</p>

<p>
<code>mlisp</code> — PRs #134, #136, #137 merged. Q3: anonymous side-channel networks
over SMTP, FidoNet-style P2P mesh, Type I/II anonymous remailers.
</p>

<p>
<code>hack.dapla.net</code> — Podman quadlets on ZFS. Soft Serve, 3270 BBS, Asterisk on
the NYNEX-era dialplan (PhreakNet connected). HAProxy edge, Cloudflare Zero
Trust tunnel, VRRP via keepalived.
</p>

<h2 id="open-source">Open source</h2>

<ul>
<li><code>ns</code> — single-form namespace declaration for Common Lisp. <a href="https://github.com/denzuko/ns">github.com/denzuko/ns</a></li>
<li><code>mlisp</code> — zero-dependency SBCL mailing list manager over actor-based pub/sub. <a href="https://github.com/denzuko/mlisp">github.com/denzuko/mlisp</a></li>
<li><code>odoo-mcp-server</code> — C99 MCP JSON-RPC 2.0 server, WASM/Cloudflare Workers target. BDD-first throughout.</li>
<li><code>r2-asset-sync</code> — five release channels (POSIX shell, GitHub Actions, Terraform, Ansible, nob.h DAG), v1.0.0 tagged.</li>
<li><code>clacks.h</code> — single-header C library for Discworld Clacks optical telegraph protocol. Macros only.</li>
</ul>

<h2 id="community">Community</h2>

<p>
Technology Chair, Restore The Fourth (national). RT4 TWG published standards:
RT4-TWG-2026-001 (Signal Desktop Technical Brief), RT4-STD-2026-001 (Technical
Brief Reporting Standard). Albany 2600 regular. SCORE mentor.
</p>

<h2 id="reading">Reading</h2>

<p>
Third-Party Doctrine primary sources for the book: <em>United States v. Miller</em>
(1976), <em>Smith v. Maryland</em> (1979), post-<em>Carpenter</em> circuit split. Chatrie v. US
(June 29 2026) added to the stack — the Eleventh Circuit held a geofence warrant
constitutes a Fourth Amendment search and remanded; does not reach ALPR.
</p>

<h2 id="radio">Radio</h2>

<p>
Da Planet Radio — <a href="https://klaxon.dapla.net">klaxon.dapla.net</a>. Live and recorded.
HPR contributions when the manuscript allows.
</p>
