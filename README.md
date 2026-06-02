# Rhoe Homebrew Tap

Official Homebrew tap for RhoePlatform command-line tools.

This repository is the distribution lane for installable Rhoe CLIs. It starts
with `rhoe-liquid`, the Homebrew formula for the RhoeLiquid `liquid` executable,
and is designed to grow into the shared tap for RhoeMarkdown, RhoeJSON,
RhoeCharts, and future foundation engines.

## Status

This tap is staged ahead of the first public `RhoeLiquid` release. The
installable `Formula/rhoe-liquid.rb` file is generated only after the
`RhoePlatform/RhoeLiquid` source repository has a reviewed `v0.1.0` tag,
source archive checksum, and bottle artifacts.

Until that release exists, this repository contains the tap infrastructure:
formula templates, bottle workflow scaffolding, validation scripts, and release
documentation.

## Install

After the first public release:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-liquid
liquid --version
```

The formula name is `rhoe-liquid`; the installed executable is `liquid`.

## Formulae

| Formula | Executable | Status | Source repo |
| --- | --- | --- | --- |
| `rhoe-liquid` | `liquid` | `v0.1.0` staging | `RhoePlatform/RhoeLiquid` |

## Bottle Targets

The first bottle lane targets:

| Homebrew target | Platform |
| --- | --- |
| `arm64_tahoe` | macOS 26 on Apple Silicon |
| `x86_64_linux` | Linux x86-64 through Linuxbrew |

Source builds remain available for maintainers and advanced users, but the
public user experience should be bottle-first.

## Maintainer Workflow

Validate the tap scaffold:

```bash
make check
```

Render a release formula after the source tag checksum and bottle checksums are
known:

```bash
RHOE_LIQUID_VERSION=0.1.0 \
RHOE_LIQUID_SOURCE_SHA256=<source-archive-sha256> \
RHOE_LIQUID_BOTTLE_SHA256_ARM64_TAHOE=<macos-26-arm64-bottle-sha256> \
RHOE_LIQUID_BOTTLE_SHA256_X86_64_LINUX=<linux-x86_64-bottle-sha256> \
make render-rhoe-liquid-formula
```

The rendered formula is written to `Formula/rhoe-liquid.rb`.

For the integrated release lane, dispatch the `RhoeLiquid Bottles` workflow with
the source tag version and source archive checksum. It renders the source
formula, builds bottles for `arm64_tahoe` and `x86_64_linux`, publishes bottle
assets when requested, computes bottle checksums, and commits the final formula
when `commit_formula=true`.

## Release Model

1. Certify and tag `RhoePlatform/RhoeLiquid`.
2. Compute the `vX.Y.Z` source archive checksum.
3. Render `Formula/rhoe-liquid.rb` from `Formula/rhoe-liquid.rb.template`.
4. Build bottles on `macos-26` and `ubuntu-24.04`.
5. Publish bottles to this tap's GitHub Releases.
6. Commit the final formula with the source checksum and bottle block.
7. Run `brew tap RhoePlatform/rhoe && brew install rhoe-liquid` as the final
   public smoke test.

## Naming

The GitHub repository name should be `RhoePlatform/homebrew-rhoe`. Homebrew maps
the short tap command `brew tap RhoePlatform/rhoe` to that repository.

## License

This tap infrastructure is released under the Apache License 2.0. Individual
formulae declare their upstream project licenses in the formula body.
