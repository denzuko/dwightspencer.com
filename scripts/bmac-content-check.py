#!/usr/bin/env python3
"""
bmac-content-check.py — gate for paid BMAC content on dwightspencer.com.

BMAC readers paid for access to the working materials behind a free article.
The gate enforces that this content delivers what paid content promises:
raw data, decisions with alternatives rejected, practical copy-pasteable
material, and a next-steps section that a practitioner can act on.

This gate complements blog-voice-check.py (voice/tone) and
bdd-rigor-check.py (BDD coverage). It runs on /projects/ content only.

Usage:
    scripts/bmac-content-check.py hugo/content/projects/some-lab.md

Exit 0 = passes. Exit 1 = one or more hard failures.
"""

import re
import sys
import argparse

FAIL = "FAIL"
WARN = "WARN"
INFO = "INFO"


def strip_frontmatter_and_code(text):
    body = text.split("+++", 2)[-1] if text.startswith("+++") else text
    body = re.sub(r"```.*?```", "", body, flags=re.S)
    body = re.sub(r"<style>.*?</style>", "", body, flags=re.S)
    return body


def check_raw_data(body):
    """BMAC content must contain actual numbers, not just conclusions.
    Free articles summarise. Paid content shows the working."""
    has_table = bool(re.search(r"<table", body, re.I))
    has_numbers = bool(re.search(
        r"\b\d[\d,]*\s*(?:tokens?|µs|ms|us|%|words?|lines?|files?|repos?|calls?)\b",
        body, re.I))
    has_figures = bool(re.search(
        r"\b(?:figure|table|measurement|benchmark|count|total)\b", body, re.I))
    if not (has_table or has_numbers):
        return FAIL, "no raw data — BMAC content must show the working, not just conclusions", \
               ["No numeric measurements or data table found. Paid readers expect figures."]
    return INFO, "raw data present", []


def check_decisions_with_rejections(body):
    """BMAC content must show what was rejected and why, not just what was shipped.
    The free article states the decision. The notebook explains the alternatives."""
    rejection_signals = [
        r"\brejected?\b", r"\bnot (?:used?|chosen?|adopted?|shipped?)\b",
        r"\balternative\b", r"\binstead of\b", r"\brather than\b",
        r"\bconsidered\b", r"\bdiscarded?\b", r"\bwhy (?:not|I)\b",
        r"\bI rejected\b", r"\bI chose\b", r"\bI did not\b",
    ]
    hits = []
    for pattern in rejection_signals:
        if re.search(pattern, body, re.I):
            hits.append(pattern.replace(r"\b", "").replace("(?:", "").replace(")", ""))
    if not hits:
        return FAIL, "no decision rationale — BMAC must show what was rejected and why", \
               ["No alternatives-considered language found. Paid readers need the decisions, not just the outcome."]
    return INFO, f"decision rationale present (signals: {hits[:3]})", []


def check_prior_art_sourced(body):
    """BMAC content that covers implementation must name prior art read
    before writing, not discovered after. 'I read X before writing' is
    paid-content information; 'X exists' is free-article information."""
    sourced_signals = [
        r"\bread (?:the |its |in )?source\b",
        r"\bsource was read\b",
        r"\bbefore (?:writing|implementation|any code)\b",
        r"\bprior art\b",
        r"\bexisting librar\w+\b",
        r"\bwhat I read\b",
    ]
    hits = [p for p in sourced_signals if re.search(p, body, re.I)]
    if not hits:
        return WARN, "no prior art sourcing — paid content should document what was read before writing", \
               ["Add a section naming what you read before implementing, with what each reading produced."]
    return INFO, "prior art sourcing present", []


def check_copy_pasteable_material(body, raw_body=""):
    """BMAC content must contain something the reader can use directly —
    not just described, but present. A template, a script excerpt, a command,
    a config block. 'Here is the text to paste' is paid content.
    'You should add a section to CLAUDE.md' is free-article content."""
    # Check raw body for code blocks (before stripping removes them)
    check_text = raw_body if raw_body else body
    has_code_block = bool(re.search(r"```", check_text))
    has_command = bool(re.search(
        r"(?:qlot exec|sbcl|ros run|asdf:|ql:quickload|git |make |brew )", check_text))
    has_template = bool(re.search(
        r"(?:paste|template|copy|verbatim|exact text|add this|use this)", check_text, re.I))
    if not (has_code_block and (has_command or has_template)):
        return WARN, "no copy-pasteable material — paid content should include something directly usable", \
               ["Add a code block with a command, template, or config the reader can paste directly."]
    return INFO, "copy-pasteable material present", []


def check_next_steps(body):
    """BMAC content must end with what comes next — not a conclusion that
    restates what the article already said, but a practitioner's next-steps
    section that a reader can act on. 'I would try X next' is paid content.
    'This is interesting future work' is academic filler."""
    next_signals = [
        r"\bwhat (?:I )?(?:would |to )?try next\b",
        r"\bnext (?:step|thing|approach|path)\b",
        r"\bwould try\b",
        r"\bfirst thing to try\b",
        r"\bsubsequent work\b",
        r"\bopen question\b",
        r"\bwhat comes next\b",
    ]
    hits = [p for p in next_signals if re.search(p, body, re.I)]
    if not hits:
        return FAIL, "no next-steps section — BMAC content must close with what to try next", \
               ["Paid readers need a next-steps section written as 'what I would try' not 'future work'."]
    return INFO, "next-steps present", []


def check_not_a_copy_of_article(body, word_count):
    """BMAC content must be substantively longer than a typical free article
    AND contain material the article does not. A padded restatement is not
    paid content. Minimum: 1,500 words, with sections not present in the
    free article (raw data, sourced prior art, decisions with rejections,
    copy-pasteable material)."""
    if word_count < 1500:
        return FAIL, f"content too short for paid tier ({word_count} words — minimum 1,500)", \
               [f"At {word_count} words this reads as a long free article, not a lab notebook. "
                "Paid content has raw data, decisions, templates, and next steps not in the free article."]
    return INFO, f"word count {word_count} — above 1,500 minimum", []


def check_section_headers(body):
    """BMAC /projects/ content uses HTML h2 headers to structure the notebook.
    Unlike blog posts (which never use headers), paid content is a reference
    document the reader returns to. Headers are required."""
    headers = re.findall(r"<h2\b", body, re.I)
    if len(headers) < 3:
        return WARN, f"only {len(headers)} <h2> section(s) — paid lab notebooks need ≥3 structured sections", \
               ["Add section headers so the reader can navigate the notebook as a reference."]
    return INFO, f"{len(headers)} <h2> sections found", []


def check_free_article_phrases(body):
    """Phrases that belong in the free article, not in paid content.
    If these appear, the content is restating the article rather than
    extending it."""
    restate_phrases = [
        "in conclusion", "to summarise", "to summarize",
        "as discussed above", "as mentioned", "as noted above",
        "this article", "this post", "the free article",
        "in summary",
    ]
    hits = [p for p in restate_phrases if p in body.lower()]
    if hits:
        return FAIL, "article-restatement phrases found — paid content extends, not restates", hits
    return INFO, "no article-restatement phrases", []


def run_checks(path):
    text = open(path, encoding="utf-8").read()
    body = strip_frontmatter_and_code(text)
    prose = re.sub(r"<[^<]+?>", " ", body)
    word_count = len(prose.split())

    raw_body = text.split("+++", 2)[-1] if text.startswith("+++") else text
    checks = [
        check_not_a_copy_of_article(body, word_count),
        check_raw_data(body),
        check_decisions_with_rejections(body),
        check_prior_art_sourced(body),
        check_copy_pasteable_material(body, raw_body),
        check_next_steps(body),
        check_section_headers(body),
        check_free_article_phrases(body),
    ]
    return checks, word_count


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("path", help="Path to the BMAC /projects/ markdown file")
    args = ap.parse_args()

    checks, word_count = run_checks(args.path)

    hard_fail = False
    print(f"=== bmac-content-check: {args.path} ({word_count} words) ===\n")

    for severity, label, hits in checks:
        if hits and severity in (FAIL, WARN):
            marker = {"FAIL": "FAIL", "WARN": "warn"}[severity]
            print(f"[{marker}] {label}")
            for h in hits[:5]:
                print(f"    - {h}")
            print()
            if severity == FAIL:
                hard_fail = True
        elif severity == INFO:
            print(f"[ok]  {label}")

    print()
    if hard_fail:
        print("RESULT: FAIL — paid content standards not met. Fix before pushing.")
        sys.exit(1)
    else:
        print("RESULT: PASS — paid content standards met.")
        sys.exit(0)


if __name__ == "__main__":
    main()
