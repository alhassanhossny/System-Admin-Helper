#!/bin/bash
#
# Add User Option

source ./func.sh    # Import useful functions
eval `resize`   # Used to make the menu size full screen.

if [ -z "${username}" ]; then
    while true; do
        username=$(whiptail --inputbox "Enter the new username:" 8 39 "${username}" \
        --title "Add User" 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ./main-menu.sh; exit; fi
        if [ -z "$username" ]; then
            ## If the user entered an empty username.
            whiptail --title "Error" --msgbox "Empty username, try again." 8 78
            continue
        else
            if [ "$(getent passwd ${username} | cut -d ":" -f1 | grep ${username})" ]; then        # If exist ask to enter again.
                whiptail --title "Error" --msgbox "Duplicated username, try another." 8 78
                continue
            else
                if isValidUsername "$username"; then    # Check if the entered username is vaild to use.
                    break
                else                    # If not valid, ask to enter again.
                    whiptail --title "Error" --msgbox "Unvalid username, try again." 8 78
                    continue
                fi
            fi
        fi
    done
fi

## Initialize some useful variables.
if [ -z "${options}" ]; then
    declare -a options
    options=("-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-")
fi

declare -a base_strings # Array of default strings.
base_strings=(\
"Create user (${username}) with the current options." \
"Any text string. Full Name, Email, Phone, ...etc." \
"Do no create the user's home directory (overwrite -d -k options)." \
"The value for the user's login directory (overwrite -M)." \
"The skeleton directory, which contains files and directories to be copied (overwrite -M)." \
"The date on which the user account will be disabled." \
"The number of days after a password expires until the account is permanently disabled." \
"The group name or number of the user's initial login group." \
"A list of supplementary groups which the user is also a member of." \
"The numerical value of the user's ID." \
"Plain-text password." \
"The name of the user's login shell."\
)

declare -a strings # Actual menu strings.
for i in "${!options[@]}"; do
    if [ "${options[$i]}" != "-" ]; then strings[$i]="${options[$i]}"
    else strings[$i]="${base_strings[$i]}"; fi
done

## Menu of user creation options.
opt=$(whiptail --title "New User Options (${username})" --ok-button "Edit" \
--menu "Select an option:" \
$LINES $COLUMNS $(( $LINES - 8 )) \
"Create" "${strings[0]}" \
"Comment" "${strings[1]}" \
"No Create Home" "${strings[2]}" \
"Home" "${strings[3]}" \
"Skeleton" "${strings[4]}" \
"Expire Date" "${strings[5]}" \
"Inactive" "${strings[6]}" \
"GID" "${strings[7]}" \
"Groups" "${strings[8]}" \
"UID" "${strings[9]}" \
"Password" "${strings[10]}" \
"Shell" "${strings[11]}" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ./main-menu.sh; exit; fi

declare -a arg
arg=("" -c -M -d -mk -e -f -g -G -u "" -s)

case $opt in
########################################################################################################################
    "Create")    # Option 0
        args=""
        for i in "${!options[@]}"; do
            if [ "${options[$i]}" != "-" ]; then
                if [ $i -ne 1 -a $i -ne 2 -a $i -ne 3 -a $i -ne 4 -a $i -ne 10 -a $i -ne 11 ];
                    then args="${args} ${arg[$i]} ${options[$i]}"
                elif [ $i -eq 1 -o $i -eq 3 -o $i -eq 4 -o $i -eq 11 ];
                    then args="${args} ${arg[$i]} \"${options[$i]}\""
                elif [[ $i =~ 2 ]];
                    then args="${args} ${arg[$i]}"
                fi
            fi
        done
		
        eval "$(echo useradd ${args} ${username} | tr -d \')" &>>./logs
		
        check=$(getent passwd ${username} | cut -d ":" -f1 | grep ${username})
        if [ "${check}" -a "${options[10]}" != "-" ];
            then echo "${options[10]}" | passwd ${username} --stdin &>>./logs; fi
        
        if [ "${check}" ];then
            output="User ($username) has been created successfully."
        else output="User ($username) has not been created."; fi
        whiptail --title "Output" --msgbox "${output}" 8 79
        ./main-menu.sh; exit ;;
########################################################################################################################
    "Comment")    # Option 1
        if [ "${options[1]}" == "-" ]; then options[1]=""; fi
        options[1]=$(whiptail --inputbox "Enter a Comment/Full Name:" 8 $(( $COLUMNS - 10 )) "${options[1]}" \
        --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
        if [ $? != 0 -o -z "${options[1]}" ]; then options[1]="-"; fi
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "No Create Home")    # Option 2
        if [ "${options[2]}" == "-" ]; then
            options[2]="Enabled"
            options[3]="-"; options[4]="-"
        else
            options[2]="-"
        fi
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Home")        # Option 3
        if [ "${options[3]}" == "-" ]; then options[3]="/home/${username}"; fi
        while true; do
            options[3]=$(whiptail --inputbox "Enter the home directory:" 8 $(( $COLUMNS - 10 )) "${options[3]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 -o -z "${options[3]}" ]; then options[3]="-"; break; fi
            if isValidDir "${options[3]}"; then        # Check if the entered directory is vaild to use.
                options[2]="-"
                break
            else                        # If not valid, ask to enter again.
                whiptail --title "Error" --msgbox "Unvalid directory, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Skeleton")        # Option 4
        if [ "${options[4]}" == "-" ]; then options[4]="/etc/skel"; fi
        while true; do
            options[4]=$(whiptail --inputbox "Enter the skeleton directory:" 8 $(( $COLUMNS - 10 )) "${options[4]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 -o -z "${options[4]}" ]; then options[4]="-"; break; fi
            if [ -d "${options[4]}" ]; then        # Check if the entered directory exist.
                options[2]="-"
                break
            else                                # If not valid, ask to enter again.
                whiptail --title "Error" --msgbox "Unvalid directory, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Expire Date")        # Option 5
        if [ "${options[5]}" == "-" ]; then options[5]=""; fi
        while true; do
            options[5]=$(whiptail --inputbox "Enter the Expire Date (YYYY-MM-DD):" 8 39 "${options[5]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? !=  0 ]; then options[5]="-"; break; fi
            if isValidDate "${options[5]}"; then break
            else                                    # If not valid, ask to enter again.
                whiptail --title "Error" --msgbox "Unvalid date, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Inactive")        # Option 6
        if [ "${options[6]}" == "-" ]; then options[6]=""; fi
        while true; do
            options[6]=$(whiptail --inputbox "Enter the Inactive Days:" 8 39 "${options[6]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? !=  0 ]; then options[6]="-"; break; fi
            if [[ "${options[6]}" =~ ^[0-9]+$ ]]; then break
            else
                whiptail --title "Error" --msgbox "Unvalid value, try again." 8 79
                options[6]=""
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "GID")        # Option 7
        if [ "${options[7]}" == "-" ]; then options[7]=""; fi
        while true; do
            options[7]=$(whiptail --inputbox "Enter the GID:" 8 39 "${options[7]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 -o -z "${options[7]}" ]; then options[7]="-"; break; fi
            if [ $(getent group ${options[7]} | cut -d ":" -f3 | grep ${options[7]}) ]; then break
            else
                whiptail --title "Error" --msgbox "The GID does not exist, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Groups")        # Option 8
        if [ "${options[8]}" == "-" ]; then options[8]=""; fi
        while true; do
            options[8]=$(whiptail --inputbox "Enter the Groups (Comma Separated):" 8 $(( $COLUMNS - 10 )) "${options[8]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? !=  0 ]; then options[8]="-"; break; fi
            if isValidGroups "${options[8]}"; then
                for grp in $(echo "${options[8]}" | tr "," " "); do
                    if [ ! "$(getent group ${grp} | cut -d ":" -f1 | grep ${grp})" ]; then
                        whiptail --title "Error" --msgbox "The (${grp}) group does not exist, try again." 8 79
                        continue 2
                    fi
                done
                break
            else
                whiptail --title "Error" --msgbox "Syntax Error, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "UID")        # Option 9
        if [ "${options[9]}" == "-" ]; then options[9]=""; fi
        while true; do
            options[9]=$(whiptail --inputbox "Enter the new UID:" 9 39 "${options[9]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
             if [ $? != 0 -o -z "${options[9]}" ]; then options[9]="-"; break; fi
            if [ ! "$(getent passwd ${options[9]} | cut -d ":" -f3 | grep ${options[9]})" ]; then break;
            else
                whiptail --title "Error" --msgbox "The UID is unvalid or exist already, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Password")        # Option 10
        if [ "${options[10]}" == "-" ]; then options[10]=""; fi
        options[10]=$(whiptail --inputbox "Enter the user password:" 9 50 "${options[10]}" \
        --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
        if [ $? != 0 -o -z "${options[10]}" ]; then options[10]="-"; fi
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    "Shell")        # Option 11
        if [ "${options[11]}" == "-" ]; then options[11]="/bin/bash"; fi
        while true; do
            options[11]=$(whiptail --inputbox "Enter the shell file path:" 8 $(( $COLUMNS - 10 )) "${options[11]}" \
            --title "New User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[11]="-"; break; fi
            if [ -f "${options[11]}" ]; then break
            else
                whiptail --title "Error" --msgbox "The shell file does not exist, try again." 8 79
                continue
            fi
        done
        source ./adduser-menu.sh; exit ;;
########################################################################################################################
    *) whiptail --title "Strange Error!" --msgbox "Error! You are not supposed to see this meesage!" 8 78 ;;
########################################################################################################################
esac
