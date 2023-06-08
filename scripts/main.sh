#!/bin/bash
#
# This program designed to help you to add/modifiy/delete/view users/groups with multipule options.
# The script mainly use (whiptail) tool to interact with user.
# Must run as a root or sudo with suitable permissions.
#
# Comment: Feel free to fork and edit it if you like.

## Check if this script is running as root.
if [ $(id -u) -ne 0 ]; then
	whiptail --title "Privileges Error!" --msgbox "Error! Please run as root user." 8 78
    exit
fi

## Important Package to view menues and resize them.
dnf -qy install newt		# Provides (whiptail)
dnf -qy install xterm-resize	# Provides (resize)

if (whiptail --title "System Admin Helper" --yesno "Start the program?" 8 78); then
    ## Start the program with the first (main) menu.
    ./main-menu.sh; exit
else
    ## If the user choose to not continue.
    whiptail --title "Bye Bye" --msgbox "This Program Created By: ALhassan Hossny\nGoodbye." 8 78
fi
