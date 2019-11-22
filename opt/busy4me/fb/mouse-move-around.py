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
	r = random.randint(100,200)
	for i in range(0, beta):
		sx, sy = pyautogui.position()
		x = sx+r*math.sin(float(i)*theta)
		y = sy+r*math.cos(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1)

def circle_03 ():
	r = random.randint(50,300)
	for i in range(0, theta):
		sx, sy = pyautogui.position()
		x = sx+r*math.cos(float(i)*theta)
		y = sy+r*math.sin(float(i)*theta)

		print "step %r" % i
		print "     %r" % x
		print "     %r" % y
		pyautogui.moveTo(x, y, 0.1, pyautogui.easeOutQuad)

pyautogui.moveTo(20, 28, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(750, 25, 3, pyautogui.easeOutQuad)

pyautogui.moveTo(400, 200, 1, pyautogui.easeOutQuad)
circle_01()

pyautogui.moveTo(300, 400, 0.5, pyautogui.easeOutQuad)
circle_02()

pyautogui.moveTo(350, 200, 0.5, pyautogui.easeOutQuad)
circle_03()

pyautogui.moveTo(500, 400, 0.3, pyautogui.easeOutQuad)
circle_01()

pyautogui.moveTo(280, 100, 0.5, pyautogui.easeOutQuad)
circle_02()

pyautogui.moveTo(420, 400, 0.7, pyautogui.easeOutQuad)
circle_03()

pyautogui.moveTo(20, 28, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(750, 25, 3, pyautogui.easeOutQuad)
circle_01()

pyautogui.moveTo(780, 470, 0.7, pyautogui.easeOutQuad)
