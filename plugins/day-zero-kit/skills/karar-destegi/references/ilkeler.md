<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="bakis"></a>

Bir bakışta

# Kısaca

Yeni ürün Neon Postgres, Go API, Next.js 16 ve Expo ile Google Cloud'da kurulur. Neon uyuyabilecek şekilde bağlanır; prod Launch'ta (aylık asgari ücret yok), test ve gerçek kullanıcısı olmayan yan projeler Free org'da. API ve web Cloud Run europe-west1'de min 0 ile çalışır. Herkese açık okumalar API belleğinden verilir, GCS'teki bir değişiklik işaretiyle tazelenir. Zamanlanmış işler tek bir Cloud Scheduler işinden OAuth token ile Cloud Run Jobs'a gider. DNS ilk günden Cloudflare'dedir: web Worker üzerinden run.app'e, api.* domain mapping ile bağlanır. Önerilen hatta imaj bir kez kurulur ve test'te doğrulanan digest onay kapısından geçerek prod'a çıkar; bizde test ve prod bugün hâlâ ayrı build ediliyor. Mobil uygulama uzaktan kontrol kiti kurulmadan yayınlanmaz. Alarmlar, doğrulanan yedek ve KVKK işleyen listesi ilk kullanıcıdan önce hazırdır. Az trafikli yeni bir ürünün bulut faturası ayda ~₺55–135, günlük kullanıcılı bir ürününki ~₺510–690 olur; gerçek kullanıcılı üründe bunun en az %60'ı Neon'dur. Alan adı ve mağaza ücretleri zorunlu sabit gider oldukları için hesaba katılmadı.

## On ilke

### 1. Veritabanı uyuyabilmeli

Neon ancak 5 dakika hiç bağlantı olmazsa uyur. Havuzun tabanı 0, boştaki bağlantı 90 sn'de kapanır, zamanlayıcıyla soran kod yoktur, herkese açık okumalar veritabanına gitmez, günlük veritabanı işleri tek sabah penceresinde çalışır.

**Neden** Bir ürünümüzün günlük tüketimi 7/24 uyanıkken 6,2 CU-saatti, bu kurallarla ~3,2'ye indi.

### 2. Önce say, sonra değiştir

Maliyet ve uyanma sorununa ölçümle başlanır: fatura proje ve SKU bazında, Neon tüketimi saat saat, trafik 5 dakikalık boş pencerelerle okunur.

**Neden** GCP için '$1/ay' denmişti; Ağustos'ta faturalama hesabının toplamı ₺2.087 geldi.

### 3. Geçici hata kimseyi oturumdan atmaz

401 yalnız kesin yetki reddinde döner; veritabanı ya da altyapı hatası 503 ve Retry-After ile döner; istemci oturumu yalnız 401'de siler; API açılışta veritabanını ~30 sn bekler.

**Neden** Soğuk başlangıçların ~%1–1,5'i uyuyan Neon'a denk geliyor; bu hata 401 dönseydi kullanıcılar oturumdan düşerdi.

### 4. Sessiz hata yoktur

Başarısız iş 2xx dönmez; her 5xx sebebiyle ve severity alanıyla loglanır; az trafikli kritik uçlara 'N saattir başarı yok' alarmı kurulur.

**Neden** Bir ödeme webhook'u 21 gün boyunca log yazmadan 500 döndü.

### 5. Prod'a giden yolu makine korur

Test'te doğrulanan imaj aynı digest'le, onay kapısından geçerek prod'a çıkar; testler ve migration hattın içindedir.

**Neden** Migration koşmadan yayına çıkan kod 11 dakika 500 döndürdü.

### 6. Yerel varsayılan asla prod olmaz

Kod, env dosyaları, testler, simülatör ve dev sunucusu varsayılan olarak yerel ya da test ortamına bağlanır; prod'a dokunan komutun adında 'prod' geçer; mobil build ve OTA ortamı açıkça veren bir betikle alınır.

**Neden** Bir testin prod'a yazdığı 44 sahte hesaplama herkese açık listede göründü.

### 7. Her çalışan şey en az yetkiyle

Her servis kendi rolsüz hesabıyla çalışır, yetki kaynakta verilir, sırlar Secret Manager'dadır, anahtar dosyası indirilmez; bir projede kapatılan açık aynı gün bütün projelerde kontrol edilir.

**Neden** 23 Eyl 2026'da bir SSRF açığı Editor yetkili hesapla birleşince proje ele geçirilebilir hale geldi ve aynı gün kapatıldı.

### 8. Para harcayan her şeyin rakamı ve tavanı önceden yazılır

Ücretli iş kurulmadan 'günde ~$Y, ayda ~$Z' satırı yazılır; anahtar projeye özeldir, sağlayıcıda sert bütçe vardır, uygulama içi tavan veritabanında filo genelinde sayılır.

**Neden** Bir harita API'si Ağustos'ta ₺1.500 yazdı, projenin Google faturasının ~%72'si.

### 9. Riskli değişiklik gölgede başlar, anahtarla kapanır

Yeni okuma yolu, CSP, bot kuralı ve özellik önce yalnız log ya da fark üretir; açma, kapama ve geri dönüş env ya da sunucu anahtarıyladır. Mobil uygulama uzaktan kontrol kiti kurulmadan yayınlanmaz.

**Neden** Gölgesiz açılan bir bot kuralı ilk gün bir e-posta link tarayıcısına 403 verdi.

### 10. Veri nerede duruyorsa öyle yazılır

Veri bölgesi, işleyen listesi ve aktarım dayanağı proje doğarken yazılır; yeni SDK bu liste, aydınlatma metni ve mağaza etiketleri güncellenmeden çıkmaz.

**Neden** Bildirilmeyen standart sözleşmenin 2026 cezası ₺90.308–1.806.177.
