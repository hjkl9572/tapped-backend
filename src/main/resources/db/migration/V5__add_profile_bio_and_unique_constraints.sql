ALTER TABLE profiles
    ADD COLUMN bio text NULL;

CREATE UNIQUE INDEX uniq_profiles_handle_ci
    ON profiles (lower(handle))
    WHERE handle IS NOT NULL;

CREATE UNIQUE INDEX uniq_profiles_nickname_ci
    ON profiles (lower(nickname))
    WHERE nickname IS NOT NULL;
