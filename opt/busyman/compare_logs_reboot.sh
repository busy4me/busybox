#!/bin/bash
# compare two files
# Get base64 encoded image
#IMG1="$(cat ~/an_image.jpg | base64)"
#IMG2="$(cat ~/another_image.jpg | base64)"
# that could be compare two binaries as above
# executed by cron, compare two files busyman.log every 5 min
# if same that means nothing happening and reboot, and write 0 to file /tmp/busyman-reboot
# if different, keep going 
PROJECT="busyman"
SCRIPT=compare_logs_reboot.sh
source /opt/${PROJECT}/${PROJECT}.cfg
LOGFILE_CRON=/var/log/${PROJECT}_cron.log

logline_cron() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE_CRON
	done
}

clean_scrot_files () {
echo -e "\e[33m Clean scrot files... \e[0m" | logline
rm /opt/${PROJECT}/data/scrot/fb-walking-around/*
}
	
echo "$(date +%F' '%T) $USER $SCRIPT start compare $LOG1 and $LOG2"

# check memory usage
memcheck() {
	memory_total=$(free -m | awk 'NR==2{printf "%s\n", $2 }')
	memory_summary=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
	memory_usage=$(free -m | awk 'NR==2{printf "%s\n", $3,$2,$3*100/$2 }')
	memory_usage_percent=$(free -m | awk 'NR==2{printf "%s %.2f%%\n", $3,$2,$3*100/$2 }')
		percent=$(($memory_usage * 100 / $memory_total))
		echo -e "\e[33m" $percent"% usage ...\e[0m "
	limit1=80
	limit2=90
		if [ "$percent" -le "$limit1" ]; then
			echo -e $memory_usage"/"$memory_total"MB ("$percent"%)\e[32m... is lower than limit" $limit1"% \e[0m" | logline_cron
		elif [ "$percent" -ge "$limit1" ] && [ "$percent" -le "$limit2" ]; then
			echo -e $memory_usage"/"$memory_total"MB ("$percent"%)\e[33m ... is higher than limit" $limit1"% \e[0m" | logline_cron
			# clear cache
			echo -e "\e[43m\e[30m|\e[0m\e[33m Clear cache ... \e[0m" | logline_cron
			sync && echo 3 > /proc/sys/vm/drop_caches
			memory_usage=$(free -m | awk 'NR==2{printf "%s\n", $3,$2,$3*100/$2 }')
			percent=$(($memory_usage * 100 / $memory_total))
			echo -e $memory_usage"/"$memory_total"MB ("$percent"%) ... after clear" | logline_cron
		elif [ "$percent" -ge "$limit2" ]; then
			echo -e $memory_usage"/"$memory_total"MB ("$percent"%)\e[31m memory usage is higher than" $limit2 "%!... oh oh ... reboot\e[0m" | logline_cron
			clean_scrot_files
			# reboot
			echo -e "\e[41m\e[30m|\e[0m\e[31m Reboot in 3s ... \e[0m" | logline_cron
			sleep 3
			/sbin/shutdown -r now
		fi
	exit
}

logcompare() {
  # check if the logs are the same
  LOG1="$(cat /tmp/${PROJECT}_tmp.log | base64)"
  LOG2="$(cat /var/log/${PROJECT}.log | base64)"
  echo -e "\e[33m check if the logs are the same... \e[0m"
  if [ "$LOG1" == "$LOG2" ]; then
	echo -e "\e[31m Yes... \e0m"
	echo "_____ ____ ___ __ _ Aw, snap! logs are same! no activity?... reboot now..." | logline_cron
	clean_scrot_files
	/sbin/shutdown -r now
  else
	echo "logs are different, good :) work in progress ..." | logline_cron
  fi
  echo -e "\e[32m Remove old busyman_tmp.log... \e[0m"
  rm /tmp/${PROJECT}_tmp.log
  echo -e "\e[32m Copy new busyman.log... \e[0m"
  cp /var/log/${PROJECT}.log /tmp/${PROJECT}_tmp.log
  # check if marked to reboot by busyuser
  echo -e "\e[33m check if marked to reboot by busyuser... \e[0m"
  if [ -f /tmp/${PROJECT}-reboot ]; then
	echo "/tmp/${PROJECT}-reboot exists... check inside..." | logline_cron
	r="$(cat /tmp/${PROJECT}-reboot)"
	if [ "$r" != 0 ]; then
	  echo -e "\e[31m Yes... \e0m"
	  echo "0" > /tmp/${PROJECT}}-reboot | logline_cron
	  echo "___________________ ____ ___ __ _ oh no! marked for reboot... reboot now..." | logline_cron
	  clean_scrot_files
	  /sbin/shutdown -r now
	else
	  echo "no marked for reboot, continue..." | logline_cron
	fi
  else
	echo -e "\e[32m No... \e0m"
	echo "0" > /tmp/${PROJECT}-reboot | logline_cron
	chown busyman:busyman /tmp/busyman-reboot
  fi
}

case $1 in
  -m|memcheck)
	memcheck
	exit
  ;;
  -l|logcompare)
	logcompare
  ;;
  *)
  ;;
esac
