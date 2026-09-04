+++
title       = "Lab Notebook: NS Macro — What I Built, What Broke, What It Cost"
date        = "2026-09-02"
draft       = false
description = "The full working record behind post 27: raw token figures, prior art source readings, every implementation decision with what I rejected and why, the edge-case taxonomy with the test that covers each one, the exact failure the workaround introduces, and what I would try next."
slug        = "ns-macro-lab"
keywords    = ["common-lisp", "lisp", "macros", "sbcl", "lab", "bmac", "namespace", "defpackage"]
tags        = ["common-lisp", "lisp", "foss", "lab", "research"]
categories  = ["projects"]
schema_type = "TechArticle"
aeo_expertise = "Common Lisp, Macro Systems, Package Management"
aliases     = ["/projects/ns-macro-lab/"]
og_image    = "/assets/og-posts.png"

[related_post]
  slug  = "27-ns-macro-lab"
  label = "post 27 is the public-facing article drawn from this notebook"
+++

# Lab Notebook: NS Macro — What I Built, What Broke, What It Cost

<p><strong>Repo:</strong> <a href="https://github.com/denzuko/ns">github.com/denzuko/ns</a> &nbsp;|&nbsp; <strong>Status:</strong> v0.1.0, thesis disproven at full scope &nbsp;|&nbsp; <strong>Codebase measured:</strong> eleven production repositories, 52 source files, 44 namespace declarations</p>

<h2 id="why">Why This Lab Existed</h2>

<p>Every Common Lisp source file that declares a namespace has two mandatory forms at the top. <code>defpackage</code> creates the package. <code>in-package</code> enters it. Both are required. The programmer states the package name twice. If you inject a project's namespace structure as few-shot context into a code generation session, both forms go in. An agent reading the namespace index to understand what a project exports pays for both on every declaration, every session, compounding over the life of the project.</p>

<p>The question was whether a single macro could eliminate the second form without changing anything visible to the programmer, the compiler, or any tooling that reads source. Not a convenience wrapper. An actual elimination: one form where two were required.</p>

<h2 id="prior-art">What I Read Before Writing Anything</h2>

<p>I do not write code against a guessed API. These are the libraries I read in source before implementation began, in the order I read them, with what each reading produced.</p>

<p><strong>defpackage-plus</strong> (rpav, Quicklisp, MIT — <code>ql:quickload :defpackage-plus</code>). Closest prior art. Adds <code>:inherit-from</code> (selective re-export of another package's symbols), <code>:documentation</code> at the top-level clause, and <code>:import-from</code> shorthand. Idempotency via <code>ensure-package</code>, which catches and handles the continuable redefinition error on re-evaluation.</p>

<p>Reading the source produced two things before I wrote a line. First: the <code>eval-when</code> requirement. <code>defpackage-plus</code> wraps its expansion in <code>eval-when (:compile-toplevel :load-toplevel :execute)</code>. I had planned a plain <code>progn</code>. Reading the source told me why that would fail: the compiler reads a file in its entirety before executing any of it, so a package created inside a <code>progn</code> does not exist when the compiler processes symbols from that package later in the same file. Those symbols get interned into the wrong package at compile time. The error surfaces at runtime. The <code>eval-when</code> requirement was identified before any test could find it.</p>

<p>Second: what <code>defpackage-plus</code> does not do. <code>in-package</code> remains a separate required form in every example and every documentation section. The gap I was trying to close was confirmed by reading the prior art, not assumed.</p>

<p><strong>named-readtables</strong> (Attila Lendvai, Quicklisp). Provides reader syntax namespacing via <code>in-readtable</code>. Not directly applicable to eliminating <code>in-package</code>, but relevant to the Open Question below. A reader macro could in principle make <code>ns</code> available at read time without any package system manipulation. <code>named-readtables</code> is the standard mechanism if that path is pursued.</p>

<p><strong>package-inferred-system</strong> (ASDF built-in, Graham Wideman). Eliminates both <code>defpackage</code> and <code>in-package</code> by inferring package structure from file hierarchy. Requires one file per package, with file path matching package name by convention. Disqualified for the use case: the eleven-repo codebase being measured has arbitrary package structures across files; enforcing a layout convention is a larger change than the ceremony being eliminated.</p>

<h2 id="raw-numbers">Raw Token Figures</h2>

<p>Tokeniser: <code>tiktoken</code>, <code>o200k_base</code> vocabulary. All figures from the actual codebase — no synthetic projections.</p>

<p>The codebase: eight dapla-deploy repositories (find, watch, meet, feed, save, burn, link, support), plus <code>bknr.hashkv</code>, <code>bknr.ttl</code>, <code>sunny-side</code>. Eleven repositories, 52 source files, 44 namespace declarations at the time of measurement.</p>

<table>
<tr><th>What was measured</th><th>defpackage + in-package</th><th>ns macro</th><th>Δ tokens</th><th>Δ %</th></tr>
<tr><td>All 44 declarations, full text</td><td>4,913</td><td>4,420</td><td>−493</td><td>−10%</td></tr>
<tr><td>Full namespace index, few-shot format</td><td>1,470</td><td>823</td><td>−647</td><td>−44%</td></tr>
<tr><td>One typical declaration</td><td>44</td><td>37</td><td>−7</td><td>−16%</td></tr>
<tr><td>Macro expansion overhead (compiler only)</td><td>44</td><td>89</td><td>+45</td><td>invisible to source readers</td></tr>
</table>

<p>The 44% figure deserves explanation because it is larger than the source-level saving. The few-shot namespace index is a condensed form — package name plus exported symbol list, stripped of internal documentation and clause boilerplate. In that condensed form, the <code>in-package</code> form is a proportionally larger share of the total. Eliminating it from 44 declarations produces a 44% reduction in the index. That is the number that compounds across code generation sessions: every session that injects the namespace index as context pays it, or does not.</p>

<p>The expansion overhead of 45 tokens is documented because leaving it out would misrepresent the complete picture. The compiler pays it once at first load. It does not appear in source, in any context window injection, or in any tooling output that reads source rather than compiled artifacts.</p>

<h2 id="compile-time">Compile-Time Figures</h2>

<p>Bulk averages over 10,000 SBCL iterations at one-microsecond clock resolution. Two paths: first load (package absent) and reload (package already present in the image).</p>

<table>
<tr><th>Path</th><th>defpackage + in-package</th><th>ns macro</th><th>Result</th></tr>
<tr><td>First load</td><td>0.008 µs/call</td><td>0.006 µs/call</td><td>1.24× faster</td></tr>
<tr><td>Reload</td><td>0.001 µs/call</td><td>~0.000 µs/call</td><td>guard exits before package system</td></tr>
</table>

<p>The first-load result surprised me. The macro expansion is more bytecode than the raw pair, yet it is faster because the <code>unless (find-package name)</code> guard short-circuits before the package system is consulted. On reload, the guard detects the package is already current and exits immediately — it never calls <code>defpackage</code> or <code>in-package</code> at all. The standard pair calls <code>handler-bind</code> machinery on every re-evaluation. In a SWANK-based development loop where a file is re-evaluated dozens of times per hour, this is not a trivial difference.</p>

<h2 id="decisions">Every Decision, With What I Rejected</h2>

<p><strong>eval-when wrapper — not progn.</strong> Covered above. <code>progn</code> produces wrong-package interning at compile time. <code>eval-when (:compile-toplevel :load-toplevel :execute)</code> is the correct wrapper. Identified from <code>defpackage-plus</code> source before any test could surface it.</p>

<p><strong>Guard clauses — not handler-bind.</strong> The standard idempotency approach is a <code>handler-bind</code> that swallows the continuable redefinition error <code>defpackage</code> signals on re-evaluation. I rejected this because it conceals the conflict and removes the restart option from practitioners who are managing a deliberate conflict in a live SWANK session. Two <code>unless</code> guard clauses prevent the conflict instead of hiding it. First guard: <code>(unless (find-package name) (defpackage ...))</code> — skips creation when the package exists. Second guard: <code>(unless (eq *package* (find-package name)) (in-package ...))</code> — skips entry when already current.</p>

<p>Trade-off: clause changes on reload are silently ignored. If you change an <code>:export</code> clause and re-evaluate the file, the export list does not update. The resolution is <code>(delete-package :my.pkg)</code> before re-evaluating. This is the same constraint <code>defpackage</code> itself has in SWANK workflows — the macro does not introduce it, it inherits it.</p>

<p><strong>Default (:use :cl) — not strict passthrough.</strong> The original implementation was a strict passthrough: whatever clauses you gave, they went to <code>defpackage</code> verbatim. No defaults. A bare <code>(ns :my.pkg)</code> produced a package with no standard symbols. I shipped that version and the first real consumer — <code>denzuko/ns-example</code>, hand-written outside the library — immediately failed with <code>UNDEFINED-FUNCTION: DEFUN</code>. Every practitioner who writes bare <code>defpackage</code> adds <code>(:use :cl)</code>. The macro failing silently on the same omission is a usability defect, not a feature. The default was added after that failure.</p>

<p>The guard: <code>(unless (member :use clauses :key #'car) (push '(:use #:cl) clauses))</code>. If any <code>:use</code> clause is present, the default is suppressed entirely. Explicit overrides implicit. A bare <code>(:use)</code> with an empty list produces a package with no standard symbols — the programmer stated explicitly that they wanted no use list.</p>

<p><strong>cond — not if.</strong> The default clause logic uses <code>cond</code>. The org-wide standard for Common Lisp code in this organisation is combinatoric forms first: <code>unless</code>/<code>when</code>/<code>cond</code> instead of <code>if</code>. <code>if</code> names two branches explicitly and reads as a jump. <code>cond</code> expresses a case analysis. A gate script scans for bare <code>(if ...)</code> forms and fails the commit if found. This is enforced on every source and test file before push.</p>

<p><strong>Shadow-import into cl-user — not use-package.</strong> To make <code>ns</code> available unqualified after <code>(ql:quickload :ns)</code>, the system load time code does <code>(import 'ns:ns (find-package '#:cl-user))</code> and <code>(export 'ns:ns (find-package '#:cl-user))</code>. This is a shadow-import — it puts the single symbol <code>ns</code> into <code>cl-user</code>'s external namespace without adding the entire <code>:ns</code> package to <code>cl-user</code>'s use list. <code>use-package :ns</code> would have added everything in the <code>:ns</code> package, which is unnecessary and polluting. Shadow-import adds the minimum required.</p>

<h2 id="edge-cases">Edge-Case Taxonomy</h2>

<p>Each case is documented in <code>src/ns.lisp</code> as part of the macro docstring, and covered by a named test in <code>t/ns.lisp</code>. The test name is given so you can read it directly.</p>

<p><strong>Compile-time existence.</strong> A package declared with <code>ns</code> is in the image before the compiler advances past the macro form. Provider packages appear in the image before any consumer file that uses them is compiled. Test: <code>ns-package-exists-after-form</code>. This is the property the <code>eval-when</code> wrapper exists to guarantee.</p>

<p><strong>Hot-reload idempotency (package exists).</strong> Re-evaluating a file with <code>(ns :my.pkg ...)</code> when <code>:my.pkg</code> already exists in the image produces no error and no side effects. The first guard clause exits before touching the package system. Test: <code>ns-idempotent-when-package-exists</code>.</p>

<p><strong>Hot-reload idempotency (already current).</strong> Re-evaluating when <code>*PACKAGE*</code> is already <code>:my.pkg</code> skips the <code>in-package</code> call. Test: <code>ns-idempotent-when-already-current</code>. Combined with the above: both guard clauses are exercised independently.</p>

<p><strong>Clause changes on reload silently ignored.</strong> A changed <code>:documentation</code> clause does not update after reload when the package already exists. This is the documented trade-off of the guard clause approach. Test: <code>ns-clause-changes-ignored-on-reload</code>. The test asserts that the documentation remains nil after a reload with a documentation clause — confirming the behaviour is what it claims to be, not an accident.</p>

<p><strong>Symbol conflicts via :use.</strong> Two packages that both export the same symbol, both listed in a <code>:use</code> clause, produce the standard <code>defpackage</code> conflict error. The macro does not handle this differently. Test: <code>ns-symbol-conflict-via-use-signals-error</code>. Resolution: <code>:shadow</code> or <code>:shadowing-import-from</code>.</p>

<p><strong>Bare keyword clause syntax fails.</strong> The <code>ros init</code> template generates <code>(ns :my.pkg :export #:main)</code> — bare keywords, not list forms. This fails at compile time with <code>:EXPORT is not of type LIST</code>. The correct form is <code>(:export #:main)</code>. Test: <code>ns-bare-keyword-clauses-signal-error</code>. This was discovered when the first Roswell script consumer tried to use the macro.</p>

<p><strong>Downstream ASDF consumer.</strong> Loading a project file via <code>--load</code> without first loading <code>ns</code> fails. <code>--load</code> compiles and loads the file directly without resolving ASDF dependencies. The shadow-import into <code>cl-user</code> only runs when the <code>ns</code> system is loaded. The correct path: <code>qlot exec sbcl --eval '(ql:quickload :ns)' --load ./file.lisp</code> or <code>qlot exec sbcl --eval '(asdf:load-system :my-project)'</code>. Test: <code>ns-asdf-depends-on-loads-ns-first</code>.</p>

<h2 id="thesis">What Broke the Thesis</h2>

<p>The original thesis: <code>(ns name clause*)</code>, called unqualified, replaces <code>defpackage</code> + <code>in-package</code> throughout any file. The thesis failed at the first real downstream consumer.</p>

<p>The failure: in a multi-namespace file, the first <code>(ns :pkg-a ...)</code> call switches <code>*PACKAGE*</code> to <code>:pkg-a</code>. The second call — <code>(ns :pkg-b ...)</code> — is read in <code>:pkg-a</code>'s context, where <code>ns</code> is undefined. Error: <code>UNDEFINED-FUNCTION: PKG-A::NS</code>.</p>

<p>The root cause is in the ANSI standard. The <code>common-lisp</code> package is locked. No external code may add symbols to it. Every package that does <code>(:use :cl)</code> inherits its symbols — but <code>ns</code> cannot be added to <code>cl</code>, so it cannot be inherited by every package automatically. The shadow-import into <code>cl-user</code> covers the starting package, but every package the macro creates is a new namespace that has no knowledge of <code>ns</code> unless told explicitly.</p>

<p>This failure was deterministic and reproducible. The library's own spec suite did not catch it because the specs ran inside <code>ns-tests</code>, which uses <code>ns</code>. A consumer operating from a package that does not use <code>ns</code> was required to surface it. That is what <code>denzuko/ns-example</code> was for, and that is why a downstream consumer test running outside the library's own package structure belongs in the spec suite from the beginning.</p>

<h2 id="workaround">The Workaround and Its Cost</h2>

<p>The current v0.1.0 release adds two forms to every macro expansion:</p>

```lisp
(import 'ns:ns (find-package ',name))
(export 'ns:ns (find-package ',name))
```

<p>Every package the macro creates gets <code>ns</code> imported and exported. The symbol propagates forward: <code>(ns :pkg-a ...)</code> creates <code>:pkg-a</code> with <code>ns</code> in its external symbol list, so the next <code>(ns :pkg-b ...)</code> call finds <code>ns</code> accessible and succeeds.</p>

<p>The cost: every package the macro creates carries <code>ns</code> as an external symbol the programmer never declared. A third package that does <code>(:use :pkg-a :pkg-b)</code> — where both <code>:pkg-a</code> and <code>:pkg-b</code> were created by <code>ns</code> — inherits the <code>ns</code> symbol from both and gets a conflict error on <code>ns</code> itself.</p>

<p>The workaround is effective for projects where namespace packages are not used together. It breaks when they are. The failure it introduces is quieter than the failure it resolves — it does not appear until a <code>:use</code> relationship between two <code>ns</code>-created packages is established. That is a later and harder-to-diagnose failure than the original <code>UNDEFINED-FUNCTION</code> at load time.</p>

<h2 id="claude-md">The CLAUDE.md Text to Paste</h2>

<p>A dependency on <code>ns</code> in <code>:depends-on</code> does not change what an LLM emits. Paste this into the consuming project's <code>CLAUDE.md</code>:</p>

```markdown
## Namespace Convention

This project uses the `ns` macro from the `ns` ASDF system.
Use `ns` for all package declarations. Do not emit `defpackage` + `in-package` pairs.

Correct:

    (ns #:my.package
      (:use #:cl)
      (:export #:my-fn))

Do not write:

    (defpackage #:my.package
      (:use #:cl)
      (:export #:my-fn))
    (in-package #:my.package)

Clause syntax is standard defpackage, verbatim.
The ns system is already in :depends-on — do not add (ql:quickload :ns).
```

<p>Cost: approximately 180 tokens per session, loaded once at session start. Breakeven against the 44% few-shot reduction: 16 namespace declarations generated in that session. The eleven-repo codebase has 44.</p>

<h2 id="gate-scripts">Gate Scripts in Use</h2>

<p>Three gate scripts run before every commit in this org's Lisp repositories. All three are in <code>denzuko/dwightspencer.com</code> on the <code>gate-hollow-check</code> branch under <code>scripts/</code>. They should be in <code>dps-meta</code> — that migration is a known open item.</p>

<p><strong>Escape-aware paren check.</strong> A Python script that strips comments and string literals (using a proper state machine, not regex) before counting parentheses. Naive regex paren counters flag parentheses inside strings. This one does not. Fails the commit on any imbalance.</p>

<p><strong>blog-voice-check.py.</strong> Catches mechanical voice violations: contractions, forbidden phrases, pundit-contrast constructions, intensifier padding, American spellings, rhetorical questions, structural headers where none belong, self-referential process narration. Runs on all Lisp source docstrings and prose content. The checks were established from the actual published corpus — not assumed, measured.</p>

<p><strong>Bare (if ...) scan.</strong> Scans for bare <code>(if ...)</code> forms in source and test files. An <code>if</code> form where <code>unless</code>, <code>when</code>, or <code>cond</code> is correct fails the commit. This enforces the org-wide combinatoric logic standard.</p>

<h2 id="next">What I Would Try Next</h2>

<p>The open question is whether the original thesis can be satisfied without the workaround's side effects on package export lists. Three paths, in the order I would try them.</p>

<p><strong>Import without export.</strong> The workaround currently both imports and exports <code>ns</code> into every created package. The export is what causes the conflict when two <code>ns</code>-created packages are used together. Import without export makes <code>ns</code> internal to the created package — accessible unqualified within that package, but not inherited by packages that use it. This resolves the conflict. The risk: an internal symbol in a package is not visible to the compiler when it reads a file in that package's context, depending on how the file is compiled. I have not tested whether this path closes the original failure or opens a new one. It is the first thing to try.</p>

<p><strong>Reader macro via named-readtables.</strong> A reader macro that dispatches on a dedicated character could make <code>ns</code> available at read time without any package-system manipulation. The cost: readtable mutation. A named readtable (via <code>named-readtables</code>) scopes the change to files that opt in with <code>in-readtable</code>. That reintroduces a single form at the top of each file — which trades the <code>in-package</code> ceremony for an <code>in-readtable</code> ceremony. Whether that is a net improvement depends on whether the token cost of <code>in-readtable</code> is lower than <code>in-package</code>, and whether tooling that reads the file understands the readtable extension.</p>

<p><strong>Package-local nicknames for ns itself.</strong> A consuming project could declare a package-local nickname that makes <code>ns</code> accessible under a shorter or more convenient name within all its packages. This is purely a consumer-side mechanism — it does not require any change to the library. It also does not solve the root problem for a practitioner who has not read this notebook.</p>

<p>This lab established the boundary and the reason for it. Subsequent work can start from a known position.</p>
