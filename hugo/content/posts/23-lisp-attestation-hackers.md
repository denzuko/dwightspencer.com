+++
title       = "Why Lisp Is Only for Hackers"
date        = "2026-06-21"
draft       = false
description = "A working session building a Common Lisp AST-to-JSON tool for policy gates and attestation pipelines ended in a structural finding: Common Lisp has no parse phase independent of execution. The archived tool and the governance lesson that follows from it."
slug        = "23-lisp-attestation-hackers"
keywords    = ["common lisp", "static analysis", "attestation", "governance", "finops", "macros", "cleavir", "policy as code", "opa", "rego"]
tags        = ["Lisp", "Governance", "FinOps", "Static Analysis", "DevSecOps"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Common Lisp, Static Analysis, Security Tooling Architecture"
aliases     = ["/23-lisp-attestation-hackers/"]
og_image    = "/assets/og-posts.png"
+++

<p>A working session building <code>sext</code> — a tool to dump Common Lisp source
as a structured JSON AST for policy-as-code pipelines: OPA and Rego gates, SARIF
reports, CycloneDX attestation, the usual supply chain stack. The pitch was
straightforward: Common Lisp has nothing equivalent to <code>clang -ast-dump=json</code>,
and a real bug class in another project — a function silently defeating its own
type-dispatch logic because a caller pre-wrapped a value before passing it in —
was exactly the kind of pattern a structural AST check would have caught before
merge.</p>

<p>The tool was built. It worked. It was archived. The reason is the content of
this post, because it is not a story about a bug that could not be fixed. It is
a story about a property of the language that no amount of engineering time was
going to resolve, and a governance lesson that applies well past Lisp.</p>

<h2 id="what-broke">What broke</h2>

<p>Most languages provide a parse phase that is structurally independent of
execution. Read the file, get a tree, done — no code has run yet. That separation
is the quiet assumption underneath every "scan it before trusting it" pipeline:
sufficient information about a piece of code is available to make a trust decision
before that code has any opportunity to act.</p>

<p>Common Lisp does not have that phase, by design. The reader and the
macroexpander are themselves ordinary Lisp code, fully available to whatever
programme is being read. That is the same extensibility that allows bending the
language to a problem in ways no other mainstream language permits — it is also
precisely what dissolves the boundary between reading code and running code.</p>

<p>The two failure modes are not symmetric, and that asymmetry is the whole
finding. A function call referencing something undefined fails loudly and
specifically — Cleavir's converter names the exact symbol it could not resolve.
A macro that has not been expanded does not fail at all. It is silently misread
as an ordinary function call, producing a structurally wrong AST with nothing
in the output to indicate anything went sideways. Verified directly: defining
a macro live in the image and dumping code that uses it works correctly — the
gap is not a capability limit in the AST conversion itself, it is specifically
that nothing was executed first.</p>

<p>The fix exists. Load the target system before dumping it, and everything —
functions, macros, all of it — resolves correctly, without further engineering.
But that fix requires the tool to execute the code it was meant to gate before
it can fully analyse it. A tool may be safe-but-blind, or it may be
correct-but-trusting. For Lisp, by design, it cannot be both at once.</p>

<h2 id="the-governance-problem">The governance problem</h2>

<p>The motivating requirement was specific: catch a dangerous pattern in CI,
before a human reviews it, without running anything. That use case requires
safe-but-blind. The version of the tool that is correct on real, idiomatic
Lisp — the macro-heavy DSL style most production Lisp codebases use — requires
the opposite property.</p>

<p>That is not a missing feature. It is a structural conflict between what the
tool needed to be safe and what it needed to be useful. The safe version does
not cover the use case. The version that covers the use case is not safe in the
way a pre-merge gate must be. No additional engineering time closes that gap,
because the gap is upstream of the engineering — it is in what the language is.</p>

<h2 id="finops">What it cost, and where</h2>

<p>The core logic — the AST walk, the JSON serialisation, the schema documentation,
a working policy-example check verified end to end with real test fixtures —
landed in relatively few iterations. The expensive portion was CI verification:
multiple full GitHub Actions run-and-poll cycles before a clean baseline, a
recurring Lisp environment issue that cost rework each time it resurfaced, and
the single most expensive mistake of the session — a conclusion about a flaky
lint failure reached from local-sandbox testing, merged, then reversed once real
CI evidence contradicted it directly.</p>

<p>That reversal is a clean proxy for the whole cost structure: spend scaled with
the gap between looks-verified-locally and is-verified-against-the-real-target-environment,
not with the difficulty of the Lisp itself.</p>

<h2 id="risk-matrix">The risk matrix, had this continued</h2>

<table>
<thead>
<tr><th>Risk</th><th>Category</th><th>Likelihood</th><th>Impact</th></tr>
</thead>
<tbody>
<tr><td>Silent misanalysis of macro-using code</td><td>Correctness</td><td>High — the default mode</td><td>High</td></tr>
<tr><td>Upstream AST schema drift (Cleavir)</td><td>Dependency coupling</td><td>Medium, ongoing</td><td>Medium-High</td></tr>
<tr><td>Single-implementation lock-in (SBCL internals)</td><td>Portability</td><td>Certain, already true</td><td>Medium</td></tr>
<tr><td>Execution-as-analysis, if load-first is added</td><td>Security / trust model</td><td>Certain, if pursued</td><td>High</td></tr>
<tr><td>Bus factor — solo maintainer</td><td>Organisational</td><td>Certain</td><td>High</td></tr>
<tr><td>CI/local verification drift</td><td>Operational</td><td>Medium</td><td>Low-Medium</td></tr>
<tr><td>Opportunity cost against other commitments</td><td>Strategic</td><td>Certain</td><td>Medium-High</td></tr>
</tbody>
</table>

<p>The pattern across that table is the actual signal: every serious risk is
structural — language design, dependency coupling, trust model — rather than
incidental. That distinction is what separates "needs more engineering time"
from "needs a different approach entirely," and it is why archiving the
repository was the correct call.</p>

<h2 id="the-source">The source</h2>

<p>This was a real working session against a real tool: a Common Lisp AST dumper
built on <a href="https://github.com/s-expressionists/Cleavir">Cleavir</a>'s
CST-to-AST converter, with a documented JSON schema, an
<code>opa test</code>-verified example policy, and two working GitHub Actions,
before the macro-expansion finding closed it out. The repository is archived at
<code>github.com/denzuko/sext</code> — the code that produced this finding is
there if reading it is more useful than taking this account of it.</p>
