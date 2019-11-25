#!/usr/bin/env python 

import pyautogui, time, sys, math, random
from time import sleep
import numpy
import imutils
import cv2

# list of pictures to find on the screen
list = ['/opt/busy4me/fb/img/cross_chat.png', '/opt/busy4me/fb/img/cross_chat2.png', '/opt/busy4me/fb/img/cross_chat3.png', '/opt/busy4me/fb/img/chat_icon.png']

# click on the first chat person
def click_chat_icon ():
    chat_icon = pyautogui.locateOnScreen(list[3], confidence=0.9)
    chat_icon
    imag = list[3]
    print(chat_icon)
    if chat_icon != None:
        chat_icon_x, chat_icon_y = pyautogui.center(chat_icon)
        sys.stdout.write("\033[1;32m") # green print
        print "found %r ... going to click" % imag
        print chat_icon_x, chat_icon_y
        sys.stdout.write("\033[1;0m")
        pyautogui.moveTo(chat_icon_x, chat_icon_y, 2, pyautogui.easeOutQuad)
        pyautogui.moveTo(chat_icon_x-50, chat_icon_y+20, 0.3, pyautogui.easeOutQuad)
        pyautogui.moveTo(chat_icon_x, chat_icon_y, 0.3, pyautogui.easeOutQuad)
        pyautogui.click(chat_icon_x, chat_icon_y) # click on the chat icon
        pyautogui.moveTo(425, 77, 1, pyautogui.easeOutQuad)
        pyautogui.moveTo(491, 167, 1, pyautogui.easeOutQuad)
        pyautogui.moveTo(458, 77, 1, pyautogui.easeOutQuad)
        pyautogui.click(458, 77) # click on the first profile in chat list
        pyautogui.moveTo(chat_icon_x, chat_icon_y, 0.3, pyautogui.easeOutQuad)
    else:
        sys.stdout.write("\033[1;31m") # red print
        print "Someone chatting, not found %r ... going to click" % imag
        sys.stdout.write("\033[1;0m")
        pyautogui.moveTo(679, 14, 1, pyautogui.easeOutQuad)
        pyautogui.moveTo(579, 34, 0.3, pyautogui.easeOutQuad)
        pyautogui.moveTo(679, 14, 0.3, pyautogui.easeOutQuad)
        pyautogui.click(679, 14) # click on the chat icon
        pyautogui.moveTo(425, 77, 1, pyautogui.easeOutQuad)
        pyautogui.moveTo(491, 167, 1, pyautogui.easeOutQuad)
        pyautogui.moveTo(458, 77, 1, pyautogui.easeOutQuad)
        pyautogui.click(458, 77) # click on the first profile in chat list
        pyautogui.moveTo(679, 14, 0.3, pyautogui.easeOutQuad)
        sys.stdout.write("\033[1;32m") # green print

click_chat_icon()

# random mouse movement
def movee ():
    ra01 = random.randint(1,4)
    ra02 = random.randint(4,9)
    for i in range(0, 1):
	    pyautogui.press('pagedown')
	    pyautogui.moveTo(300+(ra01*20), 300+(ra02*30), (ra01*0.1), pyautogui.easeOutQuad)
	    pyautogui.moveTo(300+(ra02*30), 300+(ra01*30), (ra01*0.1), pyautogui.easeOutQuad)

def close_chat_window ():
    count = 0
    while count < 3:
        movee()
	    #img = 'img0'+str(count)
        print (list[count])
        imag = list[count]
        cross = pyautogui.locateOnScreen(imag, confidence=0.9)
        cross
        print cross
        if cross is None:
            sys.stdout.write("\033[1;31m") # red print
            print('Image not found on the screen!')
            print "not found %r" % imag
            sys.stdout.write("\033[1;0m") # reset color
        else:
            sys.stdout.write("\033[1;32m") # green print
            print "Success: found %r" % imag
            cross_x, cross_y = pyautogui.center(cross)
            print cross_x, cross_y
            sys.stdout.write("\033[1;0m")
            r = random.randint(1,9)
            r2 = random.randint(1,9)
            r3 = random.randint(1,9)
            pyautogui.moveTo(cross_x, cross_y, r*0.1, pyautogui.easeOutQuad)
            pyautogui.moveTo(cross_x-180+(r*10), cross_y+5, r2*0.1, pyautogui.easeOutQuad)
            pyautogui.moveTo(cross_x-140+(r*10), cross_y, r3*0.1, pyautogui.easeOutQuad)
            pyautogui.moveTo(cross_x-160, cross_y, r*0.1, pyautogui.easeOutQuad)
            pyautogui.click(cross_x-160, cross_y) # click on the name
            pyautogui.click(cross_x+8, cross_y) # click on the cross
            pyautogui.moveTo(cross_x+8, cross_y)
            pyautogui.moveTo(cross_x-180+(r*30), cross_y, 0.3, pyautogui.easeOutQuad)
            pyautogui.moveTo(300+(r*30), 110+(r*50), 0.2, pyautogui.easeOutQuad)
        count = count + 1

pyautogui.click(5, 5) # click on top of page to activate window

close_chat_window()

for i in range(0, 10):
    r1 = random.randint(1,9)
    sleep(r1*0.1)
    pyautogui.press('down')
    sys.stdout.write("\033[1;36m") # magenta print
    print "'down' %r /" % r1,
    sys.stdout.write("\033[1;0m")
movee()

# random keys
for i in range(0, 10):
    key_list = ['down', 'up']
    r_choice = random.choice(key_list)
    r1 = random.randint(1,9)
    sleep(r1*0.1)
    sys.stdout.write("\033[1;34m") # blue print
    print "'%r' /" % r_choice,
    sys.stdout.write("\033[1;0m")
    for c in range(0, r1):
	    pyautogui.press(r_choice)	
	    if r1 < 5:
	        movee()

# random keys
for i in range(0, 10): 
    key_list = ['down', 'up', 'pagedown', 'pageup']
    r1 = random.randint(1,9)
    r2 = random.randint(0,1)
    sleep(r1*0.1)
    print (key_list[r2]),
    key1 = key_list[r2]
    for c in range(0, r1):
	    pyautogui.press(key1)
    pyautogui.press(key_list[2])
    if r2 == 0:
	    movee()

for i in range(0, 10):
    r1 = random.randint(1,9)
    sleep(r1*0.1)
    pyautogui.press('up')
    print "'up' %r|" % r1,
movee()
	
for i in range(0, 20):
    pyautogui.press('up')
    pyautogui.press('home')
print "key 'up' x 20 & 'home'"
