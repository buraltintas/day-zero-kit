-- Gün 0 adım 7: prod Neon (K-004, K-005; Gün 0 önlemi 6).
-- Ürün sahibi okur ve KENDİ kimliğiyle çalıştırır; ajan çalıştırmaz.
--
-- Önce Neon konsolunda, ürünün prod org'unda (Launch):
--   1. Proje: bölge AWS Frankfurt (aws-eu-central-1), Postgres 18.
--   2. Compute: min 0,25 CU, max 1 CU; 5 dk boşta uyku açık.
--      (1 CU'da 7/24 en kötü fatura ~$76/ay.)
--   3. Geçmiş (instant restore) 7 gün; Launch'ta varsayılan 1 gün.
--   4. Prod dalı korumalı (Launch'ta 2 korumalı dal).
--   5. Üç rol konsoldan açılır; parolaları Neon üretir, ürün sahibi
--      Secret Manager'a yazar (K-009 bekliyor), ajan görmez:
--        kampus_app      uygulama, yalnız DML, -pooler adresinden
--        kampus_migrate  migration, şemada nesne yaratır, direct adres
--        kampus_backup   yedek, salt okunur, direct adres
--      Ajanın prod'daki tek kimliği kampus_backup'ın salt okunur
--      bağlantısıdır; canlı yazma adresi ajanın ortamında yok.
--
-- Çalıştırma: Neon'un sahip rolüyle (neondb_owner), DIRECT adresten:
--   psql "$NEON_PROD_OWNER_DIRECT_URL" -v ON_ERROR_STOP=1 \
--     -f infra/owner/07-neon-prod-roles.sql
-- Adres ve parola komut geçmişine yazılmaz; ortam değişkeninden okunur.

BEGIN;

-- Migration rolü şemada nesne yaratır; tabloların sahibi o olur.
GRANT USAGE, CREATE ON SCHEMA public TO kampus_migrate;

-- Uygulama rolü: yalnız DML.
GRANT USAGE ON SCHEMA public TO kampus_app;
ALTER DEFAULT PRIVILEGES FOR ROLE kampus_migrate IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO kampus_app;
ALTER DEFAULT PRIVILEGES FOR ROLE kampus_migrate IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO kampus_app;

-- Yedek rolü: salt okunur.
GRANT USAGE ON SCHEMA public TO kampus_backup;
ALTER DEFAULT PRIVILEGES FOR ROLE kampus_migrate IN SCHEMA public
  GRANT SELECT ON TABLES TO kampus_backup;
ALTER DEFAULT PRIVILEGES FOR ROLE kampus_migrate IN SCHEMA public
  GRANT SELECT ON SEQUENCES TO kampus_backup;
ALTER ROLE kampus_backup SET default_transaction_read_only = on;

-- Rol zaman aşımları: sızan transaction veritabanını uyanık tutmasın.
ALTER ROLE kampus_app SET statement_timeout = '15s';
ALTER ROLE kampus_app SET idle_in_transaction_session_timeout = '30s';

COMMIT;

-- Doğrulama (çıktıyı ajana ver):
SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname IN ('kampus_app', 'kampus_migrate', 'kampus_backup')
ORDER BY rolname;
-- Beklenen: kampus_app {statement_timeout=15s,
--   idle_in_transaction_session_timeout=30s};
--   kampus_backup {default_transaction_read_only=on}.
SELECT defaclrole::regrole, defaclobjtype, defaclacl
FROM pg_default_acl;
