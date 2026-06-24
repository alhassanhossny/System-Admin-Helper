#!/usr/bin/env bash

set -euo pipefail

PREFIX=${1:-/usr/local}
LIBDIR=${SAH_LIBDIR:-"$PREFIX/lib/system-admin-helper"}
BINDIR=${SAH_BINDIR:-"$PREFIX/sbin"}
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

install -d "$LIBDIR" "$BINDIR"
cp -R "$SOURCE_DIR/scripts" "$LIBDIR/"
find "$LIBDIR/scripts" -type f -name '*.sh' -exec chmod 755 {} +

cat >"$BINDIR/system-admin-helper" <<EOF
#!/usr/bin/env bash
exec "$LIBDIR/scripts/main.sh" "\$@"
EOF
chmod 755 "$BINDIR/system-admin-helper"

printf 'Installed System Admin Helper to %s\n' "$LIBDIR"
printf 'Launcher: %s/system-admin-helper\n' "$BINDIR"
