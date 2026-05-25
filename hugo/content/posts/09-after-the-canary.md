+++
title       = "After the Canary: What Happened to the Warrant Canary Standard"
date        = "2026-05-23"
draft       = false
description = "The Canarytail organization is gone. Its GitHub org was deleted, its website is dark. This is what that means for implementations that depended on it — and what a resilient warrant canary infrastructure actually looks like."
slug        = "09-after-the-canary"
keywords    = ["warrant canary", "Canarytail", "privacy", "security", "open standard", "dead projects", "self-hosted", "PGP", "infrastructure"]
tags        = ["privacy", "surveillance", "open-source", "infrastructure", "bbs"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Privacy, Security, Open Source, System Architecture"
aliases     = ["/09-after-the-canary/"]
og_image    = "/assets/og-posts.png"
+++

<h2 id="canarytail-is-gone">Canarytail is gone.</h2>

<p>In <a href="/posts/01-a-better-tweedy-bird/">post 01</a>, written in January 2025,
I referenced
<a href="https://web.archive.org/web/2024*/https://github.com/canarytail/standard">Canarytail</a>
as an attempt to formalize the warrant canary into a machine-readable standard.
As of May 2026, the <code>canarytail</code> GitHub organization does not resolve.
The website <code>canarytail.org</code> returns nothing. The org appears to have been
deleted entirely — not archived, not transferred, deleted.</p>

<p>This post is the follow-up that situation demands.</p>

<h2 id="what-canarytail-was">What Canarytail was</h2>

<p>The Canarytail standard proposed a structured JSON schema for warrant canary
attestations — a machine-readable replacement for the freeform ASCII text files
most sites publish. The idea was sound: structured canaries could be
programmatically verified, aggregated, and monitored. A broken canary
could trigger alerts in tooling rather than depending on users to
periodically check a text file.</p>

<p>The standard saw some adoption in the privacy-tooling community.
A handful of projects built verification tooling against it.
Organizations that implemented it cited it in their privacy documentation.</p>

<p>Now those citations are dead links, the verification tools point at
a deleted repository, and any organization that told users
"our canary is Canarytail-compliant" is now citing a standard
that no longer has a canonical source.</p>

<h2 id="the-dependency-problem">The dependency problem this illustrates</h2>

<p>A warrant canary is supposed to be evidence that an organization
has not been compromised or coerced. Grounding that evidence in a
third-party standard maintained by a volunteer organization with
no institutional backing is precisely the wrong architecture for
the job.</p>

<p>Consider what "Canarytail-compliant" actually meant in practice:</p>

<ul>
<li>Your canary's schema was defined by a GitHub org you don't control</li>
<li>The canonical validator lived at a URL you don't control</li>
<li>The standard's continued existence depended on a small group
of maintainers staying interested and keeping the org alive</li>
<li>When the org deleted itself, every implementation that
referenced it gained a silent dependency failure</li>
</ul>

<p>This is not a criticism of the people who built Canarytail.
Volunteer projects end. People move on. The problem is the
architectural choice to build canary infrastructure on top of
a dependency that can disappear.</p>

<h2 id="what-resilient-canary-infrastructure-looks-like">What resilient canary infrastructure looks like</h2>

<p>The design principle is: <strong>a warrant canary should have zero
external dependencies at verification time.</strong> Everything needed
to verify the canary must be either in the canary document itself
or derivable from infrastructure the issuer controls.</p>

<p>This points back to the argument in post 01 and extends it:</p>

<p><strong>The canary document</strong> should be a PGP-signed plaintext or JSON file
hosted at <code>/.well-known/canary.txt</code> on a domain the issuer controls.
It should include:</p>

<ul>
<li>An issue date and an explicit expiry date (force renewal,
make absence detectable)</li>
<li>A fingerprint reference to the signing key — not a URL to
a third-party keyserver, the fingerprint itself</li>
<li>The attestation text in plain prose — "as of this date,
we have not received..." — human-readable without tooling</li>
<li>A self-describing schema version number if you want machine
readability, defined inline, not by reference to an external standard</li>
</ul>

<p><strong>The signing key</strong> should be published at a URL the issuer controls
(<code>/.well-known/pgp-key.txt</code> is conventional) and cross-referenced in
<code>security.txt</code>. Keybase works as an additional attestation layer;
it shouldn't be the only one.</p>

<p><strong>Monitoring</strong> should check for the file's presence and signature validity
from infrastructure the relying party controls — not a third-party
monitoring service that also has a single point of failure.</p>

<p>This is exactly the architecture this site runs:
<a href="/.well-known/canary.txt"><code>/.well-known/canary.txt</code></a>
is a GPG-clearsigned file with an explicit quarterly renewal cadence,
a fingerprint reference, and no external standard dependencies.
It would survive Canarytail's deletion without a change.</p>

<h2 id="what-to-do-if-you-cited-canarytail">What to do if your canary cites Canarytail</h2>

<p>If your privacy policy, canary document, or technical documentation
references <code>github.com/canarytail</code> or <code>canarytail.org</code>:</p>

<ol>
<li>Remove the reference or replace it with a Wayback Machine
archive link (<code>web.archive.org</code> has snapshots through at least 2024)</li>
<li>Evaluate whether your canary's structure depends on the Canarytail
schema — if so, document your schema inline so it's self-describing</li>
<li>Consider this an opportunity to audit the canary's other
dependencies for the same single-point-of-failure problem</li>
</ol>

<p>The canary's job is to be verifiably present or absent.
Every dependency you add is a way it can fail silently.</p>

<h2 id="the-larger-lesson">The larger lesson</h2>

<p>Canarytail is not unique. The privacy and security tooling ecosystem
is full of small open-source projects that formalized something useful,
got some adoption, and then quietly stopped being maintained.
The projects that got adopted into organizational infrastructure
become invisible maintenance debt when they go dark.</p>

<p>The answer is not to stop using open-source standards.
The answer is to evaluate any standard you depend on for attestation
or compliance using the same adversarial lens you'd apply to
any other single point of failure: what happens when this is gone?
If the answer is "our canary becomes unverifiable," that's a
design problem to fix before it's forced on you.</p>

<p class="finger-exit"><span style="color:#75715e">; → <a href="/posts/01-a-better-tweedy-bird/" style="color:#9a9a9a">post 01</a> has the original canary architecture argument</span></p>

<p class="finger-exit"><span style="color:#75715e">; → <a href="/posts/10-canary-in-the-infrastructure/" style="color:#9a9a9a">post 10</a> — rebuttal: the canary should live in the infrastructure, not just the file</span></p>
