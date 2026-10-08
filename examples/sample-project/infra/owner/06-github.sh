#!/usr/bin/env bash
# Gün 0 adım 6: GitHub tarafı (rehber: Yeni depo için kurallar 1, 5, 6;
# Gün 0 önlemi 6'nın force push yasağı).
# Ürün sahibi okur ve KENDİ GitHub kimliğiyle çalıştırır.
#
# Bekleyen kararlar: depo adları K-028'e, test dalı K-007'ye bağlı.
# Maliyet (onay gerekir, fiyatlar bu kuru çalışmada resmi sayfadan
# yeniden okunmadı):
#   - Özel depoda dal kuralı (ruleset) için GitHub Team: kişi başı
#     ~$4/ay (rehber, Gün 0 önlemi 6).
#   - Özel depoda push protection GitHub'ın ücretli sır koruma
#     eklentisini isteyebilir; rehber fiyat vermiyor. Fiyat resmi
#     sayfadan okunup onaylanmadan açılmaz.
#
# Önce konsolda:
#   1. Şirket adına GitHub organizasyonu, iki owner (önlem 1).
#   2. Renovate GitHub App'ini yalnız bu depolara yetkilendirmek
#      (hesap erişimi vermek ürün sahibinin işi).
set -euo pipefail

GH_ORG="${GH_ORG:?GitHub organizasyonu}"
# K-028 cevabına göre, boşlukla ayrılmış. Rehberin önerisi:
# "kampus-api kampus-web kampus-mobile".
REPOS="${REPOS:?depo adları}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

for repo in $REPOS; do
  gh repo create "$GH_ORG/$repo" --private

  # Sır taraması ve push protection.
  gh api -X PATCH "repos/$GH_ORG/$repo" \
    -f 'security_and_analysis[secret_scanning][status]=enabled' \
    -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'

  # main: silme ve force push yasak; PR şartı yok (rehber: GitHub'ın
  # birleştirmesi yeni commit üretir, main test'le eşit kalmaz).
  gh api -X POST "repos/$GH_ORG/$repo/rulesets" \
    --input "$HERE/github/ruleset-main.json"
done

# Doğrulama (ilk push'tan sonra, ürün sahibinin onayıyla):
#   git push --force origin main        -> reddedilmeli
#   git push origin --delete main       -> reddedilmeli
#   git push origin origin/test:main    -> fast-forward ise geçmeli (K-007)
for repo in $REPOS; do
  gh api "repos/$GH_ORG/$repo" --jq '.private, .security_and_analysis'
  gh api "repos/$GH_ORG/$repo/rulesets" --jq '.[].name'
done
