# Eman Bakery Wholesale Ordering & Dispatch Platform
## Enterprise Production Blueprint — Enhanced Master Specification v2.0

> **Document status:** Enhanced, implementation-ready specification. This document expands the original system requirements into a complete enterprise blueprint: every page, every button, every state, every error message, every automation, and the full visual/motion design language, so that an AI coding agent or a human engineering team can build the platform end-to-end without needing to guess at missing detail.

**Business:** Eman Bakery — fresh bread manufacturing and wholesale distribution, Jeddah, Saudi Arabia, operating across multiple locations with a distribution workforce of drivers and salesmen.

**Scale:** ~84 wholesale customers today (designed to scale past 500+), 60-70 bakery products (designed to scale past 300+), customer-specific pricing, multi-branch ready.

**Primary goal of this revision:** Keep every original business rule intact (nothing removed), and layer on top of it (1) full page-by-page and button-by-button detail, (2) a dedicated Smart Dispatch Automation Engine that makes creating, queuing, and finalizing an order the fastest possible action for staff, (3) a premium, animated, modern UI/UX design language, and (4) a production-grade cloud architecture with CI/CD, monitoring, and alerting.

---

## Table of Contents

1. Executive Vision & Product Principles
2. Design System & Motion Language ("Dark Luxury" UI/UX)
3. Complete Information Architecture (Sitemap by Role)
4. Core Business Rules
5. User Roles & Permissions Matrix
6. Module 1 - Authentication & Access Control
7. Module 2 - Customer Dashboard
8. Module 3 - Product Catalog & Ordering
9. Module 4 - Shopping Cart & Checkout
10. Module 5 - Order Queue & Smart Dispatch Automation Engine
11. Module 6 - Order Details & History
12. Module 7 - Customer Ledger & Payments
13. Module 8 - Customer Management
14. Module 9 - Product Management
15. Module 10 - Centralized Staff Ordering
16. Module 11 - Master Admin Management
17. Module 12 - Admin & Staff Command Center (Dashboard)
18. Module 13 - Reports & Exports
19. Module 14 - Audit Trail & Data Integrity
20. Module 15 - Notifications, Confirmations, and Errors
21. Module 16 - Delivery & Driver Dispatch Coordination (new)
22. Module 17 - Smart Automation & AI Assist Engine (new)
23. Module 18 - Progressive Web App, Offline Mode & Mobile Experience (new)
24. Module 19 - Multi-Branch / Multi-Location Support (new)
25. Module 20 - Settings & Configuration Center (new)
26. Technical Architecture
27. Database Schema & Entities
28. Environment Variables
29. Repository Structure
30. CI/CD, Monitoring & DevOps
31. Security Requirements
32. Performance, Scalability & Accessibility
33. Final Acceptance Criteria
34. Appendix A - Master Page Inventory
35. Appendix B - Master Button & Action Inventory
36. Appendix C - Master Error Message Catalogue
37. Appendix D - Master Empty-State Catalogue
38. Appendix E - Animation & Micro-Interaction Specification

---
# 1. Executive Vision & Product Principles

## 1.1 Product Vision

Eman Bakery's wholesale customers currently order the same 8-12 products almost every single day. The platform's single most important job is to remove friction between "I need to order" and "the order is confirmed" — for both the customer and the staff member dispatching on their behalf. Every design decision in this document is filtered through one question: **does this make placing, queuing, and finalizing an order faster, clearer, and harder to get wrong?**

Five principles govern the build:

1. **Speed over ceremony.** Reordering yesterday's basket should take under 10 seconds. Centralized staff should be able to build and submit an order for a phoned-in customer in under 60 seconds.
2. **Nothing is silently lost.** Every price, quantity, edit, payment, and status change is recorded, timestamped, and attributable to a person. Deletion is replaced by deactivation, correction is replaced by reversal.
3. **One glance tells the truth.** Dashboards, badges, and balances must be understandable in under 3 seconds without needing to click into a detail page.
4. **The interface should feel premium, not administrative.** This is a bakery selling a beloved product — the software representing it should feel crafted, warm, and confident, not like a generic back-office form.
5. **Automation assists, never overrides, financial control.** Smart suggestions, auto-fill, and predictive automation can prepare and pre-fill actions, but a human being always makes the final confirming click on anything that touches money.

## 1.2 What "Enterprise-Grade" Means Here

- Every page defined below has an explicit loading state, empty state, error state, and success state — no page is allowed to "just be blank" while data loads or fails.
- Every destructive or financial action has a named confirmation dialog with a cancel path.
- Every list/table page has search, filter, sort, pagination (or virtualized infinite scroll), and a "no results" state with a recovery action.
- Every form has field-level validation, inline error messages, and a disabled-until-valid submit state where appropriate.
- Every number that represents money is computed server-side and never trusted from the client.
- Every mutation is optimistic where safe and reconciled against the server response, with automatic rollback and a toast if the server rejects it.

---

# 2. Design System & Motion Language — "Dark Luxury" UI/UX

This is the aesthetic and interaction specification an AI coding agent or designer should follow so the finished product looks and feels like a single, deliberately designed product rather than a stitched-together admin template.

## 2.1 Visual Direction

- **Theme:** Dark-luxury bakery brand — deep charcoal/espresso backgrounds, warm off-white typography, and a signature accent gradient in warm gold/amber (evoking fresh-baked crust and bread crumb tones) used sparingly for primary actions, active states, and key numbers. A light theme variant exists for daytime warehouse/outdoor use but dark is the default and primary brand expression.
- **Typography:** A humanist sans-serif for UI text (e.g., Inter or similar variable font) for clarity at small sizes, paired with a warmer serif or display face reserved for the logo lockup, page hero numbers (like the outstanding balance figure), and empty-state headlines — giving the "premium bakery" feeling without sacrificing UI legibility.
- **Surface system:** Three elevation levels (base canvas, raised card, floating overlay), each with a subtle distinct background tone and soft shadow/glow rather than hard borders, so the interface reads as tactile, layered glass rather than flat boxes.
- **Iconography:** A single consistent icon set (stroke-based, rounded caps) throughout — never mixing icon families.
- **Corner radius & spacing:** Consistent rounded-corner scale (small controls, medium cards, large modals/sheets) and an 8px base spacing grid so density feels intentional rather than cramped or sparse.
- **RTL-ready:** Full mirroring support for Arabic; every icon, chevron, drawer, and progress indicator must flip correctly, since the interface is Arabic/English-ready by requirement.

## 2.2 Motion Principles

Animation exists to **communicate**, not decorate — every motion below has a job: confirming an action happened, orienting the user after a change, or reducing perceived wait time. All motion respects `prefers-reduced-motion` and degrades to instant/no-motion for users who request it.

| Interaction | Motion behavior |
|---|---|
| Page/route transition | Soft cross-fade + slight upward slide (150-200ms), never a hard cut, never a jarring full reload feel |
| Product card enters catalog (search/filter change) | Staggered fade-and-rise-in per card (grid animates in row-by-row, ~20-30ms stagger) so filtering feels alive rather than an instant re-render |
| Product card removed by filter | Fade-and-scale-down before layout reflows, so items don't just vanish |
| "Add to Cart" | The product image/quantity badge performs a short arc/fly animation toward the cart icon, the cart icon does a scale "pulse," and the cart item count badge increments with a spring bounce |
| Quantity stepper (+/-) | Number performs a quick vertical roll/count-tick animation rather than an instant digit swap |
| Cart drawer open/close | Slides in from the trailing edge with a soft spring easing, backdrop fades in behind it |
| Price change (customer-specific price applied) | Old price strikes through and fades while the new price counts/settles into place, with a small "your price" tag popping in |
| Order submitted | Full-screen success moment: a checkmark draws itself in (path-drawing animation), the order number fades up beneath it, confetti-style particles are intentionally **not** used (keeps the premium tone) — instead a soft warm glow pulse is used |
| Queue countdown timer | Circular progress ring that visibly drains as the two-hour window elapses, shifting color from neutral to amber to red as it approaches expiry |
| Realtime update arrives (new order, payment posted) | The affected row/card performs a brief highlight-flash (soft glow pulse) so staff visually catch the change without needing a manual refresh |
| Dashboard KPI numbers | Numbers count up from 0 to the target value on first load/refresh (150-500ms depending on magnitude), never just snap in |
| Charts | Bars/lines draw in from baseline on load; tooltips fade in on hover with a slight follow-cursor lag for a "liquid" feel |
| Modal/dialog open | Scale-up-from-98%-to-100% + fade, backdrop blur fades in |
| Toast notifications | Slide-in from top-right (or top for mobile), auto-stack, swipe-to-dismiss on touch, auto-dismiss with a visible shrinking progress bar |
| Skeleton loading | Shimmer sweep left-to-right on all skeleton placeholders, matched exactly to the shape of the real content so there is zero layout shift when data arrives |
| Drag-reorder (product display order, dashboard widgets) | Lifted card gains shadow/scale, other cards animate out of the way with spring physics |
| Status badge change (e.g., Draft → Submitted → Finalized) | Badge cross-fades color and label, with a subtle checkmark "tick" icon animating in when a stage completes |
| Error shake | Invalid form fields perform a short horizontal shake plus a red glow pulse on failed validation/submit |

## 2.3 Component Library Approach

- Built on a headless, accessible primitive layer (e.g., Radix-style primitives) styled with a utility-first CSS system, so every interactive control (dropdown, dialog, popover, tabs, tooltip, toast, combobox) is keyboard-accessible, screen-reader-labeled, and visually consistent by construction rather than hand-rolled per page.
- A single shared "DataTable" component (sortable columns, sticky header, row selection, column visibility toggle, export actions, empty/loading/error states) is reused across every list page in this document (Orders Queue, Customers, Products, Payments, Reports, Audit Logs, Users) rather than rebuilt per module.
- A single shared "MoneyDisplay" component formats every currency figure consistently (SAR, thousands separators, red for negative/overdue, green for credit) so financial figures are visually identical everywhere they appear.
- A single shared "ConfirmDialog" component is reused for every destructive/financial confirmation listed throughout this document, parameterized by title, consequence text, and confirm-button label/color.
# 3. Complete Information Architecture (Sitemap by Role)

## 3.1 Customer Sitemap

```
/login
/forgot-password
/reset-password
/account-frozen
/session-expired
/unauthorized

/customer
  /dashboard
  /catalog                         (product catalog / new order entry)
  /catalog/product/:id             (product quick-view panel/modal)
  /cart                            (review cart before submit)
  /orders                          (order history list)
  /orders/:orderId                 (order detail)
  /orders/queue                    (my orders currently in queue, live)
  /ledger                          (ledger & running balance)
  /ledger/statement                (printable/exportable statement)
  /payments                        (payments received history)
  /profile                         (my business profile)
  /profile/change-password
  /notifications                   (notification center / inbox)
  /support                         (help & contact support)
```

## 3.2 Centralized Staff Sitemap

```
/staff
  /dashboard                       (command center)
  /queue                           (order queue - live operations board)
  /queue/:orderId                  (queue order detail / edit)
  /customers                       (customer directory)
  /customers/:id                   (customer profile)
  /customers/:id/new-order         (create order on behalf of customer)
  /customers/new                   (add customer - if permitted)
  /products                        (product catalog view - read/limited edit per permission)
  /payments                        (record & browse payments)
  /payments/new                    (record payment form)
  /dispatch                        (delivery/driver dispatch board)          [Module 16]
  /reports                         (reports & exports)
  /notifications
  /profile
```

## 3.3 Master Admin Sitemap

```
/admin
  /dashboard                       (executive command center)
  /queue
  /customers                       (full CRUD)
  /customers/:id
  /products                        (full CRUD)
  /products/:id
  /products/new
  /payments
  /reports
  /dispatch                        [Module 16]
  /users                           (staff/admin user management)
  /users/:id
  /users/new
  /audit-logs
  /audit-logs/:eventId
  /settings                        [Module 20]
  /settings/branches               [Module 19]
  /settings/notifications
  /settings/automation             [Module 17]
  /settings/pricing-rules
  /settings/security
  /notifications
  /profile
```

---

# 4. Core Business Rules (Expanded)

The original business rules remain fully in force, restated here with enforcement detail:

1. **Account isolation.** Every customer has an individual login account and can see only their own profile, orders, payments, ledger balance, and assigned product prices. Enforced at the database layer via Row Level Security, not merely hidden in the UI.
2. **Customer-specific pricing.** A product has a default/base price; any customer may have an overridden customer-specific price, with full history retained. The catalog and cart must always resolve price in this order: active customer-specific price → base price → block the add-to-cart action with an error if neither resolves.
3. **Credit-only ordering.** All submitted orders are credit orders. Payment is collected and recorded separately, later, either partially or in full. No online payment collection exists in the initial release (may be added later behind a feature flag — see Module 20).
4. **Two-hour editable queue.** Every new order enters an editable Order Queue and remains there for up to two hours before staff finalize it. The two-hour window is configurable per Module 20 settings (default 120 minutes) rather than hardcoded, since operational needs may change.
5. **Staff-only finalization.** Customers cannot finalize queued orders; only authorized staff can review, adjust, confirm collection/delivery, and post the order to the ledger.
6. **No inventory tracking (v1).** Stock/inventory management is out of scope for the initial version. Staff can manually revise quantities or remove unavailable items while an order is in the queue. Product availability is a manual staff-controlled flag, not computed from stock counts.
7. **Full auditability.** All important changes — orders, prices, payments, customer changes, user actions — must be auditable and must never be silently deleted. Every mutation-capable table follows the append-only/reversal pattern described in Module 14.
8. **Order attribution.** Every order must clearly show whether it was created by the customer directly or by a staff member, including the creator's name, role, and timestamp — visible on every card, table row, and detail page that displays that order.
9. **Two-hour expiry escalation (new).** If a queued order approaches or passes the two-hour window without being finalized, it does not silently disappear or auto-cancel — it is flagged "Expired / Requires Review" and surfaced with priority in the dispatch automation engine (Module 5 §10, Module 17) until a staff member resolves it.
10. **Server-side truth (new).** Prices, totals, balances, roles, and permissions are never trusted from the browser; every one of these is computed or re-validated server-side at the moment of the mutating action.

---

# 5. User Roles & Permissions Matrix

## 5.1 Roles

| Role | Purpose | Access Level |
|---|---|---|
| Customer User | Places and tracks orders for their own business | Own profile, assigned prices, cart, orders, ledger, payments, exports |
| Centralized Staff User | Creates orders on behalf of any customer and processes queue/payment/dispatch activity | Customer operations, queue, customer profiles, payments, products (read + limited edit), dispatch, reports, dashboard |
| Branch Manager (new, optional role) | Same as Centralized Staff, scoped to one branch/location | Everything Staff can do, filtered to their assigned branch (see Module 19) |
| Master Admin | Full operational and configuration control | All staff capabilities plus user management, customer/product administration, audit logs, settings, and system controls |

A centralized staff user can select any customer profile and create an order on that customer's behalf without logging in separately as that customer. Every order must clearly show whether it was created by the customer directly or by a staff member, including the creator's name, role, and timestamp.

## 5.2 Granular Permission Matrix

| Capability | Customer | Staff | Branch Manager | Master Admin |
|---|:---:|:---:|:---:|:---:|
| View own orders/ledger | Yes | - | - | - |
| Place order for self | Yes | - | - | - |
| Place order on behalf of any customer | No | Yes | Branch-scoped | Yes |
| Edit queued order | No | Yes | Branch-scoped | Yes |
| Finalize order to ledger | No | Yes | Branch-scoped | Yes |
| Cancel order | No | Yes (with reason) | Branch-scoped | Yes |
| Record payment | No | Yes | Branch-scoped | Yes |
| Reverse/correct payment | No | No (request only) | No (request only) | Yes |
| View any customer profile | No (own only) | Yes | Branch-scoped | Yes |
| Create/edit customer | No | Limited (profile fields) | Limited | Yes (full) |
| Freeze/deactivate customer | No | No | No | Yes |
| Create/edit product | No | No | No | Yes |
| Deactivate product | No | No | No | Yes |
| Set customer-specific price | No | Suggest only (staff request, admin approves) — configurable | Same as Staff | Yes |
| Assign/manage drivers & dispatch routes | No | Yes | Branch-scoped | Yes |
| View reports | Own exports only | Yes | Branch-scoped | Yes |
| View audit logs | No | No | No | Yes |
| Manage users (staff/admin accounts) | No | No | No | Yes |
| Manage system settings/automation rules | No | No | No | Yes |
| Manage branches | No | No | No | Yes |

> Exact permission flags per role are stored in a `role_permissions` configuration table (Module 20) rather than hardcoded, so Master Admin can fine-tune access without a code deployment.
# 6. Module 1 — Authentication & Access Control

## Purpose

Provide secure login, logout, password management, role-based access, and strict data isolation. Customers must never access another customer's data, while staff and administrators receive only the permissions assigned to their roles.

## 6.1 Pages

- `/login` — Login page
- `/forgot-password` — Forgot-password page
- `/reset-password` — Reset-password page (token-based, from emailed/SMS link)
- `/profile/change-password` — Change-password page (authenticated, self-service)
- `/unauthorized` — Unauthorized-access page
- `/account-frozen` — Account-frozen page
- `/session-expired` — Session-expired page
- `/2fa-verify` — Two-factor verification page (staff/admin only — new, see §6.5)

## 6.2 Login Page — Full Component Inventory

- Company logo and "Eman Bakery Wholesale Portal" heading, with a subtle logo fade/scale-in on page load
- Username/email field, with floating label and inline format validation
- Password field with show/hide password toggle button (eye icon)
- "Remember me" checkbox
- Primary "Log In" button — disabled until both fields are non-empty, shows an inline spinner and switches label to "Logging in…" while the request is in flight
- "Forgot password?" link
- Clear inline validation messages for empty fields, invalid email format, and invalid credentials
- Loading state while authentication is processing (button spinner + form fields disabled, not a full-page blocking spinner)
- Language switcher control (English/Arabic), top-right, persists preference
- Arabic/English-ready interface architecture, even if English is the initial application language; layout must mirror correctly in RTL
- Background: subtle ambient bakery-brand motion (soft slow-moving warm gradient), never distracting, respects reduced-motion
- Footer: version/build tag (staff/admin builds only, hidden for customers), support contact link

## 6.3 Field-Level & Submission Errors

| Trigger | Message |
|---|---|
| Empty email/username on blur | "Please enter your email or username." |
| Malformed email | "Please enter a valid email address." |
| Empty password on blur | "Please enter your password." |
| Wrong credentials | "The email/username or password you entered is incorrect." |
| Account frozen | Redirect to `/account-frozen`: "Your account is currently inactive. Please contact Eman Bakery administration." |
| Too many failed attempts | "Too many attempts. Please try again in [X] minutes or reset your password." (rate-limited, see §31 Security) |
| Network/server failure | "We couldn't reach the server. Please check your connection and try again." |
| Session expired mid-use elsewhere | Redirect to `/session-expired`: "Your session has expired. Please log in again." |

## 6.4 Forgot Password / Reset Password Flow

**`/forgot-password`:**
- Email/phone input field
- "Send reset link" button → success state: "If an account exists for this email, a reset link has been sent." (deliberately non-revealing of account existence, to prevent user enumeration)
- "Back to login" link

**`/reset-password?token=...`:**
- New password field + confirm-password field, both with show/hide toggles
- Live password-strength indicator (weak/fair/strong bar with color + label)
- Rules displayed inline: minimum length, at least one number, at least one letter
- "Reset Password" button, disabled until both fields match and meet strength rules
- Error states: "This reset link has expired. Please request a new one." / "Passwords do not match." / "Password does not meet the minimum requirements."
- Success state: confirmation message + auto-redirect to `/login` after a short delay, with a manual "Go to login" button as fallback

## 6.5 Two-Factor Verification (new, staff/admin only)

Given staff and admin accounts can record payments, edit prices, and finalize financial transactions, an optional but recommended step-up verification is included:
- 6-digit code input (SMS or authenticator app, configurable in Module 20 Security Settings)
- "Resend code" link with a visible cooldown timer
- "Trust this device for 30 days" checkbox
- Error: "The code you entered is incorrect or has expired."

## 6.6 Access Rules

- Customers are redirected to `/customer/dashboard` after login.
- Centralized Staff Users are redirected to `/staff/dashboard`.
- Branch Managers are redirected to `/staff/dashboard`, pre-filtered to their branch.
- Master Admins are redirected to `/admin/dashboard`.
- Frozen users cannot log in and must see the clear account-frozen message above.
- Role changes take effect immediately after the next authenticated request (session claims re-validated server-side on every request, not cached indefinitely).
- All login, logout, failed-login, password-reset, account-freeze, and 2FA events must be recorded in the audit log (see Module 14), including IP/device metadata where available.
- Idle sessions automatically time out after a configurable period (default 60 minutes for staff/admin, 24 hours for customers) and route to `/session-expired`.

## 6.7 Unauthorized / Frozen / Expired Pages

Each of these three pages shares a common calm, non-alarming full-screen layout: icon, one-sentence explanation, and one clear primary action.

- `/unauthorized`: "You do not have permission to view this page." → "Go to my dashboard" button
- `/account-frozen`: "Your account is currently inactive. Please contact Eman Bakery administration." → "Contact support" button (opens WhatsApp/phone/email per configured support channel)
- `/session-expired`: "Your session has expired for your security." → "Log in again" button
# 7. Module 2 — Customer Dashboard

## Purpose

Give each customer a simple e-commerce-style homepage where they can immediately understand their outstanding balance, place an order, and review current activity. The customer must only see data related to their own business account.

## 7.1 Dashboard Widgets

- **Outstanding balance hero card** — the largest element on the page, in the display/serif figure treatment described in §2.1, with the count-up animation on load. Color shifts to an amber/red accent if the balance exceeds a configurable threshold or aging period.
- Available credit summary (shown once credit-limit support is enabled — see Module 20 feature flags)
- Orders currently in queue — count + live countdown chip for the soonest-expiring one
- Total orders placed today
- Last order date and amount, with a one-click "Reorder this" shortcut
- Recent payments received (last 3, with a "View all" link into the ledger)
- Quick "Place New Order" button — the visually dominant primary action on the page
- Quick "View Order History" button
- Quick "View Ledger" button
- Recent activity timeline (order submitted, order edited by staff, order finalized, payment posted — each with icon, timestamp, and relative time e.g. "12 minutes ago")
- Notifications panel for order status changes, payment postings, and important account announcements, with an unread-count badge
- "Your most-ordered products this month" mini-strip with one-tap "add to cart" per item (ties into Module 17 automation)

## 7.2 Customer Navigation

- Dashboard
- New Order
- My Orders
- Order Queue
- Ledger & Payments
- My Profile
- Help / Contact Support
- Logout

Navigation is a collapsible side rail on desktop and a bottom tab bar on mobile (see Module 18), with the cart icon always pinned and visible showing a live item-count badge regardless of which page the customer is on.

## 7.3 Dashboard Behavior

- The dashboard must update in realtime when a queued order is edited, finalized, or when a payment is recorded by staff — via a live subscription, not polling. Updated widgets perform the realtime highlight-flash motion described in §2.2.
- The outstanding balance must be calculated from finalized credit sales minus all posted customer payments, computed server-side.
- First-time / no-history customers see a friendly empty-state hero instead of empty widgets: "Welcome to Eman Bakery! Place your first order to get started." with a large "Browse Products" call to action.
- Loading state: skeleton cards matching the exact shape of each widget (never a full-page spinner replacing the whole dashboard).
- Error state (data failed to load): a small inline retry card per widget rather than failing the entire page — "We couldn't load this. [Retry]".

## 7.4 Customer Profile Page (`/customer/profile`)

- Business name, contact person, phone, WhatsApp number, address/location (read-only unless self-edit is enabled by Master Admin policy)
- Assigned account code
- "Request profile change" button (routes a change request to staff rather than allowing direct silent edits to commercially relevant data)
- "Change Password" button → `/profile/change-password`
- Notification preferences (email/SMS/WhatsApp toggles per notification category)
- Language preference toggle (English/Arabic)
- "Download my data" export button (orders, ledger, payments — for the customer's own records)
# 8. Module 3 — Product Catalog & Ordering

## Purpose

Enable customers and staff to create orders through a fast, modern, e-commerce-style product catalog. Products must display the correct price for the currently selected customer.

## 8.1 Product Catalog Page Layout

- Sticky header bar: search input, category filter chips, sort control, view toggle (grid/list), "Clear Filters" action, live result count
- **Recently Ordered Products** section — always the first section shown, horizontally scrollable "quick add" row of the customer's most recent order items, each with a one-tap quantity stepper directly on the card (no need to open a detail view to reorder)
- **All Products** section — full responsive grid below it, grouped/filterable by category
- Sticky/floating cart summary bar (mobile: bottom sheet handle; desktop: persistent right-side drawer trigger) showing live item count and subtotal, expandable into the full cart

## 8.2 Product Card Components

- Product image (with a graceful placeholder illustration if no image is set — never a broken-image icon)
- Product name
- Product code/SKU (small, secondary text)
- Category tag
- Unit of measure (piece, packet, tray, carton, box)
- Customer-specific unit price, prominently displayed; if a customer-specific override is active, a small "Your Price" tag appears next to it
- Base price shown struck-through in secondary color only when it differs from the customer's price (so staff instantly see a discount is applied)
- Quantity selector with minus and plus buttons, plus a manual numeric input for typing an exact quantity directly
- "Add to Cart" button — becomes a live quantity stepper in-place once the item is in the cart, rather than requiring a separate step
- Product availability note badge, if manually configured as limited/unavailable ("Currently unavailable" — button disabled with the badge visible, never just silently missing from the list)
- Favorite/pin toggle (star icon) — lets frequent buyers pin their top items to the very top of the grid regardless of filters
- Hover/tap micro-interaction: card lifts slightly with a soft shadow (desktop hover) or subtle press-scale feedback (touch)

## 8.3 Product Quick-View

Tapping a product image (not the add-to-cart control) opens a quick-view panel (side sheet on desktop, bottom sheet on mobile) with:
- Larger image, full description
- Full price breakdown (base price vs. your price, unit of measure)
- Quantity selector + "Add to Cart"
- "Order history for this product" mini list (last 5 times this customer ordered it, with quantity and date)
- Close button / swipe-to-dismiss

## 8.4 Search & Filter Requirements

- Product search must support partial matches anywhere in the product name.
- Search should work even if the user types only part of a word.
- Search results update instantly (debounced, no page refresh, no visible "loading" flash for typical catalog sizes).
- Products can be filtered by category, via chip-style multi-select filters.
- Filters must have a visible "Clear Filters" action, shown only when at least one filter is active.
- Sort controls: Recommended (recent-order-first default), Name A–Z, Name Z–A, Price low–high, Price high–low, Category.
- When no products match: empty-state illustration + "No products found. Try another keyword or clear your filters." with a one-tap "Clear Filters" button inline in the message.
- Category filter chips and the search bar remain sticky while scrolling the grid.

## 8.5 Catalog Animation Specification (see also §2.2)

- On any filter, search, or sort change, the grid does **not** hard-replace instantly: exiting cards fade/scale out (~120ms), the grid reflows, and entering/remaining cards fade-and-rise in with a small stagger (~20-30ms per card, capped so large grids don't feel slow) — this is the primary "wow factor" motion moment of the app since it happens constantly during ordering.
- Category chip selection has a sliding "pill" background indicator that animates between chips rather than instantly repainting.
- Switching grid/list view performs a shared-layout transition (cards morph shape rather than the page flashing to a different layout).
- Skeleton shimmer placeholders (matching card shape) show only on the very first catalog load, not on subsequent filter changes (those use the fade/stagger above instead, since data is already client-cached).

## 8.6 Recent Order Prioritization Logic

The first products displayed are based on the customer's most recent order, because customers often purchase the same products daily — this reduces ordering time for both customers and centralized staff. If a customer has no order history, this section is hidden and "All Products" becomes the top-level section, alongside a "Popular this month across all customers" fallback row to still speed up first-time ordering.
# 9. Module 4 — Shopping Cart & Checkout

## Purpose

Allow users to review the order before submission and create a credit order efficiently. The interface must feel familiar to users of modern e-commerce applications.

## 9.1 Cart Page / Drawer Components

- Customer name and account reference (and, in staff mode, a persistent "Ordering as: [Customer Name] — Switch Customer" banner so staff never lose track of whose order they're building)
- Order creation mode indicator: "Created by Customer" or "Created by Staff (Name)"
- List of cart items: product image thumbnail, name, price, quantity, line total
- Increase/decrease quantity controls directly in the cart row, plus manual quantity entry
- Remove-item button (with a brief "Undo" toast rather than an immediate irreversible removal — see §9.4)
- Order subtotal, live-updating with the number-roll animation on every change
- Optional customer note field (free text — e.g., delivery instructions)
- Optional internal staff note field, visible only to staff/admin, clearly labeled "Internal note — not visible to customer"
- Preferred collection/delivery time selector (new — feeds Module 16 dispatch scheduling)
- "Continue Shopping" button (returns to catalog, preserving cart state)
- "Clear Cart" button with confirmation modal
- "Review Order" button (advances to a final read-only review step before submission for larger orders; optional/skippable for very small orders to keep things fast)
- "Submit Order" button — primary, full-width on mobile, disabled while empty or invalid, shows spinner + "Submitting…" while in flight

## 9.2 Empty Cart State

Illustration + "Your cart is empty." + "Browse Products" button. If the customer has order history, a "Reorder your last order" button is also offered directly in the empty state.

## 9.3 Checkout Validation

- Cart cannot be submitted when it is empty.
- Quantity must be greater than zero for every line item.
- Product price must be retrieved from the active customer pricing record at submission time (re-validated server-side, not just trusted from the cart state held in the browser).
- The system must calculate all totals server-side to prevent browser-side price manipulation.
- A duplicate-submission guard (disable button + idempotency key on the request) must prevent accidental double-click order creation.
- If a product became unavailable or its price changed between adding to cart and submitting, the system blocks submission and shows exactly which line items changed, with an inline "Update cart" action rather than a generic failure.
- Once submitted, the system shows an order confirmation number and success message with the full-screen success animation described in §2.2.

## 9.4 Cart Error & Recovery States

| Situation | Behavior |
|---|---|
| Item removed by mistake | Toast: "Removed [Product]. [Undo]" — undo restores exact quantity for ~6 seconds |
| Quantity set to 0 via manual input | Treated as "remove item," same undo toast |
| Price changed since adding to cart | Inline banner on the affected row: "Price updated to [new price] since you added this." with an acknowledgment tap required before submit |
| Product deactivated after being added | Row is flagged "No longer available" and excluded from the submit total until removed |
| Submission fails (network/server) | "We couldn't submit the order right now. Please try again." — cart contents are preserved, never cleared on failure |
| Submission succeeds | "Order #EB-20260724-00125 has been submitted successfully and is now awaiting staff confirmation." with a "View Order" and "Place another order" pair of actions |

## 9.5 Staff-Mode Cart Differences

When a staff user is building an order on behalf of a customer, the cart additionally shows:
- A compact "recently ordered by this customer" quick-add strip pinned to the top of the cart itself (not just the catalog), so staff rarely need to leave the cart at all for repeat orders
- A running comparison to the customer's typical order size/value ("This order is 30% larger than their usual order" — informational only, non-blocking) to help staff sanity-check phoned-in orders
# 10. Module 5 — Order Queue & Smart Dispatch Automation Engine

## Purpose

Provide centralized staff with a live operational queue for all orders submitted by customers or staff, and layer a dedicated automation engine on top of it so that dispatching an order — reviewing it, adjusting it, and posting it to the ledger — is the fastest possible sequence of clicks for staff. Orders remain editable in the queue for up to two hours, allowing staff to adjust the order based on actual product availability or customer changes.

## 10.1 Queue Page Components

- Queue summary cards: total queued orders, orders due soon (< 30 min remaining), orders older than one hour, staff-created orders, customer-created orders, orders flagged for review
- Search by order number, customer name, phone number, or creator
- Filters by status, customer, order source, date, branch (Module 19), and staff user
- Sort by oldest order, newest order, pickup/delivery time, customer name, or amount
- Live countdown timer for each queued order, rendered as the draining circular-progress ring described in §2.2
- Order status badge, animated cross-fade on change
- View toggle: **Board view** (Kanban-style columns by status — new default) and **Table view** (dense list for high-volume scanning)
- "Open Order" action
- "Edit Order" action
- "Finalize to Ledger" action
- "Cancel Order" action, subject to permission and reason entry
- **Bulk selection mode** (new): checkbox-select multiple orders to bulk-finalize, bulk-print, or bulk-assign a driver in one action, with a floating action bar that slides up from the bottom once one or more rows are selected

## 10.2 Queue Statuses

- Draft
- Submitted
- In Queue
- Under Review
- Edited by Staff
- Ready for Pickup
- Out for Delivery *(new — ties to Module 16)*
- Delivered
- Collected
- Finalized to Ledger
- Cancelled
- Expired / Requires Review

## 10.3 Queue Editing

Staff must be able to add products, remove products, increase quantity, decrease quantity, and add internal notes while the order is still in queue. Each modification must create an order revision record that stores the previous value, new value, staff member, timestamp, and reason for change. Inline editing happens directly in the order detail panel (no separate "edit mode" page) with autosave-per-field and a small "Saved" checkmark micro-animation after each change, so staff never lose edits or need to hunt for a save button.

## 10.4 Finalization Workflow

1. Customer or staff submits an order.
2. The order enters the Order Queue.
3. Staff reviews availability and customer requests.
4. Staff edits the order if required.
5. Staff confirms that the customer collected the goods or that delivery was completed (optionally assigning a driver — Module 16).
6. Staff selects "Finalize to Ledger."
7. The system creates the credit-sale ledger transaction.
8. The customer's outstanding balance updates immediately.
9. The customer receives a realtime status update.

## 10.5 Smart Dispatch Automation Engine — The Centralized Speed Layer

This is the layer that directly answers the operational goal of dispatching orders in the fastest, easiest way through a centralized interface. It sits on top of the queue described above and never removes a human's final confirming action on anything financial — it removes the *manual work* leading up to that click.

### 10.5.1 One-Screen Dispatch Console

A dedicated `/staff/queue` "Console" mode presents queued orders as a single scrollable stream of compact cards, each fully actionable without navigating away:
- Customer name, order source badge, item count, total, countdown ring — all visible on the card face
- Expand-in-place (accordion, not a route change) to see/edit line items
- **Keyboard-first operation**: arrow keys move between orders, `E` edits, `F` finalizes, `C` cancels, `/` focuses search — so an experienced staff member can process a stack of orders almost entirely without the mouse
- Every action (edit save, finalize, cancel) is a single click/keystroke plus one confirmation, never a multi-page flow

### 10.5.2 Auto-Suggested Actions

- Orders that exactly match the customer's typical basket (same products ± small quantity variance) are flagged "Matches usual order" with a single "Quick Finalize" button that skips straight to the confirmation dialog, since there is nothing unusual to review.
- Orders containing a product currently marked unavailable are automatically flagged at the top of the queue with the specific line item highlighted, rather than staff discovering it manually mid-review.
- If a customer has an unusually large or unusually small order relative to their history, it's flagged "Unusual order size — please confirm" so staff attention goes where it's actually needed instead of being spent equally on every order.

### 10.5.3 Time-Based Automation & Alerts

- Orders crossing 90 minutes in queue (configurable) trigger an escalating visual state (ring turns amber) and, if enabled in Module 20, a Slack/WhatsApp alert to the on-duty staff channel so nothing quietly expires.
- Orders that do pass the two-hour window move to "Expired / Requires Review" — never auto-cancelled and never auto-finalized — and are pinned to the top of every staff member's queue until resolved.
- A configurable end-of-day sweep can notify a supervisor of any orders still open past a cutoff time.

### 10.5.4 Bulk & Batch Operations

- Multi-select "Finalize All Matching Usual Order" for a batch of routine, unmodified orders in one confirmation instead of one-by-one.
- Batch "Print Pick Tickets" / "Print Delivery Slips" for all orders assigned to a given driver or route (see Module 16), generated as a single combined PDF.
- Batch driver assignment: select several "Ready for Pickup/Delivery" orders and assign them to one driver/route in a single action.

### 10.5.5 Centralized Staff Ordering Speed Path

For phoned-in orders (Module 10), the console offers a persistent "New Order" floating action that opens a slide-over with customer search → catalog (pre-sorted to that customer's usual items) → cart, all in one continuous panel without full page navigation, so staff never leave the queue context to build and submit a new order for a calling customer.

## 10.6 Queue Error & Edge States

| Situation | Behavior |
|---|---|
| Two staff members open the same order simultaneously | Second viewer sees a non-blocking banner: "[Name] is also viewing this order." Last-write-wins with full revision history preserved; no silent overwrite without a trace. |
| Finalize attempted on an order with a zero-price or missing-price line item | Blocked with: "This order has a pricing issue and cannot be finalized. Please review the highlighted item." |
| Cancel attempted without a reason | Submit disabled until a reason is entered: "Please provide a reason for cancelling this order." |
| Network failure during finalize | "We couldn't finalize this order. Nothing has been posted to the ledger — please try again." (Finalization is transactional: either the ledger entry and status both succeed, or neither does.) |
| Empty queue | Friendly empty state: "No orders in the queue right now." with a shortcut to start a new staff order |
# 11. Module 6 — Order Details & History

## Purpose

Give customers, staff, and administrators a complete, auditable view of each order from creation through finalization.

## 11.1 Order Detail Page Components

- Order number
- Order date and time
- Customer name and account code
- Order source: customer-created or staff-created
- Created-by user name and role
- Order status and animated status timeline (horizontal stepper: Submitted → In Queue → [Edited] → Ready → Delivered/Collected → Finalized)
- Full list of ordered products, with quantity, unit price, line total, order total
- Customer note
- Internal staff note, access-controlled (hidden entirely from customer view, not merely visually de-emphasized)
- Edit history and revision timeline — expandable per revision, showing exactly what changed, who changed it, and when
- Finalized-by user and finalization timestamp
- Payment status summary (unpaid / partially applied against balance / see ledger — since payments post to the overall account, not per-order, this section clearly explains that relationship rather than implying a false per-order paid status)
- Assigned driver / delivery status, if dispatch is in use (Module 16)
- Download PDF button
- Export Excel button
- Share via WhatsApp button
- Back button to the relevant listing page (returns to the exact previous scroll position/filter state, not a reset list)

## 11.2 Order History List (`/orders`, `/staff/queue` history tab, `/admin` order history)

- Customers can view all of their historical orders, including queued, finalized, cancelled, and staff-created orders.
- Staff and administrators can view order history for any customer, with filters and search controls.
- Standard shared DataTable (see §2.3): search, status filter, date-range filter, source filter, sort, pagination, export.
- Empty state for a brand-new customer: "No orders yet." + "Place your first order" button.
- Each row supports a one-click "Reorder" action that pre-fills a new cart with that order's items at current prices.

---

# 12. Module 7 — Customer Ledger and Payments

## Purpose

Maintain a transparent running ledger for every customer. All sales are posted as credit when finalized, and payments can be recorded later in any amount, including partial payments.

## 12.1 Ledger Formula

Outstanding Balance = Finalized Credit Sales − Posted Payments

## 12.2 Ledger Page Components

- Current outstanding balance (hero treatment, same component as the dashboard widget)
- Opening balance, where applicable
- Date range filter
- Transaction-type filter
- Search by reference number or order number
- Ledger table: date, type, reference, debit, credit, running balance — running balance column highlighted and animates on new rows
- PDF export button
- Excel export button
- WhatsApp share button
- Print action

## 12.3 Ledger Transaction Types

- Opening balance
- Credit sale from finalized order
- Payment received
- Payment correction
- Authorized adjustment
- Reversal, if an approved error correction is required

## 12.4 Payment Recording Form (`/staff/payments/new`, `/admin/payments/new`)

Only staff and administrators can record payments.

Fields:
- Customer (searchable select)
- Payment date and time
- Amount received
- Payment method dropdown: Cash, Bank Transfer
- Bank reference / transaction reference — required for bank transfer, field appears/becomes required only when that method is selected
- Internal note
- Receipt reference number (auto-suggested next sequential number, editable)
- "Record Payment" button — shows a confirmation dialog summarizing customer, amount, and method before posting
- "Cancel" button

## 12.5 Payment Rules & Validation

- Payments may be less than, equal to, or greater than the value of any individual order.
- Payments are posted to the customer's overall account balance, not necessarily to one specific order.
- A payment record must never be permanently deleted.
- If a correction is required, the system must create a reversal or adjustment transaction with a reason and approval trail — never a direct edit of the original record.
- Recording a payment must update the customer ledger and dashboard in realtime, including the flash-highlight motion on the affected balance figure.
- Validation errors: "The payment amount must be greater than zero." / "Please select a payment method." / "A bank reference is required for bank transfer payments."

## 12.6 Ledger/Payment Error States

| Situation | Message |
|---|---|
| Payment amount is zero or negative | "The payment amount must be greater than zero." |
| No payment method selected | "Please select a payment method." |
| Bank transfer missing reference | "Please provide a bank reference number for this transfer." |
| Save fails | "We couldn't record this payment. Your previous data has not been affected — please try again." |
| Ledger export fails | "We couldn't generate this export. Please try again in a moment." |
# 13. Module 8 — Customer Management

## Purpose

Allow centralized staff and master administrators to manage customer accounts, profile data, login access, customer-specific prices, and account activity.

## 13.1 Customer List Page (`/customers`)

- Search by customer name, account number, phone number, or business name
- Alphabetical filter buttons: A–Z
- Status filters: Active, Inactive, Frozen
- Outstanding-balance filter (e.g., over threshold, overdue > N days)
- Customer list table or card view toggle
- "Add Customer" button
- "Export Customers" button
- Customer count display
- Each row shows a small live balance figure and a "days since last order" chip, so staff can spot at-risk/inactive accounts at a glance

## 13.2 Customer Profile Page (`/customers/:id`)

- Customer business name
- Customer contact person
- Phone number
- WhatsApp number
- Address/location
- Customer account code
- Account status
- Login account status
- Current outstanding balance
- Recent order summary
- Recent payment summary
- Customer-specific price list
- Order history tab
- Ledger tab
- Payment history tab
- Activity log tab
- Notes tab (internal, staff-visible only)
- "Edit Customer" button
- "Freeze Customer" button (with confirmation dialog explaining consequence: customer will be unable to log in or order)
- "Reset Password" button (generates and sends a reset link, does not display or set a password directly)
- "Create Order for Customer" button — the fast path into Module 10's staff ordering flow
- Back button

## 13.3 Add / Edit Customer Form

- Business name (required)
- Contact person name (required)
- Phone number (required, format-validated)
- WhatsApp number (optional, defaults to phone if left blank)
- Address / location (with optional map-pin selection)
- Account code (auto-generated, editable by Master Admin only)
- Assigned branch (Module 19, if multi-branch enabled)
- Initial login credentials generation (auto-generate secure temporary password + forced change on first login, rather than staff choosing a password)
- Save / Cancel buttons
- Validation errors: "Business name is required." / "Please enter a valid phone number." / "An account with this phone number already exists."

## 13.4 Customer-Specific Pricing

When a new product is created, its base price becomes available to all customers by default. Staff or administrators can open an individual customer profile and override the price of any product for that specific customer.

Each price record must contain:
- Product
- Customer
- Base price
- Customer-specific price
- Effective date
- Changed by
- Change reason
- Previous price
- New price
- Timestamp
- Active/inactive status

**Pricing UI:** a searchable, editable table within the customer profile's price list tab — inline-editable per row (click the price cell, type the new value, confirm), with the old price shown struck-through briefly before settling (mirrors the catalog price-change animation in §2.2) and a mandatory one-line change reason captured in a small popover before the change commits.

**Bulk pricing tools (new):** "Apply X% discount to all products for this customer," "Copy price list from another customer," and "Reset all overrides to base price" — each behind its own confirmation dialog summarizing exactly how many products will change.

---

# 14. Module 9 — Product Management

## Purpose

Manage the bakery product catalog, categories, base pricing, and product visibility. Inventory tracking is not included in the initial release.

## 14.1 Product List Page (`/products`)

- Search by product name, product code, or category
- Category filters
- Active/inactive filter
- "Add Product" button
- "Export Products" button
- Product count
- Sort controls
- Drag-to-reorder handles for controlling catalog display order (persists to `display_order`, animates with the drag-reorder motion in §2.2)

## 14.2 Product Form Fields (Add/Edit)

- Product name (required)
- Product code/SKU (required, uniqueness validated live as typed)
- Category (select or quick-create new category inline)
- Product description
- Unit of measure (piece, packet, tray, carton, box)
- Base price (required, numeric, currency-formatted input)
- Product image (drag-and-drop upload with live preview and crop tool; graceful placeholder if skipped)
- Active/inactive status toggle
- Display order
- Optional product tags (e.g., "Best seller," "New," "Seasonal" — shown as small badges on the catalog card)
- Save / Cancel buttons, with unsaved-changes confirmation if navigating away mid-edit

## 14.3 Product Rules

- A product should be soft-deactivated instead of permanently deleted if it has already appeared in orders.
- Historical orders must retain the original product name and price snapshot used at the time of ordering.
- Changing a product's base price must not overwrite previous order prices or customer-specific pricing history.
- All product and base-price changes must appear in the audit log.
- Deactivating a product that exists in currently-queued (not yet finalized) orders triggers a warning listing the affected queued orders so staff can resolve them, rather than silently breaking an in-progress order.

## 14.4 Product Management Error States

| Situation | Message |
|---|---|
| Duplicate SKU | "This product code is already in use." |
| Missing required field on save | "Please fill in the [field name] field." |
| Image upload fails | "We couldn't upload this image. Please try a smaller file or a different format." |
| Deactivating a product used in open queue orders | "This product appears in [N] queued orders. Deactivating it won't remove it from those orders, but it will no longer be available for new orders. Continue?" |
# 15. Module 10 — Centralized Staff Ordering

## Purpose

Enable staff to place an order quickly for any customer who cannot or does not want to use the customer portal. The resulting order must behave exactly like a customer order, while preserving who created it.

## 15.1 Staff Flow

1. Staff opens the Customers page (or the persistent "New Order" quick action from anywhere — see §10.5.5).
2. Staff searches or filters for the customer.
3. Staff opens the customer profile, or selects the customer directly from the quick-action search.
4. Staff selects "Create Order for Customer."
5. The system loads the customer's assigned prices and recently ordered products.
6. Staff adds items and quantities.
7. Staff reviews and submits the order.
8. The order enters the same Order Queue used for customer-created orders.
9. The order history shows that it was created by the selected staff member.

## 15.2 Performance Features

- Customer quick search with partial-name matching
- A–Z customer filtering
- Recently ordered products at the top
- Keyboard-friendly quantity editing (tab between quantity fields, arrow-key increment)
- Persistent cart while navigating between product categories
- Optimistic interface updates where safe (item appears in cart instantly; reconciled against server confirmation)
- Server-side validation before final submission
- Fast realtime synchronization through Supabase
- **Phone-call mode (new):** a compact, single-column layout optimized for a staff member actively on a call — large touch targets, minimal scrolling, voice-friendly large text for product names, so an order can be built while reading products aloud to a customer

## 15.3 Staff Ordering Error States

| Situation | Message |
|---|---|
| No customer selected before adding items | "Please select a customer to start this order." |
| Customer is frozen/inactive | "This customer's account is currently inactive and cannot place new orders." |
| Submitting with an empty cart | Submit button remains disabled; no error needed since the action is simply unavailable |

---

# 16. Module 11 — Master Admin Management

## Purpose

Give the Master Admin full control over users, customers, products, system settings, audit visibility, and operational access.

## 16.1 Admin Navigation

- Dashboard
- Orders Queue
- Customers
- Products
- Payments
- Dispatch (Module 16)
- Reports
- User Management
- Audit Logs
- System Settings (Module 20)
- Profile
- Logout

## 16.2 User Management Features (`/admin/users`)

- Create centralized staff users (and Branch Managers, if multi-branch enabled)
- Edit user name, phone, email, and role
- Activate users
- Freeze users
- Reset user passwords
- View last login
- View user activity
- Restrict access based on role (assign granular permission overrides per §5.2)
- Prevent deletion of users with historical activity; use deactivation instead
- Add/Edit User form fields: full name, email, phone, role, branch assignment, permission overrides, active/inactive toggle
- Error states: "This email is already registered." / "Please assign at least one role."

## 16.3 Customer Management Features (admin-level, superset of Module 8)

- Add new customer
- Edit customer profile
- Activate, deactivate, or freeze customer access
- Assign customer login credentials
- Reset customer password
- Configure customer-specific product prices
- View complete customer activity and ledger

---

# 17. Module 12 — Admin and Staff Command Center (Dashboard)

## Purpose

Provide realtime operational visibility for centralized staff and master administrators. Customers do not have access to this operational dashboard.

## 17.1 Dashboard Metrics

- Today's total finalized sales (hero KPI, count-up animation)
- Today's total orders
- Orders currently in queue
- Orders finalized today
- Orders awaiting review
- Orders nearing the two-hour queue limit
- Active customers
- Total customers
- Active staff users
- Total outstanding receivables
- Payments received today
- Cash payments received today
- Bank-transfer payments received today
- Sales trend chart (line, animated draw-in on load)
- Payment trend chart
- Top customers by sales
- Top products by quantity or sales value
- Recent operational activity feed
- **Dispatch snapshot (new):** orders ready for pickup, orders out for delivery, active drivers — pulled from Module 16
- **Automation insights strip (new):** "3 orders match usual baskets and are ready to quick-finalize" / "1 order flagged unusual size" — direct links into the filtered queue view, from Module 17

## 17.2 Realtime Requirements

All dashboard totals, queue counts, payment totals, and activity feeds must refresh in realtime without requiring manual page reloads. The dashboard must clearly identify the selected date range and provide filters such as today, yesterday, this week, this month, and custom range. Widgets are drag-reorderable per staff member's own preference (layout preference persisted per user, not global).

## 17.3 Dashboard Loading/Empty/Error States

- Loading: skeleton widgets shaped exactly like their final content
- No activity yet (new deployment/quiet day): "No activity yet today." rather than a blank chart
- Widget-level fetch failure: inline retry, isolated to that widget only

---

# 18. Module 13 — Reports and Exports

## Purpose

Provide powerful, dynamic, filterable reports based on orders, customers, products, payments, ledger activity, pricing, users, and audit events. Reports must support export to Excel, PDF, and WhatsApp sharing where relevant.

## 18.1 Required Reports

- Daily sales report
- Sales report by date range
- Sales by customer
- Sales by product
- Sales by category
- Sales by staff creator
- Customer-created versus staff-created orders
- Queued orders report
- Finalized orders report
- Cancelled orders report
- Order modification report
- Customer outstanding balance report
- Customer ledger statement
- Payment collection report
- Cash payment report
- Bank transfer report
- Payment report by staff member
- Top customers report
- Top products report
- Customer-specific price report
- Product base-price change report
- Customer price override history
- User activity report
- Login and security activity report
- Audit log report
- **Dispatch/delivery performance report (new)** — average time from finalize to delivered, on-time percentage per driver
- **Automation impact report (new)** — quick-finalized orders vs. manually reviewed, average queue processing time before/after automation adoption

## 18.2 Report Controls

- Date-range selector (with quick presets: today, yesterday, this week, this month, custom)
- Search box
- Customer filter
- Product filter
- Category filter
- Staff-user filter
- Status filter
- Payment-method filter
- Sorting controls
- Column visibility controls
- Export to Excel
- Export to PDF
- Share via WhatsApp
- Print action
- Reset filters action
- Report results render as a chart + table combination where relevant (e.g., sales trend), with the chart draw-in animation from §2.2

## 18.3 Report Error/Empty States

- No data for selected filters: "No records match the selected filters." + "Reset Filters" button inline
- Export failure: "We couldn't generate this export. Please try again in a moment."
- Very large export (new): a background-generation flow with a progress toast and a "We'll notify you when it's ready" fallback for exports exceeding a size threshold, rather than freezing the UI
# 19. Module 14 — Audit Trail and Data Integrity

## Purpose

Ensure that all commercially significant activity is traceable, reviewable, and protected from silent data loss. This is mandatory for order creation, price changes, customer changes, user actions, queue edits, payment records, and ledger corrections.

## 19.1 Audit Log Fields

- Audit event ID
- Timestamp
- User ID
- User name
- User role
- Action type
- Module name
- Record type
- Record ID
- Previous value
- New value
- Reason for change
- IP/device metadata, where appropriate
- Related customer ID
- Related order ID

## 19.2 Audit Log Page (`/admin/audit-logs`)

- Standard shared DataTable: search, filter by user/module/action type/date range, sort
- Each row expandable in-place to a before/after diff view (previous value vs. new value shown side-by-side, changed fields highlighted)
- Export to Excel/PDF
- Visible only to Master Admin users unless a restricted audit view is granted later (Module 20 permission flag)

## 19.3 Audit Rules

- No financial transaction can be permanently deleted.
- Order revisions must preserve the original ordered quantities and prices.
- Price changes must preserve both old and new prices.
- Payment corrections require a reversal or adjustment entry rather than direct editing of the original record.
- Customer deactivation, user freezing, and product deactivation must be logged.
- Audit logs themselves are append-only at the database layer (no update/delete privilege granted to any application role, enforced by Row Level Security policy, not merely application logic).

---

# 20. Module 15 — Notifications, Confirmations, and Errors

## Purpose

Provide human-friendly system feedback instead of raw database or developer error messages. Every important action should clearly tell the user what happened and what to do next.

## 20.1 Notification Channels

- In-app toast (all users)
- In-app notification center / inbox (persistent, with read/unread state)
- Email (configurable per event type)
- SMS (configurable, staff/admin critical events)
- WhatsApp (configurable — order confirmations, delivery updates, statements)
- Slack (staff/admin internal ops channel — queue-expiry alerts, large payment postings, system errors; see §30)

## 20.2 Success Notifications

- "Order submitted successfully."
- "Order updated successfully."
- "Order finalized to customer ledger."
- "Payment recorded successfully."
- "Customer price updated successfully."
- "Customer account created successfully."
- "Product created successfully."
- "Changes saved successfully."
- "You have been logged out successfully."
- "Driver assigned successfully." *(new)*
- "Export ready — download starting." *(new)*
- "Password reset link sent." *(new)*

## 20.3 Confirmation Dialogs

Use the shared ConfirmDialog component (§2.3) for:
- Submitting an order
- Clearing a cart
- Removing an item from cart
- Cancelling an order
- Finalizing an order to ledger
- Recording a payment
- Freezing a user
- Deactivating a customer
- Deactivating a product
- Reversing/correcting a payment *(new)*
- Bulk-finalizing multiple orders *(new)*
- Assigning/reassigning a driver *(new)*
- Logging out

Each dialog states the action plainly, the consequence in one sentence, and offers a clearly labeled Cancel and a clearly labeled, color-coded Confirm action (destructive actions use a warning color, routine confirmations use the brand accent).

## 20.4 User-Friendly Error Messages (Master List)

- "Unable to submit the order right now. Please try again."
- "This product is no longer available for ordering. Please contact Eman Bakery staff."
- "You do not have permission to perform this action."
- "The payment amount must be greater than zero."
- "Please select a payment method."
- "Your session has expired. Please log in again."
- "No records match the selected filters."
- "We could not save your changes. Your previous data has not been affected."
- "This action can't be completed because [specific, plain-language reason]." *(general fallback pattern for less common failures — always names the reason rather than defaulting to a generic error)*
- "You're offline. Changes will be saved once you're back online." *(new — see Module 18)*
- "This page took too long to load. [Retry]" *(new — timeout fallback)*

Raw PostgreSQL, Supabase, API, stack-trace, or internal developer errors must never be exposed to end users. Every caught error is mapped through a central error-translation layer to one of the messages above (or a specific, still-plain-language equivalent) before being shown, and the raw technical error is sent to Sentry (§30) for engineering visibility instead.

## 20.5 Global Error Boundary Behavior

- A full page-level failure (e.g., a rendering crash) never shows a blank white screen or a raw stack trace — it shows a branded "Something went wrong on our end" screen with a "Reload" button and a "Report this" link that sends the error details to Sentry with one tap.
- Network loss is detected proactively (not just on failed requests) and surfaces a persistent, unobtrusive "You're offline" banner rather than letting every subsequent action fail with an unexplained error.
# 21. Module 16 — Delivery & Driver Dispatch Coordination (New)

## Purpose

Eman Bakery operates its own drivers and salesmen across multiple locations. While the original brief centers on ordering and the ledger, "dispatch" of a finalized order into the hands of the customer is the natural next step in the same workflow — this module closes that loop so staff coordinate the full journey from order to delivery in one platform, without a separate spreadsheet or paper run-sheet.

## 21.1 Dispatch Board (`/staff/dispatch`, `/admin/dispatch`)

- Kanban-style columns: Ready for Pickup → Assigned → Out for Delivery → Delivered/Collected, mirroring the order status timeline
- Each card: customer name, address/area, order total, item count, assigned driver avatar/name, ETA
- Drag-and-drop cards between columns (with the drag-reorder spring motion from §2.2), which updates the underlying order status and fires the corresponding customer notification
- Map view toggle: pins for all "Out for Delivery" orders plotted by delivery area, color-coded by driver
- Driver filter, area/route filter, date filter

## 21.2 Driver & Route Management

- Driver directory: name, phone, assigned vehicle, active/inactive status, today's assigned order count
- Route grouping: staff can group several ready orders into a single route/run and assign it to one driver in one action
- "Assign Driver" quick-action directly from the Order Queue (Module 5) and from individual order detail pages, avoiding a context switch to a separate screen for the common case

## 21.3 Delivery Confirmation

- Driver-facing lightweight confirmation flow (mobile PWA — Module 18): mark "Delivered" or "Collected," optional photo-of-handoff capture, optional customer signature capture
- Failed-delivery path: "Customer unavailable" / "Address issue" / "Other" reason capture, which returns the order to "Ready for Pickup" rather than silently leaving it in limbo

## 21.4 Dispatch Notifications

- Customer notified (per their channel preferences — §20.1) when their order moves to "Out for Delivery," with driver name and estimated arrival window
- Customer notified on "Delivered"/"Collected"
- Staff/admin alerted if a delivery is marked failed

## 21.5 Dispatch Error States

| Situation | Message |
|---|---|
| Assigning a driver with no active status | "This driver is currently inactive and can't be assigned new deliveries." |
| Marking delivered with no driver assigned | "Please assign a driver before marking this order as delivered." |
| Map view with no geocoded address | Order pin omitted from map, order still listed in the sidebar list with a small "No location set" tag |
# 22. Module 17 — Smart Automation & AI Assist Engine (New)

## Purpose

Layer predictive, assistive automation across ordering and dispatch so the platform actively speeds up routine, repetitive work — without ever making an unsupervised financial decision. This module is the "brain" behind several behaviors already referenced in Modules 2, 3, 5, and 12; this section defines them centrally.

## 22.1 Predictive Reordering

- Per-customer purchase pattern modeling (frequency, typical basket, typical quantity per product) drives the "Recently Ordered" and "Usual Basket" surfaces throughout the catalog, cart, and dashboard.
- "Time to reorder" nudges: if a customer who reliably orders every weekday hasn't ordered by their usual time, staff see a gentle prompt on the dashboard ("Customer X hasn't ordered today — they usually do") — informational, opt-in per customer, never an automatic order.

## 22.2 Queue Triage Automation

- Automatic "Matches usual order" / "Unusual size" / "Contains unavailable item" flags described in Module 5 §10.5.2 are computed here, on order submission, so the queue is already pre-sorted by what needs human attention before a staff member even opens it.
- Configurable auto-prioritization: orders from customers with the largest outstanding balance, or the soonest delivery window, can be automatically surfaced at the top of the queue.

## 22.3 Smart Defaults

- New orders pre-fill quantities to the customer's typical basket where a staff member is ordering "as usual" for a customer, requiring only a confirm rather than manual re-entry (staff can still freely edit before submitting).
- Payment method defaults to whichever method a given customer most commonly uses.

## 22.4 Anomaly & Exception Detection

- Flags unusually large payment corrections/reversals for admin review.
- Flags customers approaching a configurable balance/credit threshold, surfaced on both the customer profile and the staff dashboard, so credit risk is visible before it becomes a collections problem.
- Flags products with a sudden, large base-price change for a confirmation step, to catch fat-finger pricing mistakes before they go live.

## 22.5 Automation Governance

- Every automated suggestion is visually distinct from a manual/human action (a small "Suggested" tag) and always requires a human confirming click — this module never auto-submits, auto-finalizes, or auto-posts anything financial on its own.
- All automation rules (thresholds, on/off toggles per behavior) are configurable in Module 20 Settings, not hardcoded, so Master Admin can tune or fully disable any individual automation without a code change.
- Automation actions (e.g., a quick-finalize triggered from a "matches usual order" suggestion) are still logged in the audit trail identically to a manual action, attributed to the staff member who clicked confirm.
# 23. Module 18 — Progressive Web App, Offline Mode & Mobile Experience (New)

## Purpose

Drivers, salesmen, and customers frequently operate from a phone, sometimes with unreliable connectivity (warehouse basements, delivery routes). The platform must work as a installable, resilient Progressive Web App rather than a desktop-only interface.

## 23.1 PWA Requirements

- Installable to home screen (Add to Home Screen prompt at an appropriate, non-intrusive moment — not on first page load)
- App icon, splash screen, and standalone display mode matching the brand
- Bottom tab-bar navigation on mobile (replacing the desktop side rail) for Dashboard / Catalog / Cart / Orders / More
- Native-feeling gestures: swipe-to-dismiss toasts, pull-to-refresh on list pages, swipe-back navigation

## 23.2 Offline Behavior

- Read access to already-loaded catalog, cart, and recent order data while offline (cached via a service worker)
- Cart changes made while offline are queued locally and synced automatically the moment connectivity returns, with a visible "You're offline. Changes will be saved once you're back online." banner rather than failing silently
- Order submission while offline is queued and clearly marked "Pending — will submit when back online," never silently dropped, and never falsely shown as already submitted until server confirmation actually arrives
- Driver delivery-confirmation flow (Module 16) is fully offline-capable, since delivery areas may have poor signal, syncing photo/signature capture once reconnected

## 23.3 Mobile-Specific UI Adjustments

- Large touch targets throughout (minimum 44px)
- Bottom sheets replace side drawers/modals on small screens for cart, filters, and quick actions
- Sticky "Add to Cart" / "Submit Order" primary actions pinned to the bottom of the viewport on mobile so they're always reachable with a thumb

---

# 24. Module 19 — Multi-Branch / Multi-Location Support (New)

## Purpose

Eman Bakery operates across multiple Saudi Arabian locations. The platform is built branch-aware from the start so it scales cleanly as operations expand, even if a single-branch configuration is all that's active at launch.

## 24.1 Branch Model

- Each customer, product (optionally — some products may be branch-specific), staff user, and order can be associated with a branch/location.
- A "Head Office / All Branches" view is available to Master Admin, aggregating data across every branch.
- Staff and Branch Managers see a branch-filtered experience by default across the dashboard, queue, customers, and dispatch board — with an explicit switcher if a staff member is authorized to work across more than one branch.

## 24.2 Branch Settings Page (`/admin/settings/branches`)

- Branch list: name, address, active/inactive status, assigned staff count, assigned customer count
- "Add Branch" / "Edit Branch" forms
- Per-branch operational settings override (e.g., a different queue-expiry window per branch, if operationally needed)

## 24.3 Cross-Branch Reporting

- Every report in Module 13 supports an optional branch filter/breakdown, and Master Admin's dashboard shows a per-branch comparison view (side-by-side KPI cards) in addition to the aggregate total.

---

# 25. Module 20 — Settings & Configuration Center (New)

## Purpose

Give Master Admin a single place to configure business rules, automation behavior, notification channels, and security policy without requiring a code deployment for routine operational tuning.

## 25.1 General Settings

- Business name, logo, contact details, default currency (SAR), default language
- Queue expiry window (default 120 minutes)
- Credit limit support toggle (feature flag referenced in Modules 2 and 4)

## 25.2 Automation Settings (ties to Module 17)

- Enable/disable each automation behavior individually (predictive reorder nudges, queue triage flags, smart defaults, anomaly detection)
- Configure thresholds (e.g., "unusual order size" sensitivity, balance-risk threshold, escalation timing for near-expiry orders)

## 25.3 Notification Settings

- Enable/disable each channel (email, SMS, WhatsApp, Slack) globally and per event type
- Slack webhook configuration for internal ops alerts (queue-expiry, large payments, system errors — see §30)
- Message template preview per notification type

## 25.4 Pricing Rules

- Default rounding rules
- Bulk price-change tools (global base-price increase by %, category-wide changes) — always previewed before applying, with an audit-logged confirmation

## 25.5 Security Settings

- Password policy (minimum length/complexity)
- Session timeout durations per role
- 2FA requirement toggle for staff/admin roles (Module 1 §6.5)
- Login rate-limiting thresholds

## 25.6 Feature Flags

- A single visible list of optional/in-progress features (e.g., online payment collection, credit limits, multi-branch) that can be toggled on as the business is ready for them, keeping the core v1 scope exactly as specified while allowing safe forward growth.
# 26. Technical Architecture

## 26.1 Frontend

- Next.js with App Router
- TypeScript, strict mode enabled
- Responsive, mobile-first design
- Tailwind CSS with a shared design-token theme implementing the Dark Luxury system in §2
- A headless accessible component primitive layer (Radix-style) for dialogs, dropdowns, tabs, tooltips, toasts, popovers
- A dedicated animation layer (e.g., Framer Motion or an equivalent) implementing every motion behavior specified in §2.2
- React Hook Form with schema validation (Zod or equivalent) on every form in this document
- Server Components by default; Client Components only where interactivity is required (cart, catalog filtering, realtime widgets, dispatch board)
- Loading skeletons and empty states for every data-driven view, matching §1.2's rule that no page may render blank while loading
- Accessible keyboard navigation and visible focus states throughout, including the console keyboard shortcuts defined in Module 5 §10.5.1
- ESLint + Prettier enforced via pre-commit hook and CI

## 26.2 Backend & Data Layer

- Supabase PostgreSQL database as the system of record
- Supabase Auth for login, password recovery, and session management
- Supabase Row Level Security enforced on every customer-facing and financial table for account-level and role-level data isolation
- Supabase Realtime for dashboard, queue, dispatch board, and ledger live updates
- Supabase Storage for product images, delivery-confirmation photos, and generated PDF/Excel exports
- Next.js Server Actions / Route Handlers for protected business operations (order submission, finalization, payment recording, price changes)
- Database functions (Postgres `plpgsql`/RPC) for transactional operations that must be atomic — order finalization (status change + ledger entry together), payment reversal, price-change-with-history — so these can never partially apply

## 26.3 Background Services & Automation Worker

A lightweight, independently deployable Node.js/TypeScript worker service handles scheduled and event-driven work that shouldn't run inside a user-facing request:

- Queue-expiry monitoring (flags orders crossing the two-hour window, escalates near-expiry alerts per Module 5 §10.5.3)
- Scheduled notification dispatch (WhatsApp/SMS/email fan-out, Slack ops alerts)
- Large report/export generation for exports that exceed the inline-generation threshold (Module 13 §18.3)
- Predictive-reorder and anomaly-detection batch jobs backing Module 17
- Nightly reconciliation checks (ledger balance consistency, orphaned/incomplete records)

This service is containerized with Docker and deployed to Railway, kept intentionally separate from the Vercel-hosted Next.js frontend so scheduled/background load never competes with user-facing request latency.

## 26.4 Deployment Topology

| Layer | Technology | Host |
|---|---|---|
| Web application (customer, staff, admin) | Next.js | Vercel |
| Database, Auth, Realtime, Storage | Supabase (PostgreSQL) | Supabase Cloud |
| Background/automation worker | Node.js + TypeScript, Docker | Railway |
| CI/CD | GitHub Actions | GitHub |
| Error monitoring | Sentry | Sentry Cloud (frontend + worker) |
| Ops/alerting | Slack incoming webhook | Slack |
| Source control | Git | GitHub |

## 26.5 Local Development

- `docker-compose.yml` spins up a local Supabase stack (or connects to a shared dev Supabase project) plus the automation worker, so the whole system runs locally with one command.
- A seed script populates representative demo data (sample customers, products, prices, a few queued/finalized orders) so local development and QA never start from a blank database.
# 27. Database Schema & Entities

All primary keys are UUIDs, all tables carry `created_at`/`updated_at` timestamps, and every table listed below is either directly protected by Row Level Security or accessed exclusively through a security-definer database function.

| Entity | Main Purpose | Key Fields (beyond id/timestamps) |
|---|---|---|
| `users` | Authentication identity and user profile | email, phone, full_name, role_id, branch_id, status |
| `roles` | Customer, staff, branch manager, master admin roles | name, description |
| `role_permissions` | Granular capability flags per role (§5.2) | role_id, capability_key, allowed |
| `customers` | Customer business and account information | business_name, contact_person, phone, whatsapp, address, account_code, branch_id, status |
| `customer_user_links` | Links customer login users to customer accounts | user_id, customer_id |
| `products` | Product catalog and base pricing | name, sku, category_id, unit_of_measure, base_price, image_url, status, display_order, tags |
| `product_categories` | Product categories for filtering | name, display_order |
| `customer_product_prices` | Customer-specific price overrides and pricing history | customer_id, product_id, price, effective_date, changed_by, change_reason, previous_price, status |
| `carts` | Active shopping carts | customer_id, created_by_user_id, source |
| `cart_items` | Products currently added to a cart | cart_id, product_id, quantity |
| `orders` | Main order record | customer_id, created_by_user_id, source, status, branch_id, customer_note, internal_note, total_amount, delivery_pref |
| `order_items` | Product, quantity, and price snapshot for each order | order_id, product_id, product_name_snapshot, unit_price_snapshot, quantity, line_total |
| `order_revisions` | Queue-stage edits and revision history | order_id, changed_by, field, previous_value, new_value, reason, timestamp |
| `order_status_history` | Full order-status timeline | order_id, status, changed_by, timestamp |
| `ledger_transactions` | Credit sales, payments, reversals, and adjustments | customer_id, type, amount, reference_id, reference_type, running_balance, created_by |
| `payments` | Payment details including method and reference | customer_id, amount, method, bank_reference, receipt_number, recorded_by, note |
| `drivers` | Delivery personnel directory (Module 16) | name, phone, vehicle, status, branch_id |
| `deliveries` | Delivery/dispatch assignment and confirmation | order_id, driver_id, status, assigned_at, delivered_at, failure_reason, proof_url |
| `branches` | Business locations (Module 19) | name, address, status, settings_override |
| `user_activity_logs` | Login and user activity events | user_id, event_type, ip_address, device, timestamp |
| `audit_logs` | Immutable operational audit trail | user_id, action_type, module, record_type, record_id, previous_value, new_value, reason, customer_id, order_id |
| `notifications` | In-app notifications and read status | user_id, type, message, read_at, related_record_id |
| `automation_settings` | Configurable automation thresholds/toggles (Module 17/20) | key, value, updated_by |
| `system_settings` | Configurable application-wide settings (Module 20) | key, value, updated_by |

The system must use price snapshots inside `order_items` so that historical order values remain accurate even if product or customer prices change later.

## 27.1 Data Integrity Notes

- Financial mutation (finalize order, record payment, reverse payment, change price) is performed through Postgres functions that write to the relevant table(s) and the `audit_logs`/`ledger_transactions`/`order_revisions` tables in a single transaction — never as separate client-side calls that could partially fail.
- No table involved in financial history exposes a `DELETE` grant to any application role; deactivation/reversal columns are used instead.

---

# 28. Environment Variables

`.env.example` (placeholders only — never commit real secrets):

```
DATABASE_URL=
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
JWT_SECRET=
NEXT_PUBLIC_API_URL=
SENTRY_DSN=
SLACK_WEBHOOK_URL=
RAILWAY_TOKEN=
VERCEL_TOKEN=
WHATSAPP_API_TOKEN=
SMS_PROVIDER_API_KEY=
```

Secrets are stored in Vercel (frontend), Railway (worker), and GitHub Actions encrypted secrets (CI/CD) — never in source control.

---

# 29. Repository Structure

```
project-root/
  frontend/                 # Next.js app (customer, staff, admin)
  worker/                   # Node.js/TypeScript automation & background worker service
  supabase/
    migrations/              # version-controlled schema migrations
    seed/                    # local/dev seed data
  .github/
    workflows/               # GitHub Actions CI/CD pipelines
  docs/                      # this specification and related documentation
  scripts/                   # deployment/maintenance scripts
  Dockerfile
  docker-compose.yml
  .env.example
  README.md
```
# 30. CI/CD, Monitoring & DevOps

## 30.1 GitHub-Centered Workflow

```
Developer writes code
        |
Push to GitHub
        |
GitHub Actions executes CI pipeline
        |
Lint, type-check, and tests run for frontend and worker
        |
        v
   If successful:
        |
Vercel deploys frontend (preview on PR, production on main)
        |
Railway deploys the automation worker
        |
Supabase migrations execute against the target environment
        |
Sentry monitors production errors (frontend + worker)
        |
Slack receives deployment success/failure notifications
```

## 30.2 GitHub Actions CI Pipeline (`.github/workflows/ci.yml`)

The CI pipeline supports:
- Dependency installation (cached)
- Linting (ESLint) and formatting check (Prettier)
- Type checking (`tsc --noEmit`) in strict mode
- Frontend build validation
- Worker build validation
- Automated tests (unit + integration)
- Supabase migration dry-run / validation
- Deployment-readiness gate: merge to `main` is blocked unless all of the above pass

Branching model: protected `main` branch, pull-request review required, Vercel preview deployments generated automatically per PR so changes can be reviewed live before merge. Rollback-safe deployment: every deploy is tied to an immutable Git commit, so reverting a bad release is a one-click redeploy of the previous successful build rather than a manual fix.

## 30.3 Monitoring

Sentry is integrated for:
- Frontend runtime error and performance monitoring
- Worker service exception tracking
- Stack traces routed to engineering, never to end users (§20.5)
- Release tracking tied to each deployed Git commit, so a spike in errors can be traced to the exact change that caused it

## 30.4 Notifications (Ops)

A Slack webhook integration delivers:
- Deployment success / failure notifications
- CI/CD pipeline status
- Critical production error alerts (from Sentry)
- Operational alerts from the automation worker (queue-expiry escalations, large payment corrections) as defined in Modules 5, 17, and 20

---

# 31. Security Requirements

- Enforce Supabase Row Level Security on every customer-facing table.
- Customers can query only records linked to their own customer account.
- Staff can access operational customer data only when their role/branch permits it.
- Master Admin has full access, but all admin activity is logged.
- Never trust prices, balances, roles, or permissions sent from the browser.
- Calculate order totals and ledger balances securely on the server/database layer.
- Use secure session handling, rate limiting for login attempts, and password-reset link expiry.
- Optional 2FA step-up for staff/admin accounts (Module 1 §6.5).
- Keep all secrets in environment variables, never in GitHub source code.
- Input sanitization and validation on every form and API boundary (Module-by-module error tables throughout this document define the user-facing side of this).
- Perform regular automated database backups and periodically test restoration procedures.
- Use soft deletion and reversals for commercial records rather than destructive deletion, per Module 14.
- Audit log tables are append-only at the database permission level, not just by application convention.

---

# 32. Performance, Scalability & Accessibility

## 32.1 Performance

- Catalog and queue views target sub-second perceived load via server-rendered initial payloads plus client-side caching, so repeat visits within a session feel instant.
- Realtime subscriptions are scoped narrowly (per customer, per branch) to avoid unnecessary payload on every client.
- Large exports and reports run through the background worker (§26.3) rather than blocking the request thread.
- Images are served responsively (correctly sized per viewport) and lazy-loaded below the fold in the catalog grid.

## 32.2 Scalability

- Designed to grow from ~84 customers/60-70 products today to 500+ customers and 300+ products without architectural change — pagination/virtualization is used on every list from day one rather than "load everything," specifically so this growth doesn't require a later rewrite.
- Multi-branch data model (Module 19) is present from the start even if only one branch is active at launch.

## 32.3 Accessibility

- All interactive elements keyboard-navigable with visible focus states.
- Color is never the only signal for status (badges pair color with text/label, never color alone).
- Sufficient contrast maintained even within the dark-luxury palette (validated against WCAG AA at minimum for body text).
- All motion in §2.2 respects `prefers-reduced-motion` and degrades gracefully to instant state changes.
- Screen-reader labels on every icon-only button (e.g., the show/hide password toggle, remove-item button, quantity steppers).
# 33. Final Acceptance Criteria

The first production release is successful when:

**Customer experience**
- A customer can log in, see their assigned prices, place an order, track its queue status, view complete order history, see the current outstanding balance, and export/share records.
- The catalog, cart, and dashboard exhibit the animation and feedback behaviors defined in §2.2 — filtering, adding to cart, and order submission all feel immediate and premium rather than static.
- Every page defined in §3.1 exists, is reachable through the navigation defined in Module 2, and has working loading/empty/error states.

**Staff experience**
- Centralized staff can create an order for any customer, edit queued orders, finalize completed orders into the ledger, record partial or full payments by cash or bank transfer, and access realtime dashboards and reports.
- The Smart Dispatch Automation Engine (Module 5 §10.5) is live: usual-basket detection, unusual-order flags, and keyboard-driven console operation all function against real data.
- The Dispatch board (Module 16) allows a finalized order to be assigned to a driver and tracked through to delivery/collection confirmation.

**Admin experience**
- The Master Admin can manage users, customers, products, individual customer pricing, reports, audit logs, and all system settings (Module 20) without compromising historical commercial data.
- Automation thresholds and notification channels are configurable without a code deployment.
- Every audit-relevant action (order edit, price change, payment reversal, user freeze) is visible and diffable in the Audit Trail.

**Platform**
- CI/CD pipeline (§30) runs lint, type-check, build, and tests on every push, and blocks merges to `main` on failure.
- Frontend deploys to Vercel, the automation worker deploys to Railway, and Supabase migrations apply cleanly in Development, Staging, and Production environments.
- Sentry captures and reports real errors from both frontend and worker; Slack receives deployment and critical-error notifications.
- The application installs as a PWA and functions in a reasonable offline-degraded mode per Module 18.
- Row Level Security is verified to prevent any customer from querying another customer's data, and every financial mutation is confirmed to be atomic (all-or-nothing) under test.
# 34. Appendix A — Master Page Inventory

A consolidated list of every route defined in this document, for use as a build checklist.

| # | Route | Role(s) | Defined in |
|---|---|---|---|
| 1 | `/login` | All | Module 1 |
| 2 | `/forgot-password` | All | Module 1 |
| 3 | `/reset-password` | All | Module 1 |
| 4 | `/profile/change-password` | All | Module 1 |
| 5 | `/unauthorized` | All | Module 1 |
| 6 | `/account-frozen` | All | Module 1 |
| 7 | `/session-expired` | All | Module 1 |
| 8 | `/2fa-verify` | Staff/Admin | Module 1 |
| 9 | `/customer/dashboard` | Customer | Module 2 |
| 10 | `/customer/catalog` | Customer | Module 3 |
| 11 | `/customer/catalog/product/:id` | Customer | Module 3 |
| 12 | `/customer/cart` | Customer | Module 4 |
| 13 | `/customer/orders` | Customer | Module 6 |
| 14 | `/customer/orders/:orderId` | Customer | Module 6 |
| 15 | `/customer/orders/queue` | Customer | Module 5 |
| 16 | `/customer/ledger` | Customer | Module 7 |
| 17 | `/customer/ledger/statement` | Customer | Module 7 |
| 18 | `/customer/payments` | Customer | Module 7 |
| 19 | `/customer/profile` | Customer | Module 2 |
| 20 | `/customer/notifications` | Customer | Module 15 |
| 21 | `/customer/support` | Customer | Module 2 |
| 22 | `/staff/dashboard` | Staff/Manager | Module 12 |
| 23 | `/staff/queue` | Staff/Manager | Module 5 |
| 24 | `/staff/queue/:orderId` | Staff/Manager | Module 5 |
| 25 | `/staff/customers` | Staff/Manager | Module 8 |
| 26 | `/staff/customers/:id` | Staff/Manager | Module 8 |
| 27 | `/staff/customers/:id/new-order` | Staff/Manager | Module 10 |
| 28 | `/staff/customers/new` | Staff/Manager | Module 8 |
| 29 | `/staff/products` | Staff/Manager | Module 9 |
| 30 | `/staff/payments` | Staff/Manager | Module 7 |
| 31 | `/staff/payments/new` | Staff/Manager | Module 7 |
| 32 | `/staff/dispatch` | Staff/Manager | Module 16 |
| 33 | `/staff/reports` | Staff/Manager | Module 13 |
| 34 | `/admin/dashboard` | Admin | Module 12 |
| 35 | `/admin/queue` | Admin | Module 5 |
| 36 | `/admin/customers`, `/admin/customers/:id` | Admin | Module 8 |
| 37 | `/admin/products`, `/admin/products/:id`, `/admin/products/new` | Admin | Module 9 |
| 38 | `/admin/payments` | Admin | Module 7 |
| 39 | `/admin/reports` | Admin | Module 13 |
| 40 | `/admin/dispatch` | Admin | Module 16 |
| 41 | `/admin/users`, `/admin/users/:id`, `/admin/users/new` | Admin | Module 11 |
| 42 | `/admin/audit-logs`, `/admin/audit-logs/:eventId` | Admin | Module 14 |
| 43 | `/admin/settings` | Admin | Module 20 |
| 44 | `/admin/settings/branches` | Admin | Module 19 |
| 45 | `/admin/settings/notifications` | Admin | Module 20 |
| 46 | `/admin/settings/automation` | Admin | Module 20 |
| 47 | `/admin/settings/pricing-rules` | Admin | Module 20 |
| 48 | `/admin/settings/security` | Admin | Module 20 |

---

# 35. Appendix B — Master Button & Action Inventory

Every distinct action button referenced across this document, grouped by function, so no interactive control is missed during implementation.

**Auth:** Log In, Forgot Password, Send Reset Link, Reset Password, Resend Code, Change Password, Back to Login, Contact Support

**Catalog/Cart:** Add to Cart, Increase/Decrease Quantity, Remove Item, Clear Cart, Continue Shopping, Review Order, Submit Order, Favorite/Pin Product, Clear Filters, Reorder

**Queue/Dispatch:** Open Order, Edit Order, Finalize to Ledger, Cancel Order, Quick Finalize, Bulk Finalize, Print Pick Ticket, Print Delivery Slip, Assign Driver, Mark Delivered, Mark Collected, Mark Failed Delivery

**Ledger/Payments:** Record Payment, Export PDF, Export Excel, Share via WhatsApp, Print, Reverse Payment (admin)

**Customers/Products:** Add Customer, Edit Customer, Freeze Customer, Reset Password (admin action), Create Order for Customer, Add Product, Edit Product, Deactivate Product, Apply Bulk Discount, Reset Prices to Base

**Users/Admin:** Create Staff User, Edit User, Activate User, Freeze User, Save Settings, Add Branch, Edit Branch

**Global:** Back, Save, Cancel, Retry, Undo, Logout, Language Switch, Notification Bell (open inbox), Export (generic per report)

---

# 36. Appendix C — Master Error Message Catalogue

All user-facing error and validation messages are defined inline within each module's "Error States" table (Modules 1, 4, 5, 7, 8, 9, 10, 13, 16) and centrally summarized in Module 15 §20.4. The governing rule, restated: **no raw database, API, or stack-trace text is ever shown to a user** — every failure is mapped to a specific, plain-language message naming what happened and, where possible, what to do next.

# 37. Appendix D — Master Empty-State Catalogue

Every list/detail page in this document requires a defined empty state rather than a blank view. Summary by area:

| Area | Empty state |
|---|---|
| Customer dashboard, no orders yet | "Welcome to Eman Bakery! Place your first order to get started." |
| Catalog, no search results | "No products found. Try another keyword or clear your filters." |
| Cart, empty | "Your cart is empty." + Browse Products / Reorder last order |
| Order history, no orders | "No orders yet." + Place your first order |
| Order queue, nothing queued | "No orders in the queue right now." |
| Reports, no matching data | "No records match the selected filters." |
| Dashboard charts, no activity today | "No activity yet today." |
| Notifications, none | "You're all caught up." |
| Dispatch map, unlocated order | "No location set" tag, order still listed |

# 38. Appendix E — Animation & Micro-Interaction Specification

The full motion specification is defined centrally in §2.2 and applied throughout: catalog filtering/staggered entry (Module 3 §8.5), add-to-cart fly/pulse (Module 3/4), price-change roll (Module 8 §13.4), queue countdown ring (Module 5 §10.1), realtime highlight-flash (Modules 2, 5, 12), dashboard count-up KPIs and chart draw-in (Module 12), status badge cross-fade (Module 6, 5), drag-reorder spring physics (Module 9, 16), and the order-submission success moment (Module 4 §9.3). Any new page added to the product beyond this document should be built against the same motion table in §2.2 rather than introducing a new animation language.
