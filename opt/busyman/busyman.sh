#!/bin/bash
echo -e "\u00A9 BUSYMAN \u26AA \u26AA \u26AA \u2b07 [ START ] \u2B50"
PROJECT="busyman"
SCRIPT="busyman.sh"
JOB=$((RANDOM%8999+1000))

# yaml parser, source: https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;p" $1 | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e    "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" | \
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
      if(length($2)== 0){  vname[indent]= ++idx[indent] };
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) { vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, vname[indent], $3);
      }
   }'
}

eval $(parse_yaml /opt/${PROJECT}/${PROJECT}.yml) ### main config file
echo -e "color test: $info $func_name $success $ok $warning $nok $error $nocolor"

source /opt/${PROJECT}/busy-functions # global functions
source /opt/${PROJECT}/busy-config # global variables
source /opt/${PROJECT}/fb/fb-config # fb variables from there

echo -e "${info} PROJECT: $PROJECT ${nocolor}"

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
echo -e "\u2705 [ STOP ] \u26A1"
