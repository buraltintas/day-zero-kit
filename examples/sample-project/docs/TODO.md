# Yapılacaklar
Yalnız açık işler. Biten iş silinir,
CHANGELOG'a girer.
Satır: - [ ] [öncelik] iş. Sahip. Tarih. Bağlantı.
P0 canlı kırık (hemen), P1 bu hafta,
P2 sırada, P3 fikir.

## P0

## P1
Gün 0 kurulum planı (kod yazılmadan). Adım numaraları
rehberin "Ajanın kurulum planı"ndaki numaralardır.
- [ ] [P1] Adım 3: hesap envanteri (docs/ACCOUNTS.md),
  yenileme tablosu (docs/ALERTS.md). Sahip: ajan;
  hesapları ürün sahibi açar. 2026-10-08. K-002.
- [ ] [P1] Adım 4: infra/owner/04-billing-budget.sh'yi
  çalıştırmak, konsol adımları (faturalama hesabı, Neon
  org'ları, fatura dökümü, harcama tavanı, yedek kart),
  çıktıyı ajana vermek. Sahip: ürün sahibi. 2026-10-08.
  K-003, K-011.
- [ ] [P2] cost-check.md'ye harcama tavanını kaldırma
  adımı resmi sayfadan kopyalanır. Sahip: ajan. 2026-10-08.
- [ ] [P1] Adım 5: gerçek alan adını almak (şirket adına,
  en az iki yıl, otomatik yenileme, transfer kilidi, kayıt
  firmasında iki adımlı doğrulama), NS'yi Cloudflare'e
  vermek, dört güvenlik firmasına kategori başvurusu.
  Sahip: ürün sahibi. 2026-10-08. K-001, önlem 15.
- [ ] [P1] Adım 5 devamı: Cloudflare kayıtları (gri),
  Worker, domain mapping, dig ve whois doğrulaması.
  Sahip: ajan, alan adı alınınca. 2026-10-08.
- [ ] [P1] Adım 6, GitHub: infra/owner/06-github.sh'yi
  çalıştırmak (özel depolar, push protection, main kuralı),
  Renovate uygulamasını yetkilendirmek; sonra force push,
  silme ve fast-forward denemesi. Sahip: ürün sahibi.
  2026-10-08. K-028, K-007.
- [ ] [P1] Adım 6, gitleaks: geliştirici makinelerine ve CI
  imajına sabit sürümle kurulur; sahte anahtarlı commit'in
  reddi denenir. Sahip: ajan (kurulum onayıyla). 2026-10-08.
- [ ] [P2] Renovate'te RN, React ve TypeScript mobil depoda
  Expo'nun sürümünde dondurulur; güncellemeler test dalına
  (K-007, K-028 gelince). Sahip: ajan. 2026-10-08.
- [ ] [P1] Adım 7, prod: konsol adımları ve
  infra/owner/07-neon-prod-roles.sql; rol parolaları sır
  yöneticisine (K-009); çıktıyı ajana vermek. Sahip: ürün
  sahibi. 2026-10-08. K-005.
- [ ] [P1] Adım 7, test: Free org'da test projesi, aynı üç
  rol, tüketim kotası (önlem 7). Sahip: ajan, K-010 ve
  hesaplar gelince. 2026-10-08.
- [ ] [P1] Adım 7 doğrulaması: pooler üzerinden jsonb, bytea,
  dizi testi; compute'un ~6,5 dk sonra uyuduğunu saatlik
  tüketimde görmek. Sahip: ajan, ilk API koduyla. 2026-10-08.
- [ ] [P1] Adım 8: infra/owner/08-artifact-registry.sh'yi
  çalıştırmak; ertesi gün temizliği dry-run'sız uygulamak,
  describe çıktısını ajana vermek. Sahip: ürün sahibi.
  2026-10-08.
- [ ] [P1] Adım 8: tetikleyiciler (bölgesel, ^test$ ve ^main$
  onaylı), cloudbuild.test.yaml ve cloudbuild.main.yaml
  (sonunda logging: CLOUD_LOGGING_ONLY), build hesapları,
  docs/runbooks/deploy.md. Sahip: ajan yazar, ürün sahibi
  kurar. K-007 ve K-010'u bekliyor. 2026-10-08.
- [ ] [P1] Build hesabının rolleri: plan adım 8 "roles/run.admin"
  diyor, CI/CD katmanı "hiçbir build hesabı projede Cloud Run
  rolü taşımaz; test build hesabı yalnız '-test' servislerinde
  roles/run.developer" diyor. Ürün sahibine sorulacak; önerim
  kaynak düzeyindeki dar roller. 2026-10-08.
- [ ] [P1] Adım 9: yetki ve sırlar betiği (servis hesapları
  rolsüz, rol kaynakta, compute hesabından Editor tetikleyiciler
  kendi hesabına geçtikten sonra kalkar, ajana roles/viewer'lı
  hesap). Sahip: ajan yazar, ürün sahibi çalıştırır.
  K-009'u bekliyor. 2026-10-08. Önlem 2 ve 5.
- [ ] [P1] Adım 10: okuma yolu ve kapı (herkese açık okumalar
  API belleğinden ve GCS işaretiyle, veritabanısız /health,
  proxy.ts'in ilk satırında ortak listeli kapı, güvenlik
  başlıkları, CSP report-only). Sahip: ajan. K-028 ve ilk
  kod iskeleti gelince. 2026-10-08. K-023, K-017.
- [ ] [P1] Adım 11: Resend ve SES hesapları, SES sandbox
  çıkışı, anahtarlar sır yöneticisine. Sahip: ürün sahibi.
  2026-10-08. K-015.
- [ ] [P1] Adım 11 devamı: auth. ve news. alan adları, SPF,
  DKIM, DMARC; outbox; günlük ortak sayaç (70 uyarı, 80 toplu
  durur, kodlar 100'e kadar); Turnstile; App Check; SES yedeği
  denemesi. E-posta normalleştirme testi (önlem 8). Sahip: ajan,
  alan adı ve hesaplar gelince. 2026-10-08.
- [ ] [P1] Adım 12: işleyenlerle standart sözleşme, imzadan
  sonra 5 iş günü içinde Kurum'a bildirim, gizlilik metni.
  Sahip: ürün sahibi ve hukukçu. 2026-10-08. docs/KVKK.md.
- [ ] [P1] 15 yaş altı kapsamı (7578, 2026-11-01'de yürürlükte):
  hukukçuya sorulur; kapsamdaysa kayıtta doğum yılı. Sahip:
  ürün sahibi. 2026-10-08. Önlem 23.
- [ ] [P2] Adım 14 devamı: tasarım paketi gelince token
  değerleri, yazı ailesi (Türkçe glif denemesi her yüzeyde),
  docs/brand/README.md; CI'da build.mjs --check ve
  count-hex.sh (K-007'den sonra). Sahip: ajan. 2026-10-08.
- [ ] [P1] Adım 15: Expo SDK 57 iskeleti (CNG, New Arch),
  app.config'te bundle ID, paket adı, şema, açık stil; eas.json
  profil ortamları; kit iskeleti (sürüm başlıkları,
  update-policy, zorunlu güncelleme ekranı, push kaydı); yerel
  build yolu. Sahip: ajan, K-001 ve K-028 gelince. 2026-10-08.
  Önlem 11, 20, 21.
Adım 13 (ücretli dış API) yok: K-016.

## P2
- [ ] [P2] "İlk kullanıcıdan önce" aşaması (plan adım
  16–23). Gün 0 bitmeden başlamaz.
- [ ] [P2] "İlk mağaza sürümünden önce" aşaması (plan adım
  24–27; 28 OTA seçilmedi, K-026).

## Karar bekleyen (karar: ürün sahibi)
- [ ] K-001 kısmen: gerçek alan adı; iOS bundle ID, Android
  paket adı, uygulama şeması. Soruldu: 2026-10-08.
  Seçenekler ve önerim: DECISIONS K-001.
- [ ] K-002 Hesaplar kimin adına, kimler yönetir.
  Soruldu: 2026-10-08. Önerim: DECISIONS K-002.
- [ ] K-007 Dal modeli ve deploy kapısı. Soruldu:
  2026-10-08. Önerim: DECISIONS K-007.
- [ ] K-008 Ajanın onaysız işleri, ücretli iş eşiği.
  Soruldu: 2026-10-08. Önerim: DECISIONS K-008.
- [ ] K-009 Sırların yeri ve erişimi. Soruldu: 2026-10-08.
  Önerim: DECISIONS K-009.
- [ ] K-010 Test ortamı ve verisi. Soruldu: 2026-10-08.
  Önerim: DECISIONS K-010.
- [ ] K-012 Belge dili, iş panosu, sahip oturum. Soruldu:
  2026-10-08. Önerim: DECISIONS K-012.
- [ ] K-018 kısmen: AI özelliği, abonelik/satın alma, web
  satışı, ticari ileti (bülten), şahıs olarak gelir,
  konum işleme. Soruldu: 2026-10-08.
- [ ] K-028 Depo düzeni: tek depo ya da ayrı depolar.
  Soruldu: 2026-10-08. Önerim: DECISIONS K-028.
- [ ] K-011 uygulama değeri: API max-instances 2 mi 3 mü
  (rehber "2–3" diyor; service.yaml'da 2).
- [ ] K-014 içeriği: marka renkleri ve yazı ailesi
  (tasarım paketi). Token'lar şimdilik yer tutucu.
- [ ] K-019 içeriği: analitiğin cevaplayacağı beş soru.
- [ ] Maliyet onayı: özel depoda dal kuralı için GitHub
  Team (~$4/kişi/ay, rehber önlem 6) ve özel depoda push
  protection'ın ücretli sır koruma eklentisi isteyip
  istemediği (fiyat resmi sayfadan okunacak).
- [ ] Güncelleme günü: ayın hangi günü (rehber "ayda bir").
- [ ] K-021 içeriği: iki alıcının adı, e-postası, Google
  hesabı; acil kanal.

## Rafta (bilinçli yapılmayanlar)
- İçerik otomasyonu (K-027). Yeniden bak: ürün sahibi
  isterse.
- OTA (K-026). Yeniden bak: ilk mağaza build'inden önce.
