# KVKK ve veri yeri
Son doğrulama: 2026-10-08. Hukuki görüş değildir; standart
sözleşme metni, VERBİS sorusu ve kapsam soruları hukukçuya.
Yeni SDK, işleyen ya da platform gelince bu liste, gizlilik
metni, App Store etiketi ve Play Data safety aynı gün güncellenir.

## Veri yeri (K-004)
Veri AB'de. Türkiye'de değil; belgelerde "Türkiye'de" yazılmaz.
- Veritabanı: Neon, AWS Frankfurt (aws-eu-central-1).
- Uygulama ve loglar: Google Cloud europe-west1 (Belçika).
  Log kovaları AB'de doğar (infra/owner/04-billing-budget.sh).
  Organizasyonsuz kurulumda _Required kovası (yönetim denetim
  logları) global kalır; o durumda burada öyle yazılır.
- E-posta: Resend AB bölgesi; Resend'in hesap verisi ABD'de.
  Yedek: Amazon SES eu-west-1 (İrlanda).
- Yedekler: Neon geçmişi ve döküm kovası AB'de (Tablo 24,
  "İlk kullanıcıdan önce" aşamasında sorulacak).

## İşleyen listesi
Sağlayıcı          | ne işler                          | yer        | aktarım dayanağı
Google Cloud       | uygulama, loglar (IP), sırlar,    | AB         | m.9 standart sözleşme
                   | fatura                            |            |
Firebase (Google)  | App Check (Play Integrity, App    | ABD/küresel| m.9 standart sözleşme
                   | Attest), FCM push token'ı         |            |
Neon               | veritabanı: hesaplar, kulüpler,   | AB         | m.9 standart sözleşme
                   | etkinlikler, kayıtlar             |            |
Resend             | giriş kodu ve bülten e-postası,   | AB; hesap  | m.9 standart sözleşme
                   | alıcı adresi                      | verisi ABD |
Amazon SES         | yedek e-posta, alıcı adresi       | AB         | m.9 standart sözleşme
Cloudflare         | DNS; turuncu host'larda IP ve     | küresel    | m.9 standart sözleşme
                   | istek; Turnstile                  |            |
Expo               | push bildirimi aracılığı, push    | ABD        | m.9 standart sözleşme
                   | token'ı; build                    |            |
Apple              | APNs, App Store, App Attest       | ABD/küresel| mağaza şartları; hukukçu
Google Play        | Play, Play Integrity              | ABD/küresel| mağaza şartları; hukukçu
Alan adı kayıt     | kullanıcı verisi yok; şirketin    | -          | gerekmez
  firması          | iletişim bilgisi                  |            |
GitHub             | kaynak kod; kullanıcı verisi yok  | -          | gerekmez
Kullanılmayanlar (karar numarasıyla): üçüncü taraf analitik
(K-019), Sentry (K-020), ücretli dış API ve harita (K-016),
AI sağlayıcısı (K-018 bekliyor), RevenueCat ve AdMob (K-018
bekliyor), içerik otomasyonu platformları (K-027).
Her sözleşme imzalandıktan sonra 5 iş günü içinde Kurum'a
bildirim (m.9/5); bildirilmezse 2026'da ₺90.308–1.806.177.

## Kişisel veri ve süreler (taslak)
- E-posta adresi ve hesap: hesap silinene kadar; silme
  geri yüklemede yeniden uygulanır.
- Etkinlik kayıtları: KARAR BEKLİYOR (ürün sahibi).
- Kulüplerin yayımladığı etkinlik içeriği: KARAR BEKLİYOR.
- İçerik yazan isteğin ham IP'si, portu ve zamanı (5651,
  önlem 18): ayrı tabloda 13 ay. Kapsamı hukukçu söyler.
- Diğer loglarda IP: 30 gün (varsayılan log kovası);
  analitikte yalnız IP hash'i.
- Push token'ı: cihaz kaydı silinene ya da token ölene kadar.
- Konum: işlenip işlenmeyeceği KARAR BEKLİYOR (K-018,
  "yakınlarındaki etkinlik").
- Yedek, proje dışı kopya ve soft delete dahil azami süre:
  Tablo 24'ten sonra yazılır (rehberin varsayılanı 37 gün).

## İhlal planı (Gün 0 önlemi 9)
- 72 saat, ihlalin öğrenildiği anda başlar.
- Kim karar verir: ürün sahibi. İkinci kişi: K-002 bekliyor.
- Kurul'a bildirim formu:
  https://www.kvkk.gov.tr/Icerik/5362/Veri-Ihlali-Bildirimi
- Kimin etkilendiğini bulmak için: kişisel veri dönen her
  isteğin log satırında kullanıcı, kayıt kimliği ve IP; bu
  satırlar 400 gün saklanan kovaya gider (adım 16).
- Kullanıcıya gidecek metin taslağı: ne oldu, hangi veri,
  ne yaptık, ne yapmalısınız, iletişim. Metin hukukçuyla.

## Hukukçuya ve mali müşavire sorular
- Standart sözleşme metni ve Kurum'a bildirim (m.9).
- VERBİS istisnası (önlem 25): 50'den az çalışan ve 100
  milyon TL'den az bilanço mı? Şirket bilgisi K-002 bekliyor.
- 5651 yer sağlayıcı kapsamı (önlem 18): kulüplerin
  yayımladığı etkinlik içeriği.
- 15 yaş altı (önlem 23): 7578 sayılı Kanun 1 Kasım 2026'da
  yürürlükte, bugünden 24 gün sonra. Öğrencilerin etkinlik
  içeriği görüp kayıt olduğu bu ürün sosyal ağ sağlayıcı
  sayılır mı? Sayılırsa kayıtta doğum yılı, 15 altına hesap
  yok, tedbirler sayfası.
- Bildir ve engelle (önlem 19): her içerik türünde rapor ve
  engel, içerikten önce kullanım şartı onayı.
- Bekleyen özelliklere bağlı (K-018): AI izni (17), web'den
  abonelik satışı (24), şahıs olarak mağaza ve reklam geliri,
  20/B (26, mali müşavir), bülten için İYS (22).

## Gizlilik metni taslağı
Taslaktır; yayımlanmadan önce hukukçu okur. Açılı parantezli
yerler kararlarla dolar.

  Kampüs Gizlilik Metni (taslak)
  Veri sorumlusu: <şirket unvanı, adres> (K-002).
  Hangi verileri işliyoruz: e-posta adresiniz; kayıt
  olduğunuz etkinlikler; kulüpseniz yayımladığınız
  etkinlikler; cihazınızın bildirim anahtarı; teknik
  kayıtlar (IP adresi, istek zamanı)<; konum, K-018>.
  Neden: hesabınızı açmak ve giriş kodu göndermek;
  etkinlikleri göstermek ve kaydınızı almak; bildirim
  göndermek; güvenlik ve yasal yükümlülükler.
  Nerede: verileriniz Avrupa Birliği'nde (Almanya ve
  Belçika) duran sunucularda işlenir. Yurt dışına aktarım
  KVKK m.9 uyarınca standart sözleşmeyle yapılır.
  Kimlerle: altyapı sağlayıcılarımız (yukarıdaki liste).
  Ne kadar: <süreler, yedekler dahil azami süre>.
  Haklarınız: KVKK m.11; başvuru: <adres>.
