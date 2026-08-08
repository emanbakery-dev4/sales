# PREFLIGHT.md — Your One-Time Setup Checklist

Do this once, in order. Nothing here repeats — once it's done, the agent (Cursor Cloud Agent) never needs to stop and ask you for anything while it builds. Everything below is a *your action* — the agent does not do any of this section, because it requires an account, a payment method, or a login only you have.

---

## A. Confirm/create the accounts you need

- [ ] GitHub account + this repository (you likely already have this from the `next-shadcn-admin-dashboard` Vercel template deploy — reuse that repo, don't create a second one)
- [ ] Supabase account + project (reuse your existing project if you already created one for this build)
- [ ] Vercel account + project linked to this GitHub repo (you already have this from the template deploy)
- [ ] Railway account (new — this is for the background automation worker described in the spec, §26.3)
- [ ] Sentry account (free tier is enough to start) — create **two** projects inside it: one Next.js project, one Node.js project (for the worker)
- [ ] Slack workspace access, if you want ops alerts (optional — skip if you don't want this yet)

## B. Add the files from this delivery to your repo

- [ ] Copy `AGENTS.md`, `BUILD_PLAN.md`, `PREFLIGHT.md` (this file), `.env.example` into the **root** of your repo
- [ ] Copy `.cursor/environment.json` and `.cursor/rules/00-project-standards.mdc` into your repo at those exact paths
- [ ] Copy `.github/workflows/ci.yml` into your repo at that exact path
- [ ] Copy `docs/SPEC.md` into your repo at that exact path
- [ ] Commit and push all of the above to `main` directly (this one push is fine to do yourself — everything after this point is the agent's job)

## C. Collect every key exactly once, from exactly these places

| # | Secret name | Where to get it | Paste into |
|---|---|---|---|
| 1 | `SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_URL` | Supabase Dashboard → your project → **Project Settings → API Keys** (top of page shows the Project URL) | GitHub Secrets, Vercel Env Vars, Cursor Secrets |
| 2 | `SUPABASE_PUBLISHABLE_KEY` / `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Same page → **API Keys tab** → "Publishable and secret API keys" → click **Create new API Keys** if you don't see one yet → copy the **Publishable key** | GitHub Secrets, Vercel Env Vars, Cursor Secrets |
| 3 | `SUPABASE_SECRET_KEY` | Same tab → copy the **Secret key** (`sb_secret_...`) — this replaces the old `service_role` key | GitHub Secrets, Cursor Secrets, Railway Env Vars — **never** in Vercel's client-exposed vars, **never** prefixed `NEXT_PUBLIC_` |
| 4 | `DATABASE_URL` | Same Settings area → **Database → Connection string** (use the pooled/transaction connection string) | GitHub Secrets, Cursor Secrets, Railway Env Vars |
| 5 | `JWT_SECRET` | You generate this yourself — run `openssl rand -base64 32` in any terminal | GitHub Secrets, Vercel Env Vars, Railway Env Vars, Cursor Secrets |
| 6 | `VERCEL_TOKEN` | Vercel → click your avatar (top-right) → **Settings → Tokens** → **Create** → scope it to this one project → copy immediately (shown once) | GitHub Secrets, Cursor Secrets |
| 7 | `RAILWAY_TOKEN` | Railway → **Account Settings → Tokens** → **Create Token** → copy immediately | GitHub Secrets, Cursor Secrets |
| 8 | `SENTRY_DSN` | Sentry → your Next.js project → **Settings → Client Keys (DSN)** | GitHub Secrets, Vercel Env Vars, Cursor Secrets |
| 9 | `SENTRY_DSN_WORKER` | Sentry → your Node.js project → **Settings → Client Keys (DSN)** | GitHub Secrets, Railway Env Vars, Cursor Secrets |
| 10 | `SENTRY_AUTH_TOKEN` | Sentry → **Organization Settings → Auth Tokens** → Create (needed only for CI source-map upload — optional for first deploy) | GitHub Secrets |
| 11 | `SLACK_WEBHOOK_URL` | [api.slack.com/apps](https://api.slack.com/apps) → **Create New App** → **Incoming Webhooks** → toggle on → **Add New Webhook to Workspace** → copy the URL (optional — skip if not using Slack alerts yet) | GitHub Secrets, Railway Env Vars, Cursor Secrets |

**"Paste into" means four separate places, not one** — each is a different execution environment and none of them share values automatically:

- **GitHub Secrets** — repo → **Settings → Secrets and variables → Actions → New repository secret** (used by `.github/workflows/ci.yml`)
- **Vercel Env Vars** — Vercel project → **Settings → Environment Variables** (used by the live deployed frontend; Vercel's own GitHub integration deploys automatically on push, it doesn't read GitHub Secrets)
- **Railway Env Vars** — Railway project → your worker service → **Variables** tab (used by the live deployed worker)
- **Cursor Secrets** — Cursor app → **Settings → Secrets** (scope it to this repo) — **this is the one people forget.** Without it, the Cloud Agent's sandbox has no way to run migrations, hit Supabase, or pass CI locally while it works — it will stop and ask you for exactly this reason (AGENTS.md §6.1). Do this and it never happens.

## D. Turn on autonomy (this is what removes the "click confirm" step)

- [ ] Repo → **Settings → Branches** → add a protection rule on `main`:
  - Require status checks to pass before merging → select the `frontend`, `worker`, and `migrations` jobs from `ci.yml`
  - Enable **"Allow auto-merge"** for the repository (Settings → General → Pull Requests)
- [ ] In Cursor: connect the Cursor GitHub App to this repository (Cursor → **Settings → Integrations → GitHub** → Install/Authorize → select this repo)
- [ ] In Cursor: confirm **Cloud Agents** are enabled for your plan (Pro plan or above) and that this repo appears in the Cloud Agents repo list

With auto-merge on and required checks set, an agent's PR merges itself the instant CI goes green — no click from you, ever, for a routine merge.

## E. Kick off the build

Start a new Cloud Agent on this repo with this exact prompt:

> Read AGENTS.md, then BUILD_PLAN.md, then docs/SPEC.md in full. Begin Phase 0 of BUILD_PLAN.md. Follow the Autonomous Operating Protocol in AGENTS.md §4 for every phase — do not stop for confirmation between phases, only for the two exceptions in AGENTS.md §6. Work through every phase in order until Phase 15 (Final Acceptance) is complete and merged.

That's the last manual step. Everything from here follows `AGENTS.md` on its own.

---

## One honest caveat

"Fully autonomous" here means *no human click is required for the build loop to keep moving* — CI, not a person, is the gate on every merge. That's a deliberate design choice in this setup (§D above), not a limitation of the agent. It's worth keeping that gate (rather than turning CI off too) precisely because this app moves real money through a ledger — the checks are what let you safely stay hands-off, not what's slowing you down. If you ever want a true zero-check, zero-gate setup, that's also possible (skip §D's branch protection entirely and let the agent push straight to `main`), but it isn't recommended for this specific app given what it manages financially.
