@ci
Feature: Pan and Zoom Camera
  As a Gemini scripter
  I want to pan and zoom the camera
  So I can make cool camera effects

Scenario: Pan and Zoom
  Given I am at the "scene_pan_and_zoom_test" scene
  Then I wait for 6.5 seconds
  And screen_compare("pan_and_zoom_test.png")