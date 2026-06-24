#!/usr/bin/env bash
#
# Restore /etc account database files from a backup created by System Admin Helper.

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
source ./func.sh

backup_path=${1:-}

if [ "$(id -u)" -ne 0 ]; then
	show_message "Privileges Error!" "Error! Please run as root user."
	exit 1
fi

if [ -z "$backup_path" ]; then
	show_message "Usage" "Usage: sudo ./restore-backup.sh /path/to/backup-directory"
	exit 2
fi

if [ ! -d "$backup_path" ]; then
	show_message "Backup Error" "Backup directory was not found: $backup_path"
	exit 2
fi

for required_file in passwd group shadow gshadow; do
	if [ ! -f "$backup_path/$required_file" ]; then
		show_message "Backup Error" "Missing backup file: $backup_path/$required_file"
		exit 2
	fi
done

if command -v whiptail >/dev/null 2>&1 && [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
	if ! whiptail --title "Restore Account Database" --yesno "Restore passwd/group/shadow/gshadow from:

$backup_path

This overwrites current account database files. Continue?" 12 78; then
		audit_log "restore_backup" "$backup_path" "cancelled" "restore account database"
		exit 130
	fi
elif [ "${SAH_ASSUME_YES:-0}" != "1" ]; then
	printf 'Restore preview: %s\nSet SAH_ASSUME_YES=1 to restore non-interactively.\n' "$backup_path" >&2
	exit 130
fi

run_admin_command "restore_backup" "$backup_path" cp -p "$backup_path/passwd" /etc/passwd
run_admin_command "restore_backup" "$backup_path" cp -p "$backup_path/group" /etc/group
run_admin_command "restore_backup" "$backup_path" cp -p "$backup_path/shadow" /etc/shadow
run_admin_command "restore_backup" "$backup_path" cp -p "$backup_path/gshadow" /etc/gshadow

show_message "Restore Complete" "Account database files were restored from:
$backup_path"
