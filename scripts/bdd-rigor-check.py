#!/usr/bin/env python3
"""BDD rigor gate: checks a .feature file's Scenario titles against
four categories of coverage that were found missing, on reflection,
across seven libraries built with full branch coverage and green CI
but without them: boundary conditions, invalid input, concurrency,
and persistence.

This is a forcing function, not a perfect analyzer. A category the
keyword scan misses may still be covered by wording this
script does not recognize, or may not apply to a given
library. Either way, the category must be addressed explicitly
before the BDD phase is considered complete: matched by a real
scenario, or its absence justified in the commit or README, not
silently skipped. This script cannot make that judgment; it can
only make silence impossible.

Usage: bdd-rigor-check.py path/to/some.feature
"""
import re
import sys

CATEGORIES = {
    "boundary": {
        "keywords": ["empty", "zero", "negative", "maximum", "minimum",
                     "large", "boundary", "single", "overflow", "underflow"],
        "prompt": "Boundary conditions: empty/zero/negative/maximum inputs, "
                  "off-by-one edges (the half-open-range kind of bug already "
                  "found once in this project).",
    },
    "invalid_input": {
        "keywords": ["invalid", "malformed", "wrong", "mismatch", "refus",
                      "reject", "signal", "error", "duplicate"],
        "prompt": "Invalid or malformed input: wrong type, wrong shape, "
                  "mismatched-length arguments, anything the type system "
                  "does not itself enforce.",
    },
    "concurrency": {
        "keywords": ["concurrent", "simultaneous", "parallel", "race",
                     "thread", "lock", "contention"],
        "prompt": "Concurrent access: does this library have any module-level "
                  "or shared mutable state (a *special variable*, a cache, an "
                  "index outside bknr.datastore's own transaction machinery)? "
                  "If so, what happens under concurrent access, and is that "
                  "tested, not just assumed safe?",
    },
    "persistence": {
        "keywords": ["restart", "persist", "survive", "reload", "reopen"],
        "prompt": "Persistence and restart: already the project's strongest "
                  "habit, kept here as a checklist item so it stays a habit "
                  "rather than an accident.",
    },
}


def check(path):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    scenario_titles = [
        line.strip()[len("Scenario:"):].strip().lower()
        for line in text.splitlines()
        if line.strip().startswith("Scenario:") or line.strip().startswith("Scenario Outline:")
    ]
    all_titles_text = " ".join(scenario_titles)

    print(f"=== BDD rigor check: {path} ===")
    print(f"{len(scenario_titles)} scenario(s) found.\n")

    missing = []
    for name, spec in CATEGORIES.items():
        matched = [kw for kw in spec["keywords"] if kw in all_titles_text]
        if matched:
            print(f"[present] {name}: matched on {matched}")
        else:
            print(f"[ABSENT]  {name}: no scenario title matched any of {spec['keywords']}")
            print(f"          -> {spec['prompt']}")
            missing.append(name)

    print()
    if missing:
        print(f"{len(missing)} categor{'y' if len(missing) == 1 else 'ies'} unaddressed: {', '.join(missing)}")
        print("Each one needs an explicit answer before this feature file is done:")
        print("a real scenario, or a stated reason it does not apply.")
        return 1
    print("All four categories addressed.")
    return 0


if __name__ == "__main__":
    sys.exit(check(sys.argv[1]))
