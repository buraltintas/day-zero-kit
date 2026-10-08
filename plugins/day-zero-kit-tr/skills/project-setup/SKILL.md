---
name: project-setup
description: >-
  Yeni bir ürünün altyapısını gün 0'dan Proje Kurulum Rehberi'ne göre baştan sona kurar; önce sahibine
  verilmesi gereken kararları sorar, sonra kurulum planını aşama aşama uygular ve her aşamayı
  doğrular. Yeni proje, yeni ürün, sıfırdan kurulum, "altyapıyı hazırla", "projeye başlıyoruz", yeni
  bir ürün için Neon + Go + Next.js + Expo yığını, gün 0 ya da "nereden başlayalım" geçtiğinde,
  kullanıcı rehberin adını söylemese bile bu skill'i kullan. Var olan bir projede tek bir ayar ya da
  servis için kullanma; onun için denetim skill'leri var.
---

# Proje kurulumu (gün 0)

Bu skill ürünün kodunu yazmaz; kodun etrafını kurar: hesaplar, ortamlar, veritabanı, servisler, CI/CD, bot kapısı, uyarılar, yedek, analitik ve admin, mobil uzaktan kontrol kiti ve proje hafızası. Amaç, ekibin ilk günden yalnız ürün akışlarına bakabilmesidir. Kurallar canlı ürünlerin faturalarından, loglarından ve olaylarından çıktı; her kural bir kanıt etiketi taşır: kanıtlı, ölçüldü ya da öneri. Öneri "isteğe bağlı" demek değildir; "bizde denenmedi" demektir.

## Önce oku

1. `references/how-to-use.md`: rehberin nasıl kullanıldığı, kimin ne yaptığı.
2. `references/decisions-and-setup-plan.md`: karar listesi, "Gün 0: hesaplar ve sürümler", ajanın kurulum planı ve "Bitti sayılır".
3. `references/project-memory.md`: gün 0'da açılacak dosyaların şablonları.
4. Kısa yol ve kontroller için `references/fastest-setup-path.md`, `references/checklist.md`, `references/never.md`; henüz yaşanmamış riskler için `references/day-zero-precautions.md`.
5. Gerekince `references/full-guide.md` (tam rehber, büyük; bölüm başlığıyla ara, baştan sona okuma).

## Akış

1. **Kararları sor.** Karar listesindeki her kararı sırayla, tek tek sor. Sahibin tercihi yoksa rehberin varsayılanını gerekçesiyle öner ve onay bekle. Cevapları `docs/DECISIONS.md`'ye tarih ve gerekçeyle yaz. Ürünün kısa tanımını `AGENTS.md`'ye yaz; `CLAUDE.md` yalnız `@AGENTS.md` satırını taşır.
2. **Hafıza dosyalarını aç.** `AGENTS.md`, `CHANGELOG.md`, `docs/STATUS.md`, `docs/TODO.md`, `docs/DECISIONS.md` ilk commit'te açılır ve her işle güncellenir. Şablonlar `project-memory.md`'de.
3. **Planı aşama aşama uygula.** Sıra: Gün 0 (kod yazılmadan), İlk kullanıcıdan önce, İlk mağaza sürümünden önce, Sonra. Her adımda üret, sonra adımın doğrulamasını çalıştır. Sonucu `docs/STATUS.md`'ye ve `CHANGELOG.md`'ye yaz.
4. **DUR yazan yerde dur.** Planda DUR işaretli adımda ne yapılması gerektiğini sahibine tek satırla söyle ve bekle.
5. **Bitince** "Bitti sayılır" listesini tek tek işaretle; işaretlenemeyen her maddeyi `docs/TODO.md`'ye yaz.

## Yalnız ürün sahibinin yaptıkları

Bunlara gelince dur ve sor; asla kendin yapma: hesap açmak, ödeme ve kart, şart ya da sözleşme kabulü, alan adı kaydı ve kayıt şirketi işleri, mağaza hesapları, prod deploy onayı, mobil build ve mağazaya gönderim, sürüm numarası, gerçek kullanıcılara mesaj göndermek, bir şeyi herkese açmak, IAM'de rol vermek. Sahibin yerine onay vermek ya da bir izni dolanmak yasaktır.

## Uyulacak sabit kurallar

- En güncel kararlı sürümlerle başla; desteğinin bitmesine 6 aydan az kalmış sürümle başlama. Sürümleri resmi sayfalardan o gün yeniden oku; rehberdeki tablo Ekim 2026'nın fotoğrafıdır.
- Fiyat ve kotaları kullanmadan önce kaynaklardaki resmi sayfadan yeniden doğrula.
- Mobil uygulama, zorunlu güncelleme, sunucudan duyuru ve ekran içi uyarı, bayrak ve kill switch kurulmadan mağazaya çıkmaz. OTA önerilir ama bu kuralın parçası değildir.
- Botların gezdiği herkese açık sayfa ve listeler (katalog, detay, site haritası) veritabanına gitmez: bellekten ya da ISR'dan sunulur, değişiklik işaretiyle tazelenir. Arama, filtre ve sık değişen içerik gibi önbelleğe sığmayan okumalar veritabanına gidebilir; o zaman bot erişimi sınırlanır ve veritabanı uyanışı ölçülür.
- Test ortamı ve test verisi canlıya asla dokunmaz; yerel varsayılan her zaman test ortamıdır.
- Ücretli bir dış API, alternatifleri ve en kötü günün faturası yazılmadan açılmaz.
- Bir istek rehberle çelişiyorsa önce çelişkiyi söyle, sonra sahibin kararını uygula ve `DECISIONS.md`'ye yaz.

## Rapor biçimi

Her aşamanın sonunda kısa bir rapor ver: yapılanlar, doğrulama sonuçları, DUR bekleyenler ve bir sonraki adım. Uzun anlatma; ayrıntı `docs/STATUS.md`'de dursun.
