"""Module providing Environment Setup/TearDown"""
from datetime import datetime
import glob
import os

import allure
from testui.support.appium_driver import NewDriver
from allure_commons.types import AttachmentType
from allure_behave.hooks import allure_report
from context import Context

from features.screens_ios.main_screen import IOSKitMainScreen
from features.screens_ios.login_screen import IOSKitLoginScreen
from features.screens_ios.edit_screen import IOSKitEditScreen
from features.screens_ios.push_notification_screen import IOSKitPushScreen

from features.utils.install_apps import (
    install_locally,
    load_config,
    start_ios_simulator,
    stop_ios_simulator,
)

device = os.getenv('DEVICE', 'ios').lower()


def before_all(_context):
    """Before all - Cleaning artifacts folder"""
    reports = glob.glob('features/artifacts/reports/*')
    screenshots = glob.glob('features/artifacts/screenshots/*')
    for folder in (reports, screenshots):
        for file in folder:
            try:
                os.remove(file)
            except OSError:
                pass

    if not os.path.exists('features/artifacts/screenshots'):
        os.makedirs('features/artifacts/screenshots', exist_ok=True)

    config = load_config(device)
    if "ios" in device:
        start_ios_simulator(udid=config.get('udid', ''))
    else:
        raise ValueError(f"Unsupported device: {device}. Only iOS is supported in this repo.")


def before_scenario(context: Context, scenario):
    """SetUP Fixtures for Test Scenarios Execution"""
    print(f'-- Start Scenario: {scenario} --')
    config = load_config(device)

    if "ios" not in device:
        raise ValueError(f"Unsupported device: {device}. Only iOS is supported in this repo.")

    print('-- (Re)installing app --')
    install_locally()

    context.driver = (
        NewDriver()
        .set_full_reset(True)
        .set_platform('ios')
        .set_bundle_id(config['bundle_id'])
        .set_appium_url(config['appium_url'] if 'appium_url' in config else None)  # type: ignore
        .set_extra_caps({
            "df:build": str(scenario),
            "appium:processArguments": {"args": ["-UITests"]},
        })
        .set_udid(config.get('udid', ''))
        .set_version("")
        .set_logger("behave")
        .set_appium_driver()
    )
    context.login_screen = IOSKitLoginScreen(context.driver)
    context.main_screen = IOSKitMainScreen(context.driver)
    context.edit_screen = IOSKitEditScreen(context.driver)
    context.push_screen = IOSKitPushScreen(context.driver)

    context.driver.configuration.save_full_stacktrace = False
    try:
        el = context.driver.e("accessibility", "signOutButton")
        if el.is_visible_in(1):
            el.click()
    except Exception:
        print("Already logged out")


def after_scenario(context: Context, scenario):
    """TearDown Fixtures for Test Execution"""
    print(f'-- End Scenario: {scenario} --')
    test_datetime = datetime.now().strftime("%d%m%Y%H%M%S")
    screenshot_name = f"{scenario.name}_{scenario.status}_{test_datetime}.png"
    if scenario.status == 'failed' and hasattr(context, 'driver'):
        context.driver.save_screenshot(screenshot_name)
        allure.attach(
            context.driver.get_driver().get_screenshot_as_png(),
            name=screenshot_name,
            attachment_type=AttachmentType.PNG,
        )
    if hasattr(context, 'driver'):
        context.driver.quit()


def after_all(_context):
    """After all - Cleaning up"""
    print('-- End of Test Execution --')
    if "ios" in device:
        stop_ios_simulator(udid=load_config(device).get('udid', ''))


def after_feature(_context, _feature):
    """TearDown Fixtures for Test Execution Feature"""
    allure_report("features/artifacts/reports")
