#!/bin/bash
SCRIPT=xterm.sh
source /opt/busy4me/busy-functions # global functions
source /opt/busy4me/busy-config # global variables
echo -e "\e[35m start script ... ... \e[0m"

xterm_start () {
echo -e "\e[31m start xterm....\e[0m"
xterm & 2>/dev/null
sleep 1
xdotool search --onlyvisible --class xterm windowactivate
wmctrl -l
transset -a 0.7
wmctrl -i -r $(wmctrl -l | grep -i xterm | awk '{print $1}') -b add,above -e 1,400,190,300,300
xdotool key Alt+Tab
}

xterm_stop () {
echo -e "remove transparent xterm...."
wmctrl -i -r $(wmctrl -l | grep -i xterm | awk '{print $1}') -b remove,above
xdotool search --onlyvisible --class xterm windowkill
xdotool search --onlyvisible --name xterm windowkill
}

xterm_screen_stop () {
wmctrl -i -r $(wmctrl -l | grep -i screen | awk '{print $1}') -b remove,above
xdotool search --onlyvisible --class screen windowkill
xdotool search --onlyvisible --name screen windowkill
}

xterm_screen_start () {
echo -e "\e[34m xterm with screen attached .... \e[33m screen -x $screen_name \e[0m"
xterm_arg="screen -x $screen_name"
xterm -font -*-*-*-*-*-*-8-*-*-*-*-*-*-* -hold -e $xterm_arg &
sleep 1
transset -n screen -t 0.7
#xterm -font -*-*-*-*-*-*-8-*-*-*-*-*-*-* -hold -e $xterm_arg -fn 6 &
#xterm -hold -e 'screen -x fb-walking-around' &
#sleep 1
#xdotool search --onlyvisible --class screen windowactivate
#transset -a 0.8
#wmctrl -i -r $(wmctrl -l | grep -i screen | awk '{print $1}') -b add,above
#wmctrl -i -r $(wmctrl -l | grep -i screen | awk '{print $1}') -e 1,390,340,400,190
#xdotool key Alt+Tab
#wmctrl -l

scr=$(screen -ls)
while [[ $scr == *$screen_name* ]]; do
	sleep 1
	scr=$(screen -ls)
done
xterm_screen_stop
}

case $1 in
	--start|start)
	xterm_start
	;;
	--stop|stop)
	xterm_stop
	;;
	--restart|restart)
	xterm_stop
	xterm_start
	;;
	--screen)
	xterm_screen_stop
	screen_name=$2
	xterm_screen_start
	;;
esac
	