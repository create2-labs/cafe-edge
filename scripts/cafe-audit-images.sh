#!/usr/bin/env bash
# cafe-edge: build nginx/ (image basée sur oleglod/cafe-crypto-backend:runtime-oqs), Docker Scout, rapport.
#
# Prérequis: image locale oleglod/cafe-crypto-backend:runtime-oqs (repo cafe-crypto-backend).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUN_ID="${RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
IMAGE_TAG="${IMAGE_TAG:-cafe-audit-$RUN_ID}"
IMAGE_PREFIX="${IMAGE_PREFIX:-oleglod}"
OQS_BASE="${OQS_BASE:-oleglod/cafe-crypto-backend}"
REPORT_DIR="${REPORT_DIR:-$REPO_ROOT/reports}"
REPORT_FILE="${REPORT_FILE:-$REPORT_DIR/cafe-edge-security-audit-$RUN_ID.md}"
SKIP_SCOUT="${SKIP_SCOUT:-0}"

info()  { printf '%s\n' "→ $*"; }
warn()  { printf '%s\n' "⚠ $*" >&2; }

main() {
  mkdir -p "$REPORT_DIR"
  if ! docker image inspect "${OQS_BASE}:runtime-oqs" >/dev/null 2>&1; then
    warn "Image ${OQS_BASE}:runtime-oqs absente — construire cafe-crypto-backend ./scripts/cafe-audit-images.sh d’abord."
  fi

  local im="${IMAGE_PREFIX}/cafe-edge-nginx:${IMAGE_TAG}" ok=0 sc="KO"
  if ( cd "$REPO_ROOT" && docker build -f nginx/Dockerfile -t "$im" ./nginx ); then ok=1; else warn "build échoué"; fi
  if [ "$ok" = 1 ] && [ "$SKIP_SCOUT" != 1 ] && command -v docker >/dev/null && docker scout version >/dev/null 2>&1; then
    sc=$(docker scout quickview "local://$im" 2>&1 | tr -d '\033' | grep -E 'Target[[:space:]]+│' | head -1 | \
      sed -E 's/.*[[:space:]]([0-9]+)C[[:space:]]+([0-9]+)H[[:space:]]+([0-9]+)M[[:space:]]+([0-9]+)L.*/C=\1 H=\2 M=\3 L=\4/') || sc="?"
  else
    [ "$SKIP_SCOUT" = 1 ] && sc=SKIP
  fi
  {
    echo "# cafe-edge — audit (nginx)"
    echo "- Généré: $(date -u '+%Y-%m-%d %H:%M UTC')"
    echo "- Base OQS attendue: \`${OQS_BASE}:runtime-oqs\`"
    echo ""
    echo "## Image \`$im\` (build: $([ "$ok" = 1 ] && echo OK || echo KO))"
    echo "Scout: $sc"
    echo ""
    if [ "$ok" = 1 ] && [ "$SKIP_SCOUT" != 1 ] && docker scout version >/dev/null 2>&1; then
      docker scout cves "local://$im" --format markdown 2>&1 || true
    fi
  } > "$REPORT_FILE"
  info "Rapport: $REPORT_FILE"
}

main
