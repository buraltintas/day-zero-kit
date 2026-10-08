# Kararlar
Her karar bir blok. Numara tekrar kullanılmaz.
Değişen karar silinmez: "yerini aldı: K-NNN".
Ajan karar vermez, ürün sahibinin kararını
kaydeder.

Numaralar sorulma sırasıyla verildi. Cevabı gelmeyen
soru "taslak, KARAR BEKLİYOR" durumunda; seçenekler ve
rehberin önerisi blokta, iş satırı docs/TODO.md'nin
"Karar bekleyen" bölümünde, kısa hali AGENTS.md'de.
Gün 0'da tablonun 1–17. satırları soruldu. K-019–K-027
ürün sahibinin aşaması gelmeden verdiği cevaplardır;
o aşamada yeniden onaylatılır.

## K-001 Ürün adı ve alan adı
Tarih: 2026-10-08. Durum: kısmen geçerli.
Karar veren: ürün sahibi.
Tablo: 1.
Bağlam: Alan adı ilk kullanıcıdan haftalar önce alınmalı;
  bundle ID ve paket adı mağazaya ilk yüklemeden sonra
  değişmez.
Karar: Ürün adı "Kampüs" (çalışma adı). Alan adı
  kampus.example: yer tutucu, henüz alınmadı. Tek alan
  adı; web ana alan adında, API api., giriş kodları
  auth., bülten news. alt alan adında (K-015 ile).
  Kodda ve kimliklerde ASCII yazım: kampus.
Bekleyen kısım (KARAR BEKLİYOR): gerçek alan adı;
  iOS bundle ID, Android paket adı, uygulama şeması.
  Rehberin önerisi: kimlik alan adının tersi
  (ornek.com ise com.ornek.app), iki platformda aynı;
  şema kısa ve tek; universal link ve App Links ana
  alan adında, ilk build'de. Alan adı yer tutucu
  olduğu için kimlik ondan türetilmedi.
Seçenekler: tek alan adı ve alt alan adları ya da
  yüzey başına ayrı alan adı.
Sonuç: Adım 5 (DNS), 11 (e-posta) ve 15 (mobil
  iskelet) alan adı ve kimlikler gelmeden başlamaz.
Yeniden bak: alan adı alınınca.

## K-002 Hesapların sahibi ve yöneticileri
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 2.
Soru: Hesaplar kimin adına açılır, kimler yönetir?
Seçenekler: şirket ya da kişi; bir ya da iki yönetici.
Önerim (rehberin varsayılanı): şirket adına, ürünün
  alan adındaki bir rol adresiyle; en az iki yönetici;
  kök hesaplarda donanım anahtarı ya da passkey.
  Neden: Claude, Google, Cloudflare ve PostHog'un kredi
  programları kişisel adresi kabul etmiyor; tek kişiye
  bağlı hesaplar o kişiyle birlikte gider (Gün 0
  önlemi 1).
Bağlı adım: 3 (hesap envanteri), 4.

## K-003 Ayrı faturalama hesabı ve Neon org'u
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 3.
Bağlam: Ücretsiz kotalar faturalama hesabı başına.
Karar: Ürüne ayrı faturalama hesabı ve ayrı Neon org'u,
  aynı ödeme profilinin altında.
Seçenekler: var olan hesabı paylaşmak (reddedildi: aynı
  hesaptaki iki ürün Eylül'de ₺187 build ve ₺78 Cloud
  Run ücreti ödedi).
Sonuç: Tek ürün kota için hesaplara bölünmez (Google
  Cloud Şartları 3.3 ve 4.2).
Yeniden bak: yok.

## K-004 Veri yeri
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 4.
Bağlam: Kullanıcılar Türkiye'de; Neon'un Türkiye
  bölgesi yok.
Karar: AB. Neon Frankfurt (aws-eu-central-1), Cloud Run,
  Artifact Registry, Cloud Build ve log kovası
  europe-west1 (Belçika). Belgelerde "veri AB'de"
  yazılır.
Seçenekler: Türkiye (reddedildi: Neon yok, veritabanı
  uyuma kazancını kaybeder).
Sonuç: KVKK m.9 standart sözleşmesi ve imzadan sonra
  5 iş günü içinde Kurum'a bildirim (docs/KVKK.md).
Yeniden bak: kurumsal müşteri Türkiye isterse.

## K-005 Neon planı
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 5.
Karar: Prod Launch planında (aylık asgari ücret yok,
  az trafikte ayda ~₺50–80). Test ve yan projeler
  ayrı bir Free org'da.
Seçenekler: Free (gerçek kullanıcılı prod için değil),
  Scale (gereksiz).
Sonuç: Launch'tan Free'ye inmek döküm, yükleme ve adres
  değişikliği demek; plan proje doğarken seçilir.
  Test projesine tüketim kotası konur, prod'a konmaz
  (Gün 0 önlemi 7).
Yeniden bak: Neon günde ≥6 CU-saat harcarsa.

## K-006 Platformlar
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 6.
Karar: Web, iOS ve Android.
Sonuç: Mobil uzaktan kontrol kitinin iskeleti mobil
  kodun ilk commit'inde, tamamı ilk mağaza sürümünden
  önce. Mağaza kararları (Tablo 26–29) plana girer.
Yeniden bak: yok.

## K-007 Dal modeli ve canlıya deploy kararı
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 7.
Soru: Dal modeli ne, canlıya deploy kararı kimde?
Seçenekler: test ve main ya da yalnız main; onay kapısı
  ya da doğrudan.
Önerim (rehberin varsayılanı): test ve main; main yalnız
  test'te görülmüş commit'e ilerler; deploy, build ve
  sürüm numarası ürün sahibinin; kural AGENTS.md'nin en
  üstünde. Neden: kural yalnız ajan hafızasındayken
  20 Eylül'de istenmeden iki prod build başladı.
Bağlı adım: 6 (test dalı, dal koruması), 8
  (tetikleyiciler, docs/runbooks/deploy.md).
Not: Canlıya deploy, build, gönderim ve sürüm numarasının
  ürün sahibinde olduğu skill'in sabit kuralıdır; bekleyen
  kısım dal modeli ve kapının biçimi.

## K-008 Ajanın onaysız yapabileceği işler
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 8.
Soru: Ajan neyi onaysız yapar, ücretli işte eşik ne?
Seçenekler: commit, test'e push, migration, deploy,
  mağaza; her ücretli çağrı ya da bir eşiğin üstü.
Önerim (rehberin varsayılanı): dalda commit ve test'e
  çıkış onaysız; main, prod migration, build, gönderim
  ve herkese açma onaylı; günde 1 dolar üstü ücretli iş
  sorulur. Neden: GCP için ayda 1 dolar tahmin edilen
  hesap Ağustos'ta ₺2.087 geldi.
Karar gelene kadar: ajan yalnız yerelde commit eder;
  her push, migration ve ücretli çağrı sorulur.

## K-009 Gizli bilgilerin yeri ve erişim
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 9.
Soru: Gizli bilgiler nerede durur, kim erişir?
Seçenekler: Secret Manager, .env dosyası ya da CI
  değişkeni.
Önerim (rehberin varsayılanı): Secret Manager; her servis
  kendi hesabıyla yalnız kendi sırrına; adlar
  .env.example'da; JSON anahtar yok; CI GitHub
  Actions'a taşınırsa WIF. Neden: Editor yetkili hazır
  hesap bir açıkla birleşince proje ele geçirilebilir
  oldu.
Bağlı adım: 9.
Şimdiden geçerli (plan adım 2): değer hiçbir dosyada yok,
  adlar .env.example'da.

## K-010 Test ortamı ve verisi
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 10.
Soru: Test ortamı olacak mı, verisi nereden gelir?
Seçenekler: ayrı ortam ya da yalnız yerel; canlının
  kopyası ya da temsili veri.
Önerim (rehberin varsayılanı): prod'un şeklinde '-test'
  servisleri, ayrı Neon, ayrı hesap ve sırlar, temsili
  veri; canlı veri teste inmez, test canlıya yazmaz.
  Neden: bir test canlıya 44 sahte kayıt yazdı ve
  herkese açık listede göründü.
Not: K-005 test Neon'unu Free org'da öngörüyor; '-test'
  servisleri, sırları ve hesapları bu karara bağlı.
Bağlı adım: 7'nin test kısmı, 8'in '-test' servisleri.

## K-011 Bütçe ve sunucu tavanları
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 11.
Karar: Aylık bütçe ~₺150, uyarı %50, %80 ve %100'de;
  kredileri hariç ikinci bütçe. Cloud Run: API min 0,
  max 2–3; web min 0, max 3. Prod'a harcama tavanı
  konur: kredi düşülmeden önceki brüt aylık maliyetin
  ~10 katı, en az ~$100; bu ölçekte ~$100.
Uygulama notu: service.yaml'da API max şimdilik 2
  (aralığın alt ucu); 2 mi 3 mü TODO'da soruldu.
Sonuç: Bütçe uyarısı harcamayı durdurmaz. Tavan yalnız
  Cloud Run, Cloud Run functions, Gemini API ve Vertex
  AI'ı kapsar; dolunca o projede Cloud Run ay sonuna
  kadar yeni istek almaz; kaldırma adımı
  docs/runbooks/cost-check.md'de. İnternet çıkışı,
  log, build ve dış API'ye alarm ve kota bakar.
Yeniden bak: ilk faturadan sonra; brüt maliyet 10 katı
  $100'ü geçince tavan yeniden hesaplanır.

## K-012 Belgelerin dili, iş panosu, sahip oturum
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: 12.
Soru: Belgelerin dili, iş panosu ve sahip oturum ne?
Seçenekler: Türkçe ya da İngilizce; depoda TODO ya da
  dış pano.
Önerim (rehberin varsayılanı): içerik Türkçe, dosya adları
  geleneksel İngilizce; depo başına bir sahip oturum,
  adı docs/STATUS.md'de; iş panosu docs/TODO.md. Neden:
  aynı depoda iki oturum main'e aldı, push reddedildi.
Not: Hafıza dosyaları ilk commit'te açılmak zorunda
  olduğu için önerilen biçimle yazıldı; başka bir karar
  gelirse yeniden adlandırılır.

## K-013 Mobil build hattı
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 13.
Karar: EAS Free ve ilk günden prova edilmiş yerel yol
  (eas build --local). Preview build'leri yerelde.
Seçenekler: EAS Starter, yalnız yerel, kendi hat
  (ancak EAS faturası üç ay üst üste $50'ı geçerse).
Sonuç: Platform başına ayda 15 bulut build hakkı; build
  önermeden önce sayılır, iOS için ay sonuna 2–3 acil
  hak bırakılır. Her bulut build'i ürün sahibinin sözüyle.
Yeniden bak: bir platformda ayda 12 build'e varılırsa.

## K-014 Tasarımın tek kaynağı ve koyu tema
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 14.
Karar: tokens/tokens.json (DTCG 2025.10) tek kaynak;
  web CSS'i ve mobil tema ondan üretilir, elle kopya
  yok. Koyu tema ilk sürümde yok: "yalnız açık" kilitli
  (web'de color-scheme: light, uygulama ayarında açık
  stil). DESIGN.md gün 0'da.
Seçenekler: iki mod (reddedildi: ilk sürüm için).
Sonuç: Marka renkleri ve yazı ailesi henüz yok; token
  değerleri yer tutucu (KARAR BEKLİYOR, TODO'da).
Yeniden bak: ilk tasarım paketi gelince; koyu tema ilk
  sürümden sonra.

## K-015 E-posta sağlayıcısı ve alt alan adları
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 15.
Karar: Resend AB bölgesinde; giriş kodları
  auth.kampus.example'dan, bülten news.'ten. SPF, DKIM,
  DMARC ilk gönderimden önce. Yedek sağlayıcı Amazon
  SES eu-west-1, aynı auth. alt alan adında, kurulu
  ve denenmiş.
Sonuç: Bölge sonradan değişmez (destek ister, DKIM
  değişebilir). Bülten ticari iletidir; İYS sorusu
  K-018'de bekliyor.
Yeniden bak: haftalık abone ~60'ı geçince (Resend Pro
  ya da SES).

## K-016 Ücretli dış API
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 16.
Karar: Yok. Plan adım 13 atlanır.
Sonuç: İleride biri gerekirse birim fiyat, en kötü gün,
  iki alternatif ve çıkış yolu yazılmadan açılmaz;
  sağlayıcıda sert günlük kota, ürüne özel kısıtlı
  anahtar.
Yeniden bak: ilk ücretli API isteğinde.

## K-017 AI tarayıcılarına ve cevap motorlarına tutum
Tarih: 2026-10-08. Durum: geçerli.
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 17.
Karar: Arama ve cevap motorları açık. Eğitim botları
  kapalı (GEO hedefi belirtilmedi): robots.txt'de
  Disallow, Cloudflare'de "Disallow AI Training".
  CCBot ve Bytespider engelli. "Block" seçilmez, çünkü
  Googlebot ve Bingbot'u da keser.
Sonuç: Yeni alan adının Cloudflare'deki hazır ayarı
  gün 0'da okunur, okunmadan kabul edilmez.
Yeniden bak: GEO hedefi konursa.

## K-018 Ürünün özellikleri (Gün 0 önlemleri için)
Tarih: 2026-10-08. Durum: kısmen geçerli.
Karar veren: ürün sahibi.
Tablo: yok (Gün 0 önlemleri, "1. adımda sorulur").
Karar: Kullanıcı içeriği var: kulüpler etkinlik yayımlar,
  öğrenciler görür (ürün sahibinin ürün tanımından).
Bekleyen kısım (KARAR BEKLİYOR): AI özelliği; abonelik
  ya da uygulama içi satın alma; web'den satış; ticari
  ileti (bülten, kampanya); mağaza ve reklam gelirinin
  şahıs olarak alınması; konum işlenip işlenmeyeceği
  ("yakınlarındaki etkinlik").
Sonuç: Önlem 18 (5651 kaydı), 19 (bildir ve engelle) ve
  23 (15 yaş altı, 1 Kasım 2026) geçerli; kapsamı
  hukukçuya (docs/KVKK.md). Bekleyen her özellik
  "yok" çıkarsa ilgili önlem buraya "özellik yok" diye
  yazılır.

## K-019 Analitik
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 18 (aşaması: ilk kullanıcıdan önce).
Karar: Kendi olay tablomuz; tek olay ucu, ilk build'de
  on zorunlu olay. Üçüncü taraf analitik yok.
Bekleyen kısım: analitiğin cevaplayacağı beş soru
  (rehber "önce ürün sahibinin beş sorusu" diyor).

## K-020 Hata takibi
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 19.
Karar: Birinci taraf: notify(), /v1/client-errors,
  Error Reporting ve error_shown olayı. Sentry yok.
Yeniden bak: KVKK adımından sonra (Sentry EU).

## K-021 Uyarı alıcıları
Tarih: 2026-10-08. Durum: kısmen geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 20.
Karar: İki alıcı: ürün sahibi ve bir geliştirici.
Bekleyen kısım: adlar, e-posta adresleri ve Google
  hesapları (adım 16 DUR); kanal tercihi sorulmadı,
  rehberin önerisi acilde iki telefon ve e-posta.

## K-022 Gerçek zamanlı
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 21.
Karar: Push bildirimi ve açılışta yenileme. Yoklama ve
  WebSocket yok.
Sonuç: Push kaydı mobil kit iskeletinde; 7/24 açık
  servis maliyeti yok.

## K-023 Aranan ve dışarıda kalan sayfalar
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 22.
Karar: Etkinlik sayfaları herkese açık ve aranır. Kayıt
  ve profil kapalı (giriş arkasında, noindex).
Sonuç: Etkinlik sayfaları sunucuda tam HTML, API
  belleğinden ya da ISR'dan; veritabanına gitmez.
  "Yakınımdaki" arama ve filtre veritabanına gidebilir;
  o zaman bot erişimi sınırlanır ve uyanış ölçülür.

## K-024 Admin girişi ve oturum
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi (rehberin varsayılanı).
Tablo: 23.
Karar: E-posta izin listesi; boşta 30 dk, 12 saat tavan;
  üç rol (sahip, operatör, salt okuyucu); tehlikeli
  eylemde yeniden kod.
Not: Cevap kağıdındaki "Admin" Tablo 23'e bağlandı;
  Tablo 2'nin "kimler yönetir" kısmı ayrıca bekliyor.

## K-025 Startup kredileri
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 25.
Karar: Şimdilik başvuru yok.
Yeniden bak: ağır kullanım başlamadan önce; önce Neon.

## K-026 OTA güncelleme
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 28.
Karar: Şimdilik yok.
Seçenekler: expo-updates ve EAS Update Free (rehber
  öneriyor; atlamak ürün sahibinin kararı).
Sonuç: Yalnız JS düzeltmesi de mağaza build'i harcar
  (rehberdeki üründe 19 build'in 11'i yalnız JS idi).
  Yayın kapısının 11. maddesi "seçilmedi, K-026".
Yeniden bak: ilk mağaza build'inden önce; OTA sonradan
  eklenirse eski build'lere ulaşmaz.

## K-027 İçerik otomasyonu
Tarih: 2026-10-08. Durum: geçerli (erken verildi).
Karar veren: ürün sahibi.
Tablo: 30.
Karar: Yok. Plan adım 33 kurulmaz.

## K-028 Depo düzeni
Tarih: 2026-10-08 (soruldu). Durum: taslak, KARAR BEKLİYOR.
Tablo: yok (rehber tek depo ya da çok depo diye sormuyor).
Soru: Ürün tek depoda mı, yüzey başına ayrı depoda mı?
Önerim (rehberin şablonlarındaki düzen): ayrı özel
  depolar: kampus-api (kanonik; ürün belgeleri yalnız
  burada), kampus-web, kampus-mobile. Hepsinde aynı
  deploy davranışı; öbürlerinin AGENTS.md'si kanonik
  depoyu adıyla gösterir.
Not: Bu kuru çalışmada tek klasör var; içinde yalnız
  ürün düzeyindeki belgeler ve ortak dosyalar duruyor.
