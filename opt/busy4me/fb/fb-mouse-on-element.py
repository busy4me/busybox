#!/usr/bin/env python

import pyautogui, time, sys, math, random, os
from time import sleep
import numpy
import imutils
import cv2

pyautogui.FAILSAFE = False # disables the fail-safe

script_dir = os.path.dirname(__file__)
rel_path = "img/"
img_path = os.path.join(script_dir, rel_path)

# list of pictures to find on the screen
list = [img_path+'fb_logo_01.png', img_path+'fb_logo_02.png']

# click on the first chat person
def find_element ():
    print list[0]
    element = pyautogui.locateOnScreen(list[0], confidence=0.9)
    element
    imag = list[0]
    print(element)
    if element != None:
        element_x, element_y = pyautogui.center(element)
        sys.stdout.write("\033[1;32m") # green print
        print "found %r ... element ... what todo?" % imag
        print element_x, element_y
        sys.stdout.write("\033[1;0m")
        pyautogui.moveTo(element_x, element_y, 0.1, pyautogui.easeOutQuad)
        r = random.randint(15,16)
        for i in range(0, 54):
          x = element_x+r*math.cos(float(i)*beta)
          y = element_y+r*math.sin(float(i)*beta)
          ixy = 'i'+'x'+'y'
          print "step %r" % ixy
#		  print "     %r" % x
#		  print "     %r" % y
          pyautogui.moveTo(x, y, 0.1)
#        pyautogui.moveTo(1+(element_x*20), 1+(element_y*30), (element_x*0.1), pyautogui.easeOutQuad)
#        pyautogui.moveTo(element_x-50, element_y+20, 0.3, pyautogui.easeOutQuad)
#        pyautogui.moveTo(element_x+50, element_y, 0.3, pyautogui.easeOutQuad)

    else:
        sys.stdout.write("\033[1;31m") # red print
        print "element not found %r ... move random" % imag
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

# random mouse movement
#def movee ():
#    ra01 = random.randint(1,4)
#    ra02 = random.randint(4,9)
#    for i in range(0, 1):
#	    pyautogui.press('pagedown')
#	    pyautogui.moveTo(200+(ra01*20), 200+(ra02*30), (ra01*0.1), pyautogui.easeOutQuad)
#	    pyautogui.moveTo(200+(ra02*30), 200+(ra01*30), (ra01*0.1), pyautogui.easeOutQuad)

alfa = 6
beta = 12
theta = 24

def circle_01 ():
	r = random.randint(15,16)
	for i in range(0, theta):
#		sx, sy = pyautogui.position()
		x = element_x+r*math.cos(float(i)*beta)
		y = element_y+r*math.sin(float(i)*beta)
		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1)

#movee()
find_element()

#circle_01()
