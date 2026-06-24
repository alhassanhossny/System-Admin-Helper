#!/usr/bin/env bash

set -euo pipefail

PREFIX=${1:-/usr/local}
LIBDIR=${SAH_LIBDIR:-"$PREFIX/lib/system-admin-helper"}
BINDIR=${SAH_BINDIR:-"$PREFIX/sbin"}

rm -f "$BINDIR/system-admin-helper"
rm -rf "$LIBDIR"

printf 'Removed System Admin Helper from %s\n' "$PREFIX"
