<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="katmanlar"></a>

Katman 1 / 11

# Postgres (Neon + pgx)

Neon ancak 5 dakika hiç bağlantı olmazsa uyur. Bu katmanın ayarları veritabanını uyutabilmek ve pooler üzerinden güvenle konuşmak içindir.

33,41 CU-saat
18–23 Eyl'de ticker'lar ve gece tarayıcıları yüzünden 7/24 uyanık kalan bir veritabanının tüketimi.

## Yap

[ölçüldü]
** Planı proje doğarken seç**: gerçek kullanıcılı prod Launch'ta, test ve gerçek kullanıcısı olmayan yan projeler Free org'da. Launch'ta aylık asgari ücret yok: kullanıcı gelmeden neredeyse ₺0, az trafikli üründe ayda ~₺50–80 (CU-saat başına ~₺5,2). Neon bir projeyi alt plandaki bir org'a kendisi taşımaz; sonradan taşımak döküm, geri yükleme ve bağlantı adresi değişikliği demektir.
[kanıtlı]
** Pool tek bir fonksiyonda yaratılır**; API, migrate, araçlar ve testler onu çağırır.
[kanıtlı]
** Uygulama adında -pooler geçen adrese pgx varsayılan moduyla bağlanır** (bir projemizin prod'unda doğrulandı, iki projede yapılandırma aynı); ilk gün pooler üzerinden jsonb, bytea ve dizi testi.
[öneri]
** Pooler transaction modunda oturum advisory lock, SET/RESET, LISTEN/NOTIFY ve SQL PREPARE çalışmaz**; kilit işle aynı transaction'da pg_advisory_xact_lock(hashtext(...)) ile alınır ve yarış testi yazılır.
[öneri]
** Uygulama rolüne ALTER ROLE ile statement_timeout ve idle_in_transaction_session_timeout verilir**; sızan transaction'ı MaxConnIdleTime kapatmaz ve veritabanı uyumaz.
[öneri]
** Compute min 0,25, max 1 CU**; max en kötü faturayı da belirler (1 CU'da 7/24 ~$76/ay).
[kanıtlı]
** Zamanlayıcıyla soran goroutine yok**; işi doğuran kod zamanını kurar; bakım yalnız trafik veritabanını uyandırmışken çalışır.
[ölçüldü]
** Herkese açık okumalar tek yükleme zinciriyle belleğe**; set tamsa bilinmeyen slug 404'ü de bellekten; her yazan yol (API, job ve betik) GCS işaretini aynı yazma kodundan günceller.
[öneri]
** Canlıda elle SQL yalnız olay anında ve runbook'la yapılır**; SQL işareti kendisi güncelleyemez, bu yüzden runbook'un son adımı işareti güncelleyen kayıtlı komuttur.
[öneri]
** Üç rol**: uygulama yalnız DML yetkili rolle pooled adresten, migration şemanın sahibi rolle direct adresten, yedek salt okunur rolle direct adresten bağlanır.
[kanıtlı]
** Her ortamda aynı PG ana sürümü**; SELECT * yazılmaz; her uyanış 'db wake' olarak nedeniyle loglanır.

## Başlangıç ayarları

[kanıtlı]
` MinConns=0`, `MaxConnIdleTime=90s` (pgx varsayılanı 30 dk), kodda sabit ve testle kilitli.
[öneri]
` MaxConns` da kodda açıkça yazılır, 1 vCPU'da ör. 10. Yazılmazsa pgx 4 bağlantı açar (4 ya da CPU sayısı, hangisi büyükse); Cloud Run ise bir instance'a aynı anda 80 istek verir ve birkaç yavaş sorgu havuzu tıkar. Havuzdan bağlantı isteğin bağlamıyla alınır. Bekleme ölçülen en uzun uyanıştan (5,2 sn) uzun, WriteTimeout'tan (10 sn) kısa tutulur, ör. 8 sn. `MaxConns` × max-instances ile job'ların bağlantılarının toplamı Neon pooler sınırının çok altında kalır. Boştaki bağlantıyı pgx dakikada bir yaptığı kontrolde kapatır; bu yüzden uyku son istekten 6,5 ile 7,5 dk sonra başlar.
[kanıtlı]
Exec mode varsayılan (PgBouncer max_prepared_statements=1000); sorun olursa DescribeExec, SimpleProtocol asla.
[kanıtlı]
Migration ve yedek direct host; transaction içinde `SET LOCAL lock_timeout='5s'`.
[öneri]
statement_timeout 15 sn, idle_in_transaction_session_timeout 30 sn.
[öneri]
Free: proje başına ayda 100 CU-saat, 6 saat geçmiş, 5 GB çıkış; aşılınca ay sonuna kadar durur, uyarı yok. Uyanma bütçesi: veritabanına giden bir yenileme ya birkaç saatte bir ya da yalnız değişiklik işaretiyle çalışır. Her uyanış en az ~6,5 dk sürer (havuzun 90 sn'si ve Neon'un 5 dakikası). 6,5 dakikadan sık bir yenileme veritabanını hiç uyutmaz; 15 dakikalık aralık bile zamanın ~%43'ünde uyanık tutar. Günde ~74 uyanış ayda ~₺190 ekledi.

### Kaçın

[kanıtlı]
'Pooler için' SimpleProtocol: []byte jsonb'ye bytea gider, pgx SQL injection açığı ulaşılabilir olur.
[kanıtlı]
MinConns>0 ya da MinConns = MaxIdleConns; ticker'la yoklama; /health'te ping.
[kanıtlı]
Önünde uygulayan katman yokken Cache-Control yazıp her istekte toplamak; SQL'de '||' ile tip tahmini.
[öneri]
Pooled bağlantıda pg_advisory_lock; LISTEN/NOTIFY ile instance eşitlemek.

### Bizdekinden iyisi

[kanıtlı]
SimpleProtocol'den varsayılan moda geçerken SELECT * kaldırılır, eski revizyon trafik alırken test ortamında migration denenir ('cached plan must not change result type') ve p50/p90 ölçülür.
[öneri]
Bölge seçilmeden önce gecikme etkisi ölçülür; europe-west3 Tier 2'dir ve domain mapping vermez.
[öneri]
Supabase Pro $25/ay'dan ve uyumuyor (7 gün PITR +$100); Cloud SQL db-f1-micro ~$8. Günde ≥6 CU-saat ve >1 GB RAM sürekli olursa karşılaştırılır.

### Nereden öğrendik projelerimizden, 2026

**18–23 Eyl** ticker'lar ve gece crawler'ları 33,41 CU-saat yazdırdı (günde ~6,2, 7/24 uyanık); düzeltmeden sonra günde ~3,2 (4–7 Eki ortalaması 3,18).
**5–6 Eki** 300 sn'lik revalidate günde ~74 uyanma, ayda +₺190 yazdı; 'db wake' logu bir günde buldu.
**2–23 Eyl** SimpleProtocol yüzünden ödeme webhook'u her teslimde 500 döndü; 29 Eyl'de -pooler lock_timeout başlangıç parametresini reddetti.

Katman 2 / 11

# Go API

API tek yazma noktasıdır. Geçici bir hata kimseyi oturumdan atmaz, başarısız iş sessiz kalmaz.

~%1–1,5
Uyuyan Neon'a denk gelip 503 alan soğuk başlangıç payı. 30 sn beklemeden sonra 17 açılışta sorun çıkmadı.

## Yap

[kanıtlı]
** Dinleyici hemen açılır, pool tembel kurulur, veritabanı ikiye katlanan aralarla ~30 sn beklenir**; açılış hatasına log alarmı.
[kanıtlı]
** 401 yalnız token yok/geçersiz, kullanıcı pasif ya da kod yanlışsa**; veritabanı ve dış servis hatası 503; bu sözleşme testlidir.
[öneri]
** 503 ve 429 Retry-After taşır**.
[öneri]
** slog ReplaceAttr**: level→severity, WARN→WARNING, msg→message. (Ölçülen: 14 günde 18 ERROR satırının severity alanı boştu.)
[kanıtlı]
** Toplu iş handler'da ya da yanıt sonrası goroutine'de yapılmaz**; `/app job <ad>` olur; yanıttan sonra bitmesi gereken iş outbox'a girer (nasıl boşaldığı [E-posta katmanında](#katman-9)); SIGTERM'deki son yazma GCS'e park edilir.
[kanıtlı]
** Başarısız iş non-2xx ya da exit≠0**; (iş, dönem) anahtarıyla idempotent.
[kanıtlı]
** Webhook önce ham gövdeyi kaydeder**; her non-2xx loglanır; sağlayıcıdan çeken TTL'li mutabakat vardır.
[kanıtlı]
** Config tehlikeli kombinasyonlarda açılmaz** (izin listesi dışında sabit kod + production, allowlist'siz SMTP); değerler trim'lenir.
[öneri]
** Mağaza incelemesi tek istisnadır**: prod'da izin listesindeki tek bir inceleme adresi sabit kodla girer; hesap en az yetkilidir, kod sınırlarına tabidir ve her girişi bir log satırı yazar.
[kanıtlı]
** Özellikler veritabanısız /v1/app/update-policy ile**; sözleşme değişince yeni anahtar adı; geri dönüş anahtarla.
[kanıtlı]
** İstemci IP'si [Kenar katmanındaki adres tablosuna](#adres) göre okunur**: doğrudan gelen istekte X-Forwarded-For'un en sağ elemanı, BFF'den gelende iç anahtarla doğrulanan X-Client-IP. Giriş kodu sınırları veritabanında: adres başına saatte 8, IP başına saatte 40, 60 sn; sabit kodlar da sayaca tabi.
[öneri]
** Kod isteği, sayaç kontrolüyle aynı transaction'da adres başına pg_advisory_xact_lock altında yazılır**; paralel istekler sınırı aşamaz.
[öneri]
** Gönderim sayacı UTC gününe göre ortaktır**: 70'te uyarı, günün toplamı 80'e varınca toplu gönderim durur, giriş kodları 100'e kadar gider; 100 dolarsa kodlar yedek sağlayıcıdan.
[öneri]
** Para tavanı veritabanında pg_advisory_xact_lock altında 'requested' satırıyla**; sağlayıcıda sert bütçe; olmuyorsa en kötü durum max-instances ile çarpılır.
[kanıtlı]
** Hesap silme gerçek silmedir** (DELETE); kayıt arşive taşınmaz.
[öneri]
** Silme, kişisel veri taşımayan bir tombstone bırakır** (tablo, kayıt kimliği, silinme zamanı); yedekten geri yüklemenin son adımı bu silmeleri yeniden uygular. Silme commit olunca aynı iz bir log satırı olarak 400 gün saklanan log kovasına da yazılır. Neon kaybolursa tablodaki iz de gider. Dökümdeki iz ise yalnız dökümden önceki silmeleri taşır, onlar zaten dökümde yoktur. Varsayılan log kovası 30 gün tutar, bu da yedeğin en uzun ömründen (bizde 37 gün) kısadır.
[kanıtlı]
** Herkese açık toplamlar her grupta en az 10 farklı kurulumla yayınlanır** (bizde başta 20 idi). Ayrıntı [Analitik ve admin](#analitik) bölümünde.
[öneri]
** Geliştirme ve test kurulumları bu sayıma girmez**.

## Başlangıç ayarları

[kanıtlı]
WriteTimeout 10 sn; startup probe TCP 240 sn; genel tavan 600/dk/IP; max-instances 2–3.
[öneri]
Kabul edilen canlı kod sayısı saatlik tavana eşittir (8); 60 sn'lik tekrar gönderiden sonra gecikerek gelen ilk kod da geçer.
[kanıtlı]
Scheduler → Job: oauthToken (cloud-platform), tetikleyen hesaba yalnız o job'da roles/run.invoker; OIDC yalnız servis URL'sine.
[kanıtlı]
Retry 2 kez, 60–300 sn, yalnız idempotent işte; SIGTERM sonrası boşaltma ≤4 sn, son yazma ≤5 sn.

### Kaçın

[kanıtlı]
Her veritabanı hatasını 401'e çevirmek; açılışta 5 sn ping + os.Exit(1).
[kanıtlı]
Fan-out'u r.Context()'e ya da kısılan CPU'da yanıt sonrası goroutine'e bağlamak; işi WARN + 204 ile yutmak.
[ölçüldü]
Kod ucunu yalnız instance başına 30/dk/IP ile korumak: tek IP günlük 100 maili ~4 dakikada bitirir.
[kanıtlı]
X-Forwarded-For'un ilk elemanı; mobil pakete gömülü ortak sırla iş uçları; status='deleted' ile silme.

### Nereden öğrendik projelerimizden, 2026

**6 Eyl** soğuk başlangıç uyuyan Neon'a denk gelip 503 verdi (~%1–1,5); 30 sn bekleme sonrası 17 açılışta sorun yok.
**27 Eyl** ara sertifika göndermeyen bir dış siteyi okuyan günlük iş her sabah düştü ama 204 döndü. Bu yüzden yeniden deneme de çalışmadı; hata beş gün sonra bir etki kontrolünde görüldü. Go eksik ara sertifikayı kendisi tamamlamıyor.
**28 Eyl** 21 giriş kodu isteğinin hepsi aynı IP hash'iyle sayıldı; adres yanlış okunursa tek kişi bütün girişleri kilitleyebilir.

Katman 3 / 11

# Next.js web

Herkese açık her sayfa sunucuda tam HTML olarak çıkar; oturumlu bölüm aynı uygulamada /app altında durur.

116 sayfa
Sayfalar sunucuda render edilince OAI-SearchBot'un ~11,7 günde taradığı sayfa. SPA'nın HTML gövdesi boştu.

## Yap

[kanıtlı]
** Herkese açık her sayfa sunucuda tam HTML**; oturumlu bölüm aynı uygulamada /app altında; iki uygulama yol bazında proxy'lenmez.
[ölçüldü]
** next/font/local**; build backend'den veri okumaz; büyük sitemap gzip'li.
[kanıtlı]
** notFound() yalnız backend 404'ünde**; 5xx fırlatılır ki sağlam kopya kalsın; ISR x-nextjs-cache: HIT ile doğrulanır; [slug]'a boş generateStaticParams.
[kanıtlı]
** Proxy'de istek başlığı yazılmaz**; dil yoldan; dil çerezi yalnız kullanıcı seçince; kök yönlendirme 307 ve kenarda bypass.
[kanıtlı]
** Çok instance'ta ISR**: proxy.ts instance başına 30 sn'de bir GCS işaretini okur, değişiklikte aynı instance'taki sırla korunan loopback route revalidateTag çalıştırır, 45 sn ve 5 dk sonra tekrar; zamanlayıcı yok, okuma hatası yakalanır.
[öneri]
** Next 16'da çağrı `revalidateTag(tag, { expire: 0 })` olur**. Tek argümanlı kullanım eskidi. Uyarının önerdiği 'max' profili değişiklikten sonraki ilk isteğe bayat kopyayı verir ve 3.7'yi bozar. updateTag yalnız Server Action içinde çalışır, route'ta hata verir.
[öneri]
**'use cache' kullanılırsa aynı iş cacheHandlers.default içindeki refreshTags'tedir**; her istekte çağrılır ve hatası isteği düşürür, bu yüzden 30 sn kısıtlı ve try/catch'li olur. cacheHandlers yalnız 'use cache' içindir; route ISR tekil cacheHandler kullanır.
[öneri]
** deploymentId tanımlanır**.
[kanıtlı]
** BFF**: HttpOnly, Secure, SameSite=Lax çerez; tek yerde single-flight yenileme; çıkışta sunucuda iptal; same-origin kontrolü.
[kanıtlı]
**'use server' export'ları herkese açıktır**; ?next= yalnız site içi; JSON-LD'de '<' kaçırılır; proxy yolları encode edilir.
[kanıtlı]
** Güvenlik başlıkları ilk gün**; CSP report-only ve origin'ler API'den türetilir; ortama göre değişen her şey çalışma anında okunur.
[öneri]
** Terfi eden imajda ortama özel değer yoktur**: public değerler çalışma anında okunur (tarif [Artifact Registry](#registry) bölümünde); canonical, og:url ve sitemap istek anında; terfi sonrası curl ile kontrol.
[kanıtlı]
** noindex X-Robots-Tag ile**; test kopyası host'tan tanır; standalone'da HOSTNAME=0.0.0.0 ve static kopyası; her sayfa 1280, 900, 375 px ve WebKit'te ölçülür.

## Başlangıç ayarları

[kanıtlı]
` output 'standalone'`, `poweredByHeader false`; Next 16 güncel yama.
[ölçüldü]
1 GiB ve OOM alarmı (512 MiB'ta bot trafiği altında 7 günde 540 bellek aşımı oldu); görseller yüklemede boyutlandırılır. Proxy'nin dil yönlendirmesi /api'ye dokunmaz, kapı /api aktarma uçlarında da çalışır.
[ölçüldü]
Katalog günlük ISR + değişiklik işareti; veritabanına giden revalidate birkaç saatte bir ya da yalnız işaretle (6,5 dk'dan sık yenileme veritabanını hiç uyutmaz; 15 dk bile ~%43 uyanık tutar).

### Kaçın

[kanıtlı]
Tanımsız proxy hedefinde kendi host'una düşmek; next/font/google; hatayı boş liste ya da 404 olarak önbelleğe sokmak.
[kanıtlı]
Token'ı proxy ve tarayıcıda birlikte yenilemek; CSP origin'lerini sabit yazmak.
[öneri]
Route ISR'ı refreshTags'e bağlamak; refreshTags'te kısıtsız ve try/catch'siz GCS okumak.
[ölçüldü]
Çerezsiz her isteğe dil çerezi yazan proxy.

### Bizdekinden iyisi

[kanıtlı]
Proxy + loopback düzeni bir projemizde yorumun görünmesini bir günden ~1 dakikanın altına indirdi.
[öneri]
Test'te doğrulanan tek imaj prod'a terfi eder; public değerler build'e gömülmez, çalışma anında okunur. Vercel Pro $20/ay + Active CPU; Workers/OpenNext Node proxy'yi desteklemiyor.

### Nereden öğrendik projelerimizden, 2026

**18 Eyl** SPA'nın HTML gövdesi boştu; Next'e geçince OAI-SearchBot ~11,7 günde 116 sayfa taradı.
**29 Eyl–7 Eki** 68 web build'inin 7'si (~%10) next/font hatasıyla düştü. 18–19 Eyl: yutulan okuma hatası site haritasından 2.668 sayfa düşürdü, 16 saat deploy çıkmadı.
**22–23 Eyl** CSP img-src API'yi içermiyordu, logolar bir gece kırık kaldı. 4 Eki: işaret okumasında zaman aşımı görüldü.

Katman 4 / 11

# React Native (Expo) mobil

Uzaktan kontrol kiti ilk mağaza sürümünde hazır olur; kit kurulmadan uygulama yayınlanmaz, sonradan eklenen kanal eski build'lere ulaşmaz.

3 build
Boş gelen versionCode yüzünden güncelleme uyarısını hiç gösteremeyecek Android build'i.

Ayrıntı
Bu katmanın iki eki katmanın hemen ardından gelir: [Mobil uzaktan kontrol kiti](#mobilkit) (mağazaya çıkmadan önce kurulacak 11 parça ve yayın kapısı; OTA dışında hepsi şart) ve [Mobil build ve dağıtım](#dagitim) (EAS mi, kendi hattımız mı).

## Yap

[kanıtlı]
** CNG, config plugin ve ilk günden New Arch**; her native SDK New Arch'lı release build'de denenir.
[öneri]
** İlk mağaza build'inden expo-updates**: fingerprint, production/preview kanalı, %10'dan %100'e yayın, hazır geri alma. OTA kitte önerilir, zorunlu değildir; kurulursa her OTA yayını ürün sahibinin kararıdır.
[kanıtlı]
** İlk sürümde kapatılabilir 'yeni sürüm var' sayfası, tam ekran zorunlu güncelleme ve nativeBuildVersion karşılaştırması**; politika veritabanısız uçta.
[kanıtlı]
** Her istek sürüm, build, platform ve kanal başlığı taşır**; dev build test API'sine gider, prod adresi yalnız EAS production env'inde.
[öneri]
** Production kanalında API host'u prod değilse uygulama açılmaz ve ERROR yazar**; eas update ve yerel build yalnız --environment production'ı zorlayan betikle; yerel build 'Secret' EAS değişkenlerini okumaz; submit öncesi hedef API logdan doğrulanır.
[öneri]
** Binary de kademeli**: App Store phased release (7 gün, durdurulabilir), Play staged rollout.
[öneri]
** Uygulama içi hesap silme** (Apple 5.1.1(v)) ve Play için web silme adresi.
[öneri]
** Her yeni SDK'dan önce App Store gizlilik etiketi, Play Data safety ve gizlilik metni güncellenir**.
[kanıtlı]
** Release build gerçek telefonda listeyle denenir**; sesli komut ve widget hedef dilde, TestFlight'tan geçerek.
[kanıtlı]
** Abonelik üç yoldan**: SDK, 10 dk TTL'li sunucu mutabakatı, webhook. Yeni yüzeyler sunucu anahtarı arkasında kapalı gider.
[kanıtlı]
** Push makbuzu 15 dk'lık alarmla okunur, ölü token silinir, FCM için yalnız FCM rolü olan hesap**.
[öneri]
** Play'de yeni kişisel hesap için 12 testçinin son 14 gün kesintisiz katıldığı kapalı test gerekir**; target SDK 36, 16 KB hizalama, yalnız 64-bit.

## Başlangıç ayarları

[öneri]
New Arch SDK 55'ten beri tek seçenek. newArchEnabled yazılmaz, SDK 57 bu ayarı yok sayar. OTA kurulacaksa runtimeVersion { policy: 'fingerprint' } ilk mağaza build'inde yazılır.
[kanıtlı]
appVersionSource 'remote', autoIncrement; numaralar eas build:list'ten.
[kanıtlı]
Zaman aşımları: depolama 2,5 sn, update-policy 5 sn + son bilinen değer, onay formu 6 sn; oturum yalnız refresh 401'inde kapanır.
[ölçüldü]
EAS Free: 15 iOS + 15 Android build ayrı sayılır; 3 dakikadan sonra düşen build de hak yer; OTA ayda 1.000 MAU'ya kadar ücretsiz, üstünde Starter $19.

### Kaçın

[kanıtlı]
Özelliğe mock'lu testle 'çalışıyor' demek; hedef API'yi paket grep'iyle doğrulamak; build numarasını depodan okumak.
[kanıtlı]
Zorunlu güncellemeyi sonradan eklemek; eski build'ler hiç zorlanamaz.
[kanıtlı]
Binary'yi herkese birden açmak; bir sesli komut hatası ve hiç çıkmayan bir güncelleme uyarısı herkese aynı anda ulaştı.

### Bizdekinden iyisi

[ölçüldü]
OTA ilk sürümde hazırsa küçük düzeltme mağaza sürümü harcamaz: OTA'sız bir uygulamanın 19 Eylül–7 Ekim'deki 19 mağaza build'inin 11'i yalnız JS idi ve iOS kotası 22 Eylül'de doldu. Kota bitince `eas build --local`; acil düzeltmede Starter $19/ay.
[kanıtlı]
CNG'li uygulama SDK 57'ye çıktı; native klasörleri depoya alıp New Arch'ı kapatan iki uygulama SDK 54'te kaldı.
[öneri]
Çökme telemetrisi önce birinci taraf ucu; Sentry EU ancak KVKK adımlarından sonra.

### Nereden öğrendik projelerimizden, 2026

**18 Eyl** boş gelen versionCode yüzünden üç Android build'i güncelleme uyarısını hiç gösteremeyecek.
**24 ve 26 Eyl** Expo 54'te .env Metro ortamını ezdi, simülatör prod'a yazdı. 2–3 Eki: TestFlight atlanan sesli komut özelliği iki ekstra build harcattı.
**4–5 Eki** Play, 4 KB hizalı kütüphaneler ve AD_ID yüzünden reddetti; üretim erişimi düşük kapalı test kullanımı yüzünden bir kez reddedildi.
