#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "error: $*" >&2
  exit 1
}

[[ -f README.md ]] || fail "Missing README.md"
[[ -f LICENSE ]] || fail "Missing LICENSE"
[[ -f Formula/rhoe-liquid.rb.template ]] || fail "Missing RhoeLiquid formula template"
[[ -f Formula/rhoe-markdown.rb.template ]] || fail "Missing RhoeMarkdown formula template"
[[ -x Scripts/CI/prepare-homebrew-bottle-assets.sh ]] || fail "Bottle asset preparation helper is not executable"
[[ -x Scripts/CI/render-rhoe-liquid-formula.sh ]] || fail "Formula renderer is not executable"
[[ -x Scripts/CI/render-rhoe-markdown-formula.sh ]] || fail "RhoeMarkdown formula renderer is not executable"

grep -Fq "brew tap RhoePlatform/rhoe" README.md || fail "README must document the canonical tap command"
grep -Fq "brew install rhoe-liquid" README.md || fail "README must document the canonical install command"
grep -Fq "brew install rhoe-markdown" README.md || fail "README must document the RhoeMarkdown install command"
grep -Fq "rhoelq --version" README.md || fail "README must document the RhoeLiquid alias command"
grep -Fq "markdown --version" README.md || fail "README must document the RhoeMarkdown alias command"
grep -Fq "class RhoeLiquid < Formula" Formula/rhoe-liquid.rb.template || fail "Formula template must define class RhoeLiquid"
grep -Fq "class RhoeMarkdown < Formula" Formula/rhoe-markdown.rb.template || fail "Formula template must define class RhoeMarkdown"
grep -Fq 'bin.install_symlink bin/"liquid" => "rhoelq"' Formula/rhoe-liquid.rb.template || fail "RhoeLiquid formula template must install rhoelq alias"
grep -Fq "rhoemd" Formula/rhoe-markdown.rb.template || fail "RhoeMarkdown formula template must install rhoemd"
grep -Fq 'bin.install_symlink bin/"rhoemd" => "markdown"' Formula/rhoe-markdown.rb.template || fail "RhoeMarkdown formula template must install markdown alias"
grep -Fq 'rhoemd-preview-menu' Formula/rhoe-markdown.rb.template || fail "RhoeMarkdown formula template must install the macOS preview menu companion"
grep -Fq "arm64_tahoe" README.md || fail "README must document the macOS 26 Apple Silicon bottle target"
grep -Fq "x86_64_linux" README.md || fail "README must document the Linux x86-64 bottle target"

if find . -name .DS_Store -print | grep -q .; then
  fail "Remove .DS_Store files before release"
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/rhoe-homebrew-tap.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

RHOE_LIQUID_VERSION=0.1.0 \
RHOE_LIQUID_SOURCE_SHA256=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
RHOE_LIQUID_BOTTLE_SHA256_ARM64_TAHOE=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
RHOE_LIQUID_BOTTLE_SHA256_X86_64_LINUX=cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc \
  bash Scripts/CI/render-rhoe-liquid-formula.sh "$tmp_dir/rhoe-liquid.rb" >/dev/null

ruby -c "$tmp_dir/rhoe-liquid.rb" >/dev/null
grep -Fq 'root_url "https://github.com/RhoePlatform/homebrew-rhoe/releases/download/rhoe-liquid-0.1.0"' "$tmp_dir/rhoe-liquid.rb" || fail "Rendered formula must use the tap release bottle root"
grep -Fq 'sha256 cellar: :any_skip_relocation, arm64_tahoe:' "$tmp_dir/rhoe-liquid.rb" || fail "Rendered formula must include macOS 26 Apple Silicon bottle checksum"
grep -Fq 'sha256 cellar: :any_skip_relocation, x86_64_linux:' "$tmp_dir/rhoe-liquid.rb" || fail "Rendered formula must include Linux x86-64 bottle checksum"
grep -Fq 'bin.install_symlink bin/"liquid" => "rhoelq"' "$tmp_dir/rhoe-liquid.rb" || fail "Rendered formula must install rhoelq alias"

RHOE_MARKDOWN_VERSION=0.1.0 \
RHOE_MARKDOWN_SOURCE_SHA256=dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd \
RHOE_MARKDOWN_BOTTLE_SHA256_ARM64_TAHOE=eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee \
RHOE_MARKDOWN_BOTTLE_SHA256_X86_64_LINUX=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff \
  bash Scripts/CI/render-rhoe-markdown-formula.sh "$tmp_dir/rhoe-markdown.rb" >/dev/null

ruby -c "$tmp_dir/rhoe-markdown.rb" >/dev/null
grep -Fq 'root_url "https://github.com/RhoePlatform/homebrew-rhoe/releases/download/rhoe-markdown-0.1.0"' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must use the tap release bottle root"
grep -Fq 'sha256 cellar: :any_skip_relocation, arm64_tahoe:' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must include macOS 26 Apple Silicon bottle checksum"
grep -Fq 'sha256 cellar: :any_skip_relocation, x86_64_linux:' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must include Linux x86-64 bottle checksum"
grep -Fq 'bin.install_symlink bin/"rhoemd" => "markdown"' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must install markdown alias"
grep -Fq 'rhoemd-preview-menu' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must install the macOS preview menu companion"
grep -Fq 'assert_path_exists bin/"rhoemd-preview-menu"' "$tmp_dir/rhoe-markdown.rb" || fail "Rendered RhoeMarkdown formula must style-check the macOS preview menu companion"

if [[ "${RHOE_TAP_BREW_STYLE:-0}" == "1" ]] && command -v brew >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew style --formula "$tmp_dir/rhoe-liquid.rb" >/dev/null
  HOMEBREW_NO_AUTO_UPDATE=1 brew style --formula "$tmp_dir/rhoe-markdown.rb" >/dev/null
fi

echo "Homebrew tap validation passed."
