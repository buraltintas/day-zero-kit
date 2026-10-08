#!/usr/bin/env bash
# Depo kapısı (rehber: Yeni depo için kurallar 1 ve 2).
#   --staged : pre-commit; yalnız commit'e girecek dosyalar.
#   --all    : CI; git'teki bütün dosyalar ve geçmiş.
# Reddeder: ~1 MB'tan büyük dosya, Mach-O ya da ELF ikilisi,
# gitleaks'in bulduğu sır. gitleaks yoksa reddeder (kapalı kalır).
# Meşru istisnalar .repo-gate-allow dosyasında, satır başına bir yol.
set -euo pipefail

MODE="${1:---staged}"
LIMIT=$((1024 * 1024))
ROOT="$(git rev-parse --show-toplevel)"
ALLOW="$ROOT/.repo-gate-allow"
fail=0

allowed() {
  [ -f "$ALLOW" ] && grep -qxF -- "$1" "$ALLOW"
}

if [ "$MODE" = "--staged" ]; then
  files="$(git diff --cached --name-only --diff-filter=ACMR)"
  size_of() { git cat-file -s ":$1"; }
  head_of() { git cat-file blob ":$1" | head -c 4 | od -An -tx1 | tr -d ' \n'; }
elif [ "$MODE" = "--all" ]; then
  files="$(git ls-files)"
  size_of() { wc -c < "$ROOT/$1" | tr -d ' '; }
  head_of() { head -c 4 "$ROOT/$1" | od -An -tx1 | tr -d ' \n'; }
else
  echo "kullanım: $0 [--staged|--all]" >&2
  exit 2
fi

while IFS= read -r f; do
  [ -z "$f" ] && continue
  allowed "$f" && continue
  size="$(size_of "$f")"
  if [ "$size" -gt "$LIMIT" ]; then
    echo "RET: $f $size bayt (sınır 1 MB). İstisnaysa .repo-gate-allow'a yaz." >&2
    fail=1
  fi
  case "$(head_of "$f")" in
    7f454c46) echo "RET: $f ELF ikilisi." >&2; fail=1 ;;
    feedface|feedfacf|cefaedfe|cffaedfe|cafebabe)
      echo "RET: $f Mach-O ikilisi." >&2; fail=1 ;;
  esac
done <<< "$files"

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "RET: gitleaks kurulu değil; sır taraması yapılamadı." >&2
  fail=1
elif [ "$MODE" = "--staged" ]; then
  gitleaks git --pre-commit --staged --redact --no-banner "$ROOT" || fail=1
else
  gitleaks git --redact --no-banner "$ROOT" || fail=1
fi

exit "$fail"
