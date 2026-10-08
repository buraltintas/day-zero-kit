# Changelog
En yeni üstte. Önce kullanıcının fark edeceği
değişiklik (en çok 2 satır), sonra teknik
ayrıntı (en çok 5 satır). Gizli değer yazılmaz.
Türler: Eklendi, Değişti, Kalkacak, Kaldırıldı,
Düzeltildi, Güvenlik.
40 KB'ı geçince en eski ay
docs/changelog/YYYY-MM.md'ye taşınır.

## Unreleased
### Eklendi
- Kullanıcıya etkisi yok: Gün 0 aşaması DUR noktalarında
  (adım 15 başlamadı). Teknik: kontrol listesinde 0/12 kutu;
  ayrıntı docs/STATUS.md, devir docs/handoff/2026-10-08.md.
- Kullanıcıya etkisi yok: tasarım token'ları ve üretici (Gün 0
  adım 14). Teknik: tokens/tokens.json'dan CSS, theme.ts ve
  e-posta sabitleri; DESIGN.md tablosu üretiliyor; yalnız açık
  tema (K-014); renkler yer tutucu.
- Kullanıcıya etkisi yok: KVKK belgesi ve gizlilik metni
  taslağı (Gün 0 adım 12). Teknik: docs/KVKK.md; veri AB'de,
  işleyen listesi, ihlal planı, hukukçu soruları.
- Kullanıcıya etkisi yok: prod servis tanımları ve Docker deposu
  betiği (Gün 0 adım 8, kısmen). Teknik: api ve web service.yaml,
  AR temizlik kuralı; tetikleyiciler K-007'yi bekliyor.
- Kullanıcıya etkisi yok: prod Neon rol betiği (Gün 0 adım 7).
  Teknik: infra/owner/07-neon-prod-roles.sql üç rolün yetkisi
  ve zaman aşımları; yerel PG 17'de denendi. Çalıştırılmadı.
- Kullanıcıya etkisi yok: depo kapısı ve sürüm tabanı (Gün 0
  adım 6). Teknik: pre-commit kancası 1 MB'tan büyük dosyayı,
  Mach-O/ELF ikilisini reddeder, gitleaks yoksa kapalı kalır;
  check-eol.sh, renovate.json, .npmrc (min-release-age=7);
  GitHub betiği ve main kuralı ürün sahibini bekliyor.
- Kullanıcıya etkisi yok: faturalama ve bütçe betiği (Gün 0
  adım 4). Teknik: infra/owner/04-billing-budget.sh ürün
  sahibinin kimliğiyle çalışır; docs/runbooks/cost-check.md
  (SKU sorgusu, eşikte ne yapılır). Çalıştırılmadı.
- Kullanıcıya etkisi yok: hesap envanteri ve yenileme
  tablosu (Gün 0 adım 3). Teknik: docs/ACCOUNTS.md,
  docs/ALERTS.md; hesaplar açılmadı, sahip sütunu K-002'yi
  bekliyor.
- Kullanıcıya etkisi yok: proje hafızası açıldı (Gün 0
  adım 1–2). Teknik: AGENTS.md, CLAUDE.md (@AGENTS.md),
  docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md
  (K-001–K-028; dokuzu KARAR BEKLİYOR), .gitignore,
  .env.example (yalnız adlar), .claude/settings.json.
