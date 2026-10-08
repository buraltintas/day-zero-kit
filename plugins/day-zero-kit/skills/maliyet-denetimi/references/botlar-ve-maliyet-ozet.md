<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: rehber/Proje-Kurulum-Rehberi.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="cevaplar"></a>

Önce iki cevap

# Botlar ve maliyet

## Kimi engelleriz, kimi engellemeyiz

[aç] hiçbir kural dokunmaz[sınırla] hız kovasından düşer[izle] yalnız logda görünür[engelle] 403 ya da 404

| Alibaba Cloud ve benzeri bulutlardan gelen kazıyıcılar |
| Tarayıcı kılığında bulut kazıyıcısı | [engelle] | Bulutun bütün ağı (ASN) içerik sayfalarında 403 alır; API, oturum, form ve yasal sayfalar açık kalır. |
| Kimliği belirlenemeyen istekler |
| Boş, URL biçimli ya da kesik ajan | [engelle] | Accept-Language ve Sec-Fetch-Mode da göndermeyen içerik GET'i 403 alır; güvenlik firmaları muaf. |
| Sahte bot adı | [engelle] | Yayıncının adres aralığında olmayan bot adı önce gölgede yazılır, temiz bir dönemden sonra 403 alır. |
| Adresi okunamayan istek (0.0.0.0) | [sınırla] | Ağ kuralları göremez; ad kuralları ve tek ortak hız kovası uygulanır. |
| Konut proxy havuzu | [izle] | Engel Türk ev hatlarındaki gerçek kullanıcıyı da keser; önlem veriyi ucuza sunmaktır (ISR, kenar önbelleği). |
| AI botları |
| Cevap motorları ve kullanıcı adına getiriciler | [aç] | OAI-SearchBot, ChatGPT-User, PerplexityBot, Claude-User kaynak linki verir; aralıkla doğrulanınca hız sınırından muaf. |
| Eğitim tarayıcıları | [sınırla] | GPTBot, ClaudeBot, meta-externalagent: karar GEO hedefiyle robots.txt'ye yazılır, açık kalan saniyede 1 sayfa çeker. CCBot ve Bytespider varsayılan olarak engelli. |

**Hiç dokunulmayanlar:** doğrulanmış arama motorları, link önizleyiciler, e-posta güvenlik tarayıcıları, mobil uygulamanın API'si, oturum, form ve yasal sayfalar.

## ₺510–690 bizde gerçek mi?

Dört ürünün toplamı
~₺1.300/ay
Eylül'de ~₺3.900–4.400
**Yalnız günlük kullanıcılı ürün için.** Ürün A bugün ~₺610 tutuyor. Öteki üç ürün ₺5–510 arasında.

Yeni ve az trafikli bir ürünün bulut faturası ayda ~₺55–135 olur.

NeonGoogle CloudTL/ay, 8 Ekim 2026; alan adı ve mağaza (Apple, Google) ücretleri hariç
_Grafik: Ürün başına aylık maliyet_
