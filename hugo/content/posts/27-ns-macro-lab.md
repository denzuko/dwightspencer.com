+++
title       = "The Ceremony Tax: Measurement, Macro, Constraint"
date        = "2026-09-02"
draft       = false
description = "A lab that set out to eliminate Common Lisp's defpackage + in-package pair. The token measurements are real. The macro works within documented constraints. The original thesis was disproven, and that is the finding."
slug        = "27-ns-macro-lab"
keywords    = ["common-lisp", "lisp", "macros", "sbcl", "packaging", "namespace", "defpackage", "token-cost"]
tags        = ["common-lisp", "lisp", "foss", "lab"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Common Lisp, Macro Systems, Package Management"
aliases     = ["/27-ns-macro-lab/"]
og_image    = "/assets/og-posts.png"

[related_post]
  slug  = "26-lisp-token-cost"
  label = "post 26 measured the token tax of boilerplate grammar across languages — this lab applies the same methodology to the Common Lisp namespace declaration protocol"
+++

# The Ceremony Tax: Measurement, Macro, Constraint

<p>LLM context windows are priced per token. Every form a language grammar imposes before intent can be expressed contributes to that cost structurally — no word-level compression recovers it, because the grammar runs before compression does. Common Lisp requires two forms to declare and enter a namespace. <code>defpackage</code> creates the package with its full clause set. <code>in-package</code> enters it. Both are mandatory on every source file that declares a namespace. The programmer states the package name twice.</p>

<p>This lab measured that cost against 52 source files and 44 namespace declarations across eleven production repositories, built a macro to eliminate it, and found a constraint that limits where the elimination holds cleanly. The tokeniser throughout is o200k_base. All figures come from the actual codebase.</p>

<table>
<tr><th>Measurement</th><th>defpackage + in-package</th><th>ns macro</th><th>Saving</th><th>Reduction</th></tr>
<tr><td>44 real org declarations (source)</td><td>4,913 tokens</td><td>4,420 tokens</td><td>493</td><td>10%</td></tr>
<tr><td>Full org namespace index (few-shot)</td><td>1,470 tokens</td><td>823 tokens</td><td>647</td><td>44%</td></tr>
<tr><td>Single declaration (typical)</td><td>44 tokens</td><td>37 tokens</td><td>7</td><td>16%</td></tr>
<tr><td>ns expansion overhead (compiler, once)</td><td>44 tokens</td><td>89 tokens</td><td>-45</td><td>invisible to tooling</td></tr>
</table>

<p>The 44% reduction on the namespace index is the figure that motivated the work. When a code generation tool injects a project's namespace structure as few-shot context, the standard pair costs 44% more tokens to express the same structural information. The expansion overhead of 45 tokens is documented because the complete picture matters: the compiler pays it once at load time and it does not appear in source that any downstream tool consumes.</p>

<p>The macro is <code>denzuko/ns</code>. Clause syntax is standard <code>defpackage</code>, passed through verbatim. <code>in-package</code> folds into the expansion. The default, when no <code>:use</code> clause is given, is <code>(:use :cl)</code> — matching what every practitioner writes when using <code>defpackage</code> directly. Three implementation constraints shaped the design: <code>eval-when (:compile-toplevel :load-toplevel :execute)</code> ensures the package exists before the compiler processes subsequent symbols in the same file; two <code>unless</code> guard clauses handle idempotency in a live image without swallowing the continuable redefinition error; and the expansion overhead — real and documented — is borne once by the compiler, not by the programmer or any consuming tool.</p>

<p>The original thesis was that <code>(ns name clause*)</code>, called unqualified, would replace the pair throughout a multi-namespace file. The thesis did not hold at that scope. The Common Lisp standard locks the <code>common-lisp</code> package: no external code may add symbols to it. The macro shadow-imports <code>ns</code> into <code>cl-user</code> at load time, which covers interactive use and single-namespace files. In a multi-namespace file, the first <code>(ns :pkg-a ...)</code> call switches <code>*PACKAGE*</code> away from <code>cl-user</code>. The second call — <code>(ns :pkg-b ...)</code> — fails at read time with <code>UNDEFINED-FUNCTION</code>, because the newly active package has no knowledge of <code>ns</code>.</p>

<p>The current release works around this by importing and exporting <code>ns</code> into every package the macro creates, so the symbol propagates forward through a file. The unqualified form works. The cost of the workaround is that every package the macro creates carries <code>ns</code> as an external symbol the programmer never declared. A third package that uses two <code>ns</code>-created packages inherits the <code>ns</code> symbol from both and gets a conflict. The workaround resolves the immediate failure and introduces a quieter one.</p>

<p>The measurements are real and repeatable. The 44% reduction on namespace index injections holds. The macro works within documented constraints. The constraint is a genuine property of the Common Lisp package system: a macro that tries to extend symbol vocabulary across compilation unit boundaries runs into the same wall any such macro hits. The original thesis — clean, transparent, symmetric replacement of the pair throughout any file — was disproven by the first real downstream consumer, and that is the finding.</p>

<p>A disproven thesis documents a real boundary. The work is reproducible, the constraint is identifiable, and the measurements are independent of whether the thesis holds. The next question — whether a reader macro, a named readtable, or a different propagation strategy can satisfy the original thesis cleanly — is open.</p>

<p>Repo: <code>github.com/denzuko/ns</code>, <code>develop</code> branch. Full lab report, prior art, and edge-case taxonomy: <a href="/projects/ns-macro-lab">projects/ns-macro-lab</a>.</p>
