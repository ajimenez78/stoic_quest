## Context

`TutorialIndicator` scene tree in `tutorial_indicator.tscn` is:
- `TutorialIndicator` (Node2D)
  - `Container` (Node2D)
    - `Panel` (PanelContainer)
      - `Margin` (MarginContainer)
        - `Label` (Label)
    - `Arrow` (Label)

## Goals / Non-Goals

**Goals:**
- Update `label` node path in `tutorial_indicator.gd` from `$Container/Label` to `$Container/Panel/Margin/Label`.

**Non-Goals:**
- Modifying UI design or animation of `TutorialIndicator`.

## Decisions

1. **Update `@onready var label` node path to `$Container/Panel/Margin/Label`**
   - *Rationale*: Matches the exact scene node hierarchy defined in `tutorial_indicator.tscn`.

## Risks / Trade-offs

- None.
