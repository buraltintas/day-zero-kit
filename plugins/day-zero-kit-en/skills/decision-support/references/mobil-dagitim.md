<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
