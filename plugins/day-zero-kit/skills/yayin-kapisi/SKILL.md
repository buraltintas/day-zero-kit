---
name: yayin-kapisi
description: Mobil mağaza sürümünden, prod deploy'dan ya da kullanıcıyı etkileyen bir değişiklikten önce Proje Kurulum Rehberi'nin yayın kapısını çalıştırır ve "çıkar / çıkmaz" kararı için kanıtlı bir liste verir. Sürüm çıkacağımız, build alacağımız, mağazaya göndereceğimiz, main'e alacağımız, migration yapacağımız, zorunlu güncellemeyi açacağımız ya da "bu değişiklik kullanıcıyı bozar mı" diye sorulduğu her durumda kullan.
---

# Yayın kapısı

Yayın kararı ürün sahibinindir. Bu skill kararı kanıtla besler: neyin hazır olduğunu, neyin eksik olduğunu ve eksik bir şeyle çıkılırsa kullanıcının ne yaşayacağını söyler. Build, submit, deploy ya da sürüm numarası değiştirmez.

## Hangi liste

- **Mobil mağaza sürümü:** `references/mobil-kit.md` içindeki yayın kapısı ve `references/mobil-dagitim.md` içindeki kontrol listesi.
- **Prod deploy:** `references/katmanlar-5-9-ve-botlar.md` içindeki CI/CD ve ortamlar bölümü, `references/kontrol-listesi.md`.
- **Kullanıcıyı etkileyen her değişiklik:** `references/kullaniciyi-kirmadan-degistirmek.md` (API yalnız ekleyerek değişir, eski sürümler, geri dönüş yolu, açılış zamanı).

## Akış

1. Değişikliği sınıflandır: yalnız JS mi, native mi, API sözleşmesi değişiyor mu, migration var mı, kim etkileniyor.
2. İlgili listeyi madde madde işaretle. Her madde için kanıtı yaz: komut çıktısı, log satırı, ekran görüntüsü, test sonucu. Kanıtı olmayan madde yapılmamış sayılır.
3. Mobil sürümde build hakkını say: `eas account:usage` ile platform başına kalan hak. Ayın son haftasında kalan hak 3'ün altındaysa yeni özellik build'i alınmaz; hak hata düzeltmesine saklanır.
4. Eski sürümdeki kullanıcıyı düşün: yeni akış eski build'e ne gösterecek, sunucudan duyuruyla anlatılabiliyor mu, zorunlu güncelleme açılacaksa mağazada yeni sürüm herkese açık mı.
5. Geri dönüş yolunu yaz: hangi revizyona, hangi komutla, veri geri dönüyor mu.

## Sonuç biçimi

```
Karar önerisi: ÇIKAR / ÇIKMAZ / KOŞULLU
Eksikler: <madde, etkisi, düzeltmenin süresi>
Kanıtlar: <madde: kanıt>
Geri dönüş: <yol>
Sahibin onayı gerekenler: <liste>
```

## Dikkat

- Zorunlu güncellemeyi, Play'de yayın %100 olmadan ve App Store sürümü yayında değilken açmayı önerme.
- Zorunlu ekranın önceki mağaza build'inde gerçek telefonda görüldüğünden emin ol.
- Yayını hafta içi mesai başında öner; cuma akşamı ve tatil öncesi önerme.
