#!/usr/bin/env bash
#
# This program designed to help you to add/modifiy/delete/view users/groups with multipule options.
# The script mainly use (whiptail) tool to interact with user.
# Must run as a root or sudo with suitable permissions.
#
# Comment: Feel free to fork and edit it if you like.

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
source ./func.sh

install_hint() {
	if command_exists dnf; then
		printf 'sudo dnf install newt xterm-resize shadow-utils'
	elif command_exists apt-get; then
		printf 'sudo apt-get install whiptail xterm passwd login'
	elif command_exists zypper; then
		printf 'sudo zypper install newt xterm shadow'
	else
		printf 'Install whiptail/newt, resize, and shadow-utils with your system package manager.'
	fi
}

missing_commands() {
	local required=(awk bash chage chpasswd cut date getent grep groupadd groupdel groupmod id passwd useradd userdel usermod whiptail)
	local missing=()
	local command_name

	for command_name in "${required[@]}"; do
		if ! command_exists "$command_name"; then
			missing+=("$command_name")
		fi
	done

	if [ ${#missing[@]} -gt 0 ]; then
		printf '%s\n' "${missing[*]}"
		return 1
	fi
	return 0
}

## Check if this script is running as root.
if [ "$(id -u)" -ne 0 ]; then
	show_message "Privileges Error!" "Error! Please run as root user."
	exit 1
fi

if ! missing=$(missing_commands); then
	show_message "Missing Dependencies" "Missing commands: ${missing}

Install dependencies:
$(install_hint)"
	exit 1
fi

if ! prepare_runtime_paths 2>/dev/null; then
	show_message "Log Error" "Unable to prepare runtime log directory: $LOG_DIR"
	exit 1
fi

resize_window

if (whiptail --title "System Admin Helper" --yesno "Start the program?" 8 78); then
    if whiptail --title "Dry Run" --defaultno --yesno "Enable dry-run mode for this session?\n\nDry-run mode previews and audits commands without changing system users or groups." 10 78; then
        export SAH_DRY_RUN=1
        audit_log "session" "main" "dry-run" "start session"
    else
        export SAH_DRY_RUN="${SAH_DRY_RUN:-0}"
        audit_log "session" "main" "started" "start session"
    fi
    ## Start the program with the first (main) menu.
    ./main-menu.sh; exit
else
    ## If the user choose to not continue.
    whiptail --title "Bye Bye" --msgbox "This Program Created By: ALhassan Hossny\nGoodbye." 8 78
fi
