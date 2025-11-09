#!/usr/bin/env python3
# copyrights Visaroy

import os
script_dir = os.path.dirname(__file__)
rel_path = "fb/img/"
img_path = os.path.join(script_dir, rel_path)

func_name = "\033[1;97m [ FUNC ]"
success = "\033[1;32m\033[1;100m [ SUCCESS ]\033[1;0m\033[1;32m"
ok = "\033[1;32m [ OK ]"
info = "\033[1;94m [ INFO ]"
nok = "\033[1;91m [ NOK ]"
warning = "\033[1;95m [ WARNING ]"
error = "\033[1;91m [ ERROR ]"
nocolor = "\033[1;0m"

# basic colors (rgb order)
bla='\033[0;30m'; rgb000='\033[0;30m'; k='\033[0;30m'; black='\033[0;30m'     # 000 black
blu='\033[0;34m'; rgb001='\033[0;34m'; b='\033[0;34m'; blue='\033[0;34m'      # 001 blue
gre='\033[0;32m'; rgb010='\033[0;32m'; g='\033[0;32m'; green='\033[0;32m'     # 010 green
cya='\033[0;36m'; rgb011='\033[0;36m'; c='\033[0;36m'; cyan='\033[0;36m'      # 011 cyan
red='\033[0;31m'; rgb100='\033[0;31m'; r='\033[0;31m'; red='\033[0;31m'       # 100 red
mag='\033[0;35m'; rgb101='\033[0;35m'; m='\033[0;35m'; magenta='\033[0;35m'   # 101 magenta
yel='\033[0;33m'; rgb110='\033[0;33m'; y='\033[0;33m'; yellow='\033[0;33m'    # 110 yellow
whi='\033[0;97m'; rgb111='\033[0;97m'; w='\033[0;97m'; green='\033[0;97m'     # 111 white
# ligth colors (add letter l before)
lbla='\033[0;90m'; l000='\033[0;90m'; lk='\033[0;90m'; lblack='\033[0;90m'     # 000 light black
lblu='\033[0;94m'; l001='\033[0;94m'; lb='\033[0;94m'; lblue='\033[0;94m'      # 001 light blue
lgre='\033[0;92m'; l010='\033[0;92m'; lg='\033[0;92m'; lgreen='\033[0;92m'     # 010 light green
lcya='\033[0;96m'; l011='\033[0;96m'; lc='\033[0;96m'; lcyan='\033[0;96m'      # 011 light cyan
lred='\033[0;91m'; l100='\033[0;91m'; lr='\033[0;91m'; lred='\033[0;91m'       # 100 light red
lmag='\033[0;95m'; l101='\033[0;95m'; lm='\033[0;95m'; lmagenta='\033[0;95m'   # 101 light magenta
lyel='\033[0;93m'; l110='\033[0;93m'; ly='\033[0;93m'; lyellow='\033[0;93m'    # 110 light yellow
lwhi='\033[0;97m'; l111='\033[0;97m'; lw='\033[0;97m'; lwhite='\033[0;97m'     # 111 light white
