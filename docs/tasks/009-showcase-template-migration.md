# Task 009: Migrate Showcase Templates API

Migrate the legacy `/api/showcase` behavior into the Spring Boot Play domain.

The Showcase API retrieves Play Templates for public discovery on the landing page.

The frontend currently uses the returned templates in multiple presentation areas, including:

* template cards in the hero section
* the landing-page template carousel

`showcase` is therefore a frontend/read-model concept over Play Templates, not a standalone backend domain.

Implement the migrated endpoint under `TemplateController`.

---

# Target Endpoint

Use:

```text
GET /api/templates/showcase?limit={limit}
```

Example:

```text
GET /api/templates/showcase?limit=12
```

The client determines how many templates it wants.

The current frontend requests 12 templates, but `12` is not a backend domain rule and must not be hardcoded into the Spring service or repository.

---

# Domain Ownership

This endpoint belongs to the Play domain.

The underlying resource is:

```text
PlayTemplate
```

Conceptually:

```text
public Play Templates
        ↓
showcase selection/query
        ↓
frontend presentation
```

Do not create:

* `ShowcaseController`
* `Showcase` entity
* `Showcase` aggregate
* a separate Showcase domain

Use the existing:

```text
TemplateController
```

because this is a read/query operation over templates.

---

# Required Reading

Before implementing, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`
5. the legacy `/api/showcase` implementation
6. the complete PostgreSQL function:

```text
get_showcase_templates
```

7. frontend call sites for `/api/showcase`
8. existing `TemplateController`
9. existing Template services, repositories, DTOs, entities, exceptions, and tests

Treat `get_showcase_templates` as the primary source for the existing showcase selection/query semantics.

---

# Legacy Behavior Analysis

Before coding, inspect `get_showcase_templates` in full and identify:

* input parameters
* client-provided result limit
* filtering conditions
* lifecycle-state requirements
* ordering or ranking logic
* randomness, if any
* visibility requirements
* excluded templates
* joins
* returned fields
* default/fallback behavior
* behavior when fewer templates exist than requested
* behavior when no templates exist

Do not guess these semantics from the endpoint name.

Preserve meaningful showcase-selection behavior unless current domain documentation explicitly defines a change.

---

# Remove `public_activity_templates` Dependency

Do not use:

```text
public_activity_templates
```

for the Spring implementation.

The old projection existed primarily to support public/anonymous access in the Supabase + RLS architecture.

In the Spring architecture, public access is controlled through the application server.

Conceptually:

```text
Client
   ↓
GET /api/templates/showcase
   ↓
Spring
   ↓
controlled repository query
   ↓
canonical template data
```

The client cannot directly query arbitrary template rows.

Therefore, a duplicate public projection table is not required merely to provide anonymous access.

---

# Reason for Removing the Projection

The `public_activity_templates` projection introduced synchronization complexity.

Template-related mutations had to keep:

```text
activity_templates
```

and:

```text
public_activity_templates
```

consistent.

This created risks such as:

* forgetting to update the projection
* stale projection rows
* deletion/archive synchronization bugs
* additional mutation logic
* unnecessary synchronization jobs

Do not reproduce this dual-write model in Spring.

The canonical template data should remain the source of truth.

---

# Template Immutability

The Play domain treats published templates as conceptually immutable behavioral definitions.

When a creator changes a template in a way that changes its behavioral meaning, the application creates a new template row rather than mutating the existing definition in place.

The previous template remains a valid historical definition.

Conceptually:

```text
Template A
"Run 5 km every day"

creator edits behavior
        ↓

Template B
"Run 10 km every day"

Template A remains valid
Template B is a new definition
```

Because of this model, strict real-time synchronization of a separate public projection provides little domain benefit.

A user receiving a template that has become conceptually stale shortly before the request is not necessarily observing invalid data.

If that template was valid when created and remains available according to lifecycle rules, it still represents a valid Play definition.

---

# CQRS / Read Projection Decision

Do not introduce a separate CQRS read model for Showcase as part of this migration.

The current application does not require the additional synchronization and operational complexity.

Use a direct, efficient repository/query projection from canonical template data instead.

This decision does not prohibit introducing a read model later if actual performance or query-complexity requirements justify it.

For now:

```text
canonical template data
        ↓
Spring query/projection
        ↓
Showcase response
```

is preferred.

---

# Public Access

The Showcase endpoint is intended for public landing-page discovery.

It should therefore be anonymously readable unless the legacy behavior or current documentation clearly says otherwise.

Configure:

```text
GET /api/templates/showcase
```

as public through the existing Spring Security conventions.

Do not require `AppJwtPrincipal` if the response is not personalized.

---

# Request Parameter

Accept:

```text
limit
```

as a client-provided query parameter.

Example:

```text
GET /api/templates/showcase?limit=12
```

The Spring backend should not hardcode the current frontend value.

Inspect the legacy route and `get_showcase_templates` to determine:

* whether `limit` is required
* whether there is an existing default
* valid minimum
* valid maximum
* invalid-value behavior

Use an appropriate numeric Java type and validation.

A bounded maximum may be appropriate to prevent an unbounded public query, but do not invent an arbitrary value without checking the existing contract/function or project conventions.

If a new protective maximum is needed, document it as an intentional Spring API decision.

---

# Controller

Add the endpoint to:

```text
TemplateController
```

Conceptually:

```java
@GetMapping("/showcase")
public ...
```

under the existing:

```text
/api/templates
```

controller base path.

Keep the controller thin.

It should:

1. receive and validate `limit`
2. delegate to the appropriate template query/service
3. return the response

Do not place showcase-selection SQL or business/query logic directly in the controller.

---

# Service / Query Responsibility

Use the smallest cohesive structure consistent with the existing Template implementation.

A method may conceptually resemble:

```text
getShowcaseTemplates(limit)
```

The service/query layer should express that this is a public Play Template discovery query.

Do not create a generalized statistics/discovery framework solely for this endpoint.

---

# Repository / Query

Replace the legacy dependency on `public_activity_templates` with a query over canonical template data.

The query must reproduce the meaningful behavior of:

```text
get_showcase_templates
```

including its filtering and ordering/selection semantics.

Prefer a read projection/DTO query if the Showcase response does not need full managed entities.

Avoid:

* loading unnecessary entity relationships
* N+1 queries
* Java-side filtering of large result sets
* fetching all public templates and then applying `limit` in Java

Apply the requested limit in the database query.

---

# Response

Inspect the legacy Showcase response and frontend consumers.

The frontend requires enough template information to render complete template cards, including fields such as:

* title
* rules
* photo/poster
* template identifier
* other template-card fields required by the current UI

Do not blindly return the full JPA entity.

Use the existing Template response DTO where it matches the contract, or create a suitable public Showcase projection DTO if the response shape is meaningfully different.

Avoid exposing internal-only fields.

---

# Ordering and Selection

The selection behavior from `get_showcase_templates` is part of the migration contract.

Determine whether it uses:

* ranking
* randomization
* recency
* publication ordering
* another metric

Preserve that behavior unless there is an explicit current decision to change it.

If the function uses nondeterministic/random selection, ensure the Spring implementation does not accidentally turn it into deterministic primary-key ordering.

If ranking is somewhat stale or delayed, that is acceptable for Showcase discovery.

The application does not require strict transactional freshness for this read.

---

# Caching

The frontend currently caches Showcase results for approximately 10 minutes.

This is a frontend caching policy.

Do not reproduce the 10-minute caching behavior inside Spring unless the existing backend already has an intentional server-side cache requirement.

The endpoint should simply provide the requested Showcase result.

HTTP/server-side caching can be introduced later if actual traffic justifies it.

---

# Validation

Validate the client-supplied `limit`.

Consider:

* missing value
* zero
* negative values
* excessive values
* malformed numeric input

Use standard Spring parameter validation.

Do not use string parsing manually if Spring can bind directly to a numeric type.

---

# Error Semantics

Follow the project's existing exception and `@RestControllerAdvice` conventions.

Expected categories include:

```text
400 → invalid limit
500 → unexpected query/database failure
```

An empty Showcase should normally return:

```text
200
```

with an empty collection rather than being treated as an error.

Do not expose raw SQL or PostgreSQL function errors.

---

# Tests

Add meaningful tests for the migrated endpoint.

## Controller

Test:

```text
GET /api/templates/showcase?limit=...
```

including:

* successful public request
* anonymous access
* correct response shape
* requested limit forwarded/applied
* invalid limit
* zero/negative limit according to contract
* missing limit behavior according to contract

## Query / Integration

Verify:

* only eligible public/published templates are returned
* result count does not exceed requested `limit`
* fewer available templates returns fewer results without error
* no templates returns empty result
* ordering/selection semantics from `get_showcase_templates`
* archived/private/ineligible templates are excluded
* canonical template data is queried directly
* `public_activity_templates` is not required

Do not test frontend 10-minute caching in Spring tests.

---

# OpenAPI

Update or verify the Spring OpenAPI contract for:

```text
GET /api/templates/showcase
```

including:

* public access
* `limit` query parameter
* validation constraints
* response DTO
* status codes

Do not preserve:

```text
/api/showcase
```

merely because that was the legacy frontend-oriented route.

---

# Migration Mapping

Before implementation, produce:

```text
Legacy:
GET /api/showcase

PostgreSQL:
get_showcase_templates

Spring:
GET /api/templates/showcase?limit={limit}

Domain:
Play

Controller:
TemplateController
```

Also explicitly document:

```text
public_activity_templates
→ removed from this read flow
```

and identify the canonical table/query path used instead.

---

# Migration Report

After implementation, create the corresponding review/migration result document according to the established task workflow.

Include:

## Legacy Behavior

* legacy route
* `get_showcase_templates`
* frontend usage
* request limit behavior

## Spring Implementation

* new REST endpoint
* controller
* service/query method
* repository query
* response DTO

## Projection Removal

Document that `public_activity_templates` is no longer used for Showcase.

Explain that it primarily supported Supabase anonymous/RLS access and introduced unnecessary synchronization complexity.

## Template Immutability

Document why direct canonical reads are acceptable given the immutable/versioned template model.

## Query Semantics

Document:

* filtering
* selection/ranking
* ordering
* limit behavior

## Caching

Record that the current 10-minute cache remains a frontend concern and was not duplicated in Spring.

## Tests

List the added tests and what they verify.

---

# Important Constraints

Do not:

* create `ShowcaseController`
* create a Showcase domain/entity
* use `public_activity_templates`
* recreate a synchronization mechanism for that projection
* introduce CQRS infrastructure
* introduce cron-based projection synchronization
* hardcode `12` as a backend limit
* copy frontend cache duration into backend logic
* require authentication for a public Showcase without justification
* return JPA entities directly
* fetch all templates and limit in Java
* modify template immutability semantics
* introduce unrelated storage/infrastructure changes

Use:

```text
TemplateController
→ GET /api/templates/showcase?limit={limit}
```

with canonical Play Template data as the source of truth.
