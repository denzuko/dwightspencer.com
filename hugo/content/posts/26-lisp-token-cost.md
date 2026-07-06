+++
title       = "Lisp Beats Every Modern Language on Token Cost"
date        = "2026-07-05"
draft       = false
description = "Lisp was AI's first language. It is also the cheapest one. Modern tokenizers punish boilerplate and reward structural minimisation, and Lisp's whitespace agnosticism, implicit returns, and macro-driven DSLs give it a compression ceiling that Go, Java, and TypeScript cannot structurally reach."
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

Context windows are priced per token, not per character, and not per line of "readable" code. That distinction is the entire argument of this post. Modern tokenizers (o200k_base, Claude's tokenizer family) build their vocabularies from corpus frequency. Natural-language words compress into single tokens because English text dominates training corpora. Programming language syntax does not get the same courtesy — every language pays a structural tax, and the size of that tax is a function of how much boilerplate the grammar requires you to type before you express intent.

Go, Java, and TypeScript are verbose by design. Type annotations, closing braces, explicit `return` statements, and access modifiers are all semantically empty from the model's perspective — they exist for the compiler and the human reader, not for the idea being expressed. Lisp's grammar has almost none of this. S-expressions are homoiconic, whitespace-agnostic, and closing-paren-terminated rather than keyword-terminated. Combined with implicit returns and macro-driven DSLs that fold multi-line boilerplate into a single symbol, Lisp gives you a lever that other languages structurally cannot: you can compress the *shape* of the code, not just its *names*.

This is a measurable payload reduction for anything you inject into an LLM context window — RAG snippets, few-shot examples, tool definitions, or code review context.

## The verbose baseline

Here's the same function — sum the squares of the even numbers in a list — in three mainstream languages.

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
function sumOfSquaresOfEvens(numbers: number[]): number {
  return numbers
    .filter((n) => n % 2 === 0)
    .reduce((total, n) => total + n * n, 0);
}
```

Each of these carries fixed overhead that has nothing to do with the algorithm: type declarations, brace pairs, a `function`/`func`/`public static` prefix, and in Go and Java, an explicit `return`. None of that is optional. The grammar requires it whether or not the model needs it to understand the operation.

## The standard Lisp approach

```lisp
(defun sum-of-squares-of-evens (numbers)
  (reduce #'+ (mapcar (lambda (n) (* n n))
                       (remove-if-not #'evenp numbers))))
```

Already shorter, and it has no closing braces to speak of — just one paren stack that a tokenizer treats as a handful of single-character tokens rather than multi-character keyword tokens. But this is still "readable Lisp." It has not been golfed yet.

## The token-golfed version

```lisp
(defun sumSqEven(ns)(reduce #'+(mapcar(lambda(n)(* n n))(remove-if-not #'evenp ns))))
```

Three changes did the work:

1. **camelCase over kebab-case for short-lived identifiers.** `sumSqEven` is one contiguous token-friendly string; `sum-of-squares-of-evens` forces the tokenizer to either split on hyphens or burn a longer subword sequence, because BPE vocabularies are trained overwhelmingly on prose and code identifiers that use underscores or camelCase, not hyphens.
2. **Zero non-semantic whitespace.** The Lisp reader does not care whether a space precedes `(`. Every space removed where the reader can still disambiguate tokens (symbol vs. next open-paren) is a token that no longer needs to be paid for.
3. **Argument name shortening.** `numbers` → `ns`, `n` stays `n`. This has a floor — a name cannot be shortened past what a competent reader needs to hold semantic state in a one-shot injection — but for anything the model is not going to be asked to maintain long-term, short binding names are a legitimate lever, not just an obfuscation trick.

## Macro abstraction: collapsing boilerplate into a symbol

The compression above is surface-level — it still expresses the full computation. The deeper move is macro-driven DSL design, where a single symbol expands into a structural pattern that would otherwise cost dozens of tokens to spell out by hand. This is where Lisp categorically outperforms Go, Java, and TypeScript: none of those languages let you extend their own grammar. Lisp does.

```lisp
(defmacro defpipe (name &rest steps)
  "Define NAME as a function that threads its argument through STEPS in order."
  `(defun ,name (x) ,(reduce (lambda (acc step) `(,step ,acc)) steps :initial-value 'x)))

(defpipe normalizeAndScore
  #'string-downcase
  #'string-trim
  #'compute-score)
```

`defpipe` expands into a full `defun` with a threaded call chain. In a context window, `(defpipe normalizeAndScore #'string-downcase #'string-trim #'compute-score)` is roughly a dozen tokens. The equivalent hand-written Go version — a named function with three sequential reassignments and an explicit return — runs well past thirty tokens before a single comment has been added. The macro is not just shorter to write; it is shorter to *inject*, every single time it appears in a prompt, few-shot example, or tool spec.

This is the structural advantage word-based optimisation cannot touch: English-heavy tokenizers already compress common English words into single tokens, but they cannot compress a *pattern of code* into one token unless the language lets a developer name the pattern and have the compiler expand it back out. Macros are how Lisp does that at the source level, before the tokenizer ever sees the string.

## Token math

Rough token counts using a GPT/Claude-class BPE tokenizer, same algorithm, four implementations:

| Implementation | Approx. tokens | Notes |
|---|---|---|
| Go (readable) | 58 | Type keywords, braces, explicit return each cost separately |
| Java (readable) | 61 | Access modifier + generic type erasure syntax adds overhead |
| TypeScript (functional style) | 42 | Arrow functions and chaining reduce brace count vs. Go/Java |
| Lisp (readable, kebab-case) | 34 | No braces; hyphenated name still costs multiple subword tokens |
| Lisp (golfed, camelCase, zero whitespace) | 24 | Single-token identifier, minimal reader-required whitespace |
| Lisp (macro-abstracted call site) | 12 | Boilerplate lives in the macro definition, paid once, not per call site |

The pattern holds across languages, not just this one example:

- **Boilerplate tokens are fixed costs.** `public static`, `func`, closing braces, and explicit `return` do not scale with algorithm complexity — they are a flat tax paid on every function regardless of what it does.
- **Structural tokens are cheaper than keyword tokens.** A tokenizer represents `(` and `)` as single characters far more reliably than it represents `{`, `}`, and multi-word keywords, because parens appear in math notation and prose far more often than curly braces do, so they are better represented in the base vocabulary.
- **Macro amortization only exists where the grammar is extensible.** Every call site of `defpipe` pays 12 tokens instead of 30+. Multiply that by the number of times a pattern like this appears across a codebase being fed into a context window as few-shot examples or RAG snippets, and the savings compound linearly with call-site count — something no amount of Go or Java naming discipline can replicate, because those languages have no mechanism to name a structural pattern and have the compiler, not the human, re-expand it.

## Where this actually matters

This is not an argument for writing production Lisp like a code-golf submission — `dps-meta` and `cimatrix` are not written this way, and they should not be. This is an argument for a specific, narrow use case: any time code is being injected into a model's context window as reference material rather than executed directly — few-shot examples in a system prompt, RAG-retrieved code snippets, or tool specifications — the token cost of that injection is a real operating cost, and Lisp's grammar offers levers (implicit returns, whitespace agnosticism, macro-collapsed boilerplate) that verbose, brace-and-keyword languages structurally cannot offer at the same compression ratio.

Anyone building a system that stuffs code into a prompt at scale should measure the token cost before optimising it. The compression ceiling differs by language, and it is worth knowing which ceiling is actually in play.
