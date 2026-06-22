+++
title       = "Now"
date        = "2026-06-22"
description = "What Dwight Spencer is working on right now — updated alongside the warrant canary."
layout      = "single"
type        = "now"
aliases     = ["/now/"]
+++

<p class="meta">Last updated: June 2026. <a href="https://nownownow.com/about">What is a /now page?</a></p>

<h2 id="writing">Writing</h2>

<p>
<em>The Watchers You Fed: Turn the Lens</em> — manuscript at ~64,700 words across twelve
chapters, targeting KDP release before Labor Day 2026. HOPE 26 accepted the talk:
"The Watchers You F.E.D." (Feds, Extractors, Data-brokers), August 14–16 in New
York City. The talk is the pre-order launch vehicle. Chapters surface here as
posts before the book ships — the current arc covers Third-Party Doctrine, ALPR
municipal contracts, AI capability compression, and the voluntary identity capture
built into age verification infrastructure.
</p>

<p>
GRID_BREAK_518 zine series — Issues 01–03 in production for RT4 Albany.
Central Avenue Surveillance Spine coverage (Flock/Fusus/Raven infrastructure in
the Capital Region).
</p>

<h2 id="infrastructure">Infrastructure</h2>

<p>
<code>mlisp</code> — Common Lisp mailing list manager under active development. PRs #134,
#136, #137 merged: subscriber <code>ask</code> command, filter pipeline DRY-up, procmail
DSL consolidation, token substitution. CI scheduling issue open as #138 (platform-
level GitHub Actions scheduling failure, not a workflow defect). Q3 roadmap:
anonymous side-channel networks over SMTP, FidoNet-style P2P mesh, Type I/II
anonymous remailers.
</p>

<p>
<code>zekodun-overlays</code> — Twitch streaming overlay app in SBCL/Roswell with cl-raylib.
PR #8 (v0.3.0 cl-raylib port) CI-verified and open. StumpWM window manager,
vlime for CL REPL, suckless ii for IRC/Twitch chat, eggdrop for moderation.
</p>

<p>
<code>hack.dapla.net</code> — Podman quadlets on ZFS. Soft Serve git host, 3270 BBS front
end, Asterisk PBX on the NYNEX-era dialplan (PhreakNet connected). HAProxy at
the edge, Cloudflare Zero Trust tunnel, VRRP via keepalived.
</p>

<p>
EDM/DPR back-office on BRICKS_TS — COBOL and REXX programs against PostgreSQL
via EXEC SQL. PostScript report generation through <code>pg_notify</code>. Four-tier test
suite with CECI-level testing via expect+s3270.
</p>

<h2 id="open-source">Open source</h2>

<p>Active projects:</p>

<ul>
<li><code>mlisp</code> — zero-dependency SBCL mailing list manager. Email as actor-based pub/sub. <a href="https://github.com/denzuko/mlisp">github.com/denzuko/mlisp</a></li>
<li><code>odoo-mcp-server</code> — C99 MCP JSON-RPC 2.0 server, WASM/Cloudflare Workers target. tsoding/arena.h, nob.h build driver, BDD-first discipline throughout.</li>
<li><code>r2-asset-sync</code> — five release channels (POSIX shell, GitHub Actions composite, Terraform module, Ansible Galaxy role, nob.h DAG), all merged, v1.0.0 tagged.</li>
<li><code>clacks.h</code> — single-header C library implementing an optical telegraph wire protocol (Discworld Clacks + D'ni encoding). Macros only.</li>
</ul>

<p>Recently archived: <code>sext</code> (Common Lisp AST-to-JSON attestation tool) — aborted after
a Tier 1/2/3 structural finding. The safe version fails silently on macro-using code;
the correct version crosses the trust boundary it was meant to guard.
<a href="/posts/21-lisp-attestation-hackers/">Post 21</a> has the post-mortem.</p>

<h2 id="advocacy">Advocacy</h2>

<p>
Technology Chair, Restore The Fourth (national). Current RT4 TWG published
standards: RT4-TWG-2026-001 (Signal Desktop Technical Brief),
RT4-STD-2026-001 (Technical Brief Reporting Standard). The TWG scope is
technical tools and standards for RT4 members — not public policy analysis,
which stays in this byline.
</p>

<p>
Albany 2600 regular. SCORE mentor.
</p>

<h2 id="reading">Reading</h2>

<p>
Working through the primary source record on Third-Party Doctrine for the book —
<em>United States v. Miller</em> (1976), <em>Smith v. Maryland</em> (1979), and the post-<em>Carpenter</em>
circuit split. EFF's age verification analysis as a cross-reference for the
forthcoming post on biometric capture architecture in compliance-framed identity
systems. The usual stack of <em>2600</em> and HPR backlog.
</p>

<h2 id="radio">Radio</h2>

<p>
Da Planet Radio — <a href="https://klaxon.dapla.net">klaxon.dapla.net</a>. Live and recorded. The Ellison Digital
Minerals ARG runs through the feed as diegetic internal communications. HPR
contributions when the manuscript allows.
</p>
