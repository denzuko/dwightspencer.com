+++
title       = "When the Government Buys the Model: AI, Section 702, and the Surveillance Stack"
date        = "2026-05-29"
draft       = false
description = "EPIC reported in April that Anthropic's tools are being used to analyze Section 702 data including Americans' communications. The Surveillance Accountability Act would require a warrant before accessing third-party data. Neither story has gotten the attention it deserves."
slug        = "15-ai-gov-surveillance"
keywords    = ["section 702", "fisa", "ai surveillance", "anthropic", "epic", "fourth amendment", "data brokers", "government surveillance"]
tags        = ["fourth-amendment", "privacy", "surveillance", "infrastructure", "civil-liberties"]
categories  = ["articles"]
schema_type = "Article"
aeo_expertise = "Surveillance Accountability, Infrastructure Security, Fourth Amendment"
aliases     = ["/15-ai-gov-surveillance/"]
og_image    = "/assets/og-posts.png"
series      = ["The Watchers You Fed"]

[related_post]
  slug  = "14-chatrie-geofence"
  label = "post 14 covers the Chatrie geofence case that sits at the centre of this stack"
+++

<p>The first: EPIC reported in April that Anthropic — the company that makes Claude — was in conflict with the Department of Defense over AI tool usage, and that a New Yorker piece indicated Anthropic's tools were being used to analyze Section 702 data that includes Americans' communications. Section 702 of FISA is the authority that allows intelligence agencies to collect communications of foreign targets — with the acknowledged side effect of sweeping in American communications when those Americans are in contact with foreign targets. The FBI conducts thousands of "backdoor searches" of this database annually, querying for Americans' communications without a warrant.</p>

<p>The second: Reps. Massie and Boebert introduced the Surveillance Accountability Act, which would require a warrant before the government accesses any data held by a third party — financial services providers, telecoms, ISPs, cloud storage, or data brokers — regardless of whether the third party consents or cooperates.</p>

<h2 id="the-section-702-stack">The Section 702 stack</h2>

<p>Section 702 doesn't require a warrant to collect foreign intelligence. When those collections include American communications — which they routinely do — the FBI can query for American data without a warrant, under the theory that the collection was lawful when it happened.</p>

<p>The Senate Intelligence Committee under Tom Cotton pushed for a clean reauthorization with no reforms. The House rejected a compromise extension that would have imposed warrant requirements, 200-220. The Government Surveillance Reform Act and the SAFE Act both proposed reforms that didn't pass. Section 702 survived without meaningful change.</p>

<p>Into this framework, layer AI. If an intelligence agency can feed Section 702 data — including American communications — into a large language model for analysis, the constitutional question isn't just about collection anymore. It's about what happens to that data when it becomes training signal, retrieval context, or analytical substrate for a commercial model operating under a government contract.</p>

<p>The Anthropic/DOD conflict suggests this isn't hypothetical. The details of that conflict remain classified or undisclosed, but EPIC characterizes it as a fire alarm.</p>

<h2 id="the-data-broker-parallel">The data broker parallel</h2>

<p>While Section 702 covers communications collected under intelligence authorities, the data broker loophole covers everything else: location data, browsing history, financial transactions, and behavioral profiles assembled from commercial surveillance. Federal agencies — including ICE and the FBI — have purchased this data without warrants, under the theory that a commercial transaction with a willing seller isn't a government search.</p>

<p>The USA Freedom Act (2015) prohibited bulk collection of American data. Buying bulk commercial profiles from data brokers was not what Congress had in mind when it wrote that prohibition. Privacy advocates argue it should be covered. The courts have not weighed in. Congress has not closed the loophole through direct legislation.</p>

<p>The House Appropriations Committee passed an amendment 32-25 in May to close the loophole as a spending rider — the same reform that passed the full House in 2024 but died in the Senate. It still has to survive conference. Not won.</p>

<p>The Surveillance Accountability Act goes further: a warrant requirement for any government access to third-party data, full stop. It's broader than the data broker fix. It would cover geofence warrants (see: <em>Chatrie</em>), Section 702 backdoor searches, and commercial data purchases under one framework. It was introduced in April; it has not passed committee.</p>

<h2 id="the-infrastructure-question">The infrastructure question</h2>

<p>The conflict between commercial AI tools and government surveillance mandates is structural, not incidental. A model trained on or processing government-collected data operates under different constraints than one that doesn't. A model that a government agency can direct to analyze warrantlessly-collected American communications is a different tool than one that refuses.</p>

<p>The engineering answer is the same one it always is: control your infrastructure. A model running locally, against data you control, under policies you set, is not subject to a government contract that directs how it processes Section 702 data. That's not a complete answer to a systemic surveillance problem — but it's the answer that's available to practitioners right now, while the legislative and judicial answers are still being worked out.</p>

<h2 id="what-to-watch">What to watch</h2>

<p><em>Chatrie</em> decision: expected by end of June. Sets the constitutional floor for cloud-stored location data.</p>

<p>Data broker appropriations rider: has to survive conference. If it does, it's the most meaningful Fourth Amendment reform since <em>Carpenter</em> (2018).</p>

<p>Surveillance Accountability Act: in committee. No clear path yet but the warrant requirement framework it establishes is the right one.</p>

<p>Section 702 / AI intersection: watch for DOD contract disclosures, FOIA requests from EFF and EPIC, and any public reporting on how commercial AI tools are being used in intelligence analysis. The Anthropic/DOD situation is not the last instance of this conflict.</p>

<p>RT4 is watching all of these. The Fourth Amendment applies in 2026 for the same reason it applied in 1791: the government has powerful tools for surveillance and limited institutional incentive to restrain itself. The mechanisms change. The principle doesn't.</p>
