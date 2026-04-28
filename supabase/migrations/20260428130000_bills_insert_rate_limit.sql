-- Rate-limit insert ke `bills` per user di level DB.
--
-- Konteks: anonymous sign-in di-enable tanpa captcha. Tanpa lapis ini,
-- bot yang tahu anon key bisa bikin ribuan user anonim → tiap user spam
-- bills → bloat DB + naikkan MAU billing. Trigger ini menolak insert
-- ke-(N+1) dalam window waktu tertentu.
--
-- Catatan: ini lapis pertahanan terakhir, bukan pengganti captcha.
-- Captcha mencegah pembuatan akun bot; rate limit mencegah satu akun
-- (manusia atau bot) menyalahgunakan kuota insert.

-- Tunables — adjust sesuai pola pemakaian normal:
--   per_hour: pemakai aktif paling agresif (banyak struk dalam sehari)
--             biasanya < 10 bill/jam. 30 = 3x buffer.
--   per_day:  reasonable upper bound untuk power user.
CREATE OR REPLACE FUNCTION enforce_bills_insert_rate_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    per_hour_limit CONSTANT INT := 30;
    per_day_limit  CONSTANT INT := 200;
    hourly_count INT;
    daily_count  INT;
BEGIN
    -- Service role tidak terikat (untuk migrasi/seed/admin tools).
    IF auth.role() = 'service_role' THEN
        RETURN NEW;
    END IF;

    -- owner_id wajib ada — DEFAULT auth.uid() seharusnya sudah mengisi.
    IF NEW.owner_id IS NULL THEN
        RAISE EXCEPTION 'bills.owner_id NULL — user tidak terautentikasi'
            USING ERRCODE = '42501';
    END IF;

    SELECT COUNT(*) INTO hourly_count
    FROM bills
    WHERE owner_id = NEW.owner_id
      AND created_at > NOW() - INTERVAL '1 hour';

    IF hourly_count >= per_hour_limit THEN
        RAISE EXCEPTION
            'Rate limit terlampaui: maksimal % bill per jam (current: %)',
            per_hour_limit, hourly_count
            USING ERRCODE = 'P0001',
                  HINT = 'Tunggu sebentar sebelum membuat bill baru.';
    END IF;

    SELECT COUNT(*) INTO daily_count
    FROM bills
    WHERE owner_id = NEW.owner_id
      AND created_at > NOW() - INTERVAL '1 day';

    IF daily_count >= per_day_limit THEN
        RAISE EXCEPTION
            'Rate limit harian terlampaui: maksimal % bill per hari (current: %)',
            per_day_limit, daily_count
            USING ERRCODE = 'P0001',
                  HINT = 'Coba lagi besok.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS bills_insert_rate_limit ON bills;

CREATE TRIGGER bills_insert_rate_limit
    BEFORE INSERT ON bills
    FOR EACH ROW
    EXECUTE FUNCTION enforce_bills_insert_rate_limit();

-- Index pendukung supaya COUNT(*) dengan filter owner_id + created_at cepat.
-- Tanpa ini, setiap insert melakukan full scan bills → lambat saat data
-- sudah banyak.
CREATE INDEX IF NOT EXISTS bills_owner_created_at_idx
    ON bills (owner_id, created_at DESC);

COMMENT ON FUNCTION enforce_bills_insert_rate_limit IS
    'Rate limit insert ke bills: 30/jam, 200/hari per owner. Bypass utk service_role.';
