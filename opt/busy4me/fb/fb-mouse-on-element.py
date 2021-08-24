#!/usr/bin/env python

import pyautogui, time, sys, math, random, os, getopt, numpy, imutils, cv2
from time import sleep
pyautogui.FAILSAFE = False # disables the fail-safe

script_dir = os.path.dirname(__file__)
rel_path = "img/"
img_path = os.path.join(script_dir, rel_path)

def options(argv):
  element = ''
  action = ''
  try:
     opts, args = getopt.getopt(argv,"he:a:",["element=","action="])
  except getopt.GetoptError:
      print 'usage: fb-mouse-on-element.py -e <element> -a <action>'
      sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
        print '\033[1;32m usage: fb-mouse-on-element.py -e <element> -a <action>\033[1;0m'
        sys.exit()
    elif opt in ("-e", "--element"):
        element = arg
    elif opt in ("-a", "--action"):
        action = arg
  print 'Element to find is:\033[1;32m', element, '\033[1;0m'
  print 'Action to do is:\033[1;33m', action, '\033[1;0m'
  return element, action

options(sys.argv[1:])

# list of pictures to find on the screen
list = [img_path+'fb_logo_01.png', img_path+'fb_logo_02.png', img_path+'800x600-ch75%-button-English(US).png']

element, action = options(sys.argv[1:])

def find_element ():
#  print 'Element to find is:\033[1;32m', element, '\033[1;0m'
#  print 'Action to do is:\033[1;33m', action, '\033[1;0m'
  print list[0]
  element = pyautogui.locateOnScreen(list[0], confidence=0.9)
  element
  imag = list[0]
  print(element)
  if element != None:
        element_x, element_y = pyautogui.center(element)
        print "\033[1;32m ...found: %r element \033[1;33m...what todo?\033[1;0m" % imag
        print element_x, element_y
        sys.stdout.write("\033[1;0m")
        pyautogui.moveTo(element_x, element_y, 0.1, pyautogui.easeOutQuad)
        r = random.randint(15,30)
        for i in range(0, 16):
          x = round(element_x+r*math.cos(float(i)*beta))
          y = round(element_y+r*math.sin(float(i)*beta))
          ixy = i+x+y
          print "step i:%r" %i, "radius r:",r, "x:",x, "y:",y
#		print "     %r" % x
#		print "     %r" % y
          pyautogui.moveTo(x, y, 0.1)
#       pyautogui.moveTo(1+(element_x*20), 1+(element_y*30), (element_x*0.1), pyautogui.easeOutQuad)
#       pyautogui.moveTo(element_x-50, element_y+20, 0.3, pyautogui.easeOutQuad)
#       pyautogui.moveTo(element_x+50, element_y, 0.3, pyautogui.easeOutQuad)

  else:
        sys.stdout.write("\033[1;31m") # red print
        print "element %r not found ... move random" % imag
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
