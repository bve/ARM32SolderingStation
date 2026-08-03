#!/usr/bin/env bash

set -euo pipefail

readonly asset_prefix="ARM32SolderingStation-board_v"
readonly repository="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
readonly releases_endpoint="repos/${repository}/releases?per_page=100"

latest_tag="$({
  gh api --paginate "${releases_endpoint}" \
    --jq ".[]
      | select(.draft == false)
      | select(any(.assets[]?; (.name | startswith(\"${asset_prefix}\") and endswith(\".ota\"))))
      | .tag_name"
} | sort -V | tail -n 1)"

if [[ -z "${latest_tag}" ]]; then
  echo "No published OTA release assets found"
  exit 0
fi

echo "Keeping OTA assets public for ${latest_tag}"

while IFS=$'\t' read -r release_tag asset_id asset_name; do
  if [[ "${release_tag}" == "${latest_tag}" ]]; then
    continue
  fi

  archived_name="${asset_name}.archived-${asset_id}"
  if [[ "${OTA_ARCHIVE_DRY_RUN:-0}" == "1" ]]; then
    echo "Would archive ${release_tag}/${asset_name} as ${archived_name}"
    continue
  fi

  gh api --method PATCH \
    "repos/${repository}/releases/assets/${asset_id}" \
    -f "name=${archived_name}" \
    --silent
  echo "Archived ${release_tag}/${asset_name} as ${archived_name}"
done < <(
  gh api --paginate "${releases_endpoint}" \
    --jq ".[]
      | select(.draft == false)
      | .tag_name as \$release_tag
      | .assets[]?
      | select(.name | startswith(\"${asset_prefix}\") and endswith(\".ota\"))
      | [\$release_tag, (.id | tostring), .name]
      | @tsv"
)
