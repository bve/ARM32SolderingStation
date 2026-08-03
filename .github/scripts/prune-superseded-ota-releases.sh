#!/usr/bin/env bash

set -euo pipefail

readonly repository="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
readonly releases_endpoint="repos/${repository}/releases?per_page=100"

latest_tag="$({
  gh api --paginate "${releases_endpoint}" \
    --jq ".[]
      | select(.draft == false)
      | select(.tag_name | test(\"^v[0-9]+(\\\\.[0-9]+)+\"))
      | .tag_name"
} | sort -V | tail -n 1)"

if [[ -z "${latest_tag}" ]]; then
  echo "No published versioned OTA releases found"
  exit 0
fi

echo "Keeping GitHub Release ${latest_tag} public"

while IFS=$'\t' read -r release_tag release_id; do
  if [[ "${release_tag}" == "${latest_tag}" ]]; then
    continue
  fi

  if [[ "${OTA_PRUNE_DRY_RUN:-0}" == "1" ]]; then
    echo "Would remove GitHub Release ${release_tag}; tag and repository files remain"
    continue
  fi

  gh api --method DELETE \
    "repos/${repository}/releases/${release_id}" \
    --silent
  echo "Removed GitHub Release ${release_tag}; tag and repository files remain"
done < <(
  gh api --paginate "${releases_endpoint}" \
    --jq ".[]
      | select(.draft == false)
      | select(.tag_name | test(\"^v[0-9]+(\\\\.[0-9]+)+\"))
      | [.tag_name, (.id | tostring)]
      | @tsv"
)
