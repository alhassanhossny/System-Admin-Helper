#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SAH_LOG_DIR:-$SCRIPT_DIR/logs}"
LOG_FILE="${SAH_LOG_FILE:-$LOG_DIR/commands.log}"
AUDIT_LOG_FILE="${SAH_AUDIT_LOG_FILE:-$LOG_DIR/audit.log}"
BACKUP_DIR="${SAH_BACKUP_DIR:-$LOG_DIR/backups}"

resize_window() {
	if command -v resize >/dev/null 2>&1; then
		eval "$(resize)" >/dev/null 2>&1 || true
	fi

	if [ -z "${LINES:-}" ]; then
		LINES=$(tput lines 2>/dev/null || printf '24')
	fi
	if [ -z "${COLUMNS:-}" ]; then
		COLUMNS=$(tput cols 2>/dev/null || printf '80')
	fi

	export LINES COLUMNS
}

show_message() {
	local title=$1
	local message=$2
	if command -v whiptail >/dev/null 2>&1 && [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
		whiptail --title "$title" --msgbox "$message" 8 78
	else
		printf '%s: %s\n' "$title" "$message" >&2
	fi
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

user_exists() {
	getent passwd "$1" >/dev/null
}

group_exists() {
	getent group "$1" >/dev/null
}

uid_exists() {
	getent passwd | awk -F: -v uid="$1" '$3 == uid { found = 1 } END { exit !found }'
}

gid_exists() {
	getent group | awk -F: -v gid="$1" '$3 == gid { found = 1 } END { exit !found }'
}

function isValidUsername {
	local re='^[[:lower:]_][[:lower:][:digit:]_-]{1,15}$'
	(( ${#1} > 16 )) && return 1
	[[ $1 =~ $re ]]
}

function isValidDate {
	local re='^[2-9][0-9]{3}-[01][0-9]-[0-3][0-9]$'
	(( ${#1} != 10 )) && return 1
	[[ $1 =~ $re ]] && [ "$(date --date="$1" +%s)" -gt "$(date --date="$(date '+%Y-%m-%d')" +%s)" ]
}

function isValidDir {
	local re='^/[a-zA-Z0-9\/]*$'
	[[ $1 =~ $re ]]
}

function isValidGroups {
	local re='^[[:alnum:]]+([[:alnum:]\,]*[[:alnum:]]+)?$'
	[[ $1 =~ $re ]]
}

# shellcheck source=lib/admin-actions.sh
source "$SCRIPT_DIR/lib/admin-actions.sh"
