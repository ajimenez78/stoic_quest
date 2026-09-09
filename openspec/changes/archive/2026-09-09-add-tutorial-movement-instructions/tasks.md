## 1. Adaptive Tutorial Dialogue Movement Instructions

- [x] 1.1 Update `UI/Dialogue/tutorial_guide.gd` to dynamically build `intro` dialogue lines with adaptive movement explanations for touchscreen vs desktop devices
- [x] 1.2 Verify that starting a new game tutorial shows the movement controls line in Zenón's dialogue

## 2. Path Waypoint Indicator Implementation

- [x] 2.1 Update `UI/Dialogue/tutorial_indicator.gd` and `tutorial_indicator.tscn` to support waypoint mode text (`"✦ Por aquí ✦"`)
- [x] 2.2 Update `UI/Dialogue/tutorial_guide.gd` to instantiate and manage a path waypoint indicator updated in real-time via `NavigationServer2D.map_get_path()` to point to the first visible path point in the camera viewport
- [x] 2.3 Verify that the path waypoint indicator renders correctly along the route to La Stoa, updating as the apprentice moves

## 3. Integration & Verification

- [x] 3.1 Verify GDScript compilation and runtime behavior of tutorial guide and indicators on desktop and mobile viewports
