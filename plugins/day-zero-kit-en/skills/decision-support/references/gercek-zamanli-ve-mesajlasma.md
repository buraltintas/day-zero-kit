<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
