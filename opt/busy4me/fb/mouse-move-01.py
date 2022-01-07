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
	r = random.randint(80,150)
	for i in range(0, theta):
		sx, sy = pyautogui.position()
		x = sx+r*math.cos(float(i)*theta)
		y = sy+r*math.sin(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.05, pyautogui.easeOutQuad)

def circle_02 ():
	r = random.randint(50,150)
	for i in range(0, theta):
		sx, sy = pyautogui.position()
		x = sx+r*math.sin(float(i)*theta)
		y = sy+r*math.cos(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1, pyautogui.easeOutQuad)

def circle_03 ():
	r = random.randint(50,150)
	for i in range(0, beta):
		sx, sy = pyautogui.position()
		x = sx+r*math.cos(float(i)*theta)
		y = sy+r*math.sin(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1, pyautogui.easeOutQuad)

pyautogui.moveTo(160+(ra01*20), 17, 0.4, pyautogui.easeOutQuad)
circle_02()
pyautogui.moveTo(210+(ra01*20), 400, 1, pyautogui.easeOutQuad)
circle_03()
circle_01()

#pyautogui.moveTo(sx, sy, 0.4, pyautogui.easeOutQuad)
circle_01()
circle_01()
circle_02()
circle_03()

pyautogui.moveTo(700+(ra01*20), 250, 0.2, pyautogui.easeOutQuad)
pyautogui.moveTo(450+(ra01*20), 250, 0.2, pyautogui.easeOutQuad)
pyautogui.moveTo(700+(ra01*20), 200, 0.2, pyautogui.easeOutQuad)
pyautogui.moveTo(550+(ra01*20), 300, 0.2, pyautogui.easeOutQuad)
