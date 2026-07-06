+++
title       = "Lisp Beats Every Modern Language on Token Cost"
date        = "2026-07-05"
draft       = false
description = "Lisp is one of AI's oldest surviving languages, and it is also one of the cheapest to run through a tokenizer. Modern tokenizers punish boilerplate and reward structural minimisation, and Lisp's whitespace agnosticism, implicit returns, and macro-driven DSLs give it a compression ceiling that the ALGOL family — Go, Java, TypeScript, and most of enterprise software besides — cannot structurally reach."
slug        = "26-lisp-token-cost"
keywords    = ["LLM", "tokenization", "Lisp", "token golf", "context window", "performance", "macros", "software architecture"]
tags        = ["infrastructure", "devops", "foss", "selfhosted"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "LLM Context Engineering, Lisp, Software Architecture"
aliases     = ["/26-lisp-token-cost/"]
og_image    = "/assets/og-posts.png"
series      = ["Infrastructure Independence"]

[related_post]
  slug  = "23-lisp-attestation-hackers"
  label = "post 23 covers a related argument about the exact boundary Lisp's extensibility dissolves in attestation pipelines"
+++

# Lisp Beats Every Modern Language on Token Cost

<p>Context windows are priced per token, not per character, and not per line of "readable" code. Modern tokenizers (o200k_base, Claude's tokenizer family) build their vocabularies from corpus frequency. Natural-language words compress into single tokens because English text dominates training corpora. Programming language syntax does not get the same courtesy — every language pays a structural tax, and the size of that tax is a function of how much boilerplate the grammar requires before intent gets expressed.</p>

<p>Go, Java, and TypeScript are three examples of the ALGOL family — the block-structured, procedural lineage that traces back to ALGOL 60 and now covers most of enterprise software, Python and Rust and C included. All three examples here also happen to be brace-delimited, which carries fixed syntactic overhead that has nothing to do with the algorithm. It exists for the compiler, not for the idea being expressed. Lisp's grammar carries almost none of it. S-expressions are closing-paren-terminated rather than keyword-terminated, and whitespace is purely cosmetic. That gives Lisp a lever most of the ALGOL family lacks; a compressible shape of the code and names inside it.</p>

<p>Here we see a measurable payload reduction for anything injected into an LLM context window — RAG snippets, few-shot examples, tool definitions, or code review context.</p>

<p>The same function — sum the squares of the even numbers in a list — looks like this in three mainstream languages.</p>

**Go**

```go
func sumOfSquaresOfEvens(numbers []int) int {
	total := 0
	for _, n := range numbers {
		if n%2 == 0 {
			total += n * n
		}
	}
	return total
}
```

**Java**

```java
public static int sumOfSquaresOfEvens(List<Integer> numbers) {
    int total = 0;
    for (int n : numbers) {
        if (n % 2 == 0) {
            total += n * n;
        }
    }
    return total;
}
```

**TypeScript**

```typescript
const sumOfSquaresOfEvens = (numbers: number[]): number =>
  numbers
    .filter((n) => n % 2 === 0)
    .reduce((total, n) => total + n * n, 0);
```

**C#**

```csharp
public static int SumOfSquaresOfEvens(List<int> numbers) {
    int total = 0;
    foreach (int n in numbers) {
        if (n % 2 == 0) {
            total += n * n;
        }
    }
    return total;
}
```

<p>These four are not arbitrary. TypeScript is now the most-used language on GitHub by contributor count. Java remains the language most Fortune 500 stacks are built on. Go runs the cloud infrastructure most teams already depend on, Docker and Kubernetes among them. C# anchors a comparable share of enterprise .NET shops. If a team is maintaining any of this, the boilerplate tax described here is already being paid in production, not in a benchmark.</p>

<p>That tax shows up the same way in all four, because it comes from the same place: the grammar itself, not the specific vendor or framework sitting on top of it.</p>

<p>Each language carries a fixed overhead tied to its core grammar. A model cannot optimise that overhead away, and it persists whether or not the model needs it to understand the operation.</p>

<p>The equivalent, written as standard, readable Lisp:</p>

```lisp
(defun sum-of-squares-of-evens (numbers)
  (reduce #'+ (mapcar (lambda (n) (* n n))
                       (remove-if-not #'evenp numbers))))
```

<p>Already shorter, and it has no closing braces to speak of — just one paren stack that a tokenizer treats as a handful of single-character tokens rather than multi-character keyword tokens. But this is still readable Lisp; we have yet to apply token golf strategies to it.</p>

```lisp
(defun sumSqEven(ns)(reduce #'+(mapcar(lambda(n)(* n n))(remove-if-not #'evenp ns))))
```

<p>For a brace-family programmer, the structural difference is easier to see than to explain in prose. Every open brace in Go, Java, or TypeScript needs its own matching close brace, scattered wherever the nesting happens to end. Every open paren in Lisp closes the same way, but the closes all land in one run at the point the expression finishes.</p>

<figure style="font-family:monospace;background:#1a1a18;border:1px solid #333;border-radius:4px;padding:1.25rem 1.5rem;margin:1.5rem 0;overflow-x:auto;">
<div style="font-size:.75rem;color:#999;margin-bottom:.75rem;letter-spacing:.03em;">
  <span style="color:#7ec8e3;">■</span> keyword &nbsp;
  <span style="color:#f0ede8;font-weight:700;">■</span> identifier &nbsp;
  <span style="color:#ff8a80;">■</span> body / expression &nbsp;
  <span style="color:#888;">■</span> structural punctuation
</div>
<div style="white-space:pre; line-height:2;">
<span style="color:#7ec8e3;">func</span> <span style="color:#f0ede8;font-weight:700;">sumOfSquaresOfEvens</span><span style="color:#888;">(</span>numbers<span style="color:#888;">) {</span> ... <span style="color:#7ec8e3;">return</span> <span style="color:#ff8a80;">total</span><span style="color:#888;">; }</span>
<span style="color:#888;">(</span><span style="color:#7ec8e3;">defun</span> <span style="color:#f0ede8;font-weight:700;">sumSqEven</span><span style="color:#888;">(</span>ns<span style="color:#888;">)</span> ... <span style="color:#ff8a80;">(reduce #'+ ...)</span><span style="color:#888;">)</span>
</div>
<figcaption style="color:#999;font-size:.85rem;margin-top:1rem;">Same keyword role, same identifier, same body — matched by colour across both lines. The brace-family close (<code>}</code>) pairs with <code>return</code> at the point the block ends. Lisp's close pairs with the whole expression at the end of the line, not with any single keyword.</figcaption>
</figure>

<p>Three changes did the work:</p>

<ol>
<li><strong>camelCase over kebab-case for short-lived identifiers.</strong> <code>sumSqEven</code> is one contiguous token-friendly string; <code>sum-of-squares-of-evens</code> forces the tokenizer to either split on hyphens or burn a longer subword sequence, because BPE vocabularies are trained overwhelmingly on prose and code identifiers that use underscores or camelCase, not hyphens.</li>
<li><strong>Zero non-semantic whitespace.</strong> The Lisp reader does not care whether a space precedes <code>(</code>. Every space removed where the reader can still disambiguate tokens (symbol vs. next open-paren) is a token that no longer needs to be paid for.</li>
<li><strong>Argument name shortening.</strong> <code>numbers</code> becomes <code>ns</code>, <code>n</code> stays <code>n</code>. This has a floor — a name cannot be shortened past what a competent reader needs to hold semantic state in a one-shot injection — but for anything the model is not going to be asked to maintain long-term, short binding names are a legitimate lever within a controlled scope.</li>
</ol>

<p>The compression above is surface-level — it still expresses the full computation. The deeper move is macro-driven DSL design, where a single symbol expands into a structural pattern that would otherwise cost dozens of tokens to spell out by hand. Rust's <code>macro_rules!</code> competes here — a comparable macro definition, and its call site measures tighter than Lisp's for this exact pattern. Where it splits off is scale: the moment a macro needs real AST-level transformation instead of pattern substitution, Rust leaves <code>macro_rules!</code> for procedural macros — a separate system requiring external crate dependencies and full token-stream parsing. Lisp's <code>defmacro</code> never bifurcates; the same mechanism that wrote <code>defpipe</code> above scales to arbitrary compile-time computation without reaching for another toolchain.</p>

```lisp
(defmacro defpipe (name &rest steps)
  "Define NAME as a function that threads its argument through STEPS in order."
  `(defun ,name (x) ,(reduce (lambda (acc step) `(,step ,acc)) steps :initial-value 'x)))

(defpipe normalizeAndScore
  #'string-downcase
  #'string-trim
  #'compute-score)
```

<p><code>defpipe</code> expands into a full <code>defun</code> with a threaded call chain. In a context window, <code>(defpipe normalizeAndScore #'string-downcase #'string-trim #'compute-score)</code> measures at 23 tokens under o200k_base. The equivalent hand-written Go version — a named function with three sequential reassignments and an explicit return — measures at 33. That gap holds at every call site, and it compounds each time the macro appears in a prompt, few-shot example, or tool spec.</p>

<p>Word-based optimisation cannot touch this structural advantage. English-heavy tokenizers already compress common English words into single tokens, but they cannot compress a pattern of code into one token unless the language lets a developer name the pattern and have the compiler expand it back out. Macros are how Lisp does that at the source level, before the tokenizer ever sees the string.</p>

<p>The table below measures five implementations of the same algorithm with a GPT/Claude-class BPE tokenizer.</p>

<table>
<tr><th>Implementation</th><th>Measured tokens (o200k_base)</th><th>Notes</th></tr>
<tr><td>Go (readable)</td><td>50</td><td>Type keywords, braces, explicit return each cost separately</td></tr>
<tr><td>Java (readable)</td><td>59</td><td>Access modifier and generic type erasure syntax adds overhead</td></tr>
<tr><td>C# (readable)</td><td>59</td><td>Near-identical cost to Java; same brace-and-keyword overhead</td></tr>
<tr><td>TypeScript (functional style)</td><td>51</td><td>Fewer braces than Go or Java, but chained method calls add their own overhead — token count lands close to Go's</td></tr>
<tr><td>Lisp (readable, kebab-case)</td><td>39</td><td>No braces; hyphenated name still costs multiple subword tokens</td></tr>
<tr><td>Lisp (token golf, camelCase, zero whitespace)</td><td>27</td><td>Single-token identifier, minimal reader-required whitespace</td></tr>
<tr><td>Lisp (macro-abstracted call site)</td><td>23</td><td>Boilerplate lives in the macro definition, paid once, not per call site</td></tr>
</table>

<p>Python is the honest exception, worth stating plainly. Written idiomatically as a generator expression fed to <code>sum()</code>, the same function measures at 29 tokens — fewer than readable Lisp, and close enough to the token golf version of Lisp that raw token count alone will not settle the argument. Python's syntax carries little of the ALGOL family's brace-and-keyword tax to begin with. What it lacks is the deeper mechanism: a way to name a structural pattern and have the interpreter expand it back out at the grammar level. Python has functions, decorators, and metaclasses, none of which extend syntax the way a macro does.</p>

<p>Due to commonalities in third-generation languages, the pattern holds across domains:</p>

<ul>
<li><strong>Boilerplate tokens are fixed costs.</strong> <code>public static</code>, <code>func</code>, closing braces, and explicit <code>return</code> do not scale with algorithm complexity — they are a flat tax paid on every function regardless of what it does.</li>
<li><strong>Structural tokens are cheaper than keyword tokens.</strong> A tokenizer represents <code>(</code> and <code>)</code> as single characters far more reliably than it represents <code>{</code>, <code>}</code>, and multi-word keywords, because parens appear in math notation and prose far more often than curly braces do, so they are better represented in the base vocabulary.</li>
<li><strong>Macro amortisation only exists where the grammar is extensible.</strong> Every call site of <code>defpipe</code> pays a fraction of the full expansion. Multiply that by the number of times a pattern like this appears across a codebase being fed into a context window as few-shot examples or RAG snippets, and the savings compound linearly with call-site count — something naming discipline alone does not replicate in the ALGOL family, which has no mechanism to name a structural pattern and let the compiler expand it back out.</li>
</ul>

<p>The whitespace and naming compression above is an injection-time transform, and it has no place in a codebase anyone has to maintain. Macro-driven compression is a different story. Dense, macro-heavy Lisp is a documented production tradition, most associated with the "Let Over Lambda" school of macrology — not a novelty of token golf, but a pattern that applies to systems well outside this argument. What changes for context-window injection is the scale of the payoff. A macro that saves a maintainer a few lines of typing saves a model dozens of tokens at every call site, and that gap compounds across a system prompt or RAG corpus in a way it never does across a single human-read file.</p>

<p>A live example sits closer to home than Go or Java. This site's own knowledge base — post, tag, and author facts asserted into a small Prolog engine — ships as a loadable Quicklisp system rather than a REST endpoint. A query like <code>(query '(tag ?s :selfhosted))</code> costs a handful of tokens either way, but the corpus loader that builds the underlying fact base is ordinary boilerplate: fine to write out in full for a human reading the source, worth compressing before it ever rides along in a RAG-retrieved context.</p>

<p>For anyone architecting a system that injects code into a model's context window at scale, token cost is an infrastructure line item, not a style preference — it belongs in the same cost-and-risk model as bandwidth, storage, or compute. The compression ceiling differs by language, and knowing which ceiling is in play is part of the due diligence, not an optimisation to defer until the invoice makes the case.</p>
