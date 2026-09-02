# ADR-005: Defer Selected Play Migration Gaps for Challenge MVP

## Status

Accepted

## Context

`docs/tasks/003-play-migration-review-report.md` raised three gaps between the migrated Spring API and the legacy behavior:

- **H-003**: the legacy `create_challenge_template_and_instance` RPC created a template and an instance atomically in one database transaction. The Spring API exposes `POST /api/templates` and `POST /api/instances` as separate operations with separate transactions, so a failure between the two calls can leave a published template without its intended instance.
- **M-001**: `POST /api/templates` and `POST /api/instances` are named as generic Play resources, but creation is unconditionally Challenge-shaped (`ActivityTemplate#createRoot`/`replaceContent` always set Challenge defaults, `ActivityInstanceService#create` always requires `refEmail`/`amountCents` and always writes `activity_instance_challenge_config`).
- **M-003**: the public `GET /api/instances/ref-decisions/session` and `POST /api/instances/ref-decisions` token routes have no rate limiting or CSRF/same-origin control, unlike the legacy routes.

## Decision

All three are deferred, not fixed, for the current Challenge MVP:

- **H-003**: no frontend feature calls a combined create-and-play flow yet — the frontend only calls `POST /api/templates` and `POST /api/instances` sequentially. Building a combined transactional endpoint now would be speculative. Revisit if/when a create-and-play frontend flow is actually built.
- **M-001**: the product only ships Challenge mode right now. Splitting generic Play creation from Challenge-specific creation ahead of a second mode existing would be premature abstraction.
- **M-003**: the ref-decision token is a high-entropy opaque value (see the mail-token generation in `ActivityInstanceService#prepareRefNotification`), and the page is intentionally designed to be reachable only by people the challenger explicitly emails (the challenger and the referee), not to be a hardened public surface. Rate limiting/CSRF controls are deferred until there's evidence this needs hardening.

## Consequences

- A future combined create-and-play endpoint, a generic (non-Challenge) Play creation path, and abuse controls on the ref-decision routes are all known, intentionally accepted gaps, not oversights. Re-flagging them in a future review should link back to this ADR unless the underlying assumption (no create-and-play frontend flow, Challenge-only MVP, low-value target for abuse) has changed.
