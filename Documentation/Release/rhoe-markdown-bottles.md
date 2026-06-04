# RhoeMarkdown Bottle Release Runbook

This tap publishes bottles for the `rhoe-markdown` formula after the source
repository has a certified `vX.Y.Z` tag. The installed executable is `rhoemd`.

## Preconditions

- `RhoePlatform/RhoeMarkdown` exists and is public or otherwise reachable by
  Homebrew during bottle builds.
- The `vX.Y.Z` source tag has passed the RhoeMarkdown release-candidate gate.
- The source archive SHA-256 has been computed from
  `https://github.com/RhoePlatform/RhoeMarkdown/archive/refs/tags/vX.Y.Z.tar.gz`.
- `RhoePlatform/RhoeLiquid` has a compatible public tag for the dependency
  range declared by RhoeMarkdown.

## Workflow

1. Run the `RhoeMarkdown Bottles` workflow with the source `version` and
   `source_sha256`.
2. Set `publish_release=true` to upload bottle artifacts to the tap release.
3. Set `commit_formula=true` only after confirming both bottles and checksums
   are correct.
4. The workflow renders `Formula/rhoe-markdown.rb`, builds macOS and Linux
   bottles, publishes download aliases, computes checksums, and writes the final
   bottle block.

## Smoke Test

After the formula commit lands:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-markdown
rhoemd --version
```

The formula name is intentionally `rhoe-markdown`, while the executable remains
the compact compiler command `rhoemd`.
