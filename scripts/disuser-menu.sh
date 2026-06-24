#!/bin/bash
#
# Disable User Option

source ./func.sh

while true; do
	username=$(whiptail --inputbox "Enter the username:" 8 39 "${username}" \
	--title "Disable User" 3>&1 1>&2 2>&3)
	if [ $? != 0 ]; then ./main-menu.sh; exit; fi
    if [ -z "$username" ]; then
        ## If the user entered an empty username.
        whiptail --title "Error" --msgbox "Empty username, try again." 8 78
        continue
    else
		if user_exists "${username}"; then		# If not exist ask to enter again.
			break
		else
			whiptail --title "Error" --msgbox "Username (${username}) does not exist, try another." 8 78
			continue
		fi
	fi
done

if ! (whiptail --title "Disable User (${username})" --yesno "Are you sure you want to disable user (${username})?" 8 78); then
	./main-menu.sh; exit
fi

run_admin_command "disable_user" "$username" usermod -L -e 1 "$username"

check=$(passwd --status "${username}" | awk '{if ($2 == "LK") {print "locked"}}')
if is_dry_run; then
	output="Dry run: User ($username) disable was previewed."
elif [ "${check}" ]; then
	output="User ($username) has been disabled successfully."
else output="User ($username) has not been disabled."; fi
whiptail --title "Output" --msgbox "${output}" 8 79

./main-menu.sh; exit
