#!/usr/bin/env bash
# Render docs/diagrams/*.mmd to docs/assets/workflows/*.svg.
# Chrome / Puppeteer is a render-time dependency only — not a harness runtime.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${ROOT}/docs/diagrams"
DEST="${ROOT}/docs/assets/workflows"
# Pin: bump only when re-rendering and verifying the three SVGs.
MERMAID_CLI_VERSION="11.4.2"

if [[ ! -d "$SRC" ]]; then
  echo "error: missing $SRC" >&2
  exit 1
fi

mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat > "${TMP}/puppeteer.json" <<'EOF'
{
  "args": ["--no-sandbox", "--disable-setuid-sandbox"]
}
EOF

rendered=0
for mmd in "$SRC"/*.mmd; do
  [[ -f "$mmd" ]] || continue
  name="$(basename "$mmd" .mmd)"
  out="${DEST}/${name}.svg"
  echo "render ${name}.mmd → ${out}"
  npx -y "@mermaid-js/mermaid-cli@${MERMAID_CLI_VERSION}" \
    -i "$mmd" \
    -o "$out" \
    -b "#2B313C" \
    -p "${TMP}/puppeteer.json"
  if [[ ! -s "$out" ]]; then
    echo "error: empty output $out" >&2
    exit 1
  fi
  rendered=$((rendered + 1))
done

if [[ "$rendered" -eq 0 ]]; then
  echo "error: no .mmd files in $SRC" >&2
  exit 1
fi

echo "rendered ${rendered} chart(s) into ${DEST}"
