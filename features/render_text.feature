@ci
Feature: Render Text With Custom Fonts
  As a Gemini scripter
  I want to render text using custom fonts
  So I can make cool games

Scenario: Draw a Text
  Given I am at the "scene_font_test" scene
  And screen_compare("font_test.png")