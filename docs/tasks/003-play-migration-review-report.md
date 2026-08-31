# Play Migration Review Report

Review date: 2026-08-31

## 1. Review Scope

The review followed `docs/tasks/002-play-migration-review.md` and inspected the actual Spring implementation rather than assuming the migration task was followed.

Migration and domain sources inspected:

- `docs/tasks/001-play-related-apis-migration.md`
- `docs/tasks/002-play-migration-review.md`
- `goofed/goofed/docs/SPRING-MIGRATION.md`
- `goofed/goofed/API/OPENAPI.yaml`
- `docs/domain/core-play.md`
- `docs/domain/core-challenge-user-journey.md`
- `docs/domain/generic-payment.md`
- `docs/domain/support-user.md`
- `docs/architecture/decisions/001-use-ddd-oriented-modular-monolith.md`
- `docs/architecture/decisions/002-use-oidc-and-app-user-id.md`
- `docs/architecture/decisions/003-keep-supabase-storage-during-migration.md`
- `docs/architecture/decisions/004-use-s3-presigned-uploads.md`
- `legacy/supabase/schema.sql`

Legacy routes and helpers inspected:

- `goofed/goofed/src/app/api/playTemplate/create/route.ts`
- `goofed/goofed/src/app/api/playTemplate/create/challenge/route.ts`
- `goofed/goofed/src/app/api/playTemplate/create-and-play/route.ts`
- `goofed/goofed/src/app/api/playTemplate/create-and-play/challenge/route.ts`
- `goofed/goofed/src/app/api/playTemplate/catalog/route.ts`
- `goofed/goofed/src/app/api/playTemplate/_lib/mutations.ts`
- `goofed/goofed/src/app/api/playInstance/challenge/create/route.ts`
- `goofed/goofed/src/app/api/playInstance/_lib/rpc.ts`
- `goofed/goofed/src/lib/validators.ts`

Spring controllers inspected:

- `src/main/java/games/tapped/play/controller/TemplateController.java`
- `src/main/java/games/tapped/play/controller/InstanceController.java`
- `src/main/java/games/tapped/user/controller/AuthTestController.java`

Request DTOs inspected:

- `CreateTemplateRequest`
- `UpdateTemplateRequest`
- `TemplateModesRequest`
- `TemplateChallengeModeRequest`
- `TemplateScheduleRequest`
- `CreateInstanceRequest`
- `CreateTapCardRequest`
- `ChallengerDecisionRequest`
- `CoverCardRequest`
- `RefDecisionRequest`

Response DTOs inspected:

- `TemplateMutationResponse`
- `TemplateResponse`
- `TemplateCatalogResponse`
- `TemplatePresetResponse`
- `CreateInstanceResponse`
- `PlayInstanceSummaryResponse`
- `PlayInstanceSummary`
- `PlayInstanceTemplateSummary`
- `ToggleTapResponse`
- `TapResponse`
- `TapCardResponse`
- `ChallengeFinalCallResponse`
- `RefDecisionSessionResponse`
- `RefDecisionSubmitResponse`
- `RefNotificationResponse`
- `CoverCardResponse`

Services inspected:

- `ActivityTemplateService`
- `ActivityInstanceService`
- `AppUserService`
- `JwtTokenService`
- `CustomOidcUserService`
- `JwtAuthenticationConverter`

Entities inspected:

- `ActivityTemplate`
- `ActivityTemplateChallengeConfig`
- `PublicActivityTemplate`
- `ActivityInstance`
- `ActivityInstanceChallengeConfig`
- `ActivityTap`
- `TapCard`
- `ActivityInstanceChallengeEvent`
- `ActivityInstanceChallengeMailToken`
- `ActivityInstanceChallengeDispute`
- `AppUser`

Repositories inspected:

- `ActivityTemplateRepository`
- `ActivityTemplateChallengeConfigRepository`
- `PublicActivityTemplateRepository`
- `ActivityInstanceRepository`
- `ActivityInstanceChallengeConfigRepository`
- `ActivityTapRepository`
- `TapCardRepository`
- `ActivityInstanceChallengeEventRepository`
- `ActivityInstanceChallengeMailTokenRepository`
- `ActivityInstanceChallengeDisputeRepository`
- `AppUserRepository`

Exceptions and error handling inspected:

- `GlobalExceptionHandler`
- `DomainConflictException`
- `UnprocessableOperationException`
- `jakarta.persistence.EntityNotFoundException`
- `org.springframework.security.access.AccessDeniedException`
- `ResponseStatusException` handling

Security and principal handling inspected:

- `SecurityConfig`
- `AppJwtPrincipal`
- `JwtAuthenticationConverter`
- `JwtTokenService`
- `CustomOidcUserService`
- `AppPrincipal`

Tests inspected:

- `TemplateControllerTest`
- `InstanceControllerTest`
- `ActivityTemplateServiceTest`
- `ActivityInstanceServiceTest`
- `ActivityTemplateRepositoryTest`
- `AuthTestControllerTest`
- `BackendApplicationTests`

Schema and PostgreSQL functions inspected:

- `src/main/resources/db/migration/V1__create_app_users.sql`
- `src/main/resources/db/migration/V2__create_activity_templates.sql`
- `src/main/resources/db/migration/V3__create_activity_instances.sql`
- `legacy/supabase/schema.sql`
- `app_user_id`
- `can_select_activity_template`
- `create_challenge_template`
- `create_challenge_template_and_instance`
- `create_challenge_instance`
- `toggle_activity_tap`
- `toggle_challenge_tap`
- `create_tap_card_shell`
- `create_challenge_tap_card_shell`
- `attach_tap_card_photo`
- `attach_challenge_tap_card_photo`
- `get_final_call_by_instance_id`
- `get_final_call_by_token`
- `finalize_ref_decision`
- `acknowledge_challenge_success`
- `finalize_challenge_fail_no_payment`
- `finalize_challenge_chicken`
- `finalize_challenge_dispute`

## 2. Current Flow Reconstruction

### PlayTemplate Creation

```text
HTTP endpoint
POST /api/templates

-> request DTO validation
TemplateController#create receives @Valid @RequestBody CreateTemplateRequest.
CreateTemplateRequest validates title as @NotBlank and max 100 chars, rules as max 4000 chars, lifecycleState as @NotNull, nested modes and schedule as @Valid.
Java UUID and enum fields handle malformed UUID and enum values during JSON binding.

-> AppJwtPrincipal
TemplateController#create receives @AuthenticationPrincipal AppJwtPrincipal principal.
The controller passes only principal.userId() to the service.

-> controller
TemplateController#create calls ActivityTemplateService#save(principal.userId(), request).
It returns HTTP 201 with TemplateMutationResponse.saved(result).

-> service
ActivityTemplateService#save is @Transactional.
It chooses request.templateId() or a random UUID.
It resolves default fields through resolveCreateFields.
It locks an existing template with ActivityTemplateRepository#findByIdForUpdate when the ID already exists.
If the template exists, it checks owner and deletion state, then calls ActivityTemplate#replaceContent.
If the template does not exist, it calls ActivityTemplate#createRoot.
It saves the template, synchronizes challenge-mode configuration, then synchronizes the public catalog projection.

-> entity/domain behavior
ActivityTemplate#createRoot initializes a root template with originId = id, no parent, status ACTIVE, modeKind CHALLENGE, proofKind ANY, playContext ONLINE, relationshipMode SOLO, participant range 1..1, owner fields, timestamps, title/rules/photoPath/visibility/lifecycle.
ActivityTemplate#replaceContent updates content and resets generic play metadata to the same Challenge defaults.
ActivityTemplate#isCatalogVisible returns true only when the template is PUBLIC, PUBLISHED, publishedAt is present, and deletedAt is null.

-> repository/database writes
activity_templates is inserted or updated.
activity_template_challenge_config is upserted through ActivityTemplateChallengeConfigRepository.
public_activity_templates is inserted/updated or deleted through PublicActivityTemplateRepository based on isCatalogVisible.
Database definitions are in V2 and V3.

-> response
TemplateMutationResponse contains ok, templateId, photoPath, lifecycleState, and publishedAt.
```

### PlayInstance Creation

```text
HTTP endpoint
POST /api/instances

-> request DTO validation
InstanceController#create receives @Valid @RequestBody CreateInstanceRequest.
CreateInstanceRequest requires activityTemplateId, refEmail, amountCents, and idempotencyKey.
It validates refEmail as @NotBlank and @Email.
It validates amountCents as one of 0, 500, 2500, 5000, or 10000 using @AssertTrue.
Java UUID and enum fields handle malformed UUID and enum values during JSON binding.

-> AppJwtPrincipal
InstanceController#create receives @AuthenticationPrincipal AppJwtPrincipal principal.
The controller passes only principal.userId() to ActivityInstanceService#create.

-> controller
InstanceController#create calls ActivityInstanceService#create(principal.userId(), request).
It returns HTTP 201 with CreateInstanceResponse.

-> service
ActivityInstanceService#create is @Transactional.
It loads the template using ActivityTemplateRepository#findById.
It calls assertTemplatePlayableBy.
It checks idempotency through ActivityInstanceRepository#findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull.
It computes the next sequence number with ActivityInstanceRepository#findMaxSequenceNo.
It creates and saves an ActivityInstance.
It creates and saves ActivityInstanceChallengeConfig.

-> entity/domain behavior
ActivityInstance#createChallenge initializes a CHALLENGE-mode ACTIVE instance with startedAt = now, optional endAt from request.schedule.endAt, playContext and relationshipMode from request defaults, sequenceNo, idempotencyKey, owner fields, and zero tap counters.
ActivityInstanceChallengeConfig#create initializes refEmail, failCardFeeMinor, and refState PENDING.

-> repository/database writes
activity_instances is inserted.
activity_instance_challenge_config is inserted.
The unique index on (created_by, idempotency_key) is the database backstop for duplicate idempotency keys.
The unique index on (activity_template_id, created_by, sequence_no) is the database backstop for duplicate sequence allocation.

-> response
CreateInstanceResponse contains playInstanceId, sequenceNo, and activityTemplateId.
```

### Challenge-Specific Initialization

Challenge initialization is not separate from generic instance creation in the current Spring implementation.

For template creation:

- `ActivityTemplate#createRoot` always sets `modeKind` to `CHALLENGE`.
- `ActivityTemplateService#syncChallengeConfig` is always called from `save`.
- `activity_template_challenge_config` is created even if the request does not include a challenge mode object.

For instance creation:

- `CreateInstanceRequest` requires Challenge fields: `refEmail` and `amountCents`.
- `ActivityInstanceService#create` always calls `ActivityInstance#createChallenge`.
- `ActivityInstanceService#create` always writes `activity_instance_challenge_config`.

## 3. Legacy-to-Spring Mapping

```text
Legacy:
POST /api/playTemplate/create
PostgreSQL function create_challenge_template

Responsibilities:
- Authenticate current app user through Supabase session/app_user_id.
- Validate nonblank title and required lifecycle state.
- Accept optional image path uploaded before the request.
- Upsert activity_templates when the requester owns an existing template ID.
- Store Challenge template config.
- Maintain public_activity_templates projection for PUBLIC + PUBLISHED templates.
- Return template_id, photo_path, and lifecycle_state.

Spring:
Controller:
- TemplateController#create handles POST /api/templates.
- It receives AppJwtPrincipal and delegates to ActivityTemplateService#save.

DTO validation:
- CreateTemplateRequest validates title, rules length, lifecycleState, Java UUIDs, enums, and nested objects.

Service/domain:
- ActivityTemplateService#save owns upsert, owner check, defaults, challenge-config sync, and catalog projection sync.
- ActivityTemplate#createRoot and replaceContent initialize and mutate template state.

Repository/database:
- ActivityTemplateRepository persists activity_templates.
- ActivityTemplateChallengeConfigRepository persists challenge config.
- PublicActivityTemplateRepository maintains catalog projection.
- V2 and V3 define tables, enums, foreign keys, and indexes.

Preserved behavior:
- Authenticated app user owns created templates.
- Nonblank title and rules max length are enforced.
- Image is represented as a storage reference rather than bytes.
- Challenge config and public catalog projection are persisted transactionally with the template.
- Existing owned template IDs can be updated.

Changed behavior:
- Route is REST-style /api/templates rather than /api/playTemplate/create.
- HTTP status is 201 instead of legacy 200.
- Template creation is Challenge-shaped by default even though the route is generic.
- Template request has no idempotency key.
- Template challenge config does not store refEmail because the migrated schema has no template-level ref_email column.
```

```text
Legacy:
POST /api/playTemplate/create/challenge
PostgreSQL function create_challenge_template

Responsibilities:
- Create a published Challenge template.
- Force or default Challenge-specific values such as proof_kind ANY, play_context ONLINE, relationship_mode SOLO, participant range 1..1, currency USD, fail fee default 0, and ref_required.
- Store template challenge config.

Spring:
Controller:
- TemplateController#create uses the same POST /api/templates endpoint.

DTO validation:
- CreateTemplateRequest validates lifecycleState but does not force PUBLISHED for a Challenge payload.
- TemplateChallengeModeRequest validates email format and nonnegative fee when present.

Service/domain:
- ActivityTemplateService#save applies Challenge defaults through ActivityTemplate#createRoot/replaceContent and syncChallengeConfig.

Repository/database:
- Same activity_templates, activity_template_challenge_config, and public_activity_templates writes as generic template creation.

Preserved behavior:
- Challenge defaults are applied.
- Challenge config can be created with currency, fail fee, and refRequired.

Changed behavior:
- There is no separate Challenge-template endpoint.
- Challenge template creation can produce DRAFT or ARCHIVED lifecycle states through the generic DTO.
- The domain route is generic, but implementation internals are still Challenge-specific.
```

```text
Legacy:
POST /api/playTemplate/create-and-play
POST /api/playTemplate/create-and-play/challenge
PostgreSQL function create_challenge_template_and_instance

Responsibilities:
- In one database transaction, create or update a published template.
- Create an activity instance for the same authenticated user.
- Create activity_instance_challenge_config.
- Require a nonblank ref email for the Challenge flow.
- Return both template_id and play_instance_id.

Spring:
Controller:
- No combined create-and-play endpoint was found.
- The closest behavior is a client-side sequence of POST /api/templates followed by POST /api/instances.

DTO validation:
- CreateTemplateRequest validates template input.
- CreateInstanceRequest validates instance Challenge input.

Service/domain:
- ActivityTemplateService#save and ActivityInstanceService#create run in separate service transactions.

Repository/database:
- Template and instance rows are written by separate operations.

Preserved behavior:
- The individual template and instance writes exist.
- Challenge instance config is written when POST /api/instances succeeds.

Changed behavior:
- The legacy atomic create-template-and-start-instance operation is not represented.
- A client/network/service failure between the two Spring requests can leave a template without the intended instance.
```

```text
Legacy:
POST /api/playInstance/challenge/create
PostgreSQL function create_challenge_instance

Responsibilities:
- Authenticate current app user.
- Validate template ID, ref email, nonnegative fail fee, play context, relationship mode, and idempotency key.
- Allow only PUBLIC, PUBLISHED, ACTIVE, not-deleted templates.
- Return an existing instance for the same user and idempotency key.
- Allocate a per-template, per-user sequence number.
- Insert activity_instances and activity_instance_challenge_config atomically.

Spring:
Controller:
- InstanceController#create handles POST /api/instances.

DTO validation:
- CreateInstanceRequest validates activityTemplateId, refEmail, amountCents, idempotencyKey, playContext, relationshipMode, and schedule.

Service/domain:
- ActivityInstanceService#create loads the template, checks playability, applies idempotency, allocates sequence number, and creates Challenge state.

Repository/database:
- ActivityInstanceRepository persists activity_instances.
- ActivityInstanceChallengeConfigRepository persists activity_instance_challenge_config.

Preserved behavior:
- Authenticated principal owns the instance.
- Ref email is normalized to lowercase.
- Idempotency fast path is preserved.
- Instance and Challenge config are written in one transaction.

Changed behavior:
- Endpoint is POST /api/instances rather than /api/playInstance/challenge/create.
- Spring allows the owner to instantiate their own non-public template if it is otherwise active and published. Legacy create_challenge_instance selected only PUBLIC templates.
- Amount validation follows the OpenAPI enum values rather than the wider legacy Zod custom amount range.
```

```text
Legacy:
GET /api/playTemplate/catalog
public_activity_templates projection

Responsibilities:
- Return public preset/catalog templates.
- Use the public projection maintained during template creation/update/delete.

Spring:
Controller:
- TemplateController#catalog handles GET /api/templates.

DTO validation:
- No request DTO.

Service/domain:
- ActivityTemplateService#catalog reads PublicActivityTemplate rows and maps fallback image references.

Repository/database:
- PublicActivityTemplateRepository reads public_activity_templates ordered by createdAt descending.

Preserved behavior:
- Public catalog uses projection rows, not an unrestricted scan of all templates.

Changed behavior:
- Endpoint path changed to /api/templates.
- Response shape is Spring-specific TemplateCatalogResponse rather than the legacy presets envelope exactly.
```

```text
Legacy:
can_select_activity_template

Responsibilities:
- Permit template select when not deleted and either owned by current app user or PUBLIC + PUBLISHED.

Spring:
Controller:
- TemplateController#get handles GET /api/templates/{id} and permits anonymous access through SecurityConfig.

DTO validation:
- Java UUID path binding validates malformed IDs.

Service/domain:
- ActivityTemplateService#get checks deleted and denies PRIVATE to non-owner.

Repository/database:
- ActivityTemplateRepository#findById reads the template.

Preserved behavior:
- Deleted templates are hidden.
- Private templates are owner-only.

Changed behavior:
- Public DRAFT or ARCHIVED templates can be returned by ID to anonymous/non-owner users because lifecycle and status are not checked in get().
```

```text
Legacy:
toggle_activity_tap / toggle_challenge_tap

Responsibilities:
- Owner-only tap toggling.
- Challenge state must be active and not already decided/finalized.
- Same-day tap toggles open/cancel/reopen state.
- New day creates a new tap.

Spring:
Controller:
- InstanceController#toggleTap handles POST /api/instances/{id}/taps.

DTO validation:
- Java UUID path binding validates malformed instance IDs.

Service/domain:
- ActivityInstanceService#toggleTap checks owner, locks instance/config/latest tap, enforces Challenge tappability, and opens/cancels/reopens tap.

Repository/database:
- ActivityTapRepository uses a native FOR UPDATE latest-tap query.
- ActivityInstance is updated with tap counters.

Preserved behavior:
- Owner-only access.
- Challenge state gates tap operations.
- Existing latest tap can be canceled or reopened.

Changed behavior:
- Spring uses an application tap-day calculation in America/New_York; the inspected SQL used database date casting. This appears intentional from prior domain behavior, but should remain documented.
```

```text
Legacy:
create_tap_card_shell / create_challenge_tap_card_shell / attach_tap_card_photo / attach_challenge_tap_card_photo

Responsibilities:
- Owner-only card creation/attachment.
- Tap must belong to instance and not be canceled.
- Challenge must be tappable.
- Store note/photo path.
- Finalize the tap when a card is created or photo is attached.

Spring:
Controller:
- InstanceController#createTapCard handles POST /api/instances/{id}/taps/{tapId}/cards.

DTO validation:
- CreateTapCardRequest validates note max length and optional photoPath/removePhoto.

Service/domain:
- ActivityInstanceService#createTapCard checks owner, challenge state, tap ownership, canceled state, allocates card sequence, saves TapCard, and finalizes ActivityTap.

Repository/database:
- TapCardRepository inserts tap_cards.
- ActivityTapRepository updates activity_taps.

Preserved behavior:
- Owner and Challenge state checks are present.
- Card creation and tap finalization are atomic.

Changed behavior:
- Spring combines shell creation and attachment into one request object rather than exposing both legacy phases exactly.
```

```text
Legacy:
finalize_ref_decision / get_final_call_by_token / get_final_call_by_instance_id

Responsibilities:
- Public token-based ref session lookup.
- Single-use token validation.
- Expiry and invalidation checks.
- Persist ref verdict, invalidate sibling tokens, write event.
- Owner can read final-call state by instance ID.

Spring:
Controller:
- InstanceController#getRefDecisionSession handles GET /api/instances/ref-decisions/session.
- InstanceController#submitRefDecision handles POST /api/instances/ref-decisions.
- InstanceController#getFinalCall handles GET /api/instances/{id}/challenge/final-call.

DTO validation:
- RefDecisionRequest validates token as @NotBlank and verdict as @NotNull enum.

Service/domain:
- ActivityInstanceService#getRefDecisionSession reads token and projection data.
- ActivityInstanceService#submitRefDecision locks token, checks state, updates config, marks token used, invalidates siblings, and writes an event.
- ActivityInstanceService#getFinalCall checks owner and builds final-call response.

Repository/database:
- ActivityInstanceChallengeMailTokenRepository handles token lookup, lock, and sibling invalidation.
- ActivityInstanceChallengeConfigRepository locks config.
- ActivityInstanceChallengeEventRepository writes decision event.

Preserved behavior:
- Token action, expiry, used, invalidated, and already-decided checks are present.
- Ref verdict and event are written in the same transaction.

Changed behavior:
- Legacy had same-origin CSRF and IP rate limiting around public token routes. No equivalent control was found in Spring.
```

```text
Legacy:
notify/payment/final challenger decision routes

Responsibilities:
- Notify ref by sending email through an edge function.
- Create payment checkout through an edge function.
- Let challenger acknowledge success, finalize no-payment fail, chicken out, or dispute after ref decision.

Spring:
Controller:
- InstanceController#prepareRefNotification handles POST /api/instances/{id}/challenge/notifications.
- InstanceController#createPaymentCheckout handles POST /api/instances/{id}/challenge/payment/checkout and returns 501.
- InstanceController#submitChallengerDecision handles POST /api/instances/{id}/challenge/challenger-decision.

DTO validation:
- ChallengerDecisionRequest validates enum and optional text lengths.
- CoverCardRequest validates coverCardId for separate cover-card selection.

Service/domain:
- ActivityInstanceService#prepareRefNotification creates a token and records notification metadata.
- ActivityInstanceService#submitChallengerDecision handles success, fail without payment, chicken, and dispute transitions.

Repository/database:
- Mail token, config, event, dispute, instance, and cover-card rows are written depending on the action.

Preserved behavior:
- Owner checks and major Challenge finalization states are implemented.
- Payment checkout is explicitly unsupported rather than silently succeeding.

Changed behavior:
- Notification preparation does not actually send an email and the controller does not return the created token/link.
- Legacy chicken finalization updated profile chicken_until; no equivalent profile-side effect exists in the reviewed Spring code.
```

## 4. Findings

### Critical

None.

### High

```text
ID
H-001

Severity
High

Location
src/main/java/games/tapped/play/service/ActivityTemplateService.java#get
src/main/java/games/tapped/play/controller/TemplateController.java#get
src/main/java/games/tapped/config/SecurityConfig.java
legacy/supabase/schema.sql can_select_activity_template

Observed behavior
GET /api/templates/{id} is public. ActivityTemplateService#get rejects deleted templates and rejects PRIVATE templates for non-owners, but it does not reject public DRAFT, ARCHIVED, or inactive templates for anonymous/non-owner callers.

Expected behavior
For anonymous or non-owner reads, the template should satisfy the public-selection rule supported by the legacy can_select_activity_template function and the catalog semantics: not deleted, visibility PUBLIC, lifecycle PUBLISHED, and active status where the current schema supports status. Owners can still read their own drafts.

Why it matters
The catalog projection intentionally hides non-published templates, but direct item lookup can expose unfinished or archived template content by ID. This is a business-visibility and authorization problem, not a cosmetic route concern.

Recommended action
Update ActivityTemplateService#get so owner reads and public reads are separate. For non-owner or anonymous reads, require visibility PUBLIC, lifecycle PUBLISHED, status ACTIVE, and deletedAt null. Add tests for anonymous public draft, anonymous public published, owner draft, and non-owner private reads.
```

```text
ID
H-002

Severity
High

Location
src/main/java/games/tapped/play/controller/InstanceController.java#prepareRefNotification
src/main/java/games/tapped/play/service/ActivityInstanceService.java#prepareRefNotification
goofed/goofed/API/OPENAPI.yaml POST /api/playInstance/challenge/notify
goofed/goofed/src/app/api/playInstance/challenge/notify/route.ts

Observed behavior
POST /api/instances/{id}/challenge/notifications returns success and WAITING_FOR_REF_DECISION. The service creates a mail token, updates ref-mail metadata, and writes an event. The controller discards the token, and no email, outbox message, or ref-decision link is returned.

Expected behavior
The endpoint should either send or enqueue the ref notification, or the API contract should explicitly expose a shareable ref-decision link/token if email delivery is intentionally outside the migrated scope. Returning success should not imply delivery when no delivery happened.

Why it matters
The Challenge journey depends on the referee receiving a decision link. The current endpoint can make the client believe the referee was notified while no usable notification has left the system.

Recommended action
Integrate with a notification/outbox service or change the endpoint contract to return a ref-decision link/token and document that the client must deliver it. Add abuse controls equivalent to the legacy rate-limited notify route before exposing it publicly.
```

```text
ID
H-003

Severity
High

Location
src/main/java/games/tapped/play/controller/TemplateController.java#create
src/main/java/games/tapped/play/controller/InstanceController.java#create
src/main/java/games/tapped/play/service/ActivityTemplateService.java#save
src/main/java/games/tapped/play/service/ActivityInstanceService.java#create
legacy/supabase/schema.sql create_challenge_template_and_instance

Observed behavior
The legacy create-and-play flow was a single database operation that created or updated a published template, created an instance, and created challenge config atomically. The Spring implementation has separate POST /api/templates and POST /api/instances operations, with separate service transactions and no combined application service.

Expected behavior
If the product still has a "create and play immediately" flow, template creation and instance creation should be atomic or the API should define compensation and client-visible failure semantics. The original migration task required equivalent behavior, not a line-by-line route copy, and the legacy RPC had a meaningful transaction boundary.

Why it matters
A failure after template creation but before instance creation can leave an unintended published template without the user's active Challenge instance. This changes the user workflow and the database effects of the migrated API.

Recommended action
Confirm whether create-and-play remains a required flow. If yes, add a combined endpoint or application service that writes template, template Challenge config, instance, and instance Challenge config in one transaction. If no, document the intentional split and expected cleanup/UX behavior.
```

### Medium

```text
ID
M-001

Severity
Medium

Location
src/main/java/games/tapped/play/model/ActivityTemplate.java#createRoot
src/main/java/games/tapped/play/model/ActivityTemplate.java#replaceContent
src/main/java/games/tapped/play/service/ActivityTemplateService.java#save
src/main/java/games/tapped/play/service/ActivityTemplateService.java#syncChallengeConfig
src/main/java/games/tapped/play/dto/CreateInstanceRequest.java
src/main/java/games/tapped/play/service/ActivityInstanceService.java#create
src/main/java/games/tapped/play/model/ActivityInstance.java#createChallenge

Observed behavior
The public API uses generic resources named templates and instances, but creation is Challenge-shaped throughout. Template creation always sets modeKind CHALLENGE and always syncs Challenge config. Instance creation requires refEmail and amountCents and always creates ActivityInstanceChallengeConfig.

Expected behavior
The domain docs and migration task define PlayTemplate and PlayInstance as generic Play concepts, with Challenge as an MVP mode layered on top. Generic Play creation should not require Challenge concepts unless the specific operation is a Challenge operation.

Why it matters
The current implementation is usable for the Challenge MVP, but future modes would have to pass through Challenge-specific requirements or unwind generic entity defaults. That is a real extensibility problem because it affects request contracts and persisted state, not just naming.

Recommended action
Either make POST /api/instances explicitly Challenge-specific in contract/documentation, or split generic instance creation from Challenge instance creation. For templates, create Challenge config only when the request mode is Challenge or when the endpoint is explicitly a Challenge-template operation.
```

```text
ID
M-002

Severity
Medium

Location
src/main/java/games/tapped/play/controller/TemplateController.java#patch
src/main/java/games/tapped/play/dto/UpdateTemplateRequest.java
src/main/java/games/tapped/play/service/ActivityTemplateService.java#update

Observed behavior
PATCH /api/templates/{id} uses UpdateTemplateRequest, where title is @NotBlank. ActivityTemplateService#update then requires request.title(). A PATCH request that updates only visibility, lifecycleState, photoPath, or modes is rejected.

Expected behavior
PATCH should support partial updates, or the endpoint should not be exposed as PATCH. Full replacement semantics belong on PUT.

Why it matters
This is an API semantic mismatch that will surprise clients and makes the route less useful than its HTTP method promises.

Recommended action
Introduce a separate PatchTemplateRequest with optional fields and service logic that only updates provided fields, or remove the PATCH mapping until partial semantics are implemented.
```

```text
ID
M-003

Severity
Medium

Location
src/main/java/games/tapped/config/SecurityConfig.java
src/main/java/games/tapped/play/controller/InstanceController.java#getRefDecisionSession
src/main/java/games/tapped/play/controller/InstanceController.java#submitRefDecision
src/main/java/games/tapped/play/service/ActivityInstanceService.java#getRefDecisionSession
src/main/java/games/tapped/play/service/ActivityInstanceService.java#submitRefDecision
goofed/goofed/src/app/api/playInstance/challenge/ref-decision/route.ts

Observed behavior
The ref-decision session and submit endpoints are public token endpoints. SecurityConfig disables CSRF for /api/**. No rate limiting or same-origin guard was found around these public mutation/read endpoints.

Expected behavior
A public token endpoint should have an explicit abuse-control decision. The legacy route applied CSRF and IP rate limiting around ref decision handling.

Why it matters
The token is high entropy, so this is not an immediate ownership bypass. Still, the endpoint is public and state-changing. Missing abuse controls increase brute-force, replay-attempt, and spam pressure against the decision flow.

Recommended action
Add rate limiting for token session and submit routes, or document why bearer/API architecture makes the legacy controls unnecessary. Consider a narrow CSRF/same-origin strategy if the ref flow is browser-based.
```

```text
ID
M-004

Severity
Medium

Location
src/test/java/games/tapped/play/controller/TemplateControllerTest.java
src/test/java/games/tapped/play/controller/InstanceControllerTest.java
src/test/java/games/tapped/play/service/ActivityTemplateServiceTest.java
src/test/java/games/tapped/play/service/ActivityInstanceServiceTest.java

Observed behavior
The tests mostly mock service or repository dependencies. They prove controller routing, authentication wiring, some validation, and a few service branches, but they do not prove the main creation flows against the real schema.

Expected behavior
The migrated API should have focused integration tests for database effects and rollback in multi-write operations: template + challenge config + catalog projection, and instance + challenge config.

Why it matters
The highest-risk migration behavior moved from PostgreSQL functions into Spring service transactions. Mock-heavy tests can pass while entity mappings, constraints, rollback behavior, and projection sync are broken.

Recommended action
Add integration tests for successful template creation, catalog projection insertion/deletion, instance creation, idempotency reuse, invalid related template, ownership checks, and rollback when a secondary write fails.
```

```text
ID
M-005

Severity
Medium

Location
src/test/java/games/tapped/play/repository/ActivityTemplateRepositoryTest.java
src/main/resources/db/migration/V1__create_app_users.sql

Observed behavior
ActivityTemplateRepositoryTest inserts an activity_template row with a hardcoded created_by UUID. V1 creates the app_users table but does not seed that UUID. With foreign keys active in a clean database, the test depends on external fixture state.

Expected behavior
Repository tests should create their own app_users fixture row before inserting activity_templates.

Why it matters
Clean local or CI databases can fail for reasons unrelated to the repository behavior being tested.

Recommended action
Insert a valid app_users row in the repository test setup and use its ID as created_by/updated_by.
```

### Low

```text
ID
L-001

Severity
Low

Location
src/main/java/games/tapped/play/dto/TemplateModesRequest.java
goofed/goofed/API/OPENAPI.yaml TemplateMutationPayloadJson.modes

Observed behavior
TemplateModesRequest declares a Map<String, Object> additional field, but no @JsonAnySetter or equivalent capture mechanism was found. OpenAPI allows modes to carry additionalProperties.

Expected behavior
If unknown mode keys are intended to be accepted for forward compatibility, they should be captured or rejected explicitly. Silent discard is the least useful behavior.

Why it matters
Future mode payloads can be accepted by JSON binding but lost before service logic sees them.

Recommended action
Add @JsonAnySetter support if additional modes are intentionally accepted, or configure DTO binding to reject unknown modes until those modes are implemented.
```

```text
ID
L-002

Severity
Low

Location
src/main/java/games/tapped/play/model/ActivityTemplate.java#softDelete
src/main/java/games/tapped/play/service/ActivityTemplateService.java#delete

Observed behavior
ActivityTemplateService is constructed with a Clock, but ActivityTemplate#softDelete uses OffsetDateTime.now(ZoneOffset.UTC) internally.

Expected behavior
Time-based domain changes should consistently receive the service clock or a timestamp from the application service.

Why it matters
This is minor in production but makes time-sensitive behavior harder to test deterministically.

Recommended action
Pass now from ActivityTemplateService#delete into ActivityTemplate#softDelete.
```

## 5. Authentication and Authorization Assessment

Conclusion: the migrated Play business logic correctly uses the application user ID as the business identity. The main authorization gap found is public template lifecycle visibility in `ActivityTemplateService#get`, not misuse of OIDC or email identity.

- `AppJwtPrincipal.userId` is the application user identifier. `AppJwtPrincipal` is a record containing only `UUID userId`.
- It corresponds to `app_users.id`. `CustomOidcUserService` maps Google OIDC user information to `AppUser` through `AppUserService#findOrCreateGoogleUser`, and `JwtTokenService#createAccessToken` sets the application user UUID as the JWT subject.
- Google's OIDC `sub` is not used in Play business logic. It is used at the account-mapping boundary through `CustomOidcUserService` and `AppUserService`.
- Email is not used as application identity in Play business logic. Email appears as app-user account data and as Challenge referee email, which is domain data, not ownership identity.
- Client request data cannot override the authenticated user's identity in the reviewed creation flows. `CreateTemplateRequest` and `CreateInstanceRequest` do not contain a business owner field. Controllers pass `principal.userId()` to services.
- Ownership checks are performed in the service layer. `ActivityTemplateService` checks template ownership for update/delete/private reads. `ActivityInstanceService` checks instance ownership for summary, taps, cards, notifications, final calls, and challenger decisions.

The important exception is public/non-owner template read authorization: `ActivityTemplateService#get` does not enforce lifecycle/status for public reads. See H-001.

## 6. Request Validation Assessment

### CreateTemplateRequest

- Null values: `title` and `lifecycleState` are required. `templateId`, `rules`, `visibility`, `modes`, `schedule`, and `photoPath` are optional.
- Blank/whitespace strings: `title` is `@NotBlank`. Service normalization trims and rejects blank title before persistence.
- String length: `title` max 100, `rules` max 4000.
- Enums: `visibility` and `lifecycleState` use Java enums, so malformed values fail JSON binding.
- UUIDs: `templateId` is `UUID`, so malformed values fail JSON binding.
- Numeric ranges: none directly on this DTO.
- Optional fields: service defaults visibility to PRIVATE and rules to empty string.
- Storage/image references: `photoPath` accepts `photo_path`, `photoPath`, or `photoUrl`, but no path format, bucket, length, or ownership validation was found. The migration docs say storage stays external, but allowed reference shape remains ambiguous.

### UpdateTemplateRequest

- Null values: `title` is required. `rules`, `visibility`, `lifecycleState`, `modes`, and `photoPath` are optional.
- Blank/whitespace strings: `title` is `@NotBlank`.
- String length: `title` max 100, `rules` max 4000.
- Enums: `visibility` and `lifecycleState` use Java enums.
- UUIDs: none in body.
- Numeric ranges: nested Challenge fee uses TemplateChallengeModeRequest validation.
- Optional fields: suitable for PUT replacement, but too strict for PATCH. See M-002.
- Storage/image references: same `photoPath` concern as create.

### TemplateModesRequest

- Null values: whole object is optional.
- Blank/whitespace strings: no direct string fields.
- String length: no direct constraints.
- Enums: none.
- UUIDs: none.
- Numeric ranges: nested challenge config handles fee.
- Optional fields: `challenge` is optional.
- Storage/image references: none.
- Additional modes: OpenAPI allows additionalProperties, but the DTO's `additional` map does not appear to capture unknown JSON keys. See L-001.

### TemplateChallengeModeRequest

- Null values: all fields are optional.
- Blank/whitespace strings: `currency` has no blank validation. `refEmail` is optional and only validated when present.
- String length: no max length on `currency` or `refEmail` was found.
- Enums: none.
- UUIDs: none.
- Numeric ranges: `failCardFeeMinor` is `@PositiveOrZero`.
- Optional fields: service defaults currency to USD, fail fee to 0, and refRequired from explicit value or refEmail presence.
- Storage/image references: none.

The lack of currency validation is not classified as a finding because the reviewed sources do not clearly define a strict currency enum or length constraint beyond legacy defaulting to USD.

### TemplateScheduleRequest

- Null values: `startAt` and `endAt` are optional.
- Blank/whitespace strings: not applicable because fields are `OffsetDateTime`.
- String length: not applicable.
- Enums: none.
- UUIDs: none.
- Numeric ranges: none.
- Optional fields: both schedule endpoints are optional.
- Cross-field validation: no start-before-end validation was found. This is not classified as a finding because the reviewed OpenAPI and domain docs do not clearly require it.

### CreateInstanceRequest

- Null values: `activityTemplateId`, `refEmail`, `amountCents`, and `idempotencyKey` are required. `playContext`, `relationshipMode`, and `schedule` are optional.
- Blank/whitespace strings: `refEmail` is `@NotBlank`.
- String length: no explicit length limit on refEmail.
- Enums: `playContext` and `relationshipMode` use Java enums.
- UUIDs: `activityTemplateId` and `idempotencyKey` are UUIDs.
- Numeric ranges: `amountCents` is restricted to OpenAPI-listed values 0, 500, 2500, 5000, and 10000.
- Optional fields: service defaults playContext to ONLINE and relationshipMode to SOLO. schedule.endAt is used as instance endAt.
- Storage/image references: none.

OpenAPI lists fixed amount values. The legacy Zod validator also allowed custom values from 5000 to 50000. Because the migration task prioritizes OpenAPI over legacy implementation details, the fixed Spring set is treated as intentional unless product confirms custom amounts are still required.

### CreateTapCardRequest

- Null values: note, photoPath, and removePhoto are optional.
- Blank/whitespace strings: note may be blank at DTO level. Service normalizes blank note to null.
- String length: note max 2000.
- Enums: none.
- UUIDs: none in body.
- Numeric ranges: none.
- Optional fields: photo and remove semantics are optional.
- Storage/image references: photoPath accepts multiple aliases but has no path format, bucket, length, or ownership validation.

### ChallengerDecisionRequest

- Null values: decision is required. reasonCode and details are optional.
- Blank/whitespace strings: no nonblank validation for optional text fields.
- String length: reasonCode max 80, details max 2000.
- Enums: decision uses Java enum.
- UUIDs: none.
- Numeric ranges: none.
- Optional fields: reason/details are optional and appropriate for fail/chicken/dispute context.
- Storage/image references: none directly. Cover-card selection is separate.

### CoverCardRequest

- Null values: coverCardId is required.
- Blank/whitespace strings: not applicable.
- String length: not applicable.
- Enums: none.
- UUIDs: coverCardId is UUID.
- Numeric ranges: none.
- Optional fields: none.
- Storage/image references: cover card is a related DB card ID, not a direct storage path.

### RefDecisionRequest

- Null values: token and verdict are required.
- Blank/whitespace strings: token is `@NotBlank`.
- String length: no max length on token.
- Enums: verdict uses Java enum.
- UUIDs: token is modeled as String. This is acceptable because tokens are opaque strings in the table even though current service creates UUID text.
- Numeric ranges: none.
- Optional fields: none.
- Storage/image references: none.

## 7. Domain Model Assessment

1. Is `PlayTemplate` modeled as generic behavioral content?

Partially. The table and class name are generic, and many fields are generic Play fields. However, `ActivityTemplate#createRoot` and `replaceContent` always set Challenge defaults, and `ActivityTemplateService#save` always synchronizes Challenge config. This means the implementation is still Challenge-shaped at creation time.

2. Is `PlayInstance` generic enough for future Play modes?

Partially. `ActivityInstance` stores generic fields such as template ID, state, play context, relationship mode, mode kind, schedule, and tap counters. But the only factory is `createChallenge`, and `ActivityInstanceService#create` requires Challenge request fields and writes Challenge config every time.

3. Is Challenge behavior isolated from the generic Play model?

Not fully. Challenge finalization, ref decisions, mail tokens, and disputes are isolated in Challenge-specific config/event/token/dispute entities and service methods. Creation is not isolated because generic template and instance creation paths create Challenge state unconditionally.

4. Do entity methods represent meaningful domain behavior or mostly expose generic setters?

The entity methods generally represent meaningful behavior: create root template, replace content, soft delete, create challenge instance, record tap, complete instance, set cover card, open/cancel/reopen/finalize tap, mark ref decision, mark challenger finalization, and mark mail sent. They are not just generic setters.

5. Are important entity invariants encapsulated?

Some invariants are encapsulated, especially timestamp/status changes around creation, tap state changes, ref decision marking, and instance completion. Cross-aggregate invariants such as ownership, template playability, ref-decision ordering, latest event requirements, and cover-card ownership live in `ActivityTemplateService` and `ActivityInstanceService`, which is appropriate because those checks require multiple repositories/entities.

6. Is orchestration kept in services rather than pushed unnecessarily into entities?

Yes. Repository orchestration, locking, transaction boundaries, ownership checks, and multi-row Challenge workflows are in services. This is appropriate. The recommended domain-model change is not "make entities richer" generally; it is to stop putting Challenge defaults into generic creation paths unless the operation is explicitly Challenge-specific.

## 8. Transaction Assessment

`ActivityTemplateService#save`

- Boundary: `@Transactional`.
- Writes: `activity_templates`, `activity_template_challenge_config`, and `public_activity_templates` insert/update/delete.
- Atomicity: These writes must be atomic so the template content, mode config, and catalog projection do not diverge.
- Rollback: Runtime exceptions from ownership checks, validation normalization, repository writes, or database constraints should roll back all writes.
- Exception handling: No local catch swallows exceptions.
- External operations: Image upload/storage is outside this transaction. The API accepts a storage reference only.

`ActivityTemplateService#update`

- Boundary: `@Transactional`.
- Writes: updates `activity_templates`, optionally updates/deletes `activity_template_challenge_config`, and updates/deletes `public_activity_templates`.
- Atomicity: Required for the same reason as create.
- Rollback: Runtime exceptions should roll back all writes.
- Exception handling: No local catch swallows exceptions.
- External operations: Storage object lifecycle remains outside the DB transaction.

`ActivityTemplateService#delete`

- Boundary: `@Transactional`.
- Writes: soft-deletes `activity_templates` and deletes the catalog projection.
- Atomicity: Required so deleted templates disappear from catalog.
- Rollback: Runtime exceptions should roll back both writes.
- Exception handling: No local catch swallows exceptions.
- External operations: No storage deletion is attempted.

`ActivityInstanceService#create`

- Boundary: `@Transactional`.
- Writes: `activity_instances` and `activity_instance_challenge_config`.
- Atomicity: Required so a Challenge instance cannot exist without Challenge config.
- Rollback: Runtime exceptions from template validation, ownership/playability checks, or the second insert should roll back the instance insert.
- Exception handling: No local catch swallows exceptions.
- External operations: None.

`ActivityInstanceService#toggleTap`

- Boundary: `@Transactional`.
- Writes: creates or updates `activity_taps`; updates `activity_instances` tap counters through entity behavior.
- Atomicity: Required so tap state and instance counters remain consistent.
- Rollback: Runtime exceptions should roll back both.
- Exception handling: No local catch swallows exceptions.
- External operations: None.

`ActivityInstanceService#createTapCard`

- Boundary: `@Transactional`.
- Writes: inserts `tap_cards`; updates `activity_taps` finalization state.
- Atomicity: Required so a card and tap finalization cannot diverge.
- Rollback: Runtime exceptions should roll back both.
- Exception handling: No local catch swallows exceptions.
- External operations: Photo upload/storage is outside the relational transaction. Spring stores the already-uploaded photo reference.

`ActivityInstanceService#prepareRefNotification`

- Boundary: `@Transactional`.
- Writes: inserts `activity_instance_challenge_mail_tokens`; updates `activity_instance_challenge_config` ref-mail metadata; inserts a Challenge event.
- Atomicity: The DB writes should be atomic.
- Rollback: Runtime exceptions should roll back all DB writes.
- Exception handling: No local catch swallows exceptions.
- External operations: No actual email operation was found. If email delivery is later added, it will be outside the DB transaction unless implemented as an outbox.

`ActivityInstanceService#submitRefDecision`

- Boundary: `@Transactional`.
- Writes: updates the token used state, updates challenge config ref verdict/state, invalidates sibling tokens, and inserts a Challenge event.
- Atomicity: Required so single-use token state and Challenge verdict do not diverge.
- Rollback: Runtime exceptions should roll back all writes.
- Exception handling: The method returns structured results for expected token failure cases before making writes. It does not catch and swallow write exceptions.

`ActivityInstanceService#submitChallengerDecision`

- Boundary: `@Transactional`.
- Writes: updates instance state/completion, updates challenge config finalization state, inserts Challenge events, and may insert a dispute row or set a cover card.
- Atomicity: Required because final Challenge state spans multiple tables.
- Rollback: Runtime exceptions should roll back all writes.
- Exception handling: No local catch swallows exceptions.
- External operations: Payment checkout is not implemented and throws 501 from the controller, so no payment provider call participates in a DB transaction.

Important transaction gap:

- The legacy `create_challenge_template_and_instance` operation was one DB transaction. Spring currently exposes template creation and instance creation as separate service transactions. See H-003.

Verification note:

- `./gradlew compileJava` completed successfully.
- `./gradlew test` did not run to completion in this local workspace because Flyway validation failed after migration version 3 was renamed from the previously applied description to `V3__create_activity_instances.sql`. This is local Flyway history/schema state, not a Java compilation failure. The database must be repaired/reset or Flyway history corrected before the full test suite can verify transaction behavior.

## 9. Persistence / JPA Assessment

Lost or changed PostgreSQL function behavior relevant to the reviewed flow:

- `can_select_activity_template` public lifecycle gating is not fully preserved in `ActivityTemplateService#get`. See H-001.
- `create_challenge_template_and_instance` atomic create-and-play behavior is not represented. See H-003.
- Legacy notify behavior sent email through an edge function and was rate-limited. Spring creates a token but does not deliver or return it. See H-002.
- Legacy public ref-decision routes had CSRF/rate limiting controls. Spring has public token endpoints without equivalent controls. See M-003.
- Legacy `create_challenge_instance` only selected PUBLIC, PUBLISHED, ACTIVE templates. Spring allows owners to instantiate their own published private templates. This may be intentional product behavior, but it is a semantic change that needs confirmation.
- Legacy chicken finalization updated `profiles.chicken_until`. The reviewed Spring flow does not include a profile-side effect. This may be intentionally deferred because profile behavior is outside the Play migration scope.
- Payment checkout is explicitly not implemented and returns 501.

Defaults:

- Template creation defaults align with Challenge MVP behavior: modeKind CHALLENGE, proofKind ANY, playContext ONLINE, relationshipMode SOLO, participants 1..1.
- `CreateTemplateRequest.visibility` defaults to PRIVATE in service logic, matching legacy route behavior even though the SQL function default was PUBLIC.
- Template Challenge config defaults currency to USD and fail fee to 0.
- Instance creation defaults playContext to ONLINE and relationshipMode to SOLO.

Enums:

- Java enums match the reviewed migrated PostgreSQL enum values for template lifecycle, visibility, play context, relationship mode, mode kind, instance state, ref state, ref verdict, tap state, and Challenge event type.
- `ActivityModeKind` currently contains only CHALLENGE, which is consistent with the migrated schema but narrower than the documented future Play model.

Nullable/non-null and foreign keys:

- Core creation fields required by the database are supplied by service factory methods.
- Template and instance ownership uses UUID app user IDs and database FKs to app_users.
- Challenge instance config has a required FK to activity_instances.
- Public template projection has a required FK to activity_templates.

Relationships and loading:

- The reviewed entities generally use UUID references instead of broad object graphs. That is appropriate for this flow and avoids unnecessary eager loading.
- No unnecessary bidirectional relationships were found in the creation path.
- Summary/final-call assembly performs several targeted repository reads. This is acceptable for single-instance reads; no creation-flow N+1 issue was found.

Native SQL:

- Native SQL is used for latest-tap locking. That is justified because the operation needs ordered row locking that is awkward through derived JPA methods.
- Other ordinary persistence uses repositories/JPA rather than mechanically translating legacy functions into native SQL.

Managed entity saves:

- Some `save()` calls on possibly managed entities are harmless but not strictly required after a locked find. They are not a defect in this flow.

## 10. REST and API Contract Assessment

Implemented endpoints reviewed:

- `POST /api/templates`
- `PUT /api/templates/{id}`
- `PATCH /api/templates/{id}`
- `DELETE /api/templates/{id}`
- `GET /api/templates/{id}`
- `GET /api/templates`
- `POST /api/instances`
- `GET /api/instances/{id}`
- `POST /api/instances/{id}/taps`
- `GET /api/instances/{id}/taps/{tapId}`
- `POST /api/instances/{id}/taps/{tapId}/cards`
- `POST /api/instances/{id}/challenge/challenger-decision`
- `PUT /api/instances/{id}/cover-card`
- `GET /api/instances/{id}/challenge/final-call`
- `POST /api/instances/{id}/challenge/notifications`
- `POST /api/instances/{id}/challenge/payment/checkout`
- `GET /api/instances/ref-decisions/session`
- `POST /api/instances/ref-decisions`

Intentional differences from legacy Next.js routes:

- Resource-oriented plural Spring paths replace action-style legacy paths such as `/api/playTemplate/create` and `/api/playInstance/challenge/create`.
- Template and instance creation return HTTP 201 instead of legacy 200.
- The Spring API uses explicit request/response DTOs and Java UUID/enums rather than loose JavaScript object parsing.
- Spring accepts pre-uploaded image references and does not handle multipart image bytes for template creation.
- Public ref-decision token routes remain action-like because they model a domain action rather than ordinary CRUD.

Contract concerns:

- `POST /api/instances` is a generic resource path but currently requires Challenge-specific fields. This should be documented or split.
- `PATCH /api/templates/{id}` does not implement partial update semantics. See M-002.
- `GET /api/templates/{id}` public visibility is broader than legacy/domain catalog visibility. See H-001.
- No combined create-and-play endpoint exists. See H-003.
- Notification endpoint returns success without delivery or a returned token/link. See H-002.
- Payment checkout returns 501. That is explicit and acceptable only if payment migration is intentionally out of scope for this stage.
- Response envelopes intentionally differ from legacy in several places. That is acceptable if generated/current OpenAPI is updated to match Spring.

Authentication requirements:

- Template mutations are authenticated.
- Instance owner operations are authenticated.
- `GET /api/templates/**` is public through SecurityConfig.
- `GET /api/instances/ref-decisions/session` and `POST /api/instances/ref-decisions` are public token routes.
- Other `/api/**` routes require authentication.

## 11. Test Coverage Assessment

Existing relevant tests and what they prove:

- `TemplateControllerTest` proves authenticated template create returns 201, anonymous create is 401, authenticated update/delete call the service, public/private GET behavior is delegated through the mocked service, and blank title returns 400.
- `InstanceControllerTest` proves authenticated instance create returns 201 and passes principal.userId to the service, anonymous create is 401, invalid amount returns 400, instance summary/tap response shapes are wired, and public ref-decision POST is reachable without login.
- `ActivityTemplateServiceTest` proves selected owner and non-owner branches for update/delete/get using mocked repositories. It does not prove creation persistence.
- `ActivityInstanceServiceTest` proves selected service branches for create, lowercased ref email config, idempotency fast path, non-owner read rejection, and first tap creation using mocked repositories.
- `ActivityTemplateRepositoryTest` verifies repository persistence/query behavior but depends on a hardcoded app_users row that is not seeded by V1.
- `AuthTestControllerTest` verifies auth endpoint behavior and anonymous 401 behavior for the test controller.
- `BackendApplicationTests` verifies Spring context load when Flyway validation succeeds.

Meaningful missing scenarios:

- Template creation integration test proving `activity_templates`, `activity_template_challenge_config`, and `public_activity_templates` writes.
- Template creation rollback test when challenge config or catalog projection write fails.
- Public template item lookup tests for anonymous public draft, anonymous archived, inactive, owner draft, and non-owner private access.
- Template PATCH partial update behavior test, or removal of PATCH if full replacement is intended.
- Request validation tests for missing lifecycleState, over-length title/rules, malformed UUID, malformed enum, invalid nested Challenge fee, invalid refEmail, missing idempotency key, and malformed schedule timestamp.
- Storage reference tests once expected image-reference format is defined.
- Instance creation integration test proving `activity_instances` and `activity_instance_challenge_config` rows.
- Instance creation rollback test when the second write fails.
- Instance creation tests for nonexistent template, deleted template, unpublished template, inactive template, private template owned by another user, and private template owned by the requester if that behavior is intended.
- Idempotency integration test proving same user + key returns the existing instance and different user + key does not.
- Test proving client payload cannot override AppJwtPrincipal.userId, even if future DTOs add identity-like fields.
- Tap/card state transition tests for cancel, reopen, already recorded, canceled tap card rejection, and finalized/ref-decided Challenge rejection.
- Ref-decision token tests for invalid, expired, used, invalidated, wrong action, already decided, sibling invalidation, and event creation.
- Challenger decision tests for success, fail no payment, fail with payment rejected, chicken/dispute requiring cover card/latest card, duplicate terminal event behavior, and expected database effects.
- Notification tests proving either email/outbox dispatch or returned link/token semantics.
- Clean database test setup for `ActivityTemplateRepositoryTest`.

Current local verification gap:

- Full tests currently fail before executing because the local Flyway schema history still records the old version 3 migration description while the file has been renamed to `V3__create_activity_instances.sql`. The item to care about is Flyway's immutable migration identity after application: changing a versioned migration filename/description after it has been applied causes validation failure unless the database is reset, repaired, or migrated with a new version.

## 12. Manual Review Guide

Recommended manual inspection order:

```text
1. SecurityConfig, JwtTokenService, JwtAuthenticationConverter, CustomOidcUserService, AppJwtPrincipal
Verify:
- JWT subject is app_users.id.
- OIDC sub/email are used only at account-mapping boundary.
- Play controllers receive AppJwtPrincipal and pass principal.userId only.
- Public token routes are intentionally public.
```

```text
2. TemplateController#create and CreateTemplateRequest
Verify:
- @Valid is present.
- No user identity can be supplied by client payload.
- Response status/body match intended Spring API contract.
- Validation matches OpenAPI/domain constraints.
```

```text
3. ActivityTemplateService#save, resolveCreateFields, syncChallengeConfig, syncCatalogProjection
Verify:
- Owner assignment uses AppJwtPrincipal.userId.
- Existing template IDs are owner-checked before update.
- Template, Challenge config, and catalog projection writes are in one transaction.
- Defaults are intentional.
- Challenge config creation for every template is acceptable for MVP.
```

```text
4. ActivityTemplate#createRoot, replaceContent, isCatalogVisible
Verify:
- Entity methods encode only invariants owned by the template.
- Generic Play fields are not accidentally locked to Challenge longer than intended.
- Catalog visibility rule matches public API visibility.
```

```text
5. ActivityTemplateService#get
Verify:
- Anonymous/non-owner reads cannot see public DRAFT, ARCHIVED, inactive, or deleted templates.
- Owner reads still allow drafts.
```

```text
6. InstanceController#create and CreateInstanceRequest
Verify:
- Challenge-specific required fields are intentional under /api/instances.
- Amount constraints follow the selected source of truth.
- idempotency_key aliases and UUID binding match clients.
```

```text
7. ActivityInstanceService#create and ActivityInstance#createChallenge
Verify:
- Template playability rule is intentional, especially owner access to private templates.
- Idempotency behavior matches legacy requirements.
- Sequence allocation has acceptable concurrency behavior.
- Instance and Challenge config writes are atomic.
```

```text
8. V2__create_activity_templates.sql and V3__create_activity_instances.sql
Verify:
- Enum names and values match Java enums.
- FK, nullable, and unique constraints match service assumptions.
- Version 3 migration filename matches all databases where it has already been applied, or Flyway repair/reset plan exists.
```

```text
9. ActivityInstanceService#prepareRefNotification
Verify:
- Decide whether this endpoint sends email, creates an outbox command, or returns a token/link.
- Ensure the HTTP response does not imply notification delivery unless delivery occurs.
```

```text
10. ActivityInstanceService#getRefDecisionSession and submitRefDecision
Verify:
- Token state checks are correct.
- Sibling token invalidation happens atomically.
- Rate limiting/abuse controls are planned or implemented.
```

```text
11. ActivityInstanceService#submitChallengerDecision and finalization helpers
Verify:
- Ref-decision ordering is enforced.
- Success/fail/chicken/dispute transitions match Challenge journey docs.
- Omitted profile/payment side effects are intentionally out of scope.
```

```text
12. Tests
Verify:
- Controller tests cover auth and request validation.
- Service tests do not mock away the behavior being asserted.
- Integration tests prove database effects and rollback for migrated PostgreSQL function responsibilities.
```

## 13. Open Questions / Ambiguities

1. Should create-and-play remain atomic?

Sources: legacy `create_challenge_template_and_instance` provides a single transaction; `001-play-related-apis-migration.md` requires equivalent behavior but promotes RESTful design; current Spring exposes separate template and instance creation only. Product/API decision needed.

2. Should `POST /api/instances` be generic or explicitly Challenge-specific?

Sources: domain docs say PlayInstance is generic and Challenge is a mode; current DTO requires refEmail and amountCents. Migration docs prefer generic REST resources but only Challenge MVP is currently modeled in the schema.

3. May users instantiate their own private published templates?

Sources: legacy `create_challenge_instance` selected only PUBLIC templates; Spring `assertTemplatePlayableBy` allows owner access to non-public templates. Domain docs do not clearly forbid private personal Play starts.

4. Which amount validation rule is authoritative?

Sources: OpenAPI lists fixed amounts 0, 500, 2500, 5000, and 10000; legacy Zod validator also allows custom values from 5000 to 50000. Source priority favors OpenAPI, but product may still expect custom amounts.

5. What is the expected notification contract?

Sources: legacy notify route sends email through an edge function; Spring creates a token but neither sends nor returns it. Domain journey requires the referee to receive a decision path.

6. What is the exact allowed image/storage reference format?

Sources: OpenAPI and migration docs preserve external storage reference semantics but do not define a strict format, max length, bucket allow-list, or ownership validation rule for Spring.

7. What abuse controls are required for public token routes?

Sources: legacy routes had CSRF/rate limiting; Spring disables CSRF for `/api/**` and has no visible rate limiter. The new architecture may intentionally differ, but no threat-model decision was found.

8. Should public `GET /api/templates/{id}` exist, and which lifecycle/status values should it expose?

Sources: Spring exposes the route publicly; legacy `can_select_activity_template` allowed owners or PUBLIC + PUBLISHED templates. Catalog projection only includes public published templates.

9. Where should Challenge currency for instance summaries come from?

Sources: template Challenge config stores currency; instance Challenge config stores fail fee and ref data; `ActivityInstanceService#toSummary` currently hardcodes USD. The reviewed docs do not clearly define whether currency can vary per instance.

10. Is profile-side chicken penalty in scope?

Sources: legacy `finalize_challenge_chicken` updated `profiles.chicken_until`; Spring Play migration does not include profile behavior. Domain docs mention Challenge user journey but do not clearly require this side effect in the migrated Play API.

## 14. Final Verdict

NEEDS REVISION

Short reason:

The core authenticated identity handling and the basic template/instance database writes are directionally correct, but the implementation has important behavior gaps around public template visibility, referee notification, and the legacy atomic create-and-play flow. The generic Play model is also still materially Challenge-shaped at creation boundaries.

Finding counts:

- Critical: 0
- High: 3
- Medium: 5
- Low: 2

Before merge:

1. Fix public template item visibility so anonymous/non-owner reads cannot access DRAFT, ARCHIVED, inactive, private, or deleted templates.
2. Decide and implement the ref notification contract: send/enqueue email or return a usable token/link without claiming delivery.
3. Decide whether create-and-play must be atomic; implement a combined transaction if the flow remains required.
4. Add integration coverage for template creation and instance creation database effects and rollback.
5. Repair or reset the local Flyway schema history affected by the version 3 migration rename before using the test suite as verification.

Can be deferred:

1. Split generic Play creation from Challenge-specific creation if the MVP only exposes Challenge behavior for now, but document the current contract.
2. Add partial PATCH support or remove the PATCH route.
3. Add public token route rate limiting after deciding the Spring API abuse-control approach.
4. Define exact storage reference validation for photo paths.
5. Clean up test fixture setup and clock consistency.
