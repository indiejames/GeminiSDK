@ci
Feature: Save High Score with ICE and JSON
  As a Gemini scripter
  I want to save and retrieve high scores
  So I can make cool games

Scenario: Save High Score
  Given I am at the "scene_ice_test" scene
  And screen_compare("ice_test.png")