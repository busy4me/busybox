#!/usr/bin/env python

import pyautogui, sys, math, random

pyautogui.FAILSAFE = False # disables the fail-safe

# coordinate
sx = 400
sy = 300

ra01 = random.randint(1,3)

if ra01 == 1:
	alfa = 6
	beta = 12
	theta = 24
	r = 25

elif ra01 == 2:
	alfa = 12
	beta = 24
	theta = 6
	r = 20

elif ra01 == 3:
	alfa = 24
	beta = 12
	theta = 6
	r = 25
# pyautogui.moveTo(sx, sy+r, 0.1)

def circle_01 ():
	r = random.randint(15,40)
	for i in range(0, alfa):
		sx, sy = pyautogui.position()
		x = sx+r*math.cos(float(i)*theta)
		y = sy+r*math.sin(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1)

def circle_02 ():
	r = random.randint(5,15)
	for i in range(0, beta):
		sx, sy = pyautogui.position()
		x = sx+r*math.sin(float(i)*theta)
		y = sy+r*math.cos(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1)

def circle_03 ():
	r = random.randint(5,15)
	for i in range(0, theta):
		sx, sy = pyautogui.position()
		x = sx+r*math.cos(float(i)*theta)
		y = sy+r*math.sin(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1)

circle_01()

pyautogui.moveTo(200+(ra01*20), 200, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(550+(ra01*20), 350, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(300+(ra01*20), 200, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(650+(ra01*20), 350, 0.3, pyautogui.easeOutQuad)

pyautogui.moveTo(20+ra01, 17, 0.3, pyautogui.easeOutQuad)
circle_02()
pyautogui.moveTo(70+ra01, 400, 1, pyautogui.easeOutQuad)
circle_03()
