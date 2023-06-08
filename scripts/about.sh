#!/bin/bash

eval `resize`   

about="
******************************** Admin helper Bash Script Project **********************************
This bash script performs some administration tasks to help system admins using GUI whiptail menus. 
This bash script designed to help you  add , delete , modify , view users and groups with multipule options.

Designed by Eng : Alhassan Hossny Ahmed Elbadry
Under the supervision of Eng : Romany
"

whiptail --title "About This Program" --msgbox "$about" $LINES $COLUMNS --scrolltext

./main-menu.sh; exit
