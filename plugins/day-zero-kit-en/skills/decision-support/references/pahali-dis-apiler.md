<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
