@Inbox
Feature: Test inbox

  Background: App is opened
    Given I set login credentials and go to inbox

  @ValidateMain @iOS @Android @AndroidFlutter @iOSFlutter @AndroidReactNative @AndroidExpo @iOSExpo
  Scenario: Validate inbox screen
    And I open and close edit
    Then I validate main screen

  @EditFields @SendNotification @iOS
  Scenario: Change all the fonts sizes for iOS
    And I click on Edit
    And I change all fonts size to 20
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 20.0, font color #000000 and font name Helvetica

  @SendNotification @iOS
  Scenario: Validate send notification and styles iOS
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 14.0, font color #000000 and font name Helvetica

  @EditFields @SendNotification @Android @ValidateStyles
  Scenario: Change all the fonts sizes Android
    Then I validate main screen
    And I click on Edit
    And I change all fonts size to 20
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 20, font color #FF8A0000 and font name default

  @EditFields @SendNotification @AndroidFlutter @ValidateStyles @iOSFlutter
  Scenario: Change all the fonts sizes Android Flutter
    Then I validate main screen
    And I click on Edit
    And I change all fonts size to 20
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 20, font color #000000 and font name Sen_700

  @SendNotification @Android @ValidateStyles
  Scenario: Validate send notification and styles android
    Then I validate main screen
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 16, font color #FF8A0000 and font name default

  @SendNotification @AndroidFlutter @ValidateStyles @iOSFlutter
  Scenario: Validate send notification and styles android flutter
    Then I validate main screen
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 16, font color #000000 and font name Sen_700

  @SendNotification @Archive @iOS @Android @AndroidFlutter @iOSFlutter @iOSReactNative @AndroidReactNative @AndroidExpo @iOSExpo
  Scenario: Send message to Archive
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    Then I archive by long press

  @SendNotification @ReadUnread @iOS @Android @iOSReactNative @AndroidReactNative @AndroidExpo @iOSExpo
  Scenario: Change status to unread and read back
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    Then I change the status to read and unread

  @SendNotification @ReadUnread @AndroidFlutter @iOSFlutter
  Scenario: Change status to unread and read back in flutter
    And I open and close edit
    Then I send a notification
    And I validate notification has arrived
    And I validate the font size 16, font color #000000 and font name Sen_700
    Then I change the status to read and unread
    And I validate the font size 16, font color #000000 and font name Sen_regular

  @SendNotification @iOS @Android @Action @AndroidFlutter @iOSFlutter @iOSReactNative @AndroidReactNative @AndroidExpo @iOSExpo
  Scenario: Validate send notification with action and styles
    Then I validate main screen
    And I open and close edit
    Then I send a notification with action
    And I validate notification has arrived with button
    And I click on notification button

