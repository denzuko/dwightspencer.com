---
layout: post
title: "Rules, Types, and Glue: A Multi-Paradigm Architecture for Game Simulation"
date: 2026-05-22T00:00:00-05:00
author: Dwight Spencer
orcid: "0009-0001-0066-4646"
description: >
  A technical evaluation of Prolog, ML-style types (Coalton DSL), and Common
  Lisp as a layered architecture for game simulation engines. Benchmarks across
  SBCL and ECL, portability findings, and honest conclusions about where each
  paradigm earns its place and where the boundaries between them create friction.
keywords:
  - Prolog
  - Common Lisp
  - Coalton
  - game engine architecture
  - multi-paradigm programming
  - knowledge representation
  - simulation
  - SBCL
  - ECL
  - domain-specific languages
tags:
  - architecture
  - lisp
  - prolog
  - gamedev
  - systems
categories:
  - Technical
section: articles
canonical: "https://dwightaspencer.com/posts/03-rules-types-and-glue/"
schema_type: TechArticle
---

## Abstract

We describe a domain exercise that evaluates three programming paradigms as
layers in a game simulation engine: Prolog for rule-based knowledge, an
ML-style type system (Coalton DSL) for typed computation, and Common Lisp as
glue and tooling. The domain is a Gen-I Pokémon Yellow battle simulator —
chosen for its well-specified rules, enumerable state space, and rich catalog
data. We report benchmark results across SBCL (native compilation) and ECL
(C-native and bytecode), document where each paradigm excels, and give honest
findings about the friction at language boundaries. The central conclusion is
that Prolog's backward-chaining over ground facts is genuinely well-suited to
rule-driven game knowledge; that an ML type layer adds real value at internal
interfaces but creates a portability ceiling; and that Common Lisp's role is
strongest at the metalevel — tooling, codegen, and REPL-driven development —
rather than as a runtime layer competing with C.

Source: [github.com/denzuko/ml-prolog-pokemon](https://github.com/denzuko/ml-prolog-pokemon)

---

## 1. Introduction

Game simulation engines solve a recurring architectural problem: a large,
structured body of rules (damage formulas, type interactions, status effects,
item behaviors) must be applied efficiently to a dynamic state that changes
every frame or turn. The naive approach — encode everything as C structs and
switch statements — is fast but brittle. Rules are scattered across source
files, adding a new mechanic requires touching multiple sites, and testing
rule correctness in isolation is difficult.

The alternative explored here is layered paradigm specialisation: let each
layer do what it does best, with explicit boundaries between them.

This is not a new idea. Logic programming for game AI has a lineage stretching
from PROLOG-based adventure game engines in the 1980s through modern
Datalog-based query systems in commercial engines. What is less explored is
the interaction between a Prolog knowledge layer and a typed functional layer
in the same runtime, and the performance and portability consequences of that
interaction.

We chose Pokémon Gen-I Yellow as the domain because:

1. The type-effectiveness chart (17 types, ~72 non-trivial matchups) is a
   canonical example of a relational knowledge base — a set of ground facts
   with derived rules.
2. The battle mechanics are formally specified and well-documented, giving us
   a ground truth against which to test correctness.
3. The state space is small enough that exhaustive testing is practical.
4. The domain is familiar enough that readers can evaluate architectural
   decisions without domain-specific knowledge.

The exercise produced a working simulator: 65 functional tests passing at
100%, 11 performance regression tests, and benchmarks across two Common Lisp
implementations. We report what we found.

---

## 2. Architecture

The system is structured as three layers with strict ownership boundaries.

```
┌─────────────────────────────────────────────────────────────┐
│  PROLOG  (logic-engine.lisp + catalog.lisp)                 │
│  Rules: type chart · item effects · team validity           │
│  Facts: 151 Pokémon · 85 moves · 19 items · all trainers   │
│  Queries: suggest-badge-team · usable-item-p · team-valid-p │
└──────────────────────────┬──────────────────────────────────┘
                           │  get-logic-multiplier
                           │  db-prove-first / db-prove-all
┌──────────────────────────▼──────────────────────────────────┐
│  COALTON  (types.ct)                                        │
│  ADTs: PkmnType · Status · Move · Pokemon · BattleOutcome   │
│  Pure: calculate-damage · apply-end-of-turn · run-turn      │
│  Pure: simulate-battle (recursive, typed turn counter)      │
│  Escape: lookup-multiplier → one lisp form → Prolog query   │
└──────────────────────────┬──────────────────────────────────┘
                           │  plist→Pokemon · match-outcome
┌──────────────────────────▼──────────────────────────────────┐
│  CL GLUE  (simulator.lisp — ~80 lines)                      │
│  Bridges catalog plists to Coalton values                   │
│  Entry points: run-simulation · run-badge-battle            │
└─────────────────────────────────────────────────────────────┘
```

The boundary rule is explicit: **Prolog owns facts and rules; Coalton owns
typed computation; CL owns nothing except bridging.** If `simulator.lisp`
acquires logic, something has crossed the wrong boundary.

### 2.1 The Prolog Layer

The knowledge base is a `prolog-db` struct (a hash table keyed by functor)
populated by `make-pokemon-kb`. Fact schemas:

```prolog
(pokemon   name num type1 type2 base-hp base-atk base-def base-spc base-spd)
(move      name type category power accuracy pp effect)
(item      name symbol description)
(gym-party gym  slot species level m1 m2 m3 m4)
(effectiveness  atk-type def-type result)   ; super-effective | not-very-effective
(immune         atk-type def-type)
(counters       atk-type def-type)          ; materialised from effectiveness
```

All atoms are normalised to Common Lisp keywords on `db-assert` — `:fire`
not `POKEMON-LOGIC::FIRE`. This eliminates cross-package symbol mismatch
entirely.

A note on the Prolog evaluator: we evaluated `wmannis/cl-gambol` first. It
has a known infinite-loop bug in SBCL 2.x headless environments: the
continuation-passing search causes `unify` to recurse infinitely via SBCL's
tail-call optimiser. The bug was confirmed via disassembly and call-depth
tracing. We replaced it with a self-contained 60-line backward-chaining
interpreter with correct symmetric unification. The `cl-gambol` ASD
dependency is retained as an architectural statement; the runtime uses our
evaluator.

### 2.2 The Coalton Layer

Coalton is an ML-style type system DSL for Common Lisp. It compiles to CL
via a macro-expansion pipeline and provides Hindley-Milner type inference,
algebraic data types, and pattern matching. The battle computation is fully
typed:

```
BattleOutcome = Victor Pokemon | Draw | Ongoing Pokemon Pokemon

simulate-battle :
  PrologDb → Pokemon → Move → Pokemon → Move → IFix → BattleOutcome
```

The `Victor | Draw | Ongoing` sum type means the compiler enforces
exhaustiveness on every match — the turn loop cannot silently drop a case.
This caught a real bug during development: an early version of the loop
body used a CL `cond` that had no `draw` arm.

The single impure call site is `lookup-multiplier`:

```lisp
(define (lookup-multiplier kb atk-t def-t)
  (lisp Fraction (kb atk-t def-t)
    (pokemon-logic:multiplier->ratio
      (pokemon-logic:get-logic-multiplier
        kb
        (cl:intern (pokemon-sim::type->string atk-t) "KEYWORD")
        (cl:intern (pokemon-sim::type->string def-t) "KEYWORD")))))
```

The `lisp` form is Coalton's controlled escape hatch. Every use site is
documented with the reason pure Coalton cannot express it. There is exactly
one in the codebase.

### 2.3 The CL Glue Layer

`simulator.lisp` is ~80 lines with no logic. It bridges catalog data
(plists) to Coalton values, exposes `run-simulation` and `run-badge-battle`
as human-readable entry points, and defines the `match-outcome` macro for
dispatching on `BattleOutcome` from outside the Coalton package boundary.

The `match-outcome` macro required three iterations due to cross-package
symbol resolution: `BattleOutcome/Victor`'s slot is `POKEMON-SIM::|_0|`
(Coalton's generated name), but the binding name `winner` in the macro
expansion resolves to the caller's package. The final form accepts keyword
arguments (`:winner w`) to let the caller control the binding name.

---

## 3. Layer-by-Layer Analysis

### 3.1 Prolog: What Worked

The type-effectiveness chart as Prolog facts is the most natural
representation we considered. The advisor query —

```lisp
(defun suggest-badge-team (kb enemy-types)
  (let* ((all-types '(:normal :fire :water ...))
         (scored
           (loop for cand in all-types
                 for score := (count-if (lambda (ety)
                                          (eq :super-effective
                                              (get-logic-multiplier kb cand ety)))
                                        enemy-types)
                 when (plusp score) collect (cons cand score))))
    (mapcar #'car (sort scored #'> :key #'cdr))))
```

— is four lines of logic on top of the Prolog query. In a C implementation
this is a lookup table, a scoring loop, and a sort — more code, harder to
change. When the Gen-II type chart added Steel and Dark, only new `effectiveness`
facts need asserting; the query logic is unchanged.

The team validity check (`team-valid-p`) is similarly clean: a set of Prolog
rules for 1–6 member teams with uniqueness enforced via a `lisp` hook calling
`remove-duplicates`. Expressing this as Prolog rules keeps it in the same
knowledge layer as the type chart rather than scattering it into a separate
validation module.

Item interactions — `item-cures-status`, `item-restores-hp`, `item-revives`,
`item-boosts-stat` — are Prolog facts. `apply-item-effect` queries them and
applies effects in CL. When a new item is added, one fact is asserted; no
recompilation.

### 3.2 Prolog: What Didn't

**Performance at the Prolog/Coalton boundary.** `lookup-multiplier` takes
~7 µs per call on SBCL — one `intern` call plus one hash-table probe plus
one ecase. For turn-based simulation this is fine; for real-time simulation
where damage is recalculated hundreds of times per second, the boundary cost
accumulates. The mitigation is caching: for a given `(atk-type, def-type)`
pair the result is deterministic and can be pre-computed into a 17×17 integer
matrix at kb-construction time, reducing per-call cost to a single array
lookup.

**The gambol bug.** A production Prolog evaluator embedded in a CL system
should be expected to work. `wmannis/cl-gambol` does not work in SBCL 2.x
headless, and the bug (TCO interaction in CPS search) is not straightforward
to fix without understanding the full continuation stack. Teams evaluating
this architecture should use `SWI-Prolog`'s `libswipl` (which has a stable C
API and is actively maintained) or write a domain-specific evaluator as we
did.

### 3.3 Coalton: What Worked

**Exhaustiveness at sum-type boundaries.** The `BattleOutcome` type made the
turn loop correct by construction. The `Victor | Draw | Ongoing` variant is
small enough that the exhaustiveness check is more valuable than the typing
overhead — you genuinely cannot write a loop that forgets to handle the draw
case.

**Catching type errors early.** During development, `calculate-damage` was
initially declared to return `UFix` but the body computed `Integer` (from
`floor`). Coalton caught this at compile time. In pure CL this would be a
runtime type error surfacing only when the result is passed to `take-damage`.

**Self-documenting boundaries.** The `lisp` escape is syntactically visible.
Any reviewer reading `types.ct` immediately sees where the type system
boundary is and why it exists. There is no invisible hole.

### 3.4 Coalton: What Didn't

**SBCL-only.** Coalton's readmacro (`READ-COALTON-TOPLEVEL-OPEN-PAREN`)
returns two values, which SBCL permits as an extension but the CL standard
does not require. ECL rejects it with a compile-time error. This is not a
configuration problem; it is a deliberate design choice by the Coalton
authors, who officially target SBCL. Any architecture that might need ECL
(embedded in a C game engine), ABCL (JVM target), or CCL (macOS) cannot rely
on Coalton.

**Codegen fragility at the `lisp` escape.** Coalton's code generator
sometimes mangles variable names captured in `lisp` forms: `def-type` became
`DEF-TYPE-45` in the generated defun, causing an "illegal function call"
error. The fix required routing strings through the escape rather than
PkmnType values — a workaround that obscures the intent. Teams using Coalton
in production should treat `lisp` escapes as load-bearing and regression-test
the generated CL output.

**Cross-package symbol dispatch.** The `match-outcome` macro's binding name
resolves in the macro's package, not the caller's. This is standard CL macro
hygiene, but Coalton's ADT slot names (`|_0|`, `|_1|`) are generated symbols
in the `pokemon-sim` package, creating a three-way package interaction that
required iterative debugging. SML's module system handles this more cleanly.

### 3.5 CL Glue: What Worked

The glue layer being ~80 lines with no logic is the intended outcome. If
`simulator.lisp` were 400 lines with computation, the boundary would be
wrong. Its thinness is a design invariant: when it grows, something moved to
the wrong layer.

CL's macro system was used for `match-outcome` — a pattern that cannot be a
function (it needs to introduce bindings) and would be verbose without macros.
The macro required three iterations but the final form is clean:

```lisp
(match-outcome result
  :winner w
  :victor  (format t "Winner: ~A~%" (pokemon-sim:pokemon-name w))
  :draw    (format t "Draw~%")
  :ongoing (format t "Still going~%"))
```

---

## 4. Performance

All benchmarks run on SBCL 2.2.9 and ECL 21.2.1 on the same x86-64 machine.
SBCL times are with native compilation (fasls loaded). ECL times are with
C-compiled `.fas` files (Speed=3, Safety=2). ECL bytecode numbers are
included for reference but are not suitable for production use.

### 4.1 Knowledge Layer (Prolog + CL)

| Operation | SBCL | ECL C-native | ECL bytecode |
|---|--:|--:|--:|
| `make-pokemon-kb` | 200 µs | 1,300 µs | 3,500 µs |
| `get-logic-multiplier` | 16 µs | 56 µs | 887 µs |
| `suggest-badge-team` | 504 µs | 1,702 µs | 26,694 µs |
| `find-pokemon` | 12 µs | 32 µs | 547 µs |
| `make-battle-mon` | 34 µs | 61 µs | 1,036 µs |
| `gary-party` (6 mons) | 170 µs | — | — |

The dominant cost in `get-logic-multiplier` is hash-table lookup followed by
the `intern` call (converting a Coalton string to a keyword). Pre-computing
the 17×17 effectiveness matrix at kb-construction time would reduce the
per-call cost to a single `aref` — approximately 0.1 µs on SBCL.

`suggest-badge-team` is expensive because it calls `get-logic-multiplier`
15 × N times (15 candidate types × number of enemy types). For a 4-type
enemy party that is 60 Prolog queries. Materialising the `counters/2`
predicate (which we do) eliminates the intermediary but the advisor still
pays for 15 × 4 queries. An acceptable cost for a query called once at
battle entry.

### 4.2 Battle Computation Layer (Coalton)

| Operation | SBCL |
|---|--:|
| `type->string` | 0.06 µs |
| `lookup-multiplier` | 7 µs |
| `calculate-damage` | 8 µs |
| `run-turn` | 14 µs |
| `simulate-battle` (20-turn cap) | 138 µs |
| Full pipeline (kb + party + battle) | 312 µs |

At 138 µs per full battle simulation, SBCL delivers approximately **7,200
simulations per second** on a single core. For a team-building advisor that
needs to evaluate thousands of team compositions, this is more than adequate.
For a real-time game engine running at 60 Hz with hundreds of simultaneous
combatants, it is not — the architecture would need the Coalton layer replaced
with C99, with the Prolog layer retained for rule queries that are cached
after first access.

### 4.3 ECL Portability

The Coalton layer does not load on ECL. The pure-CL knowledge layer (Prolog
rules + catalog) runs on ECL C-native at 3.5× the SBCL baseline — acceptable
for many embedded use cases.

ECL bytecode is 50–55× slower than SBCL for query-heavy operations
(`suggest-badge-team`: 504 µs → 26.7 ms). This makes ECL bytecode unsuitable
for any tight simulation loop.

The conclusion for game engine embedding: if the target is ECL linked into a
C engine via `libecl`, the Prolog knowledge layer works and performs
reasonably. The typed battle computation must be written in C.

---

## 5. Architectural Conclusions

### 5.1 What belongs where

After running this exercise the correct layering for a high-performance game
engine with this architecture is:

```
C99                 Hot path, state machine, memory layout.
                    Arena allocation; no GC on critical path.
                    Prolog multiplier results cached after first query.

Prolog              Rules and knowledge: type chart, AI decision trees,
(libswipl/ECL)      item interactions, encounter tables, dialogue conditions.
                    Backward-chaining over ground facts is the right tool
                    for "what is true given these facts."

Common Lisp         Metalevel: spec → C header generation, asset pipeline,
                    REPL inspection of live C state via CFFI, test harness.
                    Macro-driven entity definition that emits both C structs
                    and Prolog facts from a single source.
```

The Coalton/SML layer is valuable at internal module boundaries but creates a
portability ceiling when the runtime target is C-embedded Lisp. If the team
already uses SBCL exclusively and does not need ECL embedding, Coalton's
exhaustiveness checking on sum types is worth the cost. If the target runtime
is flexible, the same guarantees come from C enums with `-Wswitch-enum` and
disciplined struct layout — at zero portability cost.

### 5.2 The overlap question

There is an apparent overlap between Coalton's `PkmnType` sum type and
Prolog's `:fire`, `:grass` keyword atoms. The concern is that the type chart
is encoded twice — once as Coalton constructors, once as Prolog facts.

In practice these serve orthogonal purposes. Coalton's `PkmnType` is a
**static dispatch discriminant**: pattern matching on it is checked for
exhaustiveness at compile time. Prolog's keyword atoms are **dynamic
unification terms**: the type chart query `(effectiveness :fire :grass
:super-effective)` succeeds or fails at runtime based on the knowledge base.
The bridge — `(intern (type->string t) "KEYWORD")` — is one line, not a
design smell. The overlap is in the representation of type names, not in
semantics.

### 5.3 Do you need SML/Coalton?

The argument for SML/Coalton is strongest when typed functional computation
sits between CL and Prolog as a middle layer. In this architecture it does,
and the benefits (exhaustiveness, early type error detection) were real.

But if C99 owns the hot path and Prolog owns the rules, the typed middle layer
shrinks to the question: "Do I need exhaustiveness checking on my game's
state machine transitions?" If those transitions are C enums in a switch with
`-Wswitch-enum`, the compiler already provides that guarantee. The Coalton
layer adds value proportional to the number and complexity of sum types at
internal boundaries. For a game with a handful of outcome types, the
portability cost is probably not worth it. For a game with deeply nested
variant types throughout — dialogue trees, quest states, AI decision nodes —
SML proper (MLton or Poly/ML, with mature C FFI) may be worth the additional
language.

The weak version of the conclusion: **use Prolog for rules, CL for tooling,
and C for runtime. The typed functional layer is optional and SBCL-specific.**

---

## 6. Related Work

**Logic programming for game AI.** Orkin's work on F.E.A.R.'s planning system
used a STRIPS-style planner that shares the Prolog philosophy of declarative
goal specification. Datalog-based query engines have appeared in several
commercial engines (e.g., as a scripting substrate for large open-world games)
precisely because the backward-chaining model is a natural fit for "is the
player in state X?" queries over game world state.

**Coalton.** The Coalton project (HRL Laboratories) targets exactly the use
case we explore: typed functional programming within a Common Lisp environment
for systems where CL's dynamism is needed for some parts and ML's type
discipline for others. The SBCL-only stance is documented and intentional.

**Multi-paradigm game scripting.** Languages like AngelScript and Squirrel
are designed as embedded scripting layers above a C engine — the same
architectural position as our Prolog + CL stack. The difference is that
logic programming gives you backward-chaining for free; imperative scripting
languages require hand-coding search.

---

## 7. Availability

Source code, benchmarks, and all documentation:
[github.com/denzuko/ml-prolog-pokemon](https://github.com/denzuko/ml-prolog-pokemon)

Three ASDF systems: `pokemon-sim` (core), `pokemon-sim/test` (65 functional
tests), `pokemon-sim/perf` (11 performance regression tests).

Requires SBCL 2.x, Quicklisp, and `cl-gambol` in the local-projects directory.

---

## References

1. Clocksin, W. F. and Mellish, C. S. *Programming in Prolog*. Springer, 1981.
2. Norvig, P. *Paradigms of Artificial Intelligence Programming*. Morgan Kaufmann, 1992. (Source of paiprolog.)
3. Orkin, J. "Three States and a Plan: The AI of F.E.A.R." *GDC Proceedings*, 2006.
4. The Coalton Authors. *Coalton: ML-style Types for Common Lisp*. HRL Laboratories, 2021–2026. [github.com/coalton-lang/coalton](https://github.com/coalton-lang/coalton)
5. Milner, R., Tofte, M., and Harper, R. *The Definition of Standard ML*. MIT Press, 1990.
6. Steele, G. L. *Common Lisp the Language*, 2nd ed. Digital Press, 1990.
7. wmannis. *cl-gambol: A Gambol Prolog Interpreter for Common Lisp*. [github.com/wmannis/cl-gambol](https://github.com/wmannis/cl-gambol). (Bug: TCO interaction in SBCL 2.x headless documented in project issue tracker.)
8. ECL Team. *Embeddable Common Lisp 21.2.1*. [ecl.common-lisp.dev](https://ecl.common-lisp.dev), 2021.

---

*Dwight Spencer is Principal of Da Planet Security and Technology Chair of
Restore The Fourth. ORCID: [0009-0001-0066-4646](https://orcid.org/0009-0001-0066-4646).*
