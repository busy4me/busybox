#!/usr/bin/env python3
SCRIPT = "fb-save-links-sel.py"
VERSION = "0.0.190210"

import pyautogui, sys, math, random, time, subprocess
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

SPOT01url = "https://fb.com"
profile_name = "me"
profile_settings_url = SPOT01url + "/settings"
profile_about_url = SPOT01url + "/me/about"
profile_fanpages_url = SPOT01url + "/bookmarks/pages"
my_groups_url = SPOT01url + "/me/groups"
zoom = "75 %"

system_meminfo_before = ""
#subprocess.call([free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')])
print("subprocess... /opt/busy4me/system-meminfo.sh")
subprocess.call(["/opt/busy4me/system-meminfo.sh"])

# read username and password from files
usr_file=open("/opt/busy/fb/fb-login", "r")
if usr_file.mode == 'r':
	usr =usr_file.read()

pwd_file=open("/opt/busy/fb/fb-password", "r")
if pwd_file.mode == 'r':
	pwd =pwd_file.read()
#usr = "login_name"
#pwd = "password"

pyautogui.FAILSAFE = False # disables the fail-safe
pyautogui.hotkey('alt', 'f4')


chrome_options = webdriver.ChromeOptions()
#chrome_options.add_argument("--user-data-dir=/home/busyman/.chromeroot/bu99-fake-chrome-user-chrome-profile2 ");
chrome_options.add_argument("--disk-cache-dir==/home/busyman/.chromeroot/bu99-fake-chrome-user-chrome-profile-cache ");
chrome_options.add_argument("--window-size=825,682 ");
chrome_options.add_argument("--window-position=0,-71 ");
chrome_options.add_argument("--incognito ");
chrome_options.add_argument("--disable-notifications ");
chrome_options.add_argument("--mute-audio ");
chrome_options.add_argument("--disable-device-discovery-notifications ");
chrome_options.add_argument("--no-first-run ");
chrome_options.add_argument("--no-default-browser-check ");
chrome_options.add_argument("--disable-translate ");
chrome_options.add_argument("test-type=browser ");
chrome_options.add_argument("--enable-precise-memory-info ");
chrome_options.add_argument("--disable-popup-blocking ");
chrome_options.add_argument("--disable-default-apps ");
chrome_options.add_argument("--disable-infobars")

driver = webdriver.Chrome(executable_path='/opt/busy/files/chromedriver', chrome_options=chrome_options, service_args=['--verbose', '--log-path=/tmp/chromedriver.log'])

#print SPOT01url
driver.get(SPOT01url)
#print "zoom:" + zoom
driver.execute_script("document.body.style.zoom='75 %'")
#time.sleep(1)

# set zoom to 75%
#pyautogui.keyDown('ctrl')
#pyautogui.press('-', '-', '-')  
#pyautogui.keyUp('ctrl')
pyautogui.hotkey('ctrl', '-')
pyautogui.hotkey('ctrl', '-')
pyautogui.hotkey('ctrl', '-')

# xdotool
subprocess.call(["xdotool", "mousemove", "745", "132"])
print("subprocess... start Zenity info...")
subprocess.call(["zenity", "--info", "--text='Find login... \n\ Open chrome window with facebook ...'", "--timeout", "5"])
#print "end Zenity info"

assert "Facebook" in driver.title
elem = driver.find_element_by_id("email")
elem.send_keys(usr)
time.sleep(1)
elem = driver.find_element_by_id("pass")
elem.send_keys(pwd)
time.sleep(1)
elem.send_keys(Keys.RETURN)

#elem = driver.find_element_by_css_selector(".input.textInput")
#elem.send_keys("Posted using Python's Selenium WebDriver bindings!")
#elem = driver.find_element_by_css_selector("input[value=\"Publicar\"]")
#elem.click()

time.sleep(3)
#driver.close()
#print my_groups_url
driver.get(my_groups_url)

print("subprocess... /opt/busy4me/system-meminfo.sh")
subprocess.call(["/opt/busy4me/system-meminfo.sh"])
