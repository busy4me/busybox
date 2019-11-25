#!/bin/bash

# change hostname and minion_id match to UUID

SCRIPT=change_hostname.sh
LOGFILE=/var/log/busy4me.log
LOGFILE_CRON=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

logline() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE
	done
}

# check UUID, two methods
uuid_1=$(cat /sys/class/dmi/id/product_uuid)
uuid_2=$(dmidecode -s system-uuid)

echo "UUID: " $(cat /sys/class/dmi/id/product_uuid)
	old_hostname=$(cat /etc/hostname)
	old_hostname_uppercase=$(cat /etc/hostname | tr a-z A-Z)
	new_hostname=busy-$(cat /sys/class/dmi/id/product_uuid)
	new_hostname_lowercase=busy-$(cat /sys/class/dmi/id/product_uuid | tr A-Z a-z)

	minion_id=$(cat /etc/salt/minion_id)

if [ "$old_hostname" == "$new_hostname_lowercase" ] && [ "$minion_id" == "$new_hostname_lowercase" ]
then
	echo -e "   \e[32m...hostname is OK\e[0m, match to uuid \"$new_hostname_lowercase\"...exit"
	echo -e "...stop"
	exit
fi

echo -e "   \e[35m...hostname is different\e[0m, change to uuid lowercase\e[35m \n\"$new_hostname_lowercase\" \e[0m"

echo "   ...set new hostname: " $new_hostname
	hostnamectl set-hostname $new_hostname_lowercase
echo "   ...set new minion_id: " $new_hostname_lowercase
echo $new_hostname_lowercase > /etc/salt/minion_id
echo "   ...delete salt minion old certificates..."
	rm /etc/salt/pki/minion/minion*.*

echo "   ...update /etc/hosts file"
	cp /etc/hosts /etc/hosts.bak
	sed -i "/\s$old_hostname/d" /etc/hosts
	sed -i "/\s$old_hostname_uppercase/d" /etc/hosts
	echo "127.0.0.1 localhost" >> /etc/hosts
	echo "127.0.1.1 $new_hostname" >> /etc/hosts

minion_id=$(cat /etc/salt/minion_id)
echo "restart salt-minion service"
	service salt-minion restart &&

echo "       New minion_id"
echo "-----------------------------------------------"
echo -e "\e[32m|     " $minion_id
echo -e "\e[0m-----------------------------------------------"
echo -e "...done \e[32m OK \e[0m"

service salt-minion status