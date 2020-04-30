#!/usr/bin/env python

import pyautogui, sys, subprocess, os, commands, time
from PIL import Image
print('Press Ctrl-C to quit.')
def above():
    command = "wmctrl -i -r $(wmctrl -l | grep -i /opt/busy/images/mouse.png | awk '{print $1}') -b add,above",
    os.system("command")

#def mouse_show():
#    command = "xli -delay 1 -fork /opt/busy/images/mouse.png",
#    os.system("command")

def mouse_show():
    command = "feh -x /opt/busy/images/mouse.png",
    os.system("command")

def mouse_move():
    command = "wmctrl -r /opt/busy/images/mouse.png -e 5,50,50,100,100",
    os.system("command")

try:
    while True:
        x, y = pyautogui.position()
        positionStr = 'X: ' + str(x).rjust(4) + ' Y: ' + str(y).rjust(4)
        print positionStr,
        print '\b' * (len(positionStr) + 2),
        sys.stdout.flush(),
#        subprocess.Popen(["xli", "-delay", "1", "-fork", "/opt/busy/images/mouse.png"])
#        wm = subprocess.Popen(["xli", "-delay", "1", "-fork", "/opt/busy/images/mouse.png"])
#        wm.wait()
#        mouse_show()
        above()
#        subprocess.call(["wmctrl", "-i", "-r", "/opt/busy/images/mouse.png", "-b", "add , above"]),
#        subprocess.call(["wmctrl", "-i", "-r", "/opt/busy/images/mouse.png", "-b", "add", "above"]),
        mx = 50
        my = 200
#        movem = subprocess.Popen(["wmctrl", "-r", "/opt/busy/images/mouse.png", "-e", "5,", mx, "50,100,100"])
#        movem.wait()
#        image = Image.open('/usr/share/pixmaps/spin/spin02.gif')
#        image.show()
        time.sleep(1)
except KeyboardInterrupt:
    print '\n'



#xdotool search --sync --onlyvisible --name '/usr/share/pixmaps/spin/spin01.gif' windowactivate
#xdotool search --sync --onlyvisible --name '/opt/busy/images/mouse.png' windowactivate
#wmctrl -i -r $(wmctrl -l | grep -i '/opt/busy/images/mouse.png' | awk '{print $1}') -b add,above
#wmctrl -r "/opt/busy/images/mouse.png" -e 5,50,50,100,100
