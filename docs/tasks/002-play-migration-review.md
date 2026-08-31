# Task: Review the Play Creation Flow Migration

Review the completed Spring migration of the **Play creation flow**, including both PlayTemplate creation and the related PlayInstance creation behavior.

The goal is to verify that the migrated Spring implementation is:

* behaviorally equivalent to the intended legacy flow where appropriate
* consistent with the current Play domain model
* RESTful
* correctly authenticated and authorized
* strongly typed
* correctly validated
* transactionally safe
* properly tested
* free from accidental Challenge-specific coupling in generic Play concepts

Do **not** begin by refactoring or rewriting code.

First reconstruct the complete flow, identify discrepancies and risks, and produce a review report. Make code changes only after the issues are understood.

---

# Required Reading

Read the following before reviewing the implementation:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. all relevant documents under `docs/domain`
4. `legacy/supabase/schema.sql`

Then inspect the Spring implementation involved in the Play creation flow.

At minimum, inspect:

* `src/main/java/games/tapped/play/controller/TemplateController.java`
* `src/main/java/games/tapped/play/controller/InstanceController.java`
* `src/test/java/games/tapped/play/controller/TemplateControllerTest.java`

Also inspect all related:

* request DTOs
* response DTOs
* services
* repositories
* entities
* enums
* exception classes
* `@RestControllerAdvice`
* security/principal handling
* repository tests
* service tests
* integration tests

Inspect the actual migrated code rather than assuming the migration task followed its instructions correctly.

---

# Review Scope

Review the full flow beginning with creation or selection of a PlayTemplate and ending with creation of a playable PlayInstance.

Conceptually reconstruct:

```text
PlayTemplate
    ↓
user selects/creates a behavior
    ↓
mode-specific configuration if required
    ↓
PlayInstance
    ↓
user can participate in the Play
```

For the MVP, Challenge Mode may add additional configuration, but generic PlayTemplate and PlayInstance behavior must remain independent from Challenge-specific assumptions.

---

# Source Priority

When determining intended behavior, use this priority:

1. current domain documentation
2. current OpenAPI specification
3. `SPRING-MIGRATION.md`
4. explicit architectural decisions
5. current Spring conventions
6. PostgreSQL schema/function behavior
7. legacy Next.js implementation details

If two sources genuinely conflict, identify the conflict instead of silently choosing one.

---

# 1. Reconstruct the Current Spring Flow

Before judging individual classes, explain the current Spring Play creation flow.

Trace:

```text
HTTP request
    ↓
Controller
    ↓
DTO validation
    ↓
AppJwtPrincipal
    ↓
Service
    ↓
authorization/business rules
    ↓
repository/database operations
    ↓
transaction commit
    ↓
response DTO
```

For each endpoint involved, identify:

* HTTP method
* path
* request DTO
* principal
* service method
* repositories touched
* tables/entities affected
* response DTO
* possible exceptions

Do this for both:

* PlayTemplate creation
* PlayInstance creation

Also identify any Challenge-specific creation flow connected to them.

---

# 2. Verify Domain Boundaries

The Play domain represents behavioral content.

The generic relationship should remain conceptually similar to:

```text
PlayTemplate
→ defines the behavior

PlayInstance
→ represents a user's participation in that behavior
```

Challenge Mode extends this model.

Verify that generic PlayTemplate and PlayInstance code does not unnecessarily require Challenge concepts such as:

* stake
* referee
* verdict
* success/failure
* payment
* Final Call

Challenge-specific behavior may depend on PlayTemplate or PlayInstance, but the dependency should not be reversed.

Flag any design where:

```text
generic Play
→ cannot exist without Challenge
```

unless the current domain documentation explicitly requires it.

---

# 3. Authentication and Identity Review

The only user identifier allowed for application business logic is:

```text
AppJwtPrincipal.userId
```

which corresponds to:

```text
app_users.id
```

Verify that no migrated Play creation logic uses:

* Google/OIDC `sub`
* email
* provider subject
* a client-supplied current-user ID

for ownership or application identity.

Trace how `AppJwtPrincipal` reaches the relevant service operations.

Verify that ownership is assigned using the authenticated principal rather than request payload data.

A request must not be able to impersonate another user by providing another `userId`.

---

# 4. Request Contract and Validation Review

Review every request DTO involved in Play creation.

For each field, compare:

```text
OpenAPI
PostgreSQL schema
legacy behavior
Java type
Bean Validation annotations
```

Check especially:

### Strings

Verify handling of:

* null
* empty string
* whitespace-only string
* maximum length
* minimum length where meaningful
* malformed storage paths
* finite string values represented as enums where appropriate

Use `@NotBlank` rather than only `@NotNull` when whitespace-only input is invalid.

Do not require arbitrary limits unsupported by the domain/schema.

### Types

Verify that appropriate Java types are used:

```text
UUID → UUID
enum → enum
timestamp → java.time type
numeric values → appropriate numeric type
boolean → boolean/Boolean according to nullability
```

Flag unnecessary conversion between typed values and strings.

### Enum Handling

Verify that malformed enum input results in a clean client error rather than an internal exception.

Check that API enum values correspond to the actual domain/database values.

---

# 5. REST API Review

Review whether the migrated endpoints represent resources naturally.

Check for:

* appropriate nouns in paths
* appropriate HTTP methods
* correct status codes
* correct use of path variables
* absence of unnecessary `/create`, `/update`, or RPC-style route naming

Do not reject an action endpoint merely because it contains an action.

If an operation represents a real domain transition that cannot naturally be expressed as CRUD, evaluate whether the action endpoint is justified.

Compare the final Spring route with the previous Next.js route and explain whether the migration improved the API semantics.

---

# 6. Controller Review

Controllers should remain thin.

Verify that controllers primarily:

1. receive the HTTP request
2. receive `AppJwtPrincipal`
3. trigger DTO validation through `@Valid`
4. delegate to a service
5. return the response

Flag:

* business rules inside controllers
* repository calls from controllers
* manual validation that belongs in DTOs/services
* authentication/ownership logic duplicated across endpoints
* unnecessary mapping complexity

Use `TemplateController` as the style baseline and verify that `InstanceController` follows the same conventions unless there is a justified difference.

---

# 7. Service and Business Logic Review

Review service methods involved in Play creation.

Verify:

* business logic has an appropriate home
* methods have clear responsibilities
* template creation and instance creation are not accidentally coupled
* Challenge behavior is isolated where appropriate
* ownership checks occur before protected mutations
* nonexistent references are handled explicitly
* lifecycle transitions are valid
* no legacy Supabase assumptions remain accidentally embedded

Look for duplicated logic between:

* Template service
* Instance service
* Challenge-related service

and determine whether duplication represents genuinely different domain behavior or accidental migration duplication.

Do not recommend abstraction merely because two small methods look similar.

---

# 8. Persistence Review

Compare the migrated persistence behavior against:

`legacy/supabase/schema.sql`

and the relevant PostgreSQL functions.

For each creation flow verify:

* which rows should be inserted
* insert ordering
* foreign-key relationships
* generated IDs
* default values
* nullable values
* enum values
* timestamps
* lifecycle state
* ownership fields

Check whether any behavior previously provided automatically by a PostgreSQL function has been lost during migration.

Examples:

* creation of related configuration rows
* generated identifiers
* conditional inserts
* state initialization
* default values
* integrity checks

Do not assume successful compilation means semantic equivalence.

---

# 9. Transaction Review

Identify the actual transaction boundary for each creation operation.

Determine whether multiple writes belong to one business operation.

For example:

```text
create template
+ create mode configuration
+ create related records
```

or:

```text
create instance
+ create challenge configuration
+ initialize related state
```

If those writes must either all succeed or all fail, verify that they execute within the same Spring transaction.

Look for:

* missing `@Transactional`
* transaction placed at the wrong layer
* nested service calls that unintentionally escape the expected transaction
* exceptions swallowed before rollback
* database writes performed before validation that should happen first

Also verify that no code assumes external systems participate in the DB transaction.

---

# 10. JPA and Query Review

Review the persistence implementation for common migration problems.

Check for:

* accidental N+1 queries
* unnecessary eager loading
* unnecessary bidirectional entity mappings
* incorrect owning/inverse relationship setup
* loading whole entities when existence/ownership checks would suffice
* native SQL retained unnecessarily from the legacy RPC
* incorrect use of `save()` where dirty checking already applies
* repository methods with ambiguous semantics

Do not recommend additional mappings unless the required business flow benefits from them.

---

# 11. Error Semantics Review

Verify that errors are mapped consistently.

Where applicable:

```text
400 → invalid request
401 → unauthenticated
403 → authenticated but not allowed
404 → referenced resource does not exist
409 → current resource state conflicts with operation
500 → unexpected failure
```

Check that:

* database exceptions are not leaked
* malformed request values do not become 500 errors
* nonexistent resources do not become authorization failures accidentally
* ownership failures do not become validation failures
* errors use the project's established response structure

---

# 12. Response Contract Review

Compare response DTOs against the OpenAPI specification and intended frontend usage.

Verify:

* field names
* field types
* nullability
* status code
* lifecycle/state values
* returned IDs

Do not add Bean Validation to response DTOs merely for symmetry.

Instead, verify that responses are constructed from valid application state and are covered by tests.

Flag any response fields that expose internal implementation concepts unnecessarily.

---

# 13. Test Review

Review the tests as evidence that the migration works.

Do not only count tests. Determine what behavior they actually prove.

At minimum, verify coverage for relevant cases:

### Template creation

* authenticated valid creation
* invalid/blank strings
* malformed enum/type
* unauthenticated access
* correct owner assignment from `AppJwtPrincipal`
* expected database/service effects
* Challenge-specific configuration when applicable

### Instance creation

* authenticated valid creation
* nonexistent template
* unauthorized template/resource access where applicable
* malformed request
* correct user identity
* correct initial state
* correct mode-specific initialization

### Transaction behavior

Where multiple rows are created:

* successful atomic creation
* rollback when a later write fails

### Security

Explicitly verify that a client cannot choose another current-user identity.

### HTTP contract

Verify:

* expected routes
* methods
* status codes
* response shape

Use the existing `TemplateControllerTest` style as the baseline.

Identify important behavior that currently has no test.

---

# 14. Compare Against Legacy PostgreSQL Functions

For every PostgreSQL function replaced by the migration, create a short mapping:

```text
Legacy function:
<function name>

Responsibilities:
- ...
- ...
- ...

Spring replacement:
- DTO:
- Controller:
- Service:
- Repository:
- DB constraint:

Preserved behavior:
- ...

Changed behavior:
- ...
```

The purpose is to verify that no responsibility disappeared merely because the stored procedure itself no longer exists.

---

# 15. Review Output

Produce the review in this order.

## A. Flow Summary

Briefly explain how Play creation currently works in Spring from HTTP request to database commit.

## B. Findings

Group findings by severity:

### Critical

Problems that can cause:

* incorrect ownership/security
* corrupted/inconsistent state
* broken transaction guarantees
* fundamentally incorrect domain behavior

### High

Problems likely to cause:

* incorrect API behavior
* substantial legacy-semantic differences
* incorrect validation
* important missing tests
* incorrect persistence

### Medium

Problems involving:

* architectural inconsistency
* maintainability
* weak type usage
* REST semantics
* avoidable coupling

### Low

Minor naming, consistency, or cleanup issues.

For every finding include:

```text
Location
Problem
Why it matters
Expected behavior
Recommended fix
```

Use concrete file/class/method references.

Do not report stylistic preferences as architectural defects.

## C. Legacy-to-Spring Mapping

Show how the important legacy RPC responsibilities were redistributed in Spring.

## D. Missing Test Coverage

List only meaningful missing scenarios.

## E. Domain Boundary Assessment

Answer explicitly:

1. Is PlayTemplate still generic?
2. Is PlayInstance still generic?
3. Is Challenge-specific behavior correctly isolated?
4. Can future Play modes reasonably build on this model without redesigning the generic creation flow?

## F. Security Assessment

Answer explicitly:

1. Is `AppJwtPrincipal.userId` the only business user identity?
2. Can request data override ownership?
3. Are authentication and authorization correctly separated?

## G. Transaction Assessment

State the transaction boundaries and whether they correctly preserve each creation invariant.

## H. Final Verdict

Choose one:

```text
READY
READY WITH MINOR FIXES
NEEDS REVISION
BLOCKED BY CORRECTNESS ISSUE
```

Explain the decision briefly.

---

# Fixing Issues

Do not modify code before completing the review.

After the review:

* fix Critical and High findings
* fix Medium findings when they have a clear correctness or architectural benefit
* avoid unnecessary cleanup unrelated to the Play creation flow

After fixes:

1. run the relevant tests
2. re-review affected paths
3. report what changed
4. report remaining findings, if any

Do not weaken tests or change specifications merely to make the implementation pass.

If implementation and specification conflict, determine which represents the intended current behavior before modifying either.
