# dwightaspencer.com Architecture

## Site build pipeline

```mermaid
graph LR
    A[hugo/data/author.yaml] --> B[partials/finger.html]
    A --> C[index.lisp]
    A --> D[index.humans]
    A --> E[partials/head.html]
    F[hugo/content/posts/*.md] --> C
    F --> G[_default/single.html]
    C --> H[/corpus.lisp Hugo-generated — at site root]
    D --> I[/humans.txt Hugo-generated]
    B --> J[index.html finger block]
    G --> K[/posts/NN-slug/]
    L[taxonomy/tag.terms.html] --> M[/tags/ frequency-weighted]
    N[taxonomy/series.terms.html] --> O[/series/ arc index]
    P[hugo/static/lisp/*.lisp] --> Q[Quicklisp dist: /distinfo.txt at root, /lisp/ for tgz+indexes]
    R[hugo build] --> S[npx pagefind]
    S --> T[/pagefind/ search index]
```

## GH Actions deploy pipeline

```mermaid
graph LR
    A[push to master] --> B[actions/checkout]
    B --> C[hugo --minify --gc]
    C --> D[npx pagefind --site public]
    D --> E[peaceiris/actions-gh-pages]
    E --> F[gh-pages branch]
    F --> G[Cloudflare CDN]
    G --> H[dwightaspencer.com]
```

## The Lisp system layers

```mermaid
graph TD
    L1["Layer 1: Homepage finger block
    defpackage :DwightASpencerCom
    Real SBCL program — plain pre/code"] --> L2

    L2["Layer 2: &lt;link rel=alternate type=application/vnd.quicklisp-dist&gt;
    href=http://dwightaspencer.com/distinfo.txt
    Survives Hugo --minify. Visible in view-source.
    HTML comments are stripped by minifier — link tag is the correct surface"] --> L3

    L3["Layer 3: PostScript polyglot
    DwightASpencerCom:render :ps
    Valid PS + CL comments + git bundle
    PoC‖GTFO tradition"] --> L4

    L4["Layers 4–23: Reserved"]

    subgraph CL System
        PKG[package.lisp] --> LE[logic-engine.lisp]
        LE --> CO[corpus.lisp Hugo-generated]
        CO --> RE[render.lisp PostScript only]
        RE --> DW[dwightaspencer.lisp entry points]
    end

    subgraph "dogfoods ml-prolog-pokemon"
        LE -. "same prolog-db struct" .-> MP[ml-prolog-pokemon/logic-engine]
        CO -. "same db-assert pattern" .-> CA[ml-prolog-pokemon/catalog]
    end
```

## Cloudflare interaction

```mermaid
graph TD
    S["<script data-cfasync=false>
    FOUC theme detection
    Must run before first paint"] -- "CF leaves alone" --> P[paint with correct theme]
    T["<script> no attribute
    DOMContentLoaded wiring"] -- "CF Rocket Loader rewrites type=hash" --> D[deferred — OK after paint]
    U["bare text node in head
    (historical bug — now fixed)"] -- "HTML5 foster-parenting" --> V[rendered visibly in body — was BUG, now resolved]
    W["Layer 2 as &lt;link rel=alternate&gt; in &lt;head&gt;"] -- "preserved by Hugo minifier" --> X[view-source readable — correct]
```

## Entity separation

```mermaid
graph TD
    DW["dwightaspencer.com
    Personal publishing platform
    ORCID + PGP identity only"]
    DPS["Da Planet Security
    dapla.net
    Commercial MSSP"]
    RT4["Restore The Fourth
    restorethe4th.com
    Civil liberties advocacy"]

    DW -- "Technology Chair, RT4 only" --> RT4
    DW -- "Principal, Da Planet Security only" --> DPS
    DPS -. "NEVER appears on" .-> DW
    RT4 -. "Chapter materials separate" .-> DW
```

## Content taxonomy (live)

```mermaid
graph LR
    P[posts] --> T[tags]
    P --> CA[categories]
    P --> SE[series]
    P --> VE[venue field only]
    T --> TI[/tags/ frequency-weighted]
    SE --> SI[/series/infrastructure-independence]
    SE --> SW[/series/the-watchers-you-fed]
    VE --> KD[KDP front matter only]
    VE --> HP[HPR front matter only]
```

## Pages (not in nav)

```mermaid
graph LR
    N[/now/] -- "quarterly update" --> WC[warrant canary renewal]
    PR[/projects/] -- "active + historical" --> ES[entity-separation compliant]
    U[/uses/] -- "HPR/aNONradio audience" --> IS[infra stack]
    PO[/posts/] -- "in nav" --> NAV[posts · tags · series · media]
```
