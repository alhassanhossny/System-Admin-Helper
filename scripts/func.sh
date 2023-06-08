#!/bin/bash

function isValidUsername {
	local re='^[[:lower:]_][[:lower:][:digit:]_-]{1,15}$'
	(( ${#1} > 16 )) && return 1
	[[ $1 =~ $re ]]
}

function isValidDate {
	local re='^[2-9][0-9]{3}-[01][0-9]-[0-3][0-9]$'
        (( ${#1} != 10 )) && return 1
        [[ $1 =~ $re ]] && [ $(date --date="$1" +%s) -gt $(date --date="$(date '+%Y-%m-%d')" +%s) ]
}

function isValidDir {
	local re='^/[a-zA-Z0-9\/]*$'
        [[ $1 =~ $re ]]
}

function isValidGroups {
	local re='^[[:alnum:]]+([[:alnum:]\,]*[[:alnum:]]+)?$'
        [[ $1 =~ $re ]]
}
