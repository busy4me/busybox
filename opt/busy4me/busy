#!/bin/bash
#help# Usage:	busy <function> [command]
#help# functions:	start, stop, status
#help# commands: fb-walking-around, fb-login, fb-init,

source /opt/busy4me/busy-functions # global functions
source /opt/busy4me/busy-config # global variables
source /opt/busy4me/fb/fb-config # fb variables from there
# source /opt/busy4me/fb/fb-post # fb post variables from there
# source /opt/busy4me/fb/fb-user # fb user variables from there
# edited from Atom

SCRIPT=busy

#screen_name="xterm-"$DISPLAY
#screen_task="/opt/busy4me/xterm.sh --screen busy"$DISPLAY
#screen -S $screen_name -X kill # kill screen on this display
#screen -dmS $screen_name $screen_task

#echo -e "login="$login "| user_first_name="$user_first_name "| user_last_name="$user_last_name | logline
#echo -e "login_string = "$login_string | logline
# echo -e "\e[42m\e[30m user_db = \e[0m\e[32m" $user_db "\e[0m" | logline

JOB=$((RANDOM%8999+1000))

if [ $USER = "root" ]; then
 echo -e "\e[92m[info]\e[0m don't run as root ... \n\
 test color codes:\
 \e[90m text \e\[90m \e[0m \e[41m 41 \e[42m 42 \e[43m\e[30m 43+30 \e[0m\e[44m 44 \e[45m 45 \e[46m\e[30m 46+30 \e[0m\e[100m 100 \e[0m\e[101m\e[30m 101+30 \e[0m\e[102m\e[30m 102+30 \e[0m\e[103m\e[30m 103 \e[0m\e[104m 104 \e[105m\e[30m 105+30 \e[0m\e[36m \n\
 \e[92m[info]\e[0m login as busyman ...\e[0m ... \n usage: busy --help"
 su busyman
fi

Arg_2 () {
		echo -e "\e[104mfunc: Arg_2 \e[0m\e[96m - SCRIPT=$SCRIPT JOB=$JOB ... \e[0m" | logline
	case $second in
		enable)
		enable-crontab-job $third
		;;
		disable)
		disable-crontab-job $third
		;;
		status)
		crontab -l
		;;
		*)
			echo -e "\e[31m  ... Bad 2nd argument: \e[0m $arg"
			help
		;;
	esac
}

# without echo message
#if ! [[ $2 == "--clip-clear" ]]; then
#	echo -e "\e[44m\e[90m SCRIPT=$SCRIPT \e[0m\e[33m Action: $1 ...  \e[0m $0 $1 $2 $3 $4 $5 $6 $7"
#fi

case $1 in
	USER|fb-user)
  	USER $2
	;;
	--screen-status)
  	status
  	exit 0
	;;
	--stop-walking|stop-walking|stop-fb-walking-around)
  	stop-walking
	;;
	--start-walking|start-walking|start-fb-walking-around)
  	start-walking
	;;
	--stop-mouse-move-around|stop-mouse-move-around)
  	stop-mouse-move-around
	;;
	--start-fb-save-my-groups|start-fb-save-my-groups)
  	stop-walking
  	stop-mouse-move-around
  	start-fb-save-my-groups
	;;
	start) #help# busy start [command]	- start specific task in the screen session, eg. busy start fb-walking-around
  	start $2 $3 $4 $5 $6 $7
	;;
	stop) #help# busy stop [command]	- stop specific task in the screen session
  	stop $2 $3 $4
	;;
	status) #help# busy status		- show status
  	status $2
  	echo -e "\e[33m$_TASK_VAR=$_VAL\e[0m"
	;;
  	--set_crontab|set_crontab)
  	set_crontab $2
	;;
  	COMMENT)
  	COMMENT $2 $3
	;;
  	CRON|CRONTAB)
  	echo $2
  	echo $3
  	CRON $2 $3
	;;
  	FIND)
  	FIND $2 $3 $4
	;;
  	DB)
  	DB $2 '\'$3 $4 $5 $6 $7
	;;
  	SYSTEM)
  	SYSTEM $2
	;;
  --help|-h|-\?)
		echo -e "\e[32m # [OK] \e[0m\e[95m $0 --help \e[33m\e[0m"
		$0 __help
	;;
  "$1")
    $1 $2 $3 $4 2>/dev/null
    if [ ! $? == "0" ]; then
      echoerror "$1 - command not found, try $0 --help"
    fi
  ;;
	'')
  	echo -e "\e[44m\e[90m SCRIPT=$SCRIPT \e[0m\e[33m no arguments: \e[0m $1 ... $0 $1 $2 $3"
	;;
	*)
  	echo -e "\e[41m SCRIPT=$SCRIPT \e[0m\e[31m Bad arguments: \e[0m $1 ... $0 $1 $2 $3"
  	first=$1
	;;
esac
