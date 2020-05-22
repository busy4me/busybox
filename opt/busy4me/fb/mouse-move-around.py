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
circle_02()
pyautogui.moveTo(280, 100, 0.5, pyautogui.easeOutQuad)
circle_03()
pyautogui.moveTo(420, 400, 0.7, pyautogui.easeOutQuad)
circle_01()

pyautogui.moveTo(20, 28, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(40, 500, 4, pyautogui.easeOutQuad)
pyautogui.moveTo(20, 80, 2, pyautogui.easeOutQuad)
pyautogui.moveTo(50, 480, 2, pyautogui.easeOutQuad)
pyautogui.moveTo(26, 40, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(60, 380, 2, pyautogui.easeOutQuad)
circle_03()
pyautogui.moveTo(500, 400, 0.3, pyautogui.easeOutQuad)
circle_01()
pyautogui.moveTo(280, 100, 0.5, pyautogui.easeOutQuad)
circle_02()
pyautogui.moveTo(420, 400, 0.7, pyautogui.easeOutQuad)
circle_01()
pyautogui.moveTo(20, 28, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(40, 500, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(20, 28, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(40, 500, 0.3, pyautogui.easeOutQuad)

t = random.randint(1,3)
x = random.randint(5,20)
y = random.randint(400,550)
pyautogui.moveTo(x, 28, t, pyautogui.easeOutQuad)
pyautogui.moveTo(40, y, t, pyautogui.easeOutQuad)
pyautogui.moveTo(x, 80, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(50, y, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(x, 40, 2, pyautogui.easeOutQuad)
pyautogui.moveTo(60, y, 3, pyautogui.easeOutQuad)
circle_03()
pyautogui.moveTo(500, 400, 0.4, pyautogui.easeOutQuad)
circle_01()
pyautogui.moveTo(280, 100, 0.6, pyautogui.easeOutQuad)
circle_02()
pyautogui.moveTo(420, 400, 0.8, pyautogui.easeOutQuad)
circle_01()
pyautogui.moveTo(20, 28, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(40, 500, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(20, 28, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(40, 500, 0.3, pyautogui.easeOutQuad)

t = random.randint(1,2)
x = random.randint(650,750)
y = random.randint(5,20)
pyautogui.moveTo(20, 28, t, pyautogui.easeOutQuad)
pyautogui.moveTo(x, y, 3, pyautogui.easeOutQuad)
pyautogui.moveTo(20, 48, t, pyautogui.easeOutQuad)
pyautogui.moveTo(650, y, t, pyautogui.easeOutQuad)
x = random.randint(220,320)
y = random.randint(5,20)
pyautogui.moveTo(x, y, 1, pyautogui.easeOutQuad)
pyautogui.moveTo(670, 25, 1, pyautogui.easeOutQuad)
x = random.randint(220,320)
y = random.randint(5,20)
pyautogui.moveTo(x, y, 0.3, pyautogui.easeOutQuad)
pyautogui.moveTo(690, 25, 0.3, pyautogui.easeOutQuad)

x = random.randint(5,30)
y = random.randint(5,30)
pyautogui.moveTo(x, y, 4, pyautogui.easeOutQuad)
