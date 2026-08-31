"""Module providing Step Methods for Edit Screen"""
from behave import step # type: ignore (remove IDE warning about step)
from features.context import Context


@step('I change all the fields to {value}')
def change_everything(context: Context, value):
    """iterate rows of table"""
    context.edit_screen.change_all_to(value)

@step('I change all the colour fonts to {value}')
def change_only_fonts(context: Context, value):
    """iterate rows of table"""
    context.edit_screen.change_only_fonts(value)

@step('I change all fonts size to {value}')
def step_change_font_size(context: Context, value):
    """Change all font size"""
    context.edit_screen.change_all_font(value)
