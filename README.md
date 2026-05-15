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
    HC32F460SolderingStation-board_v1-v1.0.0.ota
    HC32F460SolderingStation-board_v2-v1.0.0.ota
    SHA256SUMS.txt
release-notes/
  v1.0.0.md
```

## Release Flow

1. Build encrypted OTA packages in the private source repository.
2. Copy the resulting `.ota` files into `packages/<version>/`.
3. Add optional notes into `release-notes/<version>.md`.
4. Commit and push the changes.
5. Run the `Publish OTA Release` GitHub Actions workflow.

## Building Packages

Encrypted `.ota` packages are expected to be built in the main firmware repository with the OTA packaging tooling there, for example via `tools/build_ota_package.py`.

## Security Notes

The published `.ota` assets are expected to be encrypted and authenticated before they are copied into this repository. This repository is public by design, so no secrets should ever be committed here.
