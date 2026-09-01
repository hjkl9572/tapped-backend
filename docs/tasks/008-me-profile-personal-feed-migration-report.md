# `/me` and Profile Migration Report

Report for the migration performed under `docs/tasks/007-me-profile-personal-feed-migration.md`: `me/personal-feed` into the Play domain, and `me/profile-card` / `profile/by-handle` / `profile/handle/check` / `profile/nickname` into a new Profile domain.

---

## 1. Domain Separation

The legacy `/me` and `profile/**` routes were organized by frontend page/history, not by business responsibility. This migration splits them by domain:

```text
Play
→ me/personal-feed → GET /api/tap-cards/personal-feed
  (the authenticated user's own Play Cards; TapCardController, TapCardQueryService)

Profile
→ me/profile-card, profile/nickname → PATCH /api/profiles/current
→ profile/by-handle → GET /api/profiles/by-handle/{handle}
→ profile/handle/check → GET /api/profiles/handles/{handle}/availability
  (new games.tapped.profile.* package: ProfileController, ProfileService,
   Profile entity, ProfileRepository)
```

No `Me`/`MeController` was created. No Profile mutation logic lives in Play; no Play query logic lives in `ProfileController`. `AppUser` remains where it already lived (`games.tapped.play.entity`) — this task did not relocate the User domain, only added the Profile domain alongside it, per the existing Spring convention noted during research.

---

## 2. Personal Feed

```text
GET /api/tap-cards/personal-feed
    → TapCardController#getPersonalFeed(AppJwtPrincipal principal)
    → TapCardQueryService#getPersonalFeed(principal.userId())
    → TapCardRepository#findPersonalFeed(userId, MAX_PERSONAL_FEED_ENTRIES=120)
        (single native CTE: candidate cards owned by the user, capped at 120
         by tc.updated_at desc, then a per-row "latest touch" timestamp —
         greatest of card/tap/instance/config timestamps — used for the
         final descending sort)
    → mapped row-by-row into PersonalFeedItem (status derived via the shared
      ChallengeStatusDeriver, also used by ActivityInstanceService)
    → PersonalFeedResponse{ items }
```

Identity is resolved exclusively from `AppJwtPrincipal.userId`; the route has no public/anonymous variant (`/api/**` → `authenticated()` already covers it — no `SecurityConfig` change was needed).

### Legacy mapping

The legacy `me/personal-feed` route had no backing Postgres RPC — its filtering/ordering/derivation logic lived entirely in the Next.js route handler and a TS helper module. That logic was ported into a single native SQL query plus `TapCardQueryService`:

* **Filter**: owned by `activity_instances.created_by = :userId`, `tap_cards.deleted_at IS NULL`. Spring additionally filters `activity_instances.deleted_at IS NULL` (legacy did not) — see Behavioral Differences.
* **Ordering**: legacy capped candidates by `tap_cards.updated_at DESC LIMIT 120` in SQL, then re-sorted client-side by a composite "latest touch" timestamp before rendering. Spring reproduces both steps in one query: a `candidates` CTE applies the same cap/order, then the outer `SELECT` orders by the same composite `GREATEST(...)` expression, with `card_id` added as a deterministic tiebreaker (legacy relied on JS's stable sort keeping DB order for ties, which isn't reproducible identically in SQL — a stable, documented tiebreak was substituted).
* **No pagination params**: legacy accepted none (fixed 120-row cap); Spring preserves this as `MAX_PERSONAL_FEED_ENTRIES = 120`, not a client-controlled page size.
* **Status derivation**: the legacy route computed a 9-branch challenge status inline. Spring reuses `ActivityInstanceService`'s existing (already-tested) status precedence — extracted into a shared `ChallengeStatusDeriver` — rather than re-implementing the legacy TS branch order verbatim. See Behavioral Differences for the one precedence difference this introduces.
* **Photo path**: returned raw (`COALESCE(card.photo_path, template.photo_path)`), matching the existing leaderboard convention (`TapCardRepository#findLeaderboard`) of never resolving storage URLs server-side — the legacy route's `resolveTemplatePhotoPath` client-side URL-building helper was intentionally not ported.
* **Like/reply counts**: reuses the same `LEFT JOIN` aggregation pattern already established by `findLeaderboard` (`tap_card_likes`, `tap_card_replies WHERE status = 'VISIBLE' AND deleted_at IS NULL`).

---

## 3. Consolidated Profile Mutation

```text
me/profile-card (bio, avatarUrl)
    +
profile/nickname (nickname)
    ↓
PATCH /api/profiles/current
```

Both legacy mutation endpoints wrote to the same `profiles` row keyed by `user_id`; they are consolidated into one partial-update endpoint. The frontend may continue sending only the fields relevant to a given edit control (nickname-only, bio-only, avatar-only, or any combination).

### PATCH semantics (field presence)

Standard Bean Validation on a nullable-fields record cannot distinguish "key omitted" from "key present with `null`" — both collapse to Java `null`. This is a real, well-known Jackson limitation, not an oversight: reproducing the legacy `hasOwnKey()` check-per-field behavior requires seeing the raw JSON structure. `ProfileController#updateCurrent` therefore accepts the body as `JsonNode` (Jackson 3 — see Section 6) and `ProfileUpdateCommand.from(body)` converts it into three `(present, value)` pairs:

```text
key omitted           → present=false            → field left unchanged
key present, null     → present=true, value=null  → field cleared
key present, "x"      → present=true, value="x"   → field validated and set
```

This exactly reproduces legacy `me/profile-card`'s `hasOwnKey(payload, 'bio')`/`hasOwnKey(payload, 'avatarUrl')` behavior, including "empty string clears the field the same as explicit null" (handled in `Profile#changeIntroduction`/`#changeAvatar` via trim-then-collapse-to-null, matching the legacy RPC's `NULLIF(TRIM(...), '')`).

### Field naming

* **`introduction`** (JSON) → `Profile.bio` (entity/column). The task doc's own domain docs (`docs/domain/support-profile.md`) and its illustrative JSON both use "introduction" as the conceptual field name, while the underlying DB column (and the legacy API's field) is `bio`. The DTO keeps the domain-vocabulary name (`introduction`) at the API boundary while the entity keeps the existing schema name (`bio`) internally — no column rename, no schema churn.
* **`avatarUrl`** (JSON), not `avatarPath` as shown in the task doc's illustrative JSON. The task doc explicitly instructs following "the current contract" for the avatar reference, and the legacy `me/profile-card` contract field is `avatarUrl` (a full validated `https://` URL, not a bucket-relative path) — that existing contract was preserved instead of the illustrative name.
* Nickname: `2–30` chars after trim, case-insensitive no-op (renaming to the same nickname case-insensitively is a true no-op — does not even update casing, matching legacy exactly), case-insensitive uniqueness. A fast-path `existsByNicknameIgnoreCase` check gives a clean `409` before hitting the DB constraint; the actual invariant is the new case-insensitive unique index (Section 5), and a `DataIntegrityViolationException` race on that constraint is also caught and mapped to `409` — the check-then-update pattern is a UX nicety, not the source of truth, per the task's explicit warning against relying on it alone.
* Avatar URL validation ported from the legacy RPC: `≤2048` chars, `^https?://` prefix, no control characters.

---

## 4. Public Profile Endpoints

```text
GET /api/profiles/by-handle/{handle}
GET /api/profiles/handles/{handle}/availability
```

Both are public (`permitAll()` added to `SecurityConfig` for these two `GET` patterns; no `AppJwtPrincipal` required).

* **By-handle**: legacy trimmed but did not lowercase the input before an exact-match RPC lookup (handles are stored already-lowercased at creation, so this worked in practice for real callers). Spring normalizes trim+lowercase before `findByHandleIgnoreCase` — a deliberate robustness improvement over the legacy route's implicit assumption, not a behavior legacy callers could observe differently, since the only way to get a differently-cased handle into the system no longer exists in this migration's scope (handle creation is out of scope — see Deferred APIs).
* **Availability**: `trim → lowercase`, validated against `^[a-z0-9_]{3,20}$`, invalid → `400` before any DB check (matching legacy's validate-first order). Returns `{"available": boolean}`.
* **Rate limiting**: the legacy `profile/handle/check` endpoint enforced a 120/hour-per-IP limit via a Postgres-backed fixed-window counter (`check_rate_limit_ip`, IP resolved from `x-vercel-forwarded-for`/`cf-connecting-ip`/`x-real-ip`, hashed before storage). **No equivalent infrastructure exists anywhere in this Spring project** (confirmed: no Bucket4j/resilience4j, no rate-limit interceptor/filter, no IP-bucket table in any Flyway migration). Per the task's explicit instruction, this gap is documented rather than silently dropped or solved by introducing unrelated infrastructure for a single endpoint. **This is a known, currently-unaddressed operational difference**: `GET /api/profiles/handles/{handle}/availability` can be called without limit by the same caller today.

---

## 5. Persistence

`profiles` already existed (added in `V4` for the leaderboard's creator-profile join) but lacked a `bio` column and had **no uniqueness constraints at all** on `handle`/`nickname` — a real gap versus the legacy Supabase schema, which enforced both as case-insensitive partial unique indexes. `V5__add_profile_bio_and_unique_constraints.sql` adds:

```sql
ALTER TABLE profiles ADD COLUMN bio text NULL;
CREATE UNIQUE INDEX uniq_profiles_handle_ci   ON profiles (lower(handle))   WHERE handle IS NOT NULL;
CREATE UNIQUE INDEX uniq_profiles_nickname_ci ON profiles (lower(nickname)) WHERE nickname IS NOT NULL;
```

This restores parity with the legacy schema's actual invariants — not a new behavior, a closed gap. `Profile` has no factory/insert path in this migration (profile-row creation is part of onboarding, out of scope); it only reads and updates existing rows, matching `me/profile-card`'s own "Complete onboarding first" precondition (reproduced as `404 Profile not found` via `EntityNotFoundException`, since Spring has no onboarding-specific error code to reuse).

---

## 6. Behavioral Differences

```text
1. PATCH /api/profiles/current accepts a JsonNode body, not a validated
   Bean-Validation record, because standard `@Valid` cannot distinguish
   "field omitted" from "field explicitly null" — both collapse to Java
   null. This is a Jackson/Bean-Validation limitation, not a shortcut:
   the JsonNode-based ProfileUpdateCommand.from(...) is the mechanism that
   makes correct PATCH-omission semantics possible at all. Field-level
   validation (length, regex, required-ness) still happens explicitly in
   ProfileService, just not via @Valid annotations.

2. Uses Jackson 3 (`tools.jackson.databind.JsonNode`), not the classic
   Jackson 2 (`com.fasterxml.jackson.databind.JsonNode`) that the rest of
   the codebase's `@JsonProperty`/`@JsonAlias` annotations come from.
   Spring Boot 4.1's message converters bind to `tools.jackson.databind`;
   using the Jackson-2 JsonNode type as a controller parameter fails at
   runtime with a Jackson "type definition error" even though it compiles
   fine (confirmed via a failing test before the fix). Jackson-2
   *annotations* (`jackson-annotations`, a shared artifact) remain in use
   elsewhere and are unaffected.

3. Personal feed status derivation reuses ActivityInstanceService's exact
   precedence (via the new shared ChallengeStatusDeriver) rather than the
   legacy TS route's own branch order. The two orders differ only in
   whether a terminal `deletedAt` check and `state == TERMINATED` are
   considered before or interleaved with `state == COMPLETED` — since
   `state` is single-valued, this is only observable if `deletedAt`/
   `terminated_at` are set inconsistently with `state`, which cannot
   happen through any current write path. Chosen deliberately for
   consistency between the two Play read models rather than duplicating
   a second bespoke 9-branch implementation.

4. Personal feed query adds `activity_instances.deleted_at IS NULL` to
   its filter; the legacy route had no equivalent filter (it never
   selected or checked that column). A soft-deleted instance is normal-
   case unreachable in this codebase (no current path soft-deletes an
   instance a user still owns tap cards under), so this is a defensive
   correctness improvement, not an observed behavior change.

5. GET /api/profiles/by-handle/{handle} lowercases the input before
   lookup; the legacy route only trimmed (relying on handles already
   being stored lowercase). Handle creation is out of this migration's
   scope, so this cannot currently produce a different result than
   legacy for any real caller — documented as a deliberate robustness
   choice, not a functional change observable today.

6. Handle-availability rate limiting (120/hour/IP in legacy) is not
   reproduced — no rate-limiting infrastructure exists in this Spring
   project. This is a real, currently-open operational gap (see Section
   4), not an oversight.

7. profiles.bio and the case-insensitive unique indexes on handle/
   nickname did not exist in Spring's schema before this migration
   (V4 only had the leaderboard-join columns, no constraints). V5 adds
   them, restoring parity with legacy Supabase's actual invariants.
```

---

## 7. Deferred APIs

```text
profile/tos
→ deferred: TOS/consent is not a Profile-domain responsibility; legal
  documents are not ready. No Spring endpoint exists for this.

profile/avatar/upload
→ deferred: depends on client-side crop/resize, multipart upload,
  Supabase Storage, and an Edge Function for processing — infrastructure-
  specific, out of the current Spring storage boundary. The legacy
  upload/processing pipeline is untouched. PATCH /api/profiles/current
  only accepts the resulting avatarUrl string once upload/processing has
  already happened externally, per the task's explicit instruction; no
  raw image bytes, multipart handling, or new storage infra were added.
```

## 8. Dead Code (not restored)

```text
profile/avatar/process
profile/update
```

Both were already identified as dead/superseded legacy routes prior to this task. Neither was referenced, restored, or migrated.

---

## 9. New Routes Summary

```text
GET   /api/tap-cards/personal-feed          (authenticated)
PATCH /api/profiles/current                 (authenticated)
GET   /api/profiles/by-handle/{handle}      (public)
GET   /api/profiles/handles/{handle}/availability  (public)
```

All four are live in the running application's `GET /v3/api-docs` (springdoc auto-generates the spec from the controllers/DTOs — this project has no hand-maintained OpenAPI YAML to update separately, and no existing controller in the codebase uses manual `@Operation`/`@Schema` annotations, so none were introduced here either, matching the established convention).

---

## 10. Test Coverage

144 tests total (33 new), all passing against a real local Postgres database (no mocked DB layer for repository tests):

* `TapCardQueryServiceTest` (+8): personal feed delegation/limit, empty feed, status/result mapping (including the DISPUTE→"DISAGREE" mapping and the WAITING_FOR_REF_DECISION default), like/reply count passthrough.
* `TapCardControllerTest` (+3): authenticated personal feed, anonymous → 401, empty-feed response shape.
* `TapCardRepositoryTest` (+6): current-user scoping (another user's cards never returned), inclusion regardless of template visibility/lifecycle/instance-state (unlike the leaderboard, personal feed has no such filters), soft-deleted-card exclusion, empty-feed, most-recent-activity-first ordering, and full projection field verification (like/reply counts, challenger verdict, instance state, fee, note) against real inserted data.
* `ProfileServiceTest` (18): nickname/introduction/avatar-only updates, omitted-fields-unchanged, multi-field update, explicit-null-clears, nickname case-insensitive no-op, nickname conflict (both fast-path and DB-race paths → `DomainConflictException`), all validation-failure paths, not-found, by-handle (found/not-found/malformed), handle availability (available/taken/invalid/normalization).
* `ProfileControllerTest` (11): PATCH auth requirement and identity-from-principal-not-body, by-handle and handle-availability public access and status-code mapping.
* `ProfileRepositoryTest` (5) / `ProfileTest` (4): case-insensitive lookups, the new unique-index race (`DataIntegrityViolationException` on a duplicate nickname), pessimistic-lock read, and entity-level trim/blank-collapse/explicit-null-clear normalization.

---

## 11. Important Constraints Check

Verified against the task's "Important Constraints" list: no `Me`/`MeController` created; personal feed stayed in Play (`TapCardController`), Profile mutations stayed in Profile (`ProfileController`); identity resolved exclusively from `AppJwtPrincipal.userId` (no `userId` field accepted in the PATCH body, path, or query — confirmed by `ProfileControllerTest#resolvesCurrentUserFromPrincipalNotFromBody`, which sends a `userId` in the body and asserts it's ignored); no OIDC `sub`/email used for business identity anywhere in the new code; TOS and avatar upload/processing were not migrated; no dead routes restored; one consolidated PATCH endpoint instead of one-endpoint-per-legacy-route; PATCH implemented with real omission/null/value semantics, not PUT-style full replacement; no raw DB/RPC errors exposed (unique-violation → `DomainConflictException` → `409`, not the raw Postgres constraint message); no unrelated frontend code touched; no new storage infrastructure introduced.
