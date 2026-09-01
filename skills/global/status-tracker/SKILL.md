---
name: status-tracker
description: Use when starting any multi-phase or multi-wave implementation — a PRD, spec, or feature large enough that it needs to be split into phases and atomic tasks — when asked to break a feature down into phases or atomic tasks, when a status tracker, progress dashboard, or implementation roadmap is requested, and again after each atomic task lands during work already covered by a tracker.
---

# Status Tracker

A tracker is the single artifact that survives the whole feature: every atomic task, what
spec paragraph caused it, its status, and the evidence left behind. Write it **before** the
first line of implementation code, and update it **as each task lands** — not at the end.

## When to use

- Work spans more than one sitting, or has phases with ordering constraints.
- A spec/PRD exists (or a plan from a planning agent) that must be traced to code.
- A tracker for this work already exists → the update protocol below applies.

Not for: single-commit fixes, bugs with one root cause, exploratory spikes.

## The artifact

Write one self-contained HTML file at repo root, named `<feature>-status.html`
(`<feature>-prd-status.html` when a PRD drives it). Copy `template.html` from this skill
directory and fill it in; it carries the styling, so never author the CSS from scratch.

Slots, in this order. Every one is REQUIRED unless marked:

1. `h1` feature name, and a `.sub` line: what this tracks · branch · generated date.
2. Spec link + owner + spec status + priority. *(omit only if no spec document exists)*
3. Legend: done / partial / not started.
4. Three count cards: done, partial, pending.
5. Progress bar: `N / TOTAL done`, integer percent, `aria-valuenow` matching.
6. Open questions table — `# │ What's ambiguous │ Assumption made to keep moving │ Blocks / risks │ Who`. *(include while ambiguities are open; delete the section once none are)*
7. One `h2` + table per phase. Header is exactly `ID │ Task │ <SPEC> § │ Status │ Evidence / Notes`, where `<SPEC>` is `PRD` when a PRD drives the work and `Spec` otherwise. Match whatever the repo's existing trackers already use.
8. `Out of scope` — one `.meta` paragraph, items separated by `·`.
9. `Suggested Build Sequence` — ordered list, each item naming the task IDs it covers.

## Phases and IDs

Phases are letter-prefixed `h2`s: `A.`, `B.`, `C.`… **`A` is always foundation**
(domain types, adapters, hooks, keys — whatever "nothing else compiles without this" means
in this stack). **The last phase is always `Verification & Polish`.** In between, one phase
per surface or capability, ordered so each depends only on earlier ones.

Task IDs are phase letter + number: `A1`, `C5`. Never renumber an existing ID — it may
already be cited in a commit or a review comment.

- A task that turns out to be three tasks → suffix them: `D1a`, `D1b`, `D1c`.
- New work discovered mid-flight → append to the phase (`C13`), or open a new lettered
  phase (`U. Updates`, `D2. …`) when it is a reworking of already-shipped phases.

## Atomic task = one reviewable commit

One type, one adapter method, one hook, one modal, one i18n batch across locales, one rule
plus its tests. If a row's Evidence column would need to cite three unrelated files for
three unrelated reasons, it is two or more tasks.

## Status vocabulary

Exactly four. `✅ Done` · `⚠️ Partial` · `❌ Not started` · `➖ N/A`, with the matching
`class="status done|partial|todo|na"`.

**Partial is not a nicer word for done.** It means the shape exists but something real is
missing — a stub, a fixture, a hardcoded response, a permission not yet gated. A Partial row
must say in Evidence what is missing.

## Evidence / Notes — the load-bearing column

It carries different content before and after implementation, and both are required:

| Row state | Evidence contains |
|---|---|
| Not started | `—`, or the approach/assumption decided in advance |
| Partial | exactly what is missing and what stands in for it (fixture name, stub path) |
| Done | `path/to/file.ts:120-164` **plus** any deviation from the spec and why |

The file path alone is not evidence. The reason a naming choice, a fallback, or a scope cut
was made is the part nobody can reconstruct from the diff six weeks later.

## Update protocol

**Update the tracker in the same turn the task lands.** Change the row's status, write its
Evidence, then recompute the three counts, `N / TOTAL`, the percent, and both places the
percent appears (`aria-valuenow` and the inline `width`).

**No exceptions:**
- Not "I'll batch the updates at the end of the phase."
- Not "the commit message already records it."
- Not "I'll update it when the user next asks about progress."
- Discovering unplanned work does not exempt you — add the row, then continue.

| Excuse | Reality |
|---|---|
| "I'll update several rows at once, it's more efficient" | Batched updates lose the *why*. Evidence written from memory is the part that goes missing. |
| "The counts are close enough" | A wrong percent makes the whole artifact untrustworthy. Recompute; it is arithmetic. |
| "This task wasn't in the plan, so it has no row" | Unplanned work is exactly what the tracker is for. Append it. |
| "Status is obvious from the code" | The tracker exists because it is not. |
| "I'll renumber the IDs so they're tidy" | IDs are cited externally. Suffix or append, never renumber. |

**Red flags — stop and update the tracker first:** you are about to report a task complete;
you are about to move to the next task; you just wrote a commit message; you are answering
"how far along are we?" from memory.

## Markdown fallback

When HTML cannot be previewed, or the repo has no HTML precedent, emit `<feature>-status.md`
with the same slots and order: `# ` title, an italic subtitle line, a `**Progress:** N / TOTAL
(P%)` line replacing cards and bar, `## ` per phase, and the identical five-column table.
Same IDs, same status vocabulary, same Evidence contract. Nothing about the discipline changes.

## Common mistakes

- Authoring bespoke CSS instead of copying `template.html` — trackers stop looking like one family.
- Descriptive phase count but vague tasks ("build the UI") — a task that can't be marked done in one commit is a phase.
- The `§` column left blank. If a task traces to no paragraph of the spec, say where it came from (a review comment, a discovered constraint) — that provenance is the point of the column.
- Deleting rows that turned out unnecessary. Mark them `➖ N/A` with the reason; a vanished row reads as forgotten work.
- Leaving the tracker at 100% when the last phase is untouched.
