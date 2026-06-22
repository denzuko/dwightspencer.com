+++
title       = "The SADM Incident Is an OT Visibility Story"
date        = "2026-06-07"
draft       = false
description = "Dragos documented an attacker using Claude to pivot from IT to OT at a Mexican water utility. The AI didn't create the exposure. The boundary with no monitoring did. What that means for anyone running operational infrastructure."
slug        = "20-sadm-ot-visibility"
keywords    = ["OT security", "ICS", "SCADA", "IT-OT boundary", "Dragos", "SADM", "AI", "water utility", "network segmentation", "monitoring"]
tags        = ["OT", "ICS", "infrastructure", "security"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "OT Security, ICS, Infrastructure Architecture"
aliases     = ["/20-sadm-ot-visibility/"]
og_image    = "/assets/og-posts.png"
+++

<p>In May 2026, Dragos published findings from an investigation into
a municipal water utility in Monterrey, Mexico.
An unidentified threat actor, tracked by Gambit Security as part of a
broader campaign against Mexican government organisations, used
Anthropic's Claude to assist an intrusion that began in IT and
attempted to reach OT.</p>

<p>The coverage has mostly framed this as an AI story.
It is not primarily an AI story.
It is an OT visibility story, and the distinction matters
for what you do about it.</p>

<h2 id="what-actually-happened">What actually happened</h2>

<p>The intrusion timeline ran from December 2025 to February 2026.
Initial access was into the utility's enterprise IT environment,
likely through a vulnerable web server or stolen credentials from
the broader government campaign. Once inside, the attacker tasked
Claude with broad-spectrum reconnaissance across the internal network.</p>

<p>During that reconnaissance, Claude did something the coverage finds
alarming but which is architecturally predictable:
it found a vNode SCADA and IIoT management interface running on an
internal server, correctly identified it as a gateway to OT-adjacent
infrastructure, classified it as a high-value target, and directed
two rounds of automated password spraying against the web interface.
Both failed. The underlying control systems were never accessed.
Dragos found no evidence the attacker gained any visibility into
SADM's physical water management operations.</p>

<p>The Dragos investigation reviewed more than 350 artefacts from the
adversary's infrastructure — AI-generated scripts, offensive tools,
and interaction logs.
Claude served as the primary technical executor,
writing and iterating on a 17,000-line Python framework.
GPT handled data processing and Spanish-language output.
The operation was sophisticated and well-resourced.
It also failed at the OT boundary.</p>

<h2 id="what-the-ai-did-and-did-not-do">What the AI did and did not do</h2>

<p>Claude identified the vNode interface without being directed to look
for industrial systems. It was doing broad network enumeration and
correctly inferred the significance of what it found.
That is the capability change the Dragos report documents:
a general-purpose LLM with no prior ICS context can now classify
OT-adjacent assets as strategically significant during a live intrusion.</p>

<p>That matters. But it is a force multiplier applied to an existing
exposure, not a new exposure the AI created.
The vNode interface was reachable from the enterprise IT network.
It ran single-password authentication.
There was no network monitoring between the IT environment and the
OT-adjacent layer that would have detected the reconnaissance or
the password spraying in progress.</p>

<p>The AI found what was already exposed.
What stopped the intrusion was a failed credential attempt,
not a detection and response capability.</p>

<h2 id="the-96-percent-problem">The 96 percent problem</h2>

<p>TXOne's 2026 OT/ICS security report, consistent with five prior years
of research, documents that 96 percent of industrial security incidents
originate in IT-level compromises.
The SADM case is a live example of how that statistic is produced.</p>

<p>The pattern is: IT access → lateral movement toward OT-adjacent layer
→ exploitation attempt.
The Purdue Model addresses this with network segmentation.
NERC CIP, IEC 62443, and CMMC all define the IT-OT boundary as a
controlled zone with documented access controls and monitoring requirements.
The gap between what those frameworks require and what most operational
environments actually implement is the architecture that produces the
96 percent figure year after year.</p>

<p>Replacing the AI tool with a skilled human analyst who knows what a
vNode interface is does not change the story.
The exposure was the flat boundary.
The AI just made finding it faster and cheaper.</p>

<h2 id="what-this-means-for-home-lab-and-small-org-infrastructure">What this means for home lab and small-org infrastructure</h2>

<p>The SADM case is a large municipal utility. The architecture problem
it illustrates is not scale-dependent.</p>

<p>Home Assistant, OpenPLC, Frigate NVR, HVAC controllers, and smart
home hubs are operational technology assets. They run physical processes
over protocols — MQTT, Modbus, Z-Wave — that were not designed with
IT-style security assumptions. In a typical home lab, they sit on the
same flat network as the workstation with unrestricted internet access.</p>

<p>That is the architecture producing 96 percent IT-origin OT incidents
at industrial scale, implemented at home.</p>

<p>VLAN segmentation between automation devices and general computing
is the minimum corrective. A dedicated network segment for anything
that controls a physical process, with firewall rules that treat that
segment as untrusted from the general side. It is a weekend project
with consumer hardware. It is also the difference between a flat
network and a segmented one, and between an attacker finding your
automation devices in the first pass and not finding them at all.</p>

<h2 id="what-to-monitor">What to monitor</h2>

<p>The SADM intrusion was undetected during the reconnaissance and
password spraying phase.
It was discovered weeks later in a forensic investigation.
For smaller environments that cannot retain Dragos,
the monitoring controls that would have surfaced this earlier are not exotic:</p>

<ul>
<li><strong>East-west traffic logging</strong> between network segments.
If the automation VLAN is generating authentication attempts against
a management interface, that should produce an alert, not a log entry
reviewed in a post-incident forensic dump.</li>

<li><strong>Authentication failure alerting</strong> on any web interface that touches
OT-adjacent infrastructure. Two rounds of password spraying against
a web application should be detectable in real time.</li>

<li><strong>Asset inventory for OT-adjacent services.</strong> If you do not know
the vNode interface exists, you cannot monitor it. A periodic scan
of your automation VLAN's listening services, compared against a
known-good baseline, surfaces what an attacker's reconnaissance
would find.</li>
</ul>

<p>None of this requires specialized OT security tooling.
It requires treating the boundary between general computing and
operational infrastructure as a monitored zone rather than an
assumed-safe internal network.</p>

<h2 id="the-ai-capability-compression-is-real">The AI capability compression is real</h2>

<p>The Dragos report documents a genuine capability change.
An attacker who would previously have needed ICS domain expertise
to recognise a vNode interface as a strategically significant target
now needs only the ability to run a commercial LLM against internal
network enumeration output.</p>

<p>That compression reduces the expertise barrier for OT-targeting.
It does not change what needs to be true about the defended environment.
An IT-OT boundary with active monitoring, proper segmentation, and
authentication controls beyond a single password is more resistant
to this intrusion whether the attacker is using Claude, a specialized
ICS consultant, or a well-written enumeration script.</p>

<p>The correct response to the SADM case is not to monitor AI tool usage
by potential attackers. It is to make the architectural changes that
mean the AI finds nothing worth acting on when it does the enumeration.</p>

<h2 id="the-source">The source</h2>

<p>The Dragos report is at
<a href="https://www.dragos.com/blog/ai-assisted-ics-attack-water-utility">dragos.com/blog/ai-assisted-ics-attack-water-utility</a>.
Read it. The technical detail in the original is worth your time,
particularly the sections documenting Claude's autonomous identification
of the vNode interface and the password spraying methodology.
It is a well-documented case study of exactly what
the 96 percent statistic looks like from the inside.</p>
