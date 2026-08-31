import requests
import os
import time

# Load up .env file environment variables. If not already defined
from dotenv import load_dotenv
load_dotenv()

def send_courier_notif(user_id, notification_template: str = "", token=None):
    # Define the URL and the headers
    url = "https://api.courier.com/send"
    if token == None:
        # Fallback to default
        token = os.getenv("COURIER_API_KEY", "")
        if token == "":
            raise Exception("Environment variable COURIER_API_KEY not defined nor token provided as argument for notification send")
    if not isinstance(notification_template, str) or len(notification_template) < 2:
        # Assuming template name should be more than character
        raise Exception("Push notification template name not provided")
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"  # Specify that you are sending JSON data
    }
    # Define the payload as a dictionary
    data = {
        "message": {
            "to": {
                "user_id": user_id
            },
            "template": notification_template,
            "data": {"recipientName": "recipientName"}
        }
    }
    # Send the POST request
    response = requests.post(url, headers=headers, json=data)
    return response


def validate_status_message(message_id, status, timeout=5, interval=0.5, token=None):
    url = f"https://api.courier.com/messages/{message_id}"
    if token == None:
        # Fallback to default
        token = os.getenv("COURIER_API_KEY", "")
        if token == "":
            raise Exception("Environment variable COURIER_API_KEY not defined nor token provided as argument for notification send")
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"  # Specify that you are sending JSON data
    }

    start_time = time.time()
    json_response = None
    while time.time() - start_time < timeout:
        response = requests.get(url, headers=headers)
        json_response = response.json()

        if json_response.get("status") == status:
            return  # Expected status found, exit the method

        time.sleep(interval)

    # After timeout, if the expected status still hasn't been met, raise an exception
    if json_response == None:
        raise Exception("Response from Courier server resulted empty! Cannot check message status.")
    else:
        raise Exception(f"The status was: {json_response.get('status')} \nand we were expecting: {status}")
