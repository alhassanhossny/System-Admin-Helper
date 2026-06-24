#!/usr/bin/env bash

set -euo pipefail

while IFS= read -r file; do
	bash -n "$file"
done < <(find . -type f -name '*.sh' -print)

if ! command -v bats >/dev/null 2>&1; then
	printf 'bats is not installed; Bash syntax checks passed and Bats tests were skipped.\n'
	exit 0
fi

bats test/*.bats
