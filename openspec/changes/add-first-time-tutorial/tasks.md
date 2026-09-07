## 1. Persistence & State Management

- [x] 1.1 Update `ProgressStore` in `00_Globals/progress.gd` to include `tutorial_step` and `tutorial_completed` with default values and merge logic, and verify default dictionary creation.
- [x] 1.2 Add helper methods in `ProgressStore` to query tutorial status (`is_tutorial_completed`) and advance tutorial steps (`advance_tutorial_step`).

## 2. Dialogue UI Component

- [x] 2.1 Create the classic RPG `DialogueBox` scene (`UI/Dialogue/dialogue_box.tscn`) and script (`UI/Dialogue/dialogue_box.gd`) with portrait, speaker name, text label, and advance trigger.
- [x] 2.2 Style `DialogueBox` with responsive margins and font scaling for mobile/desktop viewports and verify layout responsiveness.

## 3. Tutorial Coordinator & Tour Integration

- [ ] 3.1 Create `TutorialGuide` coordinator in Athens / Playground to monitor player state, manage Zeno's dialogue script, and handle step transitions.
- [ ] 3.2 Add visual guide indicators / markers over the active destination building during each tutorial stage.
- [ ] 3.3 Hook tutorial entry events into Stoa, Gym, and Home scenes to trigger contextual dialogues upon arrival.
- [ ] 3.4 Implement tutorial completion logic, grant starter virtue baseline, set `tutorial_completed = true`, and verify smooth transition to free roam mode.
