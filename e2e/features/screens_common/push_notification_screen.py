from abc import ABC, abstractmethod
from typing import Optional
from testui.support.testui_driver import TestUIDriver
from testui.elements.testui_element import Elements
from features.utils.courier_api import validate_status_message

class CommonPushScreen(ABC):
    def __init__(self, driver: TestUIDriver):
        self.driver = driver
        self._notif_body: Optional[Elements] = None
        self._notif_req_perm: Optional[Elements] = None

    @abstractmethod
    def send_push_notif(self, user_id: str) -> dict:
        """Sends a push notification"""
        pass

    def send_firebase_push_notif(self, user_id: str, template_id: str = ""):
        raise NotImplementedError("Firebase specific push notification not implemented!")
    
    def send_apns_push_notif(self, user_id: str, template_id: str = ""):
        raise NotImplementedError("APNS specific push notification not implemented!")

    def allow_push_notif(self):
        if self._notif_req_perm is None:
            raise ValueError("_notif_req_perm element is not initialized.")
        self._notif_req_perm.wait_until_visible().click()
        import time
        time.sleep(2)
        return self

    def validate_status_message(self, message_id, status, timeout=5, interval=0.5):
        validate_status_message(message_id, status, timeout, interval)

    def click_push_notif(self):
        if self._notif_body is None:
            raise ValueError("_notif_body element is not initialized.")
        self._notif_body.click()
        return self
