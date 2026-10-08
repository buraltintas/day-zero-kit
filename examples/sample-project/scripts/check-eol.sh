#!/usr/bin/env bash
# Sürüm tabanı denetimi (Gün 0 önlemi 10, sürüm kuralı 1 ve 4).
# docs/STATUS.md'nin "## Sürümler" bölümünde "destek bitişi: YYYY-MM-DD"
# yazan her satırı okur.
#   60 günden az kaldıysa UYARI (CI uyarısı, önlem 10).
#   6 aydan (183 gün) az kaldıysa RET: satır TODO'ya P1 girer;
#   yeni projede bu sürümle başlanmaz.
# Tarihi yayımlanmayan bileşenler (Go, React, Expo, TypeScript, pgx)
# bu betikle denetlenmez; güncelleme gününde resmi sayfaya bakılır.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
FILE="$ROOT/docs/STATUS.md"
now="$(date -u +%s)"
to_epoch() {
  date -u -d "$1" +%s 2>/dev/null || date -u -j -f "%Y-%m-%d" "$1" +%s
}

section="$(awk '/^## Sürümler/{f=1; next} /^## /{f=0} f' "$FILE")"
if [ -z "$section" ]; then
  echo "docs/STATUS.md'de Sürümler bölümü yok." >&2
  exit 2
fi

fail=0
checked=0
while IFS= read -r line; do
  d="$(printf '%s\n' "$line" | sed -nE 's/.*destek bitişi: ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/p')"
  [ -z "$d" ] && continue
  checked=$((checked + 1))
  name="$(printf '%s\n' "$line" | sed -E 's/^- ([^:]+):.*/\1/')"
  days=$(( ( $(to_epoch "$d") - now ) / 86400 ))
  if [ "$days" -lt 60 ]; then
    echo "UYARI: $name, desteğin bitmesine $days gün."
  fi
  if [ "$days" -lt 183 ]; then
    echo "RET: $name, $days gün (6 aydan az). TODO'ya P1."
    fail=1
  else
    echo "tamam: $name, $days gün."
  fi
done <<< "$section"

if [ "$checked" -eq 0 ]; then
  echo "Tarihli satır bulunamadı." >&2
  exit 2
fi
exit "$fail"
