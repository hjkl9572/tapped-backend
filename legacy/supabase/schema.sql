

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."activity_challenger_final_verdict" AS ENUM (
    'SUCCESS',
    'FAIL',
    'CHICKEN',
    'DISPUTE'
);


ALTER TYPE "public"."activity_challenger_final_verdict" OWNER TO "postgres";


CREATE TYPE "public"."activity_instance_state" AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'TERMINATED'
);


ALTER TYPE "public"."activity_instance_state" OWNER TO "postgres";


CREATE TYPE "public"."activity_mode_kind" AS ENUM (
    'CHALLENGE'
);


ALTER TYPE "public"."activity_mode_kind" OWNER TO "postgres";


CREATE TYPE "public"."activity_ref_state" AS ENUM (
    'PENDING',
    'DECIDED'
);


ALTER TYPE "public"."activity_ref_state" OWNER TO "postgres";


CREATE TYPE "public"."activity_ref_verdict" AS ENUM (
    'SUCCESS',
    'FAIL'
);


ALTER TYPE "public"."activity_ref_verdict" OWNER TO "postgres";


CREATE TYPE "public"."activity_tap_state" AS ENUM (
    'OPENED',
    'CANCELED'
);


ALTER TYPE "public"."activity_tap_state" OWNER TO "postgres";


CREATE TYPE "public"."auth_provider" AS ENUM (
    'google',
    'apple',
    'demo',
    'email',
    'other'
);


ALTER TYPE "public"."auth_provider" OWNER TO "postgres";


CREATE TYPE "public"."challenge_event_type" AS ENUM (
    'MAIL_SENT',
    'MAIL_FAILED',
    'MAIL_TOKEN_CREATED',
    'REF_DECISION_SUCCESS',
    'REF_DECISION_FAIL',
    'REF_DECISION_DISAGREE',
    'MAIL_TOKEN_CREATED_FAILED',
    'CHALLENGER_FINALIZED_SUCCESS',
    'CHALLENGER_FINALIZED_FAIL',
    'CHALLENGER_FINALIZED_CHICKEN',
    'CHALLENGER_FINALIZED_DISAGREE'
);


ALTER TYPE "public"."challenge_event_type" OWNER TO "postgres";


CREATE TYPE "public"."challenge_status" AS ENUM (
    'FORM',
    'CONSENTED',
    'MAIL_QUEUED',
    'MAIL_FAILED',
    'MAIL_SENT',
    'WATCHER_MARKED_SUCCESS',
    'WATCHER_MARKED_FAIL',
    'CHALLENGER_FINAL_SUCCESS',
    'CHALLENGER_FINAL_FAIL',
    'CHALLENGER_FINAL_DISAGREE',
    'CANCELLED',
    'EXPIRED_WATCHER',
    'EXPIRED_CHALLENGER'
);


ALTER TYPE "public"."challenge_status" OWNER TO "postgres";


CREATE TYPE "public"."consent_type" AS ENUM (
    'off_session',
    'tos',
    'privacy',
    'cross_border',
    'other'
);


ALTER TYPE "public"."consent_type" OWNER TO "postgres";


CREATE TYPE "public"."content_status" AS ENUM (
    'VISIBLE',
    'HIDDEN',
    'PENDING_REVIEW'
);


ALTER TYPE "public"."content_status" OWNER TO "postgres";


CREATE TYPE "public"."deleted_by" AS ENUM (
    'OWNER',
    'ADMIN'
);


ALTER TYPE "public"."deleted_by" OWNER TO "postgres";


CREATE TYPE "public"."email_job_types" AS ENUM (
    'CHALLENGER_TO_WATCHER',
    'WATCHER_TO_CHALLENGER',
    'GENERIC'
);


ALTER TYPE "public"."email_job_types" OWNER TO "postgres";


CREATE TYPE "public"."email_provider" AS ENUM (
    'RESEND',
    'SENDGRID',
    'POSTMARK'
);


ALTER TYPE "public"."email_provider" OWNER TO "postgres";


CREATE TYPE "public"."email_status" AS ENUM (
    'QUEUED',
    'SENDING',
    'SENT',
    'FAILED',
    'DEAD'
);


ALTER TYPE "public"."email_status" OWNER TO "postgres";


CREATE TYPE "public"."moderation_action_type" AS ENUM (
    'HIDE',
    'UNHIDE',
    'SOFT_DELETE',
    'WARN',
    'BAN_USER'
);


ALTER TYPE "public"."moderation_action_type" OWNER TO "postgres";


CREATE TYPE "public"."payer_decision" AS ENUM (
    'APPROVE_PAY',
    'DECLINE_PAY'
);


ALTER TYPE "public"."payer_decision" OWNER TO "postgres";


CREATE TYPE "public"."payment_attempt_status" AS ENUM (
    'SCHEDULED',
    'OPENED',
    'REQUIRES_ACTION',
    'FAILED',
    'ABANDONED',
    'COMPLETED',
    'REQUESTED'
);


ALTER TYPE "public"."payment_attempt_status" OWNER TO "postgres";


CREATE TYPE "public"."payment_provider" AS ENUM (
    'LEMON_SQUEEZY',
    'STRIPE'
);


ALTER TYPE "public"."payment_provider" OWNER TO "postgres";


CREATE TYPE "public"."payment_status" AS ENUM (
    'INIT',
    'SUCCEEDED',
    'FAILED',
    'CANCELED',
    'CHECKOUT_CREATED',
    'PENDING',
    'ABANDONED',
    'REFUNDED',
    'PARTIALLY_REFUNDED'
);


ALTER TYPE "public"."payment_status" OWNER TO "postgres";


CREATE TYPE "public"."report_target_type" AS ENUM (
    'CHALLENGE_CARD',
    'PROFILE',
    'CHALLENGE'
);


ALTER TYPE "public"."report_target_type" OWNER TO "postgres";


CREATE TYPE "public"."signed_link_type" AS ENUM (
    'WATCHER_VERDICT',
    'PAYER_DECISION'
);


ALTER TYPE "public"."signed_link_type" OWNER TO "postgres";


CREATE TYPE "public"."suggestion_status" AS ENUM (
    'FORM',
    'SENT',
    'ACCEPTED',
    'DECLINED',
    'EXPIRED',
    'CANCELLED'
);


ALTER TYPE "public"."suggestion_status" OWNER TO "postgres";


CREATE TYPE "public"."template_lifecycle_state" AS ENUM (
    'DRAFT',
    'PUBLISHED',
    'ARCHIVED'
);


ALTER TYPE "public"."template_lifecycle_state" OWNER TO "postgres";


CREATE TYPE "public"."template_play_context" AS ENUM (
    'OFFLINE',
    'ONLINE',
    'HYBRID'
);


ALTER TYPE "public"."template_play_context" OWNER TO "postgres";


CREATE TYPE "public"."template_relationship_mode" AS ENUM (
    'SOLO',
    'DUEL_1V1',
    'HOST_1_TO_MANY',
    'GROUP_MANY_TO_MANY'
);


ALTER TYPE "public"."template_relationship_mode" OWNER TO "postgres";


CREATE TYPE "public"."template_visibility" AS ENUM (
    'PUBLIC',
    'PRIVATE'
);


ALTER TYPE "public"."template_visibility" OWNER TO "postgres";


CREATE TYPE "public"."tutorial_step_state" AS ENUM (
    'FORM',
    'SUMMARY',
    'LAUNCH',
    'TAP',
    'FINISHED'
);


ALTER TYPE "public"."tutorial_step_state" OWNER TO "postgres";


CREATE TYPE "public"."verdict" AS ENUM (
    'SUCCESS',
    'FAIL',
    'DISAGREE'
);


ALTER TYPE "public"."verdict" OWNER TO "postgres";


CREATE TYPE "public"."webhook_proc_status" AS ENUM (
    'RECEIVED',
    'APPLIED',
    'DUPLICATE',
    'SKIPPED',
    'ERROR'
);


ALTER TYPE "public"."webhook_proc_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."_insert_challenge_template_core"("p_template_id" "uuid", "p_title" "text", "p_rules" "text" DEFAULT NULL::"text", "p_photo_url" "text" DEFAULT NULL::"text", "p_visibility" "public"."template_visibility" DEFAULT 'PUBLIC'::"public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state" DEFAULT 'DRAFT'::"public"."template_lifecycle_state", "p_idempotency_key" "text" DEFAULT NULL::"text", "p_creator_display_name" "text" DEFAULT NULL::"text", "p_cadence_hint" "text" DEFAULT NULL::"text", "p_proof_kind" "text" DEFAULT 'ANY'::"text", "p_play_context" "public"."template_play_context" DEFAULT 'OFFLINE'::"public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode" DEFAULT 'SOLO'::"public"."template_relationship_mode", "p_min_participants" smallint DEFAULT NULL::smallint, "p_max_participants" smallint DEFAULT NULL::smallint, "p_challenge_currency" "text" DEFAULT NULL::"text", "p_challenge_ref_email" "text" DEFAULT NULL::"text", "p_challenge_fail_card_fee_minor" integer DEFAULT NULL::integer, "p_challenge_ref_required" boolean DEFAULT NULL::boolean) RETURNS TABLE("template_id" "uuid", "published_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$declare
  v_app_user_id uuid;
  v_now timestamptz;
  v_published_at timestamptz;
begin
  v_app_user_id := app_user_id();
  v_now := now();

  if v_app_user_id is null then
    raise exception 'app_user_id() returned null';
  end if;

  if p_lifecycle_state not in ('DRAFT', 'PUBLISHED') then
    raise exception 'invalid lifecycle_state: %, allowed: DRAFT, PUBLISHED', p_lifecycle_state;
  end if;

  if p_title is null or length(trim(p_title)) = 0 then
    raise exception 'title is required';
  end if;

  if p_proof_kind not in ('NONE', 'TEXT', 'PHOTO', 'LINK', 'ANY') then
    raise exception 'invalid proof_kind: %', p_proof_kind;
  end if;

  if p_min_participants is not null and p_min_participants < 1 then
    raise exception 'min_participants must be >= 1';
  end if;

  if p_max_participants is not null and p_max_participants < 1 then
    raise exception 'max_participants must be >= 1';
  end if;

  if p_min_participants is not null
     and p_max_participants is not null
     and p_min_participants > p_max_participants then
    raise exception 'min_participants cannot be greater than max_participants';
  end if;

  v_published_at :=
    case
      when p_lifecycle_state = 'PUBLISHED' then v_now
      else null
    end;

  insert into public.activity_templates (
    id,
    origin_id,
    parent_id,
    title,
    rules,
    photo_path,
    lifecycle_state,
    cadence_hint,
    proof_kind,
    visibility,
    status,
    curation_bucket,
    play_context,
    relationship_mode,
    created_by,
    idempotency_key,
    creator_display_name,
    created_at,
    updated_at,
    updated_by,
    deleted_at,
    deleted_by,
    min_participants,
    max_participants,
    mode_kind,
    published_at
  )
  values (
    p_template_id,
    p_template_id,
    null,
    trim(p_title),
    nullif(trim(coalesce(p_rules, '')), ''),
    p_photo_url,
    p_lifecycle_state,
    nullif(trim(coalesce(p_cadence_hint, '')), ''),
    p_proof_kind,
    p_visibility,
    'ACTIVE',
    null,
    p_play_context,
    p_relationship_mode,
    v_app_user_id,
    nullif(trim(coalesce(p_idempotency_key, '')), ''),
    nullif(trim(coalesce(p_creator_display_name, '')), ''),
    v_now,
    v_now,
    v_app_user_id,
    null,
    null,
    p_min_participants,
    p_max_participants,
    'CHALLENGE',
    v_published_at
  );

  insert into public.activity_template_challenge_config (
    activity_template_id,
    currency,
    ref_email,
    fail_card_fee_minor,
    ref_required
  )
  values (
    p_template_id,
    coalesce(nullif(trim(coalesce(p_challenge_currency, '')), ''), 'KRW'),
    nullif(trim(coalesce(p_challenge_ref_email, '')), ''),
    p_challenge_fail_card_fee_minor,
    coalesce(p_challenge_ref_required, false)
  );

  if p_lifecycle_state = 'PUBLISHED' then
    insert into public.public_activity_templates (
      id,
      origin_id,
      parent_id,
      title,
      rules,
      photo_path,
      cadence_hint,
      proof_kind,
      play_context,
      relationship_mode,
      created_by,
      creator_display_name,
      min_participants,
      max_participants,
      mode_kind,
      published_at
    )
    values (
      p_template_id,
      p_template_id,
      null,
      trim(p_title),
      nullif(trim(coalesce(p_rules, '')), ''),
      p_photo_url,
      nullif(trim(coalesce(p_cadence_hint, '')), ''),
      p_proof_kind,
      p_play_context,
      p_relationship_mode,
      v_app_user_id,
      nullif(trim(coalesce(p_creator_display_name, '')), ''),
      p_min_participants,
      p_max_participants,
      'CHALLENGE',
      v_published_at
    );
  end if;

  return query
  select p_template_id, v_published_at;
end;$$;


ALTER FUNCTION "public"."_insert_challenge_template_core"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."abandon_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_TAP_MODE';
  end if;

  return public.abandon_tap_card_shell(
    p_activity_instance_id,
    p_tap_id,
    p_card_id
  );
end;
$$;


ALTER FUNCTION "public"."abandon_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."abandon_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  update public.tap_cards tc
  set
    deleted_at = coalesce(tc.deleted_at, now()),
    updated_at = now()
  where tc.id = p_card_id
    and tc.activity_instance_id = p_activity_instance_id
    and tc.tap_id = p_tap_id
    and tc.created_by = v_app_user_id;

  return found;
end;
$$;


ALTER FUNCTION "public"."abandon_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_legal_both"("p_tos_id" "uuid", "p_privacy_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();
  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  insert into public.tos_acceptances (user_id, tos_id, accepted_at, expired_at)
  values (v_app_user_id, p_tos_id, now(), null)
  on conflict (user_id, tos_id) do update
    set accepted_at = excluded.accepted_at,
        expired_at = excluded.expired_at;

  insert into public.privacy_policy_acceptances (user_id, policy_id, accepted_at, expired_at)
  values (v_app_user_id, p_privacy_id, now(), null)
  on conflict (user_id, policy_id) do update
    set accepted_at = excluded.accepted_at,
        expired_at = excluded.expired_at;
end;
$$;


ALTER FUNCTION "public"."accept_legal_both"("p_tos_id" "uuid", "p_privacy_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_legal_both_for_app_user"("p_app_user_id" "uuid", "p_tos_id" "uuid", "p_privacy_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if p_app_user_id is null or not exists (
    select 1
    from public.app_users u
    where u.id = p_app_user_id
      and u.deleted_at is null
  ) then
    raise exception 'UNAUTHORIZED';
  end if;

  insert into public.tos_acceptances (user_id, tos_id, accepted_at, expired_at)
  values (p_app_user_id, p_tos_id, now(), null)
  on conflict (user_id, tos_id) do update
    set accepted_at = excluded.accepted_at,
        expired_at = excluded.expired_at;

  insert into public.privacy_policy_acceptances (user_id, policy_id, accepted_at, expired_at)
  values (p_app_user_id, p_privacy_id, now(), null)
  on conflict (user_id, policy_id) do update
    set accepted_at = excluded.accepted_at,
        expired_at = excluded.expired_at;
end;
$$;


ALTER FUNCTION "public"."accept_legal_both_for_app_user"("p_app_user_id" "uuid", "p_tos_id" "uuid", "p_privacy_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."acknowledge_challenge_success"("p_instance_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_cover_tap_id uuid;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_now timestamptz := now();
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  if not exists (
    select 1
    from public.activity_instances ai
    join public.activity_instance_challenge_config aicc
      on aicc.activity_instance_id = ai.id
    where ai.id = p_instance_id
      and ai.created_by = v_app_user_id
      and ai.deleted_at is null
      and ai.state = 'ACTIVE'::public.activity_instance_state
      and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
      and aicc.ref_state = 'DECIDED'::public.activity_ref_state
      and aicc.ref_verdict = 'SUCCESS'::public.activity_ref_verdict
      and exists (
        select 1
        from public.activity_instance_challenge_mail_tokens mt
        where mt.activity_instance_id = ai.id
          and mt.action = 'ref_access'
          and mt.invalidated_at is null
      )
      and (
        select e.event_type
        from public.activity_instance_challenge_events e
        where e.activity_instance_id = ai.id
        order by e.created_at desc, e.id desc
        limit 1
      ) = 'REF_DECISION_SUCCESS'::public.challenge_event_type
  ) then
    raise exception 'INSTANCE_NOT_ACTIVE';
  end if;

  select tc.id
  into v_cover_tap_id
  from public.tap_cards tc
  where tc.activity_instance_id = p_instance_id
    and tc.deleted_at is null
  order by tc.sequence_no desc, tc.created_at desc, tc.id desc
  limit 1;

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      cover_card_id = coalesce(ai.cover_card_id, v_cover_tap_id),
      updated_at = v_now
  where ai.id = p_instance_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'SUCCESS'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
    jsonb_build_object('cover_card_id', v_cover_tap_id)
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."acknowledge_challenge_success"("p_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."app_user_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select id
  from public.app_users
  where auth_id = auth.uid()
    and deleted_at is null
$$;


ALTER FUNCTION "public"."app_user_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."attach_challenge_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") RETURNS TABLE("id" "uuid", "note" "text", "photo_path" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_terminal_event public.activity_instance_challenge_events%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_TAP_MODE';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'INSTANCE_DELETED';
  end if;

  if v_instance.state <> 'ACTIVE'::public.activity_instance_state
     or v_instance.completed_at is not null
     or v_instance.terminated_at is not null then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  if v_config.ref_state = 'DECIDED'::public.activity_ref_state then
    raise exception 'REF_ALREADY_DECIDED';
  end if;

  select *
  into v_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_activity_instance_id
    and aice.event_type in (
      'REF_DECISION_SUCCESS'::public.challenge_event_type,
      'REF_DECISION_FAIL'::public.challenge_event_type,
      'REF_DECISION_DISAGREE'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  return query
  select *
  from public.attach_tap_card_photo(
    p_activity_instance_id,
    p_tap_id,
    p_card_id,
    p_photo_path
  );
end;
$$;


ALTER FUNCTION "public"."attach_challenge_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."attach_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") RETURNS TABLE("id" "uuid", "note" "text", "photo_path" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_app_user_id uuid;
  v_card public.tap_cards%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_activity_instance_id is null or p_tap_id is null or p_card_id is null then
    raise exception 'INVALID_ARGUMENT';
  end if;

  select *
  into v_card
  from public.tap_cards tc
  where tc.id = p_card_id
  for update;

  if not found then
    raise exception 'CARD_NOT_FOUND';
  end if;

  if v_card.created_by <> v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_card.activity_instance_id <> p_activity_instance_id then
    raise exception 'CARD_INSTANCE_MISMATCH';
  end if;

  if v_card.tap_id <> p_tap_id then
    raise exception 'CARD_TAP_MISMATCH';
  end if;

  update public.tap_cards tc
  set
    photo_path = nullif(btrim(p_photo_path), ''),
    updated_at = now()
  where tc.id = p_card_id
  returning
    tc.id,
    tc.note,
    tc.photo_path
  into id, note, photo_path;

  perform *
  from private.finalize_activity_tap_core(
    p_activity_instance_id,
    p_tap_id,
    now()
  );

  return next;
end;
$$;


ALTER FUNCTION "public"."attach_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_select_activity_instance"("p_activity_instance_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.activity_instances i
    left join public.activity_instance_challenge_config c
      on c.activity_instance_id = i.id
    where i.id = p_activity_instance_id
      and i.deleted_at is null
      and (
        i.created_by = public.app_user_id()
        or c.ref_user_id = public.app_user_id()
        or (
          i.mode_kind::text = 'CHALLENGE'
          and i.state::text = 'COMPLETED'
          and c.ref_verdict::text in ('SUCCESS', 'FAIL')
          and c.challenger_final_verdict::text in ('SUCCESS', 'FAIL')
        )
      )
  )
$$;


ALTER FUNCTION "public"."can_select_activity_instance"("p_activity_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_select_activity_tap"("p_tap_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.activity_taps t
    where t.id = p_tap_id
      and (
        t.tapped_by = public.app_user_id()
        or public.can_select_activity_instance(t.activity_instance_id)
      )
  )
$$;


ALTER FUNCTION "public"."can_select_activity_tap"("p_tap_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_select_activity_template"("p_template_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.activity_templates t
    where t.id = p_template_id
      and t.deleted_at is null
      and (
        t.created_by = public.app_user_id()
        or (
          t.visibility::text = 'PUBLIC'
          and t.lifecycle_state::text = 'PUBLISHED'
        )
      )
  )
$$;


ALTER FUNCTION "public"."can_select_activity_template"("p_template_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_select_tap_card"("p_card_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.tap_cards c
    where c.id = p_card_id
      and c.deleted_at is null
      and (
        c.created_by = public.app_user_id()
        or public.can_select_activity_instance(c.activity_instance_id)
      )
  )
$$;


ALTER FUNCTION "public"."can_select_tap_card"("p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_rate_limit_app_user"("p_endpoint" "text", "p_limit" integer, "p_window_seconds" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_bucket_start timestamptz;
  v_count integer;
begin
  if coalesce(p_limit, 0) <= 0 then
    raise exception 'RATE_LIMIT_EXCEEDED';
  end if;

  v_app_user_id := public.app_user_id();
  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  v_bucket_start := to_timestamp(
    floor(extract(epoch from now()) / greatest(p_window_seconds, 1)) * greatest(p_window_seconds, 1)
  );

  insert into public.user_rate_limits (endpoint, user_id, bucket_start, cnt)
  values (p_endpoint, v_app_user_id, v_bucket_start, 1)
  on conflict (endpoint, user_id, bucket_start) do update
    set cnt = public.user_rate_limits.cnt + 1
  returning cnt into v_count;

  if v_count > p_limit then
    raise exception 'RATE_LIMIT_EXCEEDED';
  end if;
end;
$$;


ALTER FUNCTION "public"."check_rate_limit_app_user"("p_endpoint" "text", "p_limit" integer, "p_window_seconds" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_rate_limit_ip"("p_endpoint" "text", "p_ip" "text", "p_limit" integer, "p_window_seconds" integer) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_bucket_start timestamptz;
  v_count integer;
  v_ip_hash text;
begin
  if coalesce(p_limit, 0) <= 0 then
    return false;
  end if;

  v_bucket_start := to_timestamp(
    floor(extract(epoch from now()) / greatest(p_window_seconds, 1)) * greatest(p_window_seconds, 1)
  );
  v_ip_hash := encode(digest(coalesce(nullif(p_ip, ''), 'unknown'), 'sha256'), 'hex');

  insert into public.ip_rate_limits (endpoint, ip_hash, bucket_start, cnt)
  values (p_endpoint, v_ip_hash, v_bucket_start, 1)
  on conflict (endpoint, ip_hash, bucket_start) do update
    set cnt = public.ip_rate_limits.cnt + 1
  returning cnt into v_count;

  return v_count <= p_limit;
end;
$$;


ALTER FUNCTION "public"."check_rate_limit_ip"("p_endpoint" "text", "p_ip" "text", "p_limit" integer, "p_window_seconds" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_onboarding"("p_handle" "text", "p_nickname" "text" DEFAULT NULL::"text", "p_avatar_url" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text", "p_init_user_stats" boolean DEFAULT true) RETURNS TABLE("user_id" "uuid", "profile_id" "uuid", "handle" "text", "nickname" "text", "avatar_url" "text", "bio" "text", "cg_title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_handle text;
  v_nickname text;
  v_existing_handle text;
begin
  v_app_user_id := public.app_user_id();
  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select p.handle
    into v_existing_handle
  from public.profiles p
  where p.user_id = v_app_user_id
  limit 1;

  if v_existing_handle is not null then
    raise exception 'ONBOARDING_ALREADY_COMPLETED';
  end if;

  v_handle := public.normalize_handle(p_handle);
  if not public.is_valid_handle(v_handle) then
    raise exception 'INVALID_HANDLE';
  end if;

  v_nickname := nullif(trim(coalesce(p_nickname, '')), '');

  insert into public.profiles (
    user_id,
    handle,
    nickname,
    avatar_url,
    bio,
    cg_title,
    updated_at,
    updated_by
  ) values (
    v_app_user_id,
    v_handle,
    v_nickname,
    nullif(trim(coalesce(p_avatar_url, '')), ''),
    nullif(trim(coalesce(p_bio, '')), ''),
    nullif(trim(coalesce(p_cg_title, '')), ''),
    now(),
    v_app_user_id
  )
  on conflict (user_id) do update
    set handle = excluded.handle,
        nickname = excluded.nickname,
        avatar_url = excluded.avatar_url,
        bio = excluded.bio,
        cg_title = excluded.cg_title,
        updated_at = now(),
        updated_by = v_app_user_id;

  if coalesce(p_init_user_stats, true) then
    insert into public.user_stats (user_id, handle)
    values (v_app_user_id, v_handle)
    on conflict (user_id) do update
      set handle = excluded.handle;
  end if;

  return query
  select
    p.user_id,
    p.id as profile_id,
    coalesce(p.handle, '') as handle,
    coalesce(p.nickname, '') as nickname,
    coalesce(p.avatar_url, '') as avatar_url,
    coalesce(p.bio, '') as bio,
    coalesce(p.cg_title, '') as cg_title,
    p.updated_at
  from public.profiles p
  where p.user_id = v_app_user_id;
end;
$$;


ALTER FUNCTION "public"."complete_onboarding"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "avatar_url" "text",
    "nickname" "text",
    "bio" "text",
    "cg_title" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_by" "uuid",
    "handle" "text",
    "chicken_until" timestamp with time zone,
    "tutorial_step" "public"."tutorial_step_state"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."profiles"."chicken_until" IS 'When set in the future, the profile should render the temporary chicken theme until this time.';



CREATE OR REPLACE FUNCTION "public"."complete_onboarding_core"("p_handle" "text", "p_nickname" "text" DEFAULT NULL::"text", "p_avatar_url" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text", "p_init_user_stats" boolean DEFAULT true) RETURNS "public"."profiles"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_now timestamptz := now();
  v_handle text;
  v_nickname text;
  v_profile public.profiles%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  v_handle := lower(btrim(coalesce(p_handle, '')));
  if v_handle = '' then
    raise exception 'HANDLE_REQUIRED';
  end if;

  v_nickname := nullif(btrim(coalesce(p_nickname, '')), '');
  if v_nickname is null then
    raise exception 'NICKNAME_REQUIRED';
  end if;

  if exists (
    select 1
    from public.profiles pr
    where lower(pr.handle) = v_handle
      and pr.user_id <> v_app_user_id
  ) then
    raise exception 'HANDLE_TAKEN';
  end if;

  insert into public.profiles as pr (
    user_id,
    handle,
    nickname,
    avatar_url,
    bio,
    cg_title,
    updated_at,
    updated_by
  )
  values (
    v_app_user_id,
    v_handle,
    v_nickname,
    p_avatar_url,
    p_bio,
    p_cg_title,
    v_now,
    v_app_user_id
  )
  on conflict (user_id) do update
  set
    handle = excluded.handle,
    nickname = excluded.nickname,
    avatar_url = coalesce(excluded.avatar_url, pr.avatar_url),
    bio = excluded.bio,
    cg_title = excluded.cg_title,
    updated_at = excluded.updated_at,
    updated_by = excluded.updated_by
  returning pr.* into v_profile;

  update public.profiles_history ph
  set valid_to = v_now
  where ph.user_id = v_app_user_id
    and ph.valid_to = 'infinity'::timestamptz;

  insert into public.profiles_history (
    user_id,
    handle,
    nickname,
    avatar_url,
    bio,
    cg_title,
    updated_by,
    updated_at,
    valid_from,
    valid_to
  )
  values (
    v_app_user_id,
    v_profile.handle,
    v_profile.nickname,
    v_profile.avatar_url,
    v_profile.bio,
    v_profile.cg_title,
    v_app_user_id,
    v_profile.updated_at,
    v_now,
    'infinity'::timestamptz
  );

  if coalesce(p_init_user_stats, true) then
    insert into public.user_stats as us (
      user_id,
      profile_id,
      handle
    )
    values (
      v_app_user_id,
      v_profile.id,
      v_profile.handle
    )
    on conflict (user_id) do update
    set
      profile_id = excluded.profile_id,
      handle = excluded.handle;
  end if;

  return v_profile;
end;
$$;


ALTER FUNCTION "public"."complete_onboarding_core"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_onboarding_for_app_user"("p_app_user_id" "uuid", "p_handle" "text", "p_nickname" "text" DEFAULT NULL::"text", "p_avatar_url" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text", "p_init_user_stats" boolean DEFAULT true) RETURNS TABLE("user_id" "uuid", "profile_id" "uuid", "handle" "text", "nickname" "text", "avatar_url" "text", "bio" "text", "cg_title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_handle text;
  v_nickname text;
  v_existing_handle text;
begin
  if p_app_user_id is null or not exists (
    select 1
    from public.app_users u
    where u.id = p_app_user_id
      and u.deleted_at is null
  ) then
    raise exception 'UNAUTHORIZED';
  end if;

  select p.handle
    into v_existing_handle
  from public.profiles p
  where p.user_id = p_app_user_id
  limit 1;

  if v_existing_handle is not null then
    raise exception 'ONBOARDING_ALREADY_COMPLETED';
  end if;

  v_handle := public.normalize_handle(p_handle);
  if not public.is_valid_handle(v_handle) then
    raise exception 'INVALID_HANDLE';
  end if;

  v_nickname := nullif(trim(coalesce(p_nickname, '')), '');

  insert into public.profiles (
    user_id,
    handle,
    nickname,
    avatar_url,
    bio,
    cg_title,
    updated_at,
    updated_by
  ) values (
    p_app_user_id,
    v_handle,
    v_nickname,
    nullif(trim(coalesce(p_avatar_url, '')), ''),
    nullif(trim(coalesce(p_bio, '')), ''),
    nullif(trim(coalesce(p_cg_title, '')), ''),
    now(),
    p_app_user_id
  )
  on conflict (user_id) do update
    set handle = excluded.handle,
        nickname = excluded.nickname,
        avatar_url = excluded.avatar_url,
        bio = excluded.bio,
        cg_title = excluded.cg_title,
        updated_at = now(),
        updated_by = p_app_user_id;

  if coalesce(p_init_user_stats, true) then
    insert into public.user_stats (user_id, handle)
    values (p_app_user_id, v_handle)
    on conflict (user_id) do update
      set handle = excluded.handle;
  end if;

  return query
  select
    p.user_id,
    p.id as profile_id,
    coalesce(p.handle, '') as handle,
    coalesce(p.nickname, '') as nickname,
    coalesce(p.avatar_url, '') as avatar_url,
    coalesce(p.bio, '') as bio,
    coalesce(p.cg_title, '') as cg_title,
    p.updated_at
  from public.profiles p
  where p.user_id = p_app_user_id;
end;
$$;


ALTER FUNCTION "public"."complete_onboarding_for_app_user"("p_app_user_id" "uuid", "p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_onboarding_v2"("p_handle" "text", "p_nickname" "text" DEFAULT NULL::"text", "p_avatar_url" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text", "p_init_user_stats" boolean DEFAULT true) RETURNS TABLE("avatar_url" "text", "bio" "text", "cg_title" "text", "handle" "text", "nickname" "text", "profile_id" "uuid", "updated_at" timestamp with time zone, "user_id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select *
  from public.complete_onboarding(
    p_handle => p_handle,
    p_nickname => p_nickname,
    p_avatar_url => p_avatar_url,
    p_bio => p_bio,
    p_cg_title => p_cg_title,
    p_init_user_stats => p_init_user_stats
  );
$$;


ALTER FUNCTION "public"."complete_onboarding_v2"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_challenge_instance"("p_activity_template_id" "uuid", "p_ref_email" "text", "p_fail_card_fee_minor" integer, "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_idempotency_key" "text") RETURNS TABLE("activity_instance_id" "uuid", "sequence_no" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_template public.activity_templates%rowtype;
  v_next_sequence_no integer;
  v_activity_instance_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'Authenticated app user required';
  end if;

  if p_activity_template_id is null then
    raise exception 'activity_template_id is required';
  end if;

  if p_idempotency_key is null or btrim(p_idempotency_key) = '' then
    raise exception 'idempotency_key is required';
  end if;

  if p_ref_email is null or btrim(p_ref_email) = '' then
    raise exception 'ref_email is required';
  end if;

  if p_fail_card_fee_minor is null or p_fail_card_fee_minor < 0 then
    raise exception 'fail_card_fee_minor must be >= 0';
  end if;

  if p_play_context is null then
    raise exception 'play_context is required';
  end if;

  if p_relationship_mode is null then
    raise exception 'relationship_mode is required';
  end if;

  select *
    into v_template
  from public.activity_templates t
  where t.id = p_activity_template_id
    and t.deleted_at is null
    and t.lifecycle_state = 'PUBLISHED'
    and t.status = 'ACTIVE'
    and t.visibility = 'PUBLIC'
  for share;

  if not found then
    raise exception 'Template not found or not playable';
  end if;

  /*
    Idempotency fast path:
    same app user + same idempotency key => return existing instance
  */
  select ai.id, ai.sequence_no
    into v_activity_instance_id, v_next_sequence_no
  from public.activity_instances ai
  where ai.created_by = v_app_user_id
    and ai.idempotency_key = p_idempotency_key
    and ai.deleted_at is null
  limit 1;

  if found then
    return query
    select v_activity_instance_id, v_next_sequence_no;
    return;
  end if;

  /*
    Per-(template, user) sequence allocation.
    Keep unique index as backstop.
  */
  select coalesce(max(ai.sequence_no), 0) + 1
    into v_next_sequence_no
  from public.activity_instances ai
  where ai.activity_template_id = p_activity_template_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null;

  insert into public.activity_instances (
    activity_template_id,
    created_by,
    state,
    started_at,
    play_context,
    relationship_mode,
    mode_kind,
    created_at,
    updated_at,
    updated_by,
    idempotency_key,
    sequence_no
  )
  values (
    p_activity_template_id,
    v_app_user_id,
    'ACTIVE',
    now(),
    p_play_context,
    p_relationship_mode,
    v_template.mode_kind,
    now(),
    now(),
    v_app_user_id,
    p_idempotency_key,
    v_next_sequence_no
  )
  returning id
    into v_activity_instance_id;

  insert into public.activity_instance_challenge_config (
    activity_instance_id,
    ref_email,
    fail_card_fee_minor,
    created_at,
    updated_at
  )
  values (
    v_activity_instance_id,
    lower(btrim(p_ref_email)),
    p_fail_card_fee_minor,
    now(),
    now()
  );

  return query
  select v_activity_instance_id, v_next_sequence_no;
end;
$$;


ALTER FUNCTION "public"."create_challenge_instance"("p_activity_template_id" "uuid", "p_ref_email" "text", "p_fail_card_fee_minor" integer, "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_idempotency_key" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text" DEFAULT NULL::"text", "p_link_url" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "note" "text", "photo_path" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_terminal_event public.activity_instance_challenge_events%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_TAP_MODE';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'INSTANCE_DELETED';
  end if;

  if v_instance.state <> 'ACTIVE'::public.activity_instance_state
     or v_instance.completed_at is not null
     or v_instance.terminated_at is not null then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  if v_config.ref_state = 'DECIDED'::public.activity_ref_state then
    raise exception 'REF_ALREADY_DECIDED';
  end if;

  select *
  into v_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_activity_instance_id
    and aice.event_type in (
      'REF_DECISION_SUCCESS'::public.challenge_event_type,
      'REF_DECISION_FAIL'::public.challenge_event_type,
      'REF_DECISION_DISAGREE'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  return query
  select *
  from public.create_tap_card_shell(
    p_activity_instance_id,
    p_card_id,
    p_tap_id,
    p_note,
    p_link_url
  );
end;
$$;


ALTER FUNCTION "public"."create_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_challenge_template"("p_template_id" "uuid", "p_title" "text", "p_rules" "text" DEFAULT NULL::"text", "p_photo_url" "text" DEFAULT NULL::"text", "p_visibility" "public"."template_visibility" DEFAULT 'PUBLIC'::"public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state" DEFAULT 'PUBLISHED'::"public"."template_lifecycle_state", "p_idempotency_key" "text" DEFAULT NULL::"text", "p_creator_display_name" "text" DEFAULT NULL::"text", "p_cadence_hint" "text" DEFAULT NULL::"text", "p_proof_kind" "text" DEFAULT 'ANY'::"text", "p_play_context" "public"."template_play_context" DEFAULT 'ONLINE'::"public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode" DEFAULT 'SOLO'::"public"."template_relationship_mode", "p_min_participants" smallint DEFAULT 1, "p_max_participants" smallint DEFAULT 1, "p_challenge_currency" "text" DEFAULT 'USD'::"text", "p_challenge_ref_email" "text" DEFAULT NULL::"text", "p_challenge_fail_card_fee_minor" integer DEFAULT NULL::integer, "p_challenge_ref_required" boolean DEFAULT NULL::boolean) RETURNS TABLE("template_id" "uuid", "lifecycle_state" "public"."template_lifecycle_state", "published_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_now timestamptz := now();
  v_template_id uuid;
  v_published_at timestamptz;
  v_ref_required boolean;
  v_fail_card_fee_minor integer;
  v_visibility public.template_visibility;
  v_lifecycle_state public.template_lifecycle_state;
  v_play_context public.template_play_context;
  v_relationship_mode public.template_relationship_mode;
  v_proof_kind text;
  v_min_participants smallint;
  v_max_participants smallint;
  v_currency text;
  v_step text := 'init';
  v_context text;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'app_user_id() returned null';
  end if;

  if not public.is_active_app_session() then
    raise exception 'ACTIVE_SESSION_REQUIRED' using errcode = '42501';
  end if;

  if p_template_id is null then
    raise exception 'p_template_id is required' using errcode = '22023';
  end if;

  if nullif(btrim(coalesce(p_title, '')), '') is null then
    raise exception 'p_title is required' using errcode = '22023';
  end if;

  v_visibility := coalesce(p_visibility, 'PUBLIC'::public.template_visibility);
  v_lifecycle_state := coalesce(p_lifecycle_state, 'PUBLISHED'::public.template_lifecycle_state);
  v_play_context := coalesce(p_play_context, 'ONLINE'::public.template_play_context);
  v_relationship_mode := coalesce(p_relationship_mode, 'SOLO'::public.template_relationship_mode);
  v_proof_kind := coalesce(nullif(btrim(coalesce(p_proof_kind, '')), ''), 'ANY');
  v_min_participants := coalesce(p_min_participants, 1);
  v_max_participants := coalesce(p_max_participants, 1);
  v_currency := coalesce(nullif(btrim(coalesce(p_challenge_currency, '')), ''), 'USD');
  v_fail_card_fee_minor := coalesce(p_challenge_fail_card_fee_minor, 0);
  v_ref_required := coalesce(p_challenge_ref_required, false);
  v_published_at := case
    when v_lifecycle_state = 'PUBLISHED'::public.template_lifecycle_state then v_now
    else null
  end;

  v_step := 'upsert activity_templates';

  insert into public.activity_templates (
    id,
    origin_id,
    parent_id,
    title,
    rules,
    photo_path,
    visibility,
    lifecycle_state,
    published_at,
    mode_kind,
    play_context,
    relationship_mode,
    proof_kind,
    min_participants,
    max_participants,
    cadence_hint,
    creator_display_name,
    idempotency_key,
    created_by,
    updated_by,
    created_at,
    updated_at
  )
  values (
    p_template_id,
    p_template_id,
    null,
    btrim(p_title),
    p_rules,
    p_photo_url,
    v_visibility,
    v_lifecycle_state,
    v_published_at,
    'CHALLENGE'::public.activity_mode_kind,
    v_play_context,
    v_relationship_mode,
    v_proof_kind,
    v_min_participants,
    v_max_participants,
    p_cadence_hint,
    p_creator_display_name,
    p_idempotency_key,
    v_app_user_id,
    v_app_user_id,
    v_now,
    v_now
  )
  on conflict (id) do update
  set
    title = excluded.title,
    rules = excluded.rules,
    photo_path = excluded.photo_path,
    visibility = excluded.visibility,
    lifecycle_state = excluded.lifecycle_state,
    published_at = excluded.published_at,
    mode_kind = excluded.mode_kind,
    play_context = excluded.play_context,
    relationship_mode = excluded.relationship_mode,
    proof_kind = excluded.proof_kind,
    min_participants = excluded.min_participants,
    max_participants = excluded.max_participants,
    cadence_hint = excluded.cadence_hint,
    creator_display_name = excluded.creator_display_name,
    idempotency_key = excluded.idempotency_key,
    updated_by = v_app_user_id,
    updated_at = v_now
  where activity_templates.created_by = v_app_user_id
  returning activity_templates.id
    into v_template_id;

  if v_template_id is null then
    raise exception 'TEMPLATE_NOT_CREATED_OR_NOT_OWNED' using errcode = '42501';
  end if;

  v_step := 'upsert activity_template_challenge_config';

  insert into public.activity_template_challenge_config (
    activity_template_id,
    currency,
    fail_card_fee_minor,
    ref_required,
    created_at
  )
  values (
    v_template_id,
    v_currency,
    v_fail_card_fee_minor,
    v_ref_required,
    v_now
  )
  on conflict (activity_template_id) do update
  set
    currency = excluded.currency,
    fail_card_fee_minor = excluded.fail_card_fee_minor,
    ref_required = excluded.ref_required;

  v_step := 'sync public_activity_templates';

  if v_visibility = 'PUBLIC'::public.template_visibility
     and v_lifecycle_state = 'PUBLISHED'::public.template_lifecycle_state
     and v_published_at is not null then
    insert into public.public_activity_templates (
      id,
      origin_id,
      parent_id,
      title,
      rules,
      photo_path,
      creator_display_name,
      published_at,
      cadence_hint,
      max_participants,
      min_participants,
      mode_kind,
      play_context,
      proof_kind,
      relationship_mode
    )
    values (
      v_template_id,
      v_template_id,
      null,
      btrim(p_title),
      p_rules,
      p_photo_url,
      p_creator_display_name,
      v_published_at,
      p_cadence_hint,
      v_max_participants,
      v_min_participants,
      'CHALLENGE'::public.activity_mode_kind,
      v_play_context,
      v_proof_kind,
      v_relationship_mode
    )
    on conflict (id) do update
    set
      origin_id = excluded.origin_id,
      parent_id = excluded.parent_id,
      title = excluded.title,
      rules = excluded.rules,
      photo_path = excluded.photo_path,
      creator_display_name = excluded.creator_display_name,
      published_at = excluded.published_at,
      cadence_hint = excluded.cadence_hint,
      max_participants = excluded.max_participants,
      min_participants = excluded.min_participants,
      mode_kind = excluded.mode_kind,
      play_context = excluded.play_context,
      proof_kind = excluded.proof_kind,
      relationship_mode = excluded.relationship_mode;
  else
    delete from public.public_activity_templates pat
    where pat.id = v_template_id;
  end if;

  return query
  select
    v_template_id,
    v_lifecycle_state,
    v_published_at;
exception when others then
  get stacked diagnostics v_context = pg_exception_context;
  raise exception 'create_challenge_template failed at %: [%] % context: %',
    v_step,
    sqlstate,
    sqlerrm,
    v_context
    using errcode = sqlstate;
end;
$$;


ALTER FUNCTION "public"."create_challenge_template"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_challenge_template_and_instance"("p_template_id" "uuid", "p_instance_id" "uuid", "p_title" "text", "p_rules" "text" DEFAULT NULL::"text", "p_photo_path" "text" DEFAULT NULL::"text", "p_visibility" "public"."template_visibility" DEFAULT 'PUBLIC'::"public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state" DEFAULT 'PUBLISHED'::"public"."template_lifecycle_state", "p_idempotency_key" "text" DEFAULT NULL::"text", "p_creator_display_name" "text" DEFAULT NULL::"text", "p_end_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_cadence_hint" "text" DEFAULT NULL::"text", "p_proof_kind" "text" DEFAULT 'ANY'::"text", "p_play_context" "public"."template_play_context" DEFAULT 'ONLINE'::"public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode" DEFAULT 'SOLO'::"public"."template_relationship_mode", "p_min_participants" smallint DEFAULT 1, "p_max_participants" smallint DEFAULT 1, "p_challenge_currency" "text" DEFAULT 'USD'::"text", "p_challenge_ref_email" "text" DEFAULT NULL::"text", "p_challenge_fail_card_fee_minor" integer DEFAULT NULL::integer, "p_challenge_ref_required" boolean DEFAULT NULL::boolean) RETURNS TABLE("template_id" "uuid", "instance_id" "uuid", "published_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_now timestamptz := now();
  v_template_id uuid;
  v_instance_id uuid;
  v_published_at timestamptz;
  v_instance_sequence_no integer;
  v_ref_email text;
  v_fail_card_fee_minor integer;
  v_ref_required boolean;
  v_visibility public.template_visibility;
  v_play_context public.template_play_context;
  v_relationship_mode public.template_relationship_mode;
  v_proof_kind text;
  v_min_participants smallint;
  v_max_participants smallint;
  v_currency text;
  v_step text := 'init';
  v_context text;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'app_user_id() returned null';
  end if;

  if not public.is_active_app_session() then
    raise exception 'ACTIVE_SESSION_REQUIRED' using errcode = '42501';
  end if;

  if p_template_id is null then
    raise exception 'p_template_id is required' using errcode = '22023';
  end if;

  if p_instance_id is null then
    raise exception 'p_instance_id is required' using errcode = '22023';
  end if;

  if nullif(btrim(coalesce(p_title, '')), '') is null then
    raise exception 'p_title is required' using errcode = '22023';
  end if;

  if coalesce(p_lifecycle_state, 'PUBLISHED'::public.template_lifecycle_state) <> 'PUBLISHED'::public.template_lifecycle_state then
    raise exception 'create_challenge_template_and_instance requires lifecycle_state = PUBLISHED';
  end if;

  v_ref_email := nullif(btrim(coalesce(p_challenge_ref_email, '')), '');
  if v_ref_email is null then
    raise exception 'REF_EMAIL_REQUIRED' using errcode = '22023';
  end if;

  v_visibility := coalesce(p_visibility, 'PUBLIC'::public.template_visibility);
  v_play_context := coalesce(p_play_context, 'ONLINE'::public.template_play_context);
  v_relationship_mode := coalesce(p_relationship_mode, 'SOLO'::public.template_relationship_mode);
  v_proof_kind := coalesce(nullif(btrim(coalesce(p_proof_kind, '')), ''), 'ANY');
  v_min_participants := coalesce(p_min_participants, 1);
  v_max_participants := coalesce(p_max_participants, 1);
  v_currency := coalesce(nullif(btrim(coalesce(p_challenge_currency, '')), ''), 'USD');
  v_fail_card_fee_minor := coalesce(p_challenge_fail_card_fee_minor, 0);
  v_ref_required := coalesce(p_challenge_ref_required, true);

  v_step := 'upsert activity_templates';

  insert into public.activity_templates (
    id,
    origin_id,
    parent_id,
    title,
    rules,
    photo_path,
    visibility,
    lifecycle_state,
    published_at,
    mode_kind,
    play_context,
    relationship_mode,
    proof_kind,
    min_participants,
    max_participants,
    cadence_hint,
    creator_display_name,
    idempotency_key,
    created_by,
    updated_by,
    created_at,
    updated_at
  )
  values (
    p_template_id,
    p_template_id,
    null,
    btrim(p_title),
    p_rules,
    p_photo_path,
    v_visibility,
    'PUBLISHED'::public.template_lifecycle_state,
    v_now,
    'CHALLENGE'::public.activity_mode_kind,
    v_play_context,
    v_relationship_mode,
    v_proof_kind,
    v_min_participants,
    v_max_participants,
    p_cadence_hint,
    p_creator_display_name,
    p_idempotency_key,
    v_app_user_id,
    v_app_user_id,
    v_now,
    v_now
  )
  on conflict (id) do update
  set
    title = excluded.title,
    rules = excluded.rules,
    photo_path = excluded.photo_path,
    visibility = excluded.visibility,
    lifecycle_state = excluded.lifecycle_state,
    published_at = excluded.published_at,
    mode_kind = excluded.mode_kind,
    play_context = excluded.play_context,
    relationship_mode = excluded.relationship_mode,
    proof_kind = excluded.proof_kind,
    min_participants = excluded.min_participants,
    max_participants = excluded.max_participants,
    cadence_hint = excluded.cadence_hint,
    creator_display_name = excluded.creator_display_name,
    idempotency_key = excluded.idempotency_key,
    updated_by = v_app_user_id,
    updated_at = v_now
  where activity_templates.created_by = v_app_user_id
  returning activity_templates.id, activity_templates.published_at
    into v_template_id, v_published_at;

  if v_template_id is null then
    raise exception 'TEMPLATE_NOT_CREATED_OR_NOT_OWNED' using errcode = '42501';
  end if;

  v_step := 'upsert activity_template_challenge_config';

  insert into public.activity_template_challenge_config (
    activity_template_id,
    currency,
    fail_card_fee_minor,
    ref_required,
    created_at
  )
  values (
    v_template_id,
    v_currency,
    v_fail_card_fee_minor,
    v_ref_required,
    v_now
  )
  on conflict (activity_template_id) do update
  set
    currency = excluded.currency,
    fail_card_fee_minor = excluded.fail_card_fee_minor,
    ref_required = excluded.ref_required;

  v_step := 'calculate activity_instances sequence';

  select coalesce(max(ai.sequence_no), 0) + 1
    into v_instance_sequence_no
  from public.activity_instances ai
  where ai.activity_template_id = v_template_id
    and ai.created_by = v_app_user_id;

  v_step := 'upsert activity_instances';

  insert into public.activity_instances (
    id,
    activity_template_id,
    idempotency_key,
    mode_kind,
    play_context,
    relationship_mode,
    sequence_no,
    started_at,
    end_at,
    state,
    created_by,
    updated_by,
    created_at,
    updated_at
  )
  values (
    p_instance_id,
    v_template_id,
    p_idempotency_key,
    'CHALLENGE'::public.activity_mode_kind,
    v_play_context,
    v_relationship_mode,
    v_instance_sequence_no,
    v_now,
    p_end_at,
    'ACTIVE'::public.activity_instance_state,
    v_app_user_id,
    v_app_user_id,
    v_now,
    v_now
  )
  on conflict (id) do update
  set
    activity_template_id = excluded.activity_template_id,
    idempotency_key = excluded.idempotency_key,
    mode_kind = excluded.mode_kind,
    play_context = excluded.play_context,
    relationship_mode = excluded.relationship_mode,
    end_at = excluded.end_at,
    updated_by = v_app_user_id,
    updated_at = v_now
  where activity_instances.created_by = v_app_user_id
  returning activity_instances.id
    into v_instance_id;

  if v_instance_id is null then
    raise exception 'INSTANCE_NOT_CREATED_OR_NOT_OWNED' using errcode = '42501';
  end if;

  v_step := 'insert activity_instance_challenge_config';

  insert into public.activity_instance_challenge_config (
    activity_instance_id,
    ref_email,
    fail_card_fee_minor,
    ref_state,
    ref_user_id,
    ref_verdict,
    last_ref_resend_at,
    ref_decided_at,
    created_at,
    updated_at
  )
  values (
    v_instance_id,
    v_ref_email,
    v_fail_card_fee_minor,
    'PENDING'::public.activity_ref_state,
    null,
    null,
    null,
    null,
    v_now,
    v_now
  )
  on conflict (activity_instance_id) do nothing;

  return query
  select
    v_template_id,
    v_instance_id,
    v_published_at;
exception when others then
  get stacked diagnostics v_context = pg_exception_context;
  raise exception 'create_challenge_template_and_instance failed at %: [%] % context: %',
    v_step,
    sqlstate,
    sqlerrm,
    v_context
    using errcode = sqlstate;
end;
$$;


ALTER FUNCTION "public"."create_challenge_template_and_instance"("p_template_id" "uuid", "p_instance_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_path" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_end_at" timestamp with time zone, "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_tap_card_reply"("p_card_id" "uuid", "p_body" "text") RETURNS TABLE("reply_id" "uuid", "card_id" "uuid", "user_id" "uuid", "body" "text", "status" "public"."content_status", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "edited_at" timestamp with time zone, "deleted_at" timestamp with time zone, "deleted_by" "public"."deleted_by", "edited_by" "uuid", "handle" "text", "avatar_url" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_card_id is null then
    raise exception 'CARD_NOT_FOUND';
  end if;

  if p_body is null or btrim(p_body) = '' then
    raise exception 'EMPTY_REPLY';
  end if;

  perform 1
  from public.tap_cards tc
  where tc.id = p_card_id
    and tc.deleted_at is null;

  if not found then
    raise exception 'CARD_NOT_FOUND';
  end if;

  return query
  with inserted as (
    insert into public.tap_card_replies (
      tap_card_id,
      user_id,
      body,
      status,
      created_at,
      updated_at
    )
    values (
      p_card_id,
      v_app_user_id,
      btrim(p_body),
      'VISIBLE'::public.content_status,
      now(),
      now()
    )
    returning *
  )
  select
    i.id as reply_id,
    i.tap_card_id as card_id,
    i.user_id,
    i.body,
    i.status,
    i.created_at,
    i.updated_at,
    i.edited_at,
    i.deleted_at,
    i.deleted_by,
    i.edited_by,
    p.handle,
    p.avatar_url
  from inserted i
  left join public.profiles p
    on p.user_id = i.user_id;
end;
$$;


ALTER FUNCTION "public"."create_tap_card_reply"("p_card_id" "uuid", "p_body" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text" DEFAULT NULL::"text", "p_link_url" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "note" "text", "photo_path" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_tap public.activity_taps%rowtype;
  v_instance public.activity_instances%rowtype;
  v_next_sequence_no integer;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_activity_instance_id is null or p_card_id is null or p_tap_id is null then
    raise exception 'INVALID_ARGUMENT';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by <> v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  select *
  into v_tap
  from public.activity_taps at
  where at.id = p_tap_id
  for update;

  if not found then
    raise exception 'TAP_NOT_FOUND';
  end if;

  if v_tap.activity_instance_id <> p_activity_instance_id then
    raise exception 'TAP_INSTANCE_MISMATCH';
  end if;

  if v_tap.state = 'CANCELED'::public.activity_tap_state then
    raise exception 'TAP_CANCELED';
  end if;

  if exists (
    select 1
    from public.tap_cards tc
    where tc.id = p_card_id
  ) then
    raise exception 'CARD_ID_ALREADY_EXISTS';
  end if;

  select coalesce(max(tc.sequence_no), 0) + 1
  into v_next_sequence_no
  from public.tap_cards tc
  where tc.tap_id = p_tap_id
    and tc.deleted_at is null;

  insert into public.tap_cards (
    activity_instance_id,
    id,
    tap_id,
    created_by,
    sequence_no,
    tap_sequence_no,
    note,
    link_url,
    photo_path
  )
  values (
    p_activity_instance_id,
    p_card_id,
    p_tap_id,
    v_app_user_id,
    v_next_sequence_no,
    v_tap.sequence_no,
    nullif(btrim(p_note), ''),
    nullif(btrim(p_link_url), ''),
    null
  )
  returning
    tap_cards.id,
    tap_cards.note,
    tap_cards.photo_path
  into id, note, photo_path;

  return next;
end;
$$;


ALTER FUNCTION "public"."create_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_auth_session_id"() RETURNS "text"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  select nullif(auth.jwt() ->> 'session_id', '')
$$;


ALTER FUNCTION "public"."current_auth_session_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."debug_auth_state"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
    select jsonb_build_object(
      'auth_uid', auth.uid(),
      'auth_role', auth.role(),
      'current_user', current_user::text,
      'session_user', session_user::text,
      'jwt_session_id', public.current_auth_session_id(),
      'app_user_id', public.app_user_id(),
      'is_active_app_session', public.is_active_app_session()
    );
  $$;


ALTER FUNCTION "public"."debug_auth_state"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."debug_insert_template"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
  declare
    v_id uuid := gen_random_uuid();
    v_app_user_id uuid := public.app_user_id();
    v_active boolean := public.is_active_app_session();
  begin
    raise notice 'pre-insert: app_user_id=%, active=%', v_app_user_id, v_active;

    insert into public.activity_templates (
      id, origin_id, title, lifecycle_state, visibility, mode_kind,
      play_context, relationship_mode, proof_kind,
      min_participants, max_participants,
      created_by, updated_by, created_at, updated_at, published_at
    )
    values (
      v_id, v_id, 'debug-test', 'PUBLISHED', 'PUBLIC', 'CHALLENGE',
      'ONLINE', 'SOLO', 'ANY',
      1, 1,
      v_app_user_id, v_app_user_id, now(), now(), now()
    );

    -- delete from public.activity_templates where id = v_id;

    return jsonb_build_object('ok', true, 'app_user_id', v_app_user_id, 'active', v_active);
  exception when others then
    return jsonb_build_object(
      'ok', false,
      'sqlstate', SQLSTATE,
      'sqlerrm', SQLERRM,
      'app_user_id', v_app_user_id,
      'active', v_active
    );
  end;
  $$;


ALTER FUNCTION "public"."debug_insert_template"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_tap_card_reply"("p_reply_id" "uuid") RETURNS TABLE("reply_id" "uuid", "card_id" "uuid", "deleted_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_reply public.tap_card_replies%rowtype;
  v_deleted_by public.deleted_by;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_reply
  from public.tap_card_replies tcr
  where tcr.id = p_reply_id
  for update;

  if not found then
    raise exception 'REPLY_NOT_FOUND';
  end if;

  if v_reply.user_id is distinct from v_app_user_id and not public.is_operator() then
    raise exception 'FORBIDDEN';
  end if;

  v_deleted_by := case
    when public.is_operator() and v_reply.user_id is distinct from v_app_user_id then 'ADMIN'::public.deleted_by
    else 'OWNER'::public.deleted_by
  end;

  update public.tap_card_replies tcr
  set
    deleted_at = now(),
    deleted_by = v_deleted_by,
    status = 'HIDDEN'::public.content_status,
    updated_at = now()
  where tcr.id = v_reply.id
  returning tcr.id, tcr.tap_card_id, tcr.deleted_at
  into reply_id, card_id, deleted_at;

  return next;
end;
$$;


ALTER FUNCTION "public"."delete_tap_card_reply"("p_reply_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."disagree_watcher_decision"("p_challenge_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
DECLARE
  v_owner_id     UUID;
  v_title        TEXT;
  v_amount_minor INTEGER;
BEGIN
  SELECT id
  INTO v_owner_id
  FROM app_users
  WHERE auth_id = auth.uid();

  IF v_owner_id IS NULL THEN
    RAISE EXCEPTION 'app_user not found for current auth user';
  END IF;

  UPDATE public.challenges AS c
  SET status     = 'CHALLENGER_FINAL_DISAGREE',
      result     = 'DISAGREE',
      updated_at = now()
  WHERE c.id = p_challenge_id
    AND c.owner_id = v_owner_id
    AND c.deleted_at IS NULL
    AND c.status IN ('WATCHER_MARKED_SUCCESS', 'WATCHER_MARKED_FAIL')
  RETURNING c.title, c.amount_minor
  INTO v_title, v_amount_minor;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'challenge not eligible for disagree_watcher_decision';
  END IF;

  INSERT INTO public.challenge_cards (challenge_id, episode, photo_url, status)
  SELECT
    p_challenge_id,
    format(
      '[Auto] %s — Result: DISAGREE — Stake: %s',
      coalesce(v_title, 'Challenge'),
      to_char((v_amount_minor::numeric) / 100, 'FM$999,999,999,990.00')
    ),
    NULL,
    'VISIBLE'
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.challenge_cards
    WHERE challenge_id = p_challenge_id
      AND deleted_at IS NULL
  );

  RETURN true;
END;
$_$;


ALTER FUNCTION "public"."disagree_watcher_decision"("p_challenge_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_activity_tap"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") RETURNS TABLE("ok" boolean, "action" "text", "tap_id" "uuid", "activity_instance_id" "uuid", "sequence_no" integer, "state" "public"."activity_tap_state", "finalized_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'INSTANCE_DELETED';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  return query
  select *
  from private.finalize_activity_tap_core(
    p_activity_instance_id,
    p_tap_id,
    now()
  );
end;
$$;


ALTER FUNCTION "public"."finalize_activity_tap"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_chicken"("p_instance_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_cover_tap_id uuid;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_now timestamptz := now();
  v_chicken_until timestamptz := now() + interval '7 days';
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  if not exists (
    select 1
    from public.activity_instances ai
    join public.activity_instance_challenge_config aicc
      on aicc.activity_instance_id = ai.id
    where ai.id = p_instance_id
      and ai.created_by = v_app_user_id
      and ai.deleted_at is null
      and ai.state = 'ACTIVE'::public.activity_instance_state
      and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
      and aicc.ref_state = 'DECIDED'::public.activity_ref_state
      and aicc.ref_verdict in (
        'SUCCESS'::public.activity_ref_verdict,
        'FAIL'::public.activity_ref_verdict
      )
      and (
        select e.event_type
        from public.activity_instance_challenge_events e
        where e.activity_instance_id = ai.id
        order by e.created_at desc, e.id desc
        limit 1
      ) in (
        'REF_DECISION_SUCCESS'::public.challenge_event_type,
        'REF_DECISION_FAIL'::public.challenge_event_type
      )
  ) then
    raise exception 'INSTANCE_NOT_ACTIVE';
  end if;

  select tc.id
  into v_cover_tap_id
  from public.tap_cards tc
  where tc.activity_instance_id = p_instance_id
    and tc.deleted_at is null
  order by tc.sequence_no desc, tc.created_at desc, tc.id desc
  limit 1;

  if v_cover_tap_id is null then
    raise exception 'NO_TAP_CARD_FOR_FINAL_COVER';
  end if;

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      cover_card_id = coalesce(ai.cover_card_id, v_cover_tap_id),
      updated_at = v_now
  where ai.id = p_instance_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'CHICKEN'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id
    and aicc.ref_state = 'DECIDED'::public.activity_ref_state
    and aicc.ref_verdict in (
      'SUCCESS'::public.activity_ref_verdict,
      'FAIL'::public.activity_ref_verdict
    );

  update public.profiles p
  set chicken_until = greatest(coalesce(p.chicken_until, '-infinity'::timestamptz), v_chicken_until),
      updated_at = v_now,
      updated_by = v_app_user_id
  where p.user_id = v_app_user_id;

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
    jsonb_build_object(
      'cover_card_id', v_cover_tap_id,
      'chicken_until', v_chicken_until
    )
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_chicken"("p_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_cover_tap_id uuid;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_now timestamptz := now();
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  if not exists (
    select 1
    from public.activity_instances ai
    join public.activity_instance_challenge_config aicc
      on aicc.activity_instance_id = ai.id
    where ai.id = p_instance_id
      and ai.created_by = v_app_user_id
      and ai.deleted_at is null
      and ai.state = 'ACTIVE'::public.activity_instance_state
      and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
      and aicc.ref_state = 'DECIDED'::public.activity_ref_state
      and aicc.ref_verdict in (
        'SUCCESS'::public.activity_ref_verdict,
        'FAIL'::public.activity_ref_verdict
      )
      and (
        select e.event_type
        from public.activity_instance_challenge_events e
        where e.activity_instance_id = ai.id
        order by e.created_at desc, e.id desc
        limit 1
      ) in (
        'REF_DECISION_SUCCESS'::public.challenge_event_type,
        'REF_DECISION_FAIL'::public.challenge_event_type
      )
  ) then
    raise exception 'INSTANCE_NOT_ACTIVE';
  end if;

  select tc.id
  into v_cover_tap_id
  from public.tap_cards tc
  where tc.activity_instance_id = p_instance_id
    and tc.deleted_at is null
  order by tc.sequence_no desc, tc.created_at desc, tc.id desc
  limit 1;

  if v_cover_tap_id is null then
    raise exception 'NO_TAP_CARD_FOR_FINAL_COVER';
  end if;

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      cover_card_id = coalesce(ai.cover_card_id, v_cover_tap_id),
      updated_at = v_now
  where ai.id = p_instance_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'DISPUTE'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id
    and aicc.ref_state = 'DECIDED'::public.activity_ref_state
    and aicc.ref_verdict in (
      'SUCCESS'::public.activity_ref_verdict,
      'FAIL'::public.activity_ref_verdict
    );

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type,
    jsonb_build_object('cover_card_id', v_cover_tap_id)
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid", "p_reason_code" "text" DEFAULT NULL::"text", "p_details" "text" DEFAULT NULL::"text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_cover_tap_id uuid;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_cfg public.activity_instance_challenge_config%rowtype;
  v_now timestamptz := now();
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_reason_code is null or btrim(p_reason_code) = '' then
    raise exception 'DISPUTE_REASON_REQUIRED';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  select aicc.*
  into v_cfg
  from public.activity_instances ai
  join public.activity_instance_challenge_config aicc
    on aicc.activity_instance_id = ai.id
  where ai.id = p_instance_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
    and aicc.ref_state = 'DECIDED'::public.activity_ref_state
    and aicc.ref_verdict in (
      'SUCCESS'::public.activity_ref_verdict,
      'FAIL'::public.activity_ref_verdict
    )
    and (
      select e.event_type
      from public.activity_instance_challenge_events e
      where e.activity_instance_id = ai.id
      order by e.created_at desc, e.id desc
      limit 1
    ) in (
      'REF_DECISION_SUCCESS'::public.challenge_event_type,
      'REF_DECISION_FAIL'::public.challenge_event_type
    )
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_ACTIVE';
  end if;

  select tc.id
  into v_cover_tap_id
  from public.tap_cards tc
  where tc.activity_instance_id = p_instance_id
    and tc.deleted_at is null
  order by tc.sequence_no desc, tc.created_at desc, tc.id desc
  limit 1;

  if v_cover_tap_id is null then
    raise exception 'NO_TAP_CARD_FOR_FINAL_COVER';
  end if;

  insert into public.activity_instance_challenge_disputes (
    activity_instance_id,
    submitted_by,
    submitted_at,
    reason_code,
    details,
    ref_verdict,
    updated_at
  )
  values (
    p_instance_id,
    v_app_user_id,
    v_now,
    btrim(p_reason_code),
    nullif(btrim(p_details), ''),
    v_cfg.ref_verdict,
    v_now
  );

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      cover_card_id = coalesce(ai.cover_card_id, v_cover_tap_id),
      updated_at = v_now
  where ai.id = p_instance_id
    and ai.created_by = v_app_user_id
    and ai.deleted_at is null
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'DISPUTE'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id
    and aicc.ref_state = 'DECIDED'::public.activity_ref_state
    and aicc.ref_verdict in (
      'SUCCESS'::public.activity_ref_verdict,
      'FAIL'::public.activity_ref_verdict
    );

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type,
    jsonb_build_object(
      'cover_card_id', v_cover_tap_id,
      'reason_code', btrim(p_reason_code),
      'details', nullif(btrim(p_details), ''),
      'ref_verdict', v_cfg.ref_verdict
    )
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid", "p_reason_code" "text", "p_details" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_fail_no_payment"("p_instance_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_now timestamptz := now();
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_MODE';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_instance_id
  for update;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'INSTANCE_DELETED';
  end if;

  if v_instance.state <> 'ACTIVE'::public.activity_instance_state
     or v_instance.completed_at is not null
     or v_instance.terminated_at is not null then
    raise exception 'INSTANCE_NOT_ACTIVE';
  end if;

  if v_config.ref_state <> 'DECIDED'::public.activity_ref_state
     or v_config.ref_verdict <> 'FAIL'::public.activity_ref_verdict then
    raise exception 'REF_FAIL_NOT_CONFIRMED';
  end if;

  if coalesce(v_config.fail_card_fee_minor, 0) <> 0 then
    raise exception 'PAYMENT_REQUIRED';
  end if;

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      updated_at = v_now
  where ai.id = p_instance_id;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'FAIL'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
    jsonb_build_object(
      'payment_required', false,
      'amount_minor', 0,
      'finalized_via', 'NO_PAYMENT'
    )
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_fail_no_payment"("p_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_fail_payment"("p_instance_id" "uuid", "p_challenge_payment_id" "uuid", "p_provider_order_id" "text" DEFAULT NULL::"text", "p_provider_payment_id" "text" DEFAULT NULL::"text", "p_payload" "jsonb" DEFAULT '{}'::"jsonb") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_payment public.activity_instance_challenge_payments%rowtype;
  v_existing_terminal_event public.activity_instance_challenge_events%rowtype;
  v_now timestamptz := now();
begin
  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_MODE';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_instance_id
  for update;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  if v_config.ref_state <> 'DECIDED'::public.activity_ref_state
     or v_config.ref_verdict <> 'FAIL'::public.activity_ref_verdict then
    raise exception 'REF_FAIL_NOT_CONFIRMED';
  end if;

  select *
  into v_payment
  from public.activity_instance_challenge_payments aicp
  where aicp.id = p_challenge_payment_id
    and aicp.activity_instance_id = p_instance_id
  for update;

  if not found then
    raise exception 'PAYMENT_NOT_FOUND';
  end if;

  if v_payment.status <> 'SUCCEEDED'::public.payment_status then
    raise exception 'PAYMENT_NOT_SUCCEEDED';
  end if;

  select *
  into v_existing_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_instance_id
    and aice.event_type in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    return false;
  end if;

  update public.activity_instances ai
  set state = 'COMPLETED'::public.activity_instance_state,
      completed_at = coalesce(ai.completed_at, v_now),
      terminated_at = null,
      updated_at = v_now
  where ai.id = p_instance_id;

  if not found then
    raise exception 'FAILED_TO_FINALIZE_INSTANCE';
  end if;

  update public.activity_instance_challenge_config aicc
  set challenger_finalized_at = coalesce(aicc.challenger_finalized_at, v_now),
      challenger_final_verdict = 'FAIL'::public.activity_challenger_final_verdict,
      updated_at = v_now
  where aicc.activity_instance_id = p_instance_id;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    p_instance_id,
    'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
    coalesce(p_payload, '{}'::jsonb) || jsonb_build_object(
      'challenge_payment_id', p_challenge_payment_id,
      'provider_order_id', p_provider_order_id,
      'provider_payment_id', p_provider_payment_id
    )
  );

  return true;
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_fail_payment"("p_instance_id" "uuid", "p_challenge_payment_id" "uuid", "p_provider_order_id" "text", "p_provider_payment_id" "text", "p_payload" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_challenge_tap_without_card"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") RETURNS TABLE("ok" boolean, "action" "text", "tap_id" "uuid", "activity_instance_id" "uuid", "sequence_no" integer, "state" "public"."activity_tap_state", "finalized_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_terminal_event public.activity_instance_challenge_events%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'INSTANCE_NOT_FOUND';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'FORBIDDEN';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'UNSUPPORTED_TAP_MODE';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'INSTANCE_DELETED';
  end if;

  if v_instance.state <> 'ACTIVE'::public.activity_instance_state
     or v_instance.completed_at is not null
     or v_instance.terminated_at is not null then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'CONFIG_NOT_FOUND';
  end if;

  if v_config.ref_state = 'DECIDED'::public.activity_ref_state then
    raise exception 'REF_ALREADY_DECIDED';
  end if;

  select *
  into v_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_activity_instance_id
    and aice.event_type in (
      'REF_DECISION_SUCCESS'::public.challenge_event_type,
      'REF_DECISION_FAIL'::public.challenge_event_type,
      'REF_DECISION_DISAGREE'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    raise exception 'INSTANCE_NOT_TAPPABLE';
  end if;

  return query
  select *
  from private.finalize_activity_tap_core(
    p_activity_instance_id,
    p_tap_id,
    now()
  );
end;
$$;


ALTER FUNCTION "public"."finalize_challenge_tap_without_card"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_ref_decision"("p_token" "text", "p_action" "text", "p_ip" "text" DEFAULT NULL::"text") RETURNS TABLE("ok" boolean, "result" "text", "activity_instance_id" "uuid", "next_status" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_tok public.activity_instance_challenge_mail_tokens%rowtype;
  v_cfg public.activity_instance_challenge_config%rowtype;
  v_now timestamptz := now();
  v_next_status text;
  v_ref_verdict public.activity_ref_verdict;
begin
  select *
    into v_tok
  from public.activity_instance_challenge_mail_tokens aimt
  where aimt.token = p_token
  for update;

  if not found then
    return query
    select false, 'INVALID_TOKEN', null::uuid, null::text;
    return;
  end if;

  if v_tok.invalidated_at is not null then
    return query
    select false, 'ALREADY_USED', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if v_tok.expires_at is not null and v_tok.expires_at <= v_now then
    return query
    select false, 'EXPIRED_TOKEN', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if v_tok.used_at is not null then
    return query
    select false, 'ALREADY_USED', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if p_action is null then
    return query
    select false, 'ACTION_MISMATCH', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if v_tok.action = 'ref_access' then
    if p_action not in ('mark_success', 'mark_fail') then
      return query
      select false, 'UNSUPPORTED_ACTION', v_tok.activity_instance_id, null::text;
      return;
    end if;
  elsif p_action <> v_tok.action then
    return query
    select false, 'ACTION_MISMATCH', v_tok.activity_instance_id, null::text;
    return;
  end if;

  select *
    into v_cfg
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = v_tok.activity_instance_id
  for update;

  if not found then
    return query
    select false, 'CONFIG_NOT_FOUND', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if v_cfg.ref_state = 'DECIDED'::public.activity_ref_state then
    return query
    select false, 'ALREADY_DECIDED', v_tok.activity_instance_id, null::text;
    return;
  end if;

  if p_action = 'mark_success' then
    v_ref_verdict := 'SUCCESS'::public.activity_ref_verdict;
    v_next_status := 'REF_DECIDED_SUCCESS';
  elsif p_action = 'mark_fail' then
    v_ref_verdict := 'FAIL'::public.activity_ref_verdict;
    v_next_status := 'REF_DECIDED_FAIL';
  else
    return query
    select false, 'UNSUPPORTED_ACTION', v_tok.activity_instance_id, null::text;
    return;
  end if;

  update public.activity_instance_challenge_config aicc
  set ref_state = 'DECIDED'::public.activity_ref_state,
      ref_verdict = v_ref_verdict,
      ref_decided_at = v_now,
      updated_at = v_now
  where aicc.activity_instance_id = v_cfg.activity_instance_id;

  update public.activity_instance_challenge_mail_tokens aimt
  set used_at = v_now
  where aimt.id = v_tok.id;

  update public.activity_instance_challenge_mail_tokens aimt
  set invalidated_at = v_now
  where aimt.activity_instance_id = v_tok.activity_instance_id
    and aimt.id <> v_tok.id
    and aimt.used_at is null
    and aimt.invalidated_at is null;

  insert into public.activity_instance_challenge_events (
    activity_instance_id,
    event_type,
    payload
  )
  values (
    v_tok.activity_instance_id,
    (
      case
        when v_ref_verdict = 'SUCCESS'::public.activity_ref_verdict then 'REF_DECISION_SUCCESS'
        else 'REF_DECISION_FAIL'
      end
    )::public.challenge_event_type,
    jsonb_build_object(
      'token_id', v_tok.id,
      'action', p_action,
      'token_action', v_tok.action,
      'ip', p_ip,
      'ref_verdict', v_ref_verdict
    )
  );

  return query
  select true, 'OK', v_tok.activity_instance_id, v_next_status;
end;
$$;


ALTER FUNCTION "public"."finalize_ref_decision"("p_token" "text", "p_action" "text", "p_ip" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finalize_stale_activity_taps"("p_reference_time" timestamp with time zone DEFAULT "now"()) RETURNS TABLE("reference_tap_day" "date", "canceled_count" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_reference_time timestamptz := coalesce(p_reference_time, now());
  v_reference_tap_day date := timezone('America/New_York', v_reference_time)::date;
  v_canceled_count integer := 0;
begin
  if coalesce(auth.role(), '') <> 'service_role'
     and current_user <> 'postgres' then
    raise exception 'FORBIDDEN';
  end if;

  with stale as (
    update public.activity_taps at
    set
      state = 'CANCELED'::public.activity_tap_state,
      canceled_at = coalesce(at.canceled_at, v_reference_time),
      updated_at = v_reference_time
    where at.state = 'OPENED'::public.activity_tap_state
      and at.finalized_at is null
      and timezone('America/New_York', at.first_happened_at)::date < v_reference_tap_day
    returning at.id
  )
  select count(*)
  into v_canceled_count
  from stale;

  return query
  select
    v_reference_tap_day,
    v_canceled_count;
end;
$$;


ALTER FUNCTION "public"."finalize_stale_activity_taps"("p_reference_time" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_default_handle"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
  select 'user_' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 10)
$$;


ALTER FUNCTION "public"."generate_default_handle"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_card_like_stats"("p_card_ids" "uuid"[]) RETURNS TABLE("card_id" "uuid", "like_count" bigint, "liked_by_me" boolean)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
with input_cards as (
  select unnest(coalesce(p_card_ids, '{}'::uuid[])) as card_id
),
counts as (
  select cl.card_id, count(*)::bigint as like_count
  from public.card_likes cl
  join input_cards ic on ic.card_id = cl.card_id
  group by cl.card_id
),
me as (
  -- app_user_id()는 anon이면 보통 null이 나올 것
  select public.app_user_id() as me_user_id
),
mine as (
  select cl.card_id
  from public.card_likes cl
  join input_cards ic on ic.card_id = cl.card_id
  join me on me.me_user_id is not null and cl.user_id = me.me_user_id
  group by cl.card_id
)
select
  ic.card_id,
  coalesce(c.like_count, 0)::bigint as like_count,
  (m.card_id is not null) as liked_by_me
from input_cards ic
left join counts c on c.card_id = ic.card_id
left join mine m on m.card_id = ic.card_id
order by ic.card_id;
$$;


ALTER FUNCTION "public"."get_card_like_stats"("p_card_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") RETURNS TABLE("activity_instance_id" "uuid", "completed_at" timestamp with time zone, "creator_display_name" "text", "fail_card_fee_minor" integer, "instance_sequence_no" integer, "instance_state" "text", "max_participants" integer, "min_participants" integer, "mode_kind" "public"."activity_mode_kind", "origin_id" "uuid", "parent_id" "uuid", "photo_path" "text", "play_context" "public"."template_play_context", "proof_kind" "text", "ref_state" "text", "ref_verdict" "text", "relationship_mode" "public"."template_relationship_mode", "rules" "text", "started_at" timestamp with time zone, "tap_groups" "jsonb", "title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if not exists (
    select 1
    from public.activity_instances ai
    where ai.id = p_instance_id
      and ai.created_by = v_app_user_id
      and ai.deleted_at is null
  ) then
    raise exception 'FORBIDDEN';
  end if;

  return query
  select *
  from private.build_final_call_payload(p_instance_id);
end;
$$;


ALTER FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") IS 'Owner-authenticated final call payload built directly from base tables, including private template data.';



CREATE OR REPLACE FUNCTION "public"."get_final_call_by_token"("p_token" "text") RETURNS TABLE("activity_instance_id" "uuid", "completed_at" timestamp with time zone, "creator_display_name" "text", "fail_card_fee_minor" integer, "instance_sequence_no" integer, "instance_state" "text", "max_participants" integer, "min_participants" integer, "mode_kind" "public"."activity_mode_kind", "origin_id" "uuid", "parent_id" "uuid", "photo_path" "text", "play_context" "public"."template_play_context", "proof_kind" "text", "ref_state" "text", "ref_verdict" "text", "relationship_mode" "public"."template_relationship_mode", "rules" "text", "started_at" timestamp with time zone, "tap_groups" "jsonb", "title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'private'
    AS $$
declare
  v_tok public.activity_instance_challenge_mail_tokens%rowtype;
  v_now timestamptz := now();
begin
  select *
  into v_tok
  from public.activity_instance_challenge_mail_tokens aimt
  where aimt.token = p_token
  for update;

  if not found then
    raise exception 'INVALID_TOKEN';
  end if;

  if v_tok.invalidated_at is not null then
    raise exception 'INVALID_TOKEN';
  end if;

  if v_tok.expires_at is not null and v_tok.expires_at <= v_now then
    raise exception 'TOKEN_EXPIRED';
  end if;

  if v_tok.action <> 'ref_access' then
    raise exception 'INVALID_TOKEN';
  end if;

  return query
  select *
  from private.build_final_call_payload(v_tok.activity_instance_id);
end;
$$;


ALTER FUNCTION "public"."get_final_call_by_token"("p_token" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_final_call_by_token"("p_token" "text") IS 'Token-gated final call payload for referee access. Treat the link as a secret because possession of the token grants access.';



CREATE OR REPLACE FUNCTION "public"."get_onboarding_status"() RETURNS TABLE("app_user_id" "uuid", "has_profile" boolean, "has_handle" boolean)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    return;
  end if;

  return query
  select
    v_app_user_id as app_user_id,
    exists(select 1 from public.profiles p where p.user_id = v_app_user_id) as has_profile,
    exists(
      select 1
      from public.profiles p
      where p.user_id = v_app_user_id
        and p.handle is not null
        and length(trim(p.handle)) > 0
    ) as has_handle;
end;
$$;


ALTER FUNCTION "public"."get_onboarding_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_profile_gate_status"() RETURNS TABLE("app_user_id" "uuid", "has_handle" boolean, "has_profile" boolean, "tutorial_step" "public"."tutorial_step_state")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    return;
  end if;

  return query
  select
    v_app_user_id,
    (p.handle is not null and btrim(p.handle) <> '') as has_handle,
    true as has_profile,
    p.tutorial_step
  from public.profiles p
  where p.user_id = v_app_user_id
  limit 1;
end;
$$;


ALTER FUNCTION "public"."get_profile_gate_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_card_detail"("p_card_id" "uuid") RETURNS TABLE("amount_minor" integer, "card_id" "uuid", "card_status" "public"."content_status", "challenge_id" "uuid", "challenge_result" "public"."verdict", "challenge_status" "public"."challenge_status", "challenge_title" "text", "currency" "text", "episode" "text", "like_count" bigint, "owner_avatar_url" "text", "owner_handle" "text", "photo_url" "text", "updated_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with selected_card as (
    select
      tc.id,
      tc.activity_instance_id,
      tc.note,
      tc.photo_path,
      tc.updated_at,
      ai.created_by,
      ai.state as activity_instance_state,
      ai.completed_at,
      ai.terminated_at,
      ai.updated_at as activity_updated_at,
      atpl.title as template_title,
      atpl.photo_path as template_photo_path,
      atpl.updated_at as template_updated_at,
      acc.fail_card_fee_minor,
      acc.ref_verdict,
      acc.challenger_final_verdict,
      acc.challenger_finalized_at,
      acc.updated_at as config_updated_at
    from public.tap_cards tc
    join public.activity_instances ai
      on ai.id = tc.activity_instance_id
    left join public.activity_templates atpl
      on atpl.id = ai.activity_template_id
    left join public.activity_instance_challenge_config acc
      on acc.activity_instance_id = ai.id
    where tc.id = p_card_id
      and tc.deleted_at is null
      and ai.deleted_at is null
      and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
      and ai.state = 'COMPLETED'::public.activity_instance_state
      and acc.ref_verdict in (
        'SUCCESS'::public.activity_ref_verdict,
        'FAIL'::public.activity_ref_verdict
      )
      and acc.challenger_final_verdict in (
        'SUCCESS'::public.activity_challenger_final_verdict,
        'FAIL'::public.activity_challenger_final_verdict
      )
  ),
  owner_profile as (
    select
      sc.id as card_id,
      p.handle,
      p.avatar_url
    from selected_card sc
    left join public.profiles p
      on p.user_id = sc.created_by
  ),
  like_stats as (
    select
      sc.id as card_id,
      count(tcl.id)::bigint as like_count
    from selected_card sc
    left join public.tap_card_likes tcl
      on tcl.tap_card_id = sc.id
    group by sc.id
  )
  select
    coalesce(sc.fail_card_fee_minor, 0)::integer as amount_minor,
    sc.id as card_id,
    'VISIBLE'::public.content_status as card_status,
    sc.activity_instance_id as challenge_id,
    case
      when sc.challenger_final_verdict = 'FAIL'::public.activity_challenger_final_verdict
        then 'FAIL'::public.verdict
      else 'SUCCESS'::public.verdict
    end as challenge_result,
    case
      when sc.challenger_final_verdict = 'FAIL'::public.activity_challenger_final_verdict
        then 'CHALLENGER_FINAL_FAIL'::public.challenge_status
      else 'CHALLENGER_FINAL_SUCCESS'::public.challenge_status
    end as challenge_status,
    sc.template_title as challenge_title,
    'USD'::text as currency,
    coalesce(sc.note, '') as episode,
    coalesce(ls.like_count, 0) as like_count,
    op.avatar_url as owner_avatar_url,
    op.handle as owner_handle,
    coalesce(sc.photo_path, sc.template_photo_path) as photo_url,
    greatest(
      sc.updated_at,
      sc.activity_updated_at,
      sc.template_updated_at,
      coalesce(sc.config_updated_at, sc.updated_at),
      coalesce(sc.challenger_finalized_at, sc.updated_at)
    ) as updated_at
  from selected_card sc
  left join owner_profile op
    on op.card_id = sc.id
  left join like_stats ls
    on ls.card_id = sc.id;
$$;


ALTER FUNCTION "public"."get_public_card_detail"("p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") RETURNS TABLE("profile_id" "uuid", "nickname" "text", "handle" "text", "bio" "text", "cg_title" "text", "avatar_url" "text", "updated_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    p.id as profile_id,
    p.nickname,
    p.handle,
    p.bio,
    p.cg_title,
    p.avatar_url,
    p.updated_at
  from public.profiles p
  where p.handle is not null
    and p.handle = p_handle
  limit 1;
$$;


ALTER FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) RETURNS TABLE("user_id" "uuid", "handle" "text", "nickname" "text", "avatar_url" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    p.user_id,
    p.handle,
    p.nickname,
    p.avatar_url
  from public.profiles p
  where p.user_id = any(coalesce(p_user_ids, array[]::uuid[]))
    and p.handle is not null
$$;


ALTER FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_public_tap_card_leaderboard"("p_result" "public"."verdict" DEFAULT NULL::"public"."verdict", "p_limit" integer DEFAULT 30, "p_offset" integer DEFAULT 0, "p_q" "text" DEFAULT NULL::"text") RETURNS TABLE("card_id" "uuid", "tap_id" "uuid", "activity_instance_id" "uuid", "activity_template_id" "uuid", "owner_user_id" "uuid", "owner_handle" "text", "owner_nickname" "text", "owner_avatar_url" "text", "instance_title" "text", "template_title" "text", "note" "text", "photo_path" "text", "fail_card_fee_minor" integer, "result" "public"."verdict", "like_count" bigint, "reply_count" bigint, "base_score" numeric, "card_created_at" timestamp with time zone, "card_updated_at" timestamp with time zone, "completed_at" timestamp with time zone, "rank_sort_at" timestamp with time zone, "snapshot_at" timestamp with time zone, "rank" bigint)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with filtered as (
    select *
    from public.tap_card_leaderboard_mv mv
    where (p_result is null or mv.result = p_result)
      and (
        coalesce(nullif(trim(p_q), ''), '') = ''
        or coalesce(mv.owner_handle, '') ilike '%' || trim(p_q) || '%'
        or coalesce(mv.owner_nickname, '') ilike '%' || trim(p_q) || '%'
        or coalesce(mv.instance_title, '') ilike '%' || trim(p_q) || '%'
        or coalesce(mv.template_title, '') ilike '%' || trim(p_q) || '%'
        or coalesce(mv.note, '') ilike '%' || trim(p_q) || '%'
      )
  ),
  ranked as (
    select
      filtered.*,
      row_number() over (
        order by
          filtered.base_score desc,
          filtered.reply_count desc,
          filtered.like_count desc,
          filtered.fail_card_fee_minor desc,
          filtered.rank_sort_at desc,
          filtered.card_id asc
      )::bigint as rank
    from filtered
  )
  select
    ranked.card_id,
    ranked.tap_id,
    ranked.activity_instance_id,
    ranked.activity_template_id,
    ranked.owner_user_id,
    ranked.owner_handle,
    ranked.owner_nickname,
    ranked.owner_avatar_url,
    ranked.instance_title,
    ranked.template_title,
    ranked.note,
    ranked.photo_path,
    ranked.fail_card_fee_minor,
    ranked.result,
    ranked.like_count,
    ranked.reply_count,
    ranked.base_score,
    ranked.card_created_at,
    ranked.card_updated_at,
    ranked.completed_at,
    ranked.rank_sort_at,
    ranked.snapshot_at,
    ranked.rank
  from ranked
  order by ranked.rank
  offset greatest(coalesce(p_offset, 0), 0)
  limit greatest(1, least(coalesce(p_limit, 30), 100));
$$;


ALTER FUNCTION "public"."get_public_tap_card_leaderboard"("p_result" "public"."verdict", "p_limit" integer, "p_offset" integer, "p_q" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_showcase_templates"("p_limit" integer DEFAULT 12) RETURNS TABLE("id" "uuid", "origin_id" "uuid", "title" "text", "rules" "text", "photo_path" "text", "creator_display_name" "text", "published_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  perform public.refresh_public_activity_templates();

  return query
  with ranked_templates as (
    select
      pat.id,
      pat.origin_id,
      pat.title,
      pat.rules,
      pat.photo_path,
      pat.creator_display_name,
      pat.published_at,
      row_number() over (
        partition by pat.origin_id
        order by pat.published_at desc, pat.id desc
      ) as origin_rank
    from public.public_activity_templates pat
    where pat.published_at is not null
  )
  select
    rt.id,
    rt.origin_id,
    rt.title,
    rt.rules,
    rt.photo_path,
    rt.creator_display_name,
    rt.published_at
  from ranked_templates rt
  where rt.origin_rank = 1
  order by rt.published_at desc, rt.id desc
  limit greatest(coalesce(p_limit, 12), 1);
end;
$$;


ALTER FUNCTION "public"."get_showcase_templates"("p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) RETURNS TABLE("card_id" "uuid", "like_count" bigint, "liked_by_me" boolean)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with current_app_user as (
    select public.app_user_id() as app_user_id
  ),
  requested_cards as (
    select unnest(p_card_ids) as card_id
  )
  select
    rc.card_id,
    coalesce(count(tcl.id), 0)::bigint as like_count,
    coalesce(bool_or(tcl.user_id = cau.app_user_id), false) as liked_by_me
  from requested_cards rc
  left join public.tap_card_likes tcl
    on tcl.tap_card_id = rc.card_id
  left join current_app_user cau
    on true
  group by rc.card_id
  order by rc.card_id;
$$;


ALTER FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_tap_dashboard"() RETURNS TABLE("activity_instance_id" "uuid", "tap_mode" "public"."activity_mode_kind", "title" "text", "rules" "text", "photo_path" "text", "play_context" "public"."template_play_context", "relationship_mode" "public"."template_relationship_mode", "proof_kind" "text", "started_at" timestamp with time zone, "updated_at" timestamp with time zone, "latest_tap_id" "uuid", "latest_tap_state" "public"."activity_tap_state", "latest_tap_sequence_no" integer, "latest_tap_first_happened_at" timestamp with time zone, "latest_tap_finalized_at" timestamp with time zone, "latest_tap_canceled_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with current_app_user as (
    select public.app_user_id() as app_user_id
  )
  select
    ai.id as activity_instance_id,
    ai.mode_kind as tap_mode,
    at.title,
    at.rules,
    at.photo_path,
    ai.play_context,
    ai.relationship_mode,
    at.proof_kind,
    ai.started_at,
    ai.updated_at,
    lt.id as latest_tap_id,
    lt.state as latest_tap_state,
    lt.sequence_no as latest_tap_sequence_no,
    lt.first_happened_at as latest_tap_first_happened_at,
    lt.finalized_at as latest_tap_finalized_at,
    lt.canceled_at as latest_tap_canceled_at
  from public.activity_instances ai
  join current_app_user cau
    on cau.app_user_id is not null
   and ai.created_by = cau.app_user_id
  join public.activity_instance_challenge_config aicc
    on aicc.activity_instance_id = ai.id
  join public.activity_templates at
    on at.id = ai.activity_template_id
   and at.created_by = cau.app_user_id
   and at.deleted_at is null
  left join lateral (
    select
      atp.id,
      atp.state,
      atp.sequence_no,
      atp.first_happened_at,
      atp.finalized_at,
      atp.canceled_at
    from public.activity_taps atp
    where atp.activity_instance_id = ai.id
    order by atp.sequence_no desc
    limit 1
  ) lt on true
  where ai.deleted_at is null
    and ai.mode_kind = 'CHALLENGE'::public.activity_mode_kind
    and ai.state = 'ACTIVE'::public.activity_instance_state
    and ai.completed_at is null
    and ai.terminated_at is null
    and aicc.ref_state = 'PENDING'::public.activity_ref_state
    and not exists (
      select 1
      from public.activity_instance_challenge_events aice
      where aice.activity_instance_id = ai.id
        and aice.event_type in (
          'REF_DECISION_SUCCESS'::public.challenge_event_type,
          'REF_DECISION_FAIL'::public.challenge_event_type,
          'REF_DECISION_DISAGREE'::public.challenge_event_type,
          'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
          'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
          'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
          'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
        )
    )
  order by ai.updated_at desc, ai.id desc;
$$;


ALTER FUNCTION "public"."get_tap_dashboard"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_today_tap_tray_cards"("p_limit" integer DEFAULT 24) RETURNS TABLE("id" "uuid", "activity_instance_id" "uuid", "tap_id" "uuid", "note" "text", "photo_path" "text", "created_at" timestamp with time zone, "activity_template_id" "uuid")
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with current_app_user as (
    select public.app_user_id() as app_user_id
  ),
  tap_day_window as (
    select
      timezone('America/New_York', now())::date as tap_day
  )
  select
    tc.id,
    tc.activity_instance_id,
    tc.tap_id,
    tc.note,
    tc.photo_path,
    tc.created_at,
    ai.activity_template_id
  from public.tap_cards tc
  join public.activity_instances ai
    on ai.id = tc.activity_instance_id
  join current_app_user cau
    on cau.app_user_id is not null
   and ai.created_by = cau.app_user_id
  join tap_day_window tdw
    on true
  where tc.deleted_at is null
    and ai.deleted_at is null
    and timezone('America/New_York', tc.created_at)::date = tdw.tap_day
  order by tc.created_at desc, tc.id desc
  limit greatest(coalesce(p_limit, 24), 1);
$$;


ALTER FUNCTION "public"."get_today_tap_tray_cards"("p_limit" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_weekly_tap_stats"() RETURNS TABLE("tap_count" integer, "tapper_count" integer, "window_start" timestamp with time zone, "window_end" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with bounds as (
    select
      now() - interval '7 days' as window_start,
      now() as window_end
  )
  select
    count(at.*)::integer as tap_count,
    count(distinct at.tapped_by)::integer as tapper_count,
    b.window_start,
    b.window_end
  from bounds b
  left join public.activity_taps at
    on at.finalized_at is not null
    and at.finalized_at >= b.window_start
    and at.finalized_at <= b.window_end
  group by b.window_start, b.window_end;
$$;


ALTER FUNCTION "public"."get_weekly_tap_stats"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_challenge_consent"("p_challenge_id" "uuid", "p_user_id" "uuid", "p_payload" "jsonb") RETURNS TABLE("success" boolean, "message" "text", "challenge_id_out" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  updated_challenge_id uuid;
begin
  -- 1. Update the challenge status and return the ID if successful
  update challenges
  set status = 'CONSENTED'
  where id = p_challenge_id
    and owner_id = p_user_id
    and status = 'FORM'
  returning id into updated_challenge_id;

  -- 2. Check if the update was successful
  if updated_challenge_id is null then
    return query select false, 'Challenge not found, already consented, or you are not the owner.', null::uuid;
    return;
  end if;

  -- 3. Insert the consent log
  insert into consent_logs (user_id, challenge_id, consent, payload)
  values (p_user_id, p_challenge_id, 'off_session', p_payload);

  -- 4. Return success
  return query select true, 'Consent processed successfully.', updated_challenge_id;

exception
  when others then
    -- In case of any other error, roll back and return a failure message
    return query select false, 'An unexpected error occurred during the consent process.', null::uuid;
end;
$$;


ALTER FUNCTION "public"."handle_challenge_consent"("p_challenge_id" "uuid", "p_user_id" "uuid", "p_payload" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_auth_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_provider_text text;
  v_provider public.auth_provider;
begin
  v_provider_text := lower(
    coalesce(
      new.raw_app_meta_data ->> 'provider',
      new.raw_user_meta_data ->> 'provider',
      'email'
    )
  );

  if v_provider_text not in ('google', 'apple', 'demo', 'email', 'other') then
    v_provider_text := 'other';
  end if;

  v_provider := v_provider_text::public.auth_provider;

  insert into public.app_users (auth_id, email, auth_provider)
  values (new.id, coalesce(new.email, ''), v_provider)
  on conflict (auth_id) do update
    set email = excluded.email
  where public.app_users.email is distinct from excluded.email;

  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_auth_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_active_app_session"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.app_auth_sessions s
    where s.app_user_id = public.app_user_id()
      and s.auth_session_id = public.current_auth_session_id()
  )
$$;


ALTER FUNCTION "public"."is_active_app_session"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_challenge_terminal"("s" "text") RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select s in (
    'CHALLENGER_FINAL_SUCCESS',
    'CHALLENGER_FINAL_FAIL',
    'CHALLENGER_FINAL_DISAGREE'
  );
$$;


ALTER FUNCTION "public"."is_challenge_terminal"("s" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_handle_available"("p_handle" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_handle text;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  v_handle := lower(btrim(coalesce(p_handle, '')));

  if v_handle = '' then
    return false;
  end if;

  return not exists (
    select 1
    from public.profiles p
    where lower(p.handle) = v_handle
      and p.user_id <> v_app_user_id
  );
end;
$$;


ALTER FUNCTION "public"."is_handle_available"("p_handle" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_nickname_taken"("p_nickname" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists(
    select 1
    from public.profiles
    where lower(nickname) = lower(trim(coalesce(p_nickname, '')))
      and nickname is not null
  )
$$;


ALTER FUNCTION "public"."is_nickname_taken"("p_nickname" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_operator"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM ops.operators o
    WHERE o.auth_id = auth.uid()
      AND o.disabled_at IS NULL
  )
$$;


ALTER FUNCTION "public"."is_operator"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_valid_handle"("p_handle" "text") RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $_$
  select public.normalize_handle(p_handle) ~ '^[a-z0-9_]{3,20}$'
$_$;


ALTER FUNCTION "public"."is_valid_handle"("p_handle" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") RETURNS TABLE("reply_id" "uuid", "card_id" "uuid", "user_id" "uuid", "body" "text", "status" "public"."content_status", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "edited_at" timestamp with time zone, "deleted_at" timestamp with time zone, "deleted_by" "public"."deleted_by", "edited_by" "uuid", "handle" "text", "avatar_url" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    tcr.id as reply_id,
    tcr.tap_card_id as card_id,
    tcr.user_id,
    tcr.body,
    tcr.status,
    tcr.created_at,
    tcr.updated_at,
    tcr.edited_at,
    tcr.deleted_at,
    tcr.deleted_by,
    tcr.edited_by,
    p.handle,
    p.avatar_url
  from public.tap_card_replies tcr
  join public.tap_cards tc
    on tc.id = tcr.tap_card_id
   and tc.deleted_at is null
  left join public.profiles p
    on p.user_id = tcr.user_id
  where tcr.tap_card_id = p_card_id
    and tcr.deleted_at is null
    and tcr.status = 'VISIBLE'::public.content_status
  order by tcr.created_at desc, tcr.id desc;
$$;


ALTER FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."normalize_handle"("p_handle" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select regexp_replace(lower(trim(coalesce(p_handle, ''))), '[^a-z0-9_]', '', 'g')
$$;


ALTER FUNCTION "public"."normalize_handle"("p_handle" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_template_reparent"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- parent_id immutable after insert
  IF NEW.parent_id IS DISTINCT FROM OLD.parent_id THEN
    RAISE EXCEPTION 'activity_templates.parent_id is immutable';
  END IF;

  -- origin_id immutable after insert
  IF NEW.origin_id IS DISTINCT FROM OLD.origin_id THEN
    RAISE EXCEPTION 'activity_templates.origin_id is immutable';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."prevent_template_reparent"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_final_call_projection"("p_activity_instance_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  declare
    v_row record;
  begin
    /*
      Build one projection row for the instance.
      Assumptions:
      - tap_cards.tap_sequence_no is the grouping key
      - tapped day is inferred from min(tap_cards.created_at) inside each tap group
      - deleted cards are excluded from projection
      - tap_card_id is included for authenticated cover-card selection flows
    */

    select
      api.id as activity_instance_id,

      pat.photo_path,
      pat.title,
      pat.rules,
      pat.origin_id,
      pat.parent_id,
      pat.creator_display_name,
      pat.min_participants,
      pat.max_participants,
      pat.mode_kind,
      pat.proof_kind,

      api.state as instance_state,
      api.started_at,
      api.completed_at,
      api.play_context,
      api.relationship_mode,
      api.sequence_no as instance_sequence_no,

      aicc.ref_state,
      aicc.ref_verdict,
      aicc.fail_card_fee_minor,

      coalesce(
        (
          select jsonb_agg(tap_group order by tap_sequence_no asc)
          from (
            select
              tcg.tap_sequence_no,
              jsonb_build_object(
                'tapSequenceNo', tcg.tap_sequence_no,
                'createdAt', tcg.tap_created_at,
                'cards', tcg.cards
              ) as tap_group
            from (
              select
                tc.tap_sequence_no,
                min(tc.created_at) as tap_created_at,
                jsonb_agg(
                  jsonb_build_object(
                    'tap_card_id', tc.id,
                    'photoPath', tc.photo_path,
                    'sequenceNo', tc.sequence_no,
                    'note', tc.note,
                    'linkUrl', tc.link_url,
                    'createdAt', tc.created_at
                  )
                  order by tc.sequence_no asc
                ) as cards
              from public.tap_cards tc
              where tc.activity_instance_id = api.id
                and tc.deleted_at is null
              group by tc.tap_sequence_no
            ) tcg
          ) grouped
        ),
        '[]'::jsonb
      ) as tap_groups
    into v_row
    from public.activity_instances api
    join public.public_activity_templates pat
      on pat.id = api.activity_template_id
    join public.activity_instance_challenge_config aicc
      on aicc.activity_instance_id = api.id
    where api.id = p_activity_instance_id;

    if not found then
      delete from public.final_call_projection
      where activity_instance_id = p_activity_instance_id;
      return;
    end if;

    insert into public.final_call_projection (
      activity_instance_id,
      photo_path,
      title,
      rules,
      origin_id,
      parent_id,
      creator_display_name,
      min_participants,
      max_participants,
      mode_kind,
      proof_kind,
      instance_state,
      started_at,
      completed_at,
      play_context,
      relationship_mode,
      instance_sequence_no,
      ref_state,
      ref_verdict,
      fail_card_fee_minor,
      tap_groups,
      updated_at
    )
    values (
      v_row.activity_instance_id,
      v_row.photo_path,
      v_row.title,
      v_row.rules,
      v_row.origin_id,
      v_row.parent_id,
      v_row.creator_display_name,
      v_row.min_participants,
      v_row.max_participants,
      v_row.mode_kind,
      v_row.proof_kind,
      v_row.instance_state,
      v_row.started_at,
      v_row.completed_at,
      v_row.play_context,
      v_row.relationship_mode,
      v_row.instance_sequence_no,
      v_row.ref_state,
      v_row.ref_verdict,
      v_row.fail_card_fee_minor,
      v_row.tap_groups,
      now()
    )
    on conflict (activity_instance_id)
    do update set
      photo_path = excluded.photo_path,
      title = excluded.title,
      rules = excluded.rules,
      origin_id = excluded.origin_id,
      parent_id = excluded.parent_id,
      creator_display_name = excluded.creator_display_name,
      min_participants = excluded.min_participants,
      max_participants = excluded.max_participants,
      mode_kind = excluded.mode_kind,
      proof_kind = excluded.proof_kind,
      instance_state = excluded.instance_state,
      started_at = excluded.started_at,
      completed_at = excluded.completed_at,
      play_context = excluded.play_context,
      relationship_mode = excluded.relationship_mode,
      instance_sequence_no = excluded.instance_sequence_no,
      ref_state = excluded.ref_state,
      ref_verdict = excluded.ref_verdict,
      fail_card_fee_minor = excluded.fail_card_fee_minor,
      tap_groups = excluded.tap_groups,
      updated_at = now();
  end;
  $$;


ALTER FUNCTION "public"."refresh_final_call_projection"("p_activity_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_leaderboard_views"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  refresh materialized view public.tap_card_leaderboard_mv;
$$;


ALTER FUNCTION "public"."refresh_leaderboard_views"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_public_activity_templates"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.public_activity_templates (
    id,
    origin_id,
    parent_id,
    title,
    rules,
    photo_path,
    creator_display_name,
    published_at,
    cadence_hint,
    max_participants,
    min_participants,
    mode_kind,
    play_context,
    proof_kind,
    relationship_mode
  )
  select
    at.id,
    at.origin_id,
    at.parent_id,
    at.title,
    at.rules,
    at.photo_path,
    at.creator_display_name,
    at.published_at,
    at.cadence_hint,
    at.max_participants,
    at.min_participants,
    at.mode_kind,
    at.play_context,
    at.proof_kind,
    at.relationship_mode
  from public.activity_templates at
  where at.visibility::text = 'PUBLIC'
    and at.lifecycle_state::text = 'PUBLISHED'
    and at.published_at is not null
    and at.deleted_at is null
  on conflict (id) do update
  set
    origin_id = excluded.origin_id,
    parent_id = excluded.parent_id,
    title = excluded.title,
    rules = excluded.rules,
    photo_path = excluded.photo_path,
    creator_display_name = excluded.creator_display_name,
    published_at = excluded.published_at,
    cadence_hint = excluded.cadence_hint,
    max_participants = excluded.max_participants,
    min_participants = excluded.min_participants,
    mode_kind = excluded.mode_kind,
    play_context = excluded.play_context,
    proof_kind = excluded.proof_kind,
    relationship_mode = excluded.relationship_mode;

  delete from public.public_activity_templates pat
  where not exists (
    select 1
    from public.activity_templates at
    where at.id = pat.id
      and at.visibility::text = 'PUBLIC'
      and at.lifecycle_state::text = 'PUBLISHED'
      and at.published_at is not null
      and at.deleted_at is null
  );
end;
$$;


ALTER FUNCTION "public"."refresh_public_activity_templates"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_leaderboard"("p_q" "text" DEFAULT NULL::"text", "p_tab" "text" DEFAULT 'ALL'::"text", "p_limit" integer DEFAULT 30, "p_offset" integer DEFAULT 0, "p_include_demo" boolean DEFAULT true) RETURNS TABLE("rank" integer, "handle" "text", "profile_id" "uuid", "user_id" "uuid", "nickname" "text", "avatar_url" "text", "total_spend_minor" bigint, "total_success_spend_minor" bigint, "total_fail_spend_minor" bigint, "total_success_count" integer, "total_fail_count" integer, "latest_card_id" "uuid", "latest_card_created_at" timestamp with time zone, "latest_challenge_title" "text", "last_result" "public"."verdict", "sim" real, "is_demo" boolean, "sort_seed" integer)
    LANGUAGE "plpgsql"
    AS $$
begin
  perform public.check_rate_limit_app_user('search_leaderboard', 60, 60);

  return query
  select
    x.rank,
    x.handle,
    x.profile_id,
    x.user_id,
    x.nickname,
    x.avatar_url,
    x.total_spend_minor,
    x.total_success_spend_minor,
    x.total_fail_spend_minor,
    x.total_success_count,
    x.total_fail_count,
    x.latest_card_id,
    x.latest_card_created_at,
    x.latest_challenge_title, -- ✅ add
    x.last_result,
    x.sim,
    x.is_demo,
    x.sort_seed
  from public.search_leaderboard_impl(
    p_q, p_tab, p_limit, p_offset, p_include_demo
  ) as x;
end;
$$;


ALTER FUNCTION "public"."search_leaderboard"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_leaderboard_impl"("p_q" "text" DEFAULT NULL::"text", "p_tab" "text" DEFAULT 'ALL'::"text", "p_limit" integer DEFAULT 30, "p_offset" integer DEFAULT 0, "p_include_demo" boolean DEFAULT true) RETURNS TABLE("rank" integer, "handle" "text", "profile_id" "uuid", "user_id" "uuid", "nickname" "text", "avatar_url" "text", "total_spend_minor" bigint, "total_success_spend_minor" bigint, "total_fail_spend_minor" bigint, "total_success_count" integer, "total_fail_count" integer, "latest_card_id" "uuid", "latest_card_created_at" timestamp with time zone, "latest_challenge_title" "text", "last_result" "public"."verdict", "sim" real, "is_demo" boolean, "sort_seed" integer)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
with
params as (
  select
    nullif(btrim(p_q), '') as q,
    case
      when upper(coalesce(p_tab, 'ALL')) = 'ALL' then null::verdict
      when upper(p_tab) = 'SUCCESS' then 'SUCCESS'::verdict
      when upper(p_tab) = 'FAIL' then 'FAIL'::verdict
      when upper(p_tab) = 'DISAGREE' then 'DISAGREE'::verdict
      else null::verdict
    end as tab_v,
    greatest(coalesce(p_limit, 30), 1) as lim,
    greatest(coalesce(p_offset, 0), 0) as off,
    coalesce(p_include_demo, true) as include_demo
),

real_base as (
  select
    us.user_id,

    p.handle,
    us.profile_id,

    p.nickname,
    p.avatar_url,

    us.total_spend_minor,
    us.total_success_spend_minor,
    us.total_fail_spend_minor,
    us.total_success_count,
    us.total_fail_count,
    us.latest_card_id,
    us.latest_card_created_at,

    ch.title as latest_challenge_title, -- ✅ add

    us.last_result
  from public.user_stats us
  left join public.public_profiles p
    on p.profile_id = us.profile_id
  left join public.challenge_cards cc
    on cc.id = us.latest_card_id
  left join public.challenges ch
    on ch.id = cc.challenge_id
),

real_filtered as (
  select
    rb.*,
    case
      when (select q from params) is null then null::real
      else similarity(coalesce(rb.nickname, ''), (select q from params))::real
    end as sim
  from real_base rb
  where
    (
      (select tab_v from params) is null
      or rb.last_result = (select tab_v from params)
    )
    and
    (
      (select q from params) is null
      or coalesce(rb.nickname, '') ilike ('%' || (select q from params) || '%')
    )
),

real_ranked as (
  select
    row_number() over (
      order by
        case when (select q from params) is null then null else sim end desc nulls last,
        total_spend_minor desc,
        latest_card_created_at desc nulls last,
        user_id asc
    ) as rnk,
    rf.*
  from real_filtered rf
),

demo_filtered as (
  select
    du.user_id,

    null::text as handle,
    null::uuid as profile_id,

    du.nickname,
    du.avatar_url,

    du.total_spend_minor,
    du.total_success_spend_minor,
    du.total_fail_spend_minor,
    du.total_success_count,
    du.total_fail_count,
    du.latest_card_id,
    du.latest_card_created_at,

    ch.title as latest_challenge_title, -- ✅ add

    du.last_result,
    du.is_demo,
    du.sort_seed,
    null::real as sim
  from public.demo_users du
  left join public.challenge_cards cc
    on cc.id = du.latest_card_id
  left join public.challenges ch
    on ch.id = cc.challenge_id
  where
    (
      (select tab_v from params) is null
      or du.last_result = (select tab_v from params)
    )
),

demo_ranked as (
  select
    row_number() over (
      order by
        total_spend_minor desc,
        sort_seed asc,
        user_id asc
    ) as rnk,
    df.*
  from demo_filtered df
),

merged_ranked as (
  select
    coalesce(r.rnk, d.rnk) as rank,

    coalesce(r.handle, d.handle) as handle,
    coalesce(r.profile_id, d.profile_id) as profile_id,

    coalesce(r.user_id, d.user_id) as user_id,
    coalesce(r.nickname, d.nickname) as nickname,
    coalesce(r.avatar_url, d.avatar_url) as avatar_url,

    coalesce(r.total_spend_minor, d.total_spend_minor) as total_spend_minor,
    coalesce(r.total_success_spend_minor, d.total_success_spend_minor) as total_success_spend_minor,
    coalesce(r.total_fail_spend_minor, d.total_fail_spend_minor) as total_fail_spend_minor,
    coalesce(r.total_success_count, d.total_success_count) as total_success_count,
    coalesce(r.total_fail_count, d.total_fail_count) as total_fail_count,

    coalesce(r.latest_card_id, d.latest_card_id) as latest_card_id,
    coalesce(r.latest_card_created_at, d.latest_card_created_at) as latest_card_created_at,
    coalesce(r.latest_challenge_title, d.latest_challenge_title) as latest_challenge_title, -- ✅ add

    coalesce(r.last_result, d.last_result) as last_result,

    null::real as sim,

    case when r.user_id is not null then false else d.is_demo end as is_demo,
    d.sort_seed as sort_seed
  from real_ranked r
  full outer join demo_ranked d on d.rnk = r.rnk
)

select
  x.rank,
  x.handle,
  x.profile_id,
  x.user_id,
  x.nickname,
  x.avatar_url,
  x.total_spend_minor,
  x.total_success_spend_minor,
  x.total_fail_spend_minor,
  x.total_success_count,
  x.total_fail_count,
  x.latest_card_id,
  x.latest_card_created_at,
  x.latest_challenge_title, -- ✅ add
  x.last_result,
  x.sim,
  x.is_demo,
  x.sort_seed
from params p
join lateral (
  -- 1) 검색이면: real만 반환 (demo 섞지 않음)
  select
    rr.rnk as rank,
    rr.handle,
    rr.profile_id,
    rr.user_id,
    rr.nickname,
    rr.avatar_url,
    rr.total_spend_minor,
    rr.total_success_spend_minor,
    rr.total_fail_spend_minor,
    rr.total_success_count,
    rr.total_fail_count,
    rr.latest_card_id,
    rr.latest_card_created_at,
    rr.latest_challenge_title, -- ✅ add
    rr.last_result,
    rr.sim,
    false as is_demo,
    null::int as sort_seed
  from real_ranked rr
  where p.q is not null

  union all

  -- 2) 기본랭킹이면: merged 사용 (real이 demo 동일 rank 덮어쓰기)
  select
    mr.rank,
    mr.handle,
    mr.profile_id,
    mr.user_id,
    mr.nickname,
    mr.avatar_url,
    mr.total_spend_minor,
    mr.total_success_spend_minor,
    mr.total_fail_spend_minor,
    mr.total_success_count,
    mr.total_fail_count,
    mr.latest_card_id,
    mr.latest_card_created_at,
    mr.latest_challenge_title, -- ✅ add
    mr.last_result,
    mr.sim,
    mr.is_demo,
    mr.sort_seed
  from merged_ranked mr
  where p.q is null and p.include_demo = true
) x on true
where x.rank > p.off and x.rank <= (p.off + p.lim)
order by x.rank asc;
$$;


ALTER FUNCTION "public"."search_leaderboard_impl"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_leaderboard_users"("q" "text", "mode" "text" DEFAULT 'success'::"text", "lim" integer DEFAULT 20, "off" integer DEFAULT 0) RETURNS TABLE("user_id" "uuid", "nickname" "text", "avatar_url" "text", "total_success_spend_minor" bigint, "total_fail_spend_minor" bigint, "total_success_count" integer, "total_fail_count" integer, "sim" real)
    LANGUAGE "sql" STABLE
    AS $$
  select
    p.user_id,
    p.nickname,
    p.avatar_url,
    us.total_success_spend_minor,
    us.total_fail_spend_minor,
    us.total_success_count,
    us.total_fail_count,
    similarity(p.nickname, q) as sim
  from public.profiles p
  join public.user_stats us
    on us.user_id = p.user_id
  where p.nickname ilike '%' || q || '%'
  order by
    case
      when mode = 'success' then us.total_success_spend_minor
      when mode = 'fail'    then us.total_fail_spend_minor
      else us.total_spend_minor
    end desc,
    sim desc,
    p.nickname asc
  limit least(coalesce(lim, 20), 50)
  offset coalesce(off, 0);
$$;


ALTER FUNCTION "public"."search_leaderboard_users"("q" "text", "mode" "text", "lim" integer, "off" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer DEFAULT 20) RETURNS TABLE("user_id" "uuid", "nickname" "text", "avatar_url" "text", "score" double precision)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    p.user_id,
    coalesce(p.nickname, '') as nickname,
    coalesce(p.avatar_url, '') as avatar_url,
    case
      when lower(p.nickname) = lower(trim(coalesce(q, ''))) then 1.0::double precision
      when lower(p.nickname) like lower(trim(coalesce(q, ''))) || '%' then 0.8::double precision
      else 0.5::double precision
    end as score
  from public.profiles p
  where p.nickname is not null
    and length(trim(coalesce(q, ''))) >= 2
    and lower(p.nickname) like '%' || lower(trim(q)) || '%'
  order by score desc, p.nickname asc
  limit least(greatest(coalesce(lim, 20), 1), 50)
$$;


ALTER FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_card_like"("p_card_id" "uuid", "p_like" boolean) RETURNS TABLE("out_card_id" "uuid", "liked" boolean, "like_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_user_id uuid;
  v_cnt bigint;
begin
  v_user_id := public.app_user_id();
  if v_user_id is null then
    raise exception 'auth_required';
  end if;

  if not exists (select 1 from public.challenge_cards c where c.id = p_card_id) then
    raise exception 'card_not_found';
  end if;

  if p_like then
    insert into public.card_likes(card_id, user_id)
    values (p_card_id, v_user_id)
    on conflict (card_id, user_id) do nothing;
  else
    delete from public.card_likes cl
    where cl.card_id = p_card_id
      and cl.user_id = v_user_id;
  end if;

  select count(*)::bigint
    into v_cnt
  from public.card_likes cl
  where cl.card_id = p_card_id;

  return query
  select p_card_id as card_id,
         p_like    as liked,
         v_cnt     as like_count;
end;
$$;


ALTER FUNCTION "public"."set_card_like"("p_card_id" "uuid", "p_like" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_challenge_cover_card"("p_activity_instance_id" "uuid", "p_cover_card_id" "uuid") RETURNS TABLE("ok" boolean, "result" "text", "activity_instance_id" "uuid", "cover_card_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  declare
    v_instance public.activity_instances%rowtype;
    v_cfg public.activity_instance_challenge_config%rowtype;
    v_card public.tap_cards%rowtype;
    v_latest_event public.activity_instance_challenge_events%rowtype;
  begin
    select *
      into v_instance
    from public.activity_instances ai
    where ai.id = p_activity_instance_id
    for update;

    if not found then
      return query
      select false, 'INSTANCE_NOT_FOUND', null::uuid, null::uuid;
      return;
    end if;

    if v_instance.deleted_at is not null then
      return query
      select false, 'INSTANCE_DELETED', v_instance.id, null::uuid;
      return;
    end if;

    select *
      into v_card
    from public.tap_cards tc
    where tc.id = p_cover_card_id
      and tc.deleted_at is null
    for update;

    if not found then
      return query
      select false, 'COVER_CARD_NOT_FOUND', v_instance.id, null::uuid;
      return;
    end if;

    if v_card.activity_instance_id <> v_instance.id then
      return query
      select false, 'COVER_CARD_INSTANCE_MISMATCH', v_instance.id, null::uuid;
      return;
    end if;

    select *
      into v_cfg
    from public.activity_instance_challenge_config aicc
    where aicc.activity_instance_id = v_instance.id
    for update;

    if not found then
      return query
      select false, 'CONFIG_NOT_FOUND', v_instance.id, null::uuid;
      return;
    end if;

    if v_cfg.ref_state <> 'DECIDED'::public.activity_ref_state then
      return query
      select false, 'REF_NOT_DECIDED', v_instance.id, null::uuid;
      return;
    end if;

    if v_instance.state not in (
      'COMPLETED'::public.activity_instance_state,
      'TERMINATED'::public.activity_instance_state
    ) then
      return query
      select false, 'INSTANCE_NOT_FINALIZED', v_instance.id, null::uuid;
      return;
    end if;

    select *
      into v_latest_event
    from public.activity_instance_challenge_events aice
    where aice.activity_instance_id = v_instance.id
    order by aice.created_at desc, aice.id desc
    limit 1;

    if not found then
      return query
      select false, 'EVENT_NOT_FOUND', v_instance.id, null::uuid;
      return;
    end if;

    if v_latest_event.event_type not in (
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    ) then
      return query
      select false, 'LATEST_EVENT_NOT_FINALIZED', v_instance.id, null::uuid;
      return;
    end if;

    update public.activity_instances ai
    set cover_card_id = p_cover_card_id,
        updated_at = now()
    where ai.id = v_instance.id;

    return query
    select true, 'OK', v_instance.id, p_cover_card_id;
  end;
  $$;


ALTER FUNCTION "public"."set_challenge_cover_card"("p_activity_instance_id" "uuid", "p_cover_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_tap_card_like"("p_card_id" "uuid", "p_like" boolean) RETURNS TABLE("card_id" "uuid", "like_count" bigint, "liked" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_like_count bigint;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  perform 1
  from public.tap_cards tc
  where tc.id = p_card_id
    and tc.deleted_at is null;

  if not found then
    raise exception 'CARD_NOT_FOUND';
  end if;

  if p_like then
    insert into public.tap_card_likes (tap_card_id, user_id)
    values (p_card_id, v_app_user_id)
    on conflict (tap_card_id, user_id) do nothing;
  else
    delete from public.tap_card_likes tcl
    where tcl.tap_card_id = p_card_id
      and tcl.user_id = v_app_user_id;
  end if;

  select count(*)::bigint
  into v_like_count
  from public.tap_card_likes tcl
  where tcl.tap_card_id = p_card_id;

  card_id := p_card_id;
  like_count := v_like_count;
  liked := p_like;
  return next;
end;
$$;


ALTER FUNCTION "public"."set_tap_card_like"("p_card_id" "uuid", "p_like" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_tutorial_step"("p_tutorial_step" "public"."tutorial_step_state") RETURNS "public"."tutorial_step_state"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_tutorial_step is null then
    raise exception 'INVALID_ARGUMENT';
  end if;

  update public.profiles p
  set
    tutorial_step = p_tutorial_step,
    updated_at = now(),
    updated_by = v_app_user_id
  where p.user_id = v_app_user_id;

  if not found then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return p_tutorial_step;
end;
$$;


ALTER FUNCTION "public"."set_tutorial_step"("p_tutorial_step" "public"."tutorial_step_state") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_activity_tap"("p_activity_instance_id" "uuid") RETURNS TABLE("ok" boolean, "action" "text", "tap_id" "uuid", "activity_instance_id" "uuid", "sequence_no" integer, "state" "public"."activity_tap_state", "finalized_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_latest_tap public.activity_taps%rowtype;
  v_new_tap public.activity_taps%rowtype;
  v_next_sequence integer;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'unauthorized';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'instance_not_found';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'instance_deleted';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'forbidden';
  end if;

  select *
  into v_latest_tap
  from public.activity_taps at
  where at.activity_instance_id = p_activity_instance_id
  order by at.sequence_no desc
  limit 1
  for update;

  if found
     and v_latest_tap.first_happened_at::date = now()::date then
    if v_latest_tap.finalized_at is null then
      if v_latest_tap.state = 'OPENED'::public.activity_tap_state then
        update public.activity_taps at
        set
          state = 'CANCELED'::public.activity_tap_state,
          canceled_at = now(),
          updated_at = now()
        where at.id = v_latest_tap.id
        returning *
        into v_latest_tap;

        return query
        select
          true,
          'CANCELED'::text,
          v_latest_tap.id,
          v_latest_tap.activity_instance_id,
          v_latest_tap.sequence_no,
          v_latest_tap.state,
          v_latest_tap.finalized_at;

        return;
      end if;

      if v_latest_tap.state = 'CANCELED'::public.activity_tap_state then
        update public.activity_taps at
        set
          state = 'OPENED'::public.activity_tap_state,
          canceled_at = null,
          updated_at = now()
        where at.id = v_latest_tap.id
        returning *
        into v_latest_tap;

        return query
        select
          true,
          'REOPENED'::text,
          v_latest_tap.id,
          v_latest_tap.activity_instance_id,
          v_latest_tap.sequence_no,
          v_latest_tap.state,
          v_latest_tap.finalized_at;

        return;
      end if;
    end if;

    return query
    select
      true,
      'ALREADY_RECORDED'::text,
      v_latest_tap.id,
      v_latest_tap.activity_instance_id,
      v_latest_tap.sequence_no,
      v_latest_tap.state,
      v_latest_tap.finalized_at;

    return;
  end if;

  v_next_sequence := coalesce(v_latest_tap.sequence_no, 0) + 1;

  insert into public.activity_taps (
    activity_instance_id,
    tapped_by,
    sequence_no,
    first_happened_at,
    state
  )
  values (
    p_activity_instance_id,
    v_app_user_id,
    v_next_sequence,
    now(),
    'OPENED'::public.activity_tap_state
  )
  returning *
  into v_new_tap;

  return query
  select
    true,
    'OPENED'::text,
    v_new_tap.id,
    v_new_tap.activity_instance_id,
    v_new_tap.sequence_no,
    v_new_tap.state,
    v_new_tap.finalized_at;
end;
$$;


ALTER FUNCTION "public"."toggle_activity_tap"("p_activity_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_card_like"("p_card_id" "uuid") RETURNS TABLE("card_id" "uuid", "liked" boolean, "like_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_user_id uuid;
  v_liked boolean;
  v_cnt bigint;
begin
  v_user_id := public.app_user_id();
  if v_user_id is null then
    raise exception 'auth_required';
  end if;

  -- card 존재 확인(선택): 없으면 에러
  if not exists (select 1 from public.challenge_cards c where c.id = p_card_id) then
    raise exception 'card_not_found';
  end if;

  -- 토글: 있으면 삭제, 없으면 삽입
  delete from public.card_likes
  where card_id = p_card_id and user_id = v_user_id;

  if found then
    v_liked := false;
  else
    insert into public.card_likes(card_id, user_id)
    values (p_card_id, v_user_id)
    on conflict (card_id, user_id) do nothing;
    v_liked := true;
  end if;

  -- 최신 카운트
  select count(*)::bigint into v_cnt
  from public.card_likes
  where card_id = p_card_id;

  return query
  select p_card_id, v_liked, v_cnt;
end;
$$;


ALTER FUNCTION "public"."toggle_card_like"("p_card_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."toggle_challenge_tap"("p_activity_instance_id" "uuid") RETURNS TABLE("ok" boolean, "action" "text", "tap_id" "uuid", "activity_instance_id" "uuid", "sequence_no" integer, "state" "public"."activity_tap_state", "finalized_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_instance public.activity_instances%rowtype;
  v_config public.activity_instance_challenge_config%rowtype;
  v_terminal_event public.activity_instance_challenge_events%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'unauthorized';
  end if;

  select *
  into v_instance
  from public.activity_instances ai
  where ai.id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'instance_not_found';
  end if;

  if v_instance.deleted_at is not null then
    raise exception 'instance_deleted';
  end if;

  if v_instance.created_by is distinct from v_app_user_id then
    raise exception 'forbidden';
  end if;

  if v_instance.mode_kind <> 'CHALLENGE'::public.activity_mode_kind then
    raise exception 'unsupported_tap_mode';
  end if;

  if v_instance.state <> 'ACTIVE'::public.activity_instance_state
     or v_instance.completed_at is not null
     or v_instance.terminated_at is not null then
    raise exception 'instance_not_tappable';
  end if;

  select *
  into v_config
  from public.activity_instance_challenge_config aicc
  where aicc.activity_instance_id = p_activity_instance_id
  for update;

  if not found then
    raise exception 'config_not_found';
  end if;

  if v_config.ref_state = 'DECIDED'::public.activity_ref_state then
    raise exception 'ref_already_decided';
  end if;

  select *
  into v_terminal_event
  from public.activity_instance_challenge_events aice
  where aice.activity_instance_id = p_activity_instance_id
    and aice.event_type in (
      'REF_DECISION_SUCCESS'::public.challenge_event_type,
      'REF_DECISION_FAIL'::public.challenge_event_type,
      'REF_DECISION_DISAGREE'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_SUCCESS'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_FAIL'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_CHICKEN'::public.challenge_event_type,
      'CHALLENGER_FINALIZED_DISAGREE'::public.challenge_event_type
    )
  order by aice.created_at desc, aice.id desc
  limit 1;

  if found then
    raise exception 'instance_not_tappable';
  end if;

  return query
  select *
  from public.toggle_activity_tap(p_activity_instance_id);
end;
$$;


ALTER FUNCTION "public"."toggle_challenge_tap"("p_activity_instance_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."touch_challenge_cards_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;


ALTER FUNCTION "public"."touch_challenge_cards_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."touch_challenges_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;


ALTER FUNCTION "public"."touch_challenges_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_profile_to_history"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_actor uuid;
begin
  -- 업데이트 주체 확정 (NOT NULL 보장용)
  v_actor := coalesce(new.updated_by, public.app_user_id(), old.updated_by);

  if v_actor is null then
    raise exception 'profiles_history requires updated_by (no actor found)';
  end if;

  insert into public.profiles_history (
    user_id,
    handle,
    avatar_url,
    nickname,
    bio,
    cg_title,
    valid_from,
    valid_to,
    updated_at,
    updated_by,
    avatar_sha256
  )
  values (
    old.user_id,
    old.handle,
    old.avatar_url,
    old.nickname,
    old.bio,
    old.cg_title,
    coalesce(old.updated_at, now()),
    now(),
    now(),
    v_actor,
    case
      when old.avatar_url is not null then
        encode(
          extensions.digest(
            convert_to(coalesce(old.avatar_url,''), 'UTF8')::bytea,
            'sha256'::text
          ),
          'hex'
        )
    end
  );

  -- 현재 row 메타 갱신
  new.updated_at := now();
  new.updated_by := v_actor;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_profile_to_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_profiles_avatar_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$declare
  v_count int;
  v_window_start timestamptz := now() - interval '24 hours';
begin
  -- 아바타가 실제로 바뀌는 경우에만 제한/로그/이력 처리
  if new.avatar_url is distinct from old.avatar_url then
    -- 1) 24시간 내 변경 회수 집계
    select count(*) into v_count
      from public.avatar_change_logs
     where user_id = old.user_id
       and changed_at >= v_window_start;

    -- 2) 제한 초과면 차단 (운영자면 우회하고 싶다면 is_operator()로 예외 허용 가능)
    if v_count >= 3 then
      raise exception 'AVATAR_CHANGE_LIMIT: You can change avatar at most 3 times per 24 hours.'
        using errcode = 'P0001';
    end if;

    -- 3) 이력에 OLD 상태 저장 -> 트리거로 insert 중이어서 안 씀
    -- insert into public.profiles_history (
    --   user_id, avatar_url, nickname, bio,
    --   valid_from, valid_to, changed_by
    -- )
    -- values (
    --   old.user_id, old.avatar_url, old.nickname, old.bio,
    --   coalesce(old.updated_at, now()), now(), auth.uid()
    -- );

    -- 4) 변경 로그 적재 (카운트 근거)
    insert into public.avatar_change_logs (user_id) values (old.user_id);
  end if;

  -- 5) 공통 메타 업데이트
  new.updated_at := now();
  new.updated_by := auth.uid();

  return new;
end;$$;


ALTER FUNCTION "public"."trg_profiles_avatar_limit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_profiles_ensure_handle"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  -- handle이 없으면 자동 생성
  -- UPDATE에서 handle을 null로 바꿔도 다시 생성되게 처리(공개 키가 항상 존재하도록)
  if new.handle is null or length(btrim(new.handle)) = 0 then
    new.handle := public.generate_default_handle();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_profiles_ensure_handle"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_profiles_sync_public_profiles"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if (tg_op = 'DELETE') then
    delete from public.public_profiles
    where profile_id = old.id;
    return old;
  end if;

  -- handle 없으면 public_profiles에는 반영하지 않음
  if new.handle is null then
    delete from public.public_profiles where profile_id = new.id;
    return new;
  end if;

  insert into public.public_profiles (
    profile_id, handle, avatar_url, nickname, bio, cg_title, updated_at
  )
  values (
    new.id, new.handle, new.avatar_url, new.nickname, new.bio, new.cg_title, new.updated_at
  )
  on conflict (profile_id) do update set
    handle = excluded.handle,
    avatar_url = excluded.avatar_url,
    nickname = excluded.nickname,
    bio = excluded.bio,
    cg_title = excluded.cg_title,
    updated_at = excluded.updated_at;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_profiles_sync_public_profiles"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_update_latest_card"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
declare
  v_user uuid;
  v_newer boolean;
begin
  if TG_OP = 'INSERT' then
    -- 카드 → 챌린지 → owner
    select c.owner_id into v_user
    from public.challenges c
    where c.id = NEW.challenge_id;

    if v_user is null then
      return NEW;
    end if;

    -- user_stats 행 보장
    insert into public.user_stats(user_id) values (v_user)
    on conflict (user_id) do nothing;

    -- 더 최신이면 교체 (컬럼명은 네 스키마에 맞춰 교체)
    select (us.latest_card_created_at is null or NEW.created_at >= us.latest_card_created_at)
      into v_newer
    from public.user_stats us
    where us.user_id = v_user;

    if v_newer then
      update public.user_stats
         set latest_card_id         = NEW.id,               -- ← challenge_cards의 PK
             latest_card_created_at = NEW.created_at        -- ← 생성시각 컬럼
       where user_id = v_user;
    end if;

    return NEW;

  elsif TG_OP = 'UPDATE' then
    -- UPDATE는 NEW/OLD 모두 존재
    select c.owner_id into v_user
    from public.challenges c
    where c.id = coalesce(NEW.challenge_id, OLD.challenge_id);

    if v_user is null then
      return NEW;
    end if;

    -- 최신성 비교 후 교체 (created_at 안 바뀌면 상태만 반영하려면 조건 조정)
    if NEW.created_at >= coalesce((
         select latest_card_created_at from public.user_stats where user_id = v_user
       ), 'epoch'::timestamptz)
    then
      update public.user_stats
         set latest_card_id         = NEW.id,
             latest_card_created_at = NEW.created_at
       where user_id = v_user;
    end if;

    return NEW;
  end if;

  -- AFTER 트리거에서는 반환값이 무시되지만 문법상 필요
  return coalesce(NEW, OLD);
end;
$$;


ALTER FUNCTION "public"."trg_update_latest_card"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_user_stats_fill_profile_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_profile_id uuid;
begin
  if new.profile_id is not null then
    return new;
  end if;

  -- user_stats.user_id(app_user_id FK) -> profiles.user_id 매칭 -> profiles.id 취득
  select p.id
    into v_profile_id
  from public.profiles p
  where p.user_id = new.user_id;

  -- profiles가 아직 없다면 NULL 유지 (원하면 여기서 예외를 던질 수도 있음)
  new.profile_id := v_profile_id;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_user_stats_fill_profile_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trg_user_stats_on_challenge_terminal"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_latest_card_id uuid;
  v_latest_card_created_at timestamptz;
begin
  -- terminal로 "처음" 진입할 때만
  if is_challenge_terminal(old.status::text) then
    return new;
  end if;

  if not is_challenge_terminal(new.status::text) then
    return new;
  end if;

  -- user_stats row 보장
  insert into public.user_stats(user_id)
  values (new.owner_id)
  on conflict (user_id) do nothing;

  -- latest card 조회(없을 수도 있음)
  select c.id, c.created_at
    into v_latest_card_id, v_latest_card_created_at
  from public.challenge_cards c
  where c.challenge_id = new.id
    and c.deleted_at is null
    and c.status = 'VISIBLE'
  order by c.created_at desc
  limit 1;

  -- 누산 업데이트
  update public.user_stats us
  set
    total_spend_minor = us.total_spend_minor + coalesce(new.amount_minor, 0),
    total_success_spend_minor = us.total_success_spend_minor + case when new.status::text = 'CHALLENGER_FINAL_SUCCESS' then coalesce(new.amount_minor,0) else 0 end,
    total_fail_spend_minor = us.total_fail_spend_minor + case when new.status::text = 'CHALLENGER_FINAL_FAIL' then coalesce(new.amount_minor,0) else 0 end,

    total_success_count = us.total_success_count + case when new.status::text = 'CHALLENGER_FINAL_SUCCESS' then 1 else 0 end,
    total_fail_count    = us.total_fail_count    + case when new.status::text = 'CHALLENGER_FINAL_FAIL' then 1 else 0 end,
    total_dispute_count = us.total_dispute_count + case when new.status::text = 'CHALLENGER_FINAL_DISAGREE' then 1 else 0 end,

    latest_card_id = coalesce(v_latest_card_id, us.latest_card_id),
    latest_card_created_at = greatest(coalesce(us.latest_card_created_at, 'epoch'::timestamptz),
                                      coalesce(v_latest_card_created_at, us.latest_card_created_at)),

    last_payment_at = case
      when coalesce(new.amount_minor, 0) > 0 then greatest(coalesce(us.last_payment_at, 'epoch'::timestamptz), now())
      else us.last_payment_at
    end
  where us.user_id = new.owner_id;

  return new;
end;
$$;


ALTER FUNCTION "public"."trg_user_stats_on_challenge_terminal"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_avatar"("p_avatar_url" "text") RETURNS TABLE("profile_id" "uuid", "user_id" "uuid", "avatar_url" "text", "updated_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select * from public.update_avatar_v1(p_avatar_url);
$$;


ALTER FUNCTION "public"."update_avatar"("p_avatar_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_avatar_v1"("p_avatar_url" "text") RETURNS TABLE("profile_id" "uuid", "user_id" "uuid", "avatar_url" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_actor uuid;
  v_profile_id uuid;
  v_now timestamptz;

  v_cnt int;

  -- old snapshot (history용)
  v_prev_updated_at timestamptz;
  v_prev_handle text;
  v_prev_avatar_url text;
  v_prev_nickname text;
  v_prev_bio text;
  v_prev_cg_title text;
begin
  v_now := now();
  v_actor := public.app_user_id();

  if v_actor is null then
    raise exception 'AVATAR: not authenticated';
  end if;

  -- 입력 검증(원하면 더 강하게: URL 형식 등)
  if p_avatar_url is null or length(btrim(p_avatar_url)) = 0 then
    raise exception 'AVATAR: avatar_url required';
  end if;

  -- 온보딩 완료 강제: handle이 있어야 한다
  if not exists (
    select 1
    from public.profiles p
    where p.user_id = v_actor
      and p.handle is not null
      and length(btrim(p.handle)) > 0
  ) then
    raise exception 'AVATAR: onboarding required';
  end if;

  -- 24시간 내 변경 횟수 제한 (>=3이면 차단)
  select count(*)
  into v_cnt
  from public.avatar_change_log l
  where l.user_id = v_actor
    and l.changed_at >= v_now - interval '24 hours';

  if v_cnt >= 3 then
    raise exception 'AVATAR: change limit exceeded (24h)';
  end if;

  -- 현재 profiles 스냅샷 확보(=old)
  select
    p.id,
    p.updated_at,
    p.handle,
    p.avatar_url,
    p.nickname,
    p.bio,
    p.cg_title
  into
    v_profile_id,
    v_prev_updated_at,
    v_prev_handle,
    v_prev_avatar_url,
    v_prev_nickname,
    v_prev_bio,
    v_prev_cg_title
  from public.profiles p
  where p.user_id = v_actor;

  if v_profile_id is null then
    raise exception 'AVATAR: profile missing';
  end if;

  -- profiles 업데이트
  update public.profiles p
  set
    avatar_url = p_avatar_url,
    updated_at = v_now,
    updated_by = v_actor
  where p.id = v_profile_id;

  -- avatar_change_log 기록(원자화)
  insert into public.avatar_change_log(user_id, avatar_url, changed_at)
  values (v_actor, p_avatar_url, v_now);

  -- profiles_history: 기존 현재 유효행 닫기
  update public.profiles_history h
  set
    valid_to = v_now,
    updated_at = v_now,
    updated_by = v_actor
  where h.user_id = v_actor
    and h.valid_to = 'infinity'::timestamptz;

  -- profiles_history: old 스냅샷 적재(트리거 의미 유지)
  insert into public.profiles_history (
    user_id,
    handle,
    avatar_url,
    nickname,
    bio,
    cg_title,
    valid_from,
    valid_to,
    updated_at,
    updated_by,
    avatar_sha256
  )
  values (
    v_actor,
    v_prev_handle,
    v_prev_avatar_url,
    v_prev_nickname,
    v_prev_bio,
    v_prev_cg_title,
    coalesce(v_prev_updated_at, v_now),
    v_now,
    v_now,
    v_actor,
    case
      when v_prev_avatar_url is not null then
        encode(
          extensions.digest(
            convert_to(coalesce(v_prev_avatar_url,''), 'UTF8')::bytea,
            'sha256'::text
          ),
          'hex'
        )
    end
  );

  -- profiles_history: new 현재 상태를 infinity로 오픈
  insert into public.profiles_history (
    user_id,
    handle,
    avatar_url,
    nickname,
    bio,
    cg_title,
    valid_from,
    valid_to,
    updated_at,
    updated_by,
    avatar_sha256
  )
  select
    p.user_id,
    p.handle,
    p.avatar_url,
    p.nickname,
    p.bio,
    p.cg_title,
    v_now,
    'infinity'::timestamptz,
    v_now,
    v_actor,
    case
      when p.avatar_url is not null then
        encode(
          extensions.digest(
            convert_to(coalesce(p.avatar_url,''), 'UTF8')::bytea,
            'sha256'::text
          ),
          'hex'
        )
    end
  from public.profiles p
  where p.id = v_profile_id;

  -- public_profiles 동기화
  insert into public.public_profiles (profile_id, handle, avatar_url, nickname, bio, cg_title, updated_at)
  select p.id, p.handle, p.avatar_url, p.nickname, p.bio, p.cg_title, p.updated_at
  from public.profiles p
  where p.id = v_profile_id
  on conflict (profile_id) do update set
    avatar_url = excluded.avatar_url,
    updated_at = excluded.updated_at;

  return query
  select p.id, p.user_id, p.avatar_url, p.updated_at
  from public.profiles p
  where p.id = v_profile_id;
end;
$$;


ALTER FUNCTION "public"."update_avatar_v1"("p_avatar_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_profile"("p_nickname" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text") RETURNS TABLE("profile_id" "uuid", "user_id" "uuid", "handle" "text", "nickname" "text", "avatar_url" "text", "bio" "text", "cg_title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select * from public.update_profile_v1(p_nickname, p_bio, p_cg_title);
$$;


ALTER FUNCTION "public"."update_profile"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_profile_card_for_app_user"("p_app_user_id" "uuid", "p_bio" "text" DEFAULT NULL::"text", "p_avatar_url" "text" DEFAULT NULL::"text", "p_update_bio" boolean DEFAULT false, "p_update_avatar" boolean DEFAULT false) RETURNS TABLE("id" "uuid", "user_id" "uuid", "nickname" "text", "handle" "text", "bio" "text", "cg_title" "text", "avatar_url" "text", "updated_at" timestamp with time zone, "updated_by" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if p_app_user_id is null or not exists (
    select 1
    from public.app_users u
    where u.id = p_app_user_id
      and u.deleted_at is null
  ) then
    raise exception 'UNAUTHORIZED';
  end if;

  if coalesce(p_update_bio, false) and length(coalesce(p_bio, '')) > 2000 then
    raise exception 'INVALID_BIO';
  end if;

  if coalesce(p_update_avatar, false)
    and p_avatar_url is not null
    and (
      length(p_avatar_url) > 2048
      or p_avatar_url !~ '^https?://'
      or p_avatar_url ~ '[[:cntrl:]]'
    )
  then
    raise exception 'INVALID_AVATAR_URL';
  end if;

  update public.profiles p
    set bio = case when coalesce(p_update_bio, false) then nullif(trim(coalesce(p_bio, '')), '') else p.bio end,
        avatar_url = case when coalesce(p_update_avatar, false) then nullif(trim(coalesce(p_avatar_url, '')), '') else p.avatar_url end,
        updated_at = now(),
        updated_by = p_app_user_id
  where p.user_id = p_app_user_id;

  if not found then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return query
  select
    p.id,
    p.user_id,
    p.nickname,
    p.handle,
    p.bio,
    p.cg_title,
    p.avatar_url,
    p.updated_at,
    p.updated_by
  from public.profiles p
  where p.user_id = p_app_user_id;
end;
$$;


ALTER FUNCTION "public"."update_profile_card_for_app_user"("p_app_user_id" "uuid", "p_bio" "text", "p_avatar_url" "text", "p_update_bio" boolean, "p_update_avatar" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_profile_v1"("p_nickname" "text" DEFAULT NULL::"text", "p_bio" "text" DEFAULT NULL::"text", "p_cg_title" "text" DEFAULT NULL::"text") RETURNS TABLE("profile_id" "uuid", "user_id" "uuid", "handle" "text", "nickname" "text", "avatar_url" "text", "bio" "text", "cg_title" "text", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_actor uuid;
  v_profile_id uuid;
  v_now timestamptz;
  v_prev_updated_at timestamptz;
  v_prev_handle text;
  v_prev_avatar_url text;
  v_prev_nickname text;
  v_prev_bio text;
  v_prev_cg_title text;
begin
  v_now := now();
  v_actor := public.app_user_id();

  if v_actor is null then
    raise exception 'PROFILE: not authenticated';
  end if;

  -- 온보딩 완료 강제: handle이 있어야 한다
  if not exists (
    select 1
    from public.profiles p
    where p.user_id = v_actor
      and p.handle is not null
      and length(btrim(p.handle)) > 0
  ) then
    raise exception 'PROFILE: onboarding required';
  end if;

  -- (1) 현재 profiles 스냅샷을 먼저 확보 (history를 위해)
  select
    p.id,
    p.updated_at,
    p.handle,
    p.avatar_url,
    p.nickname,
    p.bio,
    p.cg_title
  into
    v_profile_id,
    v_prev_updated_at,
    v_prev_handle,
    v_prev_avatar_url,
    v_prev_nickname,
    v_prev_bio,
    v_prev_cg_title
  from public.profiles p
  where p.user_id = v_actor;

  if v_profile_id is null then
    raise exception 'PROFILE: profile missing';
  end if;

  -- (2) profiles 업데이트 (handle은 건드리지 않음)
  update public.profiles p
  set
    nickname = p_nickname,
    bio = p_bio,
    cg_title = p_cg_title,
    updated_at = v_now,
    updated_by = v_actor
  where p.id = v_profile_id;

  -- (3) profiles_history: 기존 "현재 유효" 행 닫기
  -- 현재 유효행은 valid_to='infinity'로 가정
  update public.profiles_history h
  set
    valid_to = v_now,
    updated_at = v_now,
    updated_by = v_actor
  where h.user_id = v_actor
    and h.valid_to = 'infinity'::timestamptz;

  -- (4) profiles_history: "이전 상태(old)"를 기록 (트리거 로직의 본질)
  insert into public.profiles_history (
    user_id,
    handle,
    avatar_url,
    nickname,
    bio,
    cg_title,
    valid_from,
    valid_to,
    updated_at,
    updated_by,
    avatar_sha256
  )
  values (
    v_actor,
    v_prev_handle,
    v_prev_avatar_url,
    v_prev_nickname,
    v_prev_bio,
    v_prev_cg_title,
    coalesce(v_prev_updated_at, v_now),
    v_now,
    v_now,
    v_actor,
    case
      when v_prev_avatar_url is not null then
        encode(
          extensions.digest(
            convert_to(coalesce(v_prev_avatar_url,''), 'UTF8')::bytea,
            'sha256'::text
          ),
          'hex'
        )
    end
  );

  -- (5) profiles_history: "새 현재 상태"를 infinity로 열기
  insert into public.profiles_history (
    user_id,
    handle,
    avatar_url,
    nickname,
    bio,
    cg_title,
    valid_from,
    valid_to,
    updated_at,
    updated_by,
    avatar_sha256
  )
  select
    p.user_id,
    p.handle,
    p.avatar_url,
    p.nickname,
    p.bio,
    p.cg_title,
    v_now,
    'infinity'::timestamptz,
    v_now,
    v_actor,
    case
      when p.avatar_url is not null then
        encode(
          extensions.digest(
            convert_to(coalesce(p.avatar_url,''), 'UTF8')::bytea,
            'sha256'::text
          ),
          'hex'
        )
    end
  from public.profiles p
  where p.id = v_profile_id;

  -- (6) public_profiles 동기화 (upsert)
  insert into public.public_profiles (profile_id, handle, avatar_url, nickname, bio, cg_title, updated_at)
  select p.id, p.handle, p.avatar_url, p.nickname, p.bio, p.cg_title, p.updated_at
  from public.profiles p
  where p.id = v_profile_id
  on conflict (profile_id) do update set
    -- handle은 변경 불가지만 혹시라도 동기화 관점에서 포함
    handle = excluded.handle,
    avatar_url = excluded.avatar_url,
    nickname = excluded.nickname,
    bio = excluded.bio,
    cg_title = excluded.cg_title,
    updated_at = excluded.updated_at;

  -- return
  return query
  select p.id, p.user_id, p.handle, p.nickname, p.avatar_url, p.bio, p.cg_title, p.updated_at
  from public.profiles p
  where p.id = v_profile_id;
end;
$$;


ALTER FUNCTION "public"."update_profile_v1"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_tap_card_reply"("p_reply_id" "uuid", "p_body" "text") RETURNS TABLE("reply_id" "uuid", "card_id" "uuid", "user_id" "uuid", "body" "text", "status" "public"."content_status", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "edited_at" timestamp with time zone, "deleted_at" timestamp with time zone, "deleted_by" "public"."deleted_by", "edited_by" "uuid", "handle" "text", "avatar_url" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_app_user_id uuid;
  v_reply public.tap_card_replies%rowtype;
begin
  v_app_user_id := public.app_user_id();

  if v_app_user_id is null then
    raise exception 'UNAUTHORIZED';
  end if;

  if p_reply_id is null then
    raise exception 'REPLY_NOT_FOUND';
  end if;

  if p_body is null or btrim(p_body) = '' then
    raise exception 'EMPTY_REPLY';
  end if;

  select *
  into v_reply
  from public.tap_card_replies tcr
  where tcr.id = p_reply_id
  for update;

  if not found then
    raise exception 'REPLY_NOT_FOUND';
  end if;

  if v_reply.deleted_at is not null then
    raise exception 'REPLY_DELETED';
  end if;

  if v_reply.user_id is distinct from v_app_user_id and not public.is_operator() then
    raise exception 'FORBIDDEN';
  end if;

  return query
  update public.tap_card_replies tcr
  set
    body = btrim(p_body),
    edited_at = now(),
    edited_by = v_app_user_id,
    updated_at = now()
  where tcr.id = v_reply.id
  returning
    tcr.id as reply_id,
    tcr.tap_card_id as card_id,
    tcr.user_id,
    tcr.body,
    tcr.status,
    tcr.created_at,
    tcr.updated_at,
    tcr.edited_at,
    tcr.deleted_at,
    tcr.deleted_by,
    tcr.edited_by,
    (
      select p.handle
      from public.profiles p
      where p.user_id = tcr.user_id
      limit 1
    ) as handle,
    (
      select p.avatar_url
      from public.profiles p
      where p.user_id = tcr.user_id
      limit 1
    ) as avatar_url;
end;
$$;


ALTER FUNCTION "public"."update_tap_card_reply"("p_reply_id" "uuid", "p_body" "text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_config" (
    "activity_instance_id" "uuid" NOT NULL,
    "ref_user_id" "uuid",
    "ref_email" "text" NOT NULL,
    "ref_state" "public"."activity_ref_state" DEFAULT 'PENDING'::"public"."activity_ref_state" NOT NULL,
    "ref_verdict" "public"."activity_ref_verdict",
    "ref_decided_at" timestamp with time zone,
    "fail_card_fee_minor" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_ref_resend_at" timestamp with time zone,
    "challenger_finalized_at" timestamp with time zone,
    "challenger_final_verdict" "public"."activity_challenger_final_verdict",
    CONSTRAINT "activity_instance_challenge_config_decided_check" CHECK ((("ref_state" <> 'DECIDED'::"public"."activity_ref_state") OR (("ref_verdict" IS NOT NULL) AND ("ref_decided_at" IS NOT NULL)))),
    CONSTRAINT "activity_instance_challenge_config_fail_card_fee_nonnegative_ch" CHECK (("fail_card_fee_minor" >= 0)),
    CONSTRAINT "activity_instance_challenge_config_pending_clear_check" CHECK ((("ref_state" <> 'PENDING'::"public"."activity_ref_state") OR (("ref_verdict" IS NULL) AND ("ref_decided_at" IS NULL))))
);


ALTER TABLE "public"."activity_instance_challenge_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_disputes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "submitted_by" "uuid",
    "submitted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "reason_code" "text" NOT NULL,
    "details" "text",
    "ref_verdict" "public"."activity_ref_verdict",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."activity_instance_challenge_disputes" OWNER TO "postgres";


COMMENT ON TABLE "public"."activity_instance_challenge_disputes" IS 'Structured dispute records submitted by challengers after a referee decision.';



COMMENT ON COLUMN "public"."activity_instance_challenge_disputes"."reason_code" IS 'Stable dispute category code such as INCORRECT_VERDICT or OTHER.';



COMMENT ON COLUMN "public"."activity_instance_challenge_disputes"."details" IS 'Optional free-text explanation supplied by the challenger.';



COMMENT ON COLUMN "public"."activity_instance_challenge_disputes"."ref_verdict" IS 'Snapshot of the referee verdict being disputed at submission time.';



CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "payload" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "event_type" "public"."challenge_event_type"
);


ALTER TABLE "public"."activity_instance_challenge_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_mail_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "token" "text" NOT NULL,
    "action" "text" NOT NULL,
    "used_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone,
    "invalidated_at" timestamp with time zone,
    CONSTRAINT "challenge_mail_tokens_action_check" CHECK (("action" = ANY (ARRAY['ref_access'::"text", 'mark_success'::"text", 'mark_fail'::"text", 'mark_disagree'::"text"])))
);


ALTER TABLE "public"."activity_instance_challenge_mail_tokens" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_payment_attempts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "challenge_payment_id" "uuid" NOT NULL,
    "idempotency_key" "text" NOT NULL,
    "provider_checkout_id" "text",
    "error_code" "text",
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" "public"."payment_attempt_status" DEFAULT 'SCHEDULED'::"public"."payment_attempt_status" NOT NULL
);


ALTER TABLE "public"."activity_instance_challenge_payment_attempts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_payment_webhook_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "provider" "public"."payment_provider" NOT NULL,
    "event_id" "text" NOT NULL,
    "event_type" "text" NOT NULL,
    "challenge_payment_id" "uuid",
    "provider_order_id" "text",
    "provider_checkout_id" "text",
    "received_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "processed_at" timestamp with time zone,
    "status" "public"."webhook_proc_status" DEFAULT 'RECEIVED'::"public"."webhook_proc_status" NOT NULL,
    "attempts" integer DEFAULT 0 NOT NULL,
    "last_error" "text",
    "payload" "jsonb" NOT NULL
);


ALTER TABLE "public"."activity_instance_challenge_payment_webhook_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_challenge_payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "provider" "public"."payment_provider" NOT NULL,
    "provider_payment_id" "text",
    "idempotency_key" "text",
    "status" "public"."payment_status" DEFAULT 'INIT'::"public"."payment_status" NOT NULL,
    "amount_minor" integer NOT NULL,
    "currency" character(3) DEFAULT 'USD'::"bpchar" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "raw_payload" "jsonb",
    "provider_order_id" "text",
    "provider_checkout_id" "text",
    "idempotency_scope" "text",
    "amount_refunded_minor" integer DEFAULT 0,
    "tax_minor" integer DEFAULT 0,
    "fee_minor" integer DEFAULT 0,
    "net_minor" integer GENERATED ALWAYS AS (GREATEST((("amount_minor" - COALESCE("amount_refunded_minor", 0)) - COALESCE("fee_minor", 0)), 0)) STORED,
    "payer_user_id" "uuid",
    "status_reason" "text",
    "succeeded_at" timestamp with time zone,
    "canceled_at" timestamp with time zone,
    "refunded_at" timestamp with time zone,
    "test_mode" boolean DEFAULT false NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    CONSTRAINT "activity_instance_challenge_payments_amount_minor_check" CHECK (("amount_minor" > 0)),
    CONSTRAINT "activity_instance_challenge_payments_amount_refunded_minor_chec" CHECK (("amount_refunded_minor" >= 0)),
    CONSTRAINT "activity_instance_challenge_payments_currency_usd_only" CHECK (("currency" = 'USD'::"bpchar")),
    CONSTRAINT "activity_instance_challenge_payments_fee_minor_check" CHECK (("fee_minor" >= 0)),
    CONSTRAINT "activity_instance_challenge_payments_refund_not_exceed_check" CHECK (("amount_refunded_minor" <= "amount_minor")),
    CONSTRAINT "activity_instance_challenge_payments_tax_minor_check" CHECK (("tax_minor" >= 0))
);


ALTER TABLE "public"."activity_instance_challenge_payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_likes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."activity_instance_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instance_replies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "body" "text" NOT NULL,
    "status" "public"."content_status" DEFAULT 'VISIBLE'::"public"."content_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "edited_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "deleted_by" "public"."deleted_by",
    "edited_by" "uuid"
);


ALTER TABLE "public"."activity_instance_replies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_instances" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_template_id" "uuid" NOT NULL,
    "created_by" "uuid",
    "state" "public"."activity_instance_state" DEFAULT 'ACTIVE'::"public"."activity_instance_state" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp with time zone,
    "terminated_at" timestamp with time zone,
    "first_tap_at" timestamp with time zone,
    "last_tap_at" timestamp with time zone,
    "tap_count" integer DEFAULT 0 NOT NULL,
    "requirements_met" boolean,
    "termination_reason" "text",
    "play_context" "public"."template_play_context" NOT NULL,
    "relationship_mode" "public"."template_relationship_mode" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_by" "uuid",
    "deleted_at" timestamp with time zone,
    "deleted_by" "uuid",
    "mode_kind" "public"."activity_mode_kind" DEFAULT 'CHALLENGE'::"public"."activity_mode_kind" NOT NULL,
    "idempotency_key" "text",
    "sequence_no" integer NOT NULL,
    "cover_card_id" "uuid",
    "end_at" timestamp with time zone,
    CONSTRAINT "activity_instances_active_terminal_null_check" CHECK ((("state" <> 'ACTIVE'::"public"."activity_instance_state") OR (("completed_at" IS NULL) AND ("terminated_at" IS NULL)))),
    CONSTRAINT "activity_instances_completed_fields_check" CHECK ((("state" <> 'COMPLETED'::"public"."activity_instance_state") OR (("completed_at" IS NOT NULL) AND ("terminated_at" IS NULL)))),
    CONSTRAINT "activity_instances_sequence_no_check" CHECK (("sequence_no" > 0)),
    CONSTRAINT "activity_instances_tap_count_nonnegative" CHECK (("tap_count" >= 0)),
    CONSTRAINT "activity_instances_terminated_fields_check" CHECK ((("state" <> 'TERMINATED'::"public"."activity_instance_state") OR (("terminated_at" IS NOT NULL) AND ("completed_at" IS NULL))))
);


ALTER TABLE "public"."activity_instances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_taps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "tapped_by" "uuid",
    "sequence_no" integer NOT NULL,
    "first_happened_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "finalized_at" timestamp with time zone,
    "canceled_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "state" "public"."activity_tap_state",
    CONSTRAINT "activity_taps_canceled_requires_canceled_at_check" CHECK ((("state" <> 'CANCELED'::"public"."activity_tap_state") OR ("canceled_at" IS NOT NULL))),
    CONSTRAINT "activity_taps_opened_canceled_at_null_check" CHECK ((("state" <> 'OPENED'::"public"."activity_tap_state") OR ("canceled_at" IS NULL))),
    CONSTRAINT "activity_taps_sequence_positive" CHECK (("sequence_no" >= 1))
);


ALTER TABLE "public"."activity_taps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_template_challenge_config" (
    "activity_template_id" "uuid" NOT NULL,
    "ref_required" boolean DEFAULT true NOT NULL,
    "fail_card_fee_minor" integer,
    "currency" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."activity_template_challenge_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_template_likes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_template_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."activity_template_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_template_replies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_template_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "body" "text" NOT NULL,
    "status" "public"."content_status" DEFAULT 'VISIBLE'::"public"."content_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "edited_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "deleted_by" "public"."deleted_by",
    "edited_by" "uuid"
);


ALTER TABLE "public"."activity_template_replies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "origin_id" "uuid" NOT NULL,
    "parent_id" "uuid",
    "title" "text" NOT NULL,
    "rules" "text",
    "lifecycle_state" "public"."template_lifecycle_state" DEFAULT 'DRAFT'::"public"."template_lifecycle_state" NOT NULL,
    "cadence_hint" "text",
    "proof_kind" "text" DEFAULT 'ANY'::"text" NOT NULL,
    "status" "text" DEFAULT 'ACTIVE'::"text" NOT NULL,
    "curation_bucket" smallint,
    "play_context" "public"."template_play_context" DEFAULT 'OFFLINE'::"public"."template_play_context" NOT NULL,
    "relationship_mode" "public"."template_relationship_mode" DEFAULT 'SOLO'::"public"."template_relationship_mode" NOT NULL,
    "created_by" "uuid",
    "idempotency_key" "text",
    "creator_display_name" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_by" "uuid",
    "deleted_at" timestamp with time zone,
    "deleted_by" "uuid",
    "min_participants" smallint,
    "max_participants" smallint,
    "mode_kind" "public"."activity_mode_kind" DEFAULT 'CHALLENGE'::"public"."activity_mode_kind" NOT NULL,
    "published_at" timestamp with time zone,
    "visibility" "public"."template_visibility" DEFAULT 'PUBLIC'::"public"."template_visibility" NOT NULL,
    "deleted_photo_path" "text",
    "photo_path" "text",
    CONSTRAINT "activity_templates_idem_key_nonempty" CHECK ((("idempotency_key" IS NULL) OR ("length"(TRIM(BOTH FROM "idempotency_key")) > 0))),
    CONSTRAINT "activity_templates_parent_not_self" CHECK ((("parent_id" IS NULL) OR ("parent_id" <> "id"))),
    CONSTRAINT "activity_templates_proof_kind_check" CHECK (("proof_kind" = ANY (ARRAY['NONE'::"text", 'TEXT'::"text", 'PHOTO'::"text", 'LINK'::"text", 'ANY'::"text"]))),
    CONSTRAINT "activity_templates_status_check" CHECK (("status" = ANY (ARRAY['ACTIVE'::"text", 'DISABLED'::"text"])))
);


ALTER TABLE "public"."activity_templates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_auth_sessions" (
    "app_user_id" "uuid" NOT NULL,
    "auth_session_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_seen_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."app_auth_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text" NOT NULL,
    "auth_id" "uuid" NOT NULL,
    "auth_provider" "public"."auth_provider" DEFAULT 'google'::"public"."auth_provider" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."app_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" bigint NOT NULL,
    "source" "text" NOT NULL,
    "event" "text" NOT NULL,
    "ref_id" "text",
    "payload" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "audit_logs_source_check" CHECK (("source" = ANY (ARRAY['api'::"text", 'webhook'::"text", 'cron'::"text", 'email'::"text", 'job'::"text"])))
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."audit_logs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."audit_logs_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."audit_logs_id_seq" OWNED BY "public"."audit_logs"."id";



CREATE TABLE IF NOT EXISTS "public"."avatar_change_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."avatar_change_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."consent_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "challenge_id" "uuid",
    "consent" "public"."consent_type" NOT NULL,
    "payload" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."consent_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."email_jobs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_type" "public"."email_job_types" NOT NULL,
    "provider" "public"."email_provider" DEFAULT 'RESEND'::"public"."email_provider" NOT NULL,
    "template" "text" NOT NULL,
    "to_email" "text" NOT NULL,
    "to_user_id" "uuid",
    "from_email" "text",
    "challenge_id" "uuid",
    "correlation_id" "uuid",
    "idempotency_key" "text",
    "payload" "jsonb" NOT NULL,
    "status" "public"."email_status" DEFAULT 'QUEUED'::"public"."email_status" NOT NULL,
    "attempts" integer DEFAULT 0 NOT NULL,
    "next_run_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_error" "text",
    "provider_message_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."email_jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."final_call_projection" (
    "activity_instance_id" "uuid" NOT NULL,
    "photo_path" "text",
    "title" "text" NOT NULL,
    "rules" "text",
    "origin_id" "uuid",
    "parent_id" "uuid",
    "creator_display_name" "text",
    "min_participants" smallint,
    "max_participants" smallint,
    "mode_kind" "public"."activity_mode_kind" NOT NULL,
    "proof_kind" "text" NOT NULL,
    "instance_state" "text" NOT NULL,
    "started_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "play_context" "public"."template_play_context" NOT NULL,
    "relationship_mode" "public"."template_relationship_mode" NOT NULL,
    "instance_sequence_no" integer NOT NULL,
    "ref_state" "text",
    "ref_verdict" "text",
    "fail_card_fee_minor" integer,
    "tap_groups" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."final_call_projection" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ip_rate_limits" (
    "ip_hash" "text" NOT NULL,
    "endpoint" "text" NOT NULL,
    "bucket_start" timestamp with time zone NOT NULL,
    "cnt" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."ip_rate_limits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."privacy_policy_acceptances" (
    "user_id" "uuid" NOT NULL,
    "policy_id" "uuid" NOT NULL,
    "accepted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expired_at" timestamp with time zone
);


ALTER TABLE "public"."privacy_policy_acceptances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."privacy_policy_versions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version" "text" NOT NULL,
    "doc_url" "text" NOT NULL,
    "doc_sha256" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."privacy_policy_versions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles_history" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "avatar_url" "text",
    "nickname" "text",
    "bio" "text",
    "valid_from" timestamp with time zone NOT NULL,
    "valid_to" timestamp with time zone NOT NULL,
    "updated_by" "uuid" NOT NULL,
    "avatar_sha256" "text",
    "updated_at" timestamp with time zone NOT NULL,
    "handle" "text",
    "cg_title" "text"
);


ALTER TABLE "public"."profiles_history" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."profiles_history_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."profiles_history_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."profiles_history_id_seq" OWNED BY "public"."profiles_history"."id";



CREATE TABLE IF NOT EXISTS "public"."public_activity_templates" (
    "id" "uuid" NOT NULL,
    "origin_id" "uuid" NOT NULL,
    "parent_id" "uuid",
    "title" "text" NOT NULL,
    "rules" "text",
    "cadence_hint" "text",
    "proof_kind" "text" DEFAULT 'ANY'::"text" NOT NULL,
    "play_context" "public"."template_play_context" DEFAULT 'OFFLINE'::"public"."template_play_context" NOT NULL,
    "relationship_mode" "public"."template_relationship_mode" DEFAULT 'SOLO'::"public"."template_relationship_mode" NOT NULL,
    "creator_display_name" "text",
    "published_at" timestamp with time zone NOT NULL,
    "min_participants" smallint,
    "max_participants" smallint,
    "mode_kind" "public"."activity_mode_kind" DEFAULT 'CHALLENGE'::"public"."activity_mode_kind" NOT NULL,
    "photo_path" "text",
    CONSTRAINT "public_activity_templates_parent_not_self" CHECK ((("parent_id" IS NULL) OR ("parent_id" <> "id"))),
    CONSTRAINT "public_activity_templates_proof_kind_check" CHECK (("proof_kind" = ANY (ARRAY['NONE'::"text", 'TEXT'::"text", 'PHOTO'::"text", 'LINK'::"text", 'ANY'::"text"])))
);


ALTER TABLE "public"."public_activity_templates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."public_profiles" (
    "profile_id" "uuid" NOT NULL,
    "handle" "text",
    "avatar_url" "text",
    "nickname" "text",
    "bio" "text",
    "cg_title" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."public_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tap_card_likes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tap_card_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."tap_card_likes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tap_card_replies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tap_card_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "body" "text" NOT NULL,
    "status" "public"."content_status" DEFAULT 'VISIBLE'::"public"."content_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "edited_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "deleted_by" "public"."deleted_by",
    "edited_by" "uuid"
);


ALTER TABLE "public"."tap_card_replies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tap_cards" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "activity_instance_id" "uuid" NOT NULL,
    "tap_id" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "sequence_no" integer NOT NULL,
    "note" "text",
    "link_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone,
    "tap_sequence_no" integer NOT NULL,
    "deleted_photo_path" "text",
    "photo_path" "text",
    CONSTRAINT "tap_cards_sequence_no_check" CHECK (("sequence_no" > 0))
);


ALTER TABLE "public"."tap_cards" OWNER TO "postgres";


CREATE MATERIALIZED VIEW "public"."tap_card_leaderboard_mv" AS
 WITH "like_counts" AS (
         SELECT "tcl"."tap_card_id" AS "card_id",
            "count"(*) AS "like_count"
           FROM "public"."tap_card_likes" "tcl"
          GROUP BY "tcl"."tap_card_id"
        ), "reply_counts" AS (
         SELECT "tcr"."tap_card_id" AS "card_id",
            "count"(*) AS "reply_count"
           FROM "public"."tap_card_replies" "tcr"
          WHERE (("tcr"."status" = 'VISIBLE'::"public"."content_status") AND ("tcr"."deleted_at" IS NULL))
          GROUP BY "tcr"."tap_card_id"
        ), "eligible_cards" AS (
         SELECT "tc"."id" AS "card_id",
            "tc"."tap_id",
            "tc"."activity_instance_id",
            "ai"."activity_template_id",
            "ai"."created_by" AS "owner_user_id",
            "p"."handle" AS "owner_handle",
            "p"."nickname" AS "owner_nickname",
            "p"."avatar_url" AS "owner_avatar_url",
            "at"."title" AS "instance_title",
            "at"."title" AS "template_title",
            "tc"."note",
            COALESCE("tc"."photo_path", "at"."photo_path") AS "photo_path",
            COALESCE("cfg"."fail_card_fee_minor", 0) AS "fail_card_fee_minor",
                CASE
                    WHEN ("cfg"."challenger_final_verdict" = 'FAIL'::"public"."activity_challenger_final_verdict") THEN 'FAIL'::"public"."verdict"
                    ELSE 'SUCCESS'::"public"."verdict"
                END AS "result",
            COALESCE("lc"."like_count", (0)::bigint) AS "like_count",
            COALESCE("rc"."reply_count", (0)::bigint) AS "reply_count",
            ((((COALESCE("lc"."like_count", (0)::bigint) * 10) + (COALESCE("rc"."reply_count", (0)::bigint) * 18)))::numeric + (LEAST(((COALESCE("cfg"."fail_card_fee_minor", 0))::numeric / (100)::numeric), (100)::numeric) * (2)::numeric)) AS "base_score",
            "tc"."created_at" AS "card_created_at",
            "tc"."updated_at" AS "card_updated_at",
            "ai"."completed_at",
            GREATEST(COALESCE("ai"."completed_at", "tc"."created_at"), "tc"."created_at") AS "rank_sort_at",
            "now"() AS "snapshot_at"
           FROM (((((("public"."tap_cards" "tc"
             JOIN "public"."activity_instances" "ai" ON (("ai"."id" = "tc"."activity_instance_id")))
             JOIN "public"."activity_templates" "at" ON (("at"."id" = "ai"."activity_template_id")))
             JOIN "public"."activity_instance_challenge_config" "cfg" ON (("cfg"."activity_instance_id" = "ai"."id")))
             LEFT JOIN "public"."profiles" "p" ON (("p"."user_id" = "ai"."created_by")))
             LEFT JOIN "like_counts" "lc" ON (("lc"."card_id" = "tc"."id")))
             LEFT JOIN "reply_counts" "rc" ON (("rc"."card_id" = "tc"."id")))
          WHERE (("tc"."deleted_at" IS NULL) AND ("ai"."deleted_at" IS NULL) AND ("ai"."state" = 'COMPLETED'::"public"."activity_instance_state") AND ("ai"."completed_at" IS NOT NULL) AND ("ai"."terminated_at" IS NULL) AND ("ai"."mode_kind" = 'CHALLENGE'::"public"."activity_mode_kind") AND ("at"."deleted_at" IS NULL) AND ("at"."visibility" = 'PUBLIC'::"public"."template_visibility") AND ("at"."lifecycle_state" = 'PUBLISHED'::"public"."template_lifecycle_state") AND ("cfg"."ref_state" = 'DECIDED'::"public"."activity_ref_state") AND ("cfg"."ref_verdict" = ANY (ARRAY['SUCCESS'::"public"."activity_ref_verdict", 'FAIL'::"public"."activity_ref_verdict"])) AND ("cfg"."challenger_final_verdict" = ANY (ARRAY['SUCCESS'::"public"."activity_challenger_final_verdict", 'FAIL'::"public"."activity_challenger_final_verdict"])))
        ), "best_per_user" AS (
         SELECT "eligible_cards"."card_id",
            "eligible_cards"."tap_id",
            "eligible_cards"."activity_instance_id",
            "eligible_cards"."activity_template_id",
            "eligible_cards"."owner_user_id",
            "eligible_cards"."owner_handle",
            "eligible_cards"."owner_nickname",
            "eligible_cards"."owner_avatar_url",
            "eligible_cards"."instance_title",
            "eligible_cards"."template_title",
            "eligible_cards"."note",
            "eligible_cards"."photo_path",
            "eligible_cards"."fail_card_fee_minor",
            "eligible_cards"."result",
            "eligible_cards"."like_count",
            "eligible_cards"."reply_count",
            "eligible_cards"."base_score",
            "eligible_cards"."card_created_at",
            "eligible_cards"."card_updated_at",
            "eligible_cards"."completed_at",
            "eligible_cards"."rank_sort_at",
            "eligible_cards"."snapshot_at",
            "row_number"() OVER (PARTITION BY "eligible_cards"."owner_user_id" ORDER BY "eligible_cards"."base_score" DESC, "eligible_cards"."reply_count" DESC, "eligible_cards"."like_count" DESC, "eligible_cards"."fail_card_fee_minor" DESC, "eligible_cards"."rank_sort_at" DESC, "eligible_cards"."card_id") AS "owner_card_rank"
           FROM "eligible_cards"
        )
 SELECT "card_id",
    "tap_id",
    "activity_instance_id",
    "activity_template_id",
    "owner_user_id",
    "owner_handle",
    "owner_nickname",
    "owner_avatar_url",
    "instance_title",
    "template_title",
    "note",
    "photo_path",
    "fail_card_fee_minor",
    "result",
    "like_count",
    "reply_count",
    "base_score",
    "card_created_at",
    "card_updated_at",
    "completed_at",
    "rank_sort_at",
    "snapshot_at"
   FROM "best_per_user"
  WHERE ("owner_card_rank" = 1)
  WITH NO DATA;


ALTER MATERIALIZED VIEW "public"."tap_card_leaderboard_mv" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tos_acceptances" (
    "user_id" "uuid" NOT NULL,
    "tos_id" "uuid" NOT NULL,
    "accepted_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expired_at" timestamp with time zone
);


ALTER TABLE "public"."tos_acceptances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tos_versions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "version" "text" NOT NULL,
    "doc_url" "text" NOT NULL,
    "doc_sha256" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."tos_versions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_rate_limits" (
    "user_id" "uuid" NOT NULL,
    "endpoint" "text" NOT NULL,
    "bucket_start" timestamp with time zone NOT NULL,
    "cnt" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."user_rate_limits" OWNER TO "postgres";


ALTER TABLE ONLY "public"."audit_logs" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."audit_logs_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."profiles_history" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."profiles_history_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."activity_instance_challenge_config"
    ADD CONSTRAINT "activity_instance_challenge_config_pkey" PRIMARY KEY ("activity_instance_id");



ALTER TABLE ONLY "public"."activity_instance_challenge_disputes"
    ADD CONSTRAINT "activity_instance_challenge_disputes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_attempts"
    ADD CONSTRAINT "activity_instance_challenge_payment_attempts_idempotency_key_ke" UNIQUE ("idempotency_key");



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_attempts"
    ADD CONSTRAINT "activity_instance_challenge_payment_attempts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_webhook_events"
    ADD CONSTRAINT "activity_instance_challenge_payment_webhook_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_webhook_events"
    ADD CONSTRAINT "activity_instance_challenge_payment_webhook_events_provider_eve" UNIQUE ("provider", "event_id");



ALTER TABLE ONLY "public"."activity_instance_challenge_payments"
    ADD CONSTRAINT "activity_instance_challenge_payments_idempotency_key_key" UNIQUE ("idempotency_key");



ALTER TABLE ONLY "public"."activity_instance_challenge_payments"
    ADD CONSTRAINT "activity_instance_challenge_payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_likes"
    ADD CONSTRAINT "activity_instance_likes_activity_instance_id_user_id_key" UNIQUE ("activity_instance_id", "user_id");



ALTER TABLE ONLY "public"."activity_instance_likes"
    ADD CONSTRAINT "activity_instance_likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_replies"
    ADD CONSTRAINT "activity_instance_replies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instances"
    ADD CONSTRAINT "activity_instances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_taps"
    ADD CONSTRAINT "activity_taps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_template_challenge_config"
    ADD CONSTRAINT "activity_template_challenge_config_pkey" PRIMARY KEY ("activity_template_id");



ALTER TABLE ONLY "public"."activity_template_likes"
    ADD CONSTRAINT "activity_template_likes_activity_template_id_user_id_key" UNIQUE ("activity_template_id", "user_id");



ALTER TABLE ONLY "public"."activity_template_likes"
    ADD CONSTRAINT "activity_template_likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_template_replies"
    ADD CONSTRAINT "activity_template_replies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_templates"
    ADD CONSTRAINT "activity_templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."app_auth_sessions"
    ADD CONSTRAINT "app_auth_sessions_pkey" PRIMARY KEY ("app_user_id");



ALTER TABLE ONLY "public"."app_users"
    ADD CONSTRAINT "app_users_auth_id_key" UNIQUE ("auth_id");



ALTER TABLE ONLY "public"."app_users"
    ADD CONSTRAINT "app_users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."app_users"
    ADD CONSTRAINT "app_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."avatar_change_logs"
    ADD CONSTRAINT "avatar_update_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_events"
    ADD CONSTRAINT "challenge_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_mail_tokens"
    ADD CONSTRAINT "challenge_mail_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_instance_challenge_mail_tokens"
    ADD CONSTRAINT "challenge_mail_tokens_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."consent_logs"
    ADD CONSTRAINT "consent_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."email_jobs"
    ADD CONSTRAINT "email_jobs_idempotency_key_key" UNIQUE ("idempotency_key");



ALTER TABLE ONLY "public"."email_jobs"
    ADD CONSTRAINT "email_jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."final_call_projection"
    ADD CONSTRAINT "final_call_projection_pkey" PRIMARY KEY ("activity_instance_id");



ALTER TABLE ONLY "public"."ip_rate_limits"
    ADD CONSTRAINT "ip_rate_limits_pkey" PRIMARY KEY ("ip_hash", "endpoint", "bucket_start");



ALTER TABLE ONLY "public"."privacy_policy_acceptances"
    ADD CONSTRAINT "privacy_policy_acceptances_pkey" PRIMARY KEY ("user_id", "policy_id");



ALTER TABLE ONLY "public"."privacy_policy_versions"
    ADD CONSTRAINT "privacy_policy_versions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."privacy_policy_versions"
    ADD CONSTRAINT "privacy_policy_versions_version_key" UNIQUE ("version");



ALTER TABLE ONLY "public"."profiles_history"
    ADD CONSTRAINT "profiles_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."public_activity_templates"
    ADD CONSTRAINT "public_activity_templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."public_profiles"
    ADD CONSTRAINT "public_profiles_pkey" PRIMARY KEY ("profile_id");



ALTER TABLE ONLY "public"."tap_card_likes"
    ADD CONSTRAINT "tap_card_likes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tap_card_likes"
    ADD CONSTRAINT "tap_card_likes_tap_card_id_user_id_key" UNIQUE ("tap_card_id", "user_id");



ALTER TABLE ONLY "public"."tap_card_replies"
    ADD CONSTRAINT "tap_card_replies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tap_cards"
    ADD CONSTRAINT "tap_cards_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tos_acceptances"
    ADD CONSTRAINT "tos_acceptances_pkey" PRIMARY KEY ("user_id", "tos_id");



ALTER TABLE ONLY "public"."tos_versions"
    ADD CONSTRAINT "tos_versions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tos_versions"
    ADD CONSTRAINT "tos_versions_version_key" UNIQUE ("version");



ALTER TABLE ONLY "public"."activity_taps"
    ADD CONSTRAINT "uq_activity_taps_instance_sequence" UNIQUE ("activity_instance_id", "sequence_no");



ALTER TABLE ONLY "public"."user_rate_limits"
    ADD CONSTRAINT "user_rate_limits_pkey" PRIMARY KEY ("user_id", "endpoint", "bucket_start");



CREATE INDEX "activity_instance_challenge_disputes_instance_idx" ON "public"."activity_instance_challenge_disputes" USING "btree" ("activity_instance_id");



CREATE INDEX "activity_instance_challenge_disputes_reason_code_idx" ON "public"."activity_instance_challenge_disputes" USING "btree" ("reason_code");



CREATE INDEX "activity_instance_challenge_disputes_submitted_by_idx" ON "public"."activity_instance_challenge_disputes" USING "btree" ("submitted_by");



CREATE INDEX "activity_instance_likes_activity_instance_id_idx" ON "public"."activity_instance_likes" USING "btree" ("activity_instance_id");



CREATE INDEX "activity_instance_likes_user_id_idx" ON "public"."activity_instance_likes" USING "btree" ("user_id");



CREATE INDEX "activity_instance_replies_activity_instance_id_created_at_idx" ON "public"."activity_instance_replies" USING "btree" ("activity_instance_id", "created_at" DESC);



CREATE INDEX "activity_instance_replies_status_idx" ON "public"."activity_instance_replies" USING "btree" ("status");



CREATE INDEX "activity_instance_replies_user_id_created_at_idx" ON "public"."activity_instance_replies" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "activity_template_likes_activity_template_id_idx" ON "public"."activity_template_likes" USING "btree" ("activity_template_id");



CREATE INDEX "activity_template_likes_user_id_idx" ON "public"."activity_template_likes" USING "btree" ("user_id");



CREATE INDEX "activity_template_replies_activity_template_id_created_at_idx" ON "public"."activity_template_replies" USING "btree" ("activity_template_id", "created_at" DESC);



CREATE INDEX "activity_template_replies_status_idx" ON "public"."activity_template_replies" USING "btree" ("status");



CREATE INDEX "activity_template_replies_user_id_created_at_idx" ON "public"."activity_template_replies" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "challenge_events_activity_instance_id_idx" ON "public"."activity_instance_challenge_events" USING "btree" ("activity_instance_id");



CREATE INDEX "challenge_mail_tokens_activity_instance_id_idx" ON "public"."activity_instance_challenge_mail_tokens" USING "btree" ("activity_instance_id");



CREATE INDEX "email_jobs_challenge_id_idx" ON "public"."email_jobs" USING "btree" ("challenge_id");



CREATE INDEX "email_jobs_job_type_idx" ON "public"."email_jobs" USING "btree" ("job_type");



CREATE INDEX "email_jobs_status_next_run_at_idx" ON "public"."email_jobs" USING "btree" ("status", "next_run_at");



CREATE INDEX "email_jobs_to_email_idx" ON "public"."email_jobs" USING "btree" ("to_email");



CREATE INDEX "idx_activity_instance_challenge_config_ref_user_id" ON "public"."activity_instance_challenge_config" USING "btree" ("ref_user_id");



CREATE INDEX "idx_activity_instance_challenge_payment_attempts_payment" ON "public"."activity_instance_challenge_payment_attempts" USING "btree" ("challenge_payment_id");



CREATE INDEX "idx_activity_instance_challenge_payment_webhook_events_payment" ON "public"."activity_instance_challenge_payment_webhook_events" USING "btree" ("challenge_payment_id");



CREATE INDEX "idx_activity_instance_challenge_payment_webhook_events_provider" ON "public"."activity_instance_challenge_payment_webhook_events" USING "btree" ("provider", "provider_order_id");



CREATE INDEX "idx_activity_instance_challenge_payments_created_at" ON "public"."activity_instance_challenge_payments" USING "btree" ("created_at");



CREATE INDEX "idx_activity_instance_challenge_payments_instance" ON "public"."activity_instance_challenge_payments" USING "btree" ("activity_instance_id");



CREATE INDEX "idx_activity_instance_challenge_payments_provider_payment_id" ON "public"."activity_instance_challenge_payments" USING "btree" ("provider", "provider_payment_id");



CREATE INDEX "idx_activity_instance_challenge_payments_status" ON "public"."activity_instance_challenge_payments" USING "btree" ("status");



CREATE INDEX "idx_activity_instances_created_by" ON "public"."activity_instances" USING "btree" ("created_by");



CREATE INDEX "idx_activity_instances_creator_status_created" ON "public"."activity_instances" USING "btree" ("created_by", "state", "created_at" DESC);



CREATE INDEX "idx_activity_instances_mode_kind" ON "public"."activity_instances" USING "btree" ("mode_kind");



CREATE INDEX "idx_activity_instances_state" ON "public"."activity_instances" USING "btree" ("state") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_activity_instances_template_id" ON "public"."activity_instances" USING "btree" ("activity_template_id");



CREATE INDEX "idx_activity_taps_instance_id" ON "public"."activity_taps" USING "btree" ("activity_instance_id");



CREATE INDEX "idx_activity_templates_curation_bucket" ON "public"."activity_templates" USING "btree" ("curation_bucket") WHERE (("curation_bucket" IS NOT NULL) AND ("deleted_at" IS NULL));



CREATE INDEX "idx_activity_templates_mode_kind" ON "public"."activity_templates" USING "btree" ("mode_kind");



CREATE INDEX "idx_activity_templates_origin_id" ON "public"."activity_templates" USING "btree" ("origin_id");



CREATE INDEX "idx_activity_templates_parent_id" ON "public"."activity_templates" USING "btree" ("parent_id");



CREATE INDEX "idx_audit_logs_source" ON "public"."audit_logs" USING "btree" ("source");



CREATE INDEX "idx_audit_logs_time" ON "public"."audit_logs" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_avatar_logs_user_time" ON "public"."avatar_change_logs" USING "btree" ("user_id", "changed_at" DESC);



CREATE INDEX "idx_consent_logs_challenge" ON "public"."consent_logs" USING "btree" ("challenge_id");



CREATE INDEX "idx_consent_logs_user_time" ON "public"."consent_logs" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "idx_final_call_projection_updated_at" ON "public"."final_call_projection" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_pp_acc_user_time" ON "public"."privacy_policy_acceptances" USING "btree" ("user_id", "accepted_at" DESC);



CREATE INDEX "idx_profiles_nickname_prefix" ON "public"."profiles" USING "btree" ("lower"("nickname"));



CREATE INDEX "idx_profiles_nickname_trgm" ON "public"."profiles" USING "gin" ("nickname" "public"."gin_trgm_ops");



CREATE INDEX "idx_public_activity_templates_discovery" ON "public"."public_activity_templates" USING "btree" ("mode_kind", "published_at" DESC);



CREATE INDEX "idx_public_activity_templates_mode_kind" ON "public"."public_activity_templates" USING "btree" ("mode_kind");



CREATE INDEX "idx_public_activity_templates_origin_id" ON "public"."public_activity_templates" USING "btree" ("origin_id");



CREATE INDEX "idx_public_activity_templates_parent_id" ON "public"."public_activity_templates" USING "btree" ("parent_id");



CREATE INDEX "idx_public_activity_templates_published_at" ON "public"."public_activity_templates" USING "btree" ("published_at" DESC);



CREATE INDEX "idx_tap_cards_activity_instance_id" ON "public"."tap_cards" USING "btree" ("activity_instance_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_tap_cards_created_by" ON "public"."tap_cards" USING "btree" ("created_by") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_tap_cards_instance_tap_seq" ON "public"."tap_cards" USING "btree" ("activity_instance_id", "tap_sequence_no", "sequence_no") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_tos_acc_user_time" ON "public"."tos_acceptances" USING "btree" ("user_id", "accepted_at" DESC);



CREATE INDEX "ip_rate_limits_bucket_idx" ON "public"."ip_rate_limits" USING "btree" ("bucket_start");



CREATE UNIQUE INDEX "ip_rate_limits_key" ON "public"."ip_rate_limits" USING "btree" ("endpoint", "ip_hash", "bucket_start");



CREATE UNIQUE INDEX "profiles_handle_unique" ON "public"."profiles" USING "btree" ("lower"("handle")) WHERE ("handle" IS NOT NULL);



CREATE UNIQUE INDEX "profiles_handle_unique_lower" ON "public"."profiles" USING "btree" ("lower"("handle")) WHERE ("handle" IS NOT NULL);



CREATE INDEX "profiles_history_handle_ts_idx" ON "public"."profiles_history" USING "btree" ("lower"("handle"), "valid_to" DESC);



CREATE INDEX "profiles_history_user_ts_idx" ON "public"."profiles_history" USING "btree" ("user_id", "valid_to" DESC);



CREATE INDEX "profiles_nickname_trgm_idx" ON "public"."profiles" USING "gin" ("nickname" "public"."gin_trgm_ops");



CREATE UNIQUE INDEX "profiles_nickname_unique_lower" ON "public"."profiles" USING "btree" ("lower"("nickname")) WHERE ("nickname" IS NOT NULL);



CREATE INDEX "public_profiles_handle_prefix_idx" ON "public"."public_profiles" USING "btree" ("lower"("handle"));



CREATE UNIQUE INDEX "public_profiles_handle_unique_ci" ON "public"."public_profiles" USING "btree" ("lower"("handle"));



CREATE INDEX "public_profiles_nickname_trgm_idx" ON "public"."public_profiles" USING "gin" ("nickname" "public"."gin_trgm_ops");



CREATE UNIQUE INDEX "tap_card_leaderboard_mv_card_id_idx" ON "public"."tap_card_leaderboard_mv" USING "btree" ("card_id");



CREATE UNIQUE INDEX "tap_card_leaderboard_mv_owner_user_id_idx" ON "public"."tap_card_leaderboard_mv" USING "btree" ("owner_user_id");



CREATE INDEX "tap_card_leaderboard_mv_result_score_idx" ON "public"."tap_card_leaderboard_mv" USING "btree" ("result", "base_score" DESC, "reply_count" DESC, "like_count" DESC, "fail_card_fee_minor" DESC, "rank_sort_at" DESC, "card_id");



CREATE INDEX "tap_card_likes_tap_card_id_idx" ON "public"."tap_card_likes" USING "btree" ("tap_card_id");



CREATE INDEX "tap_card_likes_user_id_idx" ON "public"."tap_card_likes" USING "btree" ("user_id");



CREATE INDEX "tap_card_replies_status_idx" ON "public"."tap_card_replies" USING "btree" ("status");



CREATE INDEX "tap_card_replies_tap_card_id_created_at_idx" ON "public"."tap_card_replies" USING "btree" ("tap_card_id", "created_at" DESC);



CREATE INDEX "tap_card_replies_user_id_created_at_idx" ON "public"."tap_card_replies" USING "btree" ("user_id", "created_at" DESC);



CREATE UNIQUE INDEX "uniq_profiles_nickname_ci" ON "public"."profiles" USING "btree" ("lower"("nickname"));



CREATE UNIQUE INDEX "uq_activity_instance_challenge_payments_active_per_instance" ON "public"."activity_instance_challenge_payments" USING "btree" ("activity_instance_id") WHERE ("status" = ANY (ARRAY['INIT'::"public"."payment_status", 'CHECKOUT_CREATED'::"public"."payment_status", 'PENDING'::"public"."payment_status"]));



CREATE UNIQUE INDEX "uq_activity_instance_challenge_payments_idem" ON "public"."activity_instance_challenge_payments" USING "btree" ("provider", COALESCE("idempotency_scope", ''::"text"), "idempotency_key") WHERE ("idempotency_key" IS NOT NULL);



CREATE UNIQUE INDEX "uq_activity_instance_challenge_payments_provider_order" ON "public"."activity_instance_challenge_payments" USING "btree" ("provider", "provider_order_id") WHERE ("provider_order_id" IS NOT NULL);



CREATE UNIQUE INDEX "uq_activity_instance_challenge_payments_success_per_instance" ON "public"."activity_instance_challenge_payments" USING "btree" ("activity_instance_id") WHERE ("status" = 'SUCCEEDED'::"public"."payment_status");



CREATE UNIQUE INDEX "uq_activity_instances_template_user_sequence" ON "public"."activity_instances" USING "btree" ("activity_template_id", "created_by", "sequence_no") WHERE ("deleted_at" IS NULL);



CREATE UNIQUE INDEX "uq_activity_instances_user_idempotency" ON "public"."activity_instances" USING "btree" ("created_by", "idempotency_key") WHERE (("deleted_at" IS NULL) AND ("idempotency_key" IS NOT NULL));



CREATE UNIQUE INDEX "uq_activity_templates_creator_idem" ON "public"."activity_templates" USING "btree" ("created_by", "idempotency_key") WHERE ("idempotency_key" IS NOT NULL);



CREATE UNIQUE INDEX "uq_tap_cards_tap_sequence" ON "public"."tap_cards" USING "btree" ("tap_id", "sequence_no") WHERE ("deleted_at" IS NULL);



CREATE INDEX "user_rate_limits_bucket_idx" ON "public"."user_rate_limits" USING "btree" ("bucket_start");



CREATE UNIQUE INDEX "user_rate_limits_key" ON "public"."user_rate_limits" USING "btree" ("endpoint", "user_id", "bucket_start");



CREATE OR REPLACE TRIGGER "set_app_auth_sessions_updated_at" BEFORE UPDATE ON "public"."app_auth_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_activity_templates_set_updated_at" BEFORE UPDATE ON "public"."activity_templates" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();

ALTER TABLE "public"."activity_templates" DISABLE TRIGGER "trg_activity_templates_set_updated_at";



ALTER TABLE ONLY "public"."activity_instance_challenge_config"
    ADD CONSTRAINT "activity_instance_challenge_config_instance_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_config"
    ADD CONSTRAINT "activity_instance_challenge_config_ref_user_fkey" FOREIGN KEY ("ref_user_id") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_instance_challenge_disputes"
    ADD CONSTRAINT "activity_instance_challenge_disputes_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_disputes"
    ADD CONSTRAINT "activity_instance_challenge_disputes_submitted_by_fkey" FOREIGN KEY ("submitted_by") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_attempts"
    ADD CONSTRAINT "activity_instance_challenge_payment_attempts_challenge_payment_" FOREIGN KEY ("challenge_payment_id") REFERENCES "public"."activity_instance_challenge_payments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_payment_webhook_events"
    ADD CONSTRAINT "activity_instance_challenge_payment_webhook_events_challenge_pa" FOREIGN KEY ("challenge_payment_id") REFERENCES "public"."activity_instance_challenge_payments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_instance_challenge_payments"
    ADD CONSTRAINT "activity_instance_challenge_payments_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_payments"
    ADD CONSTRAINT "activity_instance_challenge_payments_payer_user_id_fkey" FOREIGN KEY ("payer_user_id") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_instance_likes"
    ADD CONSTRAINT "activity_instance_likes_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_likes"
    ADD CONSTRAINT "activity_instance_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_replies"
    ADD CONSTRAINT "activity_instance_replies_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_replies"
    ADD CONSTRAINT "activity_instance_replies_edited_by_fkey" FOREIGN KEY ("edited_by") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_instance_replies"
    ADD CONSTRAINT "activity_instance_replies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instances"
    ADD CONSTRAINT "activity_instances_activity_template_id_fkey" FOREIGN KEY ("activity_template_id") REFERENCES "public"."activity_templates"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."activity_taps"
    ADD CONSTRAINT "activity_taps_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_template_challenge_config"
    ADD CONSTRAINT "activity_template_challenge_config_activity_template_id_fkey" FOREIGN KEY ("activity_template_id") REFERENCES "public"."activity_templates"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_template_likes"
    ADD CONSTRAINT "activity_template_likes_activity_template_id_fkey" FOREIGN KEY ("activity_template_id") REFERENCES "public"."activity_templates"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_template_likes"
    ADD CONSTRAINT "activity_template_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_template_replies"
    ADD CONSTRAINT "activity_template_replies_activity_template_id_fkey" FOREIGN KEY ("activity_template_id") REFERENCES "public"."activity_templates"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_template_replies"
    ADD CONSTRAINT "activity_template_replies_edited_by_fkey" FOREIGN KEY ("edited_by") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_template_replies"
    ADD CONSTRAINT "activity_template_replies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_templates"
    ADD CONSTRAINT "activity_templates_origin_fk" FOREIGN KEY ("origin_id") REFERENCES "public"."activity_templates"("id") ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;



ALTER TABLE ONLY "public"."activity_templates"
    ADD CONSTRAINT "activity_templates_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."activity_templates"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."app_auth_sessions"
    ADD CONSTRAINT "app_auth_sessions_app_user_id_fkey" FOREIGN KEY ("app_user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."avatar_change_logs"
    ADD CONSTRAINT "avatar_update_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_events"
    ADD CONSTRAINT "challenge_events_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_instance_challenge_mail_tokens"
    ADD CONSTRAINT "challenge_mail_tokens_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."consent_logs"
    ADD CONSTRAINT "consent_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."email_jobs"
    ADD CONSTRAINT "email_jobs_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."app_users"
    ADD CONSTRAINT "fk_app_users_auth" FOREIGN KEY ("auth_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."privacy_policy_acceptances"
    ADD CONSTRAINT "privacy_policy_acceptances_policy_id_fkey" FOREIGN KEY ("policy_id") REFERENCES "public"."privacy_policy_versions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."privacy_policy_acceptances"
    ADD CONSTRAINT "privacy_policy_acceptances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."public_activity_templates"
    ADD CONSTRAINT "public_activity_templates_source_fk" FOREIGN KEY ("id") REFERENCES "public"."activity_templates"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_card_likes"
    ADD CONSTRAINT "tap_card_likes_tap_card_id_fkey" FOREIGN KEY ("tap_card_id") REFERENCES "public"."tap_cards"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_card_likes"
    ADD CONSTRAINT "tap_card_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_card_replies"
    ADD CONSTRAINT "tap_card_replies_edited_by_fkey" FOREIGN KEY ("edited_by") REFERENCES "public"."app_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tap_card_replies"
    ADD CONSTRAINT "tap_card_replies_tap_card_id_fkey" FOREIGN KEY ("tap_card_id") REFERENCES "public"."tap_cards"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_card_replies"
    ADD CONSTRAINT "tap_card_replies_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_cards"
    ADD CONSTRAINT "tap_cards_activity_instance_id_fkey" FOREIGN KEY ("activity_instance_id") REFERENCES "public"."activity_instances"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tap_cards"
    ADD CONSTRAINT "tap_cards_tap_id_fkey" FOREIGN KEY ("tap_id") REFERENCES "public"."activity_taps"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tos_acceptances"
    ADD CONSTRAINT "tos_acceptances_tos_id_fkey" FOREIGN KEY ("tos_id") REFERENCES "public"."tos_versions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tos_acceptances"
    ADD CONSTRAINT "tos_acceptances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."app_users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow public read access on privacy_policy_versions" ON "public"."privacy_policy_versions" FOR SELECT USING (true);



CREATE POLICY "Allow public read access on tos_versions" ON "public"."tos_versions" FOR SELECT USING (true);



ALTER TABLE "public"."activity_instance_challenge_config" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_instance_challenge_config_insert_active_owner" ON "public"."activity_instance_challenge_config" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_instances" "i"
  WHERE (("i"."id" = "activity_instance_challenge_config"."activity_instance_id") AND ("i"."created_by" = "public"."app_user_id"()))))));



CREATE POLICY "activity_instance_challenge_config_select_participant" ON "public"."activity_instance_challenge_config" FOR SELECT TO "authenticated" USING ((("ref_user_id" = "public"."app_user_id"()) OR "public"."is_operator"() OR (EXISTS ( SELECT 1
   FROM "public"."activity_instances" "i"
  WHERE (("i"."id" = "activity_instance_challenge_config"."activity_instance_id") AND ("i"."created_by" = "public"."app_user_id"()))))));



CREATE POLICY "activity_instance_challenge_config_update_active_owner" ON "public"."activity_instance_challenge_config" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_instances" "i"
  WHERE (("i"."id" = "activity_instance_challenge_config"."activity_instance_id") AND ("i"."created_by" = "public"."app_user_id"())))))) WITH CHECK (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_instances" "i"
  WHERE (("i"."id" = "activity_instance_challenge_config"."activity_instance_id") AND ("i"."created_by" = "public"."app_user_id"()))))));



ALTER TABLE "public"."activity_instance_challenge_disputes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_instance_challenge_disputes_select_participant" ON "public"."activity_instance_challenge_disputes" FOR SELECT TO "authenticated" USING ((("submitted_by" = "public"."app_user_id"()) OR "public"."is_operator"() OR (EXISTS ( SELECT 1
   FROM "public"."activity_instances" "i"
  WHERE (("i"."id" = "activity_instance_challenge_disputes"."activity_instance_id") AND ("i"."created_by" = "public"."app_user_id"())))) OR (EXISTS ( SELECT 1
   FROM "public"."activity_instance_challenge_config" "c"
  WHERE (("c"."activity_instance_id" = "activity_instance_challenge_disputes"."activity_instance_id") AND ("c"."ref_user_id" = "public"."app_user_id"()))))));



ALTER TABLE "public"."activity_instance_challenge_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."activity_instance_challenge_mail_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."activity_instance_challenge_payment_attempts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."activity_instance_challenge_payment_webhook_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."activity_instance_challenge_payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."activity_instance_likes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_instance_likes_insert_active_owner" ON "public"."activity_instance_likes" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_activity_instance"("activity_instance_id")));



CREATE POLICY "activity_instance_likes_select_visible" ON "public"."activity_instance_likes" FOR SELECT TO "authenticated", "anon" USING (("public"."can_select_activity_instance"("activity_instance_id") OR ("user_id" = "public"."app_user_id"())));



ALTER TABLE "public"."activity_instance_replies" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_instance_replies_insert_active_owner" ON "public"."activity_instance_replies" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_activity_instance"("activity_instance_id") AND (("status")::"text" = 'VISIBLE'::"text") AND ("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND ("edited_at" IS NULL) AND ("edited_by" IS NULL)));



CREATE POLICY "activity_instance_replies_select_operator" ON "public"."activity_instance_replies" FOR SELECT TO "authenticated" USING ("public"."is_operator"());



CREATE POLICY "activity_instance_replies_select_visible" ON "public"."activity_instance_replies" FOR SELECT TO "authenticated", "anon" USING ((("deleted_at" IS NULL) AND (((("status")::"text" = 'VISIBLE'::"text") AND "public"."can_select_activity_instance"("activity_instance_id")) OR ("user_id" = "public"."app_user_id"()))));



CREATE POLICY "activity_instance_replies_update_active_owner" ON "public"."activity_instance_replies" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND ("deleted_at" IS NULL) AND (("user_id" = "public"."app_user_id"()) OR "public"."is_operator"()))) WITH CHECK (("public"."is_active_app_session"() AND ((("user_id" = "public"."app_user_id"()) AND ((("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND (("status")::"text" = 'VISIBLE'::"text")) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = 'OWNER'::"public"."deleted_by") AND (("status")::"text" = 'HIDDEN'::"text")))) OR ("public"."is_operator"() AND (("deleted_at" IS NULL) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = ANY (ARRAY['OWNER'::"public"."deleted_by", 'ADMIN'::"public"."deleted_by"])) AND (("status")::"text" = 'HIDDEN'::"text")))))));



ALTER TABLE "public"."activity_instances" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_instances_insert_active_owner" ON "public"."activity_instances" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND (COALESCE("created_by", "public"."app_user_id"()) = "public"."app_user_id"())));



CREATE POLICY "activity_instances_select_visible" ON "public"."activity_instances" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_activity_instance"("id"));



CREATE POLICY "activity_instances_update_active_owner" ON "public"."activity_instances" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND ("created_by" = "public"."app_user_id"()))) WITH CHECK (("public"."is_active_app_session"() AND ("created_by" = "public"."app_user_id"())));



ALTER TABLE "public"."activity_taps" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_taps_select_own" ON "public"."activity_taps" FOR SELECT TO "authenticated" USING (("tapped_by" = "public"."app_user_id"()));



CREATE POLICY "activity_taps_select_visible" ON "public"."activity_taps" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_activity_tap"("id"));



ALTER TABLE "public"."activity_template_challenge_config" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_template_challenge_config_insert_active_owner" ON "public"."activity_template_challenge_config" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_templates" "t"
  WHERE (("t"."id" = "activity_template_challenge_config"."activity_template_id") AND ("t"."created_by" = "public"."app_user_id"()))))));



CREATE POLICY "activity_template_challenge_config_select_visible" ON "public"."activity_template_challenge_config" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_activity_template"("activity_template_id"));



CREATE POLICY "activity_template_challenge_config_update_active_owner" ON "public"."activity_template_challenge_config" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_templates" "t"
  WHERE (("t"."id" = "activity_template_challenge_config"."activity_template_id") AND ("t"."created_by" = "public"."app_user_id"())))))) WITH CHECK (("public"."is_active_app_session"() AND (EXISTS ( SELECT 1
   FROM "public"."activity_templates" "t"
  WHERE (("t"."id" = "activity_template_challenge_config"."activity_template_id") AND ("t"."created_by" = "public"."app_user_id"()))))));



ALTER TABLE "public"."activity_template_likes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_template_likes_insert_active_owner" ON "public"."activity_template_likes" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_activity_template"("activity_template_id")));



CREATE POLICY "activity_template_likes_select_visible" ON "public"."activity_template_likes" FOR SELECT TO "authenticated", "anon" USING (("public"."can_select_activity_template"("activity_template_id") OR ("user_id" = "public"."app_user_id"())));



ALTER TABLE "public"."activity_template_replies" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_template_replies_insert_active_owner" ON "public"."activity_template_replies" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_activity_template"("activity_template_id") AND (("status")::"text" = 'VISIBLE'::"text") AND ("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND ("edited_at" IS NULL) AND ("edited_by" IS NULL)));



CREATE POLICY "activity_template_replies_select_operator" ON "public"."activity_template_replies" FOR SELECT TO "authenticated" USING ("public"."is_operator"());



CREATE POLICY "activity_template_replies_select_visible" ON "public"."activity_template_replies" FOR SELECT TO "authenticated", "anon" USING ((("deleted_at" IS NULL) AND (((("status")::"text" = 'VISIBLE'::"text") AND "public"."can_select_activity_template"("activity_template_id")) OR ("user_id" = "public"."app_user_id"()))));



CREATE POLICY "activity_template_replies_update_active_owner" ON "public"."activity_template_replies" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND ("deleted_at" IS NULL) AND (("user_id" = "public"."app_user_id"()) OR "public"."is_operator"()))) WITH CHECK (("public"."is_active_app_session"() AND ((("user_id" = "public"."app_user_id"()) AND ((("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND (("status")::"text" = 'VISIBLE'::"text")) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = 'OWNER'::"public"."deleted_by") AND (("status")::"text" = 'HIDDEN'::"text")))) OR ("public"."is_operator"() AND (("deleted_at" IS NULL) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = ANY (ARRAY['OWNER'::"public"."deleted_by", 'ADMIN'::"public"."deleted_by"])) AND (("status")::"text" = 'HIDDEN'::"text")))))));



ALTER TABLE "public"."activity_templates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_templates_insert_active_owner" ON "public"."activity_templates" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND (COALESCE("created_by", "public"."app_user_id"()) = "public"."app_user_id"())));



CREATE POLICY "activity_templates_select_visible" ON "public"."activity_templates" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_activity_template"("id"));



CREATE POLICY "activity_templates_update_active_owner" ON "public"."activity_templates" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND ("created_by" = "public"."app_user_id"()))) WITH CHECK (("public"."is_active_app_session"() AND ("created_by" = "public"."app_user_id"())));



ALTER TABLE "public"."app_auth_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."app_users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "app_users_select_own" ON "public"."app_users" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "auth_id") OR "public"."is_operator"()));



CREATE POLICY "app_users_update_own" ON "public"."app_users" FOR UPDATE TO "authenticated" USING ((("auth"."uid"() = "auth_id") OR "public"."is_operator"()));



ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."avatar_change_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."consent_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."email_jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."final_call_projection" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "final_call_projection_read_all" ON "public"."final_call_projection" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "final_call_projection_select_visible" ON "public"."final_call_projection" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_activity_instance"("activity_instance_id"));



ALTER TABLE "public"."ip_rate_limits" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "legal_versions_read_public" ON "public"."tos_versions" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "pol_payments_write_none" ON "public"."activity_instance_challenge_payments" USING (false) WITH CHECK (false);



CREATE POLICY "pol_profiles_select" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("user_id" = "public"."app_user_id"()));



CREATE POLICY "pol_profiles_update" ON "public"."profiles" FOR UPDATE USING ((("user_id" = "public"."app_user_id"()) OR "public"."is_operator"())) WITH CHECK ((("user_id" = "public"."app_user_id"()) OR "public"."is_operator"()));



ALTER TABLE "public"."privacy_policy_acceptances" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "privacy_policy_acceptances_insert_own" ON "public"."privacy_policy_acceptances" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "public"."app_user_id"()));



CREATE POLICY "privacy_policy_acceptances_select_self" ON "public"."privacy_policy_acceptances" FOR SELECT TO "authenticated" USING (("user_id" = "public"."app_user_id"()));



ALTER TABLE "public"."privacy_policy_versions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "privacy_versions_read_public" ON "public"."privacy_policy_versions" FOR SELECT TO "authenticated", "anon" USING (true);



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_deny_anon_select" ON "public"."profiles" FOR SELECT TO "anon" USING (false);



ALTER TABLE "public"."profiles_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_history_insert_ops" ON "public"."profiles_history" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_operator"());



CREATE POLICY "profiles_history_select_ops" ON "public"."profiles_history" FOR SELECT TO "authenticated" USING ("public"."is_operator"());



CREATE POLICY "profiles_read_own" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "profiles_update_own" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("user_id" = "public"."app_user_id"())) WITH CHECK (("user_id" = "public"."app_user_id"()));



CREATE POLICY "public read public_activity_templates" ON "public"."public_activity_templates" FOR SELECT TO "authenticated", "anon" USING (true);



ALTER TABLE "public"."public_activity_templates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "public_activity_templates_insert_own" ON "public"."public_activity_templates" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."activity_templates" "at"
  WHERE (("at"."id" = "public_activity_templates"."id") AND ("at"."created_by" = "public"."app_user_id"())))));



CREATE POLICY "public_activity_templates_read_public" ON "public"."public_activity_templates" FOR SELECT TO "authenticated", "anon" USING (true);



ALTER TABLE "public"."public_profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "public_profiles_read_all" ON "public"."public_profiles" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "public_profiles_read_public" ON "public"."public_profiles" FOR SELECT TO "authenticated", "anon" USING (true);



ALTER TABLE "public"."tap_card_likes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tap_card_likes_insert_active_owner" ON "public"."tap_card_likes" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_tap_card"("tap_card_id")));



CREATE POLICY "tap_card_likes_select_visible" ON "public"."tap_card_likes" FOR SELECT TO "authenticated", "anon" USING (("public"."can_select_tap_card"("tap_card_id") OR ("user_id" = "public"."app_user_id"())));



ALTER TABLE "public"."tap_card_replies" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tap_card_replies_insert_active_owner" ON "public"."tap_card_replies" FOR INSERT TO "authenticated" WITH CHECK (("public"."is_active_app_session"() AND ("user_id" = "public"."app_user_id"()) AND "public"."can_select_tap_card"("tap_card_id") AND (("status")::"text" = 'VISIBLE'::"text") AND ("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND ("edited_at" IS NULL) AND ("edited_by" IS NULL)));



CREATE POLICY "tap_card_replies_select_operator" ON "public"."tap_card_replies" FOR SELECT TO "authenticated" USING ("public"."is_operator"());



CREATE POLICY "tap_card_replies_select_visible" ON "public"."tap_card_replies" FOR SELECT TO "authenticated", "anon" USING ((("deleted_at" IS NULL) AND (((("status")::"text" = 'VISIBLE'::"text") AND "public"."can_select_tap_card"("tap_card_id")) OR ("user_id" = "public"."app_user_id"()))));



CREATE POLICY "tap_card_replies_update_active_owner" ON "public"."tap_card_replies" FOR UPDATE TO "authenticated" USING (("public"."is_active_app_session"() AND ("deleted_at" IS NULL) AND (("user_id" = "public"."app_user_id"()) OR "public"."is_operator"()))) WITH CHECK (("public"."is_active_app_session"() AND ((("user_id" = "public"."app_user_id"()) AND ((("deleted_at" IS NULL) AND ("deleted_by" IS NULL) AND (("status")::"text" = 'VISIBLE'::"text")) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = 'OWNER'::"public"."deleted_by") AND (("status")::"text" = 'HIDDEN'::"text")))) OR ("public"."is_operator"() AND (("deleted_at" IS NULL) OR (("deleted_at" IS NOT NULL) AND ("deleted_by" = ANY (ARRAY['OWNER'::"public"."deleted_by", 'ADMIN'::"public"."deleted_by"])) AND (("status")::"text" = 'HIDDEN'::"text")))))));



ALTER TABLE "public"."tap_cards" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tap_cards_select_own" ON "public"."tap_cards" FOR SELECT TO "authenticated" USING (("created_by" = "public"."app_user_id"()));



CREATE POLICY "tap_cards_select_visible" ON "public"."tap_cards" FOR SELECT TO "authenticated", "anon" USING ("public"."can_select_tap_card"("id"));



ALTER TABLE "public"."tos_acceptances" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tos_acceptances_insert_own" ON "public"."tos_acceptances" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "public"."app_user_id"()));



CREATE POLICY "tos_acceptances_select_self" ON "public"."tos_acceptances" FOR SELECT TO "authenticated" USING (("user_id" = "public"."app_user_id"()));



ALTER TABLE "public"."tos_versions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_rate_limits" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."_insert_challenge_template_core"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."_insert_challenge_template_core"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."_insert_challenge_template_core"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."abandon_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."abandon_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."abandon_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."abandon_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."abandon_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."abandon_tap_card_shell"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."accept_legal_both"("p_tos_id" "uuid", "p_privacy_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."accept_legal_both"("p_tos_id" "uuid", "p_privacy_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."accept_legal_both_for_app_user"("p_app_user_id" "uuid", "p_tos_id" "uuid", "p_privacy_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."accept_legal_both_for_app_user"("p_app_user_id" "uuid", "p_tos_id" "uuid", "p_privacy_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."acknowledge_challenge_success"("p_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."acknowledge_challenge_success"("p_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."acknowledge_challenge_success"("p_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."app_user_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."app_user_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."app_user_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."attach_challenge_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."attach_challenge_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."attach_challenge_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."attach_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."attach_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."attach_tap_card_photo"("p_activity_instance_id" "uuid", "p_tap_id" "uuid", "p_card_id" "uuid", "p_photo_path" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_select_activity_instance"("p_activity_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_select_activity_instance"("p_activity_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_select_activity_instance"("p_activity_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_select_activity_tap"("p_tap_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_select_activity_tap"("p_tap_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_select_activity_tap"("p_tap_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_select_activity_template"("p_template_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_select_activity_template"("p_template_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_select_activity_template"("p_template_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_select_tap_card"("p_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_select_tap_card"("p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_select_tap_card"("p_card_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_rate_limit_app_user"("p_endpoint" "text", "p_limit" integer, "p_window_seconds" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."check_rate_limit_app_user"("p_endpoint" "text", "p_limit" integer, "p_window_seconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_rate_limit_app_user"("p_endpoint" "text", "p_limit" integer, "p_window_seconds" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."check_rate_limit_ip"("p_endpoint" "text", "p_ip" "text", "p_limit" integer, "p_window_seconds" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."check_rate_limit_ip"("p_endpoint" "text", "p_ip" "text", "p_limit" integer, "p_window_seconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_rate_limit_ip"("p_endpoint" "text", "p_ip" "text", "p_limit" integer, "p_window_seconds" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."complete_onboarding"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."complete_onboarding"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."profiles" TO "authenticated";



GRANT ALL ON FUNCTION "public"."complete_onboarding_core"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_onboarding_core"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_onboarding_core"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "service_role";



REVOKE ALL ON FUNCTION "public"."complete_onboarding_for_app_user"("p_app_user_id" "uuid", "p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."complete_onboarding_for_app_user"("p_app_user_id" "uuid", "p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_onboarding_v2"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_onboarding_v2"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_onboarding_v2"("p_handle" "text", "p_nickname" "text", "p_avatar_url" "text", "p_bio" "text", "p_cg_title" "text", "p_init_user_stats" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_challenge_instance"("p_activity_template_id" "uuid", "p_ref_email" "text", "p_fail_card_fee_minor" integer, "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_idempotency_key" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_challenge_instance"("p_activity_template_id" "uuid", "p_ref_email" "text", "p_fail_card_fee_minor" integer, "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_idempotency_key" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_challenge_instance"("p_activity_template_id" "uuid", "p_ref_email" "text", "p_fail_card_fee_minor" integer, "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_idempotency_key" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_challenge_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_challenge_template"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_challenge_template"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_challenge_template"("p_template_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_url" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_challenge_template_and_instance"("p_template_id" "uuid", "p_instance_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_path" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_end_at" timestamp with time zone, "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_challenge_template_and_instance"("p_template_id" "uuid", "p_instance_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_path" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_end_at" timestamp with time zone, "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_challenge_template_and_instance"("p_template_id" "uuid", "p_instance_id" "uuid", "p_title" "text", "p_rules" "text", "p_photo_path" "text", "p_visibility" "public"."template_visibility", "p_lifecycle_state" "public"."template_lifecycle_state", "p_idempotency_key" "text", "p_creator_display_name" "text", "p_end_at" timestamp with time zone, "p_cadence_hint" "text", "p_proof_kind" "text", "p_play_context" "public"."template_play_context", "p_relationship_mode" "public"."template_relationship_mode", "p_min_participants" smallint, "p_max_participants" smallint, "p_challenge_currency" "text", "p_challenge_ref_email" "text", "p_challenge_fail_card_fee_minor" integer, "p_challenge_ref_required" boolean) TO "service_role";



REVOKE ALL ON FUNCTION "public"."create_tap_card_reply"("p_card_id" "uuid", "p_body" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_tap_card_reply"("p_card_id" "uuid", "p_body" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_tap_card_reply"("p_card_id" "uuid", "p_body" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_tap_card_shell"("p_activity_instance_id" "uuid", "p_card_id" "uuid", "p_tap_id" "uuid", "p_note" "text", "p_link_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."current_auth_session_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_auth_session_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_auth_session_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_auth_state"() TO "anon";
GRANT ALL ON FUNCTION "public"."debug_auth_state"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_auth_state"() TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_insert_template"() TO "anon";
GRANT ALL ON FUNCTION "public"."debug_insert_template"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_insert_template"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."delete_tap_card_reply"("p_reply_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_tap_card_reply"("p_reply_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_tap_card_reply"("p_reply_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."disagree_watcher_decision"("p_challenge_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."disagree_watcher_decision"("p_challenge_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."disagree_watcher_decision"("p_challenge_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_activity_tap"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_activity_tap"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_activity_tap"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_chicken"("p_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_chicken"("p_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_chicken"("p_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid", "p_reason_code" "text", "p_details" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid", "p_reason_code" "text", "p_details" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_dispute"("p_instance_id" "uuid", "p_reason_code" "text", "p_details" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_no_payment"("p_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_no_payment"("p_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_no_payment"("p_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_payment"("p_instance_id" "uuid", "p_challenge_payment_id" "uuid", "p_provider_order_id" "text", "p_provider_payment_id" "text", "p_payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_payment"("p_instance_id" "uuid", "p_challenge_payment_id" "uuid", "p_provider_order_id" "text", "p_provider_payment_id" "text", "p_payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_fail_payment"("p_instance_id" "uuid", "p_challenge_payment_id" "uuid", "p_provider_order_id" "text", "p_provider_payment_id" "text", "p_payload" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_challenge_tap_without_card"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_challenge_tap_without_card"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_challenge_tap_without_card"("p_activity_instance_id" "uuid", "p_tap_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_ref_decision"("p_token" "text", "p_action" "text", "p_ip" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_ref_decision"("p_token" "text", "p_action" "text", "p_ip" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_ref_decision"("p_token" "text", "p_action" "text", "p_ip" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."finalize_stale_activity_taps"("p_reference_time" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."finalize_stale_activity_taps"("p_reference_time" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."finalize_stale_activity_taps"("p_reference_time" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_default_handle"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_default_handle"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_default_handle"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_card_like_stats"("p_card_ids" "uuid"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_card_like_stats"("p_card_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_card_like_stats"("p_card_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_final_call_by_instance_id"("p_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_final_call_by_token"("p_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_final_call_by_token"("p_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_final_call_by_token"("p_token" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_onboarding_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_onboarding_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_onboarding_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_profile_gate_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_profile_gate_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_profile_gate_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_public_card_detail"("p_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_public_card_detail"("p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_card_detail"("p_card_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_profile_by_handle"("p_handle" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_profiles_by_user_ids"("p_user_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_public_tap_card_leaderboard"("p_result" "public"."verdict", "p_limit" integer, "p_offset" integer, "p_q" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_public_tap_card_leaderboard"("p_result" "public"."verdict", "p_limit" integer, "p_offset" integer, "p_q" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_public_tap_card_leaderboard"("p_result" "public"."verdict", "p_limit" integer, "p_offset" integer, "p_q" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_showcase_templates"("p_limit" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_showcase_templates"("p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_showcase_templates"("p_limit" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) TO "service_role";
GRANT ALL ON FUNCTION "public"."get_tap_card_like_stats"("p_card_ids" "uuid"[]) TO "anon";



GRANT ALL ON FUNCTION "public"."get_tap_dashboard"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_tap_dashboard"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_tap_dashboard"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_today_tap_tray_cards"("p_limit" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_today_tap_tray_cards"("p_limit" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_today_tap_tray_cards"("p_limit" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_weekly_tap_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_weekly_tap_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_weekly_tap_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_challenge_consent"("p_challenge_id" "uuid", "p_user_id" "uuid", "p_payload" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_challenge_consent"("p_challenge_id" "uuid", "p_user_id" "uuid", "p_payload" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_challenge_consent"("p_challenge_id" "uuid", "p_user_id" "uuid", "p_payload" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_active_app_session"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_active_app_session"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_active_app_session"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_challenge_terminal"("s" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_challenge_terminal"("s" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_challenge_terminal"("s" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_handle_available"("p_handle" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_handle_available"("p_handle" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_handle_available"("p_handle" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_nickname_taken"("p_nickname" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_nickname_taken"("p_nickname" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_nickname_taken"("p_nickname" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."is_operator"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_operator"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_operator"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_valid_handle"("p_handle" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_valid_handle"("p_handle" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_valid_handle"("p_handle" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."list_tap_card_replies"("p_card_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."normalize_handle"("p_handle" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."normalize_handle"("p_handle" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."normalize_handle"("p_handle" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_template_reparent"() TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_template_reparent"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_template_reparent"() TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_final_call_projection"("p_activity_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_final_call_projection"("p_activity_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_final_call_projection"("p_activity_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_leaderboard_views"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_leaderboard_views"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_leaderboard_views"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."refresh_public_activity_templates"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."refresh_public_activity_templates"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_public_activity_templates"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_public_activity_templates"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."search_leaderboard"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."search_leaderboard"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_leaderboard"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_leaderboard_impl"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."search_leaderboard_impl"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_leaderboard_impl"("p_q" "text", "p_tab" "text", "p_limit" integer, "p_offset" integer, "p_include_demo" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_leaderboard_users"("q" "text", "mode" "text", "lim" integer, "off" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."search_leaderboard_users"("q" "text", "mode" "text", "lim" integer, "off" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_leaderboard_users"("q" "text", "mode" "text", "lim" integer, "off" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_profiles_nickname"("q" "text", "lim" integer) TO "service_role";



REVOKE ALL ON FUNCTION "public"."set_card_like"("p_card_id" "uuid", "p_like" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."set_card_like"("p_card_id" "uuid", "p_like" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_card_like"("p_card_id" "uuid", "p_like" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_challenge_cover_card"("p_activity_instance_id" "uuid", "p_cover_card_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."set_challenge_cover_card"("p_activity_instance_id" "uuid", "p_cover_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_challenge_cover_card"("p_activity_instance_id" "uuid", "p_cover_card_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."set_tap_card_like"("p_card_id" "uuid", "p_like" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."set_tap_card_like"("p_card_id" "uuid", "p_like" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_tap_card_like"("p_card_id" "uuid", "p_like" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_tutorial_step"("p_tutorial_step" "public"."tutorial_step_state") TO "anon";
GRANT ALL ON FUNCTION "public"."set_tutorial_step"("p_tutorial_step" "public"."tutorial_step_state") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_tutorial_step"("p_tutorial_step" "public"."tutorial_step_state") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."toggle_activity_tap"("p_activity_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_activity_tap"("p_activity_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_activity_tap"("p_activity_instance_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."toggle_card_like"("p_card_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."toggle_card_like"("p_card_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_card_like"("p_card_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."toggle_challenge_tap"("p_activity_instance_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_challenge_tap"("p_activity_instance_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_challenge_tap"("p_activity_instance_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."touch_challenge_cards_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."touch_challenge_cards_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."touch_challenge_cards_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."touch_challenges_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."touch_challenges_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."touch_challenges_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_profile_to_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_profile_to_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_profile_to_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_profiles_avatar_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_profiles_avatar_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_profiles_avatar_limit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_profiles_ensure_handle"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_profiles_ensure_handle"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_profiles_ensure_handle"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_profiles_sync_public_profiles"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_profiles_sync_public_profiles"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_profiles_sync_public_profiles"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_update_latest_card"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_update_latest_card"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_update_latest_card"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_user_stats_fill_profile_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_user_stats_fill_profile_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_user_stats_fill_profile_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trg_user_stats_on_challenge_terminal"() TO "anon";
GRANT ALL ON FUNCTION "public"."trg_user_stats_on_challenge_terminal"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trg_user_stats_on_challenge_terminal"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_avatar"("p_avatar_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_avatar"("p_avatar_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_avatar"("p_avatar_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_avatar_v1"("p_avatar_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_avatar_v1"("p_avatar_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_avatar_v1"("p_avatar_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_profile"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."update_profile_card_for_app_user"("p_app_user_id" "uuid", "p_bio" "text", "p_avatar_url" "text", "p_update_bio" boolean, "p_update_avatar" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."update_profile_card_for_app_user"("p_app_user_id" "uuid", "p_bio" "text", "p_avatar_url" "text", "p_update_bio" boolean, "p_update_avatar" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_profile_v1"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile_v1"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile_v1"("p_nickname" "text", "p_bio" "text", "p_cg_title" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."update_tap_card_reply"("p_reply_id" "uuid", "p_body" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."update_tap_card_reply"("p_reply_id" "uuid", "p_body" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_tap_card_reply"("p_reply_id" "uuid", "p_body" "text") TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_challenge_config" TO "service_role";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_instance_challenge_config" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_instance_challenge_disputes" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_instance_challenge_disputes" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_instance_challenge_events" TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_challenge_mail_tokens" TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_challenge_payment_attempts" TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_challenge_payment_webhook_events" TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_challenge_payments" TO "service_role";



GRANT ALL ON TABLE "public"."activity_instance_likes" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_instance_likes" TO "anon";
GRANT SELECT,INSERT ON TABLE "public"."activity_instance_likes" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_instance_replies" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_instance_replies" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_instance_replies" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_instances" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_instances" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_instances" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_taps" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_taps" TO "anon";
GRANT SELECT ON TABLE "public"."activity_taps" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_template_challenge_config" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_template_challenge_config" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_template_challenge_config" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_template_likes" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_template_likes" TO "anon";
GRANT SELECT,INSERT ON TABLE "public"."activity_template_likes" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_template_replies" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_template_replies" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_template_replies" TO "authenticated";



GRANT ALL ON TABLE "public"."activity_templates" TO "service_role";
GRANT SELECT ON TABLE "public"."activity_templates" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."activity_templates" TO "authenticated";



GRANT ALL ON TABLE "public"."app_auth_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."app_users" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON SEQUENCE "public"."audit_logs_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."audit_logs_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."audit_logs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."avatar_change_logs" TO "service_role";



GRANT ALL ON TABLE "public"."consent_logs" TO "service_role";



GRANT ALL ON TABLE "public"."email_jobs" TO "service_role";



GRANT ALL ON TABLE "public"."final_call_projection" TO "service_role";
GRANT SELECT ON TABLE "public"."final_call_projection" TO "anon";
GRANT SELECT ON TABLE "public"."final_call_projection" TO "authenticated";



GRANT ALL ON TABLE "public"."ip_rate_limits" TO "service_role";



GRANT ALL ON TABLE "public"."privacy_policy_acceptances" TO "service_role";



GRANT ALL ON TABLE "public"."privacy_policy_versions" TO "service_role";
GRANT SELECT ON TABLE "public"."privacy_policy_versions" TO "anon";
GRANT SELECT ON TABLE "public"."privacy_policy_versions" TO "authenticated";



GRANT ALL ON TABLE "public"."profiles_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."profiles_history_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."profiles_history_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."profiles_history_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."public_activity_templates" TO "service_role";
GRANT SELECT ON TABLE "public"."public_activity_templates" TO "anon";
GRANT SELECT ON TABLE "public"."public_activity_templates" TO "authenticated";



GRANT ALL ON TABLE "public"."public_profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."public_profiles" TO "anon";
GRANT SELECT ON TABLE "public"."public_profiles" TO "authenticated";



GRANT ALL ON TABLE "public"."tap_card_likes" TO "service_role";
GRANT SELECT ON TABLE "public"."tap_card_likes" TO "anon";
GRANT SELECT,INSERT ON TABLE "public"."tap_card_likes" TO "authenticated";



GRANT ALL ON TABLE "public"."tap_card_replies" TO "service_role";
GRANT SELECT ON TABLE "public"."tap_card_replies" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "public"."tap_card_replies" TO "authenticated";



GRANT ALL ON TABLE "public"."tap_cards" TO "service_role";
GRANT SELECT ON TABLE "public"."tap_cards" TO "anon";
GRANT SELECT ON TABLE "public"."tap_cards" TO "authenticated";



GRANT ALL ON TABLE "public"."tap_card_leaderboard_mv" TO "service_role";



GRANT ALL ON TABLE "public"."tos_acceptances" TO "service_role";



GRANT ALL ON TABLE "public"."tos_versions" TO "service_role";
GRANT SELECT ON TABLE "public"."tos_versions" TO "anon";
GRANT SELECT ON TABLE "public"."tos_versions" TO "authenticated";



GRANT ALL ON TABLE "public"."user_rate_limits" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






