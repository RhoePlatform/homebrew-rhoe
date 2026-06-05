# Formula Directory

This directory keeps one template per RhoePlatform CLI formula.

Generated formula files are committed only after the matching source tag,
source archive checksum, and bottle checksums are available. Keeping the tap
template-driven avoids publishing formulas with placeholder checksums or URLs
that cannot yet be installed.

| Formula | Executables | Template |
| --- | --- | --- |
| `rhoe-liquid` | `liquid`, `rhoelq` | `Formula/rhoe-liquid.rb.template` |
| `rhoe-markdown` | `rhoemd`, `markdown` | `Formula/rhoe-markdown.rb.template` |
