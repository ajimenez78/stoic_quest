## Why

In `UI/Dialogue/tutorial_indicator.gd`, `@onready var label: Label = $Container/Label` referenced `$Container/Label`, but in `tutorial_indicator.tscn` the Label node is located at `$Container/Panel/Margin/Label`. This caused a runtime node path error: `Node not found: "Container/Label"`.

## What Changes

- Update `@onready var label: Label` in `tutorial_indicator.gd` to `$Container/Panel/Margin/Label`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
<!-- None (pure node path fix, skip_specs: true) -->

## Impact

- **Affected Code**: `UI/Dialogue/tutorial_indicator.gd`
- **Behavior**: Fixes `TutorialIndicator` node lookup during tutorial guide initialization.
