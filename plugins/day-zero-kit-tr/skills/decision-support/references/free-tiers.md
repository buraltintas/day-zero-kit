<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="ucretsiz"></a>

Ücretsiz katmanlar

# Ücretsiz katmanları sonuna kadar kullanmak

Küçük bir ürün doğru kurulursa bulut faturası ayda ~₺55–135'te kalır ve bunun çoğu Neon Launch'ın kullanım bedelidir. Bunun için her ücretsiz sınırın ne kadar olduğu, ne zaman sıfırlandığı ve aşınca ne olduğu baştan bilinir.

Sınırlar 8 Ekim 2026'da resmi sayfalardan okundu ve ikinci bir geçişte sayfa metinleriyle tek tek karşılaştırıldı. Kullanımımız 1 Eylül–8 Ekim faturasından ve Monitoring'den, salt okunur. İki faturalama hesabımız var, her birinde iki ürün; aşağıda hesap 1 ve hesap 2 diye geçer.

## Bir faturalama hesabı, bir gerçek ürün

Ücretsiz katman faturalama hesabı başınadır; aynı hesaptaki projeler aynı kotayı paylaşır. Eylül'de hesap 1'deki iki ürün build kotasını birlikte 621 dakika aştı ve faturaya ₺187 yazıldı; ayrı hesaplarda ikisi de kotada kalırdı. Aynı hesaptaki ikinci ürüne ₺78 Cloud Run ücreti yazıldı, oysa kendi kullanımı kotanın altındaydı. Küçük bir ürünün gerçekten kullandığı kotaların değeri ayda ~$22: ~$15'i build dakikası, ~$6'sı Cloud Run.

ücretsiz kotadakotayı aşan, faturalananEylül 2026, build dakikası; ölçek gerçek
_Grafik: Eylül build dakikaları ve ücretsiz kota_
**Google Cloud Şartları**
Kural, kota için bir ürünü bölmek değildir. Google Cloud Şartları (madde 3.3) tek bir uygulamayı birden çok hesap ya da projeyle taklit ederek ücretten kaçınmayı ve kotayı dolanmayı yasaklıyor; ihlalde Google hizmeti askıya alabilir (madde 4.2). Her gerçek ürün kendi hesabında doğar, tek ürün hesaplara bölünmez. Hesaplar aynı ödeme profilinin altında açılır ve her birine bütçe alarmı kurulur. Ayrı hesap startup kredisinin doğru ürüne gitmesini ve ürünün devrini de kolaylaştırır.

## Neon Free'ye kim sığar

Aylık CU-saat, Ekim 2026 temposu (günlük ortalama × 30,4). Free'de proje başına ayda 100 CU-saat ve 5 GB çıkış var.

Free'de ya da sığarLaunch'ta kalmalıCU-saat/ay
_Grafik: Neon Free'ye kim sığar_

## Ücretsiz sınırlar, servis servis

Resmi sınır, sıfırlanma, aşınca ne olduğu, bizim kullanımımız ve sınırda kalmanın yolu. 8 Ekim 2026.

### Google Cloud

### Kapsam

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Sınırlar faturalama hesabı başına; aynı hesaptaki projeler paylaşır. Proje başına olan üç istisna: Logging 50 GiB, uptime 1 milyon çalıştırma, Firestore. Kredi değildir, devretmez; Google 30 gün önceden haber vererek değiştirebilir.

**Aşınca:** Servis durmaz; aşan kısım standart fiyattan.

**Bizde:** İki hesap, her birinde iki ürün. Eylül'de hesap 1'deki iki ürün build kotasını birlikte aştı.

**Sınırda kalmak için:** Bir faturalama hesabına tek gerçek ürün; tek ürün kota için bölünmez.

### Cloud Run servisleri

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Ayda 180.000 vCPU-sn, 360.000 GiB-sn, 2 milyon istek (istek bazlı; ~$4,32 CPU ve ~$0,90 bellek değerinde). IAM'in reddettiği istek ücretlenmez. europe-west1 Tier 1, europe-west3 Tier 2.

**Aşınca:** Servis çalışır. Aktif süre $0,000024/vCPU-sn, $0,0000025/GiB-sn; milyon istek $0,40.

**Bizde:** Hesap 1, min 0'dan sonra: ayda ~310.000 vCPU-sn (%170, ~$3) ve ~4,4 milyon istek (2 kat, ~$1); çoğu bir sitenin kendi API'sine attığı SSR istekleri. Hesap 2: %28 ve %27.

**Sınırda kalmak için:** min 0, CPU yalnız istek sırasında, max-instances 2–3. Okumalar API belleğinden; site her sayfada kendi API'sine gitmez; test web'i ve yönetim IAM ya da IAP arkasında; kazıyıcı kapıda.

### Cloud Run Jobs

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Instance bazlı: ayda 240.000 vCPU-sn ve 450.000 GiB-sn; her instance en az 1 dk.

**Aşınca:** Aşan süre instance fiyatından.

**Bizde:** Günlük yedek ve migration job'ları kotanın çok altında.

**Sınırda kalmak için:** Toplu iş servisin içinde değil, ayrı job; job'lar veritabanının uyanık olduğu sabah penceresinde.

### İnternet çıkışı

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** europe-west1'den ücretsiz pay yok: ilk GiB'tan $0,12/GiB, 1 TiB'tan sonra $0,11. Ücretsiz 1 GiB yalnız Kuzey Amerika bölgelerinde. Aynı bölgedeki Google kaynaklarına trafik ücretsiz.

**Aşınca:** Aşan trafik ücretlenir.

**Bizde:** Hesap 1 Eylül'de 19,1 GiB; Ekim temposu ~46 GiB (~$5,5), çoğu tek siteden. Kıtalar arası imaj çekişi ayrıca 73 GiB, ₺282.

**Sınırda kalmak için:** Sıkıştırma; boyutlandırılmış, uzun önbellekli görsel; statik dosya CDN'den; kazıyıcı kapıda; build, AR ve Cloud Run aynı bölgede.

### Cloud Build

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Hesap başına ayda 2.500 build-dakika, yalnız varsayılan havuzdaki e2-standard-2. Google 'promosyon' diyor, değişebilir. Kuyruk sayılmaz.

**Aşınca:** Build çalışır; dakikası $0,006, saniye hesabıyla.

**Bizde:** Hesap 1 Eylül: 3.114 dk (faturada 3.121), 621 dk aşım, ~₺187. Hesap 2 Ekim temposuyla %40.

**Sınırda kalmak için:** Aynı commit bir kez build, test'teki digest prod'a; includedFiles ve ignoredFiles; iş bitince tek push; e2-standard-2.

### Artifact Registry

_**Sıfırlanma** Saatlik kullanım_ **Ücretsiz sınır:** Hesap başına 0,5 GiB, sonra ~$0,10/GiB-ay. Aynı konumda çekiş ücretsiz; Avrupa içi bölgeler arası $0,02, kıtalar arası $0,08/GiB ve üstü.

**Aşınca:** Aşan depolama ücretlenir.

**Bizde:** Hesap 1: 5,48 GB (~$0,46/ay). Hesap 2: 1,45 GB (~$0,08/ay). Temizlik kuralı dört projede canlı.

**Sınırda kalmak için:** Temizlik ilk gün, dry-run'ın kapalı olduğu okunarak; job'lar her sürümde yeni imaja çevrilir.

### Cloud Storage

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** 5 GB-ay Standard, 5.000 A ve 50.000 B sınıfı işlem; yalnız us-east1, us-west1 ve us-central1 kovalarında. AB bölgeleri kapsam dışı.

**Aşınca:** Aşan kullanım ücretlenir.

**Bizde:** Kovalar AB'de, toplam ~0,2 GB; depolama ayda bir kuruşun altında.

**Sınırda kalmak için:** Kişisel veri ücretsiz kota için ABD'ye taşınmaz; 5 GB'ın değeri ayda ~$0,10. Kova servisle aynı bölgede, yedek kovasında 30 günlük lifecycle.

### Secret Manager

_**Sıfırlanma** Her ay, orantılı_ **Ücretsiz sınır:** Hesap başına 6 etkin sürüm, 10.000 erişim, 3 rotasyon bildirimi. Disabled sürüm de etkin sayılır; yalnız Destroyed ücretsiz.

**Aşınca:** Etkin sürüm ayda $0,06; 10.000 erişim $0,03.

**Bizde:** Hesap 1: 24 etkin sürüm, 18'i ücretli (~$1,08/ay). Hesap 2: 16 sürüm, 10'u ücretli (~$0,60/ay).

**Sınırda kalmak için:** Her sırrın tek etkin sürümü; rotasyondan sonra eski sürüm devre dışı, yeni sürüm doğrulanınca yok edilir. Sır olmayan ayar düz ortam değişkeninde.

### Cloud Scheduler

_**Sıfırlanma** Her ay, günlük orantı_ **Ücretsiz sınır:** Hesap başına ayda 3 iş; duraklatılmış iş de sayılır, çalıştırma sayısı önemsiz.

**Aşınca:** İş başına ayda $0,10.

**Bizde:** Hesap 1: 9 iş, 6'sı ücretli (~$0,60/ay). Hesap 2: 3 iş, tam sınırda.

**Sınırda kalmak için:** Tek dağıtıcı iş, takvim kodda; sabah penceresindeki işler sırayla çalışır, veritabanı tek kez uyanır. Duraklatılan iş silinir.

### Cloud Logging

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Proje başına ayda 50 GiB; _Default kovasında 30 gün saklama ücretsiz, _Required hiç ücretlenmez.

**Aşınca:** GiB başına bir kez $0,50; 30 günden uzun saklama ayda $0,01/GiB.

**Bizde:** Eylül'de proje başına 0,07–1,63 GiB; en gürültülü projenin Ekim temposu ~7 GiB (%14). Dört projemizin _Default kovası global kaldı; kova sonradan taşınmaz.

**Sınırda kalmak için:** Önce uygulamada gürültü kısılır; gerekirse uptime, /health ve statik 2xx satırları dışlanır. Hata, kapı ve denetim satırı dışlanmaz. Yeni projede log kovası AB'de.

**Kurulum:** [öneri] Organizasyon varsa proje açılmadan önce: `gcloud logging settings update --organization=ORG --storage-location=europe-west1`. Yeni projenin `_Default` ve `_Required` kovaları böylece AB'de doğar. Organizasyon yoksa proje doğarken AB'de bir kova kurulur ve `_Default` yönlendiricisi ona çevrilir: `gcloud logging buckets create ab --location=europe-west1 --retention-days=30 --project PROJE`, sonra `gcloud logging sinks update _Default logging.googleapis.com/projects/PROJE/locations/europe-west1/buckets/ab --project PROJE`. Süzgeç ve dışlamalar yerinde kalır; 30 gün saklama aynı ücretsiz kotadadır. Bu yolda `_Required` kovası (yönetim denetim logları) global kalır ve KVKK belgesinde böyle yazılır. Logu okuyan iş ve log alarmları yeni kovada bir kez denenir; `gcloud logging sinks describe _Default --project PROJE` hedefte europe-west1 gösterir.

### Cloud Monitoring

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Google metrikleri sınırsız; ücretli metrikte ayda 150 MiB, API okumasında 1 milyon zaman serisi. Alarmlar bugün ücretsiz; ücret en erken 1 Eylül 2027'de, metrik referansı başına ayda $0,35. Uptime, billing ve kota metriğine bağlı alarm ücretsiz kalacak.

**Aşınca:** Ücretli metrik MiB başına $0,258'den.

**Bizde:** Ücretli metrik 0. Bir üründe 7 koşul, 3'ü uptime'a bağlı; ücret başlarsa kalan 4 koşul en çok ~$1,40/ay.

**Sınırda kalmak için:** Koşullar az ve anlamlı; erişilebilirlik alarmı uptime metriğine bağlanır.

### Uptime kontrolü

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Proje başına ayda 1 milyon çalıştırma; 3 bölgeden kontrol her turda 3 sayılır.

**Aşınca:** 1.000 çalıştırma $0,30.

**Bizde:** 3 kontrol, 3 bölge, 300 sn: ayda ~80.000 (%8); API'yi min 0'da sıcak tutan bu.

**Sınırda kalmak için:** 300 sn'de bir, 3 bölgeden; hedef veritabanına dokunmaz, yoksa Neon hiç uyumaz.

### Firestore ve Firebase

_**Sıfırlanma** Günlük, Pasifik gece yarısı_ **Ücretsiz sınır:** Firestore proje başına 1 GiB; günde 50.000 okuma, 20.000 yazma ve 20.000 silme. FCM ve Crashlytics ücretsiz.

**Aşınca:** Spark'ta işlem durur, Blaze'de ücret yazar.

**Bizde:** Firestore yok; Android push için FCM, ücretsiz.

**Sınırda kalmak için:** Küçük sayaç ve bayrak için seçenek, ama ikinci veri deposu ve ayrı KVKK konum kararı demek; tercih GCS işareti ve API belleği.

### BigQuery

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Ayda 1 TiB sorgu, 10 GiB depolama.

**Aşınca:** Aşan kullanım ücretlenir.

**Bizde:** Eylül'deki ₺657'lik harita API'si ve ₺282'lik imaj çekişi ancak fatura gelince görüldü.

**Sınırda kalmak için:** Faturalama dökümü ilk gün açılır; tutar her gün SKU bazında okunur.

### Veritabanı ve kenar

### Neon Free

_**Sıfırlanma** CU-saat ve çıkış her dönem; depolama sürekli_ **Ücretsiz sınır:** 100 proje; proje başına ayda 100 CU-saat (0,25 CU'da ~400 saat), 1 GB depolama (hesapta 20 GB), 5 GB çıkış, 6 saat geçmiş, 1 elle snapshot, 10 dal. 2 CU'ya kadar ölçekleme, 5 dk boşta uyku zorunlu, harcama bildirimi yok.

**Aşınca:** Compute dönem sonuna kadar askıya alınır, uygulama bağlanamaz. Depolama dolunca yazmalar hata verir; veri silinmez.

**Bizde:** Free'de iki proje: ayda ~14 ve ~4,5 CU-saat (%14 ve %5). Günlük kullanıcılı prod ayda ~95 CU-saatle sınırın dibinde, Launch'ta.

**Sınırda kalmak için:** max 0,25 CU (2 CU'da 100 CU-saat 50 saatte biter), günlük bütçe ~3,3 CU-saat; havuz tabanı 0, boşta 90 sn; okumalar bellekten. Gerçek kullanıcılı prod Free'de tutulmaz.

### Cloudflare Free

_**Sıfırlanma** Sürekli_ **Ücretsiz sınır:** DNS, ölçümsüz DDoS koruması, CDN, Universal SSL, Free Managed Ruleset, 5 WAF özel kuralı, 1 hız sınırı kuralı, Bot Fight Mode.

**Aşınca:** Kural sayısı plana bağlı; trafik ücreti yok.

**Bizde:** Bugün kullanmıyoruz; bot kapısı uygulamanın içinde.

**Sınırda kalmak için:** DNS ilk günden Cloudflare'de. Bot Fight Mode bütün alan adını kapsar, WAF'la atlanamaz; API kaydı proxy'siz (gri) tutulur, gri kayıt Cloudflare'den geçmediği için BFM ona dokunmaz. Webhook ya da uptime kontrolü turuncu bir host'a geliyorsa BFM kapalı kalır.

### Workers Free

_**Sıfırlanma** Her gün 00:00 UTC (03:00 TSİ)_ **Ücretsiz sınır:** Günde 100.000 istek, istek başına 10 ms CPU, 128 MB bellek, 50 alt istek, hesapta 5 cron.

**Aşınca:** Fail closed'da 1027 hata sayfası; fail open'da Worker atlanır. Worker yönlendiriciyse atlanan istek boş yer tutucu kökene gider ve site yine düşer.

**Bizde:** Kullanmıyoruz. Bir sitemizin web servisi 4–7 Eki'de, kazıyıcısıyla birlikte, günde ~56.000 istek aldı. Worker önde olsaydı bunların hepsi kotadan düşerdi.

**Sınırda kalmak için:** Worker'dan geçen her istek sayılır: sayfa, `_next/static` dosyası, görsel, bot ve uptime kontrolü. Worker önbellekten önce çalıştığı için önbellekten dönen istek de sayılır. Kapı Next'te olduğundan kapının reddettiği bot da kotadan düşer. Tarama yolu ve bulut ağı WAF kuralları Worker'dan önce çalışır, durdurdukları sayılmaz.

**İzleme:** Dağıtıcı job saatte bir, salt okunur bir token'la, Worker'ın o günkü istek sayısını Cloudflare'in GraphQL analitik API'sinden okur [öneri]. 50.000'de bugün, 80.000'de acil seviyesinde uyarı verilir. 80.000'e varmadan Workers Paid alınır, en az $5/ay (~₺245); geçiş panelden hemen olur. Yönlendirici Worker'da fail open kurtarmaz.

### Cloudflare R2

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Ayda 10 GB-ay, 1 milyon A ve 10 milyon B sınıfı işlem; internete çıkış ücretsiz.

**Aşınca:** $0,015/GB-ay; A işleminin milyonu $4,50, B'ninki $0,36.

**Bizde:** Kullanmıyoruz.

**Sınırda kalmak için:** Yalnız herkese açık ağır dosyalar gerçek bir çıkış kalemine dönüşürse.

### Turnstile

_**Sıfırlanma** Sürekli_ **Ücretsiz sınır:** 20 widget, sınırsız doğrulama, widget başına 10 alan adı.

**Aşınca:** Sınır yalnız widget sayısında.

**Sınırda kalmak için:** Gün 0'dan giriş kodu formunda ve öteki herkese açık formlarda; botlar e-posta kotasını tüketemesin diye.

### E-posta, mobil ve araçlar

### Resend Free

_**Sıfırlanma** Günlük 00:00 UTC (kayan değil); aylık dönemde_ **Ücretsiz sınır:** Günde 100, ayda 3.000 e-posta; 3 alan adı; 1 webhook; saniyede 10 istek (takım başına). Gelen e-posta ve To, CC, BCC'deki her alıcı ayrı sayılır.

**Aşınca:** Aşım yok: API 429 döner, e-posta gitmez.

**Bizde:** Giriş kodu günde 2–21. Haftalık bülten kendi günlük tavanıyla gider; kodlara pay kalır.

**Sınırda kalmak için:** UTC gününe göre ortak sayaç: 70'te uyarı, günün toplamı 80'e varınca toplu gönderim durur, kodlar 100'e kadar gider; toplu gönderim günlere yayılır; CC yok. Bülten sürekli günlere taşıyorsa Pro ($20).

### EAS Build Free

_**Sıfırlanma** Takvim ayının ilk günü (00:00 UTC gözlendi); devretmez_ **Ücretsiz sınır:** Ayda 15 iOS ve 15 Android build; hesaptaki bütün uygulamalar paylaşır. Düşük öncelikli kuyruk, 1 eşzamanlı build, build başına 45 dk, ayda 60 dk workflow.

**Aşınca:** Aşım ücreti yok; bulut build'i ayın 1'ine kadar alınmaz. Yerel build sınır dışı.

**Bizde:** Ekim'de (8'ine kadar) iOS 7/15, Android 6/15, iki uygulama; 3 dakikadan kısa sürede düşen bir build sayılmadı. Eylül'de iOS kotası bitti, bir sürüm Ekim'e kaldı.

**Sınırda kalmak için:** Build önermeden önce platform başına sayım; deneme build'i yerelde; iOS için ay sonuna 2–3 acil hak.

### EAS Update Free

_**Sıfırlanma** Her dönem_ **Ücretsiz sınır:** Ayda 1.000 MAU (dönemde en az bir güncelleme indiren kurulum), 100 GiB bant, 20 GiB depolama.

**Aşınca:** Aşım ücreti yok, plan dahil MAU ile sınırlı; Starter 3.000 MAU.

**Bizde:** OTA ile gidebilecek düzeltmeler mağaza build'i harcadı: 19 build'in 11'i yalnız JS idi.

**Sınırda kalmak için:** Yalnız JS düzeltmesini build harcamadan göndermek için; runtimeVersion ilk gün yazılır, güncelleme gerektiğinde yayınlanır.

### Expo Push, APNs, FCM

_**Sıfırlanma** Saniyelik_ **Ücretsiz sınır:** Ücretsiz; Expo push'ta proje başına saniyede 600 bildirim.

**Aşınca:** Fazlası oran düşene kadar hata alır.

**Bizde:** Hacim sınırın çok altında.

**Sınırda kalmak için:** Toplu gönderim parçalara bölünür; makbuzlar okunur, ölü token silinir.

### GitHub Free

_**Sıfırlanma** Ay başı_ **Ücretsiz sınır:** Özel depoda ayda 2.000 dk standart runner; Actions ve Packages için 500 MB. Linux dakikası $0,006, macOS $0,062. Hata veren iş de sayılır.

**Aşınca:** Ödeme yöntemi yoksa iş çalışmaz; varsa faturalanır, bütçeyle sınırlanır.

**Bizde:** Build ve deploy Cloud Build'de.

**Sınırda kalmak için:** Yedek havuz. Testler varsayılan olarak Cloud Build'de koşar. Bir hesap iki ay üst üste 2.500 Cloud Build dakikasını aşarsa test ve lint buraya taşınır. Yalnız Linux runner kullanılır, Google'a anahtarsız bağlanılır (Workload Identity Federation).

### Sentry Developer

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** 1 kullanıcı; ayda 5.000 hata, 5 GB log, 5 milyon span, 50 oturum kaydı; 1 uptime ve 1 cron monitörü.

**Aşınca:** Kotayı aşan olay kabul edilmez.

**Bizde:** Kullanmıyoruz; hatalar Cloud Logging, uptime ve 5xx alarmıyla.

**Sınırda kalmak için:** Kurulursa örnekleme, beforeSend ile kişisel veri temizliği, oturum kaydı kapalı, EU bölgesi.

### RevenueCat

_**Sıfırlanma** Aylık_ **Ücretsiz sınır:** Aylık takip edilen gelir $2.500'e kadar ücretsiz, bütün özellikler dahil.

**Aşınca:** Takip edilen gelirin %1'i.

**Bizde:** Eşiğin altında.

**Sınırda kalmak için:** Eşik ancak gelir artınca aşılır.

### Search Console, Bing

_**Sıfırlanma** Günlük_ **Ücretsiz sınır:** Ücretsiz; URL Inspection API site başına günde 2.000, dakikada 600 sorgu. IndexNow ücretsiz.

**Aşınca:** Sorgu reddedilir.

**Bizde:** Elle dizine ekleme isteği gözlemimize göre günde ~10'da tükeniyor (Google yazmıyor); her web deploy'u site haritasını IndexNow'a bildiriyor.

**Sınırda kalmak için:** Asıl yol site haritası ve IndexNow; elle istek yalnız yeni ve önemli sayfalar için.

### PostHog Free

_**Sıfırlanma** Her ay_ **Ücretsiz sınır:** Ayda 1 milyon olay, 5.000 oturum kaydı, 1 milyon bayrak isteği, 100.000 hata; 1 proje, 1 yıl saklama.

**Aşınca:** Kart yoksa kullanım limitte durur; sürpriz ücret yok.

**Bizde:** Kullanmıyoruz; KVKK değerlendirmesi bekliyor.

**Sınırda kalmak için:** Açılırsa oturum kaydı ve otomatik yakalama kapalı, yalnız tanımlı olaylar.

### Dış uptime

_**Sıfırlanma** Sürekli_ **Ücretsiz sınır:** UptimeRobot Free: 50 monitör, 5 dk aralık; plan hobi ve kâr amacı gütmeyen projeler için tanıtılıyor. Sentry Developer: 1 uptime monitörü.

**Aşınca:** Monitör sayısı plana bağlı.

**Bizde:** Kullanmıyoruz; Google'ın uptime kontrolü yetiyor.

**Sınırda kalmak için:** Önce Google'ın kontrolü; dış servis yalnız Google'ın kendisi çökerse haber almak için ikinci göz.

## Kurallar

1. Her gerçek ürün kendi faturalama hesabında doğar.

Ücretsiz katman hesap başınadır; aynı hesaptaki iki ürün Eylül'de ₺187 build ve ₺78 Cloud Run ücreti ödedi, ayrı hesaplarda ikisi de ₺0 olurdu. Tek ürün kota için hesaplara bölünmez (Google Cloud Şartları 3.3 ve 4.2).

2. Cloud Run min 0, istek bazlı faturalama, CPU yalnız istek sırasında.

Boşta bir min instance liste fiyatıyla 30 günde ~$9,7; faturamızda Eylül'ün 24 gününde ₺203 yazdı. API'yi 300 sn'de bir, 3 bölgeden veritabanına dokunmayan /health'e giden uptime kontrolü sıcak tutar: ayda ~26.000 çalıştırma, proje kotasının %3'ü. Startup CPU boost açık kalır.

3. Servisler europe-west1'de kalır; kişisel veri ücretsiz kota için ABD'ye taşınmaz.

europe-west1 Tier 1, fiyatı us-central1 ile aynı; europe-west3 Tier 2. GCS'in 5 GB'ı yalnız üç ABD bölgesinde geçer ve değeri ayda ~$0,10; KVKK ve gecikme bedeli bundan büyük.

4. Test web'i, yönetim ve iç servisler IAM ya da IAP arkasında açılır; test API'si ağda açık, girişi izin listeli.

IAM'in reddettiği istek ücretlenmez; tarayıcı ve kazıyıcı trafiği ne istek kotasını ne CPU'yu harcar ve saldırı yüzeyi küçülür. Mobil build IAM'i geçemediği için test API'si ağda açık kalır: giriş yalnız izinli adreslere, X-Robots-Tag noindex, en fazla 1 instance.

5. Build bir kez yapılır; test'te doğrulanan digest prod'a verilir.

2.500 dakika yalnız varsayılan havuzdaki e2-standard-2'yi kapsar. Bir ürünün Eylül dakikalarının %32'si (474 dk) aynı kodu test için yeniden build etmeye gitti. includedFiles ve ignoredFiles kullanılır, iş bitince tek push yapılır.

6. Artifact Registry'de temizlik ilk gün kurulur ve dry-run'ın kapalı olduğu okunur.

Kurallar haftalarca dry-run'da kaldı, depo 1,3 GB'a çıktı. Global tetikleyici imajı her build'de kıtalar arası çekti: Eylül'de 73 GiB, ₺282. Aynı konumda çekiş ücretsiz.

7. Scheduler'da tek dağıtıcı iş; takvim kodda durur.

Hesap başına 3 iş ücretsiz, duraklatılan da sayılır; her ek iş ayda $0,10 (~₺5). Rehberin istediği on kadar zamanlanmış iş (sabah veritabanı penceresi, yedek, haftalık proje dışı kopya, mağaza izleyicisi, site haritası ve drift kontrolü, kapı listesi yenilemesi, bülten, ertesi sabah kontrolü) tek dağıtıcı job'dan sırayla çalışır. Scheduler dağıtıcıyı saatte bir tetikler; dağıtıcı kodda yazılı takvime bakar, o saatin işlerini yürütür, ayrı imajlı yedek job'ını API'den çalıştırıp bitmesini bekler. Veritabanına dokunan işler aynı sabah saatinde toplanır, veritabanı da böylece tek kez uyanır; her ayrı uyanış havuzun 90 sn'si ve Neon'un 5 dakikasıyla en az ~6,5 dk compute yazar.

8. Secret Manager'da her sırrın tek etkin sürümü.

Devre dışı sürüm de ücretlenir, hesap başına yalnız 6 sürüm ücretsiz. Eski bir kimlik bilgisinin okunabilir kalması güvenlik açısından da istenmez.

9. Log kotası proje başına 50 GiB; dışlama filtresi ölçmeden yazılmaz.

En gürültülü projemiz ayda ~7 GiB (%14). Dışlanan satır aranamaz ve log alarmı onu görmez. IP taşıyan loglar için doğru yer AB'deki log kovası.

10. Alarmlar ilk gün kurulur, sayısı az tutulur.

Bugün ücretsizler; ücret en erken 1 Eylül 2027'de metrik referansı başına ayda $0,35 olarak başlar. Uptime, billing ve kota metriğine bağlı alarm ücretsiz kalır; erişilebilirlik alarmı bu yüzden uptime'a bağlanır.

11. Neon Free yalnız test ve gerçek kullanıcısı olmayan yan projeler içindir; gerçek kullanıcılı prod Launch'ta doğar.

Launch'ta aylık asgari ücret yok: kullanıcı gelmeden neredeyse ₺0, az trafikli üründe ayda ~₺50–80. Free'de kota bitince compute dönem sonuna kadar durur ve bildirim yok. Max CU 0,25 olur: 2 CU'da 100 CU-saat 50 saatte biter. Free'den Launch'a geçmek kolay; Launch'tan Free'ye inmek döküm, yükleme ve adres değişikliği demek.

12. Neon'un çıkışını ve CU-saatini aynı kaldıraç düşürür: herkese açık okumalar API belleğinden.

Free'de proje başına 5 GB çıkış var ve sorgu sonuçları da sayılır. Bellek kopyası bir projeyi günde 6,5'ten 1,3 CU-saate, ötekini 2,3'ten ~0,3'e indirdi.

13. E-posta sayacı UTC gününe göre ortak: günün toplamı 80'e varınca toplu gönderim durur, giriş kodları 100'e kadar gider, 70'te uyarı.

Resend Free'de aşım yok, gönderim 429 ile reddedilir; giriş kodu gelmezse kullanıcı içeri giremez. Kota 03:00 TSİ'de sıfırlanır; gelen e-posta ve her alıcı ayrı sayılır. Kod formuna Turnstile, mobil kod ucuna App Check konur ve bir yedek sağlayıcı hazır tutulur; dağıtık bir saldırgan günlük 100'ü bitirirse kimse giremez.

14. EAS build hakkı hesap başınadır ve bütün uygulamalar paylaşır.

Build önermeden önce platform başına sayılır, deneme build'i yerelde alınır, iOS için ay sonuna 2–3 acil hak bırakılır. Eylül'de iOS kotası bitti ve bir sürüm Ekim'e kaldı.

15. Test ve lint varsayılan olarak test dalının Cloud Build hattında koşar ([Parçalar ve akışlar](#mimari), akış 6). GitHub Actions yedek ücretsiz havuzdur.

Actions'a tek durumda geçilir: bir faturalama hesabı iki ay üst üste 2.500 Cloud Build dakikasını aşarsa. O zaman test ve lint Actions'a taşınır, deploy Cloud Build'de kalır. Önce build'i bir kez alıp terfi etmek ve includedFiles denenir. Actions'ta özel depoya ayda 2.000 dk verilir. Yalnız Linux runner kullanılır, macOS ~10 kat pahalı. Google'a Workload Identity Federation ile anahtarsız bağlanılır.

16. Cloudflare Free ön katman olunca DNS, SSL, önbellek ve WAF açılır; API kaydı proxy'siz (gri) tutulur.

Bot Fight Mode bütün alan adını kapsar, uç bazında ayrılamaz ve WAF'la atlanamaz; API ve mobil trafiğe sınama çıkarabilir. Gri kayıt Cloudflare'den geçmediği için BFM API'ye dokunmaz. Worker yönlendirici olduğunda fail open kurtarmaz: Worker atlanınca istek boş yer tutucu kökene gider ve site yine düşer. Günde ~80.000 isteğe varmadan Workers Paid'e ($5/ay) geçilir.

17. Kullanılmayan ücretli API kapalı tutulur; açılan her ücretli API'ye günlük kota ve anahtar kısıtı konur.

Bir harita API'si Eylül'de ₺657 yazdı. Açık duran ama kullanılmayan API sızan bir anahtarla fatura yazabilir. Ayrıntı [Pahalı dış API'ler](#pahali-api) bölümünde.

18. İlk gün her hesaba bütçe alarmı ve BigQuery faturalama dökümü.

Bütçe ücretsiz, döküm sorguları BigQuery kotasında kalır. Eylül'deki ₺657 ve ₺282'lik kalemler ancak fatura gelince görüldü; dökümle ilk gün görülürdü.

## İzleme

Ücretsiz kotanın sonuna gelindiğini fatura gelmeden görmek için.

| Ne | Nasıl | Eşik | Ne sıklıkla |
|---|---|---|---|
| Bütçe alarmı | Her faturalama hesabına bir Cloud Billing bütçesi; %50, %80 ve %100'de e-posta. | Beklenen aylık tutar; küçük ürün için ~₺150. | Sürekli, kurulum ilk gün |
| SKU bazında günlük maliyet | Faturalama dökümü BigQuery'ye; günlük sorgu tutarı SKU ve projeye göre toplar, önceki haftayla karşılaştırır. | Bir SKU'nun günlük tutarı önceki haftanın 2 katını geçerse. | Günde bir |
| Cloud Build dakikası | Hesaptaki her projede ay içindeki build süreleri gcloud builds list --project PROJE --region europe-west1 ile ve bir kez de --region global ile toplanır, ay sonu temposu hesaplanır. Bölge verilmezse komut yalnız global build'leri listeler. Bölgesel tetikleyicinin build'leri o zaman sayılmaz ve alarm hiç çalmaz. | Tempo 2.000 dk'yı (%80) geçerse. | Haftada bir |
| Cloud Run CPU ve istek | billable_instance_time (vCPU ile çarpılır) ve request_count, hesaptaki projeler toplanarak. | Ay sonu temposu 144.000 vCPU-sn ya da 1,6 milyon isteği (%80) geçerse. | Haftada bir |
| İnternet çıkışı | network/sent_bytes_count, kind=internet, servis bazında ve günlük. | Küçük üründe günde 1 GiB; ani artışın sebebi çoğu zaman bir kazıyıcı. | Günde bir, alarm |
| Log hacmi | logging billing/bytes_ingested, proje bazında aylık toplam. | Proje başına 25 GiB (%50). | Ayda bir; alarmla sürekli |
| Neon Free CU-saat ve çıkış | Tüketim API'si ve bildirim yok: proje sayfasındaki Usage okunur; uygulama her uyanışı nedeniyle 'db wake' satırı olarak loglar, ondan log metriği çıkar. | Ayın 15'inden önce 50 CU-saat ya da herhangi bir anda 80; çıkışta 2,5 ve 4 GB. 80'de önce uyandıranlar kapatılır, gerekirse Launch. | Haftada bir, son hafta günde bir |
| E-posta günlük sayacı | Gönderim bütçesi tablosu UTC gününe göre sayar; sayaç loga da yazılır, log alarmı kurulur. | 70'te uyarı, günün toplamı 80'de toplu gönderim durur, kodlar 100'e kadar gider. | Sürekli |
| EAS build hakkı | eas account:usage ile hesabın bu ayki kullanımı platform başına okunur; build listesi kotayı değil, gerçek build numarasını okumak içindir. | Bir platformda 12 build (%80): yalnız acil sürüm. | Her build'den önce |
| Sayıyla ücretlenen kalemler | Scheduler iş sayısı (duraklatılanlar dahil), Secret Manager sürümleri, AR boyutu ve cleanupPolicyDryRun, uptime kontrolü sayısı. | 3 iş, 6 sürüm, 0,5 GiB, proje başına 1 milyon çalıştırma; dry-run true ise hemen düzeltilir. | Ayda bir |
| Cloudflare Workers ve Sentry | Worker'ın günlük istek sayısı dağıtıcı job'la Cloudflare'in GraphQL analitik API'sinden okunur; Sentry kota kullanım sayfası (kullanılırsa). | Workers: 50.000'de bugün, 80.000'de acil ve Paid'e geçiş; Sentry: ayda 4.000 hata. | Workers saatte bir, alarmla; Sentry haftada bir |
| Ücretsiz katman şartları | Google Cloud, Neon, Resend ve Expo fiyat sayfaları yeniden okunur; alarm ücreti için Google'ın 90 ve 30 gün önceki bildirimleri izlenir. | Bir sınır değişirse bu tablo güncellenir. | Üç ayda bir |
