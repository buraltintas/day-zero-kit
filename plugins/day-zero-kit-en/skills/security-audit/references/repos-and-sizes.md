<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="boyutlar"></a>

Depolar ve boyutlar

# Projelerimiz ne büyüklükte

Dört ürünümüz 14 aktif depoda duruyor. Sayımlar 8 Ekim 2026'da her deponun ana dalından yapıldı.

Toplam ~499.000 satır kod var, bunun ~132.000'i (%26) test. Yanında ~52.000 satır Markdown belge duruyor. Hiçbir .git klasörü 33 MB'ı geçmiyor ve depolardaki ağırlığın çoğu koddan değil görsellerden geliyor. En büyük ürün Ürün A: beş depo, ~265.000 satır, son 30 günde 955 commit.

**14 depo** Ürün A 5, Ürün B 3, Ürün C 4, Ürün D 2. Emekli 6 depo ayrıca sayıldı.

**~499.000 satır** Kod. Yanında ~52.000 satır Markdown belge var.

**%26 test** 131.673 satır test kodu; depoya göre pay %0 ile %38 arası.

**4.341 dosya** Ana dallarda izlenen dosyalar 99,4 MB; bunun 62,5 MB'ı görsel.

**210 MB** On dört .git klasörünün toplamı. En büyüğü 32,8 MB.

**2.368 commit** Bunun 1.711'i son 30 günde. a-web 18 Eylül'de açıldı ve 260 commit aldı.

## Depo başına kod satırı

Test koduUygulama kodusatır, ana dal, 8 Ekim 2026; ölçek gerçek

_Grafik: Depo başına kod satırı_
En eski depo beş yıllık portal, sonra Ürün A mobil (Şubat 2025). Geri kalan on iki depo 2026'da açıldı: Ürün C Şubat'ta, Ürün D Mayıs'ta, Ürün B ve a-api Ağustos'ta, a-web ve a-market Eylül'de.

## Proje toplamları

| Proje | Depo | Dosya | Kod satırı | Test satırı | Test payı | Belge satırı | Görsel MB | .git MB | Commit | Son 30 gün |
|---|---|---|---|---|---|---|---|---|---|---|
| Ürün A | 5 | 1.815 | 265.482 | 80.615 | %30 | 13.771 | 13,8 | 77,5 | 1.105 | 955 |
| Ürün B | 3 | 913 | 69.704 | 15.359 | %22 | 13.188 | 36,2 | 73,0 | 708 | 385 |
| Ürün C | 4 | 1.489 | 151.380 | 33.022 | %22 | 24.241 | 12,5 | 55,3 | 524 | 360 |
| Ürün D | 2 | 124 | 12.494 | 2.677 | %21 | 367 | 0,0 | 4,0 | 31 | 11 |
| Toplam | 14 | 4.341 | 499.060 | 131.673 | %26 | 51.567 | 62,5 | 209,9 | 2.368 | 1.711 |

### Dillere göre

_Grafik: Dillere göre kod satırı_
**TypeScript** 254.214 satır, %50,9**Go** 163.232 satır, %32,7**JavaScript** 55.941 satır, %11,2**CSS** 14.816 satır, %3,0**Diğer** 10.857 satır, %2,2 (SQL, Shell, Swift, Python, Kotlin, HTML, Objective-C)

## Depo depo

| Depo | Kod satırı | Test satırı | Görsel MB | .git MB | Commit | İmaj MB |
|---|---|---|---|---|---|---|
| Ürün A |
| a-api Go API | 66.212 | 25.232 | 1,7 | 12,4 | 219 | 30,6 |
| a-portal Portal, React ve Vite | 52.033 | 15.467 | 8,7 | 32,8 | 194 | 34,6 |
| a-web Next.js bilgi sitesi | 32.528 | 8.733 | 2,8 | 13,0 | 260 | 91,9 |
| a-market Next.js pazar yeri | 20.964 | 5.218 | 0,1 | 1,3 | 154 | 88,3 |
| a-mobile Expo mobil | 93.745 | 25.965 | 0,5 | 18,1 | 278 | – |
| Ürün B |
| b-api Go API | 44.599 | 13.293 | 8,2 | 30,4 | 310 | 19,8 |
| b-web Next.js web | 23.470 | 2.066 | 15,0 | 28,5 | 379 | 455,7 |
| b-mobile Expo mobil | 1.635 | 0 | 13,0 | 14,1 | 19 | – |
| Ürün C |
| c-api Go API | 56.580 | 18.980 | 0,6 | 24,6 | 177 | 23,5 |
| c-web Next.js web | 38.374 | 4.975 | 2,0 | 6,7 | 164 | 77,4 |
| c-admin Next.js yönetim paneli | 29.140 | 2.216 | 1,8 | 6,4 | 51 | 76,6 |
| c-mobile Expo mobil | 27.286 | 6.851 | 8,2 | 17,5 | 132 | – |
| Ürün D |
| d-api Go API | 4.115 | 886 | 0,0 | 0,6 | 15 | 25,9 |
| d-web Next.js web | 8.379 | 1.791 | 0,0 | 3,4 | 16 | 419,9 |

Sayım origin/main dalından yapıldı (c-mobile'te origin/master), çünkü bazı yerel main dalları geride. Kod satırına Go, TypeScript, JavaScript, SQL, CSS, Swift, Kotlin, Objective-C, C#, HTML, Shell ve Python girer. Kilit dosyaları, Markdown, ikili dosyalar, bir depodaki üçüncü taraf ajan becerisi (72.643 satır) ve üretilmiş bir motor dosyası (4.984 satır) sayılmadı. Test satırı kod satırının içindedir. İmaj sütunu Artifact Registry'deki son prod imajıdır; mobil depoların sunucu imajı yok.

Yerelde aktif depoların kopyaları 13,8 GB tutuyor: 8,4 GB'ı node_modules, 3,1 GB'ı iOS ve Android build klasörleri. Ürün A mobil uygulaması tek başına 5,0 GB.

## Bulgular

İmaj boyutu, test ve prod'un ayrı build'i ve build önbelleği [Artifact Registry ve build kuralları](#registry) bölümünde.

### 62,5 MB. Ağırlık koddan değil görsellerden geliyor

Ana dallarda izlenen 99,4 MB'ın 62,5 MB'ı görsel. Ürün B'nin logo ve açılış PNG'leri tanesi 1,2–1,5 MB ve aynı dosyalar üç deposunda da duruyor. Aktif depolarda 259 dosya iki ya da daha fazla depoda bayt bayt aynı, toplam ~20 MB.

**Öneri** Görseller sıkıştırılır ya da WebP veya AVIF'e çevrilir. Marka dosyalarının tek kaynağı uygulama depolarının dışında durur.

### ~29 MB ve ~25 MB. Derlenmiş ikili iki kez commit'lendi

İki Go API deposuna, Şubat'ta ve 11 Eylül'de, birer macOS ikilisi girdi. İkisi de silindi ve gitignore'a eklendi, ama silinen dosya geçmişte kalır. Bir deponun geçmişinde de eski bir CRA build/ klasörünün 333 dosyası (ham 55 MB) duruyor; en büyük .git klasörünün çoğu bu.

**Öneri** Pre-commit ve CI'da ~1 MB'tan büyük her dosyayı ve her Mach-O ya da ELF ikilisini reddeden bir kontrol.

### 5 depo. Ortak kod elle kopyalanıyor

Bot kapısı modülü (kod, veri dosyası, yenileme betiği ve ~96 KB'lık test seti) dört projenin beş deposunda birebir aynı. Hesaplama motoru mobil uygulama ile portal arasında aynı; motor dosyası portaldan web sitesine kopyalanmış, yalnız baş yorumu farklı. Kopyalar bugün eşit, ama onları eşit tutan bir şey yok.

**Öneri** Ortak bir paket: Artifact Registry'de bir npm deposu ya da GitHub Packages. İlk adım olarak kopyaların hash'ini karşılaştıran bir CI kontrolü.

### 72.643 satır. Ürün deposunda üçüncü taraf ajan aracı

Bir Go API deposunda .agents/ altında üçüncü taraf bir ajan becerisi sayıldı: 155 dosya, 3,3 MB. Satır sayısı deponun kendi Go kodundan (43.020) fazla.

**Öneri** Ajan araçları ürün deposunun dışında durur ya da gitignore'a girer.

### 4 araç, ikişer sürüm. Sürümler projeler arasında kayıyor

Go, Next, Node ve Expo'nun her birinde projeler arasında iki sürüm birlikte kullanılıyor; Next, Node ve Expo'da fark ana sürümde. Temel imajlar digest'le değil etiketle sabitlenmiş.

**Öneri** Go, Node, Next ve Expo için birer sürüm yazan tek bir taban dosyası ve her depoda Renovate ya da Dependabot.

### 65 commit. Dallar birikiyor

Birleşmiş yerel dallar bazı depolarda 6–20'ye çıktı. Yerel main dalları origin'in 65 commit'e kadar gerisinde; yerelden yapılan sayım bu yüzden yanıltır.

**Öneri** Birleşen dal hemen silinir, emekli depolar arşivlenir. Sayım ve karşılaştırma yerel main'den değil origin'den yapılır.

## Emekli depolar

İki kapanmış ürünün altı deposu GitHub'da duruyor. Kişisel depolar bu sayıma girmedi.

**e-api**

Go API; 46 dosya, 4.313 satır, 11 commit.

**e-web**

Web arayüzü; 141 KB.

**e-closing**

Kapanan E ürününün kapanış sayfası deposu.

**f-api**

C# API; 53 dosya, 11.238 satır, 25 commit.

**f-web**

Web arayüzü; 4,9 MB.

**f-closing**

Kapanan F ürününün kapanış sayfası deposu.

## Denenebilecekler

| Deneme | Beklenen etki | Risk ve not |
|---|---|---|
| Büyük dosya kapısı | Yanlışlıkla eklenen ikili ve büyük görsel geçmişe hiç girmez. | Düşük. Meşru büyük dosyalar için kısa bir istisna listesi gerekir. |
| Görselleri WebP ya da AVIF'e çevirmek | Depolar ve uygulama paketleri küçülür; görsel ağırlığın çoğu 1,2–1,5 MB'lık marka PNG'leri. | Mağaza ikonları ve e-posta logoları PNG kalır. |
| Ortak paket | Kapı ve hesap motoru tek yerde düzeltilir; kopyalar arasında sessiz fark doğmaz. | Her depoda paket sürümünü yükseltmek ayrı bir adım olur. Hash karşılaştıran CI kontrolüyle başlanabilir. |
| Taban sürüm dosyası ve Renovate | Go, Node, Next ve Expo sürümleri dört projede birlikte ilerler. | Güncelleme PR'ları haftalık gruplanmazsa birikir. |
| Ajan aracını depodan çıkarmak | O deponun toplam satır sayısı ~%60 azalır. | Ajan becerisi depo dışından yüklenir. |

Ölçülmeyenler: GitHub'daki disk kullanımı (yerine yerel .git boyutu kullanıldı), mobil ikili boyutları (indirme gerekirdi) ve sıfırdan derlenmiş Go ikilisinin boyutu (yerine imaj boyutu kullanıldı).

<a id="depo-kurallari"></a>

## Yeni depo için kurallar

Bulgulardan çıkan kurallar; yeni bir depo ilk commit'inden bunlarla açılır.

1. Depo özeldir; sır taraması üç yerde çalışır.

gitleaks pre-commit'te ve CI'da, GitHub push protection açık. Elle yapılan taramada .env'i atlamayan bir grep kullanılır; bazı hızlı grep sürümleri gizli dosyaları varsayılan olarak atlar.

2. Büyük dosya ve ikili kapısı ilk commit'te kurulur.

Pre-commit ve CI ~1 MB'tan büyük her dosyayı ve her Mach-O ya da ELF ikilisini reddeder; meşru istisnalar kısa bir listede durur. Silinen ikili geçmişte kalır: bizde iki depoya birer macOS ikilisi girdi, geçmişten çıkarmak ancak geçmişi yeniden yazmakla olur.

3. .gitignore ilk commit'te anahtar desenlerini taşır.

.env*, *.jks, *.keystore, *.p8, *.p12, *.key, build ve native çıktı klasörleri, node_modules. Android upload anahtarı ve App Store Connect anahtarı depoya hiç girmez.

4. Depoda bir ajan dosyası deploy kuralını yazar.

CLAUDE.md ya da AGENTS.md: deploy, build, mağaza gönderimi ve sürüm numarası ürün sahibinin kararıdır; sıra kod biter, commit, tek satırlık rapor, karar. Hafızadaki bir not başka araçlarca görülmez, kural depoda durur.

5. İki dal, iki ortam.

test'e push test ortamına, main'e push onay kapısından prod'a gider; main yalnız test'te görülmüş commit'e fast-forward edilir, iki dal hep eşittir.

6. Birleşen dal hemen silinir.

Yerelde, GitHub'da ve worktree'de; depoda yalnız main ve test kalır. Sayım ve karşılaştırma yerel main'den değil origin'den yapılır.

7. Ortak kod kopyalanmaz.

Kapı ve hesap motoru gibi paylaşılan modül sürümlü bir paket olarak gelir. Paket yoksa kopyaların hash'ini karşılaştıran bir CI kontrolü konur.

8. Sürümler tek taban dosyasında, güncellemeler Renovate ya da Dependabot'la.

Go, Node, Next ve Expo için birer sürüm; temel imajlar sabit sürümle, latest yok. Güncelleme PR'ları haftalık gruplanır.

9. Görseller sıkıştırılmış girer; ajan araçları ürün deposuna girmez.

WebP ya da AVIF; marka dosyalarının tek kaynağı depo dışında. Üçüncü taraf ajan becerisi depo dışından yüklenir ya da gitignore'a girer.

10. Kapanan ürünün depoları arşivlenir.

Kod salt okunur kalır ve yanlışlıkla push almaz; arşiv GitHub'da geri alınabilir.
