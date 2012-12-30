Feature: Running a test
  As an iOS developer
  I want to have a sample feature file
  So I can begin testing quickly

Scenario: Example steps
  Given I am at the "scene_rectangle_test" scene
  Then I swipe left
  And I wait until I don't see "Please swipe left"
  #And screenshot("example_screenshot.png")
  And screen_compare("example_steps.png")

Scenario: Draw a circle
  Given I am at the "scene_circle_test" scene
  Then I swipe left
  And I wait until I don't see "Please swipe left"
  #And screenshot("example_screenshot.png")
  And screen_compare("circle_test.png")