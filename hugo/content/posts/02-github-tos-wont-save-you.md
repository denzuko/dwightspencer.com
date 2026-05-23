+++
title       = "GitHub's TOS Won't Save You: Why Your Code, Privacy & Copyrights Are at Risk"
date        = "2026-03-11"
draft       = false
description = "How GitHub's Terms of Service — especially Section D.8 — fail to protect your privacy, copyrights, and code from AI training. Includes a full migration guide to SourceHut using gh2srht and public-inbox."
slug        = "02-github-tos-wont-save-you"
keywords    = ["GitHub", "SourceHut", "privacy", "copyright", "AI training", "Copilot", "gh2srht", "public-inbox", "FOSS", "developer rights", "TOS", "terms of service"]
tags        = ["github", "sourcehut", "privacy", "copyright", "ai-training", "copilot", "foss"]
categories  = ["articles"]
schema_type = "TechArticle"
aeo_expertise = "DevOps, Privacy, Security, Open Source"
aliases     = ["/02-github-tos-wont-save-you/", "/github-tos/", "/posts/github-tos-privacy/"]
series   = ["The Watchers You Fed"]
og_image    = "/assets/og-posts.png"
+++

<h2>The Illusion of Ownership</h2>

<p>Millions of developers trust GitHub with their most valuable creative work. But buried in its Terms of Service are provisions granting Microsoft remarkably broad rights over publicly hosted code — including the right to train commercial AI systems on it without attribution, compensation, or meaningful consent. Your open-source license is not a shield.</p>

<p>GitHub's TOS acknowledges that you retain copyright over uploaded code. In practice, that statement coexists with a much wider set of rights GitHub grants itself:</p>

<p><small><em>Highlighted: rights GitHub claims over your content</em></small></p>
<blockquote>
<p><cite>GitHub ToS — User-Generated Content</cite></p>
<p>"You own content you create, but you allow us certain rights to it, so that we can display and share the content you post… the rights you grant us are limited to those we need to <strong>provide the service.</strong>"</p>
</blockquote>

<p>The phrase <em>"provide the service"</em> has quietly expanded to encompass AI product development. GitHub Copilot — sold to enterprise customers — was trained on all publicly available code on GitHub. That code includes yours.</p>

<p><strong>Key problem:</strong> Your open-source license (MIT, GPL, Apache) may require attribution. Copilot reproduces code snippets verbatim without citing the original author or license. GitHub argues this falls within granted rights and fair use — a contested position most individual developers lack the resources to challenge.</p>

<h2>Section D.8 — The AI Waiver Clause</h2>

<p>In one of the most aggressive clauses in any major platform's TOS, Section D.8 doesn't merely permit AI training on your code — it compels you to waive your own protective terms:</p>

<p><small><em>Highlighted: rights you are forced to waive</em></small></p>
<blockquote>
<p><cite>GitHub ToS — Section D.8</cite></p>
<p>"By using automated means to access, collect, or otherwise use any publicly accessible Content from the Service for the purpose of developing or training any commercially available artificial intelligence model… <strong>you hereby waive any and all policies, terms, conditions, or contractual provisions governing products, services, websites or datasets you own or operate that would otherwise prohibit, restrict, or place conditions upon GitHub's Access</strong>… You further agree <strong>not to impose technical or other targeted measures to restrict or retaliate against such Access.</strong>"</p>
</blockquote>

<p>Read that carefully. If GitHub decides to scrape your content for AI training, you are contractually prohibited from using technical means — <code>robots.txt</code>, rate limiting, access controls — to stop it. Any protective clauses in your own terms of service are pre-emptively voided.</p>

<p>Adding <code>.github/copilot-ignore</code>, custom TDM restriction language in your license, or a NoAI License variant does not protect you from GitHub's own AI systems under this clause.</p>

<h2>Privacy: The Telemetry You Never Agreed To</h2>

<p>GitHub collects substantial behavioural and personal data from every user interaction — even on public repositories. Copilot's Additional Products Terms are explicit:</p>

<p><small><em>Highlighted: data GitHub collects about you</em></small></p>
<blockquote>
<p><cite>GitHub Additional Products Terms — Copilot</cite></p>
<p>"GitHub Copilot may collect and process data… this may include <strong>Prompts, Suggestions, and code snippets</strong>, and will collect additional usage information tied to your Account — this may include <strong>Service Usage Information, Website Usage Data, and Feedback Data. This may include personal data.</strong></p>
<p>For GitHub Copilot Free users, the data collected by GitHub Copilot may be used for AI Model training where permitted and if you allow in your settings."</p>
</blockquote>

<p>Not only your hosted code, but your coding <em>behaviour</em> — what you type, accept, reject, and how long you pause — becomes training signal for a commercial product. Copilot Business and Enterprise customers received a 2024 contractual update confirming GitHub will not use inputs or outputs for model training "unless instructed in writing to do so." Free and personal plan users receive no such protection. It is a two-tier system that monetises the privacy of developers who cannot afford paid plans.</p>

<h2>Copyright Erosion in the Age of Copilot</h2>

<p>The class action <em>Doe v. GitHub</em> argued that Copilot violated developer rights by reproducing licensed code without attribution, directly breaching MIT, GPL, and Apache 2.0 terms that require credit. Courts have not settled this — but individual developers cannot afford to litigate it.</p>

<p>U.S. copyright law protects original expression — including source code — even when publicly accessible. The EU Copyright Directive's Article 4 requires explicit authorisation for text and data mining; most commercial AI training falls outside its research exceptions. Public availability does not equal permission.</p>

<h2>GitHub vs. SourceHut</h2>

<table>
<thead>
<tr>
<th>Criterion</th>
<th>GitHub (Microsoft)</th>
<th>SourceHut (sr.ht)</th>
</tr>
</thead>
<tbody>
<tr><td>Business model</td><td>Free users = product; sell Copilot</td><td>Subscriptions — you are the customer</td></tr>
<tr><td>AI training on code</td><td>Yes — ToS Section D.8</td><td>No AI products; no training use</td></tr>
<tr><td>Platform source</td><td>Proprietary</td><td>Fully open-source (AGPL)</td></tr>
<tr><td>Telemetry</td><td>Extensive (41+ scripts/page)</td><td>Minimal, privacy-first</td></tr>
<tr><td>Takedown risk</td><td>At Microsoft's discretion</td><td>Self-host a fork if needed</td></tr>
<tr><td>Workflow lock-in</td><td>Proprietary issues/PRs</td><td>Native git email workflow</td></tr>
<tr><td>Financial transparency</td><td>None</td><td>Annual public reports</td></tr>
<tr><td>Issue archive</td><td>Proprietary silo, no export standard</td><td>public-inbox.org compatible</td></tr>
</tbody>
</table>

<h2>How to Migrate to SourceHut</h2>

<p><a href="https://sourcehut.org">SourceHut</a> is a suite of open-source developer tools funded by subscriptions. The migration has four parts: repositories, issues, mailing list archival, and CI pipelines.</p>

<h3>Part 1 — Migrate Repositories with gh2srht</h3>

<p><a href="https://sr.ht/~emersion/gh2srht/">gh2srht</a>, written by Simon Ser (<code>~emersion</code>), automates bulk migration of GitHub repositories — including issues and labels — directly to SourceHut. Install it via Go:</p>

<pre><code>go install git.sr.ht/~emersion/gh2srht@latest</code></pre>

<p>Export your GitHub and SourceHut tokens as environment variables:</p>

<pre><code># github.com/settings/tokens — needs: repo, read:org
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

# meta.sr.ht/oauth — needs: repos:write
export SRHT_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"</code></pre>

<p>Run gh2srht to migrate all repositories for a GitHub user:</p>

<pre><code># Migrate all public repos
gh2srht -github-user yourghuser -srht-user ~yoursrhtuser

# Or migrate a single repository
gh2srht -github-repo yourghuser/myrepo -srht-user ~yoursrhtuser</code></pre>

<p>gh2srht creates the SourceHut repositories, pushes all branches and tags, and migrates issues with labels intact. For repositories needing manual handling:</p>

<ol>
<li>
Clone as a bare mirror:
<pre><code>git clone --mirror https://github.com/youruser/yourrepo.git
cd yourrepo.git</code></pre>
</li>
<li>
Add the SourceHut remote and push. SourceHut auto-creates the repo on first push if it does not exist:
<pre><code>git remote add srht git@git.sr.ht:~youruser/yourrepo
git push srht --mirror</code></pre>
</li>
<li>
Update your local origin:
<pre><code>git remote set-url origin git@git.sr.ht:~youruser/yourrepo</code></pre>
</li>
<li>
Archive on GitHub via <em>Settings &#x2192; Danger Zone &#x2192; Archive this repository</em>, then update your README:
<pre><code>## Repository Moved

Canonical development is now at:
https://git.sr.ht/~youruser/yourrepo

This GitHub mirror is archived and read-only.</code></pre>
</li>
</ol>

<h3>Part 2 — Durable Archives with public-inbox</h3>

<p><a href="https://public-inbox.org">public-inbox.org</a> is an archival and indexing system for public mailing lists that makes every thread permanently searchable over HTTPS, NNTP, and IMAP. GitHub Issues exist entirely within GitHub's proprietary silo — if GitHub removes your repository or goes offline, your issue history vanishes. public-inbox provides a durable, decentralised archive that no platform can take away.</p>

<pre><code># Clone source from the canonical repository
git clone https://public-inbox.org/public-inbox.git
cd public-inbox

# Install required Perl dependencies (Perl 5.12+, Git 1.8+)
# Core: DBD::SQLite (IMAP/NNTP/threading), URI (HTML/Atom output)
# Optional but recommended: Plack (HTTP interface), Xapian (full-text search)
#
# On Debian/Ubuntu:
#   sudo apt install perl libdbd-sqlite3-perl liburi-perl \
#     libplack-perl libsearch-xapian-perl
# On Alpine:
#   apk add perl perl-dbd-sqlite perl-uri perl-plack
# Or install via cpan:
#   cpan DBD::SQLite URI Plack Search::Xapian

# Build, test, and install to /usr/local
perl Makefile.PL
make
make test
sudo make install

# --- Unprivileged / minimal install (symlinks into $HOME/bin) ---
perl Makefile.PL
make symlink-install prefix=$HOME

# Initialise an inbox for your project list
public-inbox-init -V2 myproject \
/srv/public-inbox/myproject \
https://lists.sr.ht/~youruser/myproject-devel \
myproject-devel@lists.sr.ht

# Subscribe the inbox via LMTP — add to your MTA's aliases:
myproject-devel: "|/usr/bin/public-inbox-mda --no-precheck"

# Start the HTTPS read interface
public-inbox-httpd --listen 0.0.0.0:8080</code></pre>

<h3>Part 3 — Export GitHub Issues to public-inbox</h3>

<p>gh2srht migrates issues to <code>todo.sr.ht</code> automatically. To also inject them into your public-inbox archive:</p>

<pre><code># Export issues as JSON via the GitHub CLI
gh issue list --repo youruser/yourrepo \
--json number,title,body,state --limit 1000 > issues.json

# Convert to mbox format
python3 issues2mbox.py issues.json > issues.mbox

# Inject into public-inbox
public-inbox-inject /srv/public-inbox/myproject &lt; issues.mbox</code></pre>

<h3>Part 3b — Decentralized Project Management with git-bug</h3>

<p><a href="https://github.com/src-d/git-bug" rel="noopener">git-bug</a> is a
platform‑independent issue tracker that stores issues, comments, and
metadata as native git objects inside your repository. There are no
separate files or web UI; the entire project management history lives in
the git database, pushes and pulls with any standard remote, and works
offline. A bridge for GitHub exists today, and an open feature request
for a <em>SourceHut</em> bridge can be found in
<a href="https://github.com/src-d/git-bug/issues/1024" rel="noopener">issue
#1024</a> (area/bridge · kind/feature · priority/important-longterm).  An
active pull request, <a href="https://github.com/src-d/git-bug/pull/1499" rel="noopener">PR
#1499</a>, is adding native todo.sr.ht GraphQL synchronization; until that
lands the GitHub bridge can still push SourceHut by mirroring your repo.</p>

<p>Installation is simple:</p>
<pre><code># Go
GO111MODULE=on go install github.com/src-d/git-bug/cmd/git-bug@latest
</code></pre>

<p>Basic usage:</p>
<pre><code>git bug user create
git bug add "Issue title"
git bug ls          # list issues
git bug termui      # curses interface
git bug webui       # browser UI
</code></pre>

<p>To import an existing GitHub project, configure the bridge and pull the
data using your GitHub token:</p>
<pre><code>git bug bridge configure github \
--repo youruser/yourrepo --token $GITHUB_TOKEN

# fetch issues, comments, labels, and users
GitHub bridge pulling…
</code></pre>

<p>Because issues are stored in refs, pushing to SourceHut carries them
automatically; a simple <code>git push srht --mirror</code> will include
the <code>refs/git-bug/*</code> namespace.  The SourceHut bridge status
remains open: see <a href="https://github.com/src-d/git-bug/issues/1024" rel="noopener">issue
#1024</a> for the SourceHut-specific work and the linked
<a href="https://github.com/src-d/git-bug/pull/1499" rel="noopener">PR
#1499</a> for the todo.sr.ht sync.</p>

<h3>Part 4 — CI Pipelines on builds.sr.ht</h3>

<p>Replace <code>.github/workflows/*.yml</code> with a <code>.build.yml</code> at your repository root:</p>

<pre><code>image: alpine/edge
packages:
- make
- gcc
- git
sources:
- https://git.sr.ht/~youruser/yourrepo
tasks:
- build: |
cd yourrepo
make all
- test: |
cd yourrepo
make test
- lint: |
cd yourrepo
make lint</code></pre>

<h3>Part 4b — Bridge CI During Transition with hottub</h3>

<p>If you are running a gradual migration and still have a GitHub mirror active, <a href="https://github.com/emersion/hottub">hottub</a> — also by Simon Ser (<code>~emersion</code>) — acts as a CI bridge that forwards GitHub Check run events to <code>builds.sr.ht</code>. This lets you keep GitHub as a read-only mirror for contributors who haven't switched yet, while all actual CI runs execute on SourceHut. A <a href="https://hottub.emersion.fr/">public hosted instance</a> is available if you don't want to self-host.</p>

<h4>Step 1 — Register a GitHub App for the Checks API</h4>

<p>Open the <a href="https://github.com/settings/apps/new">GitHub App registration page</a> and configure it as follows:</p>

<ul>
<li>Set a name and homepage URL for your instance</li>
<li>Leave the callback URL empty</li>
<li>Set the <strong>Setup URL</strong> to <code>https://&lt;your-domain&gt;/post-install</code></li>
<li>Set the <strong>Webhook URL</strong> to <code>https://&lt;your-domain&gt;/webhook</code></li>
<li>Under <em>Repository permissions</em>, grant: <strong>Checks</strong> (read/write), <strong>Commit statuses</strong> (read/write), <strong>Contents</strong> (read-only), <strong>Metadata</strong> (read-only), <strong>Pull requests</strong> (read-only)</li>
<li>Under <em>Subscribe to events</em>, check: <strong>Check run</strong>, <strong>Check suite</strong>, <strong>Pull request</strong></li>
</ul>

<h4>Step 2 — Collect credentials</h4>

<p>From the app settings page, note the <strong>App ID</strong> and optional <strong>Webhook secret</strong>. Then generate and download a PEM private key — you'll pass this file to hottub at startup.</p>

<h4>Step 3 — Build and start hottub</h4>

<pre><code># Clone and build
git clone https://github.com/emersion/hottub
cd hottub
go build

# Run with your GitHub app credentials
./hottub \
-gh-app-id &lt;app-id&gt; \
-gh-private-key &lt;path/to/private-key.pem&gt; \
-gh-webhook-secret &lt;webhook-secret&gt;</code></pre>

<p>Optionally, register an <a href="https://meta.sr.ht/oauth2/client-registration">sr.ht OAuth2 client</a> (redirection URI: <code>https://&lt;your-domain&gt;/authorize-srht</code>) to improve the user authorisation flow, then pass its credentials:</p>

<pre><code>./hottub \
-gh-app-id &lt;app-id&gt; \
-gh-private-key &lt;path/to/private-key.pem&gt; \
-gh-webhook-secret &lt;webhook-secret&gt; \
-metasrht-client-id &lt;client-id&gt; \
-metasrht-client-secret &lt;client-secret&gt;</code></pre>

<h4>Step 4 — Install the app on your GitHub repositories</h4>

<p>From the GitHub App page, click <em>Install App</em> and select the repositories you want to bridge. Once installed, any Check run triggered on GitHub will be forwarded to <code>builds.sr.ht</code> and results reported back to the GitHub PR or commit status — giving contributors a familiar green/red check while your CI runs entirely outside GitHub's infrastructure.</p>

<p>Once the migration is complete and contributors have followed to SourceHut, you can remove the GitHub App installation and archive the mirror entirely.</p>

<h3>Part 5 — Harden Against AI Scrapers</h3>

<p>Even on SourceHut, assert your rights explicitly at the license level. Append a TDM restriction clause to your <code>LICENSE</code> file:</p>

<pre><code>AI TRAINING RESTRICTION
-----------------------
You may not use, reproduce, or exploit this software or any portion thereof
for text and data mining, including training, fine-tuning, evaluating, or
distilling artificial intelligence or machine learning models, without
explicit written permission from the copyright holder(s).</code></pre>

<p>Add opt-out signals that tooling and crawlers recognise:</p>

<pre><code># package.json
{ "ai-training-opt-out": true, "tdm-reservation": "1" }

# pyproject.toml
[tool.metadata]
ai-training-opt-out = true

# .well-known/ai.txt (at your domain root)
User-agent: *
Disallow: /
NoAITrain: true</code></pre>

<h2>Taking Your Code Back</h2>

<p>GitHub's Section D.8 is not an accident or oversight. It is the monetisation mechanism: your publicly hosted code is raw material for Copilot, sold to enterprises at scale. The TOS pre-emptively voids any protective terms you write into your own licenses and prohibits the technical countermeasures you might otherwise deploy.</p>

<p>SourceHut offers a different compact. You pay a subscription, you receive a service, the platform's incentives align with yours. The source code is open. The financials are public. Your mailing list archive lives in public-inbox — a standard, self-hostable system independent of any corporate platform. There is no Copilot.</p>

<p>Migration takes an afternoon. The tools are solid: <strong>gh2srht</strong> handles repositories and issues in bulk; <strong>public-inbox</strong> gives every project a permanent, decentralised archive. The privacy, copyright integrity, and alignment of incentives you receive in return are worth considerably more than the time it takes.</p>

<p>
<strong>Resources:</strong><br>
<a href="https://sourcehut.org" rel="noopener">sourcehut.org</a> — official site, documentation, and subscription<br>
<a href="https://sr.ht/~emersion/gh2srht/" rel="noopener">sr.ht/~emersion/gh2srht/</a> — GitHub &#x2192; SourceHut migration tool by Simon Ser<br>
<a href="https://public-inbox.org" rel="noopener">public-inbox.org</a> — self-hosted mailing list archival and indexing<br>
<a href="https://github.com/src-d/git-bug" rel="noopener">github.com/src-d/git-bug</a> — git-bug distributed issue tracker (see issue #1024 for SourceHut bridge)<br>
<a href="https://docs.github.com/en/site-policy/github-terms/github-terms-of-service" rel="noopener">docs.github.com/site-policy</a> — GitHub ToS (read Section D.8)<br>
<a href="https://github.com/src-d/git-bug/issues/1024" rel="noopener">Issue #1024</a> — open feature request for SourceHut bridge<br>
<a href="https://github.com/src-d/git-bug/pull/1499" rel="noopener">PR #1499</a> — todo.sr.ht GraphQL sync work in progress
</p>
