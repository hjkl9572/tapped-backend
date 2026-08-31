# Spring Migration — API Spec Extraction & Target Structure

Status: **draft** — extraction template + inventory only. Endpoint specs get filled in incrementally, not hand-written all at once.

## Goal

Migrate `playTemplate` and `playInstance` Next.js API routes (`src/app/api/playTemplate/**`, `src/app/api/playInstance/**`) to Spring RESTful controllers. Target resource roots:

- `/api/template` (was `playTemplate`)
- `/api/instance` (was `playInstance`)

Action-style sub-paths (`/create`, `/draft/discard`, `/challenger-decision/chicken`, ...) collapse into HTTP-verb-based CRUD plus a small number of sub-resource actions where the operation genuinely isn't CRUD (state transitions, decisions).

This doc has two jobs:

1. A **repeatable extraction template** for pulling payload/response/error specs out of a Next.js route file, so specs get produced mechanically per file instead of redesigned by hand each time.
2. A **migration inventory** — every route file in scope, with its target Spring endpoint, tracked to done/not-done.

## Cross-Cutting Conventions (extract once, reference everywhere)

These repeat across almost every route, so they're captured once here instead of per endpoint.

### Auth

**Spring does not depend on Supabase auth at all.** The Spring server is its own OAuth2 client (Google login) and its own resource server: it issues and decodes its own JWTs and builds a custom `Principal`/`Authentication` object for Spring Security from the decoded claims. The Next.js guards below describe *current* behavior for extraction purposes only — none of the Supabase-specific mechanics (the `app_user_id()` RPC, the `app_auth_sessions` table check, Supabase's own session object) carry over. What carries over is the **shape of the guarantee** each guard makes, which the JWT-based auth filter needs to reproduce some other way.

Source: `src/app/api/_lib/authGuard.ts`

| Next.js primitive | What it does | Spring equivalent |
|---|---|---|
| `requireActiveAppSession(request)` | CSRF same-origin check + Supabase session validation + resolves `appUserId` via `app_user_id()` RPC + checks session not superseded | JWT auth filter validates/decodes the token; `appUserId` comes straight from a claim on the custom principal, no DB round-trip. "Session not superseded" has no direct equivalent yet — see open questions |
| `requireVerifiedAppSession(request)` | Same as above minus the "session not superseded" check | Same JWT filter, no extra check |
| `requirePlayInstanceAppUser(supabase, request)` (`playInstance/_lib/rpc.ts`) | playInstance-scoped variant of the same guard | Same pattern, scoped to instance controllers |
| plain `supabase.auth.getUser()` (used in read-only GETs, e.g. `[playInstanceId]/route.ts`) | No CSRF check — reads skip origin validation | `@GetMapping` methods only need the JWT filter, not CSRF |
| `assertSameOriginMutation` (CSRF) | Applied to all mutating (non-GET) routes | Likely unnecessary if the resource server takes bearer tokens over `Authorization` header rather than cookies — see open questions |

Per-endpoint spec should just record **which guard variant** is used, not restate this table.

### Error envelope

Every mutation route follows the same shape: catch block → map an internal error signal (thrown `Error(message)` or a typed `AppAuthError`) → `{ status, body: { error } }`. See `playTemplate/_lib/mutations.ts:mutationErrorToResponse` and `playInstance/_lib/rpc.ts:playInstanceRpcErrorToResponse` for the canonical switch statements.

Spring target: a `@ControllerAdvice` / `@ExceptionHandler` mapping a small set of typed exceptions (`UnauthorizedException`, `InvalidPayloadException`, `SessionSupersededException`, etc.) to the same status codes, so the per-endpoint spec only needs to list which named errors that endpoint can throw — not redefine the mapping.

Known status codes in use today: `400` (invalid payload / no profile), `401` (unauthorized), `403` (bad origin), `409` (session conflict), `429` (rate limit), `500` (RPC/db failure), `503` (session check unavailable).

### Response envelope (inconsistent today — needs a decision, not just extraction)

Observed shapes across routes, verbatim:

- `{ ok: true, template_id, photo_path, lifecycle_state }` (`playTemplate/create/challenge`)
- `{ data: {...} }` (`playInstance/[playInstanceId]`)
- `{ play_instance_id }` (`playInstance/challenge/create`)
- `{ ok: true, data: {...} }` (`playInstance/[playInstanceId]/tap`)
- `{ presets: [...] }` (`playTemplate/catalog`)
- `{ error: string, details?: ... }` (all error paths)

This is flagged as an **open question** below — pick one envelope for Spring (e.g. always `{ data, error }`) before generating DTOs, rather than preserving each route's ad-hoc shape.

### Payload parsing

Zod schemas define most request bodies (`playTemplate/_lib/mutations.ts`, `@/lib/validators`). Path params are also Zod-validated (`z.object({ playInstanceId: z.string().uuid() })`).

Spring target: Zod schema → `record`/DTO with Bean Validation annotations (`@NotBlank`, `@Size`, `@Pattern` for uuid, etc).

### File uploads (image storage is out of scope for Spring's API surface)

Today, `playTemplate/_lib/mutations.ts:uploadTemplatePhoto` accepts the raw file as part of the request (multipart form) and uploads it to Supabase Storage (`template-assets-public` bucket) *inside* the Next.js route, then passes the resulting path into the RPC call alongside the rest of the payload.

For the Spring migration, that upload step stays outside Spring entirely — Spring never receives file bytes:

- The image is uploaded to object storage first (Supabase Storage for now, S3 later — that swap is orthogonal to this migration and doesn't change Spring's contract either way).
- Spring's create/update endpoints only ever accept a resolved `photoPath`/`photoUrl` **string field** in the JSON body, the same as every other field. No `multipart/form-data` content type, no `@RequestPart`, no storage SDK dependency in the Spring service.
- Practical effect on extraction: when a Next.js route's multipart branch exists only to relay a file for upload, the corresponding Spring spec should drop the file field entirely and just list the string path field from the JSON branch. See the worked example below.
- Open question: what layer does the upload before calling Spring — see open questions section.

## Per-Endpoint Extraction Template

Copy this block per route file. Keep it terse — this is a spec, not prose documentation.

```md
### <METHOD> <current-nextjs-path>  →  <METHOD> <proposed-spring-path>

- **Source**: `src/app/api/.../route.ts`
- **Auth**: <guard used, or "none">
- **Path params**: <name: type, validation>
- **Query params**: <name: type, required?, default>
- **Request body**:
  | field | type | required | notes |
  |---|---|---|---|
- **Success response**: `<status>`
  | field | type | notes |
  |---|---|---|
- **Errors**:
  | condition | status | body |
  |---|---|---|
- **Side effects**: <RPCs called, tables touched, storage writes>
- **Notes**: <anything that doesn't fit a REST verb cleanly, e.g. multipart handling, idempotency keys>
```

## Worked Example

### POST `/api/playTemplate/create/challenge` → POST `/api/template`

- **Source**: `src/app/api/playTemplate/create/challenge/route.ts` (+ `playTemplate/_lib/mutations.ts`)
- **Auth**: `requireActiveAppSession` (CSRF + session + `appUserId`)
- **Path params**: none
- **Query params**: none
- **Request body** (`finishMutationSchema`; Next.js accepts JSON or multipart, Spring target is JSON-only, see below):
  | field | type | required | notes |
  |---|---|---|---|
  | templateId | uuid | no | generated server-side if absent |
  | title | string (1–100) | yes | |
  | rules | string (≤4000) | no | defaults to `''` |
  | visibility | `PUBLIC` \| `PRIVATE` | no | defaults to `PRIVATE` |
  | lifecycleState | literal `PUBLISHED` | yes | this route only accepts PUBLISHED; DRAFT goes through a different route |
  | modes | object | no | defaults to `{}`; `modes.challenge` holds `currency`, `ref_email`, `fail_card_fee_minor`, `ref_required` |
  | schedule.startAt / schedule.endAt | ISO datetime, nullable | no | |
  | photoPath | string (uri), nullable | no | in Next.js today this comes from a multipart `photo` file uploaded server-side to `template-assets-public`; in the Spring target the upload already happened before this call, so the field is just the resulting path/URL — see "File uploads" above |
- **Success response**: `200`
  | field | type | notes |
  |---|---|---|
  | ok | boolean | always `true` on success |
  | template_id | string \| null | |
  | photo_path | string \| null | public URL |
  | lifecycle_state | string | echoes request |
- **Errors**:
  | condition | status | body |
  |---|---|---|
  | not authenticated | 401 | `{ error: "Unauthorized" }` |
  | bad origin (CSRF) | 403 | `{ error: "Invalid request origin." }` |
  | session superseded | 409 | `{ error: "Session was superseded by another login." }` |
  | no app profile | 400 | `{ error: "Profile not found. Complete onboarding first." }` |
  | schema validation fails / lifecycleState !== PUBLISHED | 400 | `{ error: "Invalid payload" }` |
  | unsupported image type | 400 | `{ error: "Only JPEG, PNG, or WEBP images are supported." }` |
  | storage upload fails | 500 | `{ error: "Failed to upload the template image." }` |
  | RPC `create_challenge_template` fails | 500 | `{ error: "Failed to save challenge play template." }` |
- **Side effects**: uploads photo to Supabase Storage bucket `template-assets-public` (if provided), then calls RPC `create_challenge_template` with the mapped `p_*` args (fixed to `p_proof_kind='ANY'`, `p_play_context='ONLINE'`, `p_relationship_mode='SOLO'`, `p_min_participants=1`, `p_max_participants=1`).
- **Notes**: this is the "challenge mode" variant of template creation. Sibling routes `playTemplate/create/route.ts` (generic) and `playTemplate/create-and-play/challenge/route.ts` (create + launch instance in one call) cover the same field set with different RPCs — worth deciding whether Spring collapses these into one `POST /api/template` with a `mode` field, or keeps `POST /api/template` + `POST /api/template/{id}/play` as two calls. See open questions.

## Proposed Verb/Path Mapping

Draft convention — CRUD via HTTP verbs on the resource root, non-CRUD state transitions become `POST /api/<resource>/{id}/<action>`.

| Next.js route | Proposed Spring endpoint |
|---|---|
| `POST playTemplate/create` | `POST /api/template` |
| `POST playTemplate/create/challenge` | `POST /api/template` (mode in body, see worked example notes) |
| `POST playTemplate/create-and-play` | `POST /api/template/{id}/play` or folded into instance creation |
| `POST playTemplate/create-and-play/challenge` | same as above, challenge mode |
| `GET playTemplate/catalog` | `GET /api/template` (public list) |
| `POST playTemplate/draft/create` | `POST /api/template` with `lifecycleState=DRAFT` |
| `POST playTemplate/draft/discard` | `DELETE /api/template/{id}` |
| `GET playTemplate/draft/latest` | `GET /api/template/drafts/latest` |
| `GET playInstance/[id]` | `GET /api/instance/{id}` |
| `POST playInstance/challenge/create` | `POST /api/instance` |
| `POST playInstance/challenge/notify` | `POST /api/instance/{id}/notifications` |
| `GET/POST playInstance/challenge/payment/checkout` | `POST /api/instance/{id}/payment/checkout` |
| `POST playInstance/challenge/challenger-decision/{chicken,cover,dispute,success}` | `POST /api/instance/{id}/challenger-decision` (decision type in body) |
| `POST playInstance/challenge/ref-decision/decision` | `POST /api/instance/{id}/ref-decision` |
| `.../ref-decision/{resend,session,verify}` | `POST/GET /api/instance/{id}/ref-decision/{resend,session,verify}` (token-based, may stay separate — not app-session auth) |
| `POST playInstance/draft/discard` | `DELETE /api/instance/{id}` (draft state) |
| `GET playInstance/draft/latest` | `GET /api/instance/drafts/latest` |
| `POST playInstance/draft/match` | TBD — needs spec extraction, unclear if CRUD-shaped |
| `GET playInstance/rules` | `GET /api/instance/{id}/rules` |
| `GET/POST playInstance/schedule` | `GET/PUT /api/instance/{id}/schedule` |
| `POST playInstance/[id]/tap` | `POST /api/instance/{id}/taps` |
| `.../tap/[tapId]` | `GET/PUT /api/instance/{id}/taps/{tapId}` |
| `.../tap/[tapId]/card` | `GET /api/instance/{id}/taps/{tapId}/card` |

This table is a first pass, not final — revise freely per endpoint as specs get extracted; several rows (draft/match, ref-decision token flows) need their own route read before the mapping is trustworthy.

## Migration Inventory

Tracks every file in scope. Update `Status` as specs get extracted (`todo` → `extracted` → `reviewed`).

| Source file | Status |
|---|---|
| `playTemplate/create/route.ts` | todo |
| `playTemplate/create/challenge/route.ts` | **extracted** (worked example above) |
| `playTemplate/create-and-play/route.ts` | todo |
| `playTemplate/create-and-play/challenge/route.ts` | todo |
| `playTemplate/catalog/route.ts` | todo |
| `playTemplate/draft/create/route.ts` | todo |
| `playTemplate/draft/discard/route.ts` | todo |
| `playTemplate/draft/latest/route.ts` | todo |
| `playInstance/[playInstanceId]/route.ts` | todo |
| `playInstance/[playInstanceId]/tap/route.ts` | todo |
| `playInstance/[playInstanceId]/tap/[tapId]/route.ts` | todo |
| `playInstance/[playInstanceId]/tap/[tapId]/card/route.ts` | todo |
| `playInstance/challenge/create/route.ts` | todo |
| `playInstance/challenge/notify/route.ts` | todo |
| `playInstance/challenge/payment/checkout/route.ts` | todo |
| `playInstance/challenge/challenger-decision/chicken/route.ts` | todo |
| `playInstance/challenge/challenger-decision/cover/route.ts` | todo |
| `playInstance/challenge/challenger-decision/cover/select/route.ts` | todo |
| `playInstance/challenge/challenger-decision/dispute/route.ts` | todo |
| `playInstance/challenge/challenger-decision/fail/no-payment/route.ts` | todo |
| `playInstance/challenge/challenger-decision/success/route.ts` | todo |
| `playInstance/challenge/ref-decision/decision/route.ts` | todo |
| `playInstance/challenge/ref-decision/resend/route.ts` | todo |
| `playInstance/challenge/ref-decision/session/route.ts` | todo |
| `playInstance/challenge/ref-decision/verify/route.ts` | todo |
| `playInstance/draft/discard/route.ts` | todo |
| `playInstance/draft/latest/route.ts` | todo |
| `playInstance/draft/match/route.ts` | todo |
| `playInstance/rules/route.ts` | todo |
| `playInstance/schedule/route.ts` | todo |

## Open Questions

- **Response envelope**: standardize on one shape for Spring (likely `{ data, error }`) instead of preserving each route's current shape (`{ ok, ... }` / `{ data }` / bare fields)?
- **Template creation collapse**: should `/create`, `/create/challenge`, `/create-and-play`, `/create-and-play/challenge` become one `POST /api/template` with a `mode` discriminator, or stay as separate operations exposed differently in Spring (e.g. `POST /api/template` + `POST /api/template/{id}/play`)?
- **Token-based ref-decision routes** (`resend`, `session`, `verify`): these authenticate via a token in the URL/body, not `requireActiveAppSession`. Do they belong under `/api/instance/{id}/ref-decision/*`, or are they a separate unauthenticated-by-session resource (e.g. `/api/ref-decisions/{token}`)?
- **Draft vs published as the same resource**: is a draft template the same resource as a published one (`lifecycleState` field), or a distinct sub-resource (`/api/template/drafts`)? Affects whether `discard`/`latest` map onto `/api/template` or a separate path.
- **RPC-per-endpoint mapping**: several endpoints call more than one Supabase RPC (photo upload + RPC, or RPC + fallback query as in the tap route's `TAP_ALREADY_RECORDED_TODAY` handling). Spring's service-layer equivalent needs to preserve that fallback behavior — flag these during extraction rather than assuming a 1:1 RPC-to-endpoint mapping.
- **Who uploads the image before calling Spring**: does the client upload straight to Supabase Storage (later S3) and call Spring directly with the resulting path, or does Next.js stay in the loop as a thin upload proxy in front of Spring? Determines whether Spring needs a presigned-URL/upload-ticket endpoint at all, or truly never sees the upload step.
- **Single active session enforcement**: `requireActiveAppSession` today rejects a request if `app_auth_sessions.auth_session_id` doesn't match the caller's session (i.e. logging in elsewhere invalidates the old session). Does the Spring/JWT setup need an equivalent "only one active session per user" rule, or is that dropped in favor of normal JWT expiry/refresh-token rotation?
- **CSRF under JWT auth**: `assertSameOriginMutation` exists because the current setup can be cookie-based. If Spring's resource server takes bearer tokens via `Authorization` header only (no cookies), CSRF protection is likely unnecessary — confirm the token transport before dropping it from the migrated endpoints.
