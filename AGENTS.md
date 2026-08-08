# AGENTS.md — Autonomous Build Instructions
## Eman Bakery Wholesale Ordering & Dispatch Platform

This file is read by autonomous coding agents (Cursor Cloud Agents, and any other AGENTS.md-compatible agent) at the start of every session. It is the operating manual. Read it fully before touching any file.

---

## 0. Document Hierarchy — Read In This Order

1. **`docs/SPEC.md`** — the Enhanced Master Specification. This is the single source of truth for *what* to build: every page, button, business rule, database entity, and error message. Never invent features it doesn't describe without flagging the deviation (see §5).
2. **`BUILD_PLAN.md`** — the phased execution order. This is *the order* in which to build. Do not skip phases. Do not start Phase N+1 until Phase N's Definition of Done is fully met.
3. **This file (`AGENTS.md`)** — *how* to operate: engineering rules, environment, git workflow, and the autonomy contract.

---

## 1. Mission

Build the platform described in `docs/SPEC.md` end-to-end, phase by phase per `BUILD_PLAN.md`, fully autonomously, to production, with zero human confirmation steps required during normal operation. The only two situations where you stop are defined in §6 — both are eliminated if `PREFLIGHT.md` was completed before you started.

## 2. Tech Stack (non-negotiable — do not substitute)

- Frontend: Next.js (App Router) + TypeScript (strict mode) + Tailwind CSS
- UI primitives: Radix-based headless components + shadcn/ui conventions (this repo starts from a `next-shadcn-admin-dashboard` base — respect its existing structure rather than replacing it)
- Animation: Framer Motion (or equivalent) implementing every behavior in `docs/SPEC.md` §2.2
- Database/Auth/Realtime/Storage: Supabase (PostgreSQL)
- Background worker: Node.js + TypeScript, Docker, deployed to Railway
- Hosting: Vercel (frontend), Railway (worker)
- CI/CD: GitHub Actions (`.github/workflows/ci.yml`)
- Monitoring: Sentry (frontend + worker)
- Ops alerts: Slack incoming webhook
- Forms/validation: React Hook Form + Zod
- Testing: Vitest/Jest for unit, Playwright for critical E2E flows (login, place order, finalize order, record payment)

## 3. Non-Negotiable Engineering Rules

These apply to every phase, every module, every PR, with no exceptions:

1. **Row Level Security is mandatory on every customer-facing and financial table.** A migration that creates a table without an accompanying RLS policy is incomplete — do not commit it.
2. **Never trust the client for money.** Prices, totals, and balances are always recalculated server-side (Postgres function or Server Action) at the moment of a mutating action, even if the client already computed and displayed the same number.
3. **Nothing financial is hard-deleted.** Deactivate, reverse, or correct — never `DELETE` on `orders`, `order_items`, `payments`, `ledger_transactions`, `customer_product_prices`, or `audit_logs`. No application role gets `DELETE` grant on these tables at the database level.
4. **Every mutation on those tables writes an audit_logs row in the same transaction**, per `docs/SPEC.md` Module 14. Use a single Postgres function per mutation type so this can never be skipped by a caller.
5. **Order finalization is atomic.** Status change + ledger entry happen in one transaction (a Postgres function), never as two separate client calls.
6. **No secrets in source.** Every credential comes from an environment variable already present in your sandbox (see `PREFLIGHT.md` — these are provisioned before you start). If a variable you need is missing, see §6.
7. **No raw errors reach the UI.** Every caught exception is mapped through the error-translation layer to a plain-language message from `docs/SPEC.md` Module 15 §20.4 before being shown; the raw error goes to Sentry only.
8. **Every list page ships with loading, empty, and error states** before it is considered done — not as a follow-up.
9. **Motion in `docs/SPEC.md` §2.2 is implemented, not skipped** — it's part of the acceptance criteria, not decoration to cut for time. It must also respect `prefers-reduced-motion`.
10. **TypeScript strict mode, ESLint, and Prettier must pass with zero errors before any commit.**

## 4. Autonomous Operating Protocol

For each phase in `BUILD_PLAN.md`:

1. Re-read the relevant `docs/SPEC.md` module section(s) listed for that phase.
2. Create a branch: `feat/phase-<NN>-<short-slug>` (e.g. `feat/phase-05-queue-dispatch`).
3. Implement the phase's deliverables in full.
4. Write/update tests for the new functionality (unit tests for business logic — pricing resolution, ledger math, queue-expiry timing; Playwright for the phase's critical user flow if it introduces one).
5. Run, and require green, before proceeding:
   - `pnpm lint`
   - `pnpm typecheck`
   - `pnpm build` (frontend) and the worker's equivalent build
   - `pnpm test`
   - Apply pending Supabase migrations to the dev/preview database and confirm they run cleanly (`supabase db push` or the project's migration command) — do not proceed on a failed migration
6. Self-review your own diff against the phase's Definition of Done checklist in `BUILD_PLAN.md`. Fix anything unmet before continuing.
7. Commit using Conventional Commits (`feat(queue): add smart dispatch console`, `fix(ledger): correct running balance calc`, etc.).
8. Push and open a PR against `main`. Fill the PR description with: what was built, which spec sections it satisfies, what was tested, and any assumptions made (§5). Reference the phase number.
9. Do **not** wait for a human to click anything. Branch protection on `main` requires the CI status checks above to pass and has auto-merge enabled — once checks are green, the PR merges itself. If a check fails, fix it on the same branch and push again; do not open a new PR to route around a failure.
10. Move to the next phase.

Repeat until every phase in `BUILD_PLAN.md` is merged to `main` and deployed, then run the full Final Acceptance Criteria pass (`docs/SPEC.md` §33) as the last phase.

## 5. Handling Ambiguity (without stopping)

`docs/SPEC.md` is extremely detailed, but if you hit a genuine gap:

- Resolve it using the Core Business Rules (`docs/SPEC.md` §4) and the closest analogous pattern already specified elsewhere in the document.
- Prefer the more conservative option for anything touching money, permissions, or data retention (e.g., when in doubt, log more rather than less; require a confirmation dialog rather than not).
- Write a one-paragraph "Assumption" note in the PR description explaining the gap and the choice made. Keep building — do not open the PR as a draft waiting on this, and do not ask the human first.
- Never silently expand scope beyond `docs/SPEC.md` for anything financial, permission-related, or security-related. Minor UI polish decisions (exact spacing, wording of a secondary microcopy string) don't need a note.

## 6. The Only Two Reasons To Stop

Everything else, you resolve yourself per §5. Stop and post a clear, specific message (do not just go silent) only if:

1. **A required environment variable/secret is missing or invalid** for the phase you're on (e.g., `SUPABASE_SECRET_KEY` isn't set, or a Sentry DSN 401s). You cannot generate these yourself — they require the human to create an account/project on an external platform. This should never happen if `PREFLIGHT.md` was completed first.
2. **An external account-level action is required** that you have no credential for — e.g., a new Supabase project needs to be created, a domain needs to be purchased, a WhatsApp Business API application needs approval. You cannot sign up for services on the human's behalf.

In both cases: state exactly which variable/action is missing and exactly which `PREFLIGHT.md` step provides it, then stop that phase only — continue with any other phase that isn't blocked by the same gap.

## 7. Cloud Agent Environment — Exact Commands

(Also encoded in `.cursor/environment.json` — this section is the durable reference per Cursor's recommendation to give cloud agents an explicit command reference in `AGENTS.md`.)

```
Install:     pnpm install
Dev server:  pnpm dev
Build:       pnpm build
Lint:        pnpm lint
Typecheck:   pnpm typecheck
Unit tests:  pnpm test
E2E tests:   pnpm test:e2e
DB migrate:  pnpm db:migrate      (wraps: supabase db push)
DB seed:     pnpm db:seed
Worker dev:  pnpm --filter worker dev
Worker build:pnpm --filter worker build
```

If any of these scripts don't exist yet because you're still in Phase 0 (bootstrap), creating them correctly in `package.json` is itself part of Phase 0's Definition of Done.

## 8. Repository Structure

Follow `docs/SPEC.md` §29 exactly:

```
frontend/     Next.js app (customer, staff, admin)
worker/       automation & background worker service
supabase/
  migrations/
  seed/
.github/workflows/
docs/
scripts/
Dockerfile
docker-compose.yml
.env.example
README.md
```

## 9. Security Checklist (verify at the end of every phase touching data)

- [ ] Every new table has RLS enabled and policies scoped correctly per role
- [ ] No `service_role`/secret key used anywhere in client-shipped code
- [ ] No new `console.log` of sensitive data (prices, tokens, customer PII) left in
- [ ] Every new financial mutation logs to `audit_logs` in the same transaction
- [ ] Every new form validates server-side, not just client-side
