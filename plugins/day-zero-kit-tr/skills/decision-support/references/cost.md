<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="maliyet"></a>

Maliyet

# Ne tutar?

**Kısa cevap:** ₺510–690, Ürün A gibi günlük kullanıcısı ve sabah işleri olan bir ürünün rakamıdır. Ürün A 4–7 Ekim'de günde ortalama 3,18 CU-saat harcadı; Neon ~₺500, GCP ~₺110 ile ayda ~₺610 tutuyor. Öteki üç ürün bugün ayda ₺5–510 tutuyor. Dört ürünümüzün toplamı Eylül'deki ~₺3.900–4.400'den bugün ~₺1.300'e indi.

Az trafikli yeni bir ürünün bulut faturası ayda ~₺55–135 olur: prod Neon Launch'ta doğar ve aylık asgari ücret olmadığı için kullandığı kadar, ayda ~₺50–80 öder; Cloud Run ücretsiz kotada kalır. ₺500 bandına ancak gerçek kullanıcılar veritabanını her gün saatlerce uyandırmaya başlayınca çıkılır. Alan adı ve mağaza ücretleri bu hesaba katılmadı.

**Startup kredileri** yeni bir ürünün ilk 6–24 ayındaki faturasını sıfıra yakın tutabilir. Bizim yığında en değerlisi Neon'un kendi programı, çünkü en büyük kalem Neon; ayrıntı [Startup kredileri](#krediler) bölümünde.

## Üç basamak

Yeni başlayan ürün

~₺55–135/ay

Kim

Yeni açılmış, günde birkaç yüz istek alan, kullanıcısı henüz az olan ürün.

Para nereye gider

Neon Launch günde ~0,3–0,5 CU-saat (~₺50–80); aylık asgari ücret yok, kullanıcı gelmeden neredeyse ₺0. GCP'de para internet çıkışından (ücretsiz pay yok, ₺5–30), Secret Manager'ın 6'yı aşan sürümlerinden ve birkaç liralık GCS'ten gelir; Cloud Run, alarmlar ve tek Scheduler işi ücretsiz.

Varsayımlar

Prod Neon Launch'ta (0,25–1 CU, 7 gün geçmiş), CU-saat başına ~₺5,2; test ve gerçek kullanıcısı olmayan yan projeler Free'de ₺0. Cloud Run min 0'da çalışır, ayda 180.000 vCPU-sn, 360.000 GiB-sn ve 2 milyon istek ücretsizdir. Ürünün kendi faturalama hesabı vardır. Ürün D Launch'tayken günde ~0,45 CU-saatle Neon'a ayda ~₺70 ödüyordu; gerçek kullanıcısı az bir yan proje olduğu için 7 Eki'de Free'ye alındı.

Büyüyen ürün

~₺220–550/ay

Kim

Herkese açık SSR sayfaları tarayıcılarca gezilen, kullanıcısı gelmeye başlamış ve 7 günlük geçmişe ihtiyacı olan ürün. Bizde Ürün C ve Ürün B.

Para nereye gider

Neon Launch günde ~1–2 CU-saat (~₺160–320): SSR istekleri, tarayıcılar ve yönetim işleri. GCP ₺60–230: bot çıkış trafiği ve build dakikaları; alarmlar bugün ücretsiz.

Varsayımlar

Free'nin sınırları dar gelmiştir: 100 CU-saat/ay, 5 GB çıkış ve kullanıcı verisi için kısa kalan 6 saatlik geçmiş. Herkese açık okumalar API belleğinden verilir, kazıyıcılar kapıda reddedilir. Ürün C bugün ~₺220, Ürün B ~₺470–550 tutuyor.

Günlük kullanıcılı ürün

~₺510–690/ay

Kim

Her gün giriş yapan kullanıcıları ve her sabah çalışan okuma, rapor ve yedek işleri olan ürün. Bizde Ürün A.

Para nereye gider

Toplamın en az %60'ı Neon Launch compute (~₺436, günde ~2,8 CU-saat). GCP ~₺45–205: Secret Manager ~₺16, GCS ₺15–20, internet çıkışı ₺10–60 ve kota aşılırsa Cloud Run; alarmlar ve tek Scheduler işi ücretsiz. Günde her +1 CU-saat aya +₺158 ekler.

Varsayımlar

Model günde 2,8 CU-saat, ~1 GB veritabanı ve ürünün kendi faturalama hesabıyla kuruldu. Ürün A 4–7 Eki'de günde 2,12–4,03 CU-saat harcadı (ortalama 3,18); bu modele ~₺60 ekler ve sonuç aralığın içinde kalır: Neon ~₺500 + GCP ~₺110 = ~₺610. Her uyanış en az ~6,5 dk faturalanır (90 sn boşta kapanma + 5 dk uyku eşiği).

## Bizim dört ürünümüz, 8 Ekim 2026

Neon tüketimi 4–7 Ekim ölçümünden, günde sürekli 1 CU-saat ayda ~₺158. Ürün B'nin GCP payı ₺150–230 aralığının ortası.

NeonGoogle CloudTL/ay, 8 Ekim 2026; alan adı ve mağaza (Apple, Google) ücretleri hariç

_Grafik: Ürün başına aylık maliyet_

| Ürün | Neon | GCP | Toplam | Not |
|---|---|---|---|---|
| Ürün A | ₺500 | ₺110 | ₺610 | 4–7 Eki günde 2,12–4,03 CU-saat (ortalama 3,18): gerçek kullanıcılar ve sabah işleri. GCP rakamı faturadaki paydan tahmin edildi; ücretsiz kotaların ay ortasında bitmesi hesaba katıldı. Test veritabanı 7 Eki'den beri Neon Free'de ve ₺0. Alan adı hariç. |
| Ürün B | ₺320 | ₺190 | ₺510 | 4–7 Eki günde 1,32–3,07 CU-saat (ortalama 2,05). Yoğun katalog yönetimi nedeniyle 5 Eki'den sonra yeniden yükseldi; bellek kopyasından önce 6,5'ti. GCP ₺150–230, tabloda orta değeri var. Bu tutarın çoğu bot çıkış trafiğiydi; Alibaba kazıyıcısı 7 Eki'den beri engelli. |
| Ürün C | ₺160 | ₺60 | ₺220 | 7 Eki'de günde 1,00 CU-saat. Kategori kaçağı 6 Eki 12:54Z'de kapandı. Hedef günde ~0,3; o noktada Neon ~₺50, toplam ~₺110 olur. |
| Ürün D | ₺0 | ₺5 | ₺5 | 7 Eki'de Neon Free'ye taşındı; önceden günde ~0,45 CU-saat, ayda ~₺70 tutuyordu. Kalan gider GCP'de ~₺5. |
| Toplam (dört ürün) | ₺980 | ₺365 | ₺1.345 | Ürün B'nin GCP aralığına göre ₺1.305–1.385, yani ~₺1.300. Eylül'de ~₺3.900–4.400'dü (49 TL/$). Alan adı ve mağaza (Apple, Google) ücretleri bu toplamda yok. |

## Faturayı düşüren kaldıraçlar

| Kaldıraç | Etkisi | Dayanak |
|---|---|---|
| Herkese açık okumaları API belleğinden vermek | Ürün B'de ayda ~₺700–820; Ürün C'de bugün ~₺205, hedefte ~₺320 | Ürün B'de katalog bellek kopyası 3 Eki'de açıldı. Neon günde 6,5'ten 1,3 CU-saate indi (6 Eki); yoğun katalog yönetimi olan günlerde 2–3 arasında. Ürün C bellek önbellekleriyle 2,3'ten ~0,3'e indi (3 Eki); 5 Eki'deki kategori kaçağı onu yeniden yükseltti, 7 Eki'de günde 1,00'dı. Bugünkü kazanç ~₺205, ~0,3'e inince ~₺320. |
| Ücretli API'yi kota tavanıyla açmak | Bir üründe ayda ~₺657 | Bir harita API'sinin fotoğraf ve detay çağrıları Eylül faturasına ₺657 yazdı. API 21 Eyl'de kapatıldı. Bundan sonra kural şu: ücretli API, günlük ve aylık rakamı ve tavanı yazılmadan açılmaz. |
| Veritabanını uyutan üç ayar: havuz tabanı 0, 90 sn boşta kapanma, zamanlayıcıyla yoklama yok | Günde her 1 CU-saat ayda ~₺158; Ürün A'da ayda ~₺475 | Ürün A prod 18–23 Eyl arasında günde ~6,2 CU-saat harcıyordu, yani 7/24 uyanıktı. Arka plan işleri trafiğe bağlanınca harcama ~3,2'ye indi. 0,25 CU'da 7/24 uyanık bir veritabanı ayda $19,1 (~₺935) tutar. |
| Build'i Artifact Registry ve Cloud Run ile aynı bölgede çalıştırmak | Bir üründe ayda ~₺282 | Global tetikleyici her build'de imajı kıtalar arası çekip gönderdi; Eylül'de 73 GiB çıkış ₺282 tuttu. Pull/push adımları 2 Eki'de kaldırıldı. |
| Min instance koymamak | Servis başına faturamızda ayda ~₺255 (1 vCPU, 0,5 GiB); liste fiyatıyla boşta 30 günde ~$9,7 (~₺476) | Konsoldan açılan minScale 1 tam ayda ~₺255 yazıyordu; 2 Eki'de 0'a indirildi ve 5xx sayısı 0 kaldı. API'yi veritabanına dokunmayan /health'e 300 sn'de bir, 3 bölgeden giden uptime kontrolü sıcak tutuyor. Boş bir dönemden sonraki ilk istek 1–2 sn gecikebilir. |
| Kazıyıcıyı uygulamanın kapısında reddetmek | Bir üründe GCP çıkışında ayda ~₺110; tek başına Neon'u düşürmez | Alibaba Cloud aralığından (47.74.0.0–47.87.255.255, en yoğunu 47.79.0.0/16) gelen sahte Chrome kazıyıcı robots.txt'ye uymadı. Günde ~25.700 istek attı, sitenin baytlarının %44'ünü tüketti ve gece OOM'larının büyük kısmına yol açtı; 7 Eki'den beri 403 alıyor. Neon'un uyuması için kalan trafikte 5 dakikalık boşluklar gerekir, engel tek başına bunu sağlamadı. |
| Küçük projeleri Neon Free'de tutmak | Ayda ~₺95 (iki proje); Ürün C hedefe inerse ~₺50 daha | Ürün D (günde ~0,45 CU-saat, ~₺70) ve test veritabanı (~0,15, ~₺24) 7 Eki'de Free'ye taşındı; her tablo md5 ile karşılaştırıldı. Free'de ayda 100 CU-saat aşılırsa veritabanı ay sonuna kadar durur ve uyarı gelmez. Bir proje plan değiştiremiyor; taşımak için döküm alıp yüklemek ve bağlantı adresini değiştirmek gerekiyor. |
| Günlük veritabanı işlerini tek sabah penceresinde toplamak | Küçük: her ayrı günlük uyanış 0,25 CU'da ayda ~₺4 | Ürün A'da işler haftada 6 gün, günde üç ayrı saatte veritabanını uyandırıyordu. Her uyanış en az ~6,5 dk faturalanır (90 sn boşta kapanma + 5 dk uyku eşiği). İşleri tek saate toplama planı önbelleklerle birlikte günde ~0,6 CU-saat (~₺95/ay) olarak hesaplandı; tutar küçük bulunduğu için uygulanmadı. |

## Maliyet modeli, kalem kalem

Ayda TL. 49 TL/$, $0,106/CU-saat, Ekim 2026 fiyatları.

| Kalem | Yeni başlayan | Gerçek kullanıcılı | Not |
|---|---|---|---|
| Varsayımlar | Az trafik, birkaç kullanıcı; Neon Launch günde ~0,3–0,5 CU-saat, test Free'de; Cloud Run min 0 ve ücretsiz kotada; ürünün kendi faturalama hesabı | Günlük kullanıcılar ve sabah işleri; Neon Launch günde ~2,8 CU-saat (ayda ~84), veritabanı ~1 GB, 7 gün geçmiş; ürünün kendi faturalama hesabı | 49 TL/$, $0,106/CU-saat, Ekim 2026. Günde sürekli 1 CU-saat ayda ~₺158 eder. Ürün A'nın 4–7 Eki ortalaması 3,18. |
| Neon compute | ~₺50–80 | ~₺436 | Launch'ta aylık asgari ücret yok, CU-saat başına ~₺5,2. Yeni başlayan: günde 0,3–0,5 CU-saat. Gerçek kullanıcılı: 84 × $0,106; Ürün A'nın ölçülen 3,18'i ~₺500 eder. 7/24 uyanık bir veritabanı 0,25 CU'da $19,1 (~₺935), 1 CU'da ~$76 tutar. |
| Neon depolama, snapshot, geçmiş | ₺0–5 | ~₺25–50 | $0,35/GB-ay depolama, $0,09/GB-ay snapshot, $0,20/GB-ay anında geri yükleme penceresi. Bizim veritabanlarımız küçük: 21 Eyl ölçümünde altı projenin toplam depolama ücreti $0,02'ydi. |
| Neon test | ₺0 (Free) | ₺0 (Free) | Ayrı bir Free projesi kullanılır. Ayda 100 CU-saat aşılırsa durur ve uyarı gelmez; Usage sayfası haftada bir okunur, 'db wake' log metriği alarmlıdır. |
| Cloud Run | ₺0 | ₺0–100 | Her ay 180.000 vCPU-sn, 360.000 GiB-sn ve 2 milyon istek ücretsizdir (faturalama hesabı başına). Min 1 açılırsa servis başına faturamızda ~₺255, liste fiyatıyla ~$9,7 (~₺476) eklenir. İki rakam neden farklı, henüz bilinmiyor. |
| Cloud Run internet çıkışı | ₺5–30 | ₺10–60 | europe-west1'den ücretsiz pay yok, ilk GiB'tan $0,12/GiB (~₺5,9). Kapı ve CDN önbelleği yoksa bu kalemi botlar büyütür: bot ağırlıklı bir sitede ayda ~41 GiB, ~₺240 ölçüldü; o durumda toplam üst sınırı aşar. |
| Cloud Build / Artifact Registry | ₺0 / ₺0 | ₺0 / ~₺5–10 | Ayda 2.500 dk ücretsiz, sonra $0,006/dk. Tek hesaptaki iki ürün Eylül'de 3.121 dk ile kotayı aştı (₺187). AR'de 0,5 GB ücretsiz, sonra $0,10/GB-ay; build aynı bölgede çalışır. |
| Secret Manager / GCS | ₺0–16 / ₺0–5 | ~₺16 / ~₺15–20 | Ölçülen tutar: 12 referans için ayda ~₺16. Yedek kovası ayda bir sentin altında, değişiklik işareti ayda ~$0,04. |
| Monitoring / Scheduler | ₺0 / ₺0 | ₺0 / ₺0 | Alarmlar bugün ücretsiz; ücret en erken 1 Eylül 2027'de, metrik referansı başına ayda $0,35 (uptime'a bağlı olanlar ücretsiz kalır). Scheduler'da tek dağıtıcı iş ücretsiz kotada; ayrı saatte çalışması gereken her ek iş ayda $0,10 (~₺5). |
| Cloudflare ve ön katman | ₺0 | ₺0 | Free plan ve Worker Free (günde 100.000 istek). Worker yönlendirici olduğu için günde ~80.000 isteğe varmadan Workers Paid, ayda $5 (~₺245). Global ALB ayda ~$18 + veri; Cloud Armor proje başına ayda ~$25–30. |
| Resend / EAS Build / hata takibi | ₺0 | ₺0 | Ücretsiz katmanlar: Resend ayda 3.000 mail (günde 100), EAS ayda 15 iOS + 15 Android build, Sentry Developer. Gerekirse Resend Pro $20, EAS Starter $19, Sentry Team $26. |
| EAS Update (OTA) | ₺0 | ₺0 | Kitte önerilir. Ayda 1.000 güncelleme indiren kuruluma (MAU) kadar Free; Free'de aşım ücreti yok, kullanım 1.000 MAU ile sınırlı kalır. Daha fazla kuruluma göndermek için Starter, ayda $19 (~₺930), 3.000 MAU. |
| Model ve ücretli API'ler | ₺0 (kapalı) | tavanla | Rakamı ve tavanı yazılmadan açılmaz. Bir ürünümüzün Eylül OpenAI toplamı $1,14'tü. Bir harita API'si Eylül'de ₺657 yazdı ve kapatıldı. |
| Toplam (bulut) | ~₺55–135 | ~₺510–690 | Gerçek kullanıcılı üründe toplamın en az %60'ı Neon; Ürün A'da ölçülen ~₺610 bu aralıkta. Eşik aşılınca eklenenler (yukarıdaki satırlarda) toplamda yok. Alan adı ve mağaza ücretleri hesaba katılmadı. |

Maliyet

# Maliyet kuralları

Rakam tahminle konuşulmaz; fatura proje ve SKU bazında okunur.

₺2.087

GCP için '$1/ay' denen ayda, Ağustos 2026'da faturalama hesabının toplamı.

## Yap

[ölçüldü]

**Fatura proje ve SKU bazında okunur**; ay başı rakamı yanıltır.

[kanıtlı]

**Ücretli API'de alanlar tek geçişte istenir**; cevaplar önbelleklenir, GCP'de API başına kota tavanı.

[ölçüldü]

**Model işleri kaynakta kısılır**: değişmeyen sayfa gönderilmez, günlük tavan, prompt önbelleği.

[öneri]

**Cloud Run çıkış trafiği izlenir**; bot baytı Cloudflare önbelleğiyle düşer.

## Başlangıç ayarları

[ölçüldü]

Neon $0,106/CU-saat; 0,25 CU 7/$2419,1, 1 CU 7/24 ~$76.

[öneri]

europe-west1'den internete çıkışta ücretsiz pay yok, ilk GiB'tan $0,12/GiB; Scheduler'da hesap başına 3 iş ücretsiz, sonra iş başına ayda $0,10.

[ölçüldü]

Instance başı günde 300 model çağrısı: bir instance ~$23/ay, 20 instance ~$470/ay.

### Kaçın

[kanıtlı]

Tahminden konuşmak; panikle min-instance; kıtalar arası pull/push.

### Bizdekinden iyisi

[ölçüldü]

Bütçe uyarısı ve kota tavanı yoktu; harita API'si Ağustos'ta ₺1.500 yazdı ve ancak fatura gelince görüldü.

### Nereden öğrendik projelerimizden, 2026

**Ağu** GCP için '$1/ay' tahminine karşı faturalama hesabının toplamı ₺2.087; bunun ₺2.081'i tek projenin faturası.

**6 Eki** dört ürünümüz ~₺1.590/ay tutuyordu; 8 Eki ölçümünde taşımalardan sonra ~₺1.300.
