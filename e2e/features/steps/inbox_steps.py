"""Module providing Step Methods for Main Screen"""
from behave import step # type: ignore (remove IDE warning about step)
from features.context import Context

@step('I validate main screen')
def step_validate_main(context: Context):
    """iterate rows of table"""
    context.main_screen.validate_main()


@step('I click on Archive')
def step_click_archive(context: Context):
    """iterate rows of table"""
    context.main_screen.go_to_archived()

@step('I click on Edit')
def step_click_edit(context: Context):
    """iterate rows of table"""
    context.main_screen.go_to_edit()

@step('I validate notification has arrived')
def step_validate_notif(context: Context):
    """iterate rows of table"""
    context.main_screen.validate_notif()

@step('I validate notification has arrived with button')
def step_validate_notif_with_button(context: Context):
    """iterate rows of table"""
    context.main_screen.validate_notif_with_button()

@step('I reopen the inbox')
def step_reopen_inbox(context: Context):
    """iterate rows of table"""
    context.main_screen.close_and_open_inbox()

@step('I open and close edit')
def step_open_close_edit(context: Context):
    """iterate rows of table"""
    context.main_screen.go_to_edit().close_edit_window()

@step('I validate the font size {font_size}, font color {font_color} and font name {font_name}')
def validate_styles(context: Context, font_size, font_color, font_name):
    """iterate rows of table"""
    context.main_screen.validate_style(font_name, font_size, font_color)


@step('I archive by long press')
def step_archive_long_press(context: Context):
    """iterate rows of table"""
    context.main_screen.archive_long_press()


@step('I change the status to read and unread')
def step_change_status_to_read_unread(context: Context):
    """iterate rows of table"""
    context.main_screen.read_and_unread()


@step('I click on notification button')
def step_click_notif_button(context: Context):
    """iterate rows of table"""
    context.main_screen.click_notif_button()

