Feature: homepage
  In order to use the GBOL db
  As an visitor
  I want to be informed about the project

  Scenario: homepage
    Given I am a user
    When I visit the homepage
    Then I should see "GBOL5"
