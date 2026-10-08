---
name: decision-support
description: >-
  Projede bir teknik ya da ürün kararı gündeme geldiğinde Proje Kurulum Rehberi'ndeki tecrübeye ve
  ölçülmüş rakamlara dayanarak seçenekleri, varsayılanı, maliyeti ve riski çıkarır, kararı
  DECISIONS.md'ye yazar. Ücretli API açmak (harita, model, SMS, e-posta), plan yükseltmek, analitik ya
  da hata takip aracı seçmek, gerçek zamanlı iletişim (WebSocket, SSE, polling, push), OTA, bölge ve
  veri yeri, EAS ya da kendi build hattı, içerik otomasyonu, startup kredisi gibi her "şunu mu
  yapalım, bunu mu" sorusunda kullan.
---

# Karar desteği

Kararı sahibi verir; bu skill kararı kolaylaştırır. Görevin, sorulan konuyu rehberdeki karar listesiyle ve ilgili bölümle eşleştirmek, seçenekleri gerçek rakamlarla yan yana koymak ve verilen kararı kayda geçirmektir.

## Akış

1. Soruyu tek cümleyle yeniden yaz: ne karar veriliyor, neden şimdi.
2. `references/decisions-and-setup-plan.md`'deki karar listesinde karşılığını bul. Yoksa en yakın bölümü bul: maliyet için `cost.md`, `free-tiers.md`, `expensive-external-apis.md`; mimari için `principles.md`, `architecture.md`; mesajlaşma için `realtime-and-messaging.md`; analitik ve admin için `analytics-and-admin.md`; mobil dağıtım için `mobile-distribution.md`; sosyal paylaşım için `content-automation.md`; krediler için `startup-credits.md`.
3. `case-book.md`'de aynı konuda yaşanmış bir vaka var mı bak. Varsa onu öne koy: tecrübe, belgeden önce gelir.
4. Seçenekleri karşılaştır: ne verir, aylık ve en kötü günün maliyeti, kota ve tavan, saklama ve veri yeri şartları, çıkış yolu, bizdeki kanıt düzeyi.
5. Rehberin varsayılanını ve gerekçesini söyle. Varsayılan bu ürüne uymuyorsa nedenini açıkça yaz.
6. Fiyatları ve şartları kaynaklardaki resmi sayfadan o gün yeniden doğrula. Doğrulayamadığını "doğrulanamadı" diye işaretle.
7. Sahip karar verince `docs/DECISIONS.md`'ye kaydet.

## Karar kaydı biçimi

```
## K-<numara> <karar başlığı> (<tarih>)
Karar: ...
Neden: ...
Seçenekler: ... (neden seçilmedi)
Maliyet: günde ~..., ayda ~..., en kötü gün ~...
Tavan ve alarm: ...
Yeniden bakılacak: <tarih ya da koşul>
Kaynak: <rehber bölümü, resmi sayfa>
```

## Dikkat

- Ücretli bir şey önermeden önce günlük ve aylık rakamı söyle; tavan ve alarm yazılmadan açılmasını önerme.
- Mimariyi krediye göre seçme; kredi biter, mimari kalır.
- Belirsizi kesin gibi yazma. Kanıt etiketi koru: bizde çalışıyorsa kanıtlı, ölçtüysek ölçüldü, değilse öneri.
