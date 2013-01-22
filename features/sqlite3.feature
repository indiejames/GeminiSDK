@ci
Feature: Save Data with SQLite3
  As a Gemini scripter
  I want to save data to an SQLite3 database
  So I can store game state

Scenario: Save Data
  Given I am at the "scene_sqlite3_test" scene
  And screen_compare("sqlite3_test.png")