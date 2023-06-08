#!/bin/bash
#
# Add Group Option

source ./func.sh	# Import useful functions
eval `resize`   # Used to make the menu size full screen.

if [ -z "${group}" ]; then
	while true; do
		group=$(whiptail --inputbox "Enter the new group name:" 8 39 "$group" \
		--title "Add Group" 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ./main-menu.sh; exit; fi
        if [ -z "$group" ]; then
            ## If the user entered an empty group name.
            whiptail --title "Error" --msgbox "Empty group name, try again." 8 78
            continue
		else
			if [ "$(getent group ${group} | cut -d ":" -f1 | grep ${group})" ]; then		# If exist ask to enter again.
				whiptail --title "Error" --msgbox "Duplicated group, try another." 8 78
				continue
			else
				if isValidUsername "$group"; then	# Check if the entered group is vaild to use.
					break
				else					# If not valid, ask to enter again.
					whiptail --title "Error" --msgbox "Unvalid group, try again." 8 78
					continue
				fi
			fi
		fi
	done
fi

## Initialize some useful variables.
if [ -z "${options}" ]; then
	declare -a options
	options=("-" "-" "-")
fi

declare -a base_strings # Array of default strings.
base_strings=(\
"Create group (${group}) with the current options." \
"The numerical value of the group's ID." \
"A list of usernames to add as members of the group." \
)

declare -a strings # Actual menu strings.
for i in "${!options[@]}"; do
	if [ "${options[$i]}" != "-" ]; then strings[$i]="${options[$i]}"
	else strings[$i]="${base_strings[$i]}"; fi
done

## Menu of user creation options.
opt=$(whiptail --title "New Group Options - group: ${group}" --ok-button "Edit" \
--menu "Select an option:" \
$LINES $COLUMNS $(( $LINES - 8 )) \
"Create" "${strings[0]}" \
"GID" "${strings[1]}" \
"Users" "${strings[2]}" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ./main-menu.sh; exit; fi

declare -a arg
arg=("" -g -U)

case $opt in
########################################################################################################################
	"Create")	# Option 0
		args=""
		for i in "${!options[@]}"; do
			if [ "${options[$i]}" != "-" ]; then
				args="${args} ${arg[$i]} ${options[$i]}"
			fi
		done
		
		eval "groupadd ${args} ${group}" &>>./logs
		
		check=$(getent group ${group} | cut -d ":" -f1 | grep ${group})
		if [ "${check}" ];then
			output="Group ($group) has been created successfully."
		else output="Group ($group) has not been created."; fi
		whiptail --title "Output" --msgbox "${output}" 8 79
		./main-menu.sh; exit ;;
########################################################################################################################
	"GID")	# Option 1
		if [ "${options[1]}" == "-" ]; then options[1]=""; fi
		while true; do
			options[1]=$(whiptail --inputbox "Enter the new GID:" 9 39 "${options[1]}" \
			--title "New Group Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 ]; then options[1]="-"; break; fi
			if [ ! "$(getent group ${options[1]} | cut -d ":" -f3 | grep ${options[1]})" ]; then break;
			else
				whiptail --title "Error" --msgbox "The GID is unvalid or exist already, try again." 8 79
				continue
			fi
		done
		source ./addgrp-menu.sh; exit ;;
########################################################################################################################
	"Users")	# Option 2
		if [ "${options[2]}" == "-" ]; then options[2]=""; fi
		while true; do
			options[2]=$(whiptail --inputbox "Enter the Users (Comma Separated):" 8 $(( $COLUMNS - 10 )) "${options[2]}" \
			--title "New Group Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 ]; then options[2]="-"; break; fi
			if isValidGroups "${options[2]}"; then
				for user in $(echo "${options[2]}" | tr "," " "); do
					if ! [ $(getent passwd ${user} | cut -d ":" -f1 | grep ${user}) ]; then
						whiptail --title "Error" --msgbox "The (${user}) user does not exist, try again." 8 79
						continue 2
					fi
				done
				break
			else
				whiptail --title "Error" --msgbox "Syntax Error, try again." 8 79
				continue
			fi
		done
		source ./addgrp-menu.sh; exit ;;
########################################################################################################################
    *) whiptail --title "Strange Error!" --msgbox "Error! You are not supposed to see this meesage!" 8 78 ;;
########################################################################################################################
esac
