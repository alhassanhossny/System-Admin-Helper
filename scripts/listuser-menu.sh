#!/bin/bash
#
# User List Option

eval `resize`   			# Used to make the menu size full screen.

users=$(awk -F: '{if ($7 != "/bin/bash" && $7 != "/usr/bin/bash") {print "UID", $3, ":", $1} else {print "UID", $3, ":", $1, "(bash shell user)"; login++}} END {print "\n#########################\n"; print "Number of users:", NR"\nNumber of bash shell users:", login"\nNumber of non-bash shell users:", NR-login}' /etc/passwd)

whiptail --title "List of Users" --msgbox "$users" $(( $LINES - 2 )) 65 --scrolltext

./main-menu.sh; exit
