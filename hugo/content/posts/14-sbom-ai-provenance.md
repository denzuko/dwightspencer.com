+++
title       = "Your SBOM Does Not Know Copilot Wrote That Function"
date        = "2026-06-04"
draft       = false
description = "SBOM tooling accurately enumerates dependencies. It records nothing about AI-generated code provenance. With CMMC Level 2 Phase 2 assessments starting November 2026, that gap is no longer latent."
slug        = "14-sbom-ai-provenance"
keywords    = ["sbom", "devsecops", "cmmc", "ai", "copilot", "supply-chain", "provenance", "cicd", "compliance"]
tags        = ["devsecops", "infosec", "devops"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "DevSecOps, Supply Chain Security, CMMC Compliance, AI Tooling"
aliases     = ["/14-sbom-ai-provenance/"]
og_image    = "/assets/og-posts.png"

[related_post]
  slug  = "13-copilot-meter-governance"
  label = "Yesterday: the Copilot billing change is a governance problem"
+++

A Software Bill of Materials answers three questions: what's in this software, where did
it come from, and what do I do when something in it is vulnerable?

The tooling was built around a specific model of software composition. Components come from
known sources. Open source packages have version numbers, maintainers, CVE histories, and
licenses. First-party code has commit authors and review history. The dependency graph is
knowable because everything in it has a traceable origin.

AI-generated code breaks the third leg of that model.

## What SBOM tooling sees and doesn't see

SBOM generation tools running in your CI/CD pipeline will accurately enumerate every
package your AI-generated code depends on. They won't record that the function calling
those packages was written by a model, that the model was queried with a specific context
window that may or may not have included relevant security constraints, or that no human
reviewed the generated output before it entered the protected branch.

The SBOM is technically complete and operationally misleading.

This is not an edge case. By 2025, over 70% of enterprise codebases included components
created with AI assistance. Most of those organizations are generating SBOMs that say
nothing about the primary author of a substantial fraction of their code.

For most teams this is a latent problem — it surfaces when a vulnerability appears in
AI-generated code and the incident timeline asks "who reviewed this and when?" For teams
in the defense industrial base it is an active compliance problem with a hard deadline.

## The CMMC Phase 2 deadline

CMMC Level 2 Phase 2 begins November 2026. Mandatory C3PAO assessments replace
self-assessments for most Level 2 contracts. Assessments are evidence-driven — assessors
review documentation of how Controlled Unclassified Information flows through your
environment, who has access, and what controls govern that access.

If AI-generated code is part of your software environment and you can't document the
provenance and review history of that code, you have a gap that self-assessments didn't
surface.

## Three controls worth implementing now

**Attribution at the commit level.** Git already records author, timestamp, and commit
message. A policy requiring commits containing AI-generated code to be labeled as such
costs nothing to implement and creates the audit trail that both internal review and
external assessments will ask for. Enforcement is a pre-commit hook or a CI check —
neither requires procurement.

**AI-BOM formats.** The SBOM ecosystem is extending toward AI Bills of Materials: which
model was used, which version, what the training data provenance was, and what the usage
context was. CycloneDX extensions, Anchore, and Chainguard tooling are early but
functional. Organizations that start generating AI-BOMs now will have a year of data
before Phase 2 assessments begin.

**Pipeline gates on branch protection.** The most direct control: require human review of
any commit flagged as AI-assisted before it can merge to a protected branch. Most
organizations already have branch protection rules. Adding an AI-assist check to the
review requirement is a policy change in GitHub or GitLab settings, not an infrastructure
project.

## The frame that makes this tractable

None of this requires abandoning AI-assisted development. The governance problem is not
that AI writes code — it's that the controls applied to every other input to your build
process haven't been applied to AI input.

Treat AI-generated code like any other third-party input: provenance tracked, review
documented, access controlled.

The teams that do this before November clear Phase 2 assessments cleanly. The teams that
don't find out that "we use Copilot" is not an answer to "show me your CUI handling
documentation."
