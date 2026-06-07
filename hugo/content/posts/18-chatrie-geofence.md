+++
title       = "Chatrie v. United States: The Cloud Storage Question the Supreme Court Has to Answer"
date        = "2026-05-28"
draft       = false
description = "The Supreme Court heard arguments in Chatrie v. United States on April 27. The question is whether geofence warrants violate the Fourth Amendment. The real question is whether storing your life on someone else's server destroys your constitutional protection over it."
slug        = "18-chatrie-geofence"
keywords    = ["chatrie", "geofence warrant", "fourth amendment", "scotus", "google", "location data", "cloud storage", "privacy"]
tags        = ["fourth-amendment", "privacy", "civil-liberties", "surveillance"]
categories  = ["articles"]
schema_type = "Article"
aeo_expertise = "Fourth Amendment, Surveillance Accountability, Digital Privacy Law"
aliases     = ["/18-chatrie-geofence/"]
og_image    = "/assets/og-posts.png"
series      = ["The Watchers You Fed"]

[related_post]
  slug  = "17-troy-flock"
  label = "post 13 covers the municipal procurement side of the same infrastructure"
+++

<p>On April 27, the Supreme Court heard arguments in <em>Chatrie v. United States</em> (No. 25-112). The case involves Okello Chatrie, convicted of a 2019 bank robbery in Virginia based in part on location data obtained from Google via a geofence warrant — a warrant directing Google to provide location data for all devices near a crime scene during a specific time window.</p>

<p>Chatrie had Location History enabled. The warrant reached his data along with data from everyone else who happened to be near that credit union during that two-hour window. He pleaded guilty after the motion to suppress the geofence evidence was denied. The Fourth Circuit, sitting en banc, split deeply — nine separate concurrences and dissents totaling 126 pages — before affirming in a single-sentence per curiam opinion. The Supreme Court granted cert in January 2026. A decision is expected by end of June.</p>

<h2 id="the-third-party-doctrine">The third-party doctrine problem</h2>

<p>The Fourth Circuit majority held that Chatrie had no reasonable expectation of privacy in his location data because he had voluntarily shared it with Google. This is the third-party doctrine: information you share with a third party loses Fourth Amendment protection because you assumed the risk of disclosure when you shared it.</p>

<p>The doctrine made sense in 1979 when the Supreme Court applied it to bank records. It does not map cleanly to 2026.</p>

<p>Justice Gorsuch pressed on this at oral argument: if voluntarily storing information with Google destroys Fourth Amendment protection, the same logic reaches email, documents, photos, and calendar entries. Modern people don't store the substance of their lives in filing cabinets anymore — they store it on servers owned by corporations that operate under terms of service most people have never read. If that storage constitutes voluntary disclosure to a third party the government can access without a warrant, the Fourth Amendment contracts substantially without anyone formally changing the text.</p>

<h2 id="what-a-geofence-warrant-actually-does">What a geofence warrant actually does</h2>

<p>A standard warrant names a suspect and describes what to search. A geofence warrant names a location and a time window, then asks Google to search its entire Location History database — hundreds of millions of users — to identify which devices were present. Google first returns an anonymized list, law enforcement narrows it, then requests de-anonymization of the identified devices.</p>

<p>The Fifth Circuit, in a separate case, held that geofence warrants are inherently overbroad and violate the Fourth Amendment — that the initial search of the full database, not just the eventual identification of a suspect, is the constitutional problem. The Fourth Circuit disagreed. The split is why <em>Chatrie</em> is at the Supreme Court.</p>

<p>The constitutional issue is that the search begins with no probable cause as to any individual — it's a dragnet, justified by the crime scene location, that sweeps in everyone who happened to be nearby. A person who was at that credit union legitimately, with no connection to the robbery, had their movements extracted and reviewed by law enforcement. They were never told.</p>

<h2 id="how-the-justices-read">How the justices read it</h2>

<p>After two hours of argument, the court appeared divided. Some justices seemed drawn toward a narrow ruling — clarifying what geofence warrants require procedurally without deciding the broader third-party doctrine question. Orin Kerr, a Fourth Amendment scholar at Berkeley, assessed the court as likely to allow geofence warrants to continue with scope limitations, rather than hold them categorically unconstitutional.</p>

<p>That would be the technically cautious outcome. It would also leave the third-party doctrine intact for cloud-stored data, meaning the structural problem — that storing your life on someone else's server may forfeit your constitutional protection — goes unresolved.</p>

<h2 id="the-infrastructure-question">The infrastructure question</h2>

<p>The self-hosting argument and the Fourth Amendment argument are the same argument from different directions. If you control your own infrastructure, geofence warrants can't reach it. If you store your Location History with Google, it can.</p>

<p>One major tech company has stated in its transparency reports that it doesn't maintain data in a form that responds to geofence warrants. Another changed its location data practices specifically to limit exposure to geofence requests. Those are engineering choices with constitutional consequences.</p>

<p>The court's decision will establish the legal floor. The engineering floor is yours to set.</p>

<h2 id="what-comes-next">What comes next</h2>

<p>A decision before the end of June 2026. If the court rules narrowly on procedural requirements for geofence warrants, the third-party doctrine question remains open for the next case. If the court rules on the doctrine itself, the implications extend to every piece of data stored on third-party infrastructure — which, for most people, is most of their data.</p>

<p>RT4 is watching. The Fourth Amendment Is Not For Sale Act — which would close the data broker loophole for government purchases of location data — passed the House Appropriations Committee 32-25 in May as a spending rider. <em>Chatrie</em> and the data broker fight are the same fight running on parallel tracks. One is in the courts. One is in Congress. Neither is finished.</p>
