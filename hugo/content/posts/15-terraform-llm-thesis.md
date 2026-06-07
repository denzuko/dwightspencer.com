+++
title       = "LLM-Generated Terraform vs Cookiecutter: What the Lab Showed"
date        = "2026-05-26"
draft       = false
description = "In May 2023 I ran the same infrastructure build two ways on a live Twitch stream — LLM-generated Terraform against cookiecutter atomic modules. The results weren't close."
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

<p>In May 2023 I ran the same infrastructure build two ways, live on Twitch.</p>

<p>The target: <a href="https://git.sr.ht/~denzuko/lab-techolution-debugging">~denzuko/lab-techolution-debugging</a> — a canary token and honeypot stack on Google Cloud for teaching monitoring internals. VPC, IAM, compute, logging pipeline, alerting. Full stack from Terraform up.</p>

<p>Path one: describe the architecture in plain English, generate Terraform modules with an LLM, iterate until <code>terraform plan</code> ran clean.</p>

<p>Path two: <a href="https://cookiecutter.readthedocs.io/">cookiecutter</a> with hand-written atomic modules. One module per responsibility. Policy constraints in the template. Run the tool, answer the prompts, apply.</p>

<h2 id="the-results">The results</h2>

<p><strong>Speed.</strong> The LLM path required multiple iteration cycles per module. Provider API drift alone caused three full cycles on the IAM module — the model's training data didn't match the current provider schema. The cookiecutter path was one pass: generate, fill values, apply. At module count, the gap compounds linearly.</p>

<p><strong>Correctness.</strong> The cookiecutter path produced zero apply-time failures. The LLM path introduced errors that cleared <code>terraform validate</code> but failed on apply: resource naming conflicts, incorrect IAM binding syntax, a VPC peering misconfiguration that would have connected the honeypot network to the canary network — defeating the lab's architecture.</p>

<p><strong>Security posture.</strong> Generated code passed no policy gates by default. Overly permissive IAM bindings. Missing encryption at rest on the logging pipeline. Port 22 open to <code>0.0.0.0/0</code>.</p>

<p>The cookiecutter template had OPA/Rego gates baked in. Code that violated policy was rejected at generation time. The model had no concept of policy and optimised for <code>terraform plan</code> exit code zero, not security posture.</p>

<h2 id="what-the-results-showed">What the results showed</h2>

<p>The failures above aren't surprising if you understand what the model is optimising for. Public Terraform on GitHub skews toward configurations that worked in a specific context once, were never reviewed for hardening, and are overrepresented in training data because they shipped. The model learned from what ran, not from what was secure.</p>

<p>Infrastructure that isn't understood by the people running it is the precondition for the breaches, exfiltration events, and access failures that show up in incident reports two years later.</p>

<h2 id="the-source">The source</h2>

<p>The lab is at <a href="https://git.sr.ht/~denzuko/lab-techolution-debugging">~denzuko/lab-techolution-debugging</a>. The Twitch session that ran this experiment is at <a href="https://git.sr.ht/~denzuko/twitch-lab-week2">~denzuko/twitch-lab-week2</a>. Both are dated artifacts — the tooling has moved, the methodology holds.</p>

<p>Templates. Policy gates. Generated code as a starting point, not a finished module.</p>
