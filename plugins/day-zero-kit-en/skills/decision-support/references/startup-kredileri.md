<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="krediler"></a>

Startup kredileri

# Nereye, ne zaman başvurulur

Kredi programları yeni bir ürünün ilk 6–24 ayında bulut, veritabanı ve model faturasını sıfıra yakın tutabilir. Süre çoğu programda onay ya da claim günü başlar ve kalan kredi süre bitince yanar; asıl soru nereye ve ne zaman başvurulacağı.

Bilgiler 8 Ekim 2026'da resmi program sayfalarından doğrulandı; doğrulanamayanlar bölümün sonundaki [Doğrulanamayanlar](#kr-dogrulanamayan) kutusunda. Sıra bizim boyutumuzdaki bir ürün için yazıldı: kendi parasıyla dönen, Türkiye'de, küçük bir ekip.

**Bizim durumumuz:** $1.000
Claude API kredisi 5 Nisan 2027'ye kadar
1 yıl
Claude Team ücretsiz
Ürün A 7 Ekim 2026'da Claude for Startups'a kabul edildi: 6 ay geçerli $1.000 Claude API kredisi ve bir yıl ücretsiz Claude Team.

Başka bir programa henüz başvurulmadı. Sıradaki başvuru Neon'un programı, çünkü faturanın en büyük kalemi Neon.

## Önce

Ürün canlıya çıkarken, ağır kullanım başlamadan.

### Claude for Startups (Anthropic)

https://claude.com/programs/startups
Bizde: alındı, 7 Ekim 2026.

**Ne verir:** Tek seferlik $1.000 Claude API kredisi, 6 ay geçerli, ve daha yüksek API hız sınırı. Team'e yeni gelen organizasyona 5 koltuğa kadar 1 yıl ücretsiz Claude Team. Ortak ağdaki bir VC'nin desteklediği girişime o VC üzerinden en fazla $100.000 ek kredi.

**Kimler alır:** Son 5 yılda kurulmuş ya da son 2 yılda yatırım almış girişim; VC şartı yok. Claude Console hesabı ve siteyle aynı alan adında bir şirket e-postası gerekir.

**Bizde neyi öder:** Yalnız Claude API ve claude.ai koltukları. Cloud Run, Neon ve öteki kalemlere dokunmaz.

**Dikkat:** Süre bizde claim günü başladı; 6 ay dolunca kalan kredi yanar. Auto-reload kapalı kalır, yoksa bakiye karttan dolar. Kredinin büyüklüğü, bitince ödenemeyecek ağır modellere geçmenin gerekçesi olmamalı.

### Neon (Databricks Startup Program)

https://neon.com/startups
Bizde: sıradaki başvuru.

**Ne verir:** Kendi parasıyla dönen girişime en fazla $1.000 Neon kredisi, onboarding desteği ve yeni özelliklere erken erişim. VC destekli girişime Neon ve Databricks için toplam en fazla $200.000. Kredi kabulden itibaren 12 ay geçerli.

**Kimler alır:** Kendi parasıyla dönen kolda toplam yatırım $1 milyonun altında, ürün erken aşamada ya da MVP'de. VC kolu en az $1 milyon yatırım ya da tanınmış bir hızlandırıcı ister. Mevcut Neon kullanıcısı da başvurabilir; kredi var olan hesaba eklenir.

**Bizde neyi öder:** En büyük kalem olan Postgres compute ve depolama. Ürün A'nın Neon kalemi ayda ~₺500, 12 ayda ~₺6.000 (~$120) eder; $1.000 bunu rahatça karşılar.

**Dikkat:** 12 ay dolunca ya da kredi bitince seçili planda normal fatura başlar. Sayfa kredinin hangi projelere uygulanacağını söylemiyor; organizasyonda başka ürünlerin projeleri varsa krediyi onlar da harcar.

### Google for Startups Cloud Program

https://cloud.google.com/startup
Bizde: Ürün A yaş sınırı yüzünden uymuyor; yeni bir ürün için ilk başvurulardan biri.

**Ne verir:** Start: $2.000 Google Cloud kredisi (12 ay) ve 12 ay ücretsiz Workspace Business Plus. Scale: 2 yılda en fazla $200.000. AI-first girişime Scale'de 2 yılda en fazla $350.000.

**Kimler alır:** Start: çalışan bir MVP, son 24 ayda kurulmuş olmak, ücretsiz deneme dışında GCP kredisi almamış olmak ve yakında VC yatırımı arama planı. Scale: kurumsal yatırımcı ya da VC'den pre-seed ile Seri A arası yatırım.

**Bizde neyi öder:** Cloud Run, Cloud Build, Artifact Registry, Secret Manager, Scheduler, Logging ve Google'ın modelleri. Neon'u ödemez, çünkü Marketplace dahil üçüncü taraf hizmetler kapsam dışı; Vertex'te çağrılan Claude da krediden düşmez.

**Dikkat:** Kredi seçilen billing hesabına yatar, o hesaba bağlı her proje harcayabilir. Start 12 ayda biter, sonra dosyadaki karttan fatura başlar. Başvurudaki e-posta, site ve billing hesabının e-postası aynı alan adında olmalı.

## Sonra

O aracı gerçekten kurarken, şartlar hâlâ tutuyorsa.

### Sentry for Startups

https://sentry.io/for/startups/
**Ne verir:** 12 ay geçerli, en fazla $5.000 Sentry kredisi.

**Kimler alır:** Son 2 yılda kurulmuş, $5 milyonun altında VC yatırımı almış ve Sentry'ye hiç ödeme yapmamış girişim. Önce ücretsiz bir Sentry hesabı açılır.

**Bizde neyi öder:** Hata ve performans izleme. Bizde hatalar Cloud Logging, uptime kontrolü ve 5xx alarmıyla izleniyor; Sentry KVKK adımlarından sonra.

**Dikkat:** 2 yıllık pencere dar. 12 ay sonra ne olduğu sayfada yazmıyor. Çökme verisi KVKK adımlarından sonra gönderilir.

### GitHub for Startups

https://github.com/enterprise/startups
**Ne verir:** Onaydan itibaren 12 aya kadar geçerli $10.000 GitHub kredisi: Enterprise, Copilot, Advanced Security ve Actions.

**Kimler alır:** Onaylı bir GitHub for Startups partnerine bağlı ve Seri B'ye kadar dış yatırım almış girişim. Partner bir yatırımcı, kuluçka merkezi ya da hızlandırıcı olabilir.

**Bizde neyi öder:** Kod barındırma, CI ve Copilot. Bizim build'lerimiz Cloud Build'de.

**Dikkat:** Onboarding'den birkaç hafta sonra karttan yetkilendirme çekimi yapılır; kredi bitince ürünler karttan faturalanır. Süre dolmadan plan düşürülürse kalan kredi yanar.

## Gerekirse

O platformda gerçek bir iş yükü ya da yatırım olunca.

### AWS Activate (Founders ve Portfolio)

https://aws.amazon.com/startups/credits
**Ne verir:** Founders: $1.000 Activate kredisi, seçilenlere en fazla $5.000. Portfolio: bir Activate Provider'ın (hızlandırıcı, melek yatırımcı ya da VC) Org ID'siyle en fazla $200.000.

**Kimler alır:** Pre-Seri B ve son 10 yılda kurulmuş girişim. AWS hesabı Paid Tier planında olmalı; site ya da herkese açık profil başvurudaki şirket adını göstermeli.

**Bizde neyi öder:** AWS'de değiliz. Anlamlı tek kullanım Amazon Bedrock: Claude'u Bedrock üzerinden çağırırsak LLM kalemini öder. Claude kredisi varken gerek yok.

**Dikkat:** Paid plan şartı yüzünden kart baştan tanımlı, kredi bitince fatura sessizce başlar. Bitiş tarihi yalnız Billing konsolunda görünür. Bedrock ikinci bir sağlayıcı entegrasyonu ve ikinci bir fatura demek.

### Microsoft for Startups (Azure)

https://learn.microsoft.com/en-us/startups/microsoft-for-startups/overview
**Ne verir:** Resmi sayfalar tutarı farklı anlatıyor. SSS'ye göre yatırımcısız ve Azure'a yeni gelen girişim 90 gün geçerli $1.000 ile başlar, iş doğrulamasından sonra 180 gün geçerli ek $4.000 alır. Başvuru sayfası onaydan sonra en fazla $150.000 diyor.

**Kimler alır:** Kayıtlı şirket adı ve adresi resmi belgelerle aynı olan, özel ve kâr amaçlı, Seri C öncesi bir yazılım girişimi. Kayıt, daha önce Azure açılmamış kişisel bir Microsoft hesabıyla yapılır.

**Bizde neyi öder:** Azure kullanmıyoruz. Krediyi kullanmak iş yükünü Azure'a taşımak, yani mimariye kilit demek.

**Dikkat:** Kart zorunlu; kredi bitince kullandıkça öde planına geçilir. Sözleşme kabulünden sonra 90 gün içinde aktive edilmeyen teklif düşer. Kredi başka hesaba taşınmaz.

### Cloudflare for Startups

[cloudflare.com/forstartups](https://www.cloudflare.com/forstartups/)
**Ne verir:** Tier 3: $10.000 (yatırım $1 milyonun altında). Tier 2: $100.000, Tier 1: $350.000 (anlaşmalı bir partnerden yatırım). Krediler 1 yıl ya da bitene kadar geçerli.

**Kimler alır:** En fazla 10 yıl önce tescil edilmiş şirket, aktif bir ürün, doğrulanabilir canlı bir site ve iş e-postası. Program girişim başına bir kez verilir.

**Bizde neyi öder:** Workers, KV, D1, Queues, Pages, R2 ve Workers AI gibi kullanıma dayalı hizmetler. Önbellek ve koruma için kredi gerekmez; temel güvenlik ve ağ özellikleri her tier'da ücretsiz.

**Dikkat:** Erken alınan Tier 3'ün 1 yıllık süresi başlar; sonradan yükseltme bitiş tarihini uzatmaz. Krediler hesaplar arasında taşınmaz.

### PostHog for Startups

https://posthog.com/startups
**Ne verir:** 12 ay geçerli $50.000 PostHog kredisi ve ortaklardan $12.000'ın üzerinde avantaj.

**Kimler alır:** 2 yaşından küçük, toplam yatırımı $5 milyonun altında girişim. Hesap 1 Ocak 2023'ten sonra şirket alan adındaki bir e-postayla açılmış olmalı.

**Bizde neyi öder:** Ürün analitiği, oturum kaydı ve feature flag. Kredi 14 Eylül 2026'dan beri PostHog'un AI araçlarında geçmiyor.

**Dikkat:** Başvurmak için ücretli plana geçmek, yani kart tanımlamak gerekir; 12 ay sonra kullanım bazlı ücret başlar. Kişisel veri ve veri yeri (KVKK) çözülmeden kurulmaz.

### OpenAI for Startups

https://openai.com/startups/
**Ne verir:** Resmi sayfa 8 Ekim'de 403 döndü. İkincil kaynaklara göre API kredisi, hız sınırı artışı ve çözüm mühendisleriyle görüşme.

**Kimler alır:** İkincil kaynaklara göre yalnız OpenAI'ın VC ortak ağındaki fonlardan yatırım alanlar, VC'nin verdiği referans koduyla. Kendi parasıyla dönen girişime açık bir program bulunamadı.

**Bizde neyi öder:** Model (LLM) kalemi.

**Dikkat:** Yatırım olmadan erişim yok gibi görünüyor. Program sayfası 8 Ekim'de 403 döndüğü için şartlar başvurudan önce yeniden okunur.

## Programı olmayanlar

### Expo (EAS)

program yok
Fiyat sayfası girişimlere indirim vermediklerini söylüyor. Free plan ayda 15 iOS ve 15 Android build içerir; kullanılmayan build kredisi sonraki aya devretmez.

https://expo.dev/pricing

### RevenueCat

program yok
Program bulunamadı. Aylık takip edilen gelir $2.500 olana kadar ücretsiz, sonra bu gelirin %1'i; gelir mağaza komisyonu düşülmeden sayılır.

[revenuecat.com/pricing](https://www.revenuecat.com/pricing/)

### Resend

program yok
Program bulunamadı, fiyatlar herkese aynı. Free plan ayda 3.000, günde 100 e-posta; Pro $20/ay'dan başlar. Günlük 100 sınırını giriş kodları ve bildirimler paylaşır.

https://resend.com/pricing

### Türkiye tarafı: TÜBİTAK BİGG ve teknokent

TÜBİTAK 1512 BİGG girişimcilik eğitimi ve rehberlik verir; 2024 tarihli resmi özete göre Aşama 2'de en fazla ₺900.000 ve en fazla 18 ay proje desteği. Başvuran üniversite öğrencisi ya da mezunu olmalı; program şirket kurmayı ve muhasebe yükünü getirir. Bulut faturasını doğrudan ödemez, aboneliklerin gider sayılıp sayılmadığı çağrı metninden okunur.

Teknokentte bölgede yürütülen yazılım ve Ar-Ge kazancına vergi istisnası ve personel teşvikleri var; bu ancak gelir oluşunca anlam kazanır. Dolaylı faydası şu: kuluçka merkezleri ve hızlandırıcılar AWS, Microsoft ve GitHub'da büyük katmanları açan partner olabiliyor.

## Başvurmadan önce hazırla

- [ ] Ürünün kendi alan adında bir iş e-postası. Claude, Google, Cloudflare ve PostHog kişisel adres kabul etmiyor. İstisna Microsoft: kayıt, daha önce Azure açılmamış kişisel bir Microsoft hesabıyla yapılır.

- [ ] Doğrulanabilir canlı bir site ve LinkedIn, X ya da GitHub'da görünür bir sayfa. AWS'de site ya da profil başvurudaki şirket adını göstermeli.

- [ ] 50–500 karakterlik ürün tanımı. AI'ın ne yaptığı ve tüketiciye finansal tavsiye verilip verilmediği net yazılır.

- [ ] Kuruluş tarihi ve neye dayandığı, yatırım durumu, ekip büyüklüğü, şehir ve ülke. Bunlar her formda aynı yazılır.

- [ ] GCP için 18 karakterlik billing account ID. Başvurudaki e-posta, billing hesabının e-postası ve site aynı alan adında olmalı. Alan adında ücretli Workspace varsa Workspace hediyesi gelmez.

- [ ] Önce o serviste açılmış hesap: AWS'de profesyonel e-postalı bir Builder ID ve Paid Tier hesap, Sentry'de organizasyon slug'ı, PostHog'da şirket e-postalı ve ücretli plandaki hesap.

- [ ] Neon için kullanım rakamları: günlük CU-saat ve depolama.

- [ ] Yatırım varsa: yatırımı gösteren herkese açık kaynaklar (Google Scale), tutar ve yatırımcı adları (Sentry), partner referans kodları (AWS, Microsoft, GitHub, Anthropic).

- [ ] Tescil isteyen programlar için şirket belgeleri: Microsoft kayıtlı şirket adı ve adresinin resmi belgelerle aynı olmasını, Cloudflare tescilli şirket ister.

- [ ] BİGG için iş planı. Bulut kredi programları sunum istemiyor; Google yatırım için deck yerine herkese açık kaynak linki ister.

- [ ] Kart, bütçe uyarısı ve kredi kaydı hazır: tarih, tutar, bitiş ve bitişten bir hafta önceye hatırlatma.

## Strateji

1. Başvuru ağır kullanım başlamadan hemen önce yapılır.

Süre çoğu programda onay ya da claim günü başlar: Claude'da 6 ay; Neon, Cloudflare, Sentry, PostHog, GitHub ve Google Start'ta 12 ay. Fikir aşamasında alınan kredi büyük ölçüde boşa yanar. Onay ile claim ayrıysa (Claude'da öyle) claim kullanımın başladığı haftaya bırakılır. İstisna yaş pencereleri: Google Start 24 ay, Sentry ve PostHog 2 yıl, Claude ve Google Scale 5 yıl. Pencere kapanmadan başvurulur.

2. Mimari krediye göre seçilmez.

Kredi 6–24 ay sürer, mimari kalır. GCP kredisi Neon'u ödemiyor, yine de sırf bu yüzden Cloud SQL'e geçilmez: Cloud SQL açık kaldığı her saniye faturalanır, Neon 5 dakika hiç bağlantı olmazsa uyur ve kendi programı zaten $1.000 verir. LLM sağlayıcısı tek bir ortam değişkeniyle seçilebilir tutulur; kredi bitince geri dönmek tek deploy olur.

3. Fatura ürün bazında ayrılır.

Google kredisi seçilen billing hesabına, Neon kredisi hesaba yüklenir; aynı hesaptaki başka ürünler krediyi yer. Başvurudan önce ürüne ayrı bir billing hesabı ve ayrı bir Neon organizasyonu açılır; en kolayı ikisini gün 0'da açmaktır.

4. Hiçbir şey sessizce faturalanmaz.

Her kredi için başvuru, onay, claim ve bitiş tarihi tutarıyla bir kayda yazılır ve bitişten bir hafta önceye hatırlatma kurulur. GCP bütçe uyarısı yalnız e-posta atar, harcamayı durdurmaz; krediler varsayılan olarak düşüldüğü için kredi bitince net maliyet sıçrar. Krediyi ne hızla yediğini görmek için kredileri hariç tutan ikinci bir bütçe kurulur. AWS, Microsoft, GitHub ve PostHog kredi bitince karttan faturalar. Anthropic Console'da auto-reload kapalı kalır; bakiye bitince fatura gelmez, çağrılar durur.

5. Form cevapları her programda aynıdır.

Kuruluş tarihi, yatırım durumu, ekip ve ürün tanımı programlar arasında tutarlı yazılır. Tescil tarihi ile ürünün ilk günü farklıysa hangi tarihin esas alınacağı programa sorulur; yaş penceresine girmek için yeni bir tarihle başvurulmaz. Şartları açıkça tutmayan programa başvurulmaz.

6. Yatırım gelirse partner kodları aynı hafta istenir.

AWS Activate Provider Org ID, Microsoft Investor Network kodu, Anthropic ortak ağı (en fazla $100.000 ek API kredisi) ve GitHub for Startups partnerliği bu yolla açılır. Google Scale ve Neon'un VC kolu yatırımın kanıtıyla açılır; Neon en az $1 milyon ya da tanınmış bir hızlandırıcı ister.

### Doğrulanamayanlar

8 Ekim 2026'da resmi sayfalardan teyit edilemeyen ya da sayfaların çeliştiği noktalar.

Google Start'ın tescilli şirket isteyip istemediği sayfalarda yazmıyor.

Google kredisinin Firebase'in ücretli ürünlerini ve AI Studio'daki Gemini API'yi kapsayıp kapsamadığı net değil; billing hesabındaki tek bir projeye sınırlanıp sınırlanamayacağı da doğrulanmadı.

Cloudflare'in ölçüt listesinde 'son 12 ayda yatırım almış' maddesi var, oysa Tier 3 için yatırım şartı olmadığı yazıyor.

Microsoft'un resmi sayfaları kredi tutarlarını farklı anlatıyor. Hangi Azure model hizmetlerinin kapsandığı ve kurumsal kullanıcılara bireysel hizmet veren bir ürünün B2B sayılıp sayılmayacağı doğrulanmadı.

AWS Activate kredisinin geçerlilik süresi SSS'de yok, yalnız Billing konsolunda görünüyor. İnceleme süresi bir sayfada 5–10, ötekinde 7–10 iş günü.

openai.com/startups 403 döndü; kredilerin yalnız VC ortak ağı üzerinden verildiği bilgisi ikincil kaynaklardan.

Neon kredisinin organizasyondaki tüm projelere uygulanıp uygulanmayacağı ve canlı, kullanıcısı olan bir ürünün 'erken aşama ya da MVP' sayılıp sayılmayacağı doğrulanmadı.

Sentry'de 12 ay dolunca ücretli plana mı geçildiği, ücretsiz plana mı düşüldüğü sayfada yazmıyor.

Claude'da onay ile claim arasında bir son tarih olup olmadığı, kredinin aynı Console organizasyonunda başka bir ürün için kullanılıp kullanılamayacağı ve ücretsiz Team yılı bitince kendiliğinden ücretli plana geçilip geçilmeyeceği program şartlarından okunmadı.

BİGG'deki ₺900.000 2024 tarihli özet formdan; güncel çağrının tutarı ve desteğin biçimi farklı olabilir. Teknokent istisnasının 31.12.2028'e kadar sürdüğü bilgisi ikincil kaynaklardan. KOSGEB araştırılmadı.
