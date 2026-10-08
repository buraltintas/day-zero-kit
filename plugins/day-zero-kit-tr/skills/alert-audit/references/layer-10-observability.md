<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="katmanlar-3"></a>

Katman 10 / 11

# Gözlem ve alarmlar

Alarmlar ilk kullanıcıdan önce kurulur ve her biri uçtan uca denenir.

192/gün
Alarmsız bir serviste 2 Eki'de tesadüfen bulunan günlük OOM sayısı.

## Yap

[öneri]
** İlk gün**: uptime, 5xx, açılışta veritabanı yok, Job/Scheduler hatası, yedek hatası, OOM, Cloud Build hatası, ERROR>0 (bugün seviyesi, geliştiriciye e-posta; süzgece NOT jsonPayload.message="alert" eklenir, yoksa notify()'ın kendi satırı her uyarıyı ikinci kez yollar; != yazılmaz, alanı olmayan çökme satırlarını da dışarıda bırakır), kritik uçlarda eşiksiz 5xx, dead-man's switch, 'db wake' sayısı, eski gönderilmemiş outbox satırı.
[kanıtlı]
** Her alarm '[TEST]' hatasıyla uçtan uca denenir**; durum Monitoring API'den okunur.
[öneri]
** Neon Free'de tüketim API'si yok**: uygulama her uyanışı 'db wake' satırıyla loglar, o satırdan log metriği ve alarm kurulur; Usage sayfası haftada bir okunur, 50 ve 80 CU-saatte uyarı. Gerçek kullanıcılı proje Free'de durmaz.
[öneri]
** Yenileme takvimi**: Apple Developer üyeliği (düşerse uygulama satıştan kalkar), alan adları, GCP, Neon, registrar, Expo ve Resend kartlarının son kullanma tarihi, APNs/FCM anahtarları, token'lar, krediler; 30 ve 7 gün önce hatırlatma.
[kanıtlı]
** Dış entegrasyon hataları ERROR üretir**; gözetimsiz kontroller bulutta çalışır.

## Başlangıç ayarları

[kanıtlı]
Uptime 300 sn, 3 bölge; 5xx servis başına 5 dk'da >3.
[öneri]
Ödeme ve mağaza webhook'larında başarılı teslim durursa ya da tek bir 5xx görülürse ayrı alarm.
[öneri]
Alarmlar bugün ücretsiz; ücret en erken 1 Eyl 2027'de, metrik referansı başına ayda $0,35. Uptime, billing ve kota metriğine bağlı alarm ücretsiz kalır. Proje başına 50 GiB log ücretsiz.

### Kaçın

[ölçüldü]
Alarmsız işletmek; severity'siz log; kaçağı ay sonu faturasında bulmak.

### Bizdekinden iyisi

[öneri]
Çökme telemetrisi için Sentry Developer $0, Team $26/ay; KVKK adımlarından sonra.

### Nereden öğrendik projelerimizden, 2026

**23 Eyl** alarm testi 16:57 → 17:01 → 17:11.
**2 Eki** alarmsız bir serviste tek günde 192 OOM bir maliyet analizinde tesadüfen bulundu.
**28 Ağu–27 Eyl** bir API kredisi bitince 30 paylaşım 402 aldı.
