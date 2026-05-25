+++
title       = "The Canary Should Live in the Infrastructure"
date        = "2026-05-25"
draft       = false
description = "A rebuttal to post 09: the warrant canary text file is the human-readable layer. The signal itself should live in DNSSEC TXT records, DKIM rotation, and Certificate Transparency logs — infrastructure that is independently monitored by every party that depends on your domain."
slug        = "10-canary-in-the-infrastructure"
keywords    = ["warrant canary", "DNSSEC", "DKIM", "TLS", "Certificate Transparency", "PKI", "privacy", "security", "infrastructure", "canary.txt"]
tags        = ["privacy", "surveillance", "infrastructure", "security"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Privacy, Security, DNS, PKI, Infrastructure"
aliases     = ["/10-canary-in-the-infrastructure/"]
series      = ["The Watchers You Fed"]
og_image    = "/assets/og-posts.png"
+++

<p><em>This is a response to <a href="/posts/09-after-the-canary/">post 09</a>,
which argued for PGP-clearsigned <code>/.well-known/canary.txt</code> as
the correct canary architecture. I wrote that post. I stand by it.
And I think it doesn't go far enough.</em></p>

<h2 id="the-file-is-not-the-canary">The file is not the canary</h2>

<p>Post 09 made the case that a warrant canary should have zero external
dependencies at verification time. That argument holds. But it implicitly
treats the canary as a document — a file you publish, a file you check,
a file whose absence is the signal.</p>

<p>A file can be suppressed without suppressing the domain.
A file can be quietly removed while the rest of the site continues
to serve normally. If the only canary signal is the presence or absence
of a file at a path, the adversary who compels you to remove it
also controls whether anyone notices in time.</p>

<p>The question is not just "is the file self-describing and dependency-free?"
The question is: <strong>who else is independently monitoring the infrastructure
your canary depends on?</strong></p>

<h2 id="infrastructure-that-is-already-monitored">Infrastructure that is already monitored</h2>

<p>Every party that depends on your domain is already watching three
layers of cryptographic infrastructure. You didn't build this monitoring.
You don't control it. That is precisely what makes it useful.</p>

<p><strong>Certificate Transparency logs</strong> are an append-only, publicly auditable
record of every TLS certificate issued for your domain. A certificate
issued under government compulsion — by a coerced CA, or by a CA
operating under a secret legal order — appears in the CT log.
It is detectable. Tools like <a href="https://crt.sh">crt.sh</a> and
<a href="https://certificate.transparency.dev">certificate.transparency.dev</a>
monitor these logs continuously. You do not have to ask anyone to watch.
They already are.</p>

<p><strong>DNSSEC-signed TXT records</strong> can carry a canary value at a designated
subdomain — <code>_canary.dwightaspencer.com</code>, for instance. The value is
signed by your zone key. Changing it requires your private key.
Suppressing it without changing it requires suppressing DNS responses
for your entire domain — a much harder, much more detectable action
than removing a file from a web server. DNSSEC validation is performed
by every recursive resolver that respects it, without any cooperation
from you.</p>

<p><strong>DKIM key rotation</strong> is a canary signal hiding in plain sight.
An organization that abruptly stops rotating its DKIM signing keys —
or whose keys are rotated without a corresponding policy update —
has changed a behavior pattern that email security tooling already
monitors. Absence of normal rotation is detectable.</p>

<h2 id="the-txt-file-is-the-human-readable-layer">The txt file is the human-readable layer</h2>

<p>None of this replaces <code>/.well-known/canary.txt</code>.
The file serves a different function: it's for humans who know
to look for it, in prose they can read without tooling.
The PGP signature on it provides a chain of custody.
The quarterly renewal cadence makes absence detectable
to anyone checking manually.</p>

<p>The right architecture uses both:</p>

<ul>
<li><code>/.well-known/canary.txt</code> — human-readable, PGP-clearsigned,
self-describing, zero external schema dependencies</li>
<li><code>_canary.dwightaspencer.com TXT</code> — DNSSEC-signed, machine-verifiable,
monitored by infrastructure you don't control and can't suppress quietly</li>
<li>CT log monitoring — passive, continuous, requires no action from you,
detects coerced certificate issuance</li>
</ul>

<p>The file and the infrastructure are not competing canary standards.
They are different audiences for the same signal — one for humans
who check manually, one for the monitoring infrastructure that
watches your domain whether you want it to or not.</p>

<h2 id="the-standard-question">The standard question</h2>

<p>Post 09 closed the argument against Canarytail by noting that
grounding canary evidence in a third-party standard is the wrong
architecture. That holds.</p>

<p>But the corollary is: the cryptographic infrastructure of the
public internet — CT logs, DNSSEC, DKIM — is not a third-party
standard maintained by a volunteer org. It is the infrastructure.
It predates your canary and will outlast it.
Your canary should be a participant in that infrastructure,
not an artifact that exists alongside it.</p>

<p class="finger-exit"><span style="color:#75715e">; → <a href="/posts/09-after-the-canary/" style="color:#9a9a9a">post 09</a> is the original argument this responds to</span></p>
