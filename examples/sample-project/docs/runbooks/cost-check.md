# cost-check.md: günlük maliyet nereden okunur, eşikte ne yapılır
Son prova: yok (bayat sayılır). İlk prova faturalama dökümü
açıldıktan sonraki ilk gün.

## Amaç
Kaçağı ay sonu faturasında değil, ertesi gün görmek.

## Ne zaman
Günde bir (SKU sorgusu); bütçe uyarısı gelince; harcama
tavanı dolunca.

## Kim onaylar
Okumak: ajan, salt okunur kimlikle. Bir şeyi kapatmak ya da
tavanı kaldırmak: ürün sahibi.

## Komutlar
Proje ve faturalama hesabı her komutta açık yazılır.

Bütçeler (iki bütçe, üç eşik beklenir):
  gcloud billing budgets list --billing-account=BILLING_ACCOUNT

SKU bazında son 14 gün (BigQuery fatura dökümü; tablo adı
dökümü açınca belli olur):
  bq query --project_id=PROJECT_ID --use_legacy_sql=false '
  SELECT DATE(usage_start_time, "Europe/Istanbul") AS gun,
         service.description AS servis,
         sku.description AS sku,
         ROUND(SUM(cost), 2) AS brut,
         ROUND(SUM(cost) + SUM(IFNULL((SELECT SUM(c.amount)
           FROM UNNEST(credits) c), 0)), 2) AS net
  FROM `PROJECT_ID.billing_export.gcp_billing_export_v1_XXXXXX_XXXXXX_XXXXXX`
  WHERE usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(),
        INTERVAL 14 DAY)
  GROUP BY 1, 2, 3
  ORDER BY gun DESC, brut DESC'

Eşik: bir SKU'nun günlük tutarı önceki haftanın günlük
ortalamasının 2 katını geçerse "bugün" uyarısı.

## Eşikte ne yapılır
- %50 / %80: en çok artan üç kalem okunur, sebep yazılır.
- %100: ürün sahibine tek satır; kapatılacak kalem önerilir.
- Harcama tavanı doldu: o projede Cloud Run ay sonuna kadar
  yeni istek almaz. Tavanı kaldırmak ürün sahibinin işi;
  toparlanma bir saati bulabilir.

## Harcama tavanını kaldırma (K-011)
Rehber adımı vermiyor; resmi sayfadan okunup ilk provada
buraya kopyalanır:
  https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps
Bu kuru çalışmada sayfa okunamadı (ağ yok).

## Doğrulama
Bütçe listesi iki bütçe gösterir; SKU sorgusu satır döner.

## Geri dönüş
Okuma işi; geri alınacak bir şey yok.
