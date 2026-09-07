## Why

When a new user launches Stoa for the first time, they are placed in Athens without contextual guidance on how to navigate, what the three key locations represent (Stoa, Gym, Home), who Zeno is, or how the four Stoic virtues are cultivated. Introducing a mandatory first-time guided tour led by Zeno provides immediate narrative immersion, clarifies game controls, and onboards players into the Stoic practice cycle.

## What Changes

- Add a first-time check and state tracking in `ProgressStore` to identify if the apprentice has completed the tutorial.
- Introduce a reusable classic RPG-style `DialogueBox` UI component with character portraits, speaker names, rich text, and touch/click-to-advance mechanics.
- Introduce a `TutorialGuide` coordinator in the Athens map that manages Zeno's guided tour across the 3 key buildings:
  1. **Greeting & Movement**: Zeno welcomes the Apprentice and prompts basic movement.
  2. **La Stoa**: Introduces philosophical contemplation and Wisdom.
  3. **El Gimnasio**: Introduces daily mental and physical discipline (Courage & Temperance).
  4. **El Hogar**: Introduces daily reflection and self-examination (Justice).
  5. **Graduation**: Completes onboarding, sets initial baseline virtue status, and unlocks free roam.
- Add visual indicators/markers over destination buildings during active tutorial steps.

## Capabilities

### New Capabilities
- `tutorial/first-time-onboarding`: Covers first-time detection, dialogue sequence, building tour state machine, and persistence of completion status.

### Modified Capabilities
<!-- No requirement changes to existing specs -->

## Impact

- **Persistence**: `00_Globals/progress.gd` stores `tutorial_step` and `tutorial_completed`.
- **UI & Scenes**: New `UI/Dialogue/dialogue_box.tscn` (and GDScript), new tutorial coordinator in `Playground` / `Athens`.
- **Dungeons**: `Dungeons/Scripts/dungeon.gd` (and Stoa/Gym/Home) integrate with the tutorial coordinator to trigger step progression upon entry.
- **Controls**: Integrates with keyboard, touch controls, and virtual joystick during the movement introduction.
