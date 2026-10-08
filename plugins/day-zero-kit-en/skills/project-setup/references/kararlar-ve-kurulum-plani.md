<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="kararlar"></a>

Başlarken

# Verilecek kararlar ve kurulum planı

Bu bölüm ajanın gün 0'dan başlayan iş listesidir: ürün sahibine sorulacak kararlar, kod yazılmadan biten hesap ve sürüm listesi ve altyapının kuruluş sırası. Ekip bu sırada yalnız ürün akışlarına bakar.

**Kural:** Ajan tek başına karar vermez; sorar, kaydeder, sırayla kurar ve DUR yazan yerde bekler.

Kararlar dört zamana ayrılır; ajan yalnız o anın satırlarını sorar. Ürün sahibinin tercihi yoksa rehberin varsayılanını nedeniyle önerir; kabul edilen varsayılan da bir karardır ve docs/DECISIONS.md'ye yazılır. Cevabı gelmeyen karar AGENTS.md'de 'KARAR BEKLİYOR' diye kalır ve ona bağlı adım başlamaz. Kurulum planının her adımı bir çıktı ve bir doğrulama taşır; doğrulaması geçmeyen adım bitmiş sayılmaz.

## Dört aşama

Kararlar ve kurulum adımları aynı dört zamana ayrılır. DUR, ürün sahibinin sözünün beklendiği adımdır; ajan orada tek satırlık rapor verir.

### Gün 0: kod yazılmadan

Akışların kodu bu aşama bitince başlar.

**17** karar
**15** adım
**11** DUR

### İlk kullanıcıdan önce

İlk gerçek kullanıcı bu aşama bitince gelir.

**8** karar
**8** adım
**4** DUR

### İlk mağaza sürümünden önce

Yalnız mobil varsa.

**4** karar
**5** adım
**3** DUR

### Sonra

Sürekli; ajan takvimden yürütür.

**3** karar
**5** adım
**2** DUR

## Kararlar

Satırlar sorulacakları zamana göre gruplu. Gri yazı seçenekleri ve nedeni verir, bağlantı kuralın durduğu bölüme gider; etiket varsayılanın kanıt düzeyidir, ayraç içindeki 'öneri' o cümlenin bizde denenmediğini söyler. Varsayılan rehberin teklifidir; karar ürün sahibinindir. Ajanın ilk mesajı [Bu rehber nasıl kullanılır](#kullanim) bölümünde.

| No | Karar ve seçenekler | Rehberin varsayılanı, nedeni ve bölümü | Kim, kanıt |
|---|---|---|---|
| Gün 0: kod yazılmadan, 17 karar |
| 1 | **Ürünün adı, alan adı ve uygulama kimlikleri ne?** Tek alan adı ve alt alan adları ya da yüzey başına ayrı alan adı. Mobil varsa iOS bundle ID, Android paket adı ve uygulama şeması. | Tek alan adı, ilk kullanıcıdan haftalar önce: web, api., auth. ve news. Kategori başvurusu aynı hafta. Mobilde bundle ID ve paket adı alan adının tersidir (ornek.com ise com.ornek.app) ve iki platformda aynıdır; şema kısa ve tektir; universal link ve App Links ana alan adında, ilk build'de, [Mobil kit](#mobilkit) yayın kapısı 14 (öneri). 38 günlük alan adının giriş kodları dört kurumun posta geçidinde bekledi. Bundle ID ve paket adı mağazaya ilk yüklemeden sonra değişmez; ajan bunları uydurmaz, sorar. [Kenar ve DNS](#katman-5) | Ürün sahibi [kanıtlı] |
| 2 | **Hesaplar kimin adına açılır, kimler yönetir?** Şirket ya da kişi; bir ya da iki yönetici. | Şirket adına, ürünün alan adındaki bir adresle; en az iki yönetici, kök hesaplarda donanım anahtarı ya da passkey. Claude, Google, Cloudflare ve PostHog'un kredi programları kişisel adresi kabul etmiyor. [Krediler](#krediler) | Ürün sahibi [öneri] |
| 3 | **Ürüne ayrı faturalama hesabı ve Neon org'u açılacak mı?** Ayrı hesap ya da var olan hesabı paylaşmak. | Ayrı, aynı ödeme profilinin altında. Ücretsiz kotayı artırmak için tek ürün birden çok hesaba bölünmez. Aynı hesaptaki iki ürün Eylül'de ₺187 build ve ₺78 Cloud Run ücreti ödedi. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi [ölçüldü] |
| 4 | **Veri nerede durur?** AB ya da Türkiye; Neon'un Türkiye bölgesi yok. | AB: Neon Frankfurt, servisler europe-west1. KVKK m.9 sözleşmesi ve 5 iş günü içinde bildirim. Türkiye'ye geçiş ancak kurumsal müşteri isterse. Türkiye'de Neon yok; veritabanı orada uyuma kazancını kaybeder. [KVKK](#kvkk) | Ürün sahibi [öneri] |
| 5 | **Prod ve test için Neon planı hangisi?** Free, Launch ya da Scale; test için Free ya da prod'dan dal. | Prod Launch: aylık asgari ücret yok, az trafikte ayda ~₺50–80. Test ve yan projeler ayrı Free org'da. Launch'tan Free'ye inmek döküm, yükleme ve adres değişikliği demek. [Postgres](#katman-1) | Ürün sahibi ve ajan [ölçüldü] |
| 6 | **Platformlar: yalnız web mi, iOS ve Android de mi?** Web; web ve mobil; yalnız mobil. | Akış belirler. Mobil varsa uzaktan kontrol kitinin iskeleti ilk commit'te, tamamı ilk mağaza sürümünden önce; mağaza kararları plana girer. Sonradan eklenen kanal mağazadaki eski build'lere ulaşmaz; bizde 3 Android build'i güncelleme uyarısını hiç gösteremeyecek. [Mobil kit](#mobilkit) | Ürün sahibi [kanıtlı] |
| 7 | **Dal modeli ne, canlıya deploy kararı kimde?** test ve main ya da yalnız main; onay kapısı ya da doğrudan. | test ve main; main yalnız test'te görülmüş commit'e ilerler. Deploy, build ve sürüm numarası ürün sahibinin; AGENTS.md'nin en üstünde. Kural ajanın hafızasındaydı; 20 Eylül'de istenmeden iki prod build başladı. [Kırmadan değiştirmek](#kirmama) | Ürün sahibi [kanıtlı] |
| 8 | **Ajan neyi onaysız yapar, ücretli işte eşik ne?** Commit, test'e push, migration, deploy, mağaza; her ücretli çağrı ya da bir eşiğin üstü. | Dalda commit ve test'e çıkış onaysız; main, prod migration, build, gönderim ve herkese açma onaylı. Günde 1 dolar üstü ücretli iş sorulur. GCP için ayda 1 dolar tahmin edilmişti; Ağustos'ta faturalama hesabının toplamı ₺2.087 geldi. [Proje hafızası](#hafiza) | Ürün sahibi [öneri] |
| 9 | **Gizli bilgiler nerede durur, kim erişir?** Secret Manager, .env dosyası ya da CI değişkeni. | Secret Manager; her servis kendi hesabıyla yalnız kendi sırrına, adlar .env.example'da. JSON anahtar yok, CI için WIF (öneri). Editor yetkili hazır hesap bir açıkla birleşince proje ele geçirilebilir oldu; aynı gün kapatıldı. [Güvenlik](#katman-8) | Ürün sahibi ve ajan [kanıtlı] |
| 10 | **Test ortamı olacak mı, verisi nereden gelir?** Ayrı ortam ya da yalnız yerel; canlının kopyası ya da temsili veri. | Prod'un şeklinde: '-test' servisleri, ayrı Neon, hesap ve sırlar, temsili veri. Canlı veri teste inmez, test canlıya yazmaz. Bir test canlıya 44 sahte hesaplama yazdı; herkese açık listede göründü. [CI/CD](#katman-7) | Ürün sahibi [kanıtlı] |
| 11 | **Bütçe eşikleri ne, en fazla kaç sunucu açılır?** Aylık bütçe tutarı; servis başına max instances; prod'a harcama tavanı ya da yok. | Bütçe %50, %80 ve %100'de, küçük üründe ~₺150; kredileri hariç ikinci bütçe. API max 2–3, web max 3, ikisi de min 0. Prod'a harcama tavanı ürün sahibinin kararıdır; konursa kredi düşülmeden önceki brüt maliyetin ~10 katında ve en az ~$100 olur, kaldırma adımı cost-check.md'de yazılıdır. Bütçe uyarısı harcamayı durdurmaz. Max sınırı yalnız Cloud Run'ın CPU ve bellek faturasını sınırlar; internet çıkışına, loga, build'e ve dış API'ye çıkış alarmı ve API kotası bakar. Tavan dolunca o projede Cloud Run ay sonuna kadar yeni istek almaz; tavan elle kaldırılır, toparlanma bir saati bulabilir ([Gün 0 önlemleri 7](#onlem-7)). Max ve min değerleri bizde canlıda. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi ve ajan [öneri] |
| 12 | **Belgelerin dili, iş panosu ve sahip oturum ne?** Türkçe ya da İngilizce; depoda TODO ya da dış pano. | İçerik Türkçe, dosya adları geleneksel. Depo başına bir sahip oturum, adı STATUS'ta. İş panosu docs/TODO.md (öneri). Aynı depoda iki oturum main'e aldı, push reddedildi. [Proje hafızası](#hafiza) | Ürün sahibi [kanıtlı] |
| 13 | **Mobil build EAS'te mi, kendi hattımızda mı?** EAS Free, EAS Starter, yerel build ya da kendi hat. | EAS Free ve ilk günden prova edilmiş yerel yol; kendi hat ancak EAS faturası üç ay üst üste $50'ı geçerse. Preview'lar yerelde alınınca platform başına ayda 15 hak yetiyor. [Mobil dağıtım](#dagitim) | Ürün sahibi ve ajan [ölçüldü] |
| 14 | **Tasarımın tek kaynağı ne, koyu tema olacak mı?** Token dosyası ya da elle kopya; iki mod ya da yalnız açık tema. | tokens/tokens.json'dan CSS ve mobil tema üretilir. Koyu tema ya iki modla tasarlanır ya 'yalnız açık' kilitlenir; DESIGN.md gün 0'da. Ürün A'nın ana marka rengi 5 depoda 17 dosyada sabit yazılı. [Tasarım sistemi](#tasarim) | Ürün sahibi [öneri] |
| 15 | **E-posta sağlayıcısı ve gönderim alt alan adı ne?** Resend, SES ya da başka; tek ya da ayrı alt alan adları. | Resend AB bölgesinde; kodlar auth., bülten news. alt alan adından. SPF, DKIM ve DMARC ilk gönderimden önce; yedek sağlayıcı (varsayılan Amazon SES, eu-west-1) aynı auth. alt alan adında kurulu ve denenmiş. Bölgeyi sonradan değiştirmek destek ister ve DKIM değişebilir. [E-posta](#katman-9) | Ürün sahibi ve ajan [öneri] |
| 16 | **Hangi ücretli dış API'ler kullanılır, tavanları ne?** Harita, model, SMS; çağrı başına ya da tek seferlik içe aktarma. | Birim fiyat, en kötü gün, iki alternatif ve çıkış yolu yazılmadan açılmaz; sağlayıcıda sert günlük kota, ürüne özel kısıtlı anahtar. Bir harita API'si Ağustos'ta ₺1.500 yazdı, projenin Google faturasının ~%72'si. [Pahalı API'ler](#pahali-api) | Ürün sahibi [ölçüldü] |
| 17 | **AI eğitim tarayıcılarına ve cevap motorlarına tutum ne?** Eğitim: aç, sınırla ya da engelle. Cevap motorları: aç ya da kapat. | Arama ve cevap motorları açık. Eğitim botları GEO hedefi yoksa kapalı: robots.txt'de Disallow, Cloudflare'de 'Disallow AI Training'. GEO için açılan eğitim botuna saniyede 1 sayfa, kova önce gölgede; CCBot ve Bytespider varsayılan olarak engelli. 'Block' Googlebot ve Bingbot'u da keser; yeni alan adının hazır ayarı gün 0'da okunur. [Botlar](#botlar) | Ürün sahibi [öneri] |
| İlk kullanıcıdan önce, 8 karar |
| 18 | **Analitik hangi soruları cevaplar, hangi araçla?** Kendi olay tablomuz, PostHog Cloud EU, GA4 ya da Clarity. | Önce ürün sahibinin beş sorusu. Kendi tablomuz, tek olay ucu, ilk build'de on zorunlu olay; üçüncü taraf KVKK adımından sonra, önce web'de. Sonradan eklenen olayın geçmişi yok; Ürün A'da paylaşım sayımı ve PDF sonucu ayrı birer mağaza sürümünü bekledi. [Analitik ve admin](#analitik) | Ürün sahibi [öneri] |
| 19 | **Hatalar nereden görülür?** Kendi notify() ve Error Reporting, Sentry ya da Crashlytics. | Birinci taraf: notify(), /v1/client-errors, Error Reporting ve error_shown olayı. Sentry EU ancak KVKK adımından sonra (Developer $0, Team $26/ay). Her üçüncü taraf SDK işleyen listesine ve mağaza beyanına girer. [Uyarılar](#uyarilar) | Ürün sahibi ve ajan [öneri] |
| 20 | **Uyarılar kime, hangi kanaldan gider?** E-posta, telefona push ya da sohbet kanalı; bir ya da iki kişi. | En az iki kişi. Acil olan iki telefona ve e-postaya, gece de; bugün olan e-postaya ve admin'deki kutuya; gerisi pazartesi özetinde. X kredisi bitince durum günlük inceleme e-postasında bir satırdı; 30 gün fark edilmedi. [Uyarılar](#uyarilar) | Ürün sahibi [öneri] |
| 21 | **Akış gerçek zamanlı bir şey istiyor mu?** Push ve yenileme, açık ekranda yoklama, SSE ya da WebSocket. | Push ve açılışta yenileme; yetmezse yalnız ekran açıkken kısa yoklama (bizde 8 sn); WebSocket en son, canlı ortak çalışma için. 7/24 açık bir WebSocket servisi ayda ~₺2.445; yoklamanın ek bedeli ≈ ₺0. [Gerçek zamanlı](#mesajlasma) | Ürün sahibi ve ajan [kanıtlı] |
| 22 | **Hangi sayfalar aranır, hangileri dışarıda kalır?** Bilgi, katalog ve veri sayfaları; portal, panel, paylaşım linkleri. | Herkese açık sayfa sunucuda tam HTML, bellekten ya da ISR'dan; veritabanına gitmez. Portal, panel, paylaşım linkleri ve test kopyası noindex. Ürün C'nin yeni kategori sayfaları veritabanını günde ~74 kez uyandırdı. [SEO ve GEO](#seo) | Ürün sahibi ve ajan [kanıtlı] |
| 23 | **Admin'e kim girer, oturum ne kadar sürer?** Roller, boşta kalma süresi, oturum tavanı. | E-posta izin listesi; boşta 30 dk, 12 saat tavan. Üç rol (sahip, operatör, salt okuyucu) ve tehlikeli eylemde yeniden kod (öneri). 8 saatlik boşta süre denendi, güvenlik için geri alındı. [Analitik ve admin](#analitik) | Ürün sahibi [kanıtlı] |
| 24 | **Yedekler ne kadar saklanır?** Neon geçmişi, snapshot, günlük döküm ve proje dışı kopya. | Geçmiş 7 gün, snapshot 14 gün, döküm 30 gün ve 7 gün soft delete; gizlilik metni 37 gün yazar. Haftalık proje dışı kopya (öneri) hedefte de 37 günü geçmez: GCS'te lifecycle 28 ve soft delete 7 gün, çünkü döküm kopyalanırken bir iki günlük olabilir. Hedefte daha uzun tutulursa gizlilik metni o süreyi yazar. Launch'ta geçmişin varsayılanı 1 gün; 7'ye elle çıkarılır. [Yedek](#yedek) | Ürün sahibi [ölçüldü] |
| 25 | **Hangi startup kredilerine, ne zaman başvurulur?** Neon, Google, Claude, Sentry, PostHog; şimdi ya da sonra. | Ayrı hesap ve Neon org'u açıldıktan sonra, ağır kullanımdan hemen önce; önce en büyük kalem olan Neon. Süre çoğu programda onay ya da claim günü başlar; erken alınan kredi yanar. [Krediler](#krediler) | Ürün sahibi [öneri] |
| İlk mağaza sürümünden önce, 4 karar |
| 26 | **Mağaza hesapları kimin; build, sürüm ve gönderim kimde?** Kişi ya da şirket hesabı; ajan ya da ürün sahibi. | Build, sürüm numarası, gönderim ve OTA yayını yalnız ürün sahibinin açık sözüyle. Apple, Play ve Expo şirket adına, iki yönetici (öneri). Ajan sürümü sormadan yama yerine ara sürüm numarasını artırdı. [Mobil dağıtım](#dagitim) | Ürün sahibi [kanıtlı] |
| 27 | **Zorunlu güncelleme ve yayın nasıl açılır?** Zorlama: hiç, her sürümde, kırıcı değişiklikte. Yayın: herkese ya da aşamalı. | Zorlama kapalı başlar; ancak Play'de yayın %100 ve App Store'da sürüm yayındayken açılır. App Store'da aşamalı yayın (7 gün), Play'de kademeli; API ile aynı gün açılması gereken sürüm elle yayınla gönderilir, mesai başında açılır. Sonradan eklenen zorlama eski build'lere ulaşmaz (bizde kanıtlı); kademeli yayın bizde denenmedi. [Mobil kit](#mobilkit) | Ürün sahibi [öneri] |
| 28 | **OTA güncelleme kurulacak mı?** expo-updates ya da yok; EAS Update ya da kendi sunucu. | Önerilir, zorunlu değil: ilk mağaza build'inden expo-updates, fingerprint ve kanal; EAS Update Free 1.000 MAU. Her OTA yayını ürün sahibinin kararı. 19 Eylül–7 Ekim'deki 19 mağaza build'inin 11'i yalnız JS idi. [Mobil kit](#mobilkit) | Ürün sahibi [öneri] |
| 29 | **Uygulama içi satın alma olacak mı, durum nereden okunur?** Yok, RevenueCat ya da doğrudan mağaza. | RevenueCat; durum üç yoldan: SDK, 10 dk TTL'li sunucu mutabakatı ve webhook. Webhook ucunda tek 5xx alarmı (öneri). Webhook en az 21 gün 500 döndü; öteki iki yol çalıştığı için kullanıcı etkilenmedi. [Expo mobil](#katman-4) | Ürün sahibi [kanıtlı] |
| Sonra, 3 karar |
| 30 | **İçerik otomasyonu kurulacak mı, hangi platformlarda?** X, Instagram, Facebook Sayfası, Threads, LinkedIn; otomatik ya da onaylı. | Hat kurulmadan otomatik paylaşım yok: şirkete ait hesaplar, insan onayı, X harcama tavanı, platform başına kapatma anahtarı. LinkedIn elle kalabilir. X kredisi bitti; her gün denenen paylaşım 30 gün 402 aldı. [İçerik otomasyonu](#icerik) | Ürün sahibi [öneri] |
| 31 | **Ücretli plana ne zaman geçilir?** EAS Starter, Resend Pro, Workers Paid ya da Neon'da büyük plan. | Eşikler yazılı: EAS Starter yalnız 15 hakkı aşacak ayda; Resend Pro ya da SES haftalık abone ~60'ı geçince; Workers Paid günde ~80.000 istekten önce. Kota bitince build ayın 1'ini bekler; bir iOS sürümü bir hafta kaydı. [Ücretsiz katmanlar](#ucretsiz) | Ürün sahibi ve ajan [ölçüldü] |
| 32 | **Kod açık kaynak olacak mı, hangi lisansla?** Özel depo ya da açık kaynak: MIT, Apache-2.0, AGPL. | Depo özel. Açılacaksa ayrı ve temiz depo, LICENSE, geçmişte sır ve ad taraması; önce özel itilip dosya listesine bakılır. Silinen dosya geçmişte kalır; çıkarmak ancak geçmişi yeniden yazmakla olur. [Depo kuralları](#depo-kurallari) | Ürün sahibi [öneri] |

## Gün 0: hesaplar ve sürümler

İki liste de kod yazılmadan biter. Hesapları ürün sahibi açar, ajan listeyi tutar; sürüm tabanını ajan kurar ve STATUS'a yazar.

### Hesaplar

Her kutuyu ürün sahibi kendi ekranında işaretler; ajan yalnız envanteri tutar.

- [ ] **Şirket adına.** Her hesap şirket adına ve ürünün alan adındaki bir rol adresiyle; kişisel adresler yalnız yönetici. Mobil varsa Apple ve Play kuruluş hesabı D-U-N-S numarası ister. Başvuru gün 0'da yapılır, çünkü numara ve mağaza doğrulaması günler sürebilir. [öneri]

- [ ] **En az iki yönetici.** Bulut, Neon, DNS, alan adı, GitHub, mağazalar, e-posta ve sosyal hesaplarda. [öneri]

- [ ] **Donanım anahtarı ya da passkey.** Kök hesaplarda (Google, kayıt firması, GitHub, Apple, e-posta kutusu), yedek anahtarla. [öneri]

- [ ] **SMS ile kurtarma kapalı.** Mümkün olan her yerde; kurtarma anahtar ya da kodla. [öneri]

- [ ] **Kurtarma kodları iki yerde.** Çevrimdışı, ayrı iki yerde; depoya, sohbete ve e-postaya yazılmaz. [öneri]

- [ ] **Alan adı kilitli.** Transfer kilidi, çok yıllık ve otomatik yenileme, kayıt firmasında iki adımlı doğrulama. [öneri]

- [ ] **Tek sayfa envanter.** Sağlayıcı, sahip, yöneticiler, faturalama, yenileme tarihi; tarihler yenileme tablosunda. [öneri]

- [ ] **Kartlar ve üyelikler takvimde.** 30 ve 7 gün önce hatırlatma; Apple üyeliği düşerse uygulama satıştan kalkar. [öneri]

- [ ] **Ajan hesap açmaz.** Hesap, ödeme ve şart kabulü ürün sahibinin işi; ajan parola ve kurtarma kodu görmez. [öneri]

Tek sayfa envanter; sağlayıcı listesi kararlara göre uzar. Yenileme tarihleri [Uyarılar](#uyarilar) bölümündeki yenileme tablosuna girer.

```
# docs/ACCOUNTS.md: parola, kurtarma kodu ve anahtar buraya yazılmaz
Sağlayıcı        | sahip        | yönetici | faturalama          | yenileme
Google Cloud     | şirket       | 2        | ürünün hesabı       | kart <AA/YY>
Neon             | şirket org'u | 2        | ürünün org'u        | kart <AA/YY>
Alan adı         | şirket       | 2        | çok yıllık, kilitli | <YYYY-AA-GG>
Cloudflare       | şirket       | 2        | Free                | yok
E-posta (Resend) | şirket       | 2        | Free                | yok
GitHub           | şirket org'u | 2        | Free                | yok
Apple Developer  | şirket       | 2        | yıllık üyelik       | <YYYY-AA-GG>
Google Play      | şirket       | 2        | tek seferlik kayıt  | yok
```

### Sürüm tabanı

8 Ekim 2026'da resmi sürüm ve destek sayfalarından okundu. Ajan her yeni projede aynı sayfaları yeniden okur; liste bu başlığın sonunda, tablo o günün fotoğrafıdır.

| Bileşen | En yeni kararlı, 8 Eki 2026 | Destek | Yeni projede |
|---|---|---|---|
| Go | 1.27.1, 1 Eyl 2026 | 1.27: 1.29 çıkınca biter. 1.26: 1.28 çıkınca. | 1.27; go.mod'da go ve toolchain satırı sabit. |
| Node.js | 24.21.0 LTS (7 Eyl 2026). Node 26 LTS'e 28 Eki'de geçer. | 24: 30 Nis 2028. 26: 30 Nis 2029. | 24 LTS, node:24-alpine sabit; 28 Ekim'den sonra açılan proje 26. |
| Next.js | 16.4.0, 6 Eki 2026 | 16: 21 Eki 2027. 15: 21 Eki 2026 (ikisi de politikadan). | 16, output standalone. |
| React | 19.3.0, 9 Eyl 2026 | Tarih yayımlanmıyor. | Web'de Next'in istediği; mobilde Expo'nun 19.2.3'ü. |
| Expo SDK | 57 (57.0.27, 6 Eki 2026), React Native 0.86 | Tarih yok; yılda üç SDK, 58 önizlemede. | 57, CNG, New Arch; Xcode 26.4, iOS 16.4, Android 7 ve üstü. |
| TypeScript | 7.0.2 (7.0 çıkışı 8 Tem 2026) | Tarih yok; 6.0 JavaScript tabanlı son sürüm. | 6.0 (6.0.3) web'de ve mobilde; 7.0'a typescript-eslint 7'yi destekleyince geçilir, güncelleme gününde bakılır. |
| PostgreSQL | 18.6; Neon 14–18'i destekler | 18: 14 Kas 2030. 14: 12 Kas 2026. | 18; test, döküm imajı ve yerel aynı ana sürümde. |
| pgx | v5.11.0, 7 Eyl 2026 | Go'nun son iki sürümü, Postgres'in son 5 yılı. | v5, varsayılan bağlantı modu. |

### Sürüm kuralları

1. Her bileşen en yeni kararlı sürümle başlar; Node.js'te kararlı sürüm LTS'tir. Desteğine 6 aydan az kalan sürümle başlanmaz.

8 Ekim 2026'da Next.js 15'in desteğinin bitmesine 13 gün, PostgreSQL 14'ünkine 35 gün kalmıştı. İstisna, araç zincirinin henüz desteklemediği sürümdür; bugün TypeScript 7. [öneri]

2. Mobilde React Native, React ve TypeScript Expo SDK'nın getirdiği sürümde kalır; SDK birlikte yükseltilir.

Expo her SDK'yı tek bir React Native sürümüne göre çıkarır; SDK 57, 0.86 ve React 19.2.3 ister. [öneri]

3. Renovate ya da Dependabot gün 0'da açılır; sürüm tabanı tek yerde, docs/STATUS.md'nin Sürümler bölümünde durur.

PR'lar haftalık gruplanır, ayda bir güncelleme gününde test dalında birlikte alınır; güvenlik yaması beklemez. [öneri]

4. STATUS'ta her bileşenin destek bitişi yazılır ve güncelleme gününde resmi sayfayla karşılaştırılır.

STATUS ajanın ilk 5 dakikada okuduğu dosyadır. [öneri]

### Desteğin bitmesine kalan süre

6 aydan fazla6 aydan az: yeni projede kullanılmaz
_Grafik: Desteğin bitmesine kalan süre, 8 Ekim 2026: PostgreSQL 18 ~49 ay (14 Kas 2030); Node.js 26 (LTS 28 Eki'de) ~31 ay (30 Nis 2029); Node.js 24 LTS ~19 ay (30 Nis 2028); Next.js 16 ~12 ay (21 Eki 2027); Node.js 22 ~7 ay (30 Nis 2027); PostgreSQL 14 35 gün (12 Kas 2026); Next.js 15 13 gün (21 Eki 2026)_
Yalnız tarihi yayımlanmış ana sürümler; Go, React, Expo SDK, TypeScript ve pgx tarih yayımlamıyor. Next.js tarihleri destek politikasından hesaplandı (ilk çıkış ve iki yıl).

STATUS'taki sürüm satırları; tarihi olmayan bileşen için neye bakılacağı yazılır.

```
## Sürümler. Son kontrol: 2026-10-08. Güncelleme günü: ayda bir, <gün>.
Desteğine 6 aydan az kalan satır TODO'ya P1 girer.
- Go 1.27.1: 1.29 çıkınca biter.
- Node.js 24.21.0 LTS: 2028-04-30 (Node 26, 2026-10-28'de LTS olur).
- Next.js 16.4.0: 2027-10-21. PostgreSQL 18 (Neon): 2030-11-14. pgx v5.11.0.
- Expo SDK 57 (React Native 0.86, React 19.2.3): tarih yok; yeni SDK'da bak.
- React 19.3.0 yalnız web'de: tarih yok; yeni sürümde bak. Mobilde React'i Expo belirler.
- TypeScript 6.0.3: tarih yok (7.0.2 çıktı; typescript-eslint henüz <6.1).
```

### Okunan sayfalar

Sürümler ve destek tarihleri 8 Ekim 2026'da bu sayfalardan okundu.

**Go sürümleri**https://go.dev/dl/?mode=json
**Go sürüm geçmişi ve destek kuralı**https://go.dev/doc/devel/release
**Node.js sürümleri**https://nodejs.org/dist/index.json
**Node.js sürüm takvimi**https://raw.githubusercontent.com/nodejs/Release/main/schedule.json
**Next.js destek politikası**https://nextjs.org/support-policy
**React sürümleri**https://react.dev/versions
**Expo SDK sürümleri ve istekleri**https://docs.expo.dev/versions/latest/
**TypeScript güncel sürüm**https://www.typescriptlang.org/download
**TypeScript sürüm duyuruları**https://devblogs.microsoft.com/typescript/
**Neon'un desteklediği Postgres sürümleri**https://neon.com/docs/postgresql/postgres-version-policy
**PostgreSQL sürüm politikası**https://www.postgresql.org/support/versioning/
**pgx: desteklenen Go ve Postgres sürümleri**https://github.com/jackc/pgx
**pgx sürümü**https://proxy.golang.org/github.com/jackc/pgx/v5/@latest
**npm sürüm kayıtları: next, expo, typescript, typescript-eslint**https://registry.npmjs.org/

## Ajanın kurulum planı

[En hızlı kurulum yolu](#hizli) sırayı tek satırla verir; bu plan her adımın ne ürettiğini, nasıl doğrulandığını ve nerede durulduğunu yazar. Aşama adları [Kontrol listesi](#kontrol) ile aynıdır; sağdaki bağlantı adımın kurallarına gider.

**Prod'a dokunan komut:** Projede bir şey kuran ya da yetki veren her komut (IAM, servis hesabı, servis, tetikleyici, bütçe, alarm, sır değeri) ve prod Neon rolleri ajanın yazdığı betikte toplanır. Ürün sahibi betiği okur, kendi kimliğiyle çalıştırır ve çıktıyı ajana verir. Ajanın kendi kimliği projede yalnız okur, IAM komutları onda engellidir ([Gün 0 önlemleri](#onlemler) 5 ve 6). Test ve prod aynı projede durduğu için proje düzeyinde verilen yazma rolü ikisini birden açar. Ajan test ortamına test dalına push ederek çıkar. [öneri]

### Gün 0: kod yazılmadan

Akışların kodu bu aşama bitince başlar.

### 1. Kararları sor ve kaydet

[Proje hafızası](#hafiza)
**Üretir:** docs/DECISIONS.md, K-001'den. Cevapsız satır AGENTS.md'de 'KARAR BEKLİYOR' ve TODO'nun karar bekleyen bölümünde.

**Doğrular:** Her gün 0 kararının ya K numarası ya TODO satırı var.

**DUR:** Ürün sahibi gün 0 kararlarını verir; cevapsız kararın adımı başlamaz.

### 2. Proje hafızası

[Proje hafızası](#hafiza)
**Üretir:** AGENTS.md (deploy kuralı en üstte), CLAUDE.md'de yalnız @AGENTS.md, CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/runbooks/.gitkeep, docs/handoff/.gitkeep, .gitignore, .env.example (yalnız adlar). Sonraki adımların dosyaları bu adlarla açılır: docs/ACCOUNTS.md (3), docs/ALERTS.md (yenileme tablosu 3'te, uyarı listesi 16'da), sürüm tabanı docs/STATUS.md'nin Sürümler bölümünde (6), docs/KVKK.md (12), PRODUCT.md, DESIGN.md ve tokens/tokens.json (14).

**Doğrular:** `git ls-files` hepsini listeler; Claude Code'un /memory listesinde AGENTS.md var.

### 3. Hesaplar

[Uyarılar](#uyarilar)
**Üretir:** docs/ACCOUNTS.md'de hesap envanteri: sahip, iki yönetici, faturalama, yenileme tarihi; tarihler docs/ALERTS.md'deki yenileme tablosunda.

**Doğrular:** Envanterde boş hücre yok; kök hesaplarda anahtar ürün sahibiyle ekranda görüldü.

**DUR:** Hesabı ürün sahibi açar, şartı o kabul eder, ödeme yöntemini o girer.

### 4. Faturalama ve bütçe

[Ücretsiz katmanlar](#ucretsiz)
**Üretir:** Ürünün faturalama hesabı ve Neon org'u; %50, %80, %100 bütçe ve Pub/Sub; kredisiz ikinci bütçe; BigQuery fatura dökümü.

**Doğrular:** `gcloud billing budgets list --billing-account=FATURA_HESABI` ürünün faturalama hesabında iki bütçe ve üç eşik gösterir.

**DUR:** Faturalama hesabı ve Neon'un ücretli planı ürün sahibinin kartıyla açılır.

### 5. Alan adı ve DNS

[Kenar ve DNS](#katman-5)
**Üretir:** Cloudflare'de kayıtlar başta gri; web Worker ile run.app'e, api. domain mapping ile; transfer kilidi, çok yıllık yenileme; dört güvenlik firmasına kategori başvurusu.

**Doğrular:** `dig +short NS ALAN` Cloudflare'i, whois clientTransferProhibited'ı gösterir.

**DUR:** Alan adını ürün sahibi kaydeder.

### 6. Depolar ve sürümler

[Depo kuralları](#depo-kurallari)
**Üretir:** Özel depolar, test ve main; gitleaks, push protection, 1 MB ve ikili kapısı; tablodaki sürümler, STATUS'taki taban, Renovate.

**Doğrular:** Sahte anahtarlı ya da 2 MB'lık commit reddedilir; main'e force push ve main'i silme reddedilir, test'ten main'e fast-forward push geçer; desteğine 6 aydan az kalan sürüm yok.

[öneri] GitHub'da main'e PR şartı konmaz. GitHub'ın birleştirmesi yeni commit üretir; main test'le eşit kalmaz ve main tetikleyicisi test'in `$COMMIT_SHA` etiketli imajını bulamaz.

### 7. Neon

[Postgres](#katman-1)
**Üretir:** Prod Launch'ta Frankfurt'ta, Postgres 18; test Free org'da; üç rol, rol zaman aşımları, geçmiş 7 gün; MinConns=0, MaxConnIdleTime=90s.

**Doğrular:** Pooler üzerinden jsonb, bytea ve dizi testi geçer; son istekten ~6,5 dakika sonra (havuz 90 sn + Neon 5 dk) compute uyur, Neon'un saatlik tüketiminde görülür.

**DUR:** Prod Neon'un rolleri, zaman aşımları ve geçmiş süresi betikle, ürün sahibinin kimliğiyle kurulur. Ajanda yalnız test Neon'u ve prod'un salt okunur rolü durur.

### 8. Servisler ve hat

[CI/CD](#katman-7)
**Üretir:** API ve web europe-west1'de min 0, max 2–3 ve 3, CPU boost, Next'e 1 GiB, service.yaml; tek Docker deposu, bölgesel tetikleyici, temizlik kuralı; test digest üretir, main onayla terfi eder. Tetikleyiciler baştan kendi build hesabıyla kurulur. Bu hesap roles/run.admin, roles/artifactregistry.writer ve roles/logging.logWriter taşır. roles/iam.serviceAccountUser proje genelinde verilmez, yalnız deploy ettiği çalışma hesaplarının üstünde verilir. Build dosyasında `options: logging: CLOUD_LOGGING_ONLY` bulunur; kendi hesabıyla koşan build bu satır olmadan başlamaz.

**Doğrular:** Depo tanımında cleanupPolicyDryRun yok ya da false; test push'unun build'i kendi build hesabıyla SUCCESS.

**DUR:** Servisler, tetikleyiciler ve Docker deposu betikle, ürün sahibinin kimliğiyle kurulur.

[öneri] Canlıya çıkış sırası şöyledir. Ajan test'te doğrular ve tek satır rapor verir. Ürün sahibi "deploy" der. Ajan `git push origin test:main` ile main'i ileri sarar. main tetikleyicisi onay bekler. Onayı ürün sahibi verir. roles/cloudbuild.builds.approver rolü yalnız ondadır, ajanın kimliğinde yoktur. Aynı sıra docs/runbooks/deploy.md'de yazılır.

### 9. Yetki ve sırlar

[Güvenlik](#katman-8)
**Üretir:** Compute hesabında Editor varsa, tetikleyiciler kendi build hesabına geçtikten sonra kaldırılır. Servisler rolsüz kendi hesabıyla çalışır; sırlar Secret Manager'da, tek etkin sürüm. WIF yalnız GitHub Actions'ta koşan iş için kurulur, Cloud Build'e gerekmez.

**Doğrular:** `gcloud projects get-iam-policy PROJE --flatten='bindings[].members' --filter='bindings.role=roles/editor' --format='value(bindings.members)'` boş döner. Compute, build ve uygulama hesapları bu listede yoktur. Listede Google'ın kendi hizmet aracısı `PROJE_NO@cloudservices.gserviceaccount.com` çıkarsa ona dokunulmaz. Bazı API'ler kullanılınca Google bu hesabı Editor ile kurar ve rolün kalmasını ister.

**DUR:** Bu adımın bütün komutları betikle, ürün sahibinin kimliğiyle çalışır. Sır değerini Secret Manager'a ürün sahibi yazar, ajan değeri görmez.

[öneri] Mayıs 2024'ten sonra açılan şirket organizasyonunda compute hesabı zaten rolsüz gelir; tetikleyici 8. adımda kendi hesabını almadıysa ilk build yetki hatasıyla düşer.

### 10. Okuma yolu ve kapı

[Mimari](#mimari)
**Üretir:** Herkese açık okumalar API belleğinden, GCS işaretiyle; veritabanısız /health; proxy.ts'in ilk satırında ortak listeli kapı; güvenlik başlıkları, CSP report-only.

**Doğrular:** Herkese açık sayfada 'db wake' satırı yok; /.env 404; veritabanı kapalıyken /health 200.

### 11. E-posta

[E-posta](#katman-9)
**Üretir:** Resend AB, auth. ve news.; SPF, DKIM, DMARC; outbox; günlük ortak sayaç: 70'te uyarı, 80'de toplu gönderim durur, kodlar 100'e kadar; web kod formunda Turnstile; API'de App Check doğrulaması, mobil varsa mobil kod ucu token'sız isteği ilk günden reddeder; yedek sağlayıcı SES aynı auth. alt alan adında.

**Doğrular:** Alan adları sağlayıcıda doğrulanmış; test ortamından izinli adrese kod geldi; test ortamında sayaç 100'e çekilince kod SES'ten gerçek bir gelen kutusuna geldi.

**DUR:** Sağlayıcı hesaplarını (Resend ve SES) ve ücretli planı ürün sahibi açar, SES'in sandbox'tan çıkış başvurusunu o yapar; gönderim anahtarlarını Secret Manager'a da o yazar.

### 12. KVKK

[KVKK](#kvkk)
**Üretir:** Veri yeri, işleyen listesi ve aktarım dayanağı tek belgede; gizlilik metni taslağı.

**Doğrular:** Kodda ve faturada geçen her sağlayıcı listede.

**DUR:** Standart sözleşme, Kurum'a bildirim ve metin ürün sahibinde ve hukukçuda.

### 13. Ücretli dış API (varsa)

[Pahalı API'ler](#pahali-api)
**Üretir:** 'Her ücretli API'den önce' listesinin cevapları; sağlayıcıda günlük kota. Ürüne özel, kısıtlı anahtar 16. adımın uyarıları denendikten sonra açılır.

**Doğrular:** Kota konsolda görünür; günlük maliyet sorgusu SKU kırılımıyla çalışır.

**DUR:** Ürün sahibi günlük, aylık ve en kötü gün rakamını onaylar.

### 14. Tasarım kaynağı

[Tasarım sistemi](#tasarim)
**Üretir:** tokens/tokens.json, ondan üretilen CSS ve mobil tema, DESIGN.md; koyu tema kararı DECISIONS'ta.

**Doğrular:** CI token dışı hex'leri sayar; yeniden üretilen dosyalarda fark yok.

### 15. Mobil iskelet (mobil seçildiyse)

[Mobil kit](#mobilkit)
**Üretir:** Expo SDK 57, CNG, New Arch; app.config'te DECISIONS'taki bundle ID, paket adı ve şema; eas.json'da profil ortamları; kit iskeleti: sürüm başlıkları, update-policy, zorunlu güncelleme ekranı, push kaydı. Yerel yol: `eas build --local`, fastlane, ANDROID_HOME. App Check debug sağlayıcısı yalnız test ve yerel build'de; debug token'ları sırdır, depoya yazılmaz.

**Doğrular:** Yerelde preview profiliyle alınan build'in istekleri test API logunda X-App-Build ile görünür. Token'sız kod isteği test API'de reddedilir.

**DUR:** Bulut build'i ürün sahibinin sözüyle; gün 0'da build yerelde alınır.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'Gün 0' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a yazılır, ürün sahibine tek satır rapor gider. Boş kutu varken akışların koduna geçilmez.

### İlk kullanıcıdan önce

İlk gerçek kullanıcı bu aşama bitince gelir.

### 16. Uyarılar ve alarmlar

[Uyarılar](#uyarilar)
**Üretir:** alerts tablosu, notify(), acil ve bugün log alarmları; uptime 300 sn; 5xx, OOM, ERROR > 0, webhook tek 5xx; denetim işi; pazartesi özeti.

**Doğrular:** Her uyarı türü [TEST] ile uçtan uca denendi; iki alıcı postayı ve telefondaki bildirimi gördüğünü yazdı.

**DUR:** Alıcıların e-posta adresi ve Google hesabı ürün sahibinden gelir. Telefon numarası istenmez.

[öneri] Telefon kanalı Google Cloud mobil uygulamasıdır. İki alıcı uygulamayı kurar, projeye erişimi olan kendi hesabıyla girer ve projeyi seçer. Cihaz birkaç dakikada kanal listesine düşer. Ajan onu acil politikasına ekler ve TEST uyarısıyla dener. SMS kurulmaz, yedek kanal e-postadır. Bu kanal bizde denenmedi.

### 17. Analitik ve admin

[Analitik ve admin](#analitik)
**Üretir:** POST /v1/events, on zorunlu olay; ayrı admin girişi, izin listesi; admin_audit aynı işlemde; bayrak, politika ve duyuru veritabanında.

**Doğrular:** Token'sız admin çağrısı ve denetim satırı testleri yeşil; olay ucu gerçek Postgres'e karşı test edildi.

### 18. Yedek

[Yedek](#yedek)
**Üretir:** Günlük döküm, geçici Postgres'e geri yükleme, boyut karşılaştırması, 'backup ok', iki alarm, haftalık proje dışı kopya, restore-db.md.

**Doğrular:** Bozuk bir çalışmada alarm geldi; bir elle geri yükleme yapıldı, süresi runbook'ta.

### 19. Kırmama sözleşmeleri

[Kırmadan değiştirmek](#kirmama)
**Üretir:** 401 ve 503 sözleşme testi, yalnız ekleyen migration denetimi, varsayılan kapalı anahtarlar, deploy.md ve rollback.md.

**Doğrular:** Sözleşme testinde veritabanı havuzu kimsenin dinlemediği bir adrese (127.0.0.1:1) bağlanır; oturumlu uç 503, token'sız ya da bozuk token'lı istek 401 döner. Neon compute'u askıya almak bu durumu üretmez, ilk bağlantı onu uyandırır. Erişilemeyen adresle revizyon açmak da denenmez: API açılışta veritabanını 30 sn bekler, gelmezse kapanır; revizyon hiç açılmaz. Test ortamında önceki revizyona dönüldü.

### 20. SEO ve GEO (herkese açık sayfa varsa)

[SEO ve GEO](#seo)
**Üretir:** Search Console DNS TXT ile, Bing; istek anında sitemap, canonical; robots.txt kapıdan; OG kartları; panelde noindex.

**Doğrular:** Her sayfa tipi JavaScript'siz curl ile okunur; sitemap sayısı curl ile eşit; sayfa ve sitemap istekleri 'db wake' yazmaz.

**DUR:** Siteyi herkese açmak ürün sahibinin kararı.

### 21. Gerçek zamanlı (akış istiyorsa)

[Gerçek zamanlı](#mesajlasma)
**Üretir:** Seçilen basamak ve nedeni; istemci anahtarlı mesaj tablosu; bildirim, silme, rapor ve engel kuralları.

**Doğrular:** Arka planda ve gizli sekmede yoklama isteği 0, logdan okundu.

### 22. Startup kredileri

[Krediler](#krediler)
**Üretir:** Başvuru dosyası: iş e-postası, ürün tanımı, kullanım rakamları; kredi kaydı ve bitişten bir hafta önce hatırlatma.

**Doğrular:** Her kredinin bitişi yenileme tablosunda.

**DUR:** Başvuruyu ve claim'i ürün sahibi yapar.

### 23. İlk canlı çıkış ve ölçüm

[Kırmadan değiştirmek](#kirmama)
**Üretir:** Test'te doğrulanan digest'in terfisi, candidate duman testi, ertesi sabah kontrolü; performans hedef tablosu.

**Doğrular:** Kural 8.1: build, revizyon, sağlık 200, ilk 30 dakikada 5xx 0; ilk p50 ve p90 STATUS'ta.

**DUR:** Canlıya deploy ürün sahibinin sözüyle.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'İlk kullanıcıdan önce' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a, ürün sahibine tek satır rapor. Boş kutu varken ilk gerçek kullanıcı alınmaz.

### İlk mağaza sürümünden önce

Yalnız mobil varsa.

### 24. Kit ve yayın kapısı

[Mobil kit](#mobilkit)
**Üretir:** Kitin OTA dışındaki on parçası; yayın kapısının 19 maddesi kanıtlarıyla sürüm notunda. OTA seçilmediyse 11. madde 'seçilmedi' ve karar numarasıyla (K-NNN) yazılır; seçildiyse 28. adımda kurulur.

**Doğrular:** İki platformun release build'i gerçek telefonda; zorunlu ekran önceki mağaza build'inde görüldü.

[öneri] App Check'in gerçek sağlayıcıları: Play Console'da uygulama ve bağlı proje, uygulama imzasının SHA-256'sı Firebase'de; iOS'ta App Attest yeteneği, entitlement 'production'. Yerel build Play onayı almaz, App Attest'in sandbox token'ı kabul edilmez; bu yüzden test build'i debug sağlayıcıyla çalışır, mağaza build'inde debug sağlayıcı yoktur. Firebase işleyen listesinde.

### 25. Mağaza hazırlığı

[Expo mobil](#katman-4)
**Üretir:** Play hesabı şirket adına; hesap kişisel açıldıysa 12 testçili 14 günlük kapalı test ilk sürümden en az 3 hafta önce başlar. Uygulama içi silme, gizlilik formları, inceleme hesabı.

**Doğrular:** Formlar her SDK'yı kapsar; inceleme hesabının her girişi log yazar.

**DUR:** Mağaza formlarını ve beyanları ürün sahibi gönderir.

### 26. Build bütçesi ve gönderim provası

[Mobil dağıtım](#dagitim)
**Üretir:** Platform başına aylık build bütçesi README'de; yerelde alınan build'le `eas submit --path` provası; App Store Connect kaydının kimliği eas.json'da ascAppId olarak.

**Doğrular:** `eas account:usage` kalan hakkı gösterir; yerel build mağazanın iç test kanalına ulaştı. İlk Android gönderimi iç test kanalına gider; mağaza girişi ve formlar bitene kadar uygulamanın Play Console'da taslak kalması prova hatası sayılmaz.

**DUR:** Her bulut build'i, gönderim ve sürüm numarası ürün sahibinin açık sözüyle. Provadan önce ürün sahibi Play Console'da uygulamayı açar ve Play servis hesabı anahtarını EAS'a yükler; App Store Connect'te uygulama kaydını açar.

### 27. Ödeme (satış varsa)

[Expo mobil](#katman-4)
**Üretir:** RevenueCat, 10 dk TTL'li sunucu mutabakatı, ham gövdeyi kaydeden webhook, tek 5xx alarmı.

**Doğrular:** Sağlayıcı panelinde bir teslim başarılı; webhook kapalıyken Premium doğru.

### 28. OTA (seçildiyse)

[Mobil kit](#mobilkit)
**Üretir:** expo-updates, fingerprint, kanal eşlemesi; ortamı zorlayan yayın betiği.

**Doğrular:** Preview güncellemesi release build'de uygulandı; hatalı güncellemede geri dönüş denendi.

**DUR:** Her OTA yayını ürün sahibinin kararı.

**Aşama sonu:** [Kontrol listesi](#kontrol)'nin 'İlk mağaza sürümünden önce' kutuları işaretlenir; sonuç sürüm notuna ve STATUS'a, ürün sahibine tek satır rapor. Boş kutu varken mağazaya gönderilmez.

### Sonra

Sürekli; ajan takvimden yürütür.

### 29. Her hafta

[Performans](#performans)
**Üretir:** p50 ve p90, soğuk başlangıç, uyanış ve OOM; pazartesi özeti; 7 günlük sürüm dağılımı.

**Doğrular:** STATUS'ta haftanın satırı.

### 30. Her ay

[Kontrol listesi](#kontrol)
**Üretir:** Fatura SKU kırılımıyla, Neon tüketimi, yedek, geri dönüş imajı, 60 günün yenilemeleri; güncelleme günü ve destek bitişleri.

**Doğrular:** 'Her ay' kutuları işaretli; 6 aydan az kalan sürüm TODO'da P1.

**DUR:** Güncellemelerin main'e alınması ürün sahibinin sözüyle.

### 31. Üç ayda bir

[Yedek](#yedek)
**Üretir:** Son döküm yeni bir Neon dalına tam yüklenir, md5 karşılaştırılır; ücretsiz katman şartları yeniden okunur.

**Doğrular:** Süre runbook'ta; değişen sınır tabloda.

### 32. Yeni SDK, işleyen ya da platform

[KVKK](#kvkk)
**Üretir:** KVKK listesi, gizlilik metni, App Store etiketi ve Data safety aynı gün güncellenir.

**Doğrular:** Yeni SDK listede ve iki mağaza beyanında.

### 33. İçerik otomasyonu (seçildiyse)

[İçerik otomasyonu](#icerik)
**Üretir:** Hattın on bir parçası, açılış kapısının 17 maddesi, bir haftalık kuru çalışma.

**Doğrular:** Bozuk token'la alarm geldi; aynı iş iki kez çalışınca ikinci yayın yok.

**DUR:** Otomatik paylaşımı ürün sahibi açar.

**Aşama sonu:** Her ay [Kontrol listesi](#kontrol)'nin 'Her ay' kutuları işaretlenir; sonuç STATUS ve CHANGELOG'a yazılır, ürün sahibine tek satır rapor gider.

## Bitti sayılır

Altyapı bu kutular işaretlenince teslim edilmiş sayılır. Bundan sonra ajan haftalık, aylık ve üç aylık işleri takvimden yürütür.

- [ ] **Kararlar.** Gün 0 ve ilk kullanıcı kararlarının hepsi DECISIONS.md'de; 'KARAR BEKLİYOR' yalnız sonraki aşamaların satırlarında.

- [ ] **Hafıza.** AGENTS.md, CHANGELOG, STATUS, TODO, DECISIONS ve deploy, rollback, restore-db runbook'ları depoda; STATUS'un her canlı satırı doğrulama yöntemi ve tarihiyle.

- [ ] **Hesaplar.** Envanter dolu; her hesapta iki yönetici, kök hesaplarda anahtar, yenilemeler takvimde.

- [ ] **Sürümler.** Tablo STATUS'ta destek bitişleriyle; Renovate ya da Dependabot açık.

- [ ] **Yol.** test'e push test ortamına çıkıyor; main onay kapısından aynı digest'le; bir kez önceki revizyona dönüldü.

- [ ] **Veritabanı uyuyor.** Boş saatte Neon uyuyor; saatlik tüketim ve 'db wake' satırları okundu.

- [ ] **Para.** Bütçe uyarıları ve kota tavanları kurulu; her ücretli işin günlük ve aylık rakamı yazılı.

- [ ] **Uyarılar.** Her tür [TEST] ile denendi; iki alıcı gördüğünü yazdı.

- [ ] **Yedek.** Her gün geri yüklenerek denetleniyor; bir elle geri yükleme yapıldı, süresi runbook'ta.

- [ ] **Olay ve admin.** Olay ucu ve on zorunlu olay; admin ayrı girişle ve denetim kaydıyla.

- [ ] **Mobil.** Seçildiyse kitin yayın kapısı kanıtlarıyla geçti; yerel build yolu prova edildi.

- [ ] **Devir.** Ürün sahibine tek sayfa not: ne kuruldu, nasıl doğrulandı, hangi karar bekliyor.
