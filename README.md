1. [Wiki index](https://github.com/busy4me/busy/wiki)  
2. [What is ./busy4.me?](https://github.com/busy4me/busy/wiki#busy4me-is)
3. [Where ./busy4.me can run?](https://github.com/busy4me/busy/wiki#busy4me-can-run)
4. [Main goals](https://github.com/busy4me/busy/wiki#main-goals)
5. User guide  
 • 5.1. Installation  
 • 5.2. Setup  
 • 5.3. Commands  
 • 5.4. Uninstall  
7. [Genesis](https://github.com/busy4me/busy/wiki#genesis)  
• 7.1  
• 7.2  
8. Developers guide  
  • 8.1 Basic syntax  
  • 8.2 Advanced syntax  
  • 8.3 [Old syntax](https://github.com/busy4me/busy/wiki#%EF%B8%8F-old-syntax)  
  • 8.4 [Update](https://github.com/busy4me/busy/wiki#update)  
9. [Copyrights](https://github.com/busy4me/busy/wiki#copyrights-busy4me)

# busy
🐙 busy commands set - to manage "Virtual Assistant" 🌐

basic usage
``` shell
busy [--option=value]... [:place]
```

or

``` shell
busy [sub_command] [--option=value]... [:place]
```

# Selected available options:
🚧 Under construction

## --like
``` shell
--like[="URL"] # to like something eg. post, profile
```
⭐️ EXAMPLE: Active profile will like specific post in socialportal.com, executed in DISPLAY:0
``` shell
busy --like="https://socialportal.com/fanpage/post" :0
```

## --follow
``` shell
--follow[="URL"] # to follow profile from URL
```
☝️ TIP: option without value will will be executed in current opened URL  
⭐️ EXAMPLE: Active profile will follow other profile in socialportal.com, executed in DISPLAY:02
``` shell
busy --like="https://socialportal.com/fanpage/post" :02
```

## --post
``` shell
--post[="database.table.record"] # to prepare and publish a post
```
☝️ TIP: option without value will put the oldest post from defult table from default database  
⭐️ EXAMPLE: Active profile will put a post in socialportal.com, from database "roy_visar_db", table "fb_posts", record "4276", executed in DISPLAY:5
``` shell
busy --like="roy_visar_db.fb_posts.4276" :5
```

## --live
``` shell
--live[=start|=stop|=status] --url[="URL"]
# live streaming to specific rtmp socket
```
☝️ TIP: _live_ option without value will _start_ live streaming eg. "busy --live"  
☝️ TIP: with no _url_ option, default url socket will be used  
⭐️ EXAMPLE: Start Live streaming of DISPLAY:0 to blablavideo.com portal
``` shell
busy --live=start --url="rtmp://live-api.blablavideo.com:80/api=1&key=As4fRws8Q" :0
```

## --login
``` shell
--login[=login_name] --url=["URL"]# to login in specific portal
```
⭐️ EXAMPLE: Active profile will login in socialportal.com, executed in DISPLAY:1
``` shell
busy --login --url="https://socialportal.com" :1
```  
☝️ TIP: _login_ option with no value  

## --share
``` shell
--share[="URL"] # to share something
```
⭐️ EXAMPLE: Active profile will share something in Group "group_name" in socialportal.com, executed in DISPLAY:1
``` shell
busy --share="https://somethingcool.co" --url="https://socialportal.com/group_name" :1
```  

## --join
``` shell
--join[="URL"] # to join somewhere
```
⭐️ EXAMPLE: Active profile will join somewhere
``` shell
busy --join="https://socialportal.com/group_name" :1
```  

## --invite
``` shell
--invite[=database.table] --url=["URL"]# to invite others
```
⭐️ EXAMPLE: Active profile will invite others
``` shell
busy --invite[=roy_visar_db.fb_friends] --url="https://socialportal.com/group_name" :1
```  

## --subscribe
``` shell
busy --subscribe[="URL"] # to subscribe
```
⭐️ EXAMPLE: Active profile will subscribe
``` shell
busy --subscribe="https://somethingcool.co" :1
```  

## --comment
``` shell
busy --comment="comment text" --url=["URL"] # to comment specific URL
```
☝️ TIP: option --comment without value will use default comment from database  
⭐️ EXAMPLE: Active profile will comment "good to know" in post from group _bleblegroup_ in _socialfrance.eu_
``` shell
busy --comment="good to know" --url="socialfrance.eu/groups/bleblegroup/post/0192837465"
```  

## --cron
``` shell
busy --cron[=on|=off|=status] # to operate in crontab
```

## --db
``` shell
busy --db[=add] --table[="database.table"] # add table in database
```
``` shell
busy --db[=drop] --table[="database.table"] # drop table in database
```
``` shell
busy --db[=add] --table[="database.table"] --data=["data_to_add"] # add record in database
```
``` shell
busy --db[=delete] --record[="database.table.record"] # delete record in database
```
``` shell
busy --db[=show] --table[="database.table.record"] # show records in database
```
⭐️ EXAMPLE: Add record with specific data into _fb_friends_ table
``` shell
busy --db=add --table="roy_visar_db.fb_friends" --data="001,Roy Visar,http://portal.url/profile,data1,data2"
```  
⭐️ EXAMPLE: Update record to specific data in _fb_friends_ table in _roy_visar_db_ database
``` shell
busy --db=update --table="roy_visar_db.fb_friends.2345" --data="Roy Visar,data2"
```  

# system
## --clip-clear
``` shell
busy --clip-clear|-cc # clip clear in default DISPLAY
```

## --restart
``` shell
busy --restart :5 # retart DISPLAY:5
busy --restart=all # restart all
```

## --screen
``` shell
busy --screen=status # clip clear
busy --screen=on --cmd="htop" # run _htop_ in screen session
```

# INSTALL
1. Install minimal Debian 10 Buster in  [VirtualBox](https://www.virtualbox.org/wiki/Downloads), just base, skip everything,  
ISO CD image from official website
[debian.org/debian-10.4.iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.4.0-amd64-netinst.iso) << 336MB direct link
2. Run bellow script in fresh terminal console  
 (all main software will be installed from official Debian repository)
 ``` shell
 wget busy4.me/initiv && bash ./initiv install
 ```
[...See more](https://github.com/busy4me/busy/wiki)  

``` shell
wget busy4.me/init-0 && bash ./init-0
```

# NOTES
🔥 Hot: last update  
⚠️ Caution: use carefully  

# Wiki
[busy4me Wiki 🚧 Under construction](https://github.com/busy4me/busy/wiki)
