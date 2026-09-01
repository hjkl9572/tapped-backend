# Task 011: Migrate Tap Page APIs

Migrate the legacy APIs used by the frontend `/tap` page into the Spring Boot Play domain.

The legacy APIs are:

```text
/api/tap/dashboard
/api/tap/tray
```

These route names reflect the frontend page structure rather than the actual backend domain resources.

Do not preserve `/api/tap/**` merely because both APIs are consumed by the Tap page.

The two APIs represent different Play-domain resources and should be migrated accordingly.

---

# Target Endpoints

## Dashboard

Legacy:

```text
GET /api/tap/dashboard
```

Target:

```text
GET /api/instances/dashboard
```

Controller:

```text
InstanceController
```

The dashboard primarily represents the authenticated user's active/relevant `activity_instances`, together with Tap information needed to render and interact with those instances.

---

## Tray

Legacy:

```text
GET /api/tap/tray
```

Target:

```text
GET /api/tap-cards/tray
```

Controller:

```text
TapCardController
```

The tray represents actual `tap_cards` created by the authenticated user today.

---

# Important Terminology Distinction

The frontend Tap page visually represents `activity_instances` as cards.

Users and frontend code may casually call these visual objects "Tap cards" because:

* they are card-shaped
* they are displayed on the Tap page
* the user taps them to interact with the Play

However, these are **not** the same thing as the database/domain concept:

```text
tap_cards
```

The distinction is:

```text
Tap page dashboard card
→ visual representation of activity_instance

tap_card
→ behavioral content created after the user performs/records activity
```

Conceptually:

```text
ActivityTemplate
      ↓
ActivityInstance
      ↓
rendered as tappable card on dashboard
      ↓
Tap
      ↓
TapCard
```

Do not allow frontend visual terminology to collapse `ActivityInstance` and `TapCard` into one backend concept.

---

# Required Reading

Before implementation, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. all relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`
5. legacy `/api/tap/dashboard` implementation
6. legacy `/api/tap/tray` implementation
7. all PostgreSQL RPC/functions called by both routes
8. complete definition of:

```text
get_today_tap_tray_cards
```

9. frontend `/tap` page call sites and response usage
10. existing:

* `InstanceController`
* `TapController`
* `TapCardController`
* related services
* repositories
* DTOs
* entities
* tests

11. existing `AppJwtPrincipal` conventions

Inspect the actual response usage in the frontend so that legacy frontend-oriented field names are not mistaken for domain concepts.

---

# Authentication and User Identity

Both APIs are current-user-specific.

Resolve the current user exclusively through:

```text
AppJwtPrincipal.userId
```

which corresponds to:

```text
app_users.id
```

Do not use:

* Google/OIDC `sub`
* email
* provider subject
* client-supplied user ID

Do not accept the owner ID as a query parameter or request-body field.

Conceptually:

```text
JWT
 ↓
AppJwtPrincipal.userId
 ↓
current user's instances / tap cards
```

---

# Part 1: Tap Dashboard

## Purpose

The legacy Dashboard API provides the data needed for the main dashboard area of the `/tap` page.

It primarily retrieves:

```text
activity_instances
+
related activity_taps information
```

The frontend renders each activity instance as a card-shaped, tappable UI element.

This does not make the underlying resource a `tap_card`.

---

# Domain Ownership

The primary resource is:

```text
PlayInstance / activity_instance
```

Therefore migrate the endpoint into:

```text
InstanceController
```

rather than:

```text
TapController
```

Even though Tap information is included in the response, the query is fundamentally:

> Which Play Instances should this user currently see and interact with on their Tap dashboard?

Tap state enriches the Instance representation.

It does not change the primary resource.

---

# Dashboard Endpoint

Implement:

```text
GET /api/instances/dashboard
```

The authenticated user is implicit through `AppJwtPrincipal.userId`.

Do not use:

```text
/api/tap/dashboard
```

in the new Spring API.

---

# Dashboard Legacy Analysis

Read the legacy API and its PostgreSQL function(s) completely.

Determine:

* which `activity_instances` are included
* instance-state filtering
* ownership filtering
* ordering
* template data joined into each instance
* current/latest Tap data
* whether today's Tap is specially represented
* whether open/finalized/canceled Tap state changes the response
* Challenge-specific fields
* image/poster information
* cadence-related information
* response ordering
* empty-dashboard behavior
* any limits
* any derived fields

Do not infer behavior from the frontend visual layout alone.

---

# Dashboard Response

Use a dedicated dashboard read DTO/projection where appropriate.

The response may contain information from:

```text
ActivityInstance
ActivityTemplate
ActivityTap
Challenge configuration
```

but the representation should remain centered on the Instance.

Conceptually:

```text
InstanceDashboardItem
├── instance identity/state
├── template information
└── current/relevant Tap information
```

Do not return JPA entities directly.

Do not model the dashboard visual card as a `TapCard`.

---

# Instance and Tap Relationship

Preserve the actual domain distinction:

```text
ActivityInstance
→ user's ongoing participation in a Play

ActivityTap
→ a particular interaction/session within that instance
```

The dashboard may need to determine whether an instance:

* can currently be tapped
* already has an open Tap
* has a Tap created today
* has another relevant Tap state

Derive these rules from the legacy implementation and domain docs.

Do not invent a new Tap lifecycle.

---

# Dashboard Query Implementation

This is a read-heavy composite query.

Prefer an efficient query/projection rather than repeatedly loading:

```text
Instance
→ Template
→ Taps
```

per row.

Review for:

* N+1 queries
* unnecessary entity graph loading
* unstable ordering
* Java-side filtering that should occur in SQL

If the legacy RPC efficiently performs a multi-table read, preserve the useful query semantics even if the implementation moves to JPQL/native SQL/projection.

Do not retain the RPC structure mechanically.

---

# Dashboard Tests

Test meaningful behavior including:

* current user receives only their own relevant instances
* another user's instances are excluded
* correct Instance state filtering
* correct associated Tap state
* expected ordering
* instance with no current Tap
* instance with relevant current/open Tap
* empty dashboard
* correct response projection
* identity comes from `AppJwtPrincipal.userId`
* unauthenticated request

Include Challenge-specific assertions only when they are actually part of the dashboard contract.

---

# Part 2: Tap Card Tray

## Purpose

The bottom section of the `/tap` page contains a tray-like UI area displaying Tap Cards created by the current user today.

Unlike the dashboard cards, these are actual:

```text
tap_cards
```

domain/database objects.

Legacy:

```text
GET /api/tap/tray
```

calls:

```text
get_today_tap_tray_cards
```

---

# Tray Endpoint

Implement:

```text
GET /api/tap-cards/tray
```

in:

```text
TapCardController
```

The endpoint represents a current-user query over Tap Cards.

Do not keep `/api/tap/tray`.

---

# Tray Semantics

The tray should retrieve Tap Cards:

```text
created today
+
owned by the authenticated user
```

Determine the exact meaning of "today" from:

```text
get_today_tap_tray_cards
```

including:

* timestamp column
* timezone
* day boundary
* inclusion/exclusion rules
* Tap/Card states
* ordering
* result limit

Do not guess the timezone or date boundary.

---

# Remove `app_users` Join Where Unnecessary

The legacy RPC joins with:

```text
activity_instances
app_users
```

Review why each join exists.

The Spring implementation should obtain current-user identity directly from:

```text
AppJwtPrincipal.userId
```

Therefore, if the `app_users` join exists only to determine or verify the current application user identity, remove that join.

Use:

```text
AppJwtPrincipal.userId
```

directly in the query/filter.

Do not remove the join if it supplies actual response data or enforces another required invariant.

Verify its purpose before removal.

---

# Activity Instance Join

The legacy tray RPC also joins with:

```text
activity_instances
```

Preserve this join or equivalent query relationship where it is needed for:

* ownership
* template/instance context
* ordering
* response fields
* state filtering

Do not remove it merely because the primary resource is Tap Card.

---

# Tray Limit

The legacy route invokes:

```text
get_today_tap_tray_cards
```

with:

```text
p_limit = 24
```

Do not automatically treat `24` as a Play-domain invariant.

Determine why the limit exists.

If `24` exists only because the current frontend tray was designed to display at most 24 cards, treat it as a presentation/query constraint rather than a fundamental Tap Card rule.

For this migration:

* preserve existing behavior unless there is a concrete reason to change it
* do not spread `24` into entity/domain logic
* keep the limit at the query/application boundary
* document whether it remains fixed or becomes client-configurable

Do not introduce a client-provided `limit` automatically without verifying current frontend needs.

---

# Tray Response

Use an explicit Tap Card tray DTO/projection.

Determine from the legacy RPC/frontend exactly which fields are required.

Possible data may include:

* Tap Card ID
* image/content
* creation time
* associated ActivityInstance
* associated ActivityTemplate
* relevant state

Do not return unrelated `app_users` fields merely because the old RPC joined that table.

---

# Tray Ordering

The visual tray depends on meaningful ordering.

Determine the exact legacy ordering from:

```text
get_today_tap_tray_cards
```

Preserve it.

Do not rely on implicit database row order.

If multiple cards can have the same timestamp, identify whether a secondary deterministic ordering exists or should be added.

---

# Tray Query Efficiency

Prefer a single efficient read/projection query.

Avoid:

```text
fetch cards
→ for each card fetch instance
→ for each instance fetch template
```

if the response can be constructed directly from a projection.

Review for N+1 behavior.

---

# Tray Tests

Test:

* only current user's Tap Cards are returned
* another user's cards are excluded
* only cards from "today" are returned
* exact date/time boundary behavior where practical
* correct ordering
* maximum result behavior
* fewer than maximum cards
* empty tray
* required ActivityInstance data
* `AppJwtPrincipal.userId` scoping
* unauthenticated request

---

# Frontend Caching

Both legacy responses are cached by the frontend.

The Spring backend should preserve response semantics that allow the frontend to continue caching them effectively.

However, frontend cache policy itself is not a Spring business rule.

Do not reproduce frontend cache duration or state-management logic inside Spring unless the existing backend has an explicit server-side caching requirement.

Document the fact that both endpoints are currently client-cached, but keep caching implementation outside this migration.

---

# Controllers After Migration

The Play-domain controllers should preserve this semantic division:

```text
InstanceController
├── generic PlayInstance operations
└── GET /api/instances/dashboard

TapController
└── Tap operations and Tap-specific aggregate queries

TapCardController
├── leaderboard
├── likes
├── like stats
├── personal feed
└── GET /api/tap-cards/tray
```

Do not put the dashboard into `TapController` merely because the frontend page is named Tap.

Do not put the dashboard into `TapCardController` merely because its ActivityInstances are visually rendered as cards.

---

# REST Mapping

Before implementation, explicitly record:

```text
Legacy:
GET /api/tap/dashboard

Spring:
GET /api/instances/dashboard

Primary resource:
ActivityInstance

Controller:
InstanceController
```

and:

```text
Legacy:
GET /api/tap/tray

RPC:
get_today_tap_tray_cards

Spring:
GET /api/tap-cards/tray

Primary resource:
TapCard

Controller:
TapCardController
```

---

# Request Validation

Both APIs are GET current-user queries and may not require request DTOs.

Use typed query parameters if the actual legacy behavior requires any.

Do not introduce unnecessary request objects.

If the tray limit remains fixed internally, no client parameter is needed.

If analysis proves a client-configurable limit is appropriate, validate it using standard Spring parameter validation.

---

# Error Semantics

Follow existing project conventions.

Expected behavior should generally include:

```text
200 → successful query, including empty collection
401 → authentication required
400 → invalid query parameter, if any
500 → unexpected query/database failure
```

An empty dashboard or tray is not an error.

Do not leak PostgreSQL/RPC errors.

---

# OpenAPI

Update or verify the Spring OpenAPI contract for:

```text
GET /api/instances/dashboard
GET /api/tap-cards/tray
```

Document:

* authentication requirement
* response DTOs
* query parameters if any
* status codes

Do not preserve frontend-oriented `/api/tap/dashboard` or `/api/tap/tray` names.

---

# Migration Process

## Step 1 — Analyze Dashboard

Inspect:

* route
* RPC/function
* frontend consumer
* response shape
* Instance filters
* Tap enrichment
* ordering
* auth
* query complexity

Explicitly distinguish visual dashboard cards from domain `TapCard`.

## Step 2 — Analyze Tray

Inspect:

* route
* `get_today_tap_tray_cards`
* `p_limit = 24`
* date semantics
* joins
* ordering
* response
* frontend consumer

Determine whether the `app_users` join remains necessary.

## Step 3 — Propose Mapping

Confirm:

```text
dashboard
→ InstanceController

tray
→ TapCardController
```

before implementation.

## Step 4 — Implement

Implement:

* controller endpoints
* read DTO/projections
* service/query behavior
* repository queries
* authentication scoping

Do not refactor unrelated Tap page/frontend behavior.

## Step 5 — Test

Add relevant controller/query/integration tests.

Run regression tests for existing Instance, Tap, and TapCard functionality affected by shared code.

## Step 6 — Report

Create the established review/result document after implementation and review.

Document:

* old → new routes
* controller ownership
* exact dashboard semantics
* exact tray semantics
* date/timezone behavior
* removal or retention of legacy joins
* `24` limit decision
* frontend caching behavior
* tests
* intentional differences

---

# Important Constraints

Do not:

* create a backend `Dashboard` domain
* create a backend `Tray` domain
* treat dashboard UI cards as `tap_cards`
* move Dashboard into `TapController` solely because the page is `/tap`
* move Dashboard into `TapCardController`
* put Tray into `InstanceController`
* use OIDC `sub` for current-user identity
* accept client-supplied current-user IDs
* preserve unnecessary `app_users` joins
* hardcode frontend terminology into domain entities
* reproduce frontend cache behavior in Spring
* expose JPA entities directly
* perform N+1 read assembly when a projection/query can handle it
* change Tap/Instance/Card domain semantics merely to simplify the route structure

Preserve the conceptual distinction:

```text
ActivityInstance
→ participation in a Play
→ rendered as tappable card on dashboard

ActivityTap
→ interaction with that participation

TapCard
→ behavioral content created from the user's activity
→ shown in the tray
```
