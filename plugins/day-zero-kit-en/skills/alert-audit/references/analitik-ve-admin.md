<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

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
