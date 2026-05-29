/*
 * arena_channel.c — Hardened arena + channel + structural OOP demo
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Style: tsoding (arena.h zero-init, sv.h, Yoda conditions), single-exit
 *        do{}while(0)+break, C99 only, no system()/popen()/exec*().
 *
 * Standards: ISO C99, NASA Rule subset (bounded loops, assertion density,
 *            single-exit functions, no dynamic allocation).
 */

/* ========================================================================= */
/* INCLUDES                                                                   */
/* ========================================================================= */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

/* ========================================================================= */
/* CONFIGURATION & ARCHITECTURE CONSTANTS                                     */
/* ========================================================================= */

#define ARENA_SLOTS    8U
#define SLOT_SIZE      64U
#define CHAN_CAPACITY  4U

/*
 * INVALID_HANDLE uses UINT16_MAX as the canonical sentinel so it is
 * trivially distinguishable from any valid slot index and survives
 * uint16_t arithmetic without wrapping into a valid range.
 */
#define INVALID_HANDLE ((object_handle_t)UINT16_MAX)

typedef uint16_t object_handle_t;

/* Type tags for structural-OOP polymorphic dispatch */
typedef enum {
    OBJ_TYPE_FREE    = 0,
    OBJ_TYPE_PRINTER = 1,
    OBJ_TYPE_CHANNEL = 2
} ObjectType;

/*
 * AlignedBuffer — 100% standard C99 alignment technique.
 * A union is always aligned to its coarsest member.  Placing uint64_t
 * inside the union aligns the 64-byte payload to an 8-byte boundary
 * without any compiler extensions.
 */
typedef union {
    uint64_t force_align;
    uint8_t  bytes[SLOT_SIZE];
} AlignedBuffer;

typedef struct {
    uint16_t      ref_count;
    ObjectType    type;
    AlignedBuffer payload;
} ArenaSlot;

/* Static allocation (no malloc, Rule-compliant) */
static ArenaSlot g_arena[ARENA_SLOTS];

/* ========================================================================= */
/* HARDENED ASSERTION (NASA Rule 5 — high assertion density)                 */
/* ========================================================================= */

/*
 * hardened_assert — C99-portable fault trap.
 * __builtin_trap() generates a hardware trap instruction (SIGTRAP/SIGILL)
 * on all supported toolchains (GCC, Clang) without requiring POSIX abort()
 * or an infinite spin loop.  On bare-metal targets replace with a
 * platform-specific safe-state entry point.
 */
static void hardened_assert(int condition, int line)
{
    if (0 == condition) {
        (void)fprintf(stderr,
            "CRITICAL FAULT: invariant violation at line %d\n", line);
        __builtin_trap();
    }
}

#define H_ASSERT(cond) hardened_assert((cond), __LINE__)

/* ========================================================================= */
/* MEMORY ARENA & REFERENCE COUNTING                                          */
/* ========================================================================= */

/*
 * arena_get_ptr — single-level, type-checked slot lookup.
 * Returns a typed void* — callers cast once at the call-site.
 * Rule 9 compliant: exactly one subscript dereference per call.
 */
static void *arena_get_ptr(object_handle_t handle, ObjectType expected)
{
    H_ASSERT(handle < ARENA_SLOTS);
    H_ASSERT(expected == g_arena[handle].type);
    return (void *)&g_arena[handle].payload.bytes[0];
}

/*
 * arena_alloc — deterministic O(1) slot allocation.
 * Panics via H_ASSERT if the arena is exhausted (bounded, Rule 2).
 */
static object_handle_t arena_alloc(ObjectType type)
{
    object_handle_t found = INVALID_HANDLE;
    uint16_t i = 0U;

    for (i = 0U; i < ARENA_SLOTS; i++) {
        if (OBJ_TYPE_FREE == g_arena[i].type) {
            g_arena[i].type      = type;
            g_arena[i].ref_count = 1U; /* implicit initial retain */
            found = i;
            break;
        }
    }

    H_ASSERT(INVALID_HANDLE != found);
    return found;
}

void object_retain(object_handle_t handle)
{
    H_ASSERT(handle < ARENA_SLOTS);
    H_ASSERT(OBJ_TYPE_FREE != g_arena[handle].type);
    H_ASSERT(g_arena[handle].ref_count < UINT16_MAX);

    g_arena[handle].ref_count++;
}

void object_release(object_handle_t handle)
{
    H_ASSERT(handle < ARENA_SLOTS);
    H_ASSERT(OBJ_TYPE_FREE != g_arena[handle].type);
    H_ASSERT(0U < g_arena[handle].ref_count);

    g_arena[handle].ref_count--;

    if (0U == g_arena[handle].ref_count) {
        /* Neutralise residual data before marking free */
        (void)memset(g_arena[handle].payload.bytes, 0, SLOT_SIZE);
        g_arena[handle].type = OBJ_TYPE_FREE;
    }
}

/* ========================================================================= */
/* CHANNEL — non-blocking, bounded, Go-style                                  */
/* ========================================================================= */

typedef struct {
    object_handle_t queue[CHAN_CAPACITY];
    uint16_t        head;
    uint16_t        tail;
    uint16_t        count;
} Channel;

object_handle_t channel_create(void)
{
    object_handle_t h    = arena_alloc(OBJ_TYPE_CHANNEL);
    Channel *const  chan = (Channel *)arena_get_ptr(h, OBJ_TYPE_CHANNEL);
    uint16_t        i    = 0U;

    chan->head  = 0U;
    chan->tail  = 0U;
    chan->count = 0U;

    for (i = 0U; i < CHAN_CAPACITY; i++) {
        chan->queue[i] = INVALID_HANDLE;
    }

    return h;
}

/* channel_send — non-blocking (chan <- item); returns 1 on success */
int channel_send(object_handle_t chan_h, object_handle_t item_h)
{
    Channel *const chan = (Channel *)arena_get_ptr(chan_h, OBJ_TYPE_CHANNEL);
    int success = 0;

    H_ASSERT(chan_h  < ARENA_SLOTS);
    H_ASSERT(item_h < ARENA_SLOTS);

    if (CHAN_CAPACITY > chan->count) {
        chan->queue[chan->tail] = item_h;
        object_retain(item_h);

        chan->tail++;
        if (CHAN_CAPACITY <= chan->tail) {
            chan->tail = 0U;
        }

        chan->count++;
        success = 1;
    }

    return success;
}

/* channel_recv — non-blocking (item, ok := <-chan); returns 1 on success */
int channel_recv(object_handle_t chan_h, object_handle_t *const out_h)
{
    Channel *const chan = (Channel *)arena_get_ptr(chan_h, OBJ_TYPE_CHANNEL);
    int success = 0;

    H_ASSERT(chan_h < ARENA_SLOTS);
    H_ASSERT(NULL  != out_h);

    if (0U < chan->count) {
        *out_h = chan->queue[chan->head];
        chan->queue[chan->head] = INVALID_HANDLE;

        chan->head++;
        if (CHAN_CAPACITY <= chan->head) {
            chan->head = 0U;
        }

        chan->count--;
        success = 1;
    } else {
        *out_h = INVALID_HANDLE;
    }

    return success;
}

/* ========================================================================= */
/* STRUCTURAL OOP — Printer class                                             */
/* ========================================================================= */

typedef struct {
    char message[40];
} Printer;

object_handle_t printer_create(const char *const init_msg)
{
    object_handle_t  h    = INVALID_HANDLE;
    Printer         *self = NULL;

    H_ASSERT(NULL != init_msg);

    h    = arena_alloc(OBJ_TYPE_PRINTER);
    self = (Printer *)arena_get_ptr(h, OBJ_TYPE_PRINTER);

    (void)strncpy(self->message, init_msg, sizeof(self->message) - 1U);
    self->message[sizeof(self->message) - 1U] = '\0';

    return h;
}

void printer_say_hello(object_handle_t h)
{
    const Printer *const self =
        (const Printer *)arena_get_ptr(h, OBJ_TYPE_PRINTER);

    H_ASSERT(h < ARENA_SLOTS);

    (void)printf("%s\n", self->message);
}

/* ========================================================================= */
/* MAIN — execution pipeline                                                  */
/* ========================================================================= */

int main(void)
{
    object_handle_t h_chan         = INVALID_HANDLE;
    object_handle_t h_printer_sent = INVALID_HANDLE;
    object_handle_t h_printer_rcvd = INVALID_HANDLE;
    int             send_ok        = 0;
    int             recv_ok        = 0;
    int             rc             = 1; /* assume failure; set 0 on success */

    /* 1. Initialise arena slots to a known-clean state */
    (void)memset(g_arena, 0, sizeof(g_arena));

    /* Single-exit pipeline — do{}while(0) with break on error.
     * All handle releases happen in the cleanup block below regardless
     * of which path exits the loop. No goto required. */
    do {
        /* 2. Create pipeline components */
        h_chan         = channel_create();
        h_printer_sent = printer_create("Hello, Pure ANSI C99 World via BSD!");

        /* 3. Dispatch object into channel */
        send_ok = channel_send(h_chan, h_printer_sent);
        if (1 != send_ok) {
            break;
        }

        /* 4. Current scope releases sender reference */
        object_release(h_printer_sent);
        h_printer_sent = INVALID_HANDLE;

        /* 5. Consumer receives from channel */
        recv_ok = channel_recv(h_chan, &h_printer_rcvd);
        if (1 != recv_ok) {
            break;
        }

        H_ASSERT(INVALID_HANDLE != h_printer_rcvd);

        printer_say_hello(h_printer_rcvd);
        object_release(h_printer_rcvd);
        h_printer_rcvd = INVALID_HANDLE;

        rc = 0; /* success */
    } while (0);

    /* 6. Release any handles still live — runs on every exit path */
    if (INVALID_HANDLE != h_printer_sent) {
        object_release(h_printer_sent);
    }
    if (INVALID_HANDLE != h_printer_rcvd) {
        object_release(h_printer_rcvd);
    }
    if (INVALID_HANDLE != h_chan) {
        object_release(h_chan);
    }

    return rc;
}
