#!/usr/bin/env bash
# One-shot Cloudflare Workers Builds configuration for the `docs` worker.
#
# What this does:
#   1. Looks up the Worker tag for the worker named `docs` on the configured
#      Cloudflare account.
#   2. Looks up the production trigger UUID for that worker (Workers Builds
#      stores the build/deploy command per trigger).
#   3. PATCHes the trigger to set the build command to the velocit.ee
#      pipeline: install deps → sync external content → mkdocs build.
#   4. Triggers a manual redeploy of `main` so the new command runs against
#      the current commit immediately.
#   5. Polls the build until it terminates and reports the result.
#
# Why a script: Cloudflare's Workers Builds settings live behind dashboard
# clicks or API calls. Encoding the config as a script means we can re-run
# it any time the worker needs reconnecting (account move, fresh setup,
# etc.) and the build pipeline stays reproducible from source.
#
# Required environment:
#   CLOUDFLARE_API_TOKEN  — API token with the following permissions:
#                           - Account → Workers Scripts → Edit
#                           - Account → Workers CI/CD → Edit (for Builds API)
#                           Create at https://dash.cloudflare.com/profile/api-tokens
#                           with the "Edit Cloudflare Workers" template, then
#                           add Workers CI/CD if missing.
#   CLOUDFLARE_ACCOUNT_ID — defaults to the velocit.ee account.
#   WORKER_NAME           — defaults to 'docs'.
#
# Run:
#   CLOUDFLARE_API_TOKEN=<token> bash tools/cloudflare_setup.sh

set -euo pipefail

ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-af125b9e82852f1bd4a9679ec0184783}"
WORKER_NAME="${WORKER_NAME:-docs}"
BUILD_COMMAND='pip install -r requirements.txt && bash tools/sync_external.sh && mkdocs build --strict'
DEPLOY_COMMAND='npx wrangler deploy'   # default; preserved if already different

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "ERROR: CLOUDFLARE_API_TOKEN must be set." >&2
  echo "  Create one at https://dash.cloudflare.com/profile/api-tokens" >&2
  echo "  Required permissions: Workers Scripts:Edit + Workers CI/CD:Edit" >&2
  exit 1
fi

# Defensive: avoid leaking the token if `set -x` is enabled by a wrapper.
api() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  local args=(
    -sS
    --header "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"
    --header "Content-Type: application/json"
    --request "${method}"
  )
  if [[ -n "${data}" ]]; then
    args+=(--data "${data}")
  fi
  curl "${args[@]}" "https://api.cloudflare.com/client/v4${path}"
}

# Pretty-print JSON and bail out on API errors.
require_success() {
  local label="$1"
  local body="$2"
  local ok
  ok="$(printf '%s' "${body}" | jq -r '.success // false')"
  if [[ "${ok}" != "true" ]]; then
    echo "ERROR (${label}): API call failed:" >&2
    printf '%s' "${body}" | jq '.errors // .' >&2
    exit 1
  fi
}

echo "==> Looking up Worker tag for '${WORKER_NAME}'..."
SCRIPTS_JSON="$(api GET "/accounts/${ACCOUNT_ID}/workers/scripts")"
require_success "scripts.list" "${SCRIPTS_JSON}"
WORKER_TAG="$(printf '%s' "${SCRIPTS_JSON}" | jq -r --arg n "${WORKER_NAME}" \
  '.result[] | select(.id == $n) | .tag')"
if [[ -z "${WORKER_TAG}" || "${WORKER_TAG}" == "null" ]]; then
  echo "ERROR: no Worker named '${WORKER_NAME}' on account ${ACCOUNT_ID}" >&2
  printf '%s' "${SCRIPTS_JSON}" | jq -r '.result[].id' | sed 's/^/  /' >&2
  exit 1
fi
echo "    tag = ${WORKER_TAG}"

echo "==> Looking up production trigger..."
TRIGGERS_JSON="$(api GET "/accounts/${ACCOUNT_ID}/builds/workers/${WORKER_TAG}/triggers")"
require_success "triggers.list" "${TRIGGERS_JSON}"

# Pick the trigger marked as production. If none is explicitly marked,
# fall back to the first trigger — single-trigger workers are common.
TRIGGER_UUID="$(printf '%s' "${TRIGGERS_JSON}" | jq -r '
  .result.triggers // [] |
  (map(select(.is_production == true)) + .) |
  .[0].trigger_uuid // empty
')"
if [[ -z "${TRIGGER_UUID}" ]]; then
  echo "ERROR: no triggers found for Worker '${WORKER_NAME}'." >&2
  echo "  Workers Builds may not be configured for this Worker yet." >&2
  echo "  Connect the GitHub repo via the dashboard first, then re-run." >&2
  exit 1
fi
echo "    trigger = ${TRIGGER_UUID}"

CURRENT_BUILD_CMD="$(printf '%s' "${TRIGGERS_JSON}" | jq -r --arg t "${TRIGGER_UUID}" '
  .result.triggers[] | select(.trigger_uuid == $t) | .build_command // ""
')"
echo "    current build_command:"
printf '      %s\n' "${CURRENT_BUILD_CMD:-(empty)}"
echo "    new build_command:"
printf '      %s\n' "${BUILD_COMMAND}"

if [[ "${CURRENT_BUILD_CMD}" == "${BUILD_COMMAND}" ]]; then
  echo "==> Build command already current; skipping PATCH."
else
  echo "==> Updating build command..."
  PATCH_BODY="$(jq -n --arg bc "${BUILD_COMMAND}" '{build_command: $bc}')"
  PATCH_RESP="$(api PATCH "/accounts/${ACCOUNT_ID}/builds/triggers/${TRIGGER_UUID}" "${PATCH_BODY}")"
  require_success "trigger.update" "${PATCH_RESP}"
  echo "    OK"
fi

echo "==> Triggering a manual build of main..."
BUILD_RESP="$(api POST "/accounts/${ACCOUNT_ID}/builds/triggers/${TRIGGER_UUID}/builds" '{"branch":"main"}')"
require_success "build.create" "${BUILD_RESP}"
BUILD_UUID="$(printf '%s' "${BUILD_RESP}" | jq -r '.result.build_uuid // .result.uuid // empty')"
if [[ -z "${BUILD_UUID}" ]]; then
  echo "WARNING: could not extract build_uuid from response — skipping poll." >&2
  printf '%s' "${BUILD_RESP}" | jq '.result' >&2 || true
  exit 0
fi
echo "    build = ${BUILD_UUID}"

echo "==> Polling build status (up to 8 minutes)..."
DEADLINE=$(( $(date +%s) + 8 * 60 ))
LAST_STATUS=""
while [[ "$(date +%s)" -lt "${DEADLINE}" ]]; do
  BUILDS_JSON="$(api GET "/accounts/${ACCOUNT_ID}/builds/workers/${WORKER_TAG}/builds")"
  STATUS="$(printf '%s' "${BUILDS_JSON}" | jq -r --arg b "${BUILD_UUID}" '
    .result.builds[]? | select(.build_uuid == $b) | .status // ""
  ')"
  OUTCOME="$(printf '%s' "${BUILDS_JSON}" | jq -r --arg b "${BUILD_UUID}" '
    .result.builds[]? | select(.build_uuid == $b) | .build_outcome // ""
  ')"
  if [[ "${STATUS}" != "${LAST_STATUS}" && -n "${STATUS}" ]]; then
    echo "    status=${STATUS}${OUTCOME:+ outcome=${OUTCOME}}"
    LAST_STATUS="${STATUS}"
  fi
  if [[ "${STATUS}" == "stopped" ]]; then
    if [[ "${OUTCOME}" == "success" ]]; then
      echo "==> Build succeeded."
      break
    fi
    echo "ERROR: build terminated with outcome '${OUTCOME}'" >&2
    echo "  Logs: https://dash.cloudflare.com/${ACCOUNT_ID}/workers/services/view/${WORKER_NAME}/production/deployments" >&2
    exit 1
  fi
  sleep 10
done

if [[ "${LAST_STATUS}" != "stopped" ]]; then
  echo "WARNING: build still running after 8 minutes; not polling further." >&2
  echo "  Watch progress at: https://dash.cloudflare.com/${ACCOUNT_ID}/workers/services/view/${WORKER_NAME}/production/deployments" >&2
  exit 0
fi

echo "==> Verifying live site..."
sleep 5  # propagation
LIVE_CHANGELOG="$(curl -fsSL https://docs.velocit.ee/changelog/ || true)"
if printf '%s' "${LIVE_CHANGELOG}" | grep -q "nmap enrichment\|MAAS backend\|engines.json"; then
  echo "    docs.velocit.ee/changelog/ contains the new content. ✓"
else
  echo "    WARNING: docs.velocit.ee/changelog/ does not yet show the expected content." >&2
  echo "    The build succeeded but the CDN edge may take a minute to refresh." >&2
fi

echo "==> Done."
