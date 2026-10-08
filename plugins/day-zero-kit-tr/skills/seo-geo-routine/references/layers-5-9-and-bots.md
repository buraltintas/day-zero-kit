<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="katmanlar-2"></a>

Katman 5 / 11

# Kenar, DNS ve alan adı

DNS ilk günden Cloudflare'de durur. Varsayılan bağlantı: web Worker üzerinden run.app'e, api.* domain mapping ile. İstemci adresi bu yola göre okunur.

~20 dk
Domain mapping geçişinde yaşanan HTTPS kopukluğu.

## Yap

[öneri]
** DNS ilk günden Cloudflare Free'de, kayıtlar başta gri**.
[öneri]
** Varsayılan bağlantı**: web host'ları Cloudflare Worker → *.run.app ile turuncu bulutta, api.* domain mapping ile yalnız DNS (gri). Google domain mapping'i Preview sayıyor ve gecikme yüzünden production için önermiyor (europe-west1'de var, europe-west3'te yok); bizde api.*'de prod'da çalışıyor, gecikmesi ölçülür. Worker günde 100.000 isteğe kadar ücretsiz; Worker yönlendirici olduğu için fail open kurtarmaz (atlanan istek boş yer tutucu kökene gider), günde ~80.000'e varmadan Workers Paid ($5/ay). Global external ALB (~$18/ay + veri) yalnız Cloud Armor ya da çok bölge gerekince; Firebase Hosting yalnız __session çerezini geçirdiği için yok.
[öneri]
** Turuncu bulutta domain mapping kullanılmaz**: 'Always Use HTTPS' sertifika doğrulamasını bozabiliyor, yenileme 60–90 günde bir olduğu için sorun aylar sonra çıkar. Bu host'lar Worker'la run.app'e gider; uygulama canonical'ı SITE_URL'den kurar.
[öneri]
** Takılan sertifika yenilemesi alarmla yakalanır**: yenileme tablosu, otomatik yenilenen sertifikanın takıldığını göstermez. Web ve api.* için kurulan uptime kontrollerinde SSL doğrulaması açılır. Kontrol run.app'e değil alan adına gider, yoksa ölçülen sertifika Google'ınkidir. uptime_check/time_until_ssl_cert_expires 14 günün altına inince bugün seviyesinde alarm çalar. Olağan yenileme bitişten haftalar önce yapıldığı için bu alarm yalnız yenileme takılınca çalar. Sertifika geçersiz olursa kontrol düşer ve erişim alarmı acil çalar. Uptime metriğine bağlı alarm ücretsiz kalır.
[öneri]
** AI tarayıcılarında Training için 'Disallow AI Training' seçilir**; Googlebot, Bingbot ve Applebot aramada kalır. 'Block' aramayı da keser. CCBot ve ChatGPT-User için ayrı karar verilir. 15 Eyl 2026'dan beri yeni alan adına önerilen hazır ayar okunmadan kabul edilmez.
[öneri]
** HTML kenar önbelleği yalnız yazmada URL purge bağlıysa**; Edge TTL override yok; '/', dil yönlendirmesi ve çerezli istekler bypass; Set-Cookie'li yanıt önbelleğe girmez. Cloudflare Vary'yi varsayılan olarak cache key'e katmaz; Vary: Cookie'ye güvenilmez.
[öneri]
** api.* proxy'lenmez** (gri); turuncuda BFM mobil istemciye challenge çıkarabilir ve X-Forwarded-For'un en sağı Cloudflare'in adresi olur. Ayrıntı [Botlara karşı tutum › Ayarlar](#bot-ayarlar)'da.
[öneri]
** Turuncu buluttan önce, prod açılmadan, geçici bir prova host'unda SSL Full** (strict), CF-Connecting-IP ve gizli başlıksız run.app isteğinin reddi doğrulanır. Bu host Worker ile prod web'in run.app adresine gider ve prod web'de EDGE_KEY tanımlıdır; prova bitince kayıt silinir. Nameserver taşınırken MX, SPF, DKIM, DMARC ve BIMI birebir taşınır.
[kanıtlı]
** Canlı domain mapping silinip yeniden kurulmaz**; zorunluysa apex ve www sırayla taşınır.
[kanıtlı]
** Alan adı lansmandan haftalar önce alınır ve FortiGuard, Trend Micro, Talos, Broadcom'a kategori başvurusu yapılır**.

## Başlangıç ayarları

[öneri]
Free: 5 WAF kuralı, 1 hız sınırı, 10 cache kuralı; Pro ($20–25/ay) gerekmiyor.
[ölçüldü]
Domain mapping yeniden kurulumu: ~5 dk eski sertifika, ~12 dk yeni sertifika, ~8 dk yayılma.

### Kaçın

[öneri]
AI ayarında 'Block'; purge'süz HTML önbelleği (günlük s-maxage'la bir yorum bir gün görünmez).
[öneri]
Bu ölçekte Cloud Armor + LB: proje başına ~$25+/ay.

### Nereden öğrendik projelerimizden, 2026

**18 Eyl** domain mapping geçişinde ~20 dk HTTPS kopukluğu.
**6 Eki** robots.txt'yi dinlemeyen 47.79.0.0/16 (Alibaba Cloud) günde ~25.000 istek attı. 7 Eki'de açılan 403 kuralıyla sonraki 24 saatte 6.654 istek reddedildi.
**2 Eki** 38 günlük alan adının kod mailleri kurum geçitlerinde bekledi; kategori başvurusu aynı akşam döndü.

## İstemci adresi nereden okunur

Kapı, BFF ve API aynı tabloya bakar. Kenar anahtarı Secret Manager'da durur ve ayda bir iki değerli geçişle değiştirilir; sırası tablonun altında.

| Yol | Adresi kim yazar | Kim okur, neye güvenir |
|---|---|---|
| Tarayıcı → Cloudflare (turuncu) → Worker → web | Worker, CF-Connecting-IP'yi X-Client-IP'ye yazar ve kenar anahtarını ekler. Bu yolda X-Forwarded-For'un en sağı Cloudflare'in adresidir. | Kapı ve BFF X-Client-IP'ye yalnız kenar anahtarı eşleşirse güvenir. Anahtarsız istek Cloudflare'i atlamıştır: 403. |
| Tarayıcı → web, Cloudflare yalnız DNS (gri) | Cloud Run'ın kenarı bağlanan adresi X-Forwarded-For'un en sağına ekler; öncesini istemci yazar. | Kapı ve BFF en sağ elemanı okur. |
| Web BFF → API | BFF, kendi okuduğu adresi X-Client-IP olarak iç anahtarla gönderir. En sağ XFF burada web sunucusunun adresidir. | API X-Client-IP'ye yalnız iç anahtar doğruysa güvenir; web sunucusunun adresi kimsenin IP'si değildir. |
| Mobil → api.* (gri, domain mapping) | Cloud Run'ın kenarı, X-Forwarded-For'un en sağı. | API en sağ elemanı okur. ::ffff: normalize edilir; özel alan ya da Google yük dengeleyicisi aralığı adressiz sayılır. |

Bir yolda adres yanlış okunursa adres başına kovalar ve giriş kodu sınırları bütün kullanıcıları tek adreste toplar: 429 ve kilitlenen girişler. Önüne Google'ın harici yük dengeleyicisi konursa istemci X-Forwarded-For'un sondan ikinci elemanıdır; okuma o gün değişir. Uptime kontrolü web'in alan adına gider; bulut ağı kuralı bu yolu kapsamaz. Kenar anahtarı uptime ya da build ayarına düz yazılmaz: ayda bir değişir ve izleme ayarını okuyabilen herkes başlığı görür. Duman testi ve loopback çağrısı için bkz. [Kapının iskeleti](#iskelet).

[öneri] Sırrın tek etkin sürümü "yeni,eski" iki değeri taşır. Önce alan taraf bu sürümle yeni revizyona çıkar ve iki değeri de kabul eder. Sonra gönderen taraf yeni değere geçer, burada Worker sırrı yazılır. Ertesi gün sır yalnız "yeni" ile yeniden yazılır, yeni revizyona çıkılır ve eski sürüm yok edilir. BFF'den API'ye giden iç anahtar ve kapı anahtarı da aynı sırayla değişir. Tek değerle değiştirilirse iki tarafın ayrı anlarda güncellendiği aralıkta her ziyaretçi 403 alır. İç anahtarda ise bütün site tek adres sayılır ve giriş kodu sınırı herkesi keser.

### Worker

```
// Cloudflare Worker: web host'unun önünde, run.app'e yönlendirir
export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const host = url.host;                        // ziyaretçinin gördüğü alan adı
    url.hostname = env.ORIGIN_HOST;               // servisin run.app adı; Host bu olur
    const out = new Request(url, req);
    out.headers.set("x-forwarded-host", host);    // Server Actions Origin'i bununla karşılaştırır
    out.headers.set("x-client-ip", req.headers.get("cf-connecting-ip") ?? "");
    out.headers.set("x-edge-key", env.EDGE_KEY);  // yalnız yeni değer; uygulama yeni,eski kabul eder
    return fetch(out);
  },
};
```

[öneri] Worker isteği run.app adına gönderir. Bu yüzden Host başlığı artık ziyaretçinin alan adı değildir. Next, bir Server Action'da Origin'i X-Forwarded-Host ile karşılaştırır, o yoksa Host ile. Bu başlık eklenmezse her form 'Invalid Server Actions request' hatasıyla düşer. X-Forwarded-Host'a yalnız kenar anahtarı eşleşen istekte güvenilir; anahtarsız istek zaten 403 alır. Mutlak adres gereken her yerde taban SITE_URL'dir, isteğin host'u değil. Turuncu buluta geçmeden önce prova host'unda iki deneme yapılır: alan adı üzerinden bir Server Action ve kök yönlendirmesi curl ile çağrılır. Location başlığında run.app geçmemelidir.

[öneri] www'den çıplak adrese 308'i Cloudflare yapar, Next değil. www için turuncu bulutta bir kayıt durur. Free planda gelen tek bir yönlendirme kuralı (Single Redirect), yolu ve sorgu dizesini koruyarak 308 döner. Worker yalnız çıplak host'un route'una bağlanır. Next her isteği run.app adıyla gördüğü için www'yi Host başlığından ayıran bir middleware bu yolda hiç çalışmaz. Kontrol: www adresine curl -I tek adımda 308 ve çıplak https adresi döner; çıplak adreste bir form gönderimi 200 alır.

Katman 6 / 11

# Bulut altyapısı (Cloud Run)

Servisler min 0 ile çalışır, her ürünün kendi faturalama hesabı vardır ve servis tanımı depoda durur.

~₺255/ay
Konsoldan açılan tek bir minScale=1'in tutarı. 2 Eki'de kaldırıldı, 5xx 0 kaldı.

## Yap

[kanıtlı]
** Min 0, istek bazlı CPU, CPU boost**; web'i ve API'yi ayrı ayrı, her birinin veritabanısız sağlık ucuna 300 sn'de bir, 3 bölgeden giden uptime check sıcak tutar.
[ölçüldü]
** Her ürüne kendi faturalama hesabı**; ücretsiz kotalar hesap başına.
[öneri]
** Servis tanımı depoda service.yaml**; konsoldan ayar yok; haftalık drift kontrolü. service.yaml kaynak ve ölçek ayarını tutar: bellek, CPU, min ve max, eşzamanlılık, probe, servis hesabı, sır referansları ve düz ortam değerleri. Yaml'a sır değeri yazılmaz, yalnız Secret Manager referansı yazılır. İmaj digest'ini yalnız hat değiştirir. Prod'da gcloud run services replace kullanılmaz. Bu komut yaml'da olmayan ortam değerini siler ve acil durumda kapatılmış bir anahtarı sessizce geri açar; [kural 7.8](#k-7-8)'deki kaybın aynısıdır. Ayar gcloud run services update ile, ortam değeri --update-env-vars ile değişir. İkisi de aynı gün service.yaml'a commit'lenir, acil ortam değişikliği denetim kaydına da yazılır. Drift kontrolü gcloud run services describe SERVIS --format=export çıktısını service.yaml ile karşılaştırır. Karşılaştırmaya imaj digest'i, revizyon adı, status, zaman damgaları ve gcloud'un her deploy'da yazdığı notlar girmez; servis düzeyindeki minScale notu girer. Ortam farkı susturulmaz, ayrı satırda raporlanır. Canlıda açık sanılan bayrağın kapalı çıktığı 1 Ekim notu bu farktan doğdu. Konsoldan açılan minScale=1 de bu karşılaştırmada ilk hafta görünür.
[öneri]
** AR temizliği gerçek modda**; canlı ve önceki imaj her deploy'da taşınan live ve prev etiketleriyle süresiz, deploy edilen imaj deployed- etiketiyle 30 gün KEEP; geri dönüş penceresi gerçek listeden hesaplanır; job imajlarını hat günceller.
[ölçüldü]
** Tetikleyiciler bölgesel, AR ile aynı bölgede**; buildpack tetikleyicisinde pull/push bırakılmaz.
[ölçüldü]
** Bellek gerçek tepeye göre, OOM alarmlı**; istek dışında CPU kısılır.

## Başlangıç ayarları

[kanıtlı]
API: min 0, max 2–3, 512 MiB, 1 vCPU, startupProbe TCP 240 sn. Web: min 0, max 3.
[öneri]
Go API'de GOMEMLIMIT ortam değişkeni bellek sınırının ~%85'i olarak service.yaml'da durur (512 MiB'ta GOMEMLIMIT=435MiB). Go bellek sınırını container'dan kendisi okumaz; bu ayar olmadan çöp toplayıcı sınırı bilmez. Bellek değişince bu değer de aynı deploy'da değişir. Yumuşak bir sınırdır, OOM alarmının yerini tutmaz.
[kanıtlı]
Deploy --image=<digest> --update-env-vars; --set-env-vars yok.
[öneri]
Günlük veritabanı işleri tek 10 dakikalık sabah penceresinde art arda. Varsayılan pencere 05:00–05:10 İstanbul saatidir; takvim kodda UTC ile yazılır (02:00). Bu saatte UTC günü de İstanbul günü de dönmüştür: e-posta sayacı yeni günün kotasındadır, dünün özeti eksiksiz okunur. Trafik en azdır, yedek kullanıcıyla yarışmaz. Saat değişirse 03:00'ten önceye alınmaz ve DECISIONS'a yazılır.

### Kaçın

[kanıtlı]
Konsoldan minScale=1; uptime check'i silmek (kontrolsüz serviste günde 8,3–33 otomatik başlatma).
[ölçüldü]
Global tetikleyicide kıtalar arası pull/push; günlük işleri farklı saatlere dağıtmak (bir üründe haftada 6 gün üç ayrı uyanış).

### Bizdekinden iyisi

[ölçüldü]
Her ürünün kendi faturalama hesabı ücretsiz kotaları ayırır: aynı hesaptaki iki ürün Eylül'de 3.121 build dakikasıyla kotayı aştı (₺187).
[öneri]
Fly.io, Railway ve Hetzner ancak sürekli açık bir iş çıkarsa düşünülür.

### Nereden öğrendik projelerimizden, 2026

**7 Eyl** konsoldan açılan minScale=1 ayda ~₺255 yazdı; 2 Eki'de kaldırıldı, 5xx 0.
**Eylül** global tetikleyici 73 GiB kıtalar arası çıkış yaptı, ₺282.
**21 Eyl ve 7 Eki** AR temizliği elle sabitlenmiş migrate job'ını kırdı; 1–8 Eki'de 512 MiB'lik bir serviste 7 günde 540 OOM; 2 Eki'de tek günde 192.

Katman 7 / 11

# CI/CD ve ortamlar

İmaj bir kez kurulur. Test'te doğrulanan digest onay kapısından geçerek prod'a çıkar.

11 dk
Migration koşmadan yayına çıkan kodun 500 döndürdüğü süre.

## Yap

[kanıtlı]
** İki dal, iki ortam**; main yalnız test'te görülmüş commit'e fast-forward; birleşen dal silinir.
[öneri]
** Bir kez build, terfi**: test hattı vet, Postgres sidecar'lı test, govulncheck, Docker build sonrası digest'i yazar; prod aynı digest'i onay kapısından geçirir.
[kanıtlı]
** Migration'lar yalnız ekler ve koddan önce koşar**; uygulanmış dosya değişmez.
[öneri]
** Migration hattın adımıdır**: migrate job aynı digest'le execute --wait; başarısızsa trafik verilmez.
[öneri]
** Migrate job'ı yeniden denemesiz kurulur**: gcloud run jobs create SERVIS-migrate --image=<digest> --project PROJE --region=europe-west1 --max-retries=0 --tasks=1 --task-timeout=10m. Cloud Run Jobs başarısız görevi varsayılan olarak 3 kez yeniden dener; yarım kalmış bir göç kendiliğinden tekrar koşar ve hata geç görünür. Bizdeki migrate job'ı da tek görev, sıfır yeniden deneme ve 600 sn tavanla çalışıyor.
[kanıtlı]
** Entegrasyon veritabanı yoksa testler FAIL eder**; 'testler geçti' yalnız veritabanlı koşudan sonra.
[kanıtlı]
** Test ortamı prod'un şeklini taşır**: ayrı Neon, ayrı hesap ve sırlar, aynı PG, temsili veri, mail allowlist'i, '-test' guard'ı.
[öneri]
** Test ortamında tek kural**: test web'i IAP arkasında; test API'si ağda açık, çünkü mobil build IAM'i geçemez, ama giriş yalnız izinli adreslere (sabit kod da yalnız onlara), X-Robots-Tag noindex ve en fazla 1 instance. Test ve prod aynı projede durur: '-test' servisleri kendi servis hesabı ve sırrıyla, prod sırrına erişimsiz. Aynı projede sınırı yetki çizer. test'e push onaysızdır ve test'in build dosyası dalla gelir; test tetikleyicisinin build hesabı prod'u değiştirebiliyorsa main'in onay kapısı aşılır. Bu yüzden hiçbir build hesabı projede Cloud Run rolü taşımaz. Servis ve job'lar gün 0'da bir kez açılır, yetki sonra kaynakta verilir. Test build hesabı yalnız '-test' servis ve job'larında roles/run.developer, yalnız test çalışma hesaplarında roles/iam.serviceAccountUser, depoda roles/artifactregistry.writer, projede roles/logging.logWriter alır. main build hesabı aynı rolleri yalnız prod kaynaklarında alır; yalnız terfi ediyorsa depoda reader yeter. Rol listesi docs/DECISIONS.md'ye yazılır. Kontrol: test build hesabıyla prod servisine deploy denemesi yetki hatası alır. Ücretli test anahtarının sağlayıcıda sert tavanı vardır; sertifika logları host adını açığa çıkarır. Test web'i kendi run.app adresinden IAP ile açılır. Önüne Cloudflare host'u ve Worker konmaz, servisinde EDGE_KEY tanımlanmaz. IAP'den geçen istek run.app'e anahtarsız gelir; EDGE_KEY tanımlıysa kapı ona 403 verir. Test API'si de kendi run.app adresinde kalır, ayrı alan adı almaz. Mobil preview build bu adrese bakar.
[öneri]
** Prod'a dokunan komut 'prod-' ile başlar ve host'u kontrol eder**; testlerde ağ kapalı.
[kanıtlı]
** Commit'ler birikir, iş bitince tek deploy**; canlı kırıkta sebep → düzeltme → doğrulama → commit → ilk satırda onay isteği. Build, sürüm ve deploy ürün sahibinin kararıdır ve CLAUDE.md/AGENTS.md'de yazılıdır.

## Başlangıç ayarları

[öneri]
test ^test$; main ^main$ ve approval required.
[öneri]
Tetikleyici kendi build hesabıyla koştuğu için her cloudbuild*.yaml dosyasının sonunda `options: logging: CLOUD_LOGGING_ONLY` durur. Bu satır yoksa Cloud Build build'i hiç başlatmaz. Build logu Cloud Logging'in 30 günlük _Default kovasında kalır. Bizim depolarımızda da bu satır var.
[öneri]
Prod: jobs update --image=<digest> → jobs execute --wait → deploy --no-traffic --tag=candidate → smoke → trafik.
[öneri]
Bu hat yalnız var olan servis ve job'da çalışır: gcloud yeni serviste --no-traffic'i reddeder, jobs update de olmayan job'da hata verir. İlk kurulumda servis ve SERVIS-migrate job'ı, test'te doğrulanan digest'le hattın dışında bir kez açılır: servis --no-traffic olmadan, job jobs create ile ve çalıştırılmadan. Prod'daki bu ilk açılış da ürün sahibinin onayıyla yapılır. Adım runbooks/new-env.md'ye yazılır.
[ölçüldü]
ignoredFiles **/*.md; başarısız build bildirimi.

### Kaçın

[kanıtlı]
Kodu migration bitmeden trafiğe vermek; prod migration'ı dizüstünden koşmak.
[ölçüldü]
Prod için --no-cache yeniden build; onaysız main deploy'u.
[kanıtlı]
SKIP eden testleri yeşil saymak; verisiz test ortamında 'geçti' demek.
[öneri]
Herkese açık test ortamında gerçek ücretli anahtar. İzin verilen tek hal: kimlik doğrulama arkasında ve sağlayıcıda sert tavanla.

### Bizdekinden iyisi

[ölçüldü]
Tek build ve onay kapılı terfi, değişiklik başına ~4,5 dk kazandırır; test ve main için ayrı build 4,8 + 4,4 dk sürer.
[kanıtlı]
Migration hattın adımı olunca job imajı bayatlamaz; elle yürütülen düzende imaj iki kez bayatladı.

### Nereden öğrendik projelerimizden, 2026

**21 Eyl** göçle aynı commit'teki kod 11 dk 500 döndürdü.
**26 Eyl** düzeltmeler test'i atlayıp main'e gitti; 20 Eyl'de izinsiz iki prod build başlatıldı.
**22 Eyl** 1.000 yeşil test bir build kırığını yakalamadı, deploy sessizce çıkmadı.

Katman 8 / 11

# Güvenlik ve botlar

Her servis en az yetkiyle çalışır, sırlar Secret Manager'da durur. Botlara karşı ayrıntılı tutum bu katmanın ardından gelir.

8 → 0
Güvenlik denetimi günü Go taramasında (govulncheck) bulgu sayısı. Next'teki SSRF zinciri ertesi gün sürüm yükseltmesi ve rolsüz hesapla kapandı.

## Yap

[kanıtlı]
** Önce her tetikleyiciye gereken rollerle kendi build hesabı verilir, sonra compute hesabından Editor kaldırılır**; yeni projede build varsayılan olarak compute hesabıyla koştuğu için sıra ters olursa tetikleyiciler kırılır. Kendi hesabıyla koşan her cloudbuild*.yaml dosyasının options bölümünde logging: CLOUD_LOGGING_ONLY durur ve bu hesaba projede roles/logging.logWriter verilir; bu ayar yoksa Cloud Build build'i hiç başlatmaz. Her servis rolsüz kendi hesabıyla; roller kaynakta; Token Creator hesabın kendi üstüne; build actAs'ı yalnız deploy ettiği hesaplarda.
[kanıtlı]
** Her sır ilk deploy'dan Secret Manager referansı**; düz env'den geçiş tek komutta ve SHA-256 kontrolüyle.
[öneri]
** JSON anahtar indirilmez**: organizasyon varsa iam.disableServiceAccountKeyCreation; CI Workload Identity Federation ile; sağlayıcıya yüklenen anahtar diskten silinir.
[kanıtlı]
** Private depo, gitleaks, push protection**; secret taraması .env'i atlamayan grep'le.
[kanıtlı]
** Müşteri belgeleri PAP'li ayrı kovada, yalnız sahiplik kontrollü indirme**; medyada legacyObjectReader.
[ölçüldü]
** Bot sırası**: önce okuma yolunu veritabanından ayır, sonra robots.txt, en son kapı ya da WAF.
[kanıtlı]
** Proxy'nin ilk satırında kapı**: tarama yolları 404, adı belli botlar 403, şekil kuralları yalnız çıplak GET'e; link tarayıcıları ve paylaşım yolları muaf; hata olursa geçir. Gün 0'da yalnız başka sitelerde gölgeden geçmiş ortak kurallar reddeder; yeni kural, log birikmişse önce 30 günlük log üzerinde denenir, sonra en az 7 gün (kurumsal 14) gölgede çalışır.
[öneri]
** Kapı her depoya bayt bayt kopyalanmak yerine sürümlü tek bir paket olarak dağıtılır**.
[kanıtlı]
** Güvenlik başlıkları ilk gün**; admin girişi ayrı uçta ve her adrese aynı cevap.
[öneri]
** Herkese açık yazma uçlarında Firebase App Check**.

## Başlangıç ayarları

[ölçüldü]
Secret Manager ~₺16/ay (12 referans).

### Kaçın

[kanıtlı]
Next servisini Editor yetkili compute hesabıyla çalıştırmak; proje geneli Token Creator.
[kanıtlı]
Sırrı düz env'de ya da herkese açık depoda tutmak; 'Cache-Control: private'ı erişim kontrolü sanmak.
[ölçüldü]
Bot kuralını gölgesiz zorlamak; bot engelinin Neon faturasını düşüreceğini sanmak.

### Nereden öğrendik projelerimizden, 2026

**23 Eyl** Next 14.2.35 SSRF (GHSA-c4j6-fc7j-m34r) + Editor hesabı proje ele geçirmeye açıktı; aynı gün kapatıldı: siteler Next 15.5'e geçti ve rolsüz hesaba alındı.
**22 Eyl** taramada kullanıcı yüklemelerinin avatarlarla aynı medya kovasına yazıldığı görüldü; aynı gün PAP'li ayrı kovaya taşındı. Go imajı da yükseltildi, govulncheck 8 → 0.
**7 Eki** gölgesiz bir kural bir mail link tarayıcısına 403 verdi.

Güvenlik ve botlar

# Botlara karşı tutum

Bu bölüm yeni bir ürünün otomatik trafiğe karşı tutumunu yazar: hangi botu açık tutarız, hangisini yavaşlatırız, hangisini yalnız izleriz, hangisini reddederiz.

Dayanak, 1–7 Ekim 2026'da dört sitemizin 11 servisinden çekilen yaklaşık 517.000 isteklik log ve bu analizden çıkan ortak 'kapı' kodudur. Kapı Next proxy ya da middleware'in ilk satırında çalışır ve her sitede aynı modüldür; yeni projeye iskeleti aşağıda. Yeni bir sitede gün 0'da yalnız başka sitelerde gölgeden geçmiş ortak kurallar reddeder: tarama, ad, ağ ve boş ajan kuralları. Hız, başlık ve ürüne özel kurallar önce gölgede çalışır. Web tarafında isteklerin çoğunu botlar attı: bir sitede trafiğin %65'i zafiyet taramasıydı, bir başkasında web isteklerinin %41'ini tek bir bulut kazıyıcısı aldı.

## Dört tutum

[aç]
Hiçbir kural dokunmaz.

[sınırla]
Geçer, hız kovasından düşer.

[izle]
Reddedilmez, gölge satırı yazar.

[engelle]
403 ya da 404.

## Trafik sınıfları ve tutum

Her sınıf için ne yaptığımız ve kuralın nerede çalıştığı. [Sınıf sınıf ayrıntı](#siniflar) bölümün sonunda.

| Sınıf | Tutum | Nerede uygulanır |
|---|---|---|
| Doğrulanmış arama motorları | [aç] | robots.txt'de açık. Kapıda adres doğrulanınca hız ve başlık katmanlarından muaf. Cloudflare'de doğrulanmış bot olarak geçer. |
| AI cevap motorları ve kullanıcı adına getiriciler | [aç] | robots.txt'de açık. Kapıda aralıkla doğrulanınca hız ve başlık katmanlarından muaf. |
| AI eğitim tarayıcıları | [sınırla] | Karar robots.txt'de yazılır ve kapının listesine aynen girer. Açık bırakılanlar kapının adres başına hız kovasından geçer. Cloudflare'de Training için 'Disallow AI Training'. |
| Okur getirmeyen beyanlı tarayıcılar | [engelle] | robots.txt'de Disallow. Kapıda her yolda 403; robots.txt ve /.well-known her zaman açık. |
| SEO paketleri | [engelle] | robots.txt'de Disallow. Uymayan ya da adı tutmayan için kapının site listesi. |
| Link önizleyiciler | [aç] | Kapıda hiçbir kural bunlara dokunmaz; paylaşım ve token yolları hız ve başlık katmanlarından muaf. robots.txt'de açık. |
| E-posta link tarayıcıları ve güvenlik firmaları | [aç] | Kapının sessiz listesinde: şekil kuralları ve gölge katmanlar onlara hiç uygulanmaz. Kurumsal kullanıcılı üründe ad kurallarından da muaf. |
| Tarayıcı kılığında bulut kazıyıcıları | [engelle] | Kapıda ağ kuralı: yalnız içerik sayfalarında 403. Cloudflare varsa WAF özel kuralıyla ASN, yine yalnız içerik host'u ve yollarında. API'de, oturum, form, token linki ve yasal sayfalarda uygulanmaz. Kurumsal kullanıcılı üründe önce yalnız log. |
| Konut proxy havuzları | [izle] | Kapının tarayıcı başlık kontrolü gölgede: Chrome ajanı taşıyıp HTTPS'te Sec-Fetch-Mode göndermeyen istek 'reddederdim' satırı yazar. Asıl önlem veriyi ucuza sunmaktır: ISR ve kenar önbelleği. |
| Zafiyet taramaları | [engelle] | Kapının ilk adımı: render etmeden 404. Next matcher büyük-küçük harfe duyarlıdır; desenler harf sınıflarıyla yazılır. Cloudflare varsa aynı liste bir WAF kuralına da girer. |
| Boş, URL biçimli ya da kesik kullanıcı ajanı | [engelle] | Kapıda 403, yalnız içerik sayfalarına gelen GET'te. HEAD, formlar, portal ve güvenlik firması adresleri bu kurala girmez. |
| Adresi okunamayan istekler (0.0.0.0) | [sınırla] | Kapıda ağ kuralları uygulanmaz, ad kuralları uygulanır. Hepsi tek ortak hız kovasında, adres sınırının 4 katıyla sayılır. Ham X-Forwarded-For yalnız bu isteklerde loga yazılır. |
| Sahte Googlebot ve sahte AI bot iddiaları | [engelle] | Kapıda önce gölge, temiz bir dönemden sonra 403. Doğrulanmayan ad hiçbir muafiyet almaz. Kendi test betiklerimiz kapı anahtarı başlığıyla gelir. |
| Kendi trafiğimiz | [aç] | Kapının sessiz listesi. API'de iç anahtarla gelen istek hız sınırından muaftır ve ziyaretçinin adresi X-Client-IP ile iletilir. |

## 1–7 Ekim 2026 loglarından

**275'ten ~25.000'e** Alibaba Cloud kazıyıcısının günlük isteği; robots.txt'yi hiç okumadı.
**%41 ve %44** Aynı kazıyıcının web isteklerindeki ve UI baytlarındaki payı.
**6.654** 403 kuralı açıldıktan sonraki 24 saatte reddedilen istek.
**%65** Bir sitede .env, .git ve wp-admin taramalarının trafikteki payı; hiçbiri 200 almadı.
**35'te 2** Bir sitede gerçek çıkan ChatGPT-User iddiası. PerplexityBot'ta 63'te 4.
**7.656 adres** 2.331 ASN'den; konut proxy havuzunun 15,9 saatteki ayak izi, adreslerin %98'i tek istek attı.
**38.022** Adresi okunamayan tek bir botun ~90 dakikalık patlaması; arka uç çağrıları 21 kat arttı.
**%30** Meta'nın eğitim tarayıcısının bir sitedeki payı (31.651 istek, bir saatte 11.448).
**0** 517.285 istekte engelli bulut aralıklarından gelen uygulama isteği.
**24 / 10 sn** En yoğun gerçek adresin sayfa sayısı, günde 129; varsayılan sınır her pencerede bunun en az 5 katı.
**~4–10 µs ve $0** Kapının istek başına bedeli. Cloud Armor proje başına ~$25–30/ay.

## İlkeler

1. Kimlik, yayıncının yayımladığı adres aralığıyla doğrulanır. Kullanıcı ajanı yalnız bir iddiadır.

Google Cloud'daki tarama kitleri 29 farklı bot adı taşıdı. Bir sitede ChatGPT-User iddialarının 35'inden 2'si, PerplexityBot iddialarının 63'ünden 4'ü gerçekti.

2. Sıra bellidir: önce herkese açık okumayı veritabanından ayır, sonra robots.txt'yi yaz, en son kapıyı ya da WAF'ı kur.

Neon ancak 5 dakika hiç bağlantı olmazsa uyur; bot engeli tek başına veritabanı faturasını düşürmedi. Bir projede okuma kopyası günlük tüketimi 6,5'ten 1,3 CU-saate indirdi; yoğun katalog işiyle 2–3'e döndü. Botun bedeli Cloud Run çıkışında ve bellek taşmasında göründü: bir ürünün GCP payının çoğu bot çıkış trafiğiydi, bot trafiğinde günde 192'ye varan OOM oldu.

3. robots.txt ve kapı aynı ad listesinden üretilir.

Bir sitede robots.txt herkese 'Allow: /' derken kapı 13 adı 403'lüyordu. robots.txt'ye uyan bot neyin yasak olduğunu yalnız oradan öğrenir; orada izin görüp kapıda 403 alan bot neden reddedildiğini bilemez.

4. Her yeni kural, log birikmişse önce 30 günlük log üzerinde denenir, sonra en az 7 gün (kurumsal kullanıcılı üründe 14) gölgede çalışır: reddetmez, yalnız 'reddederdim' satırı yazar. Zorlama kararı bu dönemin temiz loguyla verilir. Yeni sitede gün 0'dan reddeden yalnız başka sitelerde bu yoldan geçmiş ortak listedir.

Gölgesiz açılan boş ajan kuralı ilk gün bir e-posta link tarayıcısına 403 verdi. Gölgedeki hız kuralı da Next'in prefetch'lerini sayfa sandı ve gerçek tarayıcıları 'reddederdim' diye yazdı; zorlansaydı insanları kesecekti.

5. Bütün bir bulut ağını (ASN) reddetmek yalnız içerik sayfalarında yapılır. Mobil uygulamanın konuştuğu API'de, oturum, form, paylaşım linki ve yasal sayfalarda yapılmaz.

Engellenen bulutlarda VPN hizmetleri ve bir mobil tarayıcının hız modu çalışabiliyor. 517.285 istekte o aralıklardan tek bir uygulama isteği gelmedi, ama sosyal medya kısıldığında yapılan toplu VPN kurulumu bu tabloyu bir günde değiştirebilir.

6. Adres başına sınır yüksek tutulur ve yalnız tek adresten gelen seli durdurmak için kullanılır.

Operatör NAT'ında tek bir IPv4 adresinin arkasında 6 farklı cihaz görüldü; bir kurumun genel müdürlüğü yüzlerce kişiyi tek adresten çıkarır. Dağıtık kazıyıcılar adres başına 1–3 istek atar; insanlara güvenli hiçbir adres sınırı onları görmez.

7. Ziyaretçi getiren bot açık kalır. Eğitim tarayıcıları için karar her ürünün GEO hedefine göre verilir ve robots.txt'ye yazılır.

Sayfalar sunucuda render edilince OAI-SearchBot ~11,7 günde 116 sayfa taradı; ChatGPT-User kullanıcılar adına günde ~25 sayfa açıyor. Eğitim tarayıcısı doğrudan ziyaretçi getirmez, ama modelin ürünü tanıması GEO'nun parçasıdır.

8. Aynı veri HTML'in yanında JSON olarak da veriliyorsa önce JSON kapısı kapanır.

Bir sitenin kendi /api aktarma ucu kapının dışında kalmıştı ve tek çağrıda 5.000 kayıt döndürüyordu; katalog listesi 3 çağrıya iniyordu. HTML'i korumak o veriyi korumuyordu.

9. Kapı hata verirse isteği geçirir. Reddedilen kişinin bir çıkışı vardır.

Kapıdaki bir hatanın bedeli en fazla bir botun geçmesidir. Her ret aynı Türkçe ve İngilizce sayfayı gösterir: yeniden dene bağlantısı, iletişim adresi ve bir işaret pikseli. İşaret, reddedilmiş gerçek bir tarayıcıyı loglarda görünür kılar.

## Kapının karar sırası

Her istek bu sırayla yargılanır. Sağdaki işaret adımın tutumunu gösterir.

1. robots.txt, /.well-known ve ret sayfasının işaret pikseli her zaman geçer.

[aç]
2. Yol tarama listesinde mi: render etmeden 404.

[engelle]
3. Ajan okur getirmeyen listede mi: her yolda 403.

[engelle]
4. İçerik sayfasına GET, ajan boş, URL ya da kesik, Accept-Language ve Sec-Fetch-Mode yok, adres sessiz listede yok: 403.

[engelle]
5. Adres kanıtlı tarama bloğunda mı: her yolda 403. Engelli bulut ASN'sinde mi: yalnız içerik sayfasında 403.

[engelle]
6. Ajan doğrulanabilir bir bot adı taşıyor mu: adres yayıncının aralığındaysa gölge katmanlardan muaf, dışındaysa 'reddederdim' satırı.

[izle]
7. Kendi çıkışımız, Google, Bing ya da Apple alanı, güvenlik firması veya kapı anahtarı: gölge katmanlar atlanır.

[aç]
8. Sayfa belgesi: adres başına (IPv6'da /64 ve /48 toplamı) hız kovasından düşer. Next payload'ı ayrı ve yüksek kovada.

[sınırla]
9. HTTPS'te Chrome ajanı Sec-Fetch-Mode göndermiyor: gölgede yazılır.

[izle]
10. Her ret ya da 'reddederdim' için adres, katman ve sebep başına dakikada bir satır yazılır.

log
11. Kapının içinde hata olursa istek geçer ve bir hata satırı yazılır.

[aç]

## Yeni sitede gün 0

Reddetme yetkisi kanıtla gelir: başka sitelerde gölgeden geçmiş ortak kurallar ilk günden reddeder, gerisi gölgede başlar. 30 günlük log ilk gün yoktur; o deneme log biriktikten sonra eklenen kurallar içindir.

| Kural | Gün 0'da | Neden |
|---|---|---|
| Tarama yolları (.env, .git, wp-admin) | [engelle] | Gerçek kullanıcı bu yolları istemez; dört sitenin logunda hiçbiri 200 almadı. Düz metin 404. |
| Okur getirmeyen bot adları | [engelle] | Ad listesi ortak modülde durur ve her ad logdaki gerçek ajan dizesiyle sınanmıştır. |
| İçerik sayfalarında engelli bulut ağları | [engelle] | Ortak liste, ayda bir yenilenir; 517.285 istekte bu aralıklardan tek uygulama isteği gelmedi. |
| Boş, URL biçimli ya da kesik ajan, Accept-Language ve Sec-Fetch-Mode da yoksa | [engelle] | Başka sitelerde gölgeden geçti; güvenlik firmalarının aralıkları sessiz listede. |
| Sahte bot adı (yayıncının aralığı dışında) | [izle] | Doğrulama aralıkları bu ürünün trafiğinde sınanmadan zorlanmaz. |
| Sayfa ve payload hız kovaları | [izle] | Sınır bu ürünün en yoğun gerçek adresinin en az 5 katı olarak kendi logundan kurulur. |
| HTTPS'te Sec-Fetch-Mode göndermeyen Chrome | [izle] | Kurumsal kullanıcılı üründe hep gölgede kalır. |
| Adresi okunamayan istekler, ortak kova | [izle] | İçinde kullanıcı adına çalışan getiriciler var. |
| Ürüne özel her yeni kural; kanıtlı tarama blokları | [izle] | Log birikmişse önce 30 günlük logda denenir, sonra en az 7 gün (kurumsal 14) gölgede çalışır. |

## Ayarlar

robots.txt
[kanıtlı]
Kapının okuduğu ad listesinden üretilir; elle ikinci bir liste tutulmaz. Arama ve cevap botları açık, okur getirmeyen liste ve SEO paketleri Disallow. Eğitim tarayıcıları için ürün kararı yazılır; GEO hedefi yoksa GPTBot, ClaudeBot, CCBot, meta-externalagent, Amazonbot, Bytespider ve Google-Extended satırları eklenir. Adlar botun duyurduğu biçimde yazılır. Değişiklik botlara aynı gün ulaşmayabilir: önbelleğindeki eski dosyayla 20 sayfa daha çeken bir arama botu görüldü.
Cloudflare, AI tarayıcı ayarı
[öneri]
Training için 'Disallow AI Training' seçilir. 'Block' seçilmez: Googlebot, Bingbot ve Applebot gibi çok amaçlı tarayıcıları da keser ve arama görünürlüğü gider. 15 Eyl 2026'dan beri yeni alan adlarında reklam gösteren sayfalarda Training ve Agent varsayılan olarak engelli; ayar gün 0'da okunur ve elle kurulur.
Cloudflare, API host'u
[öneri]
api.* DNS-only (gri) kalır, turuncuya alınmaz. Gri kayıt Cloudflare'den geçmez; Bot Fight Mode ve WAF ona dokunmaz. Turuncuda iki şey bozulur. BFM WAF kuralıyla atlanamıyor ve mobil uygulamaya challenge çıkarabiliyor. X-Forwarded-For'un en sağı Cloudflare'in adresi olur; API en sağ elemanı okuduğu için bütün mobil kullanıcıları birkaç adreste sayar ve giriş kodu sınırları girişleri kilitler. Domain mapping de turuncuda kullanılmaz. API'yi kenara almak ayrı bir karardır: Worker yolu, adresin yalnız kenar anahtarı eşleşen X-Client-IP'den okunması ve kapalı BFM birlikte kurulur, önce prova host'unda denenir.
Cloudflare, WAF özel kuralları
[öneri]
Free'deki 5 kuraldan biri bulut ASN'leri için, yalnız içerik host'u ve yollarında; biri tarama yolları için. Worker CF-Connecting-IP'yi X-Client-IP'ye yazar ve kenar anahtarını ekler; uygulama adresi yalnız anahtar eşleşirse bu başlıktan okur. run.app adresine anahtarsız gelen istek reddedilir.
Kapı, Next proxy ya da middleware
[kanıtlı]
İlk satırda çalışır. Matcher /api aktarma uçlarını, tarama desenlerini ve ret sayfasının işaret yolunu kapsar. İstemci adresi Kenar katmanındaki tabloya göre okunur ([İstemci adresi nereden okunur](#adres)). ::ffff: ile yazılmış IPv4 normalize edilir; son eleman özel alanda ya da Google yük dengeleyicisinin aralığındaysa (35.191.0.0/16, 130.211.0.0/22) istek adressiz sayılır ve uyarı yazılır.
Kapı, hız kovaları
[ölçüldü]
Sayfa belgesi: 120 anlık, saniyede 1, günde 2.000. Next payload'ı: 3.000 anlık, saniyede 20, günde 20.000; prefetch ve gezinme aynı kovada, sayfa kovasına hiç girmez. Kurumsal ağdan gelen kullanıcılı üründe belge 300 anlık, saniyede 3, günde 6.000. IPv6 /64 ile anahtarlanır, /48 toplamı 4 kat. Kovalar instance başınadır. Bu rakamlar en yoğun gerçek adresin her pencerede en az 5 katıdır; operatör NAT'ı ve kurum proxy'si yüzünden daha düşük tutulmaz.
Gölge mod
[kanıtlı]
Her yeni kural, log birikmişse önce 30 günlük log üzerinde denenir, sonra en az 7 gün (kurumsal kullanıcılı üründe 14) yalnız 'would-refuse' satırı yazar. Zorlama bu dönemin logu temizse yapılır. Temiz demek: aynı adresten 2 dakika içinde JavaScript kanıtı (fetch ya da payload isteği, runtime config, CSP raporu, ret sayfası işareti) gelmiş hiçbir 'reddederdim' satırı olmaması. Kurumsal kullanıcılı üründe tarayıcı başlık kontrolü gölgede kalır.
Log
[kanıtlı]
Her ret ya da 'reddederdim' console.warn ile tek JSON satırı yazar: door, layer, reason, site, ip, ua, path, host. Aynı adres (IPv6'da /64), katman ve sebep için dakikada en çok bir satır; sonraki satır aradaki atlanan sayısını taşır. Çerez, sorgu dizesi ve anahtar yazılmaz. Bugünkü hacimde günde ~10 MB.
Ret cevabı
[kanıtlı]
Hangi kural vurursa vursun aynı 403 sayfası: Türkçe ve İngilizce, yeniden dene bağlantısı, iletişim adresi, işaret yolundan yüklenen bir piksel, no-store ve noindex. Hangi kuralın vurduğu yalnız logda durur. Tarama yollarına düz metin 404.
Adres listesi, aylık yenileme
[kanıtlı]
Betikle yenilenir, fark okunarak bütün sitelerde aynı gün işlenir. Engelli ASN'lerin prefix'leri RIPEstat'tan alınır; iki haftalık pencerenin yarısından azında duyurulan, pencere sonunda duyurulmayan ya da IPv4'te /11'den, IPv6'da /20'den geniş prefix alınmaz. Başka şirketin kendi rotasıyla kullandığı alan kesilir. Türk ve Körfez operatörlerinin bütün prefix'leri, bot, kendi çıkışımız ve güvenlik firması aralıkları çıkarılır. Açık kalması ve reddedilmesi gereken örnek adreslerle sınanır. Veri 45 günü geçince kapı uyarı yazar.
Mobil uygulamanın API'si
[kanıtlı]
ASN engeli, Bot Fight Mode ve tarayıcı başlık kontrolü uygulanmaz. Adres başına sınır yüksek: en yoğun uygulama adresi 10 dakikada 80 istek attı, sınır dakikada 600 (genel) ve 30 (giriş).
Sitenin JSON uçları (/api)
[öneri]
Aktarma ucu, tarayıcının gerçekten yaptığı çağrılardan çıkarılan yöntem ve yol izin listesiyle çalışır; listede olmayan yol loglanan bir 404 alır. Aynı köken kontrolü: Sec-Fetch-Site same-origin, yoksa Origin ya da Referer host'u. Toplu liste uçları yalnız web sunucusunun sırrını kabul eder; mobil pakete gömülü anahtar herkese açıktır.
Kapı anahtarı
[öneri]
Kendi betiklerimiz bir anahtar başlığıyla gelir; anahtar yalnız hız ve başlık katmanlarını atlar. Değer Secret Manager'da durur, loga yazılmaz, ayda bir değiştirilir.
Ücretli seçenekler
[öneri]
Bu ölçekte Cloud Armor alınmaz: harici yük dengeleyiciyle proje başına ~$25–30/ay tutar ve kapının yaptığını tekrarlar. Konut proxy havuzunu durdurabilecek tek parça, Cloud Armor Enterprise bot yönetimi, proje başına ~$200/ay ve reCAPTCHA ister. Kapının bedeli istek başına ~4–10 µs ve $0.

## Kapının iskeleti

Modül judge'ın içinde muaf yolları (robots.txt, /.well-known, yasal sayfalar, paylaşım ve form yolları), ad ve ağ listelerini, hız kovalarını ve log satırının dakikalık sınırını taşır.

Bizim modülümüz bu rehberle dağıtılmaz. Yeni projede modül bu iskelet üzerine yazılır ve kopyalar arasında fark doğmasın diye sürümlü tek paket olarak girer. Gün 0'da reddeden ortak liste dört parçadır. Tarama: [Zafiyet taramaları](#sinif-zafiyet) bölümündeki yollar, düz metin 404. Ad: [Okur getirmeyen beyanlı tarayıcılar](#sinif-okursuz) bölümündeki 13 ad, alt dize olarak, 403; bu satır örnek değil, ortak listenin tamamıdır. Şekil: boş, URL biçimli ya da kesik ajan, Accept-Language ve Sec-Fetch-Mode da yoksa ve adres sessiz listede değilse, yalnız içerik sayfalarına GET'te 403. Ağ: [Tarayıcı kılığında bulut kazıyıcıları](#sinif-bulut) bölümündeki dört ASN (AS45102, AS37963, AS132203, AS45090), yalnız içerik sayfalarında 403; prefix'ler [Adres listesi](#ayar-adres) ayarındaki kurallarla çekilir. SEO paketleri ortak listede değildir: robots.txt'de Disallow olur, uymayanı ürün kendi listesine gölgeden geçirerek ekler. Kanıtlı tarama blokları rehbere konmadı, çünkü çabuk eskir; yeni ürün onları kendi logunda bulur ve yeni kural gibi gölgeden geçirir. Bunların dışındaki her kural gölgede başlar.

```
// proxy.ts (Next 16): kapı ilk satırda; hata olursa istek geçer
import { NextResponse, type NextRequest } from "next/server";
import { judge, refusalPage } from "./door";      // ortak modül: listeler ve kurallar

const ENFORCE = new Set(["scan", "name", "net", "shape"]); // gün 0'da reddedenler

export function proxy(req: NextRequest) {
  try {
    const ip = clientIp(req);
    if (ip === "bypass") return refusalPage(403);  // Cloudflare atlanmış
    const v = judge(req, ip);                      // null ya da { layer, reason }
    if (v) {
      const on = ENFORCE.has(v.layer);
      console.warn(JSON.stringify({ door: on ? "refused" : "would-refuse",
        layer: v.layer, reason: v.reason, ip, path: req.nextUrl.pathname }));
      if (on) return v.layer === "scan"
        ? new NextResponse("Not found", { status: 404 }) : refusalPage(403);
    }
  } catch (e) {
    console.error(JSON.stringify({ door: "error", message: String(e) }));
  }
  return NextResponse.next();                      // dil yönlendirmesi bundan sonra
}

function clientIp(req: NextRequest): string | null {
  // EDGE_KEY "yeni,eski" taşır; Worker öndeyse tanımlı
  const keys = (process.env.EDGE_KEY ?? "").split(",").filter(Boolean);
  if (keys.length) return keys.includes(req.headers.get("x-edge-key") ?? "")
    ? req.headers.get("x-client-ip") : "bypass";
  const xff = (req.headers.get("x-forwarded-for") ?? "").split(",");
  const last = xff[xff.length - 1].trim().replace(/^::ffff:/, "");
  return last || null;                             // null: adressiz, ortak kova
}

export const config = { matcher: ["/((?!_next/static).*)"] };
```

EDGE_KEY tanımlıyken run.app'e anahtarsız gelen her istek 403 alır, kendi çağrılarımız da. Terfideki duman testi candidate adresine x-edge-key başlığıyla gider; değer Cloud Build'de availableSecrets ile Secret Manager'dan okunur ([Artifact Registry kural 8](#ar-kural-8)). proxy.ts'in loopback revalidate çağrısı başlığı process.env.EDGE_KEY'in ilk değerinden ekler. Biri unutulursa terfi duman testinde durur. Revalidate ise hata vermeden durur ve yeni içerik görünmez. Bunun için yol muafiyeti eklenmez.

[öneri] Matcher yalnız _next/static'i dışarıda bırakır; _next/image de kapıdan geçer. Görsel iyileştirici kapalıyken (images.unoptimized) bu yol 404 döner. İyileştirici sonradan açılırsa engelli ağ bu yoldan CPU harcatamaz.

## Ne izlenir

door="refused" satırları katman, sebep, adres, ajan ve host'a göre gruplanır; ilk 7 gün her gün, sonra haftada bir.

door="would-refuse" satırları gölge kuralların ne keseceğini gösterir. Aynı adresten JavaScript kanıtı gelmiş her satır yanlış pozitiftir; kural ya da aralık aynı gün çıkarılır.

door="seen" satırı ret sayfasının bir istemcide açıldığını söyler. Satırdaki ağ etiketine ve son bir dakikada vuran kurala birlikte bakılır; görsel yükleyen başsız tarayıcılar da bu satırı yazar.

Reddedilmemiş barındırma ASN'leri, yalnız HTML belge sayısına göre, her gün. Saatte 60'ı geçen yeni bir ASN taşınmış bir operatör olabilir.

Portal, token linki, form ve yasal sayfalarda 403 ve 429 sayısı sıfır kalmalı.

API'lerin 429 sayısı değişmemeli. Dışarıdan, uygulama ajanı olmadan API çağıran her istemciye bakılır.

Search Console tarama istatistiklerinde host durumu (429, 5xx) ve Bing Webmaster Tools: kapıdan sonra yükselme olmamalı.

Doğrulanamayan bot adı satırları: hangi ağdan geldiği, tüketici ağından gelen var mı.

remoteIp 0.0.0.0 satırları: ham X-Forwarded-For ne taşıyor.

Barındırma dışı adreslerden gelen boş ajan ret satırları, özellikle portalda: ajanı silen bir kurum proxy'si işareti.

Haftalık en çok istek atan kullanıcı ajanları: yeni bir beyanlı ad listeye girer.

Konut proxy havuzunun payı haftada bir; Cloud Run çıkış baytı ve bellek taşması.

Kapının veri yaşı uyarısı (45 gün) ve aylık adres listesi farkı.

## Kıl payı kurtulduklarımız

**Ne oldu:** Microsoft'un e-posta link tarayıcısı (134.149.116.0/24) bültendeki linkleri kullanıcı ajanı olmadan düz bir GET ile açtı. 7 Eki'de gölgesiz açılan boş ajan kuralı bir mail link tarayıcısına 403 verdi.

**Kural:** Şekil kuralı yalnız Accept-Language ve Sec-Fetch-Mode da yoksa ve adres sessiz listede yoksa uygulanır. Güvenlik firmalarının aralıkları sessiz listededir. Ortak listede gölgeden geçmemiş hiçbir kural reddetmez.

**Ne oldu:** Next, RSC, Next-Router-Prefetch ve Next-Router-Segment-Prefetch başlıklarını ve _rsc sorgusunu middleware'den önce siliyor (15.5, 16.2 ve 16.3'te aynı). Kapı her prefetch'i sayfa sandı: tek bir Türk adresinden gelen 400 prefetch 92 yanlış 'reddederdim' satırı yazdı. Birim testleri geçiyordu, çünkü başlıkları kendileri kuruyordu.

**Kural:** Kapı testi gerçek Next adaptöründen ya da derlenmiş sunucudan geçen istekle yapılır. Payload, silinmeyen Next-Url ya da sec-fetch-dest: empty ile tanınır ve sayfa kovasına girmez.

**Ne oldu:** Bir sitede robots.txt herkese 'Allow: /' derken kapı 13 adı 403'lüyordu. Kapının 'SERankingBot' girdisi gerçek ad olan 'SERankingBacklinksBot'u, 'Amazonbot' girdisi 'Amzn-SearchBot'u yakalamadı; robots.txt'deki kısaltılmış 'SERanking' satırı katı ayrıştırıcıda işe yaramıyordu.

**Kural:** robots.txt kapının listesinden üretilir. Listedeki her ad logdaki gerçek ajan dizesiyle sınanır.

**Ne oldu:** Sayfalar kapının arkasındayken sitenin kendi /api aktarma ucu kapının dışında kalmıştı. Uç her yolu web sunucusunun sırrıyla API'ye iletiyordu ve tek çağrıda 5.000 kayıt döndürüyordu; tarayıcı kodu bu toplu listeyi hiç çağırmıyordu. HTML'de reddedilen bir kazıyıcı için daha ucuz bir yoldu.

**Kural:** Kapı kurulurken önce JSON uçlarına bakılır. Aktarma ucu yöntem ve yol izin listesiyle çalışır; tarayıcının çağırmadığı toplu liste uçları 404 alır.

**Ne oldu:** Alibaba ve Tencent'in duyurduğu prefix'lerin içinde başka şirketlerin kendi rotasıyla kullandığı kiralık bloklar çıktı. Liste olduğu gibi alınsaydı o şirketlerin kullanıcıları reddedilecekti.

**Kural:** Aylık yenileme her prefix için kimin rota duyurduğunu sorar; başka bir köken daha özel bir rota duyuruyorsa o alan listeden kesilir. 7 Eki'de üç ASN'den 9 blok böyle çıkarıldı.

**Ne oldu:** Google'ın kendi alanı (goog.json) eksi Cloud müşteri aralıkları (cloud.json) hâlâ Cloud Run'ın paylaşılan çıkışını içeriyordu. Cloud Run'da çalışan sahte bir Googlebot doğrulanmış sayılacaktı.

**Kural:** Kiralanabilen her çıkış aralığı doğrulama listesinden çıkarılır.

**Ne oldu:** Ret sayfasındaki işaret pikselini görsel yükleyen her istemci çağırır, bulut adreslerindeki başsız tarayıcılar da. 'Her işaret bir insandır, aralığı kaldır' kuralı Alibaba engelini yanlışlıkla kaldırtabilirdi.

**Kural:** İşaret satırı adresin hangi listede olduğunu ve son bir dakikada hangi kuralın vurduğunu taşır; karar bunlara birlikte bakılarak verilir.

**Ne oldu:** Yasal sayfaların kısa adresleri (/privacy, /account-deletion) dil önekli adrese 307 ile gidiyordu ve o adres içerik kurallarının altındaydı. Play'in politika denetleyicisi bu sayfaları 6 günde 123 kez açtı.

**Kural:** Muaf yol listesi her dil ve her yazımıyla yazılır; mağazanın denetlediği sayfalar hiçbir sınıra girmez.

## Sınıf sınıf ayrıntı

### Doğrulanmış arama motorları

[aç]
**Örnekler:** Googlebot, Bingbot, Applebot, YandexBot, DuckDuckBot; aynı Google adreslerinden Google-InspectionTool, PlayStore-Google, AdsBot ve GoogleOther.
**Nasıl tanınır:** Yayıncının yayımladığı aralıklar: Google için googlebot.json, special-crawlers.json ve user-triggered-fetchers dosyaları; Bing için bingbot.json; Apple için 17.0.0.0/8; DuckDuckGo için duckduckbot.json. Yandex aralık yayımlamaz; ters DNS *.spider.yandex.com ve ileri doğrulama kullanılır. Yandex'in adres alanı ASN kayıtlarında başka bir adla (TELETECH) görünür, bu yüzden ASN adına göre kurulan izin listesi onu kaçırır.
**Neden bu tutum:** Arama ziyaretçisi bunlardan gelir. Adres başına dakikada en çok 6 HTML sayfa çektiler (GoogleOther 14); varsayılan sınır dakikada 180. Bir sitede Applebot 3 günde 4.137 adresten 17.532 istekle web trafiğinin %10'unu yaptı ve hepsi Apple ağındaydı.
**Dikkat:** Aralık listesi bayatlarsa gerçek Googlebot sahte sayılır; liste ayda bir yenilenir, kapı 45 günden eski veride uyarı yazar. Google için goog.json eksi cloud.json kabul edilir ve Cloud Run'ın paylaşılan çıkışı ayrıca çıkarılır, çünkü onu herkes kiralayabilir. GoogleOther aramayı beslemez; 'User-agent: GoogleOther' satırı aramaya dokunmadan onu durdurur (bir sitede 6 günde 6.113 istek). PlayStore-Google gizlilik ve hesap silme sayfalarını denetler; bu sayfalar hiçbir sınıra girmez.

### AI cevap motorları ve kullanıcı adına getiriciler

[aç]
**Örnekler:** OAI-SearchBot, ChatGPT-User, PerplexityBot, Perplexity-User, Claude-SearchBot, Claude-User, DuckAssistBot.
**Nasıl tanınır:** OpenAI için searchbot.json ve chatgpt-user.json; Perplexity için perplexitybot.json ve perplexity-user.json; DuckDuckGo için duckassistbot.json; Anthropic için 216.73.216.0/22 (ARIN kaydı Anthropic, AWS duyuruyor). OpenAI ve Anthropic adreslerinin ters DNS'i yok; doğrulama yalnız aralıkla yapılır.
**Neden bu tutum:** Bunlar bir kişinin sorusuna cevap ararken gelir ve kaynak olarak link verir. Sayfalar sunucuda render edilince OAI-SearchBot ~11,7 günde 116 sayfa taradı; ChatGPT-User kullanıcılar adına günde ~25 sayfa açıyor.
**Dikkat:** En çok taklit edilen adlar bunlar: bir sitede ChatGPT-User iddialarının 35'inden 2'si, PerplexityBot'un 63'ünden 4'ü, Perplexity-User'ın 20'sinden hiçbiri gerçek çıkmadı. Claude-User bazen adressiz (0.0.0.0) loglanır ve doğrulanamaz; ona yalnız ad kuralları uygulanır.

### AI eğitim tarayıcıları

[sınırla]
**Örnekler:** GPTBot, ClaudeBot, CCBot, meta-externalagent, Amazonbot, Bytespider; Google-Extended yalnız robots.txt işareti.
**Nasıl tanınır:** GPTBot gptbot.json içinde; ClaudeBot 216.73.216.0/22 içinde; meta-externalagent Meta'nın AS32934 ağından gelir (IPv6'da ters DNS yok, ASN doğrular); Amazonbot'un ters DNS'i *.crawl.amazonbot.amazon. Bytespider AWS adreslerinden gelir ve doğrulanamaz. Google-Extended ayrı bir istek olarak gelmez; Googlebot'un taradığı içeriğin Google'ın modellerinde kullanılıp kullanılmayacağını söyleyen bir robots.txt adıdır.
**Neden bu tutum:** Doğrudan ziyaretçi getirmezler, ama GEO hedefi olan bir üründe modelin içeriği bilmesi istenir. Yükleri ağır olabilir: meta-externalagent bir sitede trafiğin %30'unu yaptı (31.651 istek, bir saatte 11.448); ClaudeBot tek adresten dakikada 641, GPTBot 10 dakikada 919 sayfa çekti. Hız kovası onları reddetmeden saniyede 1 sayfaya indirir.
**Dikkat:** robots.txt'ye uymaları bota göre değişir: ClaudeBot robots.txt'yi 46 kez okudu ve kendini yavaşlattı, meta-externalagent bu adla hiç okumadı. Meta'yı ağ olarak engelleme; aynı blok sosyal paylaşım linklerinin önizlemesini de taşır. Bytespider ve CCBot ortak okur getirmeyen listededir; GEO hedefli ürün CCBot'u bilerek açabilir.

### Okur getirmeyen beyanlı tarayıcılar

[engelle]
**Örnekler:** ShapBot, Reflectionbot, Scrapy, Diffbot, panscient, cold-email-radar, omgili, Timpibot, ImagesiftBot, FriendlyCrawler, Webzio-Extended, Bytespider, CCBot.
**Nasıl tanınır:** Adını kullanıcı ajanında söyler. Ad, büyük-küçük harf gözetmeden alt dize olarak eşlenir.
**Neden bu tutum:** Hiçbiri ziyaretçi getirmez. ShapBot ~90 dakikalık tek bir patlamada 38.022 istek attı, dakikada 541'e çıktı ve arka uç çağrılarını 21 kat artırdı. Adresi 0.0.0.0 loglandığı için onu ancak adı durdurabilirdi.
**Dikkat:** Ad kuralı yalnız adını söyleyen botu durdurur; adını değiştiren kazıyıcı bu katmandan geçer. Yeni adlar, logdaki en çok istek atan kullanıcı ajanları haftada bir okunarak eklenir.

### SEO paketleri

[engelle]
**Örnekler:** AhrefsBot, SemrushBot, DataForSeoBot, SERankingBacklinksBot, serpstatbot, AwarioBot, Barkrowler, MJ12bot, DotBot.
**Nasıl tanınır:** Ters DNS ve ileri doğrulama: *.ahrefs.net, *.bl.bot.semrush.com, *.blex.seranking.com. AhrefsBot OVH'tan 1.079 farklı adresle gelir; aynı ağda gizli kazıyıcılar da çalıştığı için ad ile ters DNS birlikte okunur.
**Neden bu tutum:** Ürüne ziyaretçi getirmezler, sayfa başına render ve API çağrısı harcatırlar. SERankingBacklinksBot bir sitede 10 dakikada 654 istek attı. Çoğu robots.txt'ye uyar: Disallow yayına girince yalnız robots.txt'yi çektiler.
**Dikkat:** robots.txt'deki ad botun duyurduğu adla birebir yazılır (SERankingBacklinksBot); katı ayrıştırıcılar kısaltmayı tanımaz. Kapı alt dize eşlediği için orada kısa ad da tutar; iki listeyi aynı kaynaktan üret.

### Link önizleyiciler

[aç]
**Örnekler:** WhatsApp, facebookexternalhit, Twitterbot, LinkedInBot, Slackbot, TelegramBot, iMessage önizlemesi.
**Nasıl tanınır:** Kullanıcı ajanındaki ad. Meta için AS32934 ağı, X için r-*.twttr.com, LinkedIn için *.fwd.linkedin.com ters DNS'i. iMessage önizlemesi linki gönderen kişinin telefonundan gelir.
**Neden bu tutum:** İnsanlar ürüne çoğunlukla WhatsApp ve sosyal medyada paylaşılan linkle gelir; önizlemesi kırık link tıklanmaz. Günlük paylaşımdan sonra Meta ve birkaç reklam denetleyicisi o sayfayı bütün dosyalarıyla yükler; bir sitede bu günde en çok ~500 istek tuttu.
**Dikkat:** Meta'nın eğitim tarayıcısı ile link denetimi aynı ağ bloğundan (57.141.0.0/16) gelir; bloğu ağ olarak reddetmek paylaşımları kırar, eğitim tarayıcısı adıyla ayrılır. Düz Chrome ajanı gönderen önizleyiciler de beklenir; tarayıcı başlık kontrolü onları yanlış yakalayabilir, bu yüzden o kural gölgede kalır.

### E-posta link tarayıcıları ve güvenlik firmaları

[aç]
**Örnekler:** Microsoft Safe Links (134.149.116.0/24), Kaspersky, Zscaler, Fortinet, Proofpoint, Mimecast, Cisco Umbrella, Trend Micro, Palo Alto, Netskope, Forcepoint, Barracuda, Symantec.
**Nasıl tanınır:** Firmanın ASN'si, sahip adı RIPEstat'ta kontrol edilerek (19 ASN). Microsoft'ta yalnız tarayıcının görüldüğü /24 alınır; AS8075'in geri kalanı herkesin kiralayabildiği Azure'dur. Kullanıcı ajanına bakılmaz: Microsoft hiç göndermez, Kaspersky YaBrowser/Chrome 110 der, Fortinet Firefox der.
**Neden bu tutum:** Kurum ve şirket proxy'leri bir alan adını bu firmaların koyduğu kategoriye göre açar ya da kapatır. Reddedilen bir kategorileyici alan adını derecesiz bırakırsa ofisteki herkes için site kapanabilir. E-posta tarayıcıları da bültendeki linkleri kendi adreslerinden açıp kontrol eder.
**Dikkat:** Microsoft'un tarayıcısı 6 Eki'de linkleri kullanıcı ajanı olmadan düz bir GET ile açtı; sessiz liste olmasa boş ajan kuralı her bülten linkine 403 döndürürdü. Aylık yenileme sahip adı tutmayan numarayı listeden düşürür, yeniden atanmış bir ASN izin listesine girmez.

### Tarayıcı kılığında bulut kazıyıcıları

[engelle]
**Örnekler:** Alibaba Cloud 47.79.0.0/16 (AS45102) ve Alibaba Çin (AS37963); Tencent (AS132203, AS45090) ve onun 2019 tarihli 'iPhone OS 13_2_3' ajanı; OVH'ta adres döndüren Chrome/148 kazıyıcısı; saniyede 19 sayfa çeken tek adresli site aynalayıcıları.
**Nasıl tanınır:** Ağ: bu ASN'lerin RIPEstat'ta duyurduğu bütün prefix'ler. Tencent kazıyıcısı 60'tan fazla farklı prefix kullandı, /24 listesi tutmaz. Davranış: yalnız HTML, asset ve _rsc yok, robots.txt hiç okunmaz, Referer sahte 'google.com' (Alibaba'da isteklerin %99,6'sı), saat başı başlayan toplu iş, her istekte yeni adres.
**Neden bu tutum:** Alibaba kazıyıcısı günde 275 istekle başladı ve ~25.000'e çıktı; web isteklerinin %41'ini, UI baytlarının %44'ünü aldı ve gece bellek taşmalarının büyük nedeni oldu. 403 kuralı açıldıktan sonraki 24 saatte 6.654 istek reddedildi. 517.285 istekte bu aralıklardan tek bir uygulama isteği gelmedi.
**Dikkat:** Operatör başka buluta taşınabilir; her gün en çok yalnız-HTML belge çeken reddedilmemiş barındırma ASN'leri listelenir. Kapıdan sonra kalan barındırma trafiği ASN başına saatte 60'ı geçmedi, Alibaba saatte 250–1.500 çalışıyordu. OVH, AWS, Azure, Google Cloud ve Cloudflare bütün olarak engellenmez: kendi SSR çıkışımız, doğrulanmış AhrefsBot, VPN'li uygulama kullanıcıları ve bir kişi adına çalışan AI tarayıcı ajanları oradan gelir. Bu bulutlardaki bazı adresler tam render da yapar; asset yüklemek insan kanıtı sayılmaz.

### Konut proxy havuzları

[izle]
**Örnekler:** Binlerce ev ve mobil hattan dönen kazıyıcılar (bir sitede 15,9 saatte 7.656 adres, 2.331 ASN, ~100 ülke); her saat bir oran sayfasını farklı proxy adresinden çeken izleyici.
**Nasıl tanınır:** Adreslerin %98'i tek istek atar. Eski sürümlü masaüstü Chrome ajanları sırayla döner (14 ajan, Chrome/99–136). Yalnız HTML; asset, _rsc prefetch, Referer ve çerez yok; hep aynı URL listesi. Aynı sitede gerçek tarayıcılar sayfa isteklerinin %96'sını prefetch olarak yaptı.
**Neden bu tutum:** Adres ya da ağ engeli gerçek kullanıcıyı keser: havuzda 127 Türk ev hattı adresi vardı. Adres başına sınır onları hiç görmez. Bir sitede saatte 410–600 istekle süren, hâlâ sayfa alan en büyük kazıyıcı buydu.
**Dikkat:** Başlık kontrolü tek satırlık bir ayarla atlatılır: Sec-Fetch başlığını eklemek ya da Safari veya Firefox ajanına geçmek yeter. Durdurmak ücretli bot yönetimi ister (Cloud Armor Enterprise, proje başına ~$200/ay ve reCAPTCHA). İnsan kanıtı olarak Türk operatör ağı ya da /_next/static yüklemesi kullanılamaz; havuz Türk ev hatlarını kullanıyor, bazı bulut adresleri tam render yapıyor. Geçerli kanıt, aynı adresten 2 dakika içinde JavaScript'in attığı bir istektir.

### Zafiyet taramaları

[engelle]
**Örnekler:** /.env ve türevleri, /.git/config, /.aws/credentials, wp-admin, wp-login, xmlrpc.php, *.php, phpinfo, Vite'ın /@fs/ yolu, id_rsa, server.key.
**Nasıl tanınır:** Yol listesi açıkça yazılır. 'Nokta ile başlayan klasör' gibi genel bir kural yazılmaz, çünkü /.well-known uygulama linklerini taşır. Taramalar çoğunlukla 1–2 dakikalık, adres başına 100–300 isteklik patlamalardır.
**Neden bu tutum:** Bir sitede trafiğin %65'i taramaydı ve hiçbiri 200 almadı. Kapıdan önce /xmlrpc.php benzeri bir yol 68.774 baytlık ana sayfayı 3 arka uç çağrısıyla render ediyordu; şimdi 10 baytlık 404 ~1 ms'de döner.
**Dikkat:** Tarama yapan adres sonradan yasaklanmaz: bir xmlrpc taraması ev ve mobil hatlardan geliyordu, yasak operatör NAT'ındaki komşuları keserdi. Harf sınıfı olmayan matcher'da /WP-LOGIN.PHP gibi büyük harfli deneme kapıya ulaşmaz ve ana sayfayı alır.

### Boş, URL biçimli ya da kesik kullanıcı ajanı

[engelle]
**Örnekler:** Hiç kullanıcı ajanı göndermeyen webshell avcıları (Azure); ajanı bir URL olan kit ('http://<site>/wp-admin/install.php?step=1', Cloudflare Workers çıkışından); tam olarak 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' diye biten kesik ajan.
**Nasıl tanınır:** Ajanın kendisi; hiçbir tarayıcı boş, URL biçimli ya da bu kesik ajanı göndermez. Ek koşul: istek Accept-Language ve Sec-Fetch-Mode da göndermiyor olmalı. Ajanı silen bir proxy'nin arkasındaki tarayıcı bu ikisini yine gönderir.
**Neden bu tutum:** Bir sitede Azure'daki 15 adresin 6 günde attığı 6.222 isteğin hepsi boş ajanlıydı ve hepsi webshell aramasıydı. Kesik ajan, Google Cloud ve Hong Kong'daki tarama kitlerinin imzası.
**Dikkat:** Microsoft'un e-posta link tarayıcısı hiç ajan göndermez; sessiz liste olmasa bülten linkleri 403 alırdı. URL biçimli ajanı gönderen kit Cloudflare'in paylaşılan çıkış adreslerinden gelir; adresle engellenemez.

### Adresi okunamayan istekler (0.0.0.0)

[sınırla]
**Örnekler:** ShapBot, Reflectionbot, Scrapy, Claude-User, bir fbclid HEAD denetleyicisi; bir sitede 3 günde 22.750 satır.
**Nasıl tanınır:** Cloud Run istek logunda remoteIp 0.0.0.0. Kapıda X-Forwarded-For'un son elemanı boş, okunamaz ya da 0.0.0.0.
**Neden bu tutum:** Ağ kuralı bu istekleri göremez. ShapBot'un 38.022 isteklik patlaması ancak beyan ettiği adla durdurulabilirdi.
**Dikkat:** Sebebi bilinmiyor. Bu yüzden adressiz istek hiçbir kuraldan muaf tutulmaz; ad kuralları ve ortak hız kovası her zaman uygulanır. Ortak kova önce gölgede çalışır, çünkü içinde kullanıcı adına çalışan getiriciler de var.

### Sahte Googlebot ve sahte AI bot iddiaları

[engelle]
**Örnekler:** Google Cloud'daki tarama kitlerinin sırayla taşıdığı 29 bot adı: Googlebot, GPTBot, OAI-SearchBot, ChatGPT-User, ClaudeBot, PerplexityBot, meta-externalagent ve diğerleri.
**Nasıl tanınır:** Ajan doğrulanabilir bir ad taşıyor, adres o yayıncının aralığında yok. Google için tarayıcı dosyaları ve Google'ın kendi alanı (goog.json eksi cloud.json) kabul edilir, Cloud Run'ın paylaşılan çıkışı çıkarılır.
**Neden bu tutum:** Kendi testlerimiz dışında, bir penceredeki doğrulanamayan arama botu iddialarının hepsi Google Cloud (270) ve Hetzner (2) tarama adreslerindendi. Adında 'bot' geçen ajan tarayıcı başlık kontrolünden de muaf olduğu için, reddedilmeyen sahte ad bütün katmanları geçen bir kaçış yolu olur.
**Dikkat:** Aralık listesi bayatlarsa gerçek Googlebot 403 alır ve arama trafiği kaybolur. Liste düzenli yenilenir ve Search Console tarama istatistiklerinde 429 ile 5xx izlenir.

### Kendi trafiğimiz

[aç]
**Örnekler:** Sitenin kendi sunucusunun API çağrıları (Cloud Run çıkışı 34.96.0.0/14 ve 2600:1900::/28, ajan 'node'), uptime kontrolleri, Cloud Build işçileri, kendi betiklerimiz.
**Nasıl tanınır:** İç anahtar (web sunucusunun API sırrı) ve kapı anahtarı başlığı. Cloud Run çıkış aralığı tek başına kanıt sayılmaz, çünkü aynı aralığı herkes kiralayabilir.
**Neden bu tutum:** Bir sitede isteklerin %17'si sitenin kendi sunucusunun API çağrılarıydı; Google Cloud'u ağ olarak engellemek siteyi kırardı. Kendi betiklerimiz 10 saniyede 114 sayfa çekip hız kovasına takıldı.
**Dikkat:** Kendi adresinizi 'dışarıdan biri' testi için kullanmayın; sahte ajanlı testler logda sahte bot gibi görünür ve sayımları bozar. Kapı anahtarı yalnız hız ve başlık katmanlarını atlar; tarama, ad ve ağ kurallarına takılır.

Katman 9 / 11

# E-posta

Kod mailleri ayrı bir alt alan adından, outbox'tan ve gönderim bütçesinden geçerek gider.

38 gün
Kod mailleri dört kurumun posta geçidinde bekleyen alan adının yaşı. Kategori başvurusu aynı akşam döndü.

## Yap

[kanıtlı]
** İşlem maili aynı transaction'da dedupe_key'li outbox'a yazılır**; mail hatası girişi bozmaz.
[öneri]
** Outbox'ı yazan istek boşaltır**: min 0'da arka plan döngüsü yok ve CPU istek dışında kısılır. Satırı yazan istek commit'ten sonra onu aynı istekte gönderir ve 'sent' işaretler; hata isteği bozmaz, satır beklemede kalır. Outbox'a yazan sonraki istek birkaç eski satırı da dener, sabah penceresindeki job kalanı süpürür. Bu iki yol 1 saatten eski gönderilmemiş satır görünce ERROR yazar, alarm bu satırdan kurulur. Satır yaşı için saatlik iş kurulmaz: saatlik yoklama veritabanını %11 uyanık tutar, ayda ~₺101 eder. Giriş kodunun gönderim hatası zaten ilk seferde acil alarmdır.
[kanıtlı]
** SPF, DKIM, DMARC ve BIMI ilk gönderimden önce**; alan adı haftalar önce alınıp ısıtılır.
[öneri]
** Resend AB bölgesinde**; kodlar auth., bülten news.'ten. Free 3 alan adı veriyor ve her alt alan adı ayrı sayılır: apex, auth. ve news. kotayı doldurur. Test ortamı prod'un sağlayıcı hesabından gönderirse aynı günlük 100'ü yer ve prod'daki ortak sayaç bunu görmez. Free'de test için dördüncü alan adı da yok. Bizde test ortamının SMTP ayarı boş: kodlar test API'sinin loguna düşer, izinli adresler sabit kodla girer. Test ortamından gerçek gönderim yalnız kurulumdaki tek doğrulamadır; auth.'tan, izin listesindeki bir adrese gider.
[kanıtlı]
** Kod maili linksiz, uzak görselsiz, logo CID**; kod 30 dk, canlı kodlar FOR UPDATE ile kilitlenir; 60 sn'lik 'tekrar gönder'.
[öneri]
** Konu ve ilk satır kodu adlandıran sözden hemen sonra verir** ('… kodunuz: 482915'); İngilizce kalıp bir uygulamamızda iPhone'da önerildi, Türkçe kalıp doğrulanmadı.
[öneri]
** Kota tüketmeye karşı adres ve IP sınırları ile UTC gününe göre ortak sayaç veritabanında durur**: 70'te uyarı, günün toplamı 80'e varınca toplu gönderim durur, giriş kodları 100'e kadar gider; 100 dolarsa kodlar yedek sağlayıcıdan. Web'deki kod formunda Turnstile, mobil kod ucunda App Check.
[kanıtlı]
** Toplu mail yalnız doğrulanmış adreslere**; RFC 8058 List-Unsubscribe; GET hiçbir şey değiştirmez; belirsiz sonuç 'sent_pending' kalır.

## Başlangıç ayarları

[ölçüldü]
Resend Free: 3.000/ay, 100/gün, 3 alan adı; Pro $20/ay, 10 alan adı. Kota dolunca API 429 döner, mail gitmez.
[kanıtlı]
Adres başına saatte 8, IP başına saatte 40 kod, 60 sn bekleme.

### Kaçın

[kanıtlı]
Kod mailinde link ya da uzak görsel; 10 dakikada ölen kod.
[ölçüldü]
Kod ve bülteni aynı kotadan sınırsız göndermek; sağlayıcı değiştirmenin itibarı düzelteceğini sanmak.

### Bizdekinden iyisi

[öneri]
Gönderim bölgesi ilk gün AB seçilir; sonradan değiştirmek destek ister ve DKIM değişebilir.
[öneri]
Haftalık abone ~60'ı geçince bülten günün 80'lik payına sığmaz: günlere yayılır, ya da Resend Pro veya bülten için SES ($0,10/1.000) alınır.

### Nereden öğrendik projelerimizden, 2026

**2 Eki** dört kurumun posta geçidi 38 günlük alan adının kodlarını bekletti; başvuru aynı akşam döndü, kod 30 dk oldu.
**18 Ağu'ya kadar** bir projemizde outbox'ı boşaltan bir şey yoktu.
