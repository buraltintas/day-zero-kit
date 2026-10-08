# DESIGN.md
Kaynak: tokens/tokens.json. Güncelleme: 2026-10-08.
Üretim: node tokens/build.mjs. Denetim: node tokens/build.mjs --check
(üretilen dosyalarda fark ve kontrast) ve scripts/count-hex.sh
(token dışı renk sayısı, taban tokens/hex-baseline.txt).

## Tema
Yalnız açık (K-014). Koyu tema ilk sürümde yok; web'de
color-scheme: light (tokens/build/tokens.css), uygulamada açık
stil (app.config, adım 15). Yarım koyu ekran yayınlanmaz.

## Renk
Bütün değerler YER TUTUCU: marka renkleri tasarım paketiyle
gelecek (KARAR BEKLİYOR, docs/TODO.md). Rol adları kalır,
değerler değişir. Aşağıdaki tablo üretilir; elle değiştirme.
<!-- tokens:start -->
| Rol | Token | Değer | Kullanım | Karar |
|---|---|---|---|---|
| ink | --color-ink | #1a1a1a | Gövde metni ve başlıklar. Yer tutucu. | K-014 |
| ink-muted | --color-ink-muted | #595959 | İkincil metin: tarih, yer, açıklama. Yer tutucu. | K-014 |
| surface | --color-surface | #ffffff | Sayfa ve kart zemini. Yer tutucu. | K-014 |
| surface-muted | --color-surface-muted | #f2f2f2 | İkincil zemin: liste arası, devre dışı alan. Yer tutucu. | K-014 |
| line | --color-line | #8a8a8a | Kontrol kenarı ve ayraç; zemine karşı en az 3:1. Yer tutucu. | K-014 |
| accent | --color-accent | #1f5fbf | Ana eylem; yalnız basılacak şeylerde. Yer tutucu marka rengi. | K-014 |
| on-accent | --color-on-accent | #ffffff | Ana eylem rengi üstündeki metin. Yer tutucu. | K-014 |
| focus | --color-focus | #1f5fbf | Klavye odağı halkası; zemine karşı en az 3:1. Yer tutucu. | K-014 |
| success | --color-success | #1e7a3c | Durum: başarılı, ön plan (simge, kısa metin). Yanında metin olur. | K-014 |
| success-bg | --color-success-bg | #e6f4ea | Durum: başarılı, açık zemin. | K-014 |
| on-success-bg | --color-on-success-bg | #0f3d1e | Durum: başarılı zemin üstündeki metin. | K-014 |
| warning | --color-warning | #8a5a00 | Durum: uyarı, ön plan. | K-014 |
| warning-bg | --color-warning-bg | #fff4d6 | Durum: uyarı, açık zemin. | K-014 |
| on-warning-bg | --color-on-warning-bg | #4d3200 | Durum: uyarı zemini üstündeki metin. | K-014 |
| danger | --color-danger | #b3261e | Durum: hata, ön plan. | K-014 |
| danger-bg | --color-danger-bg | #fce8e6 | Durum: hata, açık zemin. | K-014 |
| on-danger-bg | --color-on-danger-bg | #5c130f | Durum: hata zemini üstündeki metin. | K-014 |
<!-- tokens:end -->

## Yazı
Aile: YER TUTUCU (system-ui). Seçilecek aile Türkçe gliflerle
("Ağır Işık Şöğüş İı") web, uygulama, e-posta, OG görseli ve
PDF'te ayrı ayrı denenir; denenmedi.
Ağırlıklar: 400 ve 600; web ve mobilde aynı küme, en çok dört.
Ölçek: caption 13, body 16, title-s 18, title-m 22, title-l 28.
Büyük harfte CSS'e güvenilmez; Türkçe metin tr-TR ile büyütülür.

## Aralık, köşe, gölge, hareket
Aralık 4, 8, 12, 16, 24, 32. Köşe 4, 8, 12. Gölge ve hareket
token'ı henüz yok; tasarım paketiyle.
Dokunma alanı: iOS ve web 44, Android 48.

## Ortak bileşenler
Henüz yok. Yeni bileşenden önce bu liste okunur. Her bileşenin
durumları: varsayılan, hover, odak, basılı, seçili, devre dışı,
yükleniyor, boş, hata, misafir ve girişli.

## Paketten sapmalar
| Paket | Ne dedi | Ne yaptık | Neden | Karar |
Henüz paket yok.

## Ekran kabul listesi
Token dışı renk yok; 375, 900, 1280 px; WebKit;
dört durum; uzun Türkçe metin; kontrast; 44 pt.
