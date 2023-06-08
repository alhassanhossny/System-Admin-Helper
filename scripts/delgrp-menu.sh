#!/bin/bash
#
# Delete Group Option

while true; do
    group=$(whiptail --inputbox "Enter the group:" 8 39 "${group}" \
    --title "Delete Group" 3>&1 1>&2 2>&3)
    if [ $? != 0 ]; then ./main-menu.sh; exit; fi
    if [ -z "$group" ]; then
        ## If the user entered an empty group name.
        whiptail --title "Error" --msgbox "Empty group name, try again." 8 78
        continue
    else
        if [ "$(getent group ${group} | cut -d ":" -f1 | grep ${group})" ]; then        # If not exist ask to enter again.
            break
        else
            whiptail --title "Error" --msgbox "Group (${group}) does not exist, try another." 8 78
            continue
        fi
    fi
done

if ! (whiptail --title "Delete Group (${group})" --yesno "Are you sure you want to delete group (${group})?" 8 78); then
    ./main-menu.sh; exit
fi

if ! (whiptail --title "Delete Group (${group})" --yesno "Again, Are you sure you want to delete group (${group})?" 8 78); then
    ./main-menu.sh; exit
fi

groupdel ${group} &>>./logs

check=$(getent group ${group} | cut -d ":" -f1 | grep ${group})
if [ "${check}" ]; then
    output="Group ($group) has not been deleted, make sure that this group is not the primary group of any user."
else output="Group ($group) has been deleted successfully."; fi
whiptail --title "Output" --msgbox "${output}" 8 79

./main-menu.sh; exit
