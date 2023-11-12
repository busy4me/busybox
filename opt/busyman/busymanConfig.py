#!/usr/bin/env python3
# copyrights Visaroy

import os
script_dir = os.path.dirname(__file__)
rel_path = "plugins/fb/img/"
img_path = os.path.join(script_dir, rel_path)

func_name = "\033[1;97m[ FUNC ]\033[1;90m"
success = "\033[1;32m\033[1;100m[ SUCCESS ]\033[1;0m\033[1;32m"
ok = "\033[1;92m[ OK ]\033[1;32m"
info = "\033[1;94m[ INFO ]\033[1;0m"
result = "\033[1;96m[ RESULT ]\033[1;36m"
nok = "\033[1;91m[ NOK ]"
warning = "\033[1;95m[ WARNING ]\033[1;35m"
error = "\033[1;91m[ ERROR ]"
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
# dark colors (add letter d before) - dimmed colors
dbla='\033[2;30m'; d000='\033[2;30m'; dk='\033[2;30m'; darkblack='\033[2;30m'     # 000 dark black
dblu='\033[2;34m'; d001='\033[2;34m'; db='\033[2;34m'; darkblue='\033[2;34m'      # 001 dark blue
dgre='\033[2;32m'; d010='\033[2;32m'; dg='\033[2;32m'; darkgreen='\033[2;32m'     # 010 dark green
dcya='\033[2;36m'; d011='\033[2;36m'; dc='\033[2;36m'; darkcyan='\033[2;36m'      # 011 dark cyan
dred='\033[2;31m'; d100='\033[2;31m'; dr='\033[2;31m'; darkred='\033[2;31m'       # 100 dark red
dmag='\033[2;35m'; d101='\033[2;35m'; dm='\033[2;35m'; darkmagenta='\033[2;35m'   # 101 dark magenta
dyel='\033[2;33m'; d110='\033[2;33m'; dy='\033[2;33m'; darkyellow='\033[2;33m'    # 110 dark yellow
dwhi='\033[2;39m'; d111='\033[2;39m'; dw='\033[2;39m'; darkwhite='\033[2;39m'     # 111 dark white (default)
# background colors (add bck before)
bckbla='\033[40m' # 000 background black
bckblu='\033[44m'; backblue='\033[44m'        # 001 background blue
bckgre='\033[42m' # 010 background green
bckcya='\033[46m' # 011 background cyan
bckred='\033[41m' # 100 background red
bckmag='\033[45m' # 101 background magenta
bckyel='\033[43m' # 110 background yellow
bckwhi='\033[107m' # 111 background white
# light background colors (add lbck before)
lbckbla='\033[100m'; lightbackblack='\033[40m'     # 000 light background black
lbckblu='\033[104m'; lightbackblue='\033[44m'        # 001 light background blue
lbckgre='\033[102m'; lightbackgreen='\033[42m'     # 010 light background green
lbckcya='\033[106m'; lightbackcyan='\033[46m'      # 011 light background cyan
lbckred='\033[101m'; lightbackred='\033[41m'       # 100 light background red
lbckmag='\033[105m'; lightbackmagenta='\033[45m'   # 101 light background magenta
lbckyel='\033[103m'; lightbackyellow='\033[43m'    # 110 light background yellow
lbckwhi='\033[107m'; lightbackwhite='\033[107m'     # 111 light background white
