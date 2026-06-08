# Rhoe Homebrew Tap

Official Homebrew tap for RhoePlatform command-line tools.

This repository is the distribution lane for installable Rhoe CLIs. It starts
with `rhoe-liquid`, the Homebrew formula for the RhoeLiquid `liquid` and
`rhoelq` executables; `rhoe-markdown`, the Homebrew formula for the RhoeMarkdown
`rhoemd` and `markdown` compiler commands; and `rhoe-json`, the Homebrew formula
for the RhoeJSON `rhoejson`, `rhoejn`, and `json` commands. The same pattern
will extend to RhoeCharts and future foundation engines.

## Status

This tap is source-formula plus bottle driven. Each installable formula is
rendered from a checked-in template after the matching source repository has a
reviewed `vX.Y.Z` tag, source archive checksum, and bottle artifacts.

## Install

After the first public release:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-liquid
liquid --version
rhoelq --version
```

Install the Markdown compiler:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-markdown
rhoemd --version
markdown --version
```

Install the JSON engine:

```bash
brew tap RhoePlatform/rhoe
brew install rhoe-json
rhoejson --version
rhoejn --version
json --version
```

The formula names are intentionally product-oriented:

| Formula | Executables |
| --- | --- |
| `rhoe-liquid` | `liquid`, `rhoelq` |
| `rhoe-markdown` | `rhoemd`, `markdown` |
| `rhoe-json` | `rhoejson`, `rhoejn`, `json` |

## Formulae

| Formula | Executables | Status | Source repo |
| --- | --- | --- | --- |
| `rhoe-liquid` | `liquid`, `rhoelq` | `v0.1.x` release lane | `RhoePlatform/RhoeLiquid` |
| `rhoe-markdown` | `rhoemd`, `markdown` | `v0.1.0` release lane | `RhoePlatform/RhoeMarkdown` |
| `rhoe-json` | `rhoejson`, `rhoejn`, `json` | `v0.1.0` release lane | `RhoePlatform/RhoeJSON` |

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

Render the RhoeMarkdown formula:

```bash
RHOE_MARKDOWN_VERSION=0.1.0 \
RHOE_MARKDOWN_SOURCE_SHA256=<source-archive-sha256> \
RHOE_MARKDOWN_BOTTLE_SHA256_ARM64_TAHOE=<macos-26-arm64-bottle-sha256> \
RHOE_MARKDOWN_BOTTLE_SHA256_X86_64_LINUX=<linux-x86_64-bottle-sha256> \
make render-rhoe-markdown-formula
```

Render the RhoeJSON formula:

```bash
RHOE_JSON_VERSION=0.1.0 \
RHOE_JSON_SOURCE_SHA256=<source-archive-sha256> \
RHOE_JSON_BOTTLE_SHA256_ARM64_TAHOE=<macos-26-arm64-bottle-sha256> \
RHOE_JSON_BOTTLE_SHA256_X86_64_LINUX=<linux-x86_64-bottle-sha256> \
make render-rhoe-json-formula
```

Rendered formulas are written to `Formula/<formula>.rb`.

For the integrated release lanes, dispatch the `RhoeLiquid Bottles`,
`RhoeMarkdown Bottles`, or `RhoeJSON Bottles` workflow with the source tag
version and source archive checksum. The workflow renders the source formula,
builds bottles for `arm64_tahoe` and `x86_64_linux`, publishes bottle assets
when requested, computes bottle checksums, and commits the final formula when
`commit_formula=true`.

## Release Model

1. Certify and tag the source repository.
2. Compute the `vX.Y.Z` source archive checksum.
3. Render the formula from its `Formula/*.rb.template`.
4. Build bottles on `macos-26` and `ubuntu-24.04`.
5. Publish bottles to this tap's GitHub Releases.
6. Commit the final formula with the source checksum and bottle block.
7. Run `brew tap RhoePlatform/rhoe && brew install <formula>` as the final
   public smoke test.

## Naming

The GitHub repository name should be `RhoePlatform/homebrew-rhoe`. Homebrew maps
the short tap command `brew tap RhoePlatform/rhoe` to that repository.

## License

This tap infrastructure is released under the Apache License 2.0. Individual
formulae declare their upstream project licenses in the formula body.
