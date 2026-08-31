# Task: Migrate PlayTemplate and PlayInstance APIs to Spring Boot

Migrate the existing **PlayTemplate** and **PlayInstance** APIs from the legacy Next.js/Supabase implementation into the Spring Boot backend.

Use RESTful API design for the new endpoints.

Do not mechanically translate the legacy implementation line by line. First understand the existing behavior from the migration docs, OpenAPI spec, domain docs, PostgreSQL schema/functions, and current Spring conventions. Then implement the equivalent behavior in Spring.

## Required Reading

Read these files before making implementation decisions:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. all relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`

Also inspect the existing Spring implementation and tests:

5. `src/main/java/games/tapped/play/controller/TemplateController.java`
6. `src/test/java/games/tapped/play/controller/TemplateControllerTest.java`

Then inspect any relevant existing DTOs, services, repositories, entities, exceptions, security classes, and test utilities in the Spring project.

## Source Priority

When sources conflict, prefer them in this order:

1. current domain documentation under `docs/domain`
2. current OpenAPI contract
3. `SPRING-MIGRATION.md`
4. current Spring architectural conventions
5. PostgreSQL schema and function behavior
6. legacy implementation details

Do not silently resolve meaningful conflicts. Report any ambiguity or intentional semantic change.

---

# Scope

Migrate:

* PlayTemplate-related APIs
* PlayInstance-related APIs

Use the existing `TemplateController` for PlayTemplate-related endpoints.

Create:

```text
InstanceController
```

for PlayInstance-related endpoints.

Do not migrate unrelated domains or infrastructure unless required to complete these APIs.

---

# Domain Model

The Play domain represents general behavioral content.

A Play is not inherently a Challenge.

Challenge Mode is the MVP mode, but the PlayTemplate and PlayInstance models must remain general enough to support future modes such as:

* offline meetups
* chatting sessions
* routines
* other behavioral formats

Do not introduce Challenge-specific fields, lifecycle assumptions, or naming into generic PlayTemplate or PlayInstance behavior unless the operation is explicitly Challenge-specific.

Preserve the distinction between concepts such as:

```text
PlayTemplate
PlayInstance
Tap
PlayCard
Challenge-specific configuration
Challenge verdict/finalization
```

Refer to the Play domain documentation for their intended meaning.

---

# Authentication and Application User Identity

The Spring application uses `AppJwtPrincipal` as the authenticated principal.

`AppJwtPrincipal` contains the internal application user ID corresponding to:

```text
app_users.id
```

This ID is different from Google's OAuth2/OpenID Connect `sub`.

The external provider `sub` is only used at the authentication/account-mapping boundary.

For all application business logic, the only user identifier that should be used is:

```text
AppJwtPrincipal.userId
```

Rules:

* Do not use Google's OIDC `sub` as an application/business identifier.
* Do not use email as the application user identifier.
* Do not trust a client-provided `userId` to identify the authenticated user.
* Do not derive ownership from request payload identity fields when `AppJwtPrincipal.userId` already determines the user.
* Use `AppJwtPrincipal.userId` for ownership checks, creator identity, user-scoped queries, and authorization.

If a legacy request contains a current-user identifier that is redundant with the authenticated principal, remove it from the new contract unless it has another legitimate domain meaning.

---

# REST API Design

Legacy Next.js route names are not authoritative for the new Spring API.

Use resource-oriented REST endpoints.

Prefer patterns such as:

```text
POST   /api/templates
GET    /api/templates/{id}
PATCH  /api/templates/{id}
DELETE /api/templates/{id}

POST   /api/instances
GET    /api/instances/{id}
PATCH  /api/instances/{id}
```

only where they correctly represent the actual domain behavior.

Do not mechanically create action-oriented endpoints such as:

```text
/create
/update
/doSomething
```

when the same behavior can be represented naturally through HTTP methods and resources.

If an operation is genuinely not CRUD-like and represents a meaningful domain action, an action endpoint may be appropriate, but justify it from the domain behavior.

---

# Controller Conventions

Use:

`src/main/java/games/tapped/play/controller/TemplateController.java`

as the primary reference for:

* route style
* principal injection
* controller structure
* response conventions
* service delegation
* status codes
* exception handling

Use:

`src/test/java/games/tapped/play/controller/TemplateControllerTest.java`

as the primary reference for controller testing conventions.

Keep controllers thin.

Controllers should mainly:

1. receive HTTP input
2. obtain `AppJwtPrincipal`
3. validate request DTOs
4. delegate to services
5. return HTTP responses

Do not place business logic or repository orchestration directly in controllers.

---

# Request DTOs and Validation

Use DTOs and Jakarta Bean Validation for request validation.

Use:

```java
@Valid
```

on request DTOs.

Apply appropriate constraints where supported by the actual API/domain contract, such as:

```java
@NotNull
@NotBlank
@Size
@Min
@Max
@Positive
@PositiveOrZero
@Pattern
```

For every string field, explicitly consider:

* null
* empty string
* whitespace-only string
* minimum length
* maximum length
* allowed values
* malformed identifiers
* malformed paths/URLs where applicable
* whether trimming is appropriate

Do not invent arbitrary restrictions that are not supported by the domain documentation, OpenAPI spec, schema, or legacy behavior.

If a string represents a finite domain value, prefer a Java enum where practical.

---

# Type Safety

Prefer strong Java types over loose strings.

Examples:

```text
PostgreSQL UUID
→ java.util.UUID

enum-like database value
→ Java enum

timestamp
→ appropriate java.time type

numeric amount
→ appropriate numeric/value type
```

Review `legacy/supabase/schema.sql` carefully for:

* PostgreSQL types
* nullability
* enum definitions
* foreign keys
* defaults
* constraints
* numeric ranges
* timestamps

Avoid carrying JavaScript-style string typing into Spring when Java can represent the value more safely.

---

# PostgreSQL Function / RPC Migration

Read every PostgreSQL function relevant to PlayTemplate and PlayInstance migration in full.

For each function, identify:

1. inputs
2. outputs
3. validation rules
4. authorization assumptions
5. tables read
6. tables written
7. generated/default values
8. conditional behavior
9. ordering requirements
10. error cases
11. transaction expectations
12. side effects

Treat these functions as evidence of legacy business behavior, not as code that must be copied structurally.

Determine which behavior belongs in:

```text
DTO validation
controller
service/application layer
domain logic
repository/query layer
database constraint
```

Do not blindly translate stored-procedure SQL into a large Spring service method.

---

# Validation vs Authorization

Keep these separate.

Validation asks:

```text
Is this request valid?
```

Authorization asks:

```text
Is this authenticated user allowed to do this?
```

Examples:

```text
blank title
→ validation failure

malformed enum
→ validation failure

editing another user's template
→ authorization failure

referenced template does not exist
→ not found
```

Do not represent ownership failures as DTO validation errors.

---

# Transaction Boundaries

Determine the transaction boundary for every migrated business operation.

If multiple database writes constitute one business operation and must succeed or fail together, use Spring transaction management at the appropriate service boundary.

Do not assume external systems such as:

* Supabase Storage
* Lemon Squeezy
* future S3 storage

participate in the same relational database transaction.

Preserve meaningful database constraints even when application validation also exists.

---

# Image / Storage References

The current migration keeps the existing external image-storage flow.

The frontend may upload the image first and send the resulting storage reference with the template request.

Do not migrate storage infrastructure as part of this task.

Preserve the current storage semantics required by the existing API.

Avoid unnecessarily spreading storage-provider-specific concepts into the Play domain.

If practical, prefer neutral application naming such as:

```text
coverImageKey
imageReference
```

over provider-specific terminology, but do not change the current contract without checking the OpenAPI specification and migration requirements.

---

# Service Layer

Business behavior should live in services/domain logic.

Services should handle things such as:

* ownership
* lifecycle/state transitions
* orchestration of repository operations
* transaction boundaries
* domain-specific validation that cannot be expressed as DTO validation

Avoid duplicating the same rule in several layers without reason.

---

# Repository Layer

Use the project's current repository conventions.

Prefer JPA/repository methods for ordinary persistence.

Use explicit JPQL/native queries when they are materially better suited to the required behavior.

Do not use native SQL merely because the previous implementation was a PostgreSQL function.

Avoid unnecessary bidirectional entity relationships and accidental N+1 queries.

Only add entity relationships when the required business logic benefits from them.

---

# Responses

Use explicit response DTOs where the API has a defined response contract.

Keep response values strongly typed.

Do not add Bean Validation to response DTOs merely for symmetry with request DTOs.

Instead:

* maintain valid application/domain state
* construct responses from valid state
* verify response shape and values through tests
* keep generated OpenAPI aligned with the implementation

If a response field has a genuine invariant, enforce that invariant before response construction rather than adding arbitrary string validation to outgoing DTOs.

---

# Error Handling

Follow the project's existing exception handling and `@RestControllerAdvice` conventions.

Use appropriate HTTP status semantics.

Where applicable:

```text
400 → invalid request
401 → unauthenticated
403 → authenticated but unauthorized
404 → resource not found
409 → conflict with current resource state
500 → unexpected internal error
```

Do not expose raw database exceptions or implementation details in HTTP responses.

Preserve meaningful legacy failure behavior where appropriate.

---

# Tests

Follow the style of:

`src/test/java/games/tapped/play/controller/TemplateControllerTest.java`

Add or update tests together with each migrated endpoint.

Cover relevant cases such as:

## Success

* authenticated valid request
* correct HTTP status
* correct response body
* expected service/database behavior

## Request Validation

Where supported by real constraints:

* missing required field
* null value
* blank string
* over-length string
* invalid enum
* malformed UUID
* invalid numeric range

## Authentication

* missing authentication
* proper use of `AppJwtPrincipal`

## Authorization

Where ownership applies:

* owner can perform the operation
* another authenticated user cannot

## Resource and State Errors

Where relevant:

* nonexistent template
* nonexistent instance
* invalid lifecycle transition
* duplicate/conflicting operation
* invalid related-resource reference

## Persistence / Integration Behavior

Where appropriate:

* expected rows are created or updated
* related writes are atomic
* rollback occurs when the operation fails

Do not mock away the behavior that the test is supposed to prove.

Choose controller, unit, repository, or integration tests according to the responsibility being tested.

---

# OpenAPI

The project uses:

`goofed/goofed/API/OPENAPI.yaml`

as the current mechanical API specification.

Use it to understand the existing/current intended API contract.

The Spring application also uses springdoc-generated OpenAPI.

Ensure the new Spring implementation correctly exposes:

* REST path
* HTTP method
* request DTO
* response DTO
* status codes
* validation constraints
* authentication requirements

If the legacy OpenAPI specification conflicts with the newly chosen RESTful route structure, preserve the business contract while documenting the intentional route migration.

Do not add excessive OpenAPI annotations when Spring and DTO metadata already describe the contract accurately.

---

# Migration Process

For each PlayTemplate or PlayInstance API, follow this sequence.

## 1. Analyze Existing Behavior

Identify:

```text
Legacy Next.js endpoint
PostgreSQL function/RPC
Purpose
Request contract
Response contract
Authentication requirement
Authorization requirement
Business rules
DB reads
DB writes
Transaction boundary
Failure conditions
```

## 2. Compare Against Domain Documentation

Verify that the legacy behavior still matches the current Play domain model.

Specifically check that Challenge-specific assumptions are not being copied into generic PlayTemplate or PlayInstance code unnecessarily.

## 3. Compare Against Current Spring Conventions

Inspect:

```text
TemplateController
TemplateControllerTest
existing DTOs
services
repositories
entities
exceptions
security code
```

Reuse existing conventions unless there is a concrete reason to improve them.

## 4. Propose the Migration Mapping

Before implementation, produce a concise mapping such as:

```text
Legacy:
POST /api/playTemplate/create/challenge
RPC: create_challenge_template(...)

Spring:
POST /api/templates

Auth:
Supabase identity
→ AppJwtPrincipal.userId

Legacy RPC responsibilities:
→ DTO validation
→ TemplateService
→ repositories
→ transaction
```

Identify semantic changes or uncertain interpretations before coding.

## 5. Implement

Implement the required:

```text
DTOs
validation
controller endpoints
service behavior
repository/query behavior
authorization
transaction handling
exceptions
response DTOs
```

## 6. Test

Add/update tests and run the relevant test suite.

Fix migration-related failures.

## 7. Report

After implementation, summarize:

* migrated APIs
* old routes replaced
* PostgreSQL functions replaced
* new REST routes
* validation rules
* authorization behavior
* transaction boundaries
* tests added/updated
* assumptions
* intentional behavior changes
* unresolved issues
* remaining PlayTemplate/PlayInstance migration work

---

# Important Constraints

Do not:

* use Google's OIDC `sub` for business logic
* use email as the canonical application identity
* trust a client-provided current-user ID
* leak Challenge-specific assumptions into generic PlayTemplate or PlayInstance models
* mechanically preserve legacy Next.js route naming
* place business logic in controllers
* duplicate validation without reason
* silently change API/domain behavior
* introduce unrelated infrastructure
* over-engineer abstractions for hypothetical future requirements

Prefer the smallest implementation that:

1. preserves intended domain behavior,
2. follows current Spring conventions,
3. uses RESTful endpoints,
4. is strongly typed,
5. validates requests through DTOs and `@Valid`,
6. uses `AppJwtPrincipal.userId` as the sole business user identifier,
7. keeps authorization explicit,
8. has clear transaction boundaries,
9. is covered by meaningful tests,
10. preserves future Play-mode extensibility.

Start with the PlayTemplate APIs. Use the existing `TemplateController` and `TemplateControllerTest` as the baseline. Once the Template migration is consistent and tested, migrate the PlayInstance APIs into `InstanceController`.
