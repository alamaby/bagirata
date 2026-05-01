-- Adds user-facing preference columns to `profiles` and an `auth.users` trigger
-- so every new user (anonymous or email) gets a profiles row automatically.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS display_name      TEXT,
  ADD COLUMN IF NOT EXISTS default_currency  TEXT NOT NULL DEFAULT 'IDR',
  ADD COLUMN IF NOT EXISTS language_pref     TEXT NOT NULL DEFAULT 'id',
  ADD COLUMN IF NOT EXISTS theme_pref        TEXT NOT NULL DEFAULT 'system';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_default_currency_check'
  ) THEN
    ALTER TABLE profiles
      ADD CONSTRAINT profiles_default_currency_check
      CHECK (default_currency IN ('IDR','USD','MYR','AUD','SGD','SAR'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_language_pref_check'
  ) THEN
    ALTER TABLE profiles
      ADD CONSTRAINT profiles_language_pref_check
      CHECK (language_pref IN ('id','en'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'profiles_theme_pref_check'
  ) THEN
    ALTER TABLE profiles
      ADD CONSTRAINT profiles_theme_pref_check
      CHECK (theme_pref IN ('light','dark','system'));
  END IF;
END $$;

CREATE OR REPLACE FUNCTION ensure_profile_for_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id) VALUES (NEW.id) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION ensure_profile_for_user();
