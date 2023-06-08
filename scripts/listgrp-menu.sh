#!/bin/bash
#
# Group List Option

eval `resize`   			# Used to make the menu size full screen.

groups=$(awk -F: '{if ($4) {print "GID", $3, ":", $1, "\t\t(Members:", $4")"} else {print "GID", $3, ":", $1}} END {print "\n#########################\n"; print "Number of groups:", NR}' /etc/group)

whiptail --title "List of Groups" --msgbox "$groups" $(( $LINES - 2 )) 65 --scrolltext

./main-menu.sh; exit
