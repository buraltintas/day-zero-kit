# docs/ACCOUNTS.md: parola, kurtarma kodu ve anahtar buraya yazılmaz
Son doğrulama: 2026-10-08. Hiçbir hesap henüz açılmadı.
Hesabı ürün sahibi açar, şartı o kabul eder, ödeme
yöntemini o girer; ajan yalnız bu envanteri tutar.
Yenileme tarihleri docs/ALERTS.md'deki yenileme tablosunda.

Sahip ve yönetici sütunu K-002'ye bağlı (KARAR BEKLİYOR).
Rehberin önerisi: şirket adına, ürünün alan adındaki bir
rol adresiyle, her hesapta iki yönetici.

Sağlayıcı              | sahip      | yönetici | faturalama                      | yenileme
Google Cloud           | K-002      | K-002    | ürünün kendi hesabı (K-003)     | kart <MM/YY>
Firebase (App Check,   | K-002      | K-002    | Google Cloud projesiyle aynı    | yok
  FCM)                 |            |          |                                 |
Neon prod org'u        | K-002      | K-002    | Launch (K-005), ürünün org'u    | kart <MM/YY>
Neon test org'u        | K-002      | K-002    | Free (K-005)                    | yok
Alan adı (kayıt firm.) | K-002      | K-002    | çok yıllık, kilitli             | <YYYY-MM-DD>
Cloudflare             | K-002      | K-002    | Free (DNS, Turnstile)           | yok
E-posta (Resend)       | K-002      | K-002    | Free (K-015)                    | yok
Amazon SES (yedek)     | K-002      | K-002    | kullandıkça (K-015)             | kart <MM/YY>
GitHub                 | K-002 org  | K-002    | Free                            | yok
Expo (EAS)             | K-002      | K-002    | Free (K-013)                    | yok
Apple Developer        | K-002      | K-002    | yıllık üyelik                   | <YYYY-MM-DD>
Google Play            | K-002      | K-002    | tek seferlik kayıt              | yok

## Hesap kutuları (her kutuyu ürün sahibi kendi ekranında işaretler)
- [ ] Şirket adına. Her hesap şirket adına ve ürünün alan
  adındaki bir rol adresiyle; kişisel adresler yalnız
  yönetici. Mobil var (K-006): Apple ve Play kuruluş
  hesabı D-U-N-S ister; başvuru gün 0'da (Gün 0 önlemi 20).
- [ ] En az iki yönetici: bulut, Neon, DNS, alan adı,
  GitHub, mağazalar, e-posta.
- [ ] Donanım anahtarı ya da passkey: kök hesaplarda
  (Google, kayıt firması, GitHub, Apple, e-posta kutusu),
  yedek anahtarla. Kişi başı iki anahtar (önlem 1).
- [ ] SMS ile kurtarma kapalı; kurtarma anahtar ya da kodla.
- [ ] Kurtarma kodları çevrimdışı, ayrı iki yerde; depoya,
  sohbete ve e-postaya yazılmaz.
- [ ] Alan adı kilitli: transfer kilidi, çok yıllık ve
  otomatik yenileme, kayıt firmasında iki adımlı doğrulama.
- [ ] Google Cloud projeleri ücretsiz Cloud Identity ile
  açılan şirket organizasyonuna bağlı, iki süper yönetici;
  Essential Contacts ortak adreste (önlem 1).
- [ ] Apple'da Account Holder tek kişi, ikinci kişi Admin;
  GitHub'da organizasyon ve iki owner (önlem 1).
- [ ] Kartlar ve üyelikler takvimde: 30 ve 7 gün önce
  hatırlatma (docs/ALERTS.md).
- [ ] Ajan hesap açmaz; ajan parola ve kurtarma kodu görmez.
