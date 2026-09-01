# Task: Migrate `/me` and Profile APIs into Play and Profile Domains

Migrate the currently used `/me` and Profile APIs into the Spring Boot backend.

The legacy frontend groups several APIs by page location and frontend implementation history. The Spring migration must instead separate them by domain responsibility.

Use these domain boundaries:

```text
User
→ application identity

Profile
→ user presentation

Play
→ behavioral content
```

The `/me` page is a frontend composition of multiple domains. It is not a backend domain boundary.

---

# Scope

## Play Domain

Migrate:

```text
me/personal-feed
```

Target:

```text
GET /api/tap-cards/personal-feed
```

This belongs to the Play domain because it returns the authenticated user's Play Cards.

---

## Profile Domain

Migrate:

```text
me/profile-card
profile/by-handle
profile/handle/check
profile/nickname
```

Create or use:

```text
ProfileController
```

Consolidate profile mutations into one partial-update endpoint:

```text
PATCH /api/profiles/current
```

Use public/profile-query endpoints:

```text
GET /api/profiles/by-handle/{handle}
GET /api/profiles/handles/{handle}/availability
```

---

# Explicitly Deferred

Do not migrate:

```text
profile/tos
profile/avatar/upload
profile/avatar/process
profile/update
```

Reasons:

## `profile/tos`

TOS/privacy acceptance is not a Profile-domain responsibility.

It belongs to a separate legal/account-consent concern.

Legal documents are not currently ready, so defer this API rather than introducing a premature domain/API design.

## Avatar Upload

Avatar upload and processing currently depend on:

* client-side crop/resize
* multipart file upload
* Supabase Storage
* Supabase Edge Function processing

This is infrastructure-specific and does not fit the current Spring storage boundary.

Keep the existing avatar upload/processing pipeline temporarily.

Spring may continue storing the resulting final avatar reference as part of Profile state.

## Dead Code

Do not restore or migrate:

```text
profile/avatar/process
profile/update
```

These were already identified as dead/superseded legacy routes.

---

# Required Reading

Before implementation, read:

1. `goofed/goofed/docs/SPRING-MIGRATION.md`
2. `goofed/goofed/API/OPENAPI.yaml`
3. all relevant files under `docs/domain`
4. `legacy/supabase/schema.sql`
5. legacy implementations for:

    * `me/personal-feed`
    * `me/profile-card`
    * `profile/by-handle`
    * `profile/handle/check`
    * `profile/nickname`
6. relevant PostgreSQL RPC/function definitions
7. frontend call sites for these APIs
8. existing Spring Play controllers/services/repositories/tests
9. existing security and `AppJwtPrincipal` conventions
10. existing Profile entity/repository/service code

Inspect frontend wrappers where they affect request semantics, but do not reproduce purely client-side error handling or URL encoding logic in Spring.

---

# Authentication and User Identity

For authenticated current-user operations, use only:

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

The external identity-provider boundary ends at authentication/account mapping.

Business logic must operate on the internal application user ID.

---

# Part 1: Personal Feed

## Legacy

```text
me/personal-feed
```

## Target

```text
GET /api/tap-cards/personal-feed
```

## Domain

Play.

The endpoint returns Play Cards associated with the currently authenticated user's personal activity.

The frontend displays the feed below Profile information on `/me`, but that presentation does not change ownership.

Conceptually:

```text
AppJwtPrincipal.userId
        ↓
Play Cards created by current user
        ↓
Personal Feed
```

---

# Personal Feed Controller

Place this endpoint in:

```text
TapCardController
```

because the returned resource is a Tap Card read model.

Do not create:

```text
MeController
```

or move this behavior into Profile/User merely because of the legacy URL.

---

# Personal Feed Analysis

Determine from the legacy route/RPC:

* exact owner/user filter
* card lifecycle/state filters
* ordering
* tie-breaking
* pagination
* page/cursor size
* included PlayTemplate data
* included Challenge data
* included Profile projection data
* visibility rules
* image/storage fields
* empty-result behavior

Preserve important ordering and pagination semantics.

Do not accidentally replace an ordered RPC with an unordered repository query.

---

# Personal Feed Response

Use an explicit read DTO/projection.

If the result includes data from multiple domains, preserve ownership conceptually.

For example:

```text
PersonalFeedItem
├── Play Card data        → Play
├── Template data         → Play
└── creator Profile data  → Profile projection
```

Cross-domain composition in a read model is acceptable.

Do not move Profile state into the Play entity model.

---

# Personal Feed Tests

Cover meaningful cases:

* authenticated user receives only their own relevant Play Cards
* another user's private cards are not returned
* identity comes from `AppJwtPrincipal.userId`
* no client user ID is accepted
* expected ordering
* pagination behavior
* empty feed
* relevant state/visibility filtering
* correct response shape
* unauthenticated access behavior

---

# Part 2: Profile Domain

Create/use:

```text
ProfileController
```

with base resource:

```text
/api/profiles
```

Profile represents how an application user is presented.

It may include:

* nickname
* introduction/bio
* avatar reference
* handle
* other public presentation fields

Profile does not own:

* authentication
* OAuth/OIDC identity
* personal Play feed
* Play Cards
* payment
* legal acceptance

---

# Consolidated Current Profile Update

The legacy frontend currently has multiple ways to update Profile data.

Examples include:

```text
me/profile-card
profile/nickname
```

Different frontend buttons or modals may update different subsets of Profile fields.

Do not preserve one backend endpoint per frontend editing control.

Instead, consolidate these mutations into:

```text
PATCH /api/profiles/current
```

The frontend should provide only the fields relevant to the current edit action.

Examples:

Nickname-only update:

```json
{
  "nickname": "new-name"
}
```

Introduction-only update:

```json
{
  "introduction": "Updated introduction"
}
```

Profile-card update:

```json
{
  "introduction": "Updated introduction",
  "avatarPath": "..."
}
```

The exact DTO field names must be derived from the current schema/API conventions.

---

# PATCH Semantics

This is a partial update.

Distinguish carefully between:

```text
field omitted
→ leave existing value unchanged

field supplied
→ validate and update that field
```

For optional/clearable fields, determine whether:

```text
null
empty string
omission
```

have different meanings.

Do not accidentally implement PATCH as full replacement.

Do not require fields unrelated to the current edit operation.

---

# Profile Update Identity

For:

```text
PATCH /api/profiles/current
```

resolve the target user exclusively through:

```text
AppJwtPrincipal.userId
```

Do not accept `{userId}` in:

* path
* request body
* query string

for the ordinary current-user update flow.

---

# Nickname Behavior

Preserve the meaningful legacy behavior from `profile/nickname`.

Review:

* trim behavior
* length: 2–30
* case-insensitive no-op behavior
* uniqueness check
* `is_nickname_taken` RPC semantics
* conflict behavior

If the new nickname equals the current nickname case-insensitively, preserve the legacy no-op behavior where appropriate.

A nickname collision should map cleanly to:

```text
409 Conflict
```

Do not expose raw RPC/database errors.

---

# Profile Field Validation

Use DTO validation and `@Valid`.

For relevant strings, consider:

* null
* blank
* whitespace-only
* min/max length
* normalization
* allowed characters
* patch omission semantics

Do not add constraints unsupported by the current domain/schema.

For Profile-specific business rules that require database lookup, such as nickname uniqueness, enforce them in the service/domain layer rather than Bean Validation.

---

# Public Profile Lookup

## Legacy

```text
profile/by-handle?handle=...
```

## Target

```text
GET /api/profiles/by-handle/{handle}
```

This endpoint is public.

Do not require `AppJwtPrincipal`.

Use the handle as a lookup key for a public Profile projection.

Preserve:

* trimming/normalization
* not-found behavior
* public visibility rules
* response projection

Expected semantics:

```text
200 → profile found
404 → profile not found
400 → malformed handle where applicable
```

---

# Handle Availability

## Legacy

```text
profile/handle/check
```

## Target

```text
GET /api/profiles/handles/{handle}/availability
```

Return:

```json
{
  "available": true
}
```

or equivalent project-consistent DTO.

Normalize according to current behavior:

```text
trim
→ lowercase
```

Validate against:

```text
^[a-z0-9_]{3,20}$
```

unless the current domain/schema documentation defines a different rule.

Invalid handles should return:

```text
400 Bad Request
```

---

# Handle Availability Rate Limit

The legacy endpoint uses IP-based rate limiting.

Inspect the current Spring infrastructure before deciding how to reproduce this.

Do not silently drop rate limiting.

If equivalent rate-limit infrastructure is not yet implemented in Spring:

* document the missing behavior
* do not introduce unrelated large infrastructure solely for this endpoint without justification
* mark the security/operational difference clearly in the migration report

The frontend wrapper's URL encoding, `cache: no-store`, and client-side thrown error are not backend business rules.

---

# Avatar Reference in Profile PATCH

The avatar upload pipeline itself is deferred.

However, if the existing `me/profile-card` behavior stores the final avatar reference after upload, `PATCH /api/profiles/current` may continue accepting the resulting avatar reference according to the current contract.

Conceptually:

```text
existing external upload/process flow
        ↓
publicUrl / storedPath
        ↓
PATCH /api/profiles/current
        ↓
Profile stores final reference
```

Do not accept or process raw image bytes in this migration.

Do not introduce S3 or new storage infrastructure.

---

# ProfileController

The resulting controller should conceptually own:

```text
PATCH /api/profiles/current

GET /api/profiles/by-handle/{handle}

GET /api/profiles/handles/{handle}/availability
```

Keep the controller thin.

Responsibilities:

1. receive typed HTTP input
2. obtain `AppJwtPrincipal` where needed
3. trigger validation
4. delegate to Profile services
5. return response DTOs

Do not place Play/Card query behavior inside `ProfileController`.

---

# Service Layer

Profile service responsibilities may include:

* retrieve Profile by app user ID
* update selected Profile fields
* nickname normalization/uniqueness checking
* retrieve public Profile by handle
* check handle availability

Do not create separate services solely because legacy routes were separate.

Split only where responsibilities become meaningfully distinct.

---

# Profile Entity Behavior

Do not automatically use unrestricted setters for meaningful Profile invariants.

If mutation has domain meaning, use intention-revealing methods where useful.

Examples:

```text
changeNickname(...)
changeIntroduction(...)
changeAvatar(...)
```

But do not create ceremonial methods where simple assignment has no invariant.

The entity should protect its own valid state; the service should orchestrate database/external operations.

---

# Persistence

Review the schema and legacy RPCs carefully.

Preserve:

* unique nickname/handle constraints
* nullability
* normalized fields
* profile ownership/reference to `app_users.id`
* defaults
* public projection behavior

Do not rely only on a "check then update" service pattern for uniqueness if the database can enforce the invariant as well.

Handle database uniqueness races cleanly.

---

# Error Semantics

Follow the existing `@RestControllerAdvice` conventions.

Where applicable:

```text
400 → invalid request
401 → unauthenticated
403 → forbidden
404 → profile not found
409 → nickname/handle conflict
429 → rate limited
500 → unexpected server/database failure
```

Do not expose raw Supabase RPC or database messages.

---

# OpenAPI

Update/verify the current Spring API contract for:

```text
GET   /api/tap-cards/personal-feed

PATCH /api/profiles/current
GET   /api/profiles/by-handle/{handle}
GET   /api/profiles/handles/{handle}/availability
```

Document:

* authentication requirements
* query/path parameters
* PATCH request semantics
* validation
* response DTOs
* pagination where applicable
* status codes

Do not document deferred TOS/avatar-upload endpoints as migrated Spring APIs.

---

# Migration Mapping

Before implementation, produce a concise mapping.

## Play

```text
Legacy:
me/personal-feed

Spring:
GET /api/tap-cards/personal-feed

Domain:
Play

Controller:
TapCardController
```

## Profile Update

```text
Legacy:
me/profile-card
profile/nickname

Spring:
PATCH /api/profiles/current

Domain:
Profile

Controller:
ProfileController
```

## Public Profile

```text
Legacy:
profile/by-handle

Spring:
GET /api/profiles/by-handle/{handle}
```

## Handle Availability

```text
Legacy:
profile/handle/check

Spring:
GET /api/profiles/handles/{handle}/availability
```

## Deferred

```text
profile/tos
→ deferred: separate domain/legal docs not ready

profile/avatar/upload
→ deferred: storage/image-processing infrastructure

profile/avatar/process
→ dead code / do not migrate

profile/update
→ dead code / superseded / do not migrate
```

---

# Tests

## Personal Feed

Test:

* current-user scoping
* ordering
* pagination
* state/visibility filtering
* empty feed
* unauthenticated access
* response projection

## Profile PATCH

Test:

* nickname-only update
* introduction-only update
* avatar-reference-only update where supported
* multiple-field update
* omitted fields remain unchanged
* nickname no-op behavior
* nickname conflict
* validation failures
* current user resolved from `AppJwtPrincipal.userId`
* request cannot update another user's Profile
* unauthenticated request

## Public Profile

Test:

* existing handle
* nonexistent handle
* malformed handle
* anonymous access
* response projection

## Handle Availability

Test:

* available handle
* taken handle
* invalid regex
* normalization behavior
* anonymous access
* rate-limit behavior if implemented

---

# Migration Report

After implementation, document:

## Domain Separation

Explain that legacy `/me` and `profile/**` routes were organized primarily around frontend usage.

The Spring migration separates them into:

```text
Play
→ personal feed

Profile
→ Profile read/update behavior
```

## Consolidated Profile Mutation

Document that:

```text
me/profile-card
+
profile/nickname
```

were consolidated into:

```text
PATCH /api/profiles/current
```

because they mutate the same Profile resource.

Frontend controls may continue editing different subsets of Profile data by sending only the relevant PATCH fields.

## Deferred APIs

Document:

* `profile/tos`
* `profile/avatar/upload`

and reasons for deferral.

## Dead Code

Document:

* `profile/avatar/process`
* `profile/update`

as intentionally not migrated.

## Behavioral Differences

List:

* new REST routes
* combined Profile mutation contract
* normalized error behavior
* rate-limit differences if any
* any intentional response-contract changes

---

# Important Constraints

Do not:

* create a `Me` domain
* create `MeController`
* put personal feed into Profile
* put Profile mutations into Play
* accept client-supplied current-user identity
* use OIDC `sub` for business identity
* migrate TOS acceptance
* migrate avatar upload/processing
* restore dead routes
* create one endpoint for every frontend edit button
* make PATCH behave like PUT
* expose raw database/RPC errors
* refactor unrelated frontend code
* introduce new storage infrastructure

Use the domain boundaries:

```text
User
→ who the participant is

Profile
→ how the participant is presented

Play
→ what the participant does
```

Frontend pages may compose these domains freely without requiring the backend to merge their responsibilities.
