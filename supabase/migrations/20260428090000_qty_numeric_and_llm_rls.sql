-- 1. items.qty: INTEGER → NUMERIC
--    OCR mengembalikan qty pecahan untuk barang per-Kg / per-volume
--    (mis. 0.58 Kg). Domain dan DTO Flutter sudah double; kolom ikut.
ALTER TABLE items
    ALTER COLUMN qty TYPE NUMERIC(10, 3) USING qty::NUMERIC(10, 3);
ALTER TABLE items
    ALTER COLUMN qty SET DEFAULT 1;

-- 2. RLS untuk llm_configs & llm_logs
--    Edge Function memakai service-role key (bypass RLS), jadi enabling RLS
--    tanpa policy = deny-all bagi anon/authenticated. Defense in depth:
--    api_key tidak boleh terbaca dari klien dengan anon key.
ALTER TABLE llm_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE llm_logs ENABLE ROW LEVEL SECURITY;
-- Sengaja tidak menambahkan policy apa pun: hanya service-role yang berhak.
