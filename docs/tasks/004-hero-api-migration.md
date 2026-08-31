# Task: Migrate Hero API

Migrate the legacy Hero API into the Spring Boot Play domain.

## Purpose

The Hero API currently provides the weekly total Tap count across all users.

The frontend displays this value in the hero section.

The current business meaning is:

> Return the total number of Taps created by all users during the current weekly period.

The existing legacy router calls a PostgreSQL RPC to calculate this value.

Although the value is currently used by the hero section, do not model `Hero` as a standalone backend domain.

Treat this as a Play-domain statistics/read API.

The response may later be extended if the hero section requires additional Play statistics.

## Required Reading

Before implementation, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`
5. the legacy Hero API implementation
6. the PostgreSQL RPC/function called by the Hero API
7. existing Spring Play controller/service/repository conventions
8. relevant Play tests

## Analysis

Before coding, identify:

* legacy route
* RPC/function name
* exact weekly boundary semantics
* tables/columns involved
* whether canceled or invalid Taps are excluded
* timezone assumptions
* return type
* behavior when no Taps exist

Do not guess the weekly calculation. Preserve the actual intended semantics from the legacy RPC/schema.

## REST Design

Do not preserve `/hero` automatically just because the frontend component uses that name.

Model the underlying resource/query.

Prefer a Play statistics route such as:

```text
GET /api/play/stats/weekly
```

or another route consistent with the existing Spring API conventions.

The returned representation may currently contain only:

```json
{
  "tapCount": 123
}
```

Keep the response extensible enough to add related weekly Play statistics later without creating a separate Hero domain.

## Implementation

Keep the controller thin.

Use an appropriate Play query/statistics service and repository/query implementation.

For this aggregate read, use the simplest efficient database query.

Do not load Tap entities individually to count them.

Preserve the PostgreSQL RPC's filtering and date semantics.

## Authentication

Determine from the legacy API/OpenAPI whether this endpoint is public.

If it is used on the anonymous landing/main page, preserve anonymous read access.

Do not require `AppJwtPrincipal` unless the existing behavior actually depends on the authenticated user.

## Tests

Cover at least:

* correct weekly Tap total
* zero-result case
* exclusion rules defined by the legacy function
* weekly boundary behavior where practical
* authentication/public access behavior
* correct response shape

## Report

After implementation, report:

* legacy route/RPC
* new REST route
* weekly calculation semantics
* query implementation
* authentication behavior
* tests added
* any intentional differences
