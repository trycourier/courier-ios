"""Module providing Page Methods and Elements for Part One Page"""
from abc import ABC
from time import sleep
from typing import Optional
from testui.elements.testui_element import e, Elements
from testui.support.testui_driver import TestUIDriver


class CommonLoginScreen(ABC):
    """Main page class and methods"""
    def __init__(self, driver: TestUIDriver):
        self.driver = driver
        self._username_input: Optional[Elements] = None
        self._sign_in_button: Optional[Elements] = None
        # TODO: Move to main screen
        self._inbox_button: Optional[Elements] = None
        self._push_notif_button: Optional[Elements] = None
        # TODO: Check if next elements are required
        # self.inbox_button = e(driver, "accessibility", "inboxButton")
        # self.push_notif_button = e(driver, "accessibility", "pushNotificationsButton")
        # self.notif_req_perm = e(driver, "accessibility", "Request permission")

    # TODO; Check if next code is required
    # @allure.step("Login to inbox with user: {user_name})")
    def login_to_inbox(self, user_name):
        """Taps on part one"""
        if self._username_input is None:
            raise ValueError("_username_input element is not initialized.")
        if self._sign_in_button is None:
            raise ValueError("_sign_in_button element is not initialized.")
        if self._inbox_button is None:
            raise ValueError("_inbox_button element is not initialized.")
        
        # Sometimes input characters are skipped (using clear and verifying after)
        self._username_input.click().clear()
        sleep(3)

        self._username_input.send_keys(user_name)
        if 'Android' in type(self).__name__:
            # Attribute for Android apps
            self._username_input.wait_until_attribute('text', user_name, 5)
        elif 'IOS' in type(self).__name__:
            # Attribute for iOS apps
            self._username_input.wait_until_attribute('value', user_name, 5)
        else:
            raise NotImplementedError("Unsupported method call for username input verification.")
        self._sign_in_button.click()
        # TODO: Move this to main window
        self._inbox_button.click()
        return self

    # @allure.step("Login to push notif with user: {user_name})")
    def login_to_push(self, user_name):
        """Taps on part one"""
        if self._username_input is None:
            raise ValueError("_username_input element is not initialized.")
        if self._sign_in_button is None:
            raise ValueError("_sign_in_button element is not initialized.")
        if self._push_notif_button is None:
            raise ValueError("_push_notif_button element is not initialized.")
        self._username_input.click().clear() # Sometimes input characters are skipped (using clear and verifying after)
        self._username_input.send_keys(user_name)
        if 'Android' in type(self).__name__:
            # Attribute for Android apps
            self._username_input.wait_until_attribute('text', user_name, 5)
        elif 'IOS' in type(self).__name__:
            # Attribute for iOS apps
            self._username_input.wait_until_attribute('value', user_name, 5)
        else:
            raise NotImplementedError("Unsupported method call for username input verification.")
        self._sign_in_button.click()
        # TODO: Move this to main window
        self._push_notif_button.click()
        return self

