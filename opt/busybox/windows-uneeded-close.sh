#!/bin/bash

SCRIPT=windows-uneeded-close.sh
LOGFILE=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

# close uneeded windows every 1s
window02="open file"
window03="Feedback"

while true; do
# method with xdotool
	check1=$(xdotool search --onlyvisible --name "$window02")
	if (($check1 > 0))
	then
		export DISPLAY=:0 && xdotool search --onlyvisible --name $window02 windowactivate
		export DISPLAY=:0 && xdotool key Escape
	fi

# method with wmctrl (no need no activating window)
	wmctrl -c "$window03"

# do this every 5s
	sleep 5
done
