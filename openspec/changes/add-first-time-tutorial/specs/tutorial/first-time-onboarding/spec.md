## Purpose

Guides first-time apprentices through an introductory narrative tour of Athens led by Zeno, familiarizing them with navigation, core locations, and Stoic virtues.

## ADDED Requirements

### Requirement: First-time tutorial detection and progression persistence
The game SHALL detect whether the user has completed the onboarding tutorial upon starting the playground. The tutorial state SHALL persist across sessions until completed.

#### Scenario: First-time launch launches tutorial
- **WHEN** the user opens the game with no saved progress or with `tutorial_completed == false`
- **THEN** the system initiates the tutorial flow at the current saved `tutorial_step`.

#### Scenario: Returning user bypasses tutorial
- **WHEN** the user opens the game and `tutorial_completed == true`
- **THEN** the game starts directly in free roam mode without triggering tutorial cutscenes.

### Requirement: Classic RPG Dialogue Box UI
The system SHALL display an interactive dialogue box overlay at the bottom of the screen with speaker portrait, name, rich text, and touch/click progression.

#### Scenario: Dialogue advancement on input
- **WHEN** a dialogue line is displayed and the user clicks/touches the dialogue box or presses the interaction action
- **THEN** the dialogue box advances to the next sentence or closes if it was the last sentence.

### Requirement: Guided Pilgrimage Across Athens
The tutorial SHALL guide the apprentice sequentially to visit La Stoa, El Gimnasio, and El Hogar, presenting contextual narrative explanations at each landmark.

#### Scenario: Step 1 - Zeno welcome and movement
- **WHEN** the tutorial begins
- **THEN** Zeno greets the apprentice and prompts them to move.

#### Scenario: Step 2 - Visiting La Stoa
- **WHEN** the apprentice enters La Stoa during the tutorial step `stoa`
- **THEN** Zeno explains the purpose of the Stoa and introduces the virtue of Wisdom.

#### Scenario: Step 3 - Visiting El Gimnasio
- **WHEN** the apprentice enters El Gimnasio during the tutorial step `gym`
- **THEN** Zeno explains daily practice, the Dichotomy of Control, and the virtues of Courage and Temperance.

#### Scenario: Step 4 - Visiting El Hogar
- **WHEN** the apprentice enters El Hogar during the tutorial step `home`
- **THEN** Zeno explains the daily journal and the virtue of Justice.

#### Scenario: Step 5 - Tutorial completion and graduation
- **WHEN** the tour of the three locations is concluded
- **THEN** Zeno congratulates the apprentice, `tutorial_completed` is set to `true` in `ProgressStore`, and full free roam is enabled.
