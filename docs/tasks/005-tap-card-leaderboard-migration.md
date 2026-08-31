# Task: Migrate Tap Card Leaderboard APIs

Migrate the currently used Tap Card leaderboard-related APIs into the Spring Boot Play domain.

Create a dedicated:

`TapCardController`

The legacy `leaderboard` folder contains multiple behaviors that were grouped together because of frontend implementation history. Do not preserve that folder structure as a backend domain boundary.

## Scope

Migrate:

* `tap-cards`
* `tap-card-like`
* `tap-card-like-stats`

Do not migrate:

* `anon-search`

`anon-search` depends on Edge Function behavior and requires verification against the updated schema. Mark it as deferred work.

---

# Domain Ownership

All migrated behavior belongs to the Play domain.

Use this conceptual ownership:

```text
Play
├── Tap
└── Tap Card
    ├── leaderboard query
    ├── likes
    └── like statistics
```

Leaderboard is not a standalone domain.

It is a ranked read model over Tap Card content.

Likes also do not belong to Leaderboard specifically. They are interactions with Tap Cards regardless of where those cards are displayed.

---

# Important Legacy Context

The legacy:

`leaderboard/tap-card-like`

exists under the leaderboard folder because the first like interaction was originally implemented through the leaderboard UI.

The same `set_tap_card_like` RPC is also invoked elsewhere through frontend `_lib` code.

This means the current frontend folder structure does not accurately represent backend domain ownership.

Do not reproduce this legacy structure in Spring.

Document this frontend organizational issue in the migration report, but do not refactor the frontend as part of this task.

---

# Required Reading

Before implementation, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. all relevant files under `docs/domain`
4. `legacy/supabase/schema.sql`
5. legacy implementations for:

    * `tap-cards`
    * `tap-card-like`
    * `tap-card-like-stats`
6. all PostgreSQL RPC/function definitions called by those APIs
7. frontend call sites for `set_tap_card_like`
8. existing Spring Play controllers, services, repositories, entities, DTOs, exceptions, and tests
9. existing `TapController` conventions where relevant

Do not migrate `_lib`; inspect it only to understand actual usage.

---

# Controller

Create:

`TapCardController`

Use:

```text
/api/tap-cards
```

as the controller resource base.

The controller should own HTTP behavior whose primary resource is a Tap Card.

Keep it thin.

It should primarily:

1. receive HTTP input
2. obtain `AppJwtPrincipal` where required
3. validate DTO/query/path input
4. delegate to services/query services
5. return response DTOs

Do not put ranking logic, like mutation rules, or repository orchestration directly in the controller.

---

# Target REST Endpoints

Use the following route design unless existing project conventions reveal a concrete conflict.

## Leaderboard

```text
GET /api/tap-cards/leaderboard?result=SUCCESS
GET /api/tap-cards/leaderboard?result=FAIL
```

The `result` query parameter determines which leaderboard is requested.

Use a strongly typed enum where appropriate.

## Like

```text
PUT /api/tap-cards/{cardId}/like
```

means:

> Ensure the current authenticated user likes this Tap Card.

## Unlike

```text
DELETE /api/tap-cards/{cardId}/like
```

means:

> Ensure the current authenticated user does not like this Tap Card.

These endpoints should be idempotent.

## Like Stats

Use a batched endpoint:

```text
GET /api/tap-cards/like-stats?ids=<id1>,<id2>,...
```

Preserve batch retrieval if the legacy API retrieves like state for multiple cards together.

Do not replace this with one request per card unless the legacy semantics prove batching is unnecessary.

---

# 1. Leaderboard Tap Cards

The legacy `tap-cards` API returns up to:

`MAX_LEADERBOARD_ENTRIES`

Tap Cards for leaderboard display.

Before implementation, determine exactly:

* how SUCCESS and FAIL leaderboards are distinguished
* ranking metric
* primary ordering
* secondary/tie-break ordering
* visibility rules
* required card/tap/challenge lifecycle state
* whether disputed or canceled results are included
* exact maximum result count
* whether pagination exists or the result is intentionally fixed-size
* included PlayTemplate fields
* included Play Card fields
* included Profile fields
* image/storage references
* any derived values

Preserve the current ranking algorithm unless current domain documentation explicitly defines a change.

Ordering is part of the API contract.

Do not replace an ordered RPC with an unordered repository query.

---

# Leaderboard Resource Semantics

The leaderboard is a query over Tap Card content.

Do not create a `Leaderboard` entity or aggregate.

Conceptually:

```text
Tap Cards
    ↓
filter by challenge result
    ↓
rank
    ↓
limit
    ↓
leaderboard representation
```

A dedicated query service or repository projection is appropriate if the query is complex.

Avoid loading complete entity graphs when only a read projection is needed.

---

# Leaderboard Result Parameter

Prefer a typed enum such as:

```java
enum LeaderboardResult {
    SUCCESS,
    FAIL
}
```

or reuse the correct existing domain enum if one already represents this meaning.

Do not introduce a duplicate enum solely for the controller if an existing type already fits.

Invalid values should return a clean `400 Bad Request`.

---

# 2. Tap Card Like

The legacy like API calls:

`set_tap_card_like`

Read the complete RPC/function before implementing its replacement.

Determine:

* how user identity is passed
* insert behavior
* delete/update behavior
* duplicate behavior
* uniqueness constraints
* whether like and unlike are already idempotent
* returned data
* card existence checks
* visibility constraints
* any ownership restrictions
* transaction requirements

The Spring implementation must preserve the actual business semantics.

---

# Authentication for Likes

Likes are authenticated Play interactions.

The liker identity must come exclusively from:

`AppJwtPrincipal.userId`

which corresponds to:

`app_users.id`

Do not use:

* Google OIDC `sub`
* email
* provider subject
* request-body `userId`
* query-parameter `userId`

The client must not be able to choose who performs the like.

---

# Like Idempotency

The REST behavior should be idempotent.

For:

```text
PUT /api/tap-cards/{cardId}/like
```

if the like already exists, the operation should result in the card being liked without creating duplicate rows.

For:

```text
DELETE /api/tap-cards/{cardId}/like
```

if the like does not exist, the final state should still be unliked.

Preserve or add the appropriate database uniqueness constraint if required.

Do not rely only on a service-level existence check if concurrent requests could create duplicates.

---

# 3. Like Statistics

The legacy `tap-card-like-stats` API retrieves like-related data separately from the main leaderboard Tap Card payload.

This separation is intentional.

Tap Card content is relatively stable.

Like information changes more frequently.

Conceptually:

```text
Tap Card data
→ comparatively stable
→ cached independently

Like count / current-user like state
→ volatile
→ frequently updated
→ optimistic UI interaction
```

The backend API should preserve the ability to update like state without requiring the frontend to refetch the entire card leaderboard payload.

Do not merge like statistics into the main leaderboard response merely because it is easier to implement.

---

# Like Stats Contract

Inspect the legacy API/RPC to determine exactly what is returned.

Possible values include:

* Tap Card ID
* total like count
* whether the current authenticated user likes the card

Preserve the actual current contract where appropriate.

For batched retrieval, prefer a response that clearly associates stats with each Tap Card ID.

For example conceptually:

```json
{
  "items": [
    {
      "tapCardId": "...",
      "likeCount": 10,
      "likedByMe": true
    }
  ]
}
```

Do not copy this shape blindly; derive the final DTO from the existing API contract and project conventions.

---

# Anonymous vs Authenticated Like Stats

Determine whether like statistics can be requested anonymously.

If anonymous users may view leaderboard like counts, support that behavior.

For anonymous users:

* total like count may still be returned
* `likedByMe` should follow a clearly defined anonymous representation

Do not require authentication merely because one response field is user-specific if the legacy/public page needs the aggregate count anonymously.

If authenticated identity is optional for this endpoint, implement that cleanly rather than inventing a fake user.

---

# Request Validation

## Path Variables

Validate `cardId` using its real Java type, preferably `UUID` if that matches the database.

Malformed IDs should result in `400`.

## Like Stats IDs

For:

```text
GET /api/tap-cards/like-stats?ids=...
```

validate:

* malformed IDs
* empty collection
* duplicate IDs
* maximum batch size where justified
* nonexistent cards according to existing semantics

Do not introduce a tiny arbitrary batch limit.

If `MAX_LEADERBOARD_ENTRIES` naturally bounds the maximum number of requested IDs, reuse that domain/API constraint where appropriate.

---

# Stable vs Volatile Response Data

Preserve the architectural benefit of separating:

```text
leaderboard card data
```

from:

```text
like state
```

This allows the frontend to:

* cache card data longer
* optimistically update like state
* refresh likes independently
* avoid retransferring large card payloads on each like interaction

The backend does not own frontend cache behavior, but its API should not unnecessarily prevent this strategy.

---

# Persistence

For leaderboard queries:

* prefer efficient read queries/projections
* preserve deterministic ordering
* preserve result limit
* avoid unnecessary entity graph loading
* inspect N+1 risks
* preserve joins required for response projection

For likes:

* preserve uniqueness of `(user, tap_card)` or the actual equivalent schema invariant
* use a transaction where required
* consider concurrency
* avoid duplicate rows
* preserve foreign-key integrity

Do not retain legacy PostgreSQL functions automatically if equivalent Spring/JPA behavior is clearer.

Likewise, do not convert efficient SQL into inefficient Java-side processing merely to avoid SQL.

---

# Domain Model

Tap Card remains a Play-domain concept.

Do not attach like state directly to a generic entity as mutable aggregate state if likes are modeled as independent user interactions in the database.

Use entity/domain methods only where they own a meaningful invariant.

Do not manufacture rich-entity behavior simply to eliminate setters.

---

# Services

Use cohesive service/query responsibilities.

For example, the implementation may naturally separate:

```text
TapCardQueryService
TapCardLikeService
```

or use another existing project-consistent structure.

Do not create separate services merely because there are separate endpoints.

Do not create one giant `PlayService` that accumulates unrelated Play behavior.

Choose the smallest cohesive structure.

---

# Error Semantics

Use existing exception and `@RestControllerAdvice` conventions.

Where applicable:

```text
400 → invalid request/query value
401 → authentication required for like/unlike
403 → authenticated but operation forbidden
404 → Tap Card not found
409 → invalid state conflict if the domain requires it
500 → unexpected server error
```

Repeated like/unlike should normally not become `409` if the chosen REST semantics are idempotent.

---

# Tests

## Leaderboard

Test meaningful behavior including:

* SUCCESS leaderboard
* FAIL leaderboard
* correct ranking/order
* deterministic tie-breaking if defined
* `MAX_LEADERBOARD_ENTRIES`
* fewer-than-max result
* empty result
* expected filtering by state/verdict
* public/authenticated access behavior
* response projection

Do not merely verify repository invocation.

## Like

Test:

* authenticated user likes a card
* repeated PUT remains idempotent
* authenticated user unlikes a card
* repeated DELETE remains idempotent
* nonexistent card
* correct use of `AppJwtPrincipal.userId`
* client cannot override liker identity
* database uniqueness
* concurrent/duplicate safety where practical

## Like Stats

Test:

* correct total like count
* correct current-user like state
* multiple card IDs
* empty/no-like cards
* anonymous behavior if supported
* malformed IDs
* duplicate IDs
* result association with correct cards

---

# OpenAPI

Update or verify the API contract for:

```text
GET    /api/tap-cards/leaderboard
PUT    /api/tap-cards/{cardId}/like
DELETE /api/tap-cards/{cardId}/like
GET    /api/tap-cards/like-stats
```

Document:

* query parameters
* enum values
* path variables
* authentication requirements
* response DTOs
* status codes

Do not preserve the legacy `/leaderboard/...` route structure.

---

# Deferred anon-search

Do not implement:

`anon-search`

during this task.

Document:

* legacy route
* related Edge Function
* related RPC/schema dependencies
* reason migration is deferred
* what must be inspected before migration

Do not delete the legacy implementation as part of this task.

---

# Migration Process

## Step 1 — Analyze

For each in-scope legacy API, produce:

```text
Legacy route
Purpose
Frontend callers
RPC/function
Tables
Request
Response
Auth
Ordering
Caching relevance
Spring target
```

## Step 2 — Confirm REST Mapping

Use:

```text
tap-cards
→ GET /api/tap-cards/leaderboard

tap-card-like
→ PUT/DELETE /api/tap-cards/{cardId}/like

tap-card-like-stats
→ GET /api/tap-cards/like-stats

anon-search
→ deferred
```

Report any discovered legacy behavior that makes one of these mappings inappropriate before changing the route design.

## Step 3 — Implement

Create `TapCardController` and required DTO/service/repository behavior.

## Step 4 — Test

Add appropriate controller/service/repository/integration tests.

Run relevant Play-domain regression tests as well.

## Step 5 — Report

Produce a migration report containing:

### Legacy Structure

Explain why likes historically lived under the leaderboard folder.

### New Resource Ownership

Document that:

```text
leaderboard
→ ranked Tap Card query

like
→ Tap Card interaction

like stats
→ Tap Card query
```

### Route Mapping

List every old route and its Spring replacement.

### Query Semantics

Document:

* ranking
* limits
* filters
* ordering
* success/fail behavior

### Like Semantics

Document:

* authentication
* idempotency
* uniqueness
* unlike behavior

### Cache/Response Separation

Explain whether stable Tap Card data and volatile like data remain independently retrievable.

### Deferred Work

Explicitly record `anon-search` as deferred.

---

# Important Constraints

Do not:

* migrate `anon-search`
* create a Leaderboard domain
* put likes under a Leaderboard controller
* move Tap behavior into TapCardController
* move weekly Tap count from `TapController`
* use OIDC `sub` as business identity
* trust a client-supplied liker ID
* merge card and like responses without justification
* replace batched like-stat retrieval with N requests
* lose leaderboard ordering
* lose `MAX_LEADERBOARD_ENTRIES`
* mechanically copy legacy folder names
* modify frontend structure as part of this task
* rewrite domain docs merely to justify implementation

Use:

```text
TapController
→ Tap interactions/queries

TapCardController
→ Tap Card content, leaderboard, likes, like stats
```

Preserve this distinction unless the actual domain documentation reveals a concrete reason to change it.
