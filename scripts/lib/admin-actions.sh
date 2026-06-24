#!/usr/bin/env bash

is_dry_run() {
	[ "${SAH_DRY_RUN:-0}" = "1" ]
}

json_escape() {
	local value=${1:-}
	value=${value//\\/\\\\}
	value=${value//\"/\\\"}
	value=${value//$'\n'/\\n}
	printf '%s' "$value"
}

format_command() {
	local output=""
	local quoted
	for arg in "$@"; do
		printf -v quoted '%q' "$arg"
		output="${output}${quoted} "
	done
	printf '%s' "${output% }"
}

audit_log() {
	local action=$1
	local target=$2
	local status=$3
	local command_text=$4
	local details=${5:-}
	local admin_user
	local timestamp

	mkdir -p "$(dirname "$AUDIT_LOG_FILE")"
	admin_user=$(id -un 2>/dev/null || printf 'unknown')
	timestamp=$(date -Is)

	printf '{"timestamp":"%s","admin":"%s","action":"%s","target":"%s","status":"%s","dry_run":%s,"command":"%s","details":"%s"}\n' \
		"$(json_escape "$timestamp")" \
		"$(json_escape "$admin_user")" \
		"$(json_escape "$action")" \
		"$(json_escape "$target")" \
		"$(json_escape "$status")" \
		"$(is_dry_run && printf true || printf false)" \
		"$(json_escape "$command_text")" \
		"$(json_escape "$details")" >>"$AUDIT_LOG_FILE"
}

confirm_admin_command() {
	local title=$1
	local command_text=$2

	if is_dry_run; then
		show_message "Dry Run" "No system changes will be made.

Command:
$command_text"
		return 0
	fi

	if command -v whiptail >/dev/null 2>&1 && [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
		whiptail --title "$title" --yesno "Review the command before running it:

$command_text

Continue?" 12 78
		return $?
	fi

	if [ "${SAH_ASSUME_YES:-0}" = "1" ]; then
		printf 'Running: %s\n' "$command_text" >&2
		return 0
	fi

	printf 'Command preview: %s\nSet SAH_ASSUME_YES=1 to run non-interactively.\n' "$command_text" >&2
	return 130
}

run_admin_command() {
	local action=$1
	local target=$2
	shift 2
	local command_text
	local status

	command_text=$(format_command "$@")

	if ! confirm_admin_command "$action" "$command_text"; then
		audit_log "$action" "$target" "cancelled" "$command_text"
		return 130
	fi

	if is_dry_run; then
		audit_log "$action" "$target" "dry-run" "$command_text"
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	"$@" >>"$LOG_FILE" 2>&1
	status=$?

	if [ "$status" -eq 0 ]; then
		audit_log "$action" "$target" "success" "$command_text"
	else
		audit_log "$action" "$target" "failed" "$command_text" "exit_status=$status"
	fi

	return "$status"
}

run_sensitive_command() {
	local action=$1
	local target=$2
	local redacted_command=$3
	shift 3
	local status

	if ! confirm_admin_command "$action" "$redacted_command"; then
		audit_log "$action" "$target" "cancelled" "$redacted_command"
		return 130
	fi

	if is_dry_run; then
		audit_log "$action" "$target" "dry-run" "$redacted_command"
		return 0
	fi

	mkdir -p "$(dirname "$LOG_FILE")"
	"$@" >>"$LOG_FILE" 2>&1
	status=$?

	if [ "$status" -eq 0 ]; then
		audit_log "$action" "$target" "success" "$redacted_command"
	else
		audit_log "$action" "$target" "failed" "$redacted_command" "exit_status=$status"
	fi

	return "$status"
}

set_user_password() {
	local username=$1
	local password=$2

	if passwd --help 2>&1 | grep -q -- '--stdin'; then
		run_sensitive_command "change_password" "$username" "passwd $username --stdin <redacted>" \
			bash -c 'printf "%s\n" "$1" | passwd "$2" --stdin' _ "$password" "$username"
	else
		run_sensitive_command "change_password" "$username" "chpasswd <redacted:$username>" \
			bash -c 'printf "%s:%s\n" "$1" "$2" | chpasswd' _ "$username" "$password"
	fi
}

command_supports_option() {
	local command_name=$1
	local option=$2
	"$command_name" --help 2>&1 | grep -Eq "(^|[ ,])${option//\//\\/}([, =]|$)"
}

create_account_backup() {
	local label=${1:-account-db}
	local safe_label
	local destination
	local source_file

	safe_label=$(printf '%s' "$label" | tr -cs '[:alnum:]_.-' '-')
	destination="$BACKUP_DIR/$(date +%Y%m%d-%H%M%S)-$safe_label"

	if is_dry_run; then
		show_message "Dry Run" "Would create account database backup at:
$destination"
		audit_log "backup" "$label" "dry-run" "backup account database" "$destination"
		return 0
	fi

	mkdir -p "$destination"
	chmod 700 "$destination"

	for source_file in /etc/passwd /etc/group /etc/shadow /etc/gshadow; do
		if [ -e "$source_file" ]; then
			cp -p "$source_file" "$destination/" >>"$LOG_FILE" 2>&1
		fi
	done

	audit_log "backup" "$label" "success" "backup account database" "$destination"
	printf '%s\n' "$destination"
}

prompt_account_backup() {
	local action_label=$1

	if command -v whiptail >/dev/null 2>&1 && [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
		if whiptail --title "Backup Recommended" --yesno "Create a backup of /etc/passwd, /etc/group, /etc/shadow, and /etc/gshadow before ${action_label}?" 10 78; then
			create_account_backup "$action_label" >/dev/null
		else
			audit_log "backup" "$action_label" "skipped" "backup account database"
		fi
		return 0
	fi

	create_account_backup "$action_label" >/dev/null
}
