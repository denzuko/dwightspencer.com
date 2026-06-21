+++
title       = "Why Lisp Is Only for Hackers"
date        = "2026-06-21"
draft       = false
description = "I built and archived a tool that dumps Common Lisp source as a structured AST for policy gates and attestation pipelines. The reason it got archived is more interesting than the tool would have been: Lisp doesn't have a parse phase independent of execution, and that's not a bug."
slug        = "21-lisp-attestation-hackers"
keywords    = ["common lisp", "static analysis", "attestation", "governance", "finops", "macros", "cleavir", "policy as code", "opa", "rego"]
tags        = ["Lisp", "Governance", "FinOps", "Static Analysis", "DevSecOps"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Common Lisp, Static Analysis, Security Tooling Architecture"
aliases     = ["/21-lisp-attestation-hackers/"]
og_image    = "/assets/og-posts.png"
+++

<p>I spent a working session building <code>sext</code>, a tool meant to
dump Common Lisp source as a structured JSON AST for policy-as-code
pipelines — OPA and Rego gates, SARIF reports, CycloneDX attestation,
the usual supply chain stack. The pitch was simple: Common Lisp has
nothing equivalent to <code>clang -ast-dump=json</code>, and a
real bug class in another project of mine — a function silently
defeating its own type-dispatch logic because a caller pre-wrapped a
value before passing it in — was exactly the kind of thing a structural
AST check would have caught before merge.</p>

<p>The tool got built. It worked. I archived it anyway. The reason is
the actual content of this post, because it isn't a story about a bug
I couldn't fix. It's a story about a property of the language that no
amount of engineering time was going to fix, and a governance lesson
that applies well past Lisp.</p>

<h2 id="what-broke">What broke</h2>

<p>Most languages give you a parse phase that's structurally
independent of execution. Read the file, get a tree, done — no code
has run yet. That separation is the quiet assumption underneath every
"scan it before you trust it" pipeline: you can learn enough about a
piece of code to make a trust decision before you give that code a
chance to act.</p>

<p>Common Lisp doesn't have that phase, by design. The reader and the
macroexpander are themselves ordinary Lisp code, fully available to
whatever program is being read. That's the same extensibility that
lets you bend the language to a problem in ways no other mainstream
language allows — it is also exactly what dissolves the boundary
between reading code and running code.</p>

<p>The two failure modes are not symmetric, and that asymmetry is the
whole finding. A function call referencing something undefined fails
loudly and specifically — Cleavir's converter names the exact symbol
it couldn't resolve. A macro that hasn't been expanded yet doesn't
fail at all. It gets silently misread as an ordinary function call,
producing a structurally wrong AST with nothing in the output to flag
that anything went sideways. I verified this directly: defining a
macro live in the image and dumping code that uses it works
perfectly — the gap isn't a capability limit in the AST conversion
itself, it's specifically about never having executed anything first.</p>

<p>The fix exists. Load the target system before you dump it, and
everything — functions, macros, all of it — resolves correctly,
no further engineering required. But that fix means the tool has to
execute the code it's meant to be gating before it can fully analyze
it. A tool can be safe-but-blind, or it can be correct-but-trusting.
For Lisp specifically, by design, it cannot be both at once.</p>

<h2 id="the-governance-problem">The governance problem, not just the technical one</h2>

<p>The motivating bug was real: catch a dangerous pattern in CI, before
a human reviews it, without running anything. That use case needs
safe-but-blind. The version of the tool that's actually correct on
real, idiomatic Lisp — the macro-heavy DSL style most of my own
codebases use — needs the opposite property.</p>

<p>That's not a missing feature. It's a structural conflict between
what the tool needed to be safe and what it needed to be useful, and
it's the kind of thing that doesn't show up until you've built the
thing and pushed on it. The safe version doesn't cover the use case.
The version that covers the use case isn't safe in the way a pre-merge
gate needs it to be. No amount of additional engineering time closes
that gap, because the gap is upstream of the engineering — it's in
what the language is.</p>

<h2 id="finops">What it cost, and where</h2>

<p>I'm not going to put a dollar figure on this — that number lives in
billing metering, not in anything visible from inside an agentic coding
session. What's worth reporting is the shape of where the cost went,
because the shape is itself the lesson.</p>

<p>The core logic — the AST walk, the JSON serialization, the schema
documentation, a working policy-example check verified end to end with
real test fixtures — landed in relatively few iterations. The expensive
part was CI verification: multiple full GitHub Actions run-and-poll
cycles before a clean baseline, a recurring Lisp environment gotcha
that cost rework every time it resurfaced, and the single most
expensive mistake of the session — a "fixed" conclusion about a flaky
lint failure, reached from local-sandbox testing, merged, and then
reversed once real CI evidence contradicted it directly.</p>

<p>That reversal is a clean proxy for the whole cost structure: spend
scaled with the gap between looks-verified-locally and is-verified-
against-the-real-target-environment, not with the difficulty of the
Lisp itself. Local testing gave false confidence more than once before
I started treating real CI logs as the actual source of truth.</p>

<h2 id="risk-matrix">The risk matrix, had this continued</h2>

<table>
<thead>
<tr><th>Risk</th><th>Category</th><th>Likelihood</th><th>Impact</th></tr>
</thead>
<tbody>
<tr><td>Silent misanalysis of macro-using code</td><td>Correctness</td><td>High — the default mode</td><td>High</td></tr>
<tr><td>Upstream AST schema drift (Cleavir)</td><td>Dependency coupling</td><td>Medium, ongoing</td><td>Medium-High</td></tr>
<tr><td>Single-implementation lock-in (SBCL internals)</td><td>Portability</td><td>Certain, already true</td><td>Medium</td></tr>
<tr><td>Execution-as-analysis, if load-first is added</td><td>Security / threat model</td><td>Certain, if pursued</td><td>High</td></tr>
<tr><td>Bus factor — solo maintainer</td><td>Organizational</td><td>Certain</td><td>High</td></tr>
<tr><td>CI/local verification drift</td><td>Operational</td><td>Medium</td><td>Low-Medium</td></tr>
<tr><td>Opportunity cost against other commitments</td><td>Strategic</td><td>Certain</td><td>Medium-High</td></tr>
</tbody>
</table>

<p>The pattern across that table is the actual signal: every serious
risk is structural — language design, dependency coupling, trust
model — rather than incidental, a bug sitting there waiting to be
fixed. That distinction is what separates "needs more engineering
time" from "needs a different approach entirely," and it's why
archiving the repo, rather than iterating further, was the right call.</p>

<h2 id="the-source">The source</h2>

<p>This was a real working session against a real tool, not a thought
experiment: a Common Lisp AST dumper built on
<a href="https://github.com/s-expressionists/Cleavir">Cleavir</a>'s
CST-to-AST converter, with a documented JSON schema, an
<code>opa test</code>-verified example policy, and two working GitHub
Actions, before the macro-expansion finding closed it out. The
repository is archived, not deleted, if anyone wants to read the
actual code that produced this finding rather than take my word for
it.</p>
