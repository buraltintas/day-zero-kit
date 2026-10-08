<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
