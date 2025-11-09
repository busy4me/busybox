#!/bin/bash
# unused
# change hostname, this is done by 'initiv __change_hostname'
# ============================================================
# === hostname structure:                                  ===
# === HWMACADDRESS-NETMACADRESS                            ===
# === where: HWMACADDRESS - hardware MAC address from UUID ===
# ===        NETMACADDRESS - network card MAC address      ===
# ============================================================

SCRIPT=change_hostname.sh
LOGFILE=/var/log/busy4me.log
LOGFILE_CRON=/var/log/busy4me_cron.log
source /opt/busy4me/fb/fb-config

# for checking
# echo "bleble" > /etc/salt/minion_id

echo "fb_login: " $(cat /opt/busy/fb/fb-login)
	old_hostname=$(cat /etc/hostname)
	old_minion_id=$(cat /etc/salt/minion_id)
	# === DELETED , previously minion_id match to fb-login ===
	#	new_hostname=$(cat /opt/busy/fb/fb-login | tr '@.' '-')
_UUID=$(cat /sys/class/dmi/id/product_uuid | sed 's/.*-//')
_UUID_MAC=$(echo $_UUID | sed 's/.*-//')
_MAC=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address | tr ':' ' ' | tr '\n' ' ' | sed 's/[[:space:]]//g')
	new_hostname="$_UUID_MAC-$_MAC"

if [ "$old_hostname" == "$new_hostname" ] && [ "$old_minion_id" == "$new_hostname" ]; then
#	echo -e "   \e[32m...hostname is OK\e[0m, match to fb-login \e[32m \"$(cat /opt/busy/fb/fb-login)\"\e[0m...exit"
	echo -e " old_hostname=\e[32m$old_hostname\e[0m  ...new_hostname=\e[32m$new_hostname\e[0m"
	echo -e " old_minion_id=\e[32m$old_minion_id\e[0m ...GOOD"
	exit
fi

echo -e " *\e[35m ... different data ... \e[0m, new_hostname=\e[32m$new_hostname\e[0m"
	hostnamectl set-hostname $new_hostname
echo -e "   ...set new minion_id: " $new_hostname
echo $new_hostname > /etc/salt/minion_id
echo -e "   ...delete salt minion old certificates..."
	rm /etc/salt/pki/minion/minion*.*

echo "   ...update /etc/hosts file"
	cp /etc/hosts /etc/hosts.bak
	sed -i "/\slocalhost/D" /etc/hosts
	sed -i "/\s$old_hostname/D" /etc/hosts
	sed -i "/\s127.0.1.1/D" /etc/hosts
#	sed -i "s/127.0.1.1/g" /etc/hosts
	echo "127.0.0.1 localhost" >> /etc/hosts
	echo "127.0.1.1 $new_hostname" >> /etc/hosts

minion_id=$(cat /etc/salt/minion_id)
echo "  * restart salt-minion service"
	service salt-minion restart &&

echo "       New minion_id"
echo "-----------------------------------------------"
echo -e "\e[32m|     " $minion_id
echo -e "\e[0m-----------------------------------------------"
echo -e "...done \e[32mOK\e[0m"

service salt-minion status
