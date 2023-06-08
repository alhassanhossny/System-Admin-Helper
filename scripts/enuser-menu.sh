#!/bin/bash
#
# Enable User Option

while true; do
    username=$(whiptail --inputbox "Enter the username:" 8 39 "${username}" \
    --title "Enable User" 3>&1 1>&2 2>&3)
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

if ! (whiptail --title "Enable User (${username})" --yesno "Are you sure you want to enable user (${username})?" 8 78); then
    ./main-menu.sh; exit
fi

usermod -U ${username} &>>./logs
usermod -e -1 ${username} &>>./logs

check1=$(chage -l ${username} | grep 'Account expires' | grep "never")
check2=$(passwd --status ${username} | awk '{if ($2 == "LK") {print "locked"}}')

if [ "${check1}" ]; then
    output="User ($username) account has been enabled successfully."
else output="User ($username) account has not been enabled."; fi

if [ "${check2}" ]; then
    output="${output}\nUser ($username) password has not been enabled. Make sure to set a password before unlock it."
else output="${output}\nUser ($username) password has been enabled successfully."; fi

whiptail --title "Output" --msgbox "${output}" 10 79
./main-menu.sh; exit
