"""Module providing Page Methods and Elements for Main Page"""
from time import sleep
from testui.elements.testui_element import e
from testui.support.logger import log_info
from features.screens_common.push_notification_screen import CommonPushScreen
from features.utils.courier_api import send_courier_notif

class IOSKitPushScreen(CommonPushScreen):
    """Main page class and methods"""
    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver
        self._notif_title = e(driver, "classChain", '**/XCUIElementTypeStaticText[`name == "NotificationTitle"`]')
        self._notif_body = e(driver, "classChain", '**/XCUIElementTypeStaticText[`name == "TextContent.Primary"`]')
        self._notif_req_perm = e(driver, "accessibility", "Request permission")
        self._allow_req_perm = e(driver, "accessibility", "Allow")

    def send_firebase_push_notif(self, user_id: str, template_id: str = "J5VKSSE0PXMFWFQAAZN7BBRZE49V"):
        return self.send_push_notif(user_id, template_id=template_id)
    
    def send_apns_push_notif(self, user_id: str, template_id: str = "J08YK1WN2YMY6APMK1Q26JMK61ZE"):
        return self.send_push_notif(user_id, template_id=template_id)

    def send_push_notif(self, user_id, template_id=""):
        if self._notif_body is None:
            raise ValueError("_notif_body element is not initialized.")
        if template_id == "":
            raise ValueError("Push notification template ID is not defined")
        # Define the URL and the headers
        self.driver.background_app(-1)
        sleep(3) # There is some issue with clicking on popup
        if self._allow_req_perm.is_visible_in(seconds=20):
            self._allow_req_perm.click()
        response = send_courier_notif(user_id, template_id)
        log_info(str(response.json()))
        self._notif_title.wait_until_visible(seconds=300) # Assuming request takes time to process
        self._notif_body.wait_until_visible()
        sleep(3) # Let Courier dashboard status 
        return response.json()

