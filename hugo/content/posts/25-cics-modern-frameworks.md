+++
title       = "Convergent Design: What BRICKS_TS Revealed About Web Frameworks"
date        = "2026-06-23"
draft       = false
description = "Running CICS transactions against a Postgres database on a Linux host makes something obvious: the architecture is not alien. The routing table, the separation of map from logic, and the explicit passing of state between transactions are the same structural answers the web framework generation arrived at independently, because they were solving the same problems under different constraints."
slug        = "25-cics-modern-frameworks"
keywords    = ["CICS","COBOL","BRICKS_TS","mainframe","web frameworks","SQL","REXX","software architecture","convergent design","history"]
tags        = ["infrastructure","devops","open-source","foss"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Software Architecture, Infrastructure, Systems Programming"
aliases     = ["/25-cics-modern-frameworks/"]
og_image    = "/assets/og-posts.png"
series      = ["Dead Reckoning"]

[related_post]
  slug  = "15-terraform-llm-thesis"
  label = "post 15 covers a related argument about the gap between code that runs and architecture that is correct"
+++

<p>I have been running CICS transactions against a Postgres database on a Linux
host, writing COBOL and REXX that most of the people who read this site have
never touched. The same design constraints that production business
needs imposed on IBM in the 1970s have paid forward across every language
generation since. What CICS solved for routing, display separation, and state
management under the constraints of expensive terminal sessions, the web
framework generation solved again under the constraints of stateless HTTP.
The constraints shaped the same answers because the problems were the same.</p>

<p>The platform is <a href="https://github.com/moshix/BRICKS_TS">BRICKS_TS</a>, a Go
implementation of the CICS transaction model with a 3270 terminal server, embedded
COBOL and REXX interpreters and PostgreSQL via EXEC SQL. It runs on modern
Linux hosts alongside a Postgres database, without the need for emulation,
compilers, nor legacy MVS subsystems. You write a <code>.cob</code> or <code>.rexx</code>
file, register a TRANSID of four characters in <code>transactions.conf</code>, and it
runs. Stripping the mainframe hardware away leaves the architecture exposed,
and the architecture is legible to anyone who has built a web application in
the last twenty years.</p>

<h2 id="the-routing-problem">The routing problem</h2>

<p>A CICS transaction identifier — four characters, uppercase, registered in the
Programme Control Table — is how a terminal operator invokes a programme.
The user types <code>CLNT</code> and presses Enter. CICS looks up CLNT in the PCT,
finds the programme name, loads it, and executes it.</p>

<p>The web framework generation arrived at the same answer from a different
direction. The constraint was stateless HTTP rather than expensive terminal
sessions, the identifiers became URL paths rather than codes of four characters,
and the lookup table became a route configuration file rather than a compiled
PCT. The structural answer is the same: a registration step maps an identifier
to executable logic, and the framework handles dispatch.</p>

<p>In <code>edm-cics</code>, the registration looks like this:</p>

<pre><code>CLNT:COBOL:CLNTINQ::edm
CLNU:COBOL:CLNTUPD::edm
ORDN:COBOL:ORDNENT::edm
HLPD:COBOL:HLPDISP::edm
SECU:COBOL:SECCCHK::edm
AUDT:REXX:AUDTLOG::edm
</code></pre>

<p>Each line maps a TRANSID to a language, a programme name, an optional group,
and a database connection. The router is a flat file, with no annotation,
decorator, attribute, nor class hierarchy required. Rails called this
convention over configuration in 2004. The CICS PCT was doing it thirty years
earlier under harder memory and bandwidth constraints — which is why it is
four characters rather than a slug.</p>

<h2 id="separating-display-from-computation">Separating display from computation</h2>

<p>Basic Mapping Support defines screen layouts in a compiled macro language.
A map specifies field positions, lengths, and attributes. The map is compiled
separately from the programme logic. The programme issues
<code>EXEC CICS SEND MAP</code> with the map name and a data structure; CICS renders the
screen. The programme issues <code>EXEC CICS RECEIVE MAP</code> and gets back the user's
input in the same structure.</p>

<p>The separation is complete: the map knows about layout, the programme knows
about business logic, and neither has visibility into the other's
implementation. The terminal bandwidth constraint made this separation
economically necessary — regenerating a full screen on every interaction was
expensive, so the system needed to distinguish between what changed and what
did not. The web framework generation arrived at the same separation through
template engines and component models, driven by the different constraint of
maintaining consistency between HTML generated on the server and state held on the client.</p>

<p>MVC's formal articulation came from Trygve Reenskaug at Xerox PARC in 1979,
five years after CICS had this pattern in production. The separation was not a
theoretical insight that practitioners later implemented — it was an
engineering requirement that theorists later named.</p>

<h2 id="state-across-stateless-interactions">State across stateless interactions</h2>

<p>CICS programmes are stateless by default. A programme runs, returns, and has
no persistent memory between invocations. State is passed between programmes
through the COMMAREA — a block of memory the calling programme populates and
the called programme receives. State that needs to persist across user
interactions goes into temporary storage.</p>

<p>HTTP is stateless by the same constraint: each request carries no inherent
memory of prior requests. The web framework generation built session stores,
cookies, and tokens to manage the same gap. The COMMAREA is the payload that
travels between a request and the next; the token is the credential that
identifies which stored state belongs to this interaction. The gap being
bridged is identical — the transport is different.</p>

<p>EXEC CICS LINK lets one programme call another with a COMMAREA. The called
programme executes and returns. This is a synchronous call across a programme
boundary with an explicit data contract — the same pattern the microservices
generation formalised into RPC interfaces and API contracts, driven by the
constraint of horizontal scaling rather than mainframe region isolation.</p>

<h2 id="the-impedance-mismatch">The impedance mismatch</h2>

<p>EXEC SQL statements embedded in COBOL and REXX are preprocessed at compile
time into host language calls against the database interface. The programme
declares host variables in the WORKING-STORAGE SECTION, binds them to SQL
parameters, and issues queries:</p>

<pre><code>       EXEC SQL
           SELECT CLIENT_NAME, RISK_TIER
           INTO   :WS-CLIENT-NAME, :WS-RISK-TIER
           FROM   EDM_CLIENTS
           WHERE  CLIENT_ID = :WS-CLIENT-ID
       END-EXEC.
</code></pre>

<p>The host variable binding, the result mapping, and the type coercion between
SQL types and the host language's type system — this is the impedance mismatch
problem. Django's ORM, ActiveRecord, and SQLAlchemy are all addressing the
same mismatch. EXEC SQL addressed it by making the SQL native in the source
with the preprocessor handling translation, keeping the query visible and the
abstraction shallow. The ORM generation moved in the opposite direction,
generating queries from object graphs and absorbing the SQL into the
framework's internals. Both approaches reflect the same underlying tension;
neither resolves it, they trade it for different failure modes.</p>

<h2 id="key-addressed-storage">Key-addressed storage and what followed</h2>

<p>VSAM KSDS (Key-Sequenced Data Sets) are ordered, key-addressed file structures
with efficient random and sequential access. The API is four operations on
keyed records: EXEC CICS READ retrieves by key, EXEC CICS WRITE creates,
EXEC CICS REWRITE updates in place, and EXEC CICS DELETE removes.</p>

<p>The NoSQL movement of the 2000s positioned key-value stores as an innovation
driven by distributed systems requirements and the inadequacy of relational
models for certain access patterns. The data model — keyed records, CRUD
operations, ordered traversal — is VSAM. The genuine innovation was removing
the relational constraint and distributing storage across commodity hardware.
The distributed systems papers that justified the movement cited CAP theorem
and eventual consistency, not VSAM, partly because the mainframe community and
the web community have not historically read each other's literature.</p>

<h2 id="what-bricks-ts-shows">What BRICKS_TS shows</h2>

<p>The <code>edm-cics</code> platform serves two organisations — EDM and Da Planet Radio —
from the same BRICKS_TS runtime, with separate transaction namespaces and
separate PostgreSQL schemas. The CICS security model, with user groups
controlling TRANSID access, produces the same access control structure any modern application framework applies. The CECI
interactive transaction — BRICKS_TS's mechanism for live CICS debugging and
query execution — is the same tool as the Rails console or Django shell, and
has been shipping since 1975.</p>

<p>None of this required coordination. The COBOL developers writing EXEC CICS
LINK calls and the Ruby developers writing controller actions were not in the
same conversation. The mainframe constraint was hardware cost and terminal
bandwidth. The web constraint was stateless HTTP and heterogeneous clients.
The business problem was the same — route a request to logic, separate display
from computation, manage state across stateless interactions, map structured
data to a host language — and similar constraints on similar problems produced
similar structures.</p>

<p>Running CICS on Linux with Postgres strips the hardware constraint away and
leaves the architecture. That architecture is not a historical artefact. It is
a worked example of solutions to problems the industry is still solving, built
fifty years earlier under harder constraints, by practitioners who arrived at
the same answers without the benefit of the literature that would later
describe what they had done.</p>

<p>The BRICKS_TS source is at
<a href="https://github.com/moshix/BRICKS_TS">github.com/moshix/BRICKS_TS</a>.
The EDM CICS application source is at
<a href="https://github.com/denzuko/edm-cics">github.com/denzuko/edm-cics</a>.
The Podman Quadlet deployment is at
<a href="https://github.com/denzuko/edm-cics-quadlet">github.com/denzuko/edm-cics-quadlet</a>.</p>
