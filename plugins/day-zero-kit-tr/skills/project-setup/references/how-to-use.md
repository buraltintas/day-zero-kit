<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="kullanim"></a>

Başlarken

# Bu rehber nasıl kullanılır

Bu rehber ürünün kodunu yazmaz; kodun etrafını toplar ve işin derli toplu başlamasını sağlar. Rehberi ekip okur, ajan uygular; ajan kararları sorar ve altyapıyı kurar, ekip ürün akışlarına bakar. Bu bölüm kimin neyi okuyacağını, ajana yapıştırılacak ilk mesajı, işin kimde olduğunu ve örneklerdeki dört ürünü verir.

## Bu rehber nedir

Rehber tek bir yığını anlatır: Neon Postgres, Cloud Run'da Go API, Next.js ve Expo; DNS Cloudflare'de. Kurallar beş yıllık ürün geliştirme tecrübesinden çıktı; rakamlar dört canlı ürünümüzün Ağustos–Ekim 2026 faturalarından, loglarından ve olay kayıtlarından. Fiyatlar Ekim 2026'nın, dolar 49 TL ile çevrildi. Her maddenin başındaki etiket o maddenin kanıt düzeyidir.

[kanıtlı] bizim prod'da çalışıyor; [ölçüldü] rakamı kendi ölçümümüz ya da faturamız gösteriyor; [öneri] bizde denenmedi ya da yalnız sağlayıcı belgesine dayanıyor. **Etiket maddenin isteğe bağlı olduğunu söylemez; bir öneriyi atlamak da ürün sahibinin kararıdır ve docs/DECISIONS.md'ye yazılır.**

## İki okuma yolu

Aynı içerik iki biçimde: PDF ekip için, Markdown kopyası ajan için. Markdown kopyası dışındaki her başlık ilgili bölüme bağlantıdır.

### Ekip lideri

PDF'i okur, ürün sahibiyle kararları verir, ajanın raporlarına bakar.

[İki yol](#iki-yol)

Önlemsiz yolun bize bedeli; ilk aylarda ne olur.

[Vaka defteri](#vakalar)

30 olay: bedeli, çözümü ve kuralı.

[En hızlı kurulum yolu](#hizli)

Gün 0'dan ilk mağaza sürümüne 24 adım, sırasıyla.

[Kontrol listesi](#kontrol)

Dört aşamada 29 kutu; ajanın raporu buna göre okunur.

### Yapay zekâ ajanı

Markdown kopyasını okur; sorar, kurar, kaydeder.

Markdown kopyası

Baştan sona, bölüm bölüm. Grafikler orada tek satırdır, kimi yalnız başlıktır.

[Verilecek kararlar](#kararlar)

Ürün sahibine tek tek sorulur; cevaplar DECISIONS.md'ye.

[Ajanın kurulum planı](#kurulum-plani)

Aşama aşama; her aşamanın kontrolü koşulur.

[Katmanlar](#katman-1)

Kurulan katmanın bölümü o sırada yeniden açılır.

İki yol kararlarda buluşur; ajan sorar, ürün sahibi cevaplar (küçük ekipte bu kişi ekip lideri de olabilir). Cevabı gelmeyen satır "KARAR BEKLİYOR" diye kalır.

## Ajana ilk mesaj

Markdown kopyası depoya ya da sohbete eklenir, bu metin ilk mesaj olarak yapıştırılır. Açılı parantezli yer ekibin cevabıyla dolar.

```
Yeni bir ürün kuruyoruz: <ürün tek cümleyle; kim kullanır>.
Ekteki project-setup-guide.md bu işin rehberi.

1. Önce "Bu rehber nasıl kullanılır" ve "Verilecek kararlar ve kurulum planı" bölümlerini oku. Rehberin tamamını bir seferde okuma; her aşamaya geçerken o aşamanın ve katmanın bölümünü aç, şablon ve tablolarıyla.
2. "Verilecek kararlar" bölümündeki soruları bana tek tek sor. Bir tercihim yoksa rehberin varsayılanını öner ve nedenini bir cümleyle söyle.
3. Cevapları docs/DECISIONS.md'ye K-001'den başlayarak yaz, ürün özetini AGENTS.md'ye. Cevabı gelmeyen satır "KARAR BEKLİYOR" diye kalır.
4. Altyapıdan önce "Proje hafızası ve devir" bölümündeki gün 0 dosyalarını aç: AGENTS.md, CLAUDE.md (yalnız @AGENTS.md), CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md, docs/runbooks/ ve docs/handoff/.
5. "Ajanın kurulum planı"nı aşama aşama uygula. Her aşamanın sonunda o aşamanın kontrollerini çalıştır, sonucu docs/STATUS.md'ye ve CHANGELOG.md'ye yaz, bana tek satır rapor ver. Kontrolü geçmeyen aşamadan sonrakine geçme.
6. Yalnız benim yapabileceğim işlerde dur ve sor: hesap açmak, ödeme ve ücretli plan, şart ve sözleşme kabulü, alan adı kaydı ve sahiplik doğrulaması, mağaza hesapları, bir uygulamaya hesap erişimi vermek (GitHub App, OAuth onayı), dış sitelerde form göndermek, yalnız konsoldan açılabilen ayarlar, canlıya deploy, mobil build ve mağazaya gönderim, gerçek kullanıcılara mesaj, bir şeyi herkese açık yapmak.
7. İsteğim rehberle çelişirse işe başlamadan çelişkiyi söyle. Kararı ben veririm, sen DECISIONS.md'ye yazarsın.
8. Etiketler kanıt düzeyidir: [kanıtlı] rehberin ürünlerinde canlıda çalışıyor, [ölçüldü] rakamı ölçüm ya da fatura gösteriyor, [öneri] o ürünlerde denenmedi ya da yalnız sağlayıcı belgesine dayanıyor. [öneri] isteğe bağlı demek değildir; bir maddeyi atlamak da benim kararımdır.
9. Gizli değerleri sohbete, dosyaya, commit'e ya da loga yazma; adları .env.example'da, değerleri Secret Manager'da durur. Denemeler test ortamında yapılır, canlıya test verisi yazılmaz.
10. Fiyat, kota ya da sürüme dayanan her adımdan önce rakamı rehberin Kaynaklar bölümündeki sayfadan yeniden oku; tutmayanı bana söyle.
```

[öneri]

Metin bütün olarak bizde denenmedi. Maddeleri depolarımızın ajan dosyalarındaki deploy ve yasak kurallarından, [Proje hafızası](#hafiza) bölümünün gün 0 dosyalarından ve [Verilecek kararlar](#kararlar) bölümünden geliyor.

## Kim ne yapar

Sağdaki sütun ajanın durup sorduğu yerdir. Soldaki etiket o satırdaki iş bölümünün kanıt düzeyidir; hücrenin başındaki etiket yalnız o hücre içindir.

| Alan | Ajan tek başına | Birlikte | Yalnız ürün sahibi |
|---|---|---|---|
| Kararlar [öneri] | Soruları sırayla sorar, tercih yoksa rehberin varsayılanını önerir, cevabı DECISIONS.md'ye yazar. | Varsayılandan sapan seçim ve atlanan her öneri; nedeni de yazılır. | Son sözü verir. Ajan karar vermez, kararı kaydeder. |
| Hesaplar ve para [kanıtlı] | Ücretli bir şey kurmadan önce birim fiyatı, günlük ve aylık tahmini yazar ve onay bekler. | [öneri] Bütçe eşikleri ve ücretli API tavanı; ajan uyarıyı ve tavanı kurar. Bizde yoktu, bir harita API'si Ağustos'ta ₺1.500 yazdı. | Bulut, veritabanı, DNS, e-posta ve mağaza hesaplarını açar; ödeme yöntemini girer, şartları kabul eder; ajanın erişimini verir. |
| Alan adı ve DNS [kanıtlı] | Kayıtları Cloudflare'de kurar: alt alan adları, servis bağlantıları, e-posta için SPF, DKIM ve DMARC. | Alan adının seçimi, alım zamanı ve güvenlik firmalarına kategori başvurusu. Alım ilk kullanıcıdan haftalar önce olur; bizde geç kaldı (vaka 27). | Alan adını kayıt firmasından alır ve sahipliğini doğrular. |
| Altyapı [kanıtlı] | Depoları ve dalları, Neon projelerini, Cloud Run servislerini, tetikleyicileri, bot kapısını, alarmları, yedeği ve mobil kiti kurar; hepsini önce test ortamında. | Alarmların kime ve hangi kanaldan gideceği. | Deneme alarmının kendisine ulaştığını söyler. |
| Deploy ve sürüm [kanıtlı] | Dalda çalışır, test'e push eder, test ortamında doğrular, tek satırlık rapor verir. | Yayının zamanı: hafta içi mesai başı. Mobilde aşamalı yayın da konuşulur; bizde denenmedi. | Canlıya deploy onayı; mobil build, mağazaya gönderim ve sürüm numarası. |
| Kullanıcıya ulaşan her şey [kanıtlı] | Duyuru, e-posta, push ve sosyal paylaşım metnini taslak yazar; e-postayı test ortamının izin listesine gönderir. | Metin, kitle ve gönderim zamanı. | Gerçek kullanıcılara gönderim ve herkese açmak: site, mağaza sayfası, paylaşım. |
| Ürün akışları [kanıtlı] | Akışı koda çevirir, testini yazar, test ortamına çıkarır. | Akış test ortamında birlikte denenir. | Akışları tanımlar: kim gelir, ne yapar, ne görür. |
| Kayıt ve devir [ölçüldü] | CHANGELOG girdisini işi yapan commit'e koyar; kural ajan dosyasında yazılıyken commit'lerin %72–84'ü böyleydi, yazılı değilken %33–52'si. STATUS, TODO ve devir notunu da tutar. | [öneri] Ayda bir tazelik turu: ajan hazırlar, ürün sahibi 15 dakika bakar. | Karar bekleyen satırları kapatır. |

## Bu rehber ne değildir

### Çok yüksek ölçek ve çok bölge için

Servislerimiz tek bölgede (europe-west1), veritabanlarımız Frankfurt'ta; yedek maliyetini ölçtüğümüz prod veritabanı 70 MB. Servisler boşta sıfıra iner. Soğuk sunucuya düşen ilk istek API'de p50 ~1,5 sn, sitede p50 2,0–4,9 sn sürdü; site ile API birlikte soğukken p50 6,2 sn. Uptime kontrolü olan serviste bu, isteklerin %0,02–0,16'sına denk geldi ([Performans](#performans)).

[öneri] **Büyüyünce ne değişir.** Rakamlarımız günde ~3 CU-saat harcayan ve 70 MB'lık bir veritabanından. Ajan 'Her hafta' adımında aşağıdaki sinyallere bakar. Biri görülürse çözümü kendisi uygulamaz; ürün sahibine tek satırla sorar.

1. Neon günde ≥6 CU-saat harcıyor ve sürekli 1 GB'tan fazla RAM istiyor: önce uyanış logundan sebep okunur. Bizde 7/24 uyanıklığın sebebi trafik değildi; zamanlayıcı, havuz tabanı ve botlardı. Sebep gerçek trafikse Neon, sabit fiyatlı bir Postgres ile aylık karşılaştırılır. [Postgres](#katman-1)

2. Compute saatlerce 1 CU tavanında kalıyor: max 2 CU'ya çıkarılır. En kötü fatura (2 CU'da 7/24 ~$150/ay) ve bütçe yeniden yazılır.

3. API max-instances tavanına dayanıyor: max yükseltilmeden önce üç sayı yeniden hesaplanır. Hız kovaları instance başına olduğu için gerçek sınır max ile çarpılır. Sağlayıcıda sert bütçesi olmayan para tavanının en kötü günü de max ile çarpılır. Bütün servislerin ve işlerin instance sayısı toplamı havuzun `MaxConns` değeriyle çarpılır; çıkan sayı compute'un `max_connections` değerinin %90'ını (1 CU'da 377) geçmez. Geçerse sorgu pooler'da sıra bekler, 120 sn sonra hata alır.

4. Değişiklik işaretine saniyede birden sık yazılıyor: GCS aynı nesneye saniyede bir yazmayı kabul eder, daha sıkını kısar. Yazmalar birleştirilir ya da işaret parçalara bölünür.

5. Bellek kopyası API belleğinin yarısını geçiyor: bellek büyütülür ya da kopya sık okunan kayıtlarla sınırlanır.

6. Olay tablosunun 180 günlük silmesi tek çalışmada bitmiyor ya da bu tabloya giden admin sorgusunun p90'ı oturumlu okuma hedefini (300 ms, [Performans](#performans)) geçiyor: tablo aylık bölümlenir, eski ay bölüm düşürülerek silinir.

7. E-posta, Worker ve mobil build kotaları: [Verilecek kararlar](#kararlar) bölümünde 31. sorudaki eşikler.

### Hukuki görüş

[KVKK bölümü](#kvkk) yeni projede yapılacakları anlatır. Maddeler kanun metnine ve Kurum duyurularına dayanır; hukuki görüş değildir. Veri işleyenle yapılan standart sözleşmenin metni, VERBİS sorusu ve silme cevabının ifadesi hukukçuya sorulur.

### Güncel fiyat listesi

Fiyat, kota ve sürümler Ekim 2026'nın. Sağlayıcılar sık değiştirir; X fiyat modelini 2026'da iki kez değiştirdi.

### Başka yığın için birebir tarif

Rehber bu yığın için yazıldı: Neon Postgres, Cloud Run'da Go, Next.js ve Expo. Başka bir yığında ayarlar, rakamlar ve araçlar değişir; mantık aynı kalır: veritabanını gereksiz uyandırma, her harcamaya tavan ve alarm koy, sessiz hata bırakma, en az yetkiyle çalış, kullanıcıyı kırmadan değiştir, kararları ve hafızayı yaz.

### Hazır kod

Kurallar, sıralar, dosya şablonları ve bazı kod iskeletleri (örneğin bot kapısı) var; başlangıç deposu yok. Kodu ajan bu kurallarla yazar.

[öneri] **Güncel tutmak.** Ajan fiyat, kota ya da sürüme dayanan bir adımdan önce rakamı [Kaynaklar](#kaynaklar) bölümündeki sayfadan yeniden okur; tutmayanı ürün sahibine söyler.

## Dört ürünümüz

Örneklerde geçen ürünler. Satır 8 Ekim 2026 sayımı, test kodu dahil ([Boyutlar](#boyutlar)); aylık tutar 8 Ekim tahmini ve yalnız bulut faturası; alan adı ve mağaza ücretleri hariç ([Ne tutar?](#maliyet)).

### Ürün A

Finans hesaplama ürünü

Mobil uygulama, bilgi sitesi, statik portal, pazar yeri sitesi ve Go API.

**Veritabanında:** Kullanıcılar ve oturumlar, hesaplama olayları, abonelik olayları, pazar yeri talepleri ve mesajları, bildirimler ve cihazlar.

Her gün giriş yapan kullanıcıları ve her sabah çalışan veri çekme, rapor ve yedek işleri var.

**5** depo

**~265.000** satır kod

**~₺610** aylık bulut

### Ürün B

Mağaza keşif uygulaması

Web ve Go API; mobil uygulama deposu erken aşamada.

**Veritabanında:** Mağaza ve marka kataloğu, değerlendirmeler ve moderasyon, arama ve tıklama kayıtları, kullanıcılar ve oturumlar.

Herkese açık ~18 bin sayfalık katalog; tek bir bulut kazıyıcısı web isteklerinin %41'ini aldı.

**3** depo

**~70.000** satır kod

**~₺510** aylık bulut

### Ürün C

İçerik uygulaması

Web, ayrı admin paneli, mobil uygulama ve Go API.

**Veritabanında:** İçerik kayıtları ve çevirileri, kategoriler, kullanıcılar ve roller, yorumlar, günlük bakılma sayaçları, paylaşım kayıtları.

Günlük, haftalık ve aylık içeriğini sosyal hesaplara kendisi paylaşır.

**4** depo

**~151.000** satır kod

**~₺220** aylık bulut

### Ürün D

Küçük içerik sitesi

Web ve Go API.

**Veritabanında:** İçerikler, yorumlar ve içerik bildirimleri; IP adresi ham tutulmaz, yalnız hash'i durur.

Gerçek kullanıcısı az; veritabanı Neon Free'de, admin paneli yok.

**2** depo

**~12.500** satır kod

**~₺5** aylık bulut

Ürün C'nin kodu Ürün B'nin iki katından fazla, aylık tutarı yarısından az (~₺220 ve ~₺510). Fark veritabanının uyanık kaldığı saatlerden, Ürün B'deki bot trafiğinden ve build dakikalarından geliyor.
