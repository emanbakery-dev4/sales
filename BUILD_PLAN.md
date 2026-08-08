# BUILD_PLAN.md — Phased Autonomous Execution Order

Sixteen phases. Build in order. Each phase lists: what to read in `docs/SPEC.md`, what to deliver, and the exact Definition of Done (DoD) that must be true before moving on. This is the single sequencing document — module detail lives in `docs/SPEC.md` so it's never duplicated or allowed to drift out of sync.

---

### Phase 0 — Repository Bootstrap
**Read:** SPEC §26 (Technical Architecture), §27 (DB Schema), §28 (Env Vars), §29 (Repo Structure)
**Deliver:** Next.js + TS + Tailwind app scaffold inside `frontend/` (building on the existing `next-shadcn-admin-dashboard` base already in this repo — extend it, don't discard it); `worker/` Node+TS skeleton with Dockerfile; `supabase/migrations/` and `supabase/seed/` folders; root `docker-compose.yml`; `package.json` scripts matching AGENTS.md §7; design tokens implementing the Dark Luxury system (SPEC §2.1) in the Tailwind config.
**DoD:** `pnpm install && pnpm build` succeeds; `docker-compose up` boots the local stack; lint/typecheck configured and passing on the empty scaffold; CI workflow file present and green on a trivial PR.

### Phase 1 — Database Foundation
**Read:** SPEC §27 (all entities), §31 (Security), Module 14 (Audit)
**Deliver:** Migrations for every table in SPEC §27; RLS policies per role for every customer-facing/financial table; the Postgres functions for order-finalization, payment-reversal, and price-change-with-history described in AGENTS.md §3; seed script with realistic demo data (customers, products, prices, a few orders in various states).
**DoD:** All migrations apply cleanly from empty; a seeded local DB has data visible per role under RLS (verified via a test script that queries as each role and confirms isolation); every table touching money has zero `DELETE` grants for non-admin roles.

### Phase 2 — Module 1: Authentication & Access Control
**Read:** SPEC Module 1 in full
**Deliver:** every page/state in §6.1–6.7; Supabase Auth wiring; role-based redirect; session timeout; audit logging of auth events.
**DoD:** All 8 auth-area pages exist with loading/empty/error states; a Playwright test covers login → correct role redirect for each of the 4 roles; frozen-account and expired-session paths tested.

### Phase 3 — Module 2 + Module 18: Customer Dashboard & PWA Shell
**Read:** SPEC Module 2, Module 18
**Deliver:** customer dashboard widgets and realtime behavior; PWA manifest, service worker, install prompt, offline banner, bottom tab nav on mobile.
**DoD:** dashboard renders all widgets with correct empty/loading states; app is installable; Lighthouse PWA check passes; offline mode shows the defined banner rather than failing silently.

### Phase 4 — Module 3 + Module 4: Catalog, Cart & Checkout
**Read:** SPEC Module 3, Module 4, §2.2 (animation spec)
**Deliver:** full catalog with search/filter/sort, recent-order prioritization, quick-view, and the stagger-fade/add-to-cart animations; cart with all validation and error-recovery states in §9.3–9.4.
**DoD:** a Playwright test completes catalog search → add to cart → submit order end to end; server-side price validation confirmed by a test that tampers with a client-sent price and expects rejection; motion respects `prefers-reduced-motion`.

### Phase 5 — Module 5: Order Queue & Smart Dispatch Automation Engine
**Read:** SPEC Module 5 in full (this is the centerpiece — read it twice)
**Deliver:** queue board + table views, all statuses, revision history, finalize-to-ledger transaction, the full automation layer in §10.5 (console, keyboard shortcuts, auto-suggested flags, time-based escalation, bulk ops).
**DoD:** finalize-to-ledger is verified atomic under test (simulated failure mid-transaction leaves neither status nor ledger changed); "matches usual order" and "unusual size" flags verified against seeded data; two-hour expiry escalation verified with a time-mocked test.

### Phase 6 — Module 6 + Module 7: Order Details & Ledger/Payments
**Read:** SPEC Module 6, Module 7
**Deliver:** order detail page with full revision timeline; ledger page and formula; payment recording form and rules; PDF/Excel export; WhatsApp share.
**DoD:** running balance recalculates correctly across a sequence of sales/payments/reversals in a test; payment reversal produces a new transaction rather than mutating the original (verified by an audit-log check).

### Phase 7 — Module 8 + Module 9: Customer & Product Management
**Read:** SPEC Module 8, Module 9
**Deliver:** customer CRUD, customer-specific pricing UI with history, bulk pricing tools; product CRUD, soft-deactivation, catalog display-order drag-reorder.
**DoD:** price history is fully retained across edits and visible in the UI; deactivating a product used in an open queued order shows the specified warning and doesn't corrupt the open order.

### Phase 8 — Module 10 + Module 11: Staff Ordering & Admin User Management
**Read:** SPEC Module 10, Module 11
**Deliver:** staff quick-order flow including phone-call mode; admin user management (create/edit/freeze staff, permission overrides).
**DoD:** a staff-created order correctly attributes creator name/role throughout; role changes take effect on next request per SPEC §6.6.

### Phase 9 — Module 12 + Module 13: Command Center & Reports
**Read:** SPEC Module 12, Module 13
**Deliver:** realtime dashboard with all KPIs and the count-up/chart-draw-in animations; every report in §18.1 with filters, export, and the background-generation path for large exports.
**DoD:** dashboard updates in realtime on a test mutation (order finalized in one session reflects within the SLA in another open session); every report returns correct results against seeded data.

### Phase 10 — Module 14 + Module 15: Audit Trail & Notifications
**Read:** SPEC Module 14, Module 15
**Deliver:** audit log viewer with diff view; full notification channel wiring (in-app, email, SMS, WhatsApp, Slack) per §20.1; global error boundary and offline banner.
**DoD:** every mutation type introduced in prior phases has a verifiable audit_logs row in a test; no raw error message reaches a rendered page in any induced-failure test.

### Phase 11 — Module 16: Delivery & Driver Dispatch
**Read:** SPEC Module 16
**Deliver:** dispatch board, driver directory, route grouping, delivery confirmation flow (including offline capability via Module 18), customer delivery notifications.
**DoD:** an order can be taken from Finalized → assigned → delivered with correct status transitions and customer notifications fired at each step.

### Phase 12 — Module 17: Automation & AI Assist (Worker Jobs)
**Read:** SPEC Module 17
**Deliver:** worker jobs for predictive reordering signals, anomaly/exception detection, and the governance rule that every automated suggestion still requires a human confirming click.
**DoD:** automation toggles in Module 20 settings actually disable the corresponding behavior when off; an automation-triggered action is indistinguishable from a manual one in the audit log except for an attribution note.

### Phase 13 — Module 19 + Module 20: Multi-Branch & Settings Center
**Read:** SPEC Module 19, Module 20
**Deliver:** branch model and filtering across dashboard/queue/customers/dispatch/reports; full settings center (general, automation, notifications, pricing rules, security, feature flags).
**DoD:** with a second branch seeded, branch-scoped staff see only their branch's data while Master Admin sees the aggregate; every setting in Module 20 actually changes runtime behavior, not just a stored value.

### Phase 14 — Platform Hardening
**Read:** SPEC §30 (CI/CD/Monitoring), §31 (Security), §32 (Performance/Accessibility)
**Deliver:** Sentry wired on frontend + worker with release tracking; Slack alerts firing for the events listed in §20.1/§30.4; accessibility pass (keyboard nav, focus states, contrast, screen-reader labels) across every page; performance pass (pagination/virtualization confirmed on every list, image optimization confirmed on the catalog).
**DoD:** a deliberately thrown error appears in Sentry with the correct release tag within a minute; an axe-core accessibility scan run against every route reports zero critical violations; WCAG AA contrast confirmed on the dark theme.

### Phase 15 — Final Acceptance
**Read:** SPEC §33 in full
**Deliver:** nothing new — this phase is verification only.
**DoD:** every bullet in SPEC §33 is individually checked off against the live Staging/Production deployment, RLS cross-customer isolation is verified by an adversarial test (customer A's session attempting to query customer B's data must fail), and a full Playwright suite covering the acceptance criteria's flows passes on `main`.

---

## Working Rules For This Plan

- Do not begin Phase N+1 until Phase N is merged to `main` and its DoD is verifiable in the deployed preview environment.
- If a later phase reveals a gap in an earlier phase's work (e.g., Phase 6 needs an audit hook Phase 1 didn't add), fix it in a small patch PR against the earlier phase's code rather than working around it — do not let debt accumulate silently.
- Every phase ends with a working, deployed, demonstrable increment — never leave `main` in a broken state between phases.
