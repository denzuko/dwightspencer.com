+++
title       = "Owning Your Memory: Hardened Arenas, Channels, and Structural OOP in Pure C99"
date        = "2026-05-29"
draft       = false
description = "Reference-counted arena, non-blocking channel, and structural OOP dispatch in ISO C99. Zero external dependencies, zero heap, all ten NASA Power of Ten rules applied. Companion source included."
slug        = "11-owning-your-memory"
keywords    = ["c99", "arena allocator", "memory safety", "supply chain", "nasa power of ten", "systems programming", "devops", "infosec", "open source", "sovereignty"]
tags        = ["c99", "systems", "devops", "infosec", "architecture", "open-source", "privacy", "sovereignty"]
categories  = ["articles"]
series      = ["Infrastructure Independence"]
schema_type = "TechArticle"
aeo_expertise = "DevOps, Security, Open Source, Systems Programming, C99"
aliases     = ["/11-owning-your-memory/"]
og_image    = "/assets/og-posts.png"

[[diagrams]]
  title   = "Architecture overview: coding standards, arena, object lifecycle, channel, assert, single-exit"
  alt     = "Architecture flowchart for example.c. Four standards layers feed into the implementation: ISO C99, all ten NASA Power of Ten rules, tsoding conventions (Yoda conditions, zero-init arenas), and project rules (no system calls, no goto in C, BDD-first workflow). The static arena holds eight typed slots. Objects are allocated by scanning for a free slot, retained by incrementing a ref_count, and released by decrementing it — zeroing the payload and freeing the slot when the count reaches zero. INVALID_HANDLE is UINT16_MAX. The channel is a ring buffer living in slot zero; send retains and enqueues, recv dequeues and transfers ownership to the caller. Assertions trap via __builtin_trap, which emits ud2 on x86 and raises SIGILL. Single-exit is a do-while-zero loop with break on error; cleanup releases any live handles unconditionally."
  caption = "Post 11 architecture: standards layer → arena → object lifecycle → channel → hardened assert → single-exit cleanup"

[related_post]
  slug  = "09-after-the-canary"
  label = "post 09 covers warrant canary infrastructure and what happens when the standards body disappears"
+++

<p class="meta"><em>Assumes working familiarity with C, a basic tolerance for
explicit memory ownership, and an interest in what happens when you take
the phrase &#8220;auditable in one sitting&#8221; literally.</em></p>

<p>Language migrations do not eliminate memory-safety problems; they move
them. The CVEs follow the toolchain: the allocator, the package registry,
the compiler plugin ecosystem, the language runtime. Each new dependency
chain is a new attack surface with a different owner and a different
disclosure timeline.</p>

<p>This post documents the implementation of a reference-counted arena,
a non-blocking channel, and structural OOP dispatch in ISO C99 with
zero external dependencies. The same patterns appear in avionics runtimes,
hypervisors, and the systems software that production infrastructure
runs on.</p>

<h2 id="supply-chain">Dependency graph as attack surface</h2>

<p>Before the code: a threat model.</p>

<p>Every dependency is a trust boundary. A Rust crate, a Go module, a
Node package &#8212; each runs with the process&#8217;s privileges at build time or
runtime. Package registries have been compromised; maintainer accounts have
been taken over; malicious versions have shipped to production. The NVD
has the receipts.</p>

<p>The complete dependency graph for <code>example.c</code>:</p>

<pre><code>&lt;stdio.h&gt;   — your libc
&lt;stdint.h&gt;  — your libc
&lt;string.h&gt;  — your libc
</code></pre>

<p>That is the entire supply chain. Provenance is the C standard and the
POSIX libc the OS ships. No registry, no lockfile, no package manifest.</p>

<h2 id="coding-standards">Coding standards in force</h2>

<p>The code in this post applies a documented, layered set of standards.
Each layer is enforceable &#8212; via OPA/Rego AST gates, LSP diagnostics,
or CI policy checks &#8212; before a line of implementation code is written
or merged. Understanding them is prerequisite to reading the implementation.</p>

<p><strong>ISO C99 (ISO/IEC 9899:1999)</strong> &#8212; the base language standard. No GNU
extensions, no <code>__attribute__</code>, no C11 atomics. Every construct is valid
under <code>-std=c99 -Wall -Wextra -Wpedantic</code> with zero warnings on GCC and Clang.</p>

<p><strong>NASA Power of Ten</strong> (Gerard Holzmann, JPL, 2006) &#8212; ten rules for
safety-critical C. All ten are in force; the codebase addresses each:</p>

<ul>
<li><em>Rule 1</em>: No complex flow constructs &#8212; no <code>setjmp</code>, no recursion.
Single-exit is achieved via <code>do&#x7B;&#x7D;while(0)</code> with <code>break</code> on error paths,
not <code>goto</code>. The C code contains no <code>goto</code> statements.</li>
<li><em>Rule 2</em>: All loops have a fixed, explicit upper bound. Every <code>for</code> loop
iterates over <code>ARENA_SLOTS</code> or <code>CHAN_CAPACITY</code> &#8212; compile-time constants.
No unbounded <code>while</code> anywhere.</li>
<li><em>Rule 3</em>: No dynamic memory allocation after initialisation.
<code>malloc()</code>, <code>calloc()</code>, <code>realloc()</code> do not appear anywhere.</li>
<li><em>Rule 4</em>: No function longer than 60 lines. Every function in
<code>example.c</code> fits comfortably within this limit and does one thing.</li>
<li><em>Rule 5</em>: Assertion density &#8805; 2 per function on average. Every public
function opens with <code>H_ASSERT</code> guards on every parameter.</li>
<li><em>Rule 6</em>: Minimal variable scope. Variables are declared at the top of
their enclosing block; no variable outlives its owning scope.</li>
<li><em>Rule 7</em>: Check the return value of every non-void function.
<code>channel_send()</code> and <code>channel_recv()</code> both return <code>int</code>; <code>main()</code>
checks both with explicit <code>break</code> on failure.</li>
<li><em>Rule 8</em>: Preprocessor use limited to includes and simple macros.
<code>H_ASSERT</code> is the only non-trivial macro; no conditional compilation,
no token-pasting, no variadic macros.</li>
<li><em>Rule 9</em>: Pointer dereference limited to one level per expression.
<code>arena_get_ptr()</code> returns a flat pointer; callers cast once at the
call-site and do not chain arrow operators.</li>
<li><em>Rule 10</em>: All code compiles with all warnings enabled.
<code>-std=c99 -Wall -Wextra -Wpedantic</code> produces zero warnings on GCC and Clang.</li>
</ul>

<p><strong>Tsoding style conventions</strong> &#8212; drawn from Alexey Kutepov&#8217;s public codebase
practice: arena allocators initialised as <code>= {0}</code>, Yoda conditions
throughout (<code>0 == condition</code>, <code>INVALID_HANDLE != found</code>), single-header
zero-dependency library philosophy, <code>sv.h</code> string views where string
handling is needed.</p>

<p><strong>Project-specific rules</strong> (enforced via OPA/Rego AST gates, CycloneDX SBOM
generation, and LSP diagnostics &#8212; the same checks run whether triggered by
a developer, an LLM agent, or CI/CD):</p>

<ul>
<li>No <code>system()</code>, <code>popen()</code>, or <code>exec*()</code> family calls &#8212; caught by Rego
AST gate before the BDD test cycle starts</li>
<li>No <code>goto</code> in C code. Single-exit is <code>do&#x7B;&#x7D;while(0)</code> + <code>break</code>;
<code>goto</code> is reserved for shell scripts (tcsh) where it is idiomatic</li>
<li>BDD-first: Rego policy gate &#8594; xUnit test &#8594; code &#8594; changelog &#8594; merge &#8594; tag.
No code before the gate and tests pass. This applies equally to human
and automated contributors.</li>
<li>Sandbox where the target OS supports it: OpenBSD <code>pledge</code>/unveil,
FreeBSD Capsicum, Linux seccomp &#8212; selected at compile time via
<code>#ifdef HAS_SANDBOX</code></li>
<li><code>/* */</code> block comments throughout; no <code>//</code> C++ line comments</li>
<li><code>INVALID_HANDLE</code> is <code>UINT16_MAX</code>, never the arena capacity</li>
<li>CycloneDX SBOM generated on every build; dependency graph stays
at three entries: <code>stdio.h</code>, <code>stdint.h</code>, <code>string.h</code></li>
</ul>

<h2 id="architecture">Architecture at a glance</h2>

<p>The full ownership and data flow across the pipeline:</p>

```mermaid
flowchart TD
    subgraph Standards["Coding Standards Layer"]
        C99["ISO C99\n-std=c99 -Wall -Wextra -Wpedantic"]
        NASA["NASA Power of Ten\nRules 2·3·5·7·9"]
        TSODING["Tsoding Style\nYoda · arena={0} · sv.h"]
        PROJ["Project Rules\nno system() · no goto · BDD-first · block comments"]
    end

    subgraph Arena["Static Arena — g_arena[8]"]
        direction LR
        S0["Slot 0\nOBJ_TYPE_CHANNEL\nref=1"]
        S1["Slot 1\nOBJ_TYPE_PRINTER\nref=1→0→free"]
        S2["Slot 2\nOBJ_TYPE_PRINTER\nref=1"]
        S3["Slots 3–7\nOBJ_TYPE_FREE"]
    end

    subgraph Lifecycle["Object Lifecycle"]
        ALLOC["arena_alloc(type)\nO(n) free-slot scan\nref_count=1"]
        RETAIN["object_retain(h)\nref_count++\nguard: < UINT16_MAX"]
        RELEASE["object_release(h)\nref_count--\nif 0: memset + FREE"]
        SENTINEL["INVALID_HANDLE\n= UINT16_MAX\nnot ARENA_SLOTS"]
    end

    subgraph Channel["Channel — ring buffer in slot 0"]
        SEND["channel_send()\nretain item\nenqueue tail"]
        RECV["channel_recv()\ndequeue head\nreturn handle"]
        RING["head · tail · count\nCHAN_CAPACITY=4"]
    end

    subgraph Assert["Hardened Assert"]
        HASSERT["H_ASSERT(cond)\n→ hardened_assert()"]
        TRAP["__builtin_trap()\n→ SIGILL x86·ud2\ncore dump · no spin"]
    end

    subgraph Exit["Single-Exit Pattern"]
        BAIL_M["do{}while(0)+break\nno goto · no labels"]
        CLEANUP["cleanup block\nrelease live handles\nreturn rc"]
    end

    C99 & NASA & TSODING & PROJ --> Arena
    ALLOC --> S0 & S1 & S2
    S1 -->|"scope release"| RELEASE
    SEND -->|"retain then enqueue"| S1
    RECV -->|"dequeue — caller owns"| S2
    RELEASE -->|"ref=0"| S3
    HASSERT -->|"violation"| TRAP
    BAIL_M --> CLEANUP
```

<h2 id="arena-model">The arena model</h2>

<p>A memory arena is a fixed-size pool of typed slots carved out of static
storage at compile time. <code>g_arena</code> is an array of eight <code>ArenaSlot</code>
structures. It lives in BSS. The linker knows its size at link time. No
<code>mmap</code>, no <code>brk</code>, no surprises.</p>

<pre><code>static ArenaSlot g_arena[ARENA_SLOTS];
</code></pre>

<p>Each slot is 72 bytes: a <code>uint16_t</code> reference count (2 bytes), an
<code>ObjectType</code> enum (4 bytes), 2 bytes of struct padding, and a 64-byte
aligned payload buffer. Eight slots occupy 576 bytes &#8212; well within L1
cache on any modern processor, though not a single cache line.</p>

<p>The payload alignment is guaranteed by a standard C99 union trick: a union
is always aligned to its coarsest member. Placing a <code>uint64_t</code> alongside
the <code>uint8_t</code> array forces 8-byte alignment with no compiler extensions:</p>

<pre><code>typedef union {
    uint64_t force_align;
    uint8_t  bytes[SLOT_SIZE];
} AlignedBuffer;
</code></pre>

<p>Allocation is a bounded O(n) free-slot scan &#8212; not a bump pointer, which
would require a separate free-list for reclamation. The scan is bounded by
<code>ARENA_SLOTS</code>, a compile-time constant, satisfying NASA Rule 2. If no free
slot exists, <code>H_ASSERT</code> fires immediately; the arena does not silently
return <code>NULL</code> for callers to ignore.</p>

<h2 id="reference-counting">Reference counting without a garbage collector</h2>

<p>The slot carries a <code>ref_count</code>. <code>object_retain()</code> increments it;
<code>object_release()</code> decrements it. When the count hits zero, the payload is
zeroed with <code>memset</code> and the type tag resets to <code>OBJ_TYPE_FREE</code>. The slot
is immediately reusable. No GC pause, no safepoint, no stop-the-world.</p>

<p>Two invariants protect the counter from integer overflow:</p>

<pre><code>H_ASSERT(g_arena[handle].ref_count &lt; UINT16_MAX); /* in retain  */
H_ASSERT(0U &lt; g_arena[handle].ref_count);          /* in release */
</code></pre>

<p>The sentinel for &#8220;no object&#8221; is <code>UINT16_MAX</code>, not <code>ARENA_SLOTS</code>. Using
the arena capacity as a sentinel is a latent bug: grow the arena past the
old capacity and previously safe code silently aliases the sentinel into a
valid slot index. <code>UINT16_MAX</code> (65535) is structurally outside any realistic
slot range.</p>

<h2 id="assertions">Hardened assertions: <code>__builtin_trap()</code> over <code>while(1)</code></h2>

<p>NASA Rule 5 demands high assertion density. The standard <code>&lt;assert.h&gt;</code> is
implementation-defined on embedded targets and routinely stripped in
production builds via <code>-DNDEBUG</code>. Rolling our own gives complete control:</p>

<pre><code>static void hardened_assert(int condition, int line)
{
    if (0 == condition) {
        (void)fprintf(stderr,
            "CRITICAL FAULT: invariant violation at line %d\n", line);
        __builtin_trap();
    }
}
</code></pre>

<p><code>__builtin_trap()</code> emits a hardware trap instruction. On x86/x86&#8209;64 Linux,
GCC generates <code>ud2</code> &#8212; an undefined instruction &#8212; which raises <code>SIGILL</code>
and produces a core dump. <code>SIGTRAP</code> is what <code>int3</code> (a software breakpoint)
raises; <code>ud2</code> is not a breakpoint. They are different instructions with
different signals.</p>

<p>A bare-metal safe-state handler that wants to halt the CPU until a watchdog
fires should use a bounded spin. A process-level fault handler should not:
an infinite loop blocks the supervisor, prevents core dump collection, and
burns CPU while hiding the fault. <code>__builtin_trap()</code> terminates immediately
and hands control to the OS.</p>

<h2 id="channels">Channels: Go concurrency semantics in C99</h2>

<p>Go&#8217;s channel model maps cleanly onto an arena-backed ring buffer. The
channel is itself an arena object (type tag <code>OBJ_TYPE_CHANNEL</code>). Its
payload holds a fixed-capacity queue of handles, a head index, a tail
index, and a count:</p>

<pre><code>typedef struct {
    object_handle_t queue[CHAN_CAPACITY];
    uint16_t        head;
    uint16_t        tail;
    uint16_t        count;
} Channel;
</code></pre>

<p><code>channel_send()</code> retains the item handle before enqueuing &#8212; the channel
owns a reference. <code>channel_recv()</code> dequeues and hands ownership to the
caller; the caller is responsible for releasing it. No implicit copying.
No dynamic allocation. The entire ownership transition is visible in
<code>ref_count</code> at any point.</p>

<p>This implementation is always non-blocking: <code>channel_send()</code> returns
<code>0</code> if the queue is full rather than blocking the caller. Go channels can
block on unbuffered sends; this is the non-blocking bounded variant &#8212;
correct for single-threaded pipelines where blocking would deadlock.</p>

<h2 id="structural-oop">Structural OOP: type safety without vtables</h2>

<p>Polymorphic dispatch in C usually means function pointers in a struct &#8212;
the vtable pattern. The pointer itself is a write target for control-flow
hijacking. Overwrite it with a ROP gadget and you have code execution.</p>

<p>The structural approach here uses a type tag in the slot header, checked
on every dereference:</p>

<pre><code>static void *arena_get_ptr(object_handle_t handle, ObjectType expected)
{
    H_ASSERT(handle &lt; ARENA_SLOTS);
    H_ASSERT(expected == g_arena[handle].type);
    return (void *)&amp;g_arena[handle].payload.bytes[0];
}
</code></pre>

<p>Pass a <code>Printer</code> handle to a <code>Channel</code> function and the assertion fires at
the dereference boundary &#8212; not after silent type confusion propagates
through three call frames. One comparison per call. No writable function
pointer anywhere in the data structure. NASA Rule 9 compliance: one
subscript dereference to reach the payload, nothing chained past it.</p>

<h2 id="single-exit">Single-exit functions</h2>

<p>Every function has exactly one <code>return</code> statement. Error paths use
<code>do&#x7B;&#x7D;while(0)</code> with <code>break</code> &#8212; no <code>goto</code>, no labels, no macros required.
The cleanup block at the bottom of the loop runs on every exit path:</p>

<pre><code>int main(void)
{
    /* all handles initialised to INVALID_HANDLE */
    do {
        send_ok = channel_send(h_chan, h_printer_sent);
        if (1 != send_ok) { break; }
        /* ... */
        rc = 0;
    } while (0);

    /* cleanup — always runs */
    if (INVALID_HANDLE != h_printer_sent) { object_release(h_printer_sent); }
    if (INVALID_HANDLE != h_printer_rcvd) { object_release(h_printer_rcvd); }
    if (INVALID_HANDLE != h_chan)          { object_release(h_chan); }
    return rc;
}
</code></pre>

<p>The handles are initialised to <code>INVALID_HANDLE</code> at declaration. The cleanup
block checks before releasing. Whether <code>break</code> fires on the first step or
control reaches the end of the loop normally, the same release logic runs.
No resource leak on any path. Static analysis tools and auditors both find
this easier to verify than scattered early returns.</p>

<h2 id="download">Download and build</h2>

<pre><code>cc -std=c99 -Wall -Wextra -Wpedantic -o example example.c
./example
</code></pre>

<p><a href="/posts/11-owning-your-memory/example.c">example.c</a> &#8212; BSD-2-Clause, no external dependencies.</p>

<h2 id="threat-model">Threat model</h2>

<p>Moving memory management into a runtime, a borrow checker, or a GC
shifts the attack surface; it does not reduce it. The Rust toolchain,
the Go runtime, and the npm registry each have CVEs and supply chain
incidents on record.</p>

<p>C99 with zero external dependencies scopes the attack surface to the
language standard and the system libc. The nginx, OpenSSH, and Linux
kernel codebases are written in it. The patterns in this post &#8212;
static allocation, explicit ownership, bounded loops, dense assertions,
policy-enforced build gates &#8212; are what that work uses.</p>

