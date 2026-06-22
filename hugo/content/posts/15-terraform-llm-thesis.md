+++
title       = "LLM-Generated Terraform Does Not Know What Your Architecture Is For"
date        = "2026-05-26"
draft       = false
description = "In May 2023 I ran the same infrastructure build two ways on a live stream — LLM-generated Terraform against cookiecutter atomic modules with OPA/Rego gates. The gap wasn't speed. It was that the model had no concept of what the infrastructure was supposed to accomplish."
slug        = "15-terraform-llm-thesis"
keywords    = ["terraform", "llm", "infrastructure", "security", "cookiecutter", "iac", "opa", "rego", "devsecops"]
tags        = ["infrastructure", "devops", "open-source"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "Infrastructure as Code, DevSecOps, Security, LLM Tooling"
aliases     = ["/15-terraform-llm-thesis/"]
og_image    = "/assets/og-posts.png"
series      = ["Infrastructure Independence"]

[related_post]
  slug  = "11-neural-sh"
  label = "post 11 covers the Unix shell approach to the same LLM tooling problem"
+++

In May 2023 I built the same infrastructure twice, live on stream.

The target was [~denzuko/lab-techolution-debugging](https://git.sr.ht/~denzuko/lab-techolution-debugging) —
a canary token and honeypot stack on Google Cloud for teaching monitoring internals.
VPC, IAM, compute, logging pipeline, alerting. Full stack from Terraform up.
Not a toy. An environment where the security properties were the point.

The first build used an LLM. I described the target architecture in plain English and
asked the model to generate Terraform modules, iterating on the output until
`terraform plan` ran clean.

The second used [cookiecutter](https://github.com/cookiecutter/cookiecutter) —
a project scaffolding tool that generates directory structures and file contents from
templates and user-supplied variable values. The cookiecutter template for this lab was
hand-written: one module per responsibility, with OPA/Rego policy constraints embedded
directly in the template structure so any generated output was validated against defined
rules before it could be applied. I ran the template, supplied the variable values for
this specific environment, and applied the result.

## What the comparison showed

The LLM path required multiple iteration cycles per module. Provider API drift alone
caused three full cycles on the IAM module — the model's training data did not match the
current provider schema. The cookiecutter path went through a single cycle: template generation, variable substitution, apply.
At module count, the gap compounds linearly.

Correctness was not close. The cookiecutter path produced zero apply-time failures. The
LLM path introduced errors that cleared `terraform validate` but failed on apply: resource
naming conflicts, incorrect IAM binding syntax, a VPC peering misconfiguration that would
have connected the honeypot network to the canary network.

That last one is the one worth thinking about. The VPC peering block was syntactically
valid. It would have passed any automated syntax check. It would have applied without
error. It would have connected two network segments that existed specifically to be
isolated from each other — the honeypot and the canary — because the model had no concept
of why those networks existed or what would break if they could reach each other. It
optimised for `terraform plan` exit code zero, which is not the same thing as correct.

On security posture: generated code passed no policy gates by default. Overly permissive
IAM bindings. Missing encryption at rest on the logging pipeline. Port 22 open to
`0.0.0.0/0`. None of this was the model being careless. It was the model writing
infrastructure that looks like the infrastructure most commonly published to GitHub —
which skews toward configurations that worked in a specific context once, were never
reviewed for hardening, and are overrepresented in training data precisely because they
shipped.

## Why policy-as-code closes the gap the model cannot close itself

The cookiecutter template had OPA/Rego gates wired into the generation step. Code that violated policy was rejected before it ever reached a plan or apply step. The model
had no such feedback loop. It had training signal from public repositories and exit codes
from the Terraform CLI. Neither of those tells it whether the IAM binding is too
permissive for the environment it is being deployed into.

This is the gap that matters. An LLM generating Terraform is doing pattern matching
against public infrastructure code, most of which was written without explicit security
constraints in the template. The model does not know your threat model. It does not know
that this VPC should never peer with that one. It does not know that this logging pipeline
handles data subject to retention requirements. It knows what Terraform that ran looked
like, and it produces more of that.

Policy-as-code is the mechanism that carries the architecture intent the model cannot
infer. An OPA/Rego gate that checks "does this VPC peering connect networks that should be
isolated" is not redundant with `terraform validate` — it is the layer that validates
semantic correctness against your specific requirements, which the CLI cannot do and the
model will not do reliably.

The practical pattern that works: cookiecutter or equivalent templating for module
structure and policy gate integration, LLM generation for the boilerplate inside a module
boundary, OPA/Rego gates that validate the output before plan, human review of anything
the gates flag or that touches IAM, networking, or encryption configuration.

Generated code as a starting point inside a constrained template is different from
generated code as the template. The second produces infrastructure that looks right.
The first produces infrastructure that is right.

## The source

The lab is at [~denzuko/lab-techolution-debugging](https://git.sr.ht/~denzuko/lab-techolution-debugging).
The stream session that ran this experiment is at
[~denzuko/twitch-lab-week2](https://git.sr.ht/~denzuko/twitch-lab-week2). Both are dated
artefacts — the tooling has moved, the methodology holds. The VPC peering misconfiguration
is documented in the commit history.
