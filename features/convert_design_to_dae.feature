Feature: convert Floorplanner design to COLLADA
  As a programmer
  I want to convert Design to COLLADA
  So that I can output valid COLLADA document

  Scenario:
    Given FML document xml/demo-plans.fml
    And Design ID 18491189
    When I call to_dae method on Floorplanner::Design instance
    Then it should return COLLADA document as String
    And the document should contain Walls
    And the document should contain same count of Areas
    And the document should contain sun
    And the document should be valid
