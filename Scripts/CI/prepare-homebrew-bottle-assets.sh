#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

FORMULA="${1:-}"
VERSION="${2:-}"
SEARCH_ROOT="${3:-}"

fail() {
  echo "error: $*" >&2
  exit 1
}

[[ -n "$FORMULA" ]] || fail "Missing formula name"
[[ -n "$VERSION" ]] || fail "Missing formula version"
[[ -d "$SEARCH_ROOT" ]] || fail "Bottle artifact directory does not exist: $SEARCH_ROOT"

python3 - "$FORMULA" "$VERSION" "$SEARCH_ROOT" <<'PY'
from pathlib import Path
import re
import shutil
import sys

formula = sys.argv[1]
version = sys.argv[2]
root = Path(sys.argv[3])
alias_dir = root / "homebrew-download-aliases"
alias_dir.mkdir(parents=True, exist_ok=True)

assets = sorted(
    path for path in root.rglob("*")
    if path.is_file() and (path.name.endswith(".tar.gz") or path.name.endswith(".json"))
)

if not assets:
    print(f"error: no bottle assets found under {root}", file=sys.stderr)
    sys.exit(1)

created = []
double_prefix = f"{formula}--{version}"
single_prefix = f"{formula}-{version}"
rebuild_suffix = re.compile(r"(\.bottle)\.\d+(\.tar\.gz)$")

for asset in assets:
    names = {asset.name}
    if asset.name.startswith(double_prefix):
        names.add(single_prefix + asset.name[len(double_prefix):])

    for name in list(names):
        canonical = rebuild_suffix.sub(r"\1\2", name)
        names.add(canonical)

    for name in sorted(names):
        if name == asset.name:
            continue
        destination = alias_dir / name
        if destination.exists() and destination.read_bytes() == asset.read_bytes():
            continue
        shutil.copy2(asset, destination)
        created.append(destination)

for path in created:
    print(f"prepared {path}")
PY
