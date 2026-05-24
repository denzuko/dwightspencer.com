+++
title       = "Infrastructure Independence: Self-Hosting Without the Hype"
date        = "2026-05-23"
draft       = false
description = "A practical, no-nonsense guide to self-hosting your critical services. Companion piece to Hacker Public Radio episode — covers what to host, what not to host, and how to avoid the traps."
slug        = "05-infrastructure-independence"
keywords    = ["self-hosting", "infrastructure", "privacy", "podman", "haproxy", "zfs", "homelab", "devops", "step-ca", "keepalived", "cgit"]
tags        = ["self-hosting", "infrastructure", "privacy", "devops"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "DevOps, Infrastructure, Security, Self-Hosting"
aliases     = ["/infra/", "/05-infrastructure-independence/"]
series   = ["Infrastructure Independence"]
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

<p><strong>Git.</strong> Your code, your commits, your history. SourceHut, or a bare
<code>git</code> server with <a href="https://jfr.im/blog/2026/01/selfhosting-git-cgit-and-git-http-backend/">cgit and git-http-backend</a>
for read-only HTTP pulls. Add <code>git send-email</code> for patch submission,
<a href="https://github.com/git-bug/git-bug">git-bug</a> for issue tracking inside
the repository, and git-flow for branching discipline. Gitolite works
well in this mix for access control, provided you are comfortable with
the GPG-signed email patch workflow and HTTP read-only pulls over an
airgap. The case for moving off GitHub was made in
<a href="/posts/02-github-tos-wont-save-you/">post 02</a>.</p>

<p><strong>Password manager.</strong>
<a href="https://keepassdx.com">KeePassDX</a> is the recommendation here — solid,
audited, no server component required, database lives on storage you
control. If you need shared team access, a KeePass-format database on
your own Nextcloud instance keeps it self-contained. Avoid server-side
password managers on public IPs.</p>

<p><strong>DNS resolver.</strong> Unbound or a Pi-hole equivalent. Blocks known
tracking and malware domains at the network layer. Does not replace
per-application controls but is a meaningful layer.</p>

<p><strong>Media and documents.</strong>
<a href="https://nextcloud.com">Nextcloud</a> covers both well — photo sync,
document storage, calendar, and contacts in one self-hosted stack.
High-value, low-threat targets: no reason to pay a platform for the
privilege of training their models on your files.</p>

<h3 id="2-2-do-not-host-this">2.2 Do not host this</h3>

<p><strong>Your primary communications if you cannot guarantee uptime.</strong>
A Matrix homeserver that goes down on a Friday evening and comes back
Monday is worse than Signal. Availability is a security property.</p>

<p><strong>Anything requiring 24/7 human attention to stay secure.</strong>
Security patches do not take weekends off. If you cannot commit to
patching within 48 hours of a critical CVE, do not run a public-facing
service.</p>

<p><strong>A standalone internal CA — use step-ca instead.</strong>
<a href="https://smallstep.com/docs/step-ca/">step-ca</a> paired with Let's Encrypt
is the right answer for certificate management: ACME protocol for
automation, short-lived certs that fail safely, and the option to run
your own intermediate for internal services without rolling a full CA
from scratch. Running a bare internal CA without automation is an
operational liability that bites you during incidents.</p>

<h2 id="3-the-stack">3. The Stack That Actually Works</h2>

<p>This is what runs on <code>dapla.net</code> infrastructure. It is not the
only valid answer. It is an answer that has survived production use.</p>

<h3 id="3-1-compute">3.1 Compute</h3>

<p><strong>Podman quadlets with a system account</strong> — not rootless user units.
A dedicated system account per service, managed by systemd, gives you
proper cgroup accounting, clean log attribution in journald, and
service isolation without running a daemon as root. Quadlet files live
in <code>/etc/containers/systemd/</code>. Restarts on failure. Survives reboots.</p>

<pre><code>&#35; Example quadlet: /etc/containers/systemd/nextcloud.container
[Unit]
Description=Nextcloud
After=network-online.target

[Container]
Image=docker.io/nextcloud:stable
AutoUpdate=registry
Volume=storage/nextcloud:/var/www/html:Z
EnvironmentFile=/etc/nextcloud.env
Label=net.matrix.owner=FC13F74B@matrix.net

[Service]
Restart=always
User=nextcloud

[Install]
WantedBy=multi-user.target default.target
</code></pre>

<h3 id="3-2-storage">3.2 Storage</h3>

<p><strong>ZFS</strong> on everything that matters. <code>storage/</code> pool.
Dataset per service: <code>storage/containers/nextcloud</code> mountpoint at
<code>/srv/nextcloud</code>. Snapshots automated via <code>zfs-auto-snapshot</code>.
Off-site replication via <code>zfs send | ssh</code>.</p>

<p>The ZFS snapshot is your first line of recovery. It costs nothing to
enable. Not having it costs everything when you need it.</p>

<h3 id="3-3-networking">3.3 Networking and reverse proxy</h3>

<p><strong>HAProxy</strong> as the edge, paired with:</p>

<ul>
<li><strong>DNS-SD</strong> for service discovery — backends register themselves,
HAProxy picks them up without a config reload</li>
<li><strong>policyd (WAF)</strong> in front for request filtering — blocks known bad
patterns before they reach application code</li>
<li><strong>FastCGI via kcgi</strong> for lightweight CGI services — no interpreter
overhead, correct privilege separation</li>
<li><strong>keepalived</strong> for HA failover between nodes — VRRP virtual IP,
automatic failover, built-in Prometheus integration via
<code>blackbox_exporter</code> scripts and the keepalived health check hooks</li>
</ul>

<pre><code>frontend https_in
    bind *:443 ssl crt /etc/haproxy/certs/
    default_backend nextcloud_back
    acl is_cloud hdr(host) -i cloud.dapla.net
    use_backend nextcloud_back if is_cloud

backend nextcloud_back
    server nextcloud 127.0.0.1:8080 check
</code></pre>

<h3 id="3-4-monitoring">3.4 Monitoring</h3>

<p>Three layers, no complexity tax:</p>

<ul>
<li><strong>systemd_exporter</strong> — exposes unit state and resource usage to
Prometheus. One binary, covers every quadlet service automatically.</li>
<li><strong>HAProxy native stats</strong> — HAProxy exports Prometheus metrics on its
stats socket natively since 2.0. No separate exporter needed;
point Prometheus at the stats endpoint.</li>
<li><strong>keepalived + blackbox_exporter</strong> — keepalived health check scripts
integrate with blackbox_exporter for external reachability probes.
VRRP state changes surface as metrics.</li>
</ul>

<p>Prometheus/Grafana is correct at scale. At one to five nodes it is
operational overhead with no return unless you already have the muscle
memory for it.</p>

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
