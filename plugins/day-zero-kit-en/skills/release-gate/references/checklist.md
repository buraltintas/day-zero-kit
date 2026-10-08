<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="kontrol"></a>

Kontrol listesi

# Aşama aşama

Dört aşama, her biri kendi listesiyle. Kutular yeni projede işaretlenmek için boş. Sağdaki etiket kanıt düzeyidir: öneri, isteğe bağlı demek değildir; her kutu işaretlenir.

## Gün 0

- [ ] Kendi faturalama hesabı ve Neon org'u, üç eşikli bütçe uyarısı ve BigQuery faturalama dökümü; önce her tetikleyiciye kendi build hesabı, sonra compute hesabından Editor kaldırılır; rolsüz hesaplar; JSON anahtar yok, CI Actions'a taşınırsa WIF ile, anahtarsız.

[öneri]

- [ ] Private depo, gitleaks ve push protection; CLAUDE.md/AGENTS.md'de deploy kararı, test → main, tek deploy; birleşen dal silinir.

[kanıtlı]

- [ ] Yeni depo kuralları: 1 MB ve ikili dosya kapısı, .gitignore'da .env, *.jks, *.keystore, *.p8, *.p12 ve *.key, ajan dosyasında deploy kuralı.

[öneri]

- [ ] Alan adı haftalar önce alınır, güvenlik firmalarına kategori başvurusu yapılır; Cloudflare DNS; SPF/DKIM/DMARC; Resend AB, auth. ve news.; web Worker → run.app, api.* yalnız DNS ve gecikmesi ölçülür.

[öneri]

- [ ] KVKK: veri yeri, işleyen listesi, standart sözleşme ve 5 iş günü bildirimi.

[öneri]

- [ ] Neon: prod Launch (0,25–1 CU, aylık asgari ücret yok), test Free (en çok 0,25 CU); üç rol (uygulama DML, migration şema sahibi, salt okunur yedek) ve rol zaman aşımları.

[öneri]

- [ ] Go: tek pool fonksiyonu, pooler testi, severity, 30 sn bekleme, 401/503, veritabanısız /health, istemci adresi Kenar katmanındaki tabloya göre, veritabanında kod sınırları, `/app job`.

[kanıtlı]

- [ ] Next: standalone, font local, kapı (gün 0'da yalnız başka sitelerde gölgeden geçmiş ortak liste reddeder, gerisi gölgede başlar), başlıklar, CSP report-only, BFF, tazelik yolu.

[kanıtlı]

- [ ] Next'in public değerleri çalışma anında okunur; test'te doğrulanan imaj prod'a aynen terfi eder. Bizde bu değerler hâlâ build'e gömülü.

[öneri]

- [ ] Expo: CNG, New Arch, .env test'i gösterir, production host koruması; uzaktan kontrol kitinin iskeleti ilk commit'te (sürüm başlıkları, politika ucu, zorunlu güncelleme ekranı, push kaydı); duyuru alanı, ekran içi uyarı, bayrak ve kill switch ilk mağaza build'inden önce. OTA seçildiyse expo-updates ilk mağaza build'inde (öneri).

[kanıtlı]

- [ ] Hat: testler, digest, migrate --wait, onay, aynı digest; tek dağıtıcı Scheduler işi → Job, OAuth ile; AR'de live ve prev KEEP; test web'i IAP arkasında, test API'sinde giriş izin listeli; yenileme takvimi.

[öneri]

- [ ] Giriş kodu kotasına karşı: web'deki kod formunda Turnstile, mobil kod ucunda App Check (Play Integrity, App Attest), hazır bir yedek e-posta sağlayıcısı.

[öneri]

## İlk kullanıcıdan önce

- [ ] Alarmlar [TEST] ile denenir; Neon Free ve mail bütçesi alarmları eklenir.

[kanıtlı]

- [ ] Yedek, haftalık proje dışı kopya, tombstone adımı, soft delete kararı; bir elle geri yükleme.

[öneri]

- [ ] Okumalar bellek kopyasına, önce gölgede; bir gün sonra boş pencereler ve Neon saatlik tüketimi okunur.

[ölçüldü]

- [ ] Saklama sözleri işlere ve testlere bağlı; gerçek hesap silme; ücretli işlerde rakam ve tavan.

[kanıtlı]

- [ ] Kategori başvuruları ve kurum adreslerine deneme kod maili; WebKit dahil görsel tarama; terfi sonrası canonical curl.

[kanıtlı]

- [ ] Cloudflare prova host'u doğrulaması, Worker → run.app, 'Disallow AI Training', purge'lü cache; KVKK sözleşmeleri bildirilir, çerez onayı.

[öneri]

- [ ] Startup kredileri: ayrı faturalama hesabı ve Neon org'u açıldıktan sonra, ağır kullanım başlamadan başvurulur.

[öneri]

## İlk mağaza sürümünden önce

- [ ] Uzaktan kontrol kitinin OTA dışındaki 10 parçası ve yayın kapısı kanıtlı; kit yoksa mağaza sürümü yok. OTA önerilir; kurulacaksa ilk mağaza build'inde kurulur.

[öneri]

- [ ] Güncelleme ekranları gerçek telefonda; RevenueCat üç yol; push makbuzu.

[kanıtlı]

- [ ] İnceleme hesabı: prod'da izin listesindeki tek adres, sabit kod, en az yetki, kod sınırı ve her girişte log satırı.

[öneri]

- [ ] OTA geri alma provası; ortamı zorlayan betik; test API'ye bakan release build yerelde preview profiliyle alınır, hedef API logdan doğrulanır; TestFlight ve internal track'teki production build'de yalnız salt okunur duman kontrolü.

[öneri]

- [ ] Play hesabı şirket adına; kişisel açıldıysa 12 testçili 14 günlük kapalı test ilk sürümden en az 3 hafta önce başlar; uygulama içi silme; gizlilik etiketi ve Data safety her SDK için; phased release ve staged rollout.

[öneri]

- [ ] EAS kotası sayılır; build için ürün sahibinin açık sözü beklenir.

[kanıtlı]

## Her ay

- [ ] Fatura, Neon saatlik tüketim, uyanma, OOM ve ERROR sayıları.

[ölçüldü]

- [ ] Yedekler doğrulanmış mı, AR'de geri dönüş imajları var mı, service.yaml ile canlı eşit mi.

[kanıtlı]

- [ ] Yenileme takvimi önümüzdeki 60 gün; yeni SDK ya da işleyen geldiyse KVKK listesi ve mağaza etiketleri.

[öneri]

- [ ] Güvenlik duyuruları; bir projede kapatılan açık hepsinde kontrol edildi mi; update-policy mağazayla eşit mi.

[kanıtlı]
