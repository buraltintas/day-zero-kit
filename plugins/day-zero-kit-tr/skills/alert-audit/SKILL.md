---
name: alert-audit
description: >-
  Projede her dış bağımlılığın ve bütçenin hata sinyalinin doğru kişiye, doğru kanaldan, zamanında
  ulaşıp ulaşmadığını Proje Kurulum Rehberi'ne göre denetler; eksik alarmları, sahipsiz sinyalleri ve
  denenmemiş uyarıları çıkarır, notify() yönlendirmesini ve uçtan uca alarm testini kurdurur. Dış API
  hatası (401, 402, 429, 5xx), kredi ya da bakiye bitmesi, token süresi, kota, zamanlanmış işin
  çalışmaması, yedek doğrulaması, webhook hatası, "neden kimse fark etmedi", alarm, gözlem, Sentry ya
  da hata takibi konuşulduğunda kullan.
---

# Uyarı denetimi

Kimsenin görmediği uyarı uyarı değildir. Bizde arızaların çoğu sinyal verdi ama kimseye ulaşmadı: bir API kredisi bitti ve 30 gün fark edilmedi, ödeme webhook'u en az 21 gün hata döndü. Bu skill her sinyalin bir sahibi, bir eşiği ve bir kanalı olduğunu doğrular.

## Okunacaklar

- `references/alerts.md`: kaynaklar, seviyeler (acil, bugün, haftalık), "Ne, ne zaman, kime" tablosu, mesaj yazım kuralları, notify() ve log süzgeci, hazır servis mi kendi altyapımız mı.
- `references/layer-10-observability.md`, `references/backup-and-restore.md`, `references/analytics-and-admin.md`, `references/content-automation.md`.

## Akış

1. Envanter çıkar: her dış API, ödeme ve mağaza webhook'u, zamanlanmış iş, yedek, token, kota, bütçe ve alan adı ya da sertifika süresi.
2. Her biri için sor: hata sinyali ne, eşik ne, seviye ne, hangi kanal, kim ilgilenir, en az iki alıcı var mı, alarm kendisi bozulan sisteme mi bağlı.
3. Eksikleri tabloya yaz ve rehberdeki tabloyla tamamla.
4. Her alarmı bir kez sahte bir hatayla uçtan uca dene; alıcının gerçekten aldığını doğrula. Yokluk alarmlarında Cloud Monitoring'in en çok 23,5 saat beklediğini hesaba kat.
5. Mesajların ürün sahibinin dilinde olduğunu kontrol et: ne oldu, kullanıcıya etkisi, ne yapılmalı, bağlantı. Yığın izi ürün sahibine gitmez.

## Rapor biçimi

```
Sahipsiz sinyaller: <liste>
Eksik alarmlar: <sinyal | önerilen eşik | seviye | kanal | sahip>
Denenmemiş alarmlar: <liste>
Bu hafta kurulacaklar: <sıralı>
```
