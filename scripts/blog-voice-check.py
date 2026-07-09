#!/usr/bin/env python3
"""
blog-voice-check.py — pre-push brand voice and litmus gate for dwightspencer.com posts.

Run before every push, same discipline as a Rego gate or BATS suite elsewhere
in this org: catch mechanical voice violations here, not in PR review comments.

Usage:
    scripts/blog-voice-check.py hugo/content/posts/26-lisp-token-cost.md
    scripts/blog-voice-check.py hugo/content/posts/26-lisp-token-cost.md --extra-words golfed:adjective

Exit code 0 = clean. Exit code 1 = one or more hard-fail checks found hits.
Warnings (structural, genre-dependent) print but do not fail the build.

Baselines below were established by grepping the actual published corpus
(posts 00-25) — not assumed, measured. Re-run the baseline scan in
docs/voice-baseline.md if a new post type is added that might legitimately
break one of these (e.g. a post that should use headers).
"""

import argparse
import re
import sys
from collections import Counter

FAIL = "FAIL"
WARN = "WARN"
INFO = "INFO"


def strip_code_and_frontmatter(text: str) -> str:
    """Return prose only: no TOML frontmatter, no fenced code blocks, no inline
    CSS style attributes or <style> blocks (which legitimately contain words
    like 'color')."""
    body = text.split("+++", 2)[-1] if text.startswith("+++") else text
    body = re.sub(r"```.*?```", "", body, flags=re.S)
    body = re.sub(r"<style>.*?</style>", "", body, flags=re.S)
    body = re.sub(r'style="[^"]*"', "", body)
    return body


def check_forbidden_phrases(prose: str):
    # Canonical list from the social-media content pipeline checker (June 2026
    # session). Merged here rather than treated as a separate, newer standard.
    phrases = [
        "it's worth noting", "in conclusion", "this is why", "thread:",
        "here's why", "here is why", "let's be clear", "make no mistake",
    ]
    tl = prose.lower()
    hits = [p for p in phrases if p in tl]
    return FAIL, "forbidden phrases (canonical list, social-pipeline checker)", hits


def check_verb_contractions(prose: str):
    # Deliberately excludes bare 's to avoid flagging possessives (Lisp's, model's).
    hits = re.findall(r"\b(?:here's|it's|that's|there's|let's|what's)\b", prose, re.I)
    hits += re.findall(r"\b\w+'(?:t|re|ve|ll|d|m)\b", prose)
    return FAIL, "verb contractions (zero precedent in corpus)", hits


def check_direct_address(prose: str):
    hits = re.findall(r"\byou\b|\byour\b", prose, re.I)
    return WARN, "direct address 'you'/'your' (corpus uses this ~once per post, rare)", hits


def check_self_referential(prose: str):
    hits = re.findall(r"(?:this (?:post|article|piece)|the (?:entire )?argument of this)", prose.lower())
    return FAIL, "self-referential meta-commentary (narrating the piece to itself)", hits


def check_pundit_contrast(prose: str):
    hits = re.findall(r"\bis not [^.]{5,60}\.\s+(?:this|that|it) is [^.]{5,60}\.", prose.lower())
    hits += re.findall(r"not (?:just|only) [^.;]{3,60}[.;]", prose.lower())
    return FAIL, "pundit-pattern contrast construction ('not X, it's Y', spelled out or contracted)", hits


def check_dramatic_colon(prose: str):
    """Colon followed by a full independent clause used for rhetorical reveal,
    as opposed to a colon introducing a list, table, code block, or short appositive."""
    hits = re.findall(r"[a-z)]:\s+[A-Z][^.]{20,}\.", prose)
    return WARN, "possible dramatic-reveal colon (verify it isn't introducing a list/code/table)", hits


def check_hollow_self_description(prose: str):
    """Sentences that are grammatically correct, pass every other check, and
    still tell a reader nothing concrete because they describe the document's
    own structure or an absence rather than giving actual reader value.
    Caught by eye first (post-26 methodology appendix, 2026-07-09): 'Every
    number in that article is independently reproducible from Sections 2 and
    3 below, without needing the article's prose.' True, structurally sound,
    and empty -- points at the document's own section numbers instead of
    saying what a reader can do, and frames the value as an absence ('without
    needing X') instead of a presence. Two syntactic signatures, both warn-
    level since false positives are real (a genuine methodological limitation
    can legitimately need 'without' framing)."""
    self_referential_pointer = re.findall(
        r"\b(?:Sections?|Chapters?)\s+\d+(?:\s+(?:and|through|to)\s+\d+)?\s+(?:below|above)\b[^.]{0,80}\.",
        prose, re.I,
    )
    negative_property_framing = re.findall(
        r"\bwithout\s+(?:needing|requiring)\s+[^.]{3,60}\.",
        prose, re.I,
    )
    hits = self_referential_pointer + negative_property_framing
    return WARN, "possible hollow self-description (structurally correct, says nothing concrete to a reader)", hits


def check_intensifiers(prose: str):
    hits = re.findall(r"\b(genuinely|actually|really)\b", prose, re.I)
    return FAIL, "intensifier padding (zero instances across baseline corpus)", hits


def check_rhetorical_questions(prose: str):
    text_only = re.sub(r"<[^<]+?>", " ", prose)
    sentences = re.split(r"(?<=[.!?])\s+", text_only)
    hits = [s.strip()[:60] for s in sentences if s.strip().endswith("?")]
    return FAIL, "rhetorical questions", hits


def check_american_spelling(prose: str):
    words = ["optimize", "optimization", "minimize", "minimization", "color",
             "behavior", "favor", "organize", "organized", "customize", "utilize"]
    hits = [w for w in words if re.search(r"\b" + w + r"\w*\b", prose.lower())]
    return FAIL, "American spellings (corpus uses Oxford -ise/-our)", hits


def check_telegraphic_fragments(prose: str):
    """Bare noun-phrase-plus-colon standing in for a sentence: no finite verb
    before the colon. Heuristic, so this is a warn, not a hard fail."""
    candidates = re.findall(r"<p>([^<]{10,120}):</p>", prose)
    flagged = []
    verb_hint = re.compile(
        r"\b(is|are|was|were|has|have|had|does|do|did|can|cannot|will|would|"
        r"measures|carries|holds|looks|shows|works|expands|means|matters|"
        r"runs|competes|persists|exists|allows|lacks|comes|counts)\b", re.I
    )
    for c in candidates:
        if not verb_hint.search(c):
            flagged.append(c)
    return WARN, "possible telegraphic fragment (noun phrase + colon, no finite verb)", flagged


def check_dramatic_emdash(prose: str):
    """Em-dash followed by a clause that reads as a full independent thought.
    NOTE: this is NOT an ASA/MLA/Chicago requirement -- verified against the
    actual ASA Style Guide, which explicitly endorses em-dash-plus-explanatory-
    clause ("Our conclusion--the students sampled were not concerned...") as
    correct usage. This is a house-style preference specific to this corpus:
    content feeding arXiv backlinks, DOI-registered book chapters, and future
    citation/excerpting needs sentences that stand alone when pulled out of
    context. An em-dash-joined compound clause doesn't excerpt cleanly; a
    complete sentence does. Warn-level, not a hard fail -- this is an editorial
    preference for citability, not a grammar rule."""
    pattern = re.compile(
        r"—\s*(?:something|not a|not just|not only|"
        r"(?:it|they|this|that|these|those)\s+(?:is|are|was|were|has|have|"
        r"does|do|did|cannot|can|will|would|belongs?|expresses?|competes?))\b"
        r"[^.<]{5,90}[.<]",
        re.I,
    )
    compound_pattern = re.compile(
        r"—[^.<]{0,60},\s*and\s+(?:its|their|his|her|the)\s+[\w\s]{1,25}?\s+"
        r"(?:measures?|is|are|has|have|does|do|competes?|expands?|scales?)\b[^.<]{0,90}[.<]",
        re.I,
    )
    matches = [m.group(0) for m in pattern.finditer(prose)]
    matches += [m.group(0) for m in compound_pattern.finditer(prose)]
    return WARN, "em-dash joining an independent clause (won't extract cleanly for citation/RAG reuse)", matches


def check_structural_headers(body: str):
    hits = re.findall(r"^##", body, re.M)
    return FAIL, "markdown ## headers (zero precedent anywhere in corpus, all 11+ posts checked)", hits


def check_markdown_tables_lists(body: str):
    table_hits = re.findall(r"^\|.*\|.*\|$", body, re.M)
    return WARN, "markdown pipe-tables (corpus uses HTML <table> exclusively)", table_hits


def check_em_dash_density(body: str, word_count: int):
    count = body.count("—")
    per_1000 = (count / word_count * 1000) if word_count else 0
    # Baseline from posts 23-25: 16-20 per 1000-1500 words, i.e. roughly 12-14 per 1000.
    if per_1000 > 20:
        return WARN, f"em-dash density {count} in {word_count} words ({per_1000:.1f}/1000, baseline ~12-14/1000)", [str(count)]
    return INFO, f"em-dash density {count} in {word_count} words ({per_1000:.1f}/1000) — within baseline", []


def run_checks(path: str, extra_word_rules):
    text = open(path, encoding="utf-8").read()
    body = strip_code_and_frontmatter(text)
    prose_full = re.sub(r"<[^<]+?>", " ", body)  # for word count / sentence-level checks
    word_count = len(prose_full.split())

    results = []
    for fn in (check_forbidden_phrases, check_verb_contractions, check_direct_address, check_self_referential,
               check_pundit_contrast, check_dramatic_colon, check_dramatic_emdash, check_intensifiers,
               check_rhetorical_questions, check_american_spelling,
               check_telegraphic_fragments, check_hollow_self_description):
        severity, label, hits = fn(body)
        results.append((severity, label, hits))

    for fn in (check_structural_headers, check_markdown_tables_lists):
        severity, label, hits = fn(body)
        results.append((severity, label, hits))

    results.append(check_em_dash_density(body, word_count))

    for rule in extra_word_rules:
        word, kind = rule.split(":", 1)
        hits = re.findall(r"\b" + re.escape(word) + r"\b", body, re.I)
        results.append((FAIL, f"custom rule: '{word}' used as {kind}", hits))

    return results, word_count


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("path", help="Path to the post markdown file")
    ap.add_argument("--extra-words", nargs="*", default=[],
                     help="Additional word:label rules specific to this post, e.g. golfed:adjective")
    args = ap.parse_args()

    results, word_count = run_checks(args.path, args.extra_words)

    hard_fail = False
    print(f"=== blog-voice-check: {args.path} ({word_count} words) ===\n")
    for severity, label, hits in results:
        if hits:
            marker = {"FAIL": "FAIL", "WARN": "warn", "INFO": "info"}[severity]
            print(f"[{marker}] {label}")
            for h in hits[:10]:
                print(f"    - {h}")
            if len(hits) > 10:
                print(f"    ... and {len(hits) - 10} more")
            print()
            if severity == FAIL:
                hard_fail = True
        elif severity == INFO:
            print(f"[info] {label}\n")

    if hard_fail:
        print("RESULT: FAIL — hard violations found, fix before pushing.")
        sys.exit(1)
    else:
        print("RESULT: PASS — no hard violations. Review any warnings above before pushing.")
        sys.exit(0)


if __name__ == "__main__":
    main()
