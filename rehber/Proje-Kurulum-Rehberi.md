<!-- Proje Kurulum Rehberi, ajan sürümü. PDF ile aynı içerik; düzen yok, bağlantılar bölüm kimliklerine gider. -->

Postgres, Go, Next.js ve Expo ile Google Cloud'da

# Proje Kurulum Rehberi

Yeni bir ürünü ilk günden ucuz, güvenli ve kullanıcıyı kırmadan kurmak için canlı ürünlerimizden çıkan kurallar.

**Burak Altıntaş**. Bu rehberdeki kurallar, ürünlerimi kurarken yediğim dayaklardan, ödediğim faturalardan ve bulduğum çözümlerden çıktı.

Veritabanı
Neon Postgres
Frankfurt, uyuyabilen; prod Launch, test Free
API
Go API
Cloud Run min 0; tek yazma noktası, okumalar bellekten
Web
Next.js 16
Cloud Run min 0; SSR ve ISR, bot kapısı ilk satırda
Mobil
Expo
CNG, New Arch, EAS; uzaktan kontrol kiti kurulmadan yayın yok
DNS Cloudflare'de, servisler Google Cloud europe-west1'de, veritabanı Neon'da.
Yeni başlayan ürün
~₺55–135/ay
Neon Launch kullandığı kadar, asgari ücret yok; Cloud Run ücretsiz kotada.
Günlük kullanıcılı ürün
~₺510–690/ay
Toplamın en az %60'ı Neon.
**Bizde bugün:** Ürün A ~₺610; diğer üç ürün ₺5–510.

Dört ürünün toplamı ~₺1.300/ay; Eylül'de ~₺3.900–4.400'dü. Alan adı ve mağaza ücretleri zorunlu sabit gider, hesaba katılmadı.

Her maddenin başındaki etiket kanıt düzeyidir; maddenin isteğe bağlı olduğunu söylemez.
[kanıtlı]
Bizim prod'da çalışıyor.

[ölçüldü]
Rakamı kendi ölçümümüz ya da faturamız gösteriyor.

[öneri]
Bizde denenmedi ya da yalnız sağlayıcı belgesine dayanıyor.

**Ekim 2026** Fiyatlar 1 USD = 49 TL ile.

<a id="iki-yol"></a>

Başlarken

# İki yol

Aynı ürünü iki ekip kuruyor; ikisi de yalnız ürün akışlarına bakıyor, yolları gün 0'da ayrılıyor. Önlemsiz yolu biz yürüdük. Kırmızı rakamlar canlı ürünlerimizin Ağustos ile Ekim 2026 arasındaki fatura ve kayıtları, yeşiller aynı ürünlerin düzeltmelerden sonraki hali.

### Önlemsiz yol

Ekip yalnız ürün akışlarına bakar, ajanın önerdiği her şeyi onaylar. Hazır servis hesabı, kotasız API anahtarı, canlıya bağlı yerel ayar ve alarmsız servisler öyle kalır; mobil kit ve yedek sonraya. Sorunu fatura ya da tesadüf haber verir.

~₺3.900–4.400/ay
Dört ürünümüzün Eylül 2026 bulut faturası

### Önlemli yol

Ekip gün 0'da bu rehberi ajana verir. Ajan altyapıyı [kurulum planındaki sırayla](#kurulum-plani) kurar: ayrı faturalama hesabı ve bütçe uyarısı, uyuyabilen veritabanı, bot kapısı, alarmlar, doğrulanan yedek, mobil kit. Kararları ekip verir; sonra o da yalnız ürün akışlarına bakar.

~₺1.300/ay
Aynı dört ürün, düzeltmelerden sonra; 8 Ekim tahmini
Bunlar boş deneme projeleri değil
Her gün
Ürün A'da giriş yapan kullanıcılar, ödeme yapan aboneler ve iki mağazada yayında bir uygulama.

~18 bin sayfa
Ürün B'nin herkese açık kataloğu; arama motorları ve kazıyıcılar her gün geziyor.

Her sabah
Ürün C sunucudan otomatik içerik üretip sosyal hesaplarda yayınlıyor.

~500 bin satır
Aktif 14 depoda kod, %26'sı test; 1–7 Ekim'de 11 servise ~517 bin istek geldi.

## Aynı ürünler, kurallardan önce ve sonra

ÖnlemsizÖnlemliNeon ölçümü ve fatura; her satır kendi ölçeğinde
_Grafik: Önce ve sonra, her satır kendi ölçeğinde: Ürün A veritabanı ~6,2 → ~3,2; Ürün B veritabanı 6,5 → ~2,1; Ürün B harita API'si ₺1.500 → ₺0_

## Arıza ne zaman fark edildi

Üç arızada da alarm yoktu. En alttaki satır, alarmlı düzende hatadan alarma geçen 4 dakika; aynı ölçekte.

_Grafik: Arızanın fark edilmesine kadar geçen süre: X kredisi bitti, her X paylaşımı 402 aldı: 30 gün; Ödeme webhook'u log yazmadan 500 döndü: en az 21 gün; Test canlıya sahte hesaplama yazdı: 11 gün; Alarm denemesi: 4 dk_
Gün 0 düzeninde her biri bir alarmdır: 402 ve token süresi, ERROR > 0, webhook yolunda tek 5xx, OOM. Testler ise ağa hiç çıkmaz. Ayrıntı: [Gözlem ve alarmlar](#katman-10).

## Alan alan

Solda önlemsiz yolun bize bedeli, sağda gün 0'da yapılan ve sonucu. Etiket gün 0 kuralının kanıt düzeyidir; bağlantı kuralın durduğu bölüme gider. Olayların tamamı [Vaka defteri](#vakalar)'nde.

~₺475/ay
Ürün A'nın 7/24 uyanık veritabanının aylık fazlası

[Postgres](#katman-1)[Mimari](#mimari)

Veritabanı

### Uyuyamayan veritabanı

**Önlemsiz yolda:** İşler zamanlayıcıyla veritabanına soruyor, gece tarayıcıları her sayfayı yeniden hesaplatıyordu; Ürün A'nın veritabanı 18–23 Eylül'de 7/24 uyanıktı. Ürün C'de yeni bir sayfa kendi veritabanını günde ~74 kez uyandırdı.

**Gün 0'da[ölçüldü]:** Veritabanına zamanlayıcıyla soran kod yok; havuz tabanı 0, boşta 90 sn. Herkese açık okumalar API belleğinden verilir, değişiklik işaretiyle tazelenir. Her uyanış nedeniyle loglanır.

**Sonuç** Ürün A günde ~3,2 CU-saate indi. Ürün B'de bellek kopyası 6,5'i 4–7 Ekim ortalamasında ~2,1'e indirdi.

₺1.500
Ağustos'ta tek bir harita API'sinin faturası

[Pahalı dış API'ler](#pahali-api)

Dış API

### Tavansız ücretli API

**Önlemsiz yolda:** Ürün B'nin harita API'si bütçe uyarısı ve kota tavanı olmadan açıldı. Projenin Ağustos Google faturasının ~%72'sini yazdı, ancak fatura gelince görüldü. Eylül'de ₺657 daha.

**Gün 0'da[ölçüldü]:** Ücretli API; birim fiyatı, en kötü günü, iki alternatifi ve çıkış yolu yazılmadan açılmaz. Sağlayıcıda sert kota, ürünün kendi hesabında bütçe uyarısı.

**Sonuç** Açık veri, markaların kendi listeleri ve kendi tablomuzla 21 Eylül'den beri ₺0.

%41
Tek bir bulut kazıyıcısının Ürün B'nin sitesindeki web isteği payı

[Botlar](#botlar)

Botlar

### Kapısız site

**Önlemsiz yolda:** robots.txt'yi dinlemeyen kazıyıcı günde 275 istekle başladı, ~25.700'e çıktı ve UI baytlarının %44'ünü aldı. Bir ürünün Google faturasının çoğu bot çıkış trafiğiydi.

**Gün 0'da[ölçüldü]:** Bot kapısı proxy'nin ilk satırında. İlk gün yalnız başka sitelerde gölgeden geçmiş kurallar reddeder; arama ve AI cevap motorları açık kalır.

**Sonuç** Kural açıldıktan sonraki 24 saatte 6.654 istek reddedildi. Kapının bedeli istek başına ~4–10 µs; ek ücreti yok.

21 gün
Ödeme webhook'u en az bu süre boyunca log yazmadan 500 döndü

[Gözlem ve alarmlar](#katman-10)

Gözlem

### Alarmsız servis

**Önlemsiz yolda:** Ürün A'nın ödeme webhook'u en geç 2 Eylül'den 23 Eylül'e kadar her teslimde 500 döndü; kullanıcı etkilenmedi, olayların kaydı kayboldu. Ürün B'nin sitesinde bellek taşması günde 192'ye vardı, gerçek kullanıcılar da 503 aldı; alarm yoktu, tesadüfen bir maliyet analizinde bulundu.

**Gün 0'da[kanıtlı]:** Alarmlar ilk kullanıcıdan önce kurulur ve uçtan uca denenir. Bizde canlıda olanlar: erişim, 5xx, yedek, yedek zamanlayıcısı ve açılışta veritabanı. Ödeme durumu üç yoldan beslenir.

[öneri] ERROR > 0, OOM ve webhook yolunda tek 5xx alarmı da gün 0'da kurulur; bizde yoktu.

**Sonuç** Denemede hatadan alarma 4 dakika.

9 + 10
19 Eylül–7 Ekim'de çıkan iOS ve Android mağaza build'i

[Mobil kit](#mobilkit)[Mobil dağıtım](#dagitim)

Mobil

### Kitsiz ilk sürüm

**Önlemsiz yolda:** Eski sürümlerin ekran metni sabitti, sunucudan yazı konacak yer yoktu. Yeni bir akış eski sürümdekilere duyurulamadı; o akışı kullananların çoğu güncelleyene kadar 1 Ekim yerine 5 Ekim'e kaldı. Her küçük düzeltme mağaza sürümü oldu; iOS build kotası 22 Eylül'de doldu.

**Gün 0'da[ölçüldü]:** Uzaktan kontrol kiti ilk mağaza sürümünde: zorunlu güncelleme, sunucudan bildirim ve duyuru, bayrak ve kill switch; release build'de, telefonda denenmiş. OTA önerilir.

**Rakam** Bu 19 build'in 11'i yalnız JS idi; OTA'yla mağazasız çıkabilirdi.

30 gün
X kredisi bitince günlük paylaşımların sessizce 402 aldığı süre

[İçerik otomasyonu](#icerik)

Sosyal paylaşım

### Sessizce duran yayın

**Önlemsiz yolda:** Ürün C'nin X kredisi bitti; durum özet e-postasında bir satırdı. 60 günlük Instagram token'ı haber vermeden öldü.

**Gün 0'da[öneri]:** Yayın sunucudan, resmi API'lerle. Her paylaşım tabloda bir satır; 402 ve token süresi alarm olur; harcama tavanı ve kapatma anahtarı vardır.

**Bizde** 30 başarısız denemenin hepsi paylaşım tablosunda duruyordu; loglarda ilk 11 gün silinmişti. Instagram süresiz Meta token'ına geçti.

44
Testin canlıya yazıp herkese açık listede gösterdiği sahte hesaplama

[Kullanıcıyı kırmadan](#kirmama)

Test verisi

### Canlıya bağlı yerel ayar

**Önlemsiz yolda:** Ürün A'nın portal testi 17–28 Eylül'de canlıya yazdı; satırlar herkese açık 'popüler' listede göründü. Simülatör iki gün canlıya analitik yazdı. Canlıya bağlı bir dizüstü 13 giriş kodundan 9'unu yuttu.

**Gün 0'da[kanıtlı]:** Yerel varsayılan hiçbir zaman prod değildir. Testlerde ağ kapalı; simülatör ve dizüstü test API'sine bağlanır, hedef çalışma anında logdan doğrulanır.

**Sonuç** 28 Eylül'de portal testlerinde ağ kesildi; öteki testlerden canlıya yazan çıkmadı.

38 gün
Giriş kodları posta geçidinde beklerken alan adının yaşı

[E-posta](#katman-9)

E-posta

### Yeni alan adından giriş kodu

**Önlemsiz yolda:** Kodlar dört kurumun posta geçidinde bekledi; sağlayıcının 'teslim edildi' demesi yalnız geçidin kabulüydü. Kod 10 dakikada öldüğü için geç gelen her kod 'süresi dolmuş' oldu.

**Gün 0'da[kanıtlı]:** Alan adı ilk kullanıcıdan haftalar önce alınır, güvenlik firmalarına kategori başvurusu yapılır. Kodlar ayrı alt alan adından ve outbox'tan gider.

**Sonuç** Başvurular aynı akşam döndü; kodun ömrü 30 dakikaya çıktı.

Editor
Web servisinin çalıştığı hazır servis hesabının rolü

[Güvenlik](#katman-8)

Güvenlik

### Varsayılan servis hesabı

**Önlemsiz yolda:** Web servisi projenin hazır, Editor yetkili hesabıyla çalışıyordu. Web çatısındaki yamasız bir açıkla birleşince proje ele geçirilebilir hale geldi. 23 Eylül'de bulundu, aynı gün kapatıldı.

**Gün 0'da[kanıtlı]:** Her servis rolsüz, kendi hesabıyla çalışır; önce tetikleyicilere kendi build hesabı verilir, sonra Editor kaldırılır. Sırlar Secret Manager'da, çatı güncel yamada.

**Sonuç** Siteler rolsüz hesaba geçti; aynı gün projede Editor taşıyan hesap kalmadı.

7 bayt
Ürün A'da ilk günlük dökümün kovaya yazdığı nesne

[Yedek](#yedek)

Yedek

### Denenmemiş yedek

**Önlemsiz yolda:** Döküm alınıyor, yedek var sanılır. Bizde ilk çalışmada geri yükleme kontrolü geçti ama kovaya 7 baytlık nesne yazıldı; boyut karşılaştırması olmasa Neon dışındaki tek kopya kullanılamazdı. Neon Launch'ta geçmişin varsayılanı 1 gündür.

**Gün 0'da[ölçüldü]:** Her döküm geçici Postgres'e geri yüklenerek ve yükleme sonrası boyutla denetlenir; başarı satırı gelmezse alarm çalar. Geçmiş 7 güne çıkarılır.

**Sonuç** 24 Eylül–8 Ekim'de 15 çalışmanın 15'i ilk denemede başarılı.

2 build
Ajanın 20 Eylül'de istenmeden başlattığı prod build

[Proje hafızası](#hafiza)[Kullanıcıyı kırmadan](#kirmama)

Ajan süreci

### Kural ajanın hafızasında

**Önlemsiz yolda:** Ajan 20 Eylül'de istenmeden iki prod build başlattı ve sürüm numarasını sormadan seçti; kural yalnız onun hafızasındaydı. 8 Ekim'de bir elektrik kesintisi geçici klasördeki commit'lenmemiş işi sildi.

**Gün 0'da[kanıtlı]:** Deploy, build ve sürüm numarası ürün sahibinin kararıdır, depodaki ajan dosyasında yazılıdır. Uzun iş kalıcı klasörde ve dalda sık commit'lenir; CHANGELOG ve durum dosyası güncel tutulur.

**Sonuç** Yayın kuralı 20 Eylül'de beş deponun ajan dosyasına yazıldı; sonraki build'ler ürün sahibinin açık sözüyle alındı. Uzun işler 8 Ekim'den beri kalıcı klasörde ve dalda.

## İki yolun bedeli

Soldakiler bizim faturamız ve kayıtlarımız. Sağdakiler bugünkü ölçüm, dolar tutarları 49 TL ile çevrildi; kurulumun ekip zamanını ölçmedik.

### Atlamanın bize bedeli

### Önlemin bedeli

~₺2.600–3.100/ay
Dört ürünün Eylül faturasıyla 8 Ekim'deki aylık tahmin arasındaki fark.

₺0
Bot kapısı; istek başına ~4–10 µs.

₺2.157
Harita API'sinin Ağustos ve Eylül faturası; Eylül'deki ₺657 üst satırdaki farkın içinde. 21 Eylül'den beri ₺0.

₺0
Alarmların bugünkü ücreti. Uptime kontrolü kontrol başına ayda ~26.000 çalıştırma, proje kotasının %3'ü; bizdeki üç kontrol ~80.000, %8.

21 ve 30 gün
Kaydı kaybolan ödeme olayları (en az 21 gün) ve X'e atılamayan paylaşımlar (30 gün).

~₺2,5/ay
Üç katmanlı yedek: 7 gün geçmiş, 14 gün snapshot ve her gün geri yüklenerek doğrulanan döküm; 70 MB'lık veritabanında.

7 gün
Kota bitince bir iOS sürümünün beklediği süre: 24 Eylül'den 1 Ekim'e; ayda $19'luk plan alınmadı.

~₺2/ay
Bellek kopyasını tazeleyen değişiklik işareti.

3 build
Kullanıcıda kaldıkça güncelleme uyarısını hiç gösteremeyecek Android build'i; uyarı gerçek release build'le telefonda denenmemişti.

24 adım
Hızlı yolun gün 0'dan ilk mağaza sürümüne kadar sırası. Kurulumu ajan yapar, ekibe kalan iş kararlardır.

Sırada
[Bu rehber nasıl kullanılır](#kullanim) ekibe ve ajana neyi nasıl okuyacağını anlatır. Hemen kurmak isteyen [En hızlı kurulum yolu](#hizli) ile başlar; ajanın soracağı kararlar [Verilecek kararlar](#kararlar) bölümünde.

<a id="icindekiler"></a>

# İçindekiler

Her başlık bir bağlantıdır; tıklanınca bölüme gider.

### Başlarken[İki yol](#iki-yol)
Aynı ürün, önlemsiz ve önlemli: ilk aylarda ne olur.

[Bu rehber nasıl kullanılır](#kullanim)
Ekip ve yapay zekâ ajanı için; dört ürünümüz.

[Verilecek kararlar](#kararlar)
Ajanın sorması gereken kararlar ve iş sırası.

[En hızlı kurulum yolu](#hizli)
Gün 0'dan ilk mağaza sürümüne adım adım sıra.

[Botlar ve maliyet](#cevaplar)
Önce iki cevap: kimi engelleriz, ne tutar.

[Vaka defteri](#vakalar)
Yaşadığımız sorunlar, bedeli, çözümü ve kuralı.

[Kısaca ve on ilke](#bakis)
Yığının özeti ve her kararın arkasındaki ilke.

[Parçalar ve akışlar](#mimari)
Mimari şeması, bileşenler ve akışlar.

### Kurallar[Kullanıcıyı kırmadan değiştirmek](#kirmama)
Sekiz başlıkta 76 kural ve izleme takvimi.

[Proje hafızası ve devir](#hafiza)
CHANGELOG, durum, yapılacaklar, kararlar; yeni gelen hızla başlar.

### Katmanlar[1Postgres (Neon + pgx)](#katman-1)
Uyuyabilen veritabanı, pooler ve roller.

[2Go API](#katman-2)
Tek yazma noktası; geçici hata 503, 401 değil.

[3Next.js web](#katman-3)
Sunucuda tam HTML, ISR ve değişiklik işareti.

[4React Native (Expo) mobil](#katman-4)
CNG, New Arch; kit kurulmadan yayın yok.

[Mobil uzaktan kontrol kiti](#mobilkit)
Mağazaya çıkmadan önce kurulacak 11 parça; OTA dışında hepsi şart.

[Mobil build ve dağıtım](#dagitim)
EAS mi, kendi hattımız mı; kota ve kullanım.

[5Kenar, DNS ve alan adı](#katman-5)
Cloudflare DNS ve alan adının bağlanma yolu.

[6Bulut altyapısı (Cloud Run)](#katman-6)
min 0, kendi faturalama hesabı, servis tanımı.

[7CI/CD ve ortamlar](#katman-7)
Bir kez build, onay kapılı terfi.

[8Güvenlik ve botlar](#katman-8)
En az yetki, Secret Manager, kapı.

[Botlara karşı tutum](#botlar)
Aç, sınırla, izle, engelle; kapının sırası.

[9E-posta](#katman-9)
Ayrı alt alan adı, outbox ve gönderim bütçesi.

[İçerik otomasyonu](#icerik)
X, Meta ve LinkedIn'e onaylı, kayıtlı ve tavanlı paylaşım hattı.

[10Gözlem ve alarmlar](#katman-10)
İlk kullanıcıdan önce denenmiş alarmlar.

[Uyarılar kime, nasıl ulaşır](#uyarilar)
Dış API hatası, bitmek üzere bütçe ve kota, süre dolumu: ürün sahibine.

[Analitik ve admin](#analitik)
Gün 0'dan olay kaydı ve yönetim uçları.

[11Yedekler](#katman-11)
Dört katman; kuralları sonraki bölümde.

[Veritabanı yedeği ve geri yükleme](#yedek)
Katmanlar, tarifler, runbook, tatbikat, KVKK.

### Ürün ve büyüme[Gerçek zamanlı ve mesajlaşma](#mesajlasma)
Akışa göre push, yoklama, SSE ya da WebSocket; mesaj yapısı.

[Tasarım sistemi ve devir](#tasarim)
Tek token kaynağı, tasarımdan koda devir, karar kaydı.

[SEO ve GEO](#seo)
Ne yaptık, ne çıktı, hangi işler hiç bitmez.

### Para ve hız[Ne tutar?](#maliyet)
Üç basamak, dört ürünümüz ve kalem kalem model.

[Startup kredileri](#krediler)
Nereye, ne zaman başvurulur.

[Ücretsiz katmanları sonuna kadar kullanmak](#ucretsiz)
28 servisin sınırı, aşınca ne olduğu, izleme.

[Pahalı dış API'ler](#pahali-api)
Places vakası, alternatifler ve açmadan önce liste.

[Performans](#performans)
Ölçümler, sayılı kurallar ve hedefler.

### Ölçüm ve denetim[Projelerimiz ne büyüklükte](#boyutlar)
14 depo: satır, test, görsel, commit.

[Yeni depo için kurallar](#depo-kurallari)
Özel depo, sır taraması, büyük dosya kapısı, dallar.

[Artifact Registry ve build kuralları](#registry)
İmaj, temizlik, geri dönüş, build dakikası.

### Son[KVKK ve veri yeri](#kvkk)
Veri bölgesi, işleyen listesi, aktarım.

[Kontrol listesi](#kontrol)
Dört aşama, işaretlenecek kutular.

[Asla](#asla)
Gün 0'dan geçerli yasaklar.

[Ek: Gün 0 önlemleri](#onlemler)
Henüz yaşamadığımız ama her yeni projede önceden alınacak 26 önlem.

[Kaynaklar](#kaynaklar)
Sağlayıcı belgeleri, fiyatlar ve şartlar.

<a id="kullanim"></a>

Başlarken

# Bu rehber nasıl kullanılır

Bu rehber ürünün kodunu yazmaz; kodun etrafını toplar ve işin derli toplu başlamasını sağlar. Rehberi ekip okur, ajan uygular; ajan kararları sorar ve altyapıyı kurar, ekip ürün akışlarına bakar. Bu bölüm kimin neyi okuyacağını, ajana yapıştırılacak ilk mesajı, işin kimde olduğunu ve örneklerdeki dört ürünü verir.

## Bu rehber nedir

Rehber tek bir yığını anlatır: Neon Postgres, Cloud Run'da Go API, Next.js ve Expo; DNS Cloudflare'de. Kurallar ürünlerimizin faturalarından, loglarından ve yaşadığımız olaylardan çıktı (Ağustos–Ekim 2026); fiyatlar Ekim 2026'nın, dolar 49 TL ile çevrildi. Her maddenin başındaki etiket o maddenin kanıt düzeyidir.

[kanıtlı] bizim prod'da çalışıyor; [ölçüldü] rakamı kendi ölçümümüz ya da faturamız gösteriyor; [öneri] bizde denenmedi ya da yalnız sağlayıcı belgesine dayanıyor. **Etiket maddenin isteğe bağlı olduğunu söylemez; bir öneriyi atlamak da ürün sahibinin kararıdır ve docs/DECISIONS.md'ye yazılır.**

## İki okuma yolu

Aynı içerik iki biçimde: PDF ekip için, Markdown kopyası ajan için. Markdown kopyası dışındaki her başlık ilgili bölüme bağlantıdır.

### Ekip lideri

PDF'i okur, ürün sahibiyle kararları verir, ajanın raporlarına bakar.

[İki yol](#iki-yol)
Önlemsiz yolun bize bedeli; ilk aylarda ne olur.

[Vaka defteri](#vakalar)
30 olay: bedeli, çözümü ve kuralı.

[En hızlı kurulum yolu](#hizli)
Gün 0'dan ilk mağaza sürümüne 24 adım, sırasıyla.

[Kontrol listesi](#kontrol)
Dört aşamada 29 kutu; ajanın raporu buna göre okunur.

### Yapay zekâ ajanı

Markdown kopyasını okur; sorar, kurar, kaydeder.

Markdown kopyası
Baştan sona, bölüm bölüm. Grafikler orada tek satırdır, kimi yalnız başlıktır.

[Verilecek kararlar](#kararlar)
Ürün sahibine tek tek sorulur; cevaplar DECISIONS.md'ye.

[Ajanın kurulum planı](#kurulum-plani)
Aşama aşama; her aşamanın kontrolü koşulur.

[Katmanlar](#katman-1)
Kurulan katmanın bölümü o sırada yeniden açılır.

İki yol kararlarda buluşur; ajan sorar, ürün sahibi cevaplar (küçük ekipte bu kişi ekip lideri de olabilir). Cevabı gelmeyen satır "KARAR BEKLİYOR" diye kalır.

## Ajana ilk mesaj

Markdown kopyası depoya ya da sohbete eklenir, bu metin ilk mesaj olarak yapıştırılır. Açılı parantezli yer ekibin cevabıyla dolar.

```
Yeni bir ürün kuruyoruz: <ürün tek cümleyle; kim kullanır>.
Ekteki Proje-Kurulum-Rehberi.md bu işin rehberi.

1. Rehberi baştan sona oku; şablonlar, kurallar ve tablolar dahil. Dosya uzun; bölüm bölüm oku, kurarken o katmanın bölümünü yeniden aç.
2. "Verilecek kararlar" bölümündeki soruları bana tek tek sor. Bir tercihim yoksa rehberin varsayılanını öner ve nedenini bir cümleyle söyle.
3. Cevapları docs/DECISIONS.md'ye K-001'den başlayarak yaz, ürün özetini AGENTS.md'ye. Cevabı gelmeyen satır "KARAR BEKLİYOR" diye kalır.
4. Altyapıdan önce "Proje hafızası ve devir" bölümündeki gün 0 dosyalarını aç: AGENTS.md, CLAUDE.md (yalnız @AGENTS.md), CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md, docs/runbooks/ ve docs/handoff/.
5. "Ajanın kurulum planı"nı aşama aşama uygula. Her aşamanın sonunda o aşamanın kontrollerini çalıştır, sonucu docs/STATUS.md'ye ve CHANGELOG.md'ye yaz, bana tek satır rapor ver. Kontrolü geçmeyen aşamadan sonrakine geçme.
6. Yalnız benim yapabileceğim işlerde dur ve sor: hesap açmak, ödeme ve ücretli plan, şart ve sözleşme kabulü, alan adı kaydı ve sahiplik doğrulaması, mağaza hesapları, bir uygulamaya hesap erişimi vermek (GitHub App, OAuth onayı), dış sitelerde form göndermek, yalnız konsoldan açılabilen ayarlar, canlıya deploy, mobil build ve mağazaya gönderim, gerçek kullanıcılara mesaj, bir şeyi herkese açık yapmak.
7. İsteğim rehberle çelişirse işe başlamadan çelişkiyi söyle. Kararı ben veririm, sen DECISIONS.md'ye yazarsın.
8. Etiketler kanıt düzeyidir: [kanıtlı] rehberin ürünlerinde canlıda çalışıyor, [ölçüldü] rakamı ölçüm ya da fatura gösteriyor, [öneri] o ürünlerde denenmedi ya da yalnız sağlayıcı belgesine dayanıyor. [öneri] isteğe bağlı demek değildir; bir maddeyi atlamak da benim kararımdır.
9. Gizli değerleri sohbete, dosyaya, commit'e ya da loga yazma; adları .env.example'da, değerleri Secret Manager'da durur. Denemeler test ortamında yapılır, canlıya test verisi yazılmaz.
10. Fiyat, kota ya da sürüme dayanan her adımdan önce rakamı rehberin Kaynaklar bölümündeki sayfadan yeniden oku; tutmayanı bana söyle.
```

[öneri]
Metin bütün olarak bizde denenmedi. Maddeleri depolarımızın ajan dosyalarındaki deploy ve yasak kurallarından, [Proje hafızası](#hafiza) bölümünün gün 0 dosyalarından ve [Verilecek kararlar](#kararlar) bölümünden geliyor.

## Kim ne yapar

Sağdaki sütun ajanın durup sorduğu yerdir. Soldaki etiket o satırdaki iş bölümünün kanıt düzeyidir; hücrenin başındaki etiket yalnız o hücre içindir.

| Alan | Ajan tek başına | Birlikte | Yalnız ürün sahibi |
|---|---|---|---|
| Kararlar [öneri] | Soruları sırayla sorar, tercih yoksa rehberin varsayılanını önerir, cevabı DECISIONS.md'ye yazar. | Varsayılandan sapan seçim ve atlanan her öneri; nedeni de yazılır. | Son sözü verir. Ajan karar vermez, kararı kaydeder. |
| Hesaplar ve para [kanıtlı] | Ücretli bir şey kurmadan önce birim fiyatı, günlük ve aylık tahmini yazar ve onay bekler. | [öneri] Bütçe eşikleri ve ücretli API tavanı; ajan uyarıyı ve tavanı kurar. Bizde yoktu, bir harita API'si Ağustos'ta ₺1.500 yazdı. | Bulut, veritabanı, DNS, e-posta ve mağaza hesaplarını açar; ödeme yöntemini girer, şartları kabul eder; ajanın erişimini verir. |
| Alan adı ve DNS [kanıtlı] | Kayıtları Cloudflare'de kurar: alt alan adları, servis bağlantıları, e-posta için SPF, DKIM ve DMARC. | Alan adının seçimi, alım zamanı ve güvenlik firmalarına kategori başvurusu. Alım ilk kullanıcıdan haftalar önce olur; bizde geç kaldı (vaka 27). | Alan adını kayıt firmasından alır ve sahipliğini doğrular. |
| Altyapı [kanıtlı] | Depoları ve dalları, Neon projelerini, Cloud Run servislerini, tetikleyicileri, bot kapısını, alarmları, yedeği ve mobil kiti kurar; hepsini önce test ortamında. | Alarmların kime ve hangi kanaldan gideceği. | Deneme alarmının kendisine ulaştığını söyler. |
| Deploy ve sürüm [kanıtlı] | Dalda çalışır, test'e push eder, test ortamında doğrular, tek satırlık rapor verir. | Yayının zamanı: hafta içi mesai başı. Mobilde aşamalı yayın da konuşulur; bizde denenmedi. | Canlıya deploy onayı; mobil build, mağazaya gönderim ve sürüm numarası. |
| Kullanıcıya ulaşan her şey [kanıtlı] | Duyuru, e-posta, push ve sosyal paylaşım metnini taslak yazar; e-postayı test ortamının izin listesine gönderir. | Metin, kitle ve gönderim zamanı. | Gerçek kullanıcılara gönderim ve herkese açmak: site, mağaza sayfası, paylaşım. |
| Ürün akışları [kanıtlı] | Akışı koda çevirir, testini yazar, test ortamına çıkarır. | Akış test ortamında birlikte denenir. | Akışları tanımlar: kim gelir, ne yapar, ne görür. |
| Kayıt ve devir [ölçüldü] | CHANGELOG girdisini işi yapan commit'e koyar; kural ajan dosyasında yazılıyken commit'lerin %72–84'ü böyleydi, yazılı değilken %33–52'si. STATUS, TODO ve devir notunu da tutar. | [öneri] Ayda bir tazelik turu: ajan hazırlar, ürün sahibi 15 dakika bakar. | Karar bekleyen satırları kapatır. |

## Bu rehber ne değildir

### Çok yüksek ölçek ve çok bölge için

Servislerimiz tek bölgede (europe-west1), veritabanlarımız Frankfurt'ta; yedek maliyetini ölçtüğümüz prod veritabanı 70 MB. Servisler boşta sıfıra iner. Soğuk sunucuya düşen ilk istek API'de p50 ~1,5 sn, sitede p50 2,0–4,9 sn sürdü; site ile API birlikte soğukken p50 6,2 sn. Uptime kontrolü olan serviste bu, isteklerin %0,02–0,16'sına denk geldi ([Performans](#performans)).

[öneri] **Büyüyünce ne değişir.** Rakamlarımız günde ~3 CU-saat harcayan ve 70 MB'lık bir veritabanından. Ajan 'Her hafta' adımında aşağıdaki sinyallere bakar. Biri görülürse çözümü kendisi uygulamaz; ürün sahibine tek satırla sorar.

1. Neon günde ≥6 CU-saat harcıyor ve sürekli 1 GB'tan fazla RAM istiyor: önce uyanış logundan sebep okunur. Bizde 7/24 uyanıklığın sebebi trafik değildi; zamanlayıcı, havuz tabanı ve botlardı. Sebep gerçek trafikse Neon, sabit fiyatlı bir Postgres ile aylık karşılaştırılır. [Postgres](#katman-1)

2. Compute saatlerce 1 CU tavanında kalıyor: max 2 CU'ya çıkarılır. En kötü fatura (2 CU'da 7/24 ~$150/ay) ve bütçe yeniden yazılır.

3. API max-instances tavanına dayanıyor: max yükseltilmeden önce üç sayı yeniden hesaplanır. Hız kovaları instance başına olduğu için gerçek sınır max ile çarpılır. Sağlayıcıda sert bütçesi olmayan para tavanının en kötü günü de max ile çarpılır. Bütün servislerin ve işlerin instance sayısı toplamı havuzun `MaxConns` değeriyle çarpılır; çıkan sayı compute'un `max_connections` değerinin %90'ını (1 CU'da 377) geçmez. Geçerse sorgu pooler'da sıra bekler, 120 sn sonra hata alır.

4. Değişiklik işaretine saniyede birden sık yazılıyor: GCS aynı nesneye saniyede bir yazmayı kabul eder, daha sıkını kısar. Yazmalar birleştirilir ya da işaret parçalara bölünür.

5. Bellek kopyası API belleğinin yarısını geçiyor: bellek büyütülür ya da kopya sık okunan kayıtlarla sınırlanır.

6. Olay tablosunun 180 günlük silmesi tek çalışmada bitmiyor ya da bu tabloya giden admin sorgusunun p90'ı oturumlu okuma hedefini (300 ms, [Performans](#performans)) geçiyor: tablo aylık bölümlenir, eski ay bölüm düşürülerek silinir.

7. E-posta, Worker ve mobil build kotaları: [Verilecek kararlar](#kararlar) bölümünde 31. sorudaki eşikler.

### Hukuki görüş

[KVKK bölümü](#kvkk) yeni projede yapılacakları anlatır. Maddeler kanun metnine ve Kurum duyurularına dayanır; hukuki görüş değildir. Veri işleyenle yapılan standart sözleşmenin metni, VERBİS sorusu ve silme cevabının ifadesi hukukçuya sorulur.

### Güncel fiyat listesi

Fiyat, kota ve sürümler Ekim 2026'nın. Sağlayıcılar sık değiştirir; X fiyat modelini 2026'da iki kez değiştirdi.

### Başka yığın için birebir

Rakamlar ve ayarlar bu yığına özgü. İlkeler geçer: uyuyabilen veritabanı, sessiz hata yok, en az yetki.

### Hazır kod

Kurallar, sıralar, dosya şablonları ve bazı kod iskeletleri (örneğin bot kapısı) var; başlangıç deposu yok. Kodu ajan bu kurallarla yazar.

[öneri] **Güncel tutmak.** Ajan fiyat, kota ya da sürüme dayanan bir adımdan önce rakamı [Kaynaklar](#kaynaklar) bölümündeki sayfadan yeniden okur; tutmayanı ürün sahibine söyler.

## Dört ürünümüz

Örneklerde geçen ürünler. Satır 8 Ekim 2026 sayımı, test kodu dahil ([Boyutlar](#boyutlar)); aylık tutar 8 Ekim tahmini ve yalnız bulut faturası; alan adı ve mağaza ücretleri hariç ([Ne tutar?](#maliyet)).

### Ürün A

Finans hesaplama ürünü
Mobil uygulama, bilgi sitesi, statik portal, pazar yeri sitesi ve Go API.

**Veritabanında:** Kullanıcılar ve oturumlar, hesaplama olayları, abonelik olayları, pazar yeri talepleri ve mesajları, bildirimler ve cihazlar.

Her gün giriş yapan kullanıcıları ve her sabah çalışan veri çekme, rapor ve yedek işleri var.

**5** depo
**~265.000** satır kod
**~₺610** aylık bulut

### Ürün B

Mağaza keşif uygulaması
Web ve Go API; mobil uygulama deposu erken aşamada.

**Veritabanında:** Mağaza ve marka kataloğu, değerlendirmeler ve moderasyon, arama ve tıklama kayıtları, kullanıcılar ve oturumlar.

Herkese açık ~18 bin sayfalık katalog; tek bir bulut kazıyıcısı web isteklerinin %41'ini aldı.

**3** depo
**~70.000** satır kod
**~₺510** aylık bulut

### Ürün C

İçerik uygulaması
Web, ayrı admin paneli, mobil uygulama ve Go API.

**Veritabanında:** İçerik kayıtları ve çevirileri, kategoriler, kullanıcılar ve roller, yorumlar, günlük bakılma sayaçları, paylaşım kayıtları.

Günlük, haftalık ve aylık içeriğini sosyal hesaplara kendisi paylaşır.

**4** depo
**~151.000** satır kod
**~₺220** aylık bulut

### Ürün D

Küçük içerik sitesi
Web ve Go API.

**Veritabanında:** İçerikler, yorumlar ve içerik bildirimleri; IP adresi ham tutulmaz, yalnız hash'i durur.

Gerçek kullanıcısı az; veritabanı Neon Free'de, admin paneli yok.

**2** depo
**~12.500** satır kod
**~₺5** aylık bulut
Ürün C'nin kodu Ürün B'nin iki katından fazla, aylık tutarı yarısından az (~₺220 ve ~₺510). Fark veritabanının uyanık kaldığı saatlerden, Ürün B'deki bot trafiğinden ve build dakikalarından geliyor.

<a id="kararlar"></a>

Başlarken

# Verilecek kararlar ve kurulum planı

Bu bölüm ajanın gün 0'dan başlayan iş listesidir: ürün sahibine sorulacak kararlar, kod yazılmadan biten hesap ve sürüm listesi ve altyapının kuruluş sırası. Ekip bu sırada yalnız ürün akışlarına bakar.

**Kural:** Ajan tek başına karar vermez; sorar, kaydeder, sırayla kurar ve DUR yazan yerde bekler.

Kararlar dört zamana ayrılır; ajan yalnız o anın satırlarını sorar. Ürün sahibinin tercihi yoksa rehberin varsayılanını nedeniyle önerir; kabul edilen varsayılan da bir karardır ve docs/DECISIONS.md'ye yazılır. Cevabı gelmeyen karar AGENTS.md'de 'KARAR BEKLİYOR' diye kalır ve ona bağlı adım başlamaz. Kurulum planının her adımı bir çıktı ve bir doğrulama taşır; doğrulaması geçmeyen adım bitmiş sayılmaz.

## Dört aşama

Kararlar ve kurulum adımları aynı dört zamana ayrılır. DUR, ürün sahibinin sözünün beklendiği adımdır; ajan orada tek satırlık rapor verir.

### Gün 0: kod yazılmadan

Akışların kodu bu aşama bitince başlar.

**17** karar
**15** adım
**11** DUR

### İlk kullanıcıdan önce

İlk gerçek kullanıcı bu aşama bitince gelir.

**8** karar
**8** adım
**4** DUR

### İlk mağaza sürümünden önce

Yalnız mobil varsa.

**4** karar
**5** adım
**3** DUR

### Sonra

Sürekli; ajan takvimden yürütür.

**3** karar
**5** adım
**2** DUR

## Kararlar

Satırlar sorulacakları zamana göre gruplu. Gri yazı seçenekleri ve nedeni verir, bağlantı kuralın durduğu bölüme gider; etiket varsayılanın kanıt düzeyidir, ayraç içindeki 'öneri' o cümlenin bizde denenmediğini söyler. Varsayılan rehberin teklifidir; karar ürün sahibinindir. Ajanın ilk mesajı [Bu rehber nasıl kullanılır](#kullanim) bölümünde.

| No | Karar ve seçenekler | Rehberin varsayılanı, nedeni ve bölümü | Kim, kanıt |
|---|---|---|---|
| Gün 0: kod yazılmadan, 17 karar |
| 1 | **Ürünün adı, alan adı ve uygulama kimlikleri ne?** Tek alan adı ve alt alan adları ya da yüzey başına ayrı alan adı. Mobil varsa iOS bundle ID, Android paket adı ve uygulama şeması. | Tek alan adı, ilk kullanıcıdan haftalar önce: web, api., auth. ve news. Kategori başvurusu aynı hafta. Mobilde bundle ID ve paket adı alan adının tersidir (ornek.com ise com.ornek.app) ve iki platformda aynıdır; şema kısa ve tektir; universal link ve App Links ana alan adında, ilk build'de, [Mobil kit](#mobilkit) yayın kapısı 14 (öneri). 38 günlük alan adının giriş kodları dört kurumun posta geçidinde bekledi. Bundle ID ve paket adı mağazaya ilk yüklemeden sonra değişmez; ajan bunları uydurmaz, sorar. [Kenar ve DNS](#katman-5) | Ürün sahibi [kanıtlı] |
| 2 | **Hesaplar kimin adına açılır, kimler yönetir?** Şirket ya da kişi; bir ya da iki yönetici. | Şirket adına, ürünün alan adındaki bir adresle; en az iki yönetici, kök hesaplarda donanım anahtarı ya da passkey. Claude, Google, Cloudflare ve PostHog'un kredi programları kişisel adresi kabul etmiyor. [Krediler](#krediler) | Ürün sahibi [öneri] |
| 3 | **Ürüne ayrı faturalama hesabı ve Neon org'u açılacak mı?** Ayrı hesap ya da var olan hesabı paylaşmak. | Ayrı, aynı ödeme profilinin altında. Ücretsiz kotayı artırmak için tek ürün birden çok hesaba bölünmez. Aynı hesaptaki iki ürün Eylül'de ₺187 build ve ₺78 Cloud Run ücreti ödedi. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi [ölçüldü] |
| 4 | **Veri nerede durur?** AB ya da Türkiye; Neon'un Türkiye bölgesi yok. | AB: Neon Frankfurt, servisler europe-west1. KVKK m.9 sözleşmesi ve 5 iş günü içinde bildirim. Türkiye'ye geçiş ancak kurumsal müşteri isterse. Türkiye'de Neon yok; veritabanı orada uyuma kazancını kaybeder. [KVKK](#kvkk) | Ürün sahibi [öneri] |
| 5 | **Prod ve test için Neon planı hangisi?** Free, Launch ya da Scale; test için Free ya da prod'dan dal. | Prod Launch: aylık asgari ücret yok, az trafikte ayda ~₺50–80. Test ve yan projeler ayrı Free org'da. Launch'tan Free'ye inmek döküm, yükleme ve adres değişikliği demek. [Postgres](#katman-1) | Ürün sahibi ve ajan [ölçüldü] |
| 6 | **Platformlar: yalnız web mi, iOS ve Android de mi?** Web; web ve mobil; yalnız mobil. | Akış belirler. Mobil varsa uzaktan kontrol kitinin iskeleti ilk commit'te, tamamı ilk mağaza sürümünden önce; mağaza kararları plana girer. Sonradan eklenen kanal mağazadaki eski build'lere ulaşmaz; bizde 3 Android build'i güncelleme uyarısını hiç gösteremeyecek. [Mobil kit](#mobilkit) | Ürün sahibi [kanıtlı] |
| 7 | **Dal modeli ne, canlıya deploy kararı kimde?** test ve main ya da yalnız main; onay kapısı ya da doğrudan. | test ve main; main yalnız test'te görülmüş commit'e ilerler. Deploy, build ve sürüm numarası ürün sahibinin; AGENTS.md'nin en üstünde. Kural ajanın hafızasındaydı; 20 Eylül'de istenmeden iki prod build başladı. [Kırmadan değiştirmek](#kirmama) | Ürün sahibi [kanıtlı] |
| 8 | **Ajan neyi onaysız yapar, ücretli işte eşik ne?** Commit, test'e push, migration, deploy, mağaza; her ücretli çağrı ya da bir eşiğin üstü. | Dalda commit ve test'e çıkış onaysız; main, prod migration, build, gönderim ve herkese açma onaylı. Günde 1 dolar üstü ücretli iş sorulur. GCP için ayda 1 dolar tahmin edilmişti; Ağustos'ta faturalama hesabının toplamı ₺2.087 geldi. [Proje hafızası](#hafiza) | Ürün sahibi [öneri] |
| 9 | **Gizli bilgiler nerede durur, kim erişir?** Secret Manager, .env dosyası ya da CI değişkeni. | Secret Manager; her servis kendi hesabıyla yalnız kendi sırrına, adlar .env.example'da. JSON anahtar yok, CI için WIF (öneri). Editor yetkili hazır hesap bir açıkla birleşince proje ele geçirilebilir oldu; aynı gün kapatıldı. [Güvenlik](#katman-8) | Ürün sahibi ve ajan [kanıtlı] |
| 10 | **Test ortamı olacak mı, verisi nereden gelir?** Ayrı ortam ya da yalnız yerel; canlının kopyası ya da temsili veri. | Prod'un şeklinde: '-test' servisleri, ayrı Neon, hesap ve sırlar, temsili veri. Canlı veri teste inmez, test canlıya yazmaz. Bir test canlıya 44 sahte hesaplama yazdı; herkese açık listede göründü. [CI/CD](#katman-7) | Ürün sahibi [kanıtlı] |
| 11 | **Bütçe eşikleri ne, en fazla kaç sunucu açılır?** Aylık bütçe tutarı; servis başına max instances; prod'a harcama tavanı ya da yok. | Bütçe %50, %80 ve %100'de, küçük üründe ~₺150; kredileri hariç ikinci bütçe. API max 2–3, web max 3, ikisi de min 0. Prod'a harcama tavanı ürün sahibinin kararıdır; konursa kredi düşülmeden önceki brüt maliyetin ~10 katında ve en az ~$100 olur, kaldırma adımı cost-check.md'de yazılıdır. Bütçe uyarısı harcamayı durdurmaz. Max sınırı yalnız Cloud Run'ın CPU ve bellek faturasını sınırlar; internet çıkışına, loga, build'e ve dış API'ye çıkış alarmı ve API kotası bakar. Tavan dolunca o projede Cloud Run ay sonuna kadar yeni istek almaz; tavan elle kaldırılır, toparlanma bir saati bulabilir ([Gün 0 önlemleri 7](#onlem-7)). Max ve min değerleri bizde canlıda. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi ve ajan [öneri] |
| 12 | **Belgelerin dili, iş panosu ve sahip oturum ne?** Türkçe ya da İngilizce; depoda TODO ya da dış pano. | İçerik Türkçe, dosya adları geleneksel. Depo başına bir sahip oturum, adı STATUS'ta. İş panosu docs/TODO.md (öneri). Aynı depoda iki oturum main'e aldı, push reddedildi. [Proje hafızası](#hafiza) | Ürün sahibi [kanıtlı] |
| 13 | **Mobil build EAS'te mi, kendi hattımızda mı?** EAS Free, EAS Starter, yerel build ya da kendi hat. | EAS Free ve ilk günden prova edilmiş yerel yol; kendi hat ancak EAS faturası üç ay üst üste $50'ı geçerse. Preview'lar yerelde alınınca platform başına ayda 15 hak yetiyor. [Mobil dağıtım](#dagitim) | Ürün sahibi ve ajan [ölçüldü] |
| 14 | **Tasarımın tek kaynağı ne, koyu tema olacak mı?** Token dosyası ya da elle kopya; iki mod ya da yalnız açık tema. | tokens/tokens.json'dan CSS ve mobil tema üretilir. Koyu tema ya iki modla tasarlanır ya 'yalnız açık' kilitlenir; DESIGN.md gün 0'da. Ürün A'nın ana marka rengi 5 depoda 17 dosyada sabit yazılı. [Tasarım sistemi](#tasarim) | Ürün sahibi [öneri] |
| 15 | **E-posta sağlayıcısı ve gönderim alt alan adı ne?** Resend, SES ya da başka; tek ya da ayrı alt alan adları. | Resend AB bölgesinde; kodlar auth., bülten news. alt alan adından. SPF, DKIM ve DMARC ilk gönderimden önce; yedek sağlayıcı (varsayılan Amazon SES, eu-west-1) aynı auth. alt alan adında kurulu ve denenmiş. Bölgeyi sonradan değiştirmek destek ister ve DKIM değişebilir. [E-posta](#katman-9) | Ürün sahibi ve ajan [öneri] |
| 16 | **Hangi ücretli dış API'ler kullanılır, tavanları ne?** Harita, model, SMS; çağrı başına ya da tek seferlik içe aktarma. | Birim fiyat, en kötü gün, iki alternatif ve çıkış yolu yazılmadan açılmaz; sağlayıcıda sert günlük kota, ürüne özel kısıtlı anahtar. Bir harita API'si Ağustos'ta ₺1.500 yazdı, projenin Google faturasının ~%72'si. [Pahalı API'ler](#pahali-api) | Ürün sahibi [ölçüldü] |
| 17 | **AI eğitim tarayıcılarına ve cevap motorlarına tutum ne?** Eğitim: aç, sınırla ya da engelle. Cevap motorları: aç ya da kapat. | Arama ve cevap motorları açık. Eğitim botları GEO hedefi yoksa kapalı: robots.txt'de Disallow, Cloudflare'de 'Disallow AI Training'. GEO için açılan eğitim botuna saniyede 1 sayfa, kova önce gölgede; CCBot ve Bytespider varsayılan olarak engelli. 'Block' Googlebot ve Bingbot'u da keser; yeni alan adının hazır ayarı gün 0'da okunur. [Botlar](#botlar) | Ürün sahibi [öneri] |
| İlk kullanıcıdan önce, 8 karar |
| 18 | **Analitik hangi soruları cevaplar, hangi araçla?** Kendi olay tablomuz, PostHog Cloud EU, GA4 ya da Clarity. | Önce ürün sahibinin beş sorusu. Kendi tablomuz, tek olay ucu, ilk build'de on zorunlu olay; üçüncü taraf KVKK adımından sonra, önce web'de. Sonradan eklenen olayın geçmişi yok; Ürün A'da paylaşım sayımı ve PDF sonucu ayrı birer mağaza sürümünü bekledi. [Analitik ve admin](#analitik) | Ürün sahibi [öneri] |
| 19 | **Hatalar nereden görülür?** Kendi notify() ve Error Reporting, Sentry ya da Crashlytics. | Birinci taraf: notify(), /v1/client-errors, Error Reporting ve error_shown olayı. Sentry EU ancak KVKK adımından sonra (Developer $0, Team $26/ay). Her üçüncü taraf SDK işleyen listesine ve mağaza beyanına girer. [Uyarılar](#uyarilar) | Ürün sahibi ve ajan [öneri] |
| 20 | **Uyarılar kime, hangi kanaldan gider?** E-posta, telefona push ya da sohbet kanalı; bir ya da iki kişi. | En az iki kişi. Acil olan iki telefona ve e-postaya, gece de; bugün olan e-postaya ve admin'deki kutuya; gerisi pazartesi özetinde. X kredisi bitince durum günlük inceleme e-postasında bir satırdı; 30 gün fark edilmedi. [Uyarılar](#uyarilar) | Ürün sahibi [öneri] |
| 21 | **Akış gerçek zamanlı bir şey istiyor mu?** Push ve yenileme, açık ekranda yoklama, SSE ya da WebSocket. | Push ve açılışta yenileme; yetmezse yalnız ekran açıkken kısa yoklama (bizde 8 sn); WebSocket en son, canlı ortak çalışma için. 7/24 açık bir WebSocket servisi ayda ~₺2.445; yoklamanın ek bedeli ≈ ₺0. [Gerçek zamanlı](#mesajlasma) | Ürün sahibi ve ajan [kanıtlı] |
| 22 | **Hangi sayfalar aranır, hangileri dışarıda kalır?** Bilgi, katalog ve veri sayfaları; portal, panel, paylaşım linkleri. | Herkese açık sayfa sunucuda tam HTML, bellekten ya da ISR'dan; veritabanına gitmez. Portal, panel, paylaşım linkleri ve test kopyası noindex. Ürün C'nin yeni kategori sayfaları veritabanını günde ~74 kez uyandırdı. [SEO ve GEO](#seo) | Ürün sahibi ve ajan [kanıtlı] |
| 23 | **Admin'e kim girer, oturum ne kadar sürer?** Roller, boşta kalma süresi, oturum tavanı. | E-posta izin listesi; boşta 30 dk, 12 saat tavan. Üç rol (sahip, operatör, salt okuyucu) ve tehlikeli eylemde yeniden kod (öneri). 8 saatlik boşta süre denendi, güvenlik için geri alındı. [Analitik ve admin](#analitik) | Ürün sahibi [kanıtlı] |
| 24 | **Yedekler ne kadar saklanır?** Neon geçmişi, snapshot, günlük döküm ve proje dışı kopya. | Geçmiş 7 gün, snapshot 14 gün, döküm 30 gün ve 7 gün soft delete; gizlilik metni 37 gün yazar. Haftalık proje dışı kopya (öneri) hedefte de 37 günü geçmez: GCS'te lifecycle 28 ve soft delete 7 gün, çünkü döküm kopyalanırken bir iki günlük olabilir. Hedefte daha uzun tutulursa gizlilik metni o süreyi yazar. Launch'ta geçmişin varsayılanı 1 gün; 7'ye elle çıkarılır. [Yedek](#yedek) | Ürün sahibi [ölçüldü] |
| 25 | **Hangi startup kredilerine, ne zaman başvurulur?** Neon, Google, Claude, Sentry, PostHog; şimdi ya da sonra. | Ayrı hesap ve Neon org'u açıldıktan sonra, ağır kullanımdan hemen önce; önce en büyük kalem olan Neon. Süre çoğu programda onay ya da claim günü başlar; erken alınan kredi yanar. [Krediler](#krediler) | Ürün sahibi [öneri] |
| İlk mağaza sürümünden önce, 4 karar |
| 26 | **Mağaza hesapları kimin; build, sürüm ve gönderim kimde?** Kişi ya da şirket hesabı; ajan ya da ürün sahibi. | Build, sürüm numarası, gönderim ve OTA yayını yalnız ürün sahibinin açık sözüyle. Apple, Play ve Expo şirket adına, iki yönetici (öneri). Ajan sürümü sormadan yama yerine ara sürüm numarasını artırdı. [Mobil dağıtım](#dagitim) | Ürün sahibi [kanıtlı] |
| 27 | **Zorunlu güncelleme ve yayın nasıl açılır?** Zorlama: hiç, her sürümde, kırıcı değişiklikte. Yayın: herkese ya da aşamalı. | Zorlama kapalı başlar; ancak Play'de yayın %100 ve App Store'da sürüm yayındayken açılır. App Store'da aşamalı yayın (7 gün), Play'de kademeli; API ile aynı gün açılması gereken sürüm elle yayınla gönderilir, mesai başında açılır. Sonradan eklenen zorlama eski build'lere ulaşmaz (bizde kanıtlı); kademeli yayın bizde denenmedi. [Mobil kit](#mobilkit) | Ürün sahibi [öneri] |
| 28 | **OTA güncelleme kurulacak mı?** expo-updates ya da yok; EAS Update ya da kendi sunucu. | Önerilir, zorunlu değil: ilk mağaza build'inden expo-updates, fingerprint ve kanal; EAS Update Free 1.000 MAU. Her OTA yayını ürün sahibinin kararı. 19 Eylül–7 Ekim'deki 19 mağaza build'inin 11'i yalnız JS idi. [Mobil kit](#mobilkit) | Ürün sahibi [öneri] |
| 29 | **Uygulama içi satın alma olacak mı, durum nereden okunur?** Yok, RevenueCat ya da doğrudan mağaza. | RevenueCat; durum üç yoldan: SDK, 10 dk TTL'li sunucu mutabakatı ve webhook. Webhook ucunda tek 5xx alarmı (öneri). Webhook en az 21 gün 500 döndü; öteki iki yol çalıştığı için kullanıcı etkilenmedi. [Expo mobil](#katman-4) | Ürün sahibi [kanıtlı] |
| Sonra, 3 karar |
| 30 | **İçerik otomasyonu kurulacak mı, hangi platformlarda?** X, Instagram, Facebook Sayfası, Threads, LinkedIn; otomatik ya da onaylı. | Hat kurulmadan otomatik paylaşım yok: şirkete ait hesaplar, insan onayı, X harcama tavanı, platform başına kapatma anahtarı. LinkedIn elle kalabilir. X kredisi bitti; her gün denenen paylaşım 30 gün 402 aldı. [İçerik otomasyonu](#icerik) | Ürün sahibi [öneri] |
| 31 | **Ücretli plana ne zaman geçilir?** EAS Starter, Resend Pro, Workers Paid ya da Neon'da büyük plan. | Eşikler yazılı: EAS Starter yalnız 15 hakkı aşacak ayda; Resend Pro ya da SES haftalık abone ~60'ı geçince; Workers Paid günde ~80.000 istekten önce. Kota bitince build ayın 1'ini bekler; bir iOS sürümü bir hafta kaydı. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi ve ajan [ölçüldü] |
| 32 | **Kod açık kaynak olacak mı, hangi lisansla?** Özel depo ya da açık kaynak: MIT, Apache-2.0, AGPL. | Depo özel. Açılacaksa ayrı ve temiz depo, LICENSE, geçmişte sır ve ad taraması; önce özel itilip dosya listesine bakılır. Silinen dosya geçmişte kalır; çıkarmak ancak geçmişi yeniden yazmakla olur. [Depo kuralları](#depo-kurallari) | Ürün sahibi [öneri] |

## Gün 0: hesaplar ve sürümler

İki liste de kod yazılmadan biter. Hesapları ürün sahibi açar, ajan listeyi tutar; sürüm tabanını ajan kurar ve STATUS'a yazar.

### Hesaplar

Her kutuyu ürün sahibi kendi ekranında işaretler; ajan yalnız envanteri tutar.

- [ ] **Şirket adına.** Her hesap şirket adına ve ürünün alan adındaki bir rol adresiyle; kişisel adresler yalnız yönetici. Mobil varsa Apple ve Play kuruluş hesabı D-U-N-S numarası ister. Başvuru gün 0'da yapılır, çünkü numara ve mağaza doğrulaması günler sürebilir. [öneri]

- [ ] **En az iki yönetici.** Bulut, Neon, DNS, alan adı, GitHub, mağazalar, e-posta ve sosyal hesaplarda. [öneri]

- [ ] **Donanım anahtarı ya da passkey.** Kök hesaplarda (Google, kayıt firması, GitHub, Apple, e-posta kutusu), yedek anahtarla. [öneri]

- [ ] **SMS ile kurtarma kapalı.** Mümkün olan her yerde; kurtarma anahtar ya da kodla. [öneri]

- [ ] **Kurtarma kodları iki yerde.** Çevrimdışı, ayrı iki yerde; depoya, sohbete ve e-postaya yazılmaz. [öneri]

- [ ] **Alan adı kilitli.** Transfer kilidi, çok yıllık ve otomatik yenileme, kayıt firmasında iki adımlı doğrulama. [öneri]

- [ ] **Tek sayfa envanter.** Sağlayıcı, sahip, yöneticiler, faturalama, yenileme tarihi; tarihler yenileme tablosunda. [öneri]

- [ ] **Kartlar ve üyelikler takvimde.** 30 ve 7 gün önce hatırlatma; Apple üyeliği düşerse uygulama satıştan kalkar. [öneri]

- [ ] **Ajan hesap açmaz.** Hesap, ödeme ve şart kabulü ürün sahibinin işi; ajan parola ve kurtarma kodu görmez. [öneri]

Tek sayfa envanter; sağlayıcı listesi kararlara göre uzar. Yenileme tarihleri [Uyarılar](#uyarilar) bölümündeki yenileme tablosuna girer.

```
# docs/ACCOUNTS.md: parola, kurtarma kodu ve anahtar buraya yazılmaz
Sağlayıcı        | sahip        | yönetici | faturalama          | yenileme
Google Cloud     | şirket       | 2        | ürünün hesabı       | kart <AA/YY>
Neon             | şirket org'u | 2        | ürünün org'u        | kart <AA/YY>
Alan adı         | şirket       | 2        | çok yıllık, kilitli | <YYYY-AA-GG>
Cloudflare       | şirket       | 2        | Free                | yok
E-posta (Resend) | şirket       | 2        | Free                | yok
GitHub           | şirket org'u | 2        | Free                | yok
Apple Developer  | şirket       | 2        | yıllık üyelik       | <YYYY-AA-GG>
Google Play      | şirket       | 2        | tek seferlik kayıt  | yok
```

### Sürüm tabanı

8 Ekim 2026'da resmi sürüm ve destek sayfalarından okundu. Ajan her yeni projede aynı sayfaları yeniden okur; liste bu başlığın sonunda, tablo o günün fotoğrafıdır.

| Bileşen | En yeni kararlı, 8 Eki 2026 | Destek | Yeni projede |
|---|---|---|---|
| Go | 1.27.1, 1 Eyl 2026 | 1.27: 1.29 çıkınca biter. 1.26: 1.28 çıkınca. | 1.27; go.mod'da go ve toolchain satırı sabit. |
| Node.js | 24.21.0 LTS (7 Eyl 2026). Node 26 LTS'e 28 Eki'de geçer. | 24: 30 Nis 2028. 26: 30 Nis 2029. | 24 LTS, node:24-alpine sabit; 28 Ekim'den sonra açılan proje 26. |
| Next.js | 16.4.0, 6 Eki 2026 | 16: 21 Eki 2027. 15: 21 Eki 2026 (ikisi de politikadan). | 16, output standalone. |
| React | 19.3.0, 9 Eyl 2026 | Tarih yayımlanmıyor. | Web'de Next'in istediği; mobilde Expo'nun 19.2.3'ü. |
| Expo SDK | 57 (57.0.27, 6 Eki 2026), React Native 0.86 | Tarih yok; yılda üç SDK, 58 önizlemede. | 57, CNG, New Arch; Xcode 26.4, iOS 16.4, Android 7 ve üstü. |
| TypeScript | 7.0.2 (7.0 çıkışı 8 Tem 2026) | Tarih yok; 6.0 JavaScript tabanlı son sürüm. | 6.0 (6.0.3) web'de ve mobilde; 7.0'a typescript-eslint 7'yi destekleyince geçilir, güncelleme gününde bakılır. |
| PostgreSQL | 18.6; Neon 14–18'i destekler | 18: 14 Kas 2030. 14: 12 Kas 2026. | 18; test, döküm imajı ve yerel aynı ana sürümde. |
| pgx | v5.11.0, 7 Eyl 2026 | Go'nun son iki sürümü, Postgres'in son 5 yılı. | v5, varsayılan bağlantı modu. |

### Sürüm kuralları

1. Her bileşen en yeni kararlı sürümle başlar; Node.js'te kararlı sürüm LTS'tir. Desteğine 6 aydan az kalan sürümle başlanmaz.

8 Ekim 2026'da Next.js 15'in desteğinin bitmesine 13 gün, PostgreSQL 14'ünkine 35 gün kalmıştı. İstisna, araç zincirinin henüz desteklemediği sürümdür; bugün TypeScript 7. [öneri]

2. Mobilde React Native, React ve TypeScript Expo SDK'nın getirdiği sürümde kalır; SDK birlikte yükseltilir.

Expo her SDK'yı tek bir React Native sürümüne göre çıkarır; SDK 57, 0.86 ve React 19.2.3 ister. [öneri]

3. Renovate ya da Dependabot gün 0'da açılır; sürüm tabanı tek yerde, docs/STATUS.md'nin Sürümler bölümünde durur.

PR'lar haftalık gruplanır, ayda bir güncelleme gününde test dalında birlikte alınır; güvenlik yaması beklemez. [öneri]

4. STATUS'ta her bileşenin destek bitişi yazılır ve güncelleme gününde resmi sayfayla karşılaştırılır.

STATUS ajanın ilk 5 dakikada okuduğu dosyadır. [öneri]

### Desteğin bitmesine kalan süre

6 aydan fazla6 aydan az: yeni projede kullanılmaz
_Grafik: Desteğin bitmesine kalan süre, 8 Ekim 2026: PostgreSQL 18 ~49 ay (14 Kas 2030); Node.js 26 (LTS 28 Eki'de) ~31 ay (30 Nis 2029); Node.js 24 LTS ~19 ay (30 Nis 2028); Next.js 16 ~12 ay (21 Eki 2027); Node.js 22 ~7 ay (30 Nis 2027); PostgreSQL 14 35 gün (12 Kas 2026); Next.js 15 13 gün (21 Eki 2026)_
Yalnız tarihi yayımlanmış ana sürümler; Go, React, Expo SDK, TypeScript ve pgx tarih yayımlamıyor. Next.js tarihleri destek politikasından hesaplandı (ilk çıkış ve iki yıl).

STATUS'taki sürüm satırları; tarihi olmayan bileşen için neye bakılacağı yazılır.

```
## Sürümler. Son kontrol: 2026-10-08. Güncelleme günü: ayda bir, <gün>.
Desteğine 6 aydan az kalan satır TODO'ya P1 girer.
- Go 1.27.1: 1.29 çıkınca biter.
- Node.js 24.21.0 LTS: 2028-04-30 (Node 26, 2026-10-28'de LTS olur).
- Next.js 16.4.0: 2027-10-21. PostgreSQL 18 (Neon): 2030-11-14. pgx v5.11.0.
- Expo SDK 57 (React Native 0.86, React 19.2.3): tarih yok; yeni SDK'da bak.
- React 19.3.0 yalnız web'de: tarih yok; yeni sürümde bak. Mobilde React'i Expo belirler.
- TypeScript 6.0.3: tarih yok (7.0.2 çıktı; typescript-eslint henüz <6.1).
```

### Okunan sayfalar

Sürümler ve destek tarihleri 8 Ekim 2026'da bu sayfalardan okundu.

**Go sürümleri**https://go.dev/dl/?mode=json
**Go sürüm geçmişi ve destek kuralı**https://go.dev/doc/devel/release
**Node.js sürümleri**https://nodejs.org/dist/index.json
**Node.js sürüm takvimi**https://raw.githubusercontent.com/nodejs/Release/main/schedule.json
**Next.js destek politikası**https://nextjs.org/support-policy
**React sürümleri**https://react.dev/versions
**Expo SDK sürümleri ve istekleri**https://docs.expo.dev/versions/latest/
**TypeScript güncel sürüm**https://www.typescriptlang.org/download
**TypeScript sürüm duyuruları**https://devblogs.microsoft.com/typescript/
**Neon'un desteklediği Postgres sürümleri**https://neon.com/docs/postgresql/postgres-version-policy
**PostgreSQL sürüm politikası**https://www.postgresql.org/support/versioning/
**pgx: desteklenen Go ve Postgres sürümleri**https://github.com/jackc/pgx
**pgx sürümü**https://proxy.golang.org/github.com/jackc/pgx/v5/@latest
**npm sürüm kayıtları: next, expo, typescript, typescript-eslint**https://registry.npmjs.org/

## Ajanın kurulum planı

[En hızlı kurulum yolu](#hizli) sırayı tek satırla verir; bu plan her adımın ne ürettiğini, nasıl doğrulandığını ve nerede durulduğunu yazar. Aşama adları [Kontrol listesi](#kontrol) ile aynıdır; sağdaki bağlantı adımın kurallarına gider.

**Prod'a dokunan komut:** Projede bir şey kuran ya da yetki veren her komut (IAM, servis hesabı, servis, tetikleyici, bütçe, alarm, sır değeri) ve prod Neon rolleri ajanın yazdığı betikte toplanır. Ürün sahibi betiği okur, kendi kimliğiyle çalıştırır ve çıktıyı ajana verir. Ajanın kendi kimliği projede yalnız okur, IAM komutları onda engellidir ([Gün 0 önlemleri](#onlemler) 5 ve 6). Test ve prod aynı projede durduğu için proje düzeyinde verilen yazma rolü ikisini birden açar. Ajan test ortamına test dalına push ederek çıkar. [öneri]

### Gün 0: kod yazılmadan

Akışların kodu bu aşama bitince başlar.

### 1. Kararları sor ve kaydet

[Proje hafızası](#hafiza)
**Üretir:** docs/DECISIONS.md, K-001'den. Cevapsız satır AGENTS.md'de 'KARAR BEKLİYOR' ve TODO'nun karar bekleyen bölümünde.

**Doğrular:** Her gün 0 kararının ya K numarası ya TODO satırı var.

**DUR:** Ürün sahibi gün 0 kararlarını verir; cevapsız kararın adımı başlamaz.

### 2. Proje hafızası

[Proje hafızası](#hafiza)
**Üretir:** AGENTS.md (deploy kuralı en üstte), CLAUDE.md'de yalnız @AGENTS.md, CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/runbooks/.gitkeep, docs/handoff/.gitkeep, .gitignore, .env.example (yalnız adlar). Sonraki adımların dosyaları bu adlarla açılır: docs/ACCOUNTS.md (3), docs/ALERTS.md (yenileme tablosu 3'te, uyarı listesi 16'da), sürüm tabanı docs/STATUS.md'nin Sürümler bölümünde (6), docs/KVKK.md (12), PRODUCT.md, DESIGN.md ve tokens/tokens.json (14).

**Doğrular:** `git ls-files` hepsini listeler; Claude Code'un /memory listesinde AGENTS.md var.

### 3. Hesaplar

[Uyarılar](#uyarilar)
**Üretir:** docs/ACCOUNTS.md'de hesap envanteri: sahip, iki yönetici, faturalama, yenileme tarihi; tarihler docs/ALERTS.md'deki yenileme tablosunda.

**Doğrular:** Envanterde boş hücre yok; kök hesaplarda anahtar ürün sahibiyle ekranda görüldü.

**DUR:** Hesabı ürün sahibi açar, şartı o kabul eder, ödeme yöntemini o girer.

### 4. Faturalama ve bütçe

[Ücretsiz katmanlar](#ucretsiz)
**Üretir:** Ürünün faturalama hesabı ve Neon org'u; %50, %80, %100 bütçe ve Pub/Sub; kredisiz ikinci bütçe; BigQuery fatura dökümü.

**Doğrular:** `gcloud billing budgets list --billing-account=FATURA_HESABI` ürünün faturalama hesabında iki bütçe ve üç eşik gösterir.

**DUR:** Faturalama hesabı ve Neon'un ücretli planı ürün sahibinin kartıyla açılır.

### 5. Alan adı ve DNS

[Kenar ve DNS](#katman-5)
**Üretir:** Cloudflare'de kayıtlar başta gri; web Worker ile run.app'e, api. domain mapping ile; transfer kilidi, çok yıllık yenileme; dört güvenlik firmasına kategori başvurusu.

**Doğrular:** `dig +short NS ALAN` Cloudflare'i, whois clientTransferProhibited'ı gösterir.

**DUR:** Alan adını ürün sahibi kaydeder.

### 6. Depolar ve sürümler

[Depo kuralları](#depo-kurallari)
**Üretir:** Özel depolar, test ve main; gitleaks, push protection, 1 MB ve ikili kapısı; tablodaki sürümler, STATUS'taki taban, Renovate.

**Doğrular:** Sahte anahtarlı ya da 2 MB'lık commit reddedilir; main'e force push ve main'i silme reddedilir, test'ten main'e fast-forward push geçer; desteğine 6 aydan az kalan sürüm yok.

[öneri] GitHub'da main'e PR şartı konmaz. GitHub'ın birleştirmesi yeni commit üretir; main test'le eşit kalmaz ve main tetikleyicisi test'in `$COMMIT_SHA` etiketli imajını bulamaz.

### 7. Neon

[Postgres](#katman-1)
**Üretir:** Prod Launch'ta Frankfurt'ta, Postgres 18; test Free org'da; üç rol, rol zaman aşımları, geçmiş 7 gün; MinConns=0, MaxConnIdleTime=90s.

**Doğrular:** Pooler üzerinden jsonb, bytea ve dizi testi geçer; son istekten ~6,5 dakika sonra (havuz 90 sn + Neon 5 dk) compute uyur, Neon'un saatlik tüketiminde görülür.

**DUR:** Prod Neon'un rolleri, zaman aşımları ve geçmiş süresi betikle, ürün sahibinin kimliğiyle kurulur. Ajanda yalnız test Neon'u ve prod'un salt okunur rolü durur.

### 8. Servisler ve hat

[CI/CD](#katman-7)
**Üretir:** API ve web europe-west1'de min 0, max 2–3 ve 3, CPU boost, Next'e 1 GiB, service.yaml; tek Docker deposu, bölgesel tetikleyici, temizlik kuralı; test digest üretir, main onayla terfi eder. Tetikleyiciler baştan kendi build hesabıyla kurulur. Bu hesap roles/run.admin, roles/artifactregistry.writer ve roles/logging.logWriter taşır. roles/iam.serviceAccountUser proje genelinde verilmez, yalnız deploy ettiği çalışma hesaplarının üstünde verilir. Build dosyasında `options: logging: CLOUD_LOGGING_ONLY` bulunur; kendi hesabıyla koşan build bu satır olmadan başlamaz.

**Doğrular:** Depo tanımında cleanupPolicyDryRun yok ya da false; test push'unun build'i kendi build hesabıyla SUCCESS.

**DUR:** Servisler, tetikleyiciler ve Docker deposu betikle, ürün sahibinin kimliğiyle kurulur.

[öneri] Canlıya çıkış sırası şöyledir. Ajan test'te doğrular ve tek satır rapor verir. Ürün sahibi "deploy" der. Ajan `git push origin test:main` ile main'i ileri sarar. main tetikleyicisi onay bekler. Onayı ürün sahibi verir. roles/cloudbuild.builds.approver rolü yalnız ondadır, ajanın kimliğinde yoktur. Aynı sıra docs/runbooks/deploy.md'de yazılır.

### 9. Yetki ve sırlar

[Güvenlik](#katman-8)
**Üretir:** Compute hesabında Editor varsa, tetikleyiciler kendi build hesabına geçtikten sonra kaldırılır. Servisler rolsüz kendi hesabıyla çalışır; sırlar Secret Manager'da, tek etkin sürüm. WIF yalnız GitHub Actions'ta koşan iş için kurulur, Cloud Build'e gerekmez.

**Doğrular:** `gcloud projects get-iam-policy PROJE --flatten='bindings[].members' --filter='bindings.role=roles/editor' --format='value(bindings.members)'` boş döner. Compute, build ve uygulama hesapları bu listede yoktur. Listede Google'ın kendi hizmet aracısı `PROJE_NO@cloudservices.gserviceaccount.com` çıkarsa ona dokunulmaz. Bazı API'ler kullanılınca Google bu hesabı Editor ile kurar ve rolün kalmasını ister.

**DUR:** Bu adımın bütün komutları betikle, ürün sahibinin kimliğiyle çalışır. Sır değerini Secret Manager'a ürün sahibi yazar, ajan değeri görmez.

[öneri] Mayıs 2024'ten sonra açılan şirket organizasyonunda compute hesabı zaten rolsüz gelir; tetikleyici 8. adımda kendi hesabını almadıysa ilk build yetki hatasıyla düşer.

### 10. Okuma yolu ve kapı

[Mimari](#mimari)
**Üretir:** Herkese açık okumalar API belleğinden, GCS işaretiyle; veritabanısız /health; proxy.ts'in ilk satırında ortak listeli kapı; güvenlik başlıkları, CSP report-only.

**Doğrular:** Herkese açık sayfada 'db wake' satırı yok; /.env 404; veritabanı kapalıyken /health 200.

### 11. E-posta

[E-posta](#katman-9)
**Üretir:** Resend AB, auth. ve news.; SPF, DKIM, DMARC; outbox; günlük ortak sayaç: 70'te uyarı, 80'de toplu gönderim durur, kodlar 100'e kadar; web kod formunda Turnstile; API'de App Check doğrulaması, mobil varsa mobil kod ucu token'sız isteği ilk günden reddeder; yedek sağlayıcı SES aynı auth. alt alan adında.

**Doğrular:** Alan adları sağlayıcıda doğrulanmış; test ortamından izinli adrese kod geldi; test ortamında sayaç 100'e çekilince kod SES'ten gerçek bir gelen kutusuna geldi.

**DUR:** Sağlayıcı hesaplarını (Resend ve SES) ve ücretli planı ürün sahibi açar, SES'in sandbox'tan çıkış başvurusunu o yapar; gönderim anahtarlarını Secret Manager'a da o yazar.

### 12. KVKK

[KVKK](#kvkk)
**Üretir:** Veri yeri, işleyen listesi ve aktarım dayanağı tek belgede; gizlilik metni taslağı.

**Doğrular:** Kodda ve faturada geçen her sağlayıcı listede.

**DUR:** Standart sözleşme, Kurum'a bildirim ve metin ürün sahibinde ve hukukçuda.

### 13. Ücretli dış API (varsa)

[Pahalı API'ler](#pahali-api)
**Üretir:** 'Her ücretli API'den önce' listesinin cevapları; sağlayıcıda günlük kota. Ürüne özel, kısıtlı anahtar 16. adımın uyarıları denendikten sonra açılır.

**Doğrular:** Kota konsolda görünür; günlük maliyet sorgusu SKU kırılımıyla çalışır.

**DUR:** Ürün sahibi günlük, aylık ve en kötü gün rakamını onaylar.

### 14. Tasarım kaynağı

[Tasarım sistemi](#tasarim)
**Üretir:** tokens/tokens.json, ondan üretilen CSS ve mobil tema, DESIGN.md; koyu tema kararı DECISIONS'ta.

**Doğrular:** CI token dışı hex'leri sayar; yeniden üretilen dosyalarda fark yok.

### 15. Mobil iskelet (mobil seçildiyse)

[Mobil kit](#mobilkit)
**Üretir:** Expo SDK 57, CNG, New Arch; app.config'te DECISIONS'taki bundle ID, paket adı ve şema; eas.json'da profil ortamları; kit iskeleti: sürüm başlıkları, update-policy, zorunlu güncelleme ekranı, push kaydı. Yerel yol: `eas build --local`, fastlane, ANDROID_HOME. App Check debug sağlayıcısı yalnız test ve yerel build'de; debug token'ları sırdır, depoya yazılmaz.

**Doğrular:** Yerelde preview profiliyle alınan build'in istekleri test API logunda X-App-Build ile görünür. Token'sız kod isteği test API'de reddedilir.

**DUR:** Bulut build'i ürün sahibinin sözüyle; gün 0'da build yerelde alınır.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'Gün 0' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a yazılır, ürün sahibine tek satır rapor gider. Boş kutu varken akışların koduna geçilmez.

### İlk kullanıcıdan önce

İlk gerçek kullanıcı bu aşama bitince gelir.

### 16. Uyarılar ve alarmlar

[Uyarılar](#uyarilar)
**Üretir:** alerts tablosu, notify(), acil ve bugün log alarmları; uptime 300 sn; 5xx, OOM, ERROR > 0, webhook tek 5xx; denetim işi; pazartesi özeti.

**Doğrular:** Her uyarı türü [TEST] ile uçtan uca denendi; iki alıcı postayı ve telefondaki bildirimi gördüğünü yazdı.

**DUR:** Alıcıların e-posta adresi ve Google hesabı ürün sahibinden gelir. Telefon numarası istenmez.

[öneri] Telefon kanalı Google Cloud mobil uygulamasıdır. İki alıcı uygulamayı kurar, projeye erişimi olan kendi hesabıyla girer ve projeyi seçer. Cihaz birkaç dakikada kanal listesine düşer. Ajan onu acil politikasına ekler ve TEST uyarısıyla dener. SMS kurulmaz, yedek kanal e-postadır. Bu kanal bizde denenmedi.

### 17. Analitik ve admin

[Analitik ve admin](#analitik)
**Üretir:** POST /v1/events, on zorunlu olay; ayrı admin girişi, izin listesi; admin_audit aynı işlemde; bayrak, politika ve duyuru veritabanında.

**Doğrular:** Token'sız admin çağrısı ve denetim satırı testleri yeşil; olay ucu gerçek Postgres'e karşı test edildi.

### 18. Yedek

[Yedek](#yedek)
**Üretir:** Günlük döküm, geçici Postgres'e geri yükleme, boyut karşılaştırması, 'backup ok', iki alarm, haftalık proje dışı kopya, restore-db.md.

**Doğrular:** Bozuk bir çalışmada alarm geldi; bir elle geri yükleme yapıldı, süresi runbook'ta.

### 19. Kırmama sözleşmeleri

[Kırmadan değiştirmek](#kirmama)
**Üretir:** 401 ve 503 sözleşme testi, yalnız ekleyen migration denetimi, varsayılan kapalı anahtarlar, deploy.md ve rollback.md.

**Doğrular:** Sözleşme testinde veritabanı havuzu kimsenin dinlemediği bir adrese (127.0.0.1:1) bağlanır; oturumlu uç 503, token'sız ya da bozuk token'lı istek 401 döner. Neon compute'u askıya almak bu durumu üretmez, ilk bağlantı onu uyandırır. Erişilemeyen adresle revizyon açmak da denenmez: API açılışta veritabanını 30 sn bekler, gelmezse kapanır; revizyon hiç açılmaz. Test ortamında önceki revizyona dönüldü.

### 20. SEO ve GEO (herkese açık sayfa varsa)

[SEO ve GEO](#seo)
**Üretir:** Search Console DNS TXT ile, Bing; istek anında sitemap, canonical; robots.txt kapıdan; OG kartları; panelde noindex.

**Doğrular:** Her sayfa tipi JavaScript'siz curl ile okunur; sitemap sayısı curl ile eşit; sayfa ve sitemap istekleri 'db wake' yazmaz.

**DUR:** Siteyi herkese açmak ürün sahibinin kararı.

### 21. Gerçek zamanlı (akış istiyorsa)

[Gerçek zamanlı](#mesajlasma)
**Üretir:** Seçilen basamak ve nedeni; istemci anahtarlı mesaj tablosu; bildirim, silme, rapor ve engel kuralları.

**Doğrular:** Arka planda ve gizli sekmede yoklama isteği 0, logdan okundu.

### 22. Startup kredileri

[Krediler](#krediler)
**Üretir:** Başvuru dosyası: iş e-postası, ürün tanımı, kullanım rakamları; kredi kaydı ve bitişten bir hafta önce hatırlatma.

**Doğrular:** Her kredinin bitişi yenileme tablosunda.

**DUR:** Başvuruyu ve claim'i ürün sahibi yapar.

### 23. İlk canlı çıkış ve ölçüm

[Kırmadan değiştirmek](#kirmama)
**Üretir:** Test'te doğrulanan digest'in terfisi, candidate duman testi, ertesi sabah kontrolü; performans hedef tablosu.

**Doğrular:** Kural 8.1: build, revizyon, sağlık 200, ilk 30 dakikada 5xx 0; ilk p50 ve p90 STATUS'ta.

**DUR:** Canlıya deploy ürün sahibinin sözüyle.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'İlk kullanıcıdan önce' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a, ürün sahibine tek satır rapor. Boş kutu varken ilk gerçek kullanıcı alınmaz.

### İlk mağaza sürümünden önce

Yalnız mobil varsa.

### 24. Kit ve yayın kapısı

[Mobil kit](#mobilkit)
**Üretir:** Kitin OTA dışındaki on parçası; yayın kapısının 19 maddesi kanıtlarıyla sürüm notunda. OTA seçilmediyse 11. madde 'seçilmedi' ve karar numarasıyla (K-NNN) yazılır; seçildiyse 28. adımda kurulur.

**Doğrular:** İki platformun release build'i gerçek telefonda; zorunlu ekran önceki mağaza build'inde görüldü.

[öneri] App Check'in gerçek sağlayıcıları: Play Console'da uygulama ve bağlı proje, uygulama imzasının SHA-256'sı Firebase'de; iOS'ta App Attest yeteneği, entitlement 'production'. Yerel build Play onayı almaz, App Attest'in sandbox token'ı kabul edilmez; bu yüzden test build'i debug sağlayıcıyla çalışır, mağaza build'inde debug sağlayıcı yoktur. Firebase işleyen listesinde.

### 25. Mağaza hazırlığı

[Expo mobil](#katman-4)
**Üretir:** Play hesabı şirket adına; hesap kişisel açıldıysa 12 testçili 14 günlük kapalı test ilk sürümden en az 3 hafta önce başlar. Uygulama içi silme, gizlilik formları, inceleme hesabı.

**Doğrular:** Formlar her SDK'yı kapsar; inceleme hesabının her girişi log yazar.

**DUR:** Mağaza formlarını ve beyanları ürün sahibi gönderir.

### 26. Build bütçesi ve gönderim provası

[Mobil dağıtım](#dagitim)
**Üretir:** Platform başına aylık build bütçesi README'de; yerelde alınan build'le `eas submit --path` provası; App Store Connect kaydının kimliği eas.json'da ascAppId olarak.

**Doğrular:** `eas account:usage` kalan hakkı gösterir; yerel build mağazanın iç test kanalına ulaştı. İlk Android gönderimi iç test kanalına gider; mağaza girişi ve formlar bitene kadar uygulamanın Play Console'da taslak kalması prova hatası sayılmaz.

**DUR:** Her bulut build'i, gönderim ve sürüm numarası ürün sahibinin açık sözüyle. Provadan önce ürün sahibi Play Console'da uygulamayı açar ve Play servis hesabı anahtarını EAS'a yükler; App Store Connect'te uygulama kaydını açar.

### 27. Ödeme (satış varsa)

[Expo mobil](#katman-4)
**Üretir:** RevenueCat, 10 dk TTL'li sunucu mutabakatı, ham gövdeyi kaydeden webhook, tek 5xx alarmı.

**Doğrular:** Sağlayıcı panelinde bir teslim başarılı; webhook kapalıyken Premium doğru.

### 28. OTA (seçildiyse)

[Mobil kit](#mobilkit)
**Üretir:** expo-updates, fingerprint, kanal eşlemesi; ortamı zorlayan yayın betiği.

**Doğrular:** Preview güncellemesi release build'de uygulandı; hatalı güncellemede geri dönüş denendi.

**DUR:** Her OTA yayını ürün sahibinin kararı.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'İlk mağaza sürümünden önce' kutuları işaretlenir; sonuç sürüm notuna ve STATUS'a, ürün sahibine tek satır rapor. Boş kutu varken mağazaya gönderilmez.

### Sonra

Sürekli; ajan takvimden yürütür.

### 29. Her hafta

[Performans](#performans)
**Üretir:** p50 ve p90, soğuk başlangıç, uyanış ve OOM; pazartesi özeti; 7 günlük sürüm dağılımı.

**Doğrular:** STATUS'ta haftanın satırı.

### 30. Her ay

[Kontrol listesi](#kontrol)
**Üretir:** Fatura SKU kırılımıyla, Neon tüketimi, yedek, geri dönüş imajı, 60 günün yenilemeleri; güncelleme günü ve destek bitişleri.

**Doğrular:** 'Her ay' kutuları işaretli; 6 aydan az kalan sürüm TODO'da P1.

**DUR:** Güncellemelerin main'e alınması ürün sahibinin sözüyle.

### 31. Üç ayda bir

[Yedek](#yedek)
**Üretir:** Son döküm yeni bir Neon dalına tam yüklenir, md5 karşılaştırılır; ücretsiz katman şartları yeniden okunur.

**Doğrular:** Süre runbook'ta; değişen sınır tabloda.

### 32. Yeni SDK, işleyen ya da platform

[KVKK](#kvkk)
**Üretir:** KVKK listesi, gizlilik metni, App Store etiketi ve Data safety aynı gün güncellenir.

**Doğrular:** Yeni SDK listede ve iki mağaza beyanında.

### 33. İçerik otomasyonu (seçildiyse)

[İçerik otomasyonu](#icerik)
**Üretir:** Hattın on bir parçası, açılış kapısının 17 maddesi, bir haftalık kuru çalışma.

**Doğrular:** Bozuk token'la alarm geldi; aynı iş iki kez çalışınca ikinci yayın yok.

**DUR:** Otomatik paylaşımı ürün sahibi açar.

**Aşama sonu:** Her ay [Kontrol listesi](#kontrol)'nin 'Her ay' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a yazılır, ürün sahibine tek satır rapor gider.

## Bitti sayılır

Altyapı bu kutular işaretlenince teslim edilmiş sayılır. Bundan sonra ajan haftalık, aylık ve üç aylık işleri takvimden yürütür.

- [ ] **Kararlar.** Gün 0 ve ilk kullanıcı kararlarının hepsi DECISIONS.md'de; 'KARAR BEKLİYOR' yalnız sonraki aşamaların satırlarında.

- [ ] **Hafıza.** AGENTS.md, CHANGELOG, STATUS, TODO, DECISIONS ve deploy, rollback, restore-db runbook'ları depoda; STATUS'un her canlı satırı doğrulama yöntemi ve tarihiyle.

- [ ] **Hesaplar.** Envanter dolu; her hesapta iki yönetici, kök hesaplarda anahtar, yenilemeler takvimde.

- [ ] **Sürümler.** Tablo STATUS'ta destek bitişleriyle; Renovate ya da Dependabot açık.

- [ ] **Yol.** test'e push test ortamına çıkıyor; main onay kapısından aynı digest'le; bir kez önceki revizyona dönüldü.

- [ ] **Veritabanı uyuyor.** Boş saatte Neon uyuyor; saatlik tüketim ve 'db wake' satırları okundu.

- [ ] **Para.** Bütçe uyarıları ve kota tavanları kurulu; her ücretli işin günlük ve aylık rakamı yazılı.

- [ ] **Uyarılar.** Her tür [TEST] ile denendi; iki alıcı gördüğünü yazdı.

- [ ] **Yedek.** Her gün geri yüklenerek denetleniyor; bir elle geri yükleme yapıldı, süresi runbook'ta.

- [ ] **Olay ve admin.** Olay ucu ve on zorunlu olay; admin ayrı girişle ve denetim kaydıyla.

- [ ] **Mobil.** Seçildiyse kitin yayın kapısı kanıtlarıyla geçti; yerel build yolu prova edildi.

- [ ] **Devir.** Ürün sahibine tek sayfa not: ne kuruldu, nasıl doğrulandı, hangi karar bekliyor.

<a id="hizli"></a>

Önce bunu oku

# En hızlı kurulum yolu

Yığının en ucuz, en hızlı ve en güvenli hali bu sırayla kurulur.

## Gün 0: kod yazılmadan

1. Ürüne ayrı faturalama hesabı ve Neon org'u; üç eşikli bütçe alarmı, BigQuery fatura dökümü.

[Ücretsiz katmanlar](#ucretsiz)
2. Alan adı haftalar önce alınır ve kategori başvurusu yapılır; DNS ilk günden Cloudflare'de.

[Kenar ve DNS](#katman-5)
3. Özel depo, gitleaks, push protection, 1 MB ve ikili kapısı, ajan dosyası; test ve main dalı.

[Depo kuralları](#depo-kurallari)
4. Neon Frankfurt'ta: prod Launch (asgari ücret yok), test Free; havuz tabanı 0, boşta 90 sn.

[Postgres](#katman-1)
5. Servisler europe-west1'de min 0, istek bazlı faturalama, CPU boost açık; Next'e 1 GiB.

[Performans](#performans)
6. Tek Docker deposu, bölgesel tetikleyici, live ve prev KEEP'li temizlik; digest terfi eder.

[Artifact Registry](#registry)
7. Herkese açık okumalar API belleğinden, GCS işaretiyle tazelenir; sayfa başına bir API çağrısı.

[Mimari](#mimari)
8. Bot kapısı proxy'nin ilk satırında; gün 0'da yalnız ortak listenin kanıtlı kuralları reddeder.

[Botlar](#botlar)
9. Kod formunda Turnstile, mobil kod ucunda App Check, hazır yedek e-posta sağlayıcısı.

[E-posta](#katman-9)
10. Sırlar Secret Manager'da, her sırrın tek etkin sürümü; her servis en az yetkiyle.

[Güvenlik](#katman-8)
11. Veri yeri, işleyen listesi ve yurt dışı aktarım dayanağı yazılı.

[KVKK](#kvkk)
12. Ücretli dış API, alternatifleri ve en kötü günün faturası yazılmadan açılmaz.

[Pahalı dış API'ler](#pahali-api)
13. Mobilde uzaktan kontrol kiti ilk commit'te: sürüm başlıkları, politika ucu, zorunlu güncelleme, duyuru, push, bayrak; OTA önerilir.

[Mobil kit](#mobilkit)

## İlk kullanıcıdan önce

14. Web ve API'ye ayrı, veritabanısız sağlık ucu ve uptime kontrolü; alarmlar denenmiş.

[Gözlem](#katman-10)
15. Günlük döküm geri yüklenerek denetlenir, başarı satırı alarmlı; Neon geçmişi 7 gün.

[Yedek](#yedek)
16. Dökümden bir kez tam geri yükleme yapıldı; süresi runbook'ta.

[Yedek](#yedek)
17. E-posta sayacı UTC gününe göre: toplam 80'de toplu gönderim durur, kodlar 100'e kadar.

[E-posta](#katman-9)
18. API yalnız ekleyerek değişir; geçici hata kimseyi oturumdan atmaz; her yayın geri alınabilir.

[Kullanıcı kuralları](#kirmama)
19. Hedef p50 ve p90 yazılı; soğuk başlangıç, uyanış ve OOM haftada bir okunur.

[Performans](#performans)
20. Startup kredisine ayrı hesap ve Neon org'u açıldıktan sonra, ağır kullanımdan önce.

[Krediler](#krediler)

## İlk mağaza sürümünden önce

21. Kitin zorunlu parçaları ve yayın kapısı kanıtlı; OTA önerilir. Kit yoksa sürüm yok.

[Mobil kit](#mobilkit)
22. Play hesabı şirket adına açılır; kişisel açıldıysa 12 testçili 14 günlük kapalı test ilk sürümden en az 3 hafta önce başlar.

[Expo](#katman-4)
23. Zorunlu ekran önceki mağaza build'inde, gerçek telefonda, önizleme listesiyle görüldü.

[Mobil kit](#mobilkit)
24. Build bütçesi: platform başına ayda 15 hak, preview yerelde, ay sonuna 2–3 acil hak.

[Mobil dağıtım](#dagitim)
Sağdaki ad o adımın kurallarının durduğu bölümdür ve bağlantıdır.

<a id="cevaplar"></a>

Önce iki cevap

# Botlar ve maliyet

## Kimi engelleriz, kimi engellemeyiz

[aç] hiçbir kural dokunmaz[sınırla] hız kovasından düşer[izle] yalnız logda görünür[engelle] 403 ya da 404

| Alibaba Cloud ve benzeri bulutlardan gelen kazıyıcılar |
| Tarayıcı kılığında bulut kazıyıcısı | [engelle] | Bulutun bütün ağı (ASN) içerik sayfalarında 403 alır; API, oturum, form ve yasal sayfalar açık kalır. |
| Kimliği belirlenemeyen istekler |
| Boş, URL biçimli ya da kesik ajan | [engelle] | Accept-Language ve Sec-Fetch-Mode da göndermeyen içerik GET'i 403 alır; güvenlik firmaları muaf. |
| Sahte bot adı | [engelle] | Yayıncının adres aralığında olmayan bot adı önce gölgede yazılır, temiz bir dönemden sonra 403 alır. |
| Adresi okunamayan istek (0.0.0.0) | [sınırla] | Ağ kuralları göremez; ad kuralları ve tek ortak hız kovası uygulanır. |
| Konut proxy havuzu | [izle] | Engel Türk ev hatlarındaki gerçek kullanıcıyı da keser; önlem veriyi ucuza sunmaktır (ISR, kenar önbelleği). |
| AI botları |
| Cevap motorları ve kullanıcı adına getiriciler | [aç] | OAI-SearchBot, ChatGPT-User, PerplexityBot, Claude-User kaynak linki verir; aralıkla doğrulanınca hız sınırından muaf. |
| Eğitim tarayıcıları | [sınırla] | GPTBot, ClaudeBot, meta-externalagent: karar GEO hedefiyle robots.txt'ye yazılır, açık kalan saniyede 1 sayfa çeker. CCBot ve Bytespider varsayılan olarak engelli. |

**Hiç dokunulmayanlar:** doğrulanmış arama motorları, link önizleyiciler, e-posta güvenlik tarayıcıları, mobil uygulamanın API'si, oturum, form ve yasal sayfalar.

## ₺510–690 bizde gerçek mi?

Dört ürünün toplamı
~₺1.300/ay
Eylül'de ~₺3.900–4.400
**Yalnız günlük kullanıcılı ürün için.** Ürün A bugün ~₺610 tutuyor. Öteki üç ürün ₺5–510 arasında.

Yeni ve az trafikli bir ürünün bulut faturası ayda ~₺55–135 olur.

NeonGoogle CloudTL/ay, 8 Ekim 2026; alan adı ve mağaza (Apple, Google) ücretleri hariç
_Grafik: Ürün başına aylık maliyet_

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

<a id="bakis"></a>

Bir bakışta

# Kısaca

Yeni ürün Neon Postgres, Go API, Next.js 16 ve Expo ile Google Cloud'da kurulur. Neon uyuyabilecek şekilde bağlanır; prod Launch'ta (aylık asgari ücret yok), test ve gerçek kullanıcısı olmayan yan projeler Free org'da. API ve web Cloud Run europe-west1'de min 0 ile çalışır. Herkese açık okumalar API belleğinden verilir, GCS'teki bir değişiklik işaretiyle tazelenir. Zamanlanmış işler tek bir Cloud Scheduler işinden OAuth token ile Cloud Run Jobs'a gider. DNS ilk günden Cloudflare'dedir: web Worker üzerinden run.app'e, api.* domain mapping ile bağlanır. Önerilen hatta imaj bir kez kurulur ve test'te doğrulanan digest onay kapısından geçerek prod'a çıkar; bizde test ve prod bugün hâlâ ayrı build ediliyor. Mobil uygulama uzaktan kontrol kiti kurulmadan yayınlanmaz. Alarmlar, doğrulanan yedek ve KVKK işleyen listesi ilk kullanıcıdan önce hazırdır. Az trafikli yeni bir ürünün bulut faturası ayda ~₺55–135, günlük kullanıcılı bir ürününki ~₺510–690 olur; gerçek kullanıcılı üründe bunun en az %60'ı Neon'dur. Alan adı ve mağaza ücretleri zorunlu sabit gider oldukları için hesaba katılmadı.

## On ilke

### 1. Veritabanı uyuyabilmeli

Neon ancak 5 dakika hiç bağlantı olmazsa uyur. Havuzun tabanı 0, boştaki bağlantı 90 sn'de kapanır, zamanlayıcıyla soran kod yoktur, herkese açık okumalar veritabanına gitmez, günlük veritabanı işleri tek sabah penceresinde çalışır.

**Neden** Bir ürünümüzün günlük tüketimi 7/24 uyanıkken 6,2 CU-saatti, bu kurallarla ~3,2'ye indi.

### 2. Önce say, sonra değiştir

Maliyet ve uyanma sorununa ölçümle başlanır: fatura proje ve SKU bazında, Neon tüketimi saat saat, trafik 5 dakikalık boş pencerelerle okunur.

**Neden** GCP için '$1/ay' denmişti; Ağustos'ta faturalama hesabının toplamı ₺2.087 geldi.

### 3. Geçici hata kimseyi oturumdan atmaz

401 yalnız kesin yetki reddinde döner; veritabanı ya da altyapı hatası 503 ve Retry-After ile döner; istemci oturumu yalnız 401'de siler; API açılışta veritabanını ~30 sn bekler.

**Neden** Soğuk başlangıçların ~%1–1,5'i uyuyan Neon'a denk geliyor; bu hata 401 dönseydi kullanıcılar oturumdan düşerdi.

### 4. Sessiz hata yoktur

Başarısız iş 2xx dönmez; her 5xx sebebiyle ve severity alanıyla loglanır; az trafikli kritik uçlara 'N saattir başarı yok' alarmı kurulur.

**Neden** Bir ödeme webhook'u 21 gün boyunca log yazmadan 500 döndü.

### 5. Prod'a giden yolu makine korur

Test'te doğrulanan imaj aynı digest'le, onay kapısından geçerek prod'a çıkar; testler ve migration hattın içindedir.

**Neden** Migration koşmadan yayına çıkan kod 11 dakika 500 döndürdü.

### 6. Yerel varsayılan asla prod olmaz

Kod, env dosyaları, testler, simülatör ve dev sunucusu varsayılan olarak yerel ya da test ortamına bağlanır; prod'a dokunan komutun adında 'prod' geçer; mobil build ve OTA ortamı açıkça veren bir betikle alınır.

**Neden** Bir testin prod'a yazdığı 44 sahte hesaplama herkese açık listede göründü.

### 7. Her çalışan şey en az yetkiyle

Her servis kendi rolsüz hesabıyla çalışır, yetki kaynakta verilir, sırlar Secret Manager'dadır, anahtar dosyası indirilmez; bir projede kapatılan açık aynı gün bütün projelerde kontrol edilir.

**Neden** 23 Eyl 2026'da bir SSRF açığı Editor yetkili hesapla birleşince proje ele geçirilebilir hale geldi ve aynı gün kapatıldı.

### 8. Para harcayan her şeyin rakamı ve tavanı önceden yazılır

Ücretli iş kurulmadan 'günde ~$Y, ayda ~$Z' satırı yazılır; anahtar projeye özeldir, sağlayıcıda sert bütçe vardır, uygulama içi tavan veritabanında filo genelinde sayılır.

**Neden** Bir harita API'si Ağustos'ta ₺1.500 yazdı, projenin Google faturasının ~%72'si.

### 9. Riskli değişiklik gölgede başlar, anahtarla kapanır

Yeni okuma yolu, CSP, bot kuralı ve özellik önce yalnız log ya da fark üretir; açma, kapama ve geri dönüş env ya da sunucu anahtarıyladır. Mobil uygulama uzaktan kontrol kiti kurulmadan yayınlanmaz.

**Neden** Gölgesiz açılan bir bot kuralı ilk gün bir e-posta link tarayıcısına 403 verdi.

### 10. Veri nerede duruyorsa öyle yazılır

Veri bölgesi, işleyen listesi ve aktarım dayanağı proje doğarken yazılır; yeni SDK bu liste, aydınlatma metni ve mağaza etiketleri güncellenmeden çıkmaz.

**Neden** Bildirilmeyen standart sözleşmenin 2026 cezası ₺90.308–1.806.177.

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
GCP projesi: 6–30 karakterlik bir kimlik, ör. `<ürün>-app`; sonradan değişmez. Servisler: api, web, api-test, web-test. Job'lar `<servis>-migrate` kalıbıyla: api-migrate, api-test-migrate. Dağıtıcı: dispatch, dispatch-test. Yedek: backup, yalnız prod'da. Servis hesapları da 6–30 karakter olmalıdır: run-api, run-web, run-api-test, run-web-test, build-test, build-main, run-backup, scheduler. Sırlar `<servis>-<ad>` kalıbıyla, ör. api-database-url ve api-test-database-url. Artifact Registry'de tek depo vardır: app, europe-west1'de. Kova adları dünya çapında tek olduğu için proje kimliğiyle başlar: `<proje>-media`, `<proje>-docs`, `<proje>-backup`, `<proje>-flags`. Test kovaları aynı adın sonuna -test alır, ör. `<proje>-flags-test`. Neon'da iki proje vardır: `<ürün>-prod` Launch org'unda, `<ürün>-test` Free org'unda. Roller: app_rw (DML), app_migrate (şema sahibi), app_backup (salt okunur).

## Akışlar

1. **Ziyaretçi** →Cloudflare (WAF; HTML önbelleği yalnız purge bağlıysa)→Worker→Next (bot kapısı, ISR, işaret kontrolü)→API (bellek)→Neon yalnız kopya yenilenirken

2. **Oturumlu kullanıcı** →Cloudflare (bypass)→Next BFF (HttpOnly çerez)→API (X-Client-IP + iç anahtar)→Neon pooled

3. **Mobil** →api.*→API; her istekte sürüm, build, platform ve kanal başlığı; update-policy bellekten

4. **Yazma** →Neon transaction (outbox, tombstone)→GCS işareti→API instance'ları 30 sn'de bir okur→Next proxy'si loopback route ile revalidateTag çalıştırır→kenarda değişen URL'ler purge edilir

5. **Scheduler (OAuth, .../jobs/J:run)** →Job→Neon; veritabanı işleri tek 10 dakikalık pencerede; hata→alarm

6. **test push** →vet, test, govulncheck, Docker build→digest→migrate --wait→test servisi; main→onay→aynı digest→migrate --wait→candidate smoke→trafik→live/prev etiketi

7. **Yedek** →pg_dump→geçici Postgres'e geri yükleme kontrolü→PAP kova→haftalık proje dışı kopya; geri yüklemeden sonra tombstone'lar uygulanır

<a id="kirmama"></a>

Kullanıcıyı bozmama kuralları

# Kullanıcıyı kırmadan değiştirmek

Canlı bir ürünü değiştirirken kullanıcının yaptığı hiçbir şey bozulmaz: eski uygulama çalışmaya devam eder, oturum açık kalır, adres yerinde durur, giriş kodu gelir, paylaşılan bağlantı açılır.

Aşağıdaki kurallar Ağustos ile Ekim 2026 arasında dört ürünümüzde yaşanan olaylardan ve ölçümlerden çıktı. Her kuralda nedeni (olay, tarih, rakam) ve nasıl kontrol edileceği yazılı. Sekiz başlıkta 76 kural var.

1. API ve veri uyumluluğu
9 kural: 9 kanıtlı
2. Mobil sürümler
13 kural: 8 kanıtlı, 2 ölçüldü, 3 öneri
3. Web
12 kural: 10 kanıtlı, 1 ölçüldü, 1 öneri
4. Giriş ve oturum
8 kural: 6 kanıtlı, 2 öneri
5. E-posta ve bildirim
10 kural: 8 kanıtlı, 1 ölçüldü, 1 öneri
6. Botlar ve sınırlar
6 kural: 5 kanıtlı, 1 ölçüldü
7. Yayın disiplini
11 kural: 11 kanıtlı
8. Hiçbir şeyin kırılmadığını ölçmek
7 kural: 5 kanıtlı, 1 ölçüldü, 1 öneri
Etiketler kapaktaki anlamla kullanılır. Bu bölümde öneri, bizde denenmemiş ya da henüz tam uygulanmamış kural demektir.

## 1. API ve veri uyumluluğu9 kural

1.1

****API sahadaki en eski desteklenen uygulamaya göre yazılır**. Değişiklik yalnız ekler: yeni tablo, yeni uç, NULL kabul eden ya da DEFAULT'lu yeni kolon, yanıtta yeni alan. Var olan kolon silinmez, adı ve tipi değişmez; var olan ucun isteği ve yanıtı değişmez.** [kanıtlı]
**Neden:** Mağaza sürümü bir gecede herkese ulaşmıyor: 28 Eyl 2026'da son 7 günde iOS'taki 308 aktif kullanıcının 22'si hâlâ 3.x sürümündeydi. Bizde API main'e push'ta onaysız deploy oluyor, bu yüzden kırıcı bir değişiklik doğrudan bu kullanıcılara gider. Önerilen onay kapısı uyumu denetlemez; bu kural onunla da geçerlidir.

**Nasıl kontrol edilir:** Migration farkında yalnız ekleme var. Değişen ucun yanıtı sahadaki en eski sürümün koduyla okunur. Test ortamında güncellenmemiş istemci senaryosu koşar; bir projemizde yeni akış açılmadan önce bu senaryo 11/11 geçti.

1.2

****Alan, anahtar ve tür adları bir kez kullanılır**. Anlamı değişecekse eski ad bırakılır, yeni adla yeni alan açılır; eski ad başka bir anlamla geri gelmez. Kaldırılan bir değer API'de kabul edilmeye devam eder. Sıralı değer listelerinin adı ve sırası sabittir.** [kanıtlı]
**Neden:** 30 Eyl 2026'da AI asistanın yeni sürümü yeni bir anahtarla açıldı; eski anahtar kalıcı olarak kapalı tutuldu ve eski uygulamalar yeni cevap biçimini hiç görmedi. 17 Eyl'de iki ürün tipi tek seçeneğe indiğinde eski değer API'de kabul edilmeye devam etti, o değeri taşıyan eski bağlantılar birleşik seçeneğe indi.

**Nasıl kontrol edilir:** İncelemede silinen ya da anlamı değişen alan adı aranır. Enum değerleri ve sıraları testle sabitlenir.

1.3

****Eski istemcinin tanımadığı veri ona eski biçimde gider ya da hiç gitmez**; eski ekranda kırık kart, boş alan ya da çözülemeyen tür görünmez. İstemci sürümünü ve build'ini her istekte bir başlıkla bildirir, sunucu süzgeci buna bakar.** [kanıtlı]
**Neden:** Bir projemizde talep havuzunun yeni iletişim akışı 5 Eki 2026'da açıldı. Sürüm başlığı göndermeyen istemciye havuz yalnız eski akışın taleplerini döndü; düzenlenen talebin gelen kutusu satırı eski türüyle yazıldı ki eski sürümler onu saysın; bilinmeyen bildirim türü eski uygulamada yalnız uygulamayı açıyor. Android istekleri build numarası taşımadığı için süzgeç uygulamanın kendi başlığına dayanıyor.

**Nasıl kontrol edilir:** Yeni tür, durum ya da bildirim eklenince test ortamında sahadaki en eski build'le liste, ayrıntı ve bildirim açılır.

1.4

****Şema değişikliği genişlet ve daralt sırasıyla gider**. Önce yalnız ekleyen migration kendi adımında uygulanır, sonra onu kullanan kod çıkar. Eski kolon ancak hiçbir yayındaki sürüm onu okumadığında, ayrı bir sürümde kalkar. Uygulanmış migration dosyası değiştirilmez.** [kanıtlı]
**Neden:** Bir projemizde 21 Eyl 2026'da yeni kolonu okuyan kod, kolonu açan migration'la aynı değişiklikte yayına çıktı. O serviste migration deploy'un parçası değildi; bütün mağaza sayfaları 11 dakika 500 döndü.

**Nasıl kontrol edilir:** Deploy'dan önce migration kaydında yeni dosya görünür. Migration işi yeni imajla ve bitmesi beklenerek çalışır; kod deploy'u ondan sonra gelir.

1.5

****Durum kodu bir sözleşmedir**. 401 yalnız kesin yetki reddidir: token yok, tanınmıyor, süresi dolmuş, çıkış yapılmış ya da devralınmış. Veritabanı ve dış servis hatası 503 ve Retry-After ile döner. Yeni bir ret sebebi yeni durum kodu olarak değil, aynı kodun gövdesinde yeni bir makine okunur alan olarak gelir.** [kanıtlı]
**Neden:** İki projede her veritabanı hatası 401'e çevriliyordu ve istemciler 401'de oturumu siliyordu; olay yaşanmadan 2–4 Eki 2026'da kapatıldı. 20 Eyl'de devralınan oturuma sebep eklenirken durum kodu 401 kaldı, gövdeye yeni kod kondu: eski uygulama eskisi gibi çıkış yaptı, yeni uygulama sebebi gösterdi.

**Nasıl kontrol edilir:** Sözleşme testi: veritabanı kapalıyken oturumlu uç 503 döner. Deploy sonrası saatlik 401 sayısı önceki günle karşılaştırılır.

1.6

****API önce, istemci sonra**. Sunucuya dayanan yeni bir istemci özelliği, bağlı olduğu API prod'da trafik almadan mağazaya gönderilmez.** [kanıtlı]
**Neden:** 4.0.9'un 'kodu tekrar gönder' düğmesi, geç gelen ilk kodun da geçmesini sağlayan 2 Eki 2026 API sürümüne dayanıyordu; sürüm notuna 'bu build o API prod'dayken çıkmalı' yazıldı. Yeni uçlar bilinmeyen alanı reddettiği için ters sıra 400 üretir.

**Nasıl kontrol edilir:** Sürüm notunda bağlı API sürümü satırı bulunur. Gönderimden önce o revizyonun trafikte olduğu servis tanımından okunur.

1.7

****Eski istemcinin sabit yazdığı bir sayı ya da metin sunucuda değiştirilmeden önce, o değeri sunucudan okuyan sürüm yayılır**. Sunucudan yönetilen bir uyarı alanı her yeni ekrana baştan konur.** [kanıtlı]
**Neden:** 30 Eyl 2026'da AI asistanın günlük hakkı 20'den 10'a inecekti; uygulamanın kilit ekranı '20' sayısını sabit yazıyordu, önce ekran sunucudan okur hale getirildi. Talep havuzunun eski ekranına sunucudan metin konamadığı için eski sürümdeki kurumsal kullanıcıya değişiklik anlatılamadı; yeni sürüme sunucu kontrollü uyarı alanı eklendi.

**Nasıl kontrol edilir:** Değişecek değer eski sürümlerin metin dosyalarında aranır.

1.8

****Kullanıcının yazdığı hiçbir değer akışı kilitlemez**. Anlaşılmayan ya da aralık dışı değer düşürülür ve kullanıcıya söylenir; bir hatalı mesaj sonraki mesajları reddettirmez. Konu içi ama eksik bir istek 'kapsam dışı' cevabı almaz, eksik olan sorulur.** [kanıtlı]
**Neden:** 2 Eki 2026'da AI sohbetinde '70000' gibi aralık dışı bir sayı yazan kullanıcının sohbeti geçersiz değer hatasına düştü ve sonraki her mesaj aynı hatayı aldı; bir başka kullanıcı 'kapsam dışı' cevabıyla hakkını harcayıp çıktı. Düzeltmeden sonra canlı değerlendirme 11/11 ve 6/6 geçti.

**Nasıl kontrol edilir:** Uç senaryo seti (yazım hatası, ASCII Türkçe, aralık dışı sayı, üçüncü şahıs anlatım) her kural ya da model değişikliğinde koşar.

1.9

****Ödeme ve Premium durumu üç yoldan beslenir**: istemci SDK'sı, kısa TTL'li sunucu mutabakatı ve webhook. Biri ölürse kullanıcı fark etmez. Geçici sağlayıcı hatası Premium'u kapatmaz, oturumu silmez, Premium kullanıcıya yeniden satın alma önermez.** [kanıtlı]
**Neden:** Ödeme webhook'u 2–23 Eyl 2026 arası her teslimde log yazmadan 500 döndü. Premium öteki iki yoldan çalıştığı için hiçbir kullanıcı etkilenmedi; kaybolan, olayların kaydı ve anında yansımasıydı.

**Nasıl kontrol edilir:** Webhook ucunda tek 5xx alarmı. Sağlayıcı panelindeki teslim listesi haftada bir okunur.

## 2. Mobil sürümler13 kural

2.1

****Güncelleme uyarısı ile zorunlu güncelleme ayrı anahtarlardır**. Kapatılabilir 'yeni sürüm hazır' sayfasının hedef sürümü ancak mağaza o sürümü gerçekten sunarken yükseltilir. Zorunlu güncelleme, kurulu tabanın büyük kısmı zorunlu ekranı doğru çizebilen build'lere geçene kadar kapalı kalır. Politika okunamazsa uygulama açılmaya devam eder.** [kanıtlı]
**Neden:** 18 Eyl 2026'da üç Android build'inin kendi numarasını okuyamadığı ve uyarıyı hiç gösteremeyeceği bulundu; iOS'ta eski zorunlu ekran telefonu içeriksiz kilitliyordu. Zorunlu güncelleme bu yüzden hiç açılmadı. Mağazanın herkese açık sayfası yeni sürümü gösterirken arama API'si saatlerce eski sürümü dönebiliyor (1 Eki).

**Nasıl kontrol edilir:** Hedef sürüm değeri mağaza sayfasında sürüm göründükten sonra değişir. 'En son sürüm' değerini yükseltmenin zorlamayı açmadığı ayrıca söylenir. Politika isteği 5 sn'de son bilinen değere düşer.

2.2

****Güncelleme ekranları ve release build gerçek telefonda kanıtlanmadan 'çalışıyor' denmez**. Hedef sürüm kurulu build'in üstüne çekilir, uygulama yeniden açılır, sayfa açılır ve 'Şimdi güncelle' mağazaya gider; sonra değer geri alınır. Aynı build'de açılış, hesaplama, paywall, PDF ve bildirim bir kez denenir.** [kanıtlı]
**Neden:** Birim testleri kurulu build numarasını taklit ediyordu; kontroller yalnız sunucu tarafındaydı ve uyarı üç build boyunca hiç çıkmadı. 19 Eyl 2026'da emülatörde release build'le dört senaryo kanıtlandı. TestFlight'ı atlayan bir sesli komut özelliği 2–3 Eki'de iki ek build harcattı.

**Nasıl kontrol edilir:** Mağaza gönderiminden önce bu liste telefonda ya da emülatörde, ekran görüntüsüyle tamamlanır.

2.3

****Eski build'ler API'yi aylarca kullanır**. Kimin hangi sürümde olduğu 7 günlük pencereyle ve tekil kullanıcıyla sayılır; karar bu sayıya göre verilir.** [ölçüldü]
**Neden:** 28 Eyl 2026'da 28 günlük 'telefon başına son sürüm' sayımı iOS'ta 211 telefonun 139'unu 3.x gösterdi ve rapor geri alındı; ödeme sağlayıcısının 7 günlük sürüm süzgeci 308 aktif kullanıcının 22'sini 3.x buldu. Uzun pencerede güncelleyen kişi iki grupta birden sayılıyor.

**Nasıl kontrol edilir:** Ödeme sağlayıcısının sürüm süzgeci, 7 gün. iOS istek kaydındaki build. Android için uygulamanın kendi başlığı.

2.4

****Eski sürümde çalışmayacak bir özellik, onu gerçekten kullananlar yeni build'e geçmeden açılmaz**. Açılış hafta içi mesai başında yapılır.** [kanıtlı]
**Neden:** Talep havuzunun yeni akışında eski sürümdeki kurumsal kullanıcı yeni talepleri göremiyordu ve son 90 günün 7 talebinin 5'i yeni akıştan gelecekti. 30 Eyl 2026'da son 30 günde havuzu kullanan 6 kurumsal kullanıcının güncellemesi beklendi; 5 Eki'de 6'nın 5'i yeni build'deyken açıldı.

**Nasıl kontrol edilir:** Push cihaz tablosundaki build dağılımı her gün okunur. Build numaraları anahtardan önce sunucuya yazılır.

2.5

****Eski sürümdeki kullanıcı ürkütülmez**. Zorla kilit, toplu uyarı ya da korkutucu metin yok; olağan 'yeni sürüm var' sayfası ve gerekiyorsa yalnız yayındaki build'in altındaki cihazlara giden bir güncelleme bildirimi yeter. Eski sürümde özelliği gizlemek de kullanıcıya bozukluk gibi görünür.** [kanıtlı]
**Neden:** 28–30 Eyl 2026 kararı: eski sürümdeki kurumsal kullanıcıya otomatik bildirim gitmez, uygulamayı açınca uyarılır; havuzu eski sürümde gizlemek 'kullanıcılar için kötü görünür' diye reddedildi. 19 Eyl'den beri güncelleme bildirimi yayındaki build'i çalıştıran cihaza gitmiyor.

**Nasıl kontrol edilir:** Duyurunun kitlesi build'e göre süzülür; göndermeden önce hedef cihaz sayısı okunur.

2.6

****Güncelleme var olan kurulumun oturumunu, Premium'unu ve dilini olduğu gibi bırakır**. İlk açılış akışı yalnız yeni kuruluma gösterilir; kurulumun yeni mi eski mi olduğu anlaşılamazsa eski sayılır.** [kanıtlı]
**Neden:** 17 Eyl 2026 denetiminde depolama taraması hata verince kullanıcının yeni kurulum sayıldığı (tam ilk açılış, İngilizce telefonda dil değişimi) ve bir anahtar önekinin taramaya hiç girmediği bulundu; 24 test eklendi. 4.0.0–4.0.2'de herkese gösterilen açılış ekranı mevcut kullanıcıların akışını da değiştirdi; geçiş reklamının gösterilme oranı %50'den %22–32'ye indi.

**Nasıl kontrol edilir:** Eski sürümlerin yazdığı depolama anahtarlarının tam listesi testte sabit; yeni anahtar o listeye eklenir. Release öncesi eski build kurulu ve girişli bir cihaza yeni build üstten kurulur.

2.7

****Mağaza ayarı ve sunucu anahtarı, onları anlatan sürümle aynı anda açılır**. Eski sürüm söylemediği bir şeyi göstermez; incelemeye giden özellik inceleme sırasında prod'da açıktır.** [kanıtlı]
**Neden:** 24 Eyl 2026 notu: mağazadaki deneme süresi erken açılırsa eski sürümler satın alma penceresinde paywall'ın hiç söylemediği bir denemeyi gösterecekti. Sesli komut özellikli build incelemeye gitmeden önce anahtar prod'da açık olmasaydı inceleyici 'şu an kapalı' cevabını duyacaktı; anahtar 1 Eki'de açıldı.

**Nasıl kontrol edilir:** Sürüm notunda 'mağazada ve sunucuda neyi, ne zaman aç' satırı bulunur.

2.8

****Mağaza onayı ile yayın ayrı tutulur**. API ile aynı gün açılması gereken sürüm manuel yayınla gönderilir; yayın tarihi dışarıya gün olarak söylenmez.** [öneri]
**Neden:** Play bir sürümü ~1,5 saatte onayladı; iOS'ta gönderimden yayına yarım gün kadar geçti (Eki 2026); bir uygulamamızda Play üretim erişimini bir kez düşük kapalı test kullanımı yüzünden reddetti. Bu yüzden dışarıya 'Ekim' dendi, gün verilmedi.

**Nasıl kontrol edilir:** App Store'da 'Manually release', Play'de 'Managed publishing' gönderim anında seçilir.

2.9

****Binary kademeli açılır**: App Store'da 7 günlük aşamalı yayın, Play'de yüzdeli yayın. Sorun görülünce yayın durdurulur.** [öneri]
**Neden:** Kademeli yayın kullanmadık; bir sesli komut hatası ve hiç çıkmayan güncelleme uyarısı herkese aynı anda ulaştı.

**Nasıl kontrol edilir:** İlk gün sürüm başına istek ve hata oranı okunur; durdurma adımı önceden bilinir.

2.10

****OTA ilk mağaza build'inden kurulur**: runtime sürümü fingerprint politikasıyla, yalnız JS hata düzeltmeleri, önce küçük bir yüzde, hazır geri alma. Her OTA mağaza sürümü gibi ürün sahibinin kararıdır.** [öneri]
**Neden:** Uygulamalarımızda OTA yok. Bir uygulama 19 Eylül–7 Ekim'de 19 mağaza build'i çıkardı (iOS 9, Android 10), 11'i yalnız JS idi; iOS build kotası 22 Eylül'de doldu; sesli komut özelliğindeki bir tutar hatası ancak yeni build'le düzelebildi.

**Nasıl kontrol edilir:** Geri alma provası test kanalında yapılır.

2.11

****Build kotası ve build numarası ölçülür, varsayılmaz**. Kota platform başına ayrı sayılır; 3 dakikadan sonra düşen build de hak yer, daha erken düşen ayda 10'a kadar sayılmaz; build numarası depodan değil build servisinin listesinden okunur.** [ölçüldü]
**Neden:** Eylül 2026'da iOS'ta 17 build başlatıldı, 2'si hata verdi; iOS kotası 22 Eyl'de doldu, 24 Eyl'de istenen build reddedildi ve iOS sürümü bir hafta kaydı. Ay 03:00'te (TR saati) dönüyor; reddedilen bir deneme bile Android numarasını artırdı, 35'ten sonra 37 geldi. 4.0.2 depoda 28, mağazada 31 numaralıydı; güncelleme uyarısının hedefi bu sayıdan kurulur.

**Nasıl kontrol edilir:** Build önermeden önce ayın build sayısı platform başına okunur; hedef sürüm değeri build listesinden alınır.

2.12

****Yeni yetenek (entitlement) ya da yerel SDK eklenmeden önce, bir sonraki iOS build'in etkileşimli giriş isteyeceği ve mağaza politikasının (izinler, gizlilik etiketi, kütüphane hizalaması) değişeceği söylenir**.** [kanıtlı]
**Neden:** 1 Eki 2026'da eklenen bir yetenek yüzünden etkileşimsiz iOS build'i hata verdi ve bir build hakkı yedi. 4–5 Eki'de Play bir uygulamamızı 4 KB hizalı kütüphaneler ve reklam kimliği izni yüzünden reddetti.

**Nasıl kontrol edilir:** Yetenek ve izin farkı değişiklikte işaretlenir; Play için 16 KB hizalama kontrol edilir.

2.13

****Ücretli kapı kullanıcıyı bekletmez**: reklam belirli sürede açılmazsa kullanıcı yoluna devam eder. Her kapının nasıl bittiği kayıt altına alınır.** [kanıtlı]
**Neden:** PDF için ödüllü reklam ~115 istekte 0 gösterim aldı ve kayıt olmadığı için sebep ayrılamadı (6 Eki 2026). Yeni sürümde reklam 8 sn'de açılmazsa vazgeçiliyor ve PDF basışının 10 ayrı sonucu kaydediliyor.

**Nasıl kontrol edilir:** Yeni sürümden sonraki ilk hafta yönetim panelindeki sonuç tablosu okunur.

## 3. Web12 kural

3.1

****Yayındaki adres değişmez**. Değişmesi gerekiyorsa eski adres tek adımda 308 ile yenisine gider ve bu yönlendirme kalıcıdır: öteki dilin yazımı, büyük harf, eski yol, eski host kopyası, eski slug. Kaldırılan sayfa da 404 değil, en yakın sayfaya 308 olur.** [kanıtlı]
**Neden:** 23 Eyl 2026'da yasal sayfalar yeni siteye taşınınca eski adresler yönlendirildi; mağaza politika denetleyicisi bu sayfaları 6 günde 123 kez açtı. Emekli edilen bir ürünün sayfaları ana sayfaya 308 ile gidiyor. Bir başka projede kaydın slug'ı değişince eski slug bir tabloyla tanınmaya devam ediyor (3 Eki).

**Nasıl kontrol edilir:** Eski sitemap'teki ve bilinen eski adreslerdeki her URL curl ile 200 ya da tek adımlı 308 döner; zincir ve döngü yok.

3.2

****Dil ya da tercih pazarlığı yapan yönlendirme geçicidir (307) ve Vary taşır**.** [kanıtlı]
**Neden:** Bir projemizde dil öneki kalıcı yönlendirmeyle düşürülünce tarayıcı yönlendirmeyi kendi önbelleğinden cevapladı ve kullanıcının seçtiği dil kayboldu; 10 Eyl 2026'da geçiciye çevrildi.

**Nasıl kontrol edilir:** Kök ve dil yönlendirmelerinde durum 307, başlıkta 'Vary: Accept-Language, Cookie'.

3.3

****Canlı alan adı bağlantısı silinip yeniden kurulmaz**. Zorunluysa apex ve www sırayla taşınır, biri hep ayakta kalır. Alan adı değişikliği yalnız kalıcı yönlendirmeyle yapılır.** [ölçüldü]
**Neden:** 18 Eyl 2026 geçişinde ~20 dakika HTTPS kopukluğu oldu: ~5 dk eski sertifika, ~12 dk yeni sertifikanın çıkması, ~8 dk yayılma.

**Nasıl kontrol edilir:** Taşıma sırasında iki host için dakikada bir HTTPS denetimi yapılır.

3.4

****Kaldırmak yerine girişi kapat**. Emekli olan özelliğin yalnız kullanıcıya görünen girişleri kalkar; uç, tablo, yönetim ekranı ve eski bildirimleri karşılayan yönlendirme kalır. Dizindeki bir sayfadan içerik ya da bağlantı kalkacaksa ne kaybedildiği aynı anda söylenir. Aynı içerik iki alan adındaysa sayfa silinmez, canonical öteki siteye çevrilir.** [kanıtlı]
**Neden:** 23 Eyl 2026'da topluluk akışı bütün kullanıcı arayüzlerinden kalktı, arka ucu bilerek bırakıldı; eski uygulamalardaki bildirimler kırık ekrana düşmedi. Bir başka projede ana sayfadan kaldırılan bir blok mağaza sayfalarına giden iç bağlantıları da götürüyordu (29 Ağu kuralı). 6 Eki'de iki sitedeki aynı oran sayfasından biri ziyaretçi için kaldı, canonical öbürüne çevrildi.

**Nasıl kontrol edilir:** Kaldırma değişikliğinde 'kaybolan bağlantı ve metin' satırı bulunur; eski bildirim türleri eski build'de açılır.

3.5

****404 yalnız arka uç 'yok' dediğinde döner**. Arka uç cevap veremediyse hata fırlatılır (5xx); önbellekteki sağlam kopya kalır, arama motoru tekrar dener.** [kanıtlı]
**Neden:** Bir projemizde 18 ve 28 Eyl 2026'da, deploy'dan dakikalar sonra, kategori sayfaları önbellekten 404 döndü: başarısız okuma boş liste sayılmış, Next 404'ü bir saat önbelleğe almış, Google sayfayı gitmiş okumuştu. 6 Eki'de kurum sayfaları aynı kurala geçti.

**Nasıl kontrol edilir:** Yerelde arka uç kapalıyken sayfa 5xx döner, 404 dönmez. Haftalık zamanlanmış kontrol sitemap'teki adresleri tarar.

3.6

****Build arka uca, dış font sunucusuna ya da eksik olabilecek bir ortam değerine bağlı olmaz**. Bağlıysa ya sessizce boş içerik basar ya da deploy'u durdurur; ikisi de kullanıcıya bayat site demektir.** [kanıtlı]
**Neden:** 18–19 Eyl 2026'da yutulan bir okuma hatası site haritasını 12.589 sayfadan 9.921'e kesti, düzeltmesi build'i kırınca 16 saat hiçbir deploy çıkmadı. 29 Eyl–7 Eki arası 68 web build'inin 7'si dış font indirmesinde düştü. 18 Eyl'de eksik ortam değeri yüzünden yasal sayfalar kendi sitesine döngüye girdi. API okuyan ve önceden render edilen bir sayfa yedek içeriğini kalıcı olarak gösterdi.

**Nasıl kontrol edilir:** API okuyan sayfa ve sitemap çalışma anında render edilir; fontlar yerelden gelir; zorunlu değer eksikse build durur, yedek değer yok. Build arka uca erişimi olmayan bir ortamda yerelde denenir.

3.7

****Kişi yazdığını hemen görür**. Kullanıcının değiştirebildiği her şey ya önbelleksiz okunur ya da yazma anında o sayfanın önbelleği bütün adresleriyle düşürülür. Yazan her yol (betik, job ve yönetim paneli dahil) değişiklik işaretini aynı yazma kodundan günceller.** [kanıtlı]
**Neden:** Bir projemizde silinen yorum önbellek süresi dolana kadar mağaza sayfasında kaldı (23 Eyl 2026). Dizüstünden yapılan katalog değişiklikleri 6 saate kadar geç görünüyordu; ürün sahibi bunu 'çok kötü' buldu ve 4 Eki'de gecikme ~30 sn'ye indi. Başvuru sitesinde kampanya sayfaları 60–120 sn önbellekliydi; yanlışı ilk fark eden kampanyayı yayınlayan kişi olacaktı (17 Eyl).

**Nasıl kontrol edilir:** Yazdıktan sonraki ilk istekte yeni içerik görünür, ikinci istekte önbellek HIT. Her yazma yolu için bir test vardır.

**Yeni projede:** [öneri] Olay anında elle SQL yapıldıysa son adım işareti güncelleyen kayıtlı komuttur.

3.8

****Dil adresten okunur**. Dil çerezi yalnız kullanıcı seçince yazılır. Aynı alan adındaki yüzeyler dili aynı yerde tutar; giriş yapmış kullanıcının dili hesabına aittir. Dil değişince sunucunun o dilde yazdığı içerik yeniden istenir. Sayı biçimi de dile göre değişir (%3,63 ve 3.63%).** [kanıtlı]
**Neden:** Bir projemizde bilgi sitesi dili çerezde, portal tarayıcı deposunda tuttuğu için giriş ile ana sayfa arasında gidip gelen kullanıcının dili her dönüşte değişti (21 Eyl 2026). Bir başka projede her isteğe dil başlığı yazan proxy bütün sayfaları dinamik yaptı (12 Eyl); dil değişince sunucunun yazdığı cevap eski dilde kaldı ve 'çevrilmemiş' diye üç kez bildirildi (10 Eyl). Mobilde dil 19 Eyl'de hesaba bağlandı; güncellenen kurulum Türkçe kalır.

**Nasıl kontrol edilir:** Çerezsiz, çerezli ve İngilizce tarayıcıyla giriş ve ana sayfa arasında dört gidiş dönüş yapılır; her adımda dil aynı kalır.

3.9

****İçerik güvenlik politikası (CSP) önce report-only ve raporların yazıldığı bir uçla çıkar**. İzinli adresler build'in hedeflediği API'den türetilir, elle yazılmaz. Zorlamadan önce canlı veri gösteren her sayfa tipi açılıp ihlaller sayılır.** [kanıtlı]
**Neden:** 22–23 Eyl 2026'da doğrudan zorlanan politika API adresini görsel kaynağı saymadığı için kurum logoları bir gece kırık kaldı; test ortamında kurum kartı olmadığı için prova bunu göstermedi. Bir başka projede report-only bir gün çalıştı ve tek bulguyu, giriş düğmesinin stil dosyasını, yalnız biri konsolu açık tuttuğu için verdi; rapor ucu eklendikten sonra 29 Eyl'de zorlandı.

**Nasıl kontrol edilir:** Rapor ucunun logunda ihlal yoktur; canlı veriyle açılan sayfada konsolda 'violates' geçmez.

3.10

****Her sayfa üç genişlikte (1280, 900 ve 375 px) ve WebKit'te ölçülür**; göz kararı yetmez. Telefona özgü bir bildirim telefonda ya da gerçek Mobile Safari çalıştıran simülatörde yeniden üretilir.** [kanıtlı]
**Neden:** 23 Eyl 2026'da Safari'nin select ve tarih alanlarını farklı çizdiği formlar canlıya çıktı; bütün kontroller Chrome'daydı. Bir başka projede sonuç listesi geniş ekranlarda iki hafta bozuk kaldı, her kontrol telefon genişliğinde yapılmıştı (19 Eyl). Konum düğmesi beş kez bozuk bildirildi ve beş kez çalışır ölçüldü: hata yalnız izin diyaloğu açılan tarayıcıdaydı.

**Nasıl kontrol edilir:** Beş ölçü: başlığı tekrar eden üst etiket, başlıktan önceki boşluk, aynı satırdaki kartların son düğmesi ±2 px içinde, 375 px'te taşan öğe, iç içe kapsayıcı. Gerçek kart genişlikleri 320, 327 ve 344 px.

3.11

****Arayüz kullanıcıyı sessizce durdurmaz**. Henüz kullanılamayan düğme basılabilir kalır ve eksik olanı söyler; üstte açılan diyalog belgeye bağlanır, bir formun içinde açılmaz.** [kanıtlı]
**Neden:** Bir projemizde '.don' ile biten adres üç formda kabul edilmedi ama gönder düğmesi gri olduğu için açıklama hiç görünmedi, basmak hiçbir şey yapmadı (27 Eyl 2026). Form içinde açılan giriş diyaloğu sayfayı yeniden yükledi; o sayfadan e-postayla kimse giriş yapamadı (28 Eyl).

**Nasıl kontrol edilir:** Formlu her sayfada giriş ve gönderim uçtan uca denenir; diyaloglar belgenin köküne portal ile bağlanır.

3.12

****Ölçüm aracı onaydan önce hiçbir istek atmaz**; kabul ve ret eşit görünür; kişisel alanlar maskelenir; oturumlu, yönetim ve talep sayfalarında hiç yüklenmez; adresteki kişisel değerler silinir; test ortamında yüklenmez.** [öneri]
**Neden:** 1 Eki 2026'da üçüncü taraf analitik bekletildi, çünkü kullanıcılar serbest alanlara başka kişilerin adını, telefonunu ve kimlik numarasını yazıyor. 6 Eki'de oturum kaydı bu kurallarla yayına alındı, araç kimliği boş, açılmayı bekliyor.

**Nasıl kontrol edilir:** Onaydan önce ağ sekmesinde üçüncü taraf istek sayısı 0; portal ve talep sayfalarında betik yok.

## 4. Giriş ve oturum8 kural

4.1

****Altyapı hatası kimseyi oturumdan atmaz**. İstemci oturumu yalnız kesin 401'de siler; 503, ağ hatası, zaman aşımı ve ödeme sağlayıcısı hatası oturuma dokunmaz. Portal 'bağlantı kurulamadı, tekrar dene' kartını gösterir ve token'ı tutar.** [kanıtlı]
**Neden:** 2 Eki 2026'da 3.1.0'dan güncel sürüme kadar her uygulama sürümünün yalnız 401'de çıkış yaptığı kontrol edildi; bu sayede sunucuda 401 yerine 503 dönmek eski sürümleri de korudu. Bu kural olmasa uyuyan bir veritabanı herkesi bir anda dışarı atabilirdi.

**Nasıl kontrol edilir:** Test ortamında veritabanı kapatılır; uygulama ve portal açık kalır, oturum durur.

4.2

****Açılan sunucu uyuyan veritabanını bekler, ilk isteği düşürmez**. Uzun süren iş kendi yanıt süresini uzatır ki iş biterken istemci 503 görmesin.** [kanıtlı]
**Neden:** 6 Eyl 2026'da soğuk başlangıç uyuyan veritabanına denk gelip 503 verdi; soğuk başlangıçların ~%1–1,5'i böyleydi. Açılış artık ~30 sn ikiye katlanan aralarla bekliyor; sonraki 17 açılışta sorun çıkmadı, minimum instance 0'a indikten sonraki ilk gece 5xx 0 oldu (3 Eki). 10 sn yazma süresini aşan bir okuma işi bitti ama istemciye 503 döndü (18 Eyl).

**Nasıl kontrol edilir:** 'Açılışta veritabanına bağlanamadı' log alarmı kuruludur; uptime denetimi API'yi sıcak tutar.

4.3

****Oturum kuralı değişince var olan oturumlara dokunulmaz**; yeni kural sonraki girişlerde işler. Yüzeyini ya da sürümünü bildirmeyen eski istemci yeni kuralın dışında kalır. Kullanılan oturumun süresi kendiliğinden uzar.** [kanıtlı]
**Neden:** 20 Eyl 2026'da 'her yüzeyde tek oturum' kuralı yayına girerken hiçbir oturum kapanmadı; adsız istemciler tek kovaya konsaydı birbirlerinin cihazından atılacaklardı. Bir hesapta 14 canlı oturum vardı. Sabit 90 günlük süre, her gün kullanan birini yılda iki kez sebepsiz çıkış yaptırıyordu; artık 90 gün dokunulmayan oturum düşüyor.

**Nasıl kontrol edilir:** Deploy sonrası saatlik 401 ve yeni giriş sayısı önceki günle karşılaştırılır.

4.4

****Giriş kodu kurum posta geçidinde gecikse de çalışır**. Kod 30 dk geçerlidir; saatlik tavan kadar, yani en yeni 8 canlı kod kabul edilir; 'tekrar gönder' öncekini öldürmez, 60 sn geri sayım vardır, tekrar gönderirken yazılmış kod silinmez. Eski uygulamanın tek tekrar yolu da çalışmaya devam eder.** [öneri]
**Neden:** 2 Eki 2026'da yeni alan adından giden kodlar kurum geçitlerinde bekledi. Kod 10 dakikada ölüyor ve yeniden istemek öncekini geçersiz kılıyordu: geç gelen her e-postadaki kod 'hatalı ya da süresi dolmuş' oluyordu. Bugün en yeni 3 kod geçiyor; ilk kod gecikirken üç kez 'tekrar gönder'e basan kişinin ilk kodu geldiğinde yine reddedilir, sayı bu yüzden saatlik tavana çıkar. Eski sürümlerin tek yolu (adresi değiştir, gönder) artık ilk kodu canlı bırakıyor.

**Nasıl kontrol edilir:** Kurum adreslerine deneme kodu gönderilir; deploy sonrası doğrulama hatalarının oranı okunur.

4.5

****Sınırlar operatör NAT'ını ve kurum proxy'sini hesaba katar**. Adres başına (saatte 8) ve IP başına (saatte 40) kod sınırı veritabanında sayılır. İstemci IP'si X-Forwarded-For'un en sağ elemanından ya da yalnız doğrulanmış BFF'nin bildirdiği adresten okunur; web sunucusunun kendi adresi kimsenin IP'si değildir.** [kanıtlı]
**Neden:** Bir projemizde web'den gelen bütün istekler web sunucusunun adresinden göründüğü için 21 kodun hepsi tek IP hash'indeydi ve saatte 10 kod sınırı bütün site için tekti: on istek herkesi girişten kesebiliyordu (28 Eyl 2026). Operatör NAT'ında tek IPv4 adresinin arkasında 6 cihaz görüldü; bir kurumun genel müdürlüğü yüzlerce kişiyi tek adresten çıkarır.

**Nasıl kontrol edilir:** Logdaki farklı istemci IP sayısı okunur; kurum ağlarından gelen gerçek girişlerde 429 sayısı 0 kalır. Önde Cloudflare Worker varsa en sağ eleman Cloudflare'in adresidir; adresin yalnız kenar anahtarı eşleşen X-Client-IP'den okunduğu doğrulanır (tablo: [Kenar, DNS ve alan adı](#katman-5)).

4.6

****Kod isteği eşzamanlı isteklere karşı kilitlenir ki sınır gerçek sınır olsun**. 429 ve 503 Retry-After taşır; uygulama 429 için ayrı ve anlaşılır bir mesaj gösterir.** [öneri]
**Neden:** Sayacı okumak ile kodu yazmak arasında kilit yoksa paralel istekler aynı sayacı okur ve sınırı birlikte aşar. Uygulama 429'u ayrı mesajla gösterir.

**Nasıl kontrol edilir:** Paralel istek testi koşar; yanıt başlıklarında Retry-After görünür.

4.7

****Yönetim girişi ayrı bir uçtadır ve her adrese aynı cevabı verir**. Listede olmayan adrese hiçbir şey gönderilmez, o kişinin kendi kodlarına dokunulmaz.** [kanıtlı]
**Neden:** Bir projemizde herkese açık yönetim girişi olağan kod ucunu çağırıyordu ve adresi yazılan herkese gerçek bir kod gidiyordu; 23 Eyl 2026'da ayrıldı.

**Nasıl kontrol edilir:** Listede olmayan adresle istek 202 döner, gönderim kuyruğuna satır düşmez.

4.8

****Veri bir hesaba yalnız doğrulanmış adresle bağlanır**. E-postayla bırakılan bir talep, adres doğrulanmadan o adresin hesabına düşmez.** [kanıtlı]
**Neden:** 28 Eyl 2026'da başkasının adresiyle bırakılan bir talebin o kişinin hesabına düşebileceği bulundu ve aynı gün kapandı.

**Nasıl kontrol edilir:** Doğrulanmamış adresle talep bırakma testi koşar.

## 5. E-posta ve bildirim10 kural

5.1

****Alan adı ilk kullanıcıdan haftalar önce alınır**; SPF, DKIM, DMARC ve BIMI kurulur; güvenlik firmalarına (FortiGuard, Trend Micro, Talos, Broadcom) kategori başvurusu yapılır.** [kanıtlı]
**Neden:** 2 Eki 2026'da 38 günlük alan adının kod e-postaları dört kurumun posta geçidinde bekledi; sağlayıcının 'teslim edildi' demesi yalnız geçidin kabul ettiği anlamına geliyordu. Bir firma alan adını 'yeni kayıtlı, yüksek risk', bir başkası 'denenmemiş' sayıyordu; başvurular aynı akşam 'Finans' olarak döndü.

**Nasıl kontrol edilir:** Dört firmanın kategori sorgusu yapılır; kurum adreslerine deneme kodu gönderilir.

5.2

****Kod e-postası bağlantısız, uzak görselsiz ve gizli önizleme metni olmadan gider**; logo e-postanın içine gömülür; açılma ve tıklama takibi kapalıdır.** [kanıtlı]
**Neden:** Kuruma giden kod çoğu zaman o geçidin bizden gördüğü ilk e-posta; yeni bir alan adındaki bağlantı ve uzak görsel bekletme sebebi olabiliyor (2 Eki 2026).

**Nasıl kontrol edilir:** MIME testi gövdede bağlantı, uzak görsel ve gizli metin bulunmadığını kilitler; sağlayıcıdaki takip ayarı API'den okunur.

5.3

****Konu ve ilk satır kodu, onu adlandıran sözden hemen sonra verir ('… kodunuz: 482915'), ki telefon klavyesi kodu önerebilsin**.** [öneri]
**Neden:** 5 Eki 2026'da bir başka uygulamamızın kodu iPhone klavyesinde önerilirken bu ürününki önerilmiyordu; fark e-postanın kalıbıydı. İngilizce kalıp doğrulandı, Türkçe kalıp telefonda henüz doğrulanmadı.

**Nasıl kontrol edilir:** Gerçek bir iPhone'da e-posta uygulamasıyla denenir.

5.4

****Giriş kodu ile toplu e-posta aynı günlük kotayı paylaşıyorsa sayaç ortaktır ve UTC gününe göre sayılır**: günün toplamı 80'e varınca toplu gönderim durur, giriş kodları 100'e kadar gider, 70'te uyarı gelir. Kodlar ve bülten ayrı alt alan adlarından gider.** [ölçüldü]
**Neden:** Sağlayıcının ücretsiz planı günde 100 e-posta veriyor ve aşımda 429 döner. Toplu gönderim yalnız kendi sayısını 80'le sınırlarsa aynı gün gelen 21 kodla toplam 101 olur ve son kod gitmez; tavan bu yüzden günün toplamına konur.

**Nasıl kontrol edilir:** Günlük gönderim sayısı UTC gününe göre okunur; 70'te uyarı, 80'de toplu gönderimin durduğu test ortamında denenir.

5.5

****Toplu e-posta yalnız çift onaylı adreslere gider ve RFC 8058 List-Unsubscribe taşır**. Abonelikten çıkış bağlantısına yapılan GET hiçbir şeyi değiştirmez; değişiklik POST ile olur. Sonucu belirsiz gönderim 'beklemede' kalır.** [kanıtlı]
**Neden:** E-posta güvenlik tarayıcıları bağlantıları kullanıcıdan önce açıyor; Microsoft'un tarayıcısı 6–7 Eki 2026'da bültendeki bağlantıları kullanıcı ajanı olmadan düz GET ile açtı. GET ile çıkış, kişinin haberi olmadan abonelik iptali demek.

**Nasıl kontrol edilir:** Çıkış bağlantısına GET yalnız onay sayfasını döner; POST çıkışı yapar.

5.6

****Sıklık kullanıcının gününe göre seçilir**. Bülten haftada bir gün sabah gider; anlık bildirim gece çaldırmaz; aynı kaynaktan okunmamış bir bildirim varken yenisi gitmez; hak sahibi olmayan kullanıcıya olay başına değil, günlük tek özet gider.** [kanıtlı]
**Neden:** 26 Eyl 2026'da günlük 09:00 gönderimi reddedildi: hafta sonu abone olan kişi iki günde iki e-posta alacaktı; pazartesi 09:00 seçildi. 30 Eyl'de havuz bildirimleri 21:00–08:00 arası susturuldu, Premium olmayan kurumsal kullanıcılara talep başına push yerine hafta içi tek özet gönderilmeye başlandı.

**Nasıl kontrol edilir:** Gönderim saatleri İstanbul saatiyle logdan okunur; 21:00–08:00 arası push sayısı 0.

5.7

****Yeniden deneme yalnız iki kez çalışmaya dayanıklı işte açılır**; e-posta atan rapor ve özet işlerinde açılmaz.** [kanıtlı]
**Neden:** 23 Eyl 2026'da 11,9 sn süren rapor e-postayı gönderdi ama zamanlayıcıya 503 döndü; yeniden deneme açık olsaydı çift e-posta gidecekti. 2 Eki'de yeniden deneme yalnız dört idempotent işte açıldı.

**Nasıl kontrol edilir:** Her zamanlanmış işin (iş, dönem) idempotency anahtarı ve yeniden deneme ayarı listelenir.

5.8

****Push yükünde içerik yoktur**: yorum metni, e-posta ve hassas veri konmaz. Güncelleme bildirimi yalnız eski build'lere gider. E-posta gönderim hatası girişi ya da satın almayı bozmaz.** [kanıtlı]
**Neden:** Depodaki değiştirilemez ürün kuralları: hoş geldin e-postasının hatası giriş sonucunu değiştirmez, e-postalar tekilleştirme anahtarıyla bir kez gider. 19 Eyl 2026'dan beri güncelleme bildirimi yayındaki build'i çalıştıran cihaza gitmiyor.

**Nasıl kontrol edilir:** Push yükü ve outbox tekilleştirmesi testle kilitli.

5.9

****Test ortamının bütün e-postaları tek bir izin listesine gider**; test hiçbir gerçek kişiye ulaşmaz. Prod verisi test ortamına kopyalanmaz.** [kanıtlı]
**Neden:** 26 Eyl 2026'dan beri test ortamının e-postaları tek listeye gidiyor; test ortamı kurulurken gerçek adres taşıyan veri oraya girerse provalar gerçek kişilere kod gönderebilirdi.

**Nasıl kontrol edilir:** Test ortamının e-posta ayarında izin listesi doludur; config bu liste olmadan açılmaz.

5.10

****Kullanıcıdan izin ve puan sınırlı istenir**: sistem bildirim izni bir kez, mağaza puan isteği kurulum başına en çok iki kez ve ilk gün değil.** [kanıtlı]
**Neden:** Mağazalar değerlendirmenin yazıldığını söylemiyor; yazana bir daha sormamanın tek yolu herkese iki denemeden sonra susmak. Bildirim izni cevapsız kalsa da sonraki açılışlarda tekrar çıkmıyor (19 Eyl 2026'dan beri).

**Nasıl kontrol edilir:** Sayaçlar cihaz deposunda testle kilitli.

## 6. Botlar ve sınırlar6 kural

6.1

****Her yeni bot ya da hız kuralı önce gölgede çalışır**: reddetmez, 'reddederdim' satırı yazar. Zorlama en az 7 günlük temiz logla, kurumsal kullanıcılı üründe 14 günle verilir. Kural testi gerçek Next sunucusundan geçen istekle yapılır.** [kanıtlı]
**Neden:** 6–7 Eki 2026'da gölgesiz açılan boş ajan kuralı ilk gün bir e-posta bağlantı tarayıcısına 403 verdi. Gölgedeki hız kuralı Next'in önyüklemelerini sayfa sandı: tek bir adresten gelen 400 önyükleme 92 yanlış 'reddederdim' satırı yazdı; zorlansaydı insanları kesecekti. Birim testleri başlıkları kendisi kurduğu için geçiyordu.

**Nasıl kontrol edilir:** 'Reddederdim' satırları her gün gruplanır; aynı adresten JavaScript kanıtı gelen her satır yanlış pozitiftir ve kural aynı gün düzeltilir.

6.2

****Hiçbir kural şunları reddetmez**: mobil uygulamanın konuştuğu API, oturum ve portal, paylaşım ve talep bağlantıları, formlar, yasal sayfalar, robots.txt, sitemap, llms.txt, /.well-known, mağaza denetleyicileri, e-posta ve güvenlik firmalarının bağlantı tarayıcıları, bağlantı önizleyicileri. API alan adı hiçbir zaman challenge sayfası gösteren bir katmanın arkasına konmaz.** [kanıtlı]
**Neden:** Mağaza politika denetleyicisi yasal sayfaları 6 günde 123 kez açtı. Müşteriye gönderilen bağlantıyı önce önizleyici açıyor. 517.285 istekte engelli bulut aralıklarından tek uygulama isteği gelmedi, ama toplu bir VPN dalgası bunu bir günde değiştirebilir.

**Nasıl kontrol edilir:** Bu yollarda 403 ve 429 sayısı her gün 0; API'nin 429 sayısı kapıdan sonra değişmez.

6.3

****Bütün bir bulut ağını (ASN) reddetmek yalnız içerik sayfalarında yapılır**. Ağ listesinden kiralanmış ve başka şirketlerin kendi rotasıyla duyurduğu bloklar çıkarılır; liste ayda bir yenilenir.** [kanıtlı]
**Neden:** 7 Eki 2026'da iki büyük bulutun öneklerinde başka şirketlerin kullandığı alanlar çıktı; üç ASN'den 9 blok listeden kesildi. Bu bulutlar bilgi sitesinde yalnız gölgede tutuldu: VPN arkasındaki bir kurumsal kullanıcıyı reddetmek hiçbir zaman değmez.

**Nasıl kontrol edilir:** Yenileme betiği her önek için rota kökenini sorar; 45 günden eski liste uyarı satırı yazar.

6.4

****Adres başına hız sınırı yüksek tutulur ve yalnız tek adresten gelen seli durdurmak için kullanılır**.** [ölçüldü]
**Neden:** Tek IPv4 arkasında 6 cihaz görüldü. En yoğun gerçek adres 10 saniyede 24, günde 129 sayfa açtı; varsayılan sınır her pencerede bunun en az 5 katı. Dağıtık kazıyıcılar adres başına 1–3 istek attığı için insanlara güvenli hiçbir adres sınırı onları görmüyor.

**Nasıl kontrol edilir:** Gerçek kullanıcı ajanlı ve JavaScript kanıtlı adreslerde 429 sayısı 0.

6.5

****Ziyaretçi getiren arama, önizleme ve AI tarayıcıları açık kalır**. Bot kimliği kullanıcı ajanından değil yayıncının adres aralığından doğrulanır. robots.txt ve kapı aynı ad listesinden üretilir.** [kanıtlı]
**Neden:** Bir sitede robots.txt herkese izin verirken kapı 13 adı reddediyordu ve listedeki kısaltılmış adlar gerçek ajanları yakalamıyordu. ChatGPT-User iddialarının 35'inden 2'si gerçekti. 7 Eki 2026'da her arama, AI ve önizleme tarayıcısının geçtiği sentetik tarama ve 30 günlük log tekrarıyla doğrulandı.

**Nasıl kontrol edilir:** Search Console tarama istatistiğinde host durumu (429, 5xx) kapıdan sonra yükselmez; listedeki her ad logdaki gerçek ajan dizesiyle sınanır.

6.6

****Kapı hata verirse isteği geçirir**. Reddedilen gerçek kişinin bir çıkışı vardır: yeniden dene bağlantısı, iletişim adresi ve ret sayfasının bir işaret pikseli.** [kanıtlı]
**Neden:** Kapıdaki bir hatanın bedeli en fazla bir botun geçmesi olmalı, bir kullanıcının kesilmesi değil. İşaret satırı reddedilmiş gerçek bir tarayıcıyı loglarda görünür kılıyor.

**Nasıl kontrol edilir:** 'Görüldü' satırları ağ etiketi ve son bir dakikada vuran kuralla birlikte okunur.

## 7. Yayın disiplini11 kural

7.1

****Önce test, sonra main**. main yalnız test'te görülmüş commit'e fast-forward edilir; iki dal her zaman eşittir.** [kanıtlı]
**Neden:** 26 Eyl 2026'da günün son düzeltmeleri test'i atlayıp üç depoda doğrudan main'e gitti ve test geride kaldı.

**Nasıl kontrol edilir:** test ve main aynı commit'i gösterir; eşit değilse bu tek satırla söylenir ve ancak ürün sahibinin sözüyle düzeltilir.

7.2

****Deploy, build, mağaza gönderimi ve sürüm numarası ürün sahibinin kararıdır ve depodaki ajan dosyalarında (CLAUDE.md, AGENTS.md) yazılıdır**. Sıra her zaman aynıdır: kod biter, commit, tek satırlık rapor, karar beklenir.** [kanıtlı]
**Neden:** 20 Eyl 2026'da istenmeden iki prod build başlatıldı ve sürüm sorulmadan 4.0.1'den 4.1.0'a çıkarıldı; 4.0.2 olmalıydı. Hafızadaki bir not başka araçlarca görülmediği için kural depoya yazıldı.

**Nasıl kontrol edilir:** Her depoda ajan dosyası vardır; main tetikleyicisinde onay kapısı önerilir.

7.3

****Commit'ler birikir, iş bitince tek deploy yapılır**. Canlı kırık bunun istisnasıdır: sebep, düzeltme, canlı veriyle doğrulama, commit, ve ilk satırda tek cümleyle onay isteği; araya başka iş girmez.** [kanıtlı]
**Neden:** 22 Eyl 2026'da aynı oturumda site üç kez deploy edildi; her biri bir build, yeni revizyon, soğuk önbellek ve arama motoru bildirimi demekti. 23 Eyl'de kırık logoların düzeltmesi hazırken onay isteği uzun bir raporun içinde kaldı; onay gelince logolar 6 dakikada canlıdaydı.

**Nasıl kontrol edilir:** Deploy sayısı oturum başına bir; canlı kırık raporunun ilk satırı onay sorusudur.

7.4

****İncelenen iş onaylanmadan commit'lenmez**; sorulan soru önce cevaplanır.** [kanıtlı]
**Neden:** 26 Eyl 2026'da bir tasarım ürün sahibi hâlâ inceleyip soru sorarken iki kez commit'lendi ve geri alındı.

**Nasıl kontrol edilir:** İnceleme sürerken değişiklikler commit'siz durur.

7.5

****Yeni yüzey sunucu anahtarı arkasında, varsayılan kapalı gider**. Açma, kapama ve geri dönüş yeni build istemez; bizde ortam değişkeniyle yapıldı. Anahtar, onu okuyan web build'inden önce açılır ki önbellek kapalı hali saklamasın.** [kanıtlı]
**Neden:** 30 Eyl 2026'da kullanıcı denemesinde kötü bulunan AI asistan tek bir env değişikliğiyle dakikalar içinde kapandı. Sesli komut, haftalık e-posta, yeni değer tablosu ve havuzun yeni akışı kapalı çıktı ve ayrı günlerde açıldı. 28 Eyl'de anahtar web build'inden önce açıldığı için sayfalar ilk istekte doğru çizildi. Bedeli: her env değişikliği canlıda yeni revizyon ve canlıya yetkili bir insan istedi; 19 Eyl–8 Eki 2026'da güncelleme politikası ve bayrak için en az 14 elle revizyon açıldı.

**Nasıl kontrol edilir:** update-policy çıktısında anahtarlar okunur; anahtar test servisinde açık, prod'da kapalıyken prova yapılır.

**Yeni projede:** [öneri] Anahtar admin'deki bayrak tablosunda durur ve yeni revizyon istemez. Ortam değişkeni yalnız acil kapatma yedeğidir; tablodaki açık değeri kapatabilir, kapalı değeri açamaz. Ayrıntısı [Analitik ve admin](#analitik) bölümünde ve [Mobil uzaktan kontrol kitinin](#mobilkit) 6. parçasında.

7.6

****Veri taşıyan bir değişiklikten sonra geri dönüş eski revizyona değil anahtara yapılır**. Her değişikliğin notunda geri dönüşte ne olacağı yazılır.** [kanıtlı]
**Neden:** Talep havuzunun yeni akışı açıldıktan sonra eski API kodu yeni akışın taleplerini süzmeden telefon numarasını gösterecekti; geri dönüş yalnız anahtarı kapatmak olarak yazıldı (5 Eki 2026). Bir başka projede not: 'bu sürümden geri dönülürse eski kod park edilen dosyaları eklemez, dosyalar kaybolmaz' (2 Eki).

**Nasıl kontrol edilir:** CHANGELOG girişinde geri dönüş satırı bulunur; anahtarla kapatma test ortamında denenir.

7.7

****Geri dönüş penceresi gerçek imaj listesinden hesaplanır**. İmaj temizliği geri dönülecek imajı ve job'ların sabitlediği imajları silmez; migration job'ı her sürümde serving imaja çevrilir.** [kanıtlı]
**Neden:** 'En yeni 5 imajı tut' kuralı sık deploy eden serviste 1–2 günlük pencere demek. 24 Eyl 2026'da bir geri dönüş revizyonunun imajı bir gün içinde silindi; geri dönüşün tek yolu revert ve yeniden build oldu. Elle sabitlenmiş migration job'ı 21 Eyl ve 7 Eki'de silinmiş imaja bakıyordu.

**Nasıl kontrol edilir:** Deploy sonrası önceki revizyonun imajı depoda var mı bakılır; job imajı serving imajla eşittir. Canlı ve önceki imaj her deploy'da taşınan `live` ve `prev` etiketleriyle süresiz, deploy edilen imaj `deployed-*` etiketiyle 30 gün tutulur.

7.8

****Deploy komutu ortamı ekler, silmez**: --update-env-vars kullanılır, --set-env-vars kullanılmaz. Düz bir değişkeni sır referansına çevirmek tek komutta yapılır.** [kanıtlı]
**Neden:** Bir sitenin build tanımı --set kullanıyordu ve her deploy elle konmuş değişkenleri siliyordu (6 Eki 2026'da düzeldi). Düz değişkeni sırra çevirirken komut ikiye bölünürse arada değerlerin boş olduğu bir revizyon doğuyor (22 Eyl).

**Nasıl kontrol edilir:** Deploy sonrası servis tanımındaki ortam listesi önceki revizyonla karşılaştırılır.

7.9

****'Deploy çıktı' demeden önce o commit için build'in başarıyla bittiği görülür**. Kırık build dışarıdan görünmez: site eski imajda kalır, yeni iş 'hâlâ bozuk' sanılır.** [kanıtlı]
**Neden:** Bir projemizde 18–19 Eyl 2026'da altı build üst üste düştü ve dört bitmiş iş 'hâlâ bozuk' diye bildirildi. 22 Eyl'de 1.000 yeşil test, portalın derlenmeyen bir dosyasını yakalamadı. 21 Eyl'de üç depodan birinin tetikleyicisi yoktu ve push hiçbir şey yapmadı.

**Nasıl kontrol edilir:** Build listesinde commit'in kısa SHA'sı SUCCESS görünür; Dockerfile'ın koştuğu build yerelde de koşar; başarısız build bildirimi açıktır.

7.10

****Testler, simülatör ve denemeler canlıya dokunmaz**; yerel varsayılan hiçbir zaman prod değildir. Herkese açık rakamlar gerçek kullanıcıyı anlatır.** [kanıtlı]
**Neden:** Bir portal testi 17–28 Eyl 2026 arası prod'a 44 sahte hesaplama yazdı ve bunlar herkese açık 'popüler hesaplamalar' listesinde göründü. Simülatör 24 ve 26 Eyl'de prod'a analitik yazdı.

**Nasıl kontrol edilir:** Testlerde ağ kapalı; prod'a dokunan komutun adında 'prod' geçer; simülatörün hedef API'si çalışma anında, test servisinin logunda doğrulanır.

7.11

****Yeni okuma yolu önce gölgede çalışır**: eski yolla aynı cevabı verip vermediğini loga yazar. Fark bir gün boyunca 0 olunca açılır.** [kanıtlı]
**Neden:** 2 Eki 2026'da gölge mod, açılmadan önce bir sıralama farkını yakaladı; düzeltilip ertesi gün fark 0 görülünce açıldı ve veritabanı tüketimi günde 6,5'ten 1,3 CU-saate indi.

**Nasıl kontrol edilir:** Fark logu açılıştan önceki 24 saatte 0.

## 8. Hiçbir şeyin kırılmadığını ölçmek7 kural

8.1

****Her deploy'dan hemen sonra**: build başarılı, yeni revizyon trafikte, sağlık ucu 200, ilk 30 dakikada 5xx 0, saatlik 401 sayısı önceki saatle aynı, update-policy beklenen anahtarları dönüyor, web'de arama motoru bildirimi 200, değişen sayfa canlı veriyle açılıyor ve konsolda CSP ihlali yok.** [kanıtlı]
**Neden:** 7 Eki 2026'da bir API sürümü bu kontrollerle 0 adet 5xx ile doğrulandı. 23 Eyl'deki CSP kırığı canlı verisi olmayan test ortamında görünmemişti.

**Nasıl kontrol edilir:** Bu liste deploy raporunun son satırıdır.

8.2

****Ertesi sabah tek seferlik bir kontrol çalışır**: zamanlanmış işler 2xx, gece 5xx ve bellek taşması 0, ERROR satırları, veritabanının saatlik tüketimi, gölge fark logu, kapı satırları. Gözetimsiz kontrol bulutta çalışır.** [kanıtlı]
**Neden:** Minimum instance 0'a indikten sonraki ilk gece böyle bir kontrolle temiz bulundu (3 Eki 2026). Bir projede zamanlanmış haftalık kontrol, deploy'dan dakikalar sonra önbellekteki 404'ü kendiliğinden yakaladı. Yerelde kurulan iki tek seferlik kontrol izin beklerken takıldı.

**Nasıl kontrol edilir:** Kontrolün sonucu ertesi gün okunur; çalışmadıysa elle yapılır.

8.3

****Sessiz hata yoktur**. Başarısız iş 2xx dönmez; her 5xx sebebiyle ve severity alanıyla loglanır; az trafikli kritik uçta tek 5xx alarm üretir. Loglanmamış bir 500 tahmin edilmez: önce log satırı eklenir, deploy edilir, sonraki olay okunur.** [kanıtlı]
**Neden:** Ödeme webhook'u 21 gün log yazmadan 500 döndü. Dış bir siteyi okuyan günlük iş beş gün boyunca her sabah düştü ama 204 döndü. 14 günde 18 ERROR satırının severity alanı boştu.

**Nasıl kontrol edilir:** Log tabanlı alarm ERROR > 0; webhook yolunda tek 5xx alarmı.

8.4

****Alarmlar ilk kullanıcıdan önce kurulur ve konusu '[TEST]' olan sahte bir hatayla uçtan uca denenir**; durum izleme API'sinden okunur. En az: uptime (300 sn, 3 bölge), servis başına 5 dakikada 3'ten fazla 5xx, açılışta veritabanı yok, zamanlanmış iş hatası, yedek hatası, bellek taşması, build hatası.** [kanıtlı]
**Neden:** 23 Eyl 2026 denemesinde hata 16:57'de üretildi, alarm 17:01'de açıldı, 17:11'de kapandı. 2 Eki'de alarmsız bir serviste tek günde 192 bellek taşması bir maliyet analizinde tesadüfen bulundu.

**Nasıl kontrol edilir:** Her yeni projede alarm listesi ve son deneme tarihi yazılıdır.

8.5

****Kullanıcı davranışına dokunan deneme yeni build harcamadan, uzak bir anahtarla ve kullanıcıların yarısında yapılır**; iki hafta izlenir. Kontrol grubu olmadan sebep söylenmez.** [öneri]
**Neden:** Eylül 2026'da iOS'ta reklam geliri bir sürümle aynı haftalarda düştü ama kontrol grubu olmadığı için sebep kanıtlanamadı. 6 Eki'de alt banner denemesi için ayrı build alınmadı; anahtar bir sonraki sürüme eklenecek.

**Nasıl kontrol edilir:** Deneme anahtarı update-policy'de; iki grubun rakamları aynı pencerede okunur.

8.6

****Arama tarafındaki etki 2–4 hafta izlenir ve logdan sayılırken önce kendi adreslerimiz, bulut aralıkları ve önyüklemeler çıkarılır**.** [ölçüldü]
**Neden:** 30 Eyl 2026 ölçümünde 'Google'dan gelen' ~120 girişin ~105'i Chrome gibi görünen bir bulut kazıyıcısıydı. 6 Eki'de AI asistanından gelen oturumlardaki '12–24 sayfa' Next önyüklemesi çıktı; gerçek ziyaretçilerin hiçbiri ikinci sayfaya geçmemişti.

**Nasıl kontrol edilir:** Search Console'da host durumu ve dizin; yönlendirilen adreslerin dizin durumu; aynı sayım 2–4 hafta sonra tekrarlanır.

8.7

****Kullanıcı bir sorun bildirdiğinde yalnız bildirilen şey ölçülmez**; aynı sınıftaki her şey ve aynı sayfanın tamamı taranır. Kontrol önce eski canlı sayfada kanıtlanır ki temiz sonuç bir şey anlatsın.** [kanıtlı]
**Neden:** 24 Eyl 2026'da bildirilen tek başlık düzeltilirken kullanıcı aynı sayfada üç sorun daha buldu. Bir başka projede bir hata bildiriminde geçen iki firma, aynı sınıfta on yedi kayıt çıktı.

**Nasıl kontrol edilir:** Raporda taramanın bulduğu ve kullanıcının önce bulduğu ayrı ayrı yazılır.

## Değişiklikten sonra izleme takvimi

[Kural 8.1](#k-8-1) ve [8.2](#k-8-2)'deki kontroller, zamana yayılmış hali.

| Ne zaman | Ne okunur | Nerede |
|---|---|---|
| İlk 30 dakika | Build başarılı, revizyon trafikte, sağlık 200, 5xx 0, 401 sayısı önceki saatle aynı, update-policy anahtarları, arama motoru bildirimi 200, canlı veriyle açılan sayfada CSP ihlali yok. | Build listesi, servis tanımı, Cloud Run istek kaydı, tarayıcı konsolu. |
| Ertesi sabah | Zamanlanmış işler 2xx, gece 5xx ve bellek taşması 0, ERROR satırları, veritabanı saatlik tüketimi ve uyanma satırları, gölge fark logu. | Uygulama logu (severity), job ve zamanlayıcı geçmişi, veritabanı sağlayıcısının saatlik tüketimi. |
| İlk 7 gün, her gün | Kapının ret ve 'reddederdim' satırları; portal, form ve yasal sayfalarda 403/429 sayısı 0; 7 günlük sürüm dağılımı; yeni kapının sonuç tablosu; CSP rapor ucu. | Kapı log satırları, ödeme sağlayıcısının sürüm süzgeci, yönetim paneli. |
| 14 gün | Kurumsal kullanıcılı üründe bir bot kuralını zorlamadan önce temiz gölge logu. | Kapı log satırları. |
| 2–4 hafta | Search Console host durumu ve dizin, yönlendirilen adreslerin dizin durumu, AI tarayıcı sayıları. | Search Console, Bing Webmaster Tools, istek kaydı. |
| Her ay | Güncelleme uyarısının hedefi mağazayla eşit mi, depoda geri dönüş imajı var mı, alarmlar son ne zaman denendi, kapı ağ listesi yenilendi mi. | Mağaza sayfaları, imaj deposu, izleme API'si. |

## Denenebilecekler

Bizde henüz denenmemiş kurallar; numara yukarıdaki kurala gider. OTA burada değil, [kural 2.10](#k-2-10)'da öneri olarak duruyor.

| Deneme | Beklenen etki | Risk ve not |
|---|---|---|
| Manuel yayın[kural 2.8](#k-2-8) | Mağaza onayı ile yayın ayrılır; API'ye bağlı sürüm API ile aynı gün, mesai başında açılır. | Yayın elle yapılır. App Store'da Manually release, Play'de Managed publishing gönderim anında seçilir. |
| Kademeli yayın[kural 2.9](#k-2-9) | Hatalı bir build ilk gün herkese değil, kullanıcıların bir kısmına ulaşır ve yayın durdurulabilir. | App Store'da aşamalı yayın 7 gün sürer. İlk gün sürüm başına istek ve hata oranı okunur, durdurma adımı önceden bilinir. |
| Uzak anahtarla deneme[kural 8.5](#k-8-5) | Reklam ya da akış değişikliğinin etkisi kontrol grubuyla ayrılır; yeni build gerekmez. | Anahtar bir sonraki mağaza sürümüne eklenmeli; iki grup iki hafta aynı pencerede izlenir. |
| Kodu klavyeye önerdirmek[kural 5.3](#k-5-3) | Telefon klavyesi e-postadaki kodu önerir, kullanıcı kodu yazmaz. | İngilizce kalıp doğrulandı; Türkçe kalıp gerçek bir iPhone'da henüz denenmedi. |

<a id="hafiza"></a>

Kurallar

# Proje hafızası ve devir

Projenin hafızası depoda durur: ne oldu, şu an ne durumda, sırada ne var, hangi karar neden verildi. Yeni gelen geliştirici ya da yapay zekâ ajanı ilk saatte projeyi tanıyıp devam edebilmeli. Dört ürünün 14 deposunda 820 CHANGELOG başlığının yalnız 11'inde tarih vardı; en büyük ajan hafıza klasöründeki 74 notun 28'i bir karar taşıyordu.

**Kural:** Hafıza dosyaları ilk commit'te açılır, her işle güncellenir.

Ajan gün 0'da, altyapıdan önce bu dosyaları oluşturur: AGENTS.md (CLAUDE.md'de yalnız `@AGENTS.md`), CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md, docs/runbooks/ ve docs/handoff/. Sonra her commit, deploy ve ürün sahibi kararında ilgili dosyayı aynı commit'te günceller. Kural ve karar depoya yazılır. Ajanın kendi notları (Claude Code'un auto memory'si) yalnız o makinedeki o aracın oturumlarında görünür.

## Hangi dosya hangi soruyu cevaplar

Dosya adları geleneksel İngilizce, içerik Türkçe; Türkçe karşılık adın altında. CLAUDE.md'de yalnız `@AGENTS.md` satırı durur, böylece Codex de Claude Code da aynı dosyayı okur. Sahip oturum, bir depoda main'e alma işini yapan tek ajan oturumudur; adı STATUS'ta yazılır.

_Grafik: Hangi dosya hangi soruyu cevaplar. Nasıl kurulur: README.md (kurulum ve yerel çalıştırma); okuyan: geliştirici ilk saatte. Nasıl çalışılır: AGENTS.md (ajan talimat dosyası, çalışma kuralları); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte. Şu an ne durumda: docs/STATUS.md (durum: canlı sürümler, bayraklar, sahip oturum); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Ne oldu: CHANGELOG.md (değişiklik günlüğü, en yeni üstte); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte. Neden böyle: docs/DECISIONS.md (kararlar, seçenekleri ve nedenleri); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Sırada ne var: docs/TODO.md (yapılacaklar ve karar bekleyenler); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Nerede kaldık: docs/handoff/ (devir notları, gün ya da oturum sonu); okuyan: ajan ilk 5 dakikada, ürün sahibi düzenli. Nasıl kurtarılır: docs/runbooks/ (işletme ve kurtarma adımları: deploy, geri dönüş); okuyan: ajan gerektiğinde, geliştirici gerektiğinde._

## Bizde ölçtüklerimiz

8 Ekim 2026 taraması: 14 deponun origin/main dalı (A beş, B üç, C dört, D iki), ajan hafıza klasörleri ve 20 Ağustos–8 Ekim oturum kayıtları. CHANGELOG 10 depoda var (biri boş), ajan talimat dosyası 9 depoda.

**11 / 820** CHANGELOG başlığından tarih taşıyanlar (A'nın beş, B'nin iki günlüğü). Ne zaman çıktığını yalnız git geçmişi söylüyordu.
**36 / 61** a-mobil'de yayında olduğu halde hâlâ 'Unreleased' duran başlık. a-api'de 114'ün 24'ü.
**12 / 15** Paralel dallar birleşirken çıkan çakışmalardan CHANGELOG'u içerenler.
**28 / 74** En büyük ajan hafıza klasöründeki notlardan karar içerenler. Bu kararları yalnız o makinedeki o araç görüyordu.
**4 / 45** Aynı klasörün notlarında geçen ve artık var olmayan dosya yolu. 74 notun 15'i 14 günden eski.
**67 kez** Tek bir oturumun 49 günde sıkıştırılma (compact) sayısı. Her sıkıştırmada araç sohbeti özetler; depoya yazılmamış ayrıntının bir kısmı gider.

## CHANGELOG boyutu

En büyük dördü son 30 günde günde 2–9 KB büyüdü. b-web'in tamamı 200 bin token'lık bağlamın yarısına yakın.

40 KB üstü40 KB altıKB, ölçek gerçek
_Grafik: CHANGELOG boyutları, KB, sınır 40: b-web 338,8; b-api 308,3; a-mobil 160,3; a-api 158,5; a-web 86,5; a-portal 68,2; c-web (ortak günlük) 58,2; a-pazar 57,1; c-api 17,6; b-mobil 0,3_

## Aynı commit'te CHANGELOG'a yazma oranı

8 Eylül–8 Ekim, kod değiştiren commit'ler, commit başına. C'de günlük deploy'dan sonra ayrı commit'te.

Kural ajan dosyasında yazılıYazılı değilGünlük ayrı commit'tekod commit'i, %; ölçek gerçek
_Grafik: Aynı commit'te CHANGELOG oranı. Kural yazılı: b-web %84, b-api %80, a-api %72. Yazılı değil: a-portal %52, a-mobil %51, a-pazar %36, a-web %33. Ürün C, 4 depo: %1–12._

## Bizde ne oldu

Kırmızı kenar bozulanı, koyu turkuaz kenar işleyeni anlatır; tarihler 2026. 4 ve 8 Ekim olayları [Vakalar](#vakalar) bölümünde ayrıntılı.

23 Eylül ile 8 Ekim arası

### Paralel dallarda CHANGELOG çakıştı

Her dal girdisini dosyanın tepesine, aynı satıra ekledi. 15 birleştirme çakışmasının 12'sinde CHANGELOG vardı.

**Bedel** 29 Eylül'de altı birleştirme ~8 dakika. Risk: sıra karışır.

**Kural** [öneri] Girdi dal başına parça dosyaya yazılır, main'e alırken birleştirilir.

3, 5 ve 7 Ekim

### Aynı depoda iki oturum main'e aldı, push reddedildi

İki oturum aynı depoda main'e alabiliyordu. Push reddedildi; bir dal 20 dakikada iki kez yeniden alındı.

**Bedel** Her seferinde rebase ve testler yeniden. Bozuk deploy olmadı.

**Kural** [kanıtlı] Bir depoda tek sahip oturum; diğerleri kendi dalında çalışır.

8 Ekim

### İstenmeden gönderilen raporlar iki oturumun işini kesti

Bir araştırma oturumu bulduklarını iki ürün oturumuna 'şunu yapın' diye gönderdi. Ürün sahibi o oturumları durdurdu.

**Bedel** İki oturumun akışı kesildi, ürün sahibi araya girmek zorunda kaldı. Süre ölçülmedi.

**Kural** [kanıtlı] Oturumlar arası mesaj yalnız ürün sahibi 'ilet' derse gider.

4 Ekim

### Doğru oturuma giden raporla hata 9 dakikada düzeldi

A'da çalışan oturum, B'nin canlısında konumun dakikada 20 ile 70 kez gönderilip 429 aldığını buldu. Ürün sahibinin talimatıyla rapor B'nin sahip oturumuna gitti: saatler, istek sayıları, kodda yer, öneri.

**Bedel** Rapor 18:45'te gitti, düzeltme 18:54'te canlıdaydı. Raporu yazan oturum koda dokunmadı.

**Kural** [kanıtlı] Başka ürünün sorunu kanıtla rapor edilir, düzeltmeyi o ürünün sahip oturumu yapar.

8 Ekim

### Elektrik kesintisi /tmp'yi sildi

Bilgisayar yeniden başlayınca /private/tmp boşaldı: yardımcı betikler, b-api'nin dört worktree'si, deneme veritabanı, bu rehberin çalışma dosyaları.

**Bedel** Commit'siz ajan işi gitti, büyüklüğü ölçülmedi. Rehber dosyaları iş akışı günlüklerinden birkaç dakikada geri alındı.

**Kural** [kanıtlı] Bir saatten uzun yaşayacak iş git'te ya da kalıcı klasörde durur.

21 Eylül

### Kardeş deponun ajan dosyası okunmadı

Oturum a-portal'da açılmıştı. Ajan a-pazar'ın main'ine push edip deploy bekledi; o depoda tetikleyici yoktu ve CLAUDE.md'si bunu söylüyordu, ama yüklenmemişti.

**Bedel** Yaklaşık 2 dakika, build izlenirken fark edildi. Fark edilmeseydi canlıda eski sürüm kalacaktı.

**Kural** [kanıtlı] Bir ürünün depoları aynı deploy davranışına sahip olur; yalnız .md değişen commit build almaz.

1 Ekim

### Hafıza notu 'açık' diyordu, canlıda kapalıydı

Not bir özelliğin 30 Eylül'de canlıda açıldığını yazıyordu; çalışan revizyonda bayrak kapalıydı. Ortam değişkeni başka bir yerden değiştirilmişti.

**Bedel** Ramak kala: bir belgeye 'canlıda' diye yazılacaktı.

**Kural** [kanıtlı] 'Canlıda' demeden çalışan revizyonun ortam değişkeni ve herkese açık uç okunur.

8 Ekim ölçümü

### Belgeler ve hafıza sessizce bayatladı

a-api'nin ajan dosyası 16 iç paketin 6'sını sayıyor ve 'gerçek durum' için 16 Eylül'den beri değişmeyen bir yol haritasını gösteriyor. a-mobil'in TODO.md'si üç sürüm geride.

**Bedel** Ölçülmedi. Risk: ajanın eski bilgiyle karar vermesi. Henüz sistemli düzeltme yok.

**Kural** [öneri] Her yaşayan belgenin tepesinde 'son doğrulama' tarihi; ayda bir tazelik turu.

27 Eylül ile 8 Ekim arası

### Ajan notları oturumun açıldığı klasöre yazıldı

C'nin oturumları ilgisiz bir projenin klasöründen açıldı; C'nin 15 hafıza notu o projenin hafızasında. B'nin hafıza klasöründe A'nın kuralları da var.

**Bedel** C'nin kendi deposunda açılan yeni bir oturum bu notları görmez.

**Kural** [öneri] Oturum ürünün ana deposunda açılır; ürün kuralları AGENTS.md'ye yazılır.

2 Ekim

### Devir notuyla iş başka oturuma geçti

Dört ürüne dokunan bir günün sonunda kalıcı klasöre bir genel not ve ürün başına birer not yazıldı. Dallar henüz GitHub'da değildi, onay bekliyordu.

**Bedel** Notu yazmak birkaç dakika. 4 Ekim'de başka bir oturum notu okuyup işi sürdürdü.

**Kural** [kanıtlı] Gün ya da iş biterken devir notu kalıcı yere yazılır; okuyan soru sormadan sıradaki adımı atabilmeli.

16 Eylül

### Yarım iş 'bitti' diye raporlandı

Bir tasarım teslimi 'yapıldı' diye raporlandı; yalnız iskelet ve filtreler vardı, tablo, çekmece ve üst çubuk yoktu.

**Bedel** Ürün sahibinin sonraki her durum raporuna güveni sarsıldı.

**Kural** [kanıtlı] 'Bitti' yalnız işin tamamı varken yazılır; ara raporda biten, kalan ve yapılamayan (nedeniyle) ayrı yazılır.

5 Ekim

### Türkçe uydurma dosya adı geri çevrildi

Ajan ürün günlüğünü Türkçe uydurma bir adla açtı. Ürün sahibi adı reddetti, dosya bir sonraki deploy'da yeniden adlandırıldı.

**Bedel** Bir düzeltme turu ve fazladan bir commit.

**Kural** [kanıtlı] Dosya adları geleneksel: README.md, CHANGELOG.md, AGENTS.md, docs/. Türkçe başlıkta kalır.

## Gün 0: ajan önce ürün sahibine sorar

Ajan gün 0'da [Kararlar](#kararlar) tablosunun gün 0 satırlarını sorar; bu bölüm ayrı soru listesi tutmaz. Proje hafızasıyla ilgili sorular tablonun 7, 8, 9, 10, 12 ve 26. satırlarındadır. Cevabı gelmeyen satır AGENTS.md'de 'KARAR BEKLİYOR' diye kalır ve TODO'nun karar bekleyen bölümüne girer.

## Ajanın gün 0'da açtığı dosyalar

[öneri] Bu düzen depolarımızda en iyi işleyen parçaların birleşimi; tam haliyle hiçbir depomuzda yok. Şablonlar aşağıda.

| Dosya | İlk gün içinde |
|---|---|
| AGENTS.md | Şablondaki iskelet, ürün sahibinin cevaplarıyla doldurulur. Bilinmeyen satır 'KARAR BEKLİYOR' diye kalır. |
| CLAUDE.md | Yalnız `@AGENTS.md` satırı. |
| CHANGELOG.md | Başlık, yazım kuralları ve boş bir Unreleased bölümü. |
| docs/STATUS.md | 'Canlıda: henüz yok'. İlk gün kurulan her servis eklendikçe doğrulama yöntemiyle dolar. |
| docs/TODO.md | Altyapı kurulum adımları P1 olarak; ürün sahibinin kararını bekleyenler ayrı başlıkta. |
| docs/DECISIONS.md | Kararlar tablosundaki her cevap bir K bloğudur. Numara verildiği sırayla K-001'den artar, blok tablodaki satırı taşır (ör. 'Tablo: 7'). |
| docs/runbooks/ | deploy.md ve rollback.md ilk deploy'dan önce; restore-db.md ilk yedekten sonra, prova tarihiyle. |
| docs/handoff/ | Boş klasör. Her oturum ya da gün sonunda bir not. |
| .gitignore | `.env` yok sayılır, `!.env.example` satırıyla örnek dosya git'te kalır. |

## Çalışırken neyi nereye yazar

Kod ve deploy kayıtları işi yapan commit'in içinde yazılır. Deploy'dan sonra ayrı commit'te yazılan günlük unutulmaya açık; C'de kod commit'lerinin yalnız %1–12'si günlüğe dokunuyor.

| Ne olunca | Nereye | Ne yazılır |
|---|---|---|
| Davranış değiştiren her commit | CHANGELOG.md | Unreleased bölümüne bir girdi, aynı commit'te. |
| Her deploy | CHANGELOG.md, docs/STATUS.md | Unreleased bölümü tarih ve revizyon başlığına çevrilir; STATUS'un 'Canlıda' satırı doğrulama yöntemiyle güncellenir. |
| Ürün sahibinin her kararı | docs/DECISIONS.md | Bir blok: tarih, seçenekler, neden, yeniden bakılacak tarih. |
| Yeni iş ya da bulgu | docs/TODO.md | Öncelik ve sahiple bir satır. Biten iş buradan silinir, CHANGELOG'a girer. |
| İkinci kez yapılan hata ya da pahalı ders | AGENTS.md, docs/lessons.md | AGENTS.md'ye bir satırlık kural, anlatımı docs/lessons.md'ye. |
| Oturum ya da gün sonu | docs/handoff/ | Devir notu. Uzun işin ara çıktısı kalıcı klasöre. |
| Ücretli çağrı ya da süren maliyet kurmadan önce | docs/TODO.md ya da DECISIONS | Günlük ve aylık rakam; kurulum ürün sahibinin onayından sonra. |

## Şablonlar

Kopyalanıp doldurulur. Örnek satırlar biçimi gösterir; numaralar temsilîdir. Açılı parantezli yerler ürün sahibinin cevabıyla dolar.

### AGENTS.md

Gün 0'da; kural ya da ders eklendikçe. CLAUDE.md içinde yalnız `@AGENTS.md`.

```
# AGENTS.md
<!-- CLAUDE.md içinde yalnız: @AGENTS.md -->
Son doğrulama: 2026-10-08

## Ürün
Ne: <tek cümle>. Kim kullanır: <tek cümle>.
Bu depo: <api | web | mobil | admin>.
Kardeş depolar: <x-api, x-web, x-mobil>.
Dokunmadan önce onların AGENTS.md'sini oku.

## Çalıştır ve doğrula
Yerel: make dev | npm run dev
  (yalnız yerel ya da test veritabanı)
Doğrula: make test vet
  | npm run typecheck && npm test && npm run lint
Temiz değilse iş bitmedi.

## Dallar ve deploy (karar: ürün sahibi)
test'e push: test ortamı. Hat test eder,
  imajı bir kez kurar, digest'i yazar.
main'e push: onay kapısı. Onaydan sonra
  test'te denenen aynı digest prod'a çıkar.
main yalnız test'te görülmüş commit'e ilerler.
Sıra: kod biter, commit, tek satır rapor,
  ürün sahibinin "deploy" sözü.
Migration hattın adımı: migrate job aynı
  digest'le koşar, bitmeden trafik verilmez.
Migration yalnız ekler. Onu okuyan kod
  sonraki deploy'da çıkar.
Build, mağazaya gönderim ve sürüm numarası
  ürün sahibinin kararı.

## Asla
- Onaysız main push.
- Canlıya deneme verisi ya da test isteği.
- Gizli değeri dosyaya, commit'e, loga,
  sohbete yazmak.
- Ücretli servisi rakamını söylemeden çağırmak.
- Başka oturuma kendiliğinden iş göndermek.

## Gizli bilgiler
Değerler Secret Manager'da, adlar .env.example'da.
Değer hiçbir dosyada yok.

## Kayıt (her değişiklikte)
CHANGELOG.md: aynı commit'te.
Durum: docs/STATUS.md. İşler: docs/TODO.md.
Kararlar: docs/DECISIONS.md.
Runbook: docs/runbooks/. Devir: docs/handoff/.
Zor öğrenilen ders: buraya bir satır,
  anlatımı docs/lessons.md'ye.
```

### docs/runbooks/

İlk deploy'dan önce; restore-db.md ilk yedekten sonra.

```
docs/runbooks/
deploy.md
  test'e çıkış, main'e alma, canlı doğrulama
rollback.md
  önceki revizyona trafik; migration geri alınmaz
restore-db.md
  zaman noktasına dal, döküm, md5 karşılaştırma
rotate-secret.md
  iki değerli geçiş, eski değerin silineceği gün
incident.md
  ilk 15 dakika: ölç, düzelt ya da geri al, kayıt
release-mobile.md
  build hakkı, sürüm numarası, mağaza adımları
new-env.md
  sıfırdan test ortamı: veritabanı dalı, servisler
cost-check.md
  günlük maliyet nereden okunur, eşikte ne yapılır

Her runbook'ta: amaç, ne zaman, kim onaylar,
kopyalanabilir komutlar (proje adı açık),
doğrulama, geri dönüş, son prova tarihi.
Prova edilmeyen runbook bayat sayılır.
```

### CHANGELOG.md

Davranış değiştiren her commit'te; deploy'da Unreleased kapanır.

```
# Changelog
En yeni üstte. Önce kullanıcının fark edeceği
değişiklik (en çok 2 satır), sonra teknik
ayrıntı (en çok 5 satır). Gizli değer yazılmaz.
Türler: Eklendi, Değişti, Kalkacak, Kaldırıldı,
Düzeltildi, Güvenlik.
40 KB'ı geçince en eski ay
docs/changelog/YYYY-AA.md'ye taşınır.

## Unreleased
### Eklendi
- Paylaşılan listeyi açan web sayfası.
  (dal share-links, test ortamında)

## 2026-10-08 (api rev 00012, web rev 00007)
### Eklendi (bayrak kapalı)
- Kullanıcı kaydettiği listeyi paylaşabilecek.
  (api a1b2c3d, web e4f5a6b)
  Teknik: POST /v1/shares. Önce migration 014.
  Bayrak SHARE=false.
  Geri dönüş: bayrağı kapat.
### Düzeltildi
- Aynı arama artık hep aynı sonucu veriyor.
  (api 9f8e7d6) Sebep: sınıflandırıcı
  varsayılan sıcaklıktaydı, 0'a çekildi.
### Güvenlik
- Admin oturumu 30 dakika boşta kalınca
  kapanıyor. (api 3c4d5e6, K-006)
```

### docs/STATUS.md

Her deploy'da, aynı commit'te.

```
# Durum
Son güncelleme: 2026-10-08 14:25, deploy sonrası.
7 günden eskiyse güvenme, canlıya bak.
Sahip oturum: <ürün ve iş adı>.
Ürün sahibi: <rol>.

## Canlıda (doğrulama yöntemiyle)
- api: a1b2c3d, rev 00012, 2026-10-08.
  /health 200, son 1 saatte 5xx 0.
- web: e4f5a6b, rev 00007.
  Ana sayfa ve giriş elle denendi.
- mobil: iOS ve Android 1.0.3 mağazada.
- Veritabanı: son migration 014, canlıda.
- Bayraklar: SHARE=false.

## Devam eden
- dal share-links: test ortamında,
  ürün sahibinin bakması bekleniyor.

## Bekleyen (dış etken ya da karar)
- Mağaza incelemesi 1.0.4, gönderim 2026-10-07.

## Bilinen sorunlar
- Kullanıcıya etkisi, geçici çözüm, TODO satırı.
```

### docs/TODO.md

İş eklenince ya da bitince.

```
# Yapılacaklar
Yalnız açık işler. Biten iş silinir,
CHANGELOG'a girer.
Satır: - [ ] [öncelik] iş. Sahip. Tarih. Bağlantı.
P0 canlı kırık (hemen), P1 bu hafta,
P2 sırada, P3 fikir.

## P0
## P1
- [ ] [P1] Ödeme ekranında iptal koşulu yazmıyor.
  Sahip: ajan. 2026-10-08.
## P2
- [ ] [P2] Arama sonuçlarını 6 saat önbellekte
  tut. Sahip: ajan. 2026-10-06.
  Ölçüm: docs/notes/search-cost.md.
  Etki: veritabanı daha çok uyur.

## Karar bekleyen (karar: ürün sahibi)
- [ ] Yıllık plan fiyatı. Soruldu: 2026-10-05.
  Seçenekler ve önerim: DECISIONS, taslak K-008.

## Rafta (bilinçli yapılmayanlar)
- Sayfaların baştan yeniden yazımı.
  Neden: ekranda görülmeden risk yüksek.
  Yeniden bak: 2026-11-15.
```

### docs/DECISIONS.md

Ürün sahibi karar verince.

```
# Kararlar
Her karar bir blok. Numara tekrar kullanılmaz.
Değişen karar silinmez: "yerini aldı: K-007".
Ajan karar vermez, ürün sahibinin kararını
kaydeder.

## K-006 Admin oturumu 30 dk boşta kapanır
Tarih: 2026-09-28. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 23.
Bağlam: admin paneli müşteri verisine erişir.
Karar: 30 dakika boşta çıkış.
Seçenekler: 8 saat (reddedildi: kolaylık için
  güvenlikten taviz).
Sonuç: admin gün içinde birkaç kez
  yeniden giriş yapar.
Yeniden bak: ikinci admin eklenince
  ya da 2027-01.
Bağlantı: api 3c4d5e6, CHANGELOG 2026-10-08.

## K-007 ...
```

### docs/handoff/2026-10-08.md

Gün ya da oturum sonunda; git'te ya da kalıcı klasörde.

```
# Devir notu: 2026-10-08, <oturum adı>
Yer: docs/handoff/ ya da kalıcı bir klasör
(/tmp açılışta silinir)

## Bitti ve canlıda (doğrulandı)
- api rev 00012 (a1b2c3d): paylaşım ucu.
  Doğrulama: 2.022 istekte 5xx 0.

## Bitti, yayında değil
- dal share-links, b1c2d3e..f4a5b6c,
  worktree ~/work/api-share-links
  Test'e: git -C ~/work/api-share-links \
    push origin share-links:test
  Canlıya yalnız ürün sahibinin onayıyla.
  main, test'te doğrulanan commit'e
  ileri sarılır; iş dalı main'e itilmez:
    git -C ~/work/api-share-links fetch origin
    git -C ~/work/api-share-links \
      push origin origin/test:main
  İleri sarma değilse push reddedilir;
  --force kullanılmaz, ürün sahibine
  tek satırla söylenir.
  Adımlar: runbooks/deploy.md.

## Bitmedi
- Mobil ekran: liste var, paylaşım sayfası yok.
  Sıradaki adım: ...

## Riskler ve geri dönüş
- Trafik önceki revizyona (runbooks/rollback.md).

## Yarın kontrol edilecek
- 04:20 işi 2xx mi, gece yedeği alındı mı.

## Karar bekleyen
- Soru, seçenekler, önerim (tek paragraf).
```

Runbook ayrıntıları: geri dönüş için [Kullanıcıyı kırmadan değiştirmek](#kirmama), geri yükleme için [Yedekler](#yedek), mobil sürüm için [Mobil dağıtım](#dagitim), maliyet okuma için [Maliyet](#maliyet).

## Kurallar

Kanıtlı kural bizde işliyor. Ölçüldü etiketinde rakam bizim ölçümümüz ama çözüm her zaman denenmedi; 40 KB sınırı, tarihli sürüm başlığı ve docs/lessons.md ayrımı bizde henüz uygulanmadı. Öneri bizde denenmedi; başka öneriler [Bizdekinden iyisi](#hf-iyisi) başlığında.

### Değişiklik günlüğü

[kanıtlı]
**CHANGELOG en yeni üstte yazılır**. Ajan dosyayı baştan okur; okuma aracı büyük dosyada yalnız ilk sayfayı döndürse de en yenisi görülür.
[ölçüldü]
**Davranış değiştiren commit günlüğü aynı commit'te günceller, bu kural AGENTS.md'de yazılır**. Yazılı olan üç depoda oran %72–84, olmayan dördünde %33–52.
[ölçüldü]
**Ana dosya 40 KB'ı** (~12 bin token) geçmez; girdi en çok 2 satır kullanıcı etkisi, 5 satır teknik ayrıntı. Bizde girdi ortancası 0,8–1,7 KB, en uzunu 11,8 KB idi.
[ölçüldü]
**Tek Unreleased bölümü deploy olunca ISO tarih ve canlı revizyon başlığına çevrilir**; girdi commit kısaltması taşır. 820 başlığın 11'inde tarih vardı.
[kanıtlı]
**Yalnız .md ya da docs/ değişen commit canlı build'i tetiklemez**. Belge düzeltmesi deploy korkusuyla beklemez.

### Ajan dosyası

[kanıtlı]
**Tek kaynak AGENTS.md**; CLAUDE.md'de yalnız `@AGENTS.md` ve gerekirse Claude'a özel birkaç satır. Claude Code, CLAUDE.md varken AGENTS.md'yi bu import olmadan okumaz (kullanıcı ayarı `claude-md-and-agents-md` hariç).
[kanıtlı]
**Deploy kuralı dosyanın en üstünde ve ürünün bütün depolarında aynı cümlelerle durur**. Ayrıntısı [Kullanıcıyı kırmadan değiştirmek](#kirmama) ve [Yeni depo için kurallar](#depo-kurallari) bölümlerinde.
[ölçüldü]
**Zor öğrenilen ders kaça mal olduğuyla bir satır girer, anlatımı docs/lessons.md'ye**. B'nin dosyaları 245 ve 203 satıra çıktı; Claude Code 200 satırın altını öneriyor.

### Durum, iş ve kararlar

[kanıtlı]
**Ürün düzeyinde tek durum yeri olur**. C'de ürün günlüğünün tepesindeki durum bölümü canlı sürümleri, son migration'ı ve bekleyenleri tek yerde gösteriyor.
[kanıtlı]
**STATUS'taki her canlı satırı doğrulama yöntemini ve tarihini taşır**. Hafıza notu ve eski durum satırı durum kaynağı değildir.
[öneri]
**Kararlar depoya yazılır** (DECISIONS.md ya da numaralı ADR). En büyük hafıza klasöründeki 74 notun 28'i karar içeriyordu ve yalnız o makinede duruyordu.

## Göreve başlarken

### Ajanın ilk 5 dakikası

[öneri] Sıra bizde parça parça uygulandı. 3. adım 4 Ekim'de bir işin ikinci kez yapılmasını bir dakikada önledi.

1. AGENTS.md. Claude Code'da `/memory` ile yüklenen dosyalara bak; AGENTS.md listede yoksa aç ve oku.

2. docs/STATUS.md: canlı sürümler, bayraklar, sahip oturum. Başka oturum sahipse yalnız kendi dalında çalış.

3. `git fetch`, `git log --oneline -20 origin/main`, `git status`, `git worktree list`. İş zaten yapılmış mı.

4. CHANGELOG.md'nin ilk 150 satırı. Tamamını okuma.

5. docs/TODO.md ve docs/DECISIONS.md'de işle ilgili satır var mı. Yoksa TODO'ya ekle.

6. En yeni devir notu. 'Yarın kontrol edilecek' maddeleri ilk iştir.

7. Dokunacağın kardeş deponun AGENTS.md'si; kendi deponun kuralı oraya taşınmaz.

8. Ürün sahibine tek satır: iş, dokunulacak depolar, deploy ya da ücretli çağrı gerekiyor mu.

### Yeni geliştiricinin ilk saati

[öneri] Taramada README komutlarının yalnız var olduğu görüldü, temiz makinede çalıştırılmadı; d-web'in ilk adımı temiz klonda çalışamaz. İlk saat bu denemedir.

1. README'deki kurulumu sırayla uygula. .env değerlerini gizli bilgi yöneticisinden al, sohbete yapıştırma.

2. Yerel testleri çalıştır (`make test` ya da `npm test`). Takıldığın her adım README'ye girer.

3. AGENTS.md'yi baştan sona oku: deploy kuralı, 'asla' listesi, doğrulama komutları.

4. docs/STATUS.md: ne canlıda, ne yarım, ne bekliyor. Damga 7 günden eskiyse canlıya bak.

5. CHANGELOG.md'nin Unreleased bölümü ve son iki tarih başlığı.

6. docs/DECISIONS.md başlıkları; bir şeyi tartışmaya açmadan önce burada ara.

7. docs/TODO.md'den bir P2 iş al, dal aç, test ortamına çıkar, CHANGELOG'a yaz. Main kararı ürün sahibinde.

## Birden çok oturum ve ajan

Bizde aynı anda birkaç uzun ömürlü oturum, aynı depolarda çalışıyordu. Yayın kuralının hafızadan depoya taşındığı 20 Eylül olayı ve yazılı 'önce test' kuralının üç depoda atlandığı 26 Eylül olayı: [Kullanıcıyı kırmadan değiştirmek](#kirmama), [7.2](#k-7-2) ve [7.1](#k-7-1).

[kanıtlı]
**Bir depo ya da dal, bir sahip oturum**. Sahibin adı STATUS'ta yazılı; diğerleri kendi dalında çalışır ve dalı commit listesiyle sahibe teslim eder.
[kanıtlı]
**İşe başlamadan ve push'tan önce `git fetch`, son 20 commit, CHANGELOG'un tepesi**. 4 Ekim'de bir düzeltmenin sabah başka oturumda yapıldığı böyle bir dakikada görüldü.
[kanıtlı]
**Her paralel iş kendi dalında ve worktree'sinde**. Worktree kalıcı klasörde durur (`~/Documents/worktrees/<depo>-<dal>` gibi); /tmp açılışta silinir.
[kanıtlı]
**Aynı gün birden çok dal girecekse tek entegrasyon dalı kullanılır**: dallar orada sırayla birleşir, test ortamına o dal çıkar, main o commit'e ileri sarılır.
[kanıtlı]
**Oturumlar arası mesaj yalnız ürün sahibinin 'ilet' sözüyle gider**: kanıt, kodda yer, öneri. Raporu yazan oturum koda dokunmaz.
[kanıtlı]
**Uzun iş akışında her ajanın sonucu kalıcı bir günlüğe yazılır**; kesintide iş kaldığı yerden sürer, biten ajan yeniden koşmaz.
[öneri]
**Haftada en az bir devir notu**; büyük iş yeni oturumda, devir notuyla başlar. Uzun oturum bağlamı aşındırır: bir oturum 49 günde 67 kez sıkıştırıldı.
[öneri]
**Oturum değiştirilecek depoda açılır**. Birden çok depo için `--add-dir` ve `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`. Bizde a-portal'da açılan bir oturumun 29.866 araç çağrısının 10.739'u dört kardeş depoya gitti (en çok a-api, 5.079).
[öneri]
**Geri dönüşü olmayan adımı araç durdurur**: korumalı main, izin listesinde `git push` yok, onay dosyası yoksa main push'unu durduran PreToolUse hook'u. 26 Eylül'de yazılı 'önce test' kuralı üç depoda atlandı.

## Tazelik kontrolleri

Güncellemesi birinin hatırlamasına kalan belge bayatlıyor; a-mobil'in TODO.md'si üç sürüm geride kaldı. Kontrolü takvim ve CI yapar.

| Ne zaman | Kontrol | Etiket |
|---|---|---|
| Her PR'da, CI | **Günlük yazıldı mı.** Kaynak kod değişip Unreleased değişmediyse uyarı; 'günlük gerekmez' etiketiyle atlanır. | [öneri] |
|  | **Boyut.** CHANGELOG 40 KB'ı, AGENTS.md 200 satırı geçerse uyarı. | [öneri] |
|  | **Komutlar var mı.** README ve AGENTS.md'deki her `npm run` ve `make` hedefi depoda var mı. Bizde hepsi vardı; temiz makinede denemek ayrıca gerekir. | [ölçüldü] |
|  | **Örnek ortam dosyası.** .env.example git'te ve kodun okuduğu adları içeriyor mu. d-web'de `.env*` kalıbı onu yuttu, README'nin ilk adımı çalışmıyor. | [öneri] |
| Her deploy'da | **Durum damgası.** STATUS'un canlı satırını ve CHANGELOG'un tarih başlığını deploy adımı yazar, ya da sürüm bir /version ucundan okunur. C'de içerik 7 Ekim'deydi, elle yazılan damga 6 Ekim. | [öneri] |
| Ayda bir, 15 dakika | **Tazelik turu.** Ajan hazırlar, ürün sahibi bakar: STATUS canlıyla karşılaştırılır, 30 günden eski P1'ler sorulur, 'yeniden bak' tarihi geçen kararlar ve ajan dosyasındaki yollar kontrol edilir. | [öneri] |
|  | **Hafıza budaması.** Olmayan dosya, bayrak ya da sürüm geçen notlar silinir, kararlar depoya taşınır. MEMORY.md 200 satır ve 25 KB altında kalır; bizde 75 satır, 11 KB. | [öneri] |
| Dal birleşince, kesintiden sonra | **Dal ve worktree.** Birleşen dal ve worktree hemen silinir. A'nın dört deposunda uzakta yalnız main ve test kaldı. | [kanıtlı] |
|  | **Ölü kayıtlar.** Kesintiden sonra `git worktree prune`. C'de 28 worktree kaydı silinmiş /tmp klasörlerini gösteriyordu. | [öneri] |

## Bizdekinden iyisi

Bizde denenmedi; belgelere ve kendi açıklarımıza dayanıyor.

[öneri]

### Değişiklik günlüğü parçaları

Her dal kendi küçük dosyasını yazar (changes/unreleased/<dal>.md), sürüm anında tek komutla birleştirilir; towncrier ve changesets böyle çalışır. `merge=union` da olur, ama sıra elle kontrol edilir.

[öneri]

### Haftalık devir taslağı

Zamanlanmış bir görev git geçmişinden, Unreleased bölümünden ve açık dallardan taslak çıkarır; ürün sahibi okur ve düzeltir. Sürüm başlıkları `git tag` ile bağlanır.

[öneri]

### Yola bağlı kurallar

Ders anlatımları .claude/rules/ altında, `paths:` alanıyla durur; yalnız ilgili dosyaya dokunulunca yüklenir, AGENTS.md kısa kalır.

[öneri]

### Ajan hafızasının yedeği

Hafıza klasörü makineye bağlı ve sürüm kontrolsüz. Ayrı, özel bir git deposuna günlük commit ya da `autoMemoryDirectory` ile yedeklenen bir klasör.

## Tuzaklar

Araçların varsayılanlarından ve alışkanlıklardan gelen tuzaklar.

CLAUDE.md'si olmayan depoda bir CLAUDE.local.md eklemek, Claude Code'un AGENTS.md'yi okumasını durdurur. `@AGENTS.md` importlu bir CLAUDE.md bunu önler.

Codex AGENTS.md zincirini varsayılan olarak 32 KiB'ta keser; ders biriktiren dosya bu sınıra yaklaşabilir.

İzin listesine `git push` eklemek, push'un deploy olduğu depoda son onay sorusunu sessizce kaldırır.

Gösterici satır ('gerçek durum şu dosyada') gösterdiği dosya bayatlarsa ajanı yanlış yere götürür.

Aynı belgenin iki kopyası zamanla ayrışır; birini güncelleyen öbürünü unutur. c-admin'in docs/ klasörü c-web'inkinin kopyası, ikisi de Şubat'tan beri değişmedi.

### Ölçülmeyenler

Bu bölümdeki rakamlar 8 Ekim 2026 taramasından. Aşağıdakiler ölçülmedi ya da kaba tahmin.

CHANGELOG çakışmalarının toplam zaman maliyeti; tek tek 1 ile 8 dakika görüldü.

8 Ekim kesintisinde kaybolan commit'siz işin büyüklüğü.

İstenmeden gönderilen iki mesajın o oturumlara maliyeti.

20 Eylül'deki iki izinsiz build'in iOS kotasının bitmesindeki payı.

Ajan dosyalarına yazılan kurallardan sonra izinsiz main push ya da build olup olmadığı; sistemli tarama yapılmadı.

README kurulumlarının gerçekten çalışıp çalışmadığı; yalnız komutların var olduğu kontrol edildi, temiz makinede denenmedi.

Token sayıları karakter/3,3 (Türkçe) ve karakter/4 (İngilizce) ile kaba tahmin; gerçek tokenizer ile sayılmadı.

Bayat bir belge ya da hafıza notunun kaç kez yanlış karara yol açtığı.

Codex oturumlarının hangi talimat dosyalarını gerçekten yüklediği; yalnız Claude Code kayıtları incelendi.

Aynı commit oranı commit başına; bir özellik birden çok commit'e bölündüğünde oran düşük görünür, özellik başına oran ölçülmedi.

## Kaynaklar

**Claude Code: proje hafızası, @import, auto memory**https://code.claude.com/docs/en/memory
**Claude Code: araç başvurusu, kısmi okuma**https://code.claude.com/docs/en/tools-reference
**OpenAI Codex: AGENTS.md ve 32 KiB sınırı**https://learn.chatgpt.com/docs/agent-configuration/agents-md
**AGENTS.md açık biçimi**https://agents.md/
**Keep a Changelog 1.1.0**https://keepachangelog.com/en/1.1.0/
**git gitattributes: union birleştirme**https://git-scm.com/docs/gitattributes
**towncrier: parça dosyalarla günlük**https://towncrier.readthedocs.io/en/stable/tutorial.html
**Mimari kararların kaydı (ADR), ilk yazı**https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
**ADR örnekleri ve araçları**https://adr.github.io/

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

<a id="mobilkit"></a>

Mobil

# Mobil uzaktan kontrol kiti

Mağazadaki bir build'e yeni build olmadan ancak ona baştan konmuş kanallarla ulaşılır. Kit ilk mağaza sürümünde eksiksiz bulunur; sonradan eklenen parça o güne kadarki kurulumlara hiç ulaşmaz.

**Kural:** Bu kit olmadan uygulama mağazaya çıkmaz.
Zorunlu güncelleme, yeni build'siz özel bildirim, sunucudan duyuru ve ekran içi uyarı, bayrak ve kill switch kurulmadan ilk mağaza build'i gönderilmez; bakım modu, push ve sürüm telemetrisi bunların taşıyıcısıdır. Her parça release build'de ve gerçek telefonda denenir; kanıtı sürüm notuna yazılır, kanıtı olmayan parça kurulmamış sayılır. OTA kanalı (8) kuralın parçası değildir, önerilir: küçük düzeltmeyi mağaza build'i harcamadan gönderir.

1Sürüm başlıkları2Politika ucu3Zorunlu güncelleme4Yumuşak uyarı5Duyuru alanı6Bayrak ve kill switch7Bakım modu8OTA (öneri)9Push kaydı10Sürüm telemetrisi11Mağaza izleyicisi

## Neden

Ağustos–Ekim 2026'da uygulamalarımızda yaşananlar. Her biri kitin bir parçası eksik ya da yanlış kurulduğu için oldu ve hiçbiri yeni build olmadan düzeltilemedi.

### 3 build. Eski Android build'leri uyarıyı gösteremiyor

Üç Android build'i kendi build numarasını okuyamadı; alan boş ya da geride geldi. Güncelleme uyarısı bu build'lerde hiç çıkmadı ve hiç çıkmayacak. Birim testleri numarayı taklit ettiği için hata görülmedi; sunucu tarafındaki kontroller de yakalamadı.

**Kural** Numara expo-application nativeBuildVersion'dan okunur. Davranış ancak gerçek release build'de, telefonda görülünce çalışıyor sayılır.

### Kilit. Zorunlu ekran telefonu boş ekranda kilitledi

Zorunlu ekran bir Modal içinde çiziliyordu; iOS'ta Modal açıldı ama içi boş kaldı ve uygulama kullanılamaz oldu. Ekran sonraki sürümde kök görünüme çevrildi. Zorlama ise kurulu tabanın tamamı ekranı doğru çizebilene kadar açılamaz.

**Kural** Zorunlu ekran ilk sürümde kök görünüm olarak çizilir; dil, oturum ya da font sağlayıcısına bağlanmaz.

### 5 / 6. Sabit metinli eski ekran yeni akışı bekletti

Eski bir ekranın metinleri uygulamaya gömülüydü; o ekrana 'güncelleyin' demenin yolu yoktu. Yeni akışın açılışı günlerce bekletildi ve ekranı kullanan altı kişiden beşi yeni build'e geçince açıldı.

**Kural** Ana ekranda ve her kritik ekranda ilk sürümden sunucudan dolan bir duyuru alanı durur.

### Aynı gün. Sonradan eklenen OTA açılışta çöktü

OTA kütüphanesi canlı bir uygulamaya sonradan eklendi. Native entegrasyon eksik kaldı, uygulama açılışta çöktü ve değişiklik aynı gün geri alındı. runtimeVersion elle sabit yazılmıştı.

**Kural** OTA kurulacaksa ilk mağaza build'inde, fingerprint politikasıyla ve release build'de denenmiş olarak bulunur.

### 404. Yedek politika dosyası kayboldu

Bir platformun yedek politikası özel bir depodaki dosyaydı. Depo gizlenince adres 404 verdi; dosyada zorlamayı açan eski değerler unutulmuştu. Dosya sonraki bir sürümde koddan çıkarıldı.

**Kural** Yedek politika kendi kontrolümüzde, kalıcı olarak açık ve izlenen bir yerde durur.

### 10 saat. Sürüm duyurusu unutuldu ya da erken yapıldı

Önerilen sürümü yükseltmek elle yapılan bir adımdı; bir platformda birkaç sürüm boyunca unutuldu ve kimseye uyarı gitmedi. Apple'ın arama API'si ise mağaza sayfası yeni sürümü gösterdikten sonra 10 saatten uzun süre eski sürümü döndü.

**Kural** Mağaza sürüm izleyicisi her gün iki mağazanın sayfasını okur ve önerir; yükseltme onayla yapılır.

## On bir parça

Her parçada sunucu ne yapar, istemci ne yapar, bir şey bozulunca ne olur ve yayından önce nasıl denenir.

### 1. Sürüm başlıkları

Her API isteği platform, sürüm, build, dil, kanal ve kurulum kimliğini taşır: X-App-Platform, X-App-Version, X-App-Build, X-App-Locale, X-App-Channel ve X-Install-Id; OTA paketinden X-App-Runtime ve X-App-Update-Id. Kurulum kimliği kurulumda üretilen rastgele bir değerdir, hesaba bağlanmaz.

**Sunucu:** Tek middleware başlıkları doğrular (sayı, uzunluk, izinli değer), isteğin bağlamına koyar ve loga yazar. Eski build'e yeni veri göndermemesi gereken uçlar kararı buradan verir. Başlıklar CORS izin listesine, kurulum kimliği gizlilik metnine ve mağaza gizlilik formlarına girer.

**İstemci:** Tek API istemcisi değerleri çalışma anında binary'den okur: expo-application nativeBuildVersion ve nativeApplicationVersion, kanal ve OTA kimliği expo-updates'ten. Elle yazılmış sabit yoktur; politika, push kaydı ve analitik aynı istemciden geçer.

**Güvenli düşüş:** Okunamayan değer gönderilmez, boş metin de gönderilmez. Başlığı eksik istek reddedilmez; 'bilinmeyen build' sayılır ve en eski güvenli davranışı alır.

**Nasıl denenir:** Aynı commit'ten test API'ye bağlı release build iki platformda kurulur; test API logunda bütün başlıklar doğru değerlerle görülür. Hedefin test olduğu çalışma anında doğrulanır.

### 2. Güncelleme politikası ucu

GET /v1/app/update-policy tek çağrıda platform başına minimumBuild, recommendedBuild, forceEnabled ve mağaza adresini, iki dilde mesajları, bayrakları, duyuruları ve bakım bilgisini verir. Tek çağrı, tek önbellek.

**Sunucu:** Yanıt bellekten verilir. Yeni açılan sunucuda bellek boştur; ilk istek politikayı veritabanından yükler ve bekler. Önbellekli herkese açık uçlarda bu pencere p99 0,9–1,5 sn ölçüldü; açılış bu çağrıyı beklemediği için kullanıcı görmez. Bizde politika ve kapatma anahtarları ortam değişkenindeydi, açılışta doğrulanıp belleğe alınıyordu; bu pencere hiç oluşmadı (bkz. [Kullanıcıyı kırmadan değiştirmek, 7.5](#k-7-5)). [öneri] Sunucu bu pencerede derlenmiş varsayılanla cevap vermez. Politika yüklenemezse uç 503 döner ve istemci son iyi politikayı kullanır. Özelliğin sunucu ucu anahtarı okuyamazsa kapalı tarafa düşer.

**İstemci:** Soğuk açılışta ve ön plana her dönüşte (en çok dakikada bir) okunur. Zaman aşımı en çok 5 sn; açılış bu çağrıyı hiç beklemez. Yanıt şemaya göre sıkı ayrıştırılır, son geçerli yanıt zaman damgasıyla saklanır.

**Admin ve önbellek:** Değerler admin ekranından değişir ve kaydederken doğrulanır: min ≤ recommended, recommended mağazada herkese açık build'i geçemez, adres https ve bu uygulamanın sayfası, iki dil dolu. Her değişiklik kayda geçer. Bütün yanıtlar Cache-Control: private, max-age=60 ve ETag taşır. Aynı adres önizleme listesindeki kuruluma farklı yanıt verdiği için yanıt CDN ya da proxy önbelleğine girmez. Yanıt zaten bellekten geldiği için kenar önbelleğine gerek yoktur. Test ortamının ayrı politikası vardır.

**Güvenli düşüş:** Ağ yok, zaman aşımı, 5xx ya da bozuk JSON: son iyi politika. O da yoksa ne uyarı ne kilit; bayraklar derlenmiş varsayılanda. Bozuk bir platform bloğu tek başına yok sayılır. 30 günden eski önbellek kilit üretmez.

**Nasıl denenir:** Release build'de dört durum: ağ kapalı, 500, bozuk JSON, geçerli yanıt. Dördünde de uygulama aynı hızda açılır; davranış yalnız geçerli yanıtta değişir.

**İkinci adres:** [öneri] Uç cevap vermezse istemci arkada, aynı 5 sn sınırla ikinci bir adresi okur; açılış bunu da beklemez. Adres başka bir sağlayıcıda ve başka bir alan adında duran statik bir JSON'dur. İçinde yalnız duyuru ve bakım bulunur; güncelleme eşikleri ve bayraklar orada yazılmaz, istemci oradan gelen zorlama alanını yok sayar. Kilit yalnız birincil uçtan doğar. Yanıt aynı şemadan ve aynı CTA süzgecinden geçer, son iyi politikanın yerine kaydedilmez. Dosya normalde boştur. Kesintide admin olmadan, kesinti runbook'undaki adımla elle doldurulur. Her kaydın bitiş saati vardır; bitişsiz kayıt gösterilmez. Dış uptime bu adresi de izler. Adres ilk mağaza build'inde bulunur; sonradan eklenen adresi eski build'ler hiç öğrenemez.

### 3. Zorunlu güncelleme ekranı

forceEnabled true ve yüklü build minimumBuild'in altındaysa tam ekran 'Güncelleme gerekli'. Mağaza kuralları zorunlu güncellemeyi açıkça düzenlemiyor; Apple 3.2.2(x) kullanıcıyı başka eylemlere zorlamayı yasaklıyor. Ekran yalnız gerçekten desteklenmeyen sürüm için kullanılır.

**Sunucu:** forceEnabled yalnız minimumu karşılayan sürüm herkese indirilebilirken kaydedilir: Play'de kademeli yayın %100 olmalı, App Store'da sürüm yayında olmalı. Admin kaydetmeden önce son 7 günün dağılımından kaç kurulumun kilitleneceğini gösterir. İncelemedeki build hiçbir zaman minimumun altında kalmaz.

**İstemci:** Modal değil kök görünüm; dil, oturum, font ve ağ olmadan çizilir. TR ve EN metni gömülü, sunucu mesajı varsa o. Android'de önce Play in-app immediate update, olmazsa market:// ve https mağaza sayfası; iOS'ta mağaza sayfası. 'Tekrar dene' politikayı yeniden okur; geri tuşu ekranı kapatmaz.

**Güvenli düşüş:** Politika okunamıyorsa kilit yok; kilit yalnız geçerli ve 30 günden yeni bir politikadan doğar. Mağaza açılamazsa bir hata satırı ve sitenin cihaza göre yönlendiren indirme bağlantısı çıkar.

**Nasıl denenir:** Önceki mağaza build'i telefona kurulur: iOS'ta TestFlight'taki önceki build, Android'de internal app sharing (Play in-app update elle kurulan APK'da çalışmaz). Önizleme listesinde minimum, yüklü build'in üstüne çekilir; ekranın dolu açıldığı, düğmenin bu uygulamanın sayfasını açtığı ve güncellemeden sonra kilidin kalktığı görülür. Ekran görüntüsü sürüm notuna.

### 4. Yumuşak uyarı ve erteleme

Yüklü build recommendedBuild'in altındaysa kapatılabilir 'Yeni sürüm hazır' sayfası.

**Sunucu:** recommendedBuild ancak mağaza sayfası yeni build'i herkese gösterdikten sonra, izleyicinin raporu ve onayla yükseltilir. snoozeDays ve maxShowsPerVersion politikada durur.

**İstemci:** Oturumda en çok bir kez, ilk ekran çizildikten sonra. 'Daha sonra' snoozeDays boyunca susturur; aynı sürüm en çok maxShowsPerVersion kez sorulur, yeni sürümde sayaç sıfırlanır. Metin sunucudan, yoksa gömülü.

**Güvenli düşüş:** Politika yoksa hiç gösterilmez; depolama okunamazsa bir kez gösterilir. Uyarı hiçbir akışın önünü kesmez.

**Nasıl denenir:** Eski build'de önizlemeyle recommended yükseltilir: 'Güncelle' mağazaya gider, 'Daha sonra'dan sonra yeniden açılışta sayfa çıkmaz, recommended bir artınca yeniden çıkar.

### 5. Sunucudan duyuru ve ekran içi uyarı

Ana ekranda ve her kritik ekranda ilk sürümden bir duyuru alanı durur: her ana akışın sonuç ekranı, ödeme, giriş, profil ve her yeni akış. Alan notices listesinden ekran anahtarına göre dolar; boşsa yer kaplamaz. İlk mağaza sürümünden önce ajan ekran anahtarı listesini ve kill switch alacak özellik listesini koddaki ekranlardan ve özelliklerden çıkarır. Listeyi ürün sahibine onaylatır ve DECISIONS'a yazar. Listede olmayan ekrana o build'de duyuru gösterilemez, bayrağı olmayan özellik de kapatılamaz.

**Sunucu:** Duyurunun alanları: değişmeyen id, ekran anahtarı (ilk sürümde sabitlenen listeden), önem (info, warning, critical), platform, build aralığı, dil, başlangıç ve bitiş, TR ve EN metin, CTA (mağaza, izinli deep link ya da kendi alan adımız) ve kapatılabilirlik. Bilinmeyen anahtar ve izinsiz bağlantı kaydedilmez. Duyuru, incelemeden geçmemiş bir özelliği açmak için kullanılmaz (Apple 2.3.1).

**İstemci:** Platform, build ve dil süzgecini istemci uygular; yanıt herkese aynıdır ve cihazda önbelleğe alınır. Bitiş saati cihazda bir kez daha kontrol edilir. Kapatılan id cihazda saklanır. critical kapatılamaz ama ekranı kilitlemez.

**Güvenli düşüş:** Bozuk duyuru atlanır, diğerleri gösterilir. Bilinmeyen önem info sayılır; izinsiz CTA düğmesiz gösterilir. Hiçbir duyuru uygulamayı kilitlemez.

**Nasıl denenir:** Eski build aralığına bir warning gönderilir, yeni build'de görünmediği doğrulanır. Kapatılan duyuru yeniden açılışta çıkmaz. CTA deep link'i soğuk ve sıcak açılışta doğru ekrana gider.

### 6. Özellik bayrakları ve kill switch

features.<anahtar> şu biçimdedir: on, minBuild ve maxBuild. Reklam, ödeme ekranı, AI, PDF, paylaşım ve dış entegrasyon gibi her riskli özelliğin bir kapatma anahtarı olur.

**Sunucu:** Anahtar listesi kodda tanımlıdır, bilinmeyen anahtar yazılamaz. Anlamı değişen özellik yeni anahtar alır. Özelliğin sunucu ucu da aynı bayrağa bakar, istemci gizlemese de uç kapanır. Yeni özelliğin bayrağı inceleme boyunca açıktır ve inceleme notunda anlatılır; Apple gizli ya da uyuyan özelliği reddediyor (2.3.1).

**İstemci:** Her bayrağın derlenmiş güvenli varsayılanı vardır: yeni ve riskli özellik kapalı, temel işlev açık. Önbellek ekranı hemen çizer, ağ sonra uzlaştırır. Kill switch özelliğin girişini gizler; ekran açıksa kullanıcıyı geri götürür.

**Güvenli düşüş:** Ağ yoksa son iyi değer, o da yoksa derlenmiş varsayılan. Tipi yanlış gelen bayrakta varsayılan. Belirsizlikte kapalı taraf. Temel yerel işlev hiçbir bayrağa bağlanmaz.

**Nasıl denenir:** Release build'de her riskli özelliğin kill switch'i önizlemede kapatılır: giriş kaybolur, çökme olmaz, ön plana dönüşten en çok bir dakika sonra yansır. Sonra geri açılır.

### 7. Bakım modu

maintenance alanı: active, mode (read_only ya da full), message ve until. Bakımda API, politika ve sağlık ucu dışındaki uçlarda 503, error: maintenance ve Retry-After döner.

**Sunucu:** Bakımı tek middleware uygular; politika ucu bakımda da cevap verir. Mesaj iki dildedir. Mağaza incelemesi sürerken bakım açılmaz; Apple backend'in inceleme boyunca canlı olmasını istiyor (2.1(a)).

**İstemci:** maintenance kodu gelince ortak bir şerit çıkar. read_only'de yazma düğmeleri pasifleşir, okuma önbellekten; full'da ağ isteyen bölümler 'Tekrar dene' ekranına döner. Yerel işlevler açık kalır.

**Güvenli düşüş:** Bakım yalnız açık bir sinyalden çıkarılır; ağ hatası, zaman aşımı ya da 5xx bakım sayılmaz. Bakım kalıcı kilit değildir, her ön plana dönüşte yeniden sorulur.

**Nasıl denenir:** Test ortamında bakım açılır: release build'de şerit ve 503 davranışı görülür, yerel hesaplama çalışır. Kapatılınca en çok bir dakikada kalkar.

### 8. OTA kanalı ve runtime politikası (öneri)

expo-updates ilk mağaza build'inde bulunur. runtimeVersion politikası fingerprint'tir: native kod, bağımlılık ya da SDK değişince runtime kendiliğinden değişir. Kanal her EAS profiline sabittir: production, preview, development. Native klasörü depoda duran projede yalnız fingerprint ya da elle sabit çalışır; appVersion ve nativeVersion yalnız CNG'de.

**Sunucu:** Güncelleme yalnız onayla yayınlanır: önce preview kanalında telefonda, sonra --rollout-percentage ile küçük bir yüzdeyle production'a. eas update:rollback hazırda durur. Güncelleme uygulamanın amacını değiştirmez (Apple lisans sözleşmesi 3.3.1(B), Play'in yorumlanan kod istisnası). Free ayda 1.000, Starter ($19) 3.000 aktif kuruluma gönderir; açmadan önce sayı ve maliyet söylenir.

**İstemci:** checkAutomatically ON_LOAD ve fallbackToCacheTimeout 0 (varsayılanlar): uygulama eldeki paketle hemen açılır, yenisi arkada iner, sonraki açılışta uygulanır. Kritik düzeltmede bir duyuru 'yeniden başlat' der. Native kod, izin ve entitlement değişikliği OTA ile gitmez.

**Güvenli düşüş:** İndirme hatası açılışı etkilemez; runtime uyuşmayan güncelleme uygulanmaz. expo-updates yalnız ilk ekrandan önceki ölümcül JS hatasında önceki pakete döner; sonraki hatada ve native çöküşte dönmez. Asıl güvence küçük yüzdeli yayın ve geri alma komutudur.

**Nasıl denenir:** Preview profiliyle yerelde (eas build --local) test API'ye bakan release build alınır; preview kanalına görünür bir değişiklik yayınlanır, iki açılışta uygulandığı ve X-App-Update-Id'nin değiştiği görülür. İlk ekrandan önce hata veren bir güncellemeyle geri dönüş denenir. Açılışın çökmediği iki platformda doğrulanır.

### 9. Push kaydı, ilk günden ve izinli

expo-notifications ilk build'de bulunur. İzin açılışta değil, ilk değerli işten sonra istenir. Misafir de hesap da kaydedilir.

**Sunucu:** Misafir ve hesap uçları upsert yapar: gönderilebilir token, platform, sürüm, build, dil, OS sürümü, izin durumu, son görülme. Hedefleme platform, build aralığı, dil ve kitleyle; app_update yalnız recommended'ın altındakilere gider. Makbuzlar ~15 dk sonra okunur (24 saatte silinir), DeviceNotRegistered token kapatılır. Yük 4.096 baytı geçmez. Pazarlama push'u yalnız uygulama içinde açık onay vermiş ve kapatma yolu olan kullanıcıya gider (Apple 4.5.4).

**İstemci:** Android kanalları ilk sürümde ve token istenmeden önce tanımlanır; kanalın önemi sonradan değişmez. Token, dil ya da kitle değişince ve ağ dönünce kayıt yenilenir. Soğuk açılıştaki dokunuş getLastNotificationResponseAsync ile ele alınır. İzinli link ilgili ekranı açar; bilinmeyen tip yalnız uygulamayı açar.

**Güvenli düşüş:** Kayıt hatası hiçbir akışı durdurmaz, arkada yeniden denenir. Push uygulamanın çalışması için şart değildir. İzin reddi saklanır, kullanıcıya kendiliğinden bir daha sorulmaz.

**Nasıl denenir:** Release build'de izin verilir; token test veritabanında platform, build ve dille görünür. Test API'den bir app_update ve bir link'li push gönderilir; ikisine de soğuk ve sıcak açılışta dokunulur.

### 10. Sürüm dağılımı telemetrisi

Platform ve build başına son 7 günün tekil kurulum sayısı admin'de tablo olarak durur.

**Sunucu:** Politika ucu her çağrıda kurulum kimliğinin özetini, platformu ve build'i tek log satırı olarak yazar; veritabanına hiç yazmaz, yoksa her uygulama açılışı Neon'u uyandırır. Sabah penceresindeki job son 7 günün satırlarını Logging API'den okur, tekil kurulumları sayar ve özeti veritabanına yazar; ham IP ve hesap kimliği tutulmaz. Pencere 7 gündür; 28 gün eski sürümü şişirir. Zorunlu güncelleme kaydedilmeden önce kaç kurulumun kilitleneceği bu tablodan hesaplanır.

**İstemci:** Ek iş yok; başlıklar yeter.

**Güvenli düşüş:** Telemetri gitmezse uygulama etkilenmez. Sayı tek başına karar vermez; mağaza konsolu ve abonelik aracının sürüm süzgeciyle karşılaştırılır.

**Nasıl denenir:** İki cihaz, biri eski build'de, bir gün kullanılır; admin tablosunda iki satır doğru build'lerle görünür.

### 11. Mağaza sürüm izleyicisi

Her gün iki mağazada herkese açık sürümü okuyan ve politikadaki recommended ile karşılaştıran zamanlanmış iş.

**Sunucu:** iOS'ta mağaza sayfası okunur; Apple'ın arama API'si saatlerce geride kalabildiği için tek kaynak yapılmaz. Android'de Play sayfası. Okunamayan sonuç 'bilinmiyor' sayılır. Kademeli yayın yüzdesi sayfadan okunamaz, zorlama kararında konsol ayrıca kontrol edilir. İş politikayı değiştirmez, yalnız önerir; kaydetme doğrulaması bu değeri kullanır.

**İstemci:** Yok.

**Güvenli düşüş:** Sayfa okunamazsa sonuç 'bilinmiyor'; o durumda zorlama kaydedilemez, diğer değişiklikler engellenmez.

**Nasıl denenir:** Bir yayından sonra izleyicinin raporu mağaza sayfasıyla bir kez elle karşılaştırılır.

## Yayın kapısı

İlk mağaza sürümünden ve kitin her değişikliğinden önce. Her madde iki platformun release build'inde, gerçek telefonda.

- [ ] 1. Her istekte X-App-Platform, X-App-Version, X-App-Build, X-App-Locale, X-App-Channel ve X-Install-Id gidiyor (OTA paketinden X-App-Runtime ve X-App-Update-Id); değerler binary'den okunuyor ve iki platformun yerelde alınan release build'inde test API logunda görüldü.

- [ ] 2. Politika ucu prod ve test'te çalışıyor: yanıt bellekten veriliyor, admin'den kaydederken doğrulanıyor, önizleme listesi çalışıyor.

- [ ] 3. Zorunlu ekran iki platformun release build'inde görüldü: kök görünüm, metni dolu, düğme bu uygulamanın mağaza sayfasını açıyor, geri tuşu kapatmıyor, 'Tekrar dene' politikayı yeniden okuyor; ekran hiçbir sağlayıcıya bağlı değil.

- [ ] 4. Android'de Play in-app update, internal app sharing ile Play'den kurulmuş bir build'de denendi; elle kurulan build'de mağaza yedeğine düştüğü görüldü.

- [ ] 5. Yumuşak uyarı görüldü: 'Güncelle' mağazaya gidiyor, erteleme ve yeni sürümde yeniden çıkma doğrulandı.

- [ ] 6. Politika ucu kapalıyken, 500 dönerken, bozuk JSON'da ve zaman aşımında uygulama normal hızda açılıyor; ne kilit ne bakım ekranı çıkıyor (ikinci adres boşken). İkinci adres kurulduysa (öneri): uç kapalıyken oradaki duyuru görüldü; dosyaya konan zorlama alanı kilit üretmedi, bitişi geçmiş kayıt gösterilmedi.

- [ ] 7. Ana ekranda ve her kritik ekranda duyuru alanı var; ekran anahtarı listesi API ile aynı. Her önem düzeyinden bir duyuru gerçek cihazda görüldü; kapatma hafızası ve CTA deep link'i çalışıyor.

- [ ] 8. Her riskli özelliğin bayrağı ve kill switch'i var, derlenmiş varsayılanı güvenli; en az biri önizlemede kapatılıp etkisi cihazda görüldü.

- [ ] 9. İncelemeye giden build'in yeni özellikleri inceleme boyunca bayrakta açık ve inceleme notunda anlatılmış (Apple 2.3.1); bakım ve kill switch'ler kapalı, backend canlı (2.1(a)).

- [ ] 10. Bakım sinyali (politika alanı ve 503 maintenance kodu) istemcide ortak şeritle karşılanıyor; ağ hatası bakım sayılmıyor.

- [ ] 11. OTA kurulduysa (öneri): expo-updates binary'de; fingerprint politikası ve kanal eşlemesi tanımlı. preview kanalındaki güncelleme release build'de uygulandı, ilk ekrandan önce hata veren güncellemede geri dönüş denendi, eas update:rollback hazır, açılış iki platformda çökmüyor. Aylık aktif kurulum ve EAS Update maliyeti rakamla söylendi.

- [ ] 12. Push: izin akışı, misafir ve hesap kaydı, token'daki platform, build ve dil doğrulandı; token gönderilebilir biçimde saklanıyor, Android kanalları token'dan önce tanımlı. app_update ve link'li push soğuk ve sıcak açılışta denendi; bilinmeyen tip yalnız uygulamayı açıyor. Pazarlama push'u için uygulama içinde açık onay ve kapatma yolu var (Apple 4.5.4).

- [ ] 13. Admin'de son 7 günün platform ve build dağılımı görünüyor.

- [ ] 14. Duyuru CTA'ları ve push link'leri için universal link alan adları ve entitlement'lar ilk build'de var.

- [ ] 15. App Privacy ve Data safety formları kurulum kimliğini ve push token'ı kapsıyor; gizlilik metni bunları anıyor.

- [ ] 16. Geliştirme ve test build'lerinin canlı API'ye gitmediği çalışma anında doğrulandı; testler canlıya veri yazmadı.

- [ ] 17. Build numaraları binary'den ya da EAS'ten okunup sürüm notuna yazıldı; mağaza izleyicisi çalışıyor.

- [ ] 18. Yayın sonrası prosedür depodaki README'de ve ajan talimat dosyasında yazılı: recommended ne zaman çekilir, zorlamanın şartları (Play'de %100 yayın, App Store'da yayında), kim onaylar.

- [ ] 19. Bu maddelerin kanıtları (ekran görüntüsü, log satırı) sürüm notunda duruyor. Kanıtı olmayan madde yapılmamış sayılır.

## Örnek politika yanıtı

GET /v1/app/update-policy. Değerler örnektir, gerçek bir uygulamanın değerleri değildir. minimumBuild zorlamanın ileride açılabileceği tabandır; örnekte zorlama kapalı.

```
{
  "schemaVersion": 1,
  "generatedAt": "2026-10-08T09:00:00Z",
  "refreshAfterSeconds": 900,
  "update": {
    "ios": {
      "minimumBuild": 12,
      "recommendedBuild": 20,
      "recommendedVersionName": "1.4.0",
      "forceEnabled": false,
      "storeUrl": "https://<iOS mağaza sayfası>",
      "softPrompt": {"snoozeDays": 3, "maxShowsPerVersion": 3}
    },
    "android": {
      "minimumBuild": 14,
      "recommendedBuild": 22,
      "recommendedVersionName": "1.4.0",
      "forceEnabled": false,
      "storeUrl": "https://<Play mağaza sayfası>",
      "inAppUpdate": "immediate",
      "softPrompt": {"snoozeDays": 3, "maxShowsPerVersion": 3}
    },
    "messages": {
      "forced": {
        "tr": "Bu sürüm artık desteklenmiyor. Devam etmek için uygulamayı güncelleyin.",
        "en": "This version is no longer supported. Update the app to continue."
      },
      "soft": {"tr": "Yeni sürüm hazır.", "en": "A new version is ready."}
    }
  },
  "features": {
    "newCheckout": {"on": true, "minBuild": {"ios": 18, "android": 20}},
    "export": {"on": true},
    "promoBanner": {"on": false}
  },
  "notices": [
    {
      "id": "akis-v2-2026-10",
      "screen": "inbox",
      "severity": "warning",
      "platforms": ["ios", "android"],
      "build": {"ios": {"max": 17}, "android": {"max": 19}},
      "locales": ["tr", "en"],
      "startsAt": "2026-10-01T06:00:00Z",
      "endsAt": "2026-10-31T21:00:00Z",
      "title": {"tr": "Mesajlar yenilendi", "en": "Messages have changed"},
      "body": {
        "tr": "Yeni mesajları görmek için uygulamayı güncelleyin.",
        "en": "Update the app to see new messages."
      },
      "cta": {"action": "store", "label": {"tr": "Güncelle", "en": "Update"}},
      "dismissible": true
    },
    {
      "id": "gecikme-2026-10-08",
      "screen": "home",
      "severity": "info",
      "platforms": ["ios", "android"],
      "build": {},
      "locales": ["tr"],
      "startsAt": "2026-10-08T06:00:00Z",
      "endsAt": "2026-10-09T06:00:00Z",
      "title": {"tr": "Veriler bugün geç güncellenecek"},
      "body": {"tr": "Uygulamanın geri kalanı etkilenmez."},
      "cta": {"action": "deeplink", "link": "uygulama://ana-sayfa", "label": {"tr": "Aç"}},
      "dismissible": true
    }
  ],
  "maintenance": {
    "active": false,
    "mode": "read_only",
    "message": {
      "tr": "Kısa bir bakım yapıyoruz. Uygulamayı kullanabilirsiniz; kayıt ve mesajlar birazdan açılacak.",
      "en": "Short maintenance. You can keep using the app; saving and messages will be back shortly."
    },
    "until": null
  }
}
```

| Alan | Anlamı |
|---|---|
| schemaVersion | İstemcinin anladığı şema. Daha büyük sürüm gelirse istemci yalnız tanıdığı alanları okur. |
| generatedAt, refreshAfterSeconds | Önbelleğin yaşı ve ön plandayken yeniden okuma aralığı. 30 günden eski önbellek kilit üretmez. |
| minimumBuild | Mağazanın gördüğü tamsayı build (iOS CFBundleVersion, Android versionCode), pazarlama sürümü değil. Altındaki build'ler ancak forceEnabled true ise kilitlenir. |
| recommendedBuild | Altındaki build'lere kapatılabilir uyarı. Mağaza sayfası bu build'i herkese gösterince yükseltilir. recommendedVersionName yalnız uyarıda görünür, karar için kullanılmaz. |
| forceEnabled | Zorlamanın ayrı anahtarı; minimumu yükseltmek tek başına kimseyi kilitlemez. Play'de yayın %100, App Store'da yayında değilse kaydedilmez. |
| storeUrl, inAppUpdate | Bu uygulamanın mağaza sayfası; istemcide gömülü bir yedek adres de durur. inAppUpdate Android'de immediate, flexible ya da off; yalnız Play'den kurulan uygulamada çalışır. |
| softPrompt, messages | snoozeDays: 'Daha sonra'dan sonra kaç gün susulur. maxShowsPerVersion: aynı sürüm en çok kaç kez sorulur. Mesajlar iki dilde; boşsa istemcinin gömülü metni. |
| features | on, minBuild ve maxBuild. Anahtar yanıtta yoksa derlenmiş varsayılan geçerli; anlamı değişen özellik yeni anahtar alır. |
| notices | id hiç değişmez (kapatma hafızası). screen ilk sürümde sabitlenen listeden (örnek: home, result, paywall, inbox, profile, login; liste ürüne göre DECISIONS'tan). severity info, warning ya da critical. Platform, build ve dil süzgecini istemci, zaman süzgecini sunucu uygular. cta: store, izinli deeplink ya da yalnız kendi alan adımızda url. |
| maintenance | read_only yazmayı, full ağ isteyen bölümleri kapatır; yerel işlevler açık kalır. Politika ucu bakımda da cevap verir. İnceleme sürerken açılmaz. |
| Önizleme | Kurulum kimliği önizleme listesindeki cihazlar aynı şemada ayrı yanıt alır. Eski build'de zorunlu ekran, uyarı ve duyurular canlı kullanıcıya dokunmadan denenir. |

## Tuzaklar

### Sürüm ve build numarası

Build numarasını Constants.platform, app.json ya da depodan okumak. Alan boş ya da geride gelebilir; reddedilen bir EAS denemesi de numara tüketir. Doğrusu expo-application nativeBuildVersion.

Pazarlama sürümünü (2.1.0) karşılaştırmak. Platform başına tamsayı build kullanılır.

Sürüm başlığını elle yazmak. '1.0.0' sabiti hiçbir sürümde değişmez.

Sürüm dağılımını 28 günlük pencereyle saymak. Güncelleyen herkes iki grupta birden sayılır.

### Politika ve zorunlu ekran

Kilit kararını sunucunun gönderdiği bir forceUpdate boolean'ına bırakmak. Sunucu eşik verir, karşılaştırmayı istemci kendi build'iyle yapar.

Yanıtı doğrulamadan kullanmak. 'false' metni bile kilit sayılabilir.

Sürüm kontrolünü açılışta beklemek. 30 sn'lik zaman aşımı açılışı 30 sn bekletir.

Politika çağrısı başarısız olunca kilitlemek, yaşı bilinmeyen önbellekten kilit üretmek ya da ağ hatasını bakım sanmak.

Zorunlu ekranı Modal içinde ya da dil, oturum veya font sağlayıcısına bağlı çizmek.

Yayın mağazada görünmeden recommended'ı yükseltmek ya da Play'de kademeli yayın sürerken zorlamayı açmak; yüzdenin dışındaki kullanıcı indiremeyeceği sürüme gönderilir.

Mağazanın arama API'sine güvenmek. Sayfanın saatlerce gerisinde kalabiliyor.

Alan adlarını belirsiz bırakmak. 'LATEST' zorlamayı açmaz; recommended ve minimum ayrı adlarla yazılır, zorlamanın kendi anahtarı olur.

Tek dilli mesaj ve mağazanın ana sayfasına giden varsayılan adres.

Yedek politikayı gizlenebilecek bir depoda ya da başkasının adresinde tutmak.

### Duyuru, push ve bayrak

Duyuruyu sunucuda build'e göre süzüp paylaşılan önbelleğe koymak. Süzgeci istemci uygular.

Push verisinden serbest bir ekran adı ya da URL açmak. Bağlantı izin listesinden geçer.

Android bildirim kanallarını sonradan ya da token istendikten sonra kurmak. Kanalın önemi sonradan değişmez.

Token'ı yalnız oturum açmıştan almak, platform, build ve dil olmadan ya da yalnız özetini saklamak. Özetten gönderim yapılamaz.

DeviceNotRegistered makbuzlarını okumamak. Makbuz 24 saatte silinir, ölü token birikir.

Pazarlama push'unu uygulama içi açık onay ve kapatma yolu olmadan göndermek (Apple 4.5.4).

Riskli yeni özelliğin bayrağına true varsayılan vermek ya da anlamı değişen özellikte eski anahtarı yeniden kullanmak.

Yeni özelliği incelemede kapalı tutup sonra açmak, inceleme sırasında bakım ya da kill switch açık bırakmak (Apple 2.3.1 ve 2.1(a)).

### OTA ve build

OTA'yı sonradan eklemek, native değişiklik içeren paketi OTA ile göndermek ya da runtimeVersion'ı elle sabit yazmak.

Native klasörü depoda olan projede appVersion ya da nativeVersion politikası seçmek. Orada yalnız fingerprint ya da elle sabit desteklenir.

expo-updates'in her bozuk güncellemeden kendiliğinden döneceğine güvenmek. Native çöküşte ve ilk ekrandan sonraki hatada dönmez.

OTA'yı ücretsiz saymak. Free ayda 1.000 aktif kuruluma gönderir; açmadan önce sayı ve maliyet söylenir.

Build kotasını hesaba katmamak. OTA'sız her acil düzeltme bir build; ücretsiz planda platform başına ayda 15, kota bitince ayın 1'ine kadar build yok.

Universal link ya da entitlement'ı sonradan eklemek. Sonraki iOS build'i etkileşimli Apple girişi ister.

### Test ve süreç

Birim testinde build numarasını taklit edip işi bitmiş saymak.

Gerçek cihaz denemesini canlı politikayı değiştirerek yapmak. O build'deki herkes uyarıyı görür; doğrusu önizleme listesi.

Android in-app update'i elle kurulan APK ile denemek. Akış yalnız Play'den kurulan uygulamada çalışır; internal app sharing gerekir.

Simülatörün .env yüzünden canlıya gitmesi. Hedef adres çalışma anında doğrulanır, paketi grep'leyerek değil.

Belgede 'tamam' yazan ama hiç bağlanmamış bir iskeleti çalışıyor saymak. Uçtan uca bir istek ve ekran görüntüsü gösterir.

<a id="dagitim"></a>

Mobil

# Mobil build ve dağıtım: EAS mi, kendi hattımız mı

Mobil uygulamayı derleyip mağazaya ve testçiye ulaştırmanın iki yolu var: Expo'nun bulut servisi EAS ya da kendi hattımız. Bugünkü cevap: EAS Free ve ilk günden prova edilmiş bir yerel yol.

Ürün sahibinin görüşü şu: kendi dağıtım hattımızı kurarsak Expo'nun ücretsiz sınırlarına hiç takılmayız. Kendi kullanımımıza baktık. Kotayı en çok iki şey yiyor: preview build'leri ve aynı hesaptaki ikinci uygulama. İkisi bütçeye bağlanınca platform başına 15 hak yetiyor. Bizim hacmimizde Starter ayda ~$24 tutuyor; bu, kendi hattın kurulum ve bakım emeğinden ucuz. Kendi hattımız ancak EAS faturası üç ay üst üste ayda $50'ı geçerse ya da EAS'in karşılayamadığı bir ihtiyaç çıkarsa kurulur.

**15 + 15** Hesap başına aylık iOS ve Android build hakkı. Hesaptaki bütün uygulamalar paylaşır; kullanılmayan hak devretmez.
**33 build** Eylül'de: 17 iOS (6'sı preview), 16 Android (5'i preview). Haziran 33, Temmuz 11, Ağustos 28.
**22 Eylül** iOS kotasının dolduğu gün. 24 Eylül'de istenen iOS build'i reddedildi ve Ekim'e kaldı.
**7 / 15 ve 6 / 15** Ekim'in ilk 8 gününde hesapta kullanılan iOS ve Android hakkı; iki uygulama aynı hesapta.
**132 dk** En uzun Android kuyruğu; medyan bekleme 6 sn, 44 build'in 4'ü 16 dakikadan fazla bekledi. Medyan build iOS 5, Android 9 dk.
**11 / 19** 19 Eylül–7 Ekim'de çıkan mağaza build'lerinden yalnız JS olanlar: iOS'ta 9'da 4, Android'de 10'da 7. OTA olsaydı mağazaya gitmeden çıkabilirdi.

## Preview'lar buluttan çıkınca kota yetiyor

Eylül 2026, platform başına build. Kesikli çizgi ücretsiz hak. Preview'lar test için bulutta alındı.

production profilipreview profilibuild, ölçek gerçek
_Grafik: Eylül build'leri ve ücretsiz hak_

## OTA olsaydı mağazaya gitmeyecek build'ler

19 Eylül–7 Ekim 2026'da çıkan mağaza build'leri. Native değişiklik: widget, SKAdNetwork, Associated Domains, yeni native modül, sesli komut kodu.

native değişiklik vardıyalnız JSbuild, ölçek gerçek
_Grafik: Mağaza build'lerinde native ve yalnız JS payı_

## Karar tablosu

Beş yol, bizim Eylül 2026 hacmimizle. Fiyatlar 8 Ekim 2026.

### EAS Free

_Bugünkü düzen_ **Maliyet:** $0. Ayda 15 iOS ve 15 Android build, 1 eşzamanlı build, düşük öncelikli kuyruk, build başına 45 dk. 3 dk'dan kısa sürede düşen build ayda 10'a kadar sayılmaz. EAS Update 1.000 MAU. Aşım yok: kota bitince build ayın 1'ini bekler.

**Emek ve kayıp:** Kurulacak bir şey yok. Kimlik bilgileri, bulut macOS, submit, uzaktan build numarası ve panel EAS'ta.

**Risk:** Ay sonunda kota biterse acil düzeltme ayın 1'ine kalır; Eylül'de iOS'ta oldu. Preview'lar da kotadan düşer. Android kuyruğu zaman zaman 2 saati bulur.

**Ne zaman:** Platform başına aylık ihtiyaç 15'in altında kaldıkça. Eylül'ün 17 iOS build'i, preview'lar buluttan çıkınca 11'e iniyor.

### EAS Starter

_Gerekirse Production_ **Maliyet:** Ayda $19, içinde $45 build kredisi: orta boy iOS build $2, Android $1. Eylül hacmimiz $50 kredi eder, fatura ~$24. Yüksek öncelikli kuyruk, 2 saat zaman aşımı, OTA 3.000 MAU. Production ayda $199.

**Emek ve kayıp:** Yalnız plan değişikliği; bir ay alınıp iptal edilebilir. Kayıp yok.

**Risk:** Aşım dönem sonunda kesilir, fatura sessizce büyüyebilir. Kota baskısı kalkınca gereksiz build artar.

**Ne zaman:** Bir ayda platform başına 15'i geçecek build planlanıyorsa ya da kuyruk bir sürümü geciktiriyorsa, o ay için.

### EAS yerel build

_eas build --local ve eas submit --path_ **Maliyet:** $0. Build kendi Mac'imizde, mağazaya yükleme yine EAS Submit ile.

**Emek ve kayıp:** Bir kez fastlane kurulumu (iOS için şart) ve her platform için bir prova. Kaybedilen: bulut macOS ve paralel build; kimlik bilgileri, build numarası ve submit EAS'ta kalır.

**Risk:** Tek seferde tek platform, önbellek yok. Secret görünürlüklü EAS değişkenleri yerelde boş gelir; eas.json'daki imaj ve araç sürümü alanları yok sayılır, yerel Xcode buluttakinden farklı olabilir. Mac meşgulken build yok.

**Ne zaman:** Test API'ye bakan preview build her zaman burada; kota bittiğinde acil düzeltme ve bulutta düşen build'in nedenini görmek için de. İşe yaraması için ilk günden prova edilmiş olmalı.

### Kendi hattımız

_xcodebuild, Gradle, fastlane; GitHub Actions ya da kendi Mac'imiz_ **Maliyet:** Actions'ta özel depoda macOS dakikası $0,062, Linux $0,006; ayda 2.000 dk dahil. Eylül hacmi için tahmin $0–26/ay. Kendi Mac'imizde runner ücretsiz. Xcode Cloud ayda 25 saat, Codemagic 500 dk ücretsiz.

**Emek ve kayıp:** Yüksek: birkaç günlük kurulum (imza, upload anahtarı, build numarası, ortamlar, TestFlight ve Play yüklemesi) ve her SDK, React Native ve Xcode yükseltmesinde bakım. EAS'in kimlik bilgisi yönetimi, sabit bulut imajları, auto-submit ve paneli kaybedilir.

**Risk:** İmza ve anahtarlar tamamen bize geçer; upload anahtarı kaybolursa Play'de sıfırlama gerekir. Build numarası depodan okunursa mağaza reddeder. Runner Mac kapalıysa sürüm durur. Hat karar sahibini atlayıp kendi kendine submit etmemeli.

**Ne zaman:** EAS faturası üç ay üst üste $50'ı geçerse, EAS'in sunmadığı bir araç zinciri gerekirse ya da ikili dosyaların ve anahtarların yalnız kendi altyapımızda durması şart olursa. Bugün değil.

### Kendi OTA sunucumuz

_Expo Updates protokolü_ **Maliyet:** Sunucu ve depolama kendi GCP hesabımızda, küçük ölçekte ayda birkaç dolar (tahmin). Karşılaştırma: EAS Update Free 1.000, Starter 3.000 MAU; sonrası kullanıcı başına $0,005, 10.000 MAU ~$54/ay.

**Emek ve kayıp:** Orta-yüksek. Protokol uygulanır: manifest, asset, runtimeVersion eşleşmesi, imza başlığı, gömülü pakete dönüş. Expo'nun örnek sunucusu yalnız gösterim amaçlı. Kanal yönetimi, kademeli dağıtım, tek tıkla geri alma ve istatistik kaybedilir.

**Risk:** Bozuk güncelleme incelemesiz herkese gider; imza, geri alma ve runtimeVersion disiplini şart. Kod onaylı amacı değiştiremez (Apple 2.5.2 ve lisans 3.3.1(B), Play'in kendi kendini güncelleme kuralı). CodePush seçenek değil: App Center 31 Mart 2025'te kapandı.

**Ne zaman:** OTA kitte önerilir ve EAS Update Free ile başlar; son dönemde 19 build'in 11'i yalnız JS idi. Kendi sunucuya ancak MAU maliyeti ayda $50–100'ı geçerse ya da trafiğin kendi altyapımızda kalması istenirse geçilir.

## Önerilen düzen

1. Yeni uygulama EAS Free ile başlar ve hesap için aylık build bütçesi yazılır.

15 hak uygulamalar arasında, iOS ve Android ayrı bölünür; örnek: ana uygulama 10, ikinci uygulama 3, acil yedek 2. Bütçe depodaki README'de durur; her build önerisinden önce kalan hak eas account:usage ile okunur. Ayın son haftasında platform başına kalan hak 3'ün altındaysa yeni özellik build'i alınmaz, hak hata düzeltmesine saklanır. Eylül'de iOS hakkı 22 Eylül'de bitti ve bir düzeltme ayın 1'ini bir hafta bekledi; plan yapılırsa ayda $19'lık plana gerek kalmaz.

2. Test API'ye bakan release build yerelde alınır; bulutta preview build alınmaz.

Kitin ve yayın kapısının denemeleri preview profiliyle eas build --local ile alınan release build'de yapılır; bu build test API'ye bakar ve kota yemez. iOS'ta ad hoc kurulum için Firebase App Distribution ücretsiz, build'ler 150 gün kalır. TestFlight internal ve Play internal track'teki production build prod API'ye bakar: orada yalnız salt okunur bir duman kontrolü yapılır, testçi canlıya veri yazmaz.

3. Yerel yol ilk günden kurulur ve prova edilir.

eas build --local ve eas submit --path. fastlane Homebrew ile kurulur, ANDROID_HOME tanımlanır, diskte yer açılır. Kimlik bilgileri ve uzaktan build numarası EAS'ta kalır. Her SDK yükseltmesinden sonra iki platformda bir kez denenir.

4. Ortamlar baştan ayrılır.

eas.json'da her profile environment alanı yazılır: preview test API'ye, production prod API'ye bakar. Prod adresi yalnız EAS production ortamında durur, yerel .env test adresini gösterir.

5. eas-cli güncel tutulur, App Store Connect API anahtarı EAS'a kaydedilir.

20.2'den beri etkileşimsiz iOS build'i bu anahtarla provisioning profilini doğrulayıp onarabiliyor; yeni bir capability eklenince Apple girişi beklenmez.

6. Native klasörler için tek yol seçilir.

Ya hep CNG ile üretilir (depoda tutulmaz) ya da hep depoda tutulur; ikisi karışınca yerel build ile bulut build'i ayrışır. EAS build imajı eas.json'da sabitlenir, yerel Xcode aynı ana sürümde tutulur.

7. Bütçe aşılacaksa o ay Starter alınır.

$19 ve aşım. Kendi hatta ancak EAS faturası üç ay üst üste $50'ı geçince başlanır; ilk adım iOS için Xcode Cloud (25 saat) ya da Codemagic (500 dk), Android için GitHub Actions Linux runner.

8. OTA planı, güncelleme indiren kullanıcı sayısına göre seçilir.

1.000'in altında EAS Update Free, 3.000'e kadar Starter yeter; üstünde maliyet kendi sunucuyla karşılaştırılır. OTA'dan önce runtimeVersion politikası (fingerprint) ve kod imzalama kararlaştırılır.

9. Build, submit, OTA yayını ve sürüm numarası yalnız açık talimatla yapılır.

İş bitince tek satır rapor verilir ve karar beklenir.

## Tuzaklar

Kota platform ve hesap başına sayılır. Yalnız bir uygulamanın build listesini saymak kalan hakkı fazla gösterir; doğru kaynak eas account:usage. Bizde kaldığı sanılan iki hak Android'indi; iOS kotasının dolduğu iki gün sonra fark edildi.

Preview build'leri de kotadan düşer: Eylül'deki 33 build'in 11'i preview idi.

3 dakikadan kısa sürede düşen build sayılmaz, ama ayda en çok 10 build için; geç düşen build hak yer.

Reddedilen build de uzaktan build numarasını artırır. Gerçek numara depodan değil eas build:list'ten okunur.

Fatura dönemi 00:00 UTC'de, yani 03:00 TSİ'de döner; gece yarısı TSİ'de kota henüz yenilenmemiştir.

Ortam sızar: Expo 54'te .env, Metro'ya verilen değişkeni ezer. Düz xcodebuild ya da gradlew kabukta değişken yoksa .env'deki adresi pakete koyar; eas build --local EAS ortamını okur ama secret görünürlüklü değişkenleri getirmez.

Yeni bir iOS capability etkileşimsiz build'i kırabilir: kayıtlı profil eskiyse Apple girişi gerekir. eas-cli 20.2 ve EAS'a kayıtlı App Store Connect anahtarı bunu etkileşimsiz çözer; kendi hatta da aynı sorun çıkar.

Kendi hatta Android upload anahtarı EAS'tan indirilip güvenli saklanır. .gitignore *.jks, *.p8, *.p12 ve *.key ile birlikte *.keystore'u da dışlar.

New Architecture kararı EAS_BUILD_PLATFORM gibi EAS'e özgü bir değişkene bağlanırsa EAS dışındaki build farklı yapılandırma gömer; asıl anahtar native dosyalardadır.

Bulut ile yerel Xcode farklıysa yerelde bulutta görülmeyen derleme hataları çıkar; imaj eas.json'da sabitlenir.

OTA yalnız JavaScript paketini değiştirir. Native pakette duran kod (sesli komutun hesap motoru, widget) güncellenmez; bir hesap düzeltmesi OTA ile gelirse uygulama ile native taraf farklı sonuç verir.

## Her build'den önce

- [ ] Build önermeden önce eas account:usage çalıştırıldı; iOS ve Android için kalan hak ayrı ayrı söylendi.

- [ ] Aylık bütçe (uygulama ve platform) güncel; bu build'in hangi satırdan düştüğü belli.

- [ ] Gerçekten bulut build'i gerekiyor; yerel derleme ya da internal track yetmiyor.

- [ ] Build'in baktığı API kontrol edildi: EAS ortamı, .env ve .env.local.

- [ ] Yeni capability ya da entitlement varsa Apple girişi ya da EAS'te kayıtlı API anahtarı hazır.

- [ ] Build sonrası gerçek numara eas build:list'ten okundu; mağazada yayınlanınca politikadaki recommended güncellendi.

- [ ] Release build'de telefon kontrolü yapıldı: güncelleme uyarısı, ana akış, ödeme ekranı, bildirim.

- [ ] Yerel yol son SDK yükseltmesinden sonra iki platformda prova edildi: fastlane, CocoaPods, JDK 17, ANDROID_HOME, disk ve buluttakiyle aynı Xcode.

- [ ] OTA yayınıysa değişiklik yalnız JS ve görsel, runtimeVersion doğru, native taraf etkilenmiyor, güncelleme imzalı.

- [ ] Build, submit, sürüm numarası ya da OTA yayını için açık talimat var.

### Doğrulanamayanlar

8 Ekim 2026'da resmi sayfalardan ya da ölçümle teyit edilemeyenler.

Starter'da $45 kredinin yanında ücretsiz 15+15 hakkın kalıp kalmadığı resmi sayfada yazmıyor; kalmadığını varsaydık.

GitHub, macOS dakikasının dahil 2.000 dakikayı hangi oranda tükettiğini artık açıkça yazmıyor; aylık tutar bu yüzden $0–26.

GitHub Actions ve Xcode Cloud'da iOS build süremiz ölçülmedi; 25 dakika ve maliyeti tahmin.

eas build --local'ın uzaktan build numarasını artırıp artırmadığı ve panelde görünüp görünmediği belgede yok; ilk provada eas build:list ile bakılır.

OTA için güncelleme indirecek aylık kullanıcı sayımız bilinmiyor; MAU eşiği buna göre netleşir.

Expo yalnız 3 dakikadan kısa sürede düşen build'in sayılmadığını yazıyor; iptal edilen build için açık kural yok.

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

<a id="icerik"></a>

E-posta ve paylaşım

# İçerik otomasyonu

İçerik otomasyonu da [Mobil uzaktan kontrol kiti](#mobilkit) gibi, otomatik paylaşım açılmadan kurulan bir altyapıdır. Elle ya da tarayıcı ajanıyla paylaşım her gönderide bir insanın zamanını yer, sessizce bozulur ve X'in kurallarına göre hesabı riske atar.

**Kural:** Hat kurulmadan otomatik paylaşım açılmaz.

Sunucudan, resmi API'lerle, onaylı ve kayıtlı paylaşım yapan bir hat gerekir: şirkete ait hesaplar ve uygulamalar, token kasası ve süre izleyici, tekilliği olan yayın kuyruğu, platform başına görsel çizici, insan onayı, denetim kaydı, deploy gerektirmeyen kapatma anahtarı ve harcama tavanı. Platform kuralları ve fiyatları sık değişir; X 2026'da fiyat modelini iki kez değiştirdi. Bu yüzden tavan, alarm ve kapatma anahtarı seçenek değil, şarttır.

**30 gün** X kredisi bitmişti; her gün denenen paylaşım 402 aldı ve kimse fark etmedi.
**~13 kat** X'te bağlantılı gönderi bağlantısıza göre: $0,20 ve $0,015.
**60 gün** Meta kullanıcı token'ının ömrü; süresiz system user token'ına geçildi.

## Bizde ne oldu

Ürün C Temmuz 2026 sonundan beri her sabah sunucudan paylaşıyor; Ürün A taslakları yapay zekâyla hazırlayıp insan onayıyla elle paylaşıyor. Kırmızı kenarlı kartlar bozulan şeyleri anlatır.

### 1. Bugün ne çalışıyor

Ürün C her sabah günün içeriğini, pazartesi haftalık, ayın ilk günü aylık 'en çok bakılanlar' raporunu sunucudan otomatik paylaşıyor. Instagram karuseli Temmuz 2026 sonundan, X Ağustos 2026 başından beri açık. İş her sabah zamanlayıcıyla çalışıyor; yarım saat sonra aynı iş bir kez daha çalışıyor ve yapılmış adımları atlıyor. Görseller sunucuda çiziliyor: 1080x1350, PNG, fontlar tam TTF olarak programın içine gömülü. Metinler şablondan üretiliyor, yapay zekâ kullanılmıyor. Instagram için görseller herkese açık okunan ama listelenemeyen bir depoya yükleniyor ve Instagram onları o adresten çekiyor. X'e ise dosya olarak yükleniyor.

### 2. Her paylaşım bir satır

Her günlük X paylaşımı veritabanında bir satır, raporların X durumu da rapor satırında duruyor. Tekillik anahtarı platform, içerik türü, içerik ve gün. Durumlar: bekliyor, medya yükleniyor, yayınlanıyor, yayınlandı, başarısız, belirsiz, silindi. Sağlayıcının gönderi kimliği tekil indeksle ve kalıcı bağlantıyla saklanıyor. Gönderi oluşturma isteği zaman aşımına ya da yanıtsız bir bağlantı hatasına düşerse durum 'belirsiz' oluyor ve tekrar denenmiyor, çünkü gönderi gitmiş olabilir. Yalnız 429 ve 5xx yanıtları Retry-After'a uyarak toplam en çok üç denemeye kadar tekrarlanıyor.

### 3. Yayından önce hesap kontrolü

Her X yayınından önce hesabın kendisi okunuyor; token beklenen kullanıcı adına ait değilse paylaşım yapılmıyor. Admin silme ucu da silmeden önce aynı kontrolü yapıyor. Her platformun ayrı açma kapama bayrağı var ve varsayılanı kapalı. Bir platformun hatası diğerlerini ve kullanıcı e-postalarını durdurmuyor. Adminlere her gün görselleri, metni ve platform durumlarını içeren bir inceleme e-postası gidiyor.

### 4. Bayrak ortam değişkeninde

Bayraklar ortam değişkeni. Kapatmak derleme istemiyor ama canlı serviste yeni bir revizyon istiyor ve bunu yalnız canlıya yetkisi olan biri yapabiliyor. Deploy yalnız imajı değiştiriyor, elle girilen ortam değerlerine dokunmuyor; elle değiştirilen token bir sonraki deploy'da ezilmedi.

### 5. X kredisi bitti, bir ay fark edilmedi

Son başarılı X paylaşımı 27 Ağustos'taydı. 28 Ağustos ile 27 Eylül arasında 30 günlük paylaşım denemesi '402 Payment Required: credits depleted' yanıtı aldı. Akış sırayla hesabı okuyor, medyayı yüklüyor ve gönderiyi oluşturuyor; yalnız son adım 402 aldı. Yani 'token sağlam mı' kontrolü bu arızayı göstermedi. Durum her gün inceleme e-postasında bir satırdı, ayrı alarm yoktu; ürün sahibi 'X çalışmıyor' deyince bakıldı. 27 Eylül'de X bayrağı kapatıldı. Bunun için gereken canlı servis güncellemesini ajanın izni olmadığı için ürün sahibi kendi terminalinden çalıştırdı. 7 Ekim'de kredi yüklendi ve bayrak açıldı. O sabahki iş bayrak kapalıyken çalıştığı için günün paylaşımı yalnız X'i yeniden deneyen ayrı uçla 23 dakika gecikmeyle atıldı.

### 6. Loglar 30 günde silindi

Bulut kayıtları 30 gün tutuluyor. 8 Ekim'de 402 satırlarından yalnız 9 Eylül ve sonrasına ait 20 tanesi kayıtlarda duruyordu, ilk 11 günün satırları silinmişti. 30 denemenin tamamı yalnız veritabanındaki paylaşım tablosunda görülebildi. Ders: denetim kaydı log değil, tablodur.

### 7. Bağlantı 13 kat pahalı

X 20 Nisan 2026'dan beri bağlantı içeren gönderiyi $0,20, bağlantısızı $0,015 ile fiyatlıyor, yani yaklaşık 13 katı. X çıplak alan adını da bağlantıya çeviriyor. 5 Ekim'de Ürün C'nin X metinlerinden adres tamamen çıkarıldı, adres artık görselin içinde. Instagram açıklamaları bağlantıyı koruyor.

### 8. Instagram token'ı öldü

Instagram token'ının süresi doldu. Token 27 Eylül öğlen (Türkiye saati) doldu; o sabahki paylaşım dolmadan yapılmıştı. 28 Eylül sabahki ilk denemede Graph API 'Session has expired' (kod 190, alt kod 463) döndü ve günlük paylaşım ile haftalık rapor birlikte düştü. Bitiş, Instagram otomatik yayınının açıldığı günden yaklaşık 60 gün sonraya denk geliyor. Aynı sabah token, Business Manager'da açılan bir system user'ın süresiz token'ıyla değiştirildi; token kontrol aracında hem bitiş hem veri erişimi süresiz göründü. İki paylaşım, yalnız Instagram adımını yeniden çalıştıran ve yayınlanmışı atlayan uçlarla, e-posta tekrar gitmeden, yaklaşık bir saat yirmi dakika gecikmeyle çıktı. Meta uygulaması geliştirme modundaydı; kendi hesabımıza yayın için bu sorun olmadı.

### 9. Hata yolu da bozuktu

Aynı olayda haftalık raporun başarısız Instagram adımı veritabanına yazılamadı. Kod durum sütununa sütunun kısıtının kabul etmediği bir değer yazmaya çalıştı, güncelleme düştü ve rapor, e-postalar gittiği halde 'bekliyor' durumunda, metni ve sayıları olmadan kaldı. Ders: hata yollarını da test et, durum değerlerini tek yerden üret.

### 10. FINISHED ama yayınlanmıyor

3 Ekim'de Instagram karuseli 'FINISHED' durumundayken yayın isteği 'Media ID is not available' (kod 9007, alt kod 2207027) ile reddedildi. Yeni ve büyük slaytların işlenmesi uzun sürüyordu. Kap durumu zaten 2 saniye arayla en çok 12 kez okunuyordu; buna ek olarak yalnız bu hata için 5, 10, 15 saniye artan aralıkla en çok 6 deneme eklendi. Bu güvenli, çünkü hiçbir şey yayınlanmamış. Başka her hata hemen geri dönüyor, böylece bir gönderi asla iki kez çıkmıyor.

### 11. Anahtarlar secret manager'a taşındı

Sosyal API anahtarları önce düz ortam değişkenindeydi ve görsel deposu listelenebiliyordu; listede yayınlanmamış taslak görseller de görünüyordu. 28 Eylül'deki güvenlik incelemesinden sonra anahtarlar secret manager'a taşındı. API kendi servis hesabıyla çalışıyor, secret'lara erişim secret bazında verilmiş, proje düzeyinde secret okuma yetkisi yok. Depoda listeleme kapatıldı, yalnız nesne okuma herkese açık kaldı.

### 12. Öbür üründe taslak ve onay

Ürün A'da API entegrasyonu yok. Haftada üç gün zamanlanmış bir görev üç taslak hazırlıyor (veri kartı, kavram kartı, özellik sayfası) ve her biri için X, LinkedIn ve Instagram metni yazıyor. Taslakları yapay zekâ yazıyor. Yayın tarayıcıdan yapılıyor, ürün sahibinin 'paylaş' onayını bekliyor ve son tıklama ona kalıyor.

### 13. Tarayıcıyla paylaşım altyapı değil

Tarayıcı ajanı dosya ekleyemiyor, görsel dosyasını insan seçiyor. Ajanın güvenlik denetimi yayın düğmesine basmayı, yazma sayfasını açmayı, yayınlanmış gönderiyi düzenlemeyi ve profil bilgisi değiştirmeyi engelliyor. Sonuçta her gönderinin son tıklaması ürün sahibine kalıyor; 7 Ekim'de LinkedIn ve Instagram'ı ürün sahibi elle paylaştı. Üstelik X'in geliştirici kuralları API dışı otomasyonu, tarayıcı betiği dahil, kalıcı askı sebebi sayıyor; tarayıcı ajanıyla X'e paylaşım bu riski taşıyor.

### 14. LinkedIn gönderisi listede yok

LinkedIn şirket sayfası gönderileri yayında olduğu halde yönetici listesinde ve üye görünümünde çıkmadı. Aynı metni yeniden göndermek 'daha önce paylaşılmış' uyarısı verdi. Yirmi dakikada altı bağlantılı gönderim spam süzgecine takılmış olabilir; ürün sahibinin elle attığı gönderiler de listede çıkmadı, gönderinin kendi bağlantısı ise açıldı. Ders: doğrulamayı listeyle değil, gönderinin kendi bağlantısıyla yap. Gönderiler arasında birkaç dakika bırak. Aynı içerikten iki üç kopya çıkmış olabilir.

### 15. Görsel dersleri

1200x630 kartlar Instagram profil ızgarasında (3:4 kırpma) yazısı kesik göründü. Çözüm 1080x1350 tuval, kart tam genişlikte ve kendi zemini üstünde. Web sitesinin alt küme fontlarıyla çizilen görsellerde ğ, ş ve İ ince ve kopuk çıktı; tam TTF dosyası kullanınca düzeldi. X bağlantı kartını tam genişlikte, LinkedIn küçük önizleme olarak gösteriyor. LinkedIn tarayıcıda önizlemeyi metindeki son bağlantıdan kuruyor.

## Hattın on bir parçası

Her parçada ne yapar, sunucuda nerede durur, bir şey bozulunca ne olur ve açmadan önce nasıl denenir.

### 1. Hesap ve uygulama sahipliği

Tüm sosyal hesaplar, Meta Business portföyü, X geliştirici hesabı ve LinkedIn uygulaması şirketin ortak adresine kayıtlı. En az iki yönetici, hepsinde iki adımlı doğrulama. Instagram profesyonel hesap ve Facebook Sayfasına bağlı. Meta uygulaması işletmeye bağlı. X hesabında 'Automated' etiketi ve biyografide işleten hesap yazılı.

**Sunucu:** Sunucu dışı, kurulum işi. Kim hangi hesabın yöneticisi, hangi uygulama hangi işletmede, bir tabloda yazılı.

**Güvenli düşüş:** Bir kişinin hesabı kapanırsa ya da şifresi değişirse hat durmaz, çünkü token'lar kişiye değil system user'a ya da şirket hesabına bağlı.

**Nasıl denenir:** İkinci yöneticiyle giriş yapılıp her platformda gönderi silme ve token yenileme yetkisi denenir.

### 2. Token kasası ve süre izleyici

Token'lar secret manager'da durur, servis hesabı yalnız kendi secret'larını okur. Ayrı bir tabloda her token için yalnız üst bilgi tutulur: platform, tür (OAuth 1.0a, 60 günlük, süresiz system user), kapsamlar, bitiş tarihi, veri erişimi bitiş tarihi, son başarılı kontrol, son hata. Günlük iş her platformu yoklar: X'te hesabın kendisini okur ve beklenen kullanıcı adıyla karşılaştırır, Meta'da debug_token ile geçerlilik, bitiş ve veri erişimi tarihini okur, Instagram ve Threads'te kalan yayın kotasını okur. 60 günlük token'lar 14, 7 ve 1 gün kala alarm verir; Instagram girişli ve Threads token'ları bu iş tarafından otomatik yenilenir.

**Sunucu:** API içinde dahili bir uç ve zamanlanmış iş, sonuç veritabanı tablosuna ve alarm kanalına.

**Güvenli düşüş:** Kontrol başarısızsa o platformun yayını otomatik durur ve tek satırlık alarm gider. Token değeri hiçbir log, hata mesajı ya da adres satırında yer almaz. Token adres parametresi olarak değil başlıkta gönderilir, çünkü ağ hatasında istemci kütüphanesi tam adresi hata metnine koyar ve o metin log ve veritabanına yazılır.

**Nasıl denenir:** Bilerek bozuk ya da iptal edilmiş bir token'la iş çalıştırılır; alarmın geldiği ve yayının durduğu görülür. 60 günlük token için bitiş tarihi ileri sarılmış bir sahte kayıtla uyarı eşikleri denenir. Ağ hatası taklit edilip hata metninde token olmadığı doğrulanır.

### 3. Yayın kuyruğu, tekillik ve yeniden deneme

Her paylaşım bir satır. Tekillik anahtarı platform, içerik türü, içerik kimliği ve gün. Durum makinesi: bekliyor, onay bekliyor, medya yükleniyor, yayınlanıyor, yayınlandı, başarısız, belirsiz, silindi. Medya kimlikleri, sağlayıcı gönderi kimliği, kalıcı bağlantı ve deneme sayısı saklanır. Yeniden deneme yalnız güvenli hatalarda: 429 ve 5xx (Retry-After'a uyarak), Instagram 9007 ve 2207027. Gönderi oluşturma zaman aşımına düşerse durum belirsiz olur ve insan bakana kadar tekrar denenmez. Her platform bağımsız: biri düşerse diğerleri devam eder.

**Sunucu:** API veritabanında tablo; yayın işi zamanlanmış dahili uçtan tetiklenir. Yalnız tek platformu yeniden deneyen ve yayınlanmışı atlayan ayrı uçlar vardır.

**Güvenli düşüş:** Aynı içerik iki kez yayınlanamaz, çünkü satır eklenemez. Belirsiz satır alarm üretir ve elle kontrol ister. Kalıcı bağlantı kaydedilmeden yayın tamamlanmış sayılmaz. Durum değerleri tek yerden üretilir ve tablo kısıtıyla aynıdır.

**Nasıl denenir:** Sahte sunucuyla 429, 5xx, zaman aşımı, 402, 190 ve 9007 yanıtları verilir; her birinde durumun ve deneme sayısının beklendiği gibi olduğu, başarısız durumun da tabloya yazılabildiği birim testlerle doğrulanır. Aynı işi iki kez çalıştırınca ikinci çalışmanın 'atlandı' döndüğü görülür.

### 4. Platform başına görsel çizici

Görseller sunucuda veriden çizilir. Fontlar tam TTF olarak programa gömülür, alt küme web fontu kullanılmaz. Hazır boyutlar: Instagram ve Threads için 1080x1350 (4:5), X için 1080x1350 ya da 1200x675, LinkedIn için 1080x1350 ya da 1200x627. Instagram için JPEG ve sRGB, 8 MB altı. Karuselin bütün slaytları aynı oranda, çünkü Instagram hepsini ilk görselin oranına kırpar. Adres ve marka görselin içinde, böylece bağlantısız X gönderisi de adresi taşır.

**Sunucu:** API içinde çizim kodu; çıktı herkese açık okunan ama listelemeye kapalı bir depoya yüklenir, adres önbelleğe uygun ve kalıcıdır.

**Güvenli düşüş:** Görsel ölçü ve boyut kontrolünden geçmezse yayın başlamaz. Görsel adresi bot korumasının arkasında değildir ya da Meta'nın çekicisine açıktır. Metin taşarsa kelime sınırında kesilir.

**Nasıl denenir:** Türkçe karakterli (ğ, ş, İ, ı) en uzun başlıkla altın görüntü testi. Her boyut Instagram profil ızgarası kırpmasıyla (3:4) kontrol edilir. Görsel adresi oturum açmamış bir istemciden 200 dönmeli, depo listesi 403 dönmeli.

### 5. İnsan onayı

Taslak üretildiğinde admin'e görsel ve platform metinleriyle bir inceleme gider (e-posta ya da admin paneli). Tek tıklık 'onayla' satırı onay bekliyor durumundan bekliyor durumuna geçirir, yayını sunucu yapar. Şablonlu ve veriye dayalı tekrar eden paylaşımlar (günün içeriği gibi) açık bir kararla otomatik onaylı olabilir; kampanya, duyuru, yeni şablon ve yapay zekâ ile yazılmış metin her zaman onay ister.

**Sunucu:** Admin panelinde onay ekranı, API'de onay ucu; onaylayan ve zaman denetim kaydına yazılır.

**Güvenli düşüş:** Belirli süre içinde onaylanmayan taslak yayınlanmaz, süresi geçer. Onay ekranı yayından önce son metni ve görseli gösterir, onaydan sonra değişiklik yeni onay ister.

**Nasıl denenir:** Onaysız taslağın hiçbir koşulda yayınlanmadığı, süresi geçen taslağın atlandığı ve onay sonrası tek bir yayın çıktığı uçtan uca denenir.

### 6. Denetim kaydı

Her yayın girişimi için kalıcı satır: kim onayladı, hangi metin ve görsel, hangi token türü, hangi platform yanıtı, sağlayıcı gönderi kimliği, kalıcı bağlantı, tahmini maliyet, silindiyse ne zaman ve kim sildi.

**Sunucu:** Veritabanı tablosu; loglar yalnız ek bilgi. Admin panelinde listelenir.

**Güvenli düşüş:** Bulut logları 30 gün sonra silinir; olay incelemesi tabloyla yapılır. Kayıt yazılamazsa yayın tamamlanmış sayılmaz ve alarm gider.

**Nasıl denenir:** Bir ay önceki bir yayının kim tarafından, hangi metinle onaylandığı ve kalıcı bağlantısı yalnız tablodan bulunabilmeli.

### 7. Kapatma anahtarı

Platform başına ve hepsi için bir anahtar. Deploy ya da yeni revizyon gerektirmez, sunucudaki bayrak tablosundan okunur. Varsayılan değer kapalı. Anahtar kapalıyken taslak üretimi ve inceleme sürer, yalnız yayın durur.

**Sunucu:** Bayrak tablosu ve admin panelinde anahtar; ortam değişkeni yalnız acil yedek.

**Güvenli düşüş:** 402, 190, 368 ya da hesap kısıtlaması görülünce ilgili platformun anahtarı otomatik kapanır ve alarm gider. Yeniden açmak insan kararıdır ve kaçan gün için yalnız o platformu yeniden deneyen uç kullanılır.

**Nasıl denenir:** Anahtar kapatıldıktan sonraki ilk zamanlanmış işin yayın yapmadığı, açıldıktan sonra kaçan gün için yalnız elle yeniden deneme yapıldığı görülür.

### 8. Maliyet tavanı

X Developer Console'da dönem başına harcama tavanı ayarlı. Otomatik yükleme açıksa tutarı ve eşiği belli. Bakiye API ile okunamadığı için uygulama içinde aylık bütçe sayacı tutulur: her X çağrısının birim fiyatı tabloya yazılır, bağlantılı gönderi ayrı sayılır. Bağlantı içeren X gönderisi yalnız açık kararla atılır, varsayılan metin bağlantısızdır. Metin yapay zekâyla üretiliyorsa çalışma başına tavan konur.

**Sunucu:** API içinde sayaç tablosu ve günlük özet; tavanın yüzde 80'inde uyarı.

**Güvenli düşüş:** Tavan aşılınca X yayını durur, diğer platformlar sürer. 402 ilk kez görüldüğünde alarm gider, özet e-postasında bir satır olarak kalmaz. Harcama tavanına ya da sıfır bakiyeye gelinmesi de aynı alarmı üretir.

**Nasıl denenir:** Sayaç tavanın hemen altına çekilerek bir sonraki yayının durduğu ve uyarının geldiği denenir.

### 9. Hata sınıflandırma ve alarm

Her platform yanıtı bir sınıfa düşer: tekrar denenir (429, 5xx, Meta 1, 2, 4, 17, 32, 341, 613, 80002, Instagram 9007), insan ister ve platformu durdurur (X 401, 402, 403; Meta 190 ve alt kodları, 10, 200 ile 299, 368, 506; LinkedIn 401, 403), belirsiz (zaman aşımı). İnsan isteyen ve belirsiz sınıflar ilk seferde tek satırlık alarm üretir.

**Sunucu:** API içinde ortak hata eşleyici; alarm kanalı e-posta ya da anlık bildirim.

**Güvenli düşüş:** Aynı arıza her gün yeniden alarm üretir, susturulmadıkça kapanmaz. Sessiz kalan bir platform (beklenen gün yayın yok) da alarmdır.

**Nasıl denenir:** Her hata sınıfı için sahte yanıtla alarmın geldiği ve platformun durduğu denenir. Yayın yapılmayan bir günün ertesi sabah raporlandığı görülür.

### 10. Yayın sonrası doğrulama ve silme

Yayından sonra kalıcı bağlantı sağlayıcıdan okunur ve kaydedilir. Doğrulama listeyle değil, gönderinin kendi bağlantısıyla yapılır. Admin panelinden tek tıkla silme, silme sonucu da denetim kaydına yazılır.

**Sunucu:** API'de silme ucu, admin panelinde düğme.

**Güvenli düşüş:** Silme isteği 'bulunamadı' yanıtı alırsa başarılı sayılır. Yanlış hesaba paylaşımı ve silmeyi önlemek için her yayından ve silmeden önce token'ın beklenen hesaba ait olduğu kontrol edilir.

**Nasıl denenir:** Test hesabında yayınla, kalıcı bağlantıyı aç, admin'den sil, bağlantının artık açılmadığını gör.

### 11. Kuru çalışma ve test ortamı

Kuru çalışma modunda hat görseli çizer, metni üretir, incelemeyi gönderir ve kuyruğa yazar ama hiçbir platforma istek atmaz. Test ortamı ayrı token'larla ayrı test hesaplarına bağlanır ya da yayını kapalı tutar. Canlı hesaba test verisi gitmez.

**Sunucu:** Ortam başına ayrı bayrak ve ayrı secret'lar.

**Güvenli düşüş:** Test ortamı canlı hesap token'ını okuyamaz; secret erişimi ortama göre ayrılmıştır.

**Nasıl denenir:** Kuru çalışmayla bir haftalık akış uçtan uca çalıştırılır, platform tarafında hiçbir istek görülmez, kuyrukta beklenen satırlar oluşur.

## Açılış kapısı

Otomatik paylaşım ilk kez açılmadan ve her yeni platform eklenmeden önce. Her madde yazılı cevaplanır.

- [ ] 1. Bütün sosyal hesaplar, Meta Business portföyü, X geliştirici hesabı ve LinkedIn uygulaması şirket hesabına kayıtlı; en az iki yönetici ve iki adımlı doğrulama var.

- [ ] 2. Instagram hesabı profesyonel ve Facebook Sayfasına bağlı, Sayfa PPA istiyorsa tamamlandı; Meta uygulaması işletmeye bağlı ve gerekli izinler Standard Access ile çalışıyor. Başka hesaplara erişim gerekecekse Business Verification ve App Review tamamlandı, yıllık Data Use Checkup takvimde.

- [ ] 3. Meta için süresiz system user token'ı, X için kullanıcı bağlamlı ve 'Read and write' izniyle üretilmiş token var. 60 günlük token kullanılan her yerde (Instagram girişli yol, Threads, LinkedIn) yenileme işi ve 14, 7, 1 gün uyarısı çalışıyor.

- [ ] 4. Bütün token'lar secret manager'da, secret bazında erişimle; hiçbiri depoda, düz ortam değişkeninde, logda, hata metninde ya da adres satırında yok.

- [ ] 5. Günlük sağlık işi çalışıyor ve bilerek bozulmuş bir token'la alarmın geldiği görüldü.

- [ ] 6. Yayın kuyruğunda tekillik anahtarı var; aynı işi iki kez çalıştırmak ikinci yayını üretmiyor. Zaman aşımı belirsiz sayılıyor ve tekrar denenmiyor. Başarısız durumlar da tabloya yazılabiliyor.

- [ ] 7. Platform başına kapatma anahtarı sunucudan, deploy'suz çalışıyor ve varsayılanı kapalı.

- [ ] 8. X harcama tavanı ve otomatik yükleme kararı verildi; bağlantılı gönderi kuralı yazılı; 402 ilk seferde alarm üretiyor ve X yayınını durduruyor.

- [ ] 9. X hesabında 'Automated' etiketi açık, biyografide işleten hesap yazılı. Metinler yapay zekâyla üretilecekse X'in ön onay kuralı okundu ve karar yazıldı.

- [ ] 10. Görsel çizici her platform boyutunda Türkçe karakterlerle test edildi; Instagram ızgara kırpmasında yazı kesilmiyor; görsel adresleri oturumsuz istemciden açılıyor, depo listelenmiyor.

- [ ] 11. İnsan onayı adımı çalışıyor; hangi şablonların otomatik onaylı olduğu yazılı bir karar.

- [ ] 12. Denetim kaydı tablosu dolu ve admin panelinde görünüyor; kalıcı bağlantı kaydedilmeden yayın tamamlanmış sayılmıyor.

- [ ] 13. Kuru çalışma modunda bir haftalık akış hatasız geçti.

- [ ] 14. Admin panelinden silme denendi.

- [ ] 15. Her yayından ve silmeden önce token'ın beklenen hesaba ait olduğu kontrol ediliyor.

- [ ] 16. Platform kuralları okundu: X'te tekrar eden içerik yasağı, API dışı otomasyon yasağı ve otomatik hesap etiketi; Instagram 24 saatte 100 yayın; Threads 250 yayın ve 1.000 yanıt; LinkedIn Development katmanında günde 500 çağrı.

- [ ] 17. LinkedIn Community Management API başvurusu tüzel kişilik ve iş e-postasıyla yapıldı ya da LinkedIn'in bu sürümde elle kalacağı açıkça kararlaştırıldı. Kullanılan API sürümlerinin kapanış tarihleri takvimde.

## Platformlar

Ekim 2026 itibarıyla resmi belgelerden. Fiyat ve kurallar sık değişir; açmadan önce bölüm sonundaki [Kaynaklar](#icerik-kaynaklar) listesindeki sayfalar yeniden okunur.

### X API v2 (gönderi ve medya)

**Ne sağlar:** Kullanıcı adına metin gönderisi, en çok 4 fotoğraf ya da 1 GIF ya da 1 video ile gönderi, yanıt, gönderi silme, hesabın kendi bilgisini okuma. Medya önce yükleme ucuna gider, dönen medya kimlikleri gönderiye eklenir. 20 Nisan 2026'dan beri self-serve erişimde API ile takip etme, beğeni ve alıntı gönderi yok.

**Erişim ve fiyat:** 6 Şubat 2026'dan beri kullandıkça öde modeli var: abonelik yok, Developer Console'dan önceden kredi alınır, her istekte düşülür. 20 Nisan 2026'dan beri gönderi oluşturma istek başına $0,015, bağlantı içeren gönderi $0,20, çağrılan (summoned) yanıt $0,010. Okumalar kaynak başına: kullanıcı $0,010, gönderi $0,005. Uygulama sahibinin kendi verisini okuyan belirli uçlar (kendi gönderileri, takipçileri, yer imleri gibi) kaynak başına $0,001. Aynı kaynak aynı UTC günü içinde bir kez ücretlenir. Etkileşim silme $0,010, içerik yönetimi ve medya üst verisi istek başına $0,005. Dönem başına harcama tavanı konabilir; tavana gelince istekler bir sonraki döneme kadar engellenir. Otomatik yükleme 5 dakikada en çok bir kez çalışır, bakiye sıfır ya da eksiyken çalışmaz. İlk uygun kartı kaydeden yeni hesaba bir kerelik $20, ilk otomatik yüklemeye $50'a kadar eşleme kredisi veriliyor; bu krediler önce harcanır, 3 ayda düşer ve kademeli açılıyor. Dönem içi toplam harcamaya göre xAI kredisi geri veriliyor: $200'dan itibaren yüzde 10, $500'dan yüzde 15, $1.000'dan yüzde 20. Kullandıkça öde planında aylık 3 milyon gönderi okuma tavanı var, üstü Enterprise. Şubat duyurusuna göre Basic ve Pro planları sürüyor ve mevcut aboneler yeni modele geçebiliyor; eski ücretsiz katmanın yakın zamanda aktif kullanıcılarına bir kerelik $10 verildi.

**Şartlar:** Geliştirici hesabı ve uygulama, ödeme kartı ve kredi. Gönderi atmak için kullanıcı bağlamı şart: OAuth 1.0a kullanıcı token'ı ya da OAuth 2.0 yetkilendirme kodu ve PKCE. Yalnız uygulama (app-only) token'ı gönderi atamaz. OAuth 1.0a'da uygulama izni 'Read and write' olmalı; izin değişirse token'lar yeniden alınmalı. OAuth 2.0 kapsamları: tweet.read, tweet.write, users.read, media.write, süresiz erişim için offline.access. Geliştirici kurallarına göre otomatik hesaplar profilde 'Automated' etiketini açar, biyografide bot olduğunu ve kimin işlettiğini yazar ve insan tarafından yönetilen bir hesaba bağlanır. Aynı ya da benzer içeriği birden çok hesaptan atmak, istenmeyen etiketleme, yanıltıcı bağlantı ve API dışı otomasyon (tarayıcı betiği, kazıma) yasak; sonuncusu kalıcı askı sebebi. Yapay zekâ ile üretilen içerik ve yanıtlar için yayından önce X'ten onay isteniyor.

**Medya:** Görsel JPG, PNG, GIF ya da WEBP, en çok 5 MB. Hareketli GIF en çok 15 MB, önerilen en çok 1280x1080 ve 350 kare. Video parçalı yükleme ister, önerilen H.264 High ve AAC LC. Sınırlar geliştirici planına değil paylaşan hesaba bağlı: standart hesapta gönderi videosu 0,5 saniye ile 20 dakika arası ve en çok 8 GB, Premium ya da onaylı hesapta 125 dakika ve 16 GB. Süreyi aşan video gönderi oluşturmada 403 alır. Gönderi başına en çok 4 fotoğraf. Doğru media_category verilmeli (gönderi görseli için tweet_image); yanlış kategoriyle yükleme başarılı olur ama gönderi oluşturma düşer. Yükleme sınırları ile gönderi sınırları ayrı uygulanır.

**Hız ve kota:** Gönderi oluşturma: kullanıcı başına 15 dakikada 100, uygulama başına 24 saatte 10.000. Gönderi silme: kullanıcı başına 15 dakikada 50. Tek parça medya yükleme: kullanıcı başına 15 dakikada 500, uygulama başına 24 saatte 50.000; parçalı yüklemenin başlat, ekle, bitir uçları kullanıcı başına 15 dakikada 1.875, uygulama başına 24 saatte 180.000. Kendi hesabını okuma: kullanıcı başına 15 dakikada 75. Yanıt başlıkları x-rate-limit-limit, x-rate-limit-remaining ve x-rate-limit-reset; sınır aşılınca 429 ve kod 88 döner, reset zamanına kadar beklenir. Hız sınırı ile ücret ayrıdır: sınır içinde kalmak harcamayı sınırlamaz.

**Token ve süre:** OAuth 1.0a kullanıcı token'larının bitiş süresi yok. Kullanıcı uygulamanın erişimini kaldırırsa ya da X uygulamayı askıya alırsa geçersiz olur; belgeler token'ın her an geçersiz olabileceğini varsaymayı söylüyor. OAuth 2.0 erişim token'ı 2 saat geçerli; offline.access kapsamı istenirse yenileme token'ı verilir, istenmezse verilmez. Yetkilendirme kodu 30 saniye içinde token'a çevrilmeli. Mevcut OAuth 1.0a token'ları aynı kullanıcı için OAuth 2.0 token'ına çevrilebiliyor. Ürün C OAuth 1.0a kullanıcı token'ı kullanıyor.

**Ne bozulur:** 402: kredi bitti; bizdeki mesaj 'Payment Required: credits depleted'. Fiyat sayfasına göre bakiye biraz eksiye düşebilir ve eksi kapanana kadar istekler engellenir; bakiye yalnız Developer Console'da görünür. Bizde yalnız gönderi oluşturma 402 aldı, hesap okuma ve medya yükleme geçti. Harcama tavanına gelince de istekler dönem sonuna kadar engellenir. 401: kimlik bilgisi geçersiz ya da eksik (token iptal edildi, anahtar yenilendi). 403: kimlik doğru ama yetki yok (uygulama bu uca kayıtlı değil, kapsam eksik, video süresi hesabın sınırını aşıyor). 429: hız sınırı ya da kullanım tavanı. 500, 502, 503, 504: bekle ve tekrar dene. Zaman aşımı: gönderinin gidip gitmediği bilinmez, tekrar denemek çift gönderi riskidir.

### Instagram API, içerik yayınlama (Meta Graph API)

**Ne sağlar:** Profesyonel Instagram hesabına tek görsel, karusel, reels ve hikâye yayını. Akış iki adımlı: önce medya kabı (container) oluşturulur, durum FINISHED olunca yayın isteği gönderilir. Karuselde önce her öğe için kap, sonra karusel kabı, sonra yayın. API ile alışveriş etiketi ve filtre desteklenmiyor.

**Erişim ve fiyat:** Ücretsiz, çağrı başına ücret yok. Sınırlar hız ve kota üzerinden.

**Şartlar:** Yalnız profesyonel (işletme ya da içerik üreticisi) hesap. İki yol var. Instagram girişli yol: Facebook Sayfası gerekmez, izinler instagram_business_basic ve instagram_business_content_publish, token Instagram kullanıcı token'ı. Facebook girişli yol: Instagram hesabı bir Facebook Sayfasına bağlı olmalı, izinler instagram_basic, instagram_content_publish, pages_read_engagement; Sayfa rolü Business Manager üzerinden geliyorsa ads_management ve ads_read de gerekir. Sayfa, Sayfa Yayın Yetkilendirmesi (PPA) istiyorsa PPA tamamlanmadan yayın yapılamaz. Uygulamada rolü olan kullanıcılar için Standard Access otomatik verilir ve inceleme gerekmez; yalnız kendi ya da yönettiğimiz hesaba paylaşıyorsak Standard Access yeter. Başkalarının hesaplarına erişmek Advanced Access ister: Business Verification şart, izin bazında App Review gerekebilir ve her yıl Data Use Checkup yapılır.

**Medya:** Görsel belgelere göre yalnız JPEG, en çok 8 MB, en boy oranı 4:5 ile 1,91:1 arasında, genişlik 320 ile 1440 piksel arasında (dışındakiler ölçeklenir), sRGB. Görsel ve video herkese açık bir adreste durmalı, Instagram onu kendisi çeker; büyük videolar için Facebook girişli yolda kesintili yükleme var. Karusel en çok 10 öğe ve tüm görseller ilk görselin oranına göre kırpılır, varsayılan 1:1. Reels MOV ya da MP4, 3 saniye ile 15 dakika arası, en çok 300 MB, H.264 ya da HEVC, 23 ile 60 kare, 9:16 önerilir. Hikâye görseli JPEG ve 8 MB, hikâye videosu 3 ile 60 saniye ve 100 MB. Açıklama en çok 2200 karakter, 30 hashtag, 20 etiket. Kaplar 24 saatte EXPIRED olur. Kap durumları: IN_PROGRESS, FINISHED, PUBLISHED, ERROR, EXPIRED. Profil ızgarası 3:4 kırpar; 1080x1350 hem gönderide hem ızgarada tam görünür.

**Hız ve kota:** Hesap başına kayan 24 saatte API ile en çok 100 yayın. Karusel tek yayın sayılır. Kalan kota content_publishing_limit ucundan okunur. Genel sınır: Instagram uçları için kayan 24 saatte 4800 x hesabın gösterim sayısı kadar çağrı (Business Use Case sınırı); aşılınca kod 80002. Kullanım X-Business-Use-Case-Usage başlığında görülür.

**Token ve süre:** İki yolda da kısa ömürlü token 1 saat, uzun ömürlü token 60 gün. Instagram girişli yolda uzun ömürlü token en az 24 saatlikse ve süresi dolmamışsa yenilenebilir; 60 gün içinde yenilenmezse ölür ve yenilenemez. Facebook girişli yolda uzun ömürlü kullanıcı token'ından alınan Sayfa token'ının bitiş tarihi yoktur ama belirli koşullarda geçersizleşir. Kişiden türeyen token'larda ayrıca 90 günlük veri erişimi süresi var: kullanıcı 90 gün etkin olmazsa uygulama verisine erişemez. pages_manage_posts ve pages_read_engagement bu sürenin dışında, instagram_basic ve instagram_content_publish değil. Sunucu için doğru seçim Business Manager'da system user token'ı: süresiz ya da 60 günlük seçilir, 60 günlük olan bu süre içinde yenilenmezse ölür, oauth/revoke ile anında iptal edilir. System user ve uygulama aynı işletmede olmalı, uygulama system user'a kurulmalı, Sayfa ve Instagram hesabı system user'a varlık olarak atanmalı. Standard erişimde 1 admin ve 1 normal system user, Advanced erişimde 1 admin ve 10 normal system user açılabilir. Ürün C Facebook girişli yolu ve süresiz system user token'ını kullanıyor.

**Ne bozulur:** Kod 190: token geçersiz. Alt kodlar: 463 süresi doldu ya da iptal edildi, 460 şifre değişti, 459 hesap güvenlik kontrolüne takıldı, 464 onaylanmamış kullanıcı, 458 uygulama kurulu değil, 467 geçersiz token, 492 token sahibinin Sayfada uygun rolü yok. Kod 10 ve 200 ile 299 arası: izin verilmemiş ya da geri alınmış. Kod 368: politika ihlali yüzünden geçici engel. Kod 1, 2, 4, 17, 341, 613 ve 80002: geçici arıza ya da kısıtlama, bekle ve tekrar dene. Kod 9007, alt kod 2207027: medya hazır değil, durum FINISHED görünse de olabiliyor; yalnız bu hata yeniden denenir. Görsel adresi erişilemezse (özel depo, yönlendirme, bot koruması) kap ERROR olur. Meta token'ın geçersizleştiğini bildirmez; bunu ilk istekte öğrenirsin.

### Facebook Sayfası, Pages API

**Ne sağlar:** Sayfa adına metin ve bağlantı gönderisi (feed ucu), adresi verilen fotoğraf (photos ucu), video (Video API) ve ileri tarihli gönderi. Uygulama yalnız kendi oluşturduğu gönderileri güncelleyebilir.

**Erişim ve fiyat:** Ücretsiz, çağrı başına ücret yok.

**Şartlar:** İzinler pages_manage_posts, pages_read_engagement, pages_read_user_engagement; video için publish_video. Sayfa access token'ı gerekir. Token sahibinin Sayfada CREATE_CONTENT, MANAGE ve MODERATE görevlerini yapabilmesi gerekir. Erişim seviyeleri Instagram ile aynı: rolümüz olan Sayfa için Standard Access, başkalarının Sayfaları için Advanced Access, Business Verification ve gerekirse App Review.

**Medya:** Fotoğraf herkese açık adresle verilebilir. Video için ayrı Video API akışı var. Sayfa için ayrıntılı ölçü kuralı bu belgede yok; Instagram ile aynı 1080x1350 ya da 1200x630 kartlar kullanılabilir.

**Hız ve kota:** Ayrı bir günlük gönderi kotası belgelerde yok. Sayfa ya da system user token'ıyla yapılan çağrılar kayan 24 saatte 4800 x Sayfanın etkileşimli kullanıcı sayısı ile sınırlı; aşılınca kod 32. Uygulama düzeyinde saatte 200 x kullanıcı sayısı sınırı ayrıca var, kullanım X-App-Usage başlığında. İleri tarihli gönderinin zamanı istekten en az 10 dakika, en çok 30 gün sonra olmalı.

**Token ve süre:** Uzun ömürlü kullanıcı token'ından alınan Sayfa token'ının bitiş tarihi yok, ama kullanıcı şifresini değiştirirse, Sayfa rolünü kaybederse ya da uygulamayı kaldırırsa geçersizleşir. pages_manage_posts izni 90 günlük veri erişimi süresine tabi değil. System user token'ı bir kişinin şifresine bağlı olmadığı için sunucu için daha sağlam. 60 günlük system user token'ı bu süre içinde yenilenmeli; oauth/revoke ile anında iptal edilebilir.

**Ne bozulur:** Instagram ile aynı hata kodları: 190 ve alt kodları, 10 ve 200 ile 299 izin hataları, 368 geçici engel, 32 Sayfa hız sınırı. Kod 506: aynı gönderi art arda yayınlanamaz, içerik değiştirilmeli. 492 alt kodu token sahibinin Sayfada uygun rolü olmadığını söyler. Sayfa yöneticisi değişince ya da işletmeden çıkarılınca o kişiden türeyen token'lar ölür.

### Threads API

**Ne sağlar:** Metin, görsel, video ve karusel gönderisi, yanıt. Akış Instagram gibi: önce kap, sonra yayın. Karuselde önce öğe kapları, sonra karusel kabı, sonra yayın.

**Erişim ve fiyat:** Ücretsiz, çağrı başına ücret yok.

**Şartlar:** İzinler threads_basic ve threads_content_publish. Meta uygulamasında Threads kullanım durumu açılmalı. Erişim seviyeleri Meta'nın genel modeline bağlı: rolü olan kullanıcı için Standard Access, başka kullanıcılar için inceleme.

**Medya:** Metin en çok 500 karakter, emojiler UTF-8 bayt olarak sayılır. Görsel JPEG ya da PNG, en çok 8 MB, genişlik 320 ile 1440 piksel arası, en boy oranı sınırı 10:1. Video MP4 ya da MOV, en çok 1 GB ve 5 dakika, 9:16 önerilir. Karusel 2 ile 20 öğe. Kap oluşturduktan sonra yayından önce ortalama 30 saniye beklemek öneriliyor. Konu etiketi 1 ile 50 karakter, nokta ve & içeremez.

**Hız ve kota:** Profil başına kayan 24 saatte 250 yayın ve 1.000 yanıt. Karusel tek yayın sayılır. Kalan kota threads_publishing_limit ucundan okunur (quota_usage ve reply_quota_usage). Gönderi başına en çok 5 bağlantı; 22 Aralık 2025'ten beri fazlası hata alıyor.

**Token ve süre:** Kısa ömürlü token 1 saat. Uzun ömürlü token 60 gün; en az 24 saatlikse ve süresi dolmamışsa yenilenir, yenilenen token yenileme gününden itibaren 60 gün yaşar. 60 gün içinde yenilenmezse ölür ve yenilenemez. Gizli profillerde verilen izinler 90 gün geçerli. Belgeler yalnız kullanıcı token'ından söz ediyor, yani düzenli yenileme işi şart.

**Ne bozulur:** Yenileme işi bir kez çalışmazsa 60. günde paylaşım durur. Kap hazır olmadan yayın isteği gönderilirse hata alınır. Beşten fazla bağlantı THREADS_API__LINK_LIMIT_EXCEEDED hatası alır. Graph hata kodları (190 ve alt kodları, izin hataları, kısıtlama) burada da geçerli.

### LinkedIn Posts API (şirket sayfası)

**Ne sağlar:** Şirket sayfası adına metin, görsel, çoklu görsel, video, belge, makale ve anket gönderisi; gönderiyi okuma, düzenleme ve silme. Görsel önce Images API ile yüklenir, dönen görsel kimliği gönderiye eklenir. Makale gönderisinde LinkedIn bağlantıyı kendisi taramaz; küçük görsel, başlık ve açıklama istekte verilir. Organik karusel yok, çoklu görsel var. Silme tekrarlanabilir: silinmiş gönderiyi yeniden silmek 204 döner.

**Erişim ve fiyat:** Ücretsiz, çağrı başına ücret yok. Erişim başvuruyla açılır: Community Management API önce Development katmanında verilir ve entegrasyon 12 ay içinde bitirilmelidir. Production için Standard katmanına ayrıca başvurulur; şirket ve ürün özeti, kullanım senaryosu, inceleme için test hesabı ve her senaryoyu gösteren indirilebilir ekran kaydı istenir. Reddedilen başvuru aynı uygulamayla tekrarlanamaz, yeni uygulama gerekir.

**Şartlar:** Yalnız tescilli tüzel kişiler ve ticari kullanım. İş e-postası doğrulanır, kişisel e-posta geçmez; kuruluşun yasal adı, adresi, sitesi ve gizlilik politikası istenir. Uygulamayı kuruluşun LinkedIn sayfasının süper yöneticisi doğrular. Gönderi için w_organization_social izni ve token sahibinin sayfada ADMINISTRATOR, CONTENT_ADMIN ya da DIRECT_SPONSORED_CONTENT_POSTER rolü. Her istekte LinkedIn-Version (YYYYMM) ve X-Restli-Protocol-Version 2.0.0 başlıkları. Sürümler yaklaşık bir yıl sonra kapanıyor: Ekim 2025 sürümü 15 Ekim 2026'da kapanıyor, Ekim 2026'daki en yeni sürüm Eylül 2026 (202609).

**Medya:** Görsel, video ve belge ayrı yükleme API'leriyle yüklenir. Önizleme kartı API'de otomatik oluşmaz, makale alanları elle verilir. Tarayıcıdan paylaşımda kart metindeki son bağlantıdan kurulur ve küçük önizleme olarak görünür.

**Hız ve kota:** Development katmanında uygulama başına 24 saatte 500, üye başına 24 saatte 100 çağrı; toplu okuma (BATCH_GET) yok, webhook bildirimi kapalı. Standard katmanında bu kısıtlar kalkar. Aşılınca 429.

**Token ve süre:** Erişim token'ı 60 gün. Programatik yenileme token'ı onaylı Marketing Developer Platform ortaklarına verilir ve 365 gün yaşar; yenileme token'ının süresi her yenilemede uzamaz. Süre bitince üye uygulamayı yeniden yetkilendirmelidir. LinkedIn token'ları teknik ya da politika sebebiyle her an iptal edebilir.

**Ne bozulur:** 401 boş ya da geçersiz token. 403 ACCESS_DENIED: izin ya da sayfa rolü eksik. 409 yazma çakışması, tekrar dene. 422 anlamsal hata. 429 hız sınırı. 400 'refresh token is invalid, expired or revoked': yeniden yetkilendirme gerekir. Sürüm kapanınca eski sürüm başlığıyla istekler düşer. Yayın PUBLISH_FAILED durumuna düşebilir; yeniden denemek için gönderiyi düzenlemek gerekir.

## Ne tutar

**X, günde bir paylaşım:** Gönderi $0,015, bağlantılı gönderi $0,20, kullanıcı okuma $0,010 (aynı UTC gününde bir kez sayılır), kendi verini okuyan uçlar $0,001, etkileşim silme $0,010. Günde bir, haftada bir ve ayda bir paylaşım ayda yaklaşık 35 gönderi eder: bağlantısız yaklaşık $0,53, bağlantılı yaklaşık $7. Her gün yayından önceki hesap okuma (kendi hesabını okuyan uç sahiplik indirimi listesinde değil) ayda yaklaşık $0,30 ekler.

**X, haftada üç gün:** Haftada üç gün üçer gönderi ayda yaklaşık 39 gönderi eder: bağlantısız yaklaşık $0,59, hepsi bağlantılıysa yaklaşık $7,8.

**X, başlangıç kredisi:** Yeni hesaba ilk kart kaydında $20 ve ilk otomatik yüklemede $50'a kadar eşleme kredisi veriliyor, toplam $70; 3 ayda düşüyor. Dönem içi harcama $200'ı geçince yüzde 10, $500'ı geçince yüzde 15, $1.000'ı geçince yüzde 20 xAI kredisi geri veriliyor; bizim hacmimizde bu sıfır.

**Meta:** Instagram, Facebook Sayfası ve Threads API'leri ücretsiz; sınır hız ve kota. Business Verification ücretsiz ama zaman alır; Advanced Access her yıl Data Use Checkup ister.

**LinkedIn:** LinkedIn API ücretsiz; maliyet tüzel kişilik şartı, başvuru süresi ve Standard katmanı için ekran kaydı hazırlığı.

**Görsel barındırma:** Görsel barındırma: ayda yüz civarı görsel, her biri birkaç yüz KB; depolama ve trafik birkaç sentlik.

**Görsel çizimi:** Görsel çizimi sunucu içinde, ek servis maliyeti yok.

**Yapay zekâ metni:** Metin yapay zekâyla üretilirse çalışma başına birkaç sent; çalışma başına tavan koy. X'te yapay zekâ içeriği için ön onay kuralını da hesaba kat.

**İnsan zamanı:** Asıl maliyet insan zamanı: elle ya da tarayıcıyla paylaşımda her gönderide dosya seçme ve yayın tıklaması bir insana kalır.

## Tuzaklar

### Her platformda

Gönderi oluşturma isteği zaman aşımına düşerse gönderi gitmiş olabilir. Tekrar deneme yapma, belirsiz işaretle ve kalıcı bağlantıyı elle kontrol et.

Hata yolu da bozulabilir. Bizde başarısız adımın durum değeri tablo kısıtına uymadı, güncelleme düştü ve rapor yarım kaldı. Başarısız durumu yazan kodu da test et.

Token'ı GET isteğinde adres parametresi olarak göndermek risklidir: ağ hatasında istemci kütüphanesi tam adresi hata metnine koyar, hata metni de log ve veritabanına yazılır. Token'ı başlıkta gönder ve hata metinlerini temizle.

Alt küme web fontlarıyla çizilen görsellerde ğ, ş ve İ bozuk çıkabilir. Görsel çiziciye tam TTF göm.

Bulut logları 30 gün sonra silinir. Olay incelemesi için kalıcı kayıt veritabanında olmalı.

### X

Kredi biten X 402 döner ve hat sessizce durur. Bizde 30 gün boyunca her gün denendi ve fark edilmedi. 402 alarmdır, özet e-postasında bir satır değildir.

X'te hesap okuma ve medya yükleme başarılıyken gönderi oluşturma 402 alabilir. 'Token sağlam mı' kontrolü kredi bittiğini göstermez; bakiye yalnız Developer Console'da görünür, bu yüzden gönderi sonucunu ve uygulama içi harcama sayacını izle.

X harcama tavanına gelince istekler dönem sonuna kadar engellenir. Çok düşük tavan da hattı 402 gibi sessizce durdurur.

X'in tanıtım kredileri 3 ayda düşer. Bakiye bir gün aniden azalabilir; tavanı ve otomatik yüklemeyi buna göre kur.

X bağlantılı gönderiyi $0,20 ile, bağlantısızı $0,015 ile fiyatlıyor. X çıplak alan adını da bağlantıya çevirir. Adresi görselin içine koy, metinden çıkar.

X'in geliştirici kuralları API dışı otomasyonu, tarayıcı betiği dahil, kalıcı askı sebebi sayıyor. Tarayıcı ajanıyla paylaşım hem insan zamanı yer hem hesabı riske atar.

X'te uygulama izni 'Read' iken üretilmiş OAuth 1.0a token'ı izin 'Read and write' yapılınca kendiliğinden yazma kazanmaz; token yeniden alınmalı.

Kısa sürede çok sayıda bağlantılı ya da benzer gönderi spam süzgecine takılır; X kuralları tekrar eden içeriği, Facebook Sayfası art arda aynı gönderiyi (kod 506) reddeder. Gönderiler arasında zaman bırak, metinleri platforma göre ayrı yaz.

Yalnız uygulama (app-only) X token'ı gönderi atamaz. Kullanıcı bağlamlı token gerekir.

X OAuth 2.0 erişim token'ı 2 saat yaşar. offline.access istenmezse yenileme token'ı gelmez ve hat 2 saat sonra durur.

Kapatma anahtarı ortam değişkeniyse kapatmak canlı serviste yeni revizyon ve canlıya yetkili bir insan ister. Bizde X'i kapatmak için komutu ürün sahibi çalıştırdı. Anahtarı sunucudaki bayrak tablosuna koy.

### Meta (Instagram, Sayfa, Threads)

60 günlük Meta kullanıcı token'ı sessizce ölür ve Meta haber vermez. Bizde iki paylaşım aynı sabah düştü. Sunucu için süresiz system user token'ı kullan.

Meta token'ı bir kişinin hesabından türerse o kişinin şifre değişikliği (alt kod 460), hesap kontrolü (459) ya da Sayfa rolünü kaybetmesi (492) hattı durdurur. Ayrıca instagram_basic ve instagram_content_publish izinleri 90 günlük veri erişimi süresine tabi; 'süresiz' görünen Sayfa token'ı bile Instagram'a erişimini kaybedebilir.

Instagram kabı FINISHED görünürken yayın 9007 ve 2207027 ile reddedilebilir. Yalnız bu hatayı artan aralıkla tekrar dene; diğer hataları tekrarlamak çift gönderi riskidir.

Instagram görseli herkese açık bir adresten çeker. Depo özelse, adres yönlendiriyorsa ya da bot koruması Meta'nın çekicisini reddediyorsa kap ERROR olur. Depo herkese açıksa listelemeyi kapat; açık listede yayınlanmamış taslaklar görünür.

Instagram profil ızgarası 3:4 kırpar ve karusel bütün slaytları ilk görselin oranına kırpar. 1200x630 kartın yazısı ızgarada kesilir; bütün slaytlarda 1080x1350 kullan.

### LinkedIn

LinkedIn yönetici listesi yayındaki gönderiyi göstermeyebilir. Listeye bakıp yeniden gönderme, kopya çıkar. Doğrulamayı gönderinin bağlantısıyla yap.

LinkedIn şirket sayfası API erişimi yalnız tüzel kişilere açık, başvuru iş e-postası ve sayfa süper yöneticisinin onayını ister; Development katmanı günde 500 çağrı ile sınırlı, Standard katmanı ekran kaydı ister ve ret yeni uygulama ister. Başvuruyu yayından haftalar önce yap.

LinkedIn API sürümleri yaklaşık bir yılda kapanır (Ekim 2025 sürümü 15 Ekim 2026'da); Meta Graph sürümleri de emekliye ayrılır. Sürümü ayarda tut ve takvime bitiş tarihini yaz.

### Doğrulanamayanlar

Resmi belgelerde bulunamayan ya da bizim kayıtlarımızla teyit edilemeyenler.

Instagram belgeleri yayın için yalnız JPEG kabul edildiğini yazıyor. Bizim PNG görsel adreslerimiz bugüne kadar yayınlandı. Bunun süreceği garanti değil; JPEG üretmek güvenli taraf.

X'in 402 için resmi bir hata türü belgelerin hata sayfasında yok. Bildiğimiz mesaj kendi kayıtlarımızdan, davranış fiyat sayfasındaki 'kredi eklenene kadar istekler engellenir' cümlesinden. Harcama tavanına gelindiğinde 402 mi yoksa 429 'usage-capped' mi döndüğü de yazmıyor.

Bizde 402 yalnız gönderi oluşturmada görüldü, kendi hesabını okuma ve medya yükleme geçti. Bunun X'in kuralı mı yoksa o günkü durum mu olduğu belgelerde yok. 7 Ekim'de kredinin tanındığı hesap okumayla kontrol edildi; bu kontrol krediyi kanıtlamaz.

X fiyat sayfası medya yükleme için ayrı bir fiyat yazmıyor (yalnız 'medya üst verisi' $0,005). Gönderi silmenin 'etkileşim silme' ($0,010) mi yoksa 'içerik yönetimi' ($0,005) mi sayıldığı da yazmıyor. Gerçek tutar Developer Console'dan okunmalı.

X OAuth 2.0 yenileme token'ının tek kullanımlık olup olmadığı ve ömrü okunan belgelerde yazmıyor. Tek kullanımlık varsayılıp her yenilemede yeni token atomik kaydedilmeli.

X geliştirici kuralları API kullanan bütün otomatik hesapların 'Automated' etiketini açmasını istiyor. Hem insanın hem sunucunun paylaşım yaptığı bir marka hesabının bu tanıma girip girmediği net değil.

X geliştirici kuralları yapay zekâ ile üretilen içerik ve yanıtlar için ön onay istiyor. Yapay zekânın yazdığı ama insanın onayladığı marka gönderilerinin bu kapsama girip girmediği net değil; yardım sayfası Cloudflare yüzünden okunamadı, bilgi geliştirici kuralları sayfasından.

X Şubat 2026 duyurusu Basic ve Pro planlarının sürdüğünü söylüyor, fiyat sayfası ise 'abonelik yok' diyor. Yeni bir geliştiricinin bugün Basic ya da Pro alıp alamadığı belgelerde net değil. Eski ücretsiz katmanın yeni geliştiricilere kapalı olduğu da açıkça yazmıyor, yalnız 'legacy' diye geçiyor.

X'te aynı metni ikinci kez yayınlamanın 403 ile reddedildiği yaygın bilgi, ama okunan güncel belgelerde bu ayrıntı yok.

Threads API'nin system user token'ını kabul edip etmediğini bulamadık; belgeler yalnız kullanıcı token'ından söz ediyor. 60 günlük yenileme işi varsayılmalı.

Meta'nın izin geri alma ya da uygulama kaldırma için bildirim (deauthorize callback) gönderdiği üçüncü taraf kaynaklarda geçiyor; system user token'larına uygulanıp uygulanmadığı ve token süresinin dolması için bildirim olup olmadığı resmi belgelerde bulunamadı. Günlük yoklama esas alınmalı.

Ölen Instagram token'ının türü kayıtlarda yazılı değildi. Otomatik yayının açılışıyla bitiş arasının yaklaşık 60 gün olması 60 günlük kullanıcı token'ı olduğunu gösteriyor.

System user token'ı üretmek için belgeler API yolunda uygulamanın Ads Management standart erişimi olmasını istiyor; bizde token iş yöneticisi ekranından üretildi ve bu şart sorulmadı.

## Kaynaklar

Resmi sayfalar Ekim 2026'da okundu. "Bizde ne oldu" kartları kendi kayıtlarımızdan.

**X API fiyatları**https://docs.x.com/x-api/getting-started/pricing
**X başlangıç kredileri**https://docs.x.com/x-api/getting-started/free-credits
**X API değişiklik günlüğü**https://docs.x.com/changelog
**X hız sınırları**https://docs.x.com/x-api/fundamentals/rate-limits
**X yanıt kodları ve hatalar**https://docs.x.com/x-api/fundamentals/response-codes-and-errors
**X medya yükleme önerileri**https://docs.x.com/x-api/media/quickstart/best-practices
**X OAuth 2.0 yetkilendirme kodu ve PKCE**https://docs.x.com/fundamentals/authentication/oauth-2-0/authorization-code
**X yalnız uygulama token'ı**https://docs.x.com/fundamentals/authentication/oauth-2-0/application-only
**X kimlik doğrulama SSS**https://docs.x.com/fundamentals/authentication/faq
**X geliştirici uygulaması ve izinler**https://docs.x.com/resources/fundamentals/developer-apps
**X geliştirici kuralları**https://docs.x.com/developer-guidelines
**X otomasyon kuralları (yardım sayfası, Cloudflare yüzünden okunamadı)**https://help.x.com/en/rules-and-policies/x-automation
**Instagram platformu genel bakış**https://developers.facebook.com/docs/instagram-platform/overview
**Instagram içerik yayınlama**https://developers.facebook.com/docs/instagram-platform/content-publishing
**Instagram medya ucu, biçim ve boyut**https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media
**Instagram girişli yol**https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login/business-login
**Meta erişim seviyeleri**https://developers.facebook.com/docs/graph-api/overview/access-levels
**Meta hız sınırları**https://developers.facebook.com/docs/graph-api/overview/rate-limiting
**Meta hata kodları**https://developers.facebook.com/docs/graph-api/guides/error-handling
**Meta uzun ömürlü token**https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived
**Meta 90 günlük veri erişimi süresi**https://developers.facebook.com/docs/facebook-login/auth-vs-data
**Meta system user token'ı**https://developers.facebook.com/docs/business-management-apis/system-users/install-apps-and-generate-tokens
**Meta system user sayıları**https://developers.facebook.com/docs/marketing-api/system-users/overview
**Facebook Sayfası gönderileri**https://developers.facebook.com/docs/pages-api/posts
**Threads gönderileri**https://developers.facebook.com/docs/threads/posts
**Threads genel bakış ve sınırlar**https://developers.facebook.com/docs/threads/overview
**Threads uzun ömürlü token**https://developers.facebook.com/docs/threads/get-started/long-lived-tokens
**LinkedIn Posts API**https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api
**LinkedIn erişim katmanları**https://learn.microsoft.com/en-us/linkedin/marketing/increasing-access
**LinkedIn Community Management başvurusu**https://learn.microsoft.com/en-us/linkedin/marketing/community-management-app-review
**LinkedIn programatik yenileme token'ı**https://learn.microsoft.com/en-us/linkedin/shared/authentication/programmatic-refresh-tokens

<a id="katmanlar-3"></a>

Katman 10 / 11

# Gözlem ve alarmlar

Alarmlar ilk kullanıcıdan önce kurulur ve her biri uçtan uca denenir.

192/gün
Alarmsız bir serviste 2 Eki'de tesadüfen bulunan günlük OOM sayısı.

## Yap

[öneri]
** İlk gün**: uptime, 5xx, açılışta veritabanı yok, Job/Scheduler hatası, yedek hatası, OOM, Cloud Build hatası, ERROR>0 (bugün seviyesi, geliştiriciye e-posta; süzgece NOT jsonPayload.message="alert" eklenir, yoksa notify()'ın kendi satırı her uyarıyı ikinci kez yollar; != yazılmaz, alanı olmayan çökme satırlarını da dışarıda bırakır), kritik uçlarda eşiksiz 5xx, dead-man's switch, 'db wake' sayısı, eski gönderilmemiş outbox satırı.
[kanıtlı]
** Her alarm '[TEST]' hatasıyla uçtan uca denenir**; durum Monitoring API'den okunur.
[öneri]
** Neon Free'de tüketim API'si yok**: uygulama her uyanışı 'db wake' satırıyla loglar, o satırdan log metriği ve alarm kurulur; Usage sayfası haftada bir okunur, 50 ve 80 CU-saatte uyarı. Gerçek kullanıcılı proje Free'de durmaz.
[öneri]
** Yenileme takvimi**: Apple Developer üyeliği (düşerse uygulama satıştan kalkar), alan adları, GCP, Neon, registrar, Expo ve Resend kartlarının son kullanma tarihi, APNs/FCM anahtarları, token'lar, krediler; 30 ve 7 gün önce hatırlatma.
[kanıtlı]
** Dış entegrasyon hataları ERROR üretir**; gözetimsiz kontroller bulutta çalışır.

## Başlangıç ayarları

[kanıtlı]
Uptime 300 sn, 3 bölge; 5xx servis başına 5 dk'da >3.
[öneri]
Ödeme ve mağaza webhook'larında başarılı teslim durursa ya da tek bir 5xx görülürse ayrı alarm.
[öneri]
Alarmlar bugün ücretsiz; ücret en erken 1 Eyl 2027'de, metrik referansı başına ayda $0,35. Uptime, billing ve kota metriğine bağlı alarm ücretsiz kalır. Proje başına 50 GiB log ücretsiz.

### Kaçın

[ölçüldü]
Alarmsız işletmek; severity'siz log; kaçağı ay sonu faturasında bulmak.

### Bizdekinden iyisi

[öneri]
Çökme telemetrisi için Sentry Developer $0, Team $26/ay; KVKK adımlarından sonra.

### Nereden öğrendik projelerimizden, 2026

**23 Eyl** alarm testi 16:57 → 17:01 → 17:11.
**2 Eki** alarmsız bir serviste tek günde 192 OOM bir maliyet analizinde tesadüfen bulundu.
**28 Ağu–27 Eyl** bir API kredisi bitince 30 paylaşım 402 aldı.

<a id="uyarilar"></a>

Gözlem ve alarmlar

# Uyarılar kime, nasıl ulaşır

Katman 10'daki alarmlar sunucunun sağlığını izler. Bu bölüm başka bir soruya cevap verir: dış bir API ödeme istediğinde, bir bütçe dolduğunda ya da bir iş hiç çalışmadığında ürün sahibi bunu ne zaman, hangi kanaldan ve hangi cümleyle öğrenir.

**Kural:** Her dış bağımlılığın ve her bütçenin uyarısı ilk gün kurulur.

Her uyarı için beş şey yazılır: sinyal, eşik, seviye, kanal ve harekete geçecek kişi. Acil olan telefona gider, gece de gönderilir. Bugün düzeltilmesi gereken e-postaya ve admin'deki uyarı kutusuna gider. Acil olmayan ama doğru olan her şey pazartesi özetinde toplanır. Uyarı düz Türkçedir: ne oldu, kullanıcı ne gördü, ne yapılacak, nereye tıklanacak. Her uyarı bir kez sahte bir hatayla uçtan uca denenir.

Dört ürünümüzde sessiz kalan arızaların çoğunda sinyal vardı: bir özet e-postasında bir satır, sağlayıcının panelinde başarısız teslimlerin listesi, faturada bir kalem. Eksik olan, sinyalin eşik aşıldığı anda, doğru kanaldan, doğru kişiye gitmesiydi. Teknik alarmların eşikleri [Gözlem ve alarmlar](#katman-10) katmanında; bu bölüm onları ürün sahibine taşıyan yolu kurar.

**5 / 0 / 0 / 0** Alarm politikası: Ürün A, B, C ve D, 8 Eki 2026. Ürün A'nın beşi erişim, 5xx, yedek, yedek zamanlayıcısı ve açılışta veritabanı içindir.
**2 e-posta** Ürün A'daki beş alarmın gittiği iki kutu. Telefona giden kanal yok; postanın kutuya düştüğünü iki alıcıdan biri doğruladı.
**0** Dört üründe dış API hatası, kota, token süresi ve hiç çalışmayan iş için kurulu alarm.

## Ne kadar sonra, nereden öğrenildi

Arızanın başladığı andan fark edildiği ana. Ölçek gerçek; aynı çalışma ve 1 saat bu ölçekte ancak bir çizgi.

Bir kontrol ya da alarm yakaladıKullanıcı, fatura ya da tesadüf gösterdi
_Grafik: Arızanın başlangıcından fark edilmesine geçen süre ve nasıl öğrenildiği: Ürün A: ilk yedek 7 bayt: aynı çalışmada, boyut karşılaştırması; Ürün B: site haritası kısaldı: 1 saat içinde, haftalık kontrol; Ürün C: Instagram token'ı doldu: ~21 saat, paylaşım düşünce; Ürün A: iOS build kotası doldu: 2 gün, build reddedilince; Ürün C: X kredisi bitti: 30 gün, ürün sahibi sorunca_
Kontrolü olan iki olay aynı çalışmada ya da bir saat içinde görüldü. Kontrolü olmayan üç olay ~21 saatte, 2 günde ve 30 günde fark edildi. Ödeme webhook'u (en az 21 gün), boşta çalışan API sunucusu (25 gün) ve yazılmayan analitik olayları (~7 gün) [Analitik ve admin](#analitik) bölümünün grafiğinde; paylaşım hattı [İçerik otomasyonu](#icerik) bölümünde.

## Uyarının yolu

Her kaynak tek bir noktadan geçer ve seviyesini orada alır. Seviye kanalı, kişiyi ve süreyi belirler.

_Grafik: Kaynaklar: Dış API: 401, 402, 403, Dış API: 429, 5xx, zaman aşımı, Webhook hatası, Kredi ve bakiye, Bütçe eşiği, günlük kalem, Kota: e-posta, build, Neon, Token süresi, Alan adı, sertifika, üyelik, Zamanlanmış iş çalışmadı, Yedek doğrulaması, Mağaza incelemesi, sürüm, Bot kapısı sıçraması, Erişim, 5xx, OOM. Hepsi seviye seçen tek noktaya gider: API'de notify(), Google tarafında alarm politikası. Seviyeler: Acil (Kullanıcı şu an etkileniyor ya da para şu an gidiyor. İki kişiye aynı anda. Kanal: Telefona push ve e-posta. Kim: Ürün sahibi ve geliştirici. Ne zaman: Hemen, gece de.); Bugün (Bugün düzeltilmezse yarın kullanıcıya ya da faturaya yansır. Sessiz saatte sabahı bekler. Kanal: E-posta ve uyarı kutusu. Kim: Satırdaki sorumlu. Ne zaman: Aynı gün.); Haftalık (Acil değil ama doğru: yaklaşan süreler, sayaçlar, kapananlar. Boş hafta da 'N kontrol geçti' yazar. Kanal: Pazartesi özet e-postası. Kim: Ürün sahibi. Ne zaman: Haftada bir.). notify()'dan geçen her uyarı, kapanana kadar admin'deki uyarı kutusunda durur. Google'ın kendi alarmları kutuya düşmez._

## Ne, ne zaman, kime

Her satır bir uyarıdır; etiketsiz satırlar öneridir. Mesaj sütunu ilk satırı tırnak içinde verir, sonra etkisini, yapılacak işi ve bağlantıyı. Mağaza sürüm izleyicisi [Mobil uzaktan kontrol kiti](#mobilkit) bölümünde.

| Sinyal ve eşik | Seviye | Kanal ve kim | Mesajda ne yazar |
|---|---|---|---|
| Dış API ve ödeme |
| Dış API 402, 401 ya da 403 İlk seferde. O platformun işi durur, ötekiler sürer. | acil | Telefon ve e-posta. Ödemeyse ürün sahibi, yetkiyse geliştirici; öteki ikinci alıcıdır. | 'X paylaşımı durdu: hesabın kredisi bitti.' Bugünkü gönderi çıkmadı; Instagram sürüyor. Kredi yükle ya da X'i admin'den kapat. |
| Dış API 429, 5xx ya da zaman aşımı Üç denemeden sonra hâlâ hata. Zaman aşımında ilk seferde, çünkü gönderi gitmiş olabilir. | bugün | E-posta ve uyarı kutusu; geliştirici. | 'Instagram paylaşımı üç denemede çıkmadı.' Bugünkü gönderi yok. Platformun durumuna bak, düzelince 'yeniden dene'ye bas. |
| Webhook 5xx Tek 5xx; ya da 24 saattir başarılı teslim yok. | bugün | E-posta ve uyarı kutusu; geliştirici. | 'Ödeme kayıtları yazılmıyor.' Kullanıcıların Premium'u çalışıyor, sunucudaki kayıt eksik kalıyor. Sağlayıcının teslim listesi bağlantısı. |
| Para ve kota |
| Bütçe eşiği Beklenen aylığın %50'si, %80'i ve %100'ü; her faturalama hesabında. | bugün | E-posta ve uyarı kutusu; ürün sahibi. | 'Bu ay bütçenin %80'ine gelindi.' Kullanıcıya etkisi yok. En çok artan üç kalem ve fatura bağlantısı. |
| Bir kalemin günlük tutarı Önceki haftanın günlük ortalamasının 2 katı; faturalama dökümünden günlük sorgu. | bugün | E-posta; ürün sahibi ve geliştirici. | 'Harita API'si dün 2 katına çıktı.' Hangi uçtan geldiği ve günlük kota tavanı. Kapat ya da tavanı düşür. |
| Kredi ve bakiye Kalan bakiye 14 günlük harcamanın altında. Sağlayıcı okutmuyorsa kendi sayacımız. Sıfırda acil. | bugün | E-posta; ürün sahibi. | 'X kredisinin 14 günlük harcamadan azı kaldı.' Şimdilik etkisi yok; bitince X paylaşımı durur. Kredi yükle. |
| Kota E-posta günde 70 (sağlayıcı sınırı 100), build ayda platform başına 12 (15), Cloud Build 2.000 dk (2.500), Neon Free 80 CU-saat (100). | bugün | E-posta; geliştirici, build'de ürün sahibi. | 'iOS build hakkının 12'si kullanıldı, 3 kaldı.' Ay sonuna kadar yalnız acil sürüm. Hak ayın 1'inde 03:00'te yenilenir. |
| Süresi dolan şeyler |
| Token süresi 14, 7 ve 1 gün kala. Meta'da bitiş tarihi token kontrol ucundan okunur. 1 günde acil. | bugün | E-posta; geliştirici. | 'Instagram token'ı 7 gün sonra doluyor.' Dolunca günlük paylaşım ve haftalık rapor durur. Süresiz sistem kullanıcısı token'ına geç. |
| Alan adı, sertifika, mağaza üyeliği, kart 30 ve 7 gün kala; tarihler yenileme tablosunda. 7 günde bugün. | haftalık | Özet, sonra e-posta; ürün sahibi. | 'Geliştirici üyeliği 7 gün sonra bitiyor.' Biterse uygulama mağazadan kalkar. Ödeme sayfası bağlantısı. |
| İşler ve veri |
| Zamanlanmış iş çalışmadı Beklenen sürede başarı satırı yok (günlük işte 26 saat) ya da art arda 2 başarısızlık. Kullanıcıya giden işte acil. | bugün | E-posta ve uyarı kutusu; geliştirici. | 'Haftalık e-posta bu pazartesi gitmedi.' Aboneler bu hafta e-posta almadı. İşin son çalışması ve 'şimdi çalıştır'. |
| Yedek doğrulaması İlk başarısızlıkta: geri yükleme ya da boyut karşılaştırması tutmadı. | bugün [kanıtlı] | E-posta; iki yönetici. | 'Bu sabahki yedek doğrulanamadı.' Kullanıcıya etkisi yok; dünkü döküm ve veritabanının geçmişi duruyor. İşin logu bağlantısı. |
| Kullanıcıya dokunan |
| Erişim, 5xx, açılışta veritabanı yok Ürün A'daki eşikler: en az iki bölgeden erişilemiyor, 5 dk'da 3'ten fazla 5xx. | acil [kanıtlı] | E-posta (bizde kurulu); telefon kanalı öneri. Geliştirici ve ürün sahibi, aynı anda. | 'Uygulama açılmıyor.' Kullanıcılar giriş yapamıyor. Geliştirici bakıyor; uptime grafiği bağlantısı. |
| Bellek aşımı (OOM) Günde 1 ve üstü geliştiriciye; günlük sayı haftalık özette. | bugün | E-posta; geliştirici. Ürün sahibine haftalık sayı. | 'Site sunucusu dün 192 kez bellek aşımıyla yeniden başladı.' O isteklere 503 döndü. Bellek ve bot trafiği grafiği. |
| Giriş kodu e-postası Gönderim hatası ya da 429 ilk seferde. Kod isteyip girmeyenlerin günlük oranı da izlenir; eşiğini ürün seçer. Oran artışında bugün. | acil | Telefon ve e-posta; geliştirici ve ürün sahibi, aynı anda. | 'Giriş kodları gitmiyor: e-posta sağlayıcısı 429 döndü.' Yeni girişler duruyor. Gönderim logu ve sağlayıcının durum sayfası bağlantısı. |
| Mağaza incelemesi ve sürüm Ret; ya da mağazadaki sürüm politikadaki önerilenden farklı. | bugün | E-posta; ürün sahibi. | 'iOS sürümü incelemeden döndü.' Kullanıcılar eski sürümde kalıyor. Ret gerekçesi ve inceleme notu bağlantısı. |
| Bot kapısı sıçraması Portal, token bağlantısı, form ve yasal sayfalarda 403 ya da 429 sayısı 0'ın üstünde. | bugün | E-posta; geliştirici. | 'Portalda bugün reddedilen istek var.' Gerçek kullanıcı olabilir. Kural ve adres listesi; kuralı gölgeye al. |

## Mesaj nasıl yazılır

Ürün sahibi uyarıyı telefonda, bir bakışta okur. Önce kurallar, sonra iki örnek.

1. [öneri]
Konu tek satırdır: seviye ve ne olduğu, düz Türkçe.

Ürün A'nın beş alarmında kendi konu satırı yok; konuyu Google üretiyor. Google konu için 255 karakter ve en çok 3 bağlantı veriyor.

2. [öneri]
İkinci satır kullanıcıya etkisini söyler; etkisi yoksa onu yazar.

Webhook olayında ürün sahibinin işine yarayan, etkiyi söyleyen kısa cümleydi: 'ödemeler etkilenmedi'.

3. [öneri]
Üçüncü satır tek iş ve sorumlusu, dördüncü satır bağlantıdır.

Yığın izi, istek gövdesi, token ve kişisel veri mesaja girmez; ayrıntı admin'deki kayıttadır. Ağ hatasında istemci kütüphanesi tam adresi hata metnine koyar; adreste token varsa mesaja da düşer.

4. [öneri]
Aynı arıza bir kez bildirilir, sonra günde bir hatırlatılır.

Anahtar kaynak, tür ve hedeftir; açık uyarıda yeni olay yalnız sayacı artırır. Kapanmamış arıza her sabah yeniden gelir. Susturmak bir düğmedir ve sebebiyle kayda geçer.

5. [öneri]
Telefona yalnız acil uyarı gider; acilin sessiz saati yoktur.

Bugün seviyesindekiler sessiz saatte (örnek: 22:00–08:00) bekler, sabah tek e-postada toplanır.

6. [öneri]
Acil uyarının iki alıcısı vardır; ikisine aynı anda gider.

Bekleyip ikinci kişiye geçen bir zamanlayıcı kurulmaz. Cloud Run min 0'da arka plan döngüsü yok. Birkaç dakikada bir çalışan bir kontrol Neon'u uyanık tutar, API çökünce de çalışmaz. Google bir politikadaki bütün kanallara aynı anda gönderir. Uyarı kutusundaki 'gördüm' kimin baktığını kayda geçirir, öteki kişi aynı işe başlamaz. Google'da 'gördüm' demek tekrar bildirimi durdurmaz; durduran kapatmaktır.

7. [öneri]
Haftalık özet boş haftada da gelir ve 'N kontrol geçti' yazar.

Ürün A'da gece raporu geldiği halde gelmedi sanıldı; o korkuyla açılan bir ayar API sunucusunu 25 gün boşta çalıştırdı (ayda ~₺255). Her hafta aynı saatte gelen ve 'N kontrol geçti' yazan özet bu tahmine yer bırakmaz.

8. [kanıtlı]
Her uyarı türü bir kez sahte bir hatayla uçtan uca denenir; konuda TEST yazar.

Ürün A'nın yedek alarmı böyle denendi: hata 16:57, alarm 17:01, kapanış 17:11. Politikanın adına geçici olarak TEST eklenir; kapanış postası da bu adı taşıdığı için ad, alarm kapandıktan sonra eski haline döner.

### İki örnek

**Konu:** **[Acil]** X paylaşımı durdu: hesabın kredisi bitti

**Etkisi:** Bugünkü gönderi X'te çıkmadı. Instagram ve e-postalar sürüyor.

**Yapılacak:** Kredi yükle ya da X'i admin'den kapat. Sorumlu: ürün sahibi.

**Bağlantı:** Admin'deki uyarı; X geliştirici konsolu.

**Konu:** **[Bugün]** Ödeme kayıtları yazılmıyor

**Etkisi:** Kullanıcıların Premium'u çalışıyor; sunucudaki ödeme kaydı eksik kalıyor.

**Yapılacak:** Webhook logundaki hatayı düzelt, sonra sağlayıcının panelinden başarısız teslimleri yeniden gönder. Sorumlu: geliştirici.

**Bağlantı:** Admin'deki uyarı; sağlayıcının teslim listesi.

## Bizim yığında nasıl kurulur

Altı parça, hepsi mevcut yığının içinde: Go API, Postgres, Cloud Run, Cloud Monitoring, Cloud Billing. Acil uyarının teslimi API'nin kendisine bağlı değildir.

### 1. notify() ve uyarı tablosu

[öneri]
API'deki tek giriş noktası. Uyarıyı tabloya yazar; aynı anahtar açıkken yeni satır açmaz, sayacı artırır. Yeni açılan ya da günü dönen uyarı için tek bir yapılandırılmış log satırı yazar.

**Nerede:** API içinde; tablo ürünün kendi Postgres'inde.

**Bozulursa:** Veritabanına yazamazsa log satırını yine yazar; teslimi Google'ın alarmı yapar.

**Nasıl denenir:** Admin'deki deneme düğmesi her türden bir TEST uyarısı üretir.

### Tablo, yardımcı ve süzgeç

Birinci parçanın Postgres tablosu ve Go fonksiyonu; sağ altta, aşağıdaki ikinci parçanın log süzgeci ve etiketi.

```
CREATE TABLE alerts (
  id        bigserial PRIMARY KEY,
  key       text NOT NULL,  -- kaynak:tür:hedef
  level     text NOT NULL CHECK
    (level IN ('acil','bugun','haftalik')),
  title     text NOT NULL,  -- tek satır
  effect    text NOT NULL,  -- kullanıcıya etkisi
  action    text NOT NULL,  -- yapılacak iş
  link      text,
  owner     text NOT NULL,  -- urun | gelistirici
  count     integer NOT NULL DEFAULT 1,
  first_at  timestamptz NOT NULL DEFAULT now(),
  last_at   timestamptz NOT NULL DEFAULT now(),
  acked_at  timestamptz,
  acked_by  text,
  closed_at timestamptz,
  test      boolean NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX alerts_open
  ON alerts (key) WHERE closed_at IS NULL;
```

```
type Alert struct {
  Key, Level, Title, Effect string
  Action, Link, Owner       string
}

// Notify satırı açar ya da açık olanın
// sayacını artırır. Yeni ya da günü dönen
// uyarıda tek log satırı yazar.
func Notify(ctx context.Context, a Alert) error

slog.Error("alert",
  "alert_level", a.Level,
  "alert_key", a.Key, "title", a.Title)
```

```
resource.type="cloud_run_revision"
jsonPayload.message="alert"
jsonPayload.alert_level="acil"

labelExtractors:
  alert_key: EXTRACT(jsonPayload.alert_key)
```

[Go API](#katman-2) katmanındaki `ReplaceAttr` `msg` alanını `message` yapar. Süzgeç bu yüzden `jsonPayload.message` alanına bakar.

### 2. Google'ın log alarmı

[öneri]
İki politika: acil satır telefona ve e-postaya, bugün olan e-postaya. Politika alert_key etiketini çıkarır; her uyarı kendi zaman çizgisini alır. Bildirim aralığı 1 saat, kendiliğinden kapanma 1 gün.

**Nerede:** Cloud Monitoring. Bizde iki e-posta kutusuna kurulu, hiç tetiklenmedi; iki politika ve mobil kanal denenmedi.

**Bozulursa:** Günde en çok 20 olay açar. Mobil uygulama, Slack ve webhook aynı iç servise dayanır; yanında e-posta durur.

**Nasıl denenir:** Politika kurulmadan önce süzgeç Logs Explorer'da çalıştırılır. Admin'deki deneme uyarısının satırı orada görünmüyorsa alarm kurulmuş sayılmaz. Adına TEST eklenir, sahte satır üretilir, kapanınca ad geri alınır. Tarif bizde metrik tabanlı yedek alarmında denendi.

### 3. Admin'deki uyarı kutusu

[öneri]
Açık uyarılar seviyeye göre sıralı; 'gördüm' ve 'kapat' düğmeleri, ikisi de denetim kaydına. Kapanan uyarı silinmez: bulut logları 30 günde gider, tablo kalır.

**Nerede:** Admin ekranı; okuma ucu tabloyu okur.

**Bozulursa:** Kutu okunamazsa acil uyarı yine gelir; teslimi Google'ın alarmı yapar, iki alıcıya birden.

**Nasıl denenir:** Deneme uyarısı açılır, iki alıcıya da geldiği görülür; 'gördüm' basılır, kayıtta kimin bastığı görülür.

### 4. Bütçe ve Pub/Sub

[öneri]
Her faturalama hesabında bütçe: %50, %80, %100, e-postayla. Aynı bütçe bir Pub/Sub konusuna bağlanır; Google günde birkaç kez tutarı, bütçeyi ve aşılan eşiği yollar. Küçük bir uç mesajdaki alertThresholdExceeded değerini GCS'teki küçük bir dosyada tutulan son eşikle karşılaştırır; dosya dönem başına (costIntervalStart) göre tutulur, yeni ayda sıfırdan başlar. Değer saklanandan büyük değilse veritabanına hiç gitmez; büyükse notify() çağırır ve dosyayı günceller. Pub/Sub aynı mesajı birden çok kez ve sırasız getirebilir; 'büyükse' kuralı bunu da karşılar. Günde birkaç mesaj böylece veritabanını uyandırmaz.

**Nerede:** Cloud Billing ve Pub/Sub; uç API içinde.

**Bozulursa:** Bütçe harcamayı durdurmaz. Durduran, ücretli API'nin günlük kotasıdır.

**Nasıl denenir:** Bütçe tutarı geçici olarak harcamanın altına çekilir, ilk mesajın geldiği görülür.

### 5. Denetim işi

[öneri]
Günde iki kez: sağlayıcı bakiyeleri ya da kendi sayaçlarımız, kotalar, token bitişleri, yenileme tablosundaki tarihler ve her zamanlanmış işin son başarısı (günlük işte 26 saat). Bulduğunu notify()'a verir. Sabah çalışması veritabanı penceresine girer, tablolara ve sayaçlara bakar. Akşam çalışması veritabanına dokunmaz: yalnız logları ve sağlayıcı API'lerini okur, bir şey bulursa notify()'a verir.

**Nerede:** Dağıtıcı job'ın kod takviminde, sabah ve akşam. Ayrı Scheduler işi açılmaz. Diğer işlerin hatası onu durdurmaz. İş yine de API'de bir uç olarak kalacaksa token'ı API kendisi doğrular: OIDC token'ının hedef adresi (audience) ve servis hesabı kontrol edilir. API mobil istemciler için ağda açık olduğundan bu kontrolü Cloud Run yapmaz.

**Bozulursa:** Her çalışma başarı satırı yazar; bu satırın log metriği 23,5 saat boş kalırsa Google'ın alarmı çalar. Dağıtıcı durursa bu yokluk alarmı onu da yakalar.

**Nasıl denenir:** Bitiş tarihi ileri sarılmış sahte bir token ve duraklatılmış bir iş ile eşikler denenir.

### 6. Haftalık özet

[öneri]
Pazartesi sabahı: hafta içinde açılan ve kapanan uyarılar, eşiğe yaklaşan sayaçlar, 30 gün içinde dolacak süreler, OOM ve 5xx sayıları.

**Nerede:** Zamanlanmış iş; ürünün kendi e-posta sağlayıcısıyla gider.

**Bozulursa:** Özet de bir iştir; gelmemesi denetim işinin listesindedir.

**Nasıl denenir:** İlk pazartesi özetin iki alıcıya da geldiği görülür.

Bugün hepsi ücretsiz: alarm politikaları, bütçe ve bu hacimde log tabanlı alarm. Alarm ücreti en erken 1 Eyl 2027'de, metrik referansı başına ayda $0,35; ücretsiz katmanların ayrıntısı [Ücretsiz katmanlar](#ucretsiz) bölümünde.

## Kendi altyapımız ve hazır hata servisleri

Sunucuda hazır servis gerekmez; notify() altyapısı ve Google'ın ücretsiz Error Reporting'i yeter. Telefondaki native çökmeyi ise yalnız uygulamaya gömülü bir araç görür; o araç ilk mağaza sürümünden önce kurulur.

**Bizde bugün.** Dört üründe Sentry, Crashlytics ya da Bugsnag yok; Error Reporting API'si de kapalı. Alarma bağlı sunucu hatası yalnız Ürün A'nın 5xx'i ve açılıştaki veritabanı hatası. Ürün A ve C'nin mobil uygulaması hatayı yalnız konsola yazıyor; Ürün A'da onu API logundan ve şikayetten öğreniyoruz. Mağaza konsollarının SDK'sız çökme raporu var; okumadık.

| Seçenek | Bedel ve ücretsiz sınır | Ne verir | Eksik ve dikkat |
|---|---|---|---|
| Kendi altyapımız notify(), tablo | ~$0; mevcut Postgres, Cloud Run, Monitoring. Log ayda 50 GiB'a kadar ücretsiz. | Ürün sahibinin dilinde uyarı; aynı arıza bir kez bildirilir. Veri kendi veritabanımızda, yeni veri işleyen yok. | Yığın gruplama, kaynak haritası, native çökme, çökmesiz oran yok. Emek: bir tablo, bir fonksiyon, iki alarm, iki iş. |
| Error Reporting Google Cloud | Ücretsiz; bedeli log. Kayıt 30 gün. | Sunucu hatasını tür ve üst beş çerçeveyle gruplar; yeni ya da geri dönen hatada e-posta, Slack, webhook. | Yığın stack_trace'te olmalı; bizim panikler 'stack' alanında, görünmez. Saatte 20 bildirimden sonra 6 saat susar. |
| Sentry sunucu, web ve Expo SDK'sı | Developer $0: 1 kullanıcı, ayda 5.000 hata, 30 gün. Team $26/ay (yıllık): 50.000 hata, 90 güne kadar. | JS ve native çökme, gruplama, kaynak haritası (EAS Build'de kendiliğinden), sürüm başına çökmesiz oran. | AB bölgesi (Frankfurt) yalnız kurulurken seçilir; hesap verisi ABD'de. Developer yalnız e-postayla bildirir. Belgedeki örnek IP ve kullanıcıyı yollar. |
| Crashlytics Firebase; yalnız mobil | Ücretsiz, kota yok. Kayıt 90 gün. | Native çökme, ölümcül olmayan hata, Android'de ANR, etkilenen kullanıcı sayısı, e-posta uyarısı. | Expo Go'da çalışmaz, development build ister. Veri yeri seçilemez. Sunucu ve web yok. |

### Yeni üründe

1. [kanıtlı]
Sunucu ve iş hataları Monitoring alarmına bağlanır; ikinci bir log servisi eklenmez.

Ürün A'da beş alarm ücretsiz kurulu; yedek alarmı denemede 4 dk'da çaldı. 5xx ve log alarmları hiç çalmadı.

2. [öneri]
notify(), uyarı tablosu ve Error Reporting ilk sürümde kurulur.

Yığın stack_trace alanına yazılır, sahte bir panikle grubun açıldığı görülür. Ayrı fatura yok; bedeli log.

3. [öneri]
Mobilde ilk mağaza sürümünden önce bir çökme aracı kurulur.

Build'e girmeyen araç o build'in native çökmesini görmez; kurulana kadar mobil hata error_shown olayıyla API'ye gelir. Araç AB bölgeli Sentry, [KVKK](#kvkk) adımlarından sonra; veri yerinin seçilememesi kabul edilirse Crashlytics.

4. [öneri]
Kişisel veri hata yüküne girmez.

sendDefaultPii false; beforeSend e-posta, token ve gövdeyi siler; hesap kimliği yerine kurulum kimliğinin HMAC'i.

5. [öneri]
Hata fırtınası fatura çıkaramaz.

Sentry'de ani artış koruması (spike protection) açık, kullandıkça öde bütçesi $0; kota bitince olay düşer. Error Reporting'in bedeli log; aylık log 25 GiB'ı (ücretsiz 50 GiB'ın yarısı) geçince alarm çalar.

6. [öneri]
Ürün sahibine yalnız kullanıcıyı etkileyen kısım gider, o da notify()'dan.

Yeni sürümdeki çökme artışı, ödeme ve girişteki hata. Error Reporting'in webhook kanalı notify()'a bağlanır.

error_shown olayı [Analitik ve admin](#analitik), sürüm ve geri alma [Mobil uzaktan kontrol kiti](#mobilkit) bölümünde.

## Bizde ne oldu

Olayların hepsi 2026'da. Kırmızı kenarlı kartlar geç öğrenileni, yeşil kenarlı kart işe yarayanı gösterir. Gecikme, arızanın başından fark edilmesine kadar geçen süredir.

30 gün. gecikme Ürün C, Ağu–Eyl

### X kredisi bitti

30 paylaşım denemesinin 30'u 402 aldı. Sinyal her gün inceleme e-postasında bir satırdı; ürün sahibi 'X çalışmıyor' deyince bakıldı.

**Yakalardı** 402 ilk seferde acil. [Vaka 26](#vaka-26)

en az 21 gün. gecikme Ürün A, Eyl

### Ödeme webhook'u 500 döndü

Hata logu yoktu, istek logunda yalnız 500 kodu vardı; sağlayıcının panelinde başarısız teslimler listeliydi. Bir duyuru için açılan 5 dakikalık canlı izlemede görüldü.

**Yakalardı** Webhook tek 5xx. [Vaka 25](#vaka-25)

₺1.500. bir aylık kalem Ürün B, Ağu

### Harita API'si faturada görüldü

Projenin Google faturasının ~%72'si. Bütçe uyarısı ve günlük kota tavanı yoktu.

**Yakalardı** Kalemin günlük tutarı 2 katı. [Pahalı dış API'ler](#pahali-api)

192. en kötü günde Ürün B, Eki

### Bellek aşımı tesadüfen bulundu

Bot trafiği altında site sunucusu günde 19 ile 192 kez yeniden başlıyordu; bir maliyet incelemesinde görüldü.

**Yakalardı** OOM günde 1 ve üstü. [Gözlem ve alarmlar](#katman-10)

~21 saat. gecikme Ürün C, Eyl

### Instagram token'ı doldu

Ömrü 60 gündü ve ilk günden belliydi. Token dolduktan sonraki sabah günlük paylaşım ve haftalık rapor birlikte düştü; iki gönderi ~1 saat 20 dk geç çıktı.

**Yakalardı** 14, 7 ve 1 gün kala uyarı. [İçerik otomasyonu](#icerik)

2 gün. gecikme Ürün A, Eyl

### Build kotası bitti

iOS hakkı 22 Eyl'de doldu, 24 Eyl'de build reddedilince öğrenildi; sürüm 1 Eki'ye kaydı.

**Yakalardı** Hak %80'de uyarı. [Vaka 19](#vaka-19)

4 kurum. kodu bekletti Ürün A, Eki

### Giriş kodları kurum geçitlerinde bekledi

Sağlayıcı 'teslim edildi' diyordu; dört büyük kurumun posta geçidi kodu bekletti ve 10 dakikalık kod ölü geldi.

**Yakalardı** Kod isteyip girmeyenlerin oranı. [Vaka 27](#vaka-27)

4 dk. hatadan alarma Ürün A, 23 Eyl

### Yedek alarmı uçtan uca denendi

Planlı deneme, bilerek bozulan çalışma: hata 16:57, alarm 17:01, kendiliğinden kapanış 17:11. Konuya TEST yazıldı.

**Kural** Her alarm bir kez böyle denenir. [Veritabanı yedeği](#yedek)

## Gün 0 kontrol listesi

İlk gerçek kullanıcıdan ve ilk ücretli API anahtarından önce. Etiketsiz satırlar öneridir; her kutu ilk sürümden önce işaretlenir.

- [ ] Uyarı listesi yazıldı: her dış bağımlılık ve her bütçe için sinyal, eşik, seviye, kanal ve sorumlu.

- [ ] Her faturalama hesabında bütçe var: %50, %80, %100; e-posta ve Pub/Sub.

- [ ] Ücretli her API'de günlük kota tavanı; bakiyesi okunamayanda kendi sayacımız.

- [ ] notify(), uyarı tablosu ve admin'deki uyarı kutusu ilk sürümde.

- [ ] Sahte bir panik Error Reporting'de grup açtı; mobilde çökme aracı ilk mağaza sürümünde, kişisel veri temizliği ve $0 bütçeyle.

- [ ] İki log alarmı (acil, bugün) alert_key etiketiyle kurulu; acil olan iki kişinin telefonuna ve e-postasına gidiyor.

- [ ] Denetim işi günde iki kez çalışıyor; 23,5 saat susarsa Google'ın alarmı çalıyor.

- [ ] Webhook tek 5xx'te uyarı veriyor; sağlayıcının panelinde bir teslim başarılı göründü.

- [ ] Yenileme tablosu dolu: alan adları, sertifikalar, mağaza üyelikleri, kartlar, token'lar.

- [ ] Her uyarı türü, Ürün A'nın yedek alarmındaki gibi, TEST konusuyla uçtan uca denendi. [kanıtlı]

- [ ] Her alıcı TEST postasını gördüğünü yazdı; yazmayanın adresi düzeltildi.

- [ ] İlk haftalık özet pazartesi geldi ve okundu.

## Tuzaklar

Hepsi bizde görüldü ya da resmi belgede yazılı.

'Token sağlam' kontrolü ödeme hatasını göstermez: hesabı okumak ve medya yüklemek geçti, yalnız gönderi 402 aldı.

Sağlayıcının 'teslim edildi'si yalnız karşı tarafın kabul ettiğini söyler: kod e-postaları kurum geçitlerinde bekledi.

Başarısızlığı sayan alarm hiç çalışmayan işi görmez: Ürün A'nın yedek alarmları zamanlayıcı duraklatılırsa susar.

Kota uyarısı, dolan kotayı kullanan kanaldan gönderilirse o da gitmez; uyarı başka bir kanaldan çıkar.

Google'ın mobil uygulama, Slack ve webhook kanalı aynı iç servise dayanır; SMS tam güvenilir değildir, her bölgede de yoktur. Yanında e-posta ya da Pub/Sub durur.

Ürün A'nın alarmları iki kişiye gidiyor; postanın kutuya düştüğünü yalnız biri doğruladı.

Google bir log alarmında günde en çok 20 bildirim gönderir. Günde 192'ye varan OOM tek tek bildirilirse sınır dolar ve sonraki uyarı o gün gitmez; sayı özete gider.

### Ölçülmeyenler

Bu araştırmada okunamayan ya da bizde denenmemiş olanlar.

Bütçelerin sayısı ve eşikleri okunmadı (Budget API kapalı); Ürün B'de Ağu–Eyl 2026'da bütçe uyarısı yoktu.

Google Cloud mobil uygulaması kanalı bizde kurulmadı; telefona ne kadar sürede geldiği ölçülmedi.

Log eşleşmesi koşulunun en erken 1 Eyl 2027'deki alarm ücretine girip girmeyeceği belli değil; bugün ücretsiz.

Giriş kodu gecikmesinden etkilenen giriş sayısı ölçülmedi.

Bellek aşımlarının ne zamandan beri sürdüğü bilinmiyor; ilk görüldüğü yer bir maliyet incelemesiydi.

Sessiz saat, 14 günlük bakiye eşiği ve giriş kodu oranının eşiği bizde denenmedi; kurallardaki saatler örnektir, ürünün temposuna göre ayarlanır.

## Kaynaklar

Resmi sayfalar 8 Ekim 2026'da okundu. Bizim rakamlarımız alarm listelerinden, vaka kayıtlarından ve faturalardan.

**Cloud Monitoring bildirim kanalları ve yedek kanal**https://docs.cloud.google.com/monitoring/support/notification-options
**Alarm belgesi: konu satırı ve bağlantılar**https://docs.cloud.google.com/monitoring/alerts/doc-variables
**Log tabanlı alarm: bildirim aralığı, kapanma**https://docs.cloud.google.com/logging/docs/alerting/log-based-alerts
**Log alarmında etiket ve günlük olay sınırı**https://docs.cloud.google.com/logging/docs/alerting/monitoring-logs
**Metrik yokluğu alarmı: en çok 23,5 saat**https://docs.cloud.google.com/monitoring/alerts/metric-absence
**Olaylar, 'gördüm' ve tekrar bildirim**https://docs.cloud.google.com/monitoring/alerts/incidents-events
**Cloud Billing bütçeleri**https://docs.cloud.google.com/billing/docs/how-to/budgets
**Bütçe bildirimini Pub/Sub ile almak**https://docs.cloud.google.com/billing/docs/how-to/budgets-programmatic-notifications
**Logging, Monitoring, Error Reporting fiyatları**https://cloud.google.com/products/observability/pricing
**Resend kota ve sınırları**https://resend.com/docs/knowledge-base/account-quotas-and-limits
**Expo fiyatları, build hakkı**https://expo.dev/pricing
**X API yanıt kodları**https://docs.x.com/x-api/fundamentals/response-codes-and-errors
**Meta uzun ömürlü token**https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived
**Meta sistem kullanıcısı token'ı**https://developers.facebook.com/docs/business-management-apis/system-users/install-apps-and-generate-tokens
**Error Reporting: yığın alanları**https://docs.cloud.google.com/error-reporting/docs/formatting-error-messages
**Error Reporting: bildirim ve saatlik sınır**https://docs.cloud.google.com/error-reporting/docs/notifications
**Sentry fiyatları ve kotalar**https://sentry.io/pricing/
**Sentry veri bölgesi**https://docs.sentry.io/organization/data-storage-location/
**Crashlytics verisi, yeri ve süresi**https://firebase.google.com/support/privacy

<a id="analitik"></a>

Gözlem ve alarmlar

# Analitik ve admin

Olay kaydı ve yönetim yüzeyi mobil kit gibi ilk sürümle kurulur. Sonradan eklenen olayın geçmişi geri gelmez; admin ekranı olmayan her ayar elle bir ortam değişkeni ve yeni bir revizyon olur.

**Kural:** Olay kaydı ve admin uçları ilk sürümle gelir.

İlk build'de tek bir olay ucu, on zorunlu olay ve her olayda platform, sürüm ve build bulunur. Admin aynı gün açılır: ayrı giriş, okuma ekranları, bayrak, güncelleme politikası ve duyuru uçları, işler ve webhook'lar ekranı, değişiklikle aynı işlemde yazılan denetim kaydı. Sıra ürün sahibinin beş sorusuyla başlar; olay listesi bu sorulardan çıkar.

Dört ürünümüzün hiçbirinde kurulum ve paywall olayı yok; 'kaç kişi indirip kaçı ödedi' sorusunun cevabı bugün de yok. Admin tarafında okuma ekranları erken geldi; bayrak, güncelleme politikası ve iş durumu ekranları gelmedi. Mobil kitin bayrak, güncelleme politikası ve duyuru parçaları bu bölümdeki admin uçlarından beslenir: [Mobil uzaktan kontrol kiti](#mobilkit).

**~1 hafta** Ürün A'nın ilk analitik haftası (26 Ağu–2 Eyl 2026) yazılmadı. API her olaya 500 döndü, uygulama hatayı göstermedi. Cihaz kuyruklarından yalnız bir kısmı sonra geldi.
**21 gün** Aynı jsonb hatası ve bir NOT NULL hatasıyla ödeme webhook'u 2–23 Eyl 2026 arası her teslimde 500 döndü; 23 Eyl öncesindeki ödeme olayları kayıp.
**139 / 211** 28 Eyl 2026'da 28 günlük sayım iOS'ta 211 telefonun 139'unu eski sürümde gösterdi. Gelir aracının 7 günlük aktif müşteri sayımında gerçek 308'de 22'ydi.
**553 ile 228** 28 Eyl 2026'da aynı dakikada rapor e-postası ve gelir aracının paneli 'yeni müşteri' için bu iki rakamı verdi. E-posta aracın eski bir ucunu okuyordu.
**en az 14** 19 Eyl–8 Eki 2026 arasında güncelleme politikası (9) ve bayrak (5) için elle açılan revizyon. Admin ekranı yoktu.
**~₺255/ay** Gece raporu gelmedi sanıldı, API konsoldan sürekli açık bırakıldı (7 Eyl–2 Eki 2026). Rapor gelmişti; bunu gösteren bir yer yoktu.

## Kimsenin görmediği sorunlar

Sorunun başladığı günden fark edildiği güne; ölçek gerçek, 15 Ağu–8 Eki 2026.

_Grafik: Kimsenin görmediği sorunlar, başlangıçtan fark edilene, 15 Ağu-8 Eki 2026: Ürün B: arama özeti toplanmadı 2 gün; Ürün A: analitik olayları yazılmadı ~7 gün; Ürün C: paylaşım bakiye bitince düştü 30 gün; Ürün A: ödeme webhook'u 500 döndü 21 gün; Ürün A: API boşuna hep açık kaldı 25 gün_
[öneri] Admin'de her iş, webhook ve olay akışı için son başarılı zaman ve 24 saati geçince çalan bir alarm olsaydı beşi de ilk gün görünürdü. Alarmlar [Gözlem ve alarmlar](#katman-10) katmanında, paylaşım hattının kurulumu [İçerik otomasyonu](#icerik) bölümünde. Webhook, boşta açık API ve paylaşım hattının tam kaydı [Vakalar](#vakalar) bölümünde.

## Dört üründe bugün

8 Ekim 2026 durumu. Son satır sonradan eklenenleri tarihiyle gösterir; ilk sürümde olmayan her olay o tarihe kadarki veriyi kaçırdı, mobilde her biri bir mağaza sürümünü bekledi.

Var Kısmen Yok Gerekmiyor

|  | Ürün A | Ürün B | Ürün C | Ürün D |
|---|---|---|---|---|
| Analitik |
| Kendi olay tablosu | Var: İlk şemada (25 Ağu 2026); ilk hafta yazılmadı | Var: Olay, arama ve sonuçla etkileşim | Kısmen: Kayıt başına günlük sayaç | Yok: Yalnız IP ve tarayıcı özeti |
| Olayda platform ve sürüm | Var: İlk şemadan beri; olayda build yok | Yok: Mobil sabit 1.0.0 gönderiyor | Yok | Yok: Olay tablosu yok |
| Kurulum ve paywall olayı | Yok: Reklam kampanyasının etkisi okunamadı | Yok | Yok | Yok |
| Mobilde ölçüm | Var: Kendi ucu, cihazda 100 olaylık kuyruk | Var: Web ile aynı uç | Yok: Çökme raporu da yok | Gerekmiyor: Mobil uygulama yok |
| Admin |
| Admin yüzeyi | Var: Portalın içinde; 40 uç, 23'ü okuma | Var: Web uygulamasının içinde; 34 uç | Var: Ayrı uygulama; 45 admin, 12 editör ucu | Yok: Admin yok; küçük sitede bugüne kadar maliyetsiz |
| Ayrı admin girişi | Var: E-posta kodu, ayrı oturum tablosu | Var: E-posta kodu, kendi ucu | Var: E-posta kodu, rol veritabanında | Yok: Admin yok |
| Bayrak ve güncelleme politikası admin'den | Yok: Ortam değişkeninde | Yok | Kısmen: Yalnız beta bandı ve site sürümü | Yok |
| Push duyurusu admin'den | Var: Kitle, platform, iki dil; arka planda | Yok | Yok: Admin uç listesinde yok | Yok |
| Sonradan gelenler | Kullanıcı tipi alanı ve kayan admin oturumu 21 Eyl; paylaş ve PDF tablosu 29 Eyl, mobilde sayım bir sonraki mağaza sürümüyle; web oturum kaydı 6 Eki; PDF sonucu 7 Eki. | Günlük toplama API sürecine 19 Ağu. | Kayıt geçmişi 5 Eki. | Değişmedi. |

## Bizde ne oldu

Kırmızı kenarlı kartlar bozulanı, yeşil kenarlı kart işe yarayanı anlatır.

115 / 0. Ürün A, 1–7 Eki 2026

### Reklamın neden gösterilmediği ayrılamadı

Ödüllü reklam teklifinde konsol yaklaşık 115 istek ve 0 gösterim gösterdi. 'Kimse seçmiyor' ile 'reklam açılmıyor' ayrılamadı; sonuç olayı ancak yeni bir mağaza sürümüyle geldi.

**Kural** Para kazandıran her yol ilk sürümde 'görüldü' ve 'nasıl bitti' olaylarını gönderir; sonuç sabit bir listeden gelir. [öneri]

%50’den %22–32’ye. Ürün A, 6 Eki 2026

### Gelir düşüşünde bizim payımız sürüm kırılımıyla ayrıldı

İlk şüphe izin sorusuydu (ATT), sebep o değildi. Düşüş yalnız iOS'taydı ve sebebi kanıtlanamadı. Bizden kaynaklı kısım sürüm kırılımında göründü. Üç sürümde tam ekran reklamın gösterilme oranı %50'den %22–32'ye inmişti (Eylül'e yaklaşık $1,5–2,2); iki sürüm sonra düzeldi.

**Kural** Gelir değişikliği önce sürüm ve platform kırılımıyla okunur. [öneri]

229 ile ~15. Ürün A, 3 Eyl 2026

### Kuyruktan gelen eski olaylar 'bugün' sayıldı

Olay kaybı düzeltilince cihaz kuyrukları boşaldı. Admin 'bugün 229' gösterdi, gerçekte yaklaşık 15'ti; sayım olayın yazıldığı anı kullanıyordu.

**Kural** Olayın hem gerçekleştiği an hem yazıldığı an tutulur; raporlar gerçekleştiği anı sayar. [kanıtlı]

4 hesaplayıcı. Ürün A, 20 Eyl 2026 öncesi

### Bir alt ürün analitikte adsızdı

API'nin listesinde bir tür yoktu; istemci onu genel 'özel' değeriyle gönderdi, dört hesaplayıcı hiç olay göndermedi. Önceki satırlar düzeltilemez.

**Kural** Ad ve değerler tek sözlüktedir; bilinmeyen değer 'diğer'e düşmez, 400 döner ve sayılır. [öneri]

2 ayar. Ürün B, 19 Ağu 2026

### Denetim kaydı bir hatayı geri aldırdı

Canlıya bağlı bir dizüstünden çalışan temizlik komutu iki mağazanın admin'in verdiği öne çıkarma ayarını sildi. Değerler işlem kaydından geri yüklendi.

**Kural** Admin değişikliği denetim kaydına, değişiklikle aynı işlemde yazılır. [kanıtlı]

114 arama. Ürün B, 17–19 Ağu 2026

### Admin paneli ilk gün boştu

Günlük toplama hiç deploy edilmemiş ayrı bir worker'daydı ve iki gündür çalışmıyordu. API sürecine alınınca sorgu metrikleri 3 satırdan 48'e çıktı.

**Kural** Toplama işi deploy edilen bir sürecin içindedir ya da izlenen bir iştir. [kanıtlı]

Gün 0

## Analitik

Olay sunucuya, kendi veritabanımıza gider. Üçüncü taraf araç ancak veri yeri, onay ve KVKK adımı yazıldıktan sonra gelir.

[öneri] Bizim beş sorumuz:

1. Kaç kişi indirip ilk işi yaptı?

2. Kaçı Premium ekranını gördü?

3. Kaçı ödedi?

4. Hangi sürümde ne bozuldu?

5. Reklam neden gösterilmedi?

[kanıtlı]
** Olayda kişiyi gösteren hiçbir şey olmaz**: kullanıcı kimliği, ad, e-posta, telefon, serbest metin, kesin konum. Kurulum kimliği sunucu anahtarıyla HMAC'lenir; anahtar ortam başına ayrıdır.
[ölçüldü]
** Olay ilk sürümde gelir**. Sonradan eklenen olayın geçmişi yoktur ve mobilde her yeni olay bir mağaza sürümünü bekler. Bizde paylaşım sayımı ve PDF sonucu ayrı birer mağaza sürümünü bekledi.

### Olay adları

[öneri]
Ad küçük harf, İngilizce, alt çizgili; önce nesne, sonra eylem; en çok 40 karakter (GA4 sınırı): `app_open`, `signup_complete`, `paywall_view`, `purchase_result`, `ad_result`, `share_tap`, `error_shown`. Sonuç aynı olayın `outcome` alanına yazılır ve sabit bir listeden gelir (bizde Premium'suz PDF için 10 değer). Bir ad bir kez kullanılır, anlamı değişirse yeni ad açılır. Bütün ad ve değerler tek bir sözlük dosyasındadır; istemci ve sunucu testleri bu dosyayı okur.

### Her olayda

Zarf alanları; olayın kendi alanları props içinde.

event_id [kanıtlı]
İstemcinin ürettiği UUID; sunucuda tekil, yeniden gönderilen olay bir kez yazılır.

name, outcome [öneri]
Sözlükteki ad ve sonuç değeri.

occurred_at [kanıtlı]
Cihaz saati; 7 gün geriye, 10 dk ileriye kadar kabul. Raporlar bunu sayar.

received_at [kanıtlı]
Sunucu saati; saklama ve silme bunu kullanır.

install_id [kanıtlı]
İlk açılışta üretilen rastgele kimlik, güvenli depoda. Sunucuda yalnız HMAC'i durur. iOS'ta güvenli depo (Keychain) uygulama silinip yeniden kurulunca çoğu zaman kalır, Android'de silinir; Expo buna güvenilmemesini söyler. [öneri] Yeni kurulum kararı ve `app_open`'daki `first=true` bu kimliğe bakılarak verilmez; uygulamanın kendi deposundaki bayraktan okunur.

session_id [öneri]
Her açılışta yeni rastgele kimlik; huni sırası için.

platform, app_version, build [kanıtlı] build [öneri]
Her olayda. Bizde platform ve sürüm her olayda var; build olayda yok, yalnız iOS isteklerinin kullanıcı ajanında.

env [öneri]
prod ya da test; canlı API prod olmayan olayı reddeder.

tier [kanıtlı]
premium, free ya da guest; sunucu oturumdan belirler.

segment [kanıtlı]
Kaba kullanıcı tipi (uzman ya da son kullanıcı); kimlik taşımaz.

consent [öneri]
Üçüncü taraf ölçüm ve reklam kişiselleştirme kararı: kabul, ret, sorulmadı.

props [kanıtlı]
Olay başına izin listesindeki birkaç alan; yayınlanacak tutarlar bantlanır.

### Tablo

Postgres; ham olay 180 gün, günlük özet daha uzun.

```
CREATE TABLE events (
  id           bigserial PRIMARY KEY,
  event_id     uuid NOT NULL UNIQUE,
  name         text NOT NULL,
  outcome      text,
  occurred_at  timestamptz NOT NULL,
  received_at  timestamptz NOT NULL
               DEFAULT now(),
  install_hash text NOT NULL,
  session_id   uuid,
  platform     text NOT NULL CHECK
    (platform IN ('ios','android','web')),
  app_version  text NOT NULL,
  app_build    integer,
  tier         text CHECK
    (tier IN ('premium','free','guest')),
  segment      text,
  props        jsonb NOT NULL DEFAULT '{}'
);
```

```
CREATE INDEX ON events (name, occurred_at);
CREATE INDEX ON events
  (install_hash, occurred_at);
CREATE INDEX ON events (received_at);

-- Uzun süreli özet, kurulum kimliği taşımaz:
CREATE TABLE events_daily (
  day         date,
  name        text,
  outcome     text NOT NULL DEFAULT '',
  platform    text,
  app_version text,
  events      integer,
  installs    integer,
  PRIMARY KEY (day, name, outcome,
               platform, app_version)
);
```

[öneri]
** Ad ve outcome CHECK yerine uygulamadaki sözlükle doğrulanır**. Yeni değer migration beklemez; sözlüğe ve teste girmeden de kabul edilmez.
[kanıtlı]
** Olay tablosunda hesap bağı yoktur**; başka bir tabloda varsa hesap silinince NULL olur (ON DELETE SET NULL), olay sayı olarak kalır.
[öneri]
** Özette boş sonuç `''` olarak durur**. Birincil anahtardaki sütun NULL alamaz; özet işi `coalesce(outcome, '')` ile yazar. ON CONFLICT (day, name, outcome, platform, app_version) DO UPDATE aynı günü yeniden hesaplar, iş iki kez çalışsa da sayı ikilenmez.

### On zorunlu olay

İlk build'de gider. Güncelleme ve bildirim olayları [mobil kit](#mobilkit) ile aynı sözlükte.

| Olay | Ne zaman | Neden | Kanıt |
|---|---|---|---|
| 1 app_open | Her açılışta; ilk açılışta `first=true`. | Huninin başı. Bizde yoktu; bir reklam kampanyasının etkisi okunamadı. | [öneri] |
| 2 signup_complete, login_complete | Sunucu yazar; yöntem alanıyla. | Kayıt hunisi, istemciye güvenmeden. | [kanıtlı] Ürün B'de |
| 3 calc_done, search_done | Ürünün ana işi bitince; tür alanıyla. | Kurulumun ilk anahtar eylemi aktivasyondur ve SQL ile bulunur. | [kanıtlı] |
| 4 paywall_view | Premium ekranı açılınca; geldiği ekranla. | Satın alma oranının paydası. Bizde önerildi, yapılmadı. | [öneri] |
| 5 purchase_result | outcome: purchased, cancelled, failed, restored. | Mağaza webhook'u iptali söyler, ekranda vazgeçeni söylemez. | [öneri] |
| 6 ad_result | outcome: shown, no_fill, failed, dismissed, earned, timeout. | 115 istek ve 0 gösterimin sebebi bu olay olmadan ayrılamadı. | [öneri] PDF yolunda 7 Eki'den beri canlıda, verisi henüz okunmadı |
| 7 share_tap, export_tap | Paylaş ve dışa aktarma düğmeleri. | Ürünün dışarı taşındığı an. | [kanıtlı] |
| 8 error_shown | Hata gösterilince; kod, ekran, HTTP durumu, metin yok. | Çökme aracı yokken mobil hatayı görmenin yolu. | [öneri] |
| 9 update_prompt, notification_open | Uyarı gösterildi, kabul, erteleme; bildirime dokunuldu. | [Mobil kitin](#mobilkit) politika ve duyurularıyla aynı sözlükte. | [öneri] |
| 10 consent_change | Onay bandı ya da ATT cevabı. | Kitlenin ne kadarının ölçüldüğü; yalnız sayı. | [öneri] |

### Olay ucu

[öneri]
** Tek uç**: `POST /v1/events`, en çok 50 olaylık toplu gövde. Bilinmeyen alan, ad ya da değer 400 döner ve sayılır; sessizce 'diğer'e düşmez.
[öneri]
** Olay ucu veritabanını kendisi uyandırmaz**. Her olay için tek log satırı yazar. Havuzda açık bağlantı varsa, yani veritabanı zaten uyanıksa, aynı istekte tabloya da yazar. Uyurken ne token ne de günlük sınır veritabanında aranır; bu durumda tier istemcinin bildirdiğidir, kurulum başına 500 sınırı sabah job'ında uygulanır. Kalan olayları sürüm telemetrisini okuyan sabah job'ı Logging API'den alır ve event_id ile tekil yazar. Olay bellekte biriktirilmez; bellekte biriken sayaç bizde kapanışta sayı kaybetti. Admin'deki bugünkü sayı ve 24 saat alarmı log metriğinden okunur; tablo ertesi sabah tamamlanır. Bizde uç bugün her olayı tabloya yazıyor ve sınır için tabloyu sayıyor.
[kanıtlı]
** İstemci olayı kuyrukta tutar** (bizde 100) ve aynı event_id ile yeniden dener; arayüz hiç beklemez. Sınırlar: olay başına 4 KiB, kurulum başına günde 500 olay, adres başına saatte 300 istek.
[kanıtlı]
** Geçersiz token olayı guest yapar ve 204 döner**; analitik çağrısı kimseyi oturumdan düşürmez.
[kanıtlı]
** Uç, API'nin bağlantı moduyla gerçek Postgres'e karşı test edilir**. İki sessiz kaybımızda da aynı hata vardı. Basit sorgu modunda bayt dizisi bytea olarak gidiyor, jsonb kolonu bunu reddediyordu; testler bu modla koşmadığı için görülmedi.
[öneri]
** Son olay 24 saattir gelmediyse alarm çalar.** 5xx alarmı [Gözlem ve alarmlar](#katman-10) katmanında.
[kanıtlı]
** Ham olay 180 gün**; silme veritabanı zaten uyanıkken çalışır.
[öneri]
** Özet tablo daha uzun kalır** (ör. 2 yıl); işin son çalışması kaydedilir.
[kanıtlı]
** Herkese açık özet k-anonim eşikten geçer**. Her grup en az 10 farklı kurulumdan gelir.

### Gizlilik

İşleyen listesi, m.9 bildirimi ve cezası [KVKK ve veri yeri](#kvkk) bölümünde.

[kanıtlı]
** Veri yeri doğru yazılır**: veritabanımız AB'de (Frankfurt). Ne gidip ne gitmediği gizlilik metninde ve uygulamanın ayarlar ekranında anlatılır.
[kanıtlı]
** Üçüncü taraf ölçüm onaydan önce hiç istek atmaz**; kabul ve ret eşit görünür, kişisel alanlar maskelenir; oturumlu, yönetim ve form sayfalarında ve test ortamında yüklenmez.
[kanıtlı]
** Alanlara başka kişilerin adı, telefonu ya da kimlik numarası yazılabiliyorsa otomatik yakalama ve oturum kaydı kapalıdır**. Bir ürün analitiği aracını bu yüzden beklettik.
[kanıtlı]
** App Store gizlilik etiketi ve Play Data safety, SDK'ların topladığı dahil, olaylarla aynı gün güncellenir**.
[öneri]
** ATT yalnız izleme varsa sorulur**; birinci taraf takma kimlikli analitik için gerekmez.
[kanıtlı]
** Gizlilik metnindeki her saklama süresi çalışan bir işe bağlıdır**. Bir üründe metin süre yazıyordu, süpürme işi hiç çalışmamıştı.
[öneri]
** Kişinin kendi verisi için başvurusu** (KVKK m.11) en geç 30 günde cevaplanır (m.13); admin'deki döküm ucu bunu dakikalara indirir.

### Araç seçimi

[öneri] İlk gün: kendi olay tablomuz, gelir aracı, mağaza konsolları, Search Console ve Bing ([SEO](#seo)); bunlar başlangıçta ücretsiz (gelir aracı aylık $2.500 izlenen gelirin üstünde %1). Üçüncü taraf ölçüm önce web'de, onay kapısının arkasında. Ekim 2026 fiyatları.

| Araç ve veri yeri | Aylık maliyet | Ne zaman | Risk |
|---|---|---|---|
| Kendi tablomuz, SQL ve admin ekranları Veri: Kendi veritabanımız (AB). [kanıtlı] | Ek maliyet 0; depolama Neon Launch'ta $0,35/GB-ay. Huni ve sürüm ekranı 1–2 gün. | Varsayılan; her ürün için ilk gün. | Hazır huni ve oturum kaydı yok; ekranları biz yazarız. |
| PostHog Cloud EU Veri: Frankfurt (AB bölgesi seçilirse). [öneri] | Ayda 1 milyon olay ve 5.000 oturum kaydı ücretsiz; sonra olay başına $0,00005. Bizim hacimde tahmini $0. | Hazır huni ve kohort isteyen, alanlara kişisel veri yazılmayan ürün. | Otomatik yakalama formdaki kişisel veriyi taşır; KVKK m.9 adımı. |
| GA4, Firebase Analytics Veri: Google. [öneri] | Ücretsiz. 500 olay adı, olay başına 25 parametre; olay düzeyi veri 2 ya da 14 ay. | Reklam ağıyla ölçüm gereken ürün. | SDK, reklam kimliği ve mağaza beyanları; KVKK m.9. |
| Microsoft Clarity Veri: Microsoft (AB için İrlanda şirketi). [kanıtlı] iki ürünün web'inde, onaylı | Ücretsiz, trafik sınırı yok; kayıtlar 30 gün. | Yalnız web: ekranda ne yapıldığı. | Onay şart, formlarda maskeleme; mobil SDK mağaza sürümü ister. |
| RevenueCat Veri: RevenueCat. [kanıtlı] | Aylık izlenen gelir $2.500'e kadar ücretsiz, sonra %1. | Abonelik, deneme hunisi, sürüm başına aktif müşteri, Apple Ads atfı. | Teslimler izlenmezse webhook sessizce düşer; eski ve yeni uç farklı rakam verir. |

### Nasıl okunur

[kanıtlı]
** Günlük rapor e-postası**: günün ve toplamın rakamları, gelir aracının rakamları, deneme hunisi. Bizde hafta içi 18:00 ve her gün 23:59; panel açmaya gerek kalmıyor.
[öneri]
** Haftada 30 dakika, her hafta aynı sırayla.**
1. Huni: kurulum, ilk anahtar eylem, paywall görüntüleme, satın alma; platform ve sürüm kırılımıyla.
2. Son 7 günün sürüm dağılımı.
3. Gelir aracının paneliyle karşılaştırma.
4. 400 alan olay sayısı.
5. Hiç gelmeyen olay adları.
[kanıtlı]
** Aynı metrik iki kaynaktan geliyorsa ikisi yan yana gösterilir, fark gizlenmez**; yaklaşık rakam etiketlenir.

## Sürüm payı nereden okunur

28 Eyl 2026, aynı soru: iOS'ta kaç telefon hâlâ eski sürümde. Uzun pencerede güncelleyen kurulum iki sürümde birden sayıldı; 55 kimlik hem eski hem yeni sürümde görünüyordu.

Yanlış pencereDoğru kaynak: gelir aracı, app_version süzgecieski sürümdeki pay
_Grafik: Eski sürümdeki pay, 28 Eyl 2026: iOS, 28 gün, telefon başına %66 (139/211); iOS, 7 gün, aktif müşteri %7 (22/308); Android, 7 gün, aktif müşteri %3 (3/88)_
[ölçüldü] Sürüm dağılımı 7 günlük pencereyle, platform ve build başına tekil kurulum olarak sayılır; zorunlu güncellemeden önce ikinci bir kaynakla karşılaştırılır. Telemetri [mobil kitin](#mobilkit) onuncu parçası.

Gün 0

## Admin

Admin ilk sürümle gelir ve okumayla başlar. Ürün A'nın ilk admin sürümü (28 Ağu 2026) tamamen salt okunurdu. Yeni projede yazma uçları sonra gelir ve her biri denetim satırı yazar.

[öneri]
** Ürünü build ve deploy olmadan yöneten her ayar** (bayrak, kill switch, güncelleme politikası, duyuru) veritabanında durur ve admin'den değişir; ortam değişkeni yalnız acil yedektir.

### Yirmi iki uç

Yol kalıpları ilk gün yazılır, ekranlar sonra gelebilir. Risk: giriş, okuma, yazma; tehlikeli olanlar yeniden doğrulama ve sebep ister.

| Yöntem ve yol | Ne yapar | Risk | Kanıt |
|---|---|---|---|
| Giriş ve oturum |
| POST /v1/admin/auth/code | Kod iste; herkese aynı cevap, listede olmayana kod gitmez. | giriş | [kanıtlı] |
| POST /v1/admin/auth/verify | Admin oturumu; ayrı tablo, ayrı önekli token. | giriş | [kanıtlı] |
| POST /v1/admin/auth/logout | Oturumu sunucuda iptal et. | giriş | [kanıtlı] |
| GET /v1/admin/me | Kim, hangi rol, oturum ne zaman bitiyor. | okuma | [kanıtlı] |
| Okuma ve ölçüm |
| GET /v1/admin/overview | Temel sayılar; kartta kaynak, pencere, son güncelleme (öneri). | okuma | [kanıtlı] |
| GET /v1/admin/metrics/funnel?days= | Kurulum, ilk eylem, paywall, satın alma; sürümle. | okuma | [öneri] |
| GET /v1/admin/metrics/versions | Son 7 günde platform ve build başına tekil kurulum. | okuma | [öneri] |
| GET /v1/admin/metrics/events | Olay sayıları, 400 alanlar, hiç gelmeyen adlar. | okuma | [öneri] |
| Ürünü build'siz yönetmek |
| GET, PUT /v1/admin/flags | Bayraklar ve kill switch; sebebiyle denetim kaydına. | tehlikeli | [öneri] |
| GET, PUT /v1/admin/update-policy | En düşük ve en son build; önce kilitlenecek kurulum sayısı. | tehlikeli | [öneri] |
| GET, POST, PATCH /v1/admin/notices | Uygulama ve sitede duyuru, ekran içi uyarı. | yazma | [öneri] |
| POST /v1/admin/broadcasts | Push, arka planda; önce dry_run=1 ile alıcı sayısı (öneri). | tehlikeli | [kanıtlı] |
| Kullanıcı ve içerik |
| GET /v1/admin/users, /users/{id} | Maskeli arama ve ayrıntı; sunucuda sayfalama. | okuma | [kanıtlı] |
| POST /v1/admin/users/{id}/status | Askıya alma; canlı oturumlar düşer. | yazma | [kanıtlı] |
| GET /v1/admin/users/{id}/export | KVKK veri dökümü (JSON). | tehlikeli | [öneri] |
| DELETE /v1/admin/users/{id} | Kullanıcının kendi silme akışıyla aynı servis. | tehlikeli | [kanıtlı] |
| GET, POST /v1/admin/moderation/{id} | Şikayet kuyruğu; karar ve sebep. Kullanıcı içeriği varsa ilk gün. | yazma | [kanıtlı] |
| İşler ve kayıtlar |
| GET, POST /v1/admin/jobs/{name}/run | İşin son çalışması, süresi, sonucu; elle çalıştırma. | yazma | [öneri] |
| GET /v1/admin/webhooks | Sağlayıcı başına son başarılı teslim ve son hata. | okuma | [öneri] |
| GET /v1/admin/audit | Denetim kaydı; kişi, eylem, hedef, tarih süzgeci. | okuma | [kanıtlı] |
| GET /v1/admin/export/{table} | CSV ya da Excel; toplam satır yazılır, kırpılırsa hata (öneri). | okuma | [kanıtlı] |
| POST /v1/internal/jobs/{name} | Zamanlayıcının işleri admin'den geçmez; Cloud Scheduler OAuth token'ıyla Cloud Run Jobs'u çalıştırır. İş API'de uç olarak kalacaksa OIDC token'ıyla. | iç iş | [öneri] |

### Kim girer, ne kadar kalır

Genel kurallar [Güvenlik ve botlar](#katman-8) katmanında.

[kanıtlı]
** Admin'i e-posta izin listesi belirler**; liste boşsa panel kapanır.
[öneri]
** Yanında üç rol olur** (sahip, operatör, salt okuyucu); rol her yazmada veritabanından okunur.
[kanıtlı]
** Giriş e-posta koduyla, kendi ucundan**. Kod 10–30 dk yaşar, 5 deneme hakkı var, adres ve IP başına saatlik sınır konur, cevap herkese aynıdır. Bir ürünün formu üye ucunu çağırıp her adrese kod yolluyordu; ayrı uca alındı.
[kanıtlı]
** Admin oturumu ayrı tabloda, ayrı önekli token'la**; veritabanında yalnız özeti durur. Üye token'ı ve mobil uygulamadaki hiçbir anahtar admin'i açamaz.
[kanıtlı]
** Boşta 30 dk kayan süre, 12 saat tavan**; 8 saatlik boşta süre denendi, güvenlik için geri alındı. Token sunucuda iptal edilir; bir üründe süresizdi, 7 güne indi.
[öneri]
** Bitmeden 2 dk önce uyarı ve tek tıkla uzatma**; okuma sırasında da oturum düşmez.
[öneri]
** Tehlikeli eylemde son 5 dk içinde yeni kod ve sebep istenir**: herkese duyuru, silme ve veri dökümü, kill switch, zorunlu güncelleme, rol değişikliği.
[kanıtlı]
** Token yalnız httpOnly çerezde durur**. Yetkisiz isteğe 404; admin uçlarına ayrı hız sınırı (bir üründe dakikada 120).
[kanıtlı]
** Panel noindex ve CSP'li, kullanıcı metnini kaçışlı gösterir**; yardımcı uçlar da admin ister. Bir üründe ham HTML gösterimiyle başlayan zincir bulunduğu gün kapatıldı.
[öneri]
** Açılışta zorunlu ayarlar doğrulanır**; yönetici listesi boşsa loga uyarı yazılır. IP izin listesi ya da IAP isteğe bağlı ikinci kapıdır.

### Denetim kaydı

before ve after maskelidir; reason tehlikeli eylemde zorunludur.

```
CREATE TABLE admin_audit (
  id          bigserial PRIMARY KEY,
  at          timestamptz NOT NULL DEFAULT now(),
  actor_id    uuid REFERENCES users(id) ON DELETE SET NULL,
  actor_email text NOT NULL,
  action      text NOT NULL,   -- 'flag.update', 'broadcast.send', 'user.delete'
  target_type text NOT NULL,
  target_id   text,
  before      jsonb,           -- maskeli
  after       jsonb,           -- maskeli
  result      jsonb,           -- {"sent": 412, "failed": 3}
  reason      text,            -- tehlikeli eylemde zorunlu
  request_id  text,
  ip_hash     text
);
CREATE INDEX ON admin_audit (at DESC);
CREATE INDEX ON admin_audit (target_type, target_id, at DESC);
```

[kanıtlı]
** Satır değişiklikle aynı işlemde** (transaction) yazılır; değişiklik geri alınırsa satır da geri alınır.
[öneri]
** Uygulamanın veritabanı rolü bu tabloya yalnız INSERT ve SELECT yapabilir**; UPDATE ve DELETE yok.
[öneri]
** Her yazan admin ucunun 'tam bir denetim satırı yazdı' testi vardır**; eylem ve hedef türü kısıtlı bir listeyse yeni tür migration'la eklenir.
[öneri]
** Admin'den başlayan her toplu işlem sonucunu sayıyla yazar**: kaç cihaza gitti, kaç satır yazıldı, kaç hata.
[öneri]
** Saklama süresi yazılır** (ör. 2 yıl) ve bir işe bağlanır. Ortam değişkeniyle yapılan acil değişiklik de sonradan bu tabloya sebebiyle elle yazılır.

### Admin'de asla

**Admin yolunu kimlik ara katmanının dışında kaydetmek.** Router'daki her /v1/admin yolu token'sız çağrılınca reddedilir; bunu bütün yolları gezen bir test denetler. [öneri]

** Paylaşılan admin hesabı.** Herkes kendi e-postasıyla girer; denetim kaydı kişiyi gösterir. [öneri]

** Canlıya test verisi yazmak.** Canlıda deneme duyurusunu herkese göndermek ve canlı sayaçları doğrulama için çağırmak da buna girer; bir doğrulama 92 istekten sonra 429 aldı. [kanıtlı]

** Canlı veritabanında elle SQL ile moderasyon ya da düzeltme.** Gerekiyorsa denetim kaydı yazan bir admin ucu ya da kayıtlı bir betik. [öneri]

** Mobil uygulamadaki bir anahtarla ya da üye token'ıyla admin'i açmak.** Süresiz admin token'ı da buna girer. [kanıtlı]

** Listelerde maskesiz kişisel veri.** Ad baş harfle, telefonun ortası yıldızlı; tam veri yalnız ayrıntıda ve denetim kaydıyla. [kanıtlı]

** Sessiz başarı.** Tanınmayan süzgeç değeri, kırpılmış dışa aktarım, boş alıcı listesi 'başarılı' dönmez. Ürün B'de 126 satırın 50'si indi, dosya eksiksiz göründü. [öneri]

** Admin'i arama motorlarına açık bırakmak.** noindex ve robots ilk gün. [kanıtlı]

## Bizdekinden iyisi

Öncelik sırasıyla. Alınan kararlar [DECISIONS dosyasına](#hafiza) yazılır.

| Ne | Etkisi | Emek ve maliyet |
|---|---|---|
| 1. **Sessiz kayba alarm** Webhook'un son teslim yaşı, son olay yaşı, işin son başarısı; 5xx alarmının yanına. | 21 günlük webhook kaybı ve bir haftalık olay kaybı bir güne iner. | 2–3 saat bugün $0; ücret en erken 1 Eyl 2027'de, metrik referansı başına ayda $0,35 [öneri] |
| 2. **Kurulum, paywall ve huni ilk gün** app_open (first), paywall_view, purchase_result; admin'de huni ekranı. | 'Kaç kişi indirip kaçı ödedi' ilk haftadan cevaplanır; kampanya etkisi kendi verimizden okunur. | ~1 gün (bizde 1 Eki'de önerildi, yapılmadı) $0 [öneri] |
| 3. **Para kazandıran her yolun sonucu** Paywall, satın alma, reklam teklifi ve gösterimi outcome ile. | Reklamın neden gösterilmediği mağaza sürümü beklemeden ayrılır. | Yarım gün $0 [öneri] |
| 4. **Olay sözlüğü ve sözleşme testi** Tek dosya; her ekranın karşılığı test edilir, bilinmeyen değer 400. | Adsız ürün ve düzeltilemeyen 'özel' verisi olmaz. | Yarım gün $0 [öneri] |
| 5. **Bayrak ve politika veritabanında** Admin'den değişir, önbellekten okunur, sebebiyle denetim kaydına. | Üç haftada en az 14 elle revizyon yerine iki tık; 'kim kapattı' sorusu kalmaz. | 1–2 gün $0 [öneri] |
| 6. **Denetim kaydı ilk günden** Yukarıdaki şema, değişiklikle aynı işlemde. | Yanlış değişiklik geri alınır; Ürün B'de iki ayar böyle geri geldi. | Yarım gün $0 [öneri] Ürün B'de [kanıtlı] |
| 7. **İşler ve webhook'lar ekranı** Her iş son çalışmasını, süresini ve sonucunu tabloya yazar. | API'yi 'rapor gelmedi' sanıp hep açık bırakmak (~₺255/ay) olmaz; düşen paylaşım aynı gün görülür. | Yarım-1 gün $0 [öneri] |
| 8. **Her istekte sürüm ve build başlığı** Android dahil; olaylar ve loglar taşır ([Mobil uzaktan kontrol kiti](#mobilkit), parça 1). | Sahadaki build'ler loglardan da okunur; bizde Android istekleri build taşımıyor. | Yarım gün $0 [öneri] |

[öneri] **Sonra, araç maliyeti $0 olanlar:** Araç ve veri yeri kararı ilk gün (2 saat; hukukçu sorusu ayrıca); Birinci taraf hata olayı (yarım gün); Roller ve yeniden doğrulama (1 gün); KVKK dökümü ve silme admin'den (1 gün); Paylaşılan bağlantıda kaynak etiketi (1 saat).

## Gün 0 kontrol listesi

İlk mağaza sürümünden ve ilk gerçek kullanıcıdan önce. Öneri etiketli kutular da işaretlenir.

- [ ] Ürün sahibinin beş sorusu yazıldı; olay sözlüğü bu sorulardan çıkarıldı.

[öneri]
- [ ] Tek olay ucu; ilk build'de on zorunlu olay, her olayda platform, sürüm ve build gidiyor.

[öneri]
- [ ] Olay uçları API'nin bağlantı moduyla gerçek Postgres'e karşı test edildi; testlerde ağ kapalı.

[kanıtlı]
- [ ] Alarmlar kuruldu ve bir kez çaldırıldı: 5xx oranı, webhook son teslim yaşı, son olay yaşı, işin son başarısı.

[öneri]
- [ ] Gelir aracının webhook'u belgelenen başarı kodunu dönüyor; sağlayıcının panelinde bir teslim başarılı göründü.

[öneri]
- [ ] Günlük rapor e-postası gidiyor; 'bugün' ürünün saat diliminde, her rakamın kaynağı ve penceresi yanında.

[kanıtlı]
- [ ] Admin: ayrı giriş ucu, izin listesi, ayrı oturum tablosu, 30 dk kayan süre ve 12 saat tavan, noindex; denetim satırı değişiklikle aynı işlemde yazılıyor.

[kanıtlı]
- [ ] Bayrak, kill switch, güncelleme politikası ve duyuru veritabanında, admin'den değişiyor; işler ve webhook'lar ekranı, kullanıcı arama, askıya alma, silme ve veri dökümü uçları var.

[öneri]
- [ ] Roller tanımlı, tehlikeli eylemde yeniden doğrulama var; admin yollarını token'sız çağıran ve her yazan ucun denetim satırına bakan testler yeşil. Canlı API test ortamının olayını reddediyor.

[öneri]
- [ ] Gizlilik metni, ayarlar kartı ve iki mağaza beyanı olaylarla aynı gün yazıldı; her saklama süresi bir işe bağlı.

[kanıtlı]

## Tuzaklar

[ölçüldü] Kartlara ek; hepsi bizde ölçüldü.

'Bugün' kayan 24 saatle sayılınca genel bakış 'bugün katılan 1' dedi, gerçekte 0'dı; öteki ekran İstanbul gününü sayıyordu.

Referer ve ön yükleme web sayılarını şişirir. 'Arama motorundan gelen' yaklaşık 120 girişin 105'i bir kazıyıcıydı; '12–24 sayfa' gezinti ön yüklemeydi.

İş süresi sunucunun yazma süresini geçince başarılı iş başarısız görünür. Rapor 11,9 sn sürdü, sınır 10 sn'ydi; başka bir üründe 58 sn.

Bellekte biriken sayaç, iki örnek çakışınca ve kapanışta veritabanının uyanmasını beklerken sayı kaybeder.

### Ölçülmeyenler

Bu araştırmada okunmayan ya da henüz verisi olmayanlar.

Olay tablolarının canlıdaki boyutu ve aylık depolama maliyeti; bu araştırmada canlı veritabanına bağlanılmadı.

Huni dönüşüm oranları: kurulum ve paywall görüntüleme olayı hiçbir üründe yok.

Ürün A'da PDF sonuç olaylarının dağılımı; olay 7 Eki'de yayına çıktı, veri henüz okunmadı.

PostHog'un bizim hacimdeki gerçek maliyeti; tahmini $0, ölçülmedi.

Admin uçlarının gecikmesi; yalnız Ürün A'nın admin girişi ölçüldü (p50 804 ms).

Mağaza tarafındaki hata ve çökme sayıları; App Store Connect ve Play Console çökme raporları okunmadı.

## Kaynaklar

8 Ekim 2026'da okundu. Bizim rakamlarımız depolardan, değişiklik kayıtlarından ve faturalardan.

**PostHog fiyatları**https://posthog.com/pricing
**PostHog ürün analitiği fiyatı**https://posthog.com/docs/product-analytics/pricing
**PostHog veri yeri (AB bulutu Frankfurt)**https://posthog.com/docs/privacy/data-storage
**GA4 veri saklama**https://support.google.com/analytics/answer/7667196
**GA4 ve Firebase toplama sınırları**https://support.google.com/firebase/answer/9237506
**Google Analytics for Firebase**https://firebase.google.com/docs/analytics
**Microsoft Clarity SSS**https://learn.microsoft.com/en-us/clarity/faq
**RevenueCat fiyatları**https://www.revenuecat.com/pricing/
**RevenueCat webhook'ları**https://www.revenuecat.com/docs/integrations/webhooks
**Apple App Tracking Transparency**https://developer.apple.com/documentation/apptrackingtransparency
**Apple kullanıcı gizliliği ve veri kullanımı**https://developer.apple.com/app-store/user-privacy-and-data-use/
**Apple App Privacy details**https://developer.apple.com/app-store/app-privacy-details/
**Google Play Data safety**https://support.google.com/googleplay/android-developer/answer/10787469
**KVKK standart sözleşme bildirim duyurusu**https://www.kvkk.gov.tr/Icerik/8043/Standart-Sozlesme-Bildirim-Modulu-Hakkinda-Kamuoyu-Duyurusu
**6698 sayılı KVKK metni (m.11, m.13)**https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6698.pdf
**Google Cloud Observability fiyatları**https://cloud.google.com/stackdriver/pricing
**Neon fiyatları**https://neon.com/pricing
**Expo SecureStore**https://docs.expo.dev/versions/latest/sdk/securestore/

<a id="katmanlar-4"></a>

Katman 11 / 11

# Yedekler

Yedek dört katmandır: Neon geçmişi, Neon snapshot'ı, Neon dışında günlük döküm ve haftalık proje dışı kopya. Her döküm geri yüklenerek doğrulanır.

2 proje
2 Ekim'de silinen iki GCP projesiyle içindeki her şey gitti. Proje dışı kopya bu yüzden ayrı bir katman.

Ayrıntı
Bu katmanın bütün kuralları hemen aşağıdaki bölümde: [Veritabanı yedeği ve geri yükleme](#yedek). Orada katmanlar tablosu, Free ve ücretli prod için tarif, ölçülmüş sürelerle geri yükleme sırası, tatbikat takvimi, silme ve KVKK, taşıma doğrulaması ve kontrol listesi var.

<a id="yedek"></a>

Yedek

# Veritabanı yedeği ve geri yükleme

Yedek üç soruya cevap verir: yanlış bir yazmayı dakikalar içinde geri alabiliyor muyuz, sağlayıcı ya da hesap giderse veri ayakta kalıyor mu, elimizdeki kopyanın gerçekten geri yüklendiğini biliyor muyuz.

Üçü ayrı katmanlarla karşılanır: hızlı geri dönüş için Neon'un kendi geçmişi ve snapshot'ları, sağlayıcı kaybı için Neon dışında her gün alınan ve alındığı anda geri yüklenerek denetlenen döküm. 70 MB'lık prod veritabanımızda geçmiş ve snapshot 1–7 Ekim 2026 ölçümüyle ayda ~5 sent; döküm kovası ve job'ı bir sentin altında. Yedek ucuz; pahalı olan, hiç denenmemiş bir yedekle olay günü karşılaşmak.

**~$0,05/ay** 70 MB'lık prod veritabanında 7 gün geçmiş (~$0,03), 14 gün snapshot (~$0,02), döküm kovası ve job (~$0).
**15 / 15** 24 Eylül–8 Ekim'de ilk denemede başarılı zamanlanmış çalışma. Döküm, geri yükleme kontrolü ve yükleme 5–8 sn.
**1 günden 7 güne** Launch'ta geçmiş penceresinin varsayılanı 1 gün; 7'ye ayardan elle çıkarılır, plan değişince kendiliğinden büyümez.
**4 dk** Alarm denemesinde hatadan alarma: 16:57'de hata, 17:01'de alarm, 17:11'de kendiliğinden kapanış.
**2,76 MB** 70 MB'lık veritabanının dökümü. 23 Eylül'de 702 KB'tı; tablo sayısı 47'den 55'e çıktı.
**~37 gün** Bir dökümün en uzun ömrü: 30. günde lifecycle siler, soft delete 7 gün daha geri getirilebilir tutar.

## İlkeler

1. Geri yüklenemeyen döküm yedek sayılmaz. Her döküm alındığı anda geçici bir Postgres'e yüklenir; kovaya ulaşan kopya da ayrıca boyutuyla denetlenir.

Döküm sağlam olsa bile yükleme onu bozabilir. Bir projemizde ilk çalışma kovaya 7 baytlık nesne yazdı; geri yükleme kontrolü geçmişti, yakalayan yükleme sonrası boyut karşılaştırması oldu.

2. Katmanlar birbirinden bağımsız arızalara karşı kurulur: sağlayıcı geçmişi, sağlayıcı snapshot'ı, sağlayıcı dışı döküm, proje dışı kopya.

Neon geçmişi ve snapshot'ları Neon projesiyle birlikte yaşar; proje silinirse 7 gün içinde kurtarılmazsa hepsi gider. Aynı GCP projesindeki döküm de o proje silinirse gider. [öneri] Prod projesine silme kilidi (lien) konur. Bedeli yoktur; projeyi silmek için önce kilidin kaldırılması gerekir: `gcloud alpha resource-manager liens create --project=PROJE --restrictions=resourcemanager.projects.delete --reason="prod"`. Kilit kazaya karşıdır; sahip hesap ele geçirilirse kaldırılabilir. Silinen proje 30 gün bekler ve `gcloud projects undelete PROJE` ile geri alınır. Ama faturalama bağlantısı elle yeniden kurulur, servislerin toparlanması 36 saati bulabilir. Kovadaki nesneler soft delete süresi (bizde 7 gün) dolunca geri gelmeyebilir; soft delete kapalıysa hemen gider. Bu yüzden geri alma proje dışı kopyanın yerini tutmaz. İki adım da restore-db.md'ye yazılır.

3. Önce en hızlı yol denenir: pencere içindeyse Neon geçmişi, değilse snapshot, en son döküm.

Geçmişten dönüş Neon'a göre birkaç saniye sürer ve son dakikaları korur. Döküm 24 saate kadar veri kaybettirir ve bağlantı adresini değiştirmeyi gerektirir.

4. Yedeği alan kimlik kovaya yalnız yazar; okuyamaz, silemez, üzerine yazamaz. Kovayı yalnız proje sahibi okur. Döküm, uygulamanın değil salt okunur ayrı bir rolün bağlantısıyla alınır.

Kimlik ele geçirilse bile eski kopyalar silinemez ve bozulamaz. Ama kimlik veritabanı bağlantı sırrını okuyabildiği için o sır uygulamanınkiyse canlı veriye yazabilir; kova kuralı tek başına yetmez.

5. Sessiz başarısızlık yok: başarılı her çalışma tek satır log yazar, başarısız çalışma alarm atar, alarm uçtan uca denenmiştir. Başarı satırının hiç gelmemesi de ayrı bir alarmdır.

Alarm kuralı yazmak yetmez; postanın gerçekten geldiğini bir kez görmek gerekir. Başarısızlığı sayan alarm, zamanlayıcı duraklatılınca ya da silinince hiç çalmaz.

6. Canlı veri test ortamına yüklenmez; deneme ve test canlıya yazmaz.

Test ortamında giriş kolaylaştırılmıştır. Oraya inen gerçek veri herkese açılmış olur.

7. Gizlilik metnindeki süre, yedekler dahil gerçek azami süredir.

Kodun sildiği kayıt dökümlerde, snapshot'larda ve kovanın soft delete süresinde haftalarca yaşar.

8. Geri yükleme bir tatbikattır, olay günü ilk kez yapılmaz. Süre ölçülür ve runbook'a yazılır.

Hiç denenmemiş yolun süresi ve tuzakları bilinmez.

## Katmanlar

Her katman başka bir arızaya karşıdır. Maliyetler 1–7 Ekim 2026 ölçümü, 70 MB'lık veritabanı.

| Katman | Neye karşı korur | Neye karşı korumaz | Maliyet |
|---|---|---|---|
| Neon geçmişiInstant restore. Launch 7 gün (varsayılan 1), Free 6 saat. Tüm zaman çizgisinin üzerine yazar; eski hal `_old_` dalında kalır, adres değişmez. | Yanlış migration, yanlış UPDATE ya da DELETE, uygulama hatasıyla bozulan satır, silinen tablo; son dakikalara kadar kayıpsız. | Pencereden eski hata, Neon projesinin silinmesi (7 gün kurtarılabilir), hesap ya da sağlayıcı kaybı. Snapshot'tan geri yüklenmiş dalda çalışmaz. | Launch'ta $0,20/GB-ay; Free'de ücretsiz. Bizde 7 gün ortalama 129 MB, ~$0,03/ay. |
| Neon snapshotZamanlanmış, günde bir; 14 gün saklama, azami 35. Zamanlama yalnız ücretli planda, Free'de tek elle snapshot. | Geçmiş penceresinden eski ama saklamadan yeni hata; büyük bir değişiklikten önce elle alınan güvenli nokta. | Proje silinmesi, hesap ve sağlayıcı kaybı; snapshot anı ile hata arasındaki yazmalar. | $0,09/GB-ay; ilki tam, sonrakiler fark. Bizde 14 gün 212–253 MB, ~$0,02/ay. |
| Neon dışı günlük dökümCloud Run job'u direct adresten pg_dump -Fc; imaj Postgres 18 ve curl, digest ile sabit; kova bölgesel ve herkese kapalı. | Neon projesinin ya da hesabının kaybı, sağlayıcı değiştirme, snapshot saklamasından eski (30 güne kadar) hata. | Gün içi kayıp (en kötü 24 saat); kova aynı GCP projesindeyse o projenin silinmesi ya da sahip hesabın ele geçirilmesi. Bozuk veriyi de sadakatle yedekler. | Kova ~30 MB, ayda bir sentin çok altında; job günde 17–62 sn, ücretsiz kotada. |
| DoğrulamaGeçici Postgres'e pg_restore --exit-on-error, tablo eşiği, yükleme sonrası boyut karşılaştırması, tek satır 'backup ok' logu ve iki alarm. | Yarım ya da bozuk yükleme, pg_dump sürüm uyumsuzluğu, açılmayan döküm, hata veren zamanlayıcı. | Satır düzeyinde eksik veri. Sabit tablo eşiği zamanla gevşer. Duraklatılan ya da silinen zamanlayıcı hiçbir alarmı çaldırmaz; başarı satırının yokluğuna ayrı alarm gerekir. | Çalışma başına birkaç saniye; ücretsiz. |
| Proje dışı kopya[öneri] Haftada bir, ayrı sahiplik ve faturalamalı başka bir projeye ya da sağlayıcıya; kopyalayan kimlik hedefte yalnız nesne oluşturur. | GCP projesinin yanlışlıkla silinmesi, sahip hesabın ele geçirilmesi, faturalama askısıyla kapanan proje. | Hedef aynı hesapla yönetiliyorsa hesap ele geçirilmesine karşı yalnız kısmen korur; hedefte de saklama kuralı gerekir. | Birkaç MB'lık nesneler için ayda birkaç sent. |
| Saklama kilidiRetention 7 gün (kilitsiz), lifecycle 30. günde siler, soft delete 7 gün. | Bir betiğin ya da elle silmenin son haftanın dökümlerini yok etmesi, üzerine yazma; kilitliyse projenin silinmesi de. | Kilitsiz politikada sahip hesabın ele geçirilmesi. Kilit geri alınamaz, süre kısaltılamaz; süre kesinleşmeden kilitlenmez. | Soft delete içindeki nesne de ücretlenir; MB'larda önemsiz. |

## Ne kadar geriye dönülebilir

Bugünkü ayarlarla katman başına en eski geri dönüş noktası; ölçek gerçek.

katmanın bugünkü süresiazami, soft delete ya da önerigün
_Grafik: Katmana göre geri dönülebilecek süre_

## Geri yükleme sırası

Önce en hızlı yol: pencere içindeyse geçmiş, değilse snapshot, en son döküm. Sağdaki süreler ölçüm ya da Neon belgesi; ölçülmeyen yazıyor.

1. **Dur ve kapsamı belirle.** Ne bozuldu, ilk yanlış yazma ne zaman oldu; zaman loglardan bulunur, tahmin edilmez. Bozulma sürüyorsa yazma durdurulur: bakım bayrağı ya da ilgili job duraklatılır.

5–15 dk
2. **Hedef anı doğrula.** Pencere içindeyse Time Travel Assist ile o an salt okunur sorgulanır ya da o andan bir dal açılır; kritik tablolarda satır sayısına bakılır. Dal açmak saniyeler sürer.

birkaç dk
3. **Tam mı seçici mi karar ver.** Birkaç tablo ya da satır bozulduysa geçmiş daldan yalnız onlar kopyalanır (`pg_dump -t` ya da `INSERT ... SELECT`). Tam dönüş, hata anından sonraki doğru yazmaları da siler.

4. **Pencere içinde tam dönüş: instant restore.** Bağlantı adresi değişmez, açık bağlantılar kısa kopar. Eski hal `_old_` dalında kalır; sonradan gelen doğru yazmalar oradan alınır.

saniyeler, Neon'a göre
5. **Pencere dışında, snapshot saklaması içinde.** Çok adımlı snapshot geri yüklemesi: yeni dal açılır, incelenir, sonra geçilir. Bu dalda instant restore çalışmaz; geçişten sonra ilk iş elle snapshot.

dakikalar, ölçülmedi
6. **Neon kaybı ya da daha eski hata: döküm.** Son geçerli döküm bulunur (log satırındaki tables ve users değerleri beklenene uymalı) ve bulut kabuğuna indirilir. Yeni proje ya da dal açılır; direct adrese `pg_restore --no-owner --no-privileges --exit-on-error -1` ile tek işlemde yüklenir.

63 sn, iki küçük veritabanı
7. **Uygulama rolünün yetkilerini yeniden ver.** `--no-owner` ve `--no-privileges` ile yüklenen tablolar yükleyen role aittir.

8. **Doğrula.** Eklentiler, şemalar, her tablonun satır sayısı, sequence değerleri ve her tablonun içeriğinin md5'i kaynakla birebir. Kaynak yoksa döküm anına en yakın Neon dalıyla ya da log satırındaki sayılarla.

~15 sn, 12 ve 53 tablo
9. **Silmeleri yeniden uygula.** Yedekten sonra silinen hesap ve kayıtlar, silmenin bıraktığı iz listesinden yeniden silinir. Neon kaybolduysa liste log kovasından okunur [öneri]. Bu adım atlanırsa silinmiş kişisel veri geri gelir.

10. **Geç.** Eski kaynak bir kez daha md5 ile karşılaştırılır; döküm sonrası yazma varsa önce o taşınır. Bağlantı sırrına yeni sürüm yazılır, servis yeni revizyona alınır.

~20 sn; tümü ~5 dk
11. **Sağlığı oku.** Sağlık ucu, 5xx ve 'veritabanına bağlanamadı' logları temiz mi; eski ve yeni kaynak bir kez daha karşılaştırılır.

12. **Kapat.** Yerel döküm kopyası, `_old_` ve geçici dallar doğrulamadan sonra silinir; olay notu ve ölçülen süreler runbook'a eklenir.

## İki tarif

### Free'deki küçük proje

Neon Free: 6 saat geçmiş, 1 elle snapshot, zamanlama yok, proje başına 1 GB, 100 CU-saat, 5 GB çıkış, 10 dal.

1
6 saatlik geçmiş açık ve büyütülemez; hatayı 6 saat içinde fark etmek için hata ve 5xx alarmı ilk gün kurulur.

2
Migration, toplu import ya da elle veri düzeltmeden hemen önce tek elle snapshot hakkı kullanılır; iş doğrulanınca eskisi silinir ki hak boşalsın.

3
Prod'daki döküm job'u aynen kopyalanır: aynı imaj ve betik, tablo eşiği projeye göre. Kova Neon dışında; retention 7, lifecycle 30 gün.

4
Job veritabanının zaten uyanık olduğu saate konur. Olmasa da birkaç saniyelik döküm 0,25 CU'da ayda ~0,6 CU-saat eder, kotanın %1'inden az (hesap, ölçülmedi).

5
Geri yükleme hedefi 1 GB ve 10 dal sınırına uyar; geri yüklemenin bıraktığı `_old_` dalları iş bitince silinir.

6
Free'de tüketim API'si yok: CU-saat 'db wake' log metriğiyle izlenir, Usage sayfası haftada bir, depolama ve dal sayısı ayda bir okunur. Kota aşılırsa compute dönem sonuna kadar durur.

7
Ücretli plandan Free'ye taşındıysa eski proje bir hafta yedek olarak durur, sonra silinir.

### Ücretli prod (Neon Launch)

Ölçülen maliyet 70 MB'lık veritabanında ayda ~$0,05: geçmiş ~$0,03, snapshot ~$0,02, kova ve job ~$0.

1
Geçmiş penceresi Settings > Postgres'ten 7 güne çıkarılır ve gözle kontrol edilir. Launch varsayılanı 1 gündür; pencere proje ayarında durur ve plan değişince kendiliğinden büyümez.

2
Günlük snapshot zamanlanır; 14 gün saklama yeter, azami 35.

3
Günlük döküm job'u: direct bağlantı, `pg_dump --format=custom`, geçici Postgres'e `pg_restore --no-owner --no-privileges --exit-on-error`, tablo eşiği, yükleme sonrası boyut karşılaştırması, tek satır başarı logu.

4
Job ve zamanlayıcıya iki alarm, bilerek başarısız bir çalışmayla bir kez uçtan uca denenir. Üçüncü alarm: son 'backup ok' satırı 26 saati geçerse. Bunu günde iki kez çalışan küçük bir denetim işi kontrol eder, çünkü Cloud Monitoring'in yokluk alarmı en çok 23,5 saat bekler.

5
Kova herkese kapalı, tek tip erişim, retention 7, lifecycle 30, soft delete 7 gün. Yedek kimliği yalnız nesne oluşturur; projenin Viewer ve Editor kolaylık bağları kovadan kaldırılır.

6
Döküm uygulamanın değil, salt okunur ayrı bir rolün bağlantısıyla alınır; migration ve yedek direct, uygulama pooled adres kullanır.

7
Haftada bir en son dökümün proje dışı kopyası alınır. [öneri] Hedef kovada lifecycle 28 gün, soft delete 7 gün olur. Lifecycle hedefteki kopyalama anından sayılır; 28 gün seçildiği için kopya da gizlilik metnindeki 37 günü aşmaz.

8
Ayda bir geçmişten önizleme, üç ayda bir dökümden tam geri yükleme tatbikatı; süreler runbook'a yazılır.

## Tatbikat takvimi

| Ne zaman | Ne yapılır | Süre |
|---|---|---|
| Her gün | Job'un geri yükleme kontrolü ve boyut karşılaştırması; başarısızlıkta alarm; son başarı 26 saati geçerse günde iki kez çalışan denetim işi ayrı alarm verir. | otomatik |
| Her hafta | Son yedi 'backup ok' satırına bakılır. Önceki güne göre %20'den fazla küçülen döküm ya da migration olmadan değişen tablo sayısı incelenir. | 2 dk |
| Her ay | 24 saat önceki andan dal açılır ya da Time Travel Assist ile sorgulanır, birkaç kritik tablonun satır sayısı bugünküyle karşılaştırılır, dal silinir. Geçmiş penceresi ve snapshot zamanlaması ayarda mı bakılır; Free projelerde CU-saat, depolama ve dal sayısı okunur. | 10 dk |
| Üç ayda bir | Son döküm yeni bir Neon dalına ya da projeye tam yüklenir (test ortamına asla), dökümün başladığı ana açılmış dalla tablo tablo md5 karşılaştırılır, uygulamanın bir kopyası bağlanıp okuma yapılır, süre kaydedilir. | 30–60 dk |
| Job, imaj ya da alarm değişince | Alarm bilerek başarısız bir çalışmayla yeniden denenir. Konu satırına TEST yazılır; ad ancak alarm kapandıktan sonra geri alınır, çünkü kapanış postası da adı taşır. |  |
| Postgres ana sürümü değişince | İmaj yeni sürümle yeniden kurulur ve elle bir çalıştırma yapılır. |  |

### Silme ve KVKK

Yedekteki kişisel veri de kişisel veridir. Saklama ve imha politikası dökümleri, snapshot'ları ve kovanın soft delete süresini açıkça kapsar.
Gerçek azami süre için süreler toplanmaz; koddaki silmeye en uzun yedek ömrü eklenir. Bizde döküm 30 gün lifecycle ve 7 gün soft delete ile 37 gün; Neon geçmişi (7 gün) ve snapshot (14 gün) bunun içinde kalır. Kodun 60. günde sildiği bir kayıt o sabahki dökümde 97. güne kadar geri getirilebilir durumda yaşar.
Tek bir kişi yedekten tek tek silinmez; yedeklerin ömrü kısa tutulur ve dökümler kendiliğinden düşer. Silme talebinin cevabında yedeklerden en geç ne zaman düşeceği yazılır.
Silme kişisel veri taşımayan bir iz bırakır (tablo, kayıt kimliği, silinme zamanı); geri yüklemenin son adımı bu izlerle silmeleri yeniden uygulamaktır.
Silme yönetmeliğine göre talep en geç 30 günde sonuçlandırılır (m.12), periyodik imha aralığı altı ayı geçemez (m.11). Canlıdan silme 30 gün içinde yapılır; yedekteki kopya 37 güne kadar kalabildiği için bu fark cevapta açıkça yazılır ve ifadesi hukukçuya sorulur.
Yedekler yurt dışındaysa (AB) aydınlatma metni bunu söyler ve yurt dışı aktarım şartı karşılanır; standart sözleşme imzadan itibaren beş iş günü içinde Kurum'a bildirilir.
Döküm müşteri verisidir: bulut kabuğunda çalışılır ya da indirilen kopya iş bitince silinir. Sohbete, issue'ya, e-postaya ya da ortak klasöre konmaz.
Canlı döküm test ortamına yüklenmez; testler ve elle denemeler canlı veritabanına yazmaz.
Yedek kovasını yalnız proje sahibi okur; kimin ne zaman okuduğunu görmek için kovada veri erişim denetim kaydı açılabilir.

## Taşıma ve geri yüklemeyi doğrulamak

7 Ekim 2026'da iki küçük veritabanı (35 KB ve 1 MB döküm) bu tarifle taşındı: döküm ve yükleme 63 sn, yapı ve sayım karşılaştırması 25 sn, md5 ~15 sn; 12 ve 53 tablonun md5'i birebir. Ortam değişkeni değişikliğinden yeni instance'a ~20 sn, dökümün başlangıcından ikinci servisin geçişine ~5 dk.

1. Aynı sorgular iki tarafta.

Her iki tarafta aynı sorgular çalışır, çıktılar diff ile karşılaştırılır.

2. Yapı.

Eklentiler ve sürümleri, şemalar, sunucu sürümü.

3. Sayım.

Her tablonun tam satır sayısı (`count(*)`) ve her sequence'in son değeri.

4. İçerik.

Her tablonun satırları metne çevrilip sıralanır ve tek md5 alınır. Aşağıdaki sorgu bu sorguları üretir; çıktısı aynı bağlantıda psql'e verilir. Alt alta iki metin sabiti Postgres'te birleşir.

```
select format(
  'select %L || '' '' || coalesce(md5(string_agg(t::text, ''|'' '
  'order by t::text)), ''bos'') from %I.%I t;',
  c.relname, n.nspname, c.relname)
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind in ('r', 'p') and n.nspname = 'public'
order by 1;
```

5. Yükleme.

`pg_dump -Fc` ve `pg_restore --no-owner --no-privileges --exit-on-error -1`: tek işlem, yarım yükleme kalmaz. İki taraf da direct adresle bağlanır.

```
pg_dump -Fc -f db.dump "$KAYNAK"
pg_restore --no-owner --no-privileges --exit-on-error -1 -d "$HEDEF" db.dump
```

6. Geçişten hemen önce ve sonra.

Eski kaynağın md5'i dökümle yeniden karşılaştırılır; fark varsa geçiş durur. Geçişten sonra bir kez daha.

7. Bağlantı bilgisi.

Sohbete ya da loga düşmez; 600 izinli dosyaya yazılır, komutlara kabuk değişkeniyle verilir.

## Tuzaklar

busybox wget ikili dosyayı ilk sıfır baytına kadar gönderir; ilk çalışma kovaya 7 baytlık nesne yazdı. Yükleme curl ile yapılır.

Pooler adresinden alınan pg_dump hata verir; döküm, migration ve geri yükleme direct adresten.

pg_dump kendi ana sürümünden yeni bir sunucudan döküm almayı reddeder; imaj digest ile sabit olduğu için Neon ana sürüm değiştirince job kırılır ve imaj yeniden kurulur.

Özel biçimde `--no-owner` pg_dump'ta yok sayılır; pg_restore'a verilir.

postgres alpine imajında su-exec değil gosu var; geçici sunucu gosu ile postgres kullanıcısında başlatılır.

Kovanın kolaylık bağları (proje Viewer ve Editor) projeyi gören herkese yedeği okutur. `remove-iam-policy-binding` bunlarda 'not found' verdi; politika `set-iam-policy` ile baştan yazılınca kalktı.

Geçmiş penceresi proje ayarında durur ve plan değişince büyümez; Launch varsayılanı 1 gün, azamisi 7 gün. 276 MB'lık bir projede 6 saatlik geçmiş ortalama 12 MB; 7 güne çıkarmak ayda birkaç sent.

Instant restore birleştirme değil, üzerine yazmadır; hata anından sonraki doğru yazmalar `_old_` dalından alınır.

Snapshot'tan geri yüklenmiş dalda instant restore çalışmaz; snapshot'a geçince ilk iş elle snapshot.

Neon projesi silinince dallar, geçmiş ve snapshot'lar da gider; proje yalnız 7 gün kurtarılabilir. Neon içindeki katmanlar Neon kaybına karşı yedek değildir.

Kilitsiz retention sahip tarafından kaldırılabilir; kilit geri alınamaz, süre kısaltılamaz ve projeye silme engeli koyar.

Soft delete lifecycle silmelerine de uygulanır: 30 günlük kural gerçekte ~37 gün demektir ve bu süre gizlilik metnine girer.

Sabit tablo eşiği zamanla gevşer: eşik 40 iken tablo sayısı 47'den 55'e çıktı. Kontrol önceki günün sayısına ya da kritik tabloların satır sayısına bağlanır.

Başarısızlığı sayan alarm hiç çalışmayan job'u görmez; zamanlayıcı duraklatılırsa ya da silinirse sessizlik olur.

Yedek saati başka bir işin veritabanını uyandırdığı saate göre seçildiyse, o iş seyrekleşince yedek kendisi uyandırmaya başlar; bağımlılık yazılır.

Döküm veritabanından çok küçüktür: 70 MB'lık veritabanının dökümü 2,76 MB, boş bir Neon veritabanı bile ~30 MB gösterir. Mutlak boyuta değil günden güne değişime bakılır.

Taşımada döküm ile geçiş arasında eski veritabanına yazma olursa kaybolur; geçişten hemen önce ve sonra md5 yeniden karşılaştırılır.

md5 karşılaştırması tabloyu bellekte sıralar; büyük tablolarda kimlik aralıklarına bölünür.

Free'de dal sınırı 10; dolunca geri yüklemenin istediği dal açılamaz. Depolama 1 GB'ı aşarsa yazmalar durur; CU-saat ya da çıkış kotası aşılırsa compute dönem sonuna kadar durur.

## Kontrol listesi

- [ ] Neon geçmiş penceresi ayarda gözle kontrol edildi (ücretli: 7 gün, Free: 6 saat).

- [ ] Ücretli projede günlük snapshot zamanlandı, saklama süresi yazıldı.

- [ ] Günlük döküm job'u: direct adres, -Fc, ayrı salt okunur rol, imaj digest ile sabit.

- [ ] Döküm geçici Postgres'e --no-owner --no-privileges ile geri yükleniyor; tablo kontrolü ve yükleme sonrası boyut karşılaştırması var.

- [ ] Başarılı her çalışma tek satır log yazıyor; job ve zamanlayıcı alarmı var ve bir kez uçtan uca denendi.

- [ ] Son başarı 26 saati geçerse alarm veren denetim işi var (yokluk alarmı en çok 23,5 saat bekler).

- [ ] Kova herkese kapalı, tek tip erişim, retention 7 gün, lifecycle 30 gün, soft delete 7 gün.

- [ ] Yedek kimliği yalnız nesne oluşturabiliyor; kovanın Viewer/Editor kolaylık bağları kaldırıldı.

- [ ] Haftalık proje dışı kopya var.

- [ ] Gizlilik metni yedekler ve soft delete dahil gerçek azami süreyi yazıyor; silmeler iz bırakıyor ve geri yüklemede yeniden uygulanıyor.

- [ ] Runbook'ta 'canlı veri test ortamına inmez' kuralı ve ölçülmüş süreler yazılı.

- [ ] Aylık geçmiş önizlemesi ve üç aylık tam geri yükleme tatbikatı takvimde.

- [ ] Postgres ana sürümü değişince imaj yeniden kuruluyor.

- [ ] Free projelerde CU-saat, depolama ve dal sayısı ayda bir okunuyor.

<a id="mesajlasma"></a>

Ürün ve büyüme

# Gerçek zamanlı ve mesajlaşma

Gerçek zamanlı bir özellik iki soruyla başlar: karşı tarafın yazdığı ne kadar sürede görünmeli ve bu yol ayda neye mal olur. Bizim yığında Cloud Run istek başına faturalar, Neon ise 5 dakika hiç bağlantı olmazsa uyur. Sürekli açık duran her bağlantı bu iki tasarrufu birden bozar.

**Kural:** Gerçek zamanlı yol, ürün akışına yeten en ucuz basamaktan seçilir.

Sıra şöyle: push ve açılışta yenileme; yetmiyorsa yalnız açık ekranda kısa yoklama; tek cevabın akması için SSE; en son canlı ortak çalışma için WebSocket. Mesajlaşma ilk günden dört şeyle gelir: açık bir veri modeli, sunucuda alıcı denetimi, yazılı bir bildirim kuralı ve yazılı bir silme kuralı.

Ürün A'nın pazar yerinde talep sahibi ile kurumsal kullanıcı yazışıyor: haber push ve e-postayla gidiyor, cevap konuşma ekranı açıkken kısa yoklamayla geliyor. Bu düzen 5 Eki 2026'dan beri canlıda; yeni bir servis, ayrı bir zamanlayıcı ya da sürekli bağlantı istemedi. Veritabanının neden uyuyabilmesi gerektiği [Postgres](#katman-1), uyuyan veritabanını bekleyen ilk isteğin davranışı [Go API](#katman-2) katmanında.

**0** Canlıda WebSocket, SSE ya da LISTEN/NOTIFY kullanan kod. Ürün C'nin web ve admin arayüzünde ilk günden kalan, hiç çağrılmayan bir Socket.IO istemcisi duruyor; sunucusu yok.
**8 sn** Konuşma ekranının yoklama aralığı. Yalnız ekran açık ve öndeyken sorar; uygulama arka plandaysa ya da sekme gizliyse istek yok.
**₺2.445** Tek bir WebSocket bağlantısının 7/24 açık tuttuğu 1 vCPU'luk Cloud Run instance'ının aylık liste bedeli. Bizim push ve açık ekranda yoklama yolumuzun ek istek bedeli ≈ ₺0.

## Bugün bizde

Dört ürünün mesaj, bildirim ve yorum akışları; depolardan ve migration'lardan okundu, 8 Eki 2026.

| Akış | Haber nasıl gider | Ekran nasıl güncellenir | Veri |
|---|---|---|---|
| Ürün A: pazar yeri konuşması[kanıtlı] | Push, okunmamış dönem başına bir; saat gözetmez. E-posta günde en çok bir; mesaj metnini taşımaz, 30 gün geçerli imzalı bağlantı konuşmayı açar. | Konuşma açık ve öndeyken 8 sn'de bir yoklama; her turda konuşmanın tamamı okunur. Kaçan tur bir sonrakinde yakalanır. | Tek mesaj tablosu. Okundu, bildirildi, paylaşım ve ret zamanları iki taraf için konuşma satırında. |
| Ürün A: yeni talep duyurusu[kanıtlı] | Premium kurumsal kullanıcıya anında push, 15 dk'lık pencerede toplanır; 21:00–08:00 arası düşen 08:00'den sonraki ilk trafikte gider. Ötekilere hafta içi 10:00'dan sonraki ilk trafikte tek satır. | Uygulama öne gelince ve push gelince liste yeniden okunur. | Talep 14 gün açık kalır. Gelen kutusu satırı talep düştüğü an yazılır. |
| Ürün A: bildirim kutusu[kanıtlı] | Hesaplı kullanıcıya giden push'un kutuda bir satırı vardır; Premium olmayana giden hafta içi özet yalnız push'tur. Push yalnız haber verir. | Öne gelince ve push gelince okunur; uygulama simgesindeki sayı okunmamışa eşitlenir. | Bildirim, cihaz (build numarasıyla) ve push makbuzu tabloları. |
| Ürün A: AI asistan[ölçüldü] | Yok. | Tek istek, tek JSON cevap; akış yok. Cevap ~2,7 sn; modele zaman aşımının varsayılanı 20 sn. | Günlük hak sayacı; geçmiş 180 günde silinir. |
| Ürün B: yorumlar[kanıtlı] | Push gönderilmiyor; cihaz tablosu push token'ının yalnız özetini (hash) saklıyor, özetle push gitmez. E-posta kuyruğunu, satırı yazan istek işçiyi uyandırarak çalıştırır. | Yazan yorumunu hemen görür; öteki ziyaretçiler ~30 sn içinde görür, çünkü her web sunucusu değişiklik işaretini en çok 30 sn'de bir okur. | Yorum, denetim sonucu ve engellenen deneme tabloları. |
| Ürün C ve Ürün D[kanıtlı] | Ürün C'de push içerik sayfasına derin bağlantıyla gider. Ürün D'de push yok. | Ürün C uygulaması öne gelince ve bağlantı dönünce veriyi yeniden okur. | İçerik yorumları; Ürün D'de içerik yorumları ve şikayet durumu. |

## Akışa göre dört basamak

Her satır bir yolun Cloud Run ve Neon'daki karşılığını yazar. Yeşil kutu bizde çalışanı, koyu kutu öneriyi gösterir.

_Grafik: Basamak 1: Haberi uygulama açılınca görmek yeter. Yol: Push ve açılışta yenileme, Push yalnız haber verir; veri sunucudan okunur. Cloud Run: İstek başına faturalı; boşta instance 0. Expo push ücretsiz. Neon: Yalnız uygulama açılınca uyanır. Bizde: Bildirim kutusu, yeni talep duyurusu, Ürün C. Etiket: kanıtlı. Basamak 2: İki kişi yazışır; cevap ekran açıkken gelmeli. Yol: Push ve açık ekranda kısa yoklama, 8 sn; her turda bütün konuşma; arka planda yok. Cloud Run: Yalnız ekran açıkken istek: 10 dk'da 75. Ekran kapanınca 0. Neon: Ekran açıkken uyanık; kapanınca ~6,5 dk sonra uyuyabilir. Bizde: Pazar yeri konuşması, 8 sn aralıkla. Etiket: kanıtlı. Basamak 3: Tek cevap parça parça akmalı. Yol: SSE, aynı istekte, Cevap bitince bağlantı da kapanır. Cloud Run: Akış süresince faturalı. Zaman aşımı varsayılan 5 dk, en çok 60 dk. Neon: Akış sırasında bağlantı tutulmaz; cevap sonunda tek yazma. Bizde: Yok; AI cevabı tek JSON, ~2,7 sn. Etiket: öneri. Basamak 4: Canlı ortak çalışma, çevrimiçi ve 'yazıyor'. Yol: WebSocket ayrı serviste ya da yönetilen servis, Kendi min instance kararı ve yayın katmanıyla. Cloud Run: Bir bağlantı açık oldukça instance tam faturalı. 60 dk'da kopar, istemci yeniden bağlanır. Neon: LISTEN pooler'dan geçmez; ya uyutmaz ya uyuyunca dinleyici kaybolur. Bizde: Yok. Etiket: öneri._

## Bir ay boyunca açık kalan yolun bedeli

Liste fiyatıyla hesap, 49 TL/$; WebSocket ve Ürün A satırları 30,4 gün, Neon 7/24 satırı rehberdeki $19,1. WebSocket satırı en az bir bağlantının ay boyu açık kaldığını varsayar; ücretsiz kota düşülmedi. Ölçek gerçek.

_Grafik: Bir ay boyunca açık kalan yolun bedeli: WebSocket servisi, 7/24: ₺2.445 ($49,9); Neon 0,25 CU, 7/24 uyanık: ₺935 ($19,1): 6,5 dk'dan sık yoklama; Ürün A Neon bugün, tüm trafik: ₺502: günde 3,18 CU-saat; Açık ekranda yoklama, Cloud Run: ≈ ₺0 ek istek; veritabanı payı ölçülmedi_
Cloud Run'da açık bir WebSocket instance'ı aktif sayar ve instance bazlı faturalar; ödenen, bağlantının açık kaldığı süredir.

## Arka planda yoklayan işin veritabanı bedeli

Liste fiyatıyla hesap; iş veritabanını tek başına uyandırıyorsa geçerli. Her uyanış en az ~6,5 dk sürer (bağlantı havuzunun 90 sn'si ve Neon'un 5 dakikası); 0,25 CU'da 7/24 uyanık veritabanı ayda ₺935.

_Grafik: Arka planda yoklayan işin veritabanı bedeli: 30 sn: Ürün A'nın eski işleri: ₺935, %100 uyanık; 5 dk: ₺935, %100 uyanık; 15 dk: Ürün B kuyruğu, eski: ₺405, %43 uyanık; 1 saat: ₺101, %11 uyanık; 6 saat: Ürün B kuyruğu, bugün: ₺17, %1,8 uyanık_
6,5 dakikadan sık soran her şey veritabanını hiç uyutmaz; konuşma ekranının 8 sn'si bu yüzden yalnız ekran açıkken çalışır.

## Altı yolun karşılaştırması

Bedel bizim ölçeğimizde, 8 Eki 2026 liste fiyatıyla. İlk iki satır bizde çalışıyor, gerisi resmi belgelerden.

| Yol | Aylık bedel | Karmaşıklık | Bağlantı kopunca | Uygun akış |
|---|---|---|---|---|
| Push ve açılışta yenileme[kanıtlı] | ~₺0. Expo push ücretsiz, saniyede 600 sınırı; istek milyonu $0,40. | Düşük: bildirim kutusu, derin bağlantı, makbuz okuma. | Push gecikebilir ya da hiç ulaşmaz; açılışta sunucudan okunur. | Bildirim, duyuru, gelen kutusu, az değişen liste. |
| Kısa yoklama, yalnız açık ekranda[kanıtlı] | Cloud Run'da ~₺0: 10 dk'da 75 istek. Ekran açıkken veritabanı uyanık; payı ölçülmedi. | Düşük: zamanlayıcı ve ekran durumu. 304 ve imleç bizde yok, öneri. | Hata yutulur, sonraki turda yakalanır. | Az hacimli konuşma, destek, durum takibi. |
| Uzun yoklama[öneri] | Bekleyen her istek instance'ı aktif ve faturalı tutar, zaman aşımına kadar. | Orta: başka instance'taki yazma, bekleyen isteği ancak ortak bir işaretle uyandırır. | İstemci yeni istek atar. | Nadiren: kısa yoklama ile WebSocket arası. |
| SSE[öneri] | Akış süresince; tek cevapta saniyeler. | Orta: Go'da yazma süresi, aradaki vekilin tamponu. | Tarayıcı yeniden bağlanır; mobilde bunu uygulama yapar. | Tek cevabın akışı: AI, uzun rapor. |
| WebSocket, Cloud Run'da[öneri] | Bir bağlantı açık oldukça instance bazlı faturalı; 1 vCPU 7/24 ~₺2.445/ay. | Yüksek: yeniden bağlanma; instance'lar arası yayın için Redis Pub/Sub ya da Firestore. | Kopunca kaçanı imleçle yeniden okumak gerekir. | Canlı ortak çalışma, çevrimiçi göstergesi. |
| Yönetilen servis[öneri] | Ücretsiz katman 100–200 eşzamanlı bağlantı; ilk ücretli $25–49/ay. | Orta: kanal yetkisi, ikinci bir veri yeri ve işleyen. | İstemci kütüphanesi yeniden bağlanır. | WebSocket gerekiyor ama sunucusu yazılmayacaksa. |

### Yönetilen servislerin sınırları

Mesaj yönetilen servise giderse yeni bir veri işleyen ve çoğu zaman yurt dışına aktarım olur: [KVKK ve veri yeri](#kvkk).

| Servis | Ücretsiz | İlk ücretli | Not |
|---|---|---|---|
| Pusher Channels | 100 eşzamanlı bağlantı, günde 200 bin mesaj. | $49/ay: 500 bağlantı, günde 1 milyon mesaj. |  |
| Ably | 200 eşzamanlı bağlantı, ayda 6 milyon mesaj. | $29/ay ve kullanım: milyon mesaj $2,50, milyon bağlantı-dakika $1. |  |
| Supabase Realtime | 200 eşzamanlı bağlantı, ayda 2 milyon mesaj. | Pro $25/ay: 500 bağlantı ve 5 milyon mesaj dahil; sonra 1.000 bağlantı $10, milyon mesaj $2,50. | Ücretsiz proje 1 hafta hareketsiz kalınca durdurulur. |
| Firebase Realtime Database | 100 eşzamanlı bağlantı, 1 GB veri, ayda 10 GB indirme. | Kullandıkça: GB depolama $5, GB indirme $1. | Push için FCM ücretsiz. |

## Veri modeli

Postgres taslağı. Ürün A'da ayrı konuşma tablosu yok; konuşma, kurumsal kullanıcının talebi üstlendiği satıra bağlı ve iki tarafın okundu ve paylaşım zamanları o satırda durur. İstemci anahtarı ve rapor sütunu bizde yok.

```
CREATE TABLE threads (
  id          uuid PRIMARY KEY
              DEFAULT gen_random_uuid(),
  subject_id  uuid NOT NULL,  -- talep, ilan
  status      text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','closed')),
  last_at     timestamptz,    -- son yazma
  closed_at   timestamptz,
  purge_at    timestamptz     -- kapanış
                              -- + saklama
);

CREATE TABLE members (
  thread_id   uuid REFERENCES threads
              ON DELETE CASCADE,
  user_id     uuid NOT NULL,
  role        text NOT NULL,  -- iki taraf
  read_at     timestamptz,    -- okundu sınırı
  notified_at timestamptz,    -- son bildirim
  muted_until timestamptz,
  shared_at   timestamptz,    -- iletişim açık
  blocked_at  timestamptz,    -- ret
  PRIMARY KEY (thread_id, user_id)
);

-- okunmamış sayı saklanmaz, türetilir
SELECT count(*) FROM messages m
JOIN members p ON p.thread_id = m.thread_id
 AND p.user_id = $1
WHERE m.sender_id <> $1
  AND m.deleted_at IS NULL
  AND m.created_at >
      COALESCE(p.read_at, '-infinity');
```

```
CREATE TABLE messages (
  id          uuid PRIMARY KEY
              DEFAULT gen_random_uuid(),
  thread_id   uuid NOT NULL REFERENCES threads
              ON DELETE CASCADE,
  sender_id   uuid NOT NULL,
  client_key  uuid NOT NULL,  -- istemci üretir
  body        text NOT NULL DEFAULT ''
    CHECK (char_length(body) <= 1000),
  created_at  timestamptz NOT NULL
              DEFAULT now(),  -- sunucu saati
  deleted_at  timestamptz,    -- yumuşak silme
  flag        text,           -- rapor, spam
  UNIQUE (sender_id, client_key)
);
CREATE INDEX ON messages
  (thread_id, created_at, id);

CREATE TABLE attachments (
  message_id  uuid PRIMARY KEY REFERENCES
              messages ON DELETE CASCADE,
  object      text,           -- silinince NULL
  mime        text NOT NULL CHECK (mime IN
    ('application/pdf','image/jpeg',
     'image/png')),
  bytes       int NOT NULL    -- en çok 6 MB
    CHECK (bytes <= 6291456),
  expires_at  timestamptz NOT NULL,
                              -- yükleme + 60 gün
  deleted_at  timestamptz,
  CHECK ((object IS NULL)
         = (deleted_at IS NOT NULL))
);
```

**İstemci anahtarı**[ öneri]
Mobil ağda gönderim tekrar edilir. Aynı anahtarla gelen ikinci istek yeni satır açmaz, ilk mesajı döner. Bizim mesaj tablomuzda yok; e-posta kuyruklarımızda tekilleştirme anahtarı var.

**Okundu zamanı**[ kanıtlı]
Okundu, katılımcı başına tek zamandır. Okunmamış sayı ondan türetilir; ayrı sayaç tutulmaz, çünkü sayaç ile mesajlar ayrışabilir. Ürün A'da iki taraf için iki sütun.

**Ek dosya**[ kanıtlı]
Dosyanın satırı kalır, nesnesi gider: 60 günde kovadan silinir, konuşmada 'silindi' görünür. Günlük temizlik süresi dolan nesneyi yaşından bulur.

**Silme ve saklama**[ öneri]
Silinen mesajın gövdesi boşaltılır, satır 'silindi' olarak kalır. Konuşma kapanıştan sonra saklama süresi dolunca bütünüyle gider; Ürün A'da 180 gün.

## Doğru mesaj doğru alıcıya

Yanlış kişiye giden mesaj, push ya da e-posta geri alınamaz; tek düzeltme önlemektir. Bizde kişiye özel yazışma tek yerde, Ürün A'nın pazar yerinde var; orada da eski revizyona dönüş, talep sahibinin telefonunu onaysız gösterecekti (kural 7). Yedi kural bu yüzden ilk sürümde konur.

1. Okuma ve gönderme yetkisi sunucuda, oturumdan çıkar; katılımcı olmayana 404 döner.

İstemcinin gönderdiği kimlik yalnız hangi konuşma olduğunu söyler, kimin istediğini oturum söyler. Katılımcı koşulu SQL'in `WHERE` satırındadır; liste uçları da kişiyi SQL'de süzer. 404, konuşmanın var olduğunu da belli etmez. Ürün A'da tek istisna e-postadaki bağlantıdır: oturumun yerini tutar, imzalı, 30 gün geçerli ve yalnız o konuşmayı açar; bu yüzden e-posta yalnız doğrulanmış adrese gider.

**Bizde** Ürün A'nın iki hesaplı testlerinde başka hesap okundu işaretleyemez, yazamaz, dosya açamaz ya da silemez; değiştirilmiş e-posta bağlantısı da 404 alır.

[kanıtlı]
2. Push token'ı bir kurulumun ve o an tek hesabındır; çıkışta düşer, hesap değişince taşınır.

Token tabloda tekildir. Çıkışta uygulama token'ı da gönderir, sunucu cihazı o hesaptan düşürür ve uygulama cihazı hesapsız yeniden kaydeder; kişisel push artık gelmez. Aynı telefona başka hesap girince satır yeni hesaba geçer. Kişisel push hesabın açık her cihazına gider.

**Ölü token** Gönderimde ya da 15 dk sonra okunan makbuzda `DeviceNotRegistered` gelince token kapatılır; Expo makbuzu 24 saat tutar. Hesap silinince cihaz ve makbuz satırları da gider.

[kanıtlı]
3. Toplu gönderim önce kuru çalışır: alıcı sayısı ve üç örnek alıcı görülür, sonra onaylanır; gönderim başına tavan sunucudadır.

Yanlış seçilen kitle tek tıkla herkese gider. Tavanı aşan gönderim ikinci bir onay ister.

**Bizde** Ürün A'nın duyuru ucu kitle ve platform adını doğrular; eşleşmeyen ad kimseye gitmeyip 'gönderildi' diyeceği için 400 döner. Cevap gönderim bitmeden döner; kaç cihaza gittiği görünmez. Güncelleme duyurusu güncel build'deki cihazı atlar. Sayı önizlemesi, onay adımı ve tavan yok.

[öneri]
4. Test ortamı gerçek kişiye ulaşamaz.

Ayrı veritabanında gerçek cihaz kaydı yoktur. E-posta yalnız izin listesindeki adreslere gider; liste test ortamında zorunludur, canlıda doluysa API başlamaz. Ayrı push projesi ve gönderen alan adı bizde denenmedi.

**Olay** Ters yönü bizde oldu: adres verilmeyen portal testi ve simülatör canlı API'ye bağlanıp canlıya sahte satır yazdı ([Vaka 15](#vaka-15)). Test istemcisinin hedefi çalışma anında doğrulanır.

[kanıtlı]
5. Push ve e-posta yalnız haber verir; açılan ekran veriyi sunucudan, yetki denetlenerek okur.

Push yalnız 'size yazdı' der; kilit ekranında görünen bu cümledir ([Kullanıcıyı kırmadan değiştirmek 5.8](#k-5-8)). Veri olarak yalnız konuşmanın kimliğini taşır; mesaj uygulamada kalır (Apple 4.5.4), bilinmeyen tür eski uygulamada yalnız uygulamayı açar. Push başka hesabın telefonuna düşse bile sunucu o oturuma konuşmayı döndürmez; ekran açılmaz, kurumsal tarafta 404. E-postanın adresi alıcının kendi kaydından gelir: oturum açıkken formda yazılan değil hesabın adresi kullanılır; oturumsuz talep, adresi kodla doğrulanınca pazar yerine düşer.

**Kilit ekranı** [öneri] Apple yönergesi bildirimde hassas ya da kişisel bilgi olmamasını, önizleme kapalıyken ayrı ve genel bir metin gösterilmesini öneriyor. Android'de kanal `VISIBILITY_PRIVATE` ile kurulursa kilit ekranında simge ve başlık görünür, metin gizlenir; son söz kullanıcının ayarındadır. Bizde kanal varsayılanda.

[kanıtlı]
6. Her gönderim tek bir kayıt satırı yazar: kime, ne, ne zaman, hangi kanaldan, teslim durumu; saklama süresi yazılıdır.

Yanlış gönderimin kapsamı, kaç kişi ve kim, ancak buradan çıkar. Alıcı token'la değil hesap kimliğiyle yazılır, çünkü token sonradan başka hesaba geçebilir. Süre gizlilik metnine girer ([KVKK](#kvkk)), kayıt admin'den okunur ([Analitik ve admin](#analitik)), makbuz hatası artınca ürün sahibine uyarı düşer ([Uyarılar](#uyarilar)).

**Bizde** gönderim izi her kanal için ayrı yerde, farklı sürelerle tutuluyor ve her kanal satır yazmıyor. Yanlış bir gönderimin kapsamı tek sorguyla çıkmıyor; bu kural oradan çıktı.

[öneri]
7. Kimin neyi göreceğini değiştiren sunucu değişikliği yalnız yeni sürüm ya da yetenek başlığı gönderen istemciye uygulanır; eski build eski kuralla cevap alır.

Ürün A'da yeni akışın kayıtları yalnız 'bu akışı gösterebilirim' başlığını gönderen istemciye döner; eski ekran yalnız eski akışı görür. Push'lar build'e göre bölünür. Geri dönüş yalnız anahtarla: eski API revizyonuna dönülseydi eski kod yeni akışı süzmeyecek, talep sahibinin telefonunu onaysız, talebi alan kurumsal kullanıcıya gösterecekti ([Kullanıcıyı kırmadan değiştirmek 7.6](#k-7-6)). Genel sürüm başlığı bizde yok, mobil kitte öneri.

**Olay** Yeni akış 1 Eki yerine 5 Eki'de, eski sürümdeki kurumsal kullanıcılar güncelleyince açıldı: [Vaka 18](#vaka-18).

[kanıtlı]

### İki hesapla deneme

Test ortamında, X ve Y hesabı ve tek telefonla, yayından önce. Etiket, Ürün A'nın canlı kodunda böyle olup olmadığını gösterir.

- [ ] Y, X'in konuşmasına yazar, okundu işaretler, dosyasını açar: üçü de 404; okuma isteğinde X'in konuşması Y'ye hiç dönmez.

[kanıtlı]
- [ ] X çıkış yapar, X'e yazılır: telefona kişisel push gelmez.

[kanıtlı]
- [ ] X'e giden push Y'nin oturumunda açılır: X'in konuşması görünmez.

[kanıtlı]
- [ ] Aynı telefona Y girer: Y'ye yazılan gelir, X'e yazılan gelmez.

[kanıtlı]
- [ ] Kilit ekranındaki push metninde ad, mesaj ve iletişim bilgisi yok.

[kanıtlı]
- [ ] Test ortamından listede olmayan adrese e-posta gitmez.

[kanıtlı]

## Kurallar

### API

Konuşma uçları bir kez doğru kurulur; sonradan değişen her şey eski istemcileri ilgilendirir.

1. Gönderme idempotenttir: istemci her mesaja kendi anahtarını verir.

Zaman aşımında mesaj yazılmış olabilir. Aynı anahtarla gelen ikinci istek ilk mesajı döner, kullanıcı çift mesaj görmez.

[öneri]
2. Okuma imleçle yapılır; değişiklik yoksa 304 ya da boş liste döner.

İstemci son gördüğü (`created_at`, `id`) çiftini gönderir. Sunucu imlecin 10 sn gerisinden başlar, istemci gelenleri kimlikle tekilleştirir. `now()` yazma işleminin bittiği an değil, başladığı andır: önce başlayıp geç biten bir yazma, ondan sonra gelip önce biten mesajın gerisinde kalır. Tam imleç o mesajı hiç döndürmez. Pencere en uzun yazma işleminden geniş tutulur. Ürün A'da konuşma en çok 300 mesaj olduğu için her turda tamamı okunuyor; sınırsız konuşmada liste sayfalanır.

[öneri]
3. Sınırlar sunucuda ve adlı hatayla: gövde 1.000 karakter, konuşmada 300 mesaj, 20 dosya, dosya 6 MB.

Genel tavan IP başına dakikada 600 istek; 429 `Retry-After` taşır ve uygulama ayrı bir mesaj gösterir.

[kanıtlı]
4. Zaman ve sıra sunucudan gelir.

`created_at` sunucuda yazılır; liste önce bu zamana, eşitlikte kimliğe göre sıralanır. Telefonun saati sırayı belirlemez.

[kanıtlı]
5. Bir hatalı mesaj konuşmayı kilitlemez.

AI sohbetinde '70000 ay' diye okunan mesaj geçersiz vade hatası verdi ve sonraki her mesaj aynı hatayı aldı (2 Eki 2026). Hata o mesajda kalır, sonraki temiz başlar.

[kanıtlı]

### Bildirim

Sıklık kuralı ve kontrolü [Kullanıcıyı kırmadan değiştirmek 5.6](#k-5-6)'da; push kaydı ve makbuz okuma [Mobil uzaktan kontrol kitinde](#mobilkit). Ürün sahibine giden uyarılar [Uyarılar kime, nasıl ulaşır](#uyarilar) bölümünde.

1. Expo'nun 'ok' makbuzu teslim demek değildir; doğru veri sunucudadır.

Makbuz yalnız Apple ya da Google'ın isteği kabul ettiğini söyler; telefona ulaşıp ulaşmadığını söylemez. Uygulama açılınca konuşma ve kutu sunucudan okunur.

[kanıtlı]
2. Okunmamış dönem başına bir push; e-posta günde en çok bir.

Karşı taraf okumadıkça yeni push gitmez, okuyunca sıfırlanır. E-posta gitmezse bir kez daha denenir; yine gitmezse günlük işaret silinir ki sonraki mesaj göndersin.

[kanıtlı]
3. Yeni talep duyurusu 15 dakikada toplanır ve gece çaldırmaz; Premium olmayana hafta içi tek özet gider.

21:00–08:00 arası düşen talep 08:00'den, özet 10:00'dan sonraki ilk trafikte gider. Ayrı zamanlayıcı yok: trafiğin zaten uyandırdığı veritabanında var olan işçi gönderir; gelen kutusu satırı anında yazılır. Konuşma push'u saat gözetmez; yeni üründe konuşmaya da gece kuralı koymak önerimiz.

[kanıtlı]
4. Konuşma başına sessize alma, kategori anahtarından ayrıdır.

Ürün A'da kategori var: kampanya anahtarını kapatmak yazışmayı susturmaz. Konuşma başına sessize alma yok; şemadaki `muted_until` bunun için.

[öneri]

### Gizlilik ve saklama

Veri yeri, işleyen listesi ve aktarım [KVKK ve veri yeri](#kvkk) bölümünde.

1. İletişim bilgisi iki taraf razı olana kadar gizlidir.

Kurumsal kullanıcı telefonu ve e-postayı görmeden yazar; talep sahibi paylaşımı onaylarsa açılır, reddederse o kişi artık yazamaz.

[kanıtlı]
2. Dosyayı yalnız talep sahibi ve yalnız paylaşımdan sonra gönderir.

Kurumsal kullanıcı dosya yükleyemez; gönderebildiği yalnız uygulamanın oluşturduğu hazır kartlardır. Karşı tarafa sahte belge gönderen dolandırıcılığa kapı açılmaz. Dosyayı yalnız iki taraf API üzerinden indirir; fotoğrafın konum bilgisi silinir.

[kanıtlı]
3. Saklama süresi ilk sürümde yazılır: dosya 60 gün, konuşma kapanıştan sonra 180 gün.

Günlük temizlik işi süresi dolanı kovadan siler, hesap silinince dosyalar da gider. Gizlilik metni bu süreleri yazar.

[kanıtlı]

### Eski sürümler ve kötüye kullanım

Yetenek başlığı ve anahtarla geri dönüş yukarıda, [Doğru mesaj doğru alıcıya](#ms-dogru) başlığının 7. kuralında. Sürüm başlığı ve güncelleme uyarısı [Mobil uzaktan kontrol kitinde](#mobilkit); şikayet ekranı [Analitik ve admin](#analitik) bölümünde.

1. Sunucudan metin gösteren alan ilk build'de olur.

Eski pazar yeri ekranına sunucudan yazı konamadığı için değişiklik eski sürümdeki kullanıcıya anlatılamadı.

[kanıtlı]
2. Spam sınırı konuşmanın kuralıdır: karşı taraf cevap vermeden en çok 3 mesaj.

Cevap sayacı sıfırlar. Reddeden kişiye yazılamaz; reddeden yazarsa ret kalkar.

[kanıtlı]
3. Denetlenmeyen yorum yayınlanmaz.

Ürün B'de yorum yayından önce modelle denetlenir; denetime ulaşılamazsa yorum yayınlanmaz, bekletilir. Reddedilen deneme kaydedilir ki karar incelenebilsin; kaldırılan silinmez.

[kanıtlı]
4. Her konuşmada rapor et ve engelle; rapor yöneticiye içeriğiyle ulaşır.

Apple kuralı 1.2, kullanıcı içeriği olan uygulamada süzme, rapor, engelleme ve iletişim bilgisi ister. Yöneticiye yalnız 'bir şikayet geldi' diyen e-posta yetmez. Hangi içerik ve hangi konuşma olduğu yazmazsa karar elle aranır. Talep sahibinin reddi engelin yerini tutabilir. Rapor ise ayrı bir düğmedir ve ilk sürümde olur.

[öneri]

## Bizde ne oldu

Kırmızı kenarlı kartlar bedeli ödenen ya da geç bulunanı, yeşil kenarlı kartlar işe yarayan kararı anlatır.

günde 6,2. Ürün A, Eyl 2026

### İşler veritabanını 7/24 uyanık tuttu

E-posta, özet ve makbuz işleri 30 sn ile 1 gün arası aralıkla soruyordu: günde ~6,2 CU-saat. İşler trafiğe bağlanıp herkese açık cevaplar bellekte tutulunca 3,18'e indi (4–7 Eki ortalaması).

**Kural** Veritabanına zamanlayıcıyla soran iş yok. [Vaka 4](#vaka-4)

saniyede 1. Ürün B, Eyl–Eki 2026

### Boş kuyruk her saniye soruldu

E-posta kuyruğu API içinde bütün gece saniyede bir yoklanıyordu. Artık satırı yazan istek işçiyi uyandırıyor; boş kuyruğa 6 saatte bir bakılıyor.

**Kural** Yoklama yalnız yedek yol, tavanı uykudan uzun. [Postgres](#katman-1)

### E-posta tarayıcısı 'görüldü' yakacaktı

Ürün A, 29 Eyl 2026
E-postadaki bağlantıyı açmak okundu sayılıyordu; bağlantıları tarayan e-posta sistemleri kurumsal kullanıcıya yanlış 'görüldü' gösterecekti. Akış açılmadan düzeltildi.

**Kural** 'Görüldü' yalnız görünür ekranda, POST ile. [Kullanıcıyı kırmadan değiştirmek](#kirmama)

5 / 6. Ürün A, Eki 2026

### Yeni akış eski sürümü bekledi

Eski sürümdeki kurumsal kullanıcı yeni akışın taleplerini göremiyordu. Açılış 1 Eki yerine 5 Eki'de, pazar yerini son 30 günde kullanan 6 kurumsal kullanıcıdan 5'i güncelleyince yapıldı.

**Kural** Sürüm başlığı ve sunucudan metin ilk build'de. [Vaka 18](#vaka-18)

4 dk. Ürün A, 30 Eyl 2026

### Gündüz hızlı, gece sessiz

Son 90 günde 7 talebin 4'ü 4 dakika içinde alındı; hız önemliydi. Ürün sahibi bildirimin sürekli düşmesini istemedi: yeni talep duyurusu gece susuyor, Premium olmayana tek özet gidiyor.

**Kural** Sıklık kullanıcının gününe göre. [Kullanıcıyı kırmadan değiştirmek](#kirmama)

294 istek. Ürün B, 4 Eki 2026

### Konum saniyede bir yazıldı

Bir ziyaretçi 14 dakikada ~294 istek gönderdi, 200'den fazlası 429 aldı. Artık ilk okumada, 200 m harekette ya da en çok dakikada bir.

**Kural** Sürekli veri yalnız anlamlı değişince yazılır. [Vaka 28](#vaka-28)

## Gün 0 kontrol listesi

İlk konuşma ekranı yayına çıkmadan önce. Öneri etiketli maddeleri bizde denemedik; yine de ilk sürümde olmalılar.

- [ ] Her akışın basamağı ve üstteki basamağın neden yetmediği bir cümleyle yazıldı.

[öneri]
- [ ] Yoklama yalnız öndeki açık ekranda; arka planda ve gizli sekmede istek 0, yayından sonra logdan okunur.

[kanıtlı]
- [ ] Veritabanına zamanlayıcıyla soran iş yok; işler trafiğin zaten uyandırdığı veritabanında çalışıyor.

[kanıtlı]
- [ ] Yoklama ucu değişiklik yoksa 304 ya da boş liste dönüyor.

[öneri]
- [ ] Mesaj tablosunda istemci anahtarı ve tekil indeks var; aynı istek iki kez gidince tek satır.

[öneri]
- [ ] Gövde, üst üste mesaj, konuşma başına mesaj ve dosya sınırları sunucuda, adlı hatayla.

[kanıtlı]
- [ ] Okundu katılımcı başına; 'görüldü' yalnız görünür ekranda POST ile yanıyor.

[kanıtlı]
- [ ] Bildirim kuralı yazılı: okunmamış dönem başına bir push, e-posta günde en çok bir, yeni talep duyurusu 21:00–08:00 sessiz, hak sahibi olmayana özet.

[kanıtlı]
- [ ] İletişim bilgisi iki taraf razı olana kadar gizli; ret sonrası yazma kapalı.

[kanıtlı]
- [ ] İki hesaplı testte başkasının konuşmasına yazma, okundu işaretleme ve dosya açma 404.

[kanıtlı]
- [ ] Çıkıştan ve hesap değişiminden sonra kişisel push'un gelmediği iki hesapla telefonda denenir.

[öneri]
- [ ] Dosya saklama süresi, günlük temizlik işi ve gizlilik metnindeki süre ilk sürümde.

[kanıtlı]
- [ ] Rapor ve engel düğmesi var; rapor yöneticiye içeriğiyle düşüyor.

[öneri]
- [ ] Yeni akış yetenek başlığı ve kayıtlı build ile süzülüyor, anahtar arkasında kapalı çıkıyor; geri dönüş anahtarla.

[kanıtlı]

## Tuzaklar

Hepsi bizde görüldü ya da resmi belgede yazılı.

LISTEN/NOTIFY pooler'dan geçmez, doğrudan bağlantı ister. Neon belgesine göre boşta bekleyen LISTEN uyumayı engellemez ve uyuyunca dinleyici sessizce kaybolur; bu rehberin varsayımına göre ise açık bağlantı veritabanını uyutmaz. İki durumda da sıfıra ölçeklenen yığına uymaz.

WebSocket instance'ları birbirini görmez: konuşmanın iki tarafı ayrı instance'a düşebilir, oturum yakınlığı yalnız en iyi çabadır. Yayın için Memorystore'da Redis Pub/Sub ya da Firestore gibi ortak bir yer gerekir.

Cloud Run isteği varsayılan 5 dk'da keser, en çok 60 dk'ya uzar. WebSocket ve SSE bu sürede kopar; Google 15 dk'yı aşan sürede yeniden bağlanmayı öneriyor.

Go sunucusunun genel yazma süresi (bizde `WriteTimeout` 10 sn) uzun cevabı keser. Akış ucu kendi süresini `http.ResponseController` ile uzatır; Ürün A'da uzun süren bir uç böyle çalışıyor.

Tarayıcıda HTTP/2 olmadan SSE, alan adı başına bütün sekmelerde toplam 6 bağlantıyla sınırlı.

React Native'de EventSource yok. Expo'nun fetch'i akışı okur, ama kopunca kendiliğinden bağlanmaz.

Ekran kapanınca durmayan `setInterval` veritabanını 7/24 uyanık tutar. Zamanlayıcı mobilde `AppState`, web'de `visibilityState` ile durur.

E-posta tarayıcıları bağlantıyı kullanıcıdan önce açar. GET ile okundu ya da abonelikten çıkış yanlış iz bırakır; durum değişikliği POST'tur.

Konum, 'yazıyor' ya da sensör gibi sürekli veriyi her değişimde yazmak kişinin kendi istek sınırını harcar.

### Ölçülmeyenler

Bu araştırmada okunamayan ya da bizde denenmemiş olanlar.

Gönderilen push sayısı ve makbuz hata oranı: bu araştırmada canlı veritabanı okunmadı.

Konuşma başına mesaj sayısı, cevap süresi ve 8 sn yoklamanın veritabanı tüketimindeki payı ölçülmedi.

WebSocket, SSE, uzun yoklama ve yönetilen servisler bizde denenmedi; bedel satırları liste fiyatından hesap.

Neon belgesi uykuyu '5 dakika aktif sorgu yok' diye tanımlıyor; bu rehber '5 dakika bağlantı yok' varsayıyor. İkisi ayrıştırılarak ölçülmedi; boşta bekleyen bir LISTEN bağlantısının etkisi de ölçülmedi.

Push'un telefona ulaşma süresi ve Android pil tasarrufunun gece etkisi ölçülmedi.

Yönetilen servislerin fiyatları 8 Eki 2026'da okundu; Türkiye'den gecikmeleri denenmedi.

Yanlış alıcıya giden bildirim sayısı: bu araştırmada canlı veritabanı okunmadı.

## Kaynaklar

Resmi sayfalar 8 Ekim 2026'da okundu. Bizim rakamlarımız depolardan, değişiklik kayıtlarından, vaka defterinden ve faturalardan.

**Cloud Run WebSocket**https://docs.cloud.google.com/run/docs/triggering/websockets
**Cloud Run istek zaman aşımı**https://docs.cloud.google.com/run/docs/configuring/request-timeout
**Cloud Run fiyatları**https://cloud.google.com/run/pricing
**Neon scale to zero**https://neon.com/docs/introduction/scale-to-zero
**Neon compute yaşam döngüsü**https://neon.com/docs/introduction/compute-lifecycle
**Neon bağlantı havuzu**https://neon.com/docs/connect/connection-pooling
**Expo push gönderme ve makbuz**https://docs.expo.dev/push-notifications/sending-notifications/
**Expo fetch akışı**https://docs.expo.dev/versions/latest/sdk/expo/
**MDN server-sent events**https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events
**App Store kuralları 1.2 ve 4.5.4**https://developer.apple.com/app-store/review/guidelines/
**Apple bildirim yönergesi**https://developer.apple.com/design/human-interface-guidelines/notifications
**Android kilit ekranı görünürlüğü**https://developer.android.com/develop/ui/views/notifications/build-notification
**Pusher Channels fiyatı**https://pusher.com/channels/pricing/
**Ably fiyatı**https://ably.com/pricing
**Supabase fiyatı**https://supabase.com/pricing
**Firebase fiyatı**https://firebase.google.com/pricing

<a id="tasarim"></a>

Ürün ve büyüme

# Tasarım sistemi ve devir

Canlı ürünlerimizde tasarım koda elle kopyalanarak indi ve her ürün aynı sorunları ayrı ayrı yaşadı: renk birden çok yerde tanımlandı, font bir yüzeyde düştü, tasarım paketi olmayan veriyi çizdi, Safari ve geniş ekran kontrol edilmedi. Bu bölüm gün 0'da açılacak üç dosyayı ve tasarımın koda iniş yolunu anlatır. Rakamlar 8 Ekim 2026 depo taramasından ve oturum kayıtlarından.

**Kural:** Tasarım koda tek yoldan iner ve gerçek ekranda görülmeden bitmez.

Gün 0'da üç dosya açılır: renk, yazı ve ölçünün tek kaynağı olan token dosyası, tasarım paketlerinin tarihli klasörlerde durduğu depo yeri ve her kararın numarayla yazıldığı karar dosyası. Ekran gerçek cihazda ve tarayıcıda görülmeden iş bitmiş sayılmaz. Ajan arayüze dokunmadan önce bu dosyaları okur, işi bitirince ekran görüntüsüyle gösterir.

**16 paket** Ürün A'da 16–19 Eylül'de tasarım aracından elle verilen devir paketi. Hiçbiri depoya alınmadı; bugün diskte yok, içerikleri yalnız oturum kayıtlarında.
**292,4 / 329,8 pt** Aynı başlığın web'de ve uygulamada genişliği. Font yüklüydü ama kullanılmıyordu; düzeltmeden sonra uygulamada 292,7 pt.
**2 hafta** Ürün B'de sonuç listesinin geniş ekranda bozuk kaldığı süre. Bütün kontroller telefon genişliğinde yapılmıştı.

## Token dosyası dışında yazılmış renk

8 Ekim 2026 depo taraması. Ürünler ortak bir tasarım paketi kullanmıyor; her ürün token'larını kendi depolarında, çoğu zaman elle kopyalayarak tutuyor. Ürün A'nın ana marka rengi 5 depoda 17 dosyada sabit değer olarak yazılı. Ürün B iki dosyayı elle eşliyor ve yine de disiplinle temiz kaldı. Ürün D'nin token'ları tek CSS dosyasında, 12 benzersiz hex 2 dosyada; Ürün C'nin sayısı elimizde yok.

kullanılan koddahiç import edilmeyen bir iskelet dosyasındaadet; ölçek gerçek
_Grafik: Token dosyası dışında yazılmış sabit renk sayısı, ürün ve yüzey başına_
Başka bölümlerde
Görsel taramanın beş ölçüsü ve WebKit kontrolü [Kullanıcıyı kırmadan değiştirmek](#kirmama) bölümünün 3.10 maddesinde, sessizce durduran arayüz 3.11'de, incelenen işin commit'lenmemesi 7.4'te. AGENTS.md, CHANGELOG ve genel karar dosyası [Proje hafızası ve devir](#hafiza) bölümünde; OG kartları [SEO ve GEO](#seo), sosyal paylaşım görselleri [İçerik otomasyonu](#icerik) bölümünde.

## Tasarımdan koda devir

Tasarımı ürün sahibi tasarım aracında (bizde Claude Design) yaptırdı; paketler klasör olarak kod ajanına elle verildi, aracın kod tabanını okuyan yolu hiç çağrılmadı. Kesik çizgili adım bizde yapılmadı. 5. adım yalnız simülatör ve tarayıcıda yapıldı; WebKit kontrolü 23 Eylül'de başladı, gerçek Android cihaz ve uzun Türkçe metin yoktu. 6. adımda sapmalar DESIGN.md ve CHANGELOG'a yazıldı, numaralı karar dosyası hiçbir üründe yok.

_Grafik: Tasarım paketinden CHANGELOG'a yedi adım_

### Devrin kuralları

1
**Tasarım için yeni uç, kolon ya da migration açılmaz**. Verisi olmayan öğe tasarımdan düşer, sahte ya da sabit veriyle doldurulmaz; yeni backend işini yalnız ürün sahibi açar.

Ürün A'nın ilk altı paketi API'de olmayan veri ve kurallar çizdi; eleme olmasa ekrana uydurma rakam çıkacaktı.

[kanıtlı]
2
**Tasarımda yeri belli olmayan ekran için yer uydurulmaz, ürün sahibine sorulur**. Onun kuralı: bizde olup tasarımda olmayanı tasarımın diline uyarlayıp koy; tasarımda olup bizde olmayanı koyma.

Tasarımda yeri belli olmayan yedi ekran tek tek soruldu; kararlar 8 dakika sürdü.

[kanıtlı]
3
**Paketin 'nerede kullanılmaz' ve 'ne yapılmaz' listesi kabul kriteridir**.

Atlandığında yükleme animasyonu düğmeye kondu, hareketli logo 375 px ekranda iki düğmeyi dışarı itti.

[kanıtlı]
4
**Rebrand renk, yazı, logo ve boşluğu değiştirir**. Kontrolün yeri, türü ve davranışı ancak ürün sahibi açıkça isterse değişir; eski ve yeni ekran yan yana gösterilir.

Ürün C'de dört paralel ajan arama yerini, dil menüsünü ve ikonları da değiştirdi; aynı gün geri alındı.

[kanıtlı]
5
**Ekran tarayıcıda ya da simülatörde görülmeden 'yapıldı' denmez**. Ara rapor 'yapıldı, yapılmadı, verisi yok' tablosudur.

Dört tur testleri yeşil geçti ve 'bitti' denildi; portalın tablosu, çekmecesi ve üst çubuğu yoktu.

[kanıtlı]
6
**Paket geldiği günün kaydı olarak saklanır**; geçerli değer token dosyasında ve karar dosyasında durur. Karar değişince ikisine yazılır; eski paketin KARAR.md'sine 'yerini aldı: K-NNN' düşülür.

Ürün C'de 3 Ekim kararı pakete geri yazılmadı; 6 Ekim'de eski paket yeniden kaynak alındı. Kural bugün yalnız ajan belleğinde.

[öneri]

## Paket ne içermeli

Gördüğümüz README'ler sayısaldı: ölçü, süre, easing, açık ve koyu renk sütunu, 'nerede kullanılmaz', erişilebilirlik ve 'ne yapılmaz' birebir koda indi. Veri kaynağı, boş ve yükleniyor durumları, uzun Türkçe metin ve mevcut kontrollerin listesi yoktu. Olmayan veri olayı bu boşluktan çıktı; değişen kontrol olayında paket ürünün mevcut kontrollerini bilmiyordu.

- [ ] Token'lar HTML'in yanında makinece okunan bir dosyada (DTCG JSON); mevcut adlarla eşleme tablosu.

[öneri]
- [ ] Her ekranın durumları: varsayılan, basılı, odak, seçili, devre dışı, yükleniyor, boş, hata, misafir ve girişli, çevrimdışı.

[öneri]
- [ ] Boş, hata ve yükleme metinleri; uzun Türkçe metinli bir varyant, iki satıra kırılma kuralı.

[öneri]
- [ ] Kırılımlar: 375, 900 ve 1280 px'te ayrı kare; tablet destekleniyorsa 768 de.

[öneri]
- [ ] Koyu tema kararı: koyu renk sütunu ya da 'yalnız açık tema' cümlesi.

[kanıtlı]
- [ ] Platform notları: iOS ve Android kontrolleri, güvenli alan, klavye, 44 pt ve 48 dp hedef.

[öneri]
- [ ] Veri kaynağı tablosu: her öğe hangi API alanından geliyor; olmayan veri işaretli.

[öneri]
- [ ] 'Nerede kullanılmaz' ve 'ne yapılmaz' listesi; küçük boy kuralı (44 px altında işaret).

[kanıtlı]
- [ ] Hareket: süre, easing, azaltılmış harekette ne olacağı.

[kanıtlı]
- [ ] Erişilebilirlik: rol, etiket, ekran okuyucu metni, kontrast oranı.

[kanıtlı]
- [ ] Mevcut kontrollerin listesi; paket değiştirdiği her kontrolü açıkça yazar.

[öneri]
- [ ] RTL gerekmiyorsa bunu yazan bir cümle.

[öneri]

### Çizmeden önce brief [kanıtlı]

Tasarım aracı ürünü bilmiyordu. Çizmeden önce ona ürünün kendisi verilir: bütün ekranlar ve akışlar, API'nin gerçekte döndürdüğü alanlar, mevcut kontroller ve token'lar, logonun çalışacağı her yer ölçüsüyle (ikon, favicon, açılış, e-posta, sosyal ve mağaza görseli). Ürün C'de bu brief koddan 14 dakikada çıkarıldı; ürün sahibi onun tasarımdan önce verilmesini istedi.

## Bizde ne oldu

On olay, Ağustos–Ekim 2026. Büyük rakam olayın ölçüsü ya da bedeli. Kural satırı aşağıdaki gün 0 kurallarının ya da yukarıdaki devir kurallarının numarasını gösterir.

6 paket. [kanıtlı]

### Paket ürünün olmayan verisini çizdi

Ürün A, 16 Eyl 2026

Haftalık ortalama, günlük tıklama sayısı, kontenjan ve süreli kilit API'de yoktu; yedi ekranın yeri belli değildi. Araç yalnız ekran çiziyordu; API'nin ne döndürdüğünü bilmiyordu.

**Çözüm** Eleme 5 dakika sürdü. Verisi zaten olan bir bölüm için yalnız okuyan bir uç 7 dakikada yazıldı, migration yok.

**Kural** Devir kuralı 1 ve 2.

498 test. [ölçüldü]

### Testler yeşil, ekran açılmamış

Ürün A, 16 Eyl 2026

Dört tur 36 dakikada yazıldı ve 'bitti' denildi. Akşam portalda satır tablosu, 480 px sağ çekmece ve üst çubuğun olmadığı görüldü.

**Çözüm** Aynı gün ~6,5 saat ekran ekran düzeltme; paket bölüm bölüm karşılaştırıldı.

**Kural** Devir kuralı 5.

159 px. [kanıtlı]

### Marka bileşeni yanlış yerde, yanlış boyda

Ürün A, 16 Eyl 2026

Yükleme animasyonu bir düğmeye kondu; 159 px'lik hareketli logo 375 px ekranda iki düğmeyi dışarı itti. Logo olarak da kullanılan bir ikon dosyası favicon ile ezildi.

**Çözüm** Düğmede standart halka, 720 px altında 44 px'lik işaret, ikon ve favicon ayrı dosyada; ~30 dakika.

**Kural** Devir kuralı 3, gün 0 kuralı 16.

4 depo. [kanıtlı]

### Rebrand kontrolleri de değiştirdi

Ürün C, 2 Eki 2026

Paket kontrol düzenini de çizmişti. Arama başlıktan ana sayfaya taşındı, dil menüsü düz yazıya döndü, düğme ikonları kalktı.

**Çözüm** Eski kontroller yeni stil altında ~1 saatte geri geldi. Onay yerel önizlemeden sonra olduğu için canlı bozulmadı.

**Kural** Devir kuralı 4.

3 gün. [kanıtlı]

### Eski paket yeni kararı ezdi

Ürün C, 3–6 Eki 2026

3 Ekim'de sayfa zemini beyaza çevrildi, karar pakete geri yazılmadı. 6 Ekim'de sosyal görseller paketin README'sine bakılarak eski zeminle yapıldı.

**Çözüm** Görsel seti canlı token'lardan yeniden üretildi.

**Kural** Devir kuralı 6.

4 şikâyet. [ölçüldü]

### Uygulama marka fontunu kullanmıyordu

Ürün A, 16 Eyl 2026

Ürün sahibi aynı gün dört kez fonttan şikâyet etti, iki kez gözle 'aynı' denildi. Ağırlığa göre dosya seçen yama React Native 0.81'de sessizce devre dışıydı; web 800 yüklüyordu, mobilde o dosya yoktu.

**Çözüm** Yama StyleSheet.create seviyesine taşındı, web 800'ü bıraktı. Ölçüm sonrası 292,7 pt.

**Kural** Gün 0 kuralı 4.

9 gün. [kanıtlı]

### Paylaşım görsellerinde ğ ve ş bozuk

Ürün A, 28 Eyl–7 Eki 2026

Alt küme dosyaları aynı aile adıyla kayıtlıydı; görüntü üretici 700 başlıklara 500 ağırlığın Türkçe alt kümesini verdi. Widget ve API sayfaları da fontu almıyordu.

**Çözüm** Türkçe alt küme kendi adıyla kaydedildi; widget'a ve API'ye font gömüldü.

**Kural** Gün 0 kuralı 5.

51 aile. [ölçüldü]

### İki görsel dünya aynı anda yayında

Ürün B, 19 Ağu 2026

Yeni tasarım eskinin üstüne katman olarak eklenmişti; 51 seçici ailesi eski sistemle çiziliyordu. Tasarım skill'i yalnız API deposundaydı, web oturumları onu yüklemiyordu.

**Çözüm** Bir tam gün: token'lar tek dosyaya, skill üç depoya, DESIGN.md baştan.

**Kural** Gün 0 kuralı 1 ve 2.

3 görsel. [kanıtlı]

### Açılışta önce eski, sonra yeni görsel

Ürün A, 16 Eyl 2026

Sistem, açılış kütüphanesi ve JS katmanı üç ayrı görsel çiziyordu; Android'de üçüncüsü 1200 ms sürüyordu.

**Çözüm** JS katmanı kalktı, native açılış animasyonun ilk karesi oldu; ~25 dakika ve bir native derleme.

**Kural** Gün 0 kuralı 16.

20 px. [ölçüldü]

### Geniş ekranda bozuk liste

Ürün B, Eylül 2026

İki sütunlu ızgaraya üçüncü bir çocuk eklenmiş, şablon değişmemişti; ad ve adres 20 px'lik sütuna sıkıştı. Kontroller hep telefondaydı; liste iki hafta böyle kaldı.

**Çözüm** Üç sütunlu şablon, 19 Eylül. İnceleme turlarının hiçbiri yakalamamıştı.

**Kural** Gün 0 kuralı 17.

## Gün 0 kuralları

25 kural, dokuz başlıkta. Etiket kuralın bizdeki kanıtını gösterir; öneri, bizde denenmemiş ya da tam uygulanmamış demek.

### Token kaynağı ve adlandırma

1
**Tek token kaynağı depoda durur**: `tokens/tokens.json`, DTCG 2025.10 biçiminde. Bir build adımı web için CSS değişkenlerini, mobil için `theme.ts`'i, e-posta şablonları için sabitleri üretir; elle kopya yoktur.

Ürün A'da üç CSS kopyası elle eşleniyor (birinde bir değer farklı), web ve mobilde token adları farklı, e-posta renkleri satır içi. Ürün C'de web dört katman, admin ayrı kopya; 51 ortak token'ın 19'u farklı.**Kontrol** CI üretilen dosyaları yeniden üretip fark arar; fark varsa build kırılır.

[öneri]
2
**Token dosyası dışında renk, font adı ve gölge yazılmaz**. CI token dosyası dışındaki hex'leri sayar, sayı artarsa kırılır.

Bugün token dosyası dışında Ürün A portalında 327, mobilde 155; Ürün B'de 29 ve 5.**Kontrol** stylelint `color-no-hex` ya da bir grep sayacı.

[öneri]
3
**Token adı rolü söyler**: ink, ink-muted, surface, surface-muted, line, accent, focus. Durum renkleri üçlü gelir: ön plan, açık zemin, o zeminin üstündeki metin. Anlam değişirse yeni ad açılır, eski ad başka anlama verilmez.

Ürün A'da adlar korunup yalnız değerler değişince ~40 ekran dokunulmadan yeni sisteme geçti. Bir yüzey rengi ters kutupluluğa geçince onu açık sanan her yer bozuldu.**Kontrol** Token dosyasında her token'ın bir rol açıklaması var.

[kanıtlı]

### Tipografi ve Türkçe karakterler

4
**Tek yazı ailesi (gerekirse sayılar için bir mono), en çok dört ağırlık, web ve mobilde aynı ağırlık kümesi**. Ölçek rol adlarıyla 5–7 basamak, mobil gövde 15–18. Mobilde her ağırlık kendi dosyasına çözülür; sentetik kalınlık bırakılmaz.

Ürün A'da web 800 kullandı, mobilde o dosya yoktu ve Android sahte kalınlık ekledi. Paketin iki ayrı yüzü ekranı iki ürün gibi okuttu; üç tur ve ~4 saat sonra tek aileye geçildi.**Kontrol** Aynı metin iki platformda aynı puntoda basılıp genişliği ölçülür (canvas `measureText`, React Native `onTextLayout`); fark %2'yi geçmez.

[ölçüldü]
5
**Font Türkçe gliflerle (ğ ş ı İ ç ö ü), gerekiyorsa Kiril ile denenerek seçilir**; tam dosya ya da kendi adıyla kayıtlı latin-ext alt kümesi kullanılır. Font her yüzeyde ayrı denenir: web, uygulama, widget, e-posta ve API sayfaları, OG ve sosyal görsel, PDF, sunum.

Ürün A'da font dört yüzeyde ayrı ayrı düştü; Ürün B'de desteklenen dillerden birinin alfabesini taşımayan bir yüz bu yüzden elendi.**Kontrol** Her yüzeyden 'Ağır Işık Şöğüş İı' örnek metnini gösteren bir ekran görüntüsü.

[kanıtlı]
6
**Büyük harfte CSS'e güvenilmez**. lang her sayfada doğrudur, Türkçe metin tr-TR ile büyütülür, marka adı ve İngilizce marka kelimeleri kaynakta sabit yazılır; harf aralığı en çok 0,04em.

Ürün A'da CSS uppercase İngilizce bir marka kelimesini noktalı İ ile yazdı; Ürün C'de Türkçe bir etiket İngilizce sayfada noktasız I çıktı. Geniş harf aralığı 'AI slop' diye reddedildi.**Kontrol** Birim test: her büyük harf etiket kendi dilinin büyük haliyle aynı.

[kanıtlı]

### Renk, kontrast ve dokunma

7
**Kontrast WCAG 2.2 AA**: gövde metni 4,5:1, büyük metin ve kontrol kenarı 3:1. Oran metnin gerçekte durduğu her zemine göre ayrı hesaplanır.

Ürün A'da soluk metin beyaz üstünde 4,69:1 idi, sayfa zemininde 4,41:1'e düşüyordu; 5,68:1 veren değer seçildi.**Kontrol** Token çiftleri listesi ve bir kontrast birim testi.

[ölçüldü]
8
**Durum rengi tek başına anlam taşımaz**; yanında metin ya da işaret olur. Ana eylem rengi yalnız basılacak şeylerde kullanılır.

Ürün A'nın tasarım belgesi ve Ürün B'de bir rozet bu kuralla çiziliyor.**Kontrol** Renk körlüğü simülasyonunda ekran okunuyor mu.

[kanıtlı]
9
**Dokunma alanı en az 44x44 pt (iOS) ve 48x48 dp (Android)**; flex ebeveyn küçültemez. Başlık satırı gibi geniş hedeflerde bütün satır dokunulur.

Ürün B'de 44 diye tanımlı bir düğme 36x44'e sıkışmıştı; Ürün A'da akordeonda yalnız 18 px'lik ok dokunuluyordu.**Kontrol** Bileşenin ekranda çizilen boyutu ölçülür.

[kanıtlı]

### Koyu tema kararı

10
**Koyu tema gün 0'da karara bağlanır**. Ya token'larda iki mod tasarlanır ve her ekran iki modda görülür, ya da 'yalnız açık tema' yazılır ve kilitlenir: uygulama ayarında açık stil, web'de `color-scheme: light`. Yarım koyu ekran yayınlanmaz.

Dört ürünün hiçbiri koyu tema yayınlamadı; bir uygulamanın ayarı hâlâ 'otomatik', birinde koyu palet açığın kopyası, bir web'de koyu mod tanımlı ama kullanılmıyor.**Kontrol** Sistem koyu moddayken native seçici, uyarı ve klavye ekranla uyumlu mu.

[öneri]

### Bileşenler ve durumlar

11
**Her bileşenin durumları baştan çizilir**: varsayılan, hover, odak, basılı, seçili, devre dışı, yükleniyor, boş, hata, misafir ve girişli.

Gördüğümüz paketlerde boş ve yükleniyor durumları yoktu; durum galerisi bizde kurulmadı.**Kontrol** Bir durum galerisi her bileşeni her durumda ve uzun Türkçe metinle gösterir.

[öneri]
12
**Kullanılamayan düğme basılabilir kalır ve eksiği söyler**; devre dışı yalnız iş sürerken kullanılır, meşgul düğme etiketini ve genişliğini korur. Yüzen her şey portal ile belgenin köküne çizilir.

Ürün B'de devre dışı düğme uyarıyı gizledi, form içindeki diyalog sayfayı yeniledi.**Kontrol** Eksik formda gönder düğmesine basılır; ekran neyin eksik olduğunu yazar.

[kanıtlı]
13
**Aynı iş aynı bileşen**. Yeni element yazmadan önce depoda aranır; ortak bileşen listesi DESIGN.md'de durur; birden fazla kopya bulunursa aynı değişiklikte teke indirilir.

Ürün A'da tarih seçici üç ekranda üç ayrı koddu, ikisi iOS'ta formu aşağı itiyordu; iki PDF üreticisi de ayrışmıştı.**Kontrol** İncelemede açılan her yeni bileşen dosyasının listede karşılığı var mı.

[kanıtlı]
14
**Hareket**: tek easing eğrisi, süreler 120–260 ms, azaltılmış harekette süre sıfır. Animasyon durum, süreklilik ya da geri bildirim anlatır; dekoratif döngü yok.

Ürün A ve B aynı aralıkta birleşti.**Kontrol** Sistemde 'hareketi azalt' açıkken ekran kaydı.

[kanıtlı]

### Platform eşliği ve marka varlıkları

15
**Platform eşliği**: aynı bilgi, aynı akış, aynı özellik kümesi. Kontrol platformun kendisidir (tarih seçici, sheet, geri hareketi, paylaşım); piksel eşliği aranmaz. İki platformda tek ikon ailesi.

Kayma en az bu ilkeyle çalışan Ürün B'de. Ürün A mobilde iki ikon ailesini karıştırıyor (kodda 280 ve 54 geçiş).**Kontrol** Yeni özellik raporunda 'web'de ve uygulamada nerede' satırı.

[kanıtlı]
16
**Marka varlıkları bir README tablosunda durur**: dosya, boyut, rol, nerede kullanılmaz, SHA-256. Küçük boy kuralı yazılıdır (ör. 44 px altında yalnız işaret). İşaret koddan ya da tek SVG'den çizilir; native açılış animasyonun ilk karesidir.

Ürün B'de roller ve hash'ler yazılı, kayma yok. Ürün A'da rolü yazılı olmayan bir ikon favicon ile ezildi, açılışta üç görsel arka arkaya çizildi.**Kontrol** Varlık değişince hash ve tablo aynı commit'te güncellenir.

[kanıtlı]

### Görsel tarama ve Safari

17
**Görsel tarama her sayfada, 375, 900 ve 1280 px'te, beş ölçüyle yapılır**; ölçü önce eski canlı sayfada denenir ki temiz sonuç bir şey ifade etsin. Beş ölçü [Kullanıcıyı kırmadan değiştirmek 3.10](#k-3-10)'da.

Ürün A'da yalnız bildirilen başlık ölçüldü, ürün sahibi aynı sayfada üç hata daha buldu (ek tur ~35 dakika).**Kontrol** Rapor taramanın bulduklarını ayrıca söyler.

[kanıtlı]
18
**Form kontrolü ya da kart düzeni değişince WebKit'te bakılır**. select ve tarih alanında `appearance: none`; ölçüm gerçek kart genişliklerinde. İzin diyaloğu isteyen hata simülatördeki gerçek Mobile Safari'de üretilir.

Ürün A'da iki kontrol yalnız Chrome'da bakılıp canlıya çıktı; Ürün B'de bir konum hatası beş kez 'çalışıyor' ölçüldü, izin hep verilmişti.**Kontrol** Playwright WebKit ya da macOS `qlmanage` ile ekran görüntüsü.

[kanıtlı]
19
**Ekran gösterilmeden onay istenmez**: masaüstü ve telefon ekran görüntüsü, her biri bir satırla. Ürün sahibi bakarken commit yok ([Kullanıcıyı kırmadan değiştirmek 7.4](#k-7-4)).

Ürün C'de ekranlar gösterilmeden deploy onayı istendi, ürün sahibi itiraz etti.**Kontrol** Deploy onayı mesajında ekran görüntüleri var.

[kanıtlı]

### Mağaza ve sosyal görseller

20
**Mağaza görseli bir hattan, gerçek ekran görüntüsünden çıkar**: simülatörde temiz durum çubuğu (9:41), demo hesap, gerçekçi örnek veri, kişisel veri yok; editör projesi JSON olarak git'te. Boyutlar: App Store 6,9 inç 1320x2868, iPad 13 inç 2064x2752, Play telefon en çok 2:1 (1080x2160), öne çıkan görsel 1024x500.

Ürün A'da elle yapılan ilk set reddedildi; açık kaynak bir editöre geçince ilk onay 17 dakikada geldi.**Kontrol** Setin bütün kareleri tek görselde ürün sahibine gider.

[kanıtlı]
21
**Sosyal ve OG görselleri koddan, tam font dosyasıyla üretilir**; boyutlar ve ızgara kırpması [İçerik otomasyonu](#icerik) bölümünde. Web'deki ekran görüntüleri WebP'dir ve her set yeni klasöre girer.

Alt küme web fontu paylaşım kartlarında ğ ve ş'yi bozdu. WebP, PNG'nin beşte biri; 30 günlük önbellekte aynı adres yeni görseli göstermez.

[kanıtlı]

### Arayüz metni ve üslup

22
**Türkçe metin İngilizcesinden uzun çıkar**. Düğmeye min-height ve dikey dolgu verilir, sabit yükseklik verilmez; iki satıra kırılma tasarımın parçasıdır, üç noktayla kesme yok. Sayı biçimi her dilde tek bir biçimlendiriciden gelir.

Ürün A'nın tasarım belgesi bu kuralla yazıldı; Ürün B bütün dillerinde aynısını uyguluyor.**Kontrol** Durum galerisinde ürünün en uzun dilindeki metin.

[kanıtlı]
23
**Örnek ve yer tutucu değerler gerçekçi ve yasal olarak mümkündür**; uç değer yalnız testte kullanılır.

Ürün A'da imkânsız bir örnek tutar ürünün tamamına güveni sarstı.**Kontrol** Örnek rakamlar ürünün kendi kural tablosundan okunur.

[kanıtlı]
24
**Yasak kalıp listesi gün 0'da yazılır**; UI, e-posta, sunum ve sosyal görselde geçerlidir ve teslimden önce aranır. Bizim listemiz: uzun tire, orta nokta ayracı, mono ya da harf aralığı açılmış büyük harf üst etiket, hap etiket, numaralı kart, alt köşede sayfa numarası, iki noktalı vurucu cümle, 'X değil Y' kalıbı, uydurma slogan, kanıtsız iddia, soyut 2x2 grafik, kutu içinde kutu. Kişinin kendi yazdığı metin cilalanmaz; yalnız anlam ve doğruluk düzeltilir.

Bu kalıpların hepsi iki üründe tek tek reddedildi.**Kontrol** Teslimden önce uzun tire, orta nokta ve büyük harf etiket için tek bir grep satırı.

[kanıtlı]
25
**Marka adı sıradan bir kelimeyse cümle başında tek başına kullanılmaz**; okur ürünü mü cins ismi mi kastettiğini ayıramaz.

Bir ürünümüzde cümle başındaki cins isim ürün adı gibi okundu.**Kontrol** Yeni metinde marka adının geçtiği her yer tek tek okunur.

[kanıtlı]

## Karar belgeleri [ölçüldü]

Ürün B'de kararlar depoda ve okunuyor; token satırı geri bildirim numarasını taşıyor. Ürün A'da DESIGN.md var ama ajan dosyası onu anmıyor, birçok kural yalnız bir makinedeki ajan belleğinde. Ürün C'nin günlüğü depo dışında, marka belgeleri eski tasarımı anlatıyor. Ürün D'de belge yok.

| Dosya | İçinde ne var |
|---|---|
| CLAUDE.md | Tek satır `@AGENTS.md`; Claude Code ve öbür ajanlar aynı dosyayı okur. |
| AGENTS.md | Okuma sırası, kontrol komutları, zor öğrenilmiş kurallar; arayüz işinden önce DESIGN.md'yi adıyla gösterir. |
| PRODUCT.md | Ürün ne, ne değil; kullanıcı kim; desteklenen diller; kanıtı olan iddialar. |

| DESIGN.md | Token tablosu (rol, değer, kullanım, karar no), yazı, ortak bileşenler, koyu tema durumu, paketten sapmalar, ekran kabul listesi. |
|---|---|
| tokens/tokens.json | Makinece okunan tek kaynak; DESIGN.md'deki tablo bundan üretilebilir. |
| docs/DECISIONS.md | K numaralı kararlar; tasarım kararları da buraya girer. |
| docs/design-handoffs/ | Her paket YYYY-AA-GG-konu/ klasöründe olduğu gibi, yanında KARAR.md. |
| docs/brand/README.md | Varlık rolleri, boyutlar, hash, küçük boy kuralı. |
| CHANGELOG.md | En yeni üstte; ne değişti ve neden; aynı commit'te. |

### Nerede durur [kanıtlı]

Ürün deposunda, kodla aynı yerde. Birden çok depo varsa API deposu kanonik olur ve ürün belgeleri yalnız orada durur; öbürlerinin AGENTS.md'si onu adıyla gösterir. Belge başka depoya kopyalanmaz. Arayüz deposunun AGENTS.md'si DESIGN.md'nin yolunu da yazar; Ürün B'de tasarım skill'i yalnız API deposundayken web oturumları onu yüklemedi. Ajan belleği tek makinede durur; kural depoya yazılır.

### Kim günceller [kanıtlı]

Kararı ürün sahibi verir; değişikliği yapan, insan ya da ajan, belgeyi aynı commit'te günceller. Token ya da bileşen değiştiyse DESIGN.md farkı aranır, yoksa iş eksiktir. Kodla çelişen belgede kod esas alınır ve belge düzeltilir; karar belirsizse ürün sahibine sorulur.

Genel karar dosyasının biçimi, AGENTS.md ve CHANGELOG kuralları [Proje hafızası ve devir](#hafiza) bölümünde.

### Ajan arayüz işinden önce okur

1
CLAUDE.md ve AGENTS.md: okuma sırası ve kurallar.

2
PRODUCT.md: ürün ne değil.

3
DESIGN.md ve tokens/tokens.json.

4
İlgili paketin README'si ve KARAR.md'si; 'yerini aldı' notu varsa yeni karar.

5
docs/DECISIONS.md'de ilgili K kayıtları.

6
Depoda mevcut bileşen ve canlıdaki ekran.

Sonra eleme raporu: var, yeni backend ister, yapılamaz; yalnız ilki kurulur. Verilen her karar aynı commit'te DECISIONS.md'ye, sapma DESIGN.md'ye yazılır.

```
# DESIGN.md
Kaynak: tokens/tokens.json. Güncelleme: YYYY-AA-GG.
## Tema
Yalnız açık | açık ve koyu. Koyu yoksa neden.
## Renk
| Rol   | Token | Değer | Kullanım | Karar |
| Metin | ink   | #...  | gövde    | K-003 |
## Yazı
Aile, ağırlıklar, ölçek; Türkçe glif denendi mi.
## Aralık, köşe, gölge, hareket
## Ortak bileşenler
Ad, dosya, durumlar. Yeni bileşenden önce bu liste.
## Paketten sapmalar
| Paket | Ne dedi | Ne yaptık | Neden | Karar |
## Ekran kabul listesi
Token dışı renk yok; 375, 900, 1280 px; WebKit;
dört durum; uzun Türkçe metin; kontrast; 44 pt.
```

```
## K-NNN Yalnız açık tema
Tarih: YYYY-AA-GG.
Durum: geçerli | yerini aldı: K-NNN.
Karar veren: ürün sahibi. Yazan: kişi ya da ajan.
Karar: tek cümle.
Neden: olay, ölçüm ya da sahibin sözü, tarihiyle.
Etkilenen: token, bileşen, web, mobil, e-posta.
Kaynak: docs/design-handoffs/YYYY-AA-GG-konu/
Eski girdiler: geçersiz kalan paket ya da belge.
Geri alma: hangi commit'ler, ne gerekir.
```

```
Paket ve kapsam: dosyalar, ekranlar.
Eleme: var | yeni backend ister | yapılamaz.
Kurulan: ekran ve commit. Kurulmayan: neden.
Sapmalar: DESIGN.md'deki satır.
Durum: uygulandı | kısmen | yerini aldı: K-NNN.
```

## **DESIGN.md iskeleti:** **Tasarım kararı, DECISIONS.md içinde:** **Paket klasöründeki KARAR.md [öneri]:** Bizdekinden iyisi

Bizde gün 0'da yapılmadı; hepsi öneri. Süreler tahmin.

### Tek token paketi ve üretici

[öneri]
tokens.json'dan Style Dictionary ile CSS değişkenleri, React Native teması, e-posta sabitleri.

**Etki** Elle kopya ve değer farkı biter; rebrand tek dosyada başlar.

**Emek** Yeni projede yarım gün, mevcut projede 1–2 gün; açık kaynak, ₺0.

### CI'da token dışı renk sayacı

[öneri]
stylelint kuralı ve token dosyası dışındaki hex'leri sayan bir adım.

**Etki** Ürün A'daki 327 ve 155 gibi sayılar büyümez, düşmeye başlar.

**Emek** 2 saat, ₺0.

### Chromium ve WebKit'te ekran testi

[öneri]
Playwright ile 375, 900 ve 1280 px'te ekran görüntüsü ve görsel fark, en uzun Türkçe metinle.

**Etki** Safari ve geniş ekran hatası canlıdan önce yakalanır.

**Emek** 1–2 gün; GitHub Actions ücretsiz kotası içinde, ₺0.

### Otomatik erişilebilirlik

[öneri]
Web'de axe-core ve eslint-plugin-jsx-a11y; token çiftleri için kontrast birim testi.

**Etki** Kontrast, etiket ve rol hataları elle bulunmayı beklemez.

**Emek** Yarım gün, ₺0.

### Tasarım sistemini koddan kurmak

[öneri]
Tasarım aracının kod tabanını okuyan yolu (Claude Code'da /design-sync) ve her turdan önce brief.

**Etki** Araç gerçek token'ları ve bileşenleri okur; brief ile verisi olan alanları da bilir. Kontrol değiştirme ve olmayan veri riski azalır, bizde denenmedi.

**Emek** 1 saat kurulum, tur başına 15 dakika; abonelik limitleri içinde.

### Paketler depoda

[öneri]
Her paket docs/design-handoffs/ altında tarihli klasörde, yanında KARAR.md.

**Etki** Kararın kaynağı izlenir, eski paket yeni kararı ezmez. Bizde 16 paketin hiçbiri bugün yok.

**Emek** Paket başına 5 dakika, ₺0.

### Numaralı karar kaydı

[öneri]
Tasarım kararları DECISIONS.md'de K numarasıyla; DESIGN.md token satırında karar numarası.

**Etki** Ürün B'nin geri bildirim numaralarıyla yaptığı izleme bütün ürünlere yayılır.

**Emek** İlk kurulum 2 saat, karar başına 5 dakika.

### Durum galerisi

[öneri]
Yalnız geliştirmede açılan bir sayfa: her bileşen her durumda, uzun Türkçe metinle.

**Etki** Tarama ve ekran testi tek yerden; boş, hata ve yükleniyor durumları unutulmaz.

**Emek** 1 gün, ₺0.

### Koyu tema kararını kilitlemek

[öneri]
Ya iki modlu token (DTCG modları) ya da uygulama ve web ayarında yalnız açık tema.

**Etki** Sistem koyu moddayken native seçici ve uyarıların ekranla çelişmesi önlenir.

**Emek** Kilitlemek 10 dakika; tasarlanmış koyu tema ürün başına 2–4 gün.

### Ürünler arası başlangıç kiti

[öneri]
Tek ikon ailesi ve tek görsel tarama listesi, her yeni ürüne hazır.

**Etki** Her yeni ürün aynı soruları sıfırdan çözmez.

**Emek** 1 gün, ₺0.

## Gün 0 listesi

İlk ekran çizilmeden önce işaretlenir.

- [ ] `tokens/tokens.json` açıldı; CSS ve mobil tema ondan üretiliyor; CI renk sayacı var.

[öneri]
- [ ] Yazı ailesi Türkçe gliflerle her yüzeyde denendi; web ve mobil aynı ağırlıklarda.

[kanıtlı]
- [ ] Koyu tema kararı yazıldı; uygulama ve web ayarında kilitlendi.

[öneri]
- [ ] CLAUDE.md `@AGENTS.md`; AGENTS.md DESIGN.md'yi gösteriyor; PRODUCT.md ve DESIGN.md var.

[kanıtlı]
- [ ] Marka README'si: her varlığın rolü, boyutu, küçük boy kuralı ve hash'i.

[kanıtlı]
- [ ] Ortak bileşen listesi ve durumları (boş, hata, yükleniyor, devre dışı) yazılı.

[kanıtlı]
- [ ] Kontrast AA ve 44 pt / 48 dp hedef, gerçek zeminde ve çizilmiş boyutta ölçüldü.

[kanıtlı]
- [ ] Görsel tarama listesi (375, 900, 1280 px ve beş ölçü) ve WebKit kontrolü AGENTS.md'de.

[öneri]
- [ ] Paket klasörü açıldı, ilk paket KARAR.md ile girdi; kararlar DECISIONS.md'de.

[öneri]
- [ ] Mağaza ve sosyal görsel hattı: editör projesi git'te, temiz durum çubuğu, boyut listesi.

[kanıtlı]
- [ ] Yasak kalıp listesi (uzun tire, orta nokta, büyük harf etiket, hap, kanıtsız iddia) yazılı.

[kanıtlı]
- [ ] Onay akışı: masaüstü ve telefon ekran görüntüsü, sonra commit ve deploy.

[kanıtlı]

## Tuzaklar

**Ölçü gerçek kart genişliğinde alınır.** Tarayıcı paneli karttan geniştir; 320, 327, 344 px gibi bileşen genişlikleri kullanılır.

**Quick Look ile WebKit render'ı next/font yüklemez.** Metin canlıdakinden geniş görünür; metin sığdırırken genişlik tarayıcıda gerçek fontla ölçülür.

**Next.js dev sunucusu açıkken build almak .next'i ezer.** Sayfa stilsiz gelir ve CSS hatası gibi görünür; bizde iki günde dört kez oldu. Önce sunucu yeniden başlatılır.

**Simülatör aracının görüntüsü cihazın gerisinde kalabilir.** Doğrulama simctl ekran görüntüsüyle yapılır. Görüntü pikseli noktaya çevrilir: 402 pt telefonda 460 px'lik görüntü 0,874 ile çarpılır.

**Native varlık app.json'da değişince kurulu uygulamada görünmez.** Açılış ve ikon yeni derleme ister; bu baştan söylenir.

**Paketteki SVG filtreleri her yerde çizilmez.** Gren gibi filtreler mobilde ve e-postada çalışmaz; o yüzeyler için PNG üretilir.

### Ölçülmeyenler

8 Ekim 2026 itibarıyla ölçülmeyen ya da okunamayan şeyler.

Tasarım aracında geçen süre ve kullanılan limit; yalnız kod tarafı ölçüldü.

Paketlerin tam içeriği: indirme klasörü silindi, yalnız oturum kayıtlarına giren README'ler okunabildi.

Yeniden tasarımların kullanıcı davranışına etkisi; hiçbir üründe öncesi ve sonrası ölçülmedi.

Bütün token çiftlerinin kontrastı; yalnız soluk metin ölçüldü. Tam WCAG denetimi ya da ekran okuyucuyla test yapılmadı.

Kullanıcıların ne kadarının sistem koyu modunda olduğu.

Gerçek Android cihazlarda font çizimi; ölçümler iOS simülatörü ve tarayıcıda yapıldı.

Ürün B'de numaralı geri bildirimlerin madde başına süresi.

Ürün D'nin tasarım süreci; depoda iz yok.

Önerilen CI testlerinin (görsel fark, axe) bizim projelerde yanlış alarm oranı.

## Kaynaklar

8 Ekim 2026'da okundu. Bu bölüme özel.

**Design Tokens Format Module 2025.10**https://www.designtokens.org/tr/drafts/format/
**Style Dictionary**https://styledictionary.com/
**WCAG 2.2**https://www.w3.org/TR/WCAG22/
**Understanding SC 1.4.3 Contrast (Minimum)**https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
**Understanding SC 1.4.11 Non-text Contrast**https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html
**Understanding SC 2.5.8 Target Size (Minimum)**https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
**Apple HIG: Accessibility**https://developer.apple.com/design/human-interface-guidelines/accessibility
**Apple HIG: Dark Mode**https://developer.apple.com/design/human-interface-guidelines/dark-mode
**Material Design 3: Accessibility basics**https://m3.material.io/foundations/accessible-design/accessibility-basics
**App Store Connect: Screenshot specifications**https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
**Google Play: Add preview assets**https://support.google.com/googleplay/android-developer/answer/9866151
**MDN: appearance**https://developer.mozilla.org/en-US/docs/Web/CSS/appearance
**MDN: text-transform**https://developer.mozilla.org/en-US/docs/Web/CSS/text-transform
**Playwright: Browsers**https://playwright.dev/docs/browsers
**Set up your design system in Claude Design**https://support.claude.com/en/articles/14604397
**Expo: Color themes**https://docs.expo.dev/develop/user-interface/color-themes/

<a id="seo"></a>

Ürün ve büyüme

# SEO ve GEO

Canlı ürünlerimizi arama motorlarında (SEO) ve yapay zekâ cevap motorlarında (GEO) bulunabilir kılmak için yaptıklarımız, ölçtüklerimiz ve hiç bitmeyen işler. Rakamlar Ağustos–Ekim 2026'dan. Alan adları yeni ve dış bağlantı neredeyse yok; bu yüzden rakamlar küçük.

**Kısaca:** Teknik temel bir haftada kuruldu, tık 28 günde 17'de kaldı.

Ürün A'da sunucuda çizim, sitemap, IndexNow, Bing kaydı ve iç bağlantılar 18–22 Eylül'de, yapısal veri 6 Ekim'e kadar yapıldı. Dizindeki sayfa 18 Eylül'de 2'ydi, 4 Ekim verisinde 136; dış bağlantı 30 Eylül'de 2'ydi. Başlığının vaat ettiğini vermeyen sayfalar 4–8. sırada 0 tık aldı. Kullanıcı adına sayfa açma (ChatGPT-User) yalnız tarihli, kaynaklı rakam sayfaları olan üründe anlamlı sayıda geldi: Ürün A'da 6 günde 150, ~18 bin sayfalık katalogda 3 günde 0; bu bir ilişki, kanıt değil. Yeni projede teknik kısım gün 0 listesiyle yarım günde biter (tahmin); zaman dış bağlantıya ve tarihli veri sayfasına ayrılır.

Başka bölümlerde
Sunucuda çizim ve noindex başlığı [Next.js web](#katman-3) katmanında; açık ve kapalı botlar [Botlara karşı tutum](#botlar), hız [Performans](#performans), olay kaydı [Analitik ve admin](#analitik), adres ve 404 kuralları [Kullanıcıyı kırmadan değiştirmek](#kirmama) bölümünde.

**Önce bunu bilin:** SEO botları çağırır, botlar veritabanını uyandırır.
SEO ve GEO için açtığımız sayfalar önce kendi faturamızı büyüttü. Ürün B'de adı belli tarayıcılar veritabanına bir gün boyunca 5 dakikalık boşluk bırakmadı; Ürün C'de yeni kategori sayfaları veritabanını günde ~74 kez uyandırdı. Botun gelebileceği her yol (sayfa, site haritası, llms.txt, paylaşım görseli) bellekten ya da ISR'dan sunulur ve veritabanına hiç gitmez; yeni bir SEO yüzeyi açılınca 48 saat uyanmalar izlenir. Ayrıntı: [Postgres](#katman-1) ve [Botlara karşı tutum](#botlar).

**2 → 136** Ürün A bilgi sitesinde dizindeki sayfa, 18 Eylül'den 4 Ekim verisine. Aynı haftalarda dört iş birlikte yapıldı; pay ayrılamıyor.
**17 tık** Ürün A'da 4 Ekim'e kadar 28 günde, 2.350 gösterimden. Ortalama konum 30,2.
**2 bağlantı** Ürün A'nın 30 Eylül'deki dış bağlantısı; ikisi de aynı sosyal ağdan. Kodla çözülmeyen en büyük boşluk.
**1 → 200** Google'ın AI özelliklerinde gösterim: 18 Eylül'e kadar üç haftada 1; 6 Ekim okumasında (3 Ekim'e kadar veri) 51 sayfada 200.
**150 ve 0** 1–7 Ekim'de ChatGPT-User isteği: tarihli veri sayfaları olan Ürün A'da 6 günde 150, ~18 bin sayfalık Ürün B kataloğunda 3 günde 0.
**1 okuma** llms.txt ~11,7 günde bir kez istendi (ClaudeBot), sonraki 6,5 günde hiç istenmedi.

## Ne yaptık

18 Eylül–6 Ekim 2026, son tarihe göre sırayla.

**18 Eyl Ürün A:** [ölçüldü]
Bilgi sitesi istemcide çizilen tek sayfalık uygulamadan sunucuda tam HTML veren Next.js'e geçti. Eski sitenin HTML gövdesi AI tarayıcılarına boştu.

**Sonuç** Dizindeki sayfa 2'den 136'ya (4 Eki verisi) çıktı; OAI-SearchBot ~11,7 günde 116 sayfa taradı. Aynı günlerde başka işler de yapıldığı için artış yalnız buna yazılamaz. Ayrıntı [Next.js web](#katman-3) bölümünde.

**18–19 Eyl Ürün A:** [ölçüldü]
Bing Webmaster Tools Search Console'dan içe aktarıldı; IndexNow her deploy'un son adımı.

**Sonuç** ~11,7 günde Bing 7, Googlebot 911 sayfa çekti; Bing içerik sayfalarını ilk kez 6 Eki'de çizdi. 7 Eki'de Bing ~2.900 adres aldığını gösteriyordu; performansı 0 tık, 0 gösterim.

**19 Eyl Ürün B:** [kanıtlı]
Sitemap istek anında üretilir oldu; arka uç cevap veremezse hata döner, son iyi kopya kalır. Önce ulaşılamayan arka uç boş liste sayılmış, sitemap 12.589 sayfadan 9.921'e inmiş, 2.668 sayfa sessizce düşmüştü.

**Sonuç** Tekrarlamadı. Düzeltme önce build'i kırdı, 16 saat deploy çıkmadı. Ayrıntı [Kullanıcıyı kırmadan değiştirmek 3.5 ve 3.6](#k-3-5) bölümünde.

**22 Eyl Ürün A:** [ölçüldü]
Her kurum sayfası, o kurumun sunduğu ürünlerin konu sayfalarından adıyla bağlandı. Önce her biri 1 iç bağlantı alıyordu, site ortalaması 9,9'du.

**Sonuç** Bağlantı 1'den 3–8'e çıktı; payı 4 Eki verisindeki 136'nın içinde ayrılamıyor. 27 Eyl'de küçük kurumların sayfaları dışarıdaydı; elle istekten sonra 3 Eki'de Türkçe kurum sayfalarının hepsi dizindeydi.

**23–24 Eyl Ürün B:** [ölçüldü]
Okur getirmeyen tarayıcılar (SEO paketleri, PetalBot, Amazonbot, Meta'nın eğitim tarayıcısı) robots.txt'de Disallow edildi. Bir günde 18.266 isteğin ~9.400'ü adı belli tarayıcılardandı.

**Sonuç** En büyüğü günde 4.685 istekten 4'e indi; uymayanı 24 Eyl'den beri proxy, 7 Eki'den beri ortak kapı reddediyor. Bedeli, backlink araçlarında daha az görünmek. Ayrıntı [Botlara karşı tutum](#botlar) bölümünde.

**27 Eyl Ürün C:** [kanıtlı]
Ürün C'nin sitesinde ana sayfa ve liste sayfaları sunucuda çizildi; site geneli tek canonical, hatalı hreflang ve /_next/ engeli kaldırıldı. Hatalar Şubat'taki ilk sürümden beri duruyordu.

**Sonuç** Ölçülmedi; 5 Eki'de okunan sayfa raporu düzeltmeden önceki tarihi taşıyordu.

**3 Eki Ürün B:** [ölçüldü]
Katalog sitemap parçaları gzip'le sunuldu; www ve kimlikli eski adresler 308 ile tek adrese gitti.

**Sonuç** En büyük parça 10,2 MB'tan 237 KB'a indi. Dizine etkisi ölçülmedi.

**19 Eyl, 6 Eki Ürün A:** [ölçüldü]
Veri sayfası açıldı, sonra tarihli hale geldi. Rakamın yanında kaynak ve okuma tarihi, başlıkta rakam ve ay, bir yöntem sayfası ve Dataset var.

**Sonuç** İlk sayımda ChatGPT'den gelen 9 girişin 7'si bu sayfadaydı; düzeltilmiş sayımda bunların bir kısmı aynı linki 1–2 günde bir açan bir bot çıktı. Sayfayı bir kazıyıcı da 2–6 Eki'de 63 kez çekti.

**6 Eki Ürün A:** [ölçüldü]
Başlığı 'hesaplama' diyen yedi sayfaya tek rakamlık tahmin kutusu kondu. Bu sorgu ailesi 90 günde 4–8. sırada ~170 gösterimde 0 tık almıştı.

**Sonuç** Taban kaydedildi: kutulu sayfaların sorgularında konum 5,1 ve 6,4, 0 tık (7,8'lik üçüncü sorgu kutusuz bir sayfaya ait). Etkisi 2–4 hafta sonra ölçülecek.

**6 Eki Ürün A:** [kanıtlı]
Her sorgu ailesine tek alan adı verildi; pazar yerindeki kopya veri sayfasının canonical'ı bilgi sitesine çevrildi.

**Sonuç** Ölçülmedi. Pazar yeri o sırada 28 günde 3 tık, 211 gösterim ve ortalama 42. konumdaydı. Ayrıntı [Kullanıcıyı kırmadan değiştirmek 3.4](#k-3-4) bölümünde.

## Ne çıktı

Ürün A bilgi sitesinde dizindeki ve dışarıdaki sayfa, Search Console okumalarıyla. 18 Eylül'de site Next.js'e geçti, 22 Eylül'de iç bağlantılar güçlendi, arada elle dizin istekleri yapıldı. Rapor 21 Eylül verisinde iki hafta dondu, 7 Ekim'de 4 Ekim verisine atladı; 22 Eylül'deki iç bağlantı değişikliği yalnız 4 Ekim verisine yansıyabilir.

dizindedışarıdasayfa, Search Console; ölçek gerçek
_Grafik: Ürün A bilgi sitesinde dizindeki ve dışarıdaki sayfa: 18 Eyl okuması (eski site) 2 dizinde, 4 dışarıda; 22 Eyl okuması (Next.js'ten 4 gün sonra) 43 dizinde, 47 dışarıda; 25 Eyl okuması (21 Eyl verisi) 92 dizinde, 54 dışarıda; 7 Eki okuması (4 Eki verisi) 136 dizinde, 28 dışarıda_

## Öbür ölçümler

| Ölçüm | Değer | Ürün, kaynak |
|---|---|---|
| Tık, gösterim, konum | 28 günde 9, 802 ve 22 (28 Eyl); 17, 2.350 ve 30,2 (4 Eki'ye kadar). Gösterim ~3 katına çıktı; konum, daha çok sayfa daha geride gösterildiği için düştü. | Ürün A, Search Console |
| Ana sorgu ailesi | 90 günde 4–8. sırada ~170 gösterim, 0 tık. 5 Eki'de üç sorgusunun ortalama konumu 5,1, 6,4 ve 7,8; yine 0 tık. | Ürün A, Search Console |
| Doğrulanmış insan ziyareti | Google'dan günde 0,85 (18–30 Eyl, çoğu marka araması), 30 Eyl–6 Eki'de 0,31. 1–7 Eki'de Türkiye ev ve mobil ağlarından ~42 sayfa görüntüleme; aynı ağlardan gelen isteklerin %95'i mobil uygulamanın API'sine. | Ürün A, istek logu |
| Katalog dizini | Dizinde 29 Ağu 48, 20 Eyl 147, 28 Eyl 148 sayfa; sitemap'te 18.084. Üç ayda 26 tık, 457 gösterim, ortalama konum 9. | Ürün B, Search Console |
| Ürün C sitesi | Şubat-Ekim 16 tık, 675 gösterim. Marka sorgusunda Google ortalaması 34,7, Bing'de 1. sıra. 75 dış bağlantı ~5 alan adından; 64'ü uygulama mağazasından. | Ürün C, Search Console ve Bing |

## Cevap botları kime geldi

1–7 Ekim 2026, Ürün B'de 4–7 Ekim (3 gün); ham istek, yalnız OpenAI'ın yayımladığı aralıktan. Arama botu Ürün D'de yalnız robots.txt'yi okudu. Kullanıcı adına sayfa açma yalnız tarihli rakam sayfası olan üründe anlamlı; bu bir ilişki, kanıt değil.

OAI-SearchBot, arama için taramaChatGPT-User, kullanıcı adına sayfa açmaistek; ölçek gerçek
_Grafik: OAI-SearchBot ve ChatGPT-User istekleri, 1-7 Ekim 2026: Ürün A (6 gün, tarihli veri sayfaları) OAI-SearchBot 130, ChatGPT-User 150; Ürün B (3 gün, ~18 bin sayfalık katalog) OAI-SearchBot 19, ChatGPT-User 0; Ürün C (6 gün, içerik sitesi) OAI-SearchBot 39 gerçek, 66 iddia, ChatGPT-User 2 gerçek, 35 iddia; Ürün D (6 gün, küçük içerik sitesi) OAI-SearchBot 7, yalnız robots.txt, ChatGPT-User 0_

## Şaşırtanlar

### AI trafiğini doğru saymak

[ölçüldü]
Ürün A'da ChatGPT ziyaretini iki kez saydık; ikinci sayımda derin oturumlar prefetch, bir ziyaretçi bot çıktı.

**İlk sayım, 30 Eylül:** 15 gün sanılan pencerede ChatGPT'den 9 giriş, 7'si veri sayfasına; ziyaretçiler 12–24 sayfa geziyor görünüyordu. 'google.com'dan gelen ~120 girişin ~105'i bulut kazıyıcısı olarak bu sayımda ayrıldı.

**Düzeltilmiş sayım, 6 Ekim:** 12–24 sayfa Next.js'in bağlantı prefetch'iydi; hiçbir ChatGPT ziyaretçisi ikinci sayfaya geçmedi. Bir AWS adresi aynı ChatGPT linkini 1–2 günde bir açan bir bottu. Sonraki 6,5 günde 1 gerçek tık. Log 11,7 gündü.

**Bundan sonra sayım sırası:** 1. Kendi adreslerimiz ve test ajanları çıkarılır. Ürün A'da 1–7 Eki'deki 564 sahte Googlebot isteği bizim testimizdi.

2. Bot adı yayıncının IP dosyasıyla doğrulanır. Ürün C'de ChatGPT-User iddialarının 35'inden 2'si gerçekti.

3. Yalnız belge istekleri sayılır; `_rsc`, prefetch ve asset istekleri ayrılır.

4. ChatGPT linkleri `utm_source=chatgpt.com` taşır; site içindeki sonraki sayfa bunu referer'da taşır.

5. Referer tek başına insan sayılmaz. İnsan kanıtı: asset ve JS isteği, ev ya da mobil ağ.

6. Bulut adresleri ayrılır; pencerenin gerçek başlangıcı logdan okunur.

### IndexNow 'aldım' dedi, Bing gelmedi

[ölçüldü]
Ürün A, 18 Eyl–7 Eki
~2.900 adres gönderildi; Bing 7 Eki'de ana sayfayı hâlâ taramamıştı. Bağlantısı olan, Şubat'tan beri yayındaki Ürün C Bing'de marka sorgusunda 1.

**Ders** IndexNow keşfi hızlandırır, otoritenin yerini tutmaz. Bu bizim yorumumuz.

### llms.txt'yi neredeyse kimse okumadı

[ölçüldü]
Ürün A, 18 Eyl–6 Eki
~11,7 günde tek istek, sonraki 6,5 günde sıfır. Okunan, sunucuda çizilmiş sayfaların kendisiydi. Eski sitede /llms.txt 200 dönüyordu ama içeriği HTML kabuğuydu.

**Ders** llms.txt bir kez üretilir ve unutulur; emek sayfa metnine gider.

### 'Keşfedildi' 8.000'den 0'a indi, iyi haber değildi

[ölçüldü]
Ürün B, 20 Eyl–3 Eki
Sitemap indekse geçtiği gün Google parçaları okumayı bıraktı; iki hafta 'Başarılı, 0 sayfa keşfedildi' göründü. Parçalar sıkıştırmasız 10 MB'a kadar çıkıyordu.

**Ders** Sebebi bulunmayan düzelme iyileşme sayılmaz; her sitemap parçası ayrı ayrı 'Başarılı' görülür.

### Google bir sayfamız için ilgisiz bir bahis sitesini standart seçti

[ölçüldü]
Ürün A, 21–25 Eyl
Canlı sayfa doğru canonical veriyordu; tarandığı anda 'bildirilen canonical: hiçbiri' görünüyordu. Yeniden dizin isteğinden sonra düzeldi.

**Ders** Canonical bir işarettir; önemli sayfalarda URL denetimindeki 'Google'ın seçtiği standart' satırı okunur.

### SEO sayfaları fatura yazdı

[ölçüldü]
Ürün C 5–6 Eki, Ürün B 23 Eyl
Ürün C'de kategori sayfaları, sitemap ve llms.txt listeyi 5 dakikada bir veritabanından okudu; 6 Eki'de 15:30'a kadar 51 uyanmanın 44'ü bu uçtandı (günde ~74 uyanma), sürseydi ayda ~₺190 fazla; bir günde kapandı. Ürün B'de adı belli tarayıcılar veritabanına bir gün boyunca 5 dakikalık boşluk bırakmadı.

**Ders** Herkese açık SEO sayfası bellekten okur; yeni bir SEO yüzeyinden sonra 48 saat uyanmalar izlenir.

### Bir site hiç SEO temeli olmadan yayında kaldı

[ölçüldü]
Ürün D, 1–7 Eki
Sitemap yok, www ve çıplak alan adı yönlendirmesiz aynı içeriği veriyor, sayfalar /null adresine link üretiyor; robots.txt ancak 2 Eki'de geldi. Doğrulanmış insan ziyareti yok.

**Ders** Küçük sitede de gün 0 listesi yarım günlük iştir (tahmin); sonradan dönmek Ürün C'de yedi ay sürdü.

## Kurallar

Üç grup. Etiket kuralın bizdeki kanıtını gösterir; gri metin nedenidir.

### Gün 0 teknik SEO 9 kural

Çok dil, slug değişimi ve 404 ile 5xx ayrımı [Kullanıcıyı kırmadan değiştirmek](#kirmama) 3.1–3.8'de.

1. [kanıtlı]
**Herkese açık her sayfa sunucuda tam HTML çıkar (SSR ya da ISR)**; JavaScript'siz curl ile gövde metni okunur. Google da bazı botların JavaScript çalıştırmadığını yazıyor. Ayrıntı [Next.js web](#katman-3) bölümünde.

2. [kanıtlı]
**www tek adımda 308 ile çıplak https adrese gider**; her sayfa kendi canonical'ını istek anında verir. Site geneli tek canonical olmaz. Ürün B'de www 233 kez alternatif sayfa olarak tarandı; Ürün C'de her sayfa ana sayfayı canonical gösteriyordu. http'den https'e yönlendirmeyi bizde barındırma katmanı 302 ile yapıyor ve koddan değişmiyor; canonical, sitemap ve HSTS https olduğu için bırakıldı.

3. [kanıtlı]
**Sitemap istek anında üretilir**; lastmod yalnız gerçek tarihtir, bilinmiyorsa yazılmaz. Büyük katalog indeks ve gzip'li parçalar kullanır. Google lastmod'u yalnız tutarlıysa kullanır, changefreq ve priority'yi yok sayar. Ürün B'de sitemap indeksi, altı parçası, ana sayfa ve 621 zincir sayfası her okumada 'az önce değişti' diyordu.

4. [kanıtlı]
**robots.txt kapının ad listesinden üretilir**. Dil önekleri joker ile yazılır; noindex taşıyan sayfa Disallow edilmez; /_next/ engellenmez; test kopyası her şeyi Disallow eder. Ürün B'de noindex'i okunamayan sayfa dizinde kaldı; Ürün C'de /_next/ engeli vardı.

5. [kanıtlı]
**Yapısal veri canlı sayfada Rich Results Test ile denenir**. @id ve sameAs ile bağlı Organization ve WebSite, görünür breadcrumb ile aynı BreadcrumbList, veri sayfasında Dataset; aynı varlık iki kez tanımlanmaz. Ürün A'da 29 Eyl'de 46 geçerli breadcrumb, hata yok. Ürün B'de puanın içinde ikinci, eksik bir işletme tanımlanmıştı.

6. [ölçüldü]
**Sayfa hızı yayından önce ölçülür**; yerel font, WebP ve boyutu yazılı görsel, küçük LCP görseli. Ürün C'de tek bir 2 MB PNG mobil LCP'yi 7,3 sn yaptı; Ürün A'da görseller 8,9 MB'tan 1,1 MB'a indi. Ayrıntı [Performans](#performans) bölümünde.

7. [ölçüldü]
**Başlık sayfanın yaptığını söyler**; bir sorgu ailesinin tek sahibi sayfası ve tek alan adı vardır. Ürün A'da 4–8. sırada 0 tık; iki alan adı aynı sorgu ailesinde yarıştı.

8. [ölçüldü]
**Yeni sayfa en az bir ilgili sayfadan adıyla bağlanır**; liste sayfası tek bağlantı kaynağı olmaz. Tek iç bağlantılı kurum sayfaları 'keşfedildi, dizine eklenmedi'de bekledi.

9. [öneri]
**Şablondan çoğaltılmış ince sayfa açılmaz**; her sayfa kendi sayısal örneği ve ayırt edici olgularıyla çıkar. Ürün A'nın ~215 kelimelik yedi benzer sayfası 22 Eyl'de dizin dışındaydı; elle istekten sonra 3 Eki'de biri dışında hepsi dizindeydi, incelik ile dizin arasındaki bağ ölçülmedi. Ürün B'nin metinsiz mağaza sayfalarından ~18 binde 148'i dizinde.

### GEO 9 kural

1. [kanıtlı]
**Ziyaretçi getiren cevap botları açık kalır (OAI-SearchBot, ChatGPT-User, PerplexityBot, Perplexity-User, Claude-SearchBot, Claude-User); eğitim botları ürün kararıdır ve robots.txt'ye yazılır**. OpenAI, OAI-SearchBot'u kapatan sitenin ChatGPT arama cevaplarında gösterilmeyeceğini yazıyor. Ayrıntı [Botlara karşı tutum](#botlar) bölümünde.

2. [kanıtlı]
**Bot kimliği yayıncının IP dosyasıyla doğrulanır**; dosyalar ayda bir yeniden okunur. Ürün C'de ChatGPT-User iddialarının 35'inden 2'si gerçekti.

3. [öneri]
**Aylık yenileme her yayıncının güncel listesini kapsar**; yeni bir cevap botu açılınca onun listesi de eklenir. Yayıncılar listelerini değiştiriyor. Ayrıntı [Botlara karşı tutum](#botlar) bölümünde.

4. [ölçüldü]
**Cevap motorları için tarihli, kaynaklı, rakamlı veri sayfası açılır**. Kaynak ve okuma tarihi görünür metinde durur, yöntem bir sayfada anlatılır. ChatGPT-User 1–7 Ekim'de yalnız bu tip sayfası olan üründe anlamlı sayıda geldi (Ürün A'da 6 günde 150, katalogda 3 günde 0); bu bir ilişki, kanıt değil.

5. [öneri]
**Her önemli sayfa bir tanım cümlesiyle başlar**; soru-cevap bölümleri Search Console'daki gerçek sorgulardan yazılır. Cevap motorları bir paragrafı alıntılar; tanımsız sayfa alıntılanacak cümle vermez.

6. [öneri]
**İkinci dil varsa eksiksiz tutulur**. Ürün A'da AI özelliklerinde en çok gösterim alan sayfalar İngilizceydi (mevzuat, veri ve ürün sayfaları).

7. [ölçüldü]
**llms.txt sitemap'ten üretilir, rakam ve tarih taşır, bir kez kurulur**; okunduğu logdan ölçülür. ~18 günde tek okuma; hiçbir motor okumayı taahhüt etmiyor.

8. [öneri]
**Marka tek biçimde yazılır**; sameAs, yazım varyantları için alternateName, mağaza sayfasından siteye bağlantı ve Wikidata kaydı. Ürün C'nin marka sorgusunu uygulama mağazası sayfası kazandı; Ürün A'nın pazar yeri markasının bir yazım varyantı 90 günde 0 gösterim aldı.

9. [ölçüldü]
**GEO için açılan veri sayfası ISR ile ucuz sunulur ve kapının arkasındadır**; aynı verinin JSON ucu da aynı korumayı alır. Ürün A'nın veri sayfası 2–6 Eki'de dönen proxy adresleriyle 63 kez çekildi. Ayrıntı [Botlara karşı tutum](#botlar) bölümünde.

### Ölçüm 6 kural

1. [kanıtlı]
**Sitemap her deploy'dan sonra gönderilir**; keşfedilen sayı curl ile sayılan adres sayısına eşit olmalı. IndexNow'un doğrulaması build logundaki 'IndexNow: N urls -> 200' satırıdır. Sayılar birkaç kez saptı (116'ya karşı 120); Bing'in IndexNow sayfası işe yarar veri göstermiyordu.

2. [kanıtlı]
**Gün 0'da taban kaydı tutulur**: dizin, 28 günlük tık ve gösterim, AI raporu, bot sayıları, dış bağlantı. Her değişiklikten 2–4 hafta sonra aynı sayım tekrarlanır. 'İşe yaradı mı' sorusunu Ürün A ve C'de cevaplatan tek şey taban kaydıydı.

3. [ölçüldü]
**AI trafiği logdan, yukarıdaki sırayla sayılır**. İlk sayım prefetch'i oturum, bir botu ChatGPT ziyaretçisi saydı. Ayrıntı [Analitik ve admin](#analitik) bölümünde.

4. [ölçüldü]
**Karar rapordan değil URL denetiminden verilir**. Elle dizin isteği günde ~10'dur ve kayan 24 saatte açılır; istemeden önce denetlenir. Ürün A'nın sayfa raporu 21 Eyl verisinde iki hafta dondu; 'keşfedildi' listesindeki sayfaların çoğu zaten dizindeydi.

5. [öneri]
**Google'ın AI özellikleri trafiği genel Web performans raporunda sayılır**; panelde ayrı bir sayfa raporu varsa ikisi birlikte okunur. Google belgesi AI trafiğini Web raporunda saydığını yazıyor; Ürün A'nın panelinde ayrıca yalnız sayfa kırılımı veren bir rapor gördük.

6. [öneri]
**Aynı anda tek değişken**; ayrılamıyorsa sonuç ortak yazılır. Ürün A'da 2'den 136'ya çıkış dört işin toplamıydı.

## Hiç bitmeyen işler

Ürün A'da 18 Eylül'den beri iki günde bir Search Console ve Bing okuması, Ürün B'de haftada bir sağlık betiği zamanlanmış görev olarak çalışıyor. Betiğin ilk çalışması sitemap'te 2.668 eksik sayfa ve iki 404 buldu. Süreler ölçülmedi.

| Ne zaman | İş | Kim, ne kadar | Harekete geçiren işaret |
|---|---|---|---|
| Her deploy'dan sonra [kanıtlı] | Sitemap sayısı curl ile, IndexNow satırı build logunda, değişen sayfada canonical; yeni sayfaya URL denetimi. | Deploy'u yapan; 10–20 dk (tahmin) | Yeni adres, değişen başlık ya da veri, sitemap sayısında fark. |
| İlk ay iki günde bir, sonra haftada bir [kanıtlı] | Search Console ve Bing: dizin dışı nedenler, sitemap durumu, geliştirme hataları, 28 günlük sorgular, dizin istekleri. | Zamanlanmış ajan görevi; süre ölçülmedi | Dizin dışı bir neden büyür; sitemap sayısı curl'den farklı; ilk 10'da 0 tık; 404 ya da 5xx; Google farklı standart seçer. |
| Haftada bir [kanıtlı] | Teknik sağlık betiği: robots, sitemap sayıları, yapısal veri, iç bağlantı, örnek sayfalarda 200. | Zamanlanmış görev; birkaç dakika (tahmin) | Bir kontrol düşer ya da bir sayı haftaya göre %5'ten fazla oynar. |
| 2–4 haftada bir, her değişiklikten sonra [ölçüldü] | AI trafiği sayımı: doğrulanmış cevap botları sayfa başına, ChatGPT'den gelen belge istekleri, llms.txt, AI raporu. | Geliştirici ya da ajan; elle ~yarım gün (tahmin) | Cevap botları tabanın yarısına iner; kapıda bir AI botu reddedilir. |
| Verinin değiştiği sıklıkta [kanıtlı] | Tarihli içerik: veri okuması, başlıktaki rakam ve ay, okuma tarihi, lastmod ve llms.txt tek kaynaktan. | Zamanlanmış iş; kurulumu 1–2 gün (tahmin) | Okuma tarihi eski (haftalık veride 8 gün) ya da rakam önceki okumadan çok saptı. |
| Ayda bir [öneri] | AI alıntı yoklaması: sabit 10–20 soru ChatGPT, Perplexity, Google AI Mode ve Copilot'ta. | Ürün sahibi ya da ajan; ~1 saat (tahmin) | Alıntılanan sayfa düşer ya da rakamımız eski verilir. |
| Ayda bir [kanıtlı] | Tarayıcı IP listelerini yayıncı dosyalarından yenilemek; ad listesi haftada bir. | Betik; ~30 dk (tahmin) | Kapı 45 günden eski veri uyarısı yazar; tarama istatistiğinde 429 ya da 5xx artar. |
| Üç ayda bir [ölçüldü] | İçerik gözden geçirme: ince ve benzer sayfalar, başlık ile sayfanın işi, gerçek sorgulardan soru-cevap. | Ürün sahibi ve geliştirici; sayfa başına 1–2 saat (tahmin) | Bir sayfa tipi 'tarandı, dizine eklenmedi'de toplanır. |
| Sürekli, ölçümü ayda bir [öneri] | Bağlantı ve marka işi: tanıtım, veri alıntısı, dizin sayfaları, mağaza sayfasından bağlantı, Wikidata. | Ürün sahibi; haftada 2–3 saat (tahmin) | Yönlendiren alan adı sayısı bir ay artmadı. |
| Yeni SEO yüzeyinden sonra [ölçüldü] | 48 saat boyunca veritabanı uyanma sayısı ve CU-saat. | Geliştirici; ~15 dk (tahmin) | Uyanmaların çoğu tek bir herkese açık uçtan geliyor. |

## Daha iyi ne yapılabilir

Öncelik sırasıyla. Bizde gün 0'da yapılmadığı için hepsi öneri; beklenen etkiler ve süreler tahmin.

### 1. Gün 0'da sunucuda tam HTML ve tek kanonik host

[öneri]
**Bizde:** Ürün A 18 Eyl'e, Ürün C 27 Eyl'e kadar istemcide çiziliyordu; Ürün B'de www 3 Eki'ye kadar ayrı host'tu.

**Beklenen etki:** AI botları içeriği ilk günden görür; Ürün A'da geçişten sonra OAI-SearchBot ~11,7 günde 116 sayfa taradı.

**Emek ve maliyet:** Next.js'te varsayılan, kontrolü yarım gün (tahmin), ₺0. Sonradan taşıma ~20 dk HTTPS kesintisi getirdi.

**Nasıl ölçülür:** curl ile gövde metni; Search Console'da 'alternatif sayfa' ve 'kopya' satırları 0.

### 2. Ölçüm hattını kod olarak kur

[öneri]
**Bizde:** Elle ve arayüzden saydık (30 Eyl, 6 Eki); ilk sayım prefetch'i oturum saydı.

**Beklenen etki:** Haftalık bir iş Search Console API'den ve istek logundan tek JSON yazar; önce-sonra rakamı birikir.

**Emek ve maliyet:** 1–2 gün (tahmin), ₺0; URL Inspection API site başına günde 2.000 sorgu. Dizin isteğinin API'si yok.

**Nasıl ölçülür:** Aynı pencere iki kez çalışınca aynı sonuç.

### 3. Bağlantı planını gün 0'da başlat

[öneri]
**Bizde:** Ürün A'nın 30 Eyl'de 2 dış bağlantısı vardı; Bing ilk 11,7 günde 7 sayfa çekti, içerik sayfalarını ilk kez 18 gün sonra (6 Eki) çizdi.

**Beklenen etki:** Bing daha çok tarar, ikinci ve üçüncü sayfadaki sorgular yükselir. Tahmin, kanıt yok.

**Emek ve maliyet:** Ürün sahibinin haftada 2–3 saati (tahmin); ₺0, ücretli bağlantı alınmaz.

**Nasıl ölçülür:** Yönlendiren alan adı sayısı aylık; Bing'de taranan sayfa.

### 4. Tarihli veri sayfası, yöntem sayfası ve Dataset ilk sürümde

[öneri]
**Bizde:** Veri sayfası 19 Eyl'de; tarihli başlık, yöntem sayfası ve Dataset 6 Eki'de geldi.

**Beklenen etki:** Kullanıcı adına sayfa açma böyle sayfası olan üründe gelir (tahmin); Ürün A'da ChatGPT-User 6 günde 150, katalogda 0.

**Emek ve maliyet:** Veri varsa 1–2 gün (tahmin); Ürün A'nın haftalık okuması bir dil modeliyle ayda ~$0,5.

**Nasıl ölçülür:** Sayfa başına doğrulanmış OAI-SearchBot ve ChatGPT-User; AI raporu gösterimleri.

### 5. Başlığı ve sorgu sahipliğini yayından önce yaz

[öneri]
**Bizde:** Başlık 'hesaplama' derken sayfa hesaplamıyordu; iki alan adı aynı sorguda yarıştı. İkisi 6 Eki'de değiştirildi; etkisi henüz ölçülmedi.

**Beklenen etki:** İlk sayfadaki gösterim tık getirir (tahmin).

**Emek ve maliyet:** Sayfa başına 1–2 saat yazı işi (tahmin), ₺0.

**Nasıl ölçülür:** Konumu 10'dan iyi olup 0 tık alan sorgu sayısı.

### 6. SEO yüzeyinin maliyetini baştan sınırla

[öneri]
**Bizde:** Ürün C'de kategori sayfaları ayda ~₺190 ekledi, 6 Eki'de düzeldi; Ürün B'de veritabanı 24 saat uyanıktı.

**Beklenen etki:** Veritabanı uyuyabilir; SEO büyüdükçe fatura büyümez.

**Emek ve maliyet:** Yarım gün (tahmin); ölçülen örnekte tasarruf ayda ~₺190.

**Nasıl ölçülür:** Yeni yüzeyden sonra 48 saat veritabanı uyanmaları ve CU-saat.

## Gün 0 listesi

Yeni bir sitede ilk herkese açık sayfa yayımlanmadan önce. Küçük bir sitede yarım günlük iş (tahmin).

- [ ] Search Console'da alan adı mülkü DNS TXT ile açıldı (kayıt silinmez); Bing Webmaster Tools içe aktarıldı.

- [ ] Her sayfa tipi JavaScript'siz curl ile okundu; gövdede metin var, başlık ve açıklama sayfaya özel.

- [ ] www tek adımda çıplak https adrese 308; http https'e gidiyor; her sayfa kendi canonical'ını veriyor.

- [ ] Sitemap istek anında üretiliyor, lastmod gerçek, büyükse gzip'li parçalar; gönderildi ve sayısı curl ile eşit.

- [ ] robots.txt kapının listesinden üretiliyor; noindex sayfaları Disallow değil; test kopyası Disallow ve noindex.

- [ ] Portal, panel ve paylaşım linkleri X-Robots-Tag noindex.

- [ ] Organization (sameAs ile), WebSite ve BreadcrumbList canlıda Rich Results Test'ten geçti.

- [ ] Her sayfanın kendi OG kartı var; WhatsApp ve X önizlemesi denendi.

- [ ] Çok dil varsa her dilin adresi, hreflang ve x-default; kök yönlendirmesi 307 ve Vary.

- [ ] Eski ya da değişecek adresler için 308 tablosu; bilinmeyen adres 404, arka uç hatası 5xx.

- [ ] Mobil PageSpeed ölçüldü; LCP görseli küçük, yerel font.

- [ ] Cevap botları açık, eğitim botları için karar robots.txt'ye yazıldı; IndexNow anahtarı yayında.

- [ ] llms.txt sitemap'ten üretiliyor (rakam ve tarihle); üstüne ayrı emek harcanmıyor.

- [ ] Taban kaydı alındı (dizin, tık, gösterim, bot sayıları, dış bağlantı); 2–4 hafta sonraki sayım takvimde.

## Tuzaklar

**Bilinmeyen yolu uygulama kabuğuna düşüren sunucu.** robots.txt, sitemap ve llms.txt ya kendisi ya 404 döner; içerik türü denetlenir.

**Her istekte 'şimdi' diyen lastmod.** Gerçek değişim tarihi ya da hiç.

**Arka uç düşünce boş sitemap.** İstek anında üret, hata fırlat, son iyi kopya kalsın.

**Aynı sayfaya Disallow ve noindex; robots'ta unutulan dil önekleri.** Dizinden çıkacak sayfa taranır ve noindex taşır; joker satırlar.

**Prefetch'i ve sahte referer'ı ziyaret saymak.** Yalnız belge isteği; insan kanıtı ve ağ ayıklaması.

**Bot adına güvenmek.** Yayıncı dosyasıyla doğrula; aylık yenileme yayımlanan her listeyi kapsasın.

**Veritabanını uyandıran SEO yüzeyi.** Herkese açık okumalar bellekten; okur getirmeyen tarayıcılar robots ve kapıyla dışarıda.

**Elle dizin isteği kotasını rastgele harcamak.** Önce URL denetimi; asıl yol sitemap ve IndexNow.

### Ölçülmeyenler

8 Ekim 2026 itibarıyla ölçülmeyen ya da ayrılamayan etkiler.

6 Eki 2026 değişikliklerinin etkisi (tahmin kutusu, tarihli başlıklar, yöntem sayfası, Dataset, alan adları arası canonical); veri 2–4 hafta sonra gelecek.

Perplexity, Claude, Copilot ve Gemini'den gelen ziyaretler; yalnız ChatGPT'nin işareti sayıldı.

Hangi cevapta hangi cümlemizin alıntılandığı; sabit sorularla yoklama yapılmadı.

llms.txt'nin alıntıya etkisi; okunma sayısı ölçüldü, etkisi ayrılamaz.

Eğitim tarayıcılarını (GPTBot, CCBot) açık tutmanın bir getirisi olup olmadığı.

Yapısal verinin tık oranına etkisi; Core Web Vitals saha verisi (Ürün A ve C'de trafik yetersiz).

Ürün B ve D'nin dış bağlantıları, Ürün D'nin Search Console verisi, Ürün B ve C'nin Bing performansı.

Ürün B'de 3 Eki gzip düzeltmesinden sonra sitemap parçalarının okunup dizinin artıp artmadığı.

OAI-SearchBot taramasının ChatGPT aramasında gösterime dönüşme oranı; OpenAI'ın bir konsolu yok.

## Resmi kaynaklar

8 Ekim 2026'da okundu (Bing Webmaster Guidelines'ın metni alınamadı). Bu bölüme özel; genel kaynak listesinde yok.

**Google: AI features and your website**https://developers.google.com/search/docs/appearance/ai-features
**Google: Build and submit a sitemap**https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap
**Google: Block indexing with noindex**https://developers.google.com/search/docs/crawling-indexing/block-indexing
**Google: JavaScript SEO basics**https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics
**Google: Consolidate duplicate URLs**https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
**Google: Verifying Googlebot and other crawlers**https://developers.google.com/search/docs/crawling-indexing/verifying-googlebot
**Google: Search Console API usage limits**https://developers.google.com/webmaster-tools/limits
**Bing: Sitemaps in AI powered search**https://blogs.bing.com/webmaster/July-2025/Keeping-Content-Discoverable-with-Sitemaps-in-AI-Powered-Search
**Bing Webmaster Guidelines**https://www.bing.com/webmasters/help/webmaster-guidelines-30fba23a
**IndexNow documentation**https://www.indexnow.org/documentation
**OpenAI: Overview of OpenAI crawlers**https://developers.openai.com/api/docs/bots
**Perplexity: Perplexity Crawlers**https://docs.perplexity.ai/guides/bots
**Anthropic: crawler and how to block it**https://support.claude.com/en/articles/8896518-does-anthropic-crawl-data-from-the-web-and-how-can-site-owners-block-the-crawler
**Common Crawl: CCBot**https://commoncrawl.org/ccbot
**llmstxt.org: The /llms.txt file**https://llmstxt.org/

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
** Fatura proje ve SKU bazında okunur**; ay başı rakamı yanıltır.
[kanıtlı]
** Ücretli API'de alanlar tek geçişte istenir**; cevaplar önbelleklenir, GCP'de API başına kota tavanı.
[ölçüldü]
** Model işleri kaynakta kısılır**: değişmeyen sayfa gönderilmez, günlük tavan, prompt önbelleği.
[öneri]
** Cloud Run çıkış trafiği izlenir**; bot baytı Cloudflare önbelleğiyle düşer.

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

<a id="krediler"></a>

Startup kredileri

# Nereye, ne zaman başvurulur

Kredi programları yeni bir ürünün ilk 6–24 ayında bulut, veritabanı ve model faturasını sıfıra yakın tutabilir. Süre çoğu programda onay ya da claim günü başlar ve kalan kredi süre bitince yanar; asıl soru nereye ve ne zaman başvurulacağı.

Bilgiler 8 Ekim 2026'da resmi program sayfalarından doğrulandı; doğrulanamayanlar bölümün sonundaki [Doğrulanamayanlar](#kr-dogrulanamayan) kutusunda. Sıra bizim boyutumuzdaki bir ürün için yazıldı: kendi parasıyla dönen, Türkiye'de, küçük bir ekip.

**Bizim durumumuz:** $1.000
Claude API kredisi 5 Nisan 2027'ye kadar
1 yıl
Claude Team ücretsiz
Ürün A 7 Ekim 2026'da Claude for Startups'a kabul edildi: 6 ay geçerli $1.000 Claude API kredisi ve bir yıl ücretsiz Claude Team.

Başka bir programa henüz başvurulmadı. Sıradaki başvuru Neon'un programı, çünkü faturanın en büyük kalemi Neon.

## Önce

Ürün canlıya çıkarken, ağır kullanım başlamadan.

### Claude for Startups (Anthropic)

https://claude.com/programs/startups
Bizde: alındı, 7 Ekim 2026.

**Ne verir:** Tek seferlik $1.000 Claude API kredisi, 6 ay geçerli, ve daha yüksek API hız sınırı. Team'e yeni gelen organizasyona 5 koltuğa kadar 1 yıl ücretsiz Claude Team. Ortak ağdaki bir VC'nin desteklediği girişime o VC üzerinden en fazla $100.000 ek kredi.

**Kimler alır:** Son 5 yılda kurulmuş ya da son 2 yılda yatırım almış girişim; VC şartı yok. Claude Console hesabı ve siteyle aynı alan adında bir şirket e-postası gerekir.

**Bizde neyi öder:** Yalnız Claude API ve claude.ai koltukları. Cloud Run, Neon ve öteki kalemlere dokunmaz.

**Dikkat:** Süre bizde claim günü başladı; 6 ay dolunca kalan kredi yanar. Auto-reload kapalı kalır, yoksa bakiye karttan dolar. Kredinin büyüklüğü, bitince ödenemeyecek ağır modellere geçmenin gerekçesi olmamalı.

### Neon (Databricks Startup Program)

https://neon.com/startups
Bizde: sıradaki başvuru.

**Ne verir:** Kendi parasıyla dönen girişime en fazla $1.000 Neon kredisi, onboarding desteği ve yeni özelliklere erken erişim. VC destekli girişime Neon ve Databricks için toplam en fazla $200.000. Kredi kabulden itibaren 12 ay geçerli.

**Kimler alır:** Kendi parasıyla dönen kolda toplam yatırım $1 milyonun altında, ürün erken aşamada ya da MVP'de. VC kolu en az $1 milyon yatırım ya da tanınmış bir hızlandırıcı ister. Mevcut Neon kullanıcısı da başvurabilir; kredi var olan hesaba eklenir.

**Bizde neyi öder:** En büyük kalem olan Postgres compute ve depolama. Ürün A'nın Neon kalemi ayda ~₺500, 12 ayda ~₺6.000 (~$120) eder; $1.000 bunu rahatça karşılar.

**Dikkat:** 12 ay dolunca ya da kredi bitince seçili planda normal fatura başlar. Sayfa kredinin hangi projelere uygulanacağını söylemiyor; organizasyonda başka ürünlerin projeleri varsa krediyi onlar da harcar.

### Google for Startups Cloud Program

https://cloud.google.com/startup
Bizde: Ürün A yaş sınırı yüzünden uymuyor; yeni bir ürün için ilk başvurulardan biri.

**Ne verir:** Start: $2.000 Google Cloud kredisi (12 ay) ve 12 ay ücretsiz Workspace Business Plus. Scale: 2 yılda en fazla $200.000. AI-first girişime Scale'de 2 yılda en fazla $350.000.

**Kimler alır:** Start: çalışan bir MVP, son 24 ayda kurulmuş olmak, ücretsiz deneme dışında GCP kredisi almamış olmak ve yakında VC yatırımı arama planı. Scale: kurumsal yatırımcı ya da VC'den pre-seed ile Seri A arası yatırım.

**Bizde neyi öder:** Cloud Run, Cloud Build, Artifact Registry, Secret Manager, Scheduler, Logging ve Google'ın modelleri. Neon'u ödemez, çünkü Marketplace dahil üçüncü taraf hizmetler kapsam dışı; Vertex'te çağrılan Claude da krediden düşmez.

**Dikkat:** Kredi seçilen billing hesabına yatar, o hesaba bağlı her proje harcayabilir. Start 12 ayda biter, sonra dosyadaki karttan fatura başlar. Başvurudaki e-posta, site ve billing hesabının e-postası aynı alan adında olmalı.

## Sonra

O aracı gerçekten kurarken, şartlar hâlâ tutuyorsa.

### Sentry for Startups

https://sentry.io/for/startups/
**Ne verir:** 12 ay geçerli, en fazla $5.000 Sentry kredisi.

**Kimler alır:** Son 2 yılda kurulmuş, $5 milyonun altında VC yatırımı almış ve Sentry'ye hiç ödeme yapmamış girişim. Önce ücretsiz bir Sentry hesabı açılır.

**Bizde neyi öder:** Hata ve performans izleme. Bizde hatalar Cloud Logging, uptime kontrolü ve 5xx alarmıyla izleniyor; Sentry KVKK adımlarından sonra.

**Dikkat:** 2 yıllık pencere dar. 12 ay sonra ne olduğu sayfada yazmıyor. Çökme verisi KVKK adımlarından sonra gönderilir.

### GitHub for Startups

https://github.com/enterprise/startups
**Ne verir:** Onaydan itibaren 12 aya kadar geçerli $10.000 GitHub kredisi: Enterprise, Copilot, Advanced Security ve Actions.

**Kimler alır:** Onaylı bir GitHub for Startups partnerine bağlı ve Seri B'ye kadar dış yatırım almış girişim. Partner bir yatırımcı, kuluçka merkezi ya da hızlandırıcı olabilir.

**Bizde neyi öder:** Kod barındırma, CI ve Copilot. Bizim build'lerimiz Cloud Build'de.

**Dikkat:** Onboarding'den birkaç hafta sonra karttan yetkilendirme çekimi yapılır; kredi bitince ürünler karttan faturalanır. Süre dolmadan plan düşürülürse kalan kredi yanar.

## Gerekirse

O platformda gerçek bir iş yükü ya da yatırım olunca.

### AWS Activate (Founders ve Portfolio)

https://aws.amazon.com/startups/credits
**Ne verir:** Founders: $1.000 Activate kredisi, seçilenlere en fazla $5.000. Portfolio: bir Activate Provider'ın (hızlandırıcı, melek yatırımcı ya da VC) Org ID'siyle en fazla $200.000.

**Kimler alır:** Pre-Seri B ve son 10 yılda kurulmuş girişim. AWS hesabı Paid Tier planında olmalı; site ya da herkese açık profil başvurudaki şirket adını göstermeli.

**Bizde neyi öder:** AWS'de değiliz. Anlamlı tek kullanım Amazon Bedrock: Claude'u Bedrock üzerinden çağırırsak LLM kalemini öder. Claude kredisi varken gerek yok.

**Dikkat:** Paid plan şartı yüzünden kart baştan tanımlı, kredi bitince fatura sessizce başlar. Bitiş tarihi yalnız Billing konsolunda görünür. Bedrock ikinci bir sağlayıcı entegrasyonu ve ikinci bir fatura demek.

### Microsoft for Startups (Azure)

https://learn.microsoft.com/en-us/startups/microsoft-for-startups/overview
**Ne verir:** Resmi sayfalar tutarı farklı anlatıyor. SSS'ye göre yatırımcısız ve Azure'a yeni gelen girişim 90 gün geçerli $1.000 ile başlar, iş doğrulamasından sonra 180 gün geçerli ek $4.000 alır. Başvuru sayfası onaydan sonra en fazla $150.000 diyor.

**Kimler alır:** Kayıtlı şirket adı ve adresi resmi belgelerle aynı olan, özel ve kâr amaçlı, Seri C öncesi bir yazılım girişimi. Kayıt, daha önce Azure açılmamış kişisel bir Microsoft hesabıyla yapılır.

**Bizde neyi öder:** Azure kullanmıyoruz. Krediyi kullanmak iş yükünü Azure'a taşımak, yani mimariye kilit demek.

**Dikkat:** Kart zorunlu; kredi bitince kullandıkça öde planına geçilir. Sözleşme kabulünden sonra 90 gün içinde aktive edilmeyen teklif düşer. Kredi başka hesaba taşınmaz.

### Cloudflare for Startups

[cloudflare.com/forstartups](https://www.cloudflare.com/forstartups/)
**Ne verir:** Tier 3: $10.000 (yatırım $1 milyonun altında). Tier 2: $100.000, Tier 1: $350.000 (anlaşmalı bir partnerden yatırım). Krediler 1 yıl ya da bitene kadar geçerli.

**Kimler alır:** En fazla 10 yıl önce tescil edilmiş şirket, aktif bir ürün, doğrulanabilir canlı bir site ve iş e-postası. Program girişim başına bir kez verilir.

**Bizde neyi öder:** Workers, KV, D1, Queues, Pages, R2 ve Workers AI gibi kullanıma dayalı hizmetler. Önbellek ve koruma için kredi gerekmez; temel güvenlik ve ağ özellikleri her tier'da ücretsiz.

**Dikkat:** Erken alınan Tier 3'ün 1 yıllık süresi başlar; sonradan yükseltme bitiş tarihini uzatmaz. Krediler hesaplar arasında taşınmaz.

### PostHog for Startups

https://posthog.com/startups
**Ne verir:** 12 ay geçerli $50.000 PostHog kredisi ve ortaklardan $12.000'ın üzerinde avantaj.

**Kimler alır:** 2 yaşından küçük, toplam yatırımı $5 milyonun altında girişim. Hesap 1 Ocak 2023'ten sonra şirket alan adındaki bir e-postayla açılmış olmalı.

**Bizde neyi öder:** Ürün analitiği, oturum kaydı ve feature flag. Kredi 14 Eylül 2026'dan beri PostHog'un AI araçlarında geçmiyor.

**Dikkat:** Başvurmak için ücretli plana geçmek, yani kart tanımlamak gerekir; 12 ay sonra kullanım bazlı ücret başlar. Kişisel veri ve veri yeri (KVKK) çözülmeden kurulmaz.

### OpenAI for Startups

https://openai.com/startups/
**Ne verir:** Resmi sayfa 8 Ekim'de 403 döndü. İkincil kaynaklara göre API kredisi, hız sınırı artışı ve çözüm mühendisleriyle görüşme.

**Kimler alır:** İkincil kaynaklara göre yalnız OpenAI'ın VC ortak ağındaki fonlardan yatırım alanlar, VC'nin verdiği referans koduyla. Kendi parasıyla dönen girişime açık bir program bulunamadı.

**Bizde neyi öder:** Model (LLM) kalemi.

**Dikkat:** Yatırım olmadan erişim yok gibi görünüyor. Program sayfası 8 Ekim'de 403 döndüğü için şartlar başvurudan önce yeniden okunur.

## Programı olmayanlar

### Expo (EAS)

program yok
Fiyat sayfası girişimlere indirim vermediklerini söylüyor. Free plan ayda 15 iOS ve 15 Android build içerir; kullanılmayan build kredisi sonraki aya devretmez.

https://expo.dev/pricing

### RevenueCat

program yok
Program bulunamadı. Aylık takip edilen gelir $2.500 olana kadar ücretsiz, sonra bu gelirin %1'i; gelir mağaza komisyonu düşülmeden sayılır.

[revenuecat.com/pricing](https://www.revenuecat.com/pricing/)

### Resend

program yok
Program bulunamadı, fiyatlar herkese aynı. Free plan ayda 3.000, günde 100 e-posta; Pro $20/ay'dan başlar. Günlük 100 sınırını giriş kodları ve bildirimler paylaşır.

https://resend.com/pricing

### Türkiye tarafı: TÜBİTAK BİGG ve teknokent

TÜBİTAK 1512 BİGG girişimcilik eğitimi ve rehberlik verir; 2024 tarihli resmi özete göre Aşama 2'de en fazla ₺900.000 ve en fazla 18 ay proje desteği. Başvuran üniversite öğrencisi ya da mezunu olmalı; program şirket kurmayı ve muhasebe yükünü getirir. Bulut faturasını doğrudan ödemez, aboneliklerin gider sayılıp sayılmadığı çağrı metninden okunur.

Teknokentte bölgede yürütülen yazılım ve Ar-Ge kazancına vergi istisnası ve personel teşvikleri var; bu ancak gelir oluşunca anlam kazanır. Dolaylı faydası şu: kuluçka merkezleri ve hızlandırıcılar AWS, Microsoft ve GitHub'da büyük katmanları açan partner olabiliyor.

## Başvurmadan önce hazırla

- [ ] Ürünün kendi alan adında bir iş e-postası. Claude, Google, Cloudflare ve PostHog kişisel adres kabul etmiyor. İstisna Microsoft: kayıt, daha önce Azure açılmamış kişisel bir Microsoft hesabıyla yapılır.

- [ ] Doğrulanabilir canlı bir site ve LinkedIn, X ya da GitHub'da görünür bir sayfa. AWS'de site ya da profil başvurudaki şirket adını göstermeli.

- [ ] 50–500 karakterlik ürün tanımı. AI'ın ne yaptığı ve tüketiciye finansal tavsiye verilip verilmediği net yazılır.

- [ ] Kuruluş tarihi ve neye dayandığı, yatırım durumu, ekip büyüklüğü, şehir ve ülke. Bunlar her formda aynı yazılır.

- [ ] GCP için 18 karakterlik billing account ID. Başvurudaki e-posta, billing hesabının e-postası ve site aynı alan adında olmalı. Alan adında ücretli Workspace varsa Workspace hediyesi gelmez.

- [ ] Önce o serviste açılmış hesap: AWS'de profesyonel e-postalı bir Builder ID ve Paid Tier hesap, Sentry'de organizasyon slug'ı, PostHog'da şirket e-postalı ve ücretli plandaki hesap.

- [ ] Neon için kullanım rakamları: günlük CU-saat ve depolama.

- [ ] Yatırım varsa: yatırımı gösteren herkese açık kaynaklar (Google Scale), tutar ve yatırımcı adları (Sentry), partner referans kodları (AWS, Microsoft, GitHub, Anthropic).

- [ ] Tescil isteyen programlar için şirket belgeleri: Microsoft kayıtlı şirket adı ve adresinin resmi belgelerle aynı olmasını, Cloudflare tescilli şirket ister.

- [ ] BİGG için iş planı. Bulut kredi programları sunum istemiyor; Google yatırım için deck yerine herkese açık kaynak linki ister.

- [ ] Kart, bütçe uyarısı ve kredi kaydı hazır: tarih, tutar, bitiş ve bitişten bir hafta önceye hatırlatma.

## Strateji

1. Başvuru ağır kullanım başlamadan hemen önce yapılır.

Süre çoğu programda onay ya da claim günü başlar: Claude'da 6 ay; Neon, Cloudflare, Sentry, PostHog, GitHub ve Google Start'ta 12 ay. Fikir aşamasında alınan kredi büyük ölçüde boşa yanar. Onay ile claim ayrıysa (Claude'da öyle) claim kullanımın başladığı haftaya bırakılır. İstisna yaş pencereleri: Google Start 24 ay, Sentry ve PostHog 2 yıl, Claude ve Google Scale 5 yıl. Pencere kapanmadan başvurulur.

2. Mimari krediye göre seçilmez.

Kredi 6–24 ay sürer, mimari kalır. GCP kredisi Neon'u ödemiyor, yine de sırf bu yüzden Cloud SQL'e geçilmez: Cloud SQL açık kaldığı her saniye faturalanır, Neon 5 dakika hiç bağlantı olmazsa uyur ve kendi programı zaten $1.000 verir. LLM sağlayıcısı tek bir ortam değişkeniyle seçilebilir tutulur; kredi bitince geri dönmek tek deploy olur.

3. Fatura ürün bazında ayrılır.

Google kredisi seçilen billing hesabına, Neon kredisi hesaba yüklenir; aynı hesaptaki başka ürünler krediyi yer. Başvurudan önce ürüne ayrı bir billing hesabı ve ayrı bir Neon organizasyonu açılır; en kolayı ikisini gün 0'da açmaktır.

4. Hiçbir şey sessizce faturalanmaz.

Her kredi için başvuru, onay, claim ve bitiş tarihi tutarıyla bir kayda yazılır ve bitişten bir hafta önceye hatırlatma kurulur. GCP bütçe uyarısı yalnız e-posta atar, harcamayı durdurmaz; krediler varsayılan olarak düşüldüğü için kredi bitince net maliyet sıçrar. Krediyi ne hızla yediğini görmek için kredileri hariç tutan ikinci bir bütçe kurulur. AWS, Microsoft, GitHub ve PostHog kredi bitince karttan faturalar. Anthropic Console'da auto-reload kapalı kalır; bakiye bitince fatura gelmez, çağrılar durur.

5. Form cevapları her programda aynıdır.

Kuruluş tarihi, yatırım durumu, ekip ve ürün tanımı programlar arasında tutarlı yazılır. Tescil tarihi ile ürünün ilk günü farklıysa hangi tarihin esas alınacağı programa sorulur; yaş penceresine girmek için yeni bir tarihle başvurulmaz. Şartları açıkça tutmayan programa başvurulmaz.

6. Yatırım gelirse partner kodları aynı hafta istenir.

AWS Activate Provider Org ID, Microsoft Investor Network kodu, Anthropic ortak ağı (en fazla $100.000 ek API kredisi) ve GitHub for Startups partnerliği bu yolla açılır. Google Scale ve Neon'un VC kolu yatırımın kanıtıyla açılır; Neon en az $1 milyon ya da tanınmış bir hızlandırıcı ister.

### Doğrulanamayanlar

8 Ekim 2026'da resmi sayfalardan teyit edilemeyen ya da sayfaların çeliştiği noktalar.

Google Start'ın tescilli şirket isteyip istemediği sayfalarda yazmıyor.

Google kredisinin Firebase'in ücretli ürünlerini ve AI Studio'daki Gemini API'yi kapsayıp kapsamadığı net değil; billing hesabındaki tek bir projeye sınırlanıp sınırlanamayacağı da doğrulanmadı.

Cloudflare'in ölçüt listesinde 'son 12 ayda yatırım almış' maddesi var, oysa Tier 3 için yatırım şartı olmadığı yazıyor.

Microsoft'un resmi sayfaları kredi tutarlarını farklı anlatıyor. Hangi Azure model hizmetlerinin kapsandığı ve kurumsal kullanıcılara bireysel hizmet veren bir ürünün B2B sayılıp sayılmayacağı doğrulanmadı.

AWS Activate kredisinin geçerlilik süresi SSS'de yok, yalnız Billing konsolunda görünüyor. İnceleme süresi bir sayfada 5–10, ötekinde 7–10 iş günü.

openai.com/startups 403 döndü; kredilerin yalnız VC ortak ağı üzerinden verildiği bilgisi ikincil kaynaklardan.

Neon kredisinin organizasyondaki tüm projelere uygulanıp uygulanmayacağı ve canlı, kullanıcısı olan bir ürünün 'erken aşama ya da MVP' sayılıp sayılmayacağı doğrulanmadı.

Sentry'de 12 ay dolunca ücretli plana mı geçildiği, ücretsiz plana mı düşüldüğü sayfada yazmıyor.

Claude'da onay ile claim arasında bir son tarih olup olmadığı, kredinin aynı Console organizasyonunda başka bir ürün için kullanılıp kullanılamayacağı ve ücretsiz Team yılı bitince kendiliğinden ücretli plana geçilip geçilmeyeceği program şartlarından okunmadı.

BİGG'deki ₺900.000 2024 tarihli özet formdan; güncel çağrının tutarı ve desteğin biçimi farklı olabilir. Teknokent istisnasının 31.12.2028'e kadar sürdüğü bilgisi ikincil kaynaklardan. KOSGEB araştırılmadı.

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

<a id="pahali-api"></a>

Ücretli API

# Pahalı dış API'ler

Dış bir API'yi açmak bir satır ayar, kapatmak haftalar sürer. Fatura çağrı başına gelir ve çağrı sayısını biz değil trafik belirler: kullanıcılar, botlar, sunucu tarafı çizim, yeniden denemeler ve unutulan tek seferlik toplu işler.

**Kural:** Önce alternatifler, sonra anahtar.

Pahalı bir API'den önce alternatifler eksiksiz değerlendirilir. Açık veri, tek seferlik içe aktarma ya da kendi tablomuz aynı işi yapabiliyor mu? En az iki alternatif fiyat, kota ve saklama hakkıyla yan yana yazılır; en kötü günün faturası ve çıkış yolu karar verene yazılı olarak gösterilir. Bunlar olmadan anahtar açılmaz.

## Ürün B'de Google Places

Ürün B bir mağaza keşif uygulaması. İlk sürümde katalog, arama, konum seçici ve mağaza fotoğrafları Google Places API'ye dayanıyordu. Places Ağustos'ta projenin Google faturasının çoğunu yazdı; kısmi düzeltmeler yetmedi ve API Eylül'de tamamen kapatıldı.

**₺1.500** Ağustos 2026'da Places: fotoğraf 3.786 çağrı ₺924, Enterprise ayrıntı 1.608 çağrı ₺576. Bu projenin ₺2.081'lik Ağustos Google faturasının ~%72'si.
**₺0,33 ve ₺0,95** Ağustos faturamızda ücretsiz kotadan sonra bir fotoğrafın ve bir Enterprise ayrıntı çağrısının bedeli. Bugünkü liste fiyatı 49 TL ile ₺0,34 ve ₺0,98. 20 küçük resimli bir sonuç sayfası ~₺6,6.
**~1.500 çağrı** Üç günde beş tek seferlik bakım komutundan gelen ayrıntı istekleri. Çoğu yalnız tür ya da durum istiyordu; hepsi Enterprise'tan ödendi.

## Aylık Places faturası

Place Details PhotosPlace Details EnterpriseSKU kırılımı bakılmadıTL, fatura; ölçek gerçek
_Grafik: Aylık Places faturası_

## Ne oldu

**19 Ağu:** Sonuç listeleri fotoğraf göstermeye başladı; 27 Ağustos'ta öne çıkanlara ve aylık seçkiye de eklendi. Her küçük resim sunucumuz üzerinden Google'a ayrı bir fotoğraf isteğiydi ve önünde yalnız tarayıcının bir saatlik önbelleği vardı. Resimlere arama hız sınırından ayrı, geniş bir sınır verildi, çünkü fotoğraf ucuz taraf sanıldı.

**26–28 Ağu:** Beş bakım komutu eksik tür, durum, iletişim ve fotoğrafı doldurdu: ~1.500 ayrıntı çağrısı. Google isteği maskedeki en pahalı alanın SKU'sundan keser; tek ve geniş maske her çağrıyı Enterprise'a taşıdı. Konum seçicinin yalnız koordinat gereken adımı da aynı maskeyle soruyordu.

**Ağustos:** Her arama kendi kataloğumuzla paralel olarak Google'a da gidiyordu. Aramaların dörtte üçünde Google görünen sonuca yeni bir mağaza eklemedi, %67'si daha önce sorulmuş bir soruydu. Arama o ay ücretsiz kotada kaldı; trafik büyüseydi sıradaki kalem buydu.

**29 Ağu–8 Eyl:** Kısmi düzeltmeler: aynı soru 6 saat önbellekten; Google'a yalnız kendi kataloğumuz yetmeyince gidiliyor; liste aramaları fotoğraf ve ayrıntı istemiyor; listelerden küçük resimler kalktı; konum seçici Essentials alanlarına indi; %5'lik ücretli gölge örneklem kapatıldı.

**Eylül:** Places yine ₺657 tuttu. Eylül ve Ekim ölçümlerinde gece trafiğinin ~dörtte biri bottu; tek bir kazıyıcı günde ~25.700 istek atıyordu ve sitenin sunucuda çizdiği her sayfa API'ye ortalama 1,73 istek daha yapıyordu. Görüntüleme başına ücretli tasarımda bu çarpanların hepsi faturaya yazılır.

**11 ve 21 Eyl:** Google 11 Eylül'de koddan tamamen çıkarıldı; API 21 Eylül'de projede kapatıldı ve etkin servisler listesinden düştüğü doğrulandı.

## Yerine gelenler

### 81 il. Konum seçici

Türkiye'nin 81 ili, 973 ilçesi ve 69.262 mahallesi noktalarıyla kendi tablomuzda; veri API'nin içinde, sıkıştırılmış ~1 MB. İstek anında dış servis yok, anahtar yok, maliyet yok.

### Zincir. Zincir mağazalar

Markaların kendi sitelerinde yayınladığı mağaza listeleri. Okuyucu robots.txt'ye uyar, saniyede bir istek atar ve kendini tanıtır; her içe aktarma önce deneme modunda çalışır, her satırın kararı kayda geçer. Doğrulanmış sayılan tek kaynak.

### 1.902. Bağımsız mağazalar

OpenStreetMap'ten il il, tek seferlik içe aktarma; ilk ilde 1.912 kayıt okundu, 1.902'si yeni çıktı. Satırlar kaynak türü ve harita kimliğiyle işaretli, doğrulanmamış sayılır ve zincirin onayladıklarının arkasında sıralanır. ODbL atfı mağaza sayfasında.

### 66 logo. Fotoğraf

Önce yöneticinin yüklediği, sonra zincirin logosu, yoksa baş harf. 125 kayıtlı marka için 66 logo dosyası var; satın alınan görsel yok.

Bedeli: Google puanları ve çalışma saatleri gitti; saatler zincirlerin kendi verisinden gelecek. Kazancı: Places faturası sıfır; arama metni, koordinat ve yarıçap artık Google'a gitmiyor ve KVKK aktarım tablosundan bir yurt dışı alıcı düştü.

### Saklama hakkı da fiyattır

Saklama hakkı fiyat kadar önemli bir kalemdir. Google'da süresiz saklanabilen yalnız place_id; enlem ve boylam en çok 30 gün; fotoğraf adı hiç önbelleklenemez; işletme adı, adres ve yorumları kopyalayıp saklamak yasak; içerik Google dışı bir haritayla birlikte gösterilemez. Maliyeti düşürmek için ayrıntıyı kalıcı saklamak ilk akla gelen yoldur, şartlar buna izin vermiyor. Verisini saklamamıza izin vermeyen sağlayıcıda önbellek bir maliyet aracı değildir.

## Kurallar

1. Açmadan önce hesapla: çağrı başı fiyat çarpı beklenen çağrı, bir de en kötü gün.

Ücretsiz kotadan sonra bir fotoğraf ₺0,33, 20 resimli sayfa ₺6,6. Bu çarpım bir satırda yazılsaydı fotoğraf listeye girmezdi. Beklenen çağrı kullanıcı sayısından değil sayfa görüntüleme, bot, tekrar ve tek seferlik toplu işten hesaplanır.

2. En ucuz SKU'dan başla; alan maskesini her çağıran için ayrı seç.

Place Details'te id ve fotoğraf adı ücretsiz; adres, koordinat ve tür Essentials ($5/1.000); ad ve durum Pro ($17); puan, telefon, site ve saat Enterprise ($20). Tek gereksiz alan isteği dört kat pahalı yapar; fotoğrafın kendisi ayrı, ücretli bir istektir ($7).

3. Önce kendi cevabın; dış servis yalnız boşluğu doldursun.

Aramaların dörtte üçünde Google yeni bir şey eklemedi, %67'si tekrardı. Aynı soruyu 6 saat önbellekte tutmak kimsenin fark etmediği bir tasarruftu.

4. Görüntüleme başına çağrı yerine tek seferlik içe aktarma ve kendi veritabanı.

Görüntüleme başına modelde botlar, sunucu tarafı çizim ve yeniden denemeler doğrudan çarpandır. İçe aktarmada maliyet bir kez ve önceden bilinir; ön şartı saklamaya izin veren kaynak: OpenStreetMap, Foursquare OS Places, Overture, Geoapify ya da markaların kendi listeleri.

5. Önbelleği şartların izin verdiği kadar kullan; şartı fiyatla birlikte, alan alan oku.

Saklama hakkı fiyat kadar önemli bir kalem: Google'da yalnız place_id süresiz saklanır, koordinat 30 gün, fotoğraf adı hiç.

6. Her ürüne ayrı anahtar; uygulama kısıtı ve API kısıtı zorunlu.

Sunucuda IP, web'de referrer, mobilde paket adı ve imza; yalnız gereken API'ler. Kısıtsız anahtarın kötüye kullanımından doğan ücretten müşteri sorumlu. Kullanılmayan anahtar silinir.

7. Günlük kota bütçedir; bütçe uyarısı sınır değildir.

Bütçe harcamayı durdurmaz, yalnız haber verir; durduran API kotasıdır. Günlük sınır, bir günde kaybetmeye razı olunan tutar bölü çağrı başı fiyattır: günde ₺100 ve ₺0,95'lik çağrı için ~100. Kota gecikmeyle uygulanır, pay bırakılır. Google Cloud'un harcama tavanı bütçesi bugün Maps Platform'u kapsamıyor. Kota dolunca uygulama hata vermez, kendi verisine düşer.

8. Bütçe uyarısı %50, %80 ve %100'de; proje ve servis bazında.

Maliyet faturaya gecikmeli düşer; %100 geldiğinde para çoktan harcanmıştır. Pub/Sub bildirimiyle eşikte faturalandırmayı otomatik kapatmak yalnız ücretli API'lerin durduğu ayrı bir projede kurulur: faturalandırma kapanınca o projedeki her şey, prod dahil, durur.

9. Tam açmadan önce örneklemde gölge ölçüm; ölçümün de bedeli ve bitiş tarihi olsun.

Google'ın getirdiği mağazalar kendi sıralamamızda medyan 114 puan aldı, bizdekiler 70: getirdiğinde iyi getiriyordu, ama aramaların dörtte üçünde hiçbir şey getirmiyordu. Gölge çağrılar da ücretli; oranı ve süresi baştan sabitlenir.

10. İlk ay faturaya haftada bir, SKU kırılımıyla bak.

Fotoğrafların listeye girdiği hafta ve bakım komutlarının üç günü faturada görünürdü; biz ay sonu toplamla gördük. GCP için tahmin ayda $1 idi; faturalama hesabının Ağustos toplamı ₺2.087, kırk kattan fazla çıktı.

11. Çıkış yolunu girişte yaz.

Google'ı çıkarmak konum seçiciyi, aramayı, fotoğrafı ve gizlilik metinlerini değiştirdi; konum seçici Google'sız hiç çalışmıyordu. Her kaydın kaynağı ayrı tutulduğu için sağlayıcıdan gelen 1.206 kaynak kaydı tek seferde silinebildi. Sağlayıcıya özel bir alan (puan, saat) ürünün vaadi olursa çıkış pahalılaşır.

## Alternatifler

Konum ve mağaza verisi için, 8 Ekim 2026. Saklama hakkı fiyat kadar belirleyici.

### Google Places API (New)

**Ne verir:** POI arama, ayrıntı, fotoğraf, otomatik tamamlama; Türkiye'de en geniş kapsam, puan ve saat.

**Ücretsiz:** SKU başına aylık: Essentials 10.000, Pro 5.000, Enterprise ve Photos 1.000; IDs Only sınırsız.

**Fiyat:** 1.000 çağrıda: Essentials $5, Pro $17, Enterprise $20, Photos $7; Text Search Pro $32, Enterprise $35.

**Saklama ve şart:** Süresiz yalnız place_id; koordinat 30 gün; ad, adres, yorum saklanamaz; fotoğraf adı önbelleklenemez; Google dışı haritayla yasak.

**Bize uygunluk:** Görüntüleme başına modelde pahalı, veri bizim olamıyor. Dönülürse yalnız boşluk için: dar maske, ayrı anahtar, günlük kota.

### OpenStreetMap, genel Overpass

**Ne verir:** OSM verisini sorgulama; il il mağaza.

**Ücretsiz:** Ücretsiz; günde ~10.000 istek ve 1 GB altı indirme beklenir.

**Fiyat:** Yok; fazlası için kendi sunucu.

**Saklama ve şart:** ODbL: saklama ve ticari kullanım serbest, atıf zorunlu; türetilen veri dağıtılırsa aynı lisans. Ana sunucunun robots.txt'si API yolunu kapatıyor.

**Bize uygunluk:** Bağımsız mağazalar için bugünkü kaynak; dönemsel içe aktarma, canlı istek değil.

### Nominatim, genel sunucu

**Ne verir:** Adresten koordinata ve koordinattan adrese.

**Ücretsiz:** Ücretsiz; saniyede en çok 1 istek.

**Fiyat:** Yok; asıl işi geocoding olan kendi sunucusunu kurar.

**Saklama ve şart:** Önbellek zorunlu; otomatik tamamlama ve bir bölgedeki bütün POI'leri indirmek yasak; tanıtan User-Agent ve atıf şart.

**Bize uygunluk:** Canlı arama için değil; ara sıra tek adres için.

### OSM'yi kendimiz barındırmak

**Ne verir:** Aynı veri kendi makinemizde, sınırsız sorgu.

**Ücretsiz:** Yazılım ve veri ücretsiz.

**Fiyat:** Sunucu: tam gezegen 200–300 GB disk; küçük bir kesit 1 GB RAM ile.

**Saklama ve şart:** ODbL.

**Bize uygunluk:** Bugün gerekmiyor; genel sunucular yetmezse ya da sık güncelleme gerekirse.

### Foursquare Places API

**Ne verir:** POI arama ve ayrıntı; ipucu ve fotoğraf ayrı katman.

**Ücretsiz:** Sayfa çelişkili: '10.000'e kadar' ve 0–500 çağrı; Premium'da yok.

**Fiyat:** Pro 1.000 çağrıda $15'ten; Premium (fotoğraf) $18,75'ten.

**Saklama ve şart:** Sözleşmeye bağlı; okunmadı.

**Bize uygunluk:** Fotoğraf için Google'dan pahalı; öncelik değil.

### Foursquare OS Places

**Ne verir:** 100 milyonu aşkın POI, 20'yi aşkın alan; fotoğraf, saat ve puan yok.

**Ücretsiz:** Tamamen ücretsiz.

**Fiyat:** Yok; indirme ve işleme emeği.

**Saklama ve şart:** Apache 2.0: saklama ve ticari kullanım serbest; lisans ve telif bildirimi korunur.

**Bize uygunluk:** Güçlü aday: OSM'nin zayıf kaldığı illerde tek seferlik içe aktarma; kapsam önce bir ilde ölçülür.

### Overture Maps Places

**Ne verir:** Birleştirilmiş açık POI; Eylül 2026'da ~81 milyon kayıt, aylık sürüm.

**Ücretsiz:** Ücretsiz.

**Fiyat:** Yok; indirme ve işleme emeği.

**Saklama ve şart:** Çoğu CDLA Permissive 2.0, share-alike yok; mükerrer ve hatalı kayıt güven puanıyla süzülür.

**Bize uygunluk:** OS Places ile aynı rol; ikisinden biri seçilir.

### Geoapify Places

**Ne verir:** OSM tabanlı POI ve geocoding API'si.

**Ücretsiz:** Günde 3.000 kredi; ticari kullanım serbest, atıf şart.

**Fiyat:** $59/ay'dan (günde 10.000 kredi).

**Saklama ve şart:** Saklama ve dağıtım serbest; OSM atfı zorunlu.

**Bize uygunluk:** Overpass aynaları cevap vermezse yedek yol.

### Mapbox Search Box

**Ne verir:** POI ve adres arama, otomatik tamamlama.

**Ücretsiz:** 500 oturum ya da 50.000 istek; geçici geocoding 100.000.

**Fiyat:** 1.000 oturum $3, 1.000 istek $1 (tanıtım fiyatı).

**Saklama ve şart:** Geçici sonuç saklanamaz; kalıcı geocoding yalnız kendi kullanımımız için.

**Bize uygunluk:** Otomatik tamamlama gerekirse ucuz; katalog için değil.

### HERE Geocoding & Search

**Ne verir:** Adres ve POI arama.

**Ücretsiz:** Ayda 30.000 geocoding, 5.000 arama.

**Fiyat:** 1.000 işlemde geocoding $0,83, arama $2,75.

**Saklama ve şart:** Sözleşmeyle sınırlı; okunmadı.

**Bize uygunluk:** Kurumsal ölçek için; bize ek bir şey getirmiyor.

### TomTom Places Search

**Ne verir:** POI ve adres arama.

**Ücretsiz:** Ayda Discover 5.000, Details 5.000, Suggest 10.000, Geocoding 20.000; kart gerekmez.

**Fiyat:** Açık sayfada fiyat yok.

**Saklama ve şart:** Açık sayfada yazmıyor.

**Bize uygunluk:** Saklama hakkı ve kapsam netleşmeden aday değil.

### Markaların kendi listeleri

**Ne verir:** Zincirin sitesindeki mağaza bulucu.

**Ücretsiz:** Ücretsiz.

**Fiyat:** Marka başına bir yapılandırma ve bakım emeği.

**Saklama ve şart:** Kamuya açık veri; robots.txt, saniyede 1 istek; site şartları ve logo kullanımı ayrıca okunur.

**Bize uygunluk:** Kataloğun ana kaynağı; doğrulanmış sayılan tek kaynak.

### Kullanıcı fotoğrafı

**Ne verir:** Ziyaretçinin yorumla yüklediği fotoğraf.

**Ücretsiz:** Depolama dışında ücretsiz.

**Fiyat:** Depolama ve moderasyon emeği.

**Saklama ve şart:** Kullanım şartlarında bize lisans veren madde ve kişisel veri (yüz, plaka) kuralı gerekir.

**Bize uygunluk:** Uzun vadede en değerli fotoğraf kaynağı; yorum akışına bağlanır.

### Logo ve yönetici yüklemesi

**Ne verir:** Marka başına logo, mağazaya yöneticinin yüklediği kapak.

**Ücretsiz:** Ücretsiz.

**Fiyat:** Yok; logolar bir kez toplanır.

**Saklama ve şart:** Markayı tanıtmak için logo kullanımının dayanağı ayrıca sorulur.

**Bize uygunluk:** Bugünkü çözüm: 125 marka için 66 logo, kalanında baş harf.

### Wikimedia Commons

**Ne verir:** Serbest lisanslı fotoğraf.

**Ücretsiz:** Ücretsiz.

**Fiyat:** Yok.

**Saklama ve şart:** Lisans dosya başına; yazar atfı ve lisans verilir, BY-SA'da değişen görsel aynı lisansla.

**Bize uygunluk:** Mağaza fotoğrafı neredeyse yok; AVM ya da cadde görseli için.

## Her ücretli API'den önce

Harita, model, SMS ya da e-posta fark etmez. Her madde yazılı cevaplanır; cevapsız madde varsa API açılmaz.

- [ ] **Birim ve birim fiyat.** Neye para ödüyoruz: çağrı, token, mesaj, oturum, SKU? Bir kullanıcı işlemi kaç birim tüketiyor? Bir sonuç sayfası 20 fotoğraf, bir SMS doğrulaması 1 mesaj, bir asistan sorusu ~4.500 girdi tokenı gibi.

- [ ] **Ücretsiz kota.** Ne kadar, hangi birimde, günlük mü aylık mı, proje mi hesap mı? Bitince servis mi duruyor, sessizce ücret mi başlıyor?

- [ ] **En kötü durum çarpanı.** Botlar, sunucu tarafı çizimin çift isteği, yeniden denemeler, en yüksek instance sayısı, döngüye giren iş, tek seferlik toplu komutlar. Hesap: çağrı başı fiyat çarpı saniyede en fazla istek çarpı 86.400. Sahte trafikle şişirilen SMS doğrulaması ve kötüye kullanılan giriş kodu formu bunun örnekleri.

- [ ] **Sert sınır.** Günlük kota, harcama tavanı ya da ön ödemeli kredi var mı? Yoksa kendi sayacımızı koyduk mu? AI asistanın günlük soru sınırı böyle bir sayaç. Uyarı sınır değildir.

- [ ] **Veri hakları ve saklama.** Sonucu saklayabilir miyiz, hangi alanı ne kadar? Başka bir servisle ya da haritayla birlikte gösterebilir miyiz? Atıf, share-alike, kişisel verinin yurt dışına çıkışı ve KVKK aktarım tablosu?

- [ ] **Kilitlenme.** Kimliklerimiz sağlayıcının kimliğine mi bağlı? Her kaydın kaynağı ayrı tutuluyor mu? Sağlayıcıya özel bir alan ürünün vaadi haline geldi mi?

- [ ] **Çıkış planı.** Kapatırsak hangi ekran çalışmaz, yerine ne gelir, kaç günlük iş, hangi yasal metin değişir? Yedek sağlayıcı ya da açık veri hazır mı?

- [ ] **Alternatifler.** Aynı işi açık veri, tek seferlik içe aktarma ya da kendi tablomuz yapabilir mi? En az iki alternatif fiyat, kota ve saklama hakkıyla yan yana yazıldı mı?

- [ ] **Anahtar ve izleme.** Ürüne özel, kısıtlı ve Secret Manager'da duran bir anahtar mı? Günlük harcamayı SKU kırılımıyla nerede, kim, ne sıklıkla görecek?

- [ ] **Karar.** Günlük ve aylık rakam, en kötü günün rakamı ve çıkış yolu, açılmadan önce karar verene yazılı söylendi mi?

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

<a id="boyutlar"></a>

Depolar ve boyutlar

# Projelerimiz ne büyüklükte

Dört ürünümüz 14 aktif depoda duruyor. Sayımlar 8 Ekim 2026'da her deponun ana dalından yapıldı.

Toplam ~499.000 satır kod var, bunun ~132.000'i (%26) test. Yanında ~52.000 satır Markdown belge duruyor. Hiçbir .git klasörü 33 MB'ı geçmiyor ve depolardaki ağırlığın çoğu koddan değil görsellerden geliyor. En büyük ürün Ürün A: beş depo, ~265.000 satır, son 30 günde 955 commit.

**14 depo** Ürün A 5, Ürün B 3, Ürün C 4, Ürün D 2. Emekli 6 depo ayrıca sayıldı.
**~499.000 satır** Kod. Yanında ~52.000 satır Markdown belge var.
**%26 test** 131.673 satır test kodu; depoya göre pay %0 ile %38 arası.
**4.341 dosya** Ana dallarda izlenen dosyalar 99,4 MB; bunun 62,5 MB'ı görsel.
**210 MB** On dört .git klasörünün toplamı. En büyüğü 32,8 MB.
**2.368 commit** Bunun 1.711'i son 30 günde. a-web 18 Eylül'de açıldı ve 260 commit aldı.

## Depo başına kod satırı

Test koduUygulama kodusatır, ana dal, 8 Ekim 2026; ölçek gerçek
_Grafik: Depo başına kod satırı_
En eski depo portal (ilk commit Kasım 2021), sonra Ürün A mobil (Şubat 2025). Geri kalan on iki depo 2026'da açıldı: Ürün C Şubat'ta, Ürün D Mayıs'ta, Ürün B ve a-api Ağustos'ta, a-web ve a-pazar Eylül'de.

## Proje toplamları

| Proje | Depo | Dosya | Kod satırı | Test satırı | Test payı | Belge satırı | Görsel MB | .git MB | Commit | Son 30 gün |
|---|---|---|---|---|---|---|---|---|---|---|
| Ürün A | 5 | 1.815 | 265.482 | 80.615 | %30 | 13.771 | 13,8 | 77,5 | 1.105 | 955 |
| Ürün B | 3 | 913 | 69.704 | 15.359 | %22 | 13.188 | 36,2 | 73,0 | 708 | 385 |
| Ürün C | 4 | 1.489 | 151.380 | 33.022 | %22 | 24.241 | 12,5 | 55,3 | 524 | 360 |
| Ürün D | 2 | 124 | 12.494 | 2.677 | %21 | 367 | 0,0 | 4,0 | 31 | 11 |
| Toplam | 14 | 4.341 | 499.060 | 131.673 | %26 | 51.567 | 62,5 | 209,9 | 2.368 | 1.711 |

### Dillere göre

_Grafik: Dillere göre kod satırı_
**TypeScript** 254.214 satır, %50,9**Go** 163.232 satır, %32,7**JavaScript** 55.941 satır, %11,2**CSS** 14.816 satır, %3,0**Diğer** 10.857 satır, %2,2 (SQL, Shell, Swift, Python, Kotlin, HTML, Objective-C)

## Depo depo

| Depo | Kod satırı | Test satırı | Görsel MB | .git MB | Commit | İmaj MB |
|---|---|---|---|---|---|---|
| Ürün A |
| a-apiGo API | 66.212 | 25.232 | 1,7 | 12,4 | 219 | 30,6 |
| a-portalPortal, React ve Vite | 52.033 | 15.467 | 8,7 | 32,8 | 194 | 34,6 |
| a-webNext.js bilgi sitesi | 32.528 | 8.733 | 2,8 | 13,0 | 260 | 91,9 |
| a-pazarNext.js pazar yeri | 20.964 | 5.218 | 0,1 | 1,3 | 154 | 88,3 |
| a-mobilExpo mobil | 93.745 | 25.965 | 0,5 | 18,1 | 278 | – |
| Ürün B |
| b-apiGo API | 44.599 | 13.293 | 8,2 | 30,4 | 310 | 19,8 |
| b-webNext.js web | 23.470 | 2.066 | 15,0 | 28,5 | 379 | 455,7 |
| b-mobilExpo mobil | 1.635 | 0 | 13,0 | 14,1 | 19 | – |
| Ürün C |
| c-apiGo API | 56.580 | 18.980 | 0,6 | 24,6 | 177 | 23,5 |
| c-webNext.js web | 38.374 | 4.975 | 2,0 | 6,7 | 164 | 77,4 |
| c-adminNext.js yönetim paneli | 29.140 | 2.216 | 1,8 | 6,4 | 51 | 76,6 |
| c-mobilExpo mobil | 27.286 | 6.851 | 8,2 | 17,5 | 132 | – |
| Ürün D |
| d-apiGo API | 4.115 | 886 | 0,0 | 0,6 | 15 | 25,9 |
| d-webNext.js web | 8.379 | 1.791 | 0,0 | 3,4 | 16 | 419,9 |

Sayım origin/main dalından yapıldı (c-mobil'te origin/master), çünkü bazı yerel main dalları geride. Kod satırına Go, TypeScript, JavaScript, SQL, CSS, Swift, Kotlin, Objective-C, C#, HTML, Shell ve Python girer. Kilit dosyaları, Markdown, ikili dosyalar, bir depodaki üçüncü taraf ajan becerisi (72.643 satır) ve üretilmiş bir motor dosyası (4.984 satır) sayılmadı. Test satırı kod satırının içindedir. İmaj sütunu Artifact Registry'deki son prod imajıdır; mobil depoların sunucu imajı yok.

Yerelde aktif depoların kopyaları 13,8 GB tutuyor: 8,4 GB'ı node_modules, 3,1 GB'ı iOS ve Android build klasörleri. Ürün A mobil uygulaması tek başına 5,0 GB.

## Bulgular

İmaj boyutu, test ve prod'un ayrı build'i ve build önbelleği [Artifact Registry ve build kuralları](#registry) bölümünde.

### 62,5 MB. Ağırlık koddan değil görsellerden geliyor

Ana dallarda izlenen 99,4 MB'ın 62,5 MB'ı görsel. Ürün B'nin logo ve açılış PNG'leri tanesi 1,2–1,5 MB ve aynı dosyalar üç deposunda da duruyor. Aktif depolarda 259 dosya iki ya da daha fazla depoda bayt bayt aynı, toplam ~20 MB.

**Öneri** Görseller sıkıştırılır ya da WebP veya AVIF'e çevrilir. Marka dosyalarının tek kaynağı uygulama depolarının dışında durur.

### ~29 MB ve ~25 MB. Derlenmiş ikili iki kez commit'lendi

İki Go API deposuna, Şubat'ta ve 11 Eylül'de, birer macOS ikilisi girdi. İkisi de silindi ve gitignore'a eklendi, ama silinen dosya geçmişte kalır. Bir deponun geçmişinde de eski bir CRA build/ klasörünün 333 dosyası (ham 55 MB) duruyor; en büyük .git klasörünün çoğu bu.

**Öneri** Pre-commit ve CI'da ~1 MB'tan büyük her dosyayı ve her Mach-O ya da ELF ikilisini reddeden bir kontrol.

### 5 depo. Ortak kod elle kopyalanıyor

Bot kapısı modülü (kod, veri dosyası, yenileme betiği ve ~96 KB'lık test seti) dört projenin beş deposunda birebir aynı. Hesaplama motoru mobil uygulama ile portal arasında aynı; motor dosyası portaldan web sitesine kopyalanmış, yalnız baş yorumu farklı. Kopyalar bugün eşit, ama onları eşit tutan bir şey yok.

**Öneri** Ortak bir paket: Artifact Registry'de bir npm deposu ya da GitHub Packages. İlk adım olarak kopyaların hash'ini karşılaştıran bir CI kontrolü.

### 72.643 satır. Ürün deposunda üçüncü taraf ajan aracı

Bir Go API deposunda .agents/ altında üçüncü taraf bir ajan becerisi sayıldı: 155 dosya, 3,3 MB. Satır sayısı deponun kendi Go kodundan (43.020) fazla.

**Öneri** Ajan araçları ürün deposunun dışında durur ya da gitignore'a girer.

### 4 araç, ikişer sürüm. Sürümler projeler arasında kayıyor

Go, Next, Node ve Expo'nun her birinde projeler arasında iki sürüm birlikte kullanılıyor; Next, Node ve Expo'da fark ana sürümde. Temel imajlar digest'le değil etiketle sabitlenmiş.

**Öneri** Go, Node, Next ve Expo için birer sürüm yazan tek bir taban dosyası ve her depoda Renovate ya da Dependabot.

### 65 commit. Dallar birikiyor

Birleşmiş yerel dallar bazı depolarda 6–20'ye çıktı. Yerel main dalları origin'in 65 commit'e kadar gerisinde; yerelden yapılan sayım bu yüzden yanıltır.

**Öneri** Birleşen dal hemen silinir, emekli depolar arşivlenir. Sayım ve karşılaştırma yerel main'den değil origin'den yapılır.

## Emekli depolar

İki kapanmış ürünün altı deposu GitHub'da duruyor. Kişisel depolar bu sayıma girmedi.

**e-api**
Go API; 46 dosya, 4.313 satır, 11 commit.

**e-web**
Web arayüzü; 141 KB.

**e-kapanış**
Kapanan E ürününün kapanış sayfası deposu.

**f-api**
C# API; 53 dosya, 11.238 satır, 25 commit.

**f-web**
Web arayüzü; 4,9 MB.

**f-kapanış**
Kapanan F ürününün kapanış sayfası deposu.

## Denenebilecekler

| Deneme | Beklenen etki | Risk ve not |
|---|---|---|
| Büyük dosya kapısı | Yanlışlıkla eklenen ikili ve büyük görsel geçmişe hiç girmez. | Düşük. Meşru büyük dosyalar için kısa bir istisna listesi gerekir. |
| Görselleri WebP ya da AVIF'e çevirmek | Depolar ve uygulama paketleri küçülür; görsel ağırlığın çoğu 1,2–1,5 MB'lık marka PNG'leri. | Mağaza ikonları ve e-posta logoları PNG kalır. |
| Ortak paket | Kapı ve hesap motoru tek yerde düzeltilir; kopyalar arasında sessiz fark doğmaz. | Her depoda paket sürümünü yükseltmek ayrı bir adım olur. Hash karşılaştıran CI kontrolüyle başlanabilir. |
| Taban sürüm dosyası ve Renovate | Go, Node, Next ve Expo sürümleri dört projede birlikte ilerler. | Güncelleme PR'ları haftalık gruplanmazsa birikir. |
| Ajan aracını depodan çıkarmak | O deponun toplam satır sayısı ~%60 azalır. | Ajan becerisi depo dışından yüklenir. |

Ölçülmeyenler: GitHub'daki disk kullanımı (yerine yerel .git boyutu kullanıldı), mobil ikili boyutları (indirme gerekirdi) ve sıfırdan derlenmiş Go ikilisinin boyutu (yerine imaj boyutu kullanıldı).

## Yeni depo için kurallar

Bulgulardan çıkan kurallar; yeni bir depo ilk commit'inden bunlarla açılır.

1. Depo özeldir; sır taraması üç yerde çalışır.

gitleaks pre-commit'te ve CI'da, GitHub push protection açık. Elle yapılan taramada .env'i atlamayan bir grep kullanılır; bazı hızlı grep sürümleri gizli dosyaları varsayılan olarak atlar.

2. Büyük dosya ve ikili kapısı ilk commit'te kurulur.

Pre-commit ve CI ~1 MB'tan büyük her dosyayı ve her Mach-O ya da ELF ikilisini reddeder; meşru istisnalar kısa bir listede durur. Silinen ikili geçmişte kalır: bizde iki depoya birer macOS ikilisi girdi, geçmişten çıkarmak ancak geçmişi yeniden yazmakla olur.

3. .gitignore ilk commit'te anahtar desenlerini taşır.

.env*, *.jks, *.keystore, *.p8, *.p12, *.key, build ve native çıktı klasörleri, node_modules. Android upload anahtarı ve App Store Connect anahtarı depoya hiç girmez.

4. Depoda bir ajan dosyası deploy kuralını yazar.

CLAUDE.md ya da AGENTS.md: deploy, build, mağaza gönderimi ve sürüm numarası ürün sahibinin kararıdır; sıra kod biter, commit, tek satırlık rapor, karar. Hafızadaki bir not başka araçlarca görülmez, kural depoda durur.

5. İki dal, iki ortam.

test'e push test ortamına, main'e push onay kapısından prod'a gider; main yalnız test'te görülmüş commit'e fast-forward edilir, iki dal hep eşittir.

6. Birleşen dal hemen silinir.

Yerelde, GitHub'da ve worktree'de; depoda yalnız main ve test kalır. Sayım ve karşılaştırma yerel main'den değil origin'den yapılır.

7. Ortak kod kopyalanmaz.

Kapı ve hesap motoru gibi paylaşılan modül sürümlü bir paket olarak gelir. Paket yoksa kopyaların hash'ini karşılaştıran bir CI kontrolü konur.

8. Sürümler tek taban dosyasında, güncellemeler Renovate ya da Dependabot'la.

Go, Node, Next ve Expo için birer sürüm; temel imajlar sabit sürümle, latest yok. Güncelleme PR'ları haftalık gruplanır.

9. Görseller sıkıştırılmış girer; ajan araçları ürün deposuna girmez.

WebP ya da AVIF; marka dosyalarının tek kaynağı depo dışında. Üçüncü taraf ajan becerisi depo dışından yüklenir ya da gitignore'a girer.

10. Kapanan ürünün depoları arşivlenir.

Kod salt okunur kalır ve yanlışlıkla push almaz; arşiv GitHub'da geri alınabilir.

<a id="registry"></a>

Artifact Registry ve Cloud Build

# Artifact Registry ve build kuralları

İmajlar nerede durur, ne kadar kalır, build ne kadar sürer ve neye para gider. 8 Ekim 2026'da dört projede salt okunur yapılan denetimden.

Dört projede 5 Docker deposu var; toplam 6,9 GB ve 94 imaj tutuyorlar. Temizlik kuralları hepsinde gerçekten çalışıyor, dry-run'da değil. Artifact Registry'nin imaj başına ücretli taraması hiçbir depoda açık değil, bütün tetikleyiciler global bölgede. Bugün kalıcı bir para kaçağı yok: Artifact Registry depolaması ayda ~$0,60 tutuyor. Asıl açık geri dönüş penceresi: dört serviste iki günden kısa.

**6,9 GB** 5 Docker deposunda 94 imaj. Depolama ayda ~$0,60; ilk 0,5 GB ücretsiz.
**3.751 dk** Son 30 günde 807 başarılı build. Ücretsiz kota faturalama hesabı başına ayda 2.500 dk.
**0,9–16,5 gün** Bugünkü geri dönüş penceresi, servise göre. Önerilen kuralla 30 gün.
**~5 kat** Buildpacks ile kurulan Next imajı Dockerfile'lı Next imajından büyük: 420–456 MB ve 77–92 MB.
**%51** Ürün A'nın Ekim build dakikalarında test tetikleyicilerinin payı.
**~$210/ay** Zafiyet taraması build depolarında açık olsaydı tutacak rakam: itilen her digest $0,26.

## Depolar ve temizlik

| Proje | Bölge | GB | Paket | İmaj | Not |
|---|---|---|---|---|---|
| Ürün A | europe-west1 | 1,93 | 11 | 45 | Test ve prod imajları ayrı paketlerde; tarayıcı servisi ve yedek job'ı da burada. |
| Ürün B | europe-west1 | 3,50 | 3 | 22 | Boyutun çoğu buildpacks ile kurulan 456 MB'lık UI imajı. |
| Ürün B | europe-west3 | 0,05 | 1 | 3 | 17–18 Ağustos'tan kalma API imajları; hiçbir servis ya da job kullanmıyor. |
| Ürün C | europe-west1 | 0,44 | 3 | 15 |  |
| Ürün D | europe-west1 | 1,01 | 2 | 9 | UI imajı buildpacks ile 420 MB. |
| Toplam |  | 6,92 | 20 | 94 | Depolama ayda ~$0,60. |

Beş depo da standart modda, Google anahtarlı ve değiştirilemez etiket kapalı. Adları Cloud Run'ın varsayılanı: cloud-run-source-deploy. Temizlik kuralı beşinde aynı ve canlı: paket başına en yeni 5 sürümü TUT, etiketli ya da etiketsiz 1 günden eski her şeyi SİL. Cloud Build her imaja iki küçük köken (SLSA provenance) eki ekliyor; listede build başına 3 sürüm görünüyor, ama ölçtük: ekler 'en yeni 5' sayısına girmiyor; her pakette en yeni 5 imaj ve son 24 saatte itilenler kalıyor.

## İmaj boyutunu build biçimi belirliyor

Artifact Registry'deki sıkıştırılmış boyut, son prod imajları. Koyu kısım en küçük, açık kısım en büyük imaj.

_Grafik: Build biçimine göre imaj boyutu_
Dil değil build biçimi belirliyor: aynı tür Next uygulaması Dockerfile ve output standalone ile 77–92 MB, buildpacks ile 420–456 MB. Ürün A API 30,6 MB, çünkü içinde üç ikili var.

## Geri dönüş penceresi bugün

AR'de imajı hâlâ duran en eski prod revizyonunun yaşı, 8 Ekim 2026.

_Grafik: Servise göre geri dönüş penceresi_
Cloud Run imajın kopyasını yalnız trafik alan revizyon için saklıyor. Canlı revizyon AR'deki silmeden etkilenmez ve yeni instance AR'den çekmez; ama trafik almayan eski bir revizyona dönmek için imajın AR'de durması gerekir. Pencere deploy hızına bağlı: sık deploy eden bir üründe son 24 saatte 9 deploy oldu, pencere 0,9 gün ama 8 deploy geri gidilebiliyor. Yeni projede bu pencereyi live ve prev etiketleri kapatır ([kural 3](#ar-kural-3)).

## İmajlar nasıl üretiliyor

| Biçim | Kim kullanıyor | İmaj |
|---|---|---|
| Dockerfile ve docker build | Ürün A'nın dört servisi, tarayıcı servisi ve yedek job'ı; Ürün B API ve migrate; Ürün C'nin üç servisi; Ürün D API. | 4–120 MB; tarayıcı 725 MB |
| Buildpacks (pack --publish) | İki ürünün UI'ı: biri değişen builder:latest ile, öteki Şubat 2026 tarihli bir RC builder'a sabit. | 420–456 MB |
| gcloud run deploy --source | Bir kez kullanıldı; Ürün A'da 9 Eylül'den kalan bir imaj. | 18 MB |

Tetikleyiciler: Ürün A'da 8 tane (4 depo, main ve test). API ve portalın main tetikleyicileri Cloud Run'ın kendi kurduğu satır içi tetikleyiciler (--no-cache, push, services update); kalanlar depodaki cloudbuild*.yaml dosyasını okuyor. Ürün C'de 3, Ürün B'de 2, Ürün D'de 2 tetikleyici var, hepsi satır içi. On beşi de global bölgede ve varsayılan havuzda. Elle yapılan gcloud builds submit --region europe-west1 build'leri bölgesel; Ürün A'da Eylül'de 82 tane oldu.

Etiketler karışık: tetikleyiciler tam commit SHA'sı, yaml dosyaları kısa SHA kullanıyor; bazı paketler ayrıca latest basıyor ve bir paketin latest'i 9 Eylül'deki bir imajı gösteriyor. Deploy etiketle yapılıyor, Cloud Run onu digest'e çeviriyor.

Test ve prod aynı commit'i ayrı ayrı build ediyor ve farklı digest alıyor: bir API commit'i 7 Ekim'de 12:25'te test imajını, 13:54'te prod imajını aldı. Web, pazar yeri ve portal da böyle. Prod'da testte denenen baytlar çalışmıyor ve build dakikası ikiye katlanıyor.

## Build dakikaları

| Proje | Başarılı build, 30 gün | Dakika, 30 gün | Medyan süre |
|---|---|---|---|
| Ürün A | 388 | 1.707 | 3,4–4,5 dk |
| Ürün B | 349 | 1.729 | UI 4,7, API 5,6 dk |
| Ürün C | 64 | 288 | 3,6–5,3 dk |
| Ürün D | 6 | 27 | – |
| Toplam | 807 | 3.751 | – |

Eylül'de iki ürünün ortak faturalama hesabı 3.121 dakikayla 2.500 dakikalık ücretsiz kotayı 621 dakika aştı ve faturaya ₺187 yazıldı; öteki iki ürünün hesabı 84 dakikada kaldı.

Ortalama süre: Go API 3,5–5,7 dk, bunun 141–275 sn'si önbelleksiz docker build. Next 4,1–5,3 dk, Vite portal 2,1–3,4 dk, buildpack UI 4,1–4,7 dk. En çok build alan tek servis Ürün B UI: 30 günde 198 build.

## Bugünkü kurallarımız

Dört proje
Tek AR deposu (cloud-run-source-deploy), europe-west1. 'En yeni 5'i tut, 1 günden eskiyi sil.' Tarama kapalı, tetikleyici global.

Ürün A
main prod'a, test test ortamına deploy eder; main'e yalnız test'ten geçen commit gider. Test ve prod ayrı paketlerde, çünkü NEXT_PUBLIC ve REACT_APP değerleri build anında gömülüyor. Migrate job'ı her API sürümünde yeni imaja çevriliyor. Tarayıcı servisi ve yedek imajı elle bölgesel build'le üretiliyor.

Ürün B
Yalnız main tetikleyicisi. UI buildpacks ile üretiliyor; Pull ve Push adımları 2 Ekim'de kaldırıldı, Ekim'deki 35 UI build'inin hepsi başarılı.

Ürün C
Yalnız main tetikleyicisi. Testler GitHub Actions'ta koşuyor, deploy yapmıyor.

Ürün D
Yalnız main tetikleyicisi. UI buildpacks ile üretiliyor.

## Ne yanlış gitti, neye para gitti

₺117
Temizlik kuralları kurulduktan 21 Eylül'e kadar dry-run'da kaldı ve hiçbir şey silinmedi. Ürün A deposu 1,3 GB ve 68 imaja çıktı; Ürün B'nin AR depolaması Eylül'de ₺117 tuttu.

**Ders:** Kural listesine değil, describe çıktısındaki cleanupPolicyDryRun alanına bakılır.

₺282
Ürün B'de global buildpack tetikleyicisi her build'de 428 MB'lık imajı Avrupa'dan ABD'deki işçiye çekip geri itti: Eylül'de 194 build, 73 GiB kıtalar arası çıkış. Adımlar 2 Ekim'de kaldırıldı. Aynı kalıp ayda ~15 build'de ~$0,50 tutar ve her build iki imaj yazdığı için geri dönüş penceresini yarıya indirir.

**Ders:** Tetikleyici, AR ve Cloud Run aynı bölgede olur; global bir build AR'den imaj çekmez.

2 kez
Migrate job'ı 'en yeni 5'in dışında kalmış bir imaja sabitti. Temizlik onu silince job kırılma noktasına geldi ve elle yeni imaja çevrildi; 21 Eylül ve 7 Ekim'de aynı şey oldu.

**Ders:** Job imajı servis imajıyla aynı build'de güncellenir.

1 gün
Eylül'de API'nin geri dönülecek revizyonunun imajı bir gün sonra silindi. Ondan sonra geri dönüşün tek yolu revert ve yeniden build oldu.

**Ders:** Bir önceki canlı imaj AR'de durmadan yeni deploy yapılmaz; prev etiketi bunu sağlar.

₺187
İki ürün aynı faturalama hesabını paylaşıyor ve Eylül'de build kotası aşıldı. Ürün A'da test build'leri dakikaların yarısı.

**Ders:** Kotayı birlikte aşan iki ürün ayrı faturalama hesabına alınır; tetikleyicilere includedFiles ve ignoredFiles eklenir.

## Yeni proje için kurallar

Rehbere hazır kurallar; DEPO, PROJE, SERVIS ve ONCEKI yerine kendi adları yazılır.

1. Bölge tektir.

AR deposu, Cloud Run ve Cloud Build tetikleyicisi aynı bölgede, europe-west1'de olur; tetikleyici global bırakılmaz. Aynı bölge içindeki aktarım ücretsiz, kıtalar arası çıkış $0,08/GiB. Global bir build'de AR'den imaj çekilmez.

2. Projede tek Docker deposu, build adımları depoda.

Build adımları depodaki cloudbuild.yaml dosyasında durur. Cloud Run'ın kendi kurduğu satır içi tetikleyici olduğu gibi bırakılmaz, çünkü incelenmez ve sürümlenmez.

3. Temizlik: canlı ve önceki imaj süresiz, deploy edilen 30 gün, testte geçen 14 gün, en yeni 10, gerisi 2 gün.

Kural `cleanup.json` dosyasına yazılır ve önce dry-run'la uygulanır. Bir gün sonra aynı komut `--dry-run` olmadan çalıştırılır, ardından describe çıktısında `cleanupPolicyDryRun` alanının olmadığı ya da false olduğu görülür. `live` ve `prev` etiketleri her deploy'da taşınır ve yaş sınırı olmadan tutulur: canlı imaj, geri dönüş imajı ve job'ın sabitlediği imaj hiç silinmez. Yalnız `deployed-*` kuralına güvenmek yetmez, çünkü `newerThan` yükleme anından sayılır: 30 gündür deploy almayan bir servisin canlı imajı 10 yeni test build'inden sonra silinir. 21 Eylül ve 7 Ekim'de migrate job'ı, sabitlendiği imaj sayı kuralıyla silinince kırıldı. Deploy edilmeyen build 2 gün durur, en yeni 10 imaj her zaman kalır. Ürün A'nın deploy hızında 30 günde ~4 GB, ayda ~$0,40.

```
[
  {"name": "keep-live-prev", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["live", "prev"]}},
  {"name": "keep-deployed-30d", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["deployed-"], "newerThan": "30d"}},
  {"name": "keep-tested-14d", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["tested-"], "newerThan": "14d"}},
  {"name": "keep-recent-10", "action": {"type": "Keep"},
   "mostRecentVersions": {"keepCount": 10}},
  {"name": "delete-rest-after-2d", "action": {"type": "Delete"},
   "condition": {"tagState": "ANY", "olderThan": "2d"}}
]
```

```
gcloud artifacts repositories set-cleanup-policies DEPO \
  --project PROJE --location europe-west1 \
  --policy cleanup.json --dry-run
```

4. Her build tam SHA'yla etiketlenir, her deploy etiketleri taşır.

Terfinin son adımı eski live'ı prev'e, yeni digest'i live'a taşır ve `deployed-YYYYMMDD-HHMMSS` ekler. Aynı digest yeniden terfi edilirse prev'e dokunulmaz; yoksa prev live'a eşit olur ve önceki imaj korumasız kalır. live ya da prev adımı hata verirse build kırmızı biter ve Cloud Build alarmı çalar; deploy geri alınmaz ama koruma eksik kalmaz. `deployed-*` etiketindeki `|| true` deploy'u yalnız bu etiket yüzünden düşürmemek için. Deploy latest ile yapılmaz; job'lar servisle aynı digest'e aynı build'de çevrilir. Cloud Build'de `$$` kaçışı şart.

```
- id: mark
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    NEW=$$(cat /workspace/digest)
    OLD=$$(gcloud artifacts docker images describe $_IMG:live \
      --format='value(image_summary.digest)' 2>/dev/null || true)
    if [ -n "$$OLD" ] && [ "$$OLD" != "$$NEW" ]; then
      gcloud artifacts docker tags add $_IMG@$$OLD $_IMG:prev
    fi
    gcloud artifacts docker tags add $_IMG@$$NEW $_IMG:live
    gcloud artifacts docker tags add $_IMG:live \
      $_IMG:deployed-$$(date -u +%Y%m%d-%H%M%S) || true
```

5. Değiştirilemez etiket build deposunda açılmaz.

Bu ayar açık olan depoda temizlik etiketli imajları silemez; her build SHA etiketi taşıdığı için depo sonsuza kadar büyür.

6. Tarama build deposunda kapalı kalır.

Otomatik tarama itilen her yeni digest için $0,26 alır, test build'leri de sayılır. Ekim hızıyla dört ürün ayda ~820 imaj itiyor; tarama açık olsaydı ayda ~$210 (~₺10.000) tutardı, bugünkü bütün GCP faturasının yirmi katından fazla. Yerine build'de ya da haftada bir canlı imajlara karşı Trivy, osv-scanner, govulncheck veya npm audit koşar; maliyeti yalnız build dakikası. AR'nin kendi taraması istenirse yalnız terfi edilen imajların durduğu küçük bir release deposunda açılır, build deposunda `--disable-vulnerability-scanning` uygulanır.

7. Temel imajlar sabit sürümle yazılır.

Go için distroless/static nonroot (bizde 20–31 MB). Next için output standalone ve node:24-alpine (bizde Dockerfile'lı Next 77–92 MB). Statik site için nginx alpine (35 MB). Next için buildpacks kullanılmaz: imaj 5 kat büyük ve builder sürümü kayıyor. Etiketler sabit sürümle yazılır (node:24-alpine, golang:1.27-alpine); alpine:latest ya da builder:latest kullanılmaz. golang etiketindeki sürüm go.mod'daki go satırıyla ve sürüm taban dosyasıyla aynıdır; ikisi güncelleme gününde birlikte yükselir. Resmi golang imajı başka araç zinciri indirmez; go satırı imajdan yeniyse build durur. Node 24 LTS 30 Nisan 2028'e kadar destekli, Node 26 28 Ekim 2026'da LTS oluyor. Google'a göre imaj boyutu Cloud Run'da soğuk başlangıcı etkilemiyor; bizim ölçümümüzde büyük imajlı servislerin ilk isteği daha uzun sürdü, ama bu bir ilişki, nedensellik ölçülmedi. Küçük imajın kesin kazancı depolama, tarama yüzeyi ve bölgeler arası çıkış.

8. Bir kez build, terfi.

Test dalının ürettiği imaj main'de yeniden build edilmez; main tetikleyicisi onay ister, digest'i `tested-*` etiketinden bulur, migrate job'ını o digest'e çevirip bitmesini bekler, servisi trafiksiz candidate etiketiyle açar, candidate adresinde duman testi yapar, trafiği verir ve etiketleri taşır. Web servislerinde migrate adımı yoktur. Prod'da testte denenen imaj bayt bayt aynı çalışır ve build dakikası yarıya iner.

[öneri] Test hattı, test ortamındaki migrate job'ı ve servis deploy'u geçince imaja `tested-<COMMIT_SHA>` etiketini ekler: `gcloud artifacts docker tags add $_IMG@$$(cat /workspace/digest) $_IMG:tested-$COMMIT_SHA`. main hattı digest'i yalnız bu etiketten okur. Etiket yoksa describe hata verir ve terfi başlamaz. Böylece imajı itilmiş ama test'te migrate ya da deploy'u düşmüş commit prod'a çıkamaz. `tested-*` etiketli imaj 14 gün tutulur ([kural 3](#ar-kural-3)); terfi birkaç gün beklese de imaj silinmez.

```
# cloudbuild.main.yaml: main tetikleyicisi, onay ister, build almaz
substitutions:
  _IMG: europe-west1-docker.pkg.dev/PROJE/DEPO/SERVIS
  _SERVICE: SERVIS
  _JOB: SERVIS-migrate
  _R: europe-west1
steps:
- id: digest
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    gcloud artifacts docker images describe $_IMG:tested-$COMMIT_SHA \
      --format='value(image_summary.digest)' > /workspace/digest
    test -s /workspace/digest
- id: migrate
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    D=$$(cat /workspace/digest)
    gcloud run jobs update $_JOB --image=$_IMG@$$D --region=$_R
    gcloud run jobs execute $_JOB --region=$_R --wait
- id: candidate
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    gcloud run deploy $_SERVICE --image=$_IMG@$$(cat /workspace/digest) \
      --region=$_R --no-traffic --tag=candidate
- id: smoke
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    U=$$(gcloud run services describe $_SERVICE --region=$_R \
      --format='value(status.url)')
    C=$$(echo "$$U" | sed 's#https://#https://candidate---#')
    curl -fsS --retry 5 --retry-all-errors "$$C/health" > /dev/null
- id: traffic
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: gcloud
  args: [run, services, update-traffic, $_SERVICE, --region=$_R,
         --to-tags=candidate=100]
# son adım: mark (kural 4)
options:
  logging: CLOUD_LOGGING_ONLY
```

Web servisinde Worker öndeyse (EDGE_KEY tanımlı), kapı kenar anahtarı taşımayan her isteğe 403 döner; /health de buna dahildir. candidate adresi run.app'tir ve Worker'dan geçmez. Bu yüzden web'in smoke adımı anahtarı başlıkta taşır; sırda iki değer varsa ilkini gönderir. API'de başlık gerekmez.

```
# web için cloudbuild.main.yaml eki
availableSecrets:
  secretManager:
  - versionName: projects/PROJE/secrets/web-edge-key/versions/latest
    env: EDGE_KEY
# smoke adımına eklenir:
  secretEnv: [EDGE_KEY]
# smoke adımındaki curl satırı:
    curl -fsS --retry 5 --retry-all-errors \
      -H "x-edge-key: $${EDGE_KEY%%,*}" "$$C/health" > /dev/null
```

Build hesabına yalnız bu sır için secretAccessor rolü verilir. Adımda set -x açılmaz, anahtar loga düşmez. Anahtar ayda bir değiştiğinde versions/latest yeni değeri okur.

9. Next'te public ayar build'e gömülmez, çalışma anında okunur.

Terfi ancak imaj ortamdan bağımsızsa çalışır. `NEXT_PUBLIC_` önekli değişken kalmaz; değerler düz adla (`SITE_URL`, `API_ORIGIN`) Cloud Run ortamında durur. Sunucu kodu bunları istek anında okur; ortama göre değişen bir şey okuyan sayfa build'de ön üretilmez (dinamik ya da boş generateStaticParams ile ISR). canonical, og:url ve sitemap istek anında kurulur, CSP origin'leri aynı değişkenlerden türetilir. Tarayıcıya gereken değerler dinamik bir route'tan gelir; istemci bir kez okur ve bellekte tutar. Terfiden sonra prod'da canonical ve bu route curl ile okunur.

```
// app/runtime-config/route.ts: tarayıcıya giden ayar çalışma anında
import { connection } from "next/server";
export async function GET() {
  await connection(); // build'de ön üretilmez; cacheComponents açıkken de
  return Response.json(
    { apiOrigin: process.env.API_ORIGIN, siteUrl: process.env.SITE_URL },
    { headers: { "Cache-Control": "no-store" } });
}
```

[öneri] `export const dynamic` yerine `await connection()` kullanılır. 'use cache' için `cacheComponents` açılırsa dynamic satırı build'i durdurur. Satır silinirse route build'de ön üretilir ve env build'deki değerle donar. `connection()` iki durumda da gerçek isteği bekler. Sayfaya ve sitemap'e konmaz. Onları ISR çalışma anında üretir ve son iyi kopyayı tutar. `connection()` ise her isteği arka uca götürür.

10. Geri dönüş her yeni projede bir kez denenir.

Bir önceki canlı imaj AR'de durmadan yeni deploy yapılmaz; prev etiketi bunu sağlar. Geri dönüş tek komuttur (ilk blok). Hemen ardından etiketler trafiğe eşitlenir (ikinci blok): live geri dönülen imaja, prev kötü imaja geçer. Kötü imaj korunur, çünkü migration geri alınmaz ve migrate job'ı hâlâ ona bakar. Bu adım atlanırsa live kötü imajda kalır ve bir sonraki terfi iyi imajı prev'den düşürür.

```
gcloud run services update-traffic SERVIS --to-revisions=ONCEKI=100 \
  --project PROJE --region europe-west1
```

```
IMG=europe-west1-docker.pkg.dev/PROJE/DEPO/SERVIS
KOTU=$(gcloud artifacts docker images describe $IMG:live \
  --project PROJE --format='value(image_summary.digest)')
IYI=$(gcloud run revisions describe ONCEKI --project PROJE \
  --region europe-west1 --format='value(status.imageDigest)')
gcloud artifacts docker tags add $IMG@$KOTU $IMG:prev --project PROJE
gcloud artifacts docker tags add $IYI $IMG:live --project PROJE
```

11. Build kotası sayılır.

Varsayılan havuzda e2-standard-2 için faturalama hesabı başına ayda 2.500 dk ücretsiz, sonrası $0,006/dk, saniye bazında. İki ürün kotayı aşıyorsa ayrı faturalama hesabı açılır. Tetikleyiciye includedFiles ve ignoredFiles eklenir, yalnız belge değişen push build almaz. Build kaynak kovasına 30 günlük silme kuralı konur.

## Denenebilecekler

| Deneme | Beklenen etki | Risk ve not |
|---|---|---|
| Bölgesel tetikleyici (europe-west1) | AR'den çekme her zaman ücretsiz olur, önbelleğin önü açılır, kaynak kod ve build AB'de kalır. | Düşük. 1. nesil GitHub App tetikleyicileri bölge seçebiliyor; tetikleyiciler yeniden kurulur. |
| live, prev ve deployed- etiketleri | Geri dönüş penceresi çoğu serviste 1–6 günden 30 güne çıkar, canlı ve önceki imaj hiç silinmez; ayda ~$0,40. | live ve prev adımının hatası build'i kırmızı bitirir; deployed- etiketi deploy'u düşürmez (`// true`). |
| Buildpack UI'ları Dockerfile kalıbına taşımak | İki UI imajı 420–456 MB'tan Dockerfile'lı Next'in 77–92 MB'ına iner; depolama, çekme ve çıkış küçülür. | Düşük. Next'te output standalone açılır, ortak Dockerfile kopyalanır. |
| Kayıt önbelleği (BuildKit --cache-to type=registry) | Tahmin, ölçülmedi: Go build adımı 3–4,5 dk'dan ~1,5–2 dk'ya inebilir. | Önbellek imajı 0,3–0,6 GB tutar ve KEEP kuralı ister. Yalnız bölgesel build'de; global build'de kıtalar arası çıkış kazancı yer. |
| Docker Hub için uzak depo (pull-through önbellek) | Docker Hub sınırına (IP başına 6 saatte 100 çekme, Cloud Build adresleri ortak) ve Hub kesintisine karşı koruma; ayda ≤$0,10. | Ağustos'tan beri ~1.250 build'de sınır hatası görülmedi, öncelik düşük. Depo build'le aynı bölgede olur; FROM satırları değişir. |
| SBOM (docker buildx build --sbom=true ya da Syft) | Bir olayda 'hangi canlı imajda X kütüphanesi var' sorusu hemen cevaplanır; ücretsiz. | Düşük; build'e 10–20 sn ekler. AR'nin kendi SBOM'u tarama ister (imaj başına $0,26). |
| Köken doğrulama | Cloud Build her imaja zaten SLSA kökeni ekliyor; denenecek olan doğrulama komutu. | Binary Authorization gerekmez. |
| GitHub Actions ve Workload Identity Federation | Cloud Build dakikası sıfıra iner, Actions önbelleğiyle katman önbelleği bedava olur; anahtar dosyası gerekmez. Free planda özel depolara ayda 2.000 dk. | Bakılacak ikinci bir sistem. ABD'deki runner AR'ye itince ücret yok, AR'den çekerse çıkış ücreti doğar. Ne zaman: bir hesap iki ay üst üste 2.500 dk'yı aşarsa. |
| İmaj boyutu bütçesi | Go 40 MB, Next 120 MB, statik 50 MB; sınır aşılırsa build düşer. Buildpacks'e kayma ya da dev bağımlılıklarının imaja girmesi gibi 5 katlık hataları yakalar. | Meşru büyümede bütçe güncellenir. |
| Önceki revizyona trafik etiketi (ör. prev) | Etiketli revizyonun imaj kopyası saklanıyor olabilir; doğrulanmadı. | Herkese açık serviste eski kod kendi adresinden erişilebilir kalır. |

### Denenmeye değmez

Bakıldı ve bu ölçekte reddedildi.

**Sanal depo.** Tek kaynakla anlamsız.

**Build deposunda değiştirilemez etiket.** Temizliği durdurur; yalnız ayrı bir release deposunda denenir.

**Cloud Build özel havuzu.** Ücretsiz kota yalnız varsayılan havuzda geçerli; özel havuz ancak VPC ya da sabit IP gerekince anlamlı.

**e2-highcpu-8.** $0,0156/dk ve kotaya girmiyor; build ancak 2,6 kat hızlanırsa başa baş.

**kaniko.** Haziran 2025'te arşivlendi.

<a id="kvkk"></a>

KVKK ve veri yeri

# Veri nerede duruyorsa öyle yazılır

Veri bölgesi, işleyen listesi ve aktarım dayanağı proje doğarken yazılır. Kurumsal müşteriler verinin ve yedeğin yerini ilk toplantıda soruyor.

₺90.308–1.806.177
Bildirilmeyen standart sözleşmenin 2026 cezası.
5 iş günü
Standart sözleşme imzalandıktan sonra Kurum'a bildirim süresi.

## Yap

[öneri]
** Veri yeri proje doğarken yazılır** (Cloud Run Belçika, Neon Frankfurt, mail bölgesi); 'veri AB'de' denir, Türkiye'de olmayana 'Türkiye'de' denmez.
[öneri]
** İşleyenler**: Google Cloud, Neon, Resend (hesap verisi ABD'de), Cloudflare (proxy açıksa IP ve istek), Expo, Apple ve Google, RevenueCat, AdMob, OpenAI, Clarity, kullanılırsa Sentry.
[öneri]
** KVKK m.9** (1 Haz 2024'ten beri): her işleyenle standart sözleşme, imzadan sonra 5 iş günü içinde Kurum'a bildirim; bildirilmezse 2026'da ₺90.308–1.806.177; metin ve VERBİS sorusu hukukçuya.
[öneri]
** Her yeni SDK'dan önce liste, aydınlatma metni, App Store etiketi ve Play Data safety güncellenir**.
[öneri]
** Hata telemetrisi önce birinci taraf**; üçüncü taraf hukuki adımdan sonra.
[kanıtlı]
** Analitik onaydan önce istek atmaz, alanlar maskelenir**; kimlik yazılan formlarda session replay yok; loglarda yalnız sayı ve IP hash'i.
[öneri]
** İstisna**: kullanıcı içerik yayımlıyorsa (ilan, yorum, mesaj) içerik yazan isteğin ham IP'si, alınabiliyorsa portu ve zamanı 5651 için ayrı bir tabloda 13 ay tutulur ve süre gizlilik metnine yazılır. Ayrıntı [Gün 0 önlemleri 18](#onlem-18)'de, kapsamı hukukçu söyler.
[öneri]
** Gizlilik metnindeki süreler yedek, proje dışı kopya ve soft delete dahil gerçek azami süredir**; geri yüklemede silmeler yeniden uygulanır.
[öneri]
** Kurumsal müşteri canlı sistemi ve yedeği Türkiye'de isteyebilir**. GCP Türkiye bölgesi 20 Kas 2025'te tarihsiz duyuruldu; açılınca Cloud Run, kovalar ve yedekler taşınabilir. Neon'da Türkiye bölgesi yok: veritabanı Türkiye'de ancak başka bir Postgres'le (Cloud SQL ya da kendi sunucumuz) durur, Neon'un uyuma kazancı da o gün gider.

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

<a id="asla"></a>

# Asla

Yeni projede gün 0'dan geçerli kurallar.

1
Yerel, test ya da CI varsayılanını asla prod yapma.

2
Veritabanı hatasında asla 401 dönme; başarısız işi 2xx ile yutma.

3
API'yi asla alan silerek ya da değiştirerek büyütme; yalnız ekle.

4
Canlı bir adresi asla kalıcı 308 olmadan değiştirme.

5
Neon'a bağlı serviste asla MinConns>0, soran ticker ya da veritabanına dokunan /health bulundurma.

6
Pooled bağlantıda asla oturum advisory lock, SET ya da LISTEN kullanma.

7
Ona dayanan kodu asla migration bitmeden yayına verme; migration hattın kendi adımında, bitmesi beklenerek ve yalnız ekleyerek koşar.

8
Prod'a asla test'te doğrulanmamış artefakt ve ürün sahibinin istemediği sürüm çıkarma.

9
Hiçbir runtime'ı Editor yetkili hesapla çalıştırma; JSON anahtarı diskte bırakma; sırrı düz env'e koyma.

10
Herkese açık test ortamına asla gerçek ücretli anahtar koyma. Ücretli anahtar ancak kimlik doğrulama arkasında ve sağlayıcıda sert tavanla.

11
Ücretli API'yi asla rakamı ve sert tavanı olmadan çağırma.

12
İlk mağaza sürümünü asla uzaktan kontrol kiti olmadan çıkarma: zorunlu güncelleme, duyuru alanı ve ekran içi uyarı, push, bayrak ve kill switch, bakım modu ve sürüm telemetrisi. OTA önerilir; OTA ve yerel build'i ortamı vermeden alma.

13
Zorunlu güncellemeyi asla Play'de yayın %100 olmadan ve App Store sürümü yayında değilken açma.

14
Cloudflare'de SEO hedefi varken asla 'Block' seçme; purge'süz HTML ya da Set-Cookie'li yanıtı önbelleğe alma.

15
Bot kuralını asla gölgeden geçirmeden zorlama; yeni sitede gün 0'da yalnız başka sitelerde gölgeden geçmiş ortak liste reddeder.

16
Geri yüklemeden sonra silmeleri uygulamadan asla trafiğe açma.

17
Yeni SDK'yı asla KVKK listesi ve mağaza etiketleri güncellenmeden çıkarma.

<a id="onlemler"></a>

Ek

# Gün 0 önlemleri

Bu liste, Neon, Go, Next.js ve Expo ile Google Cloud'da kurulan yeni bir projenin başına bir iki yıl içinde gelmesi gerçekçi olan riskleri ve gün 0'da alınacak önlemleri toplar. Çoğu birkaç saatle ya da birkaç dolarla önlenir; sonradan önlemek haftalar, para cezası ya da geri gelmeyen veri demektir. Sıra olasılık ile etkinin önlem bedeline oranıdır. AI, kullanıcı içeriği, abonelik, ödeme ve ticari ileti maddeleri yalnız o özellik varsa geçerlidir. Fiyatlar Ekim 2026'nın (1 USD = 49 TL), hukuki tutarlar 2026 yılınındır. "Rehberde" satırı, önlemin hangi kısmının Proje Kurulum Rehberi'nde zaten yazılı olduğunu söyler.

Kırmızı kenarlı ilk on madde her projede yapılır; 11 ile 26 arası yalnız o özellik ya da durum varsa. "Gün 0 önlemi" satırı yapılacak işi, "Rehberde" satırı rehberin o konuda zaten söylediğini gösterir.

**Kurulum planındaki yeri:** Her önlem [kurulum planının](#kurulum-plani) bir adımında yapılır ve STATUS'a madde numarasıyla yazılır.

**2. adımda** 5 ve 6'nın ajan ayar dosyası ve ajan dosyası satırları.

**3. adımda** 1 ve 20'nin hesap kısmı.

**4. adımda** 13 ve 7'nin harcama tavanı.

**5. adımda** 15.

**6. adımda** 2, 10 ve 6'nın force push yasağı.

**7. adımda** 6'nın korumalı dalı ve ajanın salt okunur rolü, 7'nin test projesi kotası.

**9. adımda** 5'in salt okunur hesabı ve 2'nin sır döndürme provası.

**11. adımda** 8 ve 22.

**12. adımda** 9'un ihlal planı, 25 ve 17, 18, 23, 24 ve 26'nın hukukçuya ve mali müşavire giden sorusu.

**15. adımda** 11, 21 ve 20'nin Team ID kısmı.

**16. adımda** 9'un 400 günlük log kovası ve 7'nin kova çıkışı alarmı.

**23. adımda** 10'un yama provası.

**27. adımda** 4 ve 12.

3'ün yolları gezen testi akışların ilk ucundan önce depoda olur. 14, 16 ve 17 AI özelliği, 18, 19 ve 23 kullanıcı içeriği, 24 web'den satış açılmadan; 26 ilk mağaza ya da reklam ödemesinden önce yapılır. Ürünün hangi özellikleri olacağı 1. adımda sorulur; geçerli olmayan madde DECISIONS'a 'özellik yok' diye yazılır.

### 1. Bütün hesapların anahtarı tek kişide, kurtarma tek telefonda

Bulut, alan adı kayıt şirketi, kod ve mağaza hesapları tek kişinin adresine ve telefonuna bağlı; biri giderse hepsi gider.

**Olasılık ve etki:** orta. **Etki:** kod, veri ve mağaza birlikte gider; veri sızarsa 2026 cezası ₺256.357 ile ₺17.092.242.

**Erken işaret:** tanınmayan giriş, beklenmedik SIM değişikliği.

**Gün 0 önlemi:** Bulut, alan adı kayıt şirketi, kod deposu ve mağaza hesapları şirketin ortak adresinde. Her yerde iki yönetici, kişi başı iki donanım anahtarı, SMS kurtarma kapalı. Google Cloud projeleri kişisel hesaba değil, ücretsiz Cloud Identity ile açılan şirket organizasyonuna bağlanır; iki süper yönetici olur. Essential Contacts'ta güvenlik, askıya alma, faturalama, teknik ve yasal bildirimler ortak adrese gider; kötüye kullanım uyarısı süreli gelir, okunmazsa proje askıya alınabilir. Apple'da Account Holder tek kişidir, ikinci kişi Admin olur. GitHub'da organizasyon ve iki owner. Kurtarma kodları basılı, iki yerde; tek sayfa hesap envanteri.

**Önlemin bedeli:** dört anahtar ~$116 (~₺5.700), yarım gün.

**Rehberde:** kısmen; [İçerik otomasyonu](#icerik) › Hattın on bir parçası › 1 (sosyal hesaplar), [Veritabanı yedeği ve geri yükleme](#yedek) › Katmanlar › Proje dışı kopya.

**Kaynak:** [yubico.com/us/product/security-key-nfc-by-yubico](https://www.yubico.com/us/product/security-key-nfc-by-yubico/), https://docs.cloud.google.com/resource-manager/docs/manage-essential-contacts, https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/recovering-your-account-if-you-lose-your-2fa-credentials, [kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari](https://www.kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari)

### 2. Zararlı bir paket kurulurken diskteki sırları toplar

Ele geçmiş bir npm sürümü, ajanın çalıştırdığı npx ya da modelin uydurduğu paket adı, kurulum betiğiyle .env dosyalarını ve bulut oturumunu toplar.

**Olasılık ve etki:** orta; Eylül 2025'te Shai-Hulud 500'den fazla paketi ele geçirdi, ticari modellerin önerdiği paketlerin en az %5,2'si yok. **Etki:** sırlar döndürülür; runbook varsa saatler, yoksa günler.

**Erken işaret:** beklenmedik postinstall, GitHub'da tanımadık depo.

**Gün 0 önlemi:** npm 12 ve üstü kullanılır. Bağımlılık betikleri varsayılan kapalıdır; kök package.json'daki allowScripts listesi dar tutulur, her ekleme onaydan geçer. .npmrc'de min-release-age=7 (npm 11.10 ve üstü). npm sürümü Dockerfile'da, CI'da ve EAS'ta sabitlenir, her yerde npm --version ile doğrulanır. Eski npm zorunluysa ignore-scripts=true; bu kökteki postinstall'u da durdurur, patch-package ayrı bir komutla çalışır, betiği gereken paket npm rebuild <paket> ile tek tek kurulur. CI'da yalnız npm ci. Ajanın eklediği paket onaydan geçer; npx expo izinli, bilinmeyen her npx sorulur. Actions commit SHA ile sabit. Diskte canlı sır yok. Her sırrın nerede kullanıldığı ve döndürme sırası runbook'ta durur, test ortamında bir kez prova edilir.

**Önlemin bedeli:** ücretsiz; ayarlar 2 ile 3 saat, runbook provası yarım gün.

**Rehberde:** kısmen; [Yeni depo için kurallar](#depo-kurallari) 8.

**Kaynak:** [cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem), https://docs.npmjs.com/cli/v12/using-npm/config, https://github.com/npm/cli/blob/latest/CHANGELOG.md (12.0.0 ve 11.10.0), https://arxiv.org/abs/2406.10279, https://nvd.nist.gov/vuln/detail/CVE-2025-30066

### 3. Başkasının kaydı kimlik değiştirilerek okunur

Uç kaydı /v1/x/{id} ile okur, sahibini sormaz; kullanıcı kimliği değiştirip başkasının verisini görür. Ajanın yazdığı uçta bu kontrol kolayca eksik kalır.

**Olasılık ve etki:** yüksek; OWASP API Top 10 2023'te birinci sırada. **Etki:** KVKK ihlali ve 72 saatlik bildirim; veri güvenliği cezası 2026'da ₺256.357 ile ₺17.092.242.

**Erken işaret:** bir oturumdan sıralı kimliklerle art arda 404.

**Gün 0 önlemi:** Sahiplik sorgunun içinde: WHERE id = $1 AND user_id = $oturum. Başkasının kaydı 404 döner. Dışarıya sıralı kimlik verilmez. Kullanıcı verisi dönen her uç için iki kullanıcılı test yazılır: A'nın token'ıyla B'nin kimliği 404. Router'daki bütün yolları gezen bir test, sahiplik testi olmayan ucu bulur.

**Önlemin bedeli:** yarım gün.

**Rehberde:** yok; Admin'de asla'daki yol testi yalnız admin için.

**Kaynak:** https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization

### 4. Sahte webhook isteği ücretli üyelik açar

Abonelik ya da ödeme webhook'u imzası doğrulanmadan kabul edilir. Adresi bulan biri sahte bir istekle kendine ücretli üyelik açar.

**Olasılık ve etki:** orta; webhook adresi herkese açıktır ve çoğu zaman tahmin edilebilir bir yoldadır. **Etki:** gelir kaybı, sahte üyelikler, mutabakat bozulur.

**Erken işaret:** sağlayıcıda karşılığı olmayan abonelik kaydı.

**Gün 0 önlemi:** Her webhook sağlayıcının imzası ya da paylaşılan sırrıyla doğrulanır, karşılaştırma sabit zamanlıdır. Zaman damgası varsa 5 dakikadan eskisi reddedilir. Yetki gövdeden değil, sağlayıcıdan yeniden okunan durumdan verilir. Test: imzasız istek 401 döner, kullanıcının durumu değişmez.

**Önlemin bedeli:** ücretsiz, 2 ile 3 saat.

**Rehberde:** kısmen; [Go API](#katman-2) › Yap ham gövdeyi kaydediyor ve mutabakat istiyor; imza doğrulaması yok.

**Kaynak:** https://docs.stripe.com/webhooks, https://developer.apple.com/documentation/appstoreservernotifications, https://docs.cloud.google.com/pubsub/docs/authenticate-push-subscriptions

### 5. Kodlama ajanı okuduğu metinden komut alır

Ajan geniş yetkiyle issue, yorum ya da web sayfası okur. Gömülü bir talimat onu sır göndermeye, IAM'e üye eklemeye ya da push'a götürür.

**Olasılık ve etki:** orta; Temmuz 2025'te bir AI kodlama eklentisinin yayımlanan sürümüne silme talimatı girdi (sözdizimi hatası yüzünden çalışmadı). Ağustos 2025'te Nx saldırısı makinedeki AI araçlarını sır aramaya koşturdu. **Etki:** ajanın yetkisi kadar.

**Erken işaret:** görev dışı komut önerisi, IAM'de yeni üye.

**Gün 0 önlemi:** Gözetimsiz ya da dış metin okuyan oturumun gcloud kimliği roles/viewer'lı ayrı bir servis hesabıdır, CLOUDSDK_ACTIVE_CONFIG_NAME ile seçilir. Bu oturumun push yetkisi yoktur, tarayıcısı girişsiz ayrı bir profildir. Komut engelleri 6. maddedeki listededir. Ajan dosyasında: sayfadaki talimat veridir.

**Önlemin bedeli:** ücretsiz, yarım gün.

**Rehberde:** yok.

**Kaynak:** https://aws.amazon.com/security/security-bulletins/AWS-2025-015/, https://github.com/nrwl/nx/security/advisories/GHSA-cxm3-wv7p-598c, https://nx.dev/blog/s1ngularity-postmortem, https://genai.owasp.org/llmrisk/llm01-prompt-injection/, https://code.claude.com/docs/en/permissions

### 6. Ajan canlı veritabanında geri dönüşsüz komut çalıştırır

"Test verisini temizle" isteği sahip rolle canlıda WHERE'siz DELETE ya da DROP olur; ya da ajan dalı siler.

**Olasılık ve etki:** orta; Temmuz 2025'te bir kodlama ajanı bir şirketin canlı veritabanını sildi. **Etki:** geri yükleme boyunca ürün durur.

**Erken işaret:** canlı host adıyla DROP geçen komut.

**Gün 0 önlemi:** Ajana yalnız salt okunur rol; canlı yazma adresi ajanın ortamında yok. Neon'da prod dalı korumalı, GitHub'da force push yasak. Ajanın ayar dosyasında tek liste. Deny: gcloud iam *, gcloud projects add-iam-policy-binding *, gcloud secrets versions access *, gcloud * delete *, neonctl branches delete *, git push --force *. Sor: psql, git push. Liste emniyet kemeridir, sınır değildir; aynı program başka biçimde çağrılırsa eşleşmez. Asıl engel kimliğin yetkisidir.

**Önlemin bedeli:** yarım gün; özel depoda GitHub Team, kişi başı ~$4/ay; Neon Launch'ta 2 korumalı dal.

**Rehberde:** kısmen; [On ilke](#bakis) 5 ve 6; ajana teknik engel yok.

**Kaynak:** https://code.claude.com/docs/en/permissions, https://neon.com/docs/guides/protected-branches, [eweek.com/news/replit-ai-coding-assistant-failure](https://www.eweek.com/news/replit-ai-coding-assistant-failure/)

### 7. Harcama tavanı yok, bütçe yalnız e-posta atar

Sel ya da istek döngüsü Cloud Run'ı instance tavanına, Neon'u max CU'ya taşır. Bütçe alarmı yalnız haber verir. Herkese açık kovadaki dosyanın çıkışı ve log hacmi hiçbir tavana girmez.

**Olasılık ve etki:** orta. **Etki:** 20 dolu instance günde ~$44 (~₺2.150); Neon 8 CU 7/24 ~$620/ay.

**Erken işaret:** instance sayısının 3'ü geçmesi, yeni SKU, kova çıkışında saatlik sıçrama.

**Gün 0 önlemi:** Prod'a normal ayın ~10 katında harcama tavanı. Tavan yalnız Cloud Run, Cloud Run functions, Gemini API ve Vertex AI'ı kapsar. Her bütçe tek proje ve tek hizmet içindir, dönemi yalnız aylıktır; bu yüzden her prod projesine ayrı kurulur. Dolunca ay sonuna kadar o hizmete yeni istek gitmez. Neon'da sert sınır proje tüketim kotasıdır; test ve deneme projelerine konur, prod'a konmaz, çünkü dolunca compute dönem sonuna kadar askıya alınır. Neon harcama bildirimi yalnız e-postadır. Kovanın storage.googleapis.com/network/sent_bytes_count metriğine saatlik alarm kurulur, örneğin 5 GiB. Kullanılmayan API kapalı, yeni API'ye alarm.

**Önlemin bedeli:** $0, bir saat.

**Rehberde:** kısmen; [Bulut altyapısı (Cloud Run)](#katman-6) › Başlangıç ayarları, [Postgres (Neon + pgx)](#katman-1) › Yap, [Uyarılar kime, nasıl ulaşır](#uyarilar) › 4, [Pahalı dış API'ler](#pahali-api) › Kurallar, [Ücretsiz katmanları sonuna kadar kullanmak](#ucretsiz) › İzleme (Cloud Run çıkışı ve log alarmı). Yeni olan harcama tavanı, Neon kotası ve kova çıkışı.

**Kaynak:** https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps, https://cloud.google.com/run/pricing, https://neon.com/docs/guides/consumption-limits, https://neon.com/faqs/postgres-services-capping-monthly-spend-autoscaling, https://cloud.google.com/storage/pricing

### 8. E-posta Türkçe İ yüzünden iki hesaba bölünür

Türkçe klavye ilk harfi İ yapar. JavaScript'te 'İnfo@ornek.com'.toLowerCase() sonucu 'i̇nfo@ornek.com' çıkar, nokta ayrı bir karakterdir. Go'da strings.ToLower aynı adresi info@ornek.com yapar. toLocaleLowerCase('tr') ise INFO'yu ınfo yapar. İstemci ile sunucu aynı adresi farklı yazar: aynı kişiye iki hesap açılır, kod gelmez, satın alma yanlış hesaba düşer.

**Olasılık ve etki:** yüksek; e-posta alanında otomatik büyük harf varsayılan olarak açıktır. **Etki:** bölünmüş hesaplar, kaybolan satın almalar, destek yükü.

**Erken işaret:** "kod gelmedi" şikâyeti, büyük harfle ya da birleşik noktayla kaydedilmiş adres.

**Gün 0 önlemi:** Mobilde ve web'de e-posta alanında autoCapitalize none, autoCorrect kapalı, klavye email türünde. Normalleştirme yalnız sunucuda, tek fonksiyonda yapılır: trim, İ ve I yerine i, i'den sonra gelen birleşik nokta (U+0307) silinir, kalan ASCII küçük harfe çevrilir. İstemci e-postayı küçük harfe çevirmez. Veritabanında lower(email) üzerinde unique index. Test: İnfo@, INFO@ ve info@ aynı hesaba düşer.

**Önlemin bedeli:** 1 saat.

**Rehberde:** yok; [Tasarım sistemi](#tasarim) › Tipografi ve Türkçe karakterler yalnız ekrandaki metni kapsar.

**Kaynak:** [unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt](https://www.unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt), https://pkg.go.dev/strings#ToLower, https://reactnative.dev/docs/textinput#autocapitalize

### 9. Veri ihlalinde 72 saat var, "kim neyi gördü" kaydı yok

Admin oturumu çalınır ya da yetki hatası başkasının kaydını gösterir; Kurul kaç kişi ve hangi veri diye sorar, kayıt yoktur.

**Olasılık ve etki:** orta. **Etki:** Kurul'a 72 saat, ilgili kişiye makul en kısa sürede (Kurul kararı 2019/10); kimin etkilendiği bilinmiyorsa bildirim geniş tutulur. Veri güvenliği cezası ₺256.357 ile ₺17.092.242.

**Erken işaret:** kovaya allUsers eklenmesi, olağandışı admin indirmesi.

**Gün 0 önlemi:** Kişisel veri dönen her API isteğinin log satırında kullanıcı kimliği, kayıt kimliği ve IP. Bu satırlar bir log yönlendiricisiyle 400 gün saklanan kovaya gider, çünkü varsayılan kova 30 gün tutar. DATA_READ varsayılan kapalıdır; belge kovası ve sırlar için açıkça açılır. İhlal planı tek sayfa: 72 saat ihlalin öğrenildiği anda başlar, kimin karar verdiği, Kurul bildirim formunun bağlantısı ve kullanıcıya gidecek metnin taslağı.

**Önlemin bedeli:** yarım gün, ayda birkaç kuruş.

**Rehberde:** kısmen; [Analitik ve admin](#analitik) › Denetim kaydı adminin okumasını ve yazmasını kaydediyor; kullanıcı tarafındaki okuma ve kova okuması yok.

**Kaynak:** [kvkk.gov.tr/Icerik/5362/Veri-Ihlali-Bildirimi](https://www.kvkk.gov.tr/Icerik/5362/Veri-Ihlali-Bildirimi), [kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari](https://www.kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari), https://docs.cloud.google.com/storage/docs/audit-logging, https://docs.cloud.google.com/logging/docs/routing/overview

### 10. Destek dışı kalan sürüm, yetişmeyen yama

Sürüm güvenlik desteğinden çıkar; sonraki açığın yaması yalnız yeni ana sürüme gelir, geçiş acile döner.

**Olasılık ve etki:** yüksek; Next her ana sürümü çıkışından 2 yıl, Go her sürümü iki yeni sürüm çıkana kadar (yaklaşık 1 yıl), Node her LTS'i 30 ay destekler. **Etki:** Aralık 2025'teki React2Shell (CVSS 10) App Router kullanan Next 15 ve 16'da kimlik doğrulamasız kod çalıştırıyordu.

**Erken işaret:** yamanın yalnız yeni ana sürüme gelmesi.

**Gün 0 önlemi:** Taban sürüm dosyasında her satırın destek bitiş tarihi, CI 60 gün kala uyarır. Kritik yamanın aynı gün prod'a çıkışı bir kez prova edilir.

**Önlemin bedeli:** yarım gün.

**Rehberde:** kısmen; [Yeni depo için kurallar](#depo-kurallari) 8 (taban dosyası ve Renovate); bitiş tarihi ve CI uyarısı yok.

**Kaynak:** https://nextjs.org/support-policy, https://go.dev/doc/devel/release, https://github.com/nodejs/Release, https://nextjs.org/blog/CVE-2025-66478, https://nvd.nist.gov/vuln/detail/CVE-2025-55182

### 11. Mağazaların yıllık şartı güncellemeyi durdurur

Play her 31 Ağustos'ta hedef API'yi, Apple her nisan Xcode sürümünü yükseltir; eski kütüphaneler yeni araçlarla derlenmez. Expo SDK 55'ten beri yeni mimari zorunlu; eski mimari isteyen kütüphane SDK geçişini durdurur.

**Olasılık ve etki:** yüksek; 31 Ağustos 2026'dan beri API 36, 28 Nisan 2026'dan beri Xcode 26 gerekiyor. **Etki:** son tarihten sonra güncelleme çıkmaz.

**Erken işaret:** yeni yılın şart duyurusu.

**Gün 0 önlemi:** Expo en çok bir SDK geride. Nisan, 31 Ağustos ve Expo çıkışları 60 gün önceden takvimde. SDK geçişi son tarihten önce test ortamında biter.

**Önlemin bedeli:** yeni projede sıfır; geç kalınca haftalar.

**Rehberde:** kısmen; [React Native (Expo) mobil](#katman-4) › Yap (New Arch, hedef API); takvim yok.

**Kaynak:** https://developer.android.com/google/play/requirements/target-sdk, https://developer.apple.com/news/upcoming-requirements/, https://docs.expo.dev/guides/new-architecture/

### 12. Abonelik zammı aboneleri sessizce düşürür

Play'de zam varsayılan olarak onay ister; eski fiyat grubu taşınırsa onay vermeyen abone yenileme gününde iptal olur. Apple'da zam %50'yi ve dönem başına ~$5'ı (yıllık abonelikte ~$50'ı) birlikte aşarsa, son 12 ayda zam olduysa ya da abone her zam için onay isteyen bir bölgedeyse abone onay vermelidir.

**Olasılık ve etki:** yüksek; TL fiyatı her yıl güncellenir. **Etki:** aboneler fark etmeden düşer.

**Erken işaret:** zamdan sonraki hafta iptallerde sıçrama.

**Gün 0 önlemi:** Liste fiyatı baştan hedef fiyat, indirim tanıtım teklifiyle. Zam yalnız yeni abonelere: Apple'da mevcut fiyat korunur, Play'de eski grup taşınmaz. Zam yılda bir, hep aynı ay.

**Önlemin bedeli:** para yok, bir mağaza ayarı.

**Rehberde:** yok.

**Kaynak:** https://developer.apple.com/help/app-store-connect/manage-subscriptions/manage-pricing-for-auto-renewable-subscriptions, https://developer.android.com/google/play/billing/price-changes

### 13. Kart düşerse aynı faturalama hesabındaki her şey durur

Kartın süresi biter, limiti dolar ya da kartı veren kuruluş yurt dışı işlemi reddeder. Yedek yöntem yoksa Google faturalama hesabını askıya alır; API, site ve yedek işi birlikte durur.

**Olasılık ve etki:** orta. **Etki:** faturalanan bütün servisler kapanır, bazı kaynaklar silinebilir.

**Erken işaret:** "ödeme başarısız" e-postası.

**Gün 0 önlemi:** Ödeme profiline başka bir kuruluşun yedek kartı. Faturalama yöneticisi rolü ikinci kişide. Dolar çeken her servis ve kartı tek tabloda, kartta yurt dışı işlem açık. Fatura postası ortak adrese.

**Önlemin bedeli:** $0, bir saat.

**Rehberde:** kısmen; [Gözlem ve alarmlar](#katman-10) › Yap (kart bitiş takvimi), [Veritabanı yedeği ve geri yükleme](#yedek) › Katmanlar › Proje dışı kopya (askıda veri kaybı). Yedek kart ve ikinci faturalama yöneticisi yok.

**Kaynak:** https://docs.cloud.google.com/billing/docs/how-to/payment-methods, https://docs.cloud.google.com/billing/docs/how-to/restart-services

### 14. Model anahtarı: prod ve denemeler aynı havuzda

Ürünün AI özelliği, eval'ler ve kodlama ajanları tek anahtarı ve tek aylık sınırı paylaşır. Bir deneme ya da sızan anahtar sınırı doldurunca prod 429 alır.

**Olasılık ve etki:** orta. **Etki:** AI özelliği durur; çalınan anahtarla model kullanımının günde $46.000'ı aşabileceği 2024'te hesaplandı.

**Erken işaret:** 429, beklenmedik gece kullanımı.

**Gün 0 önlemi:** Prod, eval ve kodlama ajanı için ayrı çalışma alanı, ayrı anahtar ve ayrı aylık sınır. Kullanıcı başına günlük kota veritabanında. 429 ya da 5xx gelince özellik kurala düşer ve alarm verir.

**Önlemin bedeli:** $0, 15 dakika.

**Rehberde:** kısmen; [On ilke](#bakis) 8, [Asla](#asla) 9 ile 11. Prod ile deneme ve ajan kullanımının ayrı çalışma alanı yok.

**Kaynak:** https://support.claude.com/en/articles/9796807-creating-and-managing-workspaces-in-the-claude-console, [sysdig.com/blog/llmjacking-stolen-cloud-credentials-used-in-new-ai-attack](https://www.sysdig.com/blog/llmjacking-stolen-cloud-credentials-used-in-new-ai-attack)

### 15. Alan adının süresi dolar ya da eski kaydı devralınır

Yenileme kaçar; yeni sahip MX kurup o adresli hesapların sıfırlama postasını alır. Silinen servise bakan sarkık DNS kaydı da devralınabilir.

**Olasılık ve etki:** düşük ile orta. **Etki:** e-posta, giriş kodları ve "Google ile giriş" hesapları birlikte gider.

**Erken işaret:** kayıt şirketinden beklenmedik değişiklik postası.

**Gün 0 önlemi:** Transfer kilidi etkin, otomatik yenileme, en az iki yıl. CAA eklenirse pki.goog ve letsencrypt.org birlikte. Servis silinince DNS kaydı da silinir. Kullanıcısı olmuş alan adı bırakılmaz.

**Önlemin bedeli:** 1 saat, yıllık ücret.

**Rehberde:** kısmen; [Gözlem ve alarmlar](#katman-10)'da yenileme takvimi; kilit, CAA ve sarkık kayıt yok.

**Kaynak:** https://trufflesecurity.com/blog/millions-at-risk-due-to-google-s-oauth-flaw, https://docs.cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs, https://developer.mozilla.org/en-US/docs/Web/Security/Attacks/Subdomain_takeover

### 16. Üründeki AI özelliği kullanıcının metninden komut alır

AI özelliği belge, e-posta ya da web sayfası okur ve araç çağırır. Gömülü talimat başka kullanıcının verisini çeker ya da cevaba gizlenen görsel bağlantısıyla veriyi dışarı yollar.

**Olasılık ve etki:** orta; Haziran 2025'te EchoLeak (CVE-2025-32711, CVSS 9.3) tek bir e-postayla tıklamasız veri sızdırılabileceğini gösterdi; sağlayıcı açığı sunucu tarafında kapattı. **Etki:** kullanıcılar arası sızıntı, KVKK ihlali.

**Erken işaret:** model çıktısında dış adresli bağlantı ya da görsel.

**Gün 0 önlemi:** Model yalnız isteyen kullanıcının verisini görür, araçlar onun yetkisiyle çalışır. Araç sonuçları modele veri olarak etiketlenip girer. Yazan araç kullanıcı onayı ister. Model çıktısındaki Markdown görsel ve bağlantılar yalnız izinli alan adlarına çizilir, gerisi düz metin kalır; CSP img-src de aynı listeyi kullanır. Gömülü talimat taşıyan 10 belgelik bir test seti her model değişikliğinde koşar.

**Önlemin bedeli:** 1 gün.

**Rehberde:** yok.

**Kaynak:** https://genai.owasp.org/llmrisk/llm01-prompt-injection/, https://nvd.nist.gov/vuln/detail/CVE-2025-32711

### 17. AI özelliğinde açık izin adımı yok

AI özelliği kişisel veriyi üçüncü taraf bir modele gönderir, sağlayıcıyı adıyla söyleyen izin adımı yoktur. Apple 5.1.2(i) üçüncü taraf AI ile paylaşımdan önce açık izin istiyor. Sağlayıcı yurt dışındaysa veri yurt dışına aktarılmış olur (6698 m.9).

**Olasılık ve etki:** orta. **Etki:** Apple reddederse özellik kapanır, yeni build gerekir. Aktarım bildirilmezse 2026'da ₺90.308 ile ₺1.806.177; aydınlatma eksikse ₺85.437 ile ₺1.709.200.

**Erken işaret:** App Review'da 5.1.2 notu.

**Gün 0 önlemi:** İlk kullanımdan önce tek seferlik ekran: sağlayıcının adı, ne gider, kaç gün saklanır, "Kabul ediyorum". Onay metin sürümüyle sunucuda, onaysız istek reddedilir. Sağlayıcıyla standart sözleşme imzalanır, 5 iş günü içinde Kurum'a bildirilir (6698 m.9/5). İzin ekranı Apple 5.1.2(i) içindir, aktarım dayanağı değildir. Sağlayıcının saklama şartı işleyen listesinde.

**Önlemin bedeli:** yarım gün.

**Rehberde:** kısmen; [KVKK ve veri yeri](#kvkk) › Veri nerede duruyorsa öyle yazılır (m.9, işleyen listesi); izin ekranı yok.

**Kaynak:** https://developer.apple.com/app-store/review/guidelines/, [mevzuat.gov.tr/mevzuatmetin/1.5.6698.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6698.pdf), [kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari](https://www.kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari) (2026 tablosu)

### 18. İçeriğin yazarı sorulunca IP ve zaman kaydı yok (5651)

Kullanıcı yorum, ilan ya da mesaj yayımlıyorsa ürün yer sağlayıcı sayılabilir; 5651 m.5/3 trafik bilgisini 1 ile 2 yıl ister, loglar ise 30 günde silinir. Gerçekçi tetik: dolandırıcılık soruşturması.

**Olasılık ve etki:** orta. **Etki:** m.5/6'da kanun metni ₺100.000 ile ₺1.000.000. Kabahatler Kanunu m.17/7 yeniden değerlemesiyle 2026'da yaklaşık ₺948.169 ile ₺9.481.783 (hesaplanmış, resmî tablo yok; kesin tutar hukukçuya). Cezayı Siber Güvenlik Başkanı verir (7590 sayılı Kanun). Silinen kayıt geri gelmez.

**Erken işaret:** kolluktan ilk bilgi yazısı.

**Gün 0 önlemi:** İçerik yazan her istekte tek satır: kullanıcı, içerik, işlem, IP, alınabiliyorsa port, zaman; 13 ay sonra silinir. Süre gizlilik metninde. Sitede tanıtıcı bilgiler (m.3).

**Önlemin bedeli:** yarım gün.

**Rehberde:** yok; [KVKK ve veri yeri](#kvkk) › Veri nerede duruyorsa öyle yazılır'daki IP hash'i kuralının istisnasıdır.

**Kaynak:** [mevzuat.gov.tr/mevzuatmetin/1.5.5651.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.5.5651.pdf), [mevzuat.gov.tr/mevzuatmetin/1.5.5326.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.5.5326.pdf) (m.17/7)

### 19. Bildir ve engelle her içerikte yok

Kullanıcılar birbirine içerik gösterebiliyorsa Apple 1.2 filtre, bildirme, engelleme ve iletişim bilgisi ister. Play uygulama içi bildir ve engelle ile içerikten önce kullanım şartı onayı ister.

**Olasılık ve etki:** orta. **Etki:** her ret yeni build ve gün kaybı; 5651'de kaldırma yükü haberdar olunca doğar, zaman damgası yoksa ispat edilemez.

**Erken işaret:** App Review'da 1.2 notu.

**Gün 0 önlemi:** Rapor ve engelleme konuşmayla sınırlı kalmaz, her içerik türünde olur; girişsiz de bildirilir. İçerikten önce kullanım şartı onayı (Play UGC). Admin kuyruğunda hedef süre ve zaman damgalı karar.

**Önlemin bedeli:** uygulama başına 1 ile 2 gün.

**Rehberde:** kısmen; [Gerçek zamanlı ve mesajlaşma](#mesajlasma) › Kurallar › Eski sürümler ve kötüye kullanım 4 ve 5, yalnız konuşma için.

**Kaynak:** https://developer.apple.com/app-store/review/guidelines/, https://support.google.com/googleplay/android-developer/answer/9876937?hl=en

### 20. Mağaza hesabı şahısta açılır, sonra devretmek pahalıdır

Apple 5.1.1(ix) finans ve sağlık gibi alanlarda tüzel kişi ister. Sonradan devirde iOS'ta Team ID'ye bağlı anahtar zinciri ve App Group değişir.

**Olasılık ve etki:** orta. **Etki:** ret gelirse şirket ve D-U-N-S bitene kadar güncelleme yok; devirde bütün iOS kullanıcıları bir kez yeniden giriş yapar.

**Erken işaret:** App Review'da 5.1.1(ix) sorusu.

**Gün 0 önlemi:** Mağaza hesapları ilk gün tüzel kişi adına. Play'de kuruluş hesabı, kişisel hesapların 12 test kullanıcısı ve 14 günlük kapalı test şartına girmez. Team ID ve App Group tek değişkenden üretilir, devir runbook'u depoda.

**Önlemin bedeli:** teknik kısım 1 ile 2 saat; şirket ayrı karar.

**Rehberde:** kısmen; [React Native (Expo) mobil](#katman-4) › Yap, devir yok.

**Kaynak:** https://developer.apple.com/app-store/review/guidelines/, https://developer.apple.com/help/app-store-connect/transfer-an-app/overview-of-app-transfer/, https://support.google.com/googleplay/android-developer/answer/14151465, https://support.google.com/googleplay/android-developer/answer/6230247 (devir)

### 21. Büyük kesintide kullanıcıya haber verecek ikinci kanal yok

Her şey tek bulutta ve tek CDN'in arkasında, uygulamadaki duyuru da API'den gelir. Sağlayıcı aksarsa kullanıcı yalnız "Tekrar dene" görür.

**Olasılık ve etki:** orta; 12 Haziran 2025'te Google Cloud, 18 Kasım 2025'te Cloudflare saatlerce aksadı. **Etki:** sessiz kesinti; sonradan eklenen duyuru adresini eski build'ler hiç öğrenemez.

**Erken işaret:** kullanıcı mesajının alarmdan önce gelmesi.

**Gün 0 önlemi:** Yedek politika ve duyuru dosyası başka bir sağlayıcıda, başka bir alan adında durur. Mobil, politika ucuna ulaşamazsa ilk sürümden itibaren orayı okur. Bir sayfa kesinti runbook'u.

**Önlemin bedeli:** $0, yarım gün.

**Rehberde:** kısmen; [Mobil uzaktan kontrol kiti](#mobilkit) › 404 kuralı ve 7. Bakım modu, [Ücretsiz katmanları sonuna kadar kullanmak](#ucretsiz) › Dış uptime. Eksik olan başka sağlayıcı ve başka alan adı.

**Kaynak:** https://status.cloud.google.com/incidents/ow5i3PPK96RduMcb1SsW, https://blog.cloudflare.com/18-november-2025-outage/

### 22. Bülten ve kampanya iletisi İYS'siz gider

Bülten, kampanya e-postası ve SMS ticari iletidir; onay İYS'de yoksa her şikâyet ayrı ceza olur. Giriş kodu onay istemez.

**Olasılık ve etki:** orta. **Etki:** onaysız ileti 2026'da ₺2.859 ile ₺14.309, toplu gönderimde on katına kadar; reddi işletmemek ₺5.723 ile ₺42.930.

**Erken işaret:** İYS ya da e-Devlet üzerinden ilk şikâyet.

**Gün 0 önlemi:** İYS'ye kayıt. Onay kutusu ayrı ve işaretsiz; İYS dışında alınan onay 3 iş günü içinde İYS'ye yüklenir, ret 3 iş günü içinde uygulanır. Kod ve bülten ayrı listede.

**Önlemin bedeli:** yarım gün.

**Rehberde:** kısmen; [Kullanıcıyı kırmadan değiştirmek](#kirmama) › 5. E-posta ve bildirim, İYS yok.

**Kaynak:** https://iys.org.tr, [mevzuat.gov.tr/mevzuatmetin/1.5.6563.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6563.pdf) (2026 tutarları: Resmî Gazete 25.12.2025, sayı 33118)

### 23. 15 yaş altına hizmet yasağı (1 Kasım 2026)

7578 sayılı Kanun 1 Kasım 2026'dan itibaren sosyal ağ sağlayıcının 15 yaş altına hizmet vermesini yasaklıyor. 15 yaşını dolduranlara ayrıştırılmış hizmet, yaş doğrulama, ebeveyn araçları ve tedbirlerin sitede yayımlanmasını istiyor. Kullanıcıların sosyal etkileşim için metin, görüntü, ses ya da konum paylaştığı ürün kapsama girebilir; yasakta erişim eşiği yok.

**Olasılık ve etki:** düşük ile orta. **Etki:** küresel cironun %3'üne kadar ceza, ardından reklam yasağı ve bant daraltma.

**Erken işaret:** usul ve esasların yayımlanması; e-Devlet ile yaş doğrulama planlanıyor.

**Gün 0 önlemi:** Kayıtta doğum yılı; 15 altı hesap açamaz, yöntem saklanır. Doğrulama adımına yer bırakılır. 15 ile 18 yaş arasına ayrı ayarlar; ücretli üyelik için ebeveyn onayı ve süre sınırına yer bırakılır. Tedbirler sayfası. Kapsam hukukçuya.

**Önlemin bedeli:** bir gün.

**Rehberde:** yok.

**Kaynak:** [resmigazete.gov.tr/eskiler/2026/05/20260501-1.htm](https://www.resmigazete.gov.tr/eskiler/2026/05/20260501-1.htm) (RG 1.5.2026, sayı 33240), https://developer.apple.com/documentation/declaredagerange

### 24. Mağaza dışı abonelik satışında tüketici kuralları

Web'den abonelik satılınca mağazanın taşıdığı yük ürüne geçer: ön bilgilendirme, mesafeli sözleşme, cayma ve iptal. İptal yolu kayıttan zorsa şikâyet hakem heyetine gider.

**Olasılık ve etki:** orta, web satışı açılınca. **Etki:** cayma süresi 14 gün; istisna yazılmadıysa koşulsuz iade. İptal 7 gün içinde işlenir (Yönetmelik m.24), kalan ücret 15 gün içinde kesintisiz iade edilir (6502 m.52/5).

**Erken işaret:** ilk iade talebi.

**Gün 0 önlemi:** Ödemeden önce ön bilgilendirme ve sözleşme. Anında ifa edilen dijital hizmette cayma istisnası açıkça yazılır, ifaya başlama onayı alınır. Belirli süreli (örneğin yıllık) abonelik kendiliğinden yenilenmez; süre bitmeden onay alınır ya da abonelik belirsiz süreli kurulur (6502 m.52/3, Yönetmelik m.13). İptal kayıtla aynı kanaldan, aynı kolaylıkta. Mağaza aboneliğinde iptalin yeri uygulamada yazılır.

**Önlemin bedeli:** 1 gün ve bir hukuk okuması.

**Rehberde:** yok.

**Kaynak:** [mevzuat.gov.tr/mevzuatmetin/1.5.6502.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6502.pdf) (m.48 ve m.52; Mesafeli Sözleşmeler Yönetmeliği m.15, RG 27.11.2014, sayı 29188; Abonelik Sözleşmeleri Yönetmeliği m.13, m.24 ve m.25, RG 24.01.2015, sayı 29246)

### 25. VERBİS kararı yazılmadan veri işlemeye başlamak

Ekip büyür ya da ana iş özel nitelikli veriye (sağlık, biyometri) kayar; kayıt gerektiği halde yapılmaz, ilk şikâyette ortaya çıkar.

**Olasılık ve etki:** düşük; çoğu yeni proje istisnada. **Etki:** kayıt ve bildirim cezası 2026'da ₺341.809 ile ₺17.092.242.

**Erken işaret:** çalışan sayısının 50'ye, bilançonun 100 milyon TL'ye yaklaşması.

**Gün 0 önlemi:** İstisna dayanağı tek satır: 50'den az çalışan ve 100 milyon TL'den az bilanço; ana iş özel nitelikli veriyse 10 çalışan ve 10 milyon TL. Bilanço esasına göre defter tutulmuyorsa yalnız çalışan sayısına bakılır (Kurul kararı 2025/2393). Her yıl ve özel nitelikli veri getiren özellikten önce yeniden bakılır.

**Önlemin bedeli:** 1 saat.

**Rehberde:** kısmen; [KVKK ve veri yeri](#kvkk) › Veri nerede duruyorsa öyle yazılır (VERBİS sorusu hukukçuya), eşik yok.

**Kaynak:** [kvkk.gov.tr/Icerik/8577/kisisel-verileri-koruma-kurulunun-04-09-2025-tarihli-ve-2025-1572-sayili-kararinin-uygulama-esaslarina-iliskin-kamuoyu-duyurusu](https://www.kvkk.gov.tr/Icerik/8577/kisisel-verileri-koruma-kurulunun-04-09-2025-tarihli-ve-2025-1572-sayili-kararinin-uygulama-esaslarina-iliskin-kamuoyu-duyurusu) (12.01.2026; kararlar 2025/1572 ve 2025/2393), [kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari](https://www.kvkk.gov.tr/Icerik/8145/6698-sayili-kisisel-verilerin-korunmasi-kanunu-kapsaminda-idari-para-cezasi-tutarlari)

### 26. Şahıs olarak alınan mağaza ve reklam geliri (20/B)

Mağaza ve reklam ödemeleri kişiye gelir. GVK mükerrer 20/B bu kazancı istisna tutar; şart vergi dairesinden istisna belgesi ve bütün hasılatın bu belgeyle Türkiye'de açılan hesaptan tahsili; tahsilat sırasında %15 kesinti yapılır.

**Olasılık ve etki:** orta. **Etki:** şart sağlanmazsa vergi, ceza ve faiz; şirkete geçişte kirli vergi kaydı. 2026 istisna sınırı ₺5.300.000.

**Erken işaret:** vergi dairesi yazısı.

**Gün 0 önlemi:** İlk ödemeden önce belge ve hesap; bütün ödemeler bu hesaba. Hesap bilgisi bir ay içinde vergi dairesine bildirilir (318 Seri No.lu Tebliğ). Tebliğ uygulama platformu üzerinden gelen reklam gelirini kapsıyor; reklam ağı ödemesinin bu sayılıp sayılmadığı mali müşavire sorulur.

**Önlemin bedeli:** ücretsiz, bir müşavir görüşmesi.

**Rehberde:** yok.

**Koşul:** Yalnız şirket kurulmadan, tek kişiyle başlanıyorsa. Finans ve sağlık gibi alanlarda Apple tüzel kişi istediği için ([20. madde](#onlem-20)) bu yol kapalıdır. Web'den satılan abonelik ([24. madde](#onlem-24)) mobil uygulama kazancı sayılmayabilir, mali müşavire sorulur.

**Kaynak:** [mevzuat.gov.tr/mevzuatmetin/1.4.193.pdf](https://www.mevzuat.gov.tr/mevzuatmetin/1.4.193.pdf) (318 Seri No.lu GVK Genel Tebliği, RG 12.01.2022; 2026 tarifesi: 332 Seri No.lu GVK Genel Tebliği, RG 31.12.2025, sayı 33124)

## Rehberde zaten olanlar

Sır taraması ([Yeni depo için kurallar](#depo-kurallari) 1), migration kilidi ([Postgres, Neon + pgx](#katman-1) › Başlangıç ayarları), mobil pakete giren sır ([Güvenlik ve botlar](#katman-8)), ilgili kişi başvurusu ([Veritabanı yedeği ve geri yükleme](#yedek) › Silme ve KVKK), prod'a onay kapısı ([CI/CD ve ortamlar](#katman-7)), yetkinin yalnız Next middleware'de durması ([Go API](#katman-2)).

<a id="kaynaklar"></a>

# Kaynaklar

Fiyatlar ve sınırlar Ekim 2026'da bu sayfalardan okundu. 'İkincil' işaretli olanlar sağlayıcı dışı kaynaktır.

## Sağlayıcı belgeleri ve fiyatlar

**Neon fiyatları**https://neon.com/pricing
**Neon pooler sınırları**https://neon.com/docs/connect/connection-pooling
**Cloud Run domain mapping**https://docs.cloud.google.com/run/docs/mapping-custom-domains
**Cloud Run job'ını zamanlamak (OAuth, :run)**https://docs.cloud.google.com/run/docs/execute/jobs-on-schedule
**Cloud Run fiyatları**https://cloud.google.com/run/pricing
**Cloud Scheduler fiyatları**https://cloud.google.com/scheduler/pricing
**Cloud Build fiyatları**https://cloud.google.com/build/pricing
**Cloud Storage soft delete**https://cloud.google.com/storage/docs/soft-delete
**Cloud Run çıkış özeti (ikincil)**https://cloudchipr.com/blog/cloud-run-pricing
**Alarm maliyeti**https://cloud.google.com/monitoring/alerts/cost-control
**Load Balancing fiyatları**https://cloud.google.com/load-balancing/pricing
**Servis hesabı anahtarı politikası**https://cloud.google.com/resource-manager/docs/organization-policy/restricting-service-accounts
**Next.js cacheHandlers ve refreshTags**https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheHandlers
**Cloudflare AI tarayıcı ayarları**https://blog.cloudflare.com/accountable-mixed-use-ai-crawlers/
**Cloudflare Vary**https://developers.cloudflare.com/cache/concepts/vary/
**Cloudflare Bot Fight Mode**https://developers.cloudflare.com/bots/get-started/bot-fight-mode/
**Cloudflare Workers fiyatları**https://developers.cloudflare.com/workers/platform/pricing/
**Vercel fiyatları**https://vercel.com/pricing
**OpenNext Cloudflare sınırları**https://opennext.js.org/cloudflare
**Resend fiyatları**https://resend.com/pricing
**Expo fiyatları**https://expo.dev/pricing
**EAS yerel build sınırları**https://docs.expo.dev/build-reference/local-builds/
**Play kapalı test şartı**https://support.google.com/googleplay/android-developer/answer/14151465
**Play staged rollout**https://support.google.com/googleplay/android-developer/answer/6346149
**App Store phased release**https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases
**Apple uygulama içi hesap silme**https://developer.apple.com/support/offering-account-deletion-in-your-app/
**Sentry fiyatları**https://sentry.io/pricing/
**Supabase fiyatları**https://supabase.com/pricing
**KVKK standart sözleşme bildirimi**https://www.kvkk.gov.tr/Icerik/8043/Standart-Sozlesme-Bildirim-Modulu-Hakkinda-Kamuoyu-Duyurusu
**KVKK bildirim cezası 2026 (ikincil)**https://www.cottgroup.com/en/legislation/item/standart-sozlesme-bildirim-yukumlulugu-ve-yaptirimlari
**GCP Türkiye bölgesi duyurusu**https://cloud.google.com/blog/products/infrastructure/new-google-cloud-region-coming-to-turkiye/

## Startup kredi programları

Program şartları ve tutarlar 8 Ekim 2026'da bu sayfalardan okundu. Expo ve Resend fiyatları ilk listede.

**Claude for Startups**https://claude.com/programs/startups
**Neon Startup Program**https://neon.com/startups
**Google for Startups Cloud Program**https://cloud.google.com/startup
**AWS Activate kredileri**https://aws.amazon.com/startups/credits
**Microsoft for Startups**https://learn.microsoft.com/en-us/startups/microsoft-for-startups/overview
**Cloudflare for Startups**https://www.cloudflare.com/forstartups/
**Sentry for Startups**https://sentry.io/for/startups/
**PostHog for Startups**https://posthog.com/startups
**GitHub for Startups**https://github.com/enterprise/startups
**OpenAI for Startups (8 Ekim'de 403 döndü)**https://openai.com/startups/
**RevenueCat fiyatları**https://www.revenuecat.com/pricing/
**TÜBİTAK 1512 BİGG resmi özet formu**https://yatirimadestek.gov.tr/pdf/assets/upload/dosyalar/ozet-1512_girisimcilik_destek_programi_bigg.pdf

## Artifact Registry ve Cloud Build

Depolama, tarama ve build fiyatları, temizlik kuralları ve denemeler 8 Ekim 2026'da bu sayfalardan okundu. Cloud Build fiyatları ilk listede.

**Artifact Registry fiyatları**https://cloud.google.com/artifact-registry/pricing
**Artifact Analysis fiyatları (tarama)**https://cloud.google.com/artifact-analysis/pricing
**AR temizlik kuralları**https://docs.cloud.google.com/artifact-registry/docs/repositories/cleanup-policy
**Cloud Run'a deploy (imaj kopyası)**https://docs.cloud.google.com/run/docs/deploying
**Cloud Run genel ipuçları (imaj boyutu)**https://docs.cloud.google.com/run/docs/tips/general
**GitHub tetikleyicisinde bölge**https://docs.cloud.google.com/build/docs/automating-builds/github/build-repos-from-github
**AR uzak depo**https://docs.cloud.google.com/artifact-registry/docs/repositories/remote-repo
**Artifact Analysis SBOM**https://docs.cloud.google.com/artifact-analysis/docs/sbom-overview
**Build kökeni üretme ve doğrulama**https://docs.cloud.google.com/build/docs/securing-builds/generate-validate-build-provenance
**Workload Identity Federation ile deploy**https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines
**google-github-actions/auth**https://github.com/google-github-actions/auth
**Docker Hub çekme sınırları**https://docs.docker.com/docker-hub/usage/pulls/
**kaniko (arşivlendi)**https://github.com/GoogleContainerTools/kaniko
**Node.js sürüm takvimi**https://raw.githubusercontent.com/nodejs/Release/main/schedule.json
**GitHub Actions fiyat değişikliği (ikincil)**https://itbrief.news/story/github-cuts-actions-runner-prices-adds-new-usage-fee

## Mobil uzaktan kontrol ve dağıtım

Mağaza kuralları, Expo ve EAS belgeleri, CI ve OTA seçenekleri; 8 Ekim 2026'da okundu.

**App Store İnceleme Kuralları (2.1(a), 2.3.1, 2.5.2, 3.2.2, 4.5.4)**https://developer.apple.com/app-store/review/guidelines/
**Apple Developer Program lisans sözleşmesi, 3.3.1(B)**https://developer.apple.com/support/terms/apple-developer-program-license-agreement/
**Google Play cihaz ve ağ kötüye kullanımı politikası**https://support.google.com/googleplay/android-developer/answer/9888379
**Play uygulama içi güncelleme**https://developer.android.com/guide/playcore/in-app-updates
**Play uygulama içi güncellemeyi denemek**https://developer.android.com/guide/playcore/in-app-updates/test
**TestFlight genel bakış**https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
**expo-application**https://docs.expo.dev/versions/latest/sdk/application/
**expo-updates**https://docs.expo.dev/versions/latest/sdk/updates/
**expo-notifications**https://docs.expo.dev/versions/latest/sdk/notifications/
**expo-updates kurulumu, native klasörü depoda olan proje**https://docs.expo.dev/bare/installing-updates/
**EAS Update kademeli yayın**https://docs.expo.dev/eas-update/rollouts/
**EAS Update geri alma**https://docs.expo.dev/eas-update/rollbacks/
**EAS Update hata kurtarma**https://docs.expo.dev/eas-update/error-recovery/
**Expo push gönderimi ve makbuzlar**https://docs.expo.dev/push-notifications/sending-notifications/
**Expo, fiyatlandırma metni**https://expo.dev/pricing.md
**Expo, planlar**https://docs.expo.dev/billing/plans/
**Expo, faturalama SSS**https://docs.expo.dev/billing/faq/
**Expo, kullanıma dayalı fiyatlandırma ve MAU tanımı**https://docs.expo.dev/billing/usage-based-pricing/
**Expo, hızlı düşen build'ler sayılmaz**https://expo.dev/changelog/2024-05-02-fast-failed-builds-exclusion
**EAS Build sınırları**https://docs.expo.dev/build-reference/limitations/
**EAS Build altyapısı ve imajlar**https://docs.expo.dev/build-reference/infrastructure/
**EAS uygulama sürümleri ve build:version:sync**https://docs.expo.dev/build-reference/app-versions/
**EAS build'i CI'dan tetiklemek**https://docs.expo.dev/build/building-on-ci/
**EAS Submit**https://docs.expo.dev/submit/introduction/
**EAS ortam değişkenleri ve görünürlük**https://docs.expo.dev/eas/environment-variables/
**EAS ortam değişkenleri, varsayılan ortam seçimi**https://docs.expo.dev/eas/environment-variables/usage/
**EAS internal dağıtım ve App Store Connect anahtarı**https://docs.expo.dev/build/internal-distribution/
**eas-cli v20.2.0 sürüm notu**https://github.com/expo/eas-cli/releases/tag/v20.2.0
**Expo Updates protokolü v1**https://docs.expo.dev/technical-specs/expo-updates-1/
**Expo, kendi güncelleme sunucusu**https://docs.expo.dev/eas-update/custom-updates-server/
**expo/custom-expo-updates-server**https://github.com/expo/custom-expo-updates-server
**EAS Update kod imzalama**https://docs.expo.dev/eas-update/code-signing/
**EAS Update SSS**https://docs.expo.dev/eas-update/faq/
**xprem**https://github.com/mercuretechnologies/xprem
**hot-updater**https://github.com/gronxb/hot-updater
**Microsoft, App Center emekliliği**https://learn.microsoft.com/en-us/appcenter/retirement
**microsoft/code-push-server**https://github.com/microsoft/code-push-server
**fastlane iOS kurulumu**https://docs.fastlane.tools/getting-started/ios/setup/
**fastlane match**https://docs.fastlane.tools/actions/match/
**fastlane, App Store Connect API anahtarı**https://docs.fastlane.tools/app-store-connect-api/
**fastlane, iOS beta dağıtımı**https://docs.fastlane.tools/getting-started/ios/beta-deployment/
**fastlane supply**https://docs.fastlane.tools/actions/supply/
**GitHub Actions faturalama**https://docs.github.com/en/billing/concepts/product-billing/github-actions
**GitHub Actions runner fiyatları**https://docs.github.com/en/billing/reference/actions-runner-pricing
**GitHub, self-hosted ücretinin ertelenmesi**https://github.blog/changelog/2025-12-16-coming-soon-simpler-pricing-and-a-better-experience-for-github-actions/
**GitHub self-hosted runner**https://docs.github.com/en/actions/concepts/runners/self-hosted-runners
**Xcode Cloud**https://developer.apple.com/xcode-cloud/
**Codemagic fiyatlandırma**https://codemagic.io/pricing/
**Bitrise fiyatlandırma**https://bitrise.io/pricing
**Firebase App Distribution**https://firebase.google.com/docs/app-distribution
**Firebase fiyatlandırma**https://firebase.google.com/pricing
**TestFlight**https://developer.apple.com/testflight/
**Google Play dahili test**https://support.google.com/googleplay/android-developer/answer/9845334

## Veritabanı yedeği ve geri yükleme

Neon, PostgreSQL, Cloud Storage ve KVKK metinleri; 8 Ekim 2026'da okundu.

**Neon planları**https://neon.com/docs/introduction/plans
**Neon geçmiş penceresi**https://neon.com/docs/postgres/backup-restore/history-window
**Neon anında geri yükleme**https://neon.com/docs/postgres/backup-restore/branch-restore
**Neon, Time Travel Assist**https://neon.com/docs/postgres/backup-restore/time-travel-assist
**Neon, snapshot ile yedek ve geri yükleme**https://neon.com/docs/guides/backup-restore
**Neon yedeklerine genel bakış**https://neon.com/docs/postgres/backup-restore/backups
**Neon, pg_dump ile yedek**https://neon.com/docs/manage/backup-pg-dump
**Neon, pg_dump yedeğini otomatikleştirmek**https://neon.com/docs/manage/backup-pg-dump-automate
**Neon proje yönetimi**https://neon.com/docs/manage/projects
**Neon SSS: ücretsiz plan sınırları**https://neon.com/faqs/free-plan-limits-and-quotas
**PostgreSQL 18, pg_dump**https://www.postgresql.org/docs/18/app-pgdump.html
**Google Cloud Storage, Bucket Lock ve saklama politikası**https://docs.cloud.google.com/storage/docs/bucket-lock
**KVKK, Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik**https://www.kvkk.gov.tr/Icerik/5441/KISISEL-VERILERIN-SILINMESI-YOK-EDILMESI-VEYA-ANONIM-HALE-GETIRILMESI-HAKKINDA-YONETMELIK

## Ücretsiz katmanlar

Her servisin ücretsiz sınırı 8 Ekim 2026'da bu sayfalardan okundu ve ikinci geçişte metinle karşılaştırıldı.

**Google Cloud ücretsiz katmanı**https://docs.cloud.google.com/free/docs/free-cloud-features
**Google Cloud ağ fiyatları**https://cloud.google.com/vpc/network-pricing
**Secret Manager fiyatları**https://cloud.google.com/secret-manager/pricing
**Logging ve Monitoring fiyatları, alarm ücreti**https://cloud.google.com/products/observability/pricing
**Cloudflare planları**https://www.cloudflare.com/plans/
**Cloudflare Workers sınırları**https://developers.cloudflare.com/workers/platform/limits/
**Cloudflare R2 fiyatları**https://developers.cloudflare.com/r2/pricing/
**Cloudflare Turnstile planları**https://developers.cloudflare.com/turnstile/plans/
**Resend kota ve sınırları**https://resend.com/docs/knowledge-base/account-quotas-and-limits
**Expo push SSS**https://docs.expo.dev/push-notifications/faq/
**Search Console API sınırları**https://developers.google.com/webmaster-tools/limits
**PostHog fiyatları**https://posthog.com/pricing
**UptimeRobot fiyatları**https://uptimerobot.com/pricing/
**Google Cloud Hizmet Şartları**https://cloud.google.com/terms

## Pahalı dış API'ler

Google Maps Platform fiyat ve şartları, açık veri ve alternatif sağlayıcılar; 8 Ekim 2026.

**Google Maps Platform fiyat listesi**https://developers.google.com/maps/billing-and-pricing/pricing
**Google Maps Platform Mart 2025 fiyat değişikliği**https://developers.google.com/maps/billing-and-pricing/march-2025
**Places API kullanım ve faturalama**https://developers.google.com/maps/documentation/places/web-service/usage-and-billing
**Place Details**https://developers.google.com/maps/documentation/places/web-service/place-details
**Place Photos**https://developers.google.com/maps/documentation/places/web-service/place-photos
**Places API politikaları: place_id süresiz saklanabilir, atıf**https://developers.google.com/maps/documentation/places/web-service/policies
**Google Maps Platform hizmete özel şartlar, madde 14**https://cloud.google.com/maps-platform/terms/maps-service-terms
**Google Maps Platform hizmet şartları, madde 3.2.3**https://cloud.google.com/maps-platform/terms
**Google Maps Platform maliyet yönetimi**https://developers.google.com/maps/billing-and-pricing/manage-costs
**Google Cloud: API kullanımını kota ile sınırlamak**https://docs.cloud.google.com/apis/docs/capping-api-usage
**Google Cloud: bütçe ve bütçe uyarıları**https://docs.cloud.google.com/billing/docs/how-to/budgets
**Google Cloud: harcama tavanı bütçeleri ve uygun servisler**https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps
**Google Maps Platform API güvenliği en iyi uygulamaları**https://developers.google.com/maps/api-security-best-practices
**Nominatim kullanım politikası**https://operations.osmfoundation.org/policies/nominatim/
**Overpass API ortak kullanım kuralları**https://dev.overpass-api.de/overpass-doc/en/preface/commons.html
**Overpass API kurulumu**https://wiki.openstreetmap.org/wiki/Overpass_API/Installation
**OpenStreetMap telif ve lisans**https://www.openstreetmap.org/copyright
**Foursquare fiyatlandırma**https://foursquare.com/pricing/
**Foursquare OS Places**https://docs.foursquare.com/data-products/docs/fsq-places-open-source
**Foursquare OS Places alan şeması**https://docs.foursquare.com/data-products/docs/places-os-data-schema
**Foursquare OS Places erişim**https://docs.foursquare.com/data-products/docs/access-fsq-os-places
**Foursquare OS Places tanıtım sayfası**https://opensource.foursquare.com/os-places/
**Overture Maps atıf ve lisanslar**https://docs.overturemaps.org/attribution/
**Overture Maps Places rehberi**https://docs.overturemaps.org/guides/places/
**Geoapify fiyatlandırma**https://www.geoapify.com/pricing/
**Geoapify Places API**https://www.geoapify.com/places-api/
**Mapbox fiyatlandırma**https://www.mapbox.com/pricing
**Mapbox geçici ve kalıcı geocoding**https://docs.mapbox.com/help/dive-deeper/understand-temporary-vs-permanent-geocoding/
**HERE Base Plan fiyatlandırma**https://developers.here.com/plans
**TomTom fiyatlandırma**https://docs.tomtom.com/pricing
**Wikimedia Commons içeriğini dışarıda kullanmak**https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia

## Bot doğrulama aralıkları

Botların kimliğini doğrulamak için yayıncıların yayımladığı adres listeleri. Kapının aylık yenileme betiği bunları okur.

**Googlebot aralıkları**https://developers.google.com/static/search/apis/ipranges/googlebot.json
**Google özel tarayıcı aralıkları**https://developers.google.com/static/search/apis/ipranges/special-crawlers.json
**Google kullanıcı tetiklemeli getiriciler**https://developers.google.com/static/search/apis/ipranges/user-triggered-fetchers.json
**Google adres alanı (goog.json)**https://www.gstatic.com/ipranges/goog.json
**Google Cloud müşteri aralıkları (cloud.json)**https://www.gstatic.com/ipranges/cloud.json
**Bingbot aralıkları**https://www.bing.com/toolbox/bingbot.json
**OAI-SearchBot aralıkları**https://openai.com/searchbot.json
**ChatGPT-User aralıkları**https://openai.com/chatgpt-user.json
**PerplexityBot aralıkları**https://www.perplexity.com/perplexitybot.json
**Perplexity-User aralıkları**https://www.perplexity.com/perplexity-user.json
**DuckDuckBot aralıkları**https://duckduckgo.com/duckduckbot.json
**DuckAssistBot aralıkları**https://duckduckgo.com/duckassistbot.json
**RIPEstat duyurulan prefix'ler**https://stat.ripe.net/data/announced-prefixes
Rehber Burak Altıntaş'ın çalışmasıdır; kurallar onun ürünlerinde yaşanan olaylardan, faturalardan ve bulunan çözümlerden çıktı. © 2026 Burak Altıntaş. Bu rehber canlı ürünlerimizin Ağustos–Ekim 2026 fatura, Neon tüketimi ve log ölçümlerine, 1–7 Ekim 2026'da 11 servisten çekilen yaklaşık 517.000 isteklik bot analizine ve sağlayıcıların yayımladığı belgelere dayanır. Kullanıcıyı kırmadan değiştirme kuralları Ağustos–Ekim 2026 olay kayıtlarından ve sürüm notlarından çıktı. Depo boyutları ve Artifact Registry denetimi 8 Ekim 2026'da salt okunur ölçüldü. Startup kredi bilgileri 8 Ekim 2026'da resmi program sayfalarından doğrulandı. Mobil kit, mobil dağıtım, yedek, ücretsiz katman, performans ve ücretli API bölümleri 8 Ekim 2026'da resmi sayfalardan ve salt okunur ölçümlerden doğrulandı. Maliyetlere alan adı ve mağaza ücretleri katılmadı. Fiyatlar Ekim 2026, 1 USD = 49 TL.
