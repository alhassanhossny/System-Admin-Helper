#!/usr/bin/env bash

set -euo pipefail

PREFIX=${1:-/usr/local}
LIBDIR=${SAH_LIBDIR:-"$PREFIX/lib/system-admin-helper"}
BINDIR=${SAH_BINDIR:-"$PREFIX/sbin"}
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

install -d "$LIBDIR" "$BINDIR"
install -d "$LIBDIR/scripts"
tar --exclude='./logs' --exclude='./logs/*' -C "$SOURCE_DIR/scripts" -cf - . | tar -C "$LIBDIR/scripts" -xf -
find "$LIBDIR/scripts" -type f -name '*.sh' -exec chmod 755 {} +

if [ -e "$LIBDIR/scripts/logs" ] && [ ! -d "$LIBDIR/scripts/logs" ]; then
	mv "$LIBDIR/scripts/logs" "$LIBDIR/scripts/logs.legacy-$(date +%Y%m%d-%H%M%S)"
fi

cat >"$BINDIR/system-admin-helper" <<EOF
#!/usr/bin/env bash
exec "$LIBDIR/scripts/main.sh" "\$@"
EOF
chmod 755 "$BINDIR/system-admin-helper"

printf 'Installed System Admin Helper to %s\n' "$LIBDIR"
printf 'Launcher: %s/system-admin-helper\n' "$BINDIR"
