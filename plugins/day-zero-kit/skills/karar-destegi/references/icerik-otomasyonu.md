<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
