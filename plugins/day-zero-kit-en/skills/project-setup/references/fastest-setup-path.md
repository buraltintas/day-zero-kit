<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="hizli"></a>

Önce bunu oku

# En hızlı kurulum yolu

Yığının en ucuz, en hızlı ve en güvenli hali bu sırayla kurulur.

## Gün 0: kod yazılmadan

1. Ürüne ayrı faturalama hesabı ve Neon org'u; üç eşikli bütçe alarmı, BigQuery fatura dökümü.

[Ücretsiz katmanlar](#ucretsiz)

2. Alan adı haftalar önce alınır ve kategori başvurusu yapılır; DNS ilk günden Cloudflare'de.

[Kenar ve DNS](#katman-5)

3. Özel depo, gitleaks, push protection, 1 MB ve ikili kapısı, ajan dosyası; test ve main dalı.

[Depo kuralları](#depo-kurallari)

4. Neon Frankfurt'ta: prod Launch (asgari ücret yok), test Free; havuz tabanı 0, boşta 90 sn.

[Postgres](#katman-1)

5. Servisler europe-west1'de min 0, istek bazlı faturalama, CPU boost açık; Next'e 1 GiB.

[Performans](#performans)

6. Tek Docker deposu, bölgesel tetikleyici, live ve prev KEEP'li temizlik; digest terfi eder.

[Artifact Registry](#registry)

7. Herkese açık okumalar API belleğinden, GCS işaretiyle tazelenir; sayfa başına bir API çağrısı.

[Mimari](#mimari)

8. Bot kapısı proxy'nin ilk satırında; gün 0'da yalnız ortak listenin kanıtlı kuralları reddeder.

[Botlar](#botlar)

9. Kod formunda Turnstile, mobil kod ucunda App Check, hazır yedek e-posta sağlayıcısı.

[E-posta](#katman-9)

10. Sırlar Secret Manager'da, her sırrın tek etkin sürümü; her servis en az yetkiyle.

[Güvenlik](#katman-8)

11. Veri yeri, işleyen listesi ve yurt dışı aktarım dayanağı yazılı.

[KVKK](#kvkk)

12. Ücretli dış API, alternatifleri ve en kötü günün faturası yazılmadan açılmaz.

[Pahalı dış API'ler](#pahali-api)

13. Mobilde uzaktan kontrol kiti ilk commit'te: sürüm başlıkları, politika ucu, zorunlu güncelleme, duyuru, push, bayrak; OTA önerilir.

[Mobil kit](#mobilkit)

## İlk kullanıcıdan önce

14. Web ve API'ye ayrı, veritabanısız sağlık ucu ve uptime kontrolü; alarmlar denenmiş.

[Gözlem](#katman-10)

15. Günlük döküm geri yüklenerek denetlenir, başarı satırı alarmlı; Neon geçmişi 7 gün.

[Yedek](#yedek)

16. Dökümden bir kez tam geri yükleme yapıldı; süresi runbook'ta.

[Yedek](#yedek)

17. E-posta sayacı UTC gününe göre: toplam 80'de toplu gönderim durur, kodlar 100'e kadar.

[E-posta](#katman-9)

18. API yalnız ekleyerek değişir; geçici hata kimseyi oturumdan atmaz; her yayın geri alınabilir.

[Kullanıcı kuralları](#kirmama)

19. Hedef p50 ve p90 yazılı; soğuk başlangıç, uyanış ve OOM haftada bir okunur.

[Performans](#performans)

20. Startup kredisine ayrı hesap ve Neon org'u açıldıktan sonra, ağır kullanımdan önce.

[Krediler](#krediler)

## İlk mağaza sürümünden önce

21. Kitin zorunlu parçaları ve yayın kapısı kanıtlı; OTA önerilir. Kit yoksa sürüm yok.

[Mobil kit](#mobilkit)

22. Play hesabı şirket adına açılır; kişisel açıldıysa 12 testçili 14 günlük kapalı test ilk sürümden en az 3 hafta önce başlar.

[Expo](#katman-4)

23. Zorunlu ekran önceki mağaza build'inde, gerçek telefonda, önizleme listesiyle görüldü.

[Mobil kit](#mobilkit)

24. Build bütçesi: platform başına ayda 15 hak, preview yerelde, ay sonuna 2–3 acil hak.

[Mobil dağıtım](#dagitim)

Sağdaki ad o adımın kurallarının durduğu bölümdür ve bağlantıdır.
