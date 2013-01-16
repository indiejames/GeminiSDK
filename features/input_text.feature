@ci
Feature: Input Text
  As a User
  I want to input text
  So I can enter information into the game

Scenario: Text Input Focus
  Given I am at the "scene_text_input_test" scene
  Then I touch the object named "test_text"
  And screen_compare("text_input_focus_test.png")