<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
