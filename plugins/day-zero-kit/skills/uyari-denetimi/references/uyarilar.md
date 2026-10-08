<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
