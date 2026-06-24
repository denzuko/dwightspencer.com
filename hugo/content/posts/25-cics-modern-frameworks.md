+++
title       = "You Already Know CICS. You Just Call It Something Else."
date        = "2026-06-23"
draft       = false
description = "CICS gave us MVC, request routing, session state, the ORM, and the service boundary in 1974. Every modern web framework rediscovered the same abstractions under different names. BRICKS_TS makes this visible by running the original architecture on a Linux host with PostgreSQL."
slug        = "25-cics-modern-frameworks"
keywords    = ["CICS","COBOL","BRICKS_TS","mainframe","MVC","web frameworks","SQL","REXX","software architecture","history"]
tags        = ["infrastructure","devops","open-source","foss"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Software Architecture, Infrastructure, Systems Programming"
aliases     = ["/25-cics-modern-frameworks/"]
og_image    = "/assets/og-posts.png"
series      = ["Dead Reckoning"]

[related_post]
  slug  = "15-terraform-llm-thesis"
  label = "post 15 covers a related argument: LLM-generated Terraform optimises for CLI exit codes, not architectural correctness — the same gap between 'it ran' and 'it is right' that CICS addressed by separating map, logic, and data"
+++

<p>I have been running a CICS transaction server on a Linux host with PostgreSQL
as the back end, writing COBOL and REXX programmes that issue EXEC CICS and
EXEC SQL statements, and watching the four-character TRANSID dispatch table route
requests to compiled programmes. The thing that keeps becoming obvious is that
none of this is old. The abstractions are the same abstractions every web
framework rediscovered between 1995 and 2015. CICS just did it in production
first.</p>

<p>The platform is <a href="https://github.com/moshix/BRICKS_TS">BRICKS_TS</a>, a Go
implementation of a CICS-compatible 3270 transaction server with embedded
COBOL and REXX interpreters and PostgreSQL via EXEC SQL. It runs on modern
Linux hosts alongside a Postgres database, without the need for emulation,
compilers, nor legacy MVS subsystems. You write a <code>.cob</code> or <code>.rexx</code>
file, register a four-character TRANSID in <code>transactions.conf</code>,
and it runs.</p>

<h2 id="the-transid-is-a-url">The TRANSID is a URL</h2>

<p>In a CICS environment, a transaction identifier — four characters, uppercase,
registered in the Programme Control Table — is how a terminal user invokes a
programme. The user types <code>CLNT</code> and presses Enter. CICS looks up CLNT in the
PCT, finds the programme name, loads it into the region, and executes it.
When the programme finishes, CICS returns control.</p>

<p>In contemporary terms, this is URL routing: the four-character string is the
path, the PCT is the route table, the CICS region is the application server,
and the programme is the controller. Rails did not invent this. It reinvented it with slashes and
variable interpolation, and it took until the late 1990s for the web to
catch up to where CICS was in 1974.</p>

<p>In <code>edm-cics</code>, the transaction table looks like this:</p>

<pre><code>CLNT:COBOL:CLNTINQ::edm
CLNU:COBOL:CLNTUPD::edm
ORDN:COBOL:ORDNENT::edm
HLPD:COBOL:HLPDISP::edm
SECU:COBOL:SECCCHK::edm
AUDT:REXX:AUDTLOG::edm
</code></pre>

<p>Each line maps a TRANSID to a language, a programme name, an optional group,
and a database connection. The router is a flat file, with no annotation, decorator, attribute,
nor class hierarchy required. The convention is the configuration.</p>

<p>Rails called this "convention over configuration" in 2004. CICS had the same
idea thirty years earlier and expressed it more tersely.</p>

<h2 id="the-bms-map-is-jsx">The BMS map is JSX</h2>

<p>Basic Mapping Support defines screen layouts in a compiled macro language.
A map specifies field positions, lengths, attributes (protected, unprotected,
numeric, bright), and symbolic names. The map is compiled separately from the
programme logic. The programme issues <code>EXEC CICS SEND MAP</code> with the map name
and a data structure; CICS renders the screen. The programme issues
<code>EXEC CICS RECEIVE MAP</code> and gets back the user's input in the same data structure.</p>

<p>The separation between the view definition and the rendering logic is complete.
The programme does not construct screen output character by character. It
populates a data structure and delegates rendering to the map definition.
The map knows about layout, the programme knows about business logic,
and neither has visibility into the other's implementation.</p>

<p>JSX is the same separation. The template engine in Django, Jinja2, ERB, and
Handlebars is the same separation. React's component model — props in, render
out, no side effects in the view — is the same separation. MVC's formal
articulation came from Trygve Reenskaug at Xerox PARC in 1979, five years
after CICS had already put it in production. The separation was not a
theoretical insight that practitioners later implemented. It was an engineering
requirement that theorists later named.</p>

<h2 id="the-commarea-is-the-session">The COMMAREA is the session</h2>

<p>CICS programmes are stateless by default. A programme runs, returns, and has
no persistent memory between invocations. State is passed between programmes
through the COMMAREA — a block of memory that the calling programme populates
and the called programme receives. State that needs to persist across user
interactions goes into temporary storage or the CICS Auxiliary Data Store.</p>

<p>This is the HTTP session model. The COMMAREA is the cookie or the session
token. Temporary storage is the server session store. The pattern that
web frameworks spent years debating — state held by the client versus state held by the server
state, where to put the JWT, how to handle session invalidation — is the
same problem CICS architects were solving in the 1970s under different names.</p>

<p>The EXEC CICS LINK command lets one programme call another, passing a COMMAREA.
The called programme executes and returns. This is a synchronous function call
across a programme boundary — microservice RPC with the network latency
removed. The programme isolation is the same; the communication contract is
the same; the COMMAREA is the request/response payload.</p>

<h2 id="exec-sql-is-the-orm">EXEC SQL is the ORM</h2>

<p>EXEC SQL statements embedded in COBOL and REXX are preprocessed at compile
time into host language calls against the database interface. The COBOL
programme declares host variables in the WORKING-STORAGE SECTION, binds them
to SQL parameters, and issues queries. The database returns results into those
same host variables.</p>

<pre><code>       EXEC SQL
           SELECT CLIENT_NAME, RISK_TIER
           INTO   :WS-CLIENT-NAME, :WS-RISK-TIER
           FROM   EDM_CLIENTS
           WHERE  CLIENT_ID = :WS-CLIENT-ID
       END-EXEC.
</code></pre>

<p>The host variable binding, the result mapping, the type coercion between SQL
types and host language types — this is what an ORM does. Django's ORM,
ActiveRecord, SQLAlchemy: all of them are solving the same impedance mismatch
between the relational model and the host language's type system. EXEC SQL
solved it by making the SQL native in the source, with the preprocessor
handling the translation. The abstraction layer is thinner and the SQL is
visible, which is why EXEC SQL produces fewer surprises than an ORM that
generates queries you did not write and cannot easily read.</p>

<h2 id="vsam-is-the-key-value-store">VSAM is the key-value store</h2>

<p>VSAM KSDS (Key-Sequenced Data Sets) are ordered, key-addressed file
structures with efficient random and sequential access. The API is four operations on keyed records: EXEC CICS READ retrieves
by key, EXEC CICS WRITE creates, EXEC CICS REWRITE updates in place,
and EXEC CICS DELETE removes.</p>

<p>This is Redis. This is DynamoDB. This is every key-value store that spent
the 2000s and 2010s positioning itself as a NoSQL innovation. The innovation
was removing the relational constraint and distributing the storage. The data
model — keyed records, CRUD operations, ordered traversal — is VSAM. The
distributed systems papers that justified the NoSQL movement cited CAP theorem
and eventual consistency, not VSAM. The intellectual debt to VSAM went
unacknowledged, partly because the mainframe community and the web community
have not historically read each other's literature.</p>

<h2 id="what-bricks_ts-makes-visible">What BRICKS_TS makes visible</h2>

<p>Running CICS on a Linux host with PostgreSQL removes the hardware constraint
that made the original architecture feel exotic. The 3270 terminal becomes a
telnet connection or an expect script. The CICS region becomes a Go process.
The VSAM files become PostgreSQL tables with appropriate indexes. The
COBOL and REXX programmes remain what they were.</p>

<p>What is left, once the hardware is gone, is the architecture. And the
architecture is not exotic. It is the same layered separation that every
competent web application implements: routing at the entry point, logic in
the programme, data access through a typed interface, views defined separately
from logic, state managed explicitly rather than implicitly.</p>

<p>The <code>edm-cics</code> platform serves two organisations — EDM and Da Planet Radio —
from the same BRICKS_TS runtime, with separate transaction namespaces and
separate PostgreSQL schemas. The multi-tenancy model is the same as every
SaaS platform that partitions customers by schema or database. The CICS
security model, with user groups controlling TRANSID access, is the same
as role-based access control. The CECI interactive transaction — BRICKS_TS's
REPL for live CICS/SQL debugging — is the same as the Rails console or the
Django shell, except it has been shipping since 1975.</p>

<h2 id="why-this-matters-for-people-who-learned-frameworks-first">Why this matters for people who learned frameworks first</h2>

<p>The argument is not that COBOL is better than Python or that you should
learn CICS instead of Django. The argument is that the abstractions you are
using have a fifty-year-old proof of correctness behind them, and understanding
where they came from makes it easier to evaluate new frameworks that claim
to have solved the same problems differently.</p>

<p>A new framework that claims a clean separation between view and logic
can be evaluated against BMS maps, which separated them completely in 1974
with no shared state between the map definition and the programme. A framework
that calls its routing convention-based can be compared against a four-character
TRANSID in a flat file, which is as terse as routing gets. A framework whose
ORM hides SQL has not resolved the impedance mismatch between the relational
model and the host language — it has moved the surprise from compile time
to runtime.</p>

<p>These comparisons are useful not because CICS is a benchmark to optimise for,
but because fifty years of production use is a better proof of correctness
than a conference talk and a GitHub star count. The abstractions that survived
that long are the ones that reflect something true about the problem.</p>

<p>The BRICKS_TS source is at
<a href="https://github.com/moshix/BRICKS_TS">github.com/moshix/BRICKS_TS</a>.
The EDM CICS application source is at
<a href="https://github.com/denzuko/edm-cics">github.com/denzuko/edm-cics</a>.
The Podman Quadlet deployment is at
<a href="https://github.com/denzuko/edm-cics-quadlet">github.com/denzuko/edm-cics-quadlet</a>.</p>
