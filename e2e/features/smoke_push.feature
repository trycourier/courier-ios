@Push
Feature: Test push notifications

  Background: App is opened
    Given I set login credentials and go to push notifications
    And I allow push notifications

  @ValidateMain @Android @AndroidFlutter @AndroidReactNative @AndroidExpo @iOS
  Scenario: Validation of Firebase push notification
    Then I send a Firebase push notification
    And I validate push notification status: DELIVERED
    Then I click on push notification
    And I validate push notification status: CLICKED

  @ValidateMain @iOS @iOSFlutter @iOSReactNative @iOSExpo
  Scenario: Validation of APNS push notification
    Then I send a APNS push notification
    And I validate push notification status: DELIVERED
    Then I click on push notification
    And I validate push notification status: CLICKED
