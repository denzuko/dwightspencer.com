# dwightaspencer.com Architecture

## Site build pipeline

```mermaid
graph LR
    A[hugo/data/author.yaml] --> B[layouts/partials/finger.html]
    A --> C[layouts/index.lisp]
    A --> D[layouts/index.humans]
    A --> E[layouts/partials/head.html Schema.org]
    F[hugo/content/posts/*.md] --> C
    F --> G[layouts/_default/single.html]
    C --> H[/corpus.lisp auto-generated]
    D --> I[/humans.txt auto-generated]
    B --> J[index.html finger block]
    G --> K[/posts/NN-slug/]
    L[hugo/layouts/taxonomy/tag.terms.html] --> M[/tags/ frequency-weighted]
    N[hugo/static/lisp/*.lisp] --> O[Quicklisp dist at root]
```

## The Lisp system layers

```mermaid
graph TD
    L1["Layer 1: Homepage finger block
    defpackage DwightSpencerCom
    Real SBCL program"] --> L2

    L2["Layer 2: HTML source comment
    ;; (ql-dist:install-dist
       'http://dwightaspencer.com'
       :prompt nil)"] --> L3

    L3["Layer 3: PostScript polyglot
    DwightASpencerCom:render :ps
    Valid PS + CL comments + git bundle
    PoC||GTFO tradition"] --> L4

    L4["Layers 4-23: Reserved"]

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

    DW -- "Technology Chair RT4 only" --> RT4
    DW -- "Principal Da Planet only" --> DPS
    DPS -. "NEVER appears on" .-> DW
    RT4 -. "Chapter materials separate" .-> DW
```

## Content taxonomy (current + v2.5)

```mermaid
graph LR
    P[posts] --> T[tags]
    P --> CA[categories]
    P --> SE[series v2.5]
    P --> NC[nist_controls v2.5]
    P --> VE[venue v2.5]
    NC --> NI[/nist/AC-3/ etc]
    SE --> SI[Infrastructure Independence]
    SE --> SW[The Watchers You Fed]
    VE --> AR[arXiv]
    VE --> KD[KDP]
    VE --> HP[HPR episodes]
```
