---
name: seo-geo-rutini
description: Projenin SEO ve GEO (yapay zekâ cevap motorlarında görünme) işlerini Proje Kurulum Rehberi'ne göre kurar ve düzenli olarak yürütür; gün 0 teknik listesi, Search Console ölçümü, AI trafiğini doğru sayma ve hiç bitmeyen haftalık ve aylık işler. Önce SEO yüzeyinin veritabanını uyandırmadığını doğrular. SEO, GEO, Search Console, dizine eklenme, sitemap, robots.txt, canonical, yapısal veri, llms.txt, ChatGPT ya da Perplexity'de görünmek, organik trafik veya "neden tık gelmiyor" konuşulduğunda kullan.
---

# SEO ve GEO rutini

İlk ders: SEO botları çağırır, botlar veritabanını uyandırır. Botun gelebileceği her yol (sayfa, site haritası, llms.txt, paylaşım görseli) bellekten ya da ISR'dan sunulur ve veritabanına hiç gitmez. Yeni bir SEO yüzeyi açılınca 48 saat uyanma sayısı izlenir.

## Okunacaklar

- `references/seo-ve-geo.md`: ne yaptık, ne çıktı, kurallar (gün 0 teknik, GEO, ölçüm), hiç bitmeyen işler, daha iyi ne yapılabilir, gün 0 listesi.
- `references/katmanlar-1-4.md` (Next.js web katmanı: sunucuda tam HTML, ISR, değişiklik işareti), `references/katmanlar-5-9-ve-botlar.md` (botlara karşı tutum), `references/performans.md`.

## Akış

1. **Gün 0 (bir kez):** gün 0 listesini uygula: sunucuda tam HTML, tek host ve 308 yönlendirmeler, sitemap, robots.txt, canonical, yapısal veri, Search Console ve Bing kaydı, başlangıç ölçümü.
2. **Haftalık:** Search Console kapsam ve sorgu raporu, dizinden düşen sayfalar, canonical uyarıları, veritabanı uyanma sayısı.
3. **Aylık:** cevap motorlarında örnek sorgularla atıf kontrolü, tarihli veri sayfalarının tazelenmesi, tarayıcı adres listelerinin yenilenmesi, dış bağlantı işi.
4. **AI trafiğini doğru say:** önce prefetch ve botları ayır, sonra gerçek tıklamayı say. İlk kaba sayım yanıltır.

## Rapor biçimi

```
Bu hafta: dizinde <n> sayfa, <n> tık, <n> gösterim; değişim: ...
Sorunlar: <sayfa | sorun | düzeltme>
Veritabanı: SEO yüzeyinden kaynaklanan uyanış <n>
Sıradaki iş: ...
```
