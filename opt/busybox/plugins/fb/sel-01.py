#!/usr/bin/env python

SCRIPT = "sel-01.py"
VERSION = "1.0.0"

import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import unittest

class LoginTest(unittest.TestCase):

def setUp(self):
    self.driver = webdriver.Firefox()
    self.driver.get("https://www.facebook.com/")

def test_Login(self):
    driver = self.driver
    facebookUsername = "username@emailprovider.cox"
    facebookPassword = ""
    emailFieldID = "email"
    passFieldID = "pass"
    loginButtonXpath = "//input[@value='Log In']"
    facebookLogo = "/html/body/div/div[1]/div/div/div/div[1]/div/h1/a"

    emailFieldElement = WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_id(emailFieldID))
    passFieldElement = WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_id(passFieldID))
    loginButtonElement = WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_xpath(loginButtonXpath))

    emailFieldElement.clear()
    emailFieldElement.send_keys(facebookUsername)
    passFieldElement.clear()
    passFieldElement.send_keys(facebookPassword)
    loginButtonElement.click()
    WebDriverWait(driver, 20).until(lambda driver: driver.find_element_by_xpath(facebookLogo))

def tearDown(self):
    self.driver.quit()

if name == 'main':
unittest.main()
