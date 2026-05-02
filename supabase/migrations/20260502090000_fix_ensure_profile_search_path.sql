-- Fix: `ensure_profile_for_user` trigger fails with "relation profiles does not
-- exist" because the function runs in `auth.users`'s execution context, where
-- `public` is NOT on the search_path. The bare `profiles` reference cannot be
-- resolved, the trigger raises, and Supabase Auth surfaces the generic
-- "Database error creating anonymous user" message — blocking every new
-- anonymous (and email) signup.
--
-- Fix per Supabase's recommended pattern for SECURITY DEFINER triggers on
-- auth.users:
--   1. Pin search_path to '' so name resolution is deterministic and not
--      vulnerable to caller path manipulation.
--   2. Fully qualify the target table as `public.profiles`.
--   3. Recreate the trigger so it points at the rebuilt function (CREATE OR
--      REPLACE keeps the old function body referenced by the existing trigger
--      definition, which is fine, but we recreate the trigger anyway to make
--      this migration self-contained / re-runnable).

CREATE OR REPLACE FUNCTION public.ensure_profile_for_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.ensure_profile_for_user();
