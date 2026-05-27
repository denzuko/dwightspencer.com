+++
title       = "Troy, NY: How a Surveillance Contract Captured a City"
date        = "2026-05-27"
draft       = false
description = "Mayor Mantello declared a public safety emergency to pay a Flock camera contract her city council had blocked. The council filed an Article 78 lawsuit. The fight is still live. Here's the contract mechanism that made it possible — and why it matters beyond Troy."
slug        = "13-troy-flock"
keywords    = ["flock safety", "alpr", "surveillance", "troy ny", "fourth amendment", "procurement", "civil liberties", "rt4"]
tags        = ["privacy", "surveillance", "fourth-amendment", "civil-liberties"]
categories  = ["articles"]
schema_type = "Article"
aeo_expertise = "Surveillance Accountability, Civil Liberties, Municipal Technology Policy"
aliases     = ["/13-troy-flock/"]
og_image    = "/assets/og-posts.png"
+++

On March 19, 2026, roughly 150 Troy residents showed up to a city council
meeting and the council tabled the Flock camera contract for review.
Reasonable. Standard legislative process.

On March 31, the contract auto-renewed.

The council hadn't voted to cancel it. They'd voted to pause and review.
Under the contract terms, that was enough. Flock's renewal clause required
affirmative council action to cancel — not to renew. Inaction was consent.

The council directed the city auditor to withhold payment. On April 1,
Mayor Carmella Mantello declared a public safety emergency to override
that directive and authorize payment. On May 11, the council filed an
Article 78 motion in Rensselaer County Supreme Court to vacate the
emergency order and void the payment.

The lawsuit is pending. A partial compromise was announced May 21 —
the national Flock database search function disabled, some data-sharing
safeguards implemented. The council's local law establishing ALPR
standards is still moving. The Article 78 is still moving. Both are
moving simultaneously because the council doesn't trust the compromise
to hold without the legal and legislative backstops.

<h2 id="the-mechanism">The mechanism</h2>

The auto-renewal clause is not specific to Troy. It is standard in Flock
contracts, and it is not an accident.

The structure works like this: the initial contract requires council
approval. The renewal does not — it happens automatically unless the
council affirmatively cancels before the renewal date. In Troy, the
contract was a $78,000 annual agreement. The council believed the city
attorney had publicly confirmed that council authorization was required
for renewal. The mayor's position was that authorization wasn't required
— the renewal was automatic and the council's failure to act constituted
approval.

That dispute about what the contract said is the center of the Article 78
case. But the practical outcome was already determined by the time the
legal argument started: the cameras were running, the contract had renewed,
and the only lever the council had left was to withhold payment — which
the mayor then overrode with an emergency declaration.

The emergency declaration is the piece worth understanding. New York State
allows a mayor to declare a local public safety emergency and take executive
action to address it. The standard is a genuine public safety threat.
Council President Susan Steele characterized the emergency declaration as
"the mayor's inappropriate declaration of an emergency" used to
"bypass legislative approval and authorize payments to Flock."
The mayor's position is that the cameras are public safety infrastructure
and halting payment constitutes a public safety risk.

That argument — surveillance infrastructure as public safety infrastructure,
therefore any disruption to it is a public safety emergency — is the
argument that needs scrutiny everywhere this pattern appears.

<h2 id="the-data">What Flock collects</h2>

Flock Safety's cameras are automated license plate readers with vehicle
fingerprinting: make, model, color, distinguishing features, and direction
of travel, timestamped and geolocated. Every vehicle that passes a camera
is logged.

Troy has roughly two dozen cameras. Flock has said the system doesn't
use facial recognition and only looks at vehicles. What it doesn't say
is what happens to the plate reads: by default, they feed into Flock's
national database, searchable by law enforcement agencies in other
jurisdictions. Troy's partial compromise includes disabling that national
search function — but "disabled" in a vendor-managed cloud system means
relying on Flock's configuration, not Troy's control.

The data retention policy is set by Flock's contract terms, not by Troy's
local law. The council's proposed local law would change that — mandating
explicit data retention limits, use restrictions, and oversight requirements.
That's why the mayor, the DA, and the police chief came out against it.
Not because they oppose privacy, but because the local law would shift
control over the infrastructure from the vendor and the executive to the
legislature.

<h2 id="the-pattern">The pattern</h2>

What happened in Troy is the standard procurement capture playbook for
surveillance infrastructure:

1. Contract signed by executive, often without full legislative review
2. Auto-renewal clause means inaction = continuation
3. When legislature tries to assert oversight, executive characterizes
   it as an attack on public safety
4. Vendor provides political support — Flock's national network means
   local law enforcement has relationships with the company independent
   of the city council
5. By the time residents notice, the infrastructure is operational, the
   data is flowing, and the contractual leverage is gone

The $78,000 figure is deliberately below thresholds that would trigger
more rigorous procurement review in most municipalities. It's not the
contract cost that matters — it's the data it generates and the
infrastructure it normalizes.

<h2 id="why-it-matters">Why the Article 78 matters beyond Troy</h2>

If the council prevails, municipalities across New York state have a
legal path to vacate emergency orders used to bypass procurement oversight
of surveillance contracts. That's a template. The decision would
establish that executive emergency powers cannot be used to override
legislative control over ordinary vendor payments — even for infrastructure
the executive characterizes as public safety.

If Mantello prevails, the opposite precedent sets: a mayor who disagrees
with legislative oversight of a surveillance contract can declare an
emergency, pay the vendor, and let the legislature sue. The cost of that
litigation falls on the council's legal team, which — unlike the mayor's
— is not being paid by the city.

A decision is expected this summer. RT4 Albany is watching. The Central
Avenue surveillance spine in Albany operates on the same vendor
relationships. The legal precedent set one city over applies directly.

<h2 id="what-to-do">What to do now</h2>

If you're in Troy: the public hearing on the local ALPR law has passed,
but the council is still moving the legislation. Contact your council
member. The Article 78 is in Rensselaer County Supreme Court — public
records.

If you're in any other municipality with Flock cameras: FOIL the contract.
Look for the auto-renewal clause. Look for the data retention terms. Look
for what "disabling" national database access actually means in the
contract language versus in practice.

If you want the technical picture of what ALPR infrastructure looks like
at scale — the Flock/Fusus/Raven architecture running on Albany's Central
Avenue — that writeup is coming. RT4 Albany has been documenting it.
