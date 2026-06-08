# RhoeJSON Bottle Release Runbook

This tap publishes bottles for the `rhoe-json` formula after the source
repository has a certified `vX.Y.Z` tag. The installed executables are
`rhoejson`, `rhoejn`, and `json`; macOS bottles also include
`rhoejson-preview-menu`.

## Preconditions

- `RhoePlatform/RhoeJSON` exists and is public or otherwise reachable by
  Homebrew during bottle builds.
- The `vX.Y.Z` source tag has passed the RhoeJSON release-candidate gate.
- The source archive SHA-256 has been computed from
  `https://github.com/RhoePlatform/RhoeJSON/archive/refs/tags/vX.Y.Z.tar.gz`.
- The public formula template has passed `bash Scripts/CI/validate-tap.sh`.

## Workflow

1. Run the `RhoeJSON Bottles` workflow with the source `version` and
   `source_sha256`.
2. Set `publish_release=true` to upload bottle artifacts to the tap release.
3. Set `commit_formula=true` only after confirming both bottles and checksums
   are correct.
4. The workflow renders `Formula/rhoe-json.rb`, builds macOS and Linux bottles,
   publishes download aliases, computes checksums, and writes the final bottle
   block.

## Smoke Test

After the formula commit lands:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-json
rhoejson --version
rhoejn --version
json --version
rhoejson jq '.records[] | select(.active) | .name' input.json --raw
```

The formula name is intentionally `rhoe-json`, while the installed commands
provide the canonical compiler command `rhoejson`, the compact Rhoe alias
`rhoejn`, and the convenience alias `json`.
