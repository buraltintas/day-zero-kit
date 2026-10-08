#!/usr/bin/env bash
# Gün 0 adım 4: faturalama ve bütçe (K-003, K-004, K-011).
# Ürün sahibi okur ve KENDİ kimliğiyle çalıştırır; ajan çalıştırmaz.
# Çıktıyı ajana verir. Projede bir şey kuran her komut burada.
#
# Önce konsolda (komutla yapılamaz ya da ödeme ister):
#   1. Google Cloud'da ürüne ayrı faturalama hesabı, aynı ödeme
#      profilinin altında; ödeme yöntemi ürün sahibinin kartı.
#   2. Ödeme profiline başka bir kuruluşun yedek kartı; kartta
#      yurt dışı işlem açık; fatura postası ortak adrese
#      (Gün 0 önlemi 13).
#   3. Faturalama yöneticisi rolü ikinci kişide (önlem 13; IAM,
#      K-002'deki ikinci yönetici).
#   4. Neon'da ürüne ayrı org (prod, Launch) ve ayrı Free org
#      (test); Launch planını ürün sahibi kartıyla açar (K-005).
#   5. Organizasyon varsayımı: K-002 "şirket adına" çıkarsa
#      Cloud Identity organizasyonu açılır. Kişi adına çıkarsa
#      ORG_ID'li iki komut yerine rehberin AB log kovası yolu
#      kullanılır (Ücretsiz katmanlar > Cloud Logging).
set -euo pipefail

ORG_ID="${ORG_ID:?Cloud Identity organizasyon numarası}"
PROJECT_ID="${PROJECT_ID:?ürünün Google Cloud proje kimliği}"
BILLING_ACCOUNT="${BILLING_ACCOUNT:?ürünün faturalama hesabı, XXXXXX-XXXXXX-XXXXXX}"
# Faturalama hesabının para birimiyle yazılır. TRY ise 150TRY;
# USD ise 3USD (₺150 / 49, rehberin kuru).
BUDGET_AMOUNT="${BUDGET_AMOUNT:?ör. 150TRY ya da 3USD}"
REGION="europe-west1"

# Log kovaları AB'de doğsun diye proje açılmadan ÖNCE (rehber:
# Ücretsiz katmanlar > Cloud Logging).
gcloud logging settings update --organization="$ORG_ID" \
  --storage-location="$REGION"

# Proje ve faturalama bağı. Test ve prod aynı projede
# '-test' servisleriyle durur (rehber, K-010 bekliyor).
gcloud projects create "$PROJECT_ID" --organization="$ORG_ID"
gcloud billing projects link "$PROJECT_ID" \
  --billing-account="$BILLING_ACCOUNT"

# Bütçe bildirimleri için Pub/Sub konusu.
gcloud services enable pubsub.googleapis.com billingbudgets.googleapis.com \
  --project "$PROJECT_ID"
gcloud pubsub topics create billing-budget-alerts --project "$PROJECT_ID"

# Bütçe 1: %50, %80, %100.
gcloud billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="kampus-monthly" \
  --budget-amount="$BUDGET_AMOUNT" \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.8 \
  --threshold-rule=percent=1.0 \
  --notifications-rule-pubsub-topic="projects/$PROJECT_ID/topics/billing-budget-alerts"

# Bütçe 2: krediler hariç (kredi bitince sürpriz olmasın).
gcloud billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="kampus-monthly-excluding-credits" \
  --budget-amount="$BUDGET_AMOUNT" \
  --credit-types-treatment=exclude-all-credits \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.8 \
  --threshold-rule=percent=1.0 \
  --notifications-rule-pubsub-topic="projects/$PROJECT_ID/topics/billing-budget-alerts"

# BigQuery fatura dökümü için AB'de veri kümesi. Dökümü açmak
# yalnız konsoldan: Billing > Billing export > BigQuery export >
# Standard usage cost > bu veri kümesi.
gcloud services enable bigquery.googleapis.com --project "$PROJECT_ID"
bq --location=EU mk --dataset "$PROJECT_ID:billing_export"

# Prod harcama tavanı (K-011, Gün 0 önlemi 7): ~$100. Rehber komut
# vermiyor; resmi sayfadaki adımla konsoldan kurulur:
#   https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps
# Kaldırma adımı docs/runbooks/cost-check.md'de.

# Doğrulama (çıktıyı ajana ver): iki bütçe, her birinde üç eşik.
gcloud billing budgets list --billing-account="$BILLING_ACCOUNT"
