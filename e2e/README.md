# End-to-end UI tests

Behave + Appium + Py-TestUI suite that drives the iOS `Example/` app on a
simulator and validates inbox, push, and theme-edit flows against the live
Courier API.

This suite was ported from [`trycourier/mobile-automation-tests`](https://github.com/trycourier/mobile-automation-tests).
The Python step layout, screen base classes, and scenario tags are intentionally
preserved so existing test patterns carry over.

## Layout

```
e2e/
├── features/
│   ├── smoke.feature             Inbox scenarios
│   ├── smoke_push.feature        Push scenarios
│   ├── config.json               Device → bundle id / scheme / udid
│   ├── environment.py            Behave before/after hooks
│   ├── context.py                Typed Behave context
│   ├── steps/                    Step definitions
│   ├── screens_common/           Abstract page objects
│   ├── screens_ios/              iOS UIKit selectors (Example app)
│   └── utils/
│       ├── courier_api.py        /send + status polling
│       └── install_apps.py       xcodebuild + simctl install
├── scripts/prepare_runner.sh
├── requirements.txt
└── .env.example
```

The suite drives the Example app in **UI-tests mode** — launched with a
`-UITests` process argument. That mode exposes a simplified auth screen plus
a "components" hub with the accessibility identifiers the tests look for
(`usernameInput`, `signInButton`, `inboxButton`, etc.).

## Local run

Prereqs:
- Xcode + an iOS simulator
- Python 3.10+
- An Appium server reachable at the default `http://127.0.0.1:4723` (or set
  `appium_url` in `features/config.json`)

```bash
cd e2e
cp .env.example .env             # then fill COURIER_API_KEY (and friends)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Point at a booted simulator
export IOS_UDID="$(xcrun simctl list devices booted | awk '/iPhone/ {print $NF}' | tr -d '()' | head -1)"

DEVICE=ios python -m behave features -t @iOS
```

Artifacts (screenshots + Allure JSON) land in `features/artifacts/`.

## Required env vars / secrets

| Variable | Purpose |
|---|---|
| `COURIER_API_KEY` | Used by `utils/courier_api.py` to call `/send` and poll message status |
| `COURIER_AUTH_KEY` | Written into `Example/Example/Env.swift` so the Example app can mint JWTs at sign-in. Falls back to `COURIER_API_KEY` if unset |
| `IOS_UDID` | Simulator UDID to target (overrides `features/config.json`) |
| `DEVICE` | Config key in `features/config.json` (default `ios`) |
| `COURIER_USER_ID`, `COURIER_CLIENT_KEY`, `COURIER_BRAND_ID`, `COURIER_PREFERENCE_TOPIC_ID`, `COURIER_MESSAGE_TEMPLATE_ID` | Optional — also written to `Env.swift` for the broader Example app surface |

## Courier template IDs used

These template IDs are baked into `features/screens_ios/`:

| Template | Where | Purpose |
|---|---|---|
| `YV8XBE4N4X438RG0WT3Q42HSPQR7` | `main_screen.send_notif` | Inbox message body |
| `4Z2A89Q7F149SHPP45YFB8C1WSYA` | `main_screen.send_action_notif` | Inbox + "Click Here" button |
| `J5VKSSE0PXMFWFQAAZN7BBRZE49V` | `push_notification_screen.send_firebase_push_notif` | Firebase push |
| `J08YK1WN2YMY6APMK1Q26JMK61ZE` | `push_notification_screen.send_apns_push_notif` | APNS push |

The Courier workspace that `COURIER_API_KEY` points at must have all four
templates published.

## Tags

Run a subset with Behave tags:

```bash
DEVICE=ios python -m behave features -t @iOS              # all iOS inbox scenarios
DEVICE=ios python -m behave features -t @iOS -t @Push     # iOS push only
DEVICE=ios python -m behave features -t @ValidateMain     # smoke
```
