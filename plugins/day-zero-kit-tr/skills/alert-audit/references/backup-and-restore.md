<!-- Proje Kurulum Rehberi'nden bir bölüm. Tam rehber project-setup skill'inin references/full-guide.md dosyasında (depoda guide/project-setup-guide.md); bu kesitteki (#...) bağlantılar oradaki bölümlere gider. -->

<a id="yedek"></a>

Yedek

# Veritabanı yedeği ve geri yükleme

Yedek üç soruya cevap verir: yanlış bir yazmayı dakikalar içinde geri alabiliyor muyuz, sağlayıcı ya da hesap giderse veri ayakta kalıyor mu, elimizdeki kopyanın gerçekten geri yüklendiğini biliyor muyuz.

Üçü ayrı katmanlarla karşılanır: hızlı geri dönüş için Neon'un kendi geçmişi ve snapshot'ları, sağlayıcı kaybı için Neon dışında her gün alınan ve alındığı anda geri yüklenerek denetlenen döküm. 70 MB'lık prod veritabanımızda geçmiş ve snapshot 1–7 Ekim 2026 ölçümüyle ayda ~5 sent; döküm kovası ve job'ı bir sentin altında. Yedek ucuz; pahalı olan, hiç denenmemiş bir yedekle olay günü karşılaşmak.

**~$0,05/ay** 70 MB'lık prod veritabanında 7 gün geçmiş (~$0,03), 14 gün snapshot (~$0,02), döküm kovası ve job (~$0).

**15 / 15** 24 Eylül–8 Ekim'de ilk denemede başarılı zamanlanmış çalışma. Döküm, geri yükleme kontrolü ve yükleme 5–8 sn.

**1 günden 7 güne** Launch'ta geçmiş penceresinin varsayılanı 1 gün; 7'ye ayardan elle çıkarılır, plan değişince kendiliğinden büyümez.

**4 dk** Alarm denemesinde hatadan alarma: 16:57'de hata, 17:01'de alarm, 17:11'de kendiliğinden kapanış.

**2,76 MB** 70 MB'lık veritabanının dökümü. 23 Eylül'de 702 KB'tı; tablo sayısı 47'den 55'e çıktı.

**~37 gün** Bir dökümün en uzun ömrü: 30. günde lifecycle siler, soft delete 7 gün daha geri getirilebilir tutar.

## İlkeler

1. Geri yüklenemeyen döküm yedek sayılmaz. Her döküm alındığı anda geçici bir Postgres'e yüklenir; kovaya ulaşan kopya da ayrıca boyutuyla denetlenir.

Döküm sağlam olsa bile yükleme onu bozabilir. Bir projemizde ilk çalışma kovaya 7 baytlık nesne yazdı; geri yükleme kontrolü geçmişti, yakalayan yükleme sonrası boyut karşılaştırması oldu.

2. Katmanlar birbirinden bağımsız arızalara karşı kurulur: sağlayıcı geçmişi, sağlayıcı snapshot'ı, sağlayıcı dışı döküm, proje dışı kopya.

Neon geçmişi ve snapshot'ları Neon projesiyle birlikte yaşar; proje silinirse 7 gün içinde kurtarılmazsa hepsi gider. Aynı GCP projesindeki döküm de o proje silinirse gider. [öneri] Prod projesine silme kilidi (lien) konur. Bedeli yoktur; projeyi silmek için önce kilidin kaldırılması gerekir: `gcloud alpha resource-manager liens create --project=PROJECT --restrictions=resourcemanager.projects.delete --reason="prod"`. Kilit kazaya karşıdır; sahip hesap ele geçirilirse kaldırılabilir. Silinen proje 30 gün bekler ve `gcloud projects undelete PROJECT` ile geri alınır. Ama faturalama bağlantısı elle yeniden kurulur, servislerin toparlanması 36 saati bulabilir. Kovadaki nesneler soft delete süresi (bizde 7 gün) dolunca geri gelmeyebilir; soft delete kapalıysa hemen gider. Bu yüzden geri alma proje dışı kopyanın yerini tutmaz. İki adım da restore-db.md'ye yazılır.

3. Önce en hızlı yol denenir: pencere içindeyse Neon geçmişi, değilse snapshot, en son döküm.

Geçmişten dönüş Neon'a göre birkaç saniye sürer ve son dakikaları korur. Döküm 24 saate kadar veri kaybettirir ve bağlantı adresini değiştirmeyi gerektirir.

4. Yedeği alan kimlik kovaya yalnız yazar; okuyamaz, silemez, üzerine yazamaz. Kovayı yalnız proje sahibi okur. Döküm, uygulamanın değil salt okunur ayrı bir rolün bağlantısıyla alınır.

Kimlik ele geçirilse bile eski kopyalar silinemez ve bozulamaz. Ama kimlik veritabanı bağlantı sırrını okuyabildiği için o sır uygulamanınkiyse canlı veriye yazabilir; kova kuralı tek başına yetmez.

5. Sessiz başarısızlık yok: başarılı her çalışma tek satır log yazar, başarısız çalışma alarm atar, alarm uçtan uca denenmiştir. Başarı satırının hiç gelmemesi de ayrı bir alarmdır.

Alarm kuralı yazmak yetmez; postanın gerçekten geldiğini bir kez görmek gerekir. Başarısızlığı sayan alarm, zamanlayıcı duraklatılınca ya da silinince hiç çalmaz.

6. Canlı veri test ortamına yüklenmez; deneme ve test canlıya yazmaz.

Test ortamında giriş kolaylaştırılmıştır. Oraya inen gerçek veri herkese açılmış olur.

7. Gizlilik metnindeki süre, yedekler dahil gerçek azami süredir.

Kodun sildiği kayıt dökümlerde, snapshot'larda ve kovanın soft delete süresinde haftalarca yaşar.

8. Geri yükleme bir tatbikattır, olay günü ilk kez yapılmaz. Süre ölçülür ve runbook'a yazılır.

Hiç denenmemiş yolun süresi ve tuzakları bilinmez.

## Katmanlar

Her katman başka bir arızaya karşıdır. Maliyetler 1–7 Ekim 2026 ölçümü, 70 MB'lık veritabanı.

| Katman | Neye karşı korur | Neye karşı korumaz | Maliyet |
|---|---|---|---|
| Neon geçmişi Instant restore. Launch 7 gün (varsayılan 1), Free 6 saat. Tüm zaman çizgisinin üzerine yazar; eski hal `_old_` dalında kalır, adres değişmez. | Yanlış migration, yanlış UPDATE ya da DELETE, uygulama hatasıyla bozulan satır, silinen tablo; son dakikalara kadar kayıpsız. | Pencereden eski hata, Neon projesinin silinmesi (7 gün kurtarılabilir), hesap ya da sağlayıcı kaybı. Snapshot'tan geri yüklenmiş dalda çalışmaz. | Launch'ta $0,20/GB-ay; Free'de ücretsiz. Bizde 7 gün ortalama 129 MB, ~$0,03/ay. |
| Neon snapshot Zamanlanmış, günde bir; 14 gün saklama, azami 35. Zamanlama yalnız ücretli planda, Free'de tek elle snapshot. | Geçmiş penceresinden eski ama saklamadan yeni hata; büyük bir değişiklikten önce elle alınan güvenli nokta. | Proje silinmesi, hesap ve sağlayıcı kaybı; snapshot anı ile hata arasındaki yazmalar. | $0,09/GB-ay; ilki tam, sonrakiler fark. Bizde 14 gün 212–253 MB, ~$0,02/ay. |
| Neon dışı günlük döküm Cloud Run job'u direct adresten pg_dump -Fc; imaj Postgres 18 ve curl, digest ile sabit; kova bölgesel ve herkese kapalı. | Neon projesinin ya da hesabının kaybı, sağlayıcı değiştirme, snapshot saklamasından eski (30 güne kadar) hata. | Gün içi kayıp (en kötü 24 saat); kova aynı GCP projesindeyse o projenin silinmesi ya da sahip hesabın ele geçirilmesi. Bozuk veriyi de sadakatle yedekler. | Kova ~30 MB, ayda bir sentin çok altında; job günde 17–62 sn, ücretsiz kotada. |
| Doğrulama Geçici Postgres'e pg_restore --exit-on-error, tablo eşiği, yükleme sonrası boyut karşılaştırması, tek satır 'backup ok' logu ve iki alarm. | Yarım ya da bozuk yükleme, pg_dump sürüm uyumsuzluğu, açılmayan döküm, hata veren zamanlayıcı. | Satır düzeyinde eksik veri. Sabit tablo eşiği zamanla gevşer. Duraklatılan ya da silinen zamanlayıcı hiçbir alarmı çaldırmaz; başarı satırının yokluğuna ayrı alarm gerekir. | Çalışma başına birkaç saniye; ücretsiz. |
| Proje dışı kopya [öneri] Haftada bir, ayrı sahiplik ve faturalamalı başka bir projeye ya da sağlayıcıya; kopyalayan kimlik hedefte yalnız nesne oluşturur. | GCP projesinin yanlışlıkla silinmesi, sahip hesabın ele geçirilmesi, faturalama askısıyla kapanan proje. | Hedef aynı hesapla yönetiliyorsa hesap ele geçirilmesine karşı yalnız kısmen korur; hedefte de saklama kuralı gerekir. | Birkaç MB'lık nesneler için ayda birkaç sent. |
| Saklama kilidi Retention 7 gün (kilitsiz), lifecycle 30. günde siler, soft delete 7 gün. | Bir betiğin ya da elle silmenin son haftanın dökümlerini yok etmesi, üzerine yazma; kilitliyse projenin silinmesi de. | Kilitsiz politikada sahip hesabın ele geçirilmesi. Kilit geri alınamaz, süre kısaltılamaz; süre kesinleşmeden kilitlenmez. | Soft delete içindeki nesne de ücretlenir; MB'larda önemsiz. |

## Ne kadar geriye dönülebilir

Bugünkü ayarlarla katman başına en eski geri dönüş noktası; ölçek gerçek.

katmanın bugünkü süresiazami, soft delete ya da önerigün

_Grafik: Katmana göre geri dönülebilecek süre_

## Geri yükleme sırası

Önce en hızlı yol: pencere içindeyse geçmiş, değilse snapshot, en son döküm. Sağdaki süreler ölçüm ya da Neon belgesi; ölçülmeyen yazıyor.

1. **Dur ve kapsamı belirle.** Ne bozuldu, ilk yanlış yazma ne zaman oldu; zaman loglardan bulunur, tahmin edilmez. Bozulma sürüyorsa yazma durdurulur: bakım bayrağı ya da ilgili job duraklatılır.

5–15 dk

2. **Hedef anı doğrula.** Pencere içindeyse Time Travel Assist ile o an salt okunur sorgulanır ya da o andan bir dal açılır; kritik tablolarda satır sayısına bakılır. Dal açmak saniyeler sürer.

birkaç dk

3. **Tam mı seçici mi karar ver.** Birkaç tablo ya da satır bozulduysa geçmiş daldan yalnız onlar kopyalanır (`pg_dump -t` ya da `INSERT ... SELECT`). Tam dönüş, hata anından sonraki doğru yazmaları da siler.

4. **Pencere içinde tam dönüş: instant restore.** Bağlantı adresi değişmez, açık bağlantılar kısa kopar. Eski hal `_old_` dalında kalır; sonradan gelen doğru yazmalar oradan alınır.

saniyeler, Neon'a göre

5. **Pencere dışında, snapshot saklaması içinde.** Çok adımlı snapshot geri yüklemesi: yeni dal açılır, incelenir, sonra geçilir. Bu dalda instant restore çalışmaz; geçişten sonra ilk iş elle snapshot.

dakikalar, ölçülmedi

6. **Neon kaybı ya da daha eski hata: döküm.** Son geçerli döküm bulunur (log satırındaki tables ve users değerleri beklenene uymalı) ve bulut kabuğuna indirilir. Yeni proje ya da dal açılır; direct adrese `pg_restore --no-owner --no-privileges --exit-on-error -1` ile tek işlemde yüklenir.

63 sn, iki küçük veritabanı

7. **Uygulama rolünün yetkilerini yeniden ver.** `--no-owner` ve `--no-privileges` ile yüklenen tablolar yükleyen role aittir.

8. **Doğrula.** Eklentiler, şemalar, her tablonun satır sayısı, sequence değerleri ve her tablonun içeriğinin md5'i kaynakla birebir. Kaynak yoksa döküm anına en yakın Neon dalıyla ya da log satırındaki sayılarla.

~15 sn, 12 ve 53 tablo

9. **Silmeleri yeniden uygula.** Yedekten sonra silinen hesap ve kayıtlar, silmenin bıraktığı iz listesinden yeniden silinir. Neon kaybolduysa liste log kovasından okunur [öneri]. Bu adım atlanırsa silinmiş kişisel veri geri gelir.

10. **Geç.** Eski kaynak bir kez daha md5 ile karşılaştırılır; döküm sonrası yazma varsa önce o taşınır. Bağlantı sırrına yeni sürüm yazılır, servis yeni revizyona alınır.

~20 sn; tümü ~5 dk

11. **Sağlığı oku.** Sağlık ucu, 5xx ve 'veritabanına bağlanamadı' logları temiz mi; eski ve yeni kaynak bir kez daha karşılaştırılır.

12. **Kapat.** Yerel döküm kopyası, `_old_` ve geçici dallar doğrulamadan sonra silinir; olay notu ve ölçülen süreler runbook'a eklenir.

## İki tarif

### Free'deki küçük proje

Neon Free: 6 saat geçmiş, 1 elle snapshot, zamanlama yok, proje başına 1 GB, 100 CU-saat, 5 GB çıkış, 10 dal.

1

6 saatlik geçmiş açık ve büyütülemez; hatayı 6 saat içinde fark etmek için hata ve 5xx alarmı ilk gün kurulur.

2

Migration, toplu import ya da elle veri düzeltmeden hemen önce tek elle snapshot hakkı kullanılır; iş doğrulanınca eskisi silinir ki hak boşalsın.

3

Prod'daki döküm job'u aynen kopyalanır: aynı imaj ve betik, tablo eşiği projeye göre. Kova Neon dışında; retention 7, lifecycle 30 gün.

4

Job veritabanının zaten uyanık olduğu saate konur. Olmasa da birkaç saniyelik döküm 0,25 CU'da ayda ~0,6 CU-saat eder, kotanın %1'inden az (hesap, ölçülmedi).

5

Geri yükleme hedefi 1 GB ve 10 dal sınırına uyar; geri yüklemenin bıraktığı `_old_` dalları iş bitince silinir.

6

Free'de tüketim API'si yok: CU-saat 'db wake' log metriğiyle izlenir, Usage sayfası haftada bir, depolama ve dal sayısı ayda bir okunur. Kota aşılırsa compute dönem sonuna kadar durur.

7

Ücretli plandan Free'ye taşındıysa eski proje bir hafta yedek olarak durur, sonra silinir.

### Ücretli prod (Neon Launch)

Ölçülen maliyet 70 MB'lık veritabanında ayda ~$0,05: geçmiş ~$0,03, snapshot ~$0,02, kova ve job ~$0.

1

Geçmiş penceresi Settings > Postgres'ten 7 güne çıkarılır ve gözle kontrol edilir. Launch varsayılanı 1 gündür; pencere proje ayarında durur ve plan değişince kendiliğinden büyümez.

2

Günlük snapshot zamanlanır; 14 gün saklama yeter, azami 35.

3

Günlük döküm job'u: direct bağlantı, `pg_dump --format=custom`, geçici Postgres'e `pg_restore --no-owner --no-privileges --exit-on-error`, tablo eşiği, yükleme sonrası boyut karşılaştırması, tek satır başarı logu.

4

Job ve zamanlayıcıya iki alarm, bilerek başarısız bir çalışmayla bir kez uçtan uca denenir. Üçüncü alarm: son 'backup ok' satırı 26 saati geçerse. Bunu günde iki kez çalışan küçük bir denetim işi kontrol eder, çünkü Cloud Monitoring'in yokluk alarmı en çok 23,5 saat bekler.

5

Kova herkese kapalı, tek tip erişim, retention 7, lifecycle 30, soft delete 7 gün. Yedek kimliği yalnız nesne oluşturur; projenin Viewer ve Editor kolaylık bağları kovadan kaldırılır.

6

Döküm uygulamanın değil, salt okunur ayrı bir rolün bağlantısıyla alınır; migration ve yedek direct, uygulama pooled adres kullanır.

7

Haftada bir en son dökümün proje dışı kopyası alınır. [öneri] Hedef kovada lifecycle 28 gün, soft delete 7 gün olur. Lifecycle hedefteki kopyalama anından sayılır; 28 gün seçildiği için kopya da gizlilik metnindeki 37 günü aşmaz.

8

Ayda bir geçmişten önizleme, üç ayda bir dökümden tam geri yükleme tatbikatı; süreler runbook'a yazılır.

## Tatbikat takvimi

| Ne zaman | Ne yapılır | Süre |
|---|---|---|
| Her gün | Job'un geri yükleme kontrolü ve boyut karşılaştırması; başarısızlıkta alarm; son başarı 26 saati geçerse günde iki kez çalışan denetim işi ayrı alarm verir. | otomatik |
| Her hafta | Son yedi 'backup ok' satırına bakılır. Önceki güne göre %20'den fazla küçülen döküm ya da migration olmadan değişen tablo sayısı incelenir. | 2 dk |
| Her ay | 24 saat önceki andan dal açılır ya da Time Travel Assist ile sorgulanır, birkaç kritik tablonun satır sayısı bugünküyle karşılaştırılır, dal silinir. Geçmiş penceresi ve snapshot zamanlaması ayarda mı bakılır; Free projelerde CU-saat, depolama ve dal sayısı okunur. | 10 dk |
| Üç ayda bir | Son döküm yeni bir Neon dalına ya da projeye tam yüklenir (test ortamına asla), dökümün başladığı ana açılmış dalla tablo tablo md5 karşılaştırılır, uygulamanın bir kopyası bağlanıp okuma yapılır, süre kaydedilir. | 30–60 dk |
| Job, imaj ya da alarm değişince | Alarm bilerek başarısız bir çalışmayla yeniden denenir. Konu satırına TEST yazılır; ad ancak alarm kapandıktan sonra geri alınır, çünkü kapanış postası da adı taşır. |  |
| Postgres ana sürümü değişince | İmaj yeni sürümle yeniden kurulur ve elle bir çalıştırma yapılır. |  |

### Silme ve KVKK

Yedekteki kişisel veri de kişisel veridir. Saklama ve imha politikası dökümleri, snapshot'ları ve kovanın soft delete süresini açıkça kapsar.

Gerçek azami süre için süreler toplanmaz; koddaki silmeye en uzun yedek ömrü eklenir. Bizde döküm 30 gün lifecycle ve 7 gün soft delete ile 37 gün; Neon geçmişi (7 gün) ve snapshot (14 gün) bunun içinde kalır. Kodun 60. günde sildiği bir kayıt o sabahki dökümde 97. güne kadar geri getirilebilir durumda yaşar.

Tek bir kişi yedekten tek tek silinmez; yedeklerin ömrü kısa tutulur ve dökümler kendiliğinden düşer. Silme talebinin cevabında yedeklerden en geç ne zaman düşeceği yazılır.

Silme kişisel veri taşımayan bir iz bırakır (tablo, kayıt kimliği, silinme zamanı); geri yüklemenin son adımı bu izlerle silmeleri yeniden uygulamaktır.

Silme yönetmeliğine göre talep en geç 30 günde sonuçlandırılır (m.12), periyodik imha aralığı altı ayı geçemez (m.11). Canlıdan silme 30 gün içinde yapılır; yedekteki kopya 37 güne kadar kalabildiği için bu fark cevapta açıkça yazılır ve ifadesi hukukçuya sorulur.

Yedekler yurt dışındaysa (AB) aydınlatma metni bunu söyler ve yurt dışı aktarım şartı karşılanır; standart sözleşme imzadan itibaren beş iş günü içinde Kurum'a bildirilir.

Döküm müşteri verisidir: bulut kabuğunda çalışılır ya da indirilen kopya iş bitince silinir. Sohbete, issue'ya, e-postaya ya da ortak klasöre konmaz.

Canlı döküm test ortamına yüklenmez; testler ve elle denemeler canlı veritabanına yazmaz.

Yedek kovasını yalnız proje sahibi okur; kimin ne zaman okuduğunu görmek için kovada veri erişim denetim kaydı açılabilir.

## Taşıma ve geri yüklemeyi doğrulamak

7 Ekim 2026'da iki küçük veritabanı (35 KB ve 1 MB döküm) bu tarifle taşındı: döküm ve yükleme 63 sn, yapı ve sayım karşılaştırması 25 sn, md5 ~15 sn; 12 ve 53 tablonun md5'i birebir. Ortam değişkeni değişikliğinden yeni instance'a ~20 sn, dökümün başlangıcından ikinci servisin geçişine ~5 dk.

1. Aynı sorgular iki tarafta.

Her iki tarafta aynı sorgular çalışır, çıktılar diff ile karşılaştırılır.

2. Yapı.

Eklentiler ve sürümleri, şemalar, sunucu sürümü.

3. Sayım.

Her tablonun tam satır sayısı (`count(*)`) ve her sequence'in son değeri.

4. İçerik.

Her tablonun satırları metne çevrilip sıralanır ve tek md5 alınır. Aşağıdaki sorgu bu sorguları üretir; çıktısı aynı bağlantıda psql'e verilir. Alt alta iki metin sabiti Postgres'te birleşir.

```
select format(
  'select %L || '' '' || coalesce(md5(string_agg(t::text, ''|'' '
  'order by t::text)), ''empty'') from %I.%I t;',
  c.relname, n.nspname, c.relname)
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind in ('r', 'p') and n.nspname = 'public'
order by 1;
```

5. Yükleme.

`pg_dump -Fc` ve `pg_restore --no-owner --no-privileges --exit-on-error -1`: tek işlem, yarım yükleme kalmaz. İki taraf da direct adresle bağlanır.

```
pg_dump -Fc -f db.dump "$SOURCE"
pg_restore --no-owner --no-privileges --exit-on-error -1 -d "$TARGET" db.dump
```

6. Geçişten hemen önce ve sonra.

Eski kaynağın md5'i dökümle yeniden karşılaştırılır; fark varsa geçiş durur. Geçişten sonra bir kez daha.

7. Bağlantı bilgisi.

Sohbete ya da loga düşmez; 600 izinli dosyaya yazılır, komutlara kabuk değişkeniyle verilir.

## Tuzaklar

busybox wget ikili dosyayı ilk sıfır baytına kadar gönderir; ilk çalışma kovaya 7 baytlık nesne yazdı. Yükleme curl ile yapılır.

Pooler adresinden alınan pg_dump hata verir; döküm, migration ve geri yükleme direct adresten.

pg_dump kendi ana sürümünden yeni bir sunucudan döküm almayı reddeder; imaj digest ile sabit olduğu için Neon ana sürüm değiştirince job kırılır ve imaj yeniden kurulur.

Özel biçimde `--no-owner` pg_dump'ta yok sayılır; pg_restore'a verilir.

postgres alpine imajında su-exec değil gosu var; geçici sunucu gosu ile postgres kullanıcısında başlatılır.

Kovanın kolaylık bağları (proje Viewer ve Editor) projeyi gören herkese yedeği okutur. `remove-iam-policy-binding` bunlarda 'not found' verdi; politika `set-iam-policy` ile baştan yazılınca kalktı.

Geçmiş penceresi proje ayarında durur ve plan değişince büyümez; Launch varsayılanı 1 gün, azamisi 7 gün. 276 MB'lık bir projede 6 saatlik geçmiş ortalama 12 MB; 7 güne çıkarmak ayda birkaç sent.

Instant restore birleştirme değil, üzerine yazmadır; hata anından sonraki doğru yazmalar `_old_` dalından alınır.

Snapshot'tan geri yüklenmiş dalda instant restore çalışmaz; snapshot'a geçince ilk iş elle snapshot.

Neon projesi silinince dallar, geçmiş ve snapshot'lar da gider; proje yalnız 7 gün kurtarılabilir. Neon içindeki katmanlar Neon kaybına karşı yedek değildir.

Kilitsiz retention sahip tarafından kaldırılabilir; kilit geri alınamaz, süre kısaltılamaz ve projeye silme engeli koyar.

Soft delete lifecycle silmelerine de uygulanır: 30 günlük kural gerçekte ~37 gün demektir ve bu süre gizlilik metnine girer.

Sabit tablo eşiği zamanla gevşer: eşik 40 iken tablo sayısı 47'den 55'e çıktı. Kontrol önceki günün sayısına ya da kritik tabloların satır sayısına bağlanır.

Başarısızlığı sayan alarm hiç çalışmayan job'u görmez; zamanlayıcı duraklatılırsa ya da silinirse sessizlik olur.

Yedek saati başka bir işin veritabanını uyandırdığı saate göre seçildiyse, o iş seyrekleşince yedek kendisi uyandırmaya başlar; bağımlılık yazılır.

Döküm veritabanından çok küçüktür: 70 MB'lık veritabanının dökümü 2,76 MB, boş bir Neon veritabanı bile ~30 MB gösterir. Mutlak boyuta değil günden güne değişime bakılır.

Taşımada döküm ile geçiş arasında eski veritabanına yazma olursa kaybolur; geçişten hemen önce ve sonra md5 yeniden karşılaştırılır.

md5 karşılaştırması tabloyu bellekte sıralar; büyük tablolarda kimlik aralıklarına bölünür.

Free'de dal sınırı 10; dolunca geri yüklemenin istediği dal açılamaz. Depolama 1 GB'ı aşarsa yazmalar durur; CU-saat ya da çıkış kotası aşılırsa compute dönem sonuna kadar durur.

## Kontrol listesi

- [ ] Neon geçmiş penceresi ayarda gözle kontrol edildi (ücretli: 7 gün, Free: 6 saat).

- [ ] Ücretli projede günlük snapshot zamanlandı, saklama süresi yazıldı.

- [ ] Günlük döküm job'u: direct adres, -Fc, ayrı salt okunur rol, imaj digest ile sabit.

- [ ] Döküm geçici Postgres'e --no-owner --no-privileges ile geri yükleniyor; tablo kontrolü ve yükleme sonrası boyut karşılaştırması var.

- [ ] Başarılı her çalışma tek satır log yazıyor; job ve zamanlayıcı alarmı var ve bir kez uçtan uca denendi.

- [ ] Son başarı 26 saati geçerse alarm veren denetim işi var (yokluk alarmı en çok 23,5 saat bekler).

- [ ] Kova herkese kapalı, tek tip erişim, retention 7 gün, lifecycle 30 gün, soft delete 7 gün.

- [ ] Yedek kimliği yalnız nesne oluşturabiliyor; kovanın Viewer/Editor kolaylık bağları kaldırıldı.

- [ ] Haftalık proje dışı kopya var.

- [ ] Gizlilik metni yedekler ve soft delete dahil gerçek azami süreyi yazıyor; silmeler iz bırakıyor ve geri yüklemede yeniden uygulanıyor.

- [ ] Runbook'ta 'canlı veri test ortamına inmez' kuralı ve ölçülmüş süreler yazılı.

- [ ] Aylık geçmiş önizlemesi ve üç aylık tam geri yükleme tatbikatı takvimde.

- [ ] Postgres ana sürümü değişince imaj yeniden kuruluyor.

- [ ] Free projelerde CU-saat, depolama ve dal sayısı ayda bir okunuyor.
