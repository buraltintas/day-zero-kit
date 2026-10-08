<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="vakalar"></a>

Tecrübe

# Vaka defteri

Bu defter, dört ürünümüzde Ağustos ile Ekim 2026 arasında yaşadığımız 30 olayı, bize neye mal olduklarını ve onlardan çıkan kuralları anlatır. Rehberin geri kalanı bu kuralların ayrıntısıdır.

### Nasıl okunur

Her vaka aynı sırayla okunur: Belirti, Kök neden, Bedeli, Çözüm, Sonuç ve Kural. Sağ üstteki rakam bedeldir; bedel ölçülmediyse olayın büyüklüğüdür. Para olan rakamlar kırmızıdır. Kuralın sonundaki bağlantı, kuralın ayrıntısıyla durduğu bölüme gider; kuralın bizde henüz denenmemiş kısmı "öneri" diye işaretli. [ölçüldü] rakamın faturamızdan ya da logumuzdan geldiğini, [kanıtlı] çözümün canlıda çalıştığını gösterir.

## Vakalarda tekrar eden sekiz ders

Aynı ders birden çok olayda çıktı. Numaralar aşağıdaki vakalara gider.

1. **Faturayı büyüten şey görünmeyen tekrardı.** Veritabanını uyandıran her istek ve zamanlayıcı, her build'de kıtalar arası çekilen imaj, sayfa görüntüleme başına ücretli çağrı ve her sayfayı gezen kazıyıcı parayı götürdü. İstek ve sunucu sayısı bu sırada normal görünüyordu. Vaka [3](#vaka-3), [4](#vaka-4), [5](#vaka-5), [6](#vaka-6), [7](#vaka-7), [24](#vaka-24)

2. **En pahalı hata sessiz olandı.** 500 dönen webhook en az 21 gün, 402 alan paylaşım 30 gün fark edilmedi; kırık build 16 saat hiçbir deploy çıkarmadı. Erken görülenler bir kontrol sayesinde görüldü: yedekte boyut karşılaştırması, site haritasında haftalık zamanlanmış tarama, veritabanında 'db wake' logu. Vaka [6](#vaka-6), [23](#vaka-23), [25](#vaka-25), [26](#vaka-26), [29](#vaka-29)

3. **Sorun çoğu zaman okunmayan bir varsayılandı.** Deneme modunda kalan temizlik, şablonda 0 görünen min instance, havuz tabanı, Metro ortamını ezen .env, Next'in middleware'den önce sildiği başlıklar ve /api gövdesini 10 MB'ta kesen sınır böyleydi. Hepsi çalışan sistemin kendi durumuna bakınca göründü; belge ve kural listesi bunları göstermedi. Vaka [2](#vaka-2), [5](#vaka-5), [9](#vaka-9), [10](#vaka-10), [15](#vaka-15), [21](#vaka-21)

4. **Gerçek yolu taklit eden test yanılttı.** Build numarasını taklit eden birim testi, başlıkları kendisi kuran kapı testi, prod'un bağlantı modunu kullanmayan entegrasyon testi, paket grep'i ve canlı verisi olmayan test ortamındaki CSP provası hatayı göstermedi. Bir şey ancak gerçek telefonda, gerçek Next sunucusunda ya da canlı veriyle görülünce çalışıyor sayıldı. Vaka [9](#vaka-9), [13](#vaka-13), [15](#vaka-15), [18](#vaka-18), [25](#vaka-25)

5. **Yutulan hata pahalıya çıktı.** Hata boş listeye ya da 401'e çevrilince, ya da hiç loglanmayınca, site haritasından 2.668 sayfa düştü, 23 Eyl öncesinin olay kayıtları kayboldu ve uyuyan bir veritabanı bütün kullanıcıları oturumdan atabilecek hale geldi. Dürüst hata, yani 5xx ve log satırı, her seferinde daha ucuz çıktı. Vaka [14](#vaka-14), [23](#vaka-23), [25](#vaka-25), [26](#vaka-26)

6. **Mağazadaki bir build'e sonradan kanal eklenemiyor.** Güncelleme uyarısı, sunucudan metin alanı, sürüm başlığı, yetenekler ve OTA ilk sürümde yoksa o kullanıcıya bir daha ulaşılamıyor ya da her küçük düzeltme bir build hakkı yiyor. Vaka [18](#vaka-18), [19](#vaka-19)

7. **Ölçmeden söylenen rakam yanlış çıktı.** Ayda 1 dolarlık maliyet tahmini, 12–24 sayfa gezen ChatGPT oturumları ve 'Google'dan gelen' trafik böyleydi. Önce fatura, log ve saatlik tüketim okununca karar doğru yere gitti. Vaka [1](#vaka-1), [9](#vaka-9)

8. **Riskli değişiklik gölgede başlayıp anahtarla kapanabildiğinde ucuz kaldı.** Katalog kopyası bir gün gölgede veritabanıyla karşılaştırıldı, bot kuralları önce 'reddederdim' yazdı, AI asistan tek bir ortam değişkeniyle kapandı. Gölgesiz açılan tek kural ilk gün yanlış ziyaretçiyi reddetti. Vaka [5](#vaka-5), [8](#vaka-8), [9](#vaka-9), [17](#vaka-17)

## Düzeltmelerin toplamı

**Ölçülmüş düzeltmelerin aylık etkisi:** ~₺2.580–2.700/ay

**Eylül'de ~₺3.900–4.400 olan dört ürünün bulut faturası:** ~₺1.300/ay, 8 Eki

Altı düzeltmenin tasarrufu ayrı ayrı ölçüldü ve toplandı; küçük projeler Neon Free'ye taşınınca ~₺2.672–2.791. Fatura ~₺2.600–3.100 düştü. İki hesap birbirini tutuyor.

| Kalem | Ürün | Vaka | Aylık etki | Nasıl hesaplandı |
|---|---|---|---|---|
| Katalog okumaları bellekte | Ürün B | [5](#vaka-5) | ~₺700–820 | 6,5'ten 4–7 Eki ortalaması 2,05 CU-saat/güne (4,45 × ₺158 ≈ ₺703) ya da 6 Eki'deki 1,3'e (5,2 × ₺158 ≈ ₺822) |
| Harita API'si kapandı | Ürün B | [24](#vaka-24) | ₺657 | Eylül faturası; Ağustos'ta ₺1.500'dü, düşük olan alındı |
| Veritabanı uyuyor | Ürün A | [4](#vaka-4) | ~₺475 | (6,2 − 3,2) CU-saat/gün × ₺158 |
| Kıtalar arası adımlar kalktı | Ürün B | [3](#vaka-3) | ₺282 | Eylül faturası, 73 GiB |
| Min instance 0 | Ürün A | [2](#vaka-2) | ~₺255 | Eylül'ün 24 gününde ₺203, tam aya çevrildi |
| Önbellekler | Ürün C | [5](#vaka-5), [6](#vaka-6) | ~₺205 | (2,3 − 1,00) CU-saat/gün × ₺158, 7 Eki ölçümü; 3 Eki'deki ~0,3'e yeniden inerse ~₺320 |
| Neon Free'ye taşıma | Ürün D, test |  | ~₺95 | ~₺70 + ~₺24, 7 Eki; bir maliyet kaldıracı, vakası yok |
| Toplam |  |  | ~₺2.580–2.700 | 475 + (703–822) + 205 + 657 + 255 + 282 = ₺2.577–2.696; Free taşımasıyla ₺2.672–2.791 |

Kur 49 TL/$, Neon Launch $0,106/CU-saat; günde sürekli 1 CU-saat ayda ~₺158 (30,4 gün).

### Toplama girmeyenler

Bedeli olan ama tasarrufu ölçülmeyen ya da başka bir rakamın içinde kalan kalemler. Kaldıraçların tamamı [Ne tutar?](#maliyet) bölümünde.

Vaka [6](#vaka-6). Kategori kaçağı (sürseydi ayda ~₺190): yaklaşık bir gün sürdü, Ürün C rakamının içinde.

Vaka [7](#vaka-7). Kazıyıcı engeli: bot çıkışı ayda ~₺240'tı; engelin payı ~₺110 tahmin edildi, engelden sonra ölçülmedi.

Vaka [20](#vaka-20). Build kotası aşımı (₺187) ve Ürün B'nin ₺78 Cloud Run ücreti: düzeltme henüz uygulanmadı.

Vaka [21](#vaka-21). İmaj deposu temizliği: Ürün B'de Eylül depolaması ₺117'ydi, bugün dört projenin depoları ayda ~$0,60. Eylül tutarı ay ortasında başlayan temizliği içerdiği için fark hesaplanmadı.

## Dizin

Alanlar etkiye göre sıralı. Tarihler 2026. Başlık vakanın kartına gider.

| No | Vaka | Ürün | Tarih | Bedeli |
|---|---|---|---|---|
| Maliyet |
| 1 | [Tahmin 1 dolar, fatura ₺2.087](#vaka-1) | Dört ürün | Ağu–Eyl | **₺2.087** Ürün A ve B'nin Ağustos Google faturası; tahmin 1 dolardı |
| 2 | [Konsoldan açılan min instance ayda ₺255](#vaka-2) | Ürün A | Eyl–Eki | **~₺255/ay** boşta bekleyen tek API sunucusu |
| 3 | [Her build 428 MB imajı kıtalar arası taşıdı](#vaka-3) | Ürün B | Eyl–Eki | **₺282** Eylül'de 73 GiB kıtalar arası çıkış |
| Veritabanı |
| 4 | [Veritabanı 7/24 uyanık kaldı](#vaka-4) | Ürün A | Eyl | **~₺475/ay** günde ~3 CU-saat fazla tüketim |
| 5 | [Ayar yetmedi, okuma yolu belleğe taşındı](#vaka-5) | Ürün B ve C | Eyl–Eki | **~₺1.080/ay** Ürün B'nin Neon payı (~$22); Ürün C ~$8 |
| 6 | [Yeni sayfa veritabanını günde 74 kez uyandırdı](#vaka-6) | Ürün C | Eki | **~₺190/ay** sürseydi; kaçak ~1 gün sürdü |
| Botlar ve güvenlik |
| 7 | [Bulut kazıyıcısı site baytlarının %44'ünü aldı](#vaka-7) | Ürün B | Eyl–Eki | **540 kez** 7 günde bellek aşımı; bot çıkışı ~₺240/ay |
| 8 | [Gölgesiz açılan kural bülten linklerini reddetti](#vaka-8) | Birkaç ürün | Eki | **Ölçülmedi** bülten linklerinin taraması ilk gün 403 aldı |
| 9 | [Önyüklemeler ve kazıyıcı ziyaretçi sayıldı](#vaka-9) | Birkaç ürün | Eyl–Eki | **92 satır** yanlış 'reddederdim' |
| 10 | [Veri JSON yan kapısından çıkıyordu](#vaka-10) | Birkaç ürün | Eki | **Ölçülmedi** bütün katalog 3 çağrıda alınabiliyordu |
| 11 | [Bütün site tek bir istemci sayıldı](#vaka-11) | Ürün B | Eyl | **21 / 21** giriş kodu tek istemci sayıldı |
| 12 | [Bilinen bir Next açığı yetkili hesapla birleşti](#vaka-12) | Ürün A | Eyl | **Ölçülmedi** zincir bulunduğu gün kapandı |
| Kullanıcıyı kırmamak |
| 13 | [Güvenlik politikası canlıda logoları kırdı](#vaka-13) | Ürün A | Eyl | **1 gece** kurum logoları canlıda görünmedi |
| 14 | [Uyuyan veritabanı soğuk başlangıcı düşürdü](#vaka-14) | Ürün A | Eyl–Eki | **~%1–1,5** soğuk başlangıç 503 alıyordu |
| 15 | [Test ve simülatör canlı veriye yazdı](#vaka-15) | Ürün A | Eyl | **44 satır** sahte veri herkese açık listede |
| 16 | [Yazılan yorum bir güne kadar görünmedi](#vaka-16) | Ürün B | Eyl–Eki | **24 saat** yazılan yorum geç görünebiliyordu |
| 17 | [AI asistan kullanıcıyı çıkmaza soktu](#vaka-17) | Ürün A | Eyl–Eki | **2 kullanıcı** günlük hak gitti, cevap yok |
| Mobil yayın |
| 18 | [Eski sürümlere söyleyecek kanal yoktu](#vaka-18) | Ürün A | Eyl–Eki | **3 build** uyarıyı hiç gösteremeyecek |
| 19 | [Build kotası bitti, iOS sürümü bir hafta kaydı](#vaka-19) | Ürün A | Eyl–Eki | **1 hafta** iOS sürümü 1 Eki'ye kaydı |
| Deploy ve CI |
| 20 | [İki ürün tek hesapta build kotasını aştı](#vaka-20) | Ürün A ve B | Eyl–Eki | **₺187** kota aşımı; ayrıca ₺78 Cloud Run |
| 21 | [Temizlik kuralı haftalarca deneme modunda kaldı](#vaka-21) | Birkaç ürün | Eyl–Eki | **₺117** Ürün B'nin Eylül depolaması |
| 22 | [Migration ve kod birlikte çıktı, 11 dakika 500](#vaka-22) | Ürün B | Eyl | **11 dk** her mağaza sayfası 500 döndü |
| 23 | [Yutulan hata site haritasını kesti, sonra deploy durdu](#vaka-23) | Ürün B | Eyl | **16 saat** deploy yok; 2.668 sayfa düştü |
| Dış API |
| 24 | [Harita API'si projenin faturasının %72'si oldu](#vaka-24) | Ürün B | Ağu–Eyl | **₺1.500** Ağustos'ta harita API'si; Eylül ₺657 |
| 25 | [Ödeme webhook'u en az 21 gün sessizce 500 döndü](#vaka-25) | Ürün A | Eyl | **21+ gün** her webhook teslimi 500 aldı |
| 26 | [Sosyal paylaşım hattı bir ay sessizce durdu](#vaka-26) | Ürün C | Ağu–Eki | **30 / 30** paylaşım denemesi 402 aldı |
| E-posta |
| 27 | [Yeni alan adının kodları kurum geçitlerinde bekledi](#vaka-27) | Ürün A | Eki | **4 kurum** giriş kodları posta geçidinde bekledi |
| Performans |
| 28 | [Konum saniyede bir yazıldı](#vaka-28) | Ürün B | Eki | **~294 istek** 14 dakikada; çoğu 429 aldı |
| Yedek |
| 29 | [İlk yedek 7 bayttı](#vaka-29) | Ürün A | Eyl–Eki | **7 bayt** ilk yedek; döküm 701.738 bayttı |
| Ekip ve ajan süreci |
| 30 | [Kural ve iş geçici yerde kaldı](#vaka-30) | Birkaç ürün | Eyl–Eki | **2 build** istenmeden başladı; iş kayboldu |

## Maliyet

<a id="vaka-1"></a>

### 1. Tahmin 1 dolar, fatura ₺2.087

Dört ürün, Ağu–Eyl 2026 [ölçüldü]

**₺2.087** Ürün A ve B'nin Ağustos Google faturası; tahmin 1 dolardı

**Belirti:** Google Cloud maliyeti depo boyutlarına bakılarak ayda yaklaşık 1 dolar tahmin edildi. Ağustos faturası ₺2.087 geldi; bunun ₺2.081'i tek bir ürüne (Ürün B) aitti, Ürün A'nın payı ₺6'ydı.

**Kök neden:** Tahmin depo boyutuna dayanıyordu, fatura okunmamıştı; Google tarafında para bir harita API'sine ve imaj deposu trafiğine gidiyordu. Ayrı faturalanan Neon da altı projede ayda ~$55 tutuyordu; bunun %99,7'si hiç uyumayan veritabanlarının compute'uydu, depolama $0,02'ydi.

**Bedeli:** Ağustos'ta tek faturalama hesabında ₺2.087. Eylül'de dört ürünün bulut toplamı ~₺3.900–4.400 (49 TL/$).

**Çözüm:** 21 Eyl'de fatura proje ve SKU bazında, Neon tüketimi proje başına CU-saat olarak okundu. Her kalem ayrı bir işe dönüştü; bu defterdeki maliyet ve veritabanı vakaları oradan çıktı.

**Sonuç:** 8 Eki ölçümünde dört ürünün bulut toplamı ~₺1.300/ay.

Maliyet tahminle konuşulmaz; fatura proje ve SKU bazında, veritabanı tüketimi proje ve saat bazında okunur. [Kural: Ne tutar?](#maliyet)

<a id="vaka-2"></a>

### 2. Konsoldan açılan min instance ayda ₺255

Ürün A, Eyl–Eki 2026 [ölçüldü]

**~₺255/ay** boşta bekleyen tek API sunucusu

**Belirti:** Eylül faturasında Ürün A'nın Google payı Ağustos'taki ₺6'dan ₺394'e çıktı; bunun ₺203'ü API'nin boşta duran sunucusuydu.

**Kök neden:** 7 Eyl'de gece raporunun gelmediği sanılıp loglardaki 'terminated' satırlarından korkulunca konsoldan servis düzeyinde minScale 1 açıldı; rapor aslında gelmişti. Ayar şablonda 0 görünüyor, yalnız servisin meta verisinde 1 yazıyordu, bu yüzden haftalarca fark edilmedi.

**Bedeli:** Eylül'ün 24 gününde ₺203, tam ayda ~₺255 (1 vCPU, 0,5 GiB).

**Çözüm:** 2 Eki'de ayar 0'a indirildi. API'yi veritabanına dokunmayan sağlık ucuna 300 sn'de bir, 3 bölgeden giden uptime kontrolü sıcak tutuyor; açılan sunucu uyuyan veritabanını bekliyor.

**Sonuç:** İlk gece zamanlanmış işlerin hepsi 2xx, 5xx 0. API'de otomatik başlatma günde 2,0; soğuk sunucuya düşen istek payı %0,02.

Servis ayarı depodaki servis tanımından gelir, konsoldan değiştirilmez. Loglardaki 'terminated' satırı ölçeğin sıfıra inmesidir, arıza sayılmaz. [Kural: Bulut altyapısı](#katman-6)

<a id="vaka-3"></a>

### 3. Her build 428 MB imajı kıtalar arası taşıdı

Ürün B, Eyl–Eki 2026 [ölçüldü]

**₺282** Eylül'de 73 GiB kıtalar arası çıkış

**Belirti:** Eylül faturasında imaj deposu için 73 GiB kıtalar arası çıkış ₺282 tuttu; projede kimse imaj indirmiyordu.

**Kök neden:** Web sitesinin global bölgedeki buildpack tetikleyicisi imajı yayınladıktan sonra bir de docker pull ve push adımı çalıştırıyordu; 428 MB'lık imaj her build'de europe-west1'den ABD'deki build işçisine inip geri gidiyordu. Eylül'de 194 site build'i oldu.

**Bedeli:** ₺282 (73 GiB, $0,08/GiB).

**Çözüm:** 2 Eki'de pull ve push adımları ile 'images:' satırı tetikleyiciden çıkarıldı; yalnız buildpack ve deploy adımı kaldı.

**Sonuç:** Ekim'deki 35 site build'inin 35'i başarılı, kıtalar arası çıkış yok. Aynı denetimde ölçüldü: buildpack'le kurulan Next imajları 420–456 MB, Dockerfile ve standalone ile kurulanlar 77–92 MB, yani ~5 kat.

Tetikleyici, imaj deposu ve Cloud Run aynı bölgede durur; Next imajı Dockerfile ve standalone çıktıyla kurulur. [Kural: Artifact Registry](#registry)

## Veritabanı

<a id="vaka-4"></a>

### 4. Veritabanı 7/24 uyanık kaldı

Ürün A, Eyl 2026 [ölçüldü]

**~₺475/ay** günde ~3 CU-saat fazla tüketim

**Belirti:** Prod veritabanı 18–23 Eyl arasında 33,41 CU-saat harcadı: günde ~6,2, yani 0,25 CU'da tam gün uyanık. İstek sayısı ve sunucu sayısı normal görünüyordu.

**Kök neden:** E-posta, özet ve makbuz işleri 30 sn ile 1 gün arası zamanlayıcılarla veritabanına soruyordu; Neon ise ancak 5 dakika hiç bağlantı olmazsa uyur. Herkese açık uçlar Cache-Control yazıyordu ama önlerinde bu başlığı uygulayan bir katman yoktu; gece tarayıcıları her cevabı Postgres'ten yeniden kurduruyordu.

**Bedeli:** Günde ~3 CU-saat fazlası ayda ~₺475 (günde sürekli 1 CU-saat ayda ~₺158). 0,25 CU'da 7/24 uyanık bir veritabanı ayda $19,1 (~₺935) tutar.

**Çözüm:** 23 Eyl'de arka plan işleri trafiğe bağlandı: iş yalnız bir istek havuzdan bağlantı alırken çalışıyor; saatlik bir zamanlanmış iş durduruldu. Herkese açık toplu cevaplar ertesi sabaha kadar bellekte duruyor, yazma ve yönetici düzenlemesi önbelleği düşürüyor.

**Sonuç:** Tüketim günde ~3,2 CU-saate indi; 4–7 Eki ortalaması 3,18.

Veritabanına zamanlayıcıyla soran kod yazılmaz; iş onu doğuran istekle ya da trafik veritabanını zaten uyandırmışken çalışır ve önünde uygulayan katman yoksa Cache-Control önbellek sayılmaz. [Kural: Postgres](#katman-1)

<a id="vaka-5"></a>

### 5. Ayar yetmedi, okuma yolu belleğe taşındı

Ürün B ve C, Eyl–Eki 2026 [ölçüldü]

**~₺1.080/ay** Ürün B'nin Neon payı (~$22); Ürün C ~$8

**Belirti:** Ürün B ve Ürün C'nin veritabanları da hiç uyumuyordu: Ürün B günde 6–8 CU-saat yazıyordu. Ürün C'de bir günde 363 istek veritabanını 69 kez uyandırdı, veritabanı günde ~15 saat uyanıktı.

**Kök neden:** Önce ayar bulundu: Ürün B'de havuz tabanı 2 bağlantı ve saniyede bir soran e-posta kuyruğu, Ürün C'de yanlışlıkla boşta bağlantı ayarına bağlanmış 5 bağlantılık taban. 21 Eyl'de ayarlar düzelince asıl sebep göründü: botların gezdiği, sunucuda çizilen sayfalar her istekte veritabanına gidiyordu. Ürün B'de günün 288 beş dakikalık penceresinin hepsinde trafik vardı; Google ve Bing dışındaki botlar çıkarılınca bile veritabanı zamanın %68'inde uyanıktı.

**Bedeli:** 2 Eki'de Ürün B'nin Neon payı ayda ~$22, Ürün C'ninki ~$8'di. Ürün B'de öne çıkanlar sayfasının API çağrısı p90 25,7 sn sürüyordu.

**Çözüm:** Ürün B'de herkese açık katalog okumaları API belleğindeki tam bir kopyadan veriliyor. Kopya bir gün gölgede veritabanıyla karşılaştırıldı, yakalanan tek sıralama farkı düzeltildi ve 3 Eki'de açıldı; yazmalar GCS'teki bir değişiklik işaretiyle bütün sunuculara ~30 sn'de yansıyor. Ürün C'de herkese açık okumalar 6 saat bellekte duruyor, sayaçlar veritabanı uyanıkken yazılıyor.

**Sonuç:** Ürün B 6,5'ten 1,3 CU-saat/güne indi (yoğun katalog yönetimi günlerinde 2–3); mağaza sayfası p50 28 ms'den 2 ms'ye, öne çıkanlar p90 25,7 sn'den 262 ms'ye indi. Ürün C 2,3'ten 3 Eki ölçümünde ~0,3'e indi; kategori kaçağından önce günde 1,3, kaçak kapandıktan sonra 7 Eki'de 1,00 CU-saatti (vaka [6](#vaka-6)).

Havuz tabanı 0 ve boştaki bağlantı 90 sn ile başlanır. Asıl kaldıraç okuma yoludur: herkese açık okumalar API belleğinden verilir; bot engeli tek başına veritabanını uyutmaz. [Kural: Postgres](#katman-1)

<a id="vaka-6"></a>

### 6. Yeni sayfa veritabanını günde 74 kez uyandırdı

Ürün C, Eki 2026 [ölçüldü]

**~₺190/ay** sürseydi; kaçak ~1 gün sürdü

**Belirti:** 5 Eki'de yayına çıkan kategori sayfalarından sonra Neon tüketimi günde 1,3'ten 2,5 CU-saate çıktı.

**Kök neden:** Kategori sayfaları, site haritası ve llms.txt kategori listesini beş dakikada bir yeniden okuyordu; bu uç herkese açık okumalar içinde her seferinde veritabanına giden tek uçtu. Botlar bu sayfaları gezdikçe veritabanı uyanıyordu: 6 Eki 15:30'a kadarki 51 uyanışın 44'ü bu uçtandı.

**Bedeli:** Günde ~74 uyanış; sürseydi ayda ~₺190 fazla. Kaçak 5 Eki öğleden sonra başladı ve 6 Eki öğleden sonra kapandı, yaklaşık bir gün sürdü.

**Çözüm:** Her uyanışı nedeniyle yazan 'db wake' log satırı sebebi bir günde gösterdi. 6 Eki'de kategori listesi yayındaki kayıtlarla birlikte 6 saat bellekte tutulmaya başladı; yönetici ya da editör kaydı belleği hemen boşaltıyor.

**Sonuç:** Düzeltmeden sonraki ilk 16 saatte 12 uyanış oldu, kategori kaynaklı 0. 7 Eki'de tüketim günde 1,00 CU-saatti.

Veritabanına giden her yenileme ya saatler aralıkla ya da yalnız değişiklik işaretiyle çalışır ve her uyanış nedeniyle loglanır. [Kural: Postgres](#katman-1)

## Botlar ve güvenlik

<a id="vaka-7"></a>

### 7. Bulut kazıyıcısı site baytlarının %44'ünü aldı

Ürün B, Eyl–Eki 2026 [ölçüldü]

**540 kez** 7 günde bellek aşımı; bot çıkışı ~₺240/ay

**Belirti:** 2 Eki'de 512 MiB'lik site gece bot yoğunluğunda 192 kez bellek sınırını aştı; o anda işlenen istekler, gerçek kullanıcılarınki dahil, 503 aldı. Bunu alarm yerine maliyet analizi buldu.

**Kök neden:** Alibaba Cloud'un ABD aralığından (en yoğunu 47.79.0.0/16) Chrome kılığında gelen bir kazıyıcı robots.txt'yi hiç okumadan günde ~25.700 istek atıyordu: web isteklerinin %41'i, site baytlarının %44'ü. Çizilen her sayfa API'ye ortalama 1,73 istek daha yaptığı için yük ikiye katlanıyordu.

**Bedeli:** 1–8 Eki'de 7 günde 540 bellek aşımı. Bot çıkış trafiği Ürün B'nin Google payının çoğuydu: 1–8 Eki temposu ayda ~41 GiB, ~₺240.

**Çözüm:** 6–7 Eki gecesi kazıyıcının aralığı (47.74.0.0–47.87.255.255) 403 almaya başladı; ardından ortak kapı Alibaba ve Tencent bulutlarını yalnız içerik sayfalarında reddedecek şekilde kuruldu. Bu bulutların öneklerinde başka şirketlerin kullandığı 9 blok bulundu ve listeden çıkarıldı.

**Sonuç:** Kural açıldıktan sonraki 24 saatte 6.654 istek reddedildi. Engel tek başına veritabanı faturasını düşürmedi; o iş okuma yolunun belleğe taşınmasıyla oldu (vaka [5](#vaka-5)). Engelden sonraki bellek aşımı sayısı ölçülmedi; 1 GiB önerildi.

Robots.txt'yi dinlemeyen bulut kazıyıcısı ağ olarak yalnız içerik sayfalarında reddedilir; API, form, oturum ve yasal sayfalar açık kalır. Bellek taşmasına ilk günden alarm kurulur (öneri; bizde taşmayı maliyet analizi buldu, alarm yoktu). [Kural: Botlara karşı tutum](#botlar)

<a id="vaka-8"></a>

### 8. Gölgesiz açılan kural bülten linklerini reddetti

Birkaç ürün, Eki 2026 [kanıtlı]

**Ölçülmedi** bülten linklerinin taraması ilk gün 403 aldı

**Belirti:** Kullanıcı ajanı boş içerik isteklerini reddeden kural gölgede denenmeden açıldı ve ilk gün bir e-posta güvenlik tarayıcısına 403 verdi.

**Kök neden:** Kuralın gerekçesi gerçekti: bir sitede Azure'daki 15 adresin 6 günde attığı 6.222 boş ajanlı isteğin hepsi webshell aramasıydı. Ama Microsoft'un e-posta link tarayıcısı da (134.149.116.0/24) bültendeki linkleri hiç ajan göndermeden düz bir GET ile açıyor.

**Bedeli:** Ölçülmedi: reddedilen tarama sayısı kayda geçmedi. Kişinin kendi tıklaması engellenmedi, bültendeki linklerin güvenlik taraması 403 aldı.

**Çözüm:** Kural yalnız Accept-Language ve Sec-Fetch-Mode da göndermeyen içerik GET'lerine daraltıldı; 19 ASN'lik güvenlik firması listesi kuralların dışına alındı ve bundan sonra hiçbir kural gölgesiz açılmıyor.

**Sonuç:** Ürün C'de canlıya alınırken Microsoft'un tarayıcısı geçti; son 3 günün 36 bin isteğinde ad kuralları yalnız 81 isteği reddederdi.

Her yeni bot kuralı önce gölgede 'reddederdim' yazar ve en az 7 gün (kurumsal kullanıcılı üründe 14 gün) temiz logla zorlanır; e-posta ve güvenlik firmalarının link tarayıcıları hiçbir kurala girmez. [Kural: Botlara karşı tutum](#botlar)

<a id="vaka-9"></a>

### 9. Önyüklemeler ve kazıyıcı ziyaretçi sayıldı

Birkaç ürün, Eyl–Eki 2026 [ölçüldü]

**92 satır** yanlış 'reddederdim'

**Belirti:** Kapının gölgedeki hız kuralı tek bir Türk adresinden gelen 400 isteği sayfa saydı ve 92 yanlış 'reddederdim' satırı yazdı. SEO ölçümünde ChatGPT oturumları 12–24 sayfa geziyor göründü; Ürün A'da 'Google'dan gelen' ~120 girişin ~105'i gerçek değildi.

**Kök neden:** Next, middleware çalışmadan önce RSC, Next-Router-Prefetch ve _rsc işaretlerini siliyor (15.5, 16.2 ve 16.3'te aynı). Link önyüklemeleri bu yüzden sayfa açılışı gibi görünüyordu; birim testleri başlıkları kendileri kurduğu için geçiyordu. Google referanslı girişlerin çoğu Alibaba bulutundan Chrome kılığında gelen bir kazıyıcıydı.

**Bedeli:** Kural zorlansaydı gerçek ziyaretçiler kesilecekti. SEO raporu olmayan bir başarıyı anlattı ve 6 Eki'de geri alındı.

**Çözüm:** Önyükleme, silinmeyen Next-Url ve sec-fetch-dest: empty başlıklarıyla tanınıp sayfa kovasının dışında tutuluyor; kapı testleri gerçek Next adaptöründen geçen istekle yazıldı. Logdan sayımda önce kendi adreslerimiz, bulut aralıkları ve önyüklemeler çıkarılıyor.

**Sonuç:** Aynı adresten gelen 400 önyükleme artık hiç satır yazmıyor. Düzeltilmiş ölçümde 6,5 günde gerçek ChatGPT tıklaması 1'di ve hiçbiri ikinci sayfaya geçmedi.

Kapı ve ölçüm kuralları gerçek Next sunucusundan geçen istekle sınanır; logdan ziyaretçi sayılırken önyüklemeler, bulut aralıkları ve kendi adreslerimiz çıkarılır. [Kural: Botlara karşı tutum](#botlar)

<a id="vaka-10"></a>

### 10. Veri JSON yan kapısından çıkıyordu

Birkaç ürün, Eki 2026 [kanıtlı]

**Ölçülmedi** bütün katalog 3 çağrıda alınabiliyordu

**Belirti:** Sayfalar kapının arkasına alınırken Ürün B sitesinin kendi /api aktarma ucu dışarıda kalmıştı: tek çağrıda 5.000 mağaza dönüyordu, bütün katalog 3 çağrıda alınabiliyordu.

**Kök neden:** Aktarma ucu her /v1 yolunu web sunucusunun sırrıyla API'ye iletiyordu; tarayıcının hiç çağırmadığı toplu liste uçları da açıktı. HTML'i korumak veriyi korumuyordu. Kapıyı /api'ye genişletmenin yan etkisi incelemede çıktı: Next, middleware'in gördüğü POST gövdelerini belleğe alıp 10 MB'ta kesiyor.

**Bedeli:** Yan kapıdan ne kadar veri çekildiği ölçülmedi. 10 MB sınırı üç sitede denendi: 11 MB'lık yüklemeler 500 ya da yanlış bir 400 aldı. Gerçek kullanıcı etkilenmedi, çünkü tarayıcılar dosyaları 850 KB, 2 MB ve 6 MB'ta kesiyordu.

**Çözüm:** 7 Eki'de aktarma ucu, tarayıcının hiç çağırmadığı toplu liste uçlarına 404 vermeye başladı. Kodun çağırdığı yollar bir listede tutuluyor ve listeye uymayan her çağrı loglanıyor.

**Sonuç:** Bir kazıyıcının bu uca saniyede 50 kez sorması dakikada tek log satırı yazıyor; tarayıcının çağırdığı yollar eskisi gibi çalışıyor.

Kapı kurulurken önce JSON uçlarına bakılır; aktarma ucu tarayıcının çağırmadığı toplu uçları kapatır ve çağrılan yolları listeyle izler. Kapının kapsamı genişleyince yükleme rotalarının gövde sınırı yeniden denenir. [Kural: Botlara karşı tutum](#botlar)

<a id="vaka-11"></a>

### 11. Bütün site tek bir istemci sayıldı

Ürün B, Eyl 2026 [kanıtlı]

**21 / 21** giriş kodu tek istemci sayıldı

**Belirti:** 28 Eyl'de canlı veritabanında o güne kadar verilen 21 giriş kodunun hepsinin, altı farklı e-posta adresine gitmiş olsalar da, aynı istemci IP özetini taşıdığı görüldü.

**Kök neden:** Web'den gelen her istek API'ye web sunucusunun adresinden ulaşıyordu ve API bağlantının adresini okuduğu için bütün site tek bir istemciydi. Varsayılan sınır saatte 10 koddu: herhangi biri 10 istek atınca saat dönene kadar kimseye giriş kodu gidemezdi.

**Bedeli:** Olay yaşanmadı; az kullanıcılı dönemde kimse sınıra takılmadı. Gerçek trafikte yetki gerektirmeden tetiklenebilecek bir giriş kesintisiydi.

**Çözüm:** Web sunucusu gerçek adresi X-Client-IP ile bildiriyor; API bu başlığa yalnız ortak sırrı doğrulanmış istekte güveniyor, doğrulanamayan adres ortak bir kovaya yazılmıyor. İlk taslak mobil isteklerde adres başına sınırı tamamen kapatacaktı; inceleme bunu yakaladı.

**Sonuç:** Düzeltme aynı gün yayına çıktı. Ürün C de 27–28 Eyl'de aynı düzene geçti: site sunucusu iç anahtarla tanınıyor, ziyaretçi adresi X-Client-IP ile geliyor.

İstemci adresi yola göre tek bir tablodan okunur: doğrudan gelende X-Forwarded-For'un en sağ elemanı, BFF'den gelende iç anahtarla doğrulanan X-Client-IP; web sunucusunun adresi kimsenin adresi değildir. [Kural: Kenar, DNS ve alan adı](#katman-5)

<a id="vaka-12"></a>

### 12. Bilinen bir Next açığı yetkili hesapla birleşti

Ürün A, Eyl 2026 [kanıtlı]

**Ölçülmedi** zincir bulunduğu gün kapandı

**Belirti:** 22 Eyl'de beş depo ve bulut projesi tarandı; kullanıcıların yüklediği belgelerin herkese açık medya kovasında durması bulgulardan biriydi. Bir gün sonraki üçüncü taramada daha ağır bir zincir bulundu.

**Kök neden:** Web siteleri Next.js 14'ün bilinen bir SSRF açığını taşıyordu ve proje genelinde Editor rolü olan varsayılan compute hesabıyla çalışıyordu; ikisi birlikte projenin ele geçirilmesine yol açabilirdi. Bir gün önce 'Next kapandı' denmişti, ama yalnız görsel iyileştirici açığına bakılmıştı.

**Bedeli:** Ölçülmedi; zincir bulunduğu gün kapatıldı.

**Çözüm:** Belgeler aynı gün herkese kapalı ayrı bir kovaya taşındı, eski adresler 404 veriyor. 23 Eyl'de siteler rolsüz kendi hesaplarına alındı ve Next 15.5'e geçti; öğleden sonra projede Editor taşıyan hesap kalmadı, build hesabına actAs yalnız deploy ettiği hesaplarda verildi.

**Sonuç:** Go bağımlılık taramasındaki bulgu 8'den 0'a indi, sırlar 12 Secret Manager referansına taşındı ve düz metin hassas ortam değişkeni kalmadı. Bir başka üründe Next'in ayrı bir açığı ancak 8 Eki'de kapandı; o servis de rolsüz hesaba alındı.

Her servis kendi rolsüz hesabıyla çalışır; 'kapandı' demeden sürümün bütün bilinen açıklarına bakılır ve bir projede kapanan açık aynı gün bütün projelerde aranır. [Kural: Güvenlik ve botlar](#katman-8)

## Kullanıcıyı kırmamak

<a id="vaka-13"></a>

### 13. Güvenlik politikası canlıda logoları kırdı

Ürün A, Eyl 2026 [kanıtlı]

**1 gece** kurum logoları canlıda görünmedi

**Belirti:** 22 Eyl'de üç web yüzeyine içerik güvenlik politikası (CSP) eklendi; o gece canlıda kurum logoları görünmedi.

**Kök neden:** Logolar API'den geliyordu ve img-src API'nin adresini içermiyordu. Test ortamında o kartlar yoktu, çünkü onları dolduran iş testte kapalıydı; prova kırığı göstermedi ve aynı politikada sabit yazılmış connect-src test portalını da kırmıştı.

**Bedeli:** Logolar bir gece kırık kaldı. Düzeltme hazır olduktan sonra onay isteği uzun bir raporun içinde kaldı ve bekledi; onay gelince logolar 6 dakikada canlıdaydı.

**Çözüm:** 23 Eyl 09:20'de izinli adresler build'in hedeflediği API'den türetilecek şekilde düzeltildi; 'unsafe-eval' yalnız geliştirmede kaldı.

**Sonuç:** Ürün B'de politika önce bir gün report-only çalıştı, sonra bir rapor ucu eklendi ve her sayfa tipinin dış istekleri sayıldı; 29 Eyl'de kırılmadan zorlandı.

CSP önce report-only ve bir rapor ucuyla çıkar, izinli adresler build'in hedef API'sinden türetilir, zorlamadan önce canlı veri gösteren her sayfa açılır; canlı kırıkta onay isteği raporun ilk satırıdır. [Kural: Next.js web](#katman-3)

<a id="vaka-14"></a>

### 14. Uyuyan veritabanı soğuk başlangıcı düşürdü

Ürün A, Eyl–Eki 2026 [ölçüldü]

**~%1–1,5** soğuk başlangıç 503 alıyordu

**Belirti:** 6 Eyl sabahı zamanlanmış bir iş 503 ile düştü. Soğuk başlangıçların ~%1–1,5'i aynı şekilde uyuyan veritabanına denk geliyordu.

**Kök neden:** API açılışta veritabanına 5 sn ping atıyor, cevap gelmezse kapanıyordu; uykudan uyanan Neon bu sürede yetişmeyince istek 503 aldı. Daha tehlikelisi gizliydi: oturum kontrolü her veritabanı hatasını 401'e çeviriyordu ve uygulama ile portal 401'de oturumu siliyordu.

**Bedeli:** Bir zamanlanmış iş düştü. 401 riski olay yaşanmadan bulundu; uyuyan bir veritabanı o yolla bütün kullanıcıları aynı anda oturumdan atabilirdi.

**Çözüm:** 2 Eki'de açılan sunucu veritabanını ikiye katlanan aralarla ~30 sn bekliyor ve veritabanı hatasında 401 yerine 503 dönüyor. Yayından önce kullanımdaki en eski sürümden bu yana her uygulama sürümünün yalnız 401'de çıkış yaptığı doğrulandı. Ürün C de 4 Eki'de veritabanı hatasını 401 olmaktan çıkardı; orada 500 dönüyor ve oturum silinmiyor.

**Sonuç:** 1–8 Eki'de 25.409 istekte 5xx 0. Min instance 0'a indikten sonraki ilk gece temiz geçti.

401 yalnız kesin yetki reddidir; veritabanı ve altyapı hatası 503 döner, istemci oturumu yalnız 401'de siler ve açılan sunucu uyuyan veritabanını bekler. [Kural: Go API](#katman-2)

<a id="vaka-15"></a>

### 15. Test ve simülatör canlı veriye yazdı

Ürün A, Eyl 2026 [kanıtlı]

**44 satır** sahte veri herkese açık listede

**Belirti:** Yönetim panelinde sürekli aynı imzalı hesaplamalar görünüyordu ve 17–28 Eyl arası 44 satır herkese açık 'popüler hesaplamalar' listesine girdi. Aynı hafta simülatördeki denemelerin de canlı API'ye analitik yazdığı görüldü.

**Kök neden:** Portalın testi jsdom'un gerçek fetch'iyle çalışıyordu ve API adresi verilmeyince canlıya düşüyordu. Mobilde Expo 54, Metro'ya verilen test adresini depodaki .env'in canlı adresiyle eziyordu; paket grep'i test adresini gösterip yanılttı.

**Bedeli:** 44 sahte satır herkese açık listede uygulamada ve sitelerde göründü (7 günlük pencereden 5 Eki'de düştü). Simülatör 24 ve 26 Eyl'de canlıya yazdı; yalnız Darwin sürümüne bakan bir log süzgeci 38 gerçek kullanıcının isteğini bizimki sandı.

**Çözüm:** 28 Eyl'de portal testlerinde ağ kesildi; satırlar ürün sahibinin kararıyla silinmedi, imzaları test olarak biliniyor. Simülatör her açılıştan önce geçici bir .env.local ile test API'sine bağlanıyor ve hedef adres çalışma anında, test servisinin logunda doğrulanıyor.

**Sonuç:** 28 Eyl kontrolünde mobil, iki site ve API testlerinin hiçbiri canlıya yazmıyordu.

Yerel, test, simülatör ve CI varsayılanı asla prod olmaz; hedef adres çalışma anında, hedef servisin logunda doğrulanır. [Kural: Asla](#asla)

<a id="vaka-16"></a>

### 16. Yazılan yorum bir güne kadar görünmedi

Ürün B, Eyl–Eki 2026 [ölçüldü]

**24 saat** yazılan yorum geç görünebiliyordu

**Belirti:** Mobil uygulamadan yazılan bir yorum mağaza sayfasında bir güne kadar görünmeyebiliyordu; silinen bir yorum da önbellek süresi dolana kadar sayfada kaldı (23 Eyl). Dizüstünden yapılan katalog değişiklikleri 6 saate kadar geç görünüyordu.

**Kök neden:** Mağaza sayfaları her web sunucusunun kendi önbelleğinde 24 saat duruyordu ve yalnız sitenin, aynı sunucuya düşen kendi yazması önbelleği düşürüyordu. Mobilden ya da komut satırından gelen yazma siteye hiç ulaşmıyordu.

**Bedeli:** Ölçülmedi. Yazan kişi yorumunu bir güne kadar sayfada göremiyordu ve silinen yorum sayfada kalıyordu.

**Çözüm:** 3 Eki'de site, API'nin GCS'teki değişiklik işaretini her sunucuda en çok 30 sn'de bir okuyup değişen mağazanın sayfasını, listeleri ve öne çıkanları kendi önbelleğinden düşürmeye başladı (45 sn ve 5 dk sonra iki tekrar). 4 Eki'de kataloğa yazan komutlar da işareti güncelliyor.

**Sonuç:** Yerel ölçümde yorumdan 31 sn sonraki ilk istekte sayfa yeniden çizildi; komut satırı yazmalarında gecikme ~30 sn. Maliyeti sunucu başına ayda 5 sentin altında.

Kişi yazdığını hemen görür: değiştirilebilen her sayfa yazma anında bütün adresleriyle önbellekten düşer ve yazan her yol, betik ve elle SQL dahil, değişiklik işaretini günceller. [Kural: Next.js web](#katman-3)

<a id="vaka-17"></a>

### 17. AI asistan kullanıcıyı çıkmaza soktu

Ürün A, Eyl–Eki 2026 [ölçüldü]

**2 kullanıcı** günlük hak gitti, cevap yok

**Belirti:** 30 Eyl'de açılan asistanı ürün sahibi denedi ve 'aşırı kötü' buldu. 2 Eki'de iki gerçek kullanıcı çıkmaza girdi: biri konu içi ama rakamsız bir mesaja 'bilgim yok' cevabı alıp günlük hakkını harcadı, öbürünün '70000 ay' diye okunan mesajı hata verdi ve sonraki her mesaj aynı hatayı aldı.

**Kök neden:** İlk sürümde dört cevabın dördünü kurallar vermişti, model hiç çağrılmamıştı. Sonraki sürümde aralık dışı bir sayı bütün isteğin reddedilmesine yol açıyor ve hata sohbete yapışıyordu; konu içi ama eksik istekler 'kapsam dışı' sayılıyordu.

**Bedeli:** İki gerçek kullanıcı birer günlük hak harcadı ve cevapsız kaldı; uygulama 'Bir sorun oluştu' gösterdi.

**Çözüm:** İlk sürüm aynı gün tek bir ortam değişkeniyle kapatıldı; ikinci sürümde yazılan her mesaj modele gidiyor. 2 Eki gecesi yazılan sayılar reddedilmez oldu: aralık dışı değer düşürülüp kişiye söyleniyor, eksik istekte eksik olan soruluyor.

**Sonuç:** Canlı değerlendirmede 26 cümlenin 23'ü doğru (cevap başına ~$0,0026, ~2,7 sn); düzeltmeden sonra uç senaryolar 11/11 ve 6/6 geçti.

Kullanıcının yazdığı hiçbir değer akışı kilitlemez, konu içi ama eksik istek kapsam dışı sayılmaz ve her yeni yüzey sunucu anahtarıyla dakikalar içinde kapatılabilir çıkar. [Kural: Kullanıcıyı kırmadan değiştirmek](#kirmama)

## Mobil yayın

<a id="vaka-18"></a>

### 18. Eski sürümlere söyleyecek kanal yoktu

Ürün A, Eyl–Eki 2026 [ölçüldü]

**3 build** uyarıyı hiç gösteremeyecek

**Belirti:** 18–19 Eyl'de güncelleme uyarısının Android'de üç build'de hiç çıkmadığı, iOS'ta ise önceki ana sürümün ara sürümleri çıkarken kimseye gösterilmediği bulundu. Ekim'de yeni eşleştirme akışı, eski sürümdeki kurumsal kullanıcılara anlatılamadığı için bekletildi.

**Kök neden:** Uygulama kurulu build'i app.json'daki sayıdan okuyordu ve bu sayı EAS'ın uzaktan artırdığı gerçek numaradan geride ya da boştu; birim testleri numarayı taklit ediyordu. iOS'ta hedef sürüm değeri elle güncellenmemişti. Eski sürümlerin ekran metinleri de sabitti, sunucudan yazı konacak yer yoktu.

**Bedeli:** Üç Android build'i uyarıyı hiçbir zaman gösteremeyecek; 28 Eyl'de son 7 günde Android'deki aktif kullanıcıların %3'ü, iOS'takilerin %7'si eski sürümlerdeydi. Yeni akış 1 Eki yerine 5 Eki'de, son 30 günde eski akıştan talep alan 6 kişiden 5'i güncellediğinde açılabildi.

**Çözüm:** Numara nativeBuildVersion'dan okunuyor (düzeltmeyi taşıyan ilk build'den beri); düzeltme 19 Eyl'de emülatörde gerçek release build'le dört senaryoda kanıtlandı. Zorunlu güncelleme iki platformda kapalı, çünkü eski iOS sürümlerinde zorunlu ekran telefonu içeriksiz kilitliyordu. Yeni sürüme sunucudan yazılan bir uyarı alanı eklendi.

**Sonuç:** 8 Eki'de iki mağaza aynı sürümde ve uyarı ikisinde de ona bakıyor. Mağaza yayınından sonra hedef değer hâlâ elle çekiliyor.

Güncelleme uyarısı, zorunlu ekran, sunucudan metin alanı ve her istekte sürüm başlığı ilk mağaza build'inde olur ve gerçek release build'le telefonda kanıtlanır; sonradan eklenen kanal eski build'lere ulaşmaz. [Kural: Mobil kit](#mobilkit)

<a id="vaka-19"></a>

### 19. Build kotası bitti, iOS sürümü bir hafta kaydı

Ürün A, Eyl–Eki 2026 [ölçüldü]

**1 hafta** iOS sürümü 1 Eki'ye kaydı

**Belirti:** 24 Eyl'de istenen iOS build'i kota dolduğu için reddedildi. Kaldığı sanılan iki hak Android'indi; iOS kotası 22 Eyl'de dolmuştu.

**Kök neden:** EAS'ın ücretsiz planı ayda 15 iOS ve 15 Android build verir, platform ve hesap başına ayrı sayar ve preview build'leri de düşer. Eylül'de 17 iOS build başlatıldı (6'sı preview); OTA olmadığı için yalnız JS değişen düzeltmeler de mağaza build'i istedi.

**Bedeli:** iOS sürümü 24 Eyl'den 1 Eki'ye kaydı. Reddedilen deneme bile uzaktan build numarasını artırdı (iki platformda birer numara hiç çıkmadı). Yeni eklenen bir iOS yeteneği yüzünden etkileşimsiz build profil hatasıyla düştü ve ürün sahibinin Apple girişini bekledi.

**Çözüm:** Build önermeden önce platform başına kalan hak eas account:usage ile sayılıyor, çünkü aynı hesaptaki Ürün C de bu kotayı kullanıyor. Numaralar build listesinden okunuyor ve kotanın ayın ilk günü 00:00 UTC'de (03:00 TSİ) döndüğü biliniyor. Aylık $19'luk plan alınmadı.

**Sonuç:** 8 Eki'de Ekim kullanımı iOS 7/15, Android 6/15. 19 Eyl–7 Eki arasındaki 19 mağaza build'inin 4 iOS ve 7 Android'i yalnız JS idi; OTA olsaydı mağazaya gitmeden çıkabilirdi.

Build kotası platform başına ölçülür, deneme build'i yerelde alınır ve ay sonuna 2–3 acil iOS hakkı bırakılır; OTA ve gereken yetenekler ilk mağaza build'inde olur. [Kural: Mobil build ve dağıtım](#dagitim)

## Deploy ve CI

<a id="vaka-20"></a>

### 20. İki ürün tek hesapta build kotasını aştı

Ürün A ve B, Eyl–Eki 2026 [ölçüldü]

**₺187** kota aşımı; ayrıca ₺78 Cloud Run

**Belirti:** Eylül'de Ürün A ve Ürün B'nin paylaştığı faturalama hesabında Cloud Build 3.121 dakika tuttu ve ayda 2.500 dakikalık ücretsiz kota aşıldı.

**Kök neden:** Ücretsiz kotalar faturalama hesabı başına verilir ve iki ürün aynı hesaptaydı. Test ve prod da aynı commit'i ayrı ayrı build ediyordu: Ürün A'nın Eylül dakikalarının %32'si (474 dk) test kopyasına gitti ve prod, testte denenenden farklı bir imajı çalıştırdı.

**Bedeli:** ₺187 build ücreti (Ürün A ₺110, Ürün B ₺77); aynı hesap yüzünden Ürün B'ye ayrıca ₺78 Cloud Run ücreti yazıldı. Ayrı hesaplarda ikisi de ₺0 olurdu; küçük bir ürünün kullandığı ücretsiz kotaların değeri ayda ~$22.

**Çözüm:** Ürün C'nin tetikleyicilerine yalnız .md dosyası değişen push'ta build almama ayarı kondu (5 Eki). Ürün başına faturalama hesabı ve 'bir kez build, testte doğrulanan digest'i terfi et' hattı öneri olarak yazıldı.

**Sonuç:** Henüz tam uygulanmadı: Ekim temposuyla hesap ~2.700 dk'ya gidiyor (~$1,3 aşım) ve Ürün A'nın Ekim dakikalarının %51'i test tetikleyicilerinden geliyor.

Her gerçek ürün kendi faturalama hesabında doğar; imaj bir kez build edilir ve testte doğrulanan aynı digest prod'a terfi eder (öneri; bizde henüz uygulanmadı). [Kural: Ücretsiz katmanlar](#ucretsiz)

<a id="vaka-21"></a>

### 21. Temizlik kuralı haftalarca deneme modunda kaldı

Birkaç ürün, Eyl–Eki 2026 [ölçüldü]

**₺117** Ürün B'nin Eylül depolaması

**Belirti:** İmaj deposunda temizlik kuralları listede görünüyordu ama hiçbir şey silinmemişti: Ürün A'nın deposu 1,3 GB ve 68 imaja çıkmıştı, Ürün B'nin depolaması Eylül'de ₺117 tuttu.

**Kök neden:** Kurallar 21 Eyl'e kadar dry-run'daydı. Daha önceki bir not onları canlı sanmıştı, çünkü kural listesine bakılmış, describe çıktısındaki cleanupPolicyDryRun alanına bakılmamıştı.

**Bedeli:** Ürün B'de Eylül'de ₺117 depolama. Silme gerçek olunca iki kırık çıktı: elle eski imaja sabitlenmiş migration job'ı imajını bulamadı (21 Eyl ve 7 Eki) ve bir geri dönüş revizyonunun imajı bir gün içinde silindi, geri dönüşün tek yolu revert ve yeniden build kaldı.

**Çözüm:** Kurallar beş depoda gerçek modda ve migration job'ı her API sürümünde servis imajına çevriliyor. Öneri: deploy edilen imaj bir 'deployed-' etiketiyle 30 gün tutulur.

**Sonuç:** 8 Eki'de dört projenin depoları toplam 6,9 GB, ayda ~$0,60; geri dönüş penceresi servise göre 0,9 ile 16,5 gün arası.

Temizliğin gerçekten çalıştığı describe çıktısındaki dry-run alanından okunur ve job imajı servisle aynı build'de güncellenir. Bir önceki canlı imaj depoda durmadan deploy yapılmaz (öneri; bizde geri dönüş penceresi servise göre 0,9 ile 16,5 gün arası). [Kural: Artifact Registry](#registry)

<a id="vaka-22"></a>

### 22. Migration ve kod birlikte çıktı, 11 dakika 500

Ürün B, Eyl 2026 [kanıtlı]

**11 dk** her mağaza sayfası 500 döndü

**Belirti:** 21 Eyl gecesi bir deploy'dan sonra sitedeki bütün mağaza sayfaları 11 dakika boyunca 500 döndü.

**Kök neden:** Yeni bir kolonu okuyan sorgu, o kolonu açan migration'la aynı değişiklikte çıktı. Belgeye göre migration ayrı bir yayın adımıydı, ama yayındaki imajda migration aracı ve dosyaları yoktu; yeni kod kolonu hiç görmemiş bir veritabanına karşı çalıştı ve yorumları okuyan her istek düştü.

**Bedeli:** 11 dakika boyunca her mağaza sayfası.

**Çözüm:** Kod, kolonu okumayı ve yazmayı bırakacak şekilde düzeltildi ve kural değişiklik kaydına yazıldı. Aynı gece migration aracı ve dosyaları kendi imajına kondu; API ile aynı sırrı kullanan tek seferlik bir Cloud Run job'ı olarak çalışıyor.

**Sonuç:** Kesinti 11 dakikada kapandı. Migration artık koddan önce kendi job'ıyla uygulanabiliyor ve araç veritabanı adresinden başka bir sır istemiyor.

Migration yalnız ekler ve koddan önce, kendi adımında ve bitmesi beklenerek çalışır; migration ile ona dayanan kod aynı deploy'da çıkmaz. [Kural: CI/CD ve ortamlar](#katman-7)

<a id="vaka-23"></a>

### 23. Yutulan hata site haritasını kesti, sonra deploy durdu

Ürün B, Eyl 2026 [ölçüldü]

**16 saat** deploy yok; 2.668 sayfa düştü

**Belirti:** 18 Eyl'de yayındaki site haritası 12.589 sayfadan 9.921'e düştü ve iki şehir sayfası bir saat boyunca önbellekten 404 döndü; hiçbir şey hata vermemişti. Ertesi gün düzeltmeden sonra altı build üst üste düştü ve 16 saat hiçbir deploy çıkmadı.

**Kök neden:** Katalog okuması başarısız olunca boş liste dönüyordu; boş liste 'hiç yok' sayılıp site haritası kısaldı, sayfa notFound() verdi ve Next bu 404'ü bir saat önbelleğe aldı. Hata dürüstçe fırlatılınca da site haritası build anında arka uca sorduğu ve build konteyneri arka uca ulaşamadığı için build düştü.

**Bedeli:** 2.668 sayfa site haritasından düştü; önbelleğe giren 404 bir saat boyunca, Google dahil, soran herkese gidiyordu. 16 saat deploy çıkmadı; site eski imajda kaldığı için bitmiş dört iş test edene 'hâlâ bozuk' göründü.

**Çözüm:** Okuma hataları artık 500 dönüyor: önbelleğe girmiyor ve arama motoru tekrar deniyor. Site haritası rotaları istek anında çalışıyor, build arka uca hiç sormuyor.

**Sonuç:** Haftalık zamanlanmış kontrol kesilen site haritasını bir saat içinde yakaladı. Düzeltmeden sonra yerel doğrulamada site haritası dizini 6 dosya, ilk dosya 13.348 adres.

Arka uç cevap veremezse 5xx döner ve bu boş sonuç sayılmaz; build arka uca bağlı olmaz ve 'deploy çıktı' demeden o commit'in build'inin başarıyla bittiği görülür. [Kural: Next.js web](#katman-3)

## Dış API

<a id="vaka-24"></a>

### 24. Harita API'si projenin faturasının %72'si oldu

Ürün B, Ağu–Eyl 2026 [ölçüldü]

**₺1.500** Ağustos'ta harita API'si; Eylül ₺657

**Belirti:** Ağustos faturasında harita API'si ₺1.500 tuttu: fotoğraf ₺924, ayrıntı ₺576. Projenin ₺2.081'lik Google faturasının ~%72'siydi ve ancak fatura gelince görüldü.

**Kök neden:** Listelerdeki her küçük resim sunucumuz üzerinden ayrı, ücretli bir fotoğraf isteğiydi; ücretsiz kotadan sonra 20 resimli bir sayfa ~₺6,6 tutuyordu. Bütün çağıranlar aynı geniş alan maskesini kullandığı için her istek en pahalı SKU'dan kesildi ve beş tek seferlik bakım komutu ~1.500 ayrıntı çağrısı yaptı.

**Bedeli:** Ağustos ₺1.500, Eylül ₺657. Bütçe uyarısı ve günlük kota tavanı yoktu.

**Çözüm:** Önbellek, eşik ve dar maske yetmedi. 11 Eyl'de sağlayıcı koddan çıkarıldı, 21 Eyl'de API projede kapatıldı; yerine kendi konum tablosu, zincirlerin mağaza listeleri ve OpenStreetMap geldi.

**Sonuç:** Harita API'sinin faturası ₺0. Hiçbir mağaza satırı kaybolmadı; bedeli puanların ve çalışma saatlerinin gitmesi oldu.

Ücretli bir API; en az iki alternatif, en kötü günün faturası, günlük kota tavanı, saklama şartları ve çıkış yolu yazılmadan açılmaz. [Kural: Pahalı dış API'ler](#pahali-api)

<a id="vaka-25"></a>

### 25. Ödeme webhook'u en az 21 gün sessizce 500 döndü

Ürün A, Eyl 2026 [kanıtlı]

**21+ gün** her webhook teslimi 500 aldı

**Belirti:** Abonelik sağlayıcısının webhook'u en az 2 Eyl'den 23 Eyl akşamına kadar her teslimde 500 aldı. Logda tek satır yoktu ve kimse fark etmedi.

**Kök neden:** İki sebep vardı: havuz simple protocol ile çalıştığı için ham JSON gövdesi jsonb kolonuna bytea olarak gidip reddediliyordu, bazı olay türleri 'aliases' alanı taşımadığı için de NOT NULL kolona NULL yazılıyordu. İşleyici hatayı loglamadan 500 dönüyordu ve yerel entegrasyon testi prod'un bağlantı modunu kullanmıyordu.

**Bedeli:** Premium'u kaybeden kullanıcı olmadı: uygulama aboneliği SDK'dan açıyor, sunucu da her oturumlu istekte 10 dakikalık TTL ile sağlayıcıya soruyordu. Kaybolan, anında sunucu güncellemesi ve 23 Eyl öncesinin bütün olay kayıtlarıydı.

**Çözüm:** Önce ikinci sebep düzeltildi ve hata log satırı eklendi; bir sonraki teslimin logu birinci sebebi gösterdi. Düzeltme 23 Eyl 20:00'de canlıya çıktı.

**Sonuç:** Düzeltmeden sonraki teslimler olay tablosuna yazılıyor; Ekim'deki deneme süresi sayıları artık bu webhook kayıtlarından okunuyor.

Loglanmamış bir 500 tahmin edilmez: önce log satırı eklenir, deploy edilir, sonraki olay okunur; webhook tek 5xx'te alarm verir ve veritabanı testleri prod'un bağlantı moduyla koşar. [Kural: Go API](#katman-2)

<a id="vaka-26"></a>

### 26. Sosyal paylaşım hattı bir ay sessizce durdu

Ürün C, Ağu–Eki 2026 [ölçüldü]

**30 / 30** paylaşım denemesi 402 aldı

**Belirti:** Günlük X paylaşımı 27 Ağu'dan sonra hiç çıkmadı ve bir ay fark edilmedi; ürün sahibi 'X çalışmıyor' deyince bakıldı. 28 Eyl sabahı Instagram paylaşımı ve haftalık rapor da düştü.

**Kök neden:** X'in API kredisi bitmişti: hesap okuma ve medya yükleme başarılı, yalnız gönderi oluşturma '402 Payment Required' alıyordu, yani 'token sağlam mı' kontrolü arızayı göstermedi. Instagram'ın 60 günlük token'ı otomatik yayının açılışından ~60 gün sonra sessizce doldu; iki durum da günlük inceleme e-postasında birer satırdı, alarm yoktu.

**Bedeli:** 28 Ağu–27 Eyl arası 30 paylaşım denemesinin 30'u 402 aldı. Bulut logları 30 gün tuttuğu için ilk 11 günün satırları silinmişti; tam sayı yalnız veritabanındaki paylaşım tablosunda kaldı.

**Çözüm:** 27 Eyl'de X kapatıldı, 7 Eki'de kredi yüklenip açıldı. Instagram için süresiz bir system user token'ı alındı; yalnız başarısız platformu yeniden deneyen uçlar paylaşımları çıkardı.

**Sonuç:** İki hat da çalışıyor. Başarısız adım artık 'failed' olarak tabloya yazılıyor; ilk olayda tablo kısıtı yüzünden yazılamamıştı.

Dış platformun 402'si, 401'i ve token bitişi alarm üretir; özet e-postasındaki bir satır yetmez. Denetim kaydı tabloda tutulur ve sunucu kişiye bağlı olmayan, süresiz bir token kullanır. [Kural: İçerik otomasyonu](#icerik)

## E-posta

<a id="vaka-27"></a>

### 27. Yeni alan adının kodları kurum geçitlerinde bekledi

Ürün A, Eki 2026 [kanıtlı]

**4 kurum** giriş kodları posta geçidinde bekledi

**Belirti:** Giriş kodu e-postaları, sağlayıcı 'teslim edildi' dediği halde dört büyük kurumun kendi posta geçidinde bekledi; kod gelince süresi dolmuş oluyordu.

**Kök neden:** Alan adı yalnız birkaç haftalıktı ve güvenlik firmalarının bazısı onu 'yeni kayıtlı, yüksek risk' ya da 'denenmemiş' sayıyordu; 'teslim edildi' yalnız geçidin kabul ettiği anlamına geliyordu. Kod 10 dakikada ölüyor ve yeniden istemek öncekini geçersiz kılıyordu.

**Bedeli:** Etkilenen giriş sayısı ölçülmedi; geç gelen her e-postadaki kod 'hatalı ya da süresi dolmuş' oluyordu.

**Çözüm:** 2 Eki'de kod 30 dakika geçerli oldu, en yeni 3 canlı kod kabul ediliyor ve 'tekrar gönder' öncekini öldürmüyor; kod e-postası bağlantısız ve uzak görselsiz, logo e-postanın içine gömülü, takip kapalı. Alan adını 'yeni' ya da 'denenmemiş' sayan iki güvenlik firmasına kategori başvurusu yapıldı; öbür ikisi onu zaten finans sayıyordu.

**Sonuç:** Başvurular aynı akşam 'Finans' kategorisiyle döndü. Eski uygulama sürümlerinin tek tekrar yolu da artık ilk kodu canlı bırakıyor.

Alan adı ilk kullanıcıdan haftalar önce alınıp SPF, DKIM ve DMARC kurulur ve kategori başvurusu yapılır; kod e-postası bağlantısız gider ve kod geç gelse de çalışır. [Kural: E-posta](#katman-9)

## Performans

<a id="vaka-28"></a>

### 28. Konum saniyede bir yazıldı

Ürün B, Eki 2026 [ölçüldü]

**~294 istek** 14 dakikada; çoğu 429 aldı

**Belirti:** 4 Eki'de oturum açmış tek bir ziyaretçi 14 dakikada konum güncelleme ucuna ~294 istek gönderdi; 200'den fazlası 429 aldı.

**Kök neden:** Arama sayfası tarayıcının canlı konum izlemesinden gelen her okumayı, birkaç santimetrelik kaymaları da, sunucuya yazıyordu; bu yaklaşık saniyede birdi. Yer arama paneli de canlı konuma bağlı olduğu için her harfte yeniden soruyordu.

**Bedeli:** Kişi kendi istek sınırını harcadığı için asıl yaptığı işler, yer arama ve ziyaret doğrulama, de 429 aldı. Kabul edilen her istek bir veritabanı yazmasıydı ve uyuması gereken veritabanını uyanık tutuyordu.

**Çözüm:** Aynı akşam konum yalnız ilk okumada, 200 m ve üstü harekette ya da kendiliğinden en çok dakikada bir yazılmaya başladı; oturum yoksa hiç gönderilmiyor ve yer arama ~1 km'ye yuvarlanmış konumla soruyor.

**Sonuç:** Yerel ölçümde birkaç santim arayla 100 okuma ve bir 500 m'lik hareket 101 yerine 1 istek gönderdi; yayından sonra 429 görülmedi.

Sensörden gelen sürekli veri sunucuya yalnız anlamlı değişince ve seyrekleştirilerek yazılır; hiçbir istemci kullanıcının kendi istek sınırını arka planda harcamaz. [Kural: Performans](#performans)

## Yedek

<a id="vaka-29"></a>

### 29. İlk yedek 7 bayttı

Ürün A, Eyl–Eki 2026 [ölçüldü]

**7 bayt** ilk yedek; döküm 701.738 bayttı

**Belirti:** 23 Eyl'de kurulan günlük veritabanı dökümünün ilk çalışması iki denemede de kovaya 7 baytlık nesne yazdı; döküm 701.738 bayttı.

**Kök neden:** İmajdaki busybox wget ikili dosyayı ilk sıfır baytına kadar gönderiyor.

**Bedeli:** Neon dışındaki ilk kopya kullanılamazdı; Neon'un 7 günlük geçmişi ve günlük snapshot'ı ayrıca duruyordu. Yedeğin kendisi ucuz: 70 MB'lık veritabanında geçmiş ve snapshot ayda ~5 sent, döküm kovası bir sentin altında.

**Çözüm:** Yükleme sonrası boyut karşılaştırması farkı yakaladı ve yükleme curl'e çevrildi. Her döküm geçici bir Postgres'e geri yüklenip tablo sayısı kontrol ediliyor; başarısızlık iki yöneticiye e-posta atan alarma bağlı.

**Sonuç:** 24 Eyl–8 Eki'de 15 zamanlanmış çalışmanın 15'i ilk denemede başarılı, betik 5–8 sn sürüyor. Alarm bilerek bozulan bir çalışmayla denendi: hata 16:57, alarm 17:01, kendiliğinden kapanış 17:11.

Her döküm alındığı anda geri yüklenerek ve boyutu karşılaştırılarak doğrulanır; alarm sahte bir hatayla uçtan uca denenir. Başarı satırının yokluğu da alarm üretmeli (öneri; henüz kurulmadı). [Kural: Veritabanı yedeği](#yedek)

## Ekip ve ajan süreci

<a id="vaka-30"></a>

### 30. Kural ve iş geçici yerde kaldı

Birkaç ürün, Eyl–Eki 2026 [kanıtlı]

**2 build** istenmeden başladı; iş kayboldu

**Belirti:** 20 Eyl'de kod ajanı istenmeden iki prod mobil build başlattı ve sürümü sormadan yama yerine ara sürüm numarasını artırdı. 8 Eki'de bir elektrik kesintisi bilgisayarı yeniden başlattı ve geçici klasördeki dört worktree, deneme veritabanı ve commit'lenmemiş ajan işi silindi.

**Kök neden:** Yayın kararlarının ürün sahibine ait olduğu kuralı yalnız bir ajanın kendi hafızasındaydı; başka araçlar ve oturumlar onu görmüyordu. Uzun işler /private/tmp altındaki oturum klasöründe duruyordu ve bu klasör yeniden başlatmada siliniyor.

**Bedeli:** İki build iptal edildi. Kesintide commit'lenmemiş iş kayboldu; aynı yerde duran bir model değerlendirmesinin ham sonuçları ve bir izleme betiği de daha önce gitmişti.

**Çözüm:** Kural 20 Eyl'de beş deponun ajan dosyasına (CLAUDE.md) yazıldı: kod biter, commit, tek satır rapor, karar beklenir. Uzun işlerin dosyaları artık kalıcı klasörde, ajan işi dalda erken ve sık commit'leniyor; workflow günlükleri kurtarma kaynağı olarak tutuluyor.

**Sonuç:** Sonraki mobil build'ler ürün sahibinin açık sözüyle alındı; model değerlendirme sonuçları kalıcı bir klasörde yeniden üretiliyor.

Kalıcı çalışma kuralı depodaki ajan dosyasına yazılır; uzun işin dosyası kalıcı klasörde durur ve iş dalda sık commit'lenir. [Kural: Proje hafızası](#hafiza)

Rakamı birincil kaynakta doğrulanamayan, hâlâ açık olan, rehberin dört ürünü dışında kalan ya da yer sınırı yüzünden başka bölümlerde anlatılan olaylar deftere alınmadı.
