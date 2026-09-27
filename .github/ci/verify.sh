#!/usr/bin/env bash
# the committed unicode tables must be exactly what the pinned ucd generates.
# they do not depend on the host, so the primary leg checks them once
set -euo pipefail

[ "${MACH_CI_PRIMARY:-}" = true ] || exit 0
python3 tools/unicode-tables --check
