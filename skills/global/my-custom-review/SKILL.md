---
name: my-custom-review
description: Use when reviewing a pull request, a branch, or the working diff, when asked to re-review after the author pushed changes, when checking a diff against the project's CLAUDE.md or AGENTS.md conventions, or when asked what to make of review comments other people or bots already left on a PR.
---

# My Custom Review

## Overview

A review pass tuned to conventions and reuse, not just bugs.

**Core principle:** correctness review happens by default — a competent agent finds the races and the dead code on its own. The passes that get skipped are convention adherence, reuse of what already exists, and comment hygiene. Spend the effort there.

**Second principle, inherited from `superpowers:receiving-code-review`:** verify before reporting. A finding you have not checked against the codebase is a guess, and a guess costs the author more than silence.

## When to Use

- Reviewing a PR, a branch, or uncommitted work
- Re-reviewing after the author pushed changes
- Asked to judge review comments already on a PR (yours, a teammate's, CodeRabbit's)

**Not for:** receiving feedback on your own code (use `superpowers:receiving-code-review`), or a pure bug hunt with no convention angle (use `/code-review`).

## Step 0: Pin the Head, Check It Is Worth Reviewing

```bash
gh pr view <N> --json headRefOid,state,isDraft,mergedAt
```

Re-fetch the head SHA before reading anything and again before posting. PRs move while you review them; a stale SHA produces findings the author already fixed, which reads as carelessness. If it changed mid-review, say so and re-read rather than reporting from memory.

If the PR is **merged or closed**, lead with that. The review is now a follow-up list, not a gate, and anything unactionable on a merged PR is dropped rather than reported.

## The Six Passes

Run all six. The last three are the ones that get skipped.

| # | Pass | What to look for |
|---|---|---|
| 1 | **Correctness** | Races, unreachable states, fail-open turning fail-closed, dead code, values written but never read |
| 2 | **CLAUDE.md / AGENTS.md** | Read the project's instruction files first. Flag only what they state explicitly, and quote the line |
| 3 | **Library reuse** | A hand-rolled primitive the design system already ships. In a Vammo repo: never a custom Button, Modal, Dialog, Select, Input, Table, Checkbox — `@leopardaelectric/vammo-ui` has them |
| 4 | **In-repo reuse** | Before accepting any new component, hook, or helper, grep for one that already exists. `Callout` sat in `src/shared/ui/components/` while a PR was building its own notice box |
| 5 | **Comment hygiene** | See below |
| 6 | **External references** | See below |

### Pass 4: how to actually check reuse

Do not eyeball this. For each new component/hook/helper in the diff:

```bash
ls src/shared/ui/components/ src/shared/ui/hooks/
ls src/features/<feature>/ui/components/
grep -rn "<similar-name-or-concept>" src/shared src/features --include=*.tsx --include=*.ts -l
```

Also flag the same JSX block or handler pasted into 3+ files — that is a component or a hook that has not been extracted yet.

### Pass 5: comment hygiene

Flag a comment when:

- It restates what the code does instead of why it does it
- It narrates the change ("we used to read the balance, now we read quantity") — that belongs in the commit body, not the file
- It is 3+ lines of prose above something a rename would explain
- It sits inside a JSX prop or an expression — extract a variable instead
- It has drifted from the code it sits above

Keep a comment that carries a **why** the code cannot: a surprising contract, a non-obvious invariant, a deliberate trade-off. A JSDoc on an ambiguous optional prop usually earns its place; a 12-line narrative above a 4-line function does not.

Report density when it is the story: *"213 of 1619 added lines are comments; four blocks run 12+ lines."* A number lands harder than an adjective.

### Pass 6: external references

Flag any comment in the code that points outside the repo:

- "Reviewed with the PM", "as agreed with design", "per the PRD"
- Ticket IDs (`OPS-1234`) used as the explanation for the code
- Links to specs, Figma, Notion, tracker items, phase or wave numbers

The reader six months from now has none of those. The comment must stand alone in English or it must go. The reference belongs in the commit body or the PR description.

**Verify every reference you can reach, and read sibling PRs in full.** A reference is a claim, and claims are checkable:

- **Ticket IDs** — look the card up. A placeholder that never existed (`OPS-000`) or a closed card describing different work means the PR's stated purpose is unverified. Search the tracker for the real card and name it.
- **Sibling PRs in other repos** — read the diff, not the description. If this PR sends a field, open the consumer and confirm the field name, shape, and default match; if it receives one, open the producer and confirm something actually sets it.

Cross-repo facts routinely decide severity, and they are invisible from inside one repo. On one review, reading the caller's diff turned up the per-attempt timeout and the retry counter that made a "medium" finding a confirmed one, killed a false alarm (the caller already guarded the case), and promoted a third finding once the consumer's `forbidNonWhitelisted` was verified. None of that was visible in the repo under review.

## Verify Before You Report

Score each finding privately before it reaches the report. **Report only the two top tiers:**

- **Traced end to end** — you followed the path and it fires in practice
- **Verified, or named explicitly in an instruction file** — quote the line
- *Below that:* plausible but unverified → ask it as a question, labelled as one, or drop it

Drop entirely: pre-existing issues, anything a linter/typechecker/CI catches, nitpicks a senior would not raise, unmodified lines, intentional changes tied to the PR's purpose.

**Also drop repo-process observations** — commit message format, branch naming, PR size or scope creep, missing tests as a general complaint. They are not defects in the code under review, and on a merged PR they are unactionable. If a process problem is real and worth raising, it is a separate conversation, not a review finding.

## Triaging Comments Already on the PR

**Never delete a comment.** Mark only. Deleting is irreversible and visible to the team; the call belongs to whoever wrote it.

For each existing thread, verify the claim against the code the same way you verify your own, then give a verdict:

- **Holds** — real, and say in one line what makes it real
- **Reject** — technically wrong here, with the reasoning, not just the disagreement
- **Narrow** — the concern is real but the proposed fix overshoots

Bot comments get more skepticism, not less: they cite files they have not read. A suggestion that misapplies a framework concept (a React Query `enabled` flag on a hook that runs no query) is a reject with reasoning, not a soft "worth considering".

## Output Contract

Report to the terminal first. Post to the PR only when asked.

The report is, in order:

1. One line: what the change does and whether the shape is right
2. Findings, most severe first — each is: `file:line`, one sentence naming the defect, one sentence naming the fix
3. Questions, listed separately from findings and labelled as questions
4. If existing comments were triaged: a keep/reject/narrow table with a reason per row

When asked to post: one review with inline comments anchored to lines present in the diff, tagging the author. Group findings that land on the same line into one comment.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Only hunting bugs | Passes 3–6 are the point; bugs surface anyway |
| "Too many comments" with no count | Count the lines and the blocks |
| Proposing a component that already exists | Grep `src/shared` before proposing anything new |
| Flagging commit format or PR scope | Not a code finding. Drop it |
| Deleting a comment you disagree with | Mark it. Deleting is not yours to do |
