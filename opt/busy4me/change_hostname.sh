#!/bin/bash
# change hostname and minion_id match to fb-login

SCRIPT=change_hostname.sh
LOGFILE=/var/log/busy4me.log
LOGFILE_CRON=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

echo "fb_login: " $(cat /opt/busy/fb/fb-login)
	old_hostname=$(cat /etc/hostname)
	new_hostname=$(cat /opt/busy/fb/fb-login | tr '@.' '-')

if [ "$old_hostname" == "$new_hostname" ]
then
	echo -e "   \e[32m...hostname is OK\e[0m, match to fb-login \e[32m \"$(cat /opt/busy/fb/fb-login)\"\e[0m...exit"
	echo -e "   ...hostname: \e[32m $new_hostname\e[0m"
	echo -e "...stop"
	exit
fi

echo -e "   \e[35m...hostname is different\e[0m, change to match fb-login \e[32m \n\"$(cat /opt/busy/fb/fb-login)\" \e[0m"

echo "   ...set new hostname: " $new_hostname
	hostnamectl set-hostname $new_hostname
echo "   ...set new minion_id: " $new_hostname
echo $new_hostname > /etc/salt/minion_id
echo "   ...delete salt minion old certificates..."
	rm /etc/salt/pki/minion/minion*.*

echo "   ...update /etc/hosts file"
	cp /etc/hosts /etc/hosts.bak
	sed -i "/\s$old_hostname/d" /etc/hosts
	echo "127.0.0.1 localhost" >> /etc/hosts
	echo "127.0.1.1 $new_hostname" >> /etc/hosts

minion_id=$(cat /etc/salt/minion_id)
echo "restart salt-minion service"
	service salt-minion restart &&

echo "       New minion_id"
echo "-----------------------------------------------"
echo -e "\e[32m|     " $minion_id
echo -e "\e[0m-----------------------------------------------"
echo -e "...done \e[32mOK\e[0m"

service salt-minion status
