CREATE TYPE template_lifecycle_state AS ENUM (
    'DRAFT',
    'PUBLISHED',
    'ARCHIVED'
    );

CREATE TYPE template_play_context AS ENUM (
    'OFFLINE',
    'ONLINE',
    'HYBRID'
    );

CREATE TYPE template_relationship_mode AS ENUM (
    'SOLO',
    'DUEL_1V1',
    'HOST_1_TO_MANY',
    'GROUP_MANY_TO_MANY'
    );

CREATE TYPE activity_mode_kind AS ENUM (
    'CHALLENGE'
    );

CREATE TYPE template_visibility AS ENUM (
    'PUBLIC',
    'PRIVATE'
    );


CREATE OR REPLACE FUNCTION set_updated_at()
    RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TABLE activity_templates (
                                    id uuid NOT NULL DEFAULT gen_random_uuid(),

                                    origin_id uuid NOT NULL,
                                    parent_id uuid NULL,

                                    title text NOT NULL,
                                    rules text NULL,

                                    lifecycle_state template_lifecycle_state NOT NULL DEFAULT 'DRAFT',

                                    cadence_hint text NULL,

                                    proof_kind text NOT NULL DEFAULT 'ANY',
                                    status text NOT NULL DEFAULT 'ACTIVE',

                                    curation_bucket smallint NULL,

                                    play_context template_play_context NOT NULL DEFAULT 'OFFLINE',

                                    relationship_mode template_relationship_mode NOT NULL DEFAULT 'SOLO',

                                    created_by uuid NULL,

                                    idempotency_key text NULL,
                                    creator_display_name text NULL,

                                    created_at timestamptz NOT NULL DEFAULT now(),
                                    updated_at timestamptz NOT NULL DEFAULT now(),

                                    updated_by uuid NULL,

                                    deleted_at timestamptz NULL,
                                    deleted_by uuid NULL,

                                    min_participants smallint NULL,
                                    max_participants smallint NULL,

                                    mode_kind activity_mode_kind NOT NULL DEFAULT 'CHALLENGE',

                                    published_at timestamptz NULL,

                                    visibility template_visibility NOT NULL DEFAULT 'PUBLIC',

                                    deleted_photo_path text NULL,
                                    photo_path text NULL,

                                    CONSTRAINT activity_templates_pkey
                                        PRIMARY KEY (id),

                                    CONSTRAINT activity_templates_parent_fk
                                        FOREIGN KEY (parent_id)
                                            REFERENCES activity_templates(id)
                                            ON DELETE SET NULL,

                                    CONSTRAINT activity_templates_origin_fk
                                        FOREIGN KEY (origin_id)
                                            REFERENCES activity_templates(id)
                                            ON DELETE RESTRICT
                                            DEFERRABLE INITIALLY DEFERRED,

                                    CONSTRAINT activity_templates_created_by_fk
                                        FOREIGN KEY (created_by)
                                            REFERENCES app_users(id),

                                    CONSTRAINT activity_templates_updated_by_fk
                                        FOREIGN KEY (updated_by)
                                            REFERENCES app_users(id),

                                    CONSTRAINT activity_templates_deleted_by_fk
                                        FOREIGN KEY (deleted_by)
                                            REFERENCES app_users(id),

                                    CONSTRAINT activity_templates_status_check
                                        CHECK (status IN ('ACTIVE', 'DISABLED')),

                                    CONSTRAINT activity_templates_parent_not_self
                                        CHECK (parent_id IS NULL OR parent_id <> id),

                                    CONSTRAINT activity_templates_idem_key_nonempty
                                        CHECK (
                                            idempotency_key IS NULL
                                                OR length(trim(idempotency_key)) > 0
                                            ),

                                    CONSTRAINT activity_templates_proof_kind_check
                                        CHECK (
                                            proof_kind IN (
                                                           'NONE',
                                                           'TEXT',
                                                           'PHOTO',
                                                           'LINK',
                                                           'ANY'
                                                )
                                            )
);


CREATE INDEX idx_activity_templates_mode_kind
    ON activity_templates(mode_kind);

CREATE UNIQUE INDEX uq_activity_templates_creator_idem
    ON activity_templates(created_by, idempotency_key)
    WHERE idempotency_key IS NOT NULL;

CREATE INDEX idx_activity_templates_origin_id
    ON activity_templates(origin_id);

CREATE INDEX idx_activity_templates_parent_id
    ON activity_templates(parent_id);

CREATE INDEX idx_activity_templates_curation_bucket
    ON activity_templates(curation_bucket)
    WHERE curation_bucket IS NOT NULL
        AND deleted_at IS NULL;


CREATE TRIGGER trg_activity_templates_set_updated_at
    BEFORE UPDATE ON activity_templates
    FOR EACH ROW
EXECUTE FUNCTION set_updated_at();