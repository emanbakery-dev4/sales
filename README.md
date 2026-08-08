# Eman Bakery Wholesale Ordering & Dispatch Platform

Start here, in this order:

1. **[PREFLIGHT.md](./PREFLIGHT.md)** — your one-time manual setup (accounts, secrets, autonomy switches). Do this first.
2. **[AGENTS.md](./AGENTS.md)** — how the autonomous coding agent operates on this repo.
3. **[BUILD_PLAN.md](./BUILD_PLAN.md)** — the phased build order.
4. **[docs/SPEC.md](./docs/SPEC.md)** — the full product specification (every page, button, rule, and animation).

## Workspace

- `frontend/` — Next.js App Router web application
- `worker/` — Node.js automation worker
- `supabase/` — database migrations and development seed data

## Development

Requires Node.js 22+, pnpm 10+, and Docker.

```bash
pnpm install
pnpm dev
```

Run the worker separately with `pnpm --filter worker dev`. Start the complete frontend, development database, and worker stack with `docker compose up --build`.

## Quality checks

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Copy `.env.example` to `.env.local` for local configuration. Never commit credentials.
