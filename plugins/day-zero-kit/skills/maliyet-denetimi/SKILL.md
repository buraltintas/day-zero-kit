---
name: maliyet-denetimi
description: >-
  Projenin bulut, veritabanı ve dış API maliyetini Proje Kurulum Rehberi'ndeki ölçülmüş kurallara göre
  denetler; uyanmayan veritabanı, instance tavanları, harcama freni, bütçe alarmları, ücretsiz
  kotalar, build dakikaları, log ve imaj depolama için somut düzeltme listesi çıkarır. Fatura
  yükseldiğinde, aylık kontrolde, "maliyetimiz ne", "neden bu kadar tuttu", Neon CU-saat, Cloud Run
  faturası, bütçe, kota ya da "ücretsiz katmanda kalabilir miyiz" sorulduğunda kullan.
---

# Maliyet denetimi

Faturayı büyüten şey çoğu zaman görünmeyen tekrardır: veritabanı uyanışı, build, bot isteği, açık kalan bağlantı. Bu skill bunları ölçer ve rehberdeki kurallarla karşılaştırır. Ayarları kendisi değiştirmez; değişiklik listesini ve etkisini çıkarır, uygulama kararını sahibine bırakır.

## Okunacaklar

- `references/botlar-ve-maliyet-ozet.md` ve `references/maliyet.md`: ne tutar, kalem kalem model.
- `references/katmanlar-1-4.md`: Postgres ayarları (havuz tabanı 0, 90 sn boşta kapanma, uyanma bütçesi).
- `references/ucretsiz-katmanlar.md`: her servisin sınırı, aşınca ne olduğu, izleme.
- `references/performans.md`, `references/artifact-registry-ve-build.md`, `references/pahali-dis-apiler.md`.
- `references/vaka-defteri.md`: maliyet vakaları ve neyin ne kadar kazandırdığı.

## Akış

1. Rakamları oku (salt okunur; her komutta proje açıkça verilir): son 30 günün fatura kırılımı, Neon günlük CU-saat ve uyanma sayısı, Cloud Run instance zirvesi ve max-instances değeri, build dakikası, log hacmi, imaj deposu boyutu, dış API çağrı sayısı.
2. Her kalemi rehberdeki hedefle karşılaştır. Örnekler: veritabanı günde birkaç uyanışın üstündeyse uyandıranı bul (zamanlayıcı, bot yolu, herkese açık okuma); max-instances 30 günlük zirvenin çok üstündeyse tavanı indir; harcama freni ve üç eşikli bütçe alarmı yoksa ekle.
3. Her düzeltme için aylık etkisini hesapla ve kanıtını yaz. Varsayılan kur: rehberdeki gibi, ama o günün kurunu yeniden oku.
4. Bir düzeltme kullanıcıyı etkileyebilecekse (tavanı çok indirmek, ücretsiz katmanda kota dolunca durma) riskini açıkça yaz.

## Rapor biçimi

```
Bu ay: ~<tutar>; hedef: ~<tutar>
Düzeltmeler (etkisine göre sıralı):
1. <ne> | ~<aylık kazanç> | risk: <...> | kanıt: <...>
Alarm ve tavan durumu: <var/yok listesi>
Sahibin kararı gerekenler: <liste>
```
