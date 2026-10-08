---
name: security-audit
description: >-
  Projenin güvenlik ve bot korumasını Proje Kurulum Rehberi'ne göre denetler; en az yetki ve servis
  hesapları, sırlar, bağımlılık ve tedarik zinciri, yetki kontrolleri (başkasının kaydını okuma), bot
  kapısı ve tarayıcı listeleri, KVKK ve gün 0 önlemleri için bulgu ve düzeltme listesi çıkarır.
  Güvenlik incelemesi, yetki, IAM, secret, "biri verimizi kazıyor", bot, kazıyıcı, Alibaba, AI
  tarayıcıları, robots.txt, KVKK, veri ihlali ya da yayından önce güvenlik kontrolü istendiğinde
  kullan.
---

# Güvenlik denetimi

Amaç açıkları bulmak ve kapatma sırasını vermektir. Açık bir zayıflığı herkese açık bir yere (issue, PR açıklaması, paylaşılan belge) ayrıntısıyla yazma; bulguyu sahibine ilet.

## Okunacaklar

- `references/layers-5-9-and-bots.md`: kenar ve DNS, Cloud Run, CI/CD, güvenlik ve botlar katmanı, botlara karşı tutum ve kapının iskeleti.
- `references/day-zero-precautions.md`: henüz yaşanmamış ama gün 0'da önlenmesi gereken riskler.
- `references/kvkk.md`, `references/repos-and-sizes.md` (yeni depo kuralları), `references/never.md`, `references/case-book.md`.

## Akış

1. **Kimlik ve yetki:** her servis kendi rolsüz hesabıyla mı çalışıyor; varsayılan Editor'lü hesap kullanılıyor mu; build hesabı ayrı mı; insanlarda iki adımlı doğrulama ve en az iki yönetici var mı.
2. **Sırlar:** depoda, düz ortam değişkeninde, logda, hata metninde, adres satırında sır var mı; her sırrın tek etkin sürümü ve döndürme sırası yazılı mı.
3. **Uygulama yetkisi:** her okuma ve yazma, sahibi sunucuda oturumdan kontrol ederek mi yapılıyor; iki hesapla birbirinin kaydını okumayı dene.
4. **Bağımlılıklar:** kurulum betikleri, yayın yaşı kuralı, kilit dosyası ve CI'da yalnız `npm ci`; çerçeve sürümünde bilinen açık var mı.
5. **Botlar:** kapı proxy'nin ilk satırında mı; robots.txt ve kapı aynı listeden mi üretiliyor; yeni kural önce gölgede mi çalıştı; tarayıcı adres listeleri aylık yenileniyor mu; herkese açık okumalar veritabanını uyandırıyor mu.
6. **KVKK:** veri yeri, işleyen listesi, aktarım dayanağı ve ihlalde "kim neyi gördü" kaydı.

## Rapor biçimi

```
Kritik (bugün): <bulgu | etkisi | düzeltme>
Yüksek (bu hafta): ...
Orta: ...
Sahibin yapması gerekenler: <IAM, hesap, ödeme gibi>
```

Yeni bir bot kuralını doğrudan reddeden olarak açma; önce gölgede çalıştır ve en az 7 günlük logla karar ver.
