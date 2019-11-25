#!/bin/bash

SCRIPT=windows-uneeded-close.sh
LOGFILE=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

# close uneeded windows every 1s
window2="open file"

while true; do 
	check1=$(xdotool search --onlyvisible --name "$window2")
	
	if (($check1 > 0))
	then
		export DISPLAY=:0 && xdotool search --onlyvisible --name $window2 windowactivate
		export DISPLAY=:0 && xdotool key Escape
	fi
	sleep 5
done

