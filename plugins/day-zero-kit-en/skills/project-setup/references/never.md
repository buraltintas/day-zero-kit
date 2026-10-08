<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="asla"></a>

# Asla

Yeni projede gün 0'dan geçerli kurallar.

1

Yerel, test ya da CI varsayılanını asla prod yapma.

2

Veritabanı hatasında asla 401 dönme; başarısız işi 2xx ile yutma.

3

API'yi asla alan silerek ya da değiştirerek büyütme; yalnız ekle.

4

Canlı bir adresi asla kalıcı 308 olmadan değiştirme.

5

Neon'a bağlı serviste asla MinConns>0, soran ticker ya da veritabanına dokunan /health bulundurma.

6

Pooled bağlantıda asla oturum advisory lock, SET ya da LISTEN kullanma.

7

Ona dayanan kodu asla migration bitmeden yayına verme; migration hattın kendi adımında, bitmesi beklenerek ve yalnız ekleyerek koşar.

8

Prod'a asla test'te doğrulanmamış artefakt ve ürün sahibinin istemediği sürüm çıkarma.

9

Hiçbir runtime'ı Editor yetkili hesapla çalıştırma; JSON anahtarı diskte bırakma; sırrı düz env'e koyma.

10

Herkese açık test ortamına asla gerçek ücretli anahtar koyma. Ücretli anahtar ancak kimlik doğrulama arkasında ve sağlayıcıda sert tavanla.

11

Ücretli API'yi asla rakamı ve sert tavanı olmadan çağırma.

12

İlk mağaza sürümünü asla uzaktan kontrol kiti olmadan çıkarma: zorunlu güncelleme, duyuru alanı ve ekran içi uyarı, push, bayrak ve kill switch, bakım modu ve sürüm telemetrisi. OTA önerilir; OTA ve yerel build'i ortamı vermeden alma.

13

Zorunlu güncellemeyi asla Play'de yayın %100 olmadan ve App Store sürümü yayında değilken açma.

14

Cloudflare'de SEO hedefi varken asla 'Block' seçme; purge'süz HTML ya da Set-Cookie'li yanıtı önbelleğe alma.

15

Bot kuralını asla gölgeden geçirmeden zorlama; yeni sitede gün 0'da yalnız başka sitelerde gölgeden geçmiş ortak liste reddeder.

16

Geri yüklemeden sonra silmeleri uygulamadan asla trafiğe açma.

17

Yeni SDK'yı asla KVKK listesi ve mağaza etiketleri güncellenmeden çıkarma.
