CREATE TYPE activity_instance_state AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'TERMINATED'
);

CREATE TYPE activity_ref_state AS ENUM (
    'PENDING',
    'DECIDED'
);

CREATE TYPE activity_ref_verdict AS ENUM (
    'SUCCESS',
    'FAIL'
);

CREATE TYPE activity_challenger_final_verdict AS ENUM (
    'SUCCESS',
    'FAIL',
    'CHICKEN',
    'DISPUTE'
);

CREATE TYPE activity_tap_state AS ENUM (
    'OPENED',
    'CANCELED'
);

CREATE TYPE challenge_event_type AS ENUM (
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

CREATE TABLE activity_template_challenge_config (
    activity_template_id uuid NOT NULL PRIMARY KEY
        REFERENCES activity_templates(id) ON DELETE CASCADE,
    ref_required boolean NOT NULL DEFAULT true,
    fail_card_fee_minor integer NULL,
    currency text NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT activity_template_challenge_config_fail_fee_nonnegative
        CHECK (fail_card_fee_minor IS NULL OR fail_card_fee_minor >= 0),
    CONSTRAINT activity_template_challenge_config_currency_nonempty
        CHECK (currency IS NULL OR length(trim(currency)) > 0)
);

CREATE TABLE public_activity_templates (
    id uuid NOT NULL PRIMARY KEY
        REFERENCES activity_templates(id) ON DELETE CASCADE,
    origin_id uuid NOT NULL,
    parent_id uuid NULL,
    title text NOT NULL,
    rules text NULL,
    cadence_hint text NULL,
    proof_kind text NOT NULL DEFAULT 'ANY',
    play_context template_play_context NOT NULL DEFAULT 'OFFLINE',
    relationship_mode template_relationship_mode NOT NULL DEFAULT 'SOLO',
    creator_display_name text NULL,
    published_at timestamptz NOT NULL,
    min_participants smallint NULL,
    max_participants smallint NULL,
    mode_kind activity_mode_kind NOT NULL DEFAULT 'CHALLENGE',
    photo_path text NULL,

    CONSTRAINT public_activity_templates_parent_not_self
        CHECK (parent_id IS NULL OR parent_id <> id),
    CONSTRAINT public_activity_templates_proof_kind_check
        CHECK (proof_kind IN ('NONE', 'TEXT', 'PHOTO', 'LINK', 'ANY'))
);

CREATE TABLE activity_instances (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_template_id uuid NOT NULL
        REFERENCES activity_templates(id) ON DELETE RESTRICT,
    created_by uuid NULL
        REFERENCES app_users(id),
    state activity_instance_state NOT NULL DEFAULT 'ACTIVE',
    started_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz NULL,
    terminated_at timestamptz NULL,
    first_tap_at timestamptz NULL,
    last_tap_at timestamptz NULL,
    tap_count integer NOT NULL DEFAULT 0,
    requirements_met boolean NULL,
    termination_reason text NULL,
    play_context template_play_context NOT NULL,
    relationship_mode template_relationship_mode NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid NULL
        REFERENCES app_users(id),
    deleted_at timestamptz NULL,
    deleted_by uuid NULL
        REFERENCES app_users(id),
    mode_kind activity_mode_kind NOT NULL DEFAULT 'CHALLENGE',
    idempotency_key text NULL,
    sequence_no integer NOT NULL,
    cover_card_id uuid NULL,
    end_at timestamptz NULL,

    CONSTRAINT activity_instances_pkey PRIMARY KEY (id),
    CONSTRAINT activity_instances_active_terminal_null_check
        CHECK (state <> 'ACTIVE' OR (completed_at IS NULL AND terminated_at IS NULL)),
    CONSTRAINT activity_instances_completed_fields_check
        CHECK (state <> 'COMPLETED' OR (completed_at IS NOT NULL AND terminated_at IS NULL)),
    CONSTRAINT activity_instances_terminated_fields_check
        CHECK (state <> 'TERMINATED' OR (terminated_at IS NOT NULL AND completed_at IS NULL)),
    CONSTRAINT activity_instances_sequence_no_check
        CHECK (sequence_no > 0),
    CONSTRAINT activity_instances_tap_count_nonnegative
        CHECK (tap_count >= 0),
    CONSTRAINT activity_instances_idem_key_nonempty
        CHECK (idempotency_key IS NULL OR length(trim(idempotency_key)) > 0)
);

CREATE TABLE activity_instance_challenge_config (
    activity_instance_id uuid NOT NULL PRIMARY KEY
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    ref_user_id uuid NULL
        REFERENCES app_users(id) ON DELETE SET NULL,
    ref_email text NOT NULL,
    ref_state activity_ref_state NOT NULL DEFAULT 'PENDING',
    ref_verdict activity_ref_verdict NULL,
    ref_decided_at timestamptz NULL,
    fail_card_fee_minor integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    last_ref_resend_at timestamptz NULL,
    challenger_finalized_at timestamptz NULL,
    challenger_final_verdict activity_challenger_final_verdict NULL,

    CONSTRAINT activity_instance_challenge_config_fail_card_fee_nonnegative_ch
        CHECK (fail_card_fee_minor >= 0),
    CONSTRAINT activity_instance_challenge_config_decided_check
        CHECK (ref_state <> 'DECIDED' OR (ref_verdict IS NOT NULL AND ref_decided_at IS NOT NULL)),
    CONSTRAINT activity_instance_challenge_config_pending_clear_check
        CHECK (ref_state <> 'PENDING' OR (ref_verdict IS NULL AND ref_decided_at IS NULL)),
    CONSTRAINT activity_instance_challenge_config_ref_email_nonempty
        CHECK (length(trim(ref_email)) > 0)
);

CREATE TABLE activity_taps (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_instance_id uuid NOT NULL
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    tapped_by uuid NULL
        REFERENCES app_users(id),
    sequence_no integer NOT NULL,
    first_happened_at timestamptz NOT NULL DEFAULT now(),
    finalized_at timestamptz NULL,
    canceled_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    state activity_tap_state NOT NULL,

    CONSTRAINT activity_taps_pkey PRIMARY KEY (id),
    CONSTRAINT activity_taps_sequence_positive
        CHECK (sequence_no >= 1),
    CONSTRAINT activity_taps_opened_canceled_at_null_check
        CHECK (state <> 'OPENED' OR canceled_at IS NULL),
    CONSTRAINT activity_taps_canceled_requires_canceled_at_check
        CHECK (state <> 'CANCELED' OR canceled_at IS NOT NULL),
    CONSTRAINT uq_activity_taps_instance_sequence
        UNIQUE (activity_instance_id, sequence_no)
);

CREATE TABLE tap_cards (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_instance_id uuid NOT NULL
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    tap_id uuid NOT NULL
        REFERENCES activity_taps(id) ON DELETE CASCADE,
    created_by uuid NOT NULL
        REFERENCES app_users(id),
    sequence_no integer NOT NULL,
    note text NULL,
    link_url text NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz NULL,
    tap_sequence_no integer NOT NULL,
    deleted_photo_path text NULL,
    photo_path text NULL,

    CONSTRAINT tap_cards_pkey PRIMARY KEY (id),
    CONSTRAINT tap_cards_sequence_no_check
        CHECK (sequence_no > 0)
);

CREATE TABLE activity_instance_challenge_events (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_instance_id uuid NOT NULL
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    event_type challenge_event_type NOT NULL,

    CONSTRAINT challenge_events_pkey PRIMARY KEY (id)
);

CREATE TABLE activity_instance_challenge_disputes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_instance_id uuid NOT NULL
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    submitted_by uuid NULL
        REFERENCES app_users(id) ON DELETE SET NULL,
    submitted_at timestamptz NOT NULL DEFAULT now(),
    reason_code text NOT NULL,
    details text NULL,
    ref_verdict activity_ref_verdict NULL,
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT activity_instance_challenge_disputes_pkey PRIMARY KEY (id),
    CONSTRAINT activity_instance_challenge_disputes_reason_nonempty
        CHECK (length(trim(reason_code)) > 0)
);

CREATE TABLE activity_instance_challenge_mail_tokens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    activity_instance_id uuid NOT NULL
        REFERENCES activity_instances(id) ON DELETE CASCADE,
    token text NOT NULL,
    action text NOT NULL,
    used_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NULL,
    invalidated_at timestamptz NULL,

    CONSTRAINT challenge_mail_tokens_pkey PRIMARY KEY (id),
    CONSTRAINT challenge_mail_tokens_token_key UNIQUE (token),
    CONSTRAINT challenge_mail_tokens_action_check
        CHECK (action IN ('ref_access', 'mark_success', 'mark_fail', 'mark_disagree')),
    CONSTRAINT challenge_mail_tokens_token_nonempty
        CHECK (length(trim(token)) > 0)
);

CREATE INDEX idx_activity_templates_published_public
    ON activity_templates(published_at DESC)
    WHERE deleted_at IS NULL
        AND visibility = 'PUBLIC'
        AND lifecycle_state = 'PUBLISHED';

CREATE INDEX idx_public_activity_templates_published_at
    ON public_activity_templates(published_at DESC);

CREATE INDEX idx_public_activity_templates_discovery
    ON public_activity_templates(mode_kind, published_at DESC);

CREATE INDEX idx_activity_instances_created_by
    ON activity_instances(created_by);

CREATE INDEX idx_activity_instances_template_id
    ON activity_instances(activity_template_id);

CREATE INDEX idx_activity_instances_creator_status_created
    ON activity_instances(created_by, state, created_at DESC);

CREATE UNIQUE INDEX uq_activity_instances_template_user_sequence
    ON activity_instances(activity_template_id, created_by, sequence_no)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX uq_activity_instances_user_idempotency
    ON activity_instances(created_by, idempotency_key)
    WHERE deleted_at IS NULL
        AND idempotency_key IS NOT NULL;

CREATE INDEX idx_activity_taps_instance_id
    ON activity_taps(activity_instance_id);

CREATE INDEX idx_tap_cards_activity_instance_id
    ON tap_cards(activity_instance_id)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_tap_cards_created_by
    ON tap_cards(created_by)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_tap_cards_instance_tap_seq
    ON tap_cards(activity_instance_id, tap_sequence_no, sequence_no)
    WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX uq_tap_cards_tap_sequence
    ON tap_cards(tap_id, sequence_no)
    WHERE deleted_at IS NULL;

CREATE INDEX challenge_events_activity_instance_id_idx
    ON activity_instance_challenge_events(activity_instance_id);

CREATE INDEX challenge_mail_tokens_activity_instance_id_idx
    ON activity_instance_challenge_mail_tokens(activity_instance_id);

CREATE INDEX activity_instance_challenge_disputes_instance_idx
    ON activity_instance_challenge_disputes(activity_instance_id);

CREATE TRIGGER trg_activity_template_challenge_config_set_updated_at
    BEFORE UPDATE ON activity_template_challenge_config
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_activity_instances_set_updated_at
    BEFORE UPDATE ON activity_instances
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_activity_instance_challenge_config_set_updated_at
    BEFORE UPDATE ON activity_instance_challenge_config
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_activity_taps_set_updated_at
    BEFORE UPDATE ON activity_taps
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tap_cards_set_updated_at
    BEFORE UPDATE ON tap_cards
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
