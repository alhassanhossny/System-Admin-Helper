#!/bin/bash
#
# Modify Group Option

source ./func.sh    # Import useful functions
eval `resize`               # Used to make the menu size full screen.

if [ -z "${group}" ]; then
    while true; do
        group=$(whiptail --inputbox "Enter the group:" 8 39 "${group}" \
        --title "Modify Group" 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ./main-menu.sh; exit; fi
        if [ -z "$group" ]; then
            ## If the user entered an empty group name.
            whiptail --title "Error" --msgbox "Empty group name, try again." 8 78
            continue
        else
            if [ $(getent group ${group} | cut -d ":" -f1 | grep ${group}) ]; then        # If not exist ask to enter again.
                break
            else
                whiptail --title "Error" --msgbox "Group (${group}) does not exist, try another." 8 78
                continue
            fi
        fi
    done
fi

## Initialize some useful variables.
if [ -z "${options}" ]; then
    declare -a options
    options=("-" "-" "-" "-")
fi

declare -a base_strings # The array of default strings.
base_strings=(\
"Modify (${group}) with the current options." \
"The group ID of the given GROUP will be changed to GID." \
"The name of the group will be changed from GROUP to NEW_GROUP name." \
"A list of usernames to add as members of the group." \
)

declare -a strings # Actual menu strings.
for i in "${!options[@]}"; do
    if [ "${options[$i]}" != "-" ]; then strings[$i]="${options[$i]}"
    else strings[$i]="${base_strings[$i]}"; fi
done

## Menu of user creation options.
opt=$(whiptail --title "Modify Group Options (${group})" --ok-button "Edit" \
--menu "Select an option:" \
$LINES $COLUMNS $(( $LINES - 8 )) \
"Modify" "${strings[0]}" \
"GID" "${strings[1]}" \
"New Name" "${strings[2]}" \
"Users" "${strings[3]}" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ./main-menu.sh; exit; fi

declare -a arg
arg=("" -g -n -U)

if [ -z "${defaults}" ]; then
    declare -a defaults
    defaults=(\
    "" \
    $(getent group ${group} | cut -d ":" -f3) \
    $(getent group ${group} | cut -d ":" -f1) \
    $(getent group ${group} | cut -d ":" -f4) \
    )
fi

case $opt in
########################################################################################################################
    "Modify")        # Option 0
        for i in "${!options[@]}"; do
            if [ "${options[$i]}" != "-" ]; then
                eval "$(echo groupmod ${arg[$i]} ${options[$i]} ${group} | tr -d \')" &>>./logs
                if [ $i -eq 2 ]; then group=${options[$i]}; fi
				
				if [ $i -eq 1 ]; then check=$(getent group ${group} | cut -d ":" -f3)
				elif [ $i -eq 2 ]; then check=$(getent group ${group} | cut -d ":" -f1)
				elif [ $i -eq 3 ]; then check=$(getent group ${group} | cut -d ":" -f4)
				fi
				
				if [ "${check}" == "${options[$i]}" ];then
                    output="${output}\nOption ${i} has been modified successfully (${arg[$i]} ${options[$i]})."
                else output="${output}\nOption ${i} has not been modified (${arg[$i]} ${options[$i]})."; fi
            fi
        done
        
        whiptail --title "Output" --msgbox "${output}" 10 79
        ./main-menu.sh; exit ;;
########################################################################################################################
    "GID")        # Option 1
        if [ "${options[1]}" == "-" ]; then options[1]="${defaults[1]}"; fi
        while true; do
            options[1]=$(whiptail --inputbox "Enter the new GID:" 9 39 "${options[1]}" \
            --title "Modify Group Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 ]; then options[1]="-"; source ./modgrp-menu.sh; exit; fi
            if [ "${options[1]}" == "${defaults[1]}" ]; then options[1]="-"; break; fi
            if ! [ $(getent group ${options[1]} | cut -d ":" -f3 | grep ${options[1]}) ]; then break
            else
                whiptail --title "Error" --msgbox "The GID is already existing, try again." 8 79
                continue
            fi
        done
        source ./modgrp-menu.sh; exit ;;
########################################################################################################################
    "New Name")        # Option 2
        if [ "${options[2]}" == "-" ]; then options[2]="${defaults[2]}"; fi
        while true; do
            options[2]=$(whiptail --inputbox "Enter the new group name:" 8 39 "${options[2]}" \
            --title "Modify Group Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 ]; then options[2]="-"; source ./modgrp-menu.sh; exit; fi
            if [ "${options[2]}" == "${defaults[2]}" ]; then options[2]="-"; break; fi
            if [ $(getent group ${options[2]} | cut -d ":" -f1 | grep "${options[2]}") ]; then        # If exist ask to enter again.
                whiptail --title "Error" --msgbox "Group (${options[2]}) is existing, try another." 8 78
                continue
            else
                if isValidUsername "${options[2]}"; then    # Check if the entered group name is vaild to use.
                    break
                else                    # If not valid, ask to enter again.
                    whiptail --title "Error" --msgbox "Unvalid group name, try again." 8 78
                    continue
                fi
            fi
        done
        source ./modgrp-menu.sh; exit ;;
########################################################################################################################
    "Users")        # Option 3
        if [ "${options[3]}" == "-" ]; then options[3]="${defaults[3]}"; fi
        while true; do
            options[3]=$(whiptail --inputbox "Enter the group users (Comma Separated):" 8 $(( $COLUMNS - 10 )) "${options[3]}" \
            --title "Modify Group Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 ]; then options[3]="-"; source ./modgrp-menu.sh; exit; fi
            if isValidGroups "${options[3]}"; then
                for user in $(echo "${options[3]}" | tr "," " "); do
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
        source ./modgrp-menu.sh; exit ;;
########################################################################################################################
    *) whiptail --title "Strange Error!" --msgbox "Error! You are not supposed to see this meesage!" 8 78 ;;
########################################################################################################################
esac
