#!/usr/bin/env bash
# the committed unicode tables and api reference must be exactly what a fresh run
# generates. they do not depend on the host, so the primary leg checks them once
set -euo pipefail

[ "${MACH_CI_PRIMARY:-}" = true ] || exit 0
python3 tools/unicode-tables --check

rm -rf out/docgen
"$MACH_COMPILER" doc . --out out/docgen -q
diff -r out/docgen/regex doc/regex
diff out/docgen/README.md doc/README.md
