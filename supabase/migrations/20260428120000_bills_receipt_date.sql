-- Tambah kolom receipt_date untuk tanggal yang dideteksi LLM dari struk.
-- Berbeda dari created_at (waktu user input ke aplikasi). Nullable karena
-- sebagian struk tidak mencantumkan tanggal atau LLM gagal membacanya.

ALTER TABLE bills
    ADD COLUMN receipt_date DATE;

COMMENT ON COLUMN bills.receipt_date IS
    'Tanggal transaksi yang tertera di struk (hasil OCR). NULL jika tidak terbaca.';
