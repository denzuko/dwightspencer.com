+++
title       = "What Flock Safety Actually Is: The ALPR Infrastructure Stack"
date        = "2026-05-27"
draft       = false
description = "A technical look at what Flock Safety cameras collect, how the data moves, what the backend architecture looks like, and what you can find out about a city's deployment before anyone asks for a warrant."
slug        = "16-alpr-infrastructure"
keywords    = ["flock safety", "alpr", "license plate reader", "fusus", "surveillance infrastructure", "network", "privacy", "foil"]
tags        = ["infrastructure", "privacy", "surveillance", "fourth-amendment"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Surveillance Infrastructure, Network Security, Systems Analysis"
venue       = "2600"
aliases     = ["/16-alpr-infrastructure/"]
og_image    = "/assets/og-posts.png"
+++

Flock Safety markets itself as a "public safety operating system." What
it actually is: a network of fixed automated license plate readers (ALPRs)
feeding a cloud-hosted vehicle intelligence database, searchable by law
enforcement across jurisdictions in near real time.

Here's what's in that system, how it works, and what you can find out
about a deployment in your city without touching anything.

<h2 id="the-hardware">The hardware</h2>

A Flock Falcon camera is a fixed pole-mounted unit. Solar panel and
cellular modem on the same pole — no city network connection required,
which is how they get installed without touching IT infrastructure or
requiring a network change order. That detail matters: it means the
procurement can happen entirely within a police department's budget
without facilities or IT involvement.

The camera captures:
- License plate (front and rear where visible)
- State of registration
- Vehicle make, model, color
- "Vehicle fingerprint" — distinctive features: bumper stickers, roof
  racks, spare tires, damage patterns
- Direction of travel
- Timestamp, GPS coordinates of the camera

All of this goes to Flock's cloud via the cellular modem. Not to a city
server. Not to the police department's on-premises storage. To Flock.

<h2 id="the-database">The database</h2>

Flock operates what they call the National Vehicle Location Service
(NVLS) — a shared database of plate reads contributed by all Flock
customers. A police department in Troy, NY can query plate reads from
Flock cameras in Georgia, Texas, or California. The data retention
default is 30 days for non-flagged reads. "Flagged" reads — plates on
a hot list — are retained longer.

The hot list system is worth understanding. Any Flock customer can add
a plate to a "community concern" list. That list is shared across the
NVLS. There is no judicial oversight of the hot list. A private school
can add a plate. A homeowners association can add a plate. The threshold
for inclusion is the customer's discretion, not probable cause.

When a camera reads a plate on a hot list, it sends an alert — typically
to a mobile app used by patrol officers, and to a Fusus integration if
the department runs one.

<h2 id="fusus">Fusus and the integration layer</h2>

Fusus is a separate product — a real-time crime center platform that
aggregates multiple camera feeds and sensor inputs into a unified
operational picture. When a city runs both Flock and Fusus, the ALPR
alerts feed into Fusus alongside CCTV footage, gunshot detection (ShotSpotter),
and other sensor inputs.

Albany's deployment, documented by RT4 Albany, runs Flock Falcon cameras
on the Central Avenue corridor alongside Fusus Core and Flock Raven units.
Raven is Flock's video surveillance product — a separate camera that feeds
video, not just plate reads. The combined deployment gives you a fused
operational picture: every vehicle that passed a specific block, plus
video of the same time window, searchable from one interface.

The Fusus platform also supports "community integration" — private cameras
from businesses and residences can be voluntarily connected to the Fusus
system, making their feeds available to law enforcement without a subpoena.

<h2 id="what-you-can-find">What you can find without a warrant</h2>

Most of the infrastructure is visible without any special access.

**Camera locations:** Flock cameras are on public streets. You can walk
them. Albany's Central Avenue spine has cameras at regular intervals —
enumerable by driving the corridor. In many cities, the contract with
Flock includes a map of camera locations that's obtainable via FOIL/FOIA.

**The contract:** Flock contracts are public records in most jurisdictions.
File a FOIL request with the city clerk or police department. What you
want in the contract: retention period, data sharing provisions, national
database opt-out terms (if any), auto-renewal clause, termination rights.

**The data retention policy:** Flock's standard contract terms are
documented in their public-facing privacy policy and customer agreements.
The defaults are 30 days for non-flagged reads, longer for flagged. Some
cities have negotiated shorter retention. Most haven't.

**Camera metadata:** Flock cameras report their location to the NVLS.
Some researchers have found Flock camera location data exposed through
indirect means — the cellular modems register with the carrier, and
tower association data is sometimes accessible through public records
requests to carriers or through FCC filings for the radio equipment.

<h2 id="the-cellular-modem">The cellular modem detail</h2>

The cellular modem in each Flock Falcon is registered to Flock Safety's
corporate account with the carrier, not to the city. This means:

1. The city doesn't control the network path the data takes
2. A carrier-level intercept or records request would go to Flock, not
   to the city
3. If Flock loses the carrier contract or goes out of business, the
   cameras stop working — the infrastructure is vendor-dependent by design

The data path: camera → cellular carrier → Flock's cloud (AWS, based on
their infrastructure disclosures) → NVLS → authorized law enforcement
queries. The city is not in this path except as a customer.

<h2 id="what-a-plate-read-reveals">What a plate read actually reveals</h2>

A single plate read is not very interesting. An aggregated record of
every time a specific plate passed a specific camera is a movement pattern.

If a city has 24 cameras covering major corridors, a vehicle that travels
through the city routinely will accumulate hundreds of reads per month.
That record reveals: where the person lives (plates seen near a specific
address repeatedly at night), where they work (plates seen near a specific
address repeatedly during business hours), medical appointments, religious
attendance, political meetings, who they visit.

None of this requires a warrant under current law in most jurisdictions.
The third-party doctrine applies: the data was generated by driving on
public roads past cameras operated by a vendor contracted with a public
entity. The Supreme Court's *Carpenter* decision (2018) established a
warrant requirement for historical cell-site location data. The *Chatrie*
case, currently at the Supreme Court, may extend similar protection to
geofence data. Neither decision has been held to apply directly to ALPR
data.

<h2 id="the-foil-path">The FOIL path</h2>

If you're in New York State, here's what to request:

1. **The Flock Safety contract** — from the city clerk or police
   department. Ask for all exhibits and amendments.
2. **Camera locations** — request the map provided by Flock or the
   deployment plan filed with the city
3. **Hot list policy** — ask for the department's written policy on
   adding plates to alert lists, including who can add and what
   documentation is required
4. **Data access logs** — some departments maintain logs of NVLS queries
   made by officers. These are records under FOIL.
5. **Fusus contract** — if applicable. Same structure as the Flock
   contract request.

Most departments will initially respond to a hot list policy request
with "we don't have a written policy." That response is itself useful.

<h2 id="the-architecture-question">The architecture question</h2>

What the Troy fight exposed — what every Flock deployment exposes — is
that the infrastructure was designed to be difficult to remove. The
cellular modems, the cloud backend, the NVLS integration, the auto-renewal
contract terms, the below-procurement-threshold pricing: these are not
accidents. They're design choices that maximize deployment persistence.

Understanding the architecture is the first step to contesting it on
technical grounds rather than just political ones. You can argue about
whether the city council approved the contract. You can also FOIL the
contract, enumerate the camera locations, document the data flows, and
publish what you find.

The second approach tends to be more durable.

---

*RT4 Albany has been documenting the Central Avenue surveillance spine
since 2023. If you're in the Capital Region and want to get involved:
restorethe4th.com/chapters/albany*
