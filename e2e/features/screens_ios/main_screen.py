"""Module providing Page Methods and Elements for Main Page"""
from testui.elements.testui_element import e
from features.screens_common.main_screen import CommonMainScreen
from features.utils.courier_api import send_courier_notif
from features.screens_ios.edit_screen import IOSKitEditScreen


class IOSKitMainScreen(CommonMainScreen):
    """Main page class and methods"""
    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver
        self._archived_tab = e(driver, "classChain", '**/XCUIElementTypeStaticText[`label CONTAINS "Archived"`]')
        self._edit_button = e(driver, "classChain", '**/XCUIElementTypeButton[`name == "Edit"`]')
        self._close_button_main = e(driver, "accessibility", "Close")
        self._inbox_button = e(driver, "accessibility", "inboxButton")
        # self._notification_title = e(driver, "classChain", '**/XCUIElementTypeStaticText[`name CONTAINS "InboxMessageTitleLabelLabel"`]') # TODO: Check if needed
        self._notification_body = e(driver,"classChain", '**/XCUIElementTypeStaticText[`name CONTAINS "InboxBodyLabel"`]')
        self._notification_button = e(driver, "classChain", '**/XCUIElementTypeButton[`label == "Click Here"`]')
        self._unread_dot = e(driver, "classChain", '**/XCUIElementTypeStaticText[`label == "1"`]')

    def go_to_edit(self):
        """Taps on edit"""
        if self._edit_button is None:
            raise ValueError("Edit button element is not initialized.")
        self._edit_button.click()
        return IOSKitEditScreen(self.driver)
    
    def send_notif(self, user_id="", template_inbox='YV8XBE4N4X438RG0WT3Q42HSPQR7'):
        # Define the URL and the headers
        return send_courier_notif(user_id=user_id, notification_template=template_inbox)
    
    def send_action_notif(self, user_id="", template_inbox='4Z2A89Q7F149SHPP45YFB8C1WSYA'):
        # Define the URL and the headers
        return send_courier_notif(user_id=user_id, notification_template=template_inbox)
    
    def validate_notif(self, name="recipientName", message="This is an example of a Courier Push message sent through Courier\n\nCheers, The Courier Team"):
        """Validates the notification"""
        if self._notification_body is None:
            raise ValueError("Notification body element is not initialized.")
        # TODO: Check if need to verify title
        # self._notification_title.wait_until_visible(20)
        self._notification_body.wait_until_visible(seconds=300).wait_until_contains_attribute('value', message)
        return self

    def validate_notif_with_button(self, name="recipientName", message="This is an example of a Courier Push message sent through Courier\n\nCheers, The Courier Team"):
        """Validates the action notification with a button"""
        if self._notification_body is None:
            raise ValueError("Notification body element is not initialized.")
        if self._notification_button is None:
            raise ValueError("Notification button element is not initialized.")
        self._notification_body.wait_until_visible(seconds=300).wait_until_contains_attribute('value', message)
        self._notification_button.wait_until_visible()
        return self

    def validate_style(self, font_name, font_size, font_color):
        """Validates the style of the notification"""
        if self._notification_body is None:
            raise ValueError("Notification body element is not initialized.")
        #{\n  "properties" : [\n    {\n      "value" : "Avenir-Medium",\n      "name" : "fontName"\n    },\n    {\n      "name" : "fontSize",\n      "value" : "18.0"\n    },\n    {\n      "value" : "#000000",\n      "name" : "fontColor"\n    },\n    {\n      "value" : "inboxBodyLabel",\n      "name" : "component"\n    }\n  ]\n}
        (self._notification_body.wait_until_visible().wait_until_contains_attribute("name", font_name)
         .wait_until_contains_attribute("name", font_size).wait_until_contains_attribute("name", font_color))
        # TODO: Check if next checks required, if not then remove
        # (self._notification_time.wait_until_visible().wait_until_contains_attribute("name", font_name)
        #  .wait_until_contains_attribute("name", font_size).wait_until_contains_attribute("name", font_color))
        # BUG in title: font name and color are different .wait_until_contains_attribute("name", font_name).wait_until_contains_attribute("name", font_size)
        # (self._notification_title.wait_until_visible().wait_until_contains_attribute("name", font_color))
        return self
