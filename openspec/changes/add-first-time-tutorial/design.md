## Context

The game currently starts at `playground.tscn`, loading `Athens` (`Tile Maps/athens.tscn`), `Apprentice`, and `Zeno`. Locations (Stoa, Gym, Home) are `DungeonEntrance` areas that instantiate full-screen overlay scenes via `LevelManager.enter_dungeon()`. Persistence is managed via `ProgressStore` (`00_Globals/progress.gd`) in `user://progress.json`.

## Goals / Non-Goals

**Goals:**
- Provide a responsive, classic RPG dialogue box at the bottom of the viewport that works seamlessly across desktop and mobile screens.
- Implement an event-driven tutorial coordinator (`TutorialGuide`) that tracks pilgrimage steps (`intro` -> `stoa` -> `gym` -> `home` -> `completed`).
- Hook into dungeon entrances/exits to present contextual dialogues inside each building without blocking regular UI interactions after dialogue dismissal.
- Persist tutorial state so returning players are not subjected to repetitive onboarding.

**Non-Goals:**
- Complex branched quest trees or dialogue choices (this tutorial is linear and focused on onboarding).
- Cutscene camera path animations or video pre-renders.

## Decisions

1. **Dialogue Box Component as a CanvasLayer (`UI/Dialogue/dialogue_box.tscn`)**
   - *Rationale*: A `CanvasLayer` at a high layer index (e.g. 110) ensures dialogues render reliably over both the world map and inside dungeons, adapting automatically to viewport resizing.
   - *Alternatives considered*: World-space floating speech bubbles. Rejected because they clip against viewport edges on smaller mobile screens and don't fit the classic RPG feel.

2. **Tutorial State Machine in `ProgressStore`**
   - *Rationale*: Storing `tutorial_step` ("intro", "stoa", "gym", "home", "completed") and `tutorial_completed: bool` inside `user://progress.json` with fallback defaults ensures zero breakages for existing save files.
   - *Alternatives considered*: Ephemeral session-only tutorial. Rejected because if a user closes the app mid-tutorial, progress should be preserved.

3. **Coordination via Signals and LevelManager**
   - *Rationale*: When a player enters a dungeon during the tutorial, `LevelManager` or `TutorialGuide` receives the notification and triggers the appropriate dialogue sequence. Once the dialogue concludes, the user can freely interact with the dungeon and exit back to Athens.

## Risks / Trade-offs

- **[Risk] Input contention with Apprentice movement during dialogue** → *Mitigation*: The dialogue box captures input or pauses apprentice input processing while active, preventing unintended movement clicks.
- **[Risk] Layout clipping on very small mobile screens** → *Mitigation*: Use responsive MarginContainers and scaled typography following Stoa's established `font_scale` conventions.
