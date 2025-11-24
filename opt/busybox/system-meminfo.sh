#!/bin/bash
# compare two files
# Get base64 encoded image
#IMG1="$(cat ~/an_image.jpg | base64)"
#IMG2="$(cat ~/another_image.jpg | base64)"
# that could be compare two binaries as above

# executed by cron, compare two files busybox.log every 5 min
# if same that means nothing happening and reboot, and write 0 to file /tmp/busybox_reboot
# if different, keep going
# 

SCRIPT=system-meminfo.sh
LOGFILE=/var/log/busybox.log
source /opt/busybox/fb/fb-config

logline() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE
	done
}


# memory usage
echo $(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }') | logline

