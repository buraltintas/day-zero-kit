<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="mimari"></a>

Mimari

# Parçalar ve akışlar

Ziyaretçi Cloudflare'den Next.js'e, Next.js API'ye, API Neon'a gider. Mobil uygulama API ile doğrudan konuşur. Zamanlanmış işler Scheduler'dan Job'a, Job'dan Neon'a ve yedek kovasına gider.

_Grafik: Mimari şeması_
Google CloudDış servisİstemciistekdeğişiklik işareti, 30 sn'de bir okunur

## Bileşenler

| Bileşen | Seçim | Görevi |
|---|---|---|
| DNS ve kenar | Cloudflare Free; kayıtlar başta gri. Web host'ları doğrulamadan sonra Worker → *.run.app ile turuncu buluta alınır; api.* yalnız DNS (gri). | Botları ve tekrar eden GET'leri Cloud Run'a ve Neon'a ulaşmadan karşılar. |
| Alan adı bağlantısı | Varsayılan: web host'ları Cloudflare Worker → *.run.app ($0; günde ~80.000 istekten önce $5/ay), api.* domain mapping ($0, Preview). Global ALB (~$18/ay) yalnız Cloud Armor ya da çok bölge gerekince. | Google domain mapping'i gecikme yüzünden production için önermiyor; bu yüzden yalnız api.*'de ve gecikmesi ölçülerek. İstemci adresi yola göre okunur ([Kenar, DNS ve alan adı](#katman-5)). |
| Web | Next.js 16 standalone, Cloud Run europe-west1, min 0, max 3, 1 GiB. | Herkese açık sayfalar SSR/ISR; oturumlu bölüm /app altında; tarayıcı yalnız aynı kökenli BFF'yi çağırır. |
| API | Go, pgx v5, slog, distroless; Cloud Run min 0, CPU boost, max 2–3. | Tek yazma noktası; herkese açık okumalar bellekten; /health ve /v1/app/update-policy veritabanısız. |
| Zamanlanmış işler | Tek Scheduler işi OAuth token ile POST run.googleapis.com/v2/projects/P/locations/R/jobs/J:run. Dağıtıcı job uygulamanın imajıyla kodda yazılı takvimi yürütür; ayrı imajlı yedek job'ını API'den çalıştırıp bekler. | Rapor, okuma, yedek, migration; retry ve zaman aşımı job'da, hata exit≠0. |
| Veritabanı | Neon aws-eu-central-1; prod Launch (min 0,25, max 1 CU), test Free (en çok 0,25 CU). | Uygulama pooled adres ve DML rolüyle; migration şema sahibi rolle, yedek salt okunur rolle, ikisi de direct adresten. |
| Değişiklik işareti | GCS'te tek JSON, ifGenerationMatch ile yazılır. İşaret hiçbir yazmayı düşürmez. Yazılamayan haber bellekte tutulur. Sonraki yazmayla, sonraki kontrolle ya da SIGTERM'de yeniden yazılır [kanıtlı]. Kontrol herkese açık bir okuma isteğinin içinde yapılır. Instance başına 30 sn'de en çok bir kez çalışır ve en çok 1 sn bekler. Okunamazsa atlanır ve kopyalar kendi en uzun yaşına döner, bizde 6 saat [kanıtlı]. Bozuk ya da silinmiş işaret görülünce o instance her şeyi düşürür [kanıtlı]. GCS aynı nesneye saniyede ~1 yazma alır, fazlasına 429 döner. 429'da 0,5–1 sn beklenip yeniden denenir. Bu yazmaya en çok 2 sn ekler [kanıtlı]. Yazma hızı sürekli bunu geçerse işaret konuya göre birkaç nesneye bölünür [öneri]. Başarısız yazma ve kontrol sayılır, art arda düşerse alarm verir [öneri]. | Bütün instance'lardaki kopyaları ~30 sn'de düşürür; ~$0,04/ay. |
| Depolama ve sırlar | Medya (legacyObjectReader), belge (PAP), yedek (PAP, retention) kovaları; haftalık kopya ayrı projede; Secret Manager, JSON anahtar yok. | Belge yalnız sahiplik kontrollü API indirmesiyle. |
| E-posta | Resend eu-west-1; auth. ve news. alt alan adları; SPF, DKIM, DMARC, BIMI. | Kodlar ve işlem mailleri outbox'tan ve gönderim bütçesinden geçer: yazan istek commit'ten sonra gönderir, sabah job'ı kalanı süpürür. |
| Mobil | Expo CNG, New Arch, EAS Build/Submit/Update, RevenueCat, Expo Push. | Sürüm başlıkları; özellikler ve zorunlu güncelleme sunucudan. |
| Gözlem ve CI/CD | Logging, Monitoring, Error Reporting, uptime check, birinci taraf /v1/client-errors; bölgesel Cloud Build ve aynı bölgede AR. | Alarmlar ilk gün; testler ve migration deploy'dan önce. |
| Test ortamı | Prod ile aynı projede '-test' servisleri, ayrı servis hesapları ve sırlar, ayrı Neon (Free), en fazla 1 instance. Web IAP arkasında; API ağda açık, girişi izin listeli ve noindex. | Prod'un şeklini taşır, prod'a ulaşamaz; ücretli anahtarları tavanlıdır. |

[öneri]
** Kaynak adları gün 0'da bir kez seçilir**. Ajan ad uydurmaz. Aşağıdaki kalıbı DECISIONS'a bir karar olarak yazar. Cloudbuild dosyaları ve runbook'lar yalnız bu adları kullanır. Test kopyası her yerde adın sonuna '-test' alır.
GCP projesi: 6–30 karakterlik bir kimlik, ör. `<product>-app`; sonradan değişmez. Servisler: api, web, api-test, web-test. Job'lar `<servis>-migrate` kalıbıyla: api-migrate, api-test-migrate. Dağıtıcı: dispatch, dispatch-test. Yedek: backup, yalnız prod'da. Servis hesapları da 6–30 karakter olmalıdır: run-api, run-web, run-api-test, run-web-test, build-test, build-main, run-backup, scheduler. Sırlar `<servis>-<ad>` kalıbıyla, ör. api-database-url ve api-test-database-url. Artifact Registry'de tek depo vardır: app, europe-west1'de. Kova adları dünya çapında tek olduğu için proje kimliğiyle başlar: `<proje>-media`, `<proje>-docs`, `<proje>-backup`, `<proje>-flags`. Test kovaları aynı adın sonuna -test alır, ör. `<proje>-flags-test`. Neon'da iki proje vardır: `<product>-prod` Launch org'unda, `<product>-test` Free org'unda. Roller: app_rw (DML), app_migrate (şema sahibi), app_backup (salt okunur).

## Akışlar

1. **Ziyaretçi** →Cloudflare (WAF; HTML önbelleği yalnız purge bağlıysa)→Worker→Next (bot kapısı, ISR, işaret kontrolü)→API (bellek)→Neon yalnız kopya yenilenirken

2. **Oturumlu kullanıcı** →Cloudflare (bypass)→Next BFF (HttpOnly çerez)→API (X-Client-IP + iç anahtar)→Neon pooled

3. **Mobil** →api.*→API; her istekte sürüm, build, platform ve kanal başlığı; update-policy bellekten

4. **Yazma** →Neon transaction (outbox, tombstone)→GCS işareti→API instance'ları 30 sn'de bir okur→Next proxy'si loopback route ile revalidateTag çalıştırır→kenarda değişen URL'ler purge edilir

5. **Scheduler (OAuth, .../jobs/J:run)** →Job→Neon; veritabanı işleri tek 10 dakikalık pencerede; hata→alarm

6. **test push** →vet, test, govulncheck, Docker build→digest→migrate --wait→test servisi; main→onay→aynı digest→migrate --wait→candidate smoke→trafik→live/prev etiketi

7. **Yedek** →pg_dump→geçici Postgres'e geri yükleme kontrolü→PAP kova→haftalık proje dışı kopya; geri yüklemeden sonra tombstone'lar uygulanır
