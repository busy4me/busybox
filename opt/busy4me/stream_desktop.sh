#!/bin/bash

# change hostname and minion_id from fb-login

SCRIPT=change_hostname.sh
LOGFILE=/var/log/busy4me.log
LOGFILE_CRON=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

logline_cron() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE
	done
}

echo "fb_login: " $(cat /home/busyman/busy4me/fb/fb-login)
	old_hostname=$(cat /etc/hostname)
	old_hostname=$(cat /home/busyman/busy4me/fb/fb-login | tr '@.' '_')

if [ "$old_hostname" == "$old_hostname" ]
then
	echo "   \e[32m...hostname is OK\e[0m, match to fb-login \"$(cat /home/busyman/busy4me/fb/fb-login)\"...exit"
	echo "."
	exit
fi

echo "   ...set new hostname: " $new_hostname
	hostnamectl set-hostname $new_hostname

echo $new_hostname > /etc/salt/minion_id
echo "   ...delete salt minion old certificates..."
	rm /etc/salt/pki/minion/minion*.*

echo "   ...update /etc/hosts file"
	cp /etc/hosts /etc/hosts.bak
	sed -i "/\s$old_hostname/d" /etc/hosts
	echo "127.0.1.1 $new_hostname" >> /etc/hosts

minion_id=$(cat /etc/salt/minion_id)
echo "restart salt-minion service"
	service salt-minion restart &&

echo "       New minion_id"
echo "-----------------------------------------------"
echo "|     " $minion_id
echo "-----------------------------------------------"
echo "...done OK"

service salt-minion status