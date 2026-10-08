<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
