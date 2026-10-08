---
name: proje-hafizasi
description: >-
  Projenin hafıza dosyalarını (AGENTS.md, CHANGELOG.md, docs/STATUS.md, docs/TODO.md,
  docs/DECISIONS.md, DESIGN.md, devir notu) Proje Kurulum Rehberi'ndeki şablonlara göre açar,
  günceller ve tazelik kontrolünü yapar; yeni gelen geliştirici ya da yapay zekâ ajanı projeye hızla
  alışıp devam edebilsin. Oturum ya da iş bitince, "ne oldu ne bitti", "sırada ne var", changelog yaz,
  devir notu hazırla, yeni geliştirici başlıyor, tasarım kararı kaydet ya da dokümanlar eskidi
  dendiğinde kullan.
---

# Proje hafızası

Kodun ne yaptığını kod söyler; neden öyle olduğunu, şu an ne durumda olduğunu ve sırada ne olduğunu yalnız hafıza dosyaları söyler. Bu skill bu dosyaları doğru ve güncel tutar.

## Dosyalar ve sordukları

| Dosya | Cevapladığı soru |
|---|---|
| `AGENTS.md` (CLAUDE.md yalnız `@AGENTS.md`) | Nasıl çalışılır: ürün, komutlar, dallar, deploy kuralı, asla listesi |
| `CHANGELOG.md` | Ne oldu: kullanıcıya görünen değişiklik önce, tarihli, commit bağlantılı |
| `docs/STATUS.md` | Şu an ne durumda: canlıda ne var, ne sürüyor, ne bekliyor |
| `docs/TODO.md` | Sırada ne var: sahip, öncelik, bitince CHANGELOG'a taşınır |
| `docs/DECISIONS.md` | Neden böyle: tarih, karar, gerekçe, seçenekler, yeniden bakma tarihi |
| `DESIGN.md` | Tasarım kuralları ve kararları; arayüz işinden önce okunur |
| Devir notu | Biten, bitmeyen, sıradaki adım, riskler |

Şablonlar `references/proje-hafizasi.md`'de, tasarım kararları `references/tasarim-sistemi.md`'de.

## Akış

- **İş bitince:** CHANGELOG'a aynı commit'te yaz; STATUS'u güncelle; biten TODO maddesini kaldır; verilen kararları DECISIONS'a ekle.
- **Oturum bitince:** devir notu yaz. Uzun işleri geçici klasörde (/tmp gibi) bırakma; kalıcı klasöre ve dala commit'le.
- **Yeni gelen için:** önce AGENTS.md, sonra STATUS, TODO, DECISIONS; son 2 haftalık CHANGELOG.
- **Tazelik kontrolü (ayda bir):** AGENTS.md'deki komutları çalıştır; ölmüş yol ve eski kural var mı bak; CHANGELOG 40 KB'ı geçtiyse eskiyi arşive taşı; "Unreleased" başlığı kapanmış mı bak.

## Dikkat

- Sırların değerini hiçbir dosyaya yazma; yalnız nerede durduğunu yaz.
- Bir oturum bir depo ve dalın sahibidir; başka oturuma kendiliğinden iş gönderme.
- Yazılı kural yetmiyorsa (atlanan test, unutulan CHANGELOG) hook ya da dal korumasıyla zorla.
