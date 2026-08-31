"""Module providing Page Methods and Elements for Main Page"""
from abc import ABC, abstractmethod
from typing import Optional

from requests import Response
from testui.elements.testui_element import Elements
from testui.support.testui_driver import TestUIDriver

from features.screens_common.edit_screen import CommonEditScreen


class CommonMainScreen(ABC):
    """Main page class and methods"""
    def __init__(self, driver: TestUIDriver):
        self.driver = driver
        self._archived_tab: Optional[Elements] = None
        self._edit_button: Optional[Elements] = None
        self._close_button_main: Optional[Elements] = None
        self._inbox_button: Optional[Elements] = None
        self._notification_body: Optional[Elements] = None
        self._notification_button: Optional[Elements] = None
        self._unread_dot: Optional[Elements] = None

    @abstractmethod
    def go_to_edit(self) -> CommonEditScreen:
        """Taps on edit"""
        pass

    @abstractmethod
    def send_notif(self, user_id: str = "", template_inbox: str = "") -> Response:
        """Sends a notification"""
        pass

    @abstractmethod
    def send_action_notif(self, user_id: str = "", template_inbox: str = "") -> Response:
        """Sends a notification"""
        pass

    @abstractmethod
    def validate_notif(self, name: str = "", message: str = "") -> 'CommonMainScreen':
        """Validates the notification"""
        pass

    @abstractmethod
    def validate_notif_with_button(self, name: str = "", message: str = "") -> 'CommonMainScreen':
        """Validates the action notification with a button"""
        pass

    @abstractmethod
    def validate_style(self, font_name: str, font_size: str, font_color: str) -> 'CommonMainScreen':
        """Validates the style of the notification"""
        pass

    def validate_main(self):
        """Validates main screen elements are visible"""
        if self._archived_tab is None:
            raise ValueError("_archived_tab element is not initialized.")
        if self._edit_button is None:
            raise ValueError("_edit_button element is not initialized.")
        self._archived_tab.wait_until_visible()
        self._edit_button.wait_until_visible()
        return self

    def go_to_archived(self):
        """Taps on archived"""
        if self._archived_tab is None:
            raise ValueError("_archived_tab element is not initialized.")
        self._archived_tab.click()
        return self

    def close_and_open_inbox(self):
        """Closes the current screen and opens the inbox"""
        if self._close_button_main is None:
            raise ValueError("_close_button_main element is not initialized.")
        if self._inbox_button is None:
            raise ValueError("_inbox_button element is not initialized.")
        self._close_button_main.click()
        self._inbox_button.click()
        return self

    def archive_long_press(self):
        """Taps on edit"""
        if self._notification_body is None:
            raise ValueError("_notification_body element is not initialized.")
        if self._archived_tab is None:
            raise ValueError("_archived_tab element is not initialized.")
        self._notification_body.press_hold_for(2000)
        self._notification_body.no().wait_until_visible()
        self._archived_tab.click()
        self._notification_body.wait_until_visible()
        return self

    def click_notif_button(self):
        """Clicks the notification button"""
        if self._notification_button is None:
            raise ValueError("_notification_button element is not initialized.")
        self._notification_button.click()

    def check_unread_messages(self, number=1):
        """Checks for unread messages"""
        if self._unread_dot is None:
            raise ValueError("_unread_dot element is not initialized.")
        self._unread_dot.wait_until_visible()

    def read_and_unread(self):
        """Marks messages as read and unread"""
        if self._notification_body is None:
            raise ValueError("_notification_body element is not initialized.")
        if self._unread_dot is None:
            raise ValueError("_unread_dot element is not initialized.")
        self.check_unread_messages()
        self._notification_body.click()
        self._unread_dot.no().wait_until_visible()
        self._notification_body.click()
        self.check_unread_messages()

