@ci
Feature: Input Text
  As a User
  I want to input text
  So I can enter information into the game

Scenario: Text Input Focus
  Given I am at the "scene_text_input_test" scene
  Then I touch the "type something" input field
  # do this twice to make sure the simulator gets input focus
  Then I touch the "type something" input field
  Then I type Hello world
  Then I should see text containing "Hello world"