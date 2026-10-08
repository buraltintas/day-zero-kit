#!/usr/bin/env bash
# Gün 0 adım 8, bugün kurulabilen kısım: tek Docker deposu ve
# temizlik kuralı (rehber: Artifact Registry kuralları 1, 3, 5, 6).
# Ürün sahibi okur ve KENDİ kimliğiyle çalıştırır; ajan çalıştırmaz.
#
# Bu adımın bekleyen kısmı:
#   - Tetikleyiciler, cloudbuild.test.yaml ve cloudbuild.main.yaml,
#     build hesapları, docs/runbooks/deploy.md: K-007 (dal modeli).
#   - '-test' servisleri ve hesapları: K-010 (test ortamı).
#   - Servislerin ilk açılışı: test'te doğrulanmış ilk digest'le,
#     hattın dışında bir kez, ürün sahibinin onayıyla
#     (docs/runbooks/new-env.md, ilk koddan sonra).
set -euo pipefail

PROJECT_ID="${PROJECT_ID:?ürünün Google Cloud proje kimliği}"
REGION="europe-west1"
REPO="kampus"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

gcloud services enable artifactregistry.googleapis.com run.googleapis.com \
  cloudbuild.googleapis.com --project "$PROJECT_ID"

# Tek depo, Cloud Run ve tetikleyiciyle aynı bölgede. Değiştirilemez
# etiket kapalı (varsayılan), tarama kapalı (kural 5 ve 6).
gcloud artifacts repositories create "$REPO" \
  --repository-format=docker \
  --location="$REGION" \
  --disable-vulnerability-scanning \
  --project "$PROJECT_ID"

# Temizlik önce dry-run'la (kural 3).
gcloud artifacts repositories set-cleanup-policies "$REPO" \
  --project "$PROJECT_ID" --location "$REGION" \
  --policy "$HERE/artifact-registry/cleanup.json" --dry-run

# ERTESİ GÜN aynı komut --dry-run olmadan:
#   gcloud artifacts repositories set-cleanup-policies kampus \
#     --project "$PROJECT_ID" --location europe-west1 \
#     --policy infra/artifact-registry/cleanup.json
#
# Doğrulama (çıktıyı ajana ver): ertesi günden sonra bu alan boş
# ya da False olmalı.
gcloud artifacts repositories describe "$REPO" \
  --location "$REGION" --project "$PROJECT_ID" \
  --format='value(cleanupPolicyDryRun)'
