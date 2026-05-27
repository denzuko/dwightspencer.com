+++
title       = "LLM-Generated Terraform vs Cookiecutter: What the Lab Showed"
date        = "2026-05-26"
draft       = false
description = "In May 2023 I ran the same infrastructure build two ways on a live Twitch stream — LLM-generated Terraform against cookiecutter atomic modules. The results weren't close."
slug        = "12-terraform-llm-thesis"
keywords    = ["terraform", "llm", "infrastructure", "security", "cookiecutter", "iac", "opa", "rego", "devsecops"]
tags        = ["infrastructure", "devops", "open-source"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Infrastructure as Code, DevSecOps, Security, LLM Tooling"
aliases     = ["/12-terraform-llm-thesis/"]
og_image    = "/assets/og-posts.png"
+++

In May 2023 I ran the same infrastructure build two ways, live on Twitch.

The target: [~denzuko/lab-techolution-debugging](https://git.sr.ht/~denzuko/lab-techolution-debugging) —
a canary token and honeypot stack on Google Cloud for teaching monitoring
internals. VPC, IAM, compute, logging pipeline, alerting. Full stack from
Terraform up.

Path one: describe the architecture in plain English, generate Terraform
modules with an LLM, iterate until `terraform plan` ran clean.

Path two: [cookiecutter](https://cookiecutter.readthedocs.io/) with
hand-written atomic modules. One module per responsibility. Policy
constraints in the template. Run the tool, answer the prompts, apply.

<h2 id="the-results">The results</h2>

**Speed.** The LLM path required multiple iteration cycles per module.
Provider API drift alone caused three full cycles on the IAM module —
the model's training data didn't match the current provider schema.
The cookiecutter path was one pass: generate, fill values, apply.
At module count, the gap compounds linearly.

**Correctness.** The cookiecutter path produced zero apply-time failures.
The LLM path introduced errors that cleared `terraform validate` but
failed on apply: resource naming conflicts, incorrect IAM binding syntax,
a VPC peering misconfiguration that would have connected the honeypot
network to the canary network — defeating the lab's architecture.

**Security posture.** Generated code passed no policy gates by default.
Overly permissive IAM bindings. Missing encryption at rest on the logging
pipeline. Port 22 open to `0.0.0.0/0`.

The cookiecutter template had OPA/Rego gates baked in. Code that violated
policy was rejected at generation time. The model had no concept of policy
and optimised for `terraform plan` exit code zero, not security posture.

<h2 id="why-it-matters">Why this matters beyond the lab</h2>

The failures above aren't surprising if you understand what the model is
optimising for. Public Terraform on GitHub skews toward configurations
that worked in a specific context once, were never reviewed for hardening,
and are overrepresented in training data because they shipped. The model
learned from what ran, not from what was secure.

That bias compounds when generated code runs infrastructure that collects
sensitive data. Every organisation running ALPR cameras, Fusus integration,
or similar surveillance systems is running cloud infrastructure. If that
infrastructure was generated rather than specified, the policy constraints
and access controls are whatever the model guessed at — not what the
organisation intended.

Infrastructure that isn't understood by the people running it is the
precondition for the breaches, exfiltration events, and access failures
that show up in incident reports two years later.

<h2 id="the-source">The source</h2>

The lab is at [~denzuko/lab-techolution-debugging](https://git.sr.ht/~denzuko/lab-techolution-debugging).
The Twitch session that ran this experiment is at
[~denzuko/twitch-lab-week2](https://git.sr.ht/~denzuko/twitch-lab-week2).
Both are dated artifacts — the tooling has moved, the methodology holds.

Templates. Policy gates. Generated code as a starting point, not a
finished module.
