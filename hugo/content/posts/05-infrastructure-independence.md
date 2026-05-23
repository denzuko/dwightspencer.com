+++
title       = "Infrastructure Independence: Self-Hosting Without the Hype"
date        = "2026-05-23"
draft       = false
description = "A practical, no-nonsense guide to self-hosting your critical services. Companion piece to Hacker Public Radio episode — covers what to host, what not to host, and how to avoid the traps."
slug        = "05-infrastructure-independence"
keywords    = ["self-hosting", "infrastructure", "privacy", "podman", "haproxy", "zfs", "homelab", "devops"]
tags        = ["self-hosting", "infrastructure", "privacy", "devops"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "DevOps, Infrastructure, Security, Self-Hosting"
aliases     = ["/infra/", "/05-infrastructure-independence/"]
og_image    = "/assets/og-posts.png"
+++

<p class="meta"><em>Companion piece to <a href="https://hackerpublicradio.org">Hacker Public Radio</a>.
Part of the Infrastructure Independence series.</em></p>

<h2 id="abstract">Abstract</h2>

<p>Self-hosting is having a moment. It's also attracting a lot of bad advice.
This article cuts through the homelab fantasy to answer the questions that
actually matter: what is worth hosting yourself, what is not, what the real
threat model is, and how to build infrastructure that survives you being
unavailable for two weeks.</p>

<h2 id="1-the-honest-threat-model">1. The Honest Threat Model</h2>

<p>Most self-hosting guides start with "you should own your data." They are
correct and useless. <em>Which</em> data? From whom? At what cost?</p>

<p>The realistic threat model for a privacy-conscious individual or small
organization in 2026 is:</p>

<ol>
<li><strong>Commercial surveillance</strong> — platforms monetizing behavioral data</li>
<li><strong>Data broker aggregation</strong> — your data purchased and resold without consent</li>
<li><strong>Account compromise</strong> — credential stuffing, phishing, session hijacking</li>
<li><strong>Platform discontinuation</strong> — services shut down or acquired and changed</li>
<li><strong>Legal compulsion</strong> — platforms complying with government data requests
you are not notified of</li>
</ol>

<p>Nation-state adversaries and advanced persistent threats are not in scope
for this article. If that is your threat model, self-hosting is the least
of your concerns and this is not the guide for you.</p>

<h2 id="2-what-to-host">2. What to Host</h2>

<h3 id="2-1-host-this">2.1 Host this</h3>

<p><strong>Email, if you have the operational maturity.</strong> Email is identity.
It is the recovery mechanism for every other account. Losing control of
your email domain means losing everything tied to it. The operational cost
is real — deliverability, spam filtering, key management — but the control
is worth it for anyone with a genuine privacy practice.</p>

<p><strong>Git.</strong> Your code, your commits, your history. SourceHut, Forgejo,
or a bare <code>git</code> server over SSH. The case was made in
<a href="/posts/02-github-tos-wont-save-you/">post 02</a>.</p>

<p><strong>Password manager.</strong> Vaultwarden (Bitwarden-compatible) on hardware
you control. Encrypted at rest, accessible over Tailscale or WireGuard.
Not on a public IP. Not behind a cloud provider's identity system.</p>

<p><strong>DNS resolver.</strong> Unbound or a Pi-hole equivalent. Blocks known
tracking and malware domains at the network layer. Does not replace
per-application controls but is a meaningful layer.</p>

<p><strong>Media and documents.</strong> Immich for photos. Paperless-ngx for
documents. These are high-value, low-threat targets — no reason to pay
a platform for the privilege of training their AI on your family photos.</p>

<h3 id="2-2-do-not-host-this">2.2 Do not host this</h3>

<p><strong>Your primary communications if you cannot guarantee uptime.</strong>
A Matrix homeserver that goes down on a Friday evening and comes back
Monday is worse than Signal. Availability is a security property.</p>

<p><strong>Anything requiring 24/7 human attention to stay secure.</strong>
Security patches do not take weekends off. If you cannot commit to
patching within 48 hours of a critical CVE, do not run a public-facing
service.</p>

<p><strong>Certificate authority infrastructure.</strong> Use Let's Encrypt.
Running your own CA for anything other than internal services is an
operational and security liability that almost nobody needs.</p>

<h2 id="3-the-stack">3. The Stack That Actually Works</h2>

<p>This is what I run on <code>dapla.net</code> infrastructure. It is not the
only valid answer. It is an answer that has survived production use.</p>

<h3 id="3-1-compute">3.1 Compute</h3>

<p><strong>Podman quadlets</strong> over Docker Compose. Rootless systemd-managed
containers. No daemon running as root. Quadlet files live in
<code>/etc/containers/systemd/</code>, managed by systemd, monitored by
<code>journald</code>. Restarts on failure. Survives reboots.</p>

<pre><code># Example quadlet: /etc/containers/systemd/vaultwarden.container
[Unit]
Description=Vaultwarden password manager
After=network-online.target

[Container]
Image=docker.io/vaultwarden/server:latest
AutoUpdate=registry
Volume=storage/vaultwarden:/data:Z
Environment=DOMAIN=https://vault.dapla.net
Environment=SIGNUPS_ALLOWED=false
Label=net.matrix.owner=FC13F74B@matrix.net

[Service]
Restart=always

[Install]
WantedBy=multi-user.target default.target
</code></pre>

<h3 id="3-2-storage">3.2 Storage</h3>

<p><strong>ZFS</strong> on everything that matters. <code>storage/</code> pool.
Dataset per service: <code>storage/containers/vaultwarden</code> mountpoint at
<code>/srv/vaultwarden</code>. Snapshots automated via <code>zfs-auto-snapshot</code>.
Off-site replication via <code>zfs send | ssh</code>.</p>

<p>The ZFS snapshot is your first line of recovery. It costs nothing to
enable. Not having it costs everything when you need it.</p>

<h3 id="3-3-networking">3.3 Networking and reverse proxy</h3>

<p><strong>HAProxy</strong>, not Nginx. HAProxy's ACL system, health check
granularity, and connection handling under load are meaningfully better
for a service mesh where you control the full stack. Configuration is
more verbose. That verbosity is documentation.</p>

<pre><code>frontend https_in
    bind *:443 ssl crt /etc/haproxy/certs/
    default_backend vaultwarden_back
    acl is_vault hdr(host) -i vault.dapla.net
    use_backend vaultwarden_back if is_vault

backend vaultwarden_back
    server vaultwarden 127.0.0.1:8080 check
</code></pre>

<h3 id="3-4-monitoring">3.4 Monitoring without the complexity tax</h3>

<p>Two things. <code>systemd</code> status and <code>journald</code> for service health.
Uptime Kuma behind Tailscale for external reachability checks and
alerts. That is it. Prometheus/Grafana is correct at scale. At one to
five nodes it is operational overhead with no return.</p>

<h2 id="4-the-survivability-question">4. The Survivability Question</h2>

<p>Ask yourself: if you are unavailable for two weeks, what breaks?</p>

<p>If the answer is "email," that is a bus factor problem, not an
infrastructure problem. Document your stack. Store credentials in the
self-hosted password manager <em>and</em> in a hardware-encrypted backup that
a trusted person can access. Write a runbook. Runbooks are not
bureaucracy — they are the thing that saves your service when you are
in the hospital.</p>

<p>Infrastructure independence is not the same as infrastructure solipsism.
The goal is resilience, not heroic single-person operation.</p>

<h2 id="5-start-here">5. Start Here, Not There</h2>

<p>The single highest-value first step is not standing up a server. It is
getting your own domain name and pointing your email to it, even if you
use a hosted email provider for now. The domain is yours. The provider
is interchangeable. That separation is what independence actually means.</p>

<p>Everything else follows from that decision.</p>

<p><em>Next in the series: certificate management at scale for a one-person
operation. HPR episode and write-up forthcoming.</em></p>
