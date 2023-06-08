#!/bin/bash
#
# Change Password Option

while true; do
    username=$(whiptail --inputbox "Enter the username:" 8 39 "${username}" \
    --title "Change Password" 3>&1 1>&2 2>&3)
    if [ $? != 0 ]; then ./main-menu.sh; exit; fi
    if [ -z "$username" ]; then
        ## If the user entered an empty username.
        whiptail --title "Error" --msgbox "Empty username, try again." 8 78
        continue
    else
        if [ "$(getent passwd ${username} | cut -d ":" -f1 | grep ${username})" ]; then        # If not exist ask to enter again.
            break
        else
            whiptail --title "Error" --msgbox "Username (${username}) does not exist, try another." 8 78
            continue
        fi
    fi
done

while true; do
    pass1=$(whiptail --passwordbox "Enter the new password:" 8 78 --title "Change (${username}) Password" 3>&1 1>&2 2>&3)
    if [ $? !=  0 ]; then ./main-menu.sh; exit; fi
    if [ -z "${pass1}" ]; then
        whiptail --title "Error" --msgbox "You entered an empty password, try again." 8 78
        continue; fi

    pass2=$(whiptail --passwordbox "Confirm the new password:" 8 78 --title "Change (${username}) Password" 3>&1 1>&2 2>&3)
    if [ $? !=  0 ]; then ./main-menu.sh; exit; fi
    
    if [ "${pass1}" == "${pass2}" ]; then break
    else 
        whiptail --title "Error" --msgbox "You entered unmatched passwords, try again." 8 78
        continue; fi
done

echo "${pass1}" | passwd ${username} --stdin &>>./logs

lstchg=$(getent shadow ${username} | cut -d ":" -f3)
now=$((($(date +%s -d $(date '+%Y%m%d'))-$(date +%s -d 19700101))/86400))

if [ "${now}" == "${lstchg}" ]; then
    output="Password of user ($username) has been changed successfully."
else output="Password of user ($username) has not been changed."; fi
whiptail --title "Output" --msgbox "${output}" 8 79

./main-menu.sh; exit
