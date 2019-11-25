#!/bin/bash

SCRIPT=windows-check.sh
LOGFILE=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

logline() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE
	done
}


unresponsive () {
window1="unresponsive"
check1=$(xdotool search --onlyvisible --name $window1)
if (($check1 > 0))
then
	echo -e "window \e[33m $window1 \e[0m exists! ... \e[31m going to reboot in few minutes ..." | logline
	echo "mark it for root to reboot ..." | logline
	echo "1" > /tmp/busy4me-reboot

else
  echo -e "window \e[33m $window1 \e[32m not exists, uff...\e[0m"  | logline
fi
}

# check if 'page unresponsive' window exists
task_manager () {
window2="Task Manager"
wmctrl -l
if [[ $(wmctrl -l | grep "$window2") ]]; then
	echo -e "\e[31m close window: \e[33m" $window2 "\e[0m Windows list below:"
	wmctrl -c $window2
	else
	echo -e "\e[32m window not exists: \e[33m" $window2 "\e[0m ... OK keep going ... Windows list below:"
fi
wmctrl -l
}

compare_logs_reboot () {
if [ $USER = "root" ]; then
	/bin/bash /opt/busy4me/compare_logs_reboot.sh
fi
}

case $1 in
	unresponsive)
	unresponsive
	compare_logs_reboot
	;;
	task_manager|task)
	task_manager
	;;
	compare_logs_reboot)
	compare_logs_reboot
	;;
	"")
	task_manager
	unresponsive
	compare_logs_reboot
	;;
	*)
	help
	;;
esac
