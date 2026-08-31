"""Module providing Step Methods for Main Screen"""
from behave import step # type: ignore (remove IDE warning about step)
from features.context import Context
import uuid

user_name = ""
response = None

@step('I set login credentials and go to inbox')
def login_to_inbox(context: Context):
    """ Click On Parts """
    global user_name
    user_name = "test-" + str(uuid.uuid4())
    context.login_screen.login_to_inbox(user_name)

@step('I set login credentials and go to push notifications')
def login_to_push(context: Context):
    """ Click On Parts """
    global user_name
    user_name = "test-" + str(uuid.uuid4())
    context.login_screen.login_to_push(user_name)

@step('I allow push notifications')
def allow_push_notif(context: Context):
    """ Click On Parts """
    context.push_screen.allow_push_notif()

@step('I send a notification')
def step_send_notif(context: Context):
    """iterate rows of table"""
    context.main_screen.send_notif(user_name)

@step('I send a notification with action')
def step_send_action_notif(context: Context):
    """iterate rows of table"""
    context.main_screen.send_action_notif(user_name)

@step('I send a Firebase push notification')
def step_send_push_notif(context: Context):
    """Send Firebase push notification for current device"""
    global response
    response = context.push_screen.send_firebase_push_notif(user_name)

@step('I send a APNS push notification')
def step_send_push_notif(context: Context):
    """Send Firebase push notification for current device"""
    global response
    response = context.push_screen.send_apns_push_notif(user_name)

@step('I click on push notification')
def step_click_on_push_notif(context: Context):
    """iterate rows of table"""
    context.push_screen.click_push_notif()


@step('I validate push notification status: {status}')
def step_validate_push_notif_status(context: Context, status):
    """iterate rows of table"""
    global response
    if response == None:
        raise ValueError("There is no response to check!")
    context.push_screen.validate_status_message(response['requestId'], status)

