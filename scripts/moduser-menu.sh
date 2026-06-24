#!/bin/bash
#
# Modify User Option

source ./func.sh    # Import useful functions
resize_window               # Used to make the menu size full screen.

if [ -z "${username}" ]; then
    while true; do
        username=$(whiptail --inputbox "Enter the username:" 8 39 "${username}" \
        --title "Modify User" 3>&1 1>&2 2>&3)
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
fi

## Initialize some useful variables.
if [ -z "${options}" ]; then
    declare -a options
    options=("-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-" "-")
fi

declare -a base_strings # The array of default strings.
base_strings=(\
"Modify (${username}) with the current options." \
"Any text string. Full Name, Email, Phone, ...etc." \
"The user's new login directory." \
"The date on which the user account will be disabled." \
"The number of days after a password expires until the account is permanently disabled." \
"The group name or number of the user's new initial login group." \
"A list of supplementary groups which the user is also a member of." \
"The name of the user will be changed from LOGIN to NEW_LOGIN." \
"Lock a user's password (overwrite Unlock)." \
"Unlock a user's password (overwrite Lock)." \
"Move the content of the user's home directory to the new location." \
"The new numerical value of the user's ID." \
"Plain-text password." \
"The path of the user's new login shell."\
)

declare -a strings # Actual menu strings.
for i in "${!options[@]}"; do
    if [ "${options[$i]}" != "-" ]; then strings[$i]="${options[$i]}"
    else strings[$i]="${base_strings[$i]}"; fi
done

## Menu of user creation options.
opt=$(whiptail --title "Modify User Options - username: ${username}" --ok-button "Edit" \
--menu "Select an option:" \
$LINES $COLUMNS $(( $LINES - 8 )) \
"Modify" "${strings[0]}" \
"Comment" "${strings[1]}" \
"New Home" "${strings[2]}" \
"Expire Date" "${strings[3]}" \
"Inactive" "${strings[4]}" \
"GID" "${strings[5]}" \
"Groups" "${strings[6]}" \
"Login" "${strings[7]}" \
"Lock" "${strings[8]}" \
"Unlock" "${strings[9]}" \
"Move Home" "${strings[10]}" \
"UID" "${strings[11]}" \
"Password" "${strings[12]}" \
"Shell" "${strings[13]}" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ./main-menu.sh; exit; fi

declare -a arg
arg=("" -c -d -e -f -g -G -l -L -U -m -u "" -s)

if user_exists "${username}"; then
    check="${username}"
else
    check=""
fi

if [ -z "${defaults}" ]; then
    declare -a defaults
    defaults=(\
    "" \
    "$(getent passwd "${username}" | cut -d ":" -f5)" \
    "$(getent passwd "${username}" | cut -d ":" -f6)" \
    "" \
    "" \
    "$(getent passwd "${username}" | cut -d ":" -f4)" \
    "$(id -nG ${username} | tr " " ",")" \
    "$(getent passwd "${username}" | cut -d ":" -f1)" \
    "" \
    "" \
    "$(getent passwd "${username}" | cut -d ":" -f6)" \
    "$(getent passwd "${username}" | cut -d ":" -f3)" \
    "" \
    "$(getent passwd "${username}" | cut -d ":" -f7)" \
    )
fi

case $opt in
########################################################################################################################
    "Modify")        # Option 0
        command_args=(usermod)
        for i in "${!options[@]}"; do
            if [ "${options[$i]}" != "-" ]; then
                case $i in
                    0|7|12) ;;
                    8|9) command_args+=("${arg[$i]}") ;;
                    10) command_args+=("-m" "-d" "${options[$i]}") ;;
                    *) command_args+=("${arg[$i]}" "${options[$i]}") ;;
                esac
            fi
        done

        if [ ${#command_args[@]} -gt 1 ] && [ "${check}" ]; then
            command_args+=("${username}")
            "${command_args[@]}" >>"$LOG_FILE" 2>&1
        fi
        if [ "${options[12]}" != "-" ] && [ "${check}" ]; then
            set_user_password "${username}" "${options[12]}"
        fi
        if [ "${options[7]}" != "-" ] && [ "${check}" ]; then
            usermod "${arg[7]}" "${options[7]}" "${username}" >>"$LOG_FILE" 2>&1
            username="${options[7]}"
        fi

        if user_exists "${username}"; then
            output="NOT SURE: User ($username) has been modified successfully."
        else output="NOT SURE: User ($username) has not been modified." ; fi
        whiptail --title "Output" --msgbox "${output}" 8 79
        ./main-menu.sh; exit ;;
########################################################################################################################
    "Comment")        # Option 1
        if [ "${options[1]}" == "-" ]; then options[1]="${defaults[1]}"; fi
        options[1]=$(whiptail --inputbox "Enter a Comment/Full Name:" 8 $(( $COLUMNS - 10 )) "${options[1]}" \
        --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
        if [ $? !=  0 ]; then options[1]="-"; fi
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "New Home")        # Option 2
        if [ "${options[2]}" == "-" ]; then options[2]="${defaults[2]}"; fi
        while true; do
            options[2]=$(whiptail --inputbox "Enter the new home directory:" 8 $(( $COLUMNS - 10 )) "${options[2]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[2]="-"; source ./moduser-menu.sh; exit; fi
            if [ -d "${options[2]}" ]; then break
            else
                whiptail --title "Error" --msgbox "The directory (${options[2]}) does not exist, try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Expire Date")        # Option 3
        if [ "${options[3]}" == "-" ]; then options[3]=""; fi
        while true; do
            options[3]=$(whiptail --inputbox "Enter the Expire Date (YYYY-MM-DD):" 8 39 "${options[3]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
           if [ $? != 0 ]; then options[3]="-"; source ./moduser-menu.sh; exit; fi
            if isValidDate "${options[3]}"; then break
            else                                    # If not valid, ask to enter again.
                whiptail --title "Error" --msgbox "Unvalid date, try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Inactive")            # Option 4
        if [ "${options[4]}" == "-" ]; then options[4]=""; fi
        while true; do
            options[4]=$(whiptail --inputbox "Enter the Inactive Days:" 8 39 "${options[4]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[4]="-"; source ./moduser-menu.sh; exit; fi
            if [[ "${options[4]}" =~ ^[0-9]+$ ]]; then break
            else
                whiptail --title "Error" --msgbox "Unvalid value, try again." 8 79
                options[4]=""
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "GID")            # Option 5
        if [ "${options[5]}" == "-" ]; then options[5]="${defaults[5]}"; fi
        while true; do
            options[5]=$(whiptail --inputbox "Enter the new GID:" 8 39 "${options[5]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[5]="-"; source ./moduser-menu.sh; exit; fi
            if gid_exists "${options[5]}"; then break
            else
                whiptail --title "Error" --msgbox "The GID (${options[5]}) does not exist, try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Groups")        # Option 6
        if [ "${options[6]}" == "-" ]; then options[6]="${defaults[6]}"; fi
        while true; do
            options[6]=$(whiptail --inputbox "Enter the Groups (Comma Separated):" 8 $(( $COLUMNS - 10 )) "${options[6]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[6]="-"; source ./moduser-menu.sh; exit; fi
            if isValidGroups "${options[6]}"; then
                for grp in $(echo "${options[6]}" | tr "," " "); do
                    if ! group_exists "${grp}"; then
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
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Login")        # Option 7
        if [ "${options[7]}" == "-" ]; then options[7]="${defaults[7]}"; fi
        while true; do
            options[7]=$(whiptail --inputbox "Enter the new login username:" 8 39 "${options[7]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 -o "${options[7]}" == "${defaults[7]}" ]; then options[7]="-"; source ./moduser-menu.sh; exit; fi
            if user_exists "${options[7]}"; then        # If exist ask to enter again.
                whiptail --title "Error" --msgbox "Username (${options[7]}) is existing, try another." 8 78
                continue
            else
                if isValidUsername "${options[7]}"; then    # Check if the entered username is vaild to use.
                    break
                else                    # If not valid, ask to enter again.
                    whiptail --title "Error" --msgbox "Unvalid username, try again." 8 78
                    continue
                fi
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Lock")            # Option 8
        if [ "${options[8]}" == "-" ]; then
            options[8]="Enabled"
            options[9]="-"
        else
            options[8]="-"
        fi
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Unlock")        # Option 9
        if [ "${options[9]}" == "-" ]; then
            options[9]="Enabled"
            options[8]="-"
        else
            options[9]="-"
        fi
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Move Home")    # Option 10
        if [ "${options[10]}" == "-" ]; then options[10]="${defaults[10]}"; fi
        while true; do
            options[10]=$(whiptail --inputbox "Enter the new location:" 8 $(( $COLUMNS - 10 )) "${options[10]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[10]="-"; source ./moduser-menu.sh; exit; fi
            if [ -d "${options[10]}" ]; then break
            else
                whiptail --title "Error" --msgbox "Unvalid directory (${options[10]}), try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "UID")            # Option 11
        if [ "${options[11]}" == "-" ]; then options[11]="${defaults[11]}"; fi
        while true; do
            options[11]=$(whiptail --inputbox "Enter the new UID:" 9 39 "${options[11]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
			if [ $? != 0 -o "${options[11]}" == "${defaults[11]}" ]; then options[11]="-"; source ./moduser-menu.sh; exit; fi
            if ! uid_exists "${options[11]}"; then break
            else
                whiptail --title "Error" --msgbox "The UID is already existing, try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Password")        # Option 12
        if [ "${options[12]}" == "-" ]; then options[12]=""; fi
        options[12]=$(whiptail --inputbox "Enter the new password:" 9 50 "${options[12]}" \
        --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
        if [ $? != 0 -o -z "${options[12]}" ]; then options[12]="-"; fi
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    "Shell")        # Option 13
        if [ "${options[13]}" == "-" ]; then options[13]="${defaults[13]}"; fi
        while true; do
            options[13]=$(whiptail --inputbox "Enter the shell file path:" 8 $(( $COLUMNS - 10 )) "${options[13]}" \
            --title "Modify User Options" --cancel-button "disable" 3>&1 1>&2 2>&3)
            if [ $? != 0 ]; then options[13]="-"; break; fi
            if [ -f "${options[13]}" ]; then break
            else
                whiptail --title "Error" --msgbox "The shell file (${options[13]}) does not exist, try again." 8 79
                continue
            fi
        done
        source ./moduser-menu.sh; exit ;;
########################################################################################################################
    *) whiptail --title "Strange Error!" --msgbox "Error! You are not supposed to see this meesage!" 8 78 ;;
########################################################################################################################
esac
