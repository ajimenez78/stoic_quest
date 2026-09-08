## Why

In `00_Globals/playground.gd`, `_setup_tutorial_guide()` instantiates a generic `Node.new()` and assigns it to `tutorial_guide`, which is statically typed as `TutorialGuide`. Godot 4 / GDScript 2.0 throws a runtime error: `Trying to assign value of type 'Node' to a variable of type 'tutorial_guide.gd'.`

## What Changes

- Instantiate `TutorialGuide` directly using `TutorialGuide.new()` or loading/casting the script, matching its static type annotation.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
<!-- None (pure GDScript bug fix, skip_specs: true) -->

## Impact

- **Affected Code**: `00_Globals/playground.gd`
- **Behavior**: Resolves GDScript type mismatch runtime error during `Playground` initialization.
