<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="hafiza"></a>

Kurallar

# Proje hafızası ve devir

Projenin hafızası depoda durur: ne oldu, şu an ne durumda, sırada ne var, hangi karar neden verildi. Yeni gelen geliştirici ya da yapay zekâ ajanı ilk saatte projeyi tanıyıp devam edebilmeli. Dört ürünün 14 deposunda 820 CHANGELOG başlığının yalnız 11'inde tarih vardı; en büyük ajan hafıza klasöründeki 74 notun 28'i bir karar taşıyordu.

**Kural:** Hafıza dosyaları ilk commit'te açılır, her işle güncellenir.

Ajan gün 0'da, altyapıdan önce bu dosyaları oluşturur: AGENTS.md (CLAUDE.md'de yalnız `@AGENTS.md`), CHANGELOG.md, docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md, docs/runbooks/ ve docs/handoff/. Sonra her commit, deploy ve ürün sahibi kararında ilgili dosyayı aynı commit'te günceller. Kural ve karar depoya yazılır. Ajanın kendi notları (Claude Code'un auto memory'si) yalnız o makinedeki o aracın oturumlarında görünür.

## Hangi dosya hangi soruyu cevaplar

Dosya adları geleneksel İngilizce, içerik Türkçe; Türkçe karşılık adın altında. CLAUDE.md'de yalnız `@AGENTS.md` satırı durur, böylece Codex de Claude Code da aynı dosyayı okur. Sahip oturum, bir depoda main'e alma işini yapan tek ajan oturumudur; adı STATUS'ta yazılır.

_Grafik: Hangi dosya hangi soruyu cevaplar. Nasıl kurulur: README.md (kurulum ve yerel çalıştırma); okuyan: geliştirici ilk saatte. Nasıl çalışılır: AGENTS.md (ajan talimat dosyası, çalışma kuralları); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte. Şu an ne durumda: docs/STATUS.md (durum: canlı sürümler, bayraklar, sahip oturum); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Ne oldu: CHANGELOG.md (değişiklik günlüğü, en yeni üstte); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte. Neden böyle: docs/DECISIONS.md (kararlar, seçenekleri ve nedenleri); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Sırada ne var: docs/TODO.md (yapılacaklar ve karar bekleyenler); okuyan: ajan ilk 5 dakikada, geliştirici ilk saatte, ürün sahibi düzenli. Nerede kaldık: docs/handoff/ (devir notları, gün ya da oturum sonu); okuyan: ajan ilk 5 dakikada, ürün sahibi düzenli. Nasıl kurtarılır: docs/runbooks/ (işletme ve kurtarma adımları: deploy, geri dönüş); okuyan: ajan gerektiğinde, geliştirici gerektiğinde._

## Bizde ölçtüklerimiz

8 Ekim 2026 taraması: 14 deponun origin/main dalı (A beş, B üç, C dört, D iki), ajan hafıza klasörleri ve 20 Ağustos–8 Ekim oturum kayıtları. CHANGELOG 10 depoda var (biri boş), ajan talimat dosyası 9 depoda.

**11 / 820** CHANGELOG başlığından tarih taşıyanlar (A'nın beş, B'nin iki günlüğü). Ne zaman çıktığını yalnız git geçmişi söylüyordu.
**36 / 61** a-mobile'de yayında olduğu halde hâlâ 'Unreleased' duran başlık. a-api'de 114'ün 24'ü.
**12 / 15** Paralel dallar birleşirken çıkan çakışmalardan CHANGELOG'u içerenler.
**28 / 74** En büyük ajan hafıza klasöründeki notlardan karar içerenler. Bu kararları yalnız o makinedeki o araç görüyordu.
**4 / 45** Aynı klasörün notlarında geçen ve artık var olmayan dosya yolu. 74 notun 15'i 14 günden eski.
**67 kez** Tek bir oturumun 49 günde sıkıştırılma (compact) sayısı. Her sıkıştırmada araç sohbeti özetler; depoya yazılmamış ayrıntının bir kısmı gider.

## CHANGELOG boyutu

En büyük dördü son 30 günde günde 2–9 KB büyüdü. b-web'in tamamı 200 bin token'lık bağlamın yarısına yakın.

40 KB üstü40 KB altıKB, ölçek gerçek
_Grafik: CHANGELOG boyutları, KB, sınır 40: b-web 338,8; b-api 308,3; a-mobile 160,3; a-api 158,5; a-web 86,5; a-portal 68,2; c-web (ortak günlük) 58,2; a-market 57,1; c-api 17,6; b-mobile 0,3_

## Aynı commit'te CHANGELOG'a yazma oranı

8 Eylül–8 Ekim, kod değiştiren commit'ler, commit başına. C'de günlük deploy'dan sonra ayrı commit'te.

Kural ajan dosyasında yazılıYazılı değilGünlük ayrı commit'tekod commit'i, %; ölçek gerçek
_Grafik: Aynı commit'te CHANGELOG oranı. Kural yazılı: b-web %84, b-api %80, a-api %72. Yazılı değil: a-portal %52, a-mobile %51, a-market %36, a-web %33. Ürün C, 4 depo: %1–12._

## Bizde ne oldu

Kırmızı kenar bozulanı, koyu turkuaz kenar işleyeni anlatır; tarihler 2026. 4 ve 8 Ekim olayları [Vakalar](#vakalar) bölümünde ayrıntılı.

23 Eylül ile 8 Ekim arası

### Paralel dallarda CHANGELOG çakıştı

Her dal girdisini dosyanın tepesine, aynı satıra ekledi. 15 birleştirme çakışmasının 12'sinde CHANGELOG vardı.

**Bedel** 29 Eylül'de altı birleştirme ~8 dakika. Risk: sıra karışır.

**Kural** [öneri] Girdi dal başına parça dosyaya yazılır, main'e alırken birleştirilir.

3, 5 ve 7 Ekim

### Aynı depoda iki oturum main'e aldı, push reddedildi

İki oturum aynı depoda main'e alabiliyordu. Push reddedildi; bir dal 20 dakikada iki kez yeniden alındı.

**Bedel** Her seferinde rebase ve testler yeniden. Bozuk deploy olmadı.

**Kural** [kanıtlı] Bir depoda tek sahip oturum; diğerleri kendi dalında çalışır.

8 Ekim

### İstenmeden gönderilen raporlar iki oturumun işini kesti

Bir araştırma oturumu bulduklarını iki ürün oturumuna 'şunu yapın' diye gönderdi. Ürün sahibi o oturumları durdurdu.

**Bedel** İki oturumun akışı kesildi, ürün sahibi araya girmek zorunda kaldı. Süre ölçülmedi.

**Kural** [kanıtlı] Oturumlar arası mesaj yalnız ürün sahibi 'ilet' derse gider.

4 Ekim

### Doğru oturuma giden raporla hata 9 dakikada düzeldi

A'da çalışan oturum, B'nin canlısında konumun dakikada 20 ile 70 kez gönderilip 429 aldığını buldu. Ürün sahibinin talimatıyla rapor B'nin sahip oturumuna gitti: saatler, istek sayıları, kodda yer, öneri.

**Bedel** Rapor 18:45'te gitti, düzeltme 18:54'te canlıdaydı. Raporu yazan oturum koda dokunmadı.

**Kural** [kanıtlı] Başka ürünün sorunu kanıtla rapor edilir, düzeltmeyi o ürünün sahip oturumu yapar.

8 Ekim

### Elektrik kesintisi /tmp'yi sildi

Bilgisayar yeniden başlayınca /private/tmp boşaldı: yardımcı betikler, b-api'nin dört worktree'si, deneme veritabanı, bu rehberin çalışma dosyaları.

**Bedel** Commit'siz ajan işi gitti, büyüklüğü ölçülmedi. Rehber dosyaları iş akışı günlüklerinden birkaç dakikada geri alındı.

**Kural** [kanıtlı] Bir saatten uzun yaşayacak iş git'te ya da kalıcı klasörde durur.

21 Eylül

### Kardeş deponun ajan dosyası okunmadı

Oturum a-portal'da açılmıştı. Ajan a-market'ın main'ine push edip deploy bekledi; o depoda tetikleyici yoktu ve CLAUDE.md'si bunu söylüyordu, ama yüklenmemişti.

**Bedel** Yaklaşık 2 dakika, build izlenirken fark edildi. Fark edilmeseydi canlıda eski sürüm kalacaktı.

**Kural** [kanıtlı] Bir ürünün depoları aynı deploy davranışına sahip olur; yalnız .md değişen commit build almaz.

1 Ekim

### Hafıza notu 'açık' diyordu, canlıda kapalıydı

Not bir özelliğin 30 Eylül'de canlıda açıldığını yazıyordu; çalışan revizyonda bayrak kapalıydı. Ortam değişkeni başka bir yerden değiştirilmişti.

**Bedel** Ramak kala: bir belgeye 'canlıda' diye yazılacaktı.

**Kural** [kanıtlı] 'Canlıda' demeden çalışan revizyonun ortam değişkeni ve herkese açık uç okunur.

8 Ekim ölçümü

### Belgeler ve hafıza sessizce bayatladı

a-api'nin ajan dosyası 16 iç paketin 6'sını sayıyor ve 'gerçek durum' için 16 Eylül'den beri değişmeyen bir yol haritasını gösteriyor. a-mobile'in TODO.md'si üç sürüm geride.

**Bedel** Ölçülmedi. Risk: ajanın eski bilgiyle karar vermesi. Henüz sistemli düzeltme yok.

**Kural** [öneri] Her yaşayan belgenin tepesinde 'son doğrulama' tarihi; ayda bir tazelik turu.

27 Eylül ile 8 Ekim arası

### Ajan notları oturumun açıldığı klasöre yazıldı

C'nin oturumları ilgisiz bir projenin klasöründen açıldı; C'nin 15 hafıza notu o projenin hafızasında. B'nin hafıza klasöründe A'nın kuralları da var.

**Bedel** C'nin kendi deposunda açılan yeni bir oturum bu notları görmez.

**Kural** [öneri] Oturum ürünün ana deposunda açılır; ürün kuralları AGENTS.md'ye yazılır.

2 Ekim

### Devir notuyla iş başka oturuma geçti

Dört ürüne dokunan bir günün sonunda kalıcı klasöre bir genel not ve ürün başına birer not yazıldı. Dallar henüz GitHub'da değildi, onay bekliyordu.

**Bedel** Notu yazmak birkaç dakika. 4 Ekim'de başka bir oturum notu okuyup işi sürdürdü.

**Kural** [kanıtlı] Gün ya da iş biterken devir notu kalıcı yere yazılır; okuyan soru sormadan sıradaki adımı atabilmeli.

16 Eylül

### Yarım iş 'bitti' diye raporlandı

Bir tasarım teslimi 'yapıldı' diye raporlandı; yalnız iskelet ve filtreler vardı, tablo, çekmece ve üst çubuk yoktu.

**Bedel** Ürün sahibinin sonraki her durum raporuna güveni sarsıldı.

**Kural** [kanıtlı] 'Bitti' yalnız işin tamamı varken yazılır; ara raporda biten, kalan ve yapılamayan (nedeniyle) ayrı yazılır.

5 Ekim

### Türkçe uydurma dosya adı geri çevrildi

Ajan ürün günlüğünü Türkçe uydurma bir adla açtı. Ürün sahibi adı reddetti, dosya bir sonraki deploy'da yeniden adlandırıldı.

**Bedel** Bir düzeltme turu ve fazladan bir commit.

**Kural** [kanıtlı] Dosya adları geleneksel: README.md, CHANGELOG.md, AGENTS.md, docs/. Türkçe başlıkta kalır.

## Gün 0: ajan önce ürün sahibine sorar

Ajan gün 0'da [Kararlar](#kararlar) tablosunun gün 0 satırlarını sorar; bu bölüm ayrı soru listesi tutmaz. Proje hafızasıyla ilgili sorular tablonun 7, 8, 9, 10, 12 ve 26. satırlarındadır. Cevabı gelmeyen satır AGENTS.md'de 'KARAR BEKLİYOR' diye kalır ve TODO'nun karar bekleyen bölümüne girer.

## Ajanın gün 0'da açtığı dosyalar

[öneri] Bu düzen depolarımızda en iyi işleyen parçaların birleşimi; tam haliyle hiçbir depomuzda yok. Şablonlar aşağıda.

| Dosya | İlk gün içinde |
|---|---|
| AGENTS.md | Şablondaki iskelet, ürün sahibinin cevaplarıyla doldurulur. Bilinmeyen satır 'KARAR BEKLİYOR' diye kalır. |
| CLAUDE.md | Yalnız `@AGENTS.md` satırı. |
| CHANGELOG.md | Başlık, yazım kuralları ve boş bir Unreleased bölümü. |
| docs/STATUS.md | 'Canlıda: henüz yok'. İlk gün kurulan her servis eklendikçe doğrulama yöntemiyle dolar. |
| docs/TODO.md | Altyapı kurulum adımları P1 olarak; ürün sahibinin kararını bekleyenler ayrı başlıkta. |
| docs/DECISIONS.md | Kararlar tablosundaki her cevap bir K bloğudur. Numara verildiği sırayla K-001'den artar, blok tablodaki satırı taşır (ör. 'Tablo: 7'). |
| docs/runbooks/ | deploy.md ve rollback.md ilk deploy'dan önce; restore-db.md ilk yedekten sonra, prova tarihiyle. |
| docs/handoff/ | Boş klasör. Her oturum ya da gün sonunda bir not. |
| .gitignore | `.env` yok sayılır, `!.env.example` satırıyla örnek dosya git'te kalır. |

## Çalışırken neyi nereye yazar

Kod ve deploy kayıtları işi yapan commit'in içinde yazılır. Deploy'dan sonra ayrı commit'te yazılan günlük unutulmaya açık; C'de kod commit'lerinin yalnız %1–12'si günlüğe dokunuyor.

| Ne olunca | Nereye | Ne yazılır |
|---|---|---|
| Davranış değiştiren her commit | CHANGELOG.md | Unreleased bölümüne bir girdi, aynı commit'te. |
| Her deploy | CHANGELOG.md, docs/STATUS.md | Unreleased bölümü tarih ve revizyon başlığına çevrilir; STATUS'un 'Canlıda' satırı doğrulama yöntemiyle güncellenir. |
| Ürün sahibinin her kararı | docs/DECISIONS.md | Bir blok: tarih, seçenekler, neden, yeniden bakılacak tarih. |
| Yeni iş ya da bulgu | docs/TODO.md | Öncelik ve sahiple bir satır. Biten iş buradan silinir, CHANGELOG'a girer. |
| İkinci kez yapılan hata ya da pahalı ders | AGENTS.md, docs/lessons.md | AGENTS.md'ye bir satırlık kural, anlatımı docs/lessons.md'ye. |
| Oturum ya da gün sonu | docs/handoff/ | Devir notu. Uzun işin ara çıktısı kalıcı klasöre. |
| Ücretli çağrı ya da süren maliyet kurmadan önce | docs/TODO.md ya da DECISIONS | Günlük ve aylık rakam; kurulum ürün sahibinin onayından sonra. |

## Şablonlar

Kopyalanıp doldurulur. Örnek satırlar biçimi gösterir; numaralar temsilîdir. Açılı parantezli yerler ürün sahibinin cevabıyla dolar.

### AGENTS.md

Gün 0'da; kural ya da ders eklendikçe. CLAUDE.md içinde yalnız `@AGENTS.md`.

```
# AGENTS.md
<!-- CLAUDE.md içinde yalnız: @AGENTS.md -->
Son doğrulama: 2026-10-08

## Ürün
Ne: <tek cümle>. Kim kullanır: <tek cümle>.
Bu depo: <api | web | mobil | admin>.
Kardeş depolar: <x-api, x-web, x-mobile>.
Dokunmadan önce onların AGENTS.md'sini oku.

## Çalıştır ve doğrula
Yerel: make dev | npm run dev
  (yalnız yerel ya da test veritabanı)
Doğrula: make test vet
  | npm run typecheck && npm test && npm run lint
Temiz değilse iş bitmedi.

## Dallar ve deploy (karar: ürün sahibi)
test'e push: test ortamı. Hat test eder,
  imajı bir kez kurar, digest'i yazar.
main'e push: onay kapısı. Onaydan sonra
  test'te denenen aynı digest prod'a çıkar.
main yalnız test'te görülmüş commit'e ilerler.
Sıra: kod biter, commit, tek satır rapor,
  ürün sahibinin "deploy" sözü.
Migration hattın adımı: migrate job aynı
  digest'le koşar, bitmeden trafik verilmez.
Migration yalnız ekler. Onu okuyan kod
  sonraki deploy'da çıkar.
Build, mağazaya gönderim ve sürüm numarası
  ürün sahibinin kararı.

## Asla
- Onaysız main push.
- Canlıya deneme verisi ya da test isteği.
- Gizli değeri dosyaya, commit'e, loga,
  sohbete yazmak.
- Ücretli servisi rakamını söylemeden çağırmak.
- Başka oturuma kendiliğinden iş göndermek.

## Gizli bilgiler
Değerler Secret Manager'da, adlar .env.example'da.
Değer hiçbir dosyada yok.

## Kayıt (her değişiklikte)
CHANGELOG.md: aynı commit'te.
Durum: docs/STATUS.md. İşler: docs/TODO.md.
Kararlar: docs/DECISIONS.md.
Runbook: docs/runbooks/. Devir: docs/handoff/.
Zor öğrenilen ders: buraya bir satır,
  anlatımı docs/lessons.md'ye.
```

### docs/runbooks/

İlk deploy'dan önce; restore-db.md ilk yedekten sonra.

```
docs/runbooks/
deploy.md
  test'e çıkış, main'e alma, canlı doğrulama
rollback.md
  önceki revizyona trafik; migration geri alınmaz
restore-db.md
  zaman noktasına dal, döküm, md5 karşılaştırma
rotate-secret.md
  iki değerli geçiş, eski değerin silineceği gün
incident.md
  ilk 15 dakika: ölç, düzelt ya da geri al, kayıt
release-mobile.md
  build hakkı, sürüm numarası, mağaza adımları
new-env.md
  sıfırdan test ortamı: veritabanı dalı, servisler
cost-check.md
  günlük maliyet nereden okunur, eşikte ne yapılır

Her runbook'ta: amaç, ne zaman, kim onaylar,
kopyalanabilir komutlar (proje adı açık),
doğrulama, geri dönüş, son prova tarihi.
Prova edilmeyen runbook bayat sayılır.
```

### CHANGELOG.md

Davranış değiştiren her commit'te; deploy'da Unreleased kapanır.

```
# Changelog
En yeni üstte. Önce kullanıcının fark edeceği
değişiklik (en çok 2 satır), sonra teknik
ayrıntı (en çok 5 satır). Gizli değer yazılmaz.
Türler: Eklendi, Değişti, Kalkacak, Kaldırıldı,
Düzeltildi, Güvenlik.
40 KB'ı geçince en eski ay
docs/changelog/YYYY-AA.md'ye taşınır.

## Unreleased
### Eklendi
- Paylaşılan listeyi açan web sayfası.
  (dal share-links, test ortamında)

## 2026-10-08 (api rev 00012, web rev 00007)
### Eklendi (bayrak kapalı)
- Kullanıcı kaydettiği listeyi paylaşabilecek.
  (api a1b2c3d, web e4f5a6b)
  Teknik: POST /v1/shares. Önce migration 014.
  Bayrak SHARE=false.
  Geri dönüş: bayrağı kapat.
### Düzeltildi
- Aynı arama artık hep aynı sonucu veriyor.
  (api 9f8e7d6) Sebep: sınıflandırıcı
  varsayılan sıcaklıktaydı, 0'a çekildi.
### Güvenlik
- Admin oturumu 30 dakika boşta kalınca
  kapanıyor. (api 3c4d5e6, K-006)
```

### docs/STATUS.md

Her deploy'da, aynı commit'te.

```
# Durum
Son güncelleme: 2026-10-08 14:25, deploy sonrası.
7 günden eskiyse güvenme, canlıya bak.
Sahip oturum: <ürün ve iş adı>.
Ürün sahibi: <rol>.

## Canlıda (doğrulama yöntemiyle)
- api: a1b2c3d, rev 00012, 2026-10-08.
  /health 200, son 1 saatte 5xx 0.
- web: e4f5a6b, rev 00007.
  Ana sayfa ve giriş elle denendi.
- mobil: iOS ve Android 1.0.3 mağazada.
- Veritabanı: son migration 014, canlıda.
- Bayraklar: SHARE=false.

## Devam eden
- dal share-links: test ortamında,
  ürün sahibinin bakması bekleniyor.

## Bekleyen (dış etken ya da karar)
- Mağaza incelemesi 1.0.4, gönderim 2026-10-07.

## Bilinen sorunlar
- Kullanıcıya etkisi, geçici çözüm, TODO satırı.
```

### docs/TODO.md

İş eklenince ya da bitince.

```
# Yapılacaklar
Yalnız açık işler. Biten iş silinir,
CHANGELOG'a girer.
Satır: - [ ] [öncelik] iş. Sahip. Tarih. Bağlantı.
P0 canlı kırık (hemen), P1 bu hafta,
P2 sırada, P3 fikir.

## P0
## P1
- [ ] [P1] Ödeme ekranında iptal koşulu yazmıyor.
  Sahip: ajan. 2026-10-08.
## P2
- [ ] [P2] Arama sonuçlarını 6 saat önbellekte
  tut. Sahip: ajan. 2026-10-06.
  Ölçüm: docs/notes/search-cost.md.
  Etki: veritabanı daha çok uyur.

## Karar bekleyen (karar: ürün sahibi)
- [ ] Yıllık plan fiyatı. Soruldu: 2026-10-05.
  Seçenekler ve önerim: DECISIONS, taslak K-008.

## Rafta (bilinçli yapılmayanlar)
- Sayfaların baştan yeniden yazımı.
  Neden: ekranda görülmeden risk yüksek.
  Yeniden bak: 2026-11-15.
```

### docs/DECISIONS.md

Ürün sahibi karar verince.

```
# Kararlar
Her karar bir blok. Numara tekrar kullanılmaz.
Değişen karar silinmez: "yerini aldı: K-007".
Ajan karar vermez, ürün sahibinin kararını
kaydeder.

## K-006 Admin oturumu 30 dk boşta kapanır
Tarih: 2026-09-28. Durum: geçerli.
Karar veren: ürün sahibi.
Tablo: 23.
Bağlam: admin paneli müşteri verisine erişir.
Karar: 30 dakika boşta çıkış.
Seçenekler: 8 saat (reddedildi: kolaylık için
  güvenlikten taviz).
Sonuç: admin gün içinde birkaç kez
  yeniden giriş yapar.
Yeniden bak: ikinci admin eklenince
  ya da 2027-01.
Bağlantı: api 3c4d5e6, CHANGELOG 2026-10-08.

## K-007 ...
```

### docs/handoff/2026-10-08.md

Gün ya da oturum sonunda; git'te ya da kalıcı klasörde.

```
# Devir notu: 2026-10-08, <oturum adı>
Yer: docs/handoff/ ya da kalıcı bir klasör
(/tmp açılışta silinir)

## Bitti ve canlıda (doğrulandı)
- api rev 00012 (a1b2c3d): paylaşım ucu.
  Doğrulama: 2.022 istekte 5xx 0.

## Bitti, yayında değil
- dal share-links, b1c2d3e..f4a5b6c,
  worktree ~/work/api-share-links
  Test'e: git -C ~/work/api-share-links \
    push origin share-links:test
  Canlıya yalnız ürün sahibinin onayıyla.
  main, test'te doğrulanan commit'e
  ileri sarılır; iş dalı main'e itilmez:
    git -C ~/work/api-share-links fetch origin
    git -C ~/work/api-share-links \
      push origin origin/test:main
  İleri sarma değilse push reddedilir;
  --force kullanılmaz, ürün sahibine
  tek satırla söylenir.
  Adımlar: runbooks/deploy.md.

## Bitmedi
- Mobil ekran: liste var, paylaşım sayfası yok.
  Sıradaki adım: ...

## Riskler ve geri dönüş
- Trafik önceki revizyona (runbooks/rollback.md).

## Yarın kontrol edilecek
- 04:20 işi 2xx mi, gece yedeği alındı mı.

## Karar bekleyen
- Soru, seçenekler, önerim (tek paragraf).
```

Runbook ayrıntıları: geri dönüş için [Kullanıcıyı kırmadan değiştirmek](#kirmama), geri yükleme için [Yedekler](#yedek), mobil sürüm için [Mobil dağıtım](#dagitim), maliyet okuma için [Maliyet](#maliyet).

## Kurallar

Kanıtlı kural bizde işliyor. Ölçüldü etiketinde rakam bizim ölçümümüz ama çözüm her zaman denenmedi; 40 KB sınırı, tarihli sürüm başlığı ve docs/lessons.md ayrımı bizde henüz uygulanmadı. Öneri bizde denenmedi; başka öneriler [Bizdekinden iyisi](#hf-iyisi) başlığında.

### Değişiklik günlüğü

[kanıtlı]
**CHANGELOG en yeni üstte yazılır**. Ajan dosyayı baştan okur; okuma aracı büyük dosyada yalnız ilk sayfayı döndürse de en yenisi görülür.
[ölçüldü]
**Davranış değiştiren commit günlüğü aynı commit'te günceller, bu kural AGENTS.md'de yazılır**. Yazılı olan üç depoda oran %72–84, olmayan dördünde %33–52.
[ölçüldü]
**Ana dosya 40 KB'ı** (~12 bin token) geçmez; girdi en çok 2 satır kullanıcı etkisi, 5 satır teknik ayrıntı. Bizde girdi ortancası 0,8–1,7 KB, en uzunu 11,8 KB idi.
[ölçüldü]
**Tek Unreleased bölümü deploy olunca ISO tarih ve canlı revizyon başlığına çevrilir**; girdi commit kısaltması taşır. 820 başlığın 11'inde tarih vardı.
[kanıtlı]
**Yalnız .md ya da docs/ değişen commit canlı build'i tetiklemez**. Belge düzeltmesi deploy korkusuyla beklemez.

### Ajan dosyası

[kanıtlı]
**Tek kaynak AGENTS.md**; CLAUDE.md'de yalnız `@AGENTS.md` ve gerekirse Claude'a özel birkaç satır. Claude Code, CLAUDE.md varken AGENTS.md'yi bu import olmadan okumaz (kullanıcı ayarı `claude-md-and-agents-md` hariç).
[kanıtlı]
**Deploy kuralı dosyanın en üstünde ve ürünün bütün depolarında aynı cümlelerle durur**. Ayrıntısı [Kullanıcıyı kırmadan değiştirmek](#kirmama) ve [Yeni depo için kurallar](#depo-kurallari) bölümlerinde.
[ölçüldü]
**Zor öğrenilen ders kaça mal olduğuyla bir satır girer, anlatımı docs/lessons.md'ye**. B'nin dosyaları 245 ve 203 satıra çıktı; Claude Code 200 satırın altını öneriyor.

### Durum, iş ve kararlar

[kanıtlı]
**Ürün düzeyinde tek durum yeri olur**. C'de ürün günlüğünün tepesindeki durum bölümü canlı sürümleri, son migration'ı ve bekleyenleri tek yerde gösteriyor.
[kanıtlı]
**STATUS'taki her canlı satırı doğrulama yöntemini ve tarihini taşır**. Hafıza notu ve eski durum satırı durum kaynağı değildir.
[öneri]
**Kararlar depoya yazılır** (DECISIONS.md ya da numaralı ADR). En büyük hafıza klasöründeki 74 notun 28'i karar içeriyordu ve yalnız o makinede duruyordu.

## Göreve başlarken

### Ajanın ilk 5 dakikası

[öneri] Sıra bizde parça parça uygulandı. 3. adım 4 Ekim'de bir işin ikinci kez yapılmasını bir dakikada önledi.

1. AGENTS.md. Claude Code'da `/memory` ile yüklenen dosyalara bak; AGENTS.md listede yoksa aç ve oku.

2. docs/STATUS.md: canlı sürümler, bayraklar, sahip oturum. Başka oturum sahipse yalnız kendi dalında çalış.

3. `git fetch`, `git log --oneline -20 origin/main`, `git status`, `git worktree list`. İş zaten yapılmış mı.

4. CHANGELOG.md'nin ilk 150 satırı. Tamamını okuma.

5. docs/TODO.md ve docs/DECISIONS.md'de işle ilgili satır var mı. Yoksa TODO'ya ekle.

6. En yeni devir notu. 'Yarın kontrol edilecek' maddeleri ilk iştir.

7. Dokunacağın kardeş deponun AGENTS.md'si; kendi deponun kuralı oraya taşınmaz.

8. Ürün sahibine tek satır: iş, dokunulacak depolar, deploy ya da ücretli çağrı gerekiyor mu.

### Yeni geliştiricinin ilk saati

[öneri] Taramada README komutlarının yalnız var olduğu görüldü, temiz makinede çalıştırılmadı; d-web'in ilk adımı temiz klonda çalışamaz. İlk saat bu denemedir.

1. README'deki kurulumu sırayla uygula. .env değerlerini gizli bilgi yöneticisinden al, sohbete yapıştırma.

2. Yerel testleri çalıştır (`make test` ya da `npm test`). Takıldığın her adım README'ye girer.

3. AGENTS.md'yi baştan sona oku: deploy kuralı, 'asla' listesi, doğrulama komutları.

4. docs/STATUS.md: ne canlıda, ne yarım, ne bekliyor. Damga 7 günden eskiyse canlıya bak.

5. CHANGELOG.md'nin Unreleased bölümü ve son iki tarih başlığı.

6. docs/DECISIONS.md başlıkları; bir şeyi tartışmaya açmadan önce burada ara.

7. docs/TODO.md'den bir P2 iş al, dal aç, test ortamına çıkar, CHANGELOG'a yaz. Main kararı ürün sahibinde.

## Birden çok oturum ve ajan

Bizde aynı anda birkaç uzun ömürlü oturum, aynı depolarda çalışıyordu. Yayın kuralının hafızadan depoya taşındığı 20 Eylül olayı ve yazılı 'önce test' kuralının üç depoda atlandığı 26 Eylül olayı: [Kullanıcıyı kırmadan değiştirmek](#kirmama), [7.2](#k-7-2) ve [7.1](#k-7-1).

[kanıtlı]
**Bir depo ya da dal, bir sahip oturum**. Sahibin adı STATUS'ta yazılı; diğerleri kendi dalında çalışır ve dalı commit listesiyle sahibe teslim eder.
[kanıtlı]
**İşe başlamadan ve push'tan önce `git fetch`, son 20 commit, CHANGELOG'un tepesi**. 4 Ekim'de bir düzeltmenin sabah başka oturumda yapıldığı böyle bir dakikada görüldü.
[kanıtlı]
**Her paralel iş kendi dalında ve worktree'sinde**. Worktree kalıcı klasörde durur (`~/Documents/worktrees/<depo>-<dal>` gibi); /tmp açılışta silinir.
[kanıtlı]
**Aynı gün birden çok dal girecekse tek entegrasyon dalı kullanılır**: dallar orada sırayla birleşir, test ortamına o dal çıkar, main o commit'e ileri sarılır.
[kanıtlı]
**Oturumlar arası mesaj yalnız ürün sahibinin 'ilet' sözüyle gider**: kanıt, kodda yer, öneri. Raporu yazan oturum koda dokunmaz.
[kanıtlı]
**Uzun iş akışında her ajanın sonucu kalıcı bir günlüğe yazılır**; kesintide iş kaldığı yerden sürer, biten ajan yeniden koşmaz.
[öneri]
**Haftada en az bir devir notu**; büyük iş yeni oturumda, devir notuyla başlar. Uzun oturum bağlamı aşındırır: bir oturum 49 günde 67 kez sıkıştırıldı.
[öneri]
**Oturum değiştirilecek depoda açılır**. Birden çok depo için `--add-dir` ve `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`. Bizde a-portal'da açılan bir oturumun 29.866 araç çağrısının 10.739'u dört kardeş depoya gitti (en çok a-api, 5.079).
[öneri]
**Geri dönüşü olmayan adımı araç durdurur**: korumalı main, izin listesinde `git push` yok, onay dosyası yoksa main push'unu durduran PreToolUse hook'u. 26 Eylül'de yazılı 'önce test' kuralı üç depoda atlandı.

## Tazelik kontrolleri

Güncellemesi birinin hatırlamasına kalan belge bayatlıyor; a-mobile'in TODO.md'si üç sürüm geride kaldı. Kontrolü takvim ve CI yapar.

| Ne zaman | Kontrol | Etiket |
|---|---|---|
| Her PR'da, CI | **Günlük yazıldı mı.** Kaynak kod değişip Unreleased değişmediyse uyarı; 'günlük gerekmez' etiketiyle atlanır. | [öneri] |
|  | **Boyut.** CHANGELOG 40 KB'ı, AGENTS.md 200 satırı geçerse uyarı. | [öneri] |
|  | **Komutlar var mı.** README ve AGENTS.md'deki her `npm run` ve `make` hedefi depoda var mı. Bizde hepsi vardı; temiz makinede denemek ayrıca gerekir. | [ölçüldü] |
|  | **Örnek ortam dosyası.** .env.example git'te ve kodun okuduğu adları içeriyor mu. d-web'de `.env*` kalıbı onu yuttu, README'nin ilk adımı çalışmıyor. | [öneri] |
| Her deploy'da | **Durum damgası.** STATUS'un canlı satırını ve CHANGELOG'un tarih başlığını deploy adımı yazar, ya da sürüm bir /version ucundan okunur. C'de içerik 7 Ekim'deydi, elle yazılan damga 6 Ekim. | [öneri] |
| Ayda bir, 15 dakika | **Tazelik turu.** Ajan hazırlar, ürün sahibi bakar: STATUS canlıyla karşılaştırılır, 30 günden eski P1'ler sorulur, 'yeniden bak' tarihi geçen kararlar ve ajan dosyasındaki yollar kontrol edilir. | [öneri] |
|  | **Hafıza budaması.** Olmayan dosya, bayrak ya da sürüm geçen notlar silinir, kararlar depoya taşınır. MEMORY.md 200 satır ve 25 KB altında kalır; bizde 75 satır, 11 KB. | [öneri] |
| Dal birleşince, kesintiden sonra | **Dal ve worktree.** Birleşen dal ve worktree hemen silinir. A'nın dört deposunda uzakta yalnız main ve test kaldı. | [kanıtlı] |
|  | **Ölü kayıtlar.** Kesintiden sonra `git worktree prune`. C'de 28 worktree kaydı silinmiş /tmp klasörlerini gösteriyordu. | [öneri] |

## Bizdekinden iyisi

Bizde denenmedi; belgelere ve kendi açıklarımıza dayanıyor.

[öneri]

### Değişiklik günlüğü parçaları

Her dal kendi küçük dosyasını yazar (changes/unreleased/<dal>.md), sürüm anında tek komutla birleştirilir; towncrier ve changesets böyle çalışır. `merge=union` da olur, ama sıra elle kontrol edilir.

[öneri]

### Haftalık devir taslağı

Zamanlanmış bir görev git geçmişinden, Unreleased bölümünden ve açık dallardan taslak çıkarır; ürün sahibi okur ve düzeltir. Sürüm başlıkları `git tag` ile bağlanır.

[öneri]

### Yola bağlı kurallar

Ders anlatımları .claude/rules/ altında, `paths:` alanıyla durur; yalnız ilgili dosyaya dokunulunca yüklenir, AGENTS.md kısa kalır.

[öneri]

### Ajan hafızasının yedeği

Hafıza klasörü makineye bağlı ve sürüm kontrolsüz. Ayrı, özel bir git deposuna günlük commit ya da `autoMemoryDirectory` ile yedeklenen bir klasör.

## Tuzaklar

Araçların varsayılanlarından ve alışkanlıklardan gelen tuzaklar.

CLAUDE.md'si olmayan depoda bir CLAUDE.local.md eklemek, Claude Code'un AGENTS.md'yi okumasını durdurur. `@AGENTS.md` importlu bir CLAUDE.md bunu önler.

Codex AGENTS.md zincirini varsayılan olarak 32 KiB'ta keser; ders biriktiren dosya bu sınıra yaklaşabilir.

İzin listesine `git push` eklemek, push'un deploy olduğu depoda son onay sorusunu sessizce kaldırır.

Gösterici satır ('gerçek durum şu dosyada') gösterdiği dosya bayatlarsa ajanı yanlış yere götürür.

Aynı belgenin iki kopyası zamanla ayrışır; birini güncelleyen öbürünü unutur. c-admin'in docs/ klasörü c-web'inkinin kopyası, ikisi de Şubat'tan beri değişmedi.

### Ölçülmeyenler

Bu bölümdeki rakamlar 8 Ekim 2026 taramasından. Aşağıdakiler ölçülmedi ya da kaba tahmin.

CHANGELOG çakışmalarının toplam zaman maliyeti; tek tek 1 ile 8 dakika görüldü.

8 Ekim kesintisinde kaybolan commit'siz işin büyüklüğü.

İstenmeden gönderilen iki mesajın o oturumlara maliyeti.

20 Eylül'deki iki izinsiz build'in iOS kotasının bitmesindeki payı.

Ajan dosyalarına yazılan kurallardan sonra izinsiz main push ya da build olup olmadığı; sistemli tarama yapılmadı.

README kurulumlarının gerçekten çalışıp çalışmadığı; yalnız komutların var olduğu kontrol edildi, temiz makinede denenmedi.

Token sayıları karakter/3,3 (Türkçe) ve karakter/4 (İngilizce) ile kaba tahmin; gerçek tokenizer ile sayılmadı.

Bayat bir belge ya da hafıza notunun kaç kez yanlış karara yol açtığı.

Codex oturumlarının hangi talimat dosyalarını gerçekten yüklediği; yalnız Claude Code kayıtları incelendi.

Aynı commit oranı commit başına; bir özellik birden çok commit'e bölündüğünde oran düşük görünür, özellik başına oran ölçülmedi.

## Kaynaklar

**Claude Code: proje hafızası, @import, auto memory**https://code.claude.com/docs/en/memory
**Claude Code: araç başvurusu, kısmi okuma**https://code.claude.com/docs/en/tools-reference
**OpenAI Codex: AGENTS.md ve 32 KiB sınırı**https://learn.chatgpt.com/docs/agent-configuration/agents-md
**AGENTS.md açık biçimi**https://agents.md/
**Keep a Changelog 1.1.0**https://keepachangelog.com/en/1.1.0/
**git gitattributes: union birleştirme**https://git-scm.com/docs/gitattributes
**towncrier: parça dosyalarla günlük**https://towncrier.readthedocs.io/en/stable/tutorial.html
**Mimari kararların kaydı (ADR), ilk yazı**https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
**ADR örnekleri ve araçları**https://adr.github.io/
