-- migrate_anon_data(p_old_uid)
--
-- Reassigns rows owned by an anonymous uid to the caller's current uid so a
-- user's in-progress receipts survive the transition from anonymous → signed-in.
--
-- Schema note: only `bills` carries an explicit owner column (`owner_id`).
-- items / participants / item_assignments inherit ownership through their
-- bill via the existing RLS policies, so updating bills.owner_id is sufficient
-- to migrate the entire object graph.

CREATE OR REPLACE FUNCTION public.migrate_anon_data(p_old_uid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    rows_moved INTEGER;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'migrate_anon_data must be called by an authenticated user';
    END IF;
    IF p_old_uid = auth.uid() THEN
        RETURN 0;
    END IF;

    UPDATE public.bills
       SET owner_id = auth.uid()
     WHERE owner_id = p_old_uid;

    GET DIAGNOSTICS rows_moved = ROW_COUNT;
    RETURN rows_moved;
END;
$$;

REVOKE ALL ON FUNCTION public.migrate_anon_data(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.migrate_anon_data(UUID) TO authenticated;
