# Tap Page APIs Migration Report

Report for the migration performed under `docs/tasks/011-tap-page-apis-migration.md`: `/api/tap/dashboard` and `/api/tap/tray` into the Spring Play domain.

---

## Migration Mapping

```text
Legacy:
GET /api/tap/dashboard

RPC:
get_tap_dashboard()

Spring:
GET /api/instances/dashboard

Primary resource:
ActivityInstance

Controller:
InstanceController
```

```text
Legacy:
GET /api/tap/tray

RPC:
get_today_tap_tray_cards(p_limit integer default 24)

Spring:
GET /api/tap-cards/tray

Primary resource:
TapCard

Controller:
TapCardController
```

Both were deliberately kept out of `TapController` — that controller is reserved for Tap-specific operations/aggregates (currently just `GET /api/taps/count`), not for the page they happen to be named after. Dashboard's primary resource is `ActivityInstance`; tray's primary resource is `TapCard`. Neither is a `Tap` in the domain sense.

---

## Part 1: Dashboard

```text
GET /api/instances/dashboard
    → InstanceController#dashboard(AppJwtPrincipal principal)
    → ActivityInstanceService#getDashboard(principal.userId())
    → ActivityInstanceRepository#findDashboardInstances(userId)
        (single native query: LATERAL join for latest tap, NOT EXISTS
         guard against any terminal challenge event)
    → mapped row-by-row into InstanceDashboardItem
    → InstanceDashboardResponse{ items }
```

### Legacy semantics (from `get_tap_dashboard()`, `LANGUAGE sql`)

* **Ownership**: `activity_instances.created_by = <current user>`.
* **Template ownership is also required**: the template join additionally requires `activity_templates.created_by = <current user>` — the dashboard only shows challenges the user created **from their own templates**, not instances started from someone else's public template. This is a real, deliberate filter in the RPC, not incidental, and is preserved exactly.
* **State filter**: `mode_kind = 'CHALLENGE'`, `state = 'ACTIVE'`, `completed_at IS NULL`, `terminated_at IS NULL`, `activity_instance_challenge_config.ref_state = 'PENDING'`, and — as a defensive belt-and-suspenders check — `NOT EXISTS` any of the 7 terminal challenge events (`REF_DECISION_SUCCESS/FAIL/DISAGREE`, `CHALLENGER_FINALIZED_SUCCESS/FAIL/CHICKEN/DISAGREE`) ever logged for the instance. All conditions preserved exactly, including the belt-and-suspenders `NOT EXISTS` even though it's currently unreachable via any write path in this codebase (matches the legacy RPC's own defensiveness).
* **Tap enrichment**: a `LEFT JOIN LATERAL` picks the single latest tap by `sequence_no DESC LIMIT 1`, regardless of its state (`OPENED` or `CANCELED`). **This is not specially "today's tap"** — the RPC has no date/timezone logic at all. Same-day-ness ("does this instance already have a tap today?") is a pure frontend UI derivation from `latestTap.firstHappenedAt` in the legacy TS code, and per this migration's instruction not to reproduce purely client-side derivations, it was **not** added to the Spring response — the client already has `latestTap.firstHappenedAt` and can compute this itself, exactly as it does today.
* **No Challenge-specific data fields are returned** — `activity_instance_challenge_config` is joined only to filter on `ref_state`, no fee/verdict/ref columns are selected. The Spring response matches: no challenge fields beyond what's needed to render the card.
* **Ordering**: `updated_at DESC, id DESC` — preserved exactly, including the deterministic tiebreak.
* **No limit** — returns every matching row; Spring does the same (dashboards are inherently small — one row per currently-active, undecided challenge a user owns).
* **Empty dashboard**: `200 { items: [] }`, not an error — matches Spring's behavior (empty list, no exception).

### Spring implementation notes

* `ActivityInstanceRepository#findDashboardInstances` is a native `@Query` (multi-table join + `LEFT JOIN LATERAL` + `NOT EXISTS`), following the same style already established by `TapCardRepository#findLeaderboard`/`#findPersonalFeed` — no JPA associations exist between these entities and no QueryDSL/jOOQ is available, so a single native query is the only route to this shape without N+1 fan-out per instance.
* `InstanceDashboardItem` is a new dedicated DTO (`id, modeKind, title, rules, photoPath, playContext, relationshipMode, proofKind, startedAt, updatedAt, latestTap`) — it reuses the existing `TapSummary` record for the tap sub-object instead of inventing a new one, since the fields are identical to what `PlayInstanceSummary` (the single-instance detail response) already uses.
* Visual "dashboard card" terminology was not allowed to leak into the model — the DTO/entity is `ActivityInstance`-centered throughout; nothing here is named or shaped like a `TapCard`.

---

## Part 2: Tray

```text
GET /api/tap-cards/tray
    → TapCardController#getTray(AppJwtPrincipal principal)
    → TapCardQueryService#getTray(principal.userId())
    → TapCardRepository#findTodayTray(userId, MAX_TRAY_ENTRIES=24)
        (single native query: today boundary computed in SQL,
         like/reply aggregation reusing the existing subquery pattern)
    → mapped row-by-row into TapCardTrayItem
    → TapCardTrayResponse{ items }
```

### Legacy semantics (from `get_today_tap_tray_cards(p_limit integer default 24)`, `LANGUAGE sql`)

* **"Today" boundary**: `timezone('America/New_York', tap_cards.created_at)::date = timezone('America/New_York', now())::date` — America/New_York wall-clock calendar day, computed fresh per call. This exactly matches the `TAP_DAY_ZONE = ZoneId.of("America/New_York")` constant already used by `ActivityInstanceService#isSameTapDay` elsewhere in this codebase, so the Spring tray query reuses the same timezone convention rather than introducing a second one — confirmed as an existing house decision, not something invented for this migration.
* **`app_users` join — confirmed unnecessary, not reproduced**: the legacy function has no direct join to `app_users` at all. Identity resolution went through a `current_app_user` CTE calling `app_user_id()` (itself backed by `app_users` internally, keyed off Supabase's `auth.uid()`). Since Spring resolves identity via `AppJwtPrincipal.userId` directly, this entire mechanism collapses to a single bind parameter (`ai.created_by = :userId`) — there was never a real `app_users` join to remove or keep; the "join" was purely an identity-resolution artifact of the Supabase session model.
* **`activity_instances` join — real, preserved**: supplies (a) ownership (`created_by`), (b) `activity_template_id` for the response, (c) the `deleted_at IS NULL` exclusion. All three purposes confirmed and kept.
* **Card/tap state filtering**: only `tap_cards.deleted_at IS NULL` and `activity_instances.deleted_at IS NULL` — no filtering on tap state or challenge/ref state. A card created today shows up in the tray even if its parent tap was later canceled or the challenge later finalized. Preserved exactly — no additional state filter was added.
* **Ordering**: `created_at DESC, id DESC` — preserved exactly.
* **Limit**: the legacy route always calls the RPC with a **hardcoded `24`** — never client-configurable, and no frontend UI path ever varies it. The task doc explicitly asks whether `24` is a domain invariant or a presentation constraint: it's the latter (a tray was designed to show at most 24 cards on one screen). Spring keeps it as a fixed internal constant (`TapCardQueryService.MAX_TRAY_ENTRIES = 24`) applied at the query boundary — no `limit` query parameter was added, since the task doc explicitly warns against introducing a client-configurable limit without a verified frontend need, and none exists.

### Template resolution — simplified from the legacy two-tier lookup

The legacy route did **not** join `activity_templates` in SQL at all. It queried templates separately in TypeScript with a two-tier fallback: first the user's **own** templates (`created_by = appUserId AND deleted_at IS NULL`), then — for any IDs still unresolved — `public_activity_templates` (no ownership restriction). This two-tier shape existed only because Supabase RLS let a regular client only `SELECT` template rows it owned; `public_activity_templates` existed specifically to expose published/public rows around that restriction.

In the Spring architecture there is no RLS boundary — the repository query has full table access, gated entirely by the controller/service layer, not per-row policies. Per the `public_activity_templates`-removal precedent already established in the showcase migration (task 009), the tray query instead does a **single, unrestricted `LEFT JOIN activity_templates`** by `activity_template_id`, filtered only by `deleted_at IS NULL` (matching what both legacy tiers ultimately guaranteed — neither tier ever surfaced a soft-deleted template's data). This is simpler and behaviorally equivalent for any real tap card, since `activity_template_id` already uniquely determines which template row to look up regardless of who authored it — the ownership check in the legacy code was an access-control artifact, not a data-selection rule.

**Also not reproduced**: the legacy response's `template.id` fallback chain (`template?.id ?? activity_template_id ?? activity_instance_id`) — if template resolution ever failed, the old response would eventually fall all the way back to the *instance* id in that field, which is a frontend display necessity, not a domain fact. Spring's DTO instead returns `template: null` when no template row is found — more honest than a fabricated identifier.

**Also not reproduced**: legacy's `toPublicUrl` storage-URL-building helper. Per the same convention already established for the leaderboard, personal feed, and showcase endpoints, `photoPath` fields are returned raw (`COALESCE(tap_cards.photo_path, activity_templates.photo_path)` for the top-level card image, and the template's own raw `photo_path` separately on the nested template object) — no server-side URL resolution.

### Response shape

`TapCardTrayItem`: `id, activityInstanceId, tapId, note, photoPath, createdAt, template (id/title/rules/photoPath, nullable), likeCount, replyCount`. `template` reuses the existing `PlayInstanceTemplateSummary` DTO rather than a new type, since the field set is identical. Like/reply counts are computed with the exact same `LEFT JOIN` aggregate subqueries already used by `findLeaderboard`/`findPersonalFeed` (`tap_card_likes` count, `tap_card_replies WHERE status = 'VISIBLE' AND deleted_at IS NULL` count) — reused verbatim, not re-derived, for consistency with the rest of the Play domain's read models. No `app_users` fields are returned anywhere in the response, per the task's explicit instruction.

---

## Frontend Caching

Both legacy fetches (`/api/tap/dashboard`, `/api/tap/tray`) use `cache: 'no-store'` at the fetch level and rely only on React Query's default in-memory caching — neither has an explicit `staleTime`/`refetchInterval` configured in the current frontend code, so the task doc's framing of "cached by the frontend" is true only in the loose default-React-Query-behavior sense, not a deliberate long-lived policy. Nothing was reproduced server-side; both Spring endpoints simply compute and return the current result on every call, per the task's explicit instruction.

---

## Tests

195 tests total (30 new), all passing against a real local Postgres database:

**Dashboard**:
* `ActivityInstanceServiceTest` (+4): delegates to the repository for the current user, empty-dashboard handling, row→DTO mapping with a latest tap present, row→DTO mapping with no tap (`latestTap` is `null`, not a fabricated default).
* `InstanceControllerTest` (+3): authenticated access returns correct shape, anonymous → `401`, empty dashboard → `200` with empty items.
* `ActivityInstanceRepositoryTest` (**new file**, 9 tests, against real inserted data): only the owner's own instances are returned (another user's are excluded); completed instances excluded; instances with a decided ref state excluded; instances with a terminal challenge event excluded (verifies the belt-and-suspenders `NOT EXISTS` clause actually works, not just that it's syntactically present); instances whose *template* is owned by someone else are excluded (the ownership-on-both-sides rule that's easy to get wrong); latest tap is included when one exists; `latestTap` is `null` when no tap exists; `updated_at DESC` ordering with two real timestamps; empty result when nothing is eligible.

**Tray**:
* `TapCardQueryServiceTest` (+5): delegates to the repository with the fixed `24` limit for the current user, empty-tray handling, row→DTO mapping including template and like/reply counts, missing-template maps to `null` (not a fabricated instance-id fallback).
* `TapCardControllerTest` (+3): authenticated access returns correct shape (including the nested `template.title`), anonymous → `401`, empty tray → `200` with empty items.
* `TapCardRepositoryTest` (+7, against real inserted data): only the current user's cards are returned; cards not created "today" (America/New_York, verified with a card backdated 2 days) are excluded; soft-deleted cards excluded; empty result when nothing exists; `created_at DESC` ordering with two real timestamps 30 minutes apart; the database `LIMIT` is enforced (3 cards created, limit 2 requested, exactly 2 returned); full projection verification (note, like count, reply count, template id/title) against real inserted likes and a real inserted reply.

---

## Important Constraints Check

No backend `Dashboard` or `Tray` domain/entity was created. `InstanceController` owns the dashboard; `TapCardController` owns the tray — neither was placed in `TapController` merely because the frontend page is `/tap`. Dashboard UI cards were never modeled as `tap_cards` anywhere in the entity/DTO layer — `InstanceDashboardItem` is `ActivityInstance`-shaped throughout, and the domain distinction (`ActivityInstance` → participation rendered as a tappable card; `ActivityTap` → an interaction within that participation; `TapCard` → actual behavioral content shown in the tray) is preserved in both the code and this report. Identity comes exclusively from `AppJwtPrincipal.userId` in both endpoints — no OIDC `sub`, email, or client-supplied user id is accepted anywhere. The unnecessary `app_users`/`current_app_user` identity-resolution mechanism was dropped (confirmed it supplied no response data); the `activity_instances` join in the tray query was kept (confirmed it supplies real ownership, template-id, and deletion-exclusion data). `24` was not spread into entity/domain logic — it's a named query-boundary constant (`TapCardQueryService.MAX_TRAY_ENTRIES`), not an entity invariant, and no client-configurable limit was introduced without a verified need. Frontend cache behavior was not reproduced in Spring. No JPA entities are returned directly anywhere — only DTOs. No N+1 read assembly was introduced — both endpoints are single native queries. Tap/Instance/Card domain semantics were not changed to simplify the route structure.
