# M3 — Kategori/Tag + History Search + Trash Per-Plan

Created: 2026-09-05 12:00:00

## Objective

Bikin riwayat bisa dicari dan diatur (kategori/tag + breakdown insight) dan bikin trash jadi pembeda Plus yang jujur (retensi per-plan), tanpa mengubah jendela hari existing (Free 30 / Plus 365 — `lib/core/billing/plus_feature_limits.dart:4`).

## Scope

- In-scope: F9 kategori/tag + filter insight, F15 history search server-side + trash 30 vs 90 hari.
- Out-of-scope: budget/alert, auto-kategorisasi LLM, full-text ranking kompleks.
- Skema: `bills.category`, `bill_tags`; extend RPC history + insight + share-token resolve (ikutkan kategori).

## Milestones

1. F9.1 Migrasi kategori/tag + RPC insight breakdown.
2. F9.2 Client picker + filter + insight UI.
3. F15.1 Search RPC + index + client search field.
4. F15.2 Trash retensi per-plan + UI expiry.

## Tasks

- [ ] F9.1 Migrasi: `bills.category TEXT DEFAULT 'lain'` (check preset `makan/transport/groceries/belanja/lain`), `bill_tags TEXT[] DEFAULT '{}'` (Plus custom ≤5, validasi panjang di RPC); index `(owner_id, category)`; RLS ikut bills (tanpa policy baru bila ikut tabel induk — verifikasi). `REVOKE/GRANT` eksplisit per standar.
- [ ] F9.2 Extend `get_monthly_spending_insight` (baseline `supabase/migrations/20260605100000_monthly_spending_insight.sql` + currency scoping `20260609110000/20260624090000`): tambah `p_category` opsional + output `by_category[]`; entity `MonthlySpendingInsight` (`lib/domain/entities/monthly_spending_insight.dart:1-121`) tambah `byCategory`; provider `monthly_spending_insight_provider.dart:14-33` teruskan filter.
- [ ] F9.3 Client: picker kategori di review (`bill_review_screen.dart` sejajar currency chip Plus `app_id.arb:488-489` — kategori preset bebas untuk Free, custom tag Plus-gated); chip kategori di history row + filter sheet (`history_screen.dart:611-833`, `history_filter_state.dart:7-35` tambah `category?` + `query` terpisah); insight card breakdown (`history_screen.dart:910-1252`).
- [ ] F9.4 ARB: `categoryLabel`, `categoryMakan/Transport/Groceries/Belanja/Lain`, `tagLabel`, `tagPlusLocked`, `tagLimitReached` (ID+EN).
- [ ] F9.5 Test (diperkuat hasil review): matriks `currency+category+status` (mis. `IDR+makan+settled`, `USD+lain+unpaid`, semua-null); `CHECK category IN (...)` tolak `FOOD/NULL/''` atau coerce→`lain` (kunci satu); bill lama tanpa kolom terbaca `lain` bukan crash `fromJson`; tags: Plus ≤5, tiap ≤N char, `[]` vs `null` vs `['','  ']` dinormalisasi, PII (email/phone di tag) tak di-strip tapi tak di-log; Free tambah custom tag → Plus-gate; insight bulan kosong (`billCount=0`, `average` anti-div0, `momPercent=null`, `trend/topMerchants=[]`); currency tak ada di data → `total=0` bukan error; filter kategori di luar `historyCutoff` (`history_screen.dart:89-95`) → `0` bukan bocor; DTO `bill/history_bill` roundtrip `category/tags` (field belum ada di `bill.dart:11-29`, `bill_dto.dart:12-25`, `history_bill(_dto)` — tambah + uji).
- [ ] F15.1 Extend `list_history_bills_page` + `get_history_page_summary` dengan `p_query TEXT` (ILIKE merchant + item name via join lateral; limit 25/page tetap `history_list_notifier.dart:199-210`); index trigram `pg_trgm` pada `bills.title` (+ `items.name` bila join terbukti berat → batasi ke title dulu). Jaga invariant `amount sort requires p_currency_code` (`20260715210000`).
- [ ] F15.2 Client search field di history (catat koreksi review: `history_screen.dart:170-186` hari ini hanya tombol tune+Badge, belum ada search field — tambah `TextField/SearchBar` baru) + debounce 400ms + `HistoryFilterState.query` baru + `setQuery` di notifier + `FilteredEmptyState` (`:295-302`) tampilkan teks query + tombol reset query; `normalizeHistoryFilter` (`history_filter_state.dart:25-35`) + `effectiveHistorySort` (`history_bill_filter.dart:36-49`) pertahankan aturan amount-sort saat query aktif; ganti query → reset cursor (`cursor:null,append:false`, `nextCursor/hasMore` overwrite `history_list_notifier.dart:223-227`), bukan append.
- [ ] F15.3 Trash per-plan: server hitung `delete_expires_at` per `plan_code` (Free 30 / Plus 90 hari) saat `soft_delete_bill`; `DeletedBill.isExpired` (`lib/domain/entities/deleted_bill.dart:22`) + `bill_list_notifier.dart:57-87` (gate `isPlus`) + `deleted_bills_screen.dart:20-162` tampilkan countdown + label retensi per-plan; copy ARB existing "30 hari" (`app_en.arb:250-253,267`) dipecah jadi `deletedBillsRetentionFree/Plus`.
- [ ] F15.4 Test (diperkuat hasil review): ILIKE escaping (`100%`, `a_b`, `c\d` pakai `ESCAPE '\'`); query kosong/whitespace→`NULL` (bukan `ILIKE '%%'` full-scan); search pagination + cursor + dedupe `existingIds` (`history_list_notifier.dart:216-227`) + tie-breaker stabil `createdAt+id` untuk `titleAsc/amount*`; summary count ikut `query/category` (kontrak `get_history_page_summary` hari ini hanya `p_created_after`); trash: restore expired→pesan khusus (bukan `errorGeneric`), restore already-restored/purged→hapus optimistik + `refresh`, pre-check client `isExpired` + pesan (hari ini hanya disable tombol `deleted_bills_screen.dart:109-113`); downgrade Plus→Free: expiry `+90d` yang sudah dihitung tidak dipendekkan, bill baru dapat `+30d`; list trash `order deleted_at desc` + batas + tampil countdown `Xd lagi` + label retensi per-plan (ganti sisa copy singular "30 hari" di `app_id.arb:250-253,267`); tambah `trashRetentionDaysFree/Plus` + `daysRemaining` di `plus_feature_limits.dart` (belum ada).
- [ ] Verifikasi akhir M3: `flutter analyze`, `flutter test`, `flutter build apk --split-per-abi`; migrasi operator-apply + advisor re-run.

## Risks

- LIKE/trigram lintas `bills+items` bisa berat di akun besar — mitigasi: batasi ke `bills.title` dulu, `limit+1` trick dipertahankan (`bill_remote_datasource.dart:161-175`), cutoff hari tetap mempersempit.
- Backfill kategori untuk bill lama — mitigasi: default `lain`, tanpa backfill LLM.
- Copy retensi berubah (30→30/90) — risiko klaim menyesatkan di string lama; mitigasi: pecah ARB + screenshot Play listing bila menyebut 30 hari.

## Progress Log

- 2026-09-05 12:00:00 — Plan M3 ditulis; belum ada implementasi.
- 2026-09-05 12:30:00 — Review audit vs kode: perkuat F9.5/F15.2/F15.4, koreksi klaim search-field existing, tambah DTO/ARB/kontrak yang terbukti belum ada; belum ada implementasi.

## Notes

- Contoh: `cari "kopi" → 8 bill; filter kategori "makan" + insight breakdown bulanan`.
- Counter-argumen: search + kategori sekaligus menggandakan kombinasi filter yang diuji; alternatif: rilis search dulu, kategori menyusul — plan ini menggabung karena menyentuh RPC/filter yang sama sehingga sekali migrasi filter.
- Perubahan skema live wajib lewat plan ini (aturan repo), bukan eksekusi langsung; koneksi MCP read-only.
