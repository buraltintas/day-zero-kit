#!/usr/bin/env bash
# Token dışı renk sayacı (tasarım kuralı 2). Kod dosyalarında token
# dosyası ve üretilen dosyalar dışında geçen hex renkleri sayar;
# sayı tokens/hex-baseline.txt'teki tabanı geçerse çıkış 1 (CI kırılır).
# Sayı düşerse taban aynı commit'te düşürülür.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
BASE="$(cat "$ROOT/tokens/hex-baseline.txt")"

count="$(git -C "$ROOT" ls-files -- \
    '*.css' '*.scss' '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.go' '*.html' \
    ':!:tokens/**' \
  | while IFS= read -r f; do
      grep -oE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?([0-9a-fA-F]{2})?\b' "$ROOT/$f" || true
    done | wc -l | tr -d ' ')"

echo "token dışı hex: $count (taban $BASE)"
[ "$count" -le "$BASE" ]
