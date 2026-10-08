<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber: guide/project-setup-guide.md. Bağlantılar (#...) tam rehberdeki bölümlere gider. -->

<a id="registry"></a>

Artifact Registry ve Cloud Build

# Artifact Registry ve build kuralları

İmajlar nerede durur, ne kadar kalır, build ne kadar sürer ve neye para gider. 8 Ekim 2026'da dört projede salt okunur yapılan denetimden.

Dört projede 5 Docker deposu var; toplam 6,9 GB ve 94 imaj tutuyorlar. Temizlik kuralları hepsinde gerçekten çalışıyor, dry-run'da değil. Artifact Registry'nin imaj başına ücretli taraması hiçbir depoda açık değil, bütün tetikleyiciler global bölgede. Bugün kalıcı bir para kaçağı yok: Artifact Registry depolaması ayda ~$0,60 tutuyor. Asıl açık geri dönüş penceresi: dört serviste iki günden kısa.

**6,9 GB** 5 Docker deposunda 94 imaj. Depolama ayda ~$0,60; ilk 0,5 GB ücretsiz.
**3.751 dk** Son 30 günde 807 başarılı build. Ücretsiz kota faturalama hesabı başına ayda 2.500 dk.
**0,9–16,5 gün** Bugünkü geri dönüş penceresi, servise göre. Önerilen kuralla 30 gün.
**~5 kat** Buildpacks ile kurulan Next imajı Dockerfile'lı Next imajından büyük: 420–456 MB ve 77–92 MB.
**%51** Ürün A'nın Ekim build dakikalarında test tetikleyicilerinin payı.
**~$210/ay** Zafiyet taraması build depolarında açık olsaydı tutacak rakam: itilen her digest $0,26.

## Depolar ve temizlik

| Proje | Bölge | GB | Paket | İmaj | Not |
|---|---|---|---|---|---|
| Ürün A | europe-west1 | 1,93 | 11 | 45 | Test ve prod imajları ayrı paketlerde; tarayıcı servisi ve yedek job'ı da burada. |
| Ürün B | europe-west1 | 3,50 | 3 | 22 | Boyutun çoğu buildpacks ile kurulan 456 MB'lık UI imajı. |
| Ürün B | europe-west3 | 0,05 | 1 | 3 | 17–18 Ağustos'tan kalma API imajları; hiçbir servis ya da job kullanmıyor. |
| Ürün C | europe-west1 | 0,44 | 3 | 15 |  |
| Ürün D | europe-west1 | 1,01 | 2 | 9 | UI imajı buildpacks ile 420 MB. |
| Toplam |  | 6,92 | 20 | 94 | Depolama ayda ~$0,60. |

Beş depo da standart modda, Google anahtarlı ve değiştirilemez etiket kapalı. Adları Cloud Run'ın varsayılanı: cloud-run-source-deploy. Temizlik kuralı beşinde aynı ve canlı: paket başına en yeni 5 sürümü TUT, etiketli ya da etiketsiz 1 günden eski her şeyi SİL. Cloud Build her imaja iki küçük köken (SLSA provenance) eki ekliyor; listede build başına 3 sürüm görünüyor, ama ölçtük: ekler 'en yeni 5' sayısına girmiyor; her pakette en yeni 5 imaj ve son 24 saatte itilenler kalıyor.

## İmaj boyutunu build biçimi belirliyor

Artifact Registry'deki sıkıştırılmış boyut, son prod imajları. Koyu kısım en küçük, açık kısım en büyük imaj.

_Grafik: Build biçimine göre imaj boyutu_
Dil değil build biçimi belirliyor: aynı tür Next uygulaması Dockerfile ve output standalone ile 77–92 MB, buildpacks ile 420–456 MB. Ürün A API 30,6 MB, çünkü içinde üç ikili var.

## Geri dönüş penceresi bugün

AR'de imajı hâlâ duran en eski prod revizyonunun yaşı, 8 Ekim 2026.

_Grafik: Servise göre geri dönüş penceresi_
Cloud Run imajın kopyasını yalnız trafik alan revizyon için saklıyor. Canlı revizyon AR'deki silmeden etkilenmez ve yeni instance AR'den çekmez; ama trafik almayan eski bir revizyona dönmek için imajın AR'de durması gerekir. Pencere deploy hızına bağlı: sık deploy eden bir üründe son 24 saatte 9 deploy oldu, pencere 0,9 gün ama 8 deploy geri gidilebiliyor. Yeni projede bu pencereyi live ve prev etiketleri kapatır ([kural 3](#ar-kural-3)).

## İmajlar nasıl üretiliyor

| Biçim | Kim kullanıyor | İmaj |
|---|---|---|
| Dockerfile ve docker build | Ürün A'nın dört servisi, tarayıcı servisi ve yedek job'ı; Ürün B API ve migrate; Ürün C'nin üç servisi; Ürün D API. | 4–120 MB; tarayıcı 725 MB |
| Buildpacks (pack --publish) | İki ürünün UI'ı: biri değişen builder:latest ile, öteki Şubat 2026 tarihli bir RC builder'a sabit. | 420–456 MB |
| gcloud run deploy --source | Bir kez kullanıldı; Ürün A'da 9 Eylül'den kalan bir imaj. | 18 MB |

Tetikleyiciler: Ürün A'da 8 tane (4 depo, main ve test). API ve portalın main tetikleyicileri Cloud Run'ın kendi kurduğu satır içi tetikleyiciler (--no-cache, push, services update); kalanlar depodaki cloudbuild*.yaml dosyasını okuyor. Ürün C'de 3, Ürün B'de 2, Ürün D'de 2 tetikleyici var, hepsi satır içi. On beşi de global bölgede ve varsayılan havuzda. Elle yapılan gcloud builds submit --region europe-west1 build'leri bölgesel; Ürün A'da Eylül'de 82 tane oldu.

Etiketler karışık: tetikleyiciler tam commit SHA'sı, yaml dosyaları kısa SHA kullanıyor; bazı paketler ayrıca latest basıyor ve bir paketin latest'i 9 Eylül'deki bir imajı gösteriyor. Deploy etiketle yapılıyor, Cloud Run onu digest'e çeviriyor.

Test ve prod aynı commit'i ayrı ayrı build ediyor ve farklı digest alıyor: bir API commit'i 7 Ekim'de 12:25'te test imajını, 13:54'te prod imajını aldı. Web, pazar yeri ve portal da böyle. Prod'da testte denenen baytlar çalışmıyor ve build dakikası ikiye katlanıyor.

## Build dakikaları

| Proje | Başarılı build, 30 gün | Dakika, 30 gün | Medyan süre |
|---|---|---|---|
| Ürün A | 388 | 1.707 | 3,4–4,5 dk |
| Ürün B | 349 | 1.729 | UI 4,7, API 5,6 dk |
| Ürün C | 64 | 288 | 3,6–5,3 dk |
| Ürün D | 6 | 27 | – |
| Toplam | 807 | 3.751 | – |

Eylül'de iki ürünün ortak faturalama hesabı 3.121 dakikayla 2.500 dakikalık ücretsiz kotayı 621 dakika aştı ve faturaya ₺187 yazıldı; öteki iki ürünün hesabı 84 dakikada kaldı.

Ortalama süre: Go API 3,5–5,7 dk, bunun 141–275 sn'si önbelleksiz docker build. Next 4,1–5,3 dk, Vite portal 2,1–3,4 dk, buildpack UI 4,1–4,7 dk. En çok build alan tek servis Ürün B UI: 30 günde 198 build.

## Bugünkü kurallarımız

Dört proje
Tek AR deposu (cloud-run-source-deploy), europe-west1. 'En yeni 5'i tut, 1 günden eskiyi sil.' Tarama kapalı, tetikleyici global.

Ürün A
main prod'a, test test ortamına deploy eder; main'e yalnız test'ten geçen commit gider. Test ve prod ayrı paketlerde, çünkü NEXT_PUBLIC ve REACT_APP değerleri build anında gömülüyor. Migrate job'ı her API sürümünde yeni imaja çevriliyor. Tarayıcı servisi ve yedek imajı elle bölgesel build'le üretiliyor.

Ürün B
Yalnız main tetikleyicisi. UI buildpacks ile üretiliyor; Pull ve Push adımları 2 Ekim'de kaldırıldı, Ekim'deki 35 UI build'inin hepsi başarılı.

Ürün C
Yalnız main tetikleyicisi. Testler GitHub Actions'ta koşuyor, deploy yapmıyor.

Ürün D
Yalnız main tetikleyicisi. UI buildpacks ile üretiliyor.

## Ne yanlış gitti, neye para gitti

₺117
Temizlik kuralları kurulduktan 21 Eylül'e kadar dry-run'da kaldı ve hiçbir şey silinmedi. Ürün A deposu 1,3 GB ve 68 imaja çıktı; Ürün B'nin AR depolaması Eylül'de ₺117 tuttu.

**Ders:** Kural listesine değil, describe çıktısındaki cleanupPolicyDryRun alanına bakılır.

₺282
Ürün B'de global buildpack tetikleyicisi her build'de 428 MB'lık imajı Avrupa'dan ABD'deki işçiye çekip geri itti: Eylül'de 194 build, 73 GiB kıtalar arası çıkış. Adımlar 2 Ekim'de kaldırıldı. Aynı kalıp ayda ~15 build'de ~$0,50 tutar ve her build iki imaj yazdığı için geri dönüş penceresini yarıya indirir.

**Ders:** Tetikleyici, AR ve Cloud Run aynı bölgede olur; global bir build AR'den imaj çekmez.

2 kez
Migrate job'ı 'en yeni 5'in dışında kalmış bir imaja sabitti. Temizlik onu silince job kırılma noktasına geldi ve elle yeni imaja çevrildi; 21 Eylül ve 7 Ekim'de aynı şey oldu.

**Ders:** Job imajı servis imajıyla aynı build'de güncellenir.

1 gün
Eylül'de API'nin geri dönülecek revizyonunun imajı bir gün sonra silindi. Ondan sonra geri dönüşün tek yolu revert ve yeniden build oldu.

**Ders:** Bir önceki canlı imaj AR'de durmadan yeni deploy yapılmaz; prev etiketi bunu sağlar.

₺187
İki ürün aynı faturalama hesabını paylaşıyor ve Eylül'de build kotası aşıldı. Ürün A'da test build'leri dakikaların yarısı.

**Ders:** Kotayı birlikte aşan iki ürün ayrı faturalama hesabına alınır; tetikleyicilere includedFiles ve ignoredFiles eklenir.

## Yeni proje için kurallar

Rehbere hazır kurallar; DEPO, PROJE, SERVIS ve ONCEKI yerine kendi adları yazılır.

1. Bölge tektir.

AR deposu, Cloud Run ve Cloud Build tetikleyicisi aynı bölgede, europe-west1'de olur; tetikleyici global bırakılmaz. Aynı bölge içindeki aktarım ücretsiz, kıtalar arası çıkış $0,08/GiB. Global bir build'de AR'den imaj çekilmez.

2. Projede tek Docker deposu, build adımları depoda.

Build adımları depodaki cloudbuild.yaml dosyasında durur. Cloud Run'ın kendi kurduğu satır içi tetikleyici olduğu gibi bırakılmaz, çünkü incelenmez ve sürümlenmez.

3. Temizlik: canlı ve önceki imaj süresiz, deploy edilen 30 gün, testte geçen 14 gün, en yeni 10, gerisi 2 gün.

Kural `cleanup.json` dosyasına yazılır ve önce dry-run'la uygulanır. Bir gün sonra aynı komut `--dry-run` olmadan çalıştırılır, ardından describe çıktısında `cleanupPolicyDryRun` alanının olmadığı ya da false olduğu görülür. `live` ve `prev` etiketleri her deploy'da taşınır ve yaş sınırı olmadan tutulur: canlı imaj, geri dönüş imajı ve job'ın sabitlediği imaj hiç silinmez. Yalnız `deployed-*` kuralına güvenmek yetmez, çünkü `newerThan` yükleme anından sayılır: 30 gündür deploy almayan bir servisin canlı imajı 10 yeni test build'inden sonra silinir. 21 Eylül ve 7 Ekim'de migrate job'ı, sabitlendiği imaj sayı kuralıyla silinince kırıldı. Deploy edilmeyen build 2 gün durur, en yeni 10 imaj her zaman kalır. Ürün A'nın deploy hızında 30 günde ~4 GB, ayda ~$0,40.

```
[
  {"name": "keep-live-prev", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["live", "prev"]}},
  {"name": "keep-deployed-30d", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["deployed-"], "newerThan": "30d"}},
  {"name": "keep-tested-14d", "action": {"type": "Keep"},
   "condition": {"tagState": "TAGGED", "tagPrefixes": ["tested-"], "newerThan": "14d"}},
  {"name": "keep-recent-10", "action": {"type": "Keep"},
   "mostRecentVersions": {"keepCount": 10}},
  {"name": "delete-rest-after-2d", "action": {"type": "Delete"},
   "condition": {"tagState": "ANY", "olderThan": "2d"}}
]
```

```
gcloud artifacts repositories set-cleanup-policies DEPO \
  --project PROJE --location europe-west1 \
  --policy cleanup.json --dry-run
```

4. Her build tam SHA'yla etiketlenir, her deploy etiketleri taşır.

Terfinin son adımı eski live'ı prev'e, yeni digest'i live'a taşır ve `deployed-YYYYMMDD-HHMMSS` ekler. Aynı digest yeniden terfi edilirse prev'e dokunulmaz; yoksa prev live'a eşit olur ve önceki imaj korumasız kalır. live ya da prev adımı hata verirse build kırmızı biter ve Cloud Build alarmı çalar; deploy geri alınmaz ama koruma eksik kalmaz. `deployed-*` etiketindeki `|| true` deploy'u yalnız bu etiket yüzünden düşürmemek için. Deploy latest ile yapılmaz; job'lar servisle aynı digest'e aynı build'de çevrilir. Cloud Build'de `$$` kaçışı şart.

```
- id: mark
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    NEW=$$(cat /workspace/digest)
    OLD=$$(gcloud artifacts docker images describe $_IMG:live \
      --format='value(image_summary.digest)' 2>/dev/null || true)
    if [ -n "$$OLD" ] && [ "$$OLD" != "$$NEW" ]; then
      gcloud artifacts docker tags add $_IMG@$$OLD $_IMG:prev
    fi
    gcloud artifacts docker tags add $_IMG@$$NEW $_IMG:live
    gcloud artifacts docker tags add $_IMG:live \
      $_IMG:deployed-$$(date -u +%Y%m%d-%H%M%S) || true
```

5. Değiştirilemez etiket build deposunda açılmaz.

Bu ayar açık olan depoda temizlik etiketli imajları silemez; her build SHA etiketi taşıdığı için depo sonsuza kadar büyür.

6. Tarama build deposunda kapalı kalır.

Otomatik tarama itilen her yeni digest için $0,26 alır, test build'leri de sayılır. Ekim hızıyla dört ürün ayda ~820 imaj itiyor; tarama açık olsaydı ayda ~$210 (~₺10.000) tutardı, bugünkü bütün GCP faturasının yirmi katından fazla. Yerine build'de ya da haftada bir canlı imajlara karşı Trivy, osv-scanner, govulncheck veya npm audit koşar; maliyeti yalnız build dakikası. AR'nin kendi taraması istenirse yalnız terfi edilen imajların durduğu küçük bir release deposunda açılır, build deposunda `--disable-vulnerability-scanning` uygulanır.

7. Temel imajlar sabit sürümle yazılır.

Go için distroless/static nonroot (bizde 20–31 MB). Next için output standalone ve node:24-alpine (bizde Dockerfile'lı Next 77–92 MB). Statik site için nginx alpine (35 MB). Next için buildpacks kullanılmaz: imaj 5 kat büyük ve builder sürümü kayıyor. Etiketler sabit sürümle yazılır (node:24-alpine, golang:1.27-alpine); alpine:latest ya da builder:latest kullanılmaz. golang etiketindeki sürüm go.mod'daki go satırıyla ve sürüm taban dosyasıyla aynıdır; ikisi güncelleme gününde birlikte yükselir. Resmi golang imajı başka araç zinciri indirmez; go satırı imajdan yeniyse build durur. Node 24 LTS 30 Nisan 2028'e kadar destekli, Node 26 28 Ekim 2026'da LTS oluyor. Google'a göre imaj boyutu Cloud Run'da soğuk başlangıcı etkilemiyor; bizim ölçümümüzde büyük imajlı servislerin ilk isteği daha uzun sürdü, ama bu bir ilişki, nedensellik ölçülmedi. Küçük imajın kesin kazancı depolama, tarama yüzeyi ve bölgeler arası çıkış.

8. Bir kez build, terfi.

Test dalının ürettiği imaj main'de yeniden build edilmez; main tetikleyicisi onay ister, digest'i `tested-*` etiketinden bulur, migrate job'ını o digest'e çevirip bitmesini bekler, servisi trafiksiz candidate etiketiyle açar, candidate adresinde duman testi yapar, trafiği verir ve etiketleri taşır. Web servislerinde migrate adımı yoktur. Prod'da testte denenen imaj bayt bayt aynı çalışır ve build dakikası yarıya iner.

[öneri] Test hattı, test ortamındaki migrate job'ı ve servis deploy'u geçince imaja `tested-<COMMIT_SHA>` etiketini ekler: `gcloud artifacts docker tags add $_IMG@$$(cat /workspace/digest) $_IMG:tested-$COMMIT_SHA`. main hattı digest'i yalnız bu etiketten okur. Etiket yoksa describe hata verir ve terfi başlamaz. Böylece imajı itilmiş ama test'te migrate ya da deploy'u düşmüş commit prod'a çıkamaz. `tested-*` etiketli imaj 14 gün tutulur ([kural 3](#ar-kural-3)); terfi birkaç gün beklese de imaj silinmez.

```
# cloudbuild.main.yaml: main tetikleyicisi, onay ister, build almaz
substitutions:
  _IMG: europe-west1-docker.pkg.dev/PROJE/DEPO/SERVIS
  _SERVICE: SERVIS
  _JOB: SERVIS-migrate
  _R: europe-west1
steps:
- id: digest
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    gcloud artifacts docker images describe $_IMG:tested-$COMMIT_SHA \
      --format='value(image_summary.digest)' > /workspace/digest
    test -s /workspace/digest
- id: migrate
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    D=$$(cat /workspace/digest)
    gcloud run jobs update $_JOB --image=$_IMG@$$D --region=$_R
    gcloud run jobs execute $_JOB --region=$_R --wait
- id: candidate
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    gcloud run deploy $_SERVICE --image=$_IMG@$$(cat /workspace/digest) \
      --region=$_R --no-traffic --tag=candidate
- id: smoke
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: bash
  args:
  - -c
  - |
    set -e
    U=$$(gcloud run services describe $_SERVICE --region=$_R \
      --format='value(status.url)')
    C=$$(echo "$$U" | sed 's#https://#https://candidate---#')
    curl -fsS --retry 5 --retry-all-errors "$$C/health" > /dev/null
- id: traffic
  name: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
  entrypoint: gcloud
  args: [run, services, update-traffic, $_SERVICE, --region=$_R,
         --to-tags=candidate=100]
# son adım: mark (kural 4)
options:
  logging: CLOUD_LOGGING_ONLY
```

Web servisinde Worker öndeyse (EDGE_KEY tanımlı), kapı kenar anahtarı taşımayan her isteğe 403 döner; /health de buna dahildir. candidate adresi run.app'tir ve Worker'dan geçmez. Bu yüzden web'in smoke adımı anahtarı başlıkta taşır; sırda iki değer varsa ilkini gönderir. API'de başlık gerekmez.

```
# web için cloudbuild.main.yaml eki
availableSecrets:
  secretManager:
  - versionName: projects/PROJE/secrets/web-edge-key/versions/latest
    env: EDGE_KEY
# smoke adımına eklenir:
  secretEnv: [EDGE_KEY]
# smoke adımındaki curl satırı:
    curl -fsS --retry 5 --retry-all-errors \
      -H "x-edge-key: $${EDGE_KEY%%,*}" "$$C/health" > /dev/null
```

Build hesabına yalnız bu sır için secretAccessor rolü verilir. Adımda set -x açılmaz, anahtar loga düşmez. Anahtar ayda bir değiştiğinde versions/latest yeni değeri okur.

9. Next'te public ayar build'e gömülmez, çalışma anında okunur.

Terfi ancak imaj ortamdan bağımsızsa çalışır. `NEXT_PUBLIC_` önekli değişken kalmaz; değerler düz adla (`SITE_URL`, `API_ORIGIN`) Cloud Run ortamında durur. Sunucu kodu bunları istek anında okur; ortama göre değişen bir şey okuyan sayfa build'de ön üretilmez (dinamik ya da boş generateStaticParams ile ISR). canonical, og:url ve sitemap istek anında kurulur, CSP origin'leri aynı değişkenlerden türetilir. Tarayıcıya gereken değerler dinamik bir route'tan gelir; istemci bir kez okur ve bellekte tutar. Terfiden sonra prod'da canonical ve bu route curl ile okunur.

```
// app/runtime-config/route.ts: tarayıcıya giden ayar çalışma anında
import { connection } from "next/server";
export async function GET() {
  await connection(); // build'de ön üretilmez; cacheComponents açıkken de
  return Response.json(
    { apiOrigin: process.env.API_ORIGIN, siteUrl: process.env.SITE_URL },
    { headers: { "Cache-Control": "no-store" } });
}
```

[öneri] `export const dynamic` yerine `await connection()` kullanılır. 'use cache' için `cacheComponents` açılırsa dynamic satırı build'i durdurur. Satır silinirse route build'de ön üretilir ve env build'deki değerle donar. `connection()` iki durumda da gerçek isteği bekler. Sayfaya ve sitemap'e konmaz. Onları ISR çalışma anında üretir ve son iyi kopyayı tutar. `connection()` ise her isteği arka uca götürür.

10. Geri dönüş her yeni projede bir kez denenir.

Bir önceki canlı imaj AR'de durmadan yeni deploy yapılmaz; prev etiketi bunu sağlar. Geri dönüş tek komuttur (ilk blok). Hemen ardından etiketler trafiğe eşitlenir (ikinci blok): live geri dönülen imaja, prev kötü imaja geçer. Kötü imaj korunur, çünkü migration geri alınmaz ve migrate job'ı hâlâ ona bakar. Bu adım atlanırsa live kötü imajda kalır ve bir sonraki terfi iyi imajı prev'den düşürür.

```
gcloud run services update-traffic SERVIS --to-revisions=ONCEKI=100 \
  --project PROJE --region europe-west1
```

```
IMG=europe-west1-docker.pkg.dev/PROJE/DEPO/SERVIS
KOTU=$(gcloud artifacts docker images describe $IMG:live \
  --project PROJE --format='value(image_summary.digest)')
IYI=$(gcloud run revisions describe ONCEKI --project PROJE \
  --region europe-west1 --format='value(status.imageDigest)')
gcloud artifacts docker tags add $IMG@$KOTU $IMG:prev --project PROJE
gcloud artifacts docker tags add $IYI $IMG:live --project PROJE
```

11. Build kotası sayılır.

Varsayılan havuzda e2-standard-2 için faturalama hesabı başına ayda 2.500 dk ücretsiz, sonrası $0,006/dk, saniye bazında. İki ürün kotayı aşıyorsa ayrı faturalama hesabı açılır. Tetikleyiciye includedFiles ve ignoredFiles eklenir, yalnız belge değişen push build almaz. Build kaynak kovasına 30 günlük silme kuralı konur.

## Denenebilecekler

| Deneme | Beklenen etki | Risk ve not |
|---|---|---|
| Bölgesel tetikleyici (europe-west1) | AR'den çekme her zaman ücretsiz olur, önbelleğin önü açılır, kaynak kod ve build AB'de kalır. | Düşük. 1. nesil GitHub App tetikleyicileri bölge seçebiliyor; tetikleyiciler yeniden kurulur. |
| live, prev ve deployed- etiketleri | Geri dönüş penceresi çoğu serviste 1–6 günden 30 güne çıkar, canlı ve önceki imaj hiç silinmez; ayda ~$0,40. | live ve prev adımının hatası build'i kırmızı bitirir; deployed- etiketi deploy'u düşürmez (`// true`). |
| Buildpack UI'ları Dockerfile kalıbına taşımak | İki UI imajı 420–456 MB'tan Dockerfile'lı Next'in 77–92 MB'ına iner; depolama, çekme ve çıkış küçülür. | Düşük. Next'te output standalone açılır, ortak Dockerfile kopyalanır. |
| Kayıt önbelleği (BuildKit --cache-to type=registry) | Tahmin, ölçülmedi: Go build adımı 3–4,5 dk'dan ~1,5–2 dk'ya inebilir. | Önbellek imajı 0,3–0,6 GB tutar ve KEEP kuralı ister. Yalnız bölgesel build'de; global build'de kıtalar arası çıkış kazancı yer. |
| Docker Hub için uzak depo (pull-through önbellek) | Docker Hub sınırına (IP başına 6 saatte 100 çekme, Cloud Build adresleri ortak) ve Hub kesintisine karşı koruma; ayda ≤$0,10. | Ağustos'tan beri ~1.250 build'de sınır hatası görülmedi, öncelik düşük. Depo build'le aynı bölgede olur; FROM satırları değişir. |
| SBOM (docker buildx build --sbom=true ya da Syft) | Bir olayda 'hangi canlı imajda X kütüphanesi var' sorusu hemen cevaplanır; ücretsiz. | Düşük; build'e 10–20 sn ekler. AR'nin kendi SBOM'u tarama ister (imaj başına $0,26). |
| Köken doğrulama | Cloud Build her imaja zaten SLSA kökeni ekliyor; denenecek olan doğrulama komutu. | Binary Authorization gerekmez. |
| GitHub Actions ve Workload Identity Federation | Cloud Build dakikası sıfıra iner, Actions önbelleğiyle katman önbelleği bedava olur; anahtar dosyası gerekmez. Free planda özel depolara ayda 2.000 dk. | Bakılacak ikinci bir sistem. ABD'deki runner AR'ye itince ücret yok, AR'den çekerse çıkış ücreti doğar. Ne zaman: bir hesap iki ay üst üste 2.500 dk'yı aşarsa. |
| İmaj boyutu bütçesi | Go 40 MB, Next 120 MB, statik 50 MB; sınır aşılırsa build düşer. Buildpacks'e kayma ya da dev bağımlılıklarının imaja girmesi gibi 5 katlık hataları yakalar. | Meşru büyümede bütçe güncellenir. |
| Önceki revizyona trafik etiketi (ör. prev) | Etiketli revizyonun imaj kopyası saklanıyor olabilir; doğrulanmadı. | Herkese açık serviste eski kod kendi adresinden erişilebilir kalır. |

### Denenmeye değmez

Bakıldı ve bu ölçekte reddedildi.

**Sanal depo.** Tek kaynakla anlamsız.

**Build deposunda değiştirilemez etiket.** Temizliği durdurur; yalnız ayrı bir release deposunda denenir.

**Cloud Build özel havuzu.** Ücretsiz kota yalnız varsayılan havuzda geçerli; özel havuz ancak VPC ya da sabit IP gerekince anlamlı.

**e2-highcpu-8.** $0,0156/dk ve kotaya girmiyor; build ancak 2,6 kat hızlanırsa başa baş.

**kaniko.** Haziran 2025'te arşivlendi.
