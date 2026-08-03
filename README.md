# ARM32SolderingStation

Public distribution repository for encrypted OTA firmware packages for the HC32F460 soldering station platform.

This repository is intended to publish release assets only:
- encrypted `.ota` firmware packages;
- optional checksums;
- release notes;
- GitHub Releases metadata.

This repository should not contain:
- application source code;
- bootloader source code;
- OTA encryption or HMAC keys;
- plaintext production firmware images.

## Suggested Layout

```text
packages/
  v1.0.0/
    ARM32SolderingStation-board_v1-v1.0.0.ota
    ARM32SolderingStation-board_v2-v1.0.0.ota
    SHA256SUMS.txt
release-notes/
  v1.0.0.md
```

## Asset Naming Convention

- `ARM32SolderingStation-board_v1-v<version>.ota`
- `ARM32SolderingStation-board_v2-v<version>.ota`

Each GitHub Release tag should correspond to one firmware version, for example `v1.0.0`, and should contain both board-specific encrypted OTA assets. The ESP32-C3 OTA sidecar filters release assets by `boardRevision`, so both board packages can safely live under the same GitHub Release.

Only the highest published firmware version keeps asset names ending in `.ota`.
After a newer release is published, the workflow renames older OTA assets to
`.ota.archived-<asset-id>`. This keeps the files recoverable while preventing
deployed sidecars from paginating through multiple compatible releases.

## Release Flow

1. In the private source repository, run `tools/publish_public_ota_release.py --version 1.0.0`.
2. The script builds encrypted OTA packages for both board revisions.
3. The script copies them into `packages/v1.0.0/`, updates `release-notes/v1.0.0.md`, commits, tags, and pushes.
4. This repository's GitHub Actions workflow publishes the GitHub Release automatically on tag push.

## Building Packages

Encrypted `.ota` packages are built in the private firmware repository with the OTA packaging tooling there, for example via `tools/build_ota_package.py`. The recommended publishing entry point is the private repo helper script `tools/publish_public_ota_release.py`.

## Security Notes

The published `.ota` assets are expected to be encrypted and authenticated before they are copied into this repository. This repository is public by design, so no secrets should ever be committed here.
