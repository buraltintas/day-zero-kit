<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="performans"></a>

Hız ve gecikme

# Performans

Hız ve maliyet aynı ayarlardan çıkar. Veritabanını uyutan, okumaları bellekten veren ve imajı küçük tutan kurulum hem ucuzdur hem hızlı.

Rakamlar 1–8 Ekim 2026'da dört projenin Cloud Run istek ve sistem kayıtlarından salt okunur sorgularla alındı; bir kısmı bağımsız ikinci bir sorguyla yeniden doğrulandı. Bütün Cloud Run servisleri europe-west1'de (Belçika), bütün Neon veritabanları Frankfurt'ta.

**2 ms** Bellekten verilen herkese açık okumanın p50'si. Aynı okuma veritabanından 28–80 ms'ydi.
**0,99 sn** Uyuyan Neon'u uyandıran isteğin p50'si; p90 2,25 sn, en çok 5,2 sn.
**0 / 25.409** Açılışta 30 sn bekleyen ve 401 yerine 503 dönen API'de 7 günde 5xx.
**%7** ISR'lı kurum sayfalarında 20 ms'nin altında kalan istek payı; önbellek her sunucunun kendi diskinde.
**6,2 sn** Site ile API aynı anda soğukken ilk isteğin p50'si; yalnız site soğukken 4,6 sn.
**~₺255/ay** Tek bir min-instances 1'in faturadaki tutarı. Yerine uptime kontrolü: ₺0.

## Uptime kontrolü soğuk başlangıcı keser

Servis başına günlük otomatik başlatma, 1–8 Ekim 2026. Kontrol 300 sn'de bir, 3 bölgeden, veritabanına dokunmayan sağlık ucuna.

uptime kontrollükontrolsüzbaşlatma/gün; ölçek gerçek
_Grafik: Uptime kontrolü ve günlük soğuk başlangıç_

## Ölçümler

Ne ölçüldü, ne çıktı, nerede ve ne zaman.

| Ölçüm | Değer | Nerede, ne zaman |
|---|---|---|
| Bölge yerleşimi | Cloud Run servisleri Belçika'da, Neon veritabanları Frankfurt'ta; her sorgu sağlayıcılar arası bir atlama. | Dört proje, 8 Eki |
| Veritabanı atlamasının bedeli | Veritabanısız uç p50 2 ms; iki komutlu yazma 39 ms; oturumlu okuma p50 107 ms, p90 1,22 sn. Komut başına ~15–20 ms (tahmin, bağlantı kurma dahil). | Ürün A API, 1–8 Eki |
| Bellek kopyası ile veritabanı yolu | Mağaza sayfası p50 28 ms'den 2 ms'ye (p99 76'dan 6'ya); keşif listesi 80'den 2'ye; öne çıkanlar p50 4,1 sn'den 2 ms'ye, p90 25,7 sn'den 262 ms'ye. | Ürün B API, 30 Eyl ve 6–8 Eki |
| Bellek kopyası ve Neon faturası | Günde 6,5'ten 1,3 CU-saate ve ~2,3'ten ~0,3'e. Değişiklik GCS işaretiyle ~30 sn'de bütün sunuculara yansıyor; işareti okumak ayda ~$0,04. | Ürün B, Ürün C, 3–6 Eki |
| Önbellekli herkese açık uçlar | Logolar, güncelleme politikası, oranlar, istatistik ve limitler p50 2 ms, p90 3–31 ms; önbellek boşken ya da veritabanı uyanırken p99 0,9–1,5 sn. | Ürün A API, 1–8 Eki |
| Neon uyanışı | Uyandıran 206 istek: p50 987 ms, p90 2,25 sn, en çok 5,2 sn; aynı servisin diğer istekleri p50 2 ms. Haftada 216 istek ve 43 açılış uyanışı. | Ürün C API, 1–8 Eki |
| Açılışta veritabanını beklemek | Tek 5 sn'lik ping uyuyan Neon'da 503 verdi. Artık 30 sn boyunca 0,25'ten 4 sn'ye ikiye katlanan aralarla deneniyor; oturumlu uç 401 yerine 503. 7 günde 25.409 istekte 5xx 0. | Ürün A API, 6 Eyl olayı; 1–8 Eki |
| Sunucunun hazır olması (p50 ve p90) | Go API'ler 0,80 ve 0,96 ile 2,16 ve 2,92 sn arası; Next siteleri 1,38 ve 1,91 ile 2,41 ve 3,22 sn; nginx statik portal 0,33 ve 0,50; Chromium servisi 1,94 ve 2,79. | 11 servis, 1–8 Eki |
| Soğuk sunucuya düşen ilk istek | Siteler p50 2,0–4,9 sn, p90 2,7–7,5 sn; API'ler p50 1,4–1,5 sn; statik portal 0,22 sn. | 1–8 Eki |
| Zincirleme soğuk başlangıç | Site ile API aynı anda soğukken p50 6,2 sn, p90 8,1 sn (97 kez); yalnız site soğukken 4,6 ve 5,7 sn (130 kez). | Bir site ve API'si, 1–8 Eki |
| Uptime kontrolü ve soğuk başlangıç | Kontrollü serviste günde 1,9–6,6 otomatik başlatma, soğuk sunucuya düşen istek %0,02–0,16; kontrolsüzde günde 8,3–33 ve %4,4–12,7. Sağlık ucu p50 2 ms. | 1–8 Eki |
| min-instances 1 | 1 vCPU ve 512 MiB sürekli açık: faturada 24 günde ₺203, tam ayda ~₺255; liste fiyatıyla boşta 30 günde ~$9,7. 2 Ekim'de 0'a indi. | Ürün A API, Eylül faturası |
| Startup CPU boost | 16 servisin hepsinde açık; kapalıyken ölçülmedi. 15 servis 1 vCPU, 512 MiB, eşzamanlılık 80; tarayıcı servisi 2 vCPU, 2 GiB, eşzamanlılık 2. | Dört proje, 8 Eki |
| İmaj boyutu ve açılış | Go 20–31 MB, hazır 0,8–2,2 sn; Docker'lı Next 77–92 MB, ilk istek ~2,0 sn; buildpack Next 420–456 MB, ilk istek 2,8–4,9 sn; nginx 35 MB, 0,33 sn. Bu bir ilişki, nedensellik ölçülmedi. | 8 Eki |
| Servis başına gecikme | Sağlık hariç 2xx ve 3xx, p50, p90, p99: en iyi API'ler 2, 4, 875 ms ve 5, 39, 128 ms; günlük kullanıcılı API 3, 172, 1.551 ms. Siteler p50 10–106 ms, p99 0,35–7,4 sn. | 10 servis, 1–8 Eki |
| Oturumlu ve önbelleksiz uçlar | Gelen kutusu p50 140 ms, p90 1,27 sn; kullanıcı bilgisi 107 ms ve 1,22 sn; admin girişi p50 804 ms. | Ürün A API, 1–8 Eki |
| ISR'ın gerçek isabeti | ISR 600 sn'lik sayfalarda 1.190 isteğin %7'si 20 ms altında, p50 155 ms, p90 2,08 sn. Önceden üretilen sayfa p50 17 ms. 24 saat ISR ve değişiklik işaretli sayfalarda p50 ~114 ms. | Üç site, 1–8 Eki |
| Sitenin kendi API'sini çağırması | Üretilen sayfa başına 1,73 API çağrısı; API'ye gelen 44.911 isteğin 44.557'si sitenin kendi sunucusundan. Gece botları SSR istek sayısını ikiye katlıyor. | Bir site ve API'si, 7–8 Eki |
| Anında görsel küçültme | Next görsel iyileştirici p50 226 ms, p90 994 ms. 512 MiB'lık sitede 7 günde 540 bellek aşımı ve 602 otomatik başlatma. | Bir site, 1–8 Eki |
| Statik dosyalar Cloud Run'dan | /_next/static p50 10 ms, p90 125–155 ms, p99 1,4 sn'ye kadar. Bir sitede sayfa ve API trafiği günde ~531 MB, statik ~20 MB. | Üç site, 1–8 Eki |
| İstek yolundaki uzun işler | Chromium ile sayfa çizme p50 9,4 sn, p90 24,8 sn, soğuk ilk istek ~18 sn; AI cevabı p95 6,7 sn. Yazma zaman aşımı 10 sn: daha uzun istekte iş sürse de istemci 503 alıyor. | 5 ve 8 Eki |
| Mobil uygulamanın API çağrıları | iOS p50 3 ms, p90 177 ms; Android p50 61 ms, p90 150 ms. Açılıştaki politika ve logo çağrıları p50 2 ms. Geçiş reklamından sonra sonuç ekranı 1,8 sn, reklamsız 1,3 sn (debug derleme). | Ürün A, 1–8 Eki |
| Veritabanını uyutmayan ayarlar | MinConns=2 ve 1 sn'lik bir zamanlayıcı veritabanını 7/24 uyanık tuttu: günde 6 CU-saat. MaxConnIdleTime 30 dk'dan 90 sn'ye indi; bedeli sessizlikten sonra ilk istekte ~1 sn. | İki API, 21–24 Eyl |

Ölçülemeyenler: startup CPU boost kapalıyken davranış, Belçika ile Frankfurt arasındaki atlamanın aynı bölgeye göre farkı ve mobil uygulamanın release derlemesinde açılış süresi.

## Kurallar ve rakamları

1. Sunucu ile veritabanı arasındaki her gidiş-dönüş sayılır: istek başına sorgu azaltılır, okumalar bellekten.

Bu yığında Cloud Run Belçika'da, Neon Frankfurt'ta; aynı şehir europe-west3 demek, o da Tier 2 fiyatlı ve domain mapping'siz, bu yüzden taşınmadık. Atlamanın tek başına payı ölçülmedi. Neon'un bölgesi sonradan değişmez; ilk gün seçilir ve açılışta bir 'SELECT 1' süresi loglanır.

**Rakam** Veritabanısız uç 2 ms, iki komut 39 ms, oturumlu okuma 107 ms.

2. min-instances 0 kalsın; ayakta tutmayı veritabanına dokunmayan sağlık ucuna giden uptime kontrolü yapsın, web ve API için ayrı ayrı.

Herkese açık her servisin kendi kontrolü olur: site ile API birlikte soğukken ilk istek p50 6,2 sn sürdü. 300 sn arayla ve 3 bölgeden servis başına günde ~864 istek, her biri 2–5 ms; ücretsiz kotanın çok altında. Kontrolsüz servislerde günde 8,3–33 otomatik başlatma oldu.

**Rakam** min 1 faturada ~₺255/ay. Uptime ile günde 1,9–6,6 başlatma, kontrolsüz 8,3–33. Soğuk istek payı %0,02–0,16'ya karşı %4,4–12,7.

3. Startup CPU boost her serviste açık.

Açılışın ilk saniyelerinde CPU kısılmaz; bedeli yalnız açılış saniyeleri. Kapalıyken ölçülmedi.

**Rakam** Hazır olma: Go p50 0,8–2,2 sn, Next 1,4–2,4 sn, statik 0,33 sn.

4. Havuzda MinConns 0 ve MaxConnIdleTime 90 sn; dinleyici hemen açılır, havuz tembel kurulur, veritabanı 30 sn içinde artan aralarla beklenir.

MinConns>0 ya da 1 sn'lik zamanlayıcı Neon'u hiç uyutmuyor. Tek 5 sn'lik ping ve çıkış, uyanan veritabanında 503 verdi. Herkese açık okumalar da veritabanı zaten uyanıkken belleğe yüklenir.

**Rakam** Uyanış p50 0,99 sn, p90 2,25 sn. 7/24 uyanık kalmak günde 6 CU-saat. 5xx 0/25.409.

5. Herkese açık okumalar bellekteki kopyadan; kopya her istekte GCS işaretine bakar, zamanlayıcıya bırakılmaz.

Botlar ve SSR uzun kuyruktaki sayfaları gezerek veritabanını 7/24 uyanık tutuyor. İstek dışında CPU kısıldığı için arka plan zamanlayıcısına güvenilmez.

**Rakam** 28 ms'den 2 ms'ye; 4,1 sn'den 2 ms'ye. Neon günde 6,5'ten 1,3 CU-saate. İşaret ayda ~$0,04, ~30 sn'de yansır.

6. ISR tek başına önbellek sayılmaz; herkese açık HTML kenarda yalnız purge bağlıysa tutulur.

CDN'de s-maxage yalnız yazma anında değişen URL'ler purge ediliyorsa kullanılır; oturumlu yollar dışarıda kalır. Purge bağlanana kadar sayfa ISR ve değişiklik işaretiyle sunulur. ISR her sunucunun kendi diskinde; sunucular kapanıp açıldıkça ve botlar seyrek sayfaları gezdikçe isabet düşük. revalidateTag yalnız çağrıldığı sunucuyu temizliyor; geçersiz kılma değişiklik işaretiyle yapılır. Purge'süz kenar önbelleğinde yeni bir yorum bir gün görünmez; ayrıntı [Kenar, DNS ve alan adı](#katman-5) katmanında.

**Rakam** İsabet ~%7, p50 155 ms, p90 2,08 sn. Önceden üretilen sayfa p50 17 ms.

7. İmaj küçük: Go tek ikili, Next Docker ile standalone, statik SPA nginx'te; buildpack yok.

Büyük imajlı servislerde soğuk ilk istek daha uzun sürdü; bu bir ilişki, Google imaj boyutunun açılışı etkilemediğini yazıyor ve büyük imaj çoğu zaman daha ağır uygulama demek. Kesin kazanç fatura: her build'de kıtalar arası çekilen büyük imaj çıkış ücreti olarak yazıldı.

**Rakam** Go 20–31 MB, Next 77–92 MB (ilk istek ~2,0 sn), buildpack 420–456 MB (2,8–4,9 sn), SPA 35 MB.

8. Statik dosya ve görsel CDN'den; görsel yükleme anında boyutlandırılır, istek anında küçültülmez.

Cloud Run'da statik dosyanın p90'ı 125–155 ms. Anında küçültme hem yavaş hem bellek tüketiyor; 512 MiB'ta site yeniden başlıyor.

**Rakam** Görsel iyileştirici p50 226 ms, p90 994 ms; 7 günde 540 bellek aşımı.

9. N+1 sorgu ve geveze BFF yok: bir sayfa ya da ekran tek toplu API çağrısı, bir uç sabit sayıda sorgu.

Site sunucusunun kendi API'sine her çağrısı bir gecikme ve bir veritabanı uyanışı fırsatı; bot trafiğinde istek sayısını katlıyor.

**Rakam** Sayfa başına 1,73 API çağrısı; API trafiğinin %99,2'si sitenin kendi sunucusundan.

10. Ortalamaya değil p90 ve p99'a bakılır; her serviste haftalık p50, p90, p99, soğuk başlangıç, uyanış ve OOM sayısı.

Ortalama uyanışı ve soğuk başlangıcı gizler; kullanıcının hissettiği yavaşlık kuyrukta.

**Rakam** Günlük kullanıcılı API p50 3 ms, p90 172 ms, p99 1,55 sn; bir site p50 10 ms, p99 7,4 sn.

11. Uzun iş istek yolundan çıkar: tarayıcıyla çizim, toplu okuma ve rapor zamanlanmış işte; AI çağrısına zaman aşımı, yazma süresi o uca özel uzatılır.

Sunucunun yazma zaman aşımını geçen istek 503 alıyor, iş arkada sürse bile.

**Rakam** Chromium p50 9,4 sn, p90 24,8 sn; AI p95 6,7 sn; yazma zaman aşımı 10 sn.

12. Next sitesine 1 GiB bellek ve OOM alarmı; görsel iyileştirici kapalı, görseller yüklemede boyutlandırılır.

512 MiB'ta bot trafiği altında site bellek sınırını aşıp yeniden başlıyor; bu hem 5xx hem fazladan soğuk başlangıç demek.

**Rakam** 7 günde 540 bellek aşımı ve 602 otomatik başlatma (günde ortalama 86).

## Hedefler

Yeni projede ilk kullanıcıdan önce yazılır, haftalık okunur.

| Ölçüt | Hedef |
|---|---|
| Önbellekli herkese açık API okuması | **p50 ≤ 5 ms, p90 ≤ 10 ms** |
| API geneli (2xx, sağlık kontrolü hariç) | **p50 ≤ 10 ms, p90 ≤ 200 ms, p99 ≤ 1,5 sn** |
| Oturumlu, veritabanına giden okuma | **p50 ≤ 120 ms, p90 ≤ 300 ms** |
| Herkese açık HTML sayfası | **p50 ≤ 50 ms, p90 ≤ 500 ms, p99 ≤ 2,5 sn** |
| Herkese açık HTML'de kenar önbellek isabeti (yalnız purge bağlıysa; değilse yukarıdaki HTML gecikme hedefi geçerli) | **≥ %80** |
| Sunucunun başlaması ile hazır olması arası | **Go API p50 ≤ 1 sn, p90 ≤ 2 sn; Next p50 ≤ 1,7 sn; statik SPA ≤ 0,5 sn** |
| Soğuk sunucuya düşen ilk istek | **p50 ≤ 2,5 sn, p90 ≤ 5 sn** |
| Soğuk sunucuya düşen isteklerin payı | **≤ %0,2** |
| Uptime kontrollü serviste günlük otomatik başlatma | **≤ 3** |
| Neon uyanışını tetikleyen istek | **p50 ≤ 1 sn, p90 ≤ 2,5 sn; uyanış sayısı haftalık izlenir** |
| Neon günlük tüketimi (küçük proje) | **≤ 3,3 CU-saat/gün (Free'nin 100 CU-saat/ay sınırı), hedef ≤ 1** |
| 5xx ve bellek aşımı | **Haftada 0** |
| İmaj boyutu | **Go ≤ 30 MB, Next standalone ≤ 100 MB, statik SPA ≤ 40 MB** |
| Sayfa başına SSR'dan API'ye çağrı | **≤ 1** |
| Yazılan bir değişikliğin bütün sunuculara yansıması | **≤ 30 sn** |
| Sürekli açık sunucu maliyeti | **₺0 (min 0 ve uptime kontrolü); min 1 ancak faturada ayda ~₺255 göze alınırsa** |
