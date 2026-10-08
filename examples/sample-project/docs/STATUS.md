# Durum
Son güncelleme: 2026-10-08, Gün 0 kurulumu sürüyor.
7 günden eskiyse güvenme, canlıya bak.
Sahip oturum: KARAR BEKLİYOR (K-012). Bu kurulumu yürüten
  oturum: "Kampüs gün 0 kurulumu".
Ürün sahibi: ürün sahibi (ad sonra).

## Canlıda (doğrulama yöntemiyle)
Henüz yok. Hiçbir bulut kaynağı, uzak depo ya da alan
  adı yok; bu depo yalnız yerelde.

## Gün 0 kurulumu (adım, durum, doğrulama)
- 1 Kararlar: yapıldı, DUR (dokuz soru cevapsız).
  Doğrulama 2026-10-08: Tablo 1–17'nin her satırının
  DECISIONS'ta bir K bloğu var; taslak blokların hepsi
  TODO'nun "Karar bekleyen" bölümünde (grep).
- 2 Proje hafızası: yapıldı. Doğrulama 2026-10-08:
  git ls-files 11 dosyayı listeler; CLAUDE.md tek satır
  @AGENTS.md; .env.example git check-ignore'a takılmıyor.
  Claude Code'un /memory listesi etkileşimli; bu oturumda
  açılamadı, ilk oturumda bakılacak.
- 3 Hesaplar: envanter ve yenileme tablosu açıldı, DUR.
  Doğrulama 2026-10-08: GEÇMEDİ. Envanterde K-002'ye bağlı
  hücre ve 14 tarih yer tutucusu boş; hiçbir hesap açık
  değil, kök hesap anahtarı ekranda görülmedi.
  Önlem 1 ve 20'nin hesap kısmı docs/ACCOUNTS.md
  kutularında; ürün sahibi işaretler.
- 4 Faturalama ve bütçe: betik hazır, DUR.
  Ürün sahibinin çalıştıracağı: infra/owner/04-billing-budget.sh
  (proje, iki bütçe, üç eşik, Pub/Sub, BigQuery veri kümesi).
  Konsoldan: faturalama hesabı, Neon org'ları ve Launch,
  fatura dökümü, harcama tavanı (~$100), yedek kart.
  Doğrulama: çalıştırılmadı. Ürün sahibi betiğin sonundaki
  "gcloud billing budgets list --billing-account=..."
  çıktısını verince bakılır: iki bütçe, üç eşik.
  Önlem 7 (harcama tavanı) ve 13 (yedek kart, ikinci
  faturalama yöneticisi) betiğin başındaki listede.
  Betikteki gcloud bayrakları resmi sayfadan bu kuru
  çalışmada yeniden okunmadı (ağ yok).
- 5 Alan adı ve DNS: başlamadı, DUR. kampus.example yer
  tutucu; alan adını ürün sahibi alır (K-001). Alınınca
  ajan Cloudflare kayıtlarını başta gri kurar; web Worker
  ile run.app'e, api. domain mapping ile (gri); CAA
  eklenirse pki.goog ve letsencrypt.org birlikte (önlem 15).
  Doğrulama (alınınca): "dig +short NS <alan adı>"
  Cloudflare'i, "whois <alan adı>" clientTransferProhibited'ı
  gösterir. Çalıştırılmadı.
- 6 Depolar ve sürümler: yerel kısım yapıldı; GitHub kısmı DUR.
  Üretilen: scripts/check-repo-gate.sh ve .githooks/pre-commit
  (1 MB, Mach-O/ELF, gitleaks; gitleaks yoksa reddeder),
  scripts/check-eol.sh, renovate.json, .npmrc, Sürümler bölümü,
  infra/owner/06-github.sh ve infra/github/ruleset-main.json.
  Doğrulama 2026-10-08, yerelde, core.hooksPath=.githooks ile:
  2 MB'lık commit reddedildi; Mach-O başlıklı dosya reddedildi;
  düz metin de reddedildi, çünkü bu makinede gitleaks yok
  (kurmak ağ ister). Sahte anahtarlı commit denenemedi.
  check-eol.sh: tarihli üç satır da 6 aydan uzak (Node 24
  570 gün, Next 16 378 gün, PG 18 1498 gün), çıkış 0.
  Kuru çalışmada kanca sonra kapatıldı; sonraki commit'ler
  kapıdan geçmedi.
  Çalıştırılmadı (GitHub, DUR): özel depolar, push protection,
  main'e force push ve silme yasağı, test'ten main'e
  fast-forward; Renovate uygulaması. Depo adları K-028'i,
  test dalı K-007'yi bekliyor. CI'daki kapı (check-repo-gate.sh
  --all) tetikleyiciyle gelir (adım 8, K-007).
  Önlem 2: .npmrc ve ajan izin listesinde npx kuralı; npm 12
  ve allowScripts ilk package.json'la. Önlem 10: check-eol.sh.
  Önlem 6'nın force push yasağı: ruleset-main.json.
- 7 Neon: prod betiği hazır, DUR; test kısmı K-010'u bekliyor.
  Ürün sahibinin çalıştıracağı: infra/owner/07-neon-prod-roles.sql
  (başındaki konsol adımları: Frankfurt, PG 18, 0,25–1 CU,
  geçmiş 7 gün, korumalı prod dalı, üç rol).
  Ek kontrol 2026-10-08: SQL yerel, ağsız bir PostgreSQL 17'de
  (Neon değil, ana sürüm 18 değil) koşuldu: hatasız; migrate
  tablo açtı, app yazdı ama tablo açamadı, backup okudu ama
  yazamadı; app'te 15s ve 30s zaman aşımları.
  Rehberin doğrulaması çalıştırılmadı: pooler üzerinden jsonb,
  bytea ve dizi testi (ilk API koduyla) ve son istekten ~6,5 dk
  sonra compute'un uyuması (Neon'un saatlik tüketimi).
  Önlem 6: prod dalı korumalı, ajana yalnız salt okunur rol.
  Önlem 7: test projesine tüketim kotası, test kurulunca.
- 8 Servisler ve hat: kısmen, DUR. Üretilen:
  infra/cloud-run/api.service.yaml (min 0, max 2, 512 MiB,
  1 vCPU, CPU boost, TCP startup 240 sn, GOMEMLIMIT=435MiB),
  infra/cloud-run/web.service.yaml (min 0, max 3, 1 GiB),
  infra/artifact-registry/cleanup.json, ürün sahibinin
  çalıştıracağı infra/owner/08-artifact-registry.sh (tek depo
  "kampus", tarama kapalı, temizlik önce dry-run).
  Yerel kontrol 2026-10-08: betik bash -n temiz, JSON geçerli,
  YAML okunuyor ve değerler K-011 ile aynı.
  Rehberin doğrulaması çalıştırılmadı: cleanupPolicyDryRun'ın
  boş ya da false olduğu (ürün sahibi betikten bir gün sonra)
  ve test push'unun kendi build hesabıyla SUCCESS olması.
  Başlamayan kısım: tetikleyiciler, cloudbuild*.yaml, build
  hesapları, deploy.md (K-007); '-test' servisleri (K-010);
  servislerin ilk açılışı (ilk digest gerekir).
- 9 Yetki ve sırlar: başlamadı (K-009 bekliyor); adımın kendisi
  de DUR (bütün komutlar ürün sahibinin kimliğiyle, sır değerini
  ürün sahibi yazar). Bekleyen önlemler: 5 (ajana roles/viewer'lı
  ayrı hesap, CLOUDSDK_ACTIVE_CONFIG_NAME) ve 2 (sır döndürme
  provası). Doğrulama: çalıştırılmadı.
- 10 Okuma yolu ve kapı: başlamadı. Ürün kodu iskeleti yok;
  Next ve Go iskeleti paket kurulumu ister, bu kuru çalışmada
  yasak (yerel Go 1.25.6, rehberin tabanı 1.27; build araç
  zinciri indirmeye kalkar). Depo düzeni de K-028'i bekliyor.
  Doğrulama ('db wake' yok, /.env 404, veritabanı kapalıyken
  /health 200) servis olmadan çalıştırılamaz.
- 11 E-posta: başlamadı, DUR. K-015 verildi ama alan adı
  (adım 5) ve sağlayıcı hesapları (Resend, SES; adım 3) yok.
  Ürün sahibi: iki hesabı açar, SES sandbox çıkış başvurusunu
  yapar, gönderim anahtarlarını sır yöneticisine yazar.
  Bekleyen önlemler: 8 (Türkçe İ ile e-posta normalleştirme,
  tek sunucu fonksiyonu ve lower(email) unique index) ve 22
  (bülten ticari ileti: İYS, K-018 bekliyor).
  Doğrulama: çalıştırılmadı.
- 12 KVKK: belge ve gizlilik metni taslağı yapıldı, DUR.
  docs/KVKK.md: veri yeri, işleyen listesi, aktarım dayanağı,
  süreler (bir kısmı KARAR BEKLİYOR), ihlal planı (önlem 9),
  hukukçu ve mali müşavir soruları (önlem 17, 18, 19, 22, 23,
  24, 25, 26), gizlilik metni taslağı.
  Doğrulama 2026-10-08: kod ve fatura henüz yok; yerine
  docs/ACCOUNTS.md'deki 11 sağlayıcının hepsi listede (grep).
  Ürün sahibi ve hukukçu: standart sözleşmeler, Kurum'a
  bildirim, metin. 15 yaş altı sorusu acil: yasa 2026-11-01.
- 13 Ücretli dış API: yok (K-016), adım atlandı.
- 14 Tasarım kaynağı: yapıldı; değerler yer tutucu.
  Üretilen: tokens/tokens.json (DTCG 2025.10), tokens/build.mjs,
  tokens/build/ (tokens.css, theme.ts, email.json), DESIGN.md
  (tablo üretiliyor), PRODUCT.md, scripts/count-hex.sh ve
  tokens/hex-baseline.txt (0). Koyu tema kararı K-014'te.
  Doğrulama 2026-10-08: "node tokens/build.mjs --check" çıkış 0,
  üretilen dört dosyada fark yok, 14 kontrast çiftinin hepsi
  AA'yı geçiyor; tokens.css elle değiştirilince FARK verip
  düştü. "scripts/count-hex.sh": 0, taban 0; bir .ts'e #ff0000
  eklenince çıkış 1. CI'a bağlanması tetikleyiciyle (K-007).
  theme.ts TypeScript derleyicisiyle denenmedi (tsc kurulu değil).
  Marka renkleri ve yazı ailesi KARAR BEKLİYOR.
- 15 Mobil iskelet: başlamadı, DUR. Bundle ID, paket adı ve
  şema K-001'i, depo K-028'i bekliyor; Expo iskeleti paket
  kurulumu ister (bu kuru çalışmada yok). Bulut build'i yalnız
  ürün sahibinin sözüyle; gün 0'da build yerelde alınır.
  Bekleyen önlemler: 11 (mağaza şartları takvimi), 20 (Team ID
  ve App Group tek değişkenden), 21 (başka sağlayıcıda ve başka
  alan adında yedek politika ve duyuru dosyası).
  Doğrulama (X-App-Build test API logunda, token'sız kod
  isteğinin reddi): çalıştırılmadı.

## Gün 0 kontrol listesi (aşama sonu, 2026-10-08)
İşaretli kutu: 0 / 12. Boş kutu varken akışların koduna
geçilmez.
- [ ] Faturalama hesabı, Neon org'u, bütçe, fatura dökümü,
  build hesapları, Editor'ün kaldırılması: betik hazır
  (adım 4), çalışmadı; build hesapları K-007, IAM K-009.
- [ ] Özel depo, gitleaks, push protection; ajan dosyasında
  deploy kuralı var; test → main K-007'yi, depo K-028'i bekliyor.
- [ ] 1 MB ve ikili kapısı, .gitignore desenleri, deploy
  kuralı: yerelde var ve denendi; CI'da yok (K-007).
- [ ] Alan adı, Cloudflare, SPF/DKIM/DMARC, Resend: alan adı yok.
- [ ] KVKK: belge var; standart sözleşme ve bildirim yok.
- [ ] Neon prod ve test, üç rol: prod betiği hazır; test K-010.
- [ ] Go (pool, /health, 401/503, /app job): kod yok.
- [ ] Next (standalone, kapı, başlıklar, CSP): kod yok.
- [ ] Next public değerleri çalışma anında: kod yok.
- [ ] Expo ve kit iskeleti: K-001, K-028, kod yok.
- [ ] Hat (digest, migrate --wait, onay, AR temizliği): AR
  betiği hazır; hat K-007.
- [ ] Turnstile, App Check, yedek e-posta: adım 11 bekliyor.

## Devam eden
- Gün 0 aşaması DUR noktalarında bekliyor; devir notu
  docs/handoff/2026-10-08.md.

## Bekleyen (dış etken ya da karar)
- Karar bekleyen dokuz soru: docs/TODO.md.
- Hesapların açılması (adım 3): ürün sahibi; K-002'den
  sonra. Mobil olduğu için D-U-N-S başvurusu gün 0'da.
- Alan adı (adım 5): ürün sahibi alır; ilk kullanıcıdan
  haftalar önce. Kategori başvurusu (FortiGuard, Trend
  Micro, Talos, Broadcom) aynı hafta, ürün sahibi gönderir.

## Bilinen sorunlar
- Yok.

## Sürümler. Son kontrol: 2026-10-08. Güncelleme günü: ayda bir, gün belirlenmedi (TODO).
Kaynak: rehberin 8 Ekim 2026 tablosu. Resmi sayfalar bu kuru
çalışmada yeniden okunmadı (ağ yok); ilk gerçek kurulumda okunur.
Desteğine 6 aydan az kalan satır TODO'ya P1 girer.
Denetim: scripts/check-eol.sh (60 günde uyarı, 6 ayda ret).
- Go 1.27.1: 1.29 çıkınca biter, tarih yok. go.mod'da go ve
  toolchain satırı sabit; imaj golang:1.27-alpine.
- Node.js 24.21.0 LTS: destek bitişi: 2028-04-30. Node 26,
  2026-10-28'de LTS olur; bu proje ondan önce açıldı. İmaj
  node:24-alpine.
- Next.js 16.4.0: destek bitişi: 2027-10-21. output standalone.
- PostgreSQL 18 (Neon): destek bitişi: 2030-11-14. Test, döküm
  imajı ve yerel aynı ana sürümde.
- pgx v5.11.0: Go'nun son iki sürümü, Postgres'in son 5 yılı;
  varsayılan bağlantı modu.
- Expo SDK 57 (React Native 0.86, React 19.2.3): tarih yok; yeni
  SDK'da bak. RN, React ve TypeScript mobilde Expo'nun
  sürümünde kalır.
- React 19.3.0 yalnız web'de: tarih yok; yeni sürümde bak.
- TypeScript 6.0.3: tarih yok (7.0.2 çıktı; typescript-eslint
  henüz desteklemiyor).
- npm 12 ve üstü (önlem 2): Dockerfile, CI ve EAS'ta sabit,
  her yerde npm --version ile doğrulanır; ilk kodla.
