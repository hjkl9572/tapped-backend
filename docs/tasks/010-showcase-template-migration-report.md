# Showcase Templates Migration Report

Report for the migration performed under `docs/tasks/009-showcase-template-migration.md`: `/api/showcase` into `TemplateController` in the Spring Play domain.

---

## Migration Mapping

```text
Legacy:
GET /api/showcase/templates   (the actual legacy path — nested under
                                showcase/templates/route.ts, not a bare
                                /api/showcase)

PostgreSQL:
get_showcase_templates(p_limit integer default 12)

Spring:
GET /api/templates/showcase?limit={limit}

Domain:
Play

Controller:
TemplateController
```

```text
public_activity_templates
→ removed from this read flow; findShowcaseTemplates queries
  activity_templates (canonical data) directly.
```

---

## Legacy Behavior

**Route** (`goofed/goofed/src/app/api/showcase/templates/route.ts`): no query parameters accepted at all — `limit` was never read from the request; the route hardcoded `p_limit: 12` in every RPC call. No auth check (fully anonymous). Response: `{ items: [...] }` on success, `{ error }` + `500` on any RPC/thrown error. Empty/null RPC result → `200 { items: [] }`, never an error. `export const revalidate = 600` (Next.js ISR) is the source of the "~10 minute" caching the task doc references — pure frontend/HTTP-caching, not business logic, and not duplicated in Spring.

**`get_showcase_templates`** (final version, `20260514120000_refresh_and_wrap_showcase_templates.sql`, confirmed identical in `legacy/supabase/schema.sql`): first calls `refresh_public_activity_templates()` (a synchronous upsert of `public_activity_templates` from `activity_templates` filtered by `visibility='PUBLIC' AND lifecycle_state='PUBLISHED' AND published_at IS NOT NULL AND deleted_at IS NULL`), then selects from the now-fresh projection with:

* **Dedup**: one row **per `origin_id`** (template lineage/family, not per raw row) — `ROW_NUMBER() OVER (PARTITION BY origin_id ORDER BY published_at DESC, id DESC) = 1`, i.e. the most-recently-published version of each template family.
* **Ordering**: `ORDER BY published_at DESC, id DESC` — recency, not random (no `random()` anywhere in either migration).
* **Limit**: `LIMIT GREATEST(COALESCE(p_limit, 12), 1)` — floors at 1, defaults to 12 when null, no enforced upper bound inside the function itself.
* **Returned columns**: `id, origin_id, title, rules, photo_path, creator_display_name, published_at` — exactly 7 fields, no like/tap/avatar data.

Because the RPC re-derives `public_activity_templates` from canonical `activity_templates` on every single call, the projection was never actually a separate source of truth for this endpoint — it was a same-request-scoped mirror, re-synced before every read.

**Frontend usage**: exactly one caller (`useShowcaseTemplates.ts`), always requesting the fixed route with no limit override — no UI path ever requests anything other than 12. Two consumers (`ResultsShowcase.tsx` carousel, `TemplateCard.tsx` in the hero section) actually read `id`, `photo_path`, and `title`/`rules` from the response; `origin_id`, `creator_display_name`, `published_at` are carried in the type but not visibly rendered by current UI — still returned here since they're part of the established contract and free to include (already selected by the query).

---

## Spring Implementation

```text
GET /api/templates/showcase?limit={limit}
    → TemplateController#showcase(Integer limit)
    → ActivityTemplateService#getShowcaseTemplates(limit)
        (default-when-null, then reject <1 or >50 with IllegalArgumentException → 400)
    → ActivityTemplateRepository#findShowcaseTemplates(limit)
        (native CTE query over activity_templates directly — no
         public_activity_templates involved)
    → mapped row-by-row into ShowcaseTemplateItem
    → ShowcaseTemplatesResponse{ items }
```

* **Controller**: added to the existing `TemplateController`, no new controller class. Public — `/api/templates/**` was already `permitAll()` for `GET` in `SecurityConfig` from prior work, so no security config change was needed.
* **Service**: added to the existing `ActivityTemplateService` (no new service class), matching the task's "smallest cohesive structure" instruction and the existing precedent of one service per aggregate root (`TapCardQueryService` already holds multiple unrelated read methods for the same reason).
* **Repository**: `ActivityTemplateRepository#findShowcaseTemplates`, a native `@Query` following the same CTE-with-window-function style already established by `TapCardRepository#findLeaderboard`/`#findPersonalFeed` in this codebase (no QueryDSL/jOOQ dependency exists, and these entities have no JPA associations to walk, so native SQL is the only route to a single-query multi-condition join with a window function).
* **DTO**: new `ShowcaseTemplateItem`/`ShowcaseTemplatesResponse` records (not `TemplateResponse` or `TemplatePresetResponse` — see below), with `@JsonProperty` snake_case aliases (`origin_id`, `photo_path`, `creator_display_name`, `published_at`) matching the existing `TemplateResponse#photoPath` convention and preserving the legacy field-name contract exactly.

### Why a new DTO instead of reusing an existing one

`TemplateResponse` carries internal/owner-facing fields (`lifecycleState`, `visibility`, `createdBy`, `modeKind`, `playContext`, `relationshipMode`) that have no place in a public discovery response. `TemplatePresetResponse` (used by the existing `GET /api/templates` catalog) renames fields for UI-specific purposes (`period`, `imageSrc`, `imageAlt`) and doesn't carry `originId`/`creatorDisplayName`/`publishedAt`. Showcase's actual field set (`id, originId, title, rules, photoPath, creatorDisplayName, publishedAt`) matches neither shape, so a dedicated projection DTO was the correct call per the task's own guidance ("create a suitable public Showcase projection DTO if the response shape is meaningfully different").

---

## Projection Removal

`public_activity_templates` is not queried anywhere in the showcase read path. It continues to exist and be used elsewhere in this codebase (the pre-existing `GET /api/templates` catalog endpoint, `ActivityTemplateService#catalog`/`#syncCatalogProjection`, kept in sync on every template create/update/delete) — that usage was not touched or removed, since it's out of this task's scope. This migration specifically avoided *extending* that dual-write pattern to a new endpoint, per the task's explicit instruction, rather than removing the pattern from the codebase entirely.

The projection existed in Supabase primarily to support anonymous/RLS-gated reads without exposing the full canonical table to unauthenticated PostgREST clients. In the Spring architecture, the application server itself is the access-control boundary — a client can only reach canonical `activity_templates` through a controlled repository query, never directly — so a duplicate public projection is not required merely to provide anonymous access here. Reproducing it for showcase would only add synchronization risk (stale rows, missed-update bugs, extra mutation logic) without a corresponding benefit, exactly as the task doc's "Reason for Removing the Projection" section describes.

---

## Template Immutability

Published templates are versioned, not mutated in place — a creator's edit produces a new template row (new `id`, same `origin_id`) rather than changing the existing definition's meaning. Because of this, a direct canonical read has no meaningful staleness risk: any row `findShowcaseTemplates` returns was valid Play content at the moment it was published and remains a valid historical definition even if a newer version of the same `origin_id` family exists a moment later. This is why a same-transaction canonical query is acceptable here without a separately synchronized read model — the "freshness" that a projection would protect against isn't a real risk for versioned, immutable template rows.

---

## Query Semantics

```text
Filter:    activity_templates.deleted_at IS NULL
           AND visibility = 'PUBLIC'
           AND lifecycle_state = 'PUBLISHED'
           AND published_at IS NOT NULL
           (identical to ActivityTemplate#isCatalogVisible(), and to
            refresh_public_activity_templates()'s own filter — confirmed
            consistent with both existing conventions, not invented fresh)

Selection: one row per origin_id — ROW_NUMBER() OVER (PARTITION BY
           origin_id ORDER BY published_at DESC, id DESC) = 1
           (most-recently-published version of each template family)

Ordering:  published_at DESC, id DESC — recency-based, not random,
           reproduced exactly; id is a deterministic tiebreak, matching
           the legacy function's own tiebreak column

Limit:     applied inside the native query (LIMIT :limit), never fetched
           unbounded and trimmed in Java
```

### Limit parameter — deliberate Spring-side change

Unlike the legacy route (which never let the client control `limit` — it was hardcoded to `12` in the route handler even though the underlying RPC accepted a parameter), the Spring endpoint accepts a real client-supplied `limit` query parameter, per the task's explicit instruction not to hardcode `12` into the backend.

* **Missing**: defaults to `12` (`ActivityTemplateService.DEFAULT_SHOWCASE_LIMIT`), matching both the RPC's own `DEFAULT 12` and the only value any real caller has ever used.
* **Malformed** (non-numeric): Spring's own request-parameter binding rejects it before the controller method runs (`MethodArgumentTypeMismatchException`, already mapped to `400` by the existing `GlobalExceptionHandler`) — no manual string parsing was added.
* **Zero / negative**: rejected with `400` (`IllegalArgumentException` → existing handler), **not** silently clamped to `1` the way the legacy function's `GREATEST(..., 1)` would have. This is an intentional behavior change: the legacy clamp-to-1 behavior was effectively dead code (no real caller ever sent a value low enough to trigger it, since the route always sent a fixed `12`), and now that a client genuinely controls this value, rejecting a nonsensical request is more correct than silently substituting a different one.
* **Excessive**: rejected with `400` above `MAX_SHOWCASE_LIMIT = 50`. This is a new protective maximum — the legacy PL/pgSQL function had no upper cap at all inside itself (nothing prevented `p_limit=100000` at the SQL level; only the route's hardcoded `12` protected it in practice). Since Spring now exposes `limit` directly to any anonymous caller, an unbounded value is a real availability risk that didn't exist in the old architecture (where the parameter was never client-reachable at all). `50` was chosen as a generous multiple of the only real-world value (`12`) — no other project convention or contract value existed to derive it from, so this is recorded here as an explicit new Spring API decision per the task's instruction, not silently invented.

This mirrors the existing precedent in this codebase of *rejecting* out-of-range client input rather than clamping it (`TapCardQueryService#getLikeStats` already rejects empty/oversized ID batches with `IllegalArgumentException` instead of truncating).

---

## Caching

The frontend's ~10-minute cache (`revalidate = 600` + React Query `staleTime`/`gcTime`/`refetchInterval` all set to 600000ms in `useShowcaseTemplates.ts`) is entirely client/Next.js-side and was not reproduced in Spring. `GET /api/templates/showcase` simply computes and returns the current result on every call, per the task's explicit instruction. No HTTP-level or application-level cache was added.

---

## Tests

165 tests total (24 new), all passing against a real local Postgres database:

* **`ActivityTemplateServiceTest`** (+8): default-limit-when-null, explicit-limit-forwarded, zero/negative rejected, limit-above-max rejected, limit-at-max allowed, row→DTO mapping, empty-result handling.
* **`TemplateControllerTest`** (+6): anonymous access returns `200` with correct shape (including the `photo_path` snake_case field), requested limit forwarded to the service, omitted limit passes `null` (defaulting happens in the service, not the controller), empty result, malformed (`"not-a-number"`) limit → `400` via Spring's own binding, and a service-thrown `IllegalArgumentException` (e.g. `limit=0`) → `400` via the existing `GlobalExceptionHandler`.
* **`ActivityTemplateRepositoryTest`** (+8, against real inserted data): only public+published+non-deleted+non-null-`published_at` templates are returned; soft-deleted templates excluded; only the most-recently-published version per `origin_id` is returned (the other version of the same family is verifiably absent, not just "also present"); `published_at DESC` ordering verified with distinct timestamps; requested limit is enforced by the database query itself (`LIMIT`); empty result when nothing is eligible; full projection field verification (`id`, `originId`, `title`, `rules`, `publishedAt`) against a real row. All templates in these tests are owned by real `app_users` rows created via `AppUserService#findOrCreateGoogleUser`, satisfying `activity_templates`' foreign-key constraint on `created_by` (the pre-existing `savesAndLoadsActivityTemplate` test in this file uses a hardcoded UUID that happens to already exist in the shared dev database — the new tests instead create real owners, which is more robust and was necessary since none of the hardcoded UUID's assumptions are guaranteed for a fresh row set).

Manually verified against a running instance: anonymous `GET /api/templates/showcase` → `200 {"items":[]}` (no eligible templates in the local dev DB), `?limit=2` → `200`, `?limit=0` → `400 {"error":"BAD_REQUEST","message":"limit must be at least 1"}`, `?limit=abc` → `400`, `?limit=999` → `400 {"error":"BAD_REQUEST","message":"limit must not exceed 50"}` — no raw SQL/PostgreSQL error text exposed in any case.

---

## Important Constraints Check

No `ShowcaseController`/`Showcase` entity/aggregate/domain was created; the endpoint lives in `TemplateController` over `ActivityTemplate`. `public_activity_templates` is not used by this read path, and no synchronization mechanism was added for it. No CQRS infrastructure or cron-based projection sync was introduced. `12` is not hardcoded anywhere in the service/repository — it's a named default applied only when the client omits `limit`. The frontend's 10-minute cache duration was not copied into backend logic. The endpoint requires no authentication (`AppJwtPrincipal` is not used). No JPA entities are returned directly — only the `ShowcaseTemplateItem` projection DTO. No template rows are fetched unbounded and trimmed in Java — `LIMIT` is applied inside the native query. Template immutability semantics were not modified. No unrelated storage/infrastructure changes were made.
