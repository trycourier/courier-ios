"""Module providing Page Methods and Elements for Main Page"""
from testui.elements.testui_element import e
from features.screens_common.edit_screen import CommonEditScreen


class IOSKitEditScreen(CommonEditScreen):
    """Main page class and methods"""
    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver
        self._close_button = e(driver, "classChain", '**/XCUIElementTypeStaticText[`name == "Close"`][2]')
        self._save_button = e(driver, "accessibility", "Save")

        self._all_font_size_input = e(driver, "accessibility", "allFontSizeInput")
        self._tab_indicator_color_input = e(driver, "accessibility", "tabIndicatorColorInput")
        self._tab_selected_font_name_input = e(driver, "accessibility", "tabSelectedFontNameInput")
        self._tab_selected_font_color_input = e(driver, "accessibility", "tabSelectedFontColorInput")
        self._tab_selected_indicator_font_name_input = e(driver, "accessibility", "tabSelectedIndicatorFontNameInput")
        self._tab_selected_indicator_font_color_input = e(driver, "accessibility", "tabSelectedIndicatorFontColorInput")
        self._tab_selected_indicator_color_input = e(driver, "accessibility", "tabSelectedIndicatorColorInput")
        self._tab_unselected_font_name_input = e(driver, "accessibility", "tabUnselectedFontNameInput")
        self._tab_unselected_font_color_input = e(driver, "accessibility", "tabUnselectedFontColorInput")
        self._tab_unselected_indicator_font_name_input = e(driver, "accessibility", "tabUnselectedIndicatorFontNameInput")
        self._tab_unselected_indicator_font_color_input = e(driver, "accessibility", "tabUnselectedIndicatorFontColorInput")
        self._tab_unselected_indicator_color_input = e(driver, "accessibility", "tabUnselectedIndicatorColorInput")
        self._reading_swipe_action_read_icon_input = e(driver, "accessibility", "readingSwipeActionReadIconInput")
        self._reading_swipe_action_read_color_input = e(driver, "accessibility", "readingSwipeActionReadColorInput")
        self._reading_swipe_action_unread_icon_input = e(driver, "accessibility", "readingSwipeActionUnreadIconInput")
        self._reading_swipe_action_unread_color_input = e(driver, "accessibility", "readingSwipeActionUnreadColorInput")
        self._archiving_swipe_action_archive_icon_input = e(driver, "accessibility", "archivingSwipeActionArchiveIconInput")
        self._archiving_swipe_action_archive_color_input = e(driver, "accessibility", "archivingSwipeActionArchiveColorInput")
        self._unread_indicator_style_input = e(driver, "accessibility", "unreadIndicatorStyleInput")
        self._unread_indicator_color_input = e(driver, "accessibility", "unreadIndicatorColorInput")
        self._title_style_unread_font_name_input = e(driver, "accessibility", "titleStyleUnreadFontNameInput")
        self._title_style_unread_font_color_input = e(driver, "accessibility", "titleStyleUnreadFontColorInput")
        self._time_style_unread_font_name_input = e(driver, "accessibility", "timeStyleUnreadFontNameInput")
        self._time_style_unread_font_color_input = e(driver, "accessibility", "timeStyleUnreadFontColorInput")
        self._time_style_read_font_name_input = e(driver, "accessibility", "timeStyleReadFontNameInput")
        self._time_style_read_font_color_input = e(driver, "accessibility", "timeStyleReadFontColorInput")
