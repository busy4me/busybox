#!/bin/bash
# Setup busy4.me in user "busyman" home directory or opt directory
#
google-chrome --window-size=800,600 --window-position=0,0 --no-first-run --incognito --no-default-browser-check --disable-translate http://fb.com &&
#google-chrome --window-size=800,600 --window-position=0,0 http://fb.com
BR01="google-chrome" # Browser 01


BR01_position_size () {
xdotool search --sync --onlyvisible --class chrome windowunmap windowmap 
xdotool search --sync --onlyvisible --class chrome windowsize $BR01x $BR01y windowmove 0 -1200
xdotool search --sync --onlyvisible --class chrome windowactivate
xdotool key --delay 200 Ctrl+0
xdotool key --delay 200 Ctrl+minus Ctrl+minus Ctrl+minus
xdotool search --sync --onlyvisible --class chrome windowsize $BR01x $BR01y windowmove 0 -81
xdotool key Alt_L+space m
xdotool keydown Ctrl key Left Left Left Left Left keyup Ctrl
xdotool key --delay 100 Return
}

BR01_probe () {
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
if [ -z "$( xdotool search --onlyvisible --class chrome )" ]; then
		echo "$BR01 non exists... continue..."
		sleep 1
	else
		echo "$BR01 opened successfuly...."
		BR01_position_size
		break
fi
done
}


