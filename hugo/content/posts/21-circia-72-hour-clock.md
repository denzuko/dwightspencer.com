+++
title       = "CIRCIA's Town Halls Close This Week. The 72-Hour Clock Doesn't."
date        = "2026-06-16"
draft       = false
description = "CISA is taking public input on the CIRCIA final rule through June 18. The 72-hour incident reporting and 24-hour ransomware payment requirements are fixed in statute. What remains under negotiation is scope, definitions, and burden — and that is where the OT and critical infrastructure picture becomes specific."
slug        = "21-circia-72-hour-clock"
keywords    = ["CIRCIA","CISA","incident reporting","critical infrastructure","OT","ICS","ransomware","compliance","rulemaking"]
tags        = ["infrastructure","OT","ICS","devsecops"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "OT Security, Compliance, Critical Infrastructure"
aliases     = ["/21-circia-72-hour-clock/"]
og_image    = "/assets/og-posts.png"
series      = ["Infrastructure Independence"]

[related_post]
  slug  = "20-sadm-ot-visibility"
  label = "post 20 covers the OT boundary visibility problem CIRCIA reporting is designed to surface"
+++

<p>CISA is running its final round of public town halls on the CIRCIA rulemaking
this week — June 15–18. The general session ran Monday. Critical infrastructure
sector groupings run Tuesday through Thursday, with water, energy, chemical, and
nuclear on Tuesday's docket alongside IT and communications.</p>

<p>For organisations running infrastructure in any of those sectors and not yet
tracking this: town halls close Thursday, the final rule is expected late 2026,
and reporting requirements take effect on an effective date CISA has not yet
published. The voluntary reporting period is active now.</p>

<h2 id="what-is-and-isnt-being-negotiated">What is and is not being negotiated</h2>

<p>The core reporting requirements are not in scope for the town halls. They are
fixed in the statute:</p>

<ul>
<li>Covered entities must report covered cyber incidents to CISA within 72 hours
of reasonably believing an incident occurred.</li>
<li>Covered entities must report ransomware payments to CISA within 24 hours
of making the payment.</li>
<li>Federal entities receiving incident reports must share them with CISA within 24 hours.</li>
</ul>

<p>Those figures are in the law. CISA cannot alter them in the final rule.
The town halls address everything else: which entities are covered, what
constitutes a reportable incident, how the reporting burden interacts with
existing sector-specific frameworks, and how CIRCIA harmonises with the
dozens of other federal cyber incident reporting requirements already in
force.</p>

<p>Scope is where the consequential decisions remain. CIRCIA applies to critical
infrastructure sectors as defined by Presidential Policy Directive 21 —
sixteen sectors in total. CISA estimates more than 300,000 entities will be
covered. The NPRM's definitions of "covered entity" and "covered cyber
incident" were the most heavily commented sections, with stakeholders pressing
for narrower scope and clearer thresholds. The final rule resolves those
definitions; the effective date follows publication.</p>

<h2 id="the-ot-picture">The OT picture</h2>

<p>Water and wastewater, energy, chemical, and nuclear are explicitly in scope
as critical infrastructure sectors. For organisations running operational
technology in those sectors, CIRCIA creates a reporting obligation that
intersects with an existing visibility problem.</p>

<p>The Dragos SADM case from earlier this month is the clearest recent example
of what that intersection looks like in practice. The intrusion ran undetected
through the reconnaissance phase, the asset identification phase, and two
rounds of password spraying. It surfaced weeks later in a forensic
investigation. Under CIRCIA, the 72-hour clock starts when the covered entity
reasonably believes the incident occurred — not when a post-incident forensic
review discovers it.</p>

<p>That embeds a detection requirement inside a reporting requirement. An
organisation that cannot detect an OT intrusion in real time cannot report
within 72 hours of when it occurred. The monitoring gap that made the SADM
intrusion possible is the same gap that would prevent timely CIRCIA
reporting if a similar intrusion affected a covered entity. The two problems
share the same root cause: an IT–OT boundary with no active monitoring.</p>

<h2 id="the-harmonisation-problem">The harmonisation problem</h2>

<p>CIRCIA does not operate in isolation. Healthcare carries HIPAA breach
notification at 60 days. Financial services has SEC incident disclosure at
four business days. Energy has NERC CIP reporting requirements. The NPRM
drew substantial comment on the overlap, and the Cyber Incident Reporting
Council — which DHS is required to establish under CIRCIA — is charged with
coordinating and deconflicting these frameworks.</p>

<p>The practical question for any organisation in a regulated sector is whether
CIRCIA reporting to CISA satisfies parallel obligations or runs alongside
them. The NPRM's proposed position was that CIRCIA reporting is additive —
sector-specific requirements remain independently applicable. That position
drew pushback in comments, and it is one of the areas the final rule is
expected to address.</p>

<p>For OT environments, the interaction with NERC CIP is the most immediately
relevant. NERC CIP already requires incident reporting for bulk electric
system cyber incidents. CIRCIA adds a parallel CISA reporting track for any
incident meeting the covered cyber incident threshold. Whether those two
reports carry the same information, route to different agencies, and impose
different timelines is a compliance architecture question most organisations
have not yet resolved — because the final rule has not been published.</p>

<p>The NPRM is at the Federal Register, docket CISA-2022-0010. Town hall
transcripts will be entered into the docket after each session. The CISA
CIRCIA page at cisa.gov/circia carries registration links and the current
schedule.</p>
