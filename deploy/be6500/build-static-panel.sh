#!/usr/bin/env bash
# Build a Node-free static admin console for hosts without a Node runtime,
# such as the GL-iNet BE6500 (OpenWrt/aarch64) router.
#
# The console is already a client-only SPA: every route page renders null and
# the whole UI is one "use client" shell, so the Node server only injects the
# Admin API base URL. This build bakes that URL in at compile time instead.
#
# `export const dynamic` must be a static string, so the two route segments are
# patched in place for the duration of the build and restored on exit. Tracked
# sources are left byte-identical afterwards.
set -euo pipefail

API_BASE_URL="${1:?usage: build-static-panel.sh <api-base-url>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend"
PATCHED_FILES=("app/page.tsx" "app/(console)/layout.tsx")

cd "$FRONTEND_DIR"

restore() {
  local file
  for file in "${PATCHED_FILES[@]}"; do
    if [ -f "$file.orig" ]; then
      mv "$file.orig" "$file"
    fi
  done
}
trap restore EXIT

for file in "${PATCHED_FILES[@]}"; do
  if ! grep -q 'export const dynamic = "force-dynamic";' "$file"; then
    echo "unexpected route segment config in $file; refusing to patch" >&2
    exit 1
  fi
  cp "$file" "$file.orig"
  sed 's/export const dynamic = "force-dynamic";/export const dynamic = "force-static";/' \
    "$file.orig" >"$file"
done

TOKENHUB_STATIC_EXPORT=1 TOKENHUB_API_BASE_URL="$API_BASE_URL" npx next build

echo
echo "static console written to $FRONTEND_DIR/out (API base URL: $API_BASE_URL)"
