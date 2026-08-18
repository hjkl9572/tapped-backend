CREATE TYPE auth_provider AS ENUM (
    'GOOGLE'
);

CREATE TABLE app_users (
                           id uuid NOT NULL DEFAULT gen_random_uuid(),
                           email text NOT NULL,
                           auth_provider auth_provider NOT NULL DEFAULT 'GOOGLE',
                           provider_subject text NOT NULL,
                           created_at timestamptz NOT NULL DEFAULT now(),
                           deleted_at timestamptz NULL,

                           CONSTRAINT app_users_pkey PRIMARY KEY (id),
                           CONSTRAINT app_users_email_key UNIQUE (email),
                           CONSTRAINT app_users_provider_subject_key
                               UNIQUE (auth_provider, provider_subject)
);