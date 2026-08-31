"""Module providing Page Methods and Elements for Part One Page"""
from testui.elements.testui_element import e, Elements
import allure
from testui.support.testui_driver import TestUIDriver

from features.screens_common.login_screen import CommonLoginScreen


class IOSKitLoginScreen(CommonLoginScreen):
    """Main page class and methods"""
    def __init__(self, driver: TestUIDriver):
        self.driver = driver
        self._username_input = e(driver, "accessibility", "usernameInput")
        self._sign_in_button = e(driver, "accessibility", "signInButton")
        self._inbox_button = e(driver, "accessibility", "inboxButton")
        self._push_notif_button = e(driver, "accessibility", "pushNotificationsButton")

