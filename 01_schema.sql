-- ============================================================
-- MPK SMAN 1 BANGIL — Database Schema
-- Jalankan file ini di Supabase SQL Editor
-- ============================================================

-- Tabel utama aspirasi
CREATE TABLE IF NOT EXISTS aspirasi (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_code TEXT UNIQUE NOT NULL,
  kategori    TEXT NOT NULL,
  isi         TEXT NOT NULL,
  harapan     TEXT,
  status      TEXT NOT NULL DEFAULT 'Diterima'
                CHECK (status IN ('Diterima', 'Diproses', 'Selesai')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tabel counter publik (hanya angka, tanpa isi)
-- Diupdate otomatis via trigger — publik boleh baca
CREATE TABLE IF NOT EXISTS aspirasi_counter (
  id           INT PRIMARY KEY DEFAULT 1,
  total        INT NOT NULL DEFAULT 0,
  today        INT NOT NULL DEFAULT 0,
  last_date    DATE NOT NULL DEFAULT CURRENT_DATE,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- Seed baris tunggal counter
INSERT INTO aspirasi_counter (id, total, today, last_date)
VALUES (1, 0, 0, CURRENT_DATE)
ON CONFLICT (id) DO NOTHING;


-- ============================================================
-- TRIGGER: update counter otomatis saat insert aspirasi baru
-- ============================================================
CREATE OR REPLACE FUNCTION fn_update_counter()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE aspirasi_counter
  SET
    total      = total + 1,
    today      = CASE
                   WHEN last_date = CURRENT_DATE THEN today + 1
                   ELSE 1
                 END,
    last_date  = CURRENT_DATE,
    updated_at = now()
  WHERE id = 1;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_counter ON aspirasi;
CREATE TRIGGER trg_update_counter
AFTER INSERT ON aspirasi
FOR EACH ROW EXECUTE FUNCTION fn_update_counter();


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE aspirasi         ENABLE ROW LEVEL SECURITY;
ALTER TABLE aspirasi_counter ENABLE ROW LEVEL SECURITY;

-- Hapus semua policy lama bila ada
DROP POLICY IF EXISTS "anon_insert_aspirasi"     ON aspirasi;
DROP POLICY IF EXISTS "anon_read_counter"        ON aspirasi_counter;
DROP POLICY IF EXISTS "admin_read_aspirasi"      ON aspirasi;
DROP POLICY IF EXISTS "admin_update_aspirasi"    ON aspirasi;

-- Siapa saja (anonim) boleh INSERT aspirasi
CREATE POLICY "anon_insert_aspirasi"
  ON aspirasi FOR INSERT
  TO anon
  WITH CHECK (true);

-- Siapa saja boleh READ counter (hanya angka)
CREATE POLICY "anon_read_counter"
  ON aspirasi_counter FOR SELECT
  TO anon
  USING (true);

-- Hanya authenticated (admin) boleh READ isi aspirasi
CREATE POLICY "admin_read_aspirasi"
  ON aspirasi FOR SELECT
  TO authenticated
  USING (true);

-- Hanya authenticated (admin) boleh UPDATE status
CREATE POLICY "admin_update_aspirasi"
  ON aspirasi FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
