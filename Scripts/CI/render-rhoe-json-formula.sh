#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "error: $*" >&2
  exit 1
}

VERSION="${RHOE_JSON_VERSION:-}"
SOURCE_SHA256="${RHOE_JSON_SOURCE_SHA256:-}"
BOTTLE_ROOT="${RHOE_JSON_BOTTLE_ROOT:-https://github.com/RhoePlatform/homebrew-rhoe/releases/download/rhoe-json-${VERSION}}"
MACOS_SHA256="${RHOE_JSON_BOTTLE_SHA256_ARM64_TAHOE:-}"
LINUX_SHA256="${RHOE_JSON_BOTTLE_SHA256_X86_64_LINUX:-}"
OUTPUT="${1:-Formula/rhoe-json.rb}"
TEMPLATE="Formula/rhoe-json.rb.template"

[[ -f "$TEMPLATE" ]] || fail "Missing template: $TEMPLATE"
[[ "$VERSION" =~ ^[0-9]+[.][0-9]+[.][0-9]+([-.][0-9A-Za-z.-]+)?$ ]] || fail "Set RHOE_JSON_VERSION to a semantic version such as 0.1.0"
[[ "$SOURCE_SHA256" =~ ^[0-9a-f]{64}$ ]] || fail "Set RHOE_JSON_SOURCE_SHA256 to a 64-character lowercase sha256"

if [[ -n "$MACOS_SHA256" || -n "$LINUX_SHA256" ]]; then
  [[ "$MACOS_SHA256" =~ ^[0-9a-f]{64}$ ]] || fail "Set RHOE_JSON_BOTTLE_SHA256_ARM64_TAHOE to a 64-character lowercase sha256"
  [[ "$LINUX_SHA256" =~ ^[0-9a-f]{64}$ ]] || fail "Set RHOE_JSON_BOTTLE_SHA256_X86_64_LINUX to a 64-character lowercase sha256"
  BOTTLE_BLOCK=$(cat <<EOF
  bottle do
    root_url "$BOTTLE_ROOT"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "$MACOS_SHA256"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "$LINUX_SHA256"
  end
EOF
)
else
  BOTTLE_BLOCK=""
fi

mkdir -p "$(dirname "$OUTPUT")"

python3 - "$TEMPLATE" "$OUTPUT" "$VERSION" "$SOURCE_SHA256" "$BOTTLE_BLOCK" <<'PY'
from pathlib import Path
import sys

template_path, output_path, version, source_sha256, bottle_block = sys.argv[1:]
text = Path(template_path).read_text(encoding="utf-8")
text = text.replace("__VERSION__", version)
text = text.replace("__SOURCE_SHA256__", source_sha256)
bottle_block = bottle_block.rstrip()
if bottle_block:
    bottle_block = f"\n{bottle_block}\n"
text = text.replace("__BOTTLE_BLOCK__", bottle_block)
Path(output_path).write_text(text, encoding="utf-8")
PY

ruby -c "$OUTPUT" >/dev/null
echo "Rendered $OUTPUT"
