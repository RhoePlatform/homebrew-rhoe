#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SEARCH_ROOT="${1:-.}"
OUTPUT_FILE="${GITHUB_OUTPUT:-}"

fail() {
  echo "error: $*" >&2
  exit 1
}

[[ -d "$SEARCH_ROOT" ]] || fail "Bottle artifact directory does not exist: $SEARCH_ROOT"

python3 - "$SEARCH_ROOT" "$OUTPUT_FILE" <<'PY'
from pathlib import Path
import hashlib
import sys

root = Path(sys.argv[1])
output_file = sys.argv[2]

targets = {
    "arm64_tahoe": None,
    "x86_64_linux": None,
}

for archive in sorted(root.rglob("*.tar.gz")):
    name = archive.name
    for target in targets:
        if target in name:
            digest = hashlib.sha256(archive.read_bytes()).hexdigest()
            candidate = (archive, digest)
            if targets[target] is None:
                targets[target] = candidate
                continue
            current = targets[target]
            def score(value):
                candidate_archive = value[0]
                candidate_name = candidate_archive.name
                return (
                    0 if "--" not in candidate_name else 1,
                    0 if ".bottle." not in candidate_name.replace(".bottle.tar.gz", "") else 1,
                    0 if "homebrew-download-aliases" in candidate_archive.parts else 1,
                    candidate_name,
                )
            if score(candidate) < score(current):
                targets[target] = candidate

missing = [target for target, value in targets.items() if value is None]
if missing:
    print(f"error: missing bottle archive(s) for {', '.join(missing)} under {root}", file=sys.stderr)
    sys.exit(1)

lines = []
for target, (archive, digest) in targets.items():
    key = {
        "arm64_tahoe": "arm64_tahoe_sha256",
        "x86_64_linux": "x86_64_linux_sha256",
    }[target]
    lines.append(f"{key}={digest}")
    print(f"{target}: {digest} ({archive})")

if output_file:
    with open(output_file, "a", encoding="utf-8") as handle:
        for line in lines:
            handle.write(line + "\n")
PY
