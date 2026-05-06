#!/usr/bin/env bash
# Fetch the canonical CHANGELOG.md (and any other shared content) from
# velocit-ee/core into docs/_external/ so the include-markdown plugin
# can pull it in at MkDocs build time.
#
# Strategy — try cheapest source first:
#   1. Sibling local checkout: ~/Projects/velocitee-org/core/CHANGELOG.md
#      (covers local development with both repos cloned side-by-side).
#   2. raw.githubusercontent.com over HTTPS
#      (covers Cloudflare's git-integrated build of docs.velocit.ee).
#
# This script is invoked by:
#   - mkdocs.yml's pre-build step (Cloudflare's build command should run
#     this before `mkdocs build` — see tools/README.md).
#   - The CI workflow in .github/workflows/ci.yml.
#   - Local development: `bash tools/sync_external.sh && mkdocs serve`.
#
# Idempotent. Prints what it did and where the content came from. Exit
# non-zero only if no source was reachable.

set -euo pipefail

DOCS_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTERNAL_DIR="${DOCS_REPO_ROOT}/docs/_external"
mkdir -p "${EXTERNAL_DIR}"

CORE_BRANCH="${CORE_BRANCH:-main}"
CORE_RAW_URL="${CORE_RAW_URL:-https://raw.githubusercontent.com/velocit-ee/core/${CORE_BRANCH}}"

# (relative_path_in_core, output_filename_in_external)
FILES=(
  "CHANGELOG.md:changelog.md"
  "engines.json:engines.json"
)

sync_one() {
  local pair="$1"
  local src="${pair%%:*}"
  local dst_name="${pair##*:}"
  local dst="${EXTERNAL_DIR}/${dst_name}"

  # Try sibling checkout first.
  local sibling_candidates=(
    "$(cd "${DOCS_REPO_ROOT}/.." 2>/dev/null && pwd)/core/${src}"
    "$(cd "${DOCS_REPO_ROOT}/../.." 2>/dev/null && pwd)/core/${src}"
    "${HOME}/Projects/velocitee-org/core/${src}"
  )
  for candidate in "${sibling_candidates[@]}"; do
    if [[ -f "${candidate}" ]]; then
      cp "${candidate}" "${dst}"
      echo "synced ${src} ← ${candidate}"
      return 0
    fi
  done

  # Fall back to raw GitHub.
  if curl -fsSL "${CORE_RAW_URL}/${src}" -o "${dst}"; then
    echo "synced ${src} ← ${CORE_RAW_URL}/${src}"
    return 0
  fi

  echo "ERROR: could not fetch ${src} from any source" >&2
  return 1
}

failed=0
for pair in "${FILES[@]}"; do
  sync_one "${pair}" || failed=1
done
exit "${failed}"
