CREATE TYPE content_status AS ENUM (
    'VISIBLE',
    'HIDDEN',
    'PENDING_REVIEW'
);

CREATE TABLE profiles (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL
        REFERENCES app_users(id) ON DELETE CASCADE,
    handle text NULL,
    nickname text NULL,
    avatar_url text NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT profiles_pkey PRIMARY KEY (id),
    CONSTRAINT profiles_user_id_key UNIQUE (user_id)
);

CREATE TABLE tap_card_likes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    tap_card_id uuid NOT NULL
        REFERENCES tap_cards(id) ON DELETE CASCADE,
    user_id uuid NOT NULL
        REFERENCES app_users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT tap_card_likes_pkey PRIMARY KEY (id),
    CONSTRAINT tap_card_likes_tap_card_id_user_id_key UNIQUE (tap_card_id, user_id)
);

CREATE INDEX idx_tap_card_likes_tap_card_id ON tap_card_likes(tap_card_id);
CREATE INDEX idx_tap_card_likes_user_id ON tap_card_likes(user_id);

CREATE TABLE tap_card_replies (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    tap_card_id uuid NOT NULL
        REFERENCES tap_cards(id) ON DELETE CASCADE,
    user_id uuid NOT NULL
        REFERENCES app_users(id) ON DELETE CASCADE,
    body text NOT NULL,
    status content_status NOT NULL DEFAULT 'VISIBLE',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz NULL,

    CONSTRAINT tap_card_replies_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_tap_card_replies_tap_card_id ON tap_card_replies(tap_card_id, created_at DESC);
CREATE INDEX idx_tap_card_replies_status ON tap_card_replies(status);

CREATE TRIGGER trg_profiles_set_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_tap_card_replies_set_updated_at
    BEFORE UPDATE ON tap_card_replies
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
