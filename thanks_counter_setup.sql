-- =============================================
-- Acil Epikriz — global teşekkür sayacı
-- Supabase SQL Editor'da çalıştır
-- =============================================

-- 1. Tablo oluştur
CREATE TABLE IF NOT EXISTS thanks_counter (
  id   INT     PRIMARY KEY DEFAULT 1,
  count BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT only_one_row CHECK (id = 1)
);

-- 2. İlk satırı ekle (varsa dokunma)
INSERT INTO thanks_counter (id, count) VALUES (1, 0)
  ON CONFLICT (id) DO NOTHING;

-- 3. RLS aç
ALTER TABLE thanks_counter ENABLE ROW LEVEL SECURITY;

-- 4. Herkes okuyabilir (anon key yeterli)
DROP POLICY IF EXISTS "anon_select" ON thanks_counter;
CREATE POLICY "anon_select" ON thanks_counter
  FOR SELECT TO anon USING (true);

-- 5. Herkes güncelleyebilir
DROP POLICY IF EXISTS "anon_update" ON thanks_counter;
CREATE POLICY "anon_update" ON thanks_counter
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- 6. Atomik artırma fonksiyonu (race condition'sız)
CREATE OR REPLACE FUNCTION increment_thanks()
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE new_count BIGINT;
BEGIN
  UPDATE thanks_counter
    SET count = count + 1
    WHERE id = 1
    RETURNING count INTO new_count;
  RETURN new_count;
END;
$$;

-- 7. Anon kullanıcılara çalıştırma izni
GRANT EXECUTE ON FUNCTION increment_thanks() TO anon;
