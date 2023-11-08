#!/bin/bash
echo -e "\u00A9 BUSYMAN \u26AA \u26AA \u26AA \u2b07 [ START ] \u2B50"
PROJECT="busyman"
SCRIPT="busyman.sh"
source /opt/${PROJECT}/${PROJECT}.cfg # global variables
JOB=$((RANDOM%8999+1000))

__help () {
	grep -E '^*#help#' "$0" | sed -e 's|#help#|\||g' | column -s"|" -t
}

busyman_log () {
if ! [ -f /var/log/busyman.log ];then
	touch /var/log/busyman.log
	chmod 777 /var/log/busyman.log
fi
}

# set echo types
echotest() {
    	echo "test"
}

echoerror() {
    printf "${lred}[ ERROR ]${red} %s${nocolor}\\n" "$@" 1>&2;
}

echostop() {
    printf "${lred}[ STOP ]${lred} %s${nocolor}\\n" "$@" 1>&2;
}

echopause() {
    printf "${lyel}[ PAUSE ]${yel} %s${nocolor}\\n" "$@" 1>&2;
}

echowarning() {
    printf "${lyel}[ WARNING ]${lmag} %s ${nocolor}\\n" "$@" 1>&2;
}

echoinfo() {
    printf "${lblu}[ INFO ]${lcya} %s ${nocolor}\\n" "$@" 1>&2;
}

echoresult() {
    printf "${lmag}[ RESULT ]${mag} %s ${nocolor}\\n" "$@" 1>&2;
}

echoconfirm() {
    printf "${mag}[ CONFIRMATION ]${lmag} %s ${nocolor}\\n" "$@" 1>&2;
}

echosuccess() {
    printf "${gre}[ SUCCESS ]${lgre} %s ${nocolor}\\n" "$@" 1>&2;
}

echofunc() {
    printf "${lwhi}[ FUNCTION ]${nocolor}${lwhi} %s${nocolor}\\n" "$@" 1>&2;
}

echook() {
    printf "${lgre}[ OK ]${gre} %s${nocolor}\\n" "$@" 1>&2;
}

gen_random() { # generate random number between two values, usage: generate_random [min] [max]
  min=$1
  max=$(( $2 + 1 ))
#  diff=$((max-min+1))
  diff=$((max-min))
#  random=$(($(($RANDOM%$diff))+min))
  random=$(( ( RANDOM % $diff ) + $min ))
  echo $random
  if [ -n "$3" ]; then
    echo "debug=$3 :: min=$min max=$max diff=$diff random=$random"
  fi
}

# screenshot to local catalog
scrot_local () {
  code="-"$1
  mkdir -p /opt/${PROJECT}/data/scrot/$SCRIPT
  scrot1="/opt/${PROJECT}/data/scrot/$SCRIPT/$(date +%Y%m%d-%H%M%S)-$JOB-scrot$DISPLAY$code.jpg"
  scrot -q 50 ${scrot1}
  echo -e "\e[33m code: \e[35m" ${code} "\e[33m scrot file: \e[35m" ${scrot1} "\e[0m" | logline
}

move_mouse () { # move mouse to position x:y or move to x=0:y=0, usage: move_mouse [x] [y]
	echofunc "${FUNCNAME[0]}""<< ${FUNCNAME[1]}""<< ${FUNCNAME[2]}""<< ${FUNCNAME[3]}"
	sleep 0.5
	if [[ -n "$1" ]]; then
		echoinfo "move mouse: x=$1 y=$2"
		xdotool mousemove --sync --clearmodifiers $1 $2
		return
	else
		xdotool mousemove --sync --clearmodifiers 0 0
	fi
}

hide_window () {
  echofunc "${FUNCNAME[0]}"
  echoinfo "hide window..."
  scrot /tmp/scrot${DISPLAY}.png
  feh --bg-scale /tmp/scrot${DISPLAY}.png
  transset -a 0 # hide window for a moment
  xdotool key --delay 200 Ctrl+a Ctrl+c Ctrl+Shift+a
  transset -a 0.9
  feh --bg-scale /opt/${PROJECT}/data/images/wall_black_with_vertical_logo.jpg
}

# mark machine for root to reboot in next cronjob
# see root's crontab
mark_for_reboot () {
	echo -e "\e[101m mark it for root to reboot ...\e[0m" | logline
	echo "1" > /tmp/${PROJECT}-reboot
}

cron-enable () {
echo ""
}

reset () {
	stop
	start
}

start () {
	echofunc "${FUNCNAME[0]}""<< ${FUNCNAME[1]}""<< ${FUNCNAME[2]}""<< ${FUNCNAME[3]}" | logline
	_TASK=$1
	_OPT_1=$2
	_OPT_2=$3
	_OPT_3=$4
	_OPT_4=$5
	_OPT_5=$6
  if [ -z "$_TASK" ]; then
	screen -dmS frame00$DISPLAY '/opt/busyman/frame00' # default task to run: frame00
	sleep 2
	screen -ls
	return
  fi
  task_to_do="$_TASK $_OPT_1 $_OPT_2 $_OPT_3 $_OPT_4 $_OPT_5"
  echoinfo "task_to_do=$task_to_do"
  screen -dmS $_TASK$_OPT_1$_OPT_2$_OPT_3$_OPT_4$_OPT_5$DISPLAY '$task_to_do'
  _PROCESS=$(screen -ls | tee /dev/tty)
  if echo "$_PROCESS" | grep -q "$_TASK$_OPT_1$_OPT_2$_OPT_3$_OPT_4$_OPT_5$DISPLAY"; then
	echosuccess "$task_to_do running succesfully"
  else
	echoerror "something wrong, cant see $task_to_do"
  fi
}

stop () {
	echofunc "${FUNCNAME[0]}""<< ${FUNCNAME[1]}""<< ${FUNCNAME[2]}""<< ${FUNCNAME[3]}" | logline
	_PROCESS=$(screen -ls)
	_TASK=$1
	if [ -z "$_TASK" ]; then
		for scr in $(screen -ls | awk '{print $1}'); do screen -S $scr -X kill; done
		screen -wipe
#		screen -S frame00$DISPLAY -X kill # kill frame00
#		screen -ls
		return
	fi
	if echo "$_PROCESS" | grep -q "$_TASK$DISPLAY"; then
		echoinfo "going to stop $_TASK on DISPLAY=$DISPLAY"
	else
		echoerror "can't see $_TASK on DISPLAY=$DISPLAY, are you sure is it running?"
		_PROCESS=$(screen -ls | tee /dev/tty)
		return 1
	fi
	screen_stop=$(screen -S $_TASK$DISPLAY -X kill)
	if [[ $screen_stop == *"There are several suitable screens"* ]]; then
		echo -e "\e[41m Error... There are several suitable screens... kill them... \e[0m"
		pkill screen
	fi
	_PROCESS=$(screen -ls | tee /dev/tty)
	if echo "$_PROCESS" | grep -q "$_TASK$DISPLAY"; then
		echoerror "cant stop it"
	else
		echoconfirm "$_TASK stopped on DISPLAY=$DISPLAY"
	fi
}

start-walking () {
	echo -e "\e[32m start fb-walking-around in screen $DISPLAY...\e[0m"
	screen_start=$(screen -dmS fb-walking-around$DISPLAY '/opt/busyman/fb/fb-walking-around')
	echo $screen_start
}

stop-walking () {
	screen -ls
	echo -e "\e[95m stop fb-walking-around in screen $DISPLAY...\e[0m"
	screen_stop=$(screen -S fb-walking-around$DISPLAY -X kill)
	if [[ $screen_stop == *"There are several suitable screens"* ]]; then
		echo -e "\e[41m Error... There are several suitable screens... kill them... \e[0m"
		pkill screen
	fi
	screen -ls
}

stop-mouse-move-around () {
echo -e "\e[95m stop stop-mouse-move-around in screen $DISPLAY...\e[0m"
screen -S mouse-move-around$DISPLAY -X kill
}

stop-fb-save-my-groups () {
	screen_stop=$(screen -S fb-save-my-groups$DISPLAY -X kill)
	if [[ $screen_stop == *"There are several suitable screens"* ]]; then
		echo -e "\e[41m Error... There are several suitable screens... kill them... \e[0m"
		pkill screen
	fi
}

start-fb-save-my-groups () {
	screen_start=$(screen -dmS fb-save-my-groups$DISPLAY '/opt/busyman/fb/fb-save-my-groups')
	echo $screen_start
}

function status () {
_TASK=$1
screen -ls
_TASK_VAR=$(echo "$_TASK" | tr '-' '_' | tr ':' '_')
if ! screen -list | grep -q "$_TASK"; then
		_VAL="false"
		IFS= read -r "$_TASK_VAR" <<<"false"
	else
		_VAL="true"
		IFS= read -r "$_TASK_VAR" <<<"true"
fi
#echo $_TASK_VAR
#export "$_TASK_VAR=$_VAL"
#ptintf -v $_TASK_VAR %s "$_VAL"# create variable named $_TASK_VAR with value $_VAL
#echo $_TASK_VAR
#echo -e "\e[33m$_TASK_VAR=$_VAL\e[0m"
#if ! screen -list | grep -q "fb-walking-around$DISPLAY"; then
#		echo -e "\e[33m ... screen fb-walking-around$DISPLAY not exists! \e[0m"
		#screen -S ScreenName -X quit
#	else
#
#		echo -e "\e[33m ... screen fb-walking-around$DISPLAY exists \e[0m"
#fi

}

function COMMENT () {
echo -e "\e[44m SCRIPT=$SCRIPT Func: COMMENT \e[0m" | logline
case $1 in
	all|--all|-a)
		CRON disable
		stop-mouse-move-around
		stop-walking
		screen_task="/opt/busyman/fb/fb-post COMMENT "$1
		screen_name="busy"$DISPLAY
		echo -e "\e[43m\e[30m start screen session: \e[0m\e[95m screen -dmS $screen_name $screen_task \e[0m" | logline
		screen -S $screen_name -X kill # kill screen on this display
		screen -dmS $screen_name $screen_task
		CRON enable
	;;
	*fb*com*permalink*)
		CRON disable
		stop-mouse-move-around
		stop-walking
		screen_task="/opt/busyman/fb/fb-post COMMENT "$1
		screen_name="busy"$DISPLAY
		echo -e "\e[43m\e[30m start screen session: \e[0m\e[95m screen -dmS $screen_name $screen_task \e[0m" | logline
		screen -S $screen_name -X kill # kill screen on this display
		screen -dmS $screen_name $screen_task
		CRON enable
	;;
	*)
		echo -e "... \e[33m" $1 "\e[31m ... wrong argument ...\e[0m" | logline
	;;
esac
}

# set crontab
set_crontab () {
task=$1
case $task in
	"all"|"fb-post -c all"|"fb-post")
		empty=""
		cron=$(crontab -l)
		case $cron in
			*$task*)
			echo -e "\e[32m crontab already has task: \e[33m $task ... \e[0m" | logline
			;;
			$empty)
			echo -e "\e[31m crontab is empty ... add task: \e[33m $task \e[0m" | logline
			crontab -l | echo "*/5 * * * * export DISPLAY=:0 && /opt/busyman/fb/fb-post -c all" | crontab - | logline
			;;
			*)
			echo -e "\e[31m crontab is not contains \e[33m $task ... add task: $task \e[0m" | logline
			crontab -l | echo "*/5 * * * * export DISPLAY=:0 && /opt/busyman/fb/fb-post -c all" | crontab - | logline
			;;
		esac
		echo -e "\e[32m crontab: \e[33m" | logline
		crontab -l | logline
		echo -e "\e[0m"
	;;
	*)
		echo -e "declare task ... \e[33m" $task "\e[31m ... wrong argument ...\e[0m" | logline
	;;
esac
}

function CRON () {
  echo -e "\e[44m SCRIPT=$SCRIPT Func: CRON \e[0m" | logline
  action=$1
  job=$2
  echo -e "action: " $action
  echo -e "job: " $job
  case $1 in
	disable|--disable)
	  echo -e "\e[91m # disable \e[95m crontab job ... $job\e[90m"
	  crontab -l | sed "/^[^#].*export DISPLAY=$DISPLAY && \/opt\/busyman\/fb\/$job/s/^/#/" | crontab -
	  crontab -l | sed "/^[^#].*export DISPLAY=$DISPLAY && \/opt\/busyman\/busy/s/^/#/" | crontab -
	  crontab -l
    ;;
	enable|--enable)
	  echo -e "\e[32m # enable \e[95m crontab job ... $job \e[90m"
	  crontab -l | sed "/^#.*export DISPLAY=$DISPLAY && \/opt\/busyman\/fb\/$job/s/^#//" | crontab -
	  crontab -l | sed "/^#.*export DISPLAY=$DISPLAY && \/opt\/busyman\/busy/s/^#//" | crontab -
	  crontab -l
	;;
	status|--status)
	  crontab -l
	;;
	setup|--setup)
	  echo -e "setup job: \e[33m $job \e[0m"
	  set_crontab $job
	;;
	*)
 	  echo -e "\e[41m # bad argument \e[95m $1 \e[33m"
	;;
esac
}

# disable crontab job
disable-crontab-job () {
  echo ""
}

# enable crontab job
enable-crontab-job () {
  echo "enable-crontab-job empty"
}

function FIND () {
  echo -e "\e[44m SCRIPT=$SCRIPT Func: FIND \e[0m" | logline
  echo -e "action: "$action "job: "$job
}


function DB () {
  # syntax: busy DB SELECT * FROM table WHERE column=value
  # eg. busy DB SELECT * FROM fb_groups WHERE admins=0
  echo -e "\e[44m SCRIPT=$SCRIPT Func: DB \e[0m" | logline
  action=$1 # SELECT
  tab=$2; tab=$(echo $tab | sed 's/\\//')
  data=$3
  target=$2; target=$(echo $target | sed 's/\\//')
  table=$4
  clause=$5 # WHERE
  condition=$6 # column=value
  echo -e "action=$action tab=$tab target=$target table=$table clause=$clause condition=$condition"
  case $1 in
	SELECT)
	  sqlite3 -header -column $user_db "SELECT $target FROM $table $clause $condition;"
	;;
	--show|-s)
	  echo -e "\e[91m arg: \e[95m $1 $2 \e[0m show tables: \e[35m"
	  sqlite3 $user_db "SELECT name FROM sqlite_master WHERE type='table';"
	  echo -e "\e[33mread table:\e[95m $tab\e[0m"
	  sqlite3 -header -column $user_db "SELECT * from '$tab';"
	;;
	--drop-table|--drop)
	  echo -e "\e[41m \e[0m\e[31m Warning! ... \e[33m drop table:\e[95m $tab\e[0m"
	  sqlite3 $user_db "DROP TABLE '$tab';"
	;;
	--clear-data|--clear|--delete)
	  echo -e "\e[41m \e[0m\e[31m Warning! ... \e[33m delete data from:\e[95m $tab\e[0m"
	  sqlite3 $user_db "DELETE FROM '$tab';"
	;;
	--insert-test)
	  echo -e "\e[43m \e[0m\e[33m Insert test data into table: \e[95m $tab\e[0m"
	  sqlite3 $user_db "INSERT INTO '$tab' (name,first_name,middle_name,last_name,user_name,email,pass,fb_lang,post_lang)
	  VALUES (
	  'Firstname Lastname',
	  'Firstname',
	  'Middlename',
	  'Lastname',
	  'UserName',
	  'username@emailprovider.com',
	  '',
	  'English',
	  'German,English'
	  );"
	  sqlite3 $user_db "INSERT INTO 'fb_plan' (name) VALUES ('name of group');"
	;;
	--create-table|--create)
	  sqlite3 $user_db "SELECT 1;"
	  #create sqlite3 TABLE 'fb_user' in user database
	  case $tab in
		socialmedia)
			sqlite3 $user_db "CREATE TABLE socialmedia (
			id INTEGER UNIQUE PRIMARY KEY,
			short TEXT,
			name TEXT,
			url TEXT,
			lang TEXT,
			label TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
		;;
		fb_user)
			sqlite3 $user_db "CREATE TABLE fb_user (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			first_name TEXT,
			middle_name TEXT,
			last_name TEXT,
			user_name TEXT,
			email TEXT UNIQUE,
			pass TEXT,
			fb_lang TEXT,
			post_lang TEXT,
			label TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
		;;
		fb_posts)
			sqlite3 $user_db "CREATE TABLE fb_posts (
			id INTEGER UNIQUE PRIMARY KEY,
			url TEXT UNIQUE,
			owner TEXT,
			PostDate DATE,
			CheckDate DATE,
			CheckCounter INTEGER,
			CommCounter INTEGER,
			lock INTEGER,
			label TEXT,
			LabelCounter INTEGER,
			who TEXT,
			comment TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# posts that created in the fb groups, posts collected from user Activity Log
			# url is usualy a permalink
		;;
		fb_groups)
			#create sqlite3 TABLE 'fb_groups' in user database
			sqlite3 $user_db "CREATE TABLE fb_groups (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			url TEXT UNIQUE,
			members INTEGER,
			admins INTEGER,
			lang TEXT,
			CatName TEXT,
			CatID TEXT,
			MyStatus TEXT,
			date DATE,
			DateId TEXT,
			label TEXT,
			privacy TEXT,
			history TEXT,
			description TEXT,
			KeyWord TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# MyStatus: joined, pending, ban, requested, admin, moderator
			# DateId: insert, check,
			# privacy: public, closed, secret
		;;
		fb_group__metadata)
			sqlite3 $user_db "CREATE TABLE fb_group__metadata (
			id INTEGER UNIQUE PRIMARY KEY,
			what TEXT,
			url TEXT,
			name TEXT,
			date DATE,
			status TEXT,
			confirm INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# fb_group__metadata: part of url after '*.com/' eg. fb_group_AdChicago (from https://www.facebook.com/AdChicago)
			# what: like, admin, moderator, member, post, video, event, comment, review
			# name: can be part of user's (or page's) url eg. /JohnSmith234 (with slash) or real name eg. John Chris Smith
			# date: when added to the table
			# status: posted, deleted
			# confirm: 1,2...n how many times the status is confirmed
			# stat1: if 'what' is 'member' how many posts detected, if 'what' is 'event' how many 'display' detected
			# eg. table fb_group_AdChicago
			# id | what  | url                   | name                          | date       | status | confirm | stat1 | stat2 |
			# 1  | name  | /AdChicago            | Adevertisment in Chicago Il.  | 2019-05-10 | ok     | 2       | 1     | 1     |
			# 2  | post  | /permalink/1234509876 | /JohnSmith234                 | 2019-05-10 | del    | 5       | 0     | 1     |
			# 3  | admin | /StephenBusyman       | /StephenBusyman               | 2019-05-10 | ok     | 1       | 1     | 0     |
			# 4  | event | /events/0192837465    | /AgnesCaptain                 | 2019-05-10 | ban    | 4       | 267   | 2     |
			# 5  | member| /JoannaLikeME         | Joanna Bird                   | 2019-05-11 | active | 72      | 23    | 456   |
			# 6  | page  | /permalink/2938475601 | /JohnSmith234                 | 2019-05-11 |detected| 4       |
			# 7  | lang  | /permalink/1234509876 | german                        | 2019-05-01 |detected| 2       |
			sqlite3 $user_db "INSERT INTO fb_page__metadata (what,url,name,date,status,confirm,stat1,stat2)
			VALUES (
			'admin',
			'/StephenBusyman1',
			'Stephen Busyman',
			Date('now'),
			'ins',
			'1',
			'0',
			'0'
			);"
		;;
		fb_people)
			#create sqlite3 TABLE 'fb_friends' in user database
			sqlite3 $user_db "CREATE TABLE fb_people (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			url TEXT UNIQUE,
			lang TEXT,
			date DATE,
			DateId TEXT,
			label TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
		;;
		fb_friends)
			#create sqlite3 TABLE 'fb_friends' in user database
			sqlite3 $user_db "CREATE TABLE fb_friends (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			url TEXT UNIQUE,
			lang TEXT,
			date DATE,
			DateId TEXT,
			label TEXT,
			position INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# fb_friends contains all friends collected from user's friends page (url: *.com/AgnesCaptain/friends)
		;;
		fb_user__UrlName)
			sqlite3 $user_db "CREATE TABLE fb_user__UrlName (
			id INTEGER UNIQUE PRIMARY KEY,
			what TEXT,
			url TEXT,
			name TEXT,
			date DATE,
			status TEXT,
			confirm INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# fb_user_UrlName contains info from any user wall page eg. fb_user_JohnSmith234 (from url)
			#
			sqlite3 $user_db "INSERT INTO fb_user_UrlName (what,url,name,date,status,confirm,stat1,stat2)
			VALUES (
			'admin',
			'Stephen Busyman',
			Date('now'),
			'0',
			'0'
			);"
			# insert test table data
		;;
		fb_pages)
			#create sqlite3 TABLE 'fb_pages' in user database
			sqlite3 $user_db "CREATE TABLE fb_pages (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			url TEXT UNIQUE,
			lang TEXT,
			likes INTEGER,
			date DATE,
			DateId TEXT,
			label TEXT,
			created INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# fb_pages contains all fanpages discovered or owned by the user
			# collected from user's pages (url: *.com/AgnesCaptain/pages)
		;;
		fb_page__metadata)
			sqlite3 $user_db "CREATE TABLE fb_page__metadata (
			id INTEGER UNIQUE PRIMARY KEY,
			what TEXT,
			url TEXT,
			name TEXT,
			date DATE,
			status TEXT,
			confirm INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# examples:
			# fb_page__metadata: part of url after '*.com/' eg. fb_page_CarsAndDreams (from https://www.facebook.com/CarsAndDreams)
			# what: like, admin, post, video, event, comment, review
			# name: can be part of user's (or page's) url eg. /JohnSmith234 (with slash) or real name eg. 'John Chris Smith'
			# date: when added to the table
			# eg. table fb_page_CarsAndDreams
			# id | what  | url                | name            | date       | status | confirm | stat1 | stat2 |
			# 1  | post  | /posts/1234509876  | /JohnSmith234   | 2019-05-10 | top    | 2       | 1     | 1     |
			# 2  | admin | /StephenBusyman1   | Stephen Busyman | 2019-05-10 | active | 3       | 1     |
			# 3  | event | /events/0192837465 | /AgnesCaptain   | 2019-05-10 | del    | 3       | 1     |
			# 4  |analyst| /JoannaLikeME      | Joanna Bird     | 2019-05-10 | active | 1
			sqlite3 $user_db "INSERT INTO fb_page__metadata (what,url,name,date,status,confirm,stat1,stat2)
			VALUES (
			'admin',
			'JoannaLikeME',
			'Joanna Bird',
			Date('now'),
			'insert',
			'1',
			'0',
			'0'
			);"
			# insert test data
		;;
		fb_plan)
			#create sqlite3 TABLE 'fb_plan' in user database
			sqlite3 $user_db "CREATE TABLE fb_plan (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			url TEXT UNIQUE,
			date DATE,
			DateId TEXT,
			status TEXT,
			label TEXT,
			posted INTEGER,
			stat1 INTEGER,
			stat2 INTEGER
			);"
			# status: bump, posted, banned, deleted
		;;
		yo_user)
			#create sqlite3 TABLE 'yo_user' YouTube user
			sqlite3 $user_db "CREATE TABLE yo_user (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			first_name TEXT,
			middle_name TEXT,
			last_name TEXT,
			user_name TEXT,
			email TEXT UNIQUE,
			pass TEXT,
			lang TEXT,
			post_lang TEXT,
			label TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
		;;
		in_user)
			#create sqlite3 TABLE 'in_user' Instagram user
			sqlite3 $user_db "CREATE TABLE in_user (
			id INTEGER UNIQUE PRIMARY KEY,
			name TEXT,
			first_name TEXT,
			middle_name TEXT,
			last_name TEXT,
			user_name TEXT,
			email TEXT UNIQUE,
			pass TEXT,
			lang TEXT,
			post_lang TEXT,
			label TEXT,
			stat1 INTEGER,
			stat2 INTEGER
			);"
		;;
		all)
			DB --create-table socialmedia
			DB --create-table fb_user
			DB --create-table fb_posts
			DB --create-table fb_groups
			DB --create-table fb_group__metadata
			DB --create-table fb_people
			DB --create-table fb_friends
			DB --create-table fb_user__UrlName
			DB --create-table fb_pages
			DB --create-table fb_page__metadata
			DB --create-table fb_plan
			DB --create-table yo_user
			DB --create-table in_user
		;;
		*)
			echo -e "$1 ... \e[41m wrong table name: \e[0m\e[95m $2 \e[33m\e[0m"
		;;
	esac
	;;
	--update-data|--update|-ud)
		case $tab in
			groups|fb_groups)
				# update data from Facebook groups
				echo -e "\e[33m  ... CRON disable \e[0m"
				CRON disable
				stop-mouse-move-around
				echo -e "\e[33m  ... stop-walking \e[0m"
				stop-walking
				case $3 in
					category|--category|-cat|-c)
						# screen -dmS fb-groups-$3\:$4$DISPLAY '/opt/busyman/fb/fb-groups $3 $4'
						/bin/bash /opt/busyman/fb/fb-groups $3 $4
					;;
					--key|--key-random|--key-table)
						screen_task="/opt/busyman/fb/fb-groups "$3" "$4
                    	# /bin/bash /opt/busyman/fb/fb-groups $3 $4
					;;
					--collect-info)
						screen_task="/opt/busyman/fb/fb-collect-info "$3" "$4
                    	# /bin/bash /opt/busyman/fb/fb-collect-info $3 $4
					;;
					--save-my-groups)
						screen_task="/opt/busyman/fb/fb-save-my-groups"
						# /bin/bash /opt/busyman/fb/fb-save-my-groups
					;;
					'')
						echo -e "\e[41m bad argument ... \e[0m\e[95m $3 $4 \e[33m\e[0m"
					;;
					*)
						echo -e "\e[41m # wrong --method argument ... \e[0m\e[95m $3 $4 \e[33m\e[0m"
					;;
				esac
				screen_name="busy"$DISPLAY
				echo -e "\e[43m\e[30m start screen session: \e[0m\e[95m screen -dmS $screen_name $screen_task \e[0m" | logline
				screen -S $screen_name -X kill # kill screen on this display
				screen -dmS $screen_name $screen_task
				CRON enable
			;;
			fb_pages)
				CRON disable
				stop-mouse-move-around
				stop-walking
				case $3 in
					--save-my-pages)
						/bin/bash /opt/busyman/fb/fb-save-my-pages
					;;
					*)
						echo -e "\e[41m wrong --method argument ... \e[0m\e[95m $3 $4 \e[33m\e[0m"
					;;

				esac
				CRON enable
			;;
			fb_friends)
				CRON disable
				stop-mouse-move-around
				stop-walking
				case $3 in
					--save-my-friends)
						/bin/bash /opt/busyman/fb/fb-save-my-friends
					;;
					*)
						echo -e "\e[41m wrong --method argument ... \e[0m\e[95m $3 $4 \e[33m\e[0m"
					;;

				esac
				CRON enable
			;;
			*)
			echo -e "$1 ... \e[41m wrong table name: \e[0m\e[95m $2 \e[33m\e[0m"
			;;
		esac
	;;
	*)
	echo -e "\e[41m # ... ... ... ... bad argument ... try: busy --help \e[0m\e[95m $1 \e[33m\e[0m"
	;;
esac
}

function SYSTEM () {
case $1 in
	--clip-clear|-cc)
	xclip -selection clipboard /opt/${PROJECT}/data/files/blank
	[[ $? -eq 0 ]] && echoconfirm "xclip cleared..."
	;;
	*)
		echo -e "\e[41m # bad argument \e[95m $1 \e[33m"
	;;
esac
}

function _extip () {
  # what is my external IP
  # ip
_EXTIP=$(curl -s "http://whatismyip.akamai.com/")
echo $_EXTIP
}

scroll_start () {
memory=$(free -m | awk 'NR==2{printf "%s\n", $3,$2,$3*100/$2 }')
mem=$(free -m | awk 'NR==2{printf "%s\n", $3,$2,$3*100/$2 }')
scroll_limit=200 # max steps
limit=1024 # max memory usage [MB]
full=100
difference="$(( $limit - $memory ))"
factor=$(bc <<< "scale = 4; (($full / $difference))")
while [ $mem -lt $limit ]
do
	xdotool search --sync --onlyvisible --name "youtube" windowactivate | logline
	transset -a 0.9
	scroll_step=20
		for (( i=1; i<$scroll_step; i++ )); do
			scroll_count=$((scroll_count+1))
			xdotool key --delay $kds Down;
			shift 1
		done

		if [ $scroll_count -gt $scroll_limit ]; then
				echo "Scroll step break after $scroll_step steps"
				break
			else
        echo "Scroll step: $scroll_step"
		fi
	mem=$(free -m | awk 'NR==2{printf "%s\n", $3,$2,$3*100/$2 }')
	echo "Difference: $difference"
	echo "Factor: $factor"
	echo "# Random news feed content... \nThis is just a scroll page down and memory usage test.\n \
	Scroll step: $scroll_count/$scroll_limit ...please wait\n\
	\n\
	Usage system memory bar: $mem/$limit MB"
	#echo "$(( ($mem - $memory) *$factor ))"
	usage=$(bc <<< "scale = 0; (( ($mem - $memory) * $factor))")
	echo "$usage"
done | zenity --progress --title="Scrolling in progress..." --text="Testing, testing..." --percentage=0 --no-cancel --auto-close \
		--width 400 --height 110
}

function scroll() {
  (sleep 2 && wmctrl -F -a "Scrolling in progress..." -b add,above) & scroll_start
}

function shake() {
  xdotool key --delay $kd Page_Down End Page_Up Home
}

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
