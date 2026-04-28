-- 1. EXTENSIONS (Pastikan extension yang dibutuhkan aktif)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABEL PROFIL (Untuk menyimpan info rekening setelah login)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    bank_accounts JSONB DEFAULT '[]', -- Menyimpan array [{provider: "BCA", account: "123"}, ...]
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABEL BILLS (Header Tagihan)
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    title TEXT NOT NULL,
    total_amount NUMERIC(15, 2) DEFAULT 0,
    tax_amount NUMERIC(15, 2) DEFAULT 0,
    service_charge NUMERIC(15, 2) DEFAULT 0,
    is_settled BOOLEAN DEFAULT FALSE,
    image_url TEXT, -- Opsional: jika ingin menyimpan bukti foto di Storage
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABEL ITEMS (Daftar barang dari hasil OCR)
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID REFERENCES bills(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    price NUMERIC(15, 2) NOT NULL,
    qty INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABEL PARTICIPANTS (Daftar orang yang ikut bayar)
CREATE TABLE participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID REFERENCES bills(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. TABEL ITEM_ASSIGNMENTS (Relasi Many-to-Many: Siapa makan apa)
CREATE TABLE item_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID REFERENCES items(id) ON DELETE CASCADE,
    participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
    share_weight NUMERIC(3, 2) DEFAULT 1.0, -- Contoh: 0.5 jika dibagi 2 orang
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. TABEL LLM_CONFIGS (Untuk rotasi API Key & Provider)
CREATE TABLE llm_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_name TEXT NOT NULL, -- Gemini, OpenRouter, NvidiaNIM
    api_key TEXT NOT NULL,
    base_url TEXT,
    model_name TEXT,
    priority INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. TABEL LLM_LOGS (Logging untuk debugging & pemantauan kuota)
CREATE TABLE llm_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID REFERENCES bills(id) ON DELETE SET NULL,
    provider TEXT,
    request_payload JSONB,
    response_payload JSONB,
    latency_ms INTEGER,
    status_code INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Aktifkan RLS di semua tabel
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE item_assignments ENABLE ROW LEVEL SECURITY;

-- Polisi untuk Bills: Hanya pemilik (anonim atau verified) yang bisa akses
CREATE POLICY "Users can manage their own bills" ON bills
    FOR ALL USING (auth.uid() = owner_id);

-- Polisi untuk Items: Akses jika pemilik bill
CREATE POLICY "Users can manage items of their bills" ON items
    FOR ALL USING (
        EXISTS (SELECT 1 FROM bills WHERE bills.id = items.bill_id AND bills.owner_id = auth.uid())
    );

-- Polisi untuk Participants
CREATE POLICY "Users can manage participants of their bills" ON participants
    FOR ALL USING (
        EXISTS (SELECT 1 FROM bills WHERE bills.id = participants.bill_id AND bills.owner_id = auth.uid())
    );

-- Polisi untuk Assignments
CREATE POLICY "Users can manage assignments of their bills" ON item_assignments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM items 
            JOIN bills ON bills.id = items.bill_id 
            WHERE items.id = item_assignments.item_id AND bills.owner_id = auth.uid()
        )
    );

-- Polisi untuk Profiles: Hanya pemilik yang bisa lihat/ubah
CREATE POLICY "Users can manage their own profile" ON profiles
    FOR ALL USING (auth.uid() = id);

-- ==========================================
-- TRIGGERS
-- ==========================================

-- Trigger untuk memperbarui updated_at di tabel profiles
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();