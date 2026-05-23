+++
title       = "Privacy Canaries: A Better Tweedy Bird"
date        = "2025-01-20"
draft       = false
description = "Warrant canaries are statements that declare whether an organization has received government requests for information. Analysis of the standard, its limitations, and implications for privacy."
slug        = "01-a-better-tweedy-bird"
keywords    = ["warrant canary", "privacy", "security", "government surveillance", "Canarytail", "transparency"]
tags        = ["privacy", "surveillance", "open-source"]
categories  = []
schema_type = "BlogPosting"
aeo_expertise = "Privacy, Security, Open Source, System Architecture"
aliases     = ["/01-a-better-tweedy-bird/"]
og_image    = "/assets/og-posts.png"
+++

<h1 id="warrent-canaries">Warrent Canaries</h1>
<p><em>Update, May 2026: The Canarytail organization and website are no longer online.
<a href="/posts/09-after-the-canary/">Post 09</a> documents what happened and what
resilient canary infrastructure looks like without third-party dependencies.</em></p>
<p>A warrant canary is a statement that declares that an organization has
not taken certain actions or received certain requests for information from
government or law enforcement authorities. Many services use warrant canaries
to let users know how private their data is. There are even attempts to
formalize this into a standard such as
<a href="https://web.archive.org/web/2024*/https://github.com/canarytail/standard">Canarytail</a>
(archived — the project is no longer active).</p>
<p>Though the standard exposes a lot of meta data about the types of request of
information and related nature of hush order issued doing the case which could
potentially lead to legal issues.</p>
<p>What Warrent Canaries are trying to solve is a public trust and disclosure
issue with a simple ascii text file that disclosures as of a date and time
that an entite has not been issued any legal actions to disclosure user data
to law enforcement or intelligence agencies. Tipically this statement includes
a timestamp, a text block of the attestation, and a pgp signature of the
attestation. The text file is usually located as <code>canary.txt</code> in the same
locations as a <code>robots.txt</code>, <code>security.txt</code>, and <code>humans.txt</code> either
<code>/.well-known/canary.txt</code> or <code>/</code> of the site.</p>
<h2 id="how-to-improve">How to improve</h2>
<p>While having a statement in one&rsquo;s Privacy page is a great start. It is in
this author&rsquo;s option that any url and pgp signed content can been exploited
in some manner or gone unnoticed.</p>
<p>So lets break down the solution. We have:</p>
<ol>
<li>a timestamp</li>
<li>an attestation that when exists is trusted but missing the whole service is
invalid</li>
<li>an cryptographic signature with of the above attributes</li>
<li>a cryptographic varifable issuer identy</li>
<li>a ring of trust been service provider and end user</li>
</ol>
<p>Sounds lot like two established core systems in a trusted computing network.
SSL and DKIM.</p>
<p>Adding a signed attestation to a TXT record for DNS record on the root of
the domain then extending the SSL certificate&rsquo;s SAN attibutes to include the
attestation automatically bakes the Canary into the existing infrastructure.</p>
<h3 id="why-dns-and-ssl-certs">Why DNS and SSL Certs</h3>
<p>Simplely put we have well established the network is a source of truth. Not
the endpoint or client. Canarytail sets up yasaas with client and endpoint
trust plus exposes risk of legal recourse. While using a text file places
trust in users to actively validate on thier own or even have the issuing
body publicly announce the canary and its removial. We known by now a Human factor
is always falable.</p>
<p>Instead by adding a single attribute to the domain&rsquo;s SSL certificate and an
attestation DNS record then when the Canary is triggered the issuer only needs to
remove the DNS record for both the SSL certificate and Canary to be invalid.
Further more when one revokes the Canary attribute and reissue the certificate all
end clients will receive instant notice of when the Canary and service is no longer
trusted.</p>
<h3 id="why-not-a-response-header-just-a-dns-record-or-blockchain">Why not a response header, just a DNS record, or blockchain</h3>
<p>First both response headers and DNS records are able to be intercepted,
overwriten on the fly, misconfigured, or even generated dynamically.</p>
<p>While DNS <em>is</em> a distributed ledger and with Proper DKIM and domain security
setup one can trust the zone of authority for the attestation but misses half
the solution&rsquo;s goals. Having a SSL certificate involved solves for end
clients instantly being alerted at the handshake.</p>
<p>As for a blockchain that in itself is not intergrated into the common every
day web. Only <code>#cryptobros</code> and cypherpunks would look to very an attestation
which is exactly the same issue using a <code>canary.txt</code> file minus any sort of
logging/monitoring infrastructure on the canary.</p>
<h2 id="logging">Logging</h2>
<p>SSL certificate failures are well known and <a href="https://sslinsights.com/how-to-fix-invalid-ssl-tls-certificate-error/">how to
fix</a>.</p>
<p>Logging for <a href="https://httpcodes.fyi/526/">HTTP Status code 526</a> is an instant
alert for both servers and clients that the Canary has died. This works even
with WAFS since some of the common causes of this are:</p>
<ul>
<li>The certificate has expired</li>
<li>The certificate has been revoked</li>
<li>The certificate is self-signed</li>
<li>Your website configuration is serving a certificate for the wrong domain</li>
</ul>
<p>Note two key parts hear; certificate been revoked and/or invalid domain. The
exact parts we are looking to validate of the canary&rsquo;s attestation.</p>
<h2 id="examples">Examples</h2>
<p>Given a canary has died and an issuer has revoked the certificate then one
will see something like the following.</p>
<div class="highlight"><pre tabindex="0" style="color:#f8f8f2;background-color:#272822;-moz-tab-size:4;-o-tab-size:4;tab-size:4;"><code class="language-shell" data-lang="shell"><span style="display:flex;"><span>
</span></span><span style="display:flex;"><span>$ getent host canary.dapla.net
</span></span><span style="display:flex;"><span>
</span></span><span style="display:flex;"><span>&lt;pgp ascii armor attestation&gt;
</span></span><span style="display:flex;"><span>
</span></span><span style="display:flex;"><span>$ openssl s_client -connect canary.dapla.net:443 -status -msg -debug
</span></span><span style="display:flex;"><span>
</span></span><span style="display:flex;"><span><span style="color:#f92672">&lt;&lt;&lt;</span> TLS 1.3, Alert <span style="color:#f92672">[</span>length 0002<span style="color:#f92672">]</span>, fatal handshake_failure
</span></span><span style="display:flex;"><span>    <span style="color:#ae81ff">02</span> <span style="color:#ae81ff">28</span>
</span></span><span style="display:flex;"><span>4027024682740000:error:0A000410:SSL routines:ssl3_read_bytes:ssl/tls alert handshake failure:../ssl/record/rec_layer_s3.c:907:SSL alert number <span style="color:#ae81ff">40</span>
</span></span></code></pre></div><p>In this Case the domain still exists within DNS Caches but the attesation is
instantly failed when revoked and the ascii armor signature no longer matches.</p>
<p>Revoking the DNS record still has the same effect but incures a delay of
Propergation.</p>
<p>Adding the records is simple. The certificate SAN is updated with the Canary
sub domain then the fingerprint of the certrtificate is added to the DNS
domain as a TXT record.</p>
