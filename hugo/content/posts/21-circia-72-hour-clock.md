+++
title       = "CIRCIA's Town Halls Close This Week. The 72-Hour Clock Doesn't."
date        = "2026-06-16"
draft       = false
description = "CISA is taking public input on the CIRCIA final rule through June 18. The 72-hour incident reporting and 24-hour ransomware payment requirements are not on the table. What's still being negotiated is scope, definitions, and burden — and that's where the OT and critical infrastructure picture gets specific."
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
this week — June 15-18. The general session ran Monday. Critical infrastructure
sector groupings run Tuesday through Thursday, with water, energy, chemical, and
nuclear on Tuesday's docket alongside IT and communications.</p>

<p>If you run infrastructure in any of those sectors and haven't been tracking this,
the timeline is: town halls close Thursday, final rule expected late 2026, reporting
requirements take effect on an effective date CISA has not yet set but which will
follow the final rule publication. The voluntary reporting period is now.</p>

<h2 id="what-is-and-isnt-being-negotiated">What is and isn't being negotiated</h2>

<p>The core reporting requirements are not in scope for the town halls. They are
fixed in the statute:</p>

<ul>
<li>Covered entities must report covered cyber incidents to CISA within 72 hours
of reasonably believing an incident occurred.</li>
<li>Covered entities must report ransomware payments to CISA within 24 hours
of making the payment.</li>
<li>Federal entities receiving incident reports must share them with CISA within 24 hours.</li>
</ul>

<p>Those numbers are in the law. CISA cannot change them in the final rule.
What the town halls are actually about is everything else: which entities are
covered, what constitutes a reportable incident, how the reporting burden
interacts with existing sector-specific frameworks, and how CIRCIA harmonizes
with the dozens of other federal cyber incident reporting requirements already
in place.</p>

<p>The scope question is where most organizations should be paying attention.
CIRCIA applies to critical infrastructure sectors as defined by Presidential
Policy Directive 21 — sixteen sectors total. CISA estimates more than 300,000
entities will be covered. The NPRM's definitions of "covered entity" and
"covered cyber incident" were the most heavily commented sections, with
stakeholders pushing for narrower scope and clearer thresholds. The final
rule will resolve those definitions, and the effective date follows publication.</p>

<h2 id="the-ot-picture">The OT picture</h2>

<p>Water and wastewater, energy, chemical, and nuclear are explicitly in scope
as critical infrastructure sectors. For any organization running operational
technology in those sectors, CIRCIA creates a reporting obligation that
intersects with an existing visibility problem.</p>

<p>The Dragos SADM case from earlier this month is the clearest recent example
of what that looks like in practice. The intrusion ran undetected through
the reconnaissance phase, the asset identification phase, and two rounds of
password spraying. It was discovered weeks later in a forensic investigation.
Under CIRCIA, the 72-hour clock starts when the covered entity reasonably
believes the incident occurred — not when they discover it in a post-incident
forensic review.</p>

<p>That creates a detection requirement embedded in a reporting requirement.
An organization that can't detect an OT intrusion in real time can't
report within 72 hours of when it occurred. The two problems are the same
problem: the IT-OT boundary with no monitoring that made the SADM intrusion
possible is also the monitoring gap that would prevent timely CIRCIA
reporting if a similar intrusion happened to a covered entity.</p>

<h2 id="the-harmonization-problem">The harmonization problem</h2>

<p>CIRCIA doesn't exist in isolation. The healthcare sector has HIPAA breach
notification at 60 days. Financial services has SEC incident disclosure at
four business days. Energy has NERC CIP reporting requirements. The NPRM
drew significant comment on the overlap, and the Cyber Incident Reporting
Council — which DHS is required to establish under CIRCIA — is supposed to
coordinate and deconflict these frameworks.</p>

<p>The practical question for any organization in a regulated sector is
whether CIRCIA reporting to CISA satisfies other obligations or runs in
parallel. The NPRM's proposed answer was that CIRCIA reporting is additive —
you still have to meet your sector-specific requirements separately. That
position drew pushback in comments, and it's one of the areas the final
rule is expected to address.</p>

<p>For OT environments specifically, the interaction with NERC CIP is the
most relevant. NERC CIP already requires incident reporting for bulk
electric system cyber incidents. CIRCIA adds a parallel CISA reporting
track for any incident meeting the covered cyber incident threshold.
Whether those two reports cover the same information, go to different
agencies, and require different timelines is a compliance design question
that most organizations haven't resolved because the final rule hasn't
been published.</p>

<h2 id="what-to-do-now">What to do now</h2>

<p>The voluntary reporting period is active. CISA encourages organizations
to report unusual cyber activity now at report@cisa.gov or (888) 282-0870,
and the same information shared voluntarily now will inform the trend
analysis CIRCIA is designed to enable at scale.</p>

<p>For organizations preparing for mandatory compliance: the two preparation
tracks that matter most before the final rule publishes are scope analysis
(whether your organization meets the covered entity definition under the
proposed rule's thresholds) and detection gap assessment (whether your
current monitoring can generate the information a 72-hour report requires).
The second track is the one most OT environments will find is further
behind than the first.</p>

<p>The NPRM is at the Federal Register, docket CISA-2022-0010. The town
hall transcripts will be entered into the docket after each session.
The CISA CIRCIA page at cisa.gov/circia has the registration links and
current schedule.</p>
