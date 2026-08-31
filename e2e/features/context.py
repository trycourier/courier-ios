from behave.runner import Context as BehaveContext
from features.screens_common.edit_screen import CommonEditScreen
from features.screens_common.login_screen import CommonLoginScreen
from features.screens_common.main_screen import CommonMainScreen
from features.screens_common.push_notification_screen import CommonPushScreen
from testui.support.appium_driver import TestUIDriver


class Context(BehaveContext):
    driver: TestUIDriver
    main_screen: CommonMainScreen
    login_screen: CommonLoginScreen
    edit_screen: CommonEditScreen
    push_screen: CommonPushScreen

