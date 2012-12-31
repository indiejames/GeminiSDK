@ci
Feature: Simple Geometry
  As a Gemini scripter
  I want to render simple geometric shapes
  So I can make cool games

Scenario: Draw a rectangle
  Given I am at the "scene_rectangle_test" scene
  And screen_compare("example_steps.png")

Scenario: Draw a circle
  Given I am at the "scene_circle_test" scene
  And screen_compare("circle_test.png")