from abc import ABC, abstractmethod
from typing import Optional
from testui.elements.testui_element import e, Elements
from testui.support.testui_driver import TestUIDriver

class CommonEditScreen(ABC):
    def __init__(self, driver: TestUIDriver):
        self.driver = driver
        self._close_button: Optional[Elements] = None
        self._save_button: Optional[Elements] = None

        # TODO: Add further vars
        self._all_font_size_input: Optional[Elements] = None
        # self._tab_indicator_color_input = e(driver, "accessibility", "tabIndicatorColorInput")
        # self._tab_selected_font_name_input = e(driver, "accessibility", "tabSelectedFontNameInput")
        # self._tab_selected_font_color_input = e(driver, "accessibility", "tabSelectedFontColorInput")
        # self._tab_selected_indicator_font_name_input = e(driver, "accessibility", "tabSelectedIndicatorFontNameInput")
        # self._tab_selected_indicator_font_color_input = e(driver, "accessibility", "tabSelectedIndicatorFontColorInput")
        # self._tab_selected_indicator_color_input = e(driver, "accessibility", "tabSelectedIndicatorColorInput")
        # self._tab_unselected_font_name_input = e(driver, "accessibility", "tabUnselectedFontNameInput")
        # self._tab_unselected_font_color_input = e(driver, "accessibility", "tabUnselectedFontColorInput")
        # self._tab_unselected_indicator_font_name_input = e(driver, "accessibility", "tabUnselectedIndicatorFontNameInput")
        # self._tab_unselected_indicator_font_color_input = e(driver, "accessibility", "tabUnselectedIndicatorFontColorInput")
        # self._tab_unselected_indicator_color_input = e(driver, "accessibility", "tabUnselectedIndicatorColorInput")
        # self._reading_swipe_action_read_icon_input = e(driver, "accessibility", "readingSwipeActionReadIconInput")
        # self._reading_swipe_action_read_color_input = e(driver, "accessibility", "readingSwipeActionReadColorInput")
        # self._reading_swipe_action_unread_icon_input = e(driver, "accessibility", "readingSwipeActionUnreadIconInput")
        # self._reading_swipe_action_unread_color_input = e(driver, "accessibility", "readingSwipeActionUnreadColorInput")
        # self._archiving_swipe_action_archive_icon_input = e(driver, "accessibility", "archivingSwipeActionArchiveIconInput")
        # self._archiving_swipe_action_archive_color_input = e(driver, "accessibility", "archivingSwipeActionArchiveColorInput")
        # self._unread_indicator_style_input = e(driver, "accessibility", "unreadIndicatorStyleInput")
        # self._unread_indicator_color_input = e(driver, "accessibility", "unreadIndicatorColorInput")
        # self._title_style_unread_font_name_input = e(driver, "accessibility", "titleStyleUnreadFontNameInput")
        # self._title_style_unread_font_color_input = e(driver, "accessibility", "titleStyleUnreadFontColorInput")
        # self._time_style_unread_font_name_input = e(driver, "accessibility", "timeStyleUnreadFontNameInput")
        # self._time_style_unread_font_color_input = e(driver, "accessibility", "timeStyleUnreadFontColorInput")
        # self._time_style_read_font_name_input = e(driver, "accessibility", "timeStyleReadFontNameInput")
        # self._time_style_read_font_color_input = e(driver, "accessibility", "timeStyleReadFontColorInput")

    def close_edit_window(self):
        """Closes the edit window"""
        if self._close_button is None:
            raise ValueError("_close_button element is not initialized.")
        self._close_button.click()

    def scroll_to_visible(self, element: Elements):
        size = self.driver.get_driver().get_window_size()
        start_y = size['height'] * 0.5
        end_y = size['height'] * 0.44
        start_x = size['width'] * 0.5
        end_x = size['width'] * 0.5

        for i in range(30):
            if not element.is_visible():
                actions = self.driver.actions()
                actions.w3c_actions.pointer_action.move_to_location(x=start_x, y=start_y)
                actions.w3c_actions.pointer_action.pointer_down()
                actions.w3c_actions.pointer_action.move_to_location(x=end_x, y=end_y)
                actions.w3c_actions.pointer_action.release()
                actions.perform()
            else:
                return
    
    def change_all_font(self, size):
        if self._save_button is None:
            raise ValueError("_save_button element is not initialized.")
        if self._all_font_size_input is None:
            raise ValueError("_all_font_size_input element is not initialized.")
        self._all_font_size_input.wait_until_visible().clear().send_keys(size)
        self._save_button.click()
        self.close_edit_window()

    # TODO: Clean code below
    def change_all_to(self, style):
        # Iterate through class attributes
        for attr_name, input_field in vars(self).items():
            # Check if the attribute name starts with double underscore (private)
            if attr_name.startswith('_EditScreen__'):
                # @allure.step("change value to element '{element}': {value})")
                def enter_input(element, value):
                    if self._save_button is None:
                        raise ValueError("_save_button element is not initialized.")
                    input_field.clear().send_keys(value)
                    self._save_button.click()

                enter_input(attr_name, style)
        self.close_edit_window()

    def change_only_fonts(self, style):
        # Iterate through class attributes
        for attr_name, input_field in vars(self).items():
            # Check if the attribute name starts with double underscore (private)
            if attr_name.startswith('_EditScreen__') and "font_color" in attr_name:
                # @allure.step("change value to element '{element}': {value})")
                def enter_input(element, value):
                    if self._save_button is None:
                        raise ValueError("_save_button element is not initialized.")
                    self.scroll_to_visible(input_field)
                    input_field.clear().send_keys(value)
                    self._save_button.click()

                enter_input(attr_name, style)
        self.close_edit_window()
