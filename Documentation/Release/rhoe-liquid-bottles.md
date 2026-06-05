# RhoeLiquid Bottle Release Runbook

This tap publishes bottles for the `rhoe-liquid` formula after the source
repository has a certified tag.

## Preconditions

- `RhoePlatform/RhoeLiquid` exists and is public or accessible to Homebrew.
- `vX.Y.Z` is pushed in the source repository.
- The source archive checksum is computed and reviewed.
- `Formula/rhoe-liquid.rb` has been rendered from the template.
- `make check` passes in this tap.

## Targets

- `arm64_tahoe`: macOS 26 on Apple Silicon.
- `x86_64_linux`: Linux x86-64 through Linuxbrew.

## Sequence

1. Run the `RhoeLiquid Bottles` workflow with the source `version` and
   `source_sha256`.
2. Use `publish_release=true` to upload bottle assets to the tap release.
3. Use `commit_formula=true` only after the source release is certified and the
   tap release should become installable.
4. Inspect the generated final formula artifact and committed
   `Formula/rhoe-liquid.rb`.
5. Smoke test:

```bash
brew untap RhoePlatform/rhoe || true
brew tap RhoePlatform/rhoe
brew install rhoe-liquid
liquid --version
rhoelq --version
liquid render --help
```

## Notes

The formula name is intentionally `rhoe-liquid` while the installed commands are
the friendly `liquid` executable and the compact RhoePlatform-qualified
`rhoelq` alias. This prevents generic formula-name ambiguity while preserving
the CLI names users type day to day.
