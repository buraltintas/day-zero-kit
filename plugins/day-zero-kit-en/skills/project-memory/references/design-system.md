<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="tasarim"></a>

Ürün ve büyüme

# Tasarım sistemi ve devir

Canlı ürünlerimizde tasarım koda elle kopyalanarak indi ve her ürün aynı sorunları ayrı ayrı yaşadı: renk birden çok yerde tanımlandı, font bir yüzeyde düştü, tasarım paketi olmayan veriyi çizdi, Safari ve geniş ekran kontrol edilmedi. Bu bölüm gün 0'da açılacak üç dosyayı ve tasarımın koda iniş yolunu anlatır. Rakamlar 8 Ekim 2026 depo taramasından ve oturum kayıtlarından.

**Kural:** Tasarım koda tek yoldan iner ve gerçek ekranda görülmeden bitmez.

Gün 0'da üç dosya açılır: renk, yazı ve ölçünün tek kaynağı olan token dosyası, tasarım paketlerinin tarihli klasörlerde durduğu depo yeri ve her kararın numarayla yazıldığı karar dosyası. Ekran gerçek cihazda ve tarayıcıda görülmeden iş bitmiş sayılmaz. Ajan arayüze dokunmadan önce bu dosyaları okur, işi bitirince ekran görüntüsüyle gösterir.

**16 paket** Ürün A'da 16–19 Eylül'de tasarım aracından elle verilen devir paketi. Hiçbiri depoya alınmadı; bugün diskte yok, içerikleri yalnız oturum kayıtlarında.

**292,4 / 329,8 pt** Aynı başlığın web'de ve uygulamada genişliği. Font yüklüydü ama kullanılmıyordu; düzeltmeden sonra uygulamada 292,7 pt.

**2 hafta** Ürün B'de sonuç listesinin geniş ekranda bozuk kaldığı süre. Bütün kontroller telefon genişliğinde yapılmıştı.

## Token dosyası dışında yazılmış renk

8 Ekim 2026 depo taraması. Ürünler ortak bir tasarım paketi kullanmıyor; her ürün token'larını kendi depolarında, çoğu zaman elle kopyalayarak tutuyor. Ürün A'nın ana marka rengi 5 depoda 17 dosyada sabit değer olarak yazılı. Ürün B iki dosyayı elle eşliyor ve yine de disiplinle temiz kaldı. Ürün D'nin token'ları tek CSS dosyasında, 12 benzersiz hex 2 dosyada; Ürün C'nin sayısı elimizde yok.

kullanılan koddahiç import edilmeyen bir iskelet dosyasındaadet; ölçek gerçek

_Grafik: Token dosyası dışında yazılmış sabit renk sayısı, ürün ve yüzey başına_
Başka bölümlerde

Görsel taramanın beş ölçüsü ve WebKit kontrolü [Kullanıcıyı kırmadan değiştirmek](#kirmama) bölümünün 3.10 maddesinde, sessizce durduran arayüz 3.11'de, incelenen işin commit'lenmemesi 7.4'te. AGENTS.md, CHANGELOG ve genel karar dosyası [Proje hafızası ve devir](#hafiza) bölümünde; OG kartları [SEO ve GEO](#seo), sosyal paylaşım görselleri [İçerik otomasyonu](#icerik) bölümünde.

## Tasarımdan koda devir

Tasarımı ürün sahibi tasarım aracında (bizde Claude Design) yaptırdı; paketler klasör olarak kod ajanına elle verildi, aracın kod tabanını okuyan yolu hiç çağrılmadı. Kesik çizgili adım bizde yapılmadı. 5. adım yalnız simülatör ve tarayıcıda yapıldı; WebKit kontrolü 23 Eylül'de başladı, gerçek Android cihaz ve uzun Türkçe metin yoktu. 6. adımda sapmalar DESIGN.md ve CHANGELOG'a yazıldı, numaralı karar dosyası hiçbir üründe yok.

_Grafik: Tasarım paketinden CHANGELOG'a yedi adım_

### Devrin kuralları

1

**Tasarım için yeni uç, kolon ya da migration açılmaz**. Verisi olmayan öğe tasarımdan düşer, sahte ya da sabit veriyle doldurulmaz; yeni backend işini yalnız ürün sahibi açar.

Ürün A'nın ilk altı paketi API'de olmayan veri ve kurallar çizdi; eleme olmasa ekrana uydurma rakam çıkacaktı.

[kanıtlı]

2

**Tasarımda yeri belli olmayan ekran için yer uydurulmaz, ürün sahibine sorulur**. Onun kuralı: bizde olup tasarımda olmayanı tasarımın diline uyarlayıp koy; tasarımda olup bizde olmayanı koyma.

Tasarımda yeri belli olmayan yedi ekran tek tek soruldu; kararlar 8 dakika sürdü.

[kanıtlı]

3

**Paketin 'nerede kullanılmaz' ve 'ne yapılmaz' listesi kabul kriteridir**.

Atlandığında yükleme animasyonu düğmeye kondu, hareketli logo 375 px ekranda iki düğmeyi dışarı itti.

[kanıtlı]

4

**Rebrand renk, yazı, logo ve boşluğu değiştirir**. Kontrolün yeri, türü ve davranışı ancak ürün sahibi açıkça isterse değişir; eski ve yeni ekran yan yana gösterilir.

Ürün C'de dört paralel ajan arama yerini, dil menüsünü ve ikonları da değiştirdi; aynı gün geri alındı.

[kanıtlı]

5

**Ekran tarayıcıda ya da simülatörde görülmeden 'yapıldı' denmez**. Ara rapor 'yapıldı, yapılmadı, verisi yok' tablosudur.

Dört tur testleri yeşil geçti ve 'bitti' denildi; portalın tablosu, çekmecesi ve üst çubuğu yoktu.

[kanıtlı]

6

**Paket geldiği günün kaydı olarak saklanır**; geçerli değer token dosyasında ve karar dosyasında durur. Karar değişince ikisine yazılır; eski paketin DECISION.md'sine 'yerini aldı: K-NNN' düşülür.

Ürün C'de 3 Ekim kararı pakete geri yazılmadı; 6 Ekim'de eski paket yeniden kaynak alındı. Kural bugün yalnız ajan belleğinde.

[öneri]

## Paket ne içermeli

Gördüğümüz README'ler sayısaldı: ölçü, süre, easing, açık ve koyu renk sütunu, 'nerede kullanılmaz', erişilebilirlik ve 'ne yapılmaz' birebir koda indi. Veri kaynağı, boş ve yükleniyor durumları, uzun Türkçe metin ve mevcut kontrollerin listesi yoktu. Olmayan veri olayı bu boşluktan çıktı; değişen kontrol olayında paket ürünün mevcut kontrollerini bilmiyordu.

- [ ] Token'lar HTML'in yanında makinece okunan bir dosyada (DTCG JSON); mevcut adlarla eşleme tablosu.

[öneri]

- [ ] Her ekranın durumları: varsayılan, basılı, odak, seçili, devre dışı, yükleniyor, boş, hata, misafir ve girişli, çevrimdışı.

[öneri]

- [ ] Boş, hata ve yükleme metinleri; uzun Türkçe metinli bir varyant, iki satıra kırılma kuralı.

[öneri]

- [ ] Kırılımlar: 375, 900 ve 1280 px'te ayrı kare; tablet destekleniyorsa 768 de.

[öneri]

- [ ] Koyu tema kararı: koyu renk sütunu ya da 'yalnız açık tema' cümlesi.

[kanıtlı]

- [ ] Platform notları: iOS ve Android kontrolleri, güvenli alan, klavye, 44 pt ve 48 dp hedef.

[öneri]

- [ ] Veri kaynağı tablosu: her öğe hangi API alanından geliyor; olmayan veri işaretli.

[öneri]

- [ ] 'Nerede kullanılmaz' ve 'ne yapılmaz' listesi; küçük boy kuralı (44 px altında işaret).

[kanıtlı]

- [ ] Hareket: süre, easing, azaltılmış harekette ne olacağı.

[kanıtlı]

- [ ] Erişilebilirlik: rol, etiket, ekran okuyucu metni, kontrast oranı.

[kanıtlı]

- [ ] Mevcut kontrollerin listesi; paket değiştirdiği her kontrolü açıkça yazar.

[öneri]

- [ ] RTL gerekmiyorsa bunu yazan bir cümle.

[öneri]

### Çizmeden önce brief [kanıtlı]

Tasarım aracı ürünü bilmiyordu. Çizmeden önce ona ürünün kendisi verilir: bütün ekranlar ve akışlar, API'nin gerçekte döndürdüğü alanlar, mevcut kontroller ve token'lar, logonun çalışacağı her yer ölçüsüyle (ikon, favicon, açılış, e-posta, sosyal ve mağaza görseli). Ürün C'de bu brief koddan 14 dakikada çıkarıldı; ürün sahibi onun tasarımdan önce verilmesini istedi.

## Bizde ne oldu

On olay, Ağustos–Ekim 2026. Büyük rakam olayın ölçüsü ya da bedeli. Kural satırı aşağıdaki gün 0 kurallarının ya da yukarıdaki devir kurallarının numarasını gösterir.

6 paket. [kanıtlı]

### Paket ürünün olmayan verisini çizdi

Ürün A, 16 Eyl 2026

Haftalık ortalama, günlük tıklama sayısı, kontenjan ve süreli kilit API'de yoktu; yedi ekranın yeri belli değildi. Araç yalnız ekran çiziyordu; API'nin ne döndürdüğünü bilmiyordu.

**Çözüm** Eleme 5 dakika sürdü. Verisi zaten olan bir bölüm için yalnız okuyan bir uç 7 dakikada yazıldı, migration yok.

**Kural** Devir kuralı 1 ve 2.

498 test. [ölçüldü]

### Testler yeşil, ekran açılmamış

Ürün A, 16 Eyl 2026

Dört tur 36 dakikada yazıldı ve 'bitti' denildi. Akşam portalda satır tablosu, 480 px sağ çekmece ve üst çubuğun olmadığı görüldü.

**Çözüm** Aynı gün ~6,5 saat ekran ekran düzeltme; paket bölüm bölüm karşılaştırıldı.

**Kural** Devir kuralı 5.

159 px. [kanıtlı]

### Marka bileşeni yanlış yerde, yanlış boyda

Ürün A, 16 Eyl 2026

Yükleme animasyonu bir düğmeye kondu; 159 px'lik hareketli logo 375 px ekranda iki düğmeyi dışarı itti. Logo olarak da kullanılan bir ikon dosyası favicon ile ezildi.

**Çözüm** Düğmede standart halka, 720 px altında 44 px'lik işaret, ikon ve favicon ayrı dosyada; ~30 dakika.

**Kural** Devir kuralı 3, gün 0 kuralı 16.

4 depo. [kanıtlı]

### Rebrand kontrolleri de değiştirdi

Ürün C, 2 Eki 2026

Paket kontrol düzenini de çizmişti. Arama başlıktan ana sayfaya taşındı, dil menüsü düz yazıya döndü, düğme ikonları kalktı.

**Çözüm** Eski kontroller yeni stil altında ~1 saatte geri geldi. Onay yerel önizlemeden sonra olduğu için canlı bozulmadı.

**Kural** Devir kuralı 4.

3 gün. [kanıtlı]

### Eski paket yeni kararı ezdi

Ürün C, 3–6 Eki 2026

3 Ekim'de sayfa zemini beyaza çevrildi, karar pakete geri yazılmadı. 6 Ekim'de sosyal görseller paketin README'sine bakılarak eski zeminle yapıldı.

**Çözüm** Görsel seti canlı token'lardan yeniden üretildi.

**Kural** Devir kuralı 6.

4 şikâyet. [ölçüldü]

### Uygulama marka fontunu kullanmıyordu

Ürün A, 16 Eyl 2026

Ürün sahibi aynı gün dört kez fonttan şikâyet etti, iki kez gözle 'aynı' denildi. Ağırlığa göre dosya seçen yama React Native 0.81'de sessizce devre dışıydı; web 800 yüklüyordu, mobilde o dosya yoktu.

**Çözüm** Yama StyleSheet.create seviyesine taşındı, web 800'ü bıraktı. Ölçüm sonrası 292,7 pt.

**Kural** Gün 0 kuralı 4.

9 gün. [kanıtlı]

### Paylaşım görsellerinde ğ ve ş bozuk

Ürün A, 28 Eyl–7 Eki 2026

Alt küme dosyaları aynı aile adıyla kayıtlıydı; görüntü üretici 700 başlıklara 500 ağırlığın Türkçe alt kümesini verdi. Widget ve API sayfaları da fontu almıyordu.

**Çözüm** Türkçe alt küme kendi adıyla kaydedildi; widget'a ve API'ye font gömüldü.

**Kural** Gün 0 kuralı 5.

51 aile. [ölçüldü]

### İki görsel dünya aynı anda yayında

Ürün B, 19 Ağu 2026

Yeni tasarım eskinin üstüne katman olarak eklenmişti; 51 seçici ailesi eski sistemle çiziliyordu. Tasarım skill'i yalnız API deposundaydı, web oturumları onu yüklemiyordu.

**Çözüm** Bir tam gün: token'lar tek dosyaya, skill üç depoya, DESIGN.md baştan.

**Kural** Gün 0 kuralı 1 ve 2.

3 görsel. [kanıtlı]

### Açılışta önce eski, sonra yeni görsel

Ürün A, 16 Eyl 2026

Sistem, açılış kütüphanesi ve JS katmanı üç ayrı görsel çiziyordu; Android'de üçüncüsü 1200 ms sürüyordu.

**Çözüm** JS katmanı kalktı, native açılış animasyonun ilk karesi oldu; ~25 dakika ve bir native derleme.

**Kural** Gün 0 kuralı 16.

20 px. [ölçüldü]

### Geniş ekranda bozuk liste

Ürün B, Eylül 2026

İki sütunlu ızgaraya üçüncü bir çocuk eklenmiş, şablon değişmemişti; ad ve adres 20 px'lik sütuna sıkıştı. Kontroller hep telefondaydı; liste iki hafta böyle kaldı.

**Çözüm** Üç sütunlu şablon, 19 Eylül. İnceleme turlarının hiçbiri yakalamamıştı.

**Kural** Gün 0 kuralı 17.

## Gün 0 kuralları

25 kural, dokuz başlıkta. Etiket kuralın bizdeki kanıtını gösterir; öneri, bizde denenmemiş ya da tam uygulanmamış demek.

### Token kaynağı ve adlandırma

1

**Tek token kaynağı depoda durur**: `tokens/tokens.json`, DTCG 2025.10 biçiminde. Bir build adımı web için CSS değişkenlerini, mobil için `theme.ts`'i, e-posta şablonları için sabitleri üretir; elle kopya yoktur.

Ürün A'da üç CSS kopyası elle eşleniyor (birinde bir değer farklı), web ve mobilde token adları farklı, e-posta renkleri satır içi. Ürün C'de web dört katman, admin ayrı kopya; 51 ortak token'ın 19'u farklı.**Kontrol** CI üretilen dosyaları yeniden üretip fark arar; fark varsa build kırılır.

[öneri]

2

**Token dosyası dışında renk, font adı ve gölge yazılmaz**. CI token dosyası dışındaki hex'leri sayar, sayı artarsa kırılır.

Bugün token dosyası dışında Ürün A portalında 327, mobilde 155; Ürün B'de 29 ve 5.**Kontrol** stylelint `color-no-hex` ya da bir grep sayacı.

[öneri]

3

**Token adı rolü söyler**: ink, ink-muted, surface, surface-muted, line, accent, focus. Durum renkleri üçlü gelir: ön plan, açık zemin, o zeminin üstündeki metin. Anlam değişirse yeni ad açılır, eski ad başka anlama verilmez.

Ürün A'da adlar korunup yalnız değerler değişince ~40 ekran dokunulmadan yeni sisteme geçti. Bir yüzey rengi ters kutupluluğa geçince onu açık sanan her yer bozuldu.**Kontrol** Token dosyasında her token'ın bir rol açıklaması var.

[kanıtlı]

### Tipografi ve Türkçe karakterler

4

**Tek yazı ailesi (gerekirse sayılar için bir mono), en çok dört ağırlık, web ve mobilde aynı ağırlık kümesi**. Ölçek rol adlarıyla 5–7 basamak, mobil gövde 15–18. Mobilde her ağırlık kendi dosyasına çözülür; sentetik kalınlık bırakılmaz.

Ürün A'da web 800 kullandı, mobilde o dosya yoktu ve Android sahte kalınlık ekledi. Paketin iki ayrı yüzü ekranı iki ürün gibi okuttu; üç tur ve ~4 saat sonra tek aileye geçildi.**Kontrol** Aynı metin iki platformda aynı puntoda basılıp genişliği ölçülür (canvas `measureText`, React Native `onTextLayout`); fark %2'yi geçmez.

[ölçüldü]

5

**Font Türkçe gliflerle (ğ ş ı İ ç ö ü), gerekiyorsa Kiril ile denenerek seçilir**; tam dosya ya da kendi adıyla kayıtlı latin-ext alt kümesi kullanılır. Font her yüzeyde ayrı denenir: web, uygulama, widget, e-posta ve API sayfaları, OG ve sosyal görsel, PDF, sunum.

Ürün A'da font dört yüzeyde ayrı ayrı düştü; Ürün B'de desteklenen dillerden birinin alfabesini taşımayan bir yüz bu yüzden elendi.**Kontrol** Her yüzeyden 'Ağır Işık Şöğüş İı' örnek metnini gösteren bir ekran görüntüsü.

[kanıtlı]

6

**Büyük harfte CSS'e güvenilmez**. lang her sayfada doğrudur, Türkçe metin tr-TR ile büyütülür, marka adı ve İngilizce marka kelimeleri kaynakta sabit yazılır; harf aralığı en çok 0,04em.

Ürün A'da CSS uppercase İngilizce bir marka kelimesini noktalı İ ile yazdı; Ürün C'de Türkçe bir etiket İngilizce sayfada noktasız I çıktı. Geniş harf aralığı 'AI slop' diye reddedildi.**Kontrol** Birim test: her büyük harf etiket kendi dilinin büyük haliyle aynı.

[kanıtlı]

### Renk, kontrast ve dokunma

7

**Kontrast WCAG 2.2 AA**: gövde metni 4,5:1, büyük metin ve kontrol kenarı 3:1. Oran metnin gerçekte durduğu her zemine göre ayrı hesaplanır.

Ürün A'da soluk metin beyaz üstünde 4,69:1 idi, sayfa zemininde 4,41:1'e düşüyordu; 5,68:1 veren değer seçildi.**Kontrol** Token çiftleri listesi ve bir kontrast birim testi.

[ölçüldü]

8

**Durum rengi tek başına anlam taşımaz**; yanında metin ya da işaret olur. Ana eylem rengi yalnız basılacak şeylerde kullanılır.

Ürün A'nın tasarım belgesi ve Ürün B'de bir rozet bu kuralla çiziliyor.**Kontrol** Renk körlüğü simülasyonunda ekran okunuyor mu.

[kanıtlı]

9

**Dokunma alanı en az 44x44 pt (iOS) ve 48x48 dp (Android)**; flex ebeveyn küçültemez. Başlık satırı gibi geniş hedeflerde bütün satır dokunulur.

Ürün B'de 44 diye tanımlı bir düğme 36x44'e sıkışmıştı; Ürün A'da akordeonda yalnız 18 px'lik ok dokunuluyordu.**Kontrol** Bileşenin ekranda çizilen boyutu ölçülür.

[kanıtlı]

### Koyu tema kararı

10

**Koyu tema gün 0'da karara bağlanır**. Ya token'larda iki mod tasarlanır ve her ekran iki modda görülür, ya da 'yalnız açık tema' yazılır ve kilitlenir: uygulama ayarında açık stil, web'de `color-scheme: light`. Yarım koyu ekran yayınlanmaz.

Dört ürünün hiçbiri koyu tema yayınlamadı; bir uygulamanın ayarı hâlâ 'otomatik', birinde koyu palet açığın kopyası, bir web'de koyu mod tanımlı ama kullanılmıyor.**Kontrol** Sistem koyu moddayken native seçici, uyarı ve klavye ekranla uyumlu mu.

[öneri]

### Bileşenler ve durumlar

11

**Her bileşenin durumları baştan çizilir**: varsayılan, hover, odak, basılı, seçili, devre dışı, yükleniyor, boş, hata, misafir ve girişli.

Gördüğümüz paketlerde boş ve yükleniyor durumları yoktu; durum galerisi bizde kurulmadı.**Kontrol** Bir durum galerisi her bileşeni her durumda ve uzun Türkçe metinle gösterir.

[öneri]

12

**Kullanılamayan düğme basılabilir kalır ve eksiği söyler**; devre dışı yalnız iş sürerken kullanılır, meşgul düğme etiketini ve genişliğini korur. Yüzen her şey portal ile belgenin köküne çizilir.

Ürün B'de devre dışı düğme uyarıyı gizledi, form içindeki diyalog sayfayı yeniledi.**Kontrol** Eksik formda gönder düğmesine basılır; ekran neyin eksik olduğunu yazar.

[kanıtlı]

13

**Aynı iş aynı bileşen**. Yeni element yazmadan önce depoda aranır; ortak bileşen listesi DESIGN.md'de durur; birden fazla kopya bulunursa aynı değişiklikte teke indirilir.

Ürün A'da tarih seçici üç ekranda üç ayrı koddu, ikisi iOS'ta formu aşağı itiyordu; iki PDF üreticisi de ayrışmıştı.**Kontrol** İncelemede açılan her yeni bileşen dosyasının listede karşılığı var mı.

[kanıtlı]

14

**Hareket**: tek easing eğrisi, süreler 120–260 ms, azaltılmış harekette süre sıfır. Animasyon durum, süreklilik ya da geri bildirim anlatır; dekoratif döngü yok.

Ürün A ve B aynı aralıkta birleşti.**Kontrol** Sistemde 'hareketi azalt' açıkken ekran kaydı.

[kanıtlı]

### Platform eşliği ve marka varlıkları

15

**Platform eşliği**: aynı bilgi, aynı akış, aynı özellik kümesi. Kontrol platformun kendisidir (tarih seçici, sheet, geri hareketi, paylaşım); piksel eşliği aranmaz. İki platformda tek ikon ailesi.

Kayma en az bu ilkeyle çalışan Ürün B'de. Ürün A mobilde iki ikon ailesini karıştırıyor (kodda 280 ve 54 geçiş).**Kontrol** Yeni özellik raporunda 'web'de ve uygulamada nerede' satırı.

[kanıtlı]

16

**Marka varlıkları bir README tablosunda durur**: dosya, boyut, rol, nerede kullanılmaz, SHA-256. Küçük boy kuralı yazılıdır (ör. 44 px altında yalnız işaret). İşaret koddan ya da tek SVG'den çizilir; native açılış animasyonun ilk karesidir.

Ürün B'de roller ve hash'ler yazılı, kayma yok. Ürün A'da rolü yazılı olmayan bir ikon favicon ile ezildi, açılışta üç görsel arka arkaya çizildi.**Kontrol** Varlık değişince hash ve tablo aynı commit'te güncellenir.

[kanıtlı]

### Görsel tarama ve Safari

17

**Görsel tarama her sayfada, 375, 900 ve 1280 px'te, beş ölçüyle yapılır**; ölçü önce eski canlı sayfada denenir ki temiz sonuç bir şey ifade etsin. Beş ölçü [Kullanıcıyı kırmadan değiştirmek 3.10](#k-3-10)'da.

Ürün A'da yalnız bildirilen başlık ölçüldü, ürün sahibi aynı sayfada üç hata daha buldu (ek tur ~35 dakika).**Kontrol** Rapor taramanın bulduklarını ayrıca söyler.

[kanıtlı]

18

**Form kontrolü ya da kart düzeni değişince WebKit'te bakılır**. select ve tarih alanında `appearance: none`; ölçüm gerçek kart genişliklerinde. İzin diyaloğu isteyen hata simülatördeki gerçek Mobile Safari'de üretilir.

Ürün A'da iki kontrol yalnız Chrome'da bakılıp canlıya çıktı; Ürün B'de bir konum hatası beş kez 'çalışıyor' ölçüldü, izin hep verilmişti.**Kontrol** Playwright WebKit ya da macOS `qlmanage` ile ekran görüntüsü.

[kanıtlı]

19

**Ekran gösterilmeden onay istenmez**: masaüstü ve telefon ekran görüntüsü, her biri bir satırla. Ürün sahibi bakarken commit yok ([Kullanıcıyı kırmadan değiştirmek 7.4](#k-7-4)).

Ürün C'de ekranlar gösterilmeden deploy onayı istendi, ürün sahibi itiraz etti.**Kontrol** Deploy onayı mesajında ekran görüntüleri var.

[kanıtlı]

### Mağaza ve sosyal görseller

20

**Mağaza görseli bir hattan, gerçek ekran görüntüsünden çıkar**: simülatörde temiz durum çubuğu (9:41), demo hesap, gerçekçi örnek veri, kişisel veri yok; editör projesi JSON olarak git'te. Boyutlar: App Store 6,9 inç 1320x2868, iPad 13 inç 2064x2752, Play telefon en çok 2:1 (1080x2160), öne çıkan görsel 1024x500.

Ürün A'da elle yapılan ilk set reddedildi; açık kaynak bir editöre geçince ilk onay 17 dakikada geldi.**Kontrol** Setin bütün kareleri tek görselde ürün sahibine gider.

[kanıtlı]

21

**Sosyal ve OG görselleri koddan, tam font dosyasıyla üretilir**; boyutlar ve ızgara kırpması [İçerik otomasyonu](#icerik) bölümünde. Web'deki ekran görüntüleri WebP'dir ve her set yeni klasöre girer.

Alt küme web fontu paylaşım kartlarında ğ ve ş'yi bozdu. WebP, PNG'nin beşte biri; 30 günlük önbellekte aynı adres yeni görseli göstermez.

[kanıtlı]

### Arayüz metni ve üslup

22

**Türkçe metin İngilizcesinden uzun çıkar**. Düğmeye min-height ve dikey dolgu verilir, sabit yükseklik verilmez; iki satıra kırılma tasarımın parçasıdır, üç noktayla kesme yok. Sayı biçimi her dilde tek bir biçimlendiriciden gelir.

Ürün A'nın tasarım belgesi bu kuralla yazıldı; Ürün B bütün dillerinde aynısını uyguluyor.**Kontrol** Durum galerisinde ürünün en uzun dilindeki metin.

[kanıtlı]

23

**Örnek ve yer tutucu değerler gerçekçi ve yasal olarak mümkündür**; uç değer yalnız testte kullanılır.

Ürün A'da imkânsız bir örnek tutar ürünün tamamına güveni sarstı.**Kontrol** Örnek rakamlar ürünün kendi kural tablosundan okunur.

[kanıtlı]

24

**Yasak kalıp listesi gün 0'da yazılır**; UI, e-posta, sunum ve sosyal görselde geçerlidir ve teslimden önce aranır. Bizim listemiz: uzun tire, orta nokta ayracı, mono ya da harf aralığı açılmış büyük harf üst etiket, hap etiket, numaralı kart, alt köşede sayfa numarası, iki noktalı vurucu cümle, 'X değil Y' kalıbı, uydurma slogan, kanıtsız iddia, soyut 2x2 grafik, kutu içinde kutu. Kişinin kendi yazdığı metin cilalanmaz; yalnız anlam ve doğruluk düzeltilir.

Bu kalıpların hepsi iki üründe tek tek reddedildi.**Kontrol** Teslimden önce uzun tire, orta nokta ve büyük harf etiket için tek bir grep satırı.

[kanıtlı]

25

**Marka adı sıradan bir kelimeyse cümle başında tek başına kullanılmaz**; okur ürünü mü cins ismi mi kastettiğini ayıramaz.

Bir ürünümüzde cümle başındaki cins isim ürün adı gibi okundu.**Kontrol** Yeni metinde marka adının geçtiği her yer tek tek okunur.

[kanıtlı]

## Karar belgeleri [ölçüldü]

Ürün B'de kararlar depoda ve okunuyor; token satırı geri bildirim numarasını taşıyor. Ürün A'da DESIGN.md var ama ajan dosyası onu anmıyor, birçok kural yalnız bir makinedeki ajan belleğinde. Ürün C'nin günlüğü depo dışında, marka belgeleri eski tasarımı anlatıyor. Ürün D'de belge yok.

| Dosya | İçinde ne var |
|---|---|
| CLAUDE.md | Tek satır `@AGENTS.md`; Claude Code ve öbür ajanlar aynı dosyayı okur. |
| AGENTS.md | Okuma sırası, kontrol komutları, zor öğrenilmiş kurallar; arayüz işinden önce DESIGN.md'yi adıyla gösterir. |
| PRODUCT.md | Ürün ne, ne değil; kullanıcı kim; desteklenen diller; kanıtı olan iddialar. |

| DESIGN.md | Token tablosu (rol, değer, kullanım, karar no), yazı, ortak bileşenler, koyu tema durumu, paketten sapmalar, ekran kabul listesi. |
|---|---|
| tokens/tokens.json | Makinece okunan tek kaynak; DESIGN.md'deki tablo bundan üretilebilir. |
| docs/DECISIONS.md | K numaralı kararlar; tasarım kararları da buraya girer. |
| docs/design-handoffs/ | Her paket YYYY-MM-DD-konu/ klasöründe olduğu gibi, yanında DECISION.md. |
| docs/brand/README.md | Varlık rolleri, boyutlar, hash, küçük boy kuralı. |
| CHANGELOG.md | En yeni üstte; ne değişti ve neden; aynı commit'te. |

### Nerede durur [kanıtlı]

Ürün deposunda, kodla aynı yerde. Birden çok depo varsa API deposu kanonik olur ve ürün belgeleri yalnız orada durur; öbürlerinin AGENTS.md'si onu adıyla gösterir. Belge başka depoya kopyalanmaz. Arayüz deposunun AGENTS.md'si DESIGN.md'nin yolunu da yazar; Ürün B'de tasarım skill'i yalnız API deposundayken web oturumları onu yüklemedi. Ajan belleği tek makinede durur; kural depoya yazılır.

### Kim günceller [kanıtlı]

Kararı ürün sahibi verir; değişikliği yapan, insan ya da ajan, belgeyi aynı commit'te günceller. Token ya da bileşen değiştiyse DESIGN.md farkı aranır, yoksa iş eksiktir. Kodla çelişen belgede kod esas alınır ve belge düzeltilir; karar belirsizse ürün sahibine sorulur.

Genel karar dosyasının biçimi, AGENTS.md ve CHANGELOG kuralları [Proje hafızası ve devir](#hafiza) bölümünde.

### Ajan arayüz işinden önce okur

1

CLAUDE.md ve AGENTS.md: okuma sırası ve kurallar.

2

PRODUCT.md: ürün ne değil.

3

DESIGN.md ve tokens/tokens.json.

4

İlgili paketin README'si ve DECISION.md'si; 'yerini aldı' notu varsa yeni karar.

5

docs/DECISIONS.md'de ilgili K kayıtları.

6

Depoda mevcut bileşen ve canlıdaki ekran.

Sonra eleme raporu: var, yeni backend ister, yapılamaz; yalnız ilki kurulur. Verilen her karar aynı commit'te DECISIONS.md'ye, sapma DESIGN.md'ye yazılır.

```
# DESIGN.md
Kaynak: tokens/tokens.json. Güncelleme: YYYY-MM-DD.
## Tema
Yalnız açık | açık ve koyu. Koyu yoksa neden.
## Renk
| Rol   | Token | Değer | Kullanım | Karar |
| Metin | ink   | #...  | gövde    | K-003 |
## Yazı
Aile, ağırlıklar, ölçek; Türkçe glif denendi mi.
## Aralık, köşe, gölge, hareket
## Ortak bileşenler
Ad, dosya, durumlar. Yeni bileşenden önce bu liste.
## Paketten sapmalar
| Paket | Ne dedi | Ne yaptık | Neden | Karar |
## Ekran kabul listesi
Token dışı renk yok; 375, 900, 1280 px; WebKit;
dört durum; uzun Türkçe metin; kontrast; 44 pt.
```

```
## K-NNN Yalnız açık tema
Tarih: YYYY-MM-DD.
Durum: geçerli | yerini aldı: K-NNN.
Karar veren: ürün sahibi. Yazan: kişi ya da ajan.
Karar: tek cümle.
Neden: olay, ölçüm ya da sahibin sözü, tarihiyle.
Etkilenen: token, bileşen, web, mobil, e-posta.
Kaynak: docs/design-handoffs/YYYY-MM-DD-konu/
Eski girdiler: geçersiz kalan paket ya da belge.
Geri alma: hangi commit'ler, ne gerekir.
```

```
Paket ve kapsam: dosyalar, ekranlar.
Eleme: var | yeni backend ister | yapılamaz.
Kurulan: ekran ve commit. Kurulmayan: neden.
Sapmalar: DESIGN.md'deki satır.
Durum: uygulandı | kısmen | yerini aldı: K-NNN.
```

## **DESIGN.md iskeleti:** **Tasarım kararı, DECISIONS.md içinde:** **Paket klasöründeki DECISION.md [öneri]:** Bizdekinden iyisi

Bizde gün 0'da yapılmadı; hepsi öneri. Süreler tahmin.

### Tek token paketi ve üretici

[öneri]

tokens.json'dan Style Dictionary ile CSS değişkenleri, React Native teması, e-posta sabitleri.

**Etki** Elle kopya ve değer farkı biter; rebrand tek dosyada başlar.

**Emek** Yeni projede yarım gün, mevcut projede 1–2 gün; açık kaynak, ₺0.

### CI'da token dışı renk sayacı

[öneri]

stylelint kuralı ve token dosyası dışındaki hex'leri sayan bir adım.

**Etki** Ürün A'daki 327 ve 155 gibi sayılar büyümez, düşmeye başlar.

**Emek** 2 saat, ₺0.

### Chromium ve WebKit'te ekran testi

[öneri]

Playwright ile 375, 900 ve 1280 px'te ekran görüntüsü ve görsel fark, en uzun Türkçe metinle.

**Etki** Safari ve geniş ekran hatası canlıdan önce yakalanır.

**Emek** 1–2 gün; GitHub Actions ücretsiz kotası içinde, ₺0.

### Otomatik erişilebilirlik

[öneri]

Web'de axe-core ve eslint-plugin-jsx-a11y; token çiftleri için kontrast birim testi.

**Etki** Kontrast, etiket ve rol hataları elle bulunmayı beklemez.

**Emek** Yarım gün, ₺0.

### Tasarım sistemini koddan kurmak

[öneri]

Tasarım aracının kod tabanını okuyan yolu (Claude Code'da /design-sync) ve her turdan önce brief.

**Etki** Araç gerçek token'ları ve bileşenleri okur; brief ile verisi olan alanları da bilir. Kontrol değiştirme ve olmayan veri riski azalır, bizde denenmedi.

**Emek** 1 saat kurulum, tur başına 15 dakika; abonelik limitleri içinde.

### Paketler depoda

[öneri]

Her paket docs/design-handoffs/ altında tarihli klasörde, yanında DECISION.md.

**Etki** Kararın kaynağı izlenir, eski paket yeni kararı ezmez. Bizde 16 paketin hiçbiri bugün yok.

**Emek** Paket başına 5 dakika, ₺0.

### Numaralı karar kaydı

[öneri]

Tasarım kararları DECISIONS.md'de K numarasıyla; DESIGN.md token satırında karar numarası.

**Etki** Ürün B'nin geri bildirim numaralarıyla yaptığı izleme bütün ürünlere yayılır.

**Emek** İlk kurulum 2 saat, karar başına 5 dakika.

### Durum galerisi

[öneri]

Yalnız geliştirmede açılan bir sayfa: her bileşen her durumda, uzun Türkçe metinle.

**Etki** Tarama ve ekran testi tek yerden; boş, hata ve yükleniyor durumları unutulmaz.

**Emek** 1 gün, ₺0.

### Koyu tema kararını kilitlemek

[öneri]

Ya iki modlu token (DTCG modları) ya da uygulama ve web ayarında yalnız açık tema.

**Etki** Sistem koyu moddayken native seçici ve uyarıların ekranla çelişmesi önlenir.

**Emek** Kilitlemek 10 dakika; tasarlanmış koyu tema ürün başına 2–4 gün.

### Ürünler arası başlangıç kiti

[öneri]

Tek ikon ailesi ve tek görsel tarama listesi, her yeni ürüne hazır.

**Etki** Her yeni ürün aynı soruları sıfırdan çözmez.

**Emek** 1 gün, ₺0.

## Gün 0 listesi

İlk ekran çizilmeden önce işaretlenir.

- [ ] `tokens/tokens.json` açıldı; CSS ve mobil tema ondan üretiliyor; CI renk sayacı var.

[öneri]

- [ ] Yazı ailesi Türkçe gliflerle her yüzeyde denendi; web ve mobil aynı ağırlıklarda.

[kanıtlı]

- [ ] Koyu tema kararı yazıldı; uygulama ve web ayarında kilitlendi.

[öneri]

- [ ] CLAUDE.md `@AGENTS.md`; AGENTS.md DESIGN.md'yi gösteriyor; PRODUCT.md ve DESIGN.md var.

[kanıtlı]

- [ ] Marka README'si: her varlığın rolü, boyutu, küçük boy kuralı ve hash'i.

[kanıtlı]

- [ ] Ortak bileşen listesi ve durumları (boş, hata, yükleniyor, devre dışı) yazılı.

[kanıtlı]

- [ ] Kontrast AA ve 44 pt / 48 dp hedef, gerçek zeminde ve çizilmiş boyutta ölçüldü.

[kanıtlı]

- [ ] Görsel tarama listesi (375, 900, 1280 px ve beş ölçü) ve WebKit kontrolü AGENTS.md'de.

[öneri]

- [ ] Paket klasörü açıldı, ilk paket DECISION.md ile girdi; kararlar DECISIONS.md'de.

[öneri]

- [ ] Mağaza ve sosyal görsel hattı: editör projesi git'te, temiz durum çubuğu, boyut listesi.

[kanıtlı]

- [ ] Yasak kalıp listesi (uzun tire, orta nokta, büyük harf etiket, hap, kanıtsız iddia) yazılı.

[kanıtlı]

- [ ] Onay akışı: masaüstü ve telefon ekran görüntüsü, sonra commit ve deploy.

[kanıtlı]

## Tuzaklar

**Ölçü gerçek kart genişliğinde alınır.** Tarayıcı paneli karttan geniştir; 320, 327, 344 px gibi bileşen genişlikleri kullanılır.

**Quick Look ile WebKit render'ı next/font yüklemez.** Metin canlıdakinden geniş görünür; metin sığdırırken genişlik tarayıcıda gerçek fontla ölçülür.

**Next.js dev sunucusu açıkken build almak .next'i ezer.** Sayfa stilsiz gelir ve CSS hatası gibi görünür; bizde iki günde dört kez oldu. Önce sunucu yeniden başlatılır.

**Simülatör aracının görüntüsü cihazın gerisinde kalabilir.** Doğrulama simctl ekran görüntüsüyle yapılır. Görüntü pikseli noktaya çevrilir: 402 pt telefonda 460 px'lik görüntü 0,874 ile çarpılır.

**Native varlık app.json'da değişince kurulu uygulamada görünmez.** Açılış ve ikon yeni derleme ister; bu baştan söylenir.

**Paketteki SVG filtreleri her yerde çizilmez.** Gren gibi filtreler mobilde ve e-postada çalışmaz; o yüzeyler için PNG üretilir.

### Ölçülmeyenler

8 Ekim 2026 itibarıyla ölçülmeyen ya da okunamayan şeyler.

Tasarım aracında geçen süre ve kullanılan limit; yalnız kod tarafı ölçüldü.

Paketlerin tam içeriği: indirme klasörü silindi, yalnız oturum kayıtlarına giren README'ler okunabildi.

Yeniden tasarımların kullanıcı davranışına etkisi; hiçbir üründe öncesi ve sonrası ölçülmedi.

Bütün token çiftlerinin kontrastı; yalnız soluk metin ölçüldü. Tam WCAG denetimi ya da ekran okuyucuyla test yapılmadı.

Kullanıcıların ne kadarının sistem koyu modunda olduğu.

Gerçek Android cihazlarda font çizimi; ölçümler iOS simülatörü ve tarayıcıda yapıldı.

Ürün B'de numaralı geri bildirimlerin madde başına süresi.

Ürün D'nin tasarım süreci; depoda iz yok.

Önerilen CI testlerinin (görsel fark, axe) bizim projelerde yanlış alarm oranı.

## Kaynaklar

8 Ekim 2026'da okundu. Bu bölüme özel.

**Design Tokens Format Module 2025.10**https://www.designtokens.org/tr/drafts/format/

**Style Dictionary**https://styledictionary.com/

**WCAG 2.2**https://www.w3.org/TR/WCAG22/

**Understanding SC 1.4.3 Contrast (Minimum)**https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html

**Understanding SC 1.4.11 Non-text Contrast**https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html

**Understanding SC 2.5.8 Target Size (Minimum)**https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html

**Apple HIG: Accessibility**https://developer.apple.com/design/human-interface-guidelines/accessibility

**Apple HIG: Dark Mode**https://developer.apple.com/design/human-interface-guidelines/dark-mode

**Material Design 3: Accessibility basics**https://m3.material.io/foundations/accessible-design/accessibility-basics

**App Store Connect: Screenshot specifications**https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications

**Google Play: Add preview assets**https://support.google.com/googleplay/android-developer/answer/9866151

**MDN: appearance**https://developer.mozilla.org/en-US/docs/Web/CSS/appearance

**MDN: text-transform**https://developer.mozilla.org/en-US/docs/Web/CSS/text-transform

**Playwright: Browsers**https://playwright.dev/docs/browsers

**Set up your design system in Claude Design**https://support.claude.com/en/articles/14604397

**Expo: Color themes**https://docs.expo.dev/develop/user-interface/color-themes/
