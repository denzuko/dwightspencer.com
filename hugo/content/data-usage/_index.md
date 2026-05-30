+++
title       = "Data Usage Policy"
date        = "2026-05-23"
description = "What data dwightaspencer.com collects, what it doesn't, and how it's used. Plain language. No legal maze."
layout      = "single"
type        = "policy"
aliases     = ["/data-usage/", "/data/"]
related_policies = [
  {title = "Privacy Policy", url = "/privacy/"},
  {title = "Cookie Policy", url = "/cookies/"},
  {title = "Terms of Use", url = "/terms/"},
  {title = "TDM Policy (JSON)", url = "/.well-known/tdm-policy.json"}
]
+++

This page answers the question directly: what data does **dwightaspencer.com** touch, and what happens to it? No legal maze. This site is operated by Dwight Spencer (@denzuko). Cross-references to the full [Privacy Policy](/privacy/) where you need the detail.

---

{{< data-summary type="collect" heading="What is collected" >}}
- Cloudflare CDN logs: IP address, request path, timestamp, user-agent,
  referrer — retained by Cloudflare, not by me
- Google Fonts request: your IP is logged by Google when fonts load
- Aggregate traffic summaries from Cloudflare — no individual identifiers
{{< /data-summary >}}

{{< data-summary type="nocollect" heading="What is not collected" >}}
- No name, email address, or contact information unless you initiate contact
- No location data beyond what Cloudflare's CDN infers from IP
- No behavioral tracking, session recording, or heatmaps
- No advertising identifiers or cross-site tracking
- No form submissions — there are no forms on this site
{{< /data-summary >}}

{{< data-summary type="share" heading="What is shared" >}}
- Nothing. No data broker relationships. No data sales. No third-party
  analytics beyond Cloudflare's aggregate CDN reporting.
{{< /data-summary >}}

---

## AI and automated access

All content is opted out of AI training, text and data mining, and
retrieval-augmented generation. This applies to every piece of content
on this site, globally, with no exceptions.

Machine-readable: [`/robots.txt`](/robots.txt) · [`/ai.txt`](/ai.txt) ·
[`/llms.txt`](/llms.txt) · [`/.well-known/tdm-policy.json`](/.well-known/tdm-policy.json)

The [EU CDSM Directive Art. 4](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32019L0790)
TDM reservation is asserted. In jurisdictions where that reservation is not
recognized, access by AI training crawlers is prohibited by contract under the
[Terms of Use](/terms/).

## Your rights

If you are in the EEA, California, or New York you have rights over your data.
In practice the only personal data I am likely to hold is correspondence you
initiated. See [Privacy Policy §4](/privacy/#4-your-rights) for the full
statement. Contact via [Keybase](https://keybase.io/Denzuko).

## Warrant canary

This site maintains a warrant canary at
[`/.well-known/canary.txt`](/.well-known/canary.txt), renewed quarterly.
Failure to renew within 30 days of the scheduled date should be treated as
canary death. Verification key: [0x5DCBF78E3F9C3FE3](/.well-known/pgp-key.txt).
