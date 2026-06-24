#!/bin/bash
#
# Delete User Option

source ./func.sh
resize_window

while true; do
    username=$(whiptail --inputbox "Enter the username:" 8 39 "${username}" \
    --title "Delete User" 3>&1 1>&2 2>&3)
    if [ $? != 0 ]; then ./main-menu.sh; exit; fi
    if [ -z "$username" ]; then
        ## If the user entered an empty username.
        whiptail --title "Error" --msgbox "Empty username, try again." 8 78
        continue
    else
        if user_exists "${username}"; then        # If not exist ask to enter again.
            break
        else
            whiptail --title "Error" --msgbox "Username (${username}) does not exist, try another." 8 78
            continue
        fi
    fi
done

options=$(whiptail --title "Delete User Options (${username})" --checklist \
"Select options: [Space] to check/uncheck, [Enter] to apply, [TAB] to cancel." \
$(( $LINES - 2 )) 80 $(( $LINES - 8 )) \
"Remove" "Files in the user's home directory will be removed." ON \
"Force" "This option forces the removal of the user account." OFF \
"SELinux" "Remove any SELinux user mapping for the user's login." OFF \
 3>&1 1>&2 2>&3)
 
 if [ $? != 0 ]; then ./main-menu.sh; exit; fi
 
 command_args=(userdel)
 for opt in ${options}; do
    case ${opt} in
        "Remove") command_args+=("-r") ;;
        "Force") command_args+=("-f") ;;
        "SELinux") command_args+=("-Z") ;;
    esac
 done
 
if ! (whiptail --title "Delete User (${username})" --yesno "Are you sure you want to delete user (${username})?" 8 78); then
    ./main-menu.sh; exit
fi

if ! (whiptail --title "Delete User (${username})" --yesno "Again, Are you sure you want to delete user (${username})?" 8 78); then
    ./main-menu.sh; exit
fi

command_args+=("${username}")
"${command_args[@]}" >>"$LOG_FILE" 2>&1

if user_exists "${username}"; then
    output="User ($username) has not been deleted."
else output="User ($username) has been deleted successfully."; fi
whiptail --title "Output" --msgbox "${output}" 8 79

./main-menu.sh; exit
