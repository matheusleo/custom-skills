# Engineering mode

## Branching & git hygiene
- Always branch before changing code. Never push to `main` / default branch directly.
- Read the repo's `AGENTS.md` / `CLAUDE.md` (and any README) BEFORE making non-trivial edits. Each Vammo repo has golden rules — respect them.
- **Front-load the prettier sweep** when starting a multi-commit refactor on a file. Pre-commit `lint --fix` will reformat the file when *any* commit touches it; if the file is non-prettier-clean to start, every subsequent commit on the same branch resurfaces the formatting diff and you'll burn 5+ revert cycles. **How to apply:** before starting work, run `npm run lint -- --fix <file>` and commit the result as `style(scope): apply prettier formatting` (no logic changes). Then begin the real work.

## Commits
- Conventional commit style: `fix(scope):`, `feat(scope):`, `refactor(scope):`, `docs(scope):`, `chore(scope):`, `test(scope):`, `style(scope):`.
- **One logical change per commit.** If `npm run lint` (which auto-fixes in many Vammo repos) modifies files unrelated to your change, **revert those before staging** — don't silently bundle them.
- Commit message body explains **why**, not what. The diff shows what.
- Prefer creating new commits over `--amend`, especially after a pre-commit hook failure (the failed commit didn't happen, so `--amend` would modify the *previous* commit and may destroy work).
- Never use `--no-verify` to skip hooks unless the user explicitly asks.

## Test-driven development
- Red → green → refactor. Always watch the red fail for the **right reason** — a failing-to-compile spec is not a meaningful red.
- **TDD with strict TypeScript: stub-first, not `(service as any)`.** Calling `service.newMethod()` in a spec before the method exists breaks compilation (TS2339), not just the test, and the entire suite stops loading. Bypassing with `(service as any)` works but loses the type-check on the spec, which is part of TDD's value in Nest. Pattern: before writing the test, add an empty stub to the class (`async newMethod(): Promise<X[]> { return []; }`). That's the RED — the test fails because the implementation is empty, not because TS rejects the spec. Then implement the body → GREEN.
- **Mocks that replace `prisma.$transaction` or the Prisma client strip every `$use` middleware** — encryption fail-closed, soft-delete, audit log, any transformation. If the function under test depends on middleware behavior (precondition, fail-closed, transformation), either (a) integration-test against a real Prisma instance, or (b) explicitly assert (via `invocationCallOrder` in vitest or equivalent) that the precondition runs before the query. Listing the middleware function in `vi.mock` without asserting it gets called is **not** coverage.
- Prefer integration-style tests for anything touching Prisma transactions or middleware behavior.
- Run the narrow spec while iterating: `npm run test -- <path-fragment>`. Run the full suite before committing: `npm run test`.

## Systematic debugging
Before proposing a fix:
1. **Reproduce** the bug deterministically. If you can't reproduce, you're guessing.
2. **Isolate** the smallest input or path that triggers it.
3. **Identify the root cause**, not just a surface symptom. "It works now" after a change you don't understand is not a fix.
4. **Verify the fix** by re-running the reproduction and confirming the symptom is gone — not by re-reading the diff.

Don't shotgun changes. Don't bypass safety checks (`--no-verify`, broad `try/catch`, deleting failing tests) as a shortcut to make the failure go away.

## Verification before completion
- Before claiming "done" / "fixed" / "passing" / before opening a PR or commit: run the verification commands, read the output, confirm what you claim.
- Type checks and test suites verify code correctness, not feature correctness. UI work needs browser-tested verification or an explicit "I cannot test this UI" disclosure — never claim a UI feature works because the build passed.

## Superpowers skill discipline (Claude Code only)
If a superpowers skill applies to the current step, **invoke it**. This is the expected workflow on every non-trivial task. "I know what this skill says" / "this is simple" / "I'll skip it just this once" are **rationalizations** — invoke the skill anyway. Skill content evolves; memory of it does not.

Trigger → skill mapping (invoke via the `Skill` tool):

| Situation | Skill to invoke |
|---|---|
| Starting any conversation / task | `superpowers:using-superpowers` (auto-loads at session start) |
| Before designing a new feature, component, or non-trivial behavior change | `superpowers:brainstorming` |
| Before starting a multi-step implementation | `superpowers:writing-plans` |
| Need an isolated workspace before executing a plan | `superpowers:using-git-worktrees` |
| Executing a written plan in the current session | `superpowers:executing-plans` |
| Executing a plan across fresh subagents with review checkpoints | `superpowers:subagent-driven-development` |
| 2+ independent tasks with no shared state | `superpowers:dispatching-parallel-agents` |
| Implementing any feature or bugfix (writing production code) | `superpowers:test-driven-development` |
| Any bug, test failure, or unexpected behavior before proposing a fix | `superpowers:systematic-debugging` |
| About to claim work is done / fixed / passing, before commit/PR | `superpowers:verification-before-completion` |
| Completed a major feature, before opening the PR | `superpowers:requesting-code-review` |
| Receiving code review feedback before acting on it | `superpowers:receiving-code-review` |
| Implementation complete, deciding how to integrate (merge / PR / cleanup) | `superpowers:finishing-a-development-branch` |
| Creating or editing a skill | `superpowers:writing-skills` |

**Skill priority when multiple apply:** process skills first (brainstorming, debugging) — they determine *how* to approach the task — then implementation skills. "Let's build X" → brainstorming → writing-plans → TDD → verification. "Fix this bug" → systematic-debugging → TDD → verification.

**Rigid vs flexible:** TDD, systematic-debugging, and verification-before-completion are **rigid** — follow exactly, don't adapt away the discipline. Pattern skills are flexible. The skill itself says which.

**Red flags that mean you're skipping a skill:** "just a simple question", "let me explore first", "I'll check git quickly", "doesn't need a formal skill", "I remember what that one says", "skill is overkill here". All of those = invoke the skill.

**User instructions override skills**, skills override default behavior. If the user says "skip TDD on this", that wins. If they say "go" without opting out, skills apply.

## Security & secrets in code/docs
- **Never include literal secret values** in audit reports, post-mortems, threat models, tickets, or any doc that goes into the repo / Slack / Linear / Notion / email. Audit docs are committed, shared, indexed, and stick around in git history forever. Use `<redacted>` + a fingerprint (last 4 chars, or first+last 2) so rotations remain correlatable without exposing the secret.
- When you find an old doc with literal secrets, flag it to the doc's owner as pending redaction. The redaction commit goes **separately**, **never bundled** with content edits, and **never** via `git push --force` rewriting history without explicit coordination — the secret already leaked the moment it was committed; rewriting history only removes it from the current branch, not from clones / caches / forks.
- When rotating a secret mentioned in a doc, redact it in the same commit as the rotation (or immediately after).

## Migrations
Use the framework CLI to create migration files; never write timestamps or filenames by hand:
- TypeORM: `./node_modules/.bin/typeorm migration:create <dir>/<Name>`
- Prisma: `npx prisma migrate dev --name <name>`
- Rails / ActiveRecord: `rails generate migration <Name>`
- Alembic: `alembic revision -m "<msg>"` (or `--autogenerate`)

Manually-invented timestamps with round numbers (`1776100000000`) are a strong red flag — they break ordering, conflict in parallel PRs, and drift from team convention. If you absolutely must reserve a slot manually, use `node -e "console.log(Date.now())"` and document why in the PR description.

## Vammo conventions (verify per repo)
The default Vammo microservice stack is **NestJS + Prisma (PostgreSQL) + Kafka + Datadog**, with i18n via `nestjs-i18n`. Newer or different repos may diverge — always read the repo's `AGENTS.md` / `CLAUDE.md` first. Treat the conventions below as *typical*, not universal:

- `@Auth(...permissions)` decorator usually uses **OR semantics** via `.some()` in the guard. Pass multiple permissions when a route serves multiple resource types.
- Throw via `createI18nException` with keys in `i18n/*/errors.json`. Don't throw raw strings from services.
- DTOs: `class-validator` decorators with error messages via `i18nValidationMessage('validation.X')`.
- Don't add new abstractions before grepping for the existing one — Vammo codebases already have most helpers you think you need.
- For inventory mutations in `ms-ims` specifically, all writes go through `TransactionsService.executeOperations()`. Check the repo's `AGENTS.md` for the equivalent rule in other services.

## Red flags (stop and check)
- About to modify **shared state** (push, open PR, deploy, change DB schema, touch shared infra).
- About to add a **new abstraction** — first grep for the existing one.
- `npm run lint` (with `--fix`) modified files you didn't intentionally touch. Don't `git stash` your work as a workaround — `git stash pop` aborts when lint auto-fix conflicts with stashed changes, and you may lose work recovering it. Safer pattern: capture the dirty file list (`git status --short`), then `git checkout -- <paths>` on the ones you didn't modify.
- A context / accumulator object has **write-only fields** (assigned somewhere, never read) — either a consumer is missing or it's leftover scaffolding. Resolve before the PR.
- Reaching for a mock when an integration test would catch a real bug.
- About to bypass a hook (`--no-verify`, `--no-gpg-sign`) without explicit user request — don't.
- Test setup becoming huge → the design is probably wrong; simplify the interface.
- Installing a third-party tool / MCP server / CLI that reads project files and ships them to a relay — stop and validate the trust chain (official registry? signed? documented threat model?) before running anything inside `~/Projects/Vammo/`. Confirm with the user even if the chain checks out — uploading internal context to a third party may violate confidentiality.
