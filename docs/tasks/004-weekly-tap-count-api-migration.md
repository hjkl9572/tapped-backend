# Task: Migrate Weekly Tap Count API

Migrate the legacy Hero API behavior into the Spring Boot Play domain.

The legacy endpoint is currently used by the frontend hero section, but the backend concept is not “Hero.”

Its actual meaning is:

> Return the total number of Taps created by all users during the requested period.

For the current MVP, the only supported period is:

```text
week
```

The new Spring endpoint should be:

```text
GET /api/taps/count?period=week
```

Implement this endpoint in:

```text
TapController
```

Do not create a separate `HeroController` or `PlayStatController` for this behavior.

---

# Domain Ownership

This query belongs to the Play domain because Tap is a distinct Play-domain concept.

The frontend currently consumes the value in the hero section, but frontend placement must not determine backend ownership.

Conceptually:

```text
Frontend Hero
    ↓
needs weekly Tap count
    ↓
GET /api/taps/count?period=week
    ↓
TapController
    ↓
Play domain
```

`Hero` should remain a frontend presentation concept.

---

# Required Reading

Before implementation, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`
5. the legacy Hero API implementation
6. the exact PostgreSQL RPC/function used by the Hero API
7. existing Spring Play controllers/services/repositories
8. existing Play tests

Inspect the actual legacy implementation before deciding the query semantics.

---

# Existing Behavior

The current legacy API calls a PostgreSQL RPC that calculates the total Tap count across all users for the current weekly period.

Determine exactly:

* which table represents Taps
* which timestamp determines whether a Tap belongs to the week
* how the start/end of the week are calculated
* timezone assumptions
* whether canceled or otherwise invalid Taps are excluded
* whether all users are included
* behavior when no Taps exist
* exact numeric return type

Do not guess the weekly boundary semantics.

Preserve the actual intended behavior from the RPC/schema unless current documentation explicitly defines something different.

---

# REST API

Implement:

```http
GET /api/taps/count?period=week
```

Use plural resource naming:

```text
/api/taps
```

The query parameter represents the requested aggregation period.

For now, support only:

```text
period=week
```

Do not prematurely introduce arbitrary `from` / `to` date ranges.

If another period is unsupported, return the project's normal invalid-request response rather than silently substituting a value.

---

# TapController

Create `TapController` if it does not already exist.

Use it for HTTP operations whose primary subject is Tap.

The controller may later contain additional Tap-related operations such as Tap creation or lifecycle interaction.

Keep the controller thin.

Conceptually:

```java
@RestController
@RequestMapping("/api/taps")
public class TapController {

    @GetMapping("/count")
    public TapCountResponse getCount(...) {
        ...
    }
}
```

Follow the existing controller conventions in the Spring project.

Do not introduce a controller abstraction solely for statistics.

---

# Request Parameter

Model `period` using a strongly typed representation where practical.

Prefer something such as:

```java
enum TapCountPeriod {
    WEEK
}
```

or another project-consistent approach over unrestricted string branching.

The HTTP contract should accept:

```text
week
```

If enum conversion requires custom handling to preserve lowercase API values, implement it consistently with the project's existing enum conventions.

Ensure invalid values result in a clean `400 Bad Request`.

---

# Response

Return an explicit response DTO.

For example:

```json
{
  "count": 1234
}
```

Use an appropriate numeric Java type based on the possible database count.

Do not return a raw primitive if the project normally uses explicit response DTOs.

The response may remain intentionally small.

Do not add unrelated Hero-specific fields.

---

# Service / Query Layer

Use an appropriate Tap query/service method.

For example, conceptually:

```text
TapController
    ↓
TapQueryService
    ↓
TapRepository
```

or the closest equivalent consistent with the current project structure.

Do not create a large generic statistics service just for this endpoint.

The service/query method should express the actual intent clearly, such as:

```text
countTaps(period)
```

or:

```text
countWeeklyTaps()
```

Choose the simplest design consistent with the rest of the project.

---

# Persistence

Use an aggregate database query.

Do not load Tap entities individually and count them in Java.

Preserve the filtering and weekly date semantics of the legacy PostgreSQL RPC.

If the PostgreSQL function can be replaced cleanly with a JPA/JPQL/native count query, prefer the simplest correct implementation.

Do not retain the RPC structure merely because the legacy system used one.

---

# Authentication

Determine from the existing API and frontend usage whether this endpoint is public.

Because the count is displayed in the hero section, it is likely intended for anonymous access.

If the legacy behavior confirms that, configure:

```text
GET /api/taps/count
```

as publicly readable.

Do not inject or require `AppJwtPrincipal` when the result does not depend on the authenticated user.

---

# Validation

Validate `period`.

For the current implementation:

```text
week
```

is the only supported value.

Verify:

* missing `period`
* unsupported value
* malformed value
* case behavior

Follow existing API conventions rather than inventing implicit defaults unless the old/current contract already defines one.

---

# Tests

Add tests covering meaningful behavior.

At minimum:

## Controller/API

* `GET /api/taps/count?period=week`
* correct response status
* correct response shape
* public/anonymous access if applicable
* unsupported `period` returns `400`
* missing required `period` behavior

## Query Behavior

Verify:

* correct total for Taps inside the current week
* Taps outside the current week are excluded
* zero-result case returns `0`
* any canceled/state filtering required by the legacy RPC
* weekly boundary semantics where practical

Do not test private implementation details.

---

# OpenAPI

Update or verify the OpenAPI contract for:

```text
GET /api/taps/count
```

including:

* required `period` query parameter
* allowed value `week`
* response DTO
* status codes
* authentication/public-access semantics

Do not preserve `/hero` merely because the current frontend uses the result in the hero section.

---

# Migration Report

After implementation, report:

## Legacy

* old Hero route
* RPC/function used
* current frontend usage

## Spring

```text
GET /api/taps/count?period=week
```

* controller
* service/query method
* repository/query
* response DTO

## Semantics

Document:

* definition of “week”
* included/excluded Tap states
* timezone behavior
* authentication requirement

## Intentional Architectural Change

Explicitly note:

> The legacy endpoint was named according to its frontend presentation location (`hero`). The Spring API is instead modeled around the underlying domain resource (`Tap`).

## Tests

List the tests added and the behaviors they verify.
